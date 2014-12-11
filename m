From: Wolfgang Walter <linux@stwm.de>
Subject: Re: [bisected] xfrm: TCP connection initiating PMTU discovery stalls on v3.
Date: Thu, 11 Dec 2014 01:36:48 +0100
Message-ID: <3485487.Ob8lM3Vmqr@h2o.as.studentenwerk.mhn.de>
References: <1709726.jUgUSQI9sl@pikkukde.a.i2n> <6700748.kZ07xrNvHX@h2o.as.studentenwerk.mhn.de> <1418238603.27198.37.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Jarosch <thomas.jarosch@intra2net.com>,
	netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailin.studentenwerk.mhn.de ([141.84.225.229]:60845 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933226AbaLKAgv convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Dec 2014 19:36:51 -0500
In-Reply-To: <1418238603.27198.37.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Mittwoch, 10. Dezember 2014, 11:10:03 schrieb Eric Dumazet:
> On Wed, 2014-12-10 at 19:34 +0100, Wolfgang Walter wrote:
> > So gso is on. When the hang happens sk_setup_caps is called from
> > inet_sk_rebuild_header(). Now the path
> >=20
> > 		sk->sk_route_caps &=3D ~NETIF_F_GSO_MASK;
> >=20
> > is taken as dst->header_len is now non zero.
> >=20
> > This is the reason why later calls of sk_can_gso() return false.
> >=20
> > I'll try to change the above patch to
> >=20
> > @@ -1585,6 +1585,8 @@ void sk_setup_caps(struct sock *sk, struct ds=
t_entry
> > *dst) sk->sk_gso_max_size =3D dst->dev->gso_max_size;
> >=20
> >  			sk->sk_gso_max_segs =3D dst->dev->gso_max_segs;
> >  	=09
> >  		}
> > =09
> > 	}
> >=20
> > +   if (sk_can_gso(sk)) {
> > +		sk->sk_gso_max_segs =3D 1;
> >=20
> >  	}
> > =20
> >  }
> >  EXPORT_SYMBOL_GPL(sk_setup_caps);
> >=20
> > so that the case that GSO is disabled because of dst->header_len !=3D=
 0 sets
> > sk_gso_max_segs, too.
>=20
> Sounds good, or maybe simply :
>=20
> diff --git a/net/core/sock.c b/net/core/sock.c
> index
> 9a56b2000c3f374fb95aedada3327447816a9512..edca31319dfee57cabe5b376505=
324bea
> 07f767a 100644 --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -1577,6 +1577,7 @@ void sk_setup_caps(struct sock *sk, struct dst_=
entry
> *dst) if (sk->sk_route_caps & NETIF_F_GSO)
>  		sk->sk_route_caps |=3D NETIF_F_GSO_SOFTWARE;
>  	sk->sk_route_caps &=3D ~sk->sk_route_nocaps;
> +	sk->sk_gso_max_segs =3D 1;
>  	if (sk_can_gso(sk)) {
>  		if (dst->header_len) {
>  			sk->sk_route_caps &=3D ~NETIF_F_GSO_MASK;

Yes, true.


This fixes the issue. That means no hangs any more even if gso is enabl=
ed on=20
the device serving the ipsec traffic.

As said I could not apply https://patchwork.ozlabs.org/patch/418506/=20
unmodified to 3.14. This is because the following patch is missing in v=
=2E3.14:

commit e114a710aa5058c0ba4aa1dfb105132aefeb5e04
Author: Eric Dumazet <edumazet@google.com>
Date:   Wed Apr 30 11:58:13 2014 -0700

    tcp: fix cwnd limited checking to improve congestion control

(and the follow-up 249015515fe3fc9818d86cb5c83bbc92505ad7dc).

I'll next try to apply these patches on v3.14.26, see if the other patc=
h then=20
applies cleanly, add that one-liner - and hopefully it will work.

Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
