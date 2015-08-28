package MetaCPAN::Web::Role::Request;

use utf8;
use Moose::Role;
use Plack::Session;
use JSON::MaybeXS ();
use MetaCPAN::Web::Types qw( PositiveInt );
use Try::Tiny;

use namespace::autoclean;

sub page {
    my $page = shift->parameters->{p};
    return $page && $page =~ /^\d+$/ ? $page : 1;
}

sub session {
    my $self = shift;
    return Plack::Session->new( $self->env );
}

sub get_page_size {
    my $req               = shift;
    my $default_page_size = shift;

    my $page_size = $req->param('size');
    unless ( is_PositiveInt($page_size) && $page_size <= 500 ) {
        $page_size = $default_page_size;
    }
    return $page_size;
}

sub json_param {
    my ( $self, $name ) = @_;
    return try {
        JSON::MaybeXS->new->relaxed->utf8( $self->params_are_decoded ? 0 : 1 )
            ->decode( $self->params->{$name} );
    }
    catch {
        warn "Failed to decode JSON: $_[0]";
        undef;
    };
}

sub params_are_decoded {
    my ($self) = @_;
    return $self->params->{utf8} eq "🐪";
}

1;
