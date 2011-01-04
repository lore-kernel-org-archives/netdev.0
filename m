From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4/route.c: respect prefsrc for local routes
Date: Tue, 04 Jan 2011 08:24:40 +0100
Message-ID: <1294125880.2711.34.camel@edumazet-laptop>
References: <1294122260-13245-1-git-send-email-jsing@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Joel Sing <jsing@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:55856 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750926Ab1ADHYp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jan 2011 02:24:45 -0500
Received: by wyb28 with SMTP id 28so14056007wyb.19
        for <netdev@vger.kernel.org>; Mon, 03 Jan 2011 23:24:44 -0800 (PST)
In-Reply-To: <1294122260-13245-1-git-send-email-jsing@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 04 janvier 2011 =C3=A0 17:24 +1100, Joel Sing a =C3=A9crit :
> The preferred source address is currently ignored for local routes,
> which results in all local connections having a src address that is t=
he
> same as the local dst address. Fix this by respecting the preferred s=
ource
> address when it is provided for local routes.
>=20
> This bug can be demonstrated as follows:
>=20
>  # ifconfig dummy0 192.168.0.1
>  # ip route show table local | grep local.*dummy0
>  local 192.168.0.1 dev dummy0  proto kernel  scope host  src 192.168.=
0.1
>  # ip route change table local local 192.168.0.1 dev dummy0 \
>      proto kernel scope host src 127.0.0.1
>  # ip route show table local | grep local.*dummy0
>  local 192.168.0.1 dev dummy0  proto kernel  scope host  src 127.0.0.=
1
>=20
> We now establish a local connection and verify the source IP
> address selection:
>=20
>  # nc -l 192.168.0.1 3128 &
>  # nc 192.168.0.1 3128 &
>  # netstat -ant | grep 192.168.0.1:3128.*EST
>  tcp        0      0 192.168.0.1:3128        192.168.0.1:33228 ESTABL=
ISHED
>  tcp        0      0 192.168.0.1:33228       192.168.0.1:3128  ESTABL=
ISHED
>=20
> Signed-off-by: Joel Sing <jsing@google.com>
> ---
>  net/ipv4/route.c |    8 ++++++--
>  1 files changed, 6 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index df948b0..93bfd95 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -2649,8 +2649,12 @@ static int ip_route_output_slow(struct net *ne=
t, struct rtable **rp,
>  	}
> =20
>  	if (res.type =3D=3D RTN_LOCAL) {
> -		if (!fl.fl4_src)
> -			fl.fl4_src =3D fl.fl4_dst;
> +		if (!fl.fl4_src) {
> +			if (res.fi->fib_prefsrc)
> +				fl.fl4_src =3D res.fi->fib_prefsrc;
> +			else
> +				fl.fl4_src =3D fl.fl4_dst;
> +		}
>  		dev_out =3D net->loopback_dev;
>  		fl.oif =3D dev_out->ifindex;
>  		res.fi =3D NULL;

Please use FIB_RES_PREFSRC(res)

as we do a few lines after ;)

Thanks


