From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: add limits to ip_default_ttl
Date: Mon, 13 Dec 2010 21:08:32 +0100
Message-ID: <1292270912.2679.42.camel@edumazet-laptop>
References: <20101213.100400.39192396.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:34743 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754996Ab0LMUIh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 15:08:37 -0500
Received: by wyb28 with SMTP id 28so6277234wyb.19
        for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 12:08:35 -0800 (PST)
In-Reply-To: <20101213.100400.39192396.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 13 d=C3=A9cembre 2010 =C3=A0 10:04 -0800, David Miller a =C3=A9=
crit :
> Always go through a new ip4_dst_hoplimit() helper, just like ipv6.
>=20
> This allowed several simplifications:
>=20
> 1) The interim dst_metric_hoplimit() can go as it's no longer
>    userd.
>=20
> 2) The sysctl_ip_default_ttl entry no longer needs to use
>    ipv4_doint_and_flush, since the sysctl is not cached in
>    routing cache metrics any longer.
>=20
> 3) ipv4_doint_and_flush no longer needs to be exported and
>    therefore can be marked static.
>=20
> When ipv4_doint_and_flush_strategy was removed some time ago,
> the external declaration in ip.h was mistakenly left around
> so kill that off too.
>=20
> We have to move the sysctl_ip_default_ttl declaration into
> ipv4's route cache definition header net/route.h, because
> currently net/ip.h (where the declaration lives now) has
> a back dependency on net/route.h
>=20
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---

> --- a/net/ipv4/sysctl_net_ipv4.c
> +++ b/net/ipv4/sysctl_net_ipv4.c
> @@ -155,7 +155,7 @@ static struct ctl_table ipv4_table[] =3D {
>  		.data		=3D &sysctl_ip_default_ttl,
>  		.maxlen		=3D sizeof(int),
>  		.mode		=3D 0644,
> -		.proc_handler	=3D ipv4_doint_and_flush,
> +		.proc_handler	=3D proc_dointvec,
>  		.extra2		=3D &init_net,
>  	},

Please find following patch then, because extra2 is not anymore used.

BTW, I cant find where extra2 was set to actual struct net pointer in
net-2.6 kernel. I suspect a write on /proc/sys/net/ipv4/ip_default_ttl
was flushing routes of initial net only, not current one ?

I can see this extra2 param properly handled in
__devinet_sysctl_register() for /proc/net/ipv4/conf parameters, not for
ip_default_ttl.



=46or net-next-2.6, we could remove the line, or we could add sensible
limits ;)

[PATCH net-next-2.6] net: add limits to ip_default_ttl

ip_default_ttl should be between 1 and 255

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/sysctl_net_ipv4.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index e85ff59..1a45665 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -28,6 +28,8 @@ static int ip_local_port_range_min[] =3D { 1, 1 };
 static int ip_local_port_range_max[] =3D { 65535, 65535 };
 static int tcp_adv_win_scale_min =3D -31;
 static int tcp_adv_win_scale_max =3D 31;
+static int ip_ttl_min =3D 1;
+static int ip_ttl_max =3D 255;
=20
 /* Update system visible IP port range */
 static void set_local_port_range(int range[2])
@@ -155,8 +157,9 @@ static struct ctl_table ipv4_table[] =3D {
 		.data		=3D &sysctl_ip_default_ttl,
 		.maxlen		=3D sizeof(int),
 		.mode		=3D 0644,
-		.proc_handler	=3D proc_dointvec,
-		.extra2		=3D &init_net,
+		.proc_handler	=3D proc_dointvec_minmax,
+		.extra1		=3D &ip_ttl_min,
+		.extra2		=3D &ip_ttl_max,
 	},
 	{
 		.procname	=3D "ip_no_pmtu_disc",


