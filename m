From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG] ipv6: all routes share same inetpeer
Date: Tue, 19 Jul 2011 20:20:38 +0200
Message-ID: <1311099638.3113.2.camel@edumazet-laptop>
References: <1311096229.2375.49.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20110719.103724.1461298517132188126.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:57460 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750874Ab1GSSUn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2011 14:20:43 -0400
Received: by wyg8 with SMTP id 8so2977601wyg.19
        for <netdev@vger.kernel.org>; Tue, 19 Jul 2011 11:20:42 -0700 (PDT)
In-Reply-To: <20110719.103724.1461298517132188126.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 19 juillet 2011 =C3=A0 10:37 -0700, David Miller a =C3=A9crit =
:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 19 Jul 2011 19:23:49 +0200
>=20
> > Maybe you can find the bug before me ?
>=20
> I think when we add the route we cow the metrics almost immediately.
> The daddr is, unfortunately, fully prefixed at that point.

Yes, we shall provide a second ip6_rt_copy() argument, with the
destination address.

I am testing :

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index ddef80f..2a6d70a 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -72,7 +72,7 @@
 #define RT6_TRACE(x...) do { ; } while (0)
 #endif
=20
-static struct rt6_info * ip6_rt_copy(struct rt6_info *ort);
+static struct rt6_info * ip6_rt_copy(struct rt6_info *ort, const struc=
t in6_addr *dest);
 static struct dst_entry	*ip6_dst_check(struct dst_entry *dst, u32 cook=
ie);
 static unsigned int	 ip6_default_advmss(const struct dst_entry *dst);
 static unsigned int	 ip6_default_mtu(const struct dst_entry *dst);
@@ -699,7 +699,7 @@ static struct rt6_info *rt6_alloc_cow(struct rt6_in=
fo *ort, const struct in6_add
 	 *	Clone the route.
 	 */
=20
-	rt =3D ip6_rt_copy(ort);
+	rt =3D ip6_rt_copy(ort, daddr);
=20
 	if (rt) {
 		struct neighbour *neigh;
@@ -712,7 +712,6 @@ static struct rt6_info *rt6_alloc_cow(struct rt6_in=
fo *ort, const struct in6_add
 			ipv6_addr_copy(&rt->rt6i_gateway, daddr);
 		}
=20
-		ipv6_addr_copy(&rt->rt6i_dst.addr, daddr);
 		rt->rt6i_dst.plen =3D 128;
 		rt->rt6i_flags |=3D RTF_CACHE;
 		rt->dst.flags |=3D DST_HOST;
@@ -761,9 +760,9 @@ static struct rt6_info *rt6_alloc_cow(struct rt6_in=
fo *ort, const struct in6_add
=20
 static struct rt6_info *rt6_alloc_clone(struct rt6_info *ort, const st=
ruct in6_addr *daddr)
 {
-	struct rt6_info *rt =3D ip6_rt_copy(ort);
+	struct rt6_info *rt =3D ip6_rt_copy(ort, daddr);
+
 	if (rt) {
-		ipv6_addr_copy(&rt->rt6i_dst.addr, daddr);
 		rt->rt6i_dst.plen =3D 128;
 		rt->rt6i_flags |=3D RTF_CACHE;
 		rt->dst.flags |=3D DST_HOST;
@@ -1584,7 +1583,7 @@ void rt6_redirect(const struct in6_addr *dest, co=
nst struct in6_addr *src,
 	if (neigh =3D=3D dst_get_neighbour(&rt->dst))
 		goto out;
=20
-	nrt =3D ip6_rt_copy(rt);
+	nrt =3D ip6_rt_copy(rt, dest);
 	if (nrt =3D=3D NULL)
 		goto out;
=20
@@ -1592,7 +1591,6 @@ void rt6_redirect(const struct in6_addr *dest, co=
nst struct in6_addr *src,
 	if (on_link)
 		nrt->rt6i_flags &=3D ~RTF_GATEWAY;
=20
-	ipv6_addr_copy(&nrt->rt6i_dst.addr, dest);
 	nrt->rt6i_dst.plen =3D 128;
 	nrt->dst.flags |=3D DST_HOST;
=20
@@ -1730,7 +1728,7 @@ void rt6_pmtu_discovery(const struct in6_addr *da=
ddr, const struct in6_addr *sad
  *	Misc support functions
  */
=20
-static struct rt6_info * ip6_rt_copy(struct rt6_info *ort)
+static struct rt6_info * ip6_rt_copy(struct rt6_info *ort, const struc=
t in6_addr *dest)
 {
 	struct net *net =3D dev_net(ort->rt6i_dev);
 	struct rt6_info *rt =3D ip6_dst_alloc(&net->ipv6.ip6_dst_ops,
@@ -1740,6 +1738,8 @@ static struct rt6_info * ip6_rt_copy(struct rt6_i=
nfo *ort)
 		rt->dst.input =3D ort->dst.input;
 		rt->dst.output =3D ort->dst.output;
=20
+		ipv6_addr_copy(&rt->rt6i_dst.addr, dest);
+		rt->rt6i_dst.plen =3D ort->rt6i_dst.plen;
 		dst_copy_metrics(&rt->dst, &ort->dst);
 		rt->dst.error =3D ort->dst.error;
 		rt->rt6i_idev =3D ort->rt6i_idev;
@@ -1752,7 +1752,6 @@ static struct rt6_info * ip6_rt_copy(struct rt6_i=
nfo *ort)
 		rt->rt6i_flags =3D ort->rt6i_flags & ~RTF_EXPIRES;
 		rt->rt6i_metric =3D 0;
=20
-		memcpy(&rt->rt6i_dst, &ort->rt6i_dst, sizeof(struct rt6key));
 #ifdef CONFIG_IPV6_SUBTREES
 		memcpy(&rt->rt6i_src, &ort->rt6i_src, sizeof(struct rt6key));
 #endif


