From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Connect hangs for a while before returns -1 with ECONNREFUSED
 on 3.2 for loopback
Date: Sat, 04 Feb 2012 13:26:42 +0100
Message-ID: <1328358402.2731.11.camel@edumazet-laptop>
References: <4F2B7DF1.5050303@oktetlabs.ru>
	 <1328279894.2157.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1328282126.2157.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "Yurij M. Plotnikov" <Yurij.Plotnikov@oktetlabs.ru>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:41846 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752379Ab2BDM0s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2012 07:26:48 -0500
Received: by wgbdt10 with SMTP id dt10so4712389wgb.1
        for <netdev@vger.kernel.org>; Sat, 04 Feb 2012 04:26:46 -0800 (PST)
In-Reply-To: <1328282126.2157.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 03 f=C3=A9vrier 2012 =C3=A0 16:15 +0100, Eric Dumazet a =C3=
=A9crit :

> We omit to send RST packet in tcp_v4_send_reset()
>=20
> because of this test :
>=20
> if (skb_rtable(skb)->rt_type !=3D RTN_LOCAL)
> 	return
>=20
> At this point rt_type is RTN_UNICAST
>=20
>=20

Here is the fix, thanks again !

[PATCH] ipv4: fix a route regression

commit 813b3b5db83 (ipv4: Use caller's on-stack flowi as-is in output
route lookups.) added a regression.

Some callers of ip_route_output_slow() assumed their flow argument was
constant.

ip_route_output_slow() must leave with original content of various
fields.

Thanks to Yurij M. Plotnikov for providing a bug report including a
program to reproduce the problem.

Reported-by: Yurij M. Plotnikov <Yurij.Plotnikov@oktetlabs.ru>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/route.c |   13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index bcacf54..0f63240 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2633,19 +2633,15 @@ static struct rtable *ip_route_output_slow(stru=
ct net *net, struct flowi4 *fl4)
 	unsigned int flags =3D 0;
 	struct fib_result res;
 	struct rtable *rth;
-	__be32 orig_daddr;
-	__be32 orig_saddr;
-	int orig_oif;
+	__be32 orig_daddr =3D fl4->daddr;
+	__be32 orig_saddr =3D fl4->saddr;
+	int orig_oif =3D fl4->flowi4_oif;
=20
 	res.fi		=3D NULL;
 #ifdef CONFIG_IP_MULTIPLE_TABLES
 	res.r		=3D NULL;
 #endif
=20
-	orig_daddr =3D fl4->daddr;
-	orig_saddr =3D fl4->saddr;
-	orig_oif =3D fl4->flowi4_oif;
-
 	fl4->flowi4_iif =3D net->loopback_dev->ifindex;
 	fl4->flowi4_tos =3D tos & IPTOS_RT_MASK;
 	fl4->flowi4_scope =3D ((tos & RTO_ONLINK) ?
@@ -2816,6 +2812,9 @@ make_route:
=20
 out:
 	rcu_read_unlock();
+	fl4->flowi4_oif =3D orig_oif;
+	fl4->daddr =3D orig_daddr;
+	fl4->saddr =3D orig_saddr;
 	return rth;
 }
=20
