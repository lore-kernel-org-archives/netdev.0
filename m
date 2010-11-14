From: Zhang Le <r0bertz@gentoo.org>
Subject: Re: [PATCH] ipv4: mitigate an integer underflow when comparing tcp
 timestamps
Date: Sun, 14 Nov 2010 23:00:07 +0800
Message-ID: <20101114150006.GA23973@adriano>
References: <1289720156-30118-1-git-send-email-r0bertz@gentoo.org>
 <1289724745.2743.61.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="jI8keyz6grp/JLjh"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:33288 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755642Ab0KNO6y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Nov 2010 09:58:54 -0500
Content-Disposition: inline
In-Reply-To: <1289724745.2743.61.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--jI8keyz6grp/JLjh
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 09:52 Sun 14 Nov     , Eric Dumazet wrote:
> Le dimanche 14 novembre 2010 =E0 15:35 +0800, Zhang Le a =E9crit :
> > Behind a loadbalancer which does NAT, peer->tcp_ts could be much smalle=
r than
> > req->ts_recent. In this case, theoretically the req should not be ignor=
ed.
> >=20
> > But in fact, it could be ignored, if peer->tcp_ts is so small that the
> > difference between this two number is larger than 2 to the power of 31.
> >=20
> > I understand that under this situation, timestamp does not make sense a=
ny more,
> > because it actually comes from difference machines. However, if anyone
> > ever need to do the same investigation which I have done, this will
> > save some time for him.
> >=20
> > Signed-off-by: Zhang Le <r0bertz@gentoo.org>
> > ---
> >  net/ipv4/tcp_ipv4.c |    4 ++--
> >  1 files changed, 2 insertions(+), 2 deletions(-)
> >=20
> > diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> > index 8f8527d..1eb4974 100644
> > --- a/net/ipv4/tcp_ipv4.c
> > +++ b/net/ipv4/tcp_ipv4.c
> > @@ -1352,8 +1352,8 @@ int tcp_v4_conn_request(struct sock *sk, struct s=
k_buff *skb)
> >  		    peer->v4daddr =3D=3D saddr) {
> >  			inet_peer_refcheck(peer);
> >  			if ((u32)get_seconds() - peer->tcp_ts_stamp < TCP_PAWS_MSL &&
> > -			    (s32)(peer->tcp_ts - req->ts_recent) >
> > -							TCP_PAWS_WINDOW) {
> > +			    ((s32)(peer->tcp_ts - req->ts_recent) > TCP_PAWS_WINDOW &&
> > +			     peer->tcp_ts > req->ts_recent)) {
> >  				NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_PAWSPASSIVEREJECTED);
> >  				goto drop_and_release;
> >  			}
>=20
> This seems very wrong to me.
>=20
> Adding a : if (peer->tcp_ts > req->ts_recent) condition is _not_ going
> to help. And it might break some working setups, because of wrap around.

Yeah, you are right. And sorry for overlooking this.

I should have reviewed time_{before,after}'s implementation before posting =
this.

So it seems we can't do anything to improve this except to add some warning=
 in
documentation. Maybe some comments in the code too.

>=20
> Really, if you have multiple clients behind a common NAT, you cannot use
> this code at all, since NAT doesnt usually change TCP timestamps.
>=20
> What about following patch instead ?
>=20
> [PATCH] doc: extend tcp_tw_recycle documentation
>=20
> tcp_tw_recycle should not be used on a server if there is a chance
> clients are behind a same NAT. Document this fact before too many users
> discover this too late.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  Documentation/networking/ip-sysctl.txt |    7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
>=20
> diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/netwo=
rking/ip-sysctl.txt
> index c7165f4..406f0d5 100644
> --- a/Documentation/networking/ip-sysctl.txt
> +++ b/Documentation/networking/ip-sysctl.txt
> @@ -446,7 +446,12 @@ tcp_tso_win_divisor - INTEGER
>  tcp_tw_recycle - BOOLEAN
>  	Enable fast recycling TIME-WAIT sockets. Default value is 0.
>  	It should not be changed without advice/request of technical
> -	experts.
> +	experts. If you set it to 1, make sure you dont miss connections
> +	attempts (check LINUX_MIB_PAWSPASSIVEREJECTED netstat counter).
> +	In particular, this might break if several clients are behind
> +	a common NAT device, since their TCP timestamp wont be changed
> +	by the NAT. tcp_tw_recycle should be used with care, most
> +	probably in private networks.
> =20
>  tcp_tw_reuse - BOOLEAN
>  	Allow to reuse TIME-WAIT sockets for new connections when it is
>=20
>=20

--=20
Zhang, Le
Gentoo/Loongson Developer
http://zhangle.is-a-geek.org
0260 C902 B8F8 6506 6586 2B90 BC51 C808 1E4E 2973

--jI8keyz6grp/JLjh
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.16 (GNU/Linux)

iEYEARECAAYFAkzf+XYACgkQvFHICB5OKXPx8QCfYlOMbTAvFvQS6r6Xpkzj2ysa
oswAnAox5JEa+MaePY6RTg3bLZ/liVrl
=VWBQ
-----END PGP SIGNATURE-----

--jI8keyz6grp/JLjh--
