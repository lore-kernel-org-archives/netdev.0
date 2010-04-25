From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: PROBLEM: Linux kernel 2.6.31 IPv4 TCP fails to open huge
	amount of outgoing connections (unable to bind ... )
Date: Sun, 25 Apr 2010 19:35:43 +0300
Message-ID: <20100425163543.GA11831@redhat.com>
References: <1271840535.7895.1612.camel@edumazet-laptop> <20100421095812.GA14778@ioremap.net> <1271849253.7895.1929.camel@edumazet-laptop> <20100421182723.GA17202@ioremap.net> <1271875416.7895.3033.camel@edumazet-laptop> <20100421185837.GB21249@ioremap.net> <1271877975.7895.3171.camel@edumazet-laptop> <20100425142642.GA11411@redhat.com> <20100425155600.GA13319@ioremap.net> <1272212460.2069.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Evgeniy Polyakov <zbr@ioremap.net>,
	Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>,
	Gaspar Chilingarov <gasparch@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32912 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752231Ab0DYRQF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Apr 2010 13:16:05 -0400
Content-Disposition: inline
In-Reply-To: <1272212460.2069.9.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 25, 2010 at 06:21:00PM +0200, Eric Dumazet wrote:
> Le dimanche 25 avril 2010 =E0 19:56 +0400, Evgeniy Polyakov a =E9crit=
 :
> > On Sun, Apr 25, 2010 at 05:26:42PM +0300, Michael S. Tsirkin (mst@r=
edhat.com) wrote:
> >=20
> > > > diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_=
connection_sock.c
> > > > index 0c5e3c3..fb6959c 100644
> > > > --- a/net/ipv6/inet6_connection_sock.c
> > > > +++ b/net/ipv6/inet6_connection_sock.c
> > > > @@ -42,11 +42,16 @@ int inet6_csk_bind_conflict(const struct so=
ck *sk,
> > > >  		if (sk !=3D sk2 &&
> > > >  		    (!sk->sk_bound_dev_if ||
> > > >  		     !sk2->sk_bound_dev_if ||
> > > > -		     sk->sk_bound_dev_if =3D=3D sk2->sk_bound_dev_if) &&
> > > > -		    (!sk->sk_reuse || !sk2->sk_reuse ||
> > > > -		     sk2->sk_state =3D=3D TCP_LISTEN) &&
> > > > -		     ipv6_rcv_saddr_equal(sk, sk2))
> > > > -			break;
> > > > +		     sk->sk_bound_dev_if =3D=3D sk2->sk_bound_dev_if)) {
> > > > +			if ((!sk->sk_reuse || !sk2->sk_reuse ||
> > > > +			     sk2->sk_state =3D=3D TCP_LISTEN) &&
> > > > +			     ipv6_rcv_saddr_equal(sk, sk2))
> > > > +				break;
> > > > +			else if (sk->sk_reuse && sk2->sk_reuse &&
> > > > +				!ipv6_addr_any(inet6_rcv_saddr(sk2)) &&
> >=20
> > I suppose above line is guilty when inet6_rcv_saddr() returns NULL?
> >=20
>=20
> Sorry, I cant test this at this moment (I am travelling)
>=20
> Evgeniy, David could you double check ?
>=20
> Michael, could you test this patch ?
>=20
> Thanks !
>=20
> [PATCH] ipv6: Fix inet6_csk_bind_conflict()
>=20
> Commit fda48a0d7a84 (tcp: bind() fix when many ports are bound)
> introduced a bug on IPV6 part.
> We should not call ipv6_addr_any(inet6_rcv_saddr(sk2)) but
> ipv6_addr_any(inet6_rcv_saddr(sk)) because sk2 can be IPV4, while sk =
is
> IPV6.
>=20
> Reported-by: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connec=
tion_sock.c
> index b4b7d40..3a4d92b 100644
> --- a/net/ipv6/inet6_connection_sock.c
> +++ b/net/ipv6/inet6_connection_sock.c
> @@ -48,7 +48,7 @@ int inet6_csk_bind_conflict(const struct sock *sk,
>  			     ipv6_rcv_saddr_equal(sk, sk2))
>  				break;
>  			else if (sk->sk_reuse && sk2->sk_reuse &&
> -				!ipv6_addr_any(inet6_rcv_saddr(sk2)) &&
> +				!ipv6_addr_any(inet6_rcv_saddr(sk)) &&
>  				ipv6_rcv_saddr_equal(sk, sk2))
>  				break;
>  		}
>=20

works for me
Tested-by: Michael S. Tsirkin <mst@redhat.com>

