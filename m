From: Martin Steigerwald <Martin@lichtvoll.de>
Subject: Re: [PATCH] tcp: avoid a possible divide by zero
Date: Wed, 8 Dec 2010 09:23:25 +0100
Message-ID: <201012080923.36086.Martin@lichtvoll.de>
References: <201012071639.58884.Martin@lichtvoll.de> <1291757563.21627.15.camel@bwh-desktop> <1291759435.5324.25.camel@edumazet-laptop> (sfid-20101208_091329_309252_DAE30076)
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart6142528.P4nJRnzZX2";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mondschein.lichtvoll.de ([194.150.191.11]:57497 "EHLO
	mail.lichtvoll.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754301Ab0LHIXj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 03:23:39 -0500
In-Reply-To: <1291759435.5324.25.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart6142528.P4nJRnzZX2
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

Am Dienstag 07 Dezember 2010 schrieb Eric Dumazet:
> Le mardi 07 d=C3=A9cembre 2010 =C3=A0 21:32 +0000, Ben Hutchings a =C3=A9=
crit :
> > On Tue, 2010-12-07 at 22:28 +0100, Eric Dumazet wrote:
> > [...]
> >=20
> > > Thanks
> > >=20
> > > Great, I feel we are going to fix all sysctls, one by one then :(

Are there so many sysctls which are likely to freeze the kernel when fed=20
with wrong value? Once could argue for sysctls where invalid values don't=20
cause any serious harm, its not so important to fix it. I probably could=20
have next weeks training members a go at poking creative values in other=20
controls as well to see what happens.

> > > lkml removed from Cc
> > >=20
> > >=20
> > > [PATCH] tcp: avoid a possible divide by zero
> > >=20
> > > sysctl_tcp_tso_win_divisor might be set to zero while one cpu runs
> > > in tcp_tso_should_defer(). Make sure we dont allow a divide by
> > > zero by reading sysctl_tcp_tso_win_divisor once.
> > >=20
> > > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> > > ---
[...]
> > > +	win_divisor =3D sysctl_tcp_tso_win_divisor;
> >=20
> > You need to use ACCESS_ONCE(sysctl_tcp_tso_win_divisor).  Otherwise
> > the compiler may eliminate the local variable and read the global
> > twice.
>=20
> Yes, I knew that, of course :)
>=20
> I wonder how many bugs like that we have in sysctls
>=20
> Thanks
>=20
> [PATCH v2] tcp: avoid a possible divide by zero
>=20
> sysctl_tcp_tso_win_divisor might be set to zero while one cpu runs in
> tcp_tso_should_defer(). Make sure we dont allow a divide by zero by
> reading sysctl_tcp_tso_win_divisor exactly once.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> v2: Use ACCESS_ONCE() as Ben suggested
>=20
>  net/ipv4/tcp_output.c |    6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 05b1ecf..0464d70 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -1513,6 +1513,7 @@ static int tcp_tso_should_defer(struct sock *sk,
> struct sk_buff *skb) struct tcp_sock *tp =3D tcp_sk(sk);
>  	const struct inet_connection_sock *icsk =3D inet_csk(sk);
>  	u32 send_win, cong_win, limit, in_flight;
> +	int win_divisor;
[...]
> -	if (sysctl_tcp_tso_win_divisor) {
> +	win_divisor =3D ACCESS_ONCE(sysctl_tcp_tso_win_divisor);
> +	if (win_divisor) {
>  		u32 chunk =3D min(tp->snd_wnd, tp->snd_cwnd * tp->mss_cache);
>=20
>  		/* If at least some fraction of a window is available,
>  		 * just use it.
>  		 */
> -		chunk /=3D sysctl_tcp_tso_win_divisor;
> +		chunk /=3D win_divisor;
>  		if (limit >=3D chunk)
>  			goto send_now;
>  	} else {

So this patch helps other cases as well? Or is it, as I think just a=20
different approach, to fix the issue my training member brought up, by its=
=20
cause instead of or additional to limiting its range?

Want to check whether I basically understood the patch. Do you want me to=20
test it?=20

Thanks,
=2D-=20
Martin 'Helios' Steigerwald - http://www.Lichtvoll.de
GPG: 03B0 0D6C 0040 0710 4AFA  B82F 991B EAAC A599 84C7

--nextPart6142528.P4nJRnzZX2
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAkz/QH8ACgkQmRvqrKWZhMfM4wCgssfa/H3HbmLMovBB+d6Y24ln
kU8AnRMrmyV0E8JdBrYsvYAbMj4yxVRt
=JIA1
-----END PGP SIGNATURE-----

--nextPart6142528.P4nJRnzZX2--
