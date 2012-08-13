From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: iproute2-3.5.0: `ip a s` no longer shows addresses
Date: Mon, 13 Aug 2012 08:11:25 -0700
Message-ID: <20120813081125.275937fb@nehalam.linuxnetplumber.net>
References: <201208071503.01261.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA256;
 boundary="Sig_/Ut8Q8D41A4lblkjuarZZl44"; protocol="application/pgp-signature"
Cc: netdev@vger.kernel.org
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37700 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752416Ab2HMPLf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2012 11:11:35 -0400
In-Reply-To: <201208071503.01261.vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/Ut8Q8D41A4lblkjuarZZl44
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 7 Aug 2012 15:03:00 -0400
Mike Frysinger <vapier@gentoo.org> wrote:

> since 3.4.0 works, but 3.5.0, a quick bisect shows the bad commit:
> http://git.kernel.org/?p=3Dlinux/kernel/git/shemminger/iproute2.git;a=3Dc=
ommit;h=3D8d07e5f7d995171ee8834eae268e300560de5d4f
>=20
> the simple test case:
> make clean && make -j -s && ./ip/ip a s lo
>=20
> before that change, i would get:
> 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN=20
>     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>     inet 127.0.0.1/8 scope host lo
>     inet6 ::1/128 scope host=20
>        valid_lft forever preferred_lft forever
>=20
> but after, i now get:
> 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN=20
>     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>=20
> seems like the bug was introduced in the middle of that patch:
> =20
> -	if (filter.family !=3D AF_PACKET) {
> +	if (filter.family && filter.family !=3D AF_PACKET) {
> +		if (filter.oneline)
> +			no_link =3D 1;
> +
>  		if (rtnl_wilddump_request(&rth, filter.family, RTM_GETADDR) < 0) {
>  			perror("Cannot send dump request");
>  			exit(1);
>=20
> if i revert the change to the if statement there, `ip a s` works for me a=
gain.
> (see below)
> -mike
>=20
> diff --git a/ip/ipaddress.c b/ip/ipaddress.c
> index 37deda5..69a63b3 100644
> --- a/ip/ipaddress.c
> +++ b/ip/ipaddress.c
> @@ -1018,7 +1018,7 @@ static int ipaddr_list_or_flush(int argc, char **ar=
gv, int flush)
>  		exit(1);
>  	}
> =20
> -	if (filter.family && filter.family !=3D AF_PACKET) {
> +	if (filter.family !=3D AF_PACKET) {
>  		if (filter.oneline)
>  			no_link =3D 1;
> =20

Ok. Applied

--Sig_/Ut8Q8D41A4lblkjuarZZl44
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJQKRkdAAoJEICnf2CVzeR+pvgP/jj2I6hoP8mv4G4nytIEoVCo
wu5NXb1IiuVMyhscbodwAAkLA1S2Zmi/1P7me8Jv0VVHSFVeo84n5KbHnJE2tgzC
pbrE4kucccBnTPuVSQRQvwe0cHr0P2Iu4JALR23y05VgxgInF3s/movLBbemU+85
fdTiSPNfK5xwbu8wd18Bax3xMHAaz+Nfb3CyGbvKdBNijDd5pHF+iaMYmp81udPB
bwQDd6iT+mdgaUbn6V3w95hfOpcQYkW0+BEBnG6vOZGuE9+ZydDKGPGYnAbhjzrD
PK4YhowlrSeFGK8OWFca+9vISGz3Ceg6RD61onFy/H57R3meQ480Qwm4/CCmY7cz
dx0iO7lXFzHCywPQRgnfd1m+8OL6YubupYs7PFGrOhN7kdihWUpcmaeJNaHjcfoM
yHY2EQMbBbKbN4Jsc28ts0x9ae5spaK3hipOP0DqnrO8szDKHi9vt4Y5kbSkf2B7
5vdG/hB/Hve3av0qaD173gXrwF+l4h3aAsSiQld6fzQMfEhTGN/VLq+5SVhGAnTe
DDxsfRjp2koRh/ZhzMZ/x1Fz4lapHqxNvUDDagbpLsLYJGehYwQL2UiAuU9ThjH5
9iziolCUSt3aDGgyTQHxVmFrA+yV9TQk7K2NpyF4EWuEMZGtAPooNiYb/d+l+3On
yh0pi09eDFydcrSGsE0P
=B/5G
-----END PGP SIGNATURE-----

--Sig_/Ut8Q8D41A4lblkjuarZZl44--
