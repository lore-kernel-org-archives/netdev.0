From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PROBLEM: Linux kernel 2.6.31 IPv4 TCP fails to open huge
 amount of outgoing connections (unable to bind ... )
Date: Sun, 25 Apr 2010 18:21:00 +0200
Message-ID: <1272212460.2069.9.camel@edumazet-laptop>
References: <1271828799.7895.1287.camel@edumazet-laptop>
	 <20100421082559.GA32475@ioremap.net>
	 <1271840535.7895.1612.camel@edumazet-laptop>
	 <20100421095812.GA14778@ioremap.net>
	 <1271849253.7895.1929.camel@edumazet-laptop>
	 <20100421182723.GA17202@ioremap.net>
	 <1271875416.7895.3033.camel@edumazet-laptop>
	 <20100421185837.GB21249@ioremap.net>
	 <1271877975.7895.3171.camel@edumazet-laptop>
	 <20100425142642.GA11411@redhat.com>  <20100425155600.GA13319@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>,
	Gaspar Chilingarov <gasparch@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:35796 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753461Ab0DYQVH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Apr 2010 12:21:07 -0400
Received: by bwz19 with SMTP id 19so633765bwz.21
        for <netdev@vger.kernel.org>; Sun, 25 Apr 2010 09:21:04 -0700 (PDT)
In-Reply-To: <20100425155600.GA13319@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 25 avril 2010 =C3=A0 19:56 +0400, Evgeniy Polyakov a =C3=A9=
crit :
> On Sun, Apr 25, 2010 at 05:26:42PM +0300, Michael S. Tsirkin (mst@red=
hat.com) wrote:
>=20
> > > diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_co=
nnection_sock.c
> > > index 0c5e3c3..fb6959c 100644
> > > --- a/net/ipv6/inet6_connection_sock.c
> > > +++ b/net/ipv6/inet6_connection_sock.c
> > > @@ -42,11 +42,16 @@ int inet6_csk_bind_conflict(const struct sock=
 *sk,
> > >  		if (sk !=3D sk2 &&
> > >  		    (!sk->sk_bound_dev_if ||
> > >  		     !sk2->sk_bound_dev_if ||
> > > -		     sk->sk_bound_dev_if =3D=3D sk2->sk_bound_dev_if) &&
> > > -		    (!sk->sk_reuse || !sk2->sk_reuse ||
> > > -		     sk2->sk_state =3D=3D TCP_LISTEN) &&
> > > -		     ipv6_rcv_saddr_equal(sk, sk2))
> > > -			break;
> > > +		     sk->sk_bound_dev_if =3D=3D sk2->sk_bound_dev_if)) {
> > > +			if ((!sk->sk_reuse || !sk2->sk_reuse ||
> > > +			     sk2->sk_state =3D=3D TCP_LISTEN) &&
> > > +			     ipv6_rcv_saddr_equal(sk, sk2))
> > > +				break;
> > > +			else if (sk->sk_reuse && sk2->sk_reuse &&
> > > +				!ipv6_addr_any(inet6_rcv_saddr(sk2)) &&
>=20
> I suppose above line is guilty when inet6_rcv_saddr() returns NULL?
>=20

Sorry, I cant test this at this moment (I am travelling)

Evgeniy, David could you double check ?

Michael, could you test this patch ?

Thanks !

[PATCH] ipv6: Fix inet6_csk_bind_conflict()

Commit fda48a0d7a84 (tcp: bind() fix when many ports are bound)
introduced a bug on IPV6 part.
We should not call ipv6_addr_any(inet6_rcv_saddr(sk2)) but
ipv6_addr_any(inet6_rcv_saddr(sk)) because sk2 can be IPV4, while sk is
IPV6.

Reported-by: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connecti=
on_sock.c
index b4b7d40..3a4d92b 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -48,7 +48,7 @@ int inet6_csk_bind_conflict(const struct sock *sk,
 			     ipv6_rcv_saddr_equal(sk, sk2))
 				break;
 			else if (sk->sk_reuse && sk2->sk_reuse &&
-				!ipv6_addr_any(inet6_rcv_saddr(sk2)) &&
+				!ipv6_addr_any(inet6_rcv_saddr(sk)) &&
 				ipv6_rcv_saddr_equal(sk, sk2))
 				break;
 		}


