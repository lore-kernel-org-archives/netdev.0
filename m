From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: restrict net.ipv4.tcp_adv_min_scale (#20312)
Date: Sun, 14 Nov 2010 20:49:43 +0100
Message-ID: <1289764183.2743.94.camel@edumazet-laptop>
References: <20101114151825.GA25137@core2.telecom.by>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:63297 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756855Ab0KNTtw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Nov 2010 14:49:52 -0500
Received: by wyb28 with SMTP id 28so3728366wyb.19
        for <netdev@vger.kernel.org>; Sun, 14 Nov 2010 11:49:51 -0800 (PST)
In-Reply-To: <20101114151825.GA25137@core2.telecom.by>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 14 novembre 2010 =C3=A0 17:18 +0200, Alexey Dobriyan a =C3=A9=
crit :
> tcp_win_from_space() does the following:
>=20
> 	if (sysctl_tcp_adv_win_scale <=3D 0)
> 		return space >> (-sysctl_tcp_adv_win_scale);
> 	else
> 		return space - (space >> sysctl_tcp_adv_win_scale);
>=20
> "space" is int.
>=20
> As per C99 6.5.7 (3) shifting int for 32 or more bits is
> undefined behaviour.
>=20
> Indeed, if sysctl_tcp_adv_win_scale is exactly 32, space >> 32 equals
> space and function returns 0;
>=20
> Which means we busyloop in tcp_fixup_rcvbuf().
>=20
> Restrict net.ipv4.tcp_adv_win_scale to [-31, 31].
>=20
> Fix https://bugzilla.kernel.org/show_bug.cgi?id=3D20312
>=20
> Steps to reproduce:
>=20
> 	echo 32 >/proc/sys/net/ipv4/tcp_adv_win_scale
> 	wget www.kernel.org
> 	[softlockup]
>=20
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> ---
>=20

Please fix your patch title, you speak of adv_min_scale ...

> --- a/net/ipv4/sysctl_net_ipv4.c
> +++ b/net/ipv4/sysctl_net_ipv4.c
> @@ -26,6 +26,8 @@ static int zero;
>  static int tcp_retr1_max =3D 255;
>  static int ip_local_port_range_min[] =3D { 1, 1 };
>  static int ip_local_port_range_max[] =3D { 65535, 65535 };
> +static int _minus_31 =3D -31;
> +static int _31 =3D 31;

Please use normal symbols, not starting by underscore.

> =20
>  /* Update system visible IP port range */
>  static void set_local_port_range(int range[2])
> @@ -426,7 +428,9 @@ static struct ctl_table ipv4_table[] =3D {
>  		.data		=3D &sysctl_tcp_adv_win_scale,
>  		.maxlen		=3D sizeof(int),
>  		.mode		=3D 0644,
> -		.proc_handler	=3D proc_dointvec
> +		.proc_handler	=3D proc_dointvec_minmax,
> +		.extra1		=3D &_minus_31,
> +		.extra2		=3D &_31,
>  	},
>  	{
>  		.procname	=3D "tcp_tw_reuse",

Please change Documentation/networking/ip-sysctl.txt to reflect possibl=
e
values of adv_win_scale

Thanks


