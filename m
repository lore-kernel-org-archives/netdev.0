From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG] ipv6: all routes share same inetpeer
Date: Wed, 20 Jul 2011 08:18:36 +0200
Message-ID: <1311142716.3113.104.camel@edumazet-laptop>
References: <20110719.103724.1461298517132188126.davem@davemloft.net>
	 <1311099638.3113.2.camel@edumazet-laptop>
	 <1311101870.3113.6.camel@edumazet-laptop>
	 <20110719.115929.106510307852361614.davem@davemloft.net>
	 <1311139774.3113.86.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:44998 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751326Ab1GTGSm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 02:18:42 -0400
Received: by wwe5 with SMTP id 5so4871590wwe.1
        for <netdev@vger.kernel.org>; Tue, 19 Jul 2011 23:18:41 -0700 (PDT)
In-Reply-To: <1311139774.3113.86.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 20 juillet 2011 =C3=A0 07:29 +0200, Eric Dumazet a =C3=A9cr=
it :

> My first patch had an issue in rt6_alloc_cow(), line 710, where=20
> ipv6_addr_equal(&rt->rt6i_dst.addr, daddr) becomes always true.
>=20
> I guess I can replace it by ipv6_addr_equal(&ort->rt6i_dst.addr, dadd=
r)
>=20
>=20

Here the combo patch I tested :

I also had to solve the icmp6_dst_alloc() problem
[it uses dst_metric_set(&rt->dst, RTAX_HOPLIMIT, 255);]

Note : this is based on net-2.6, but I really tested it on net-next-2.6
(with the frag ident patch applied too)

[PATCH] ipv6: unshare inetpeers

We currently cow metrics a bit too soon in IPv6 case : All routes are
tied to a single inetpeer entry.

Change ip6_rt_copy() to get destination address as second argument, so
that we fill rt6i_dst before the dst_copy_metrics() call.

icmp6_dst_alloc() must set rt6i_dst before calling dst_metric_set(), or
else the cow is done while rt6i_dst is still NULL.

If orig route points to readonly metrics, we can share the pointer
instead of performing the memory allocation and copy.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv6/route.c |   33 ++++++++++++++++++++-------------
 1 file changed, 20 insertions(+), 13 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 0ef1f08..5b5a32d 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -72,7 +72,8 @@
 #define RT6_TRACE(x...) do { ; } while (0)
 #endif
=20
-static struct rt6_info * ip6_rt_copy(struct rt6_info *ort);
+static struct rt6_info *ip6_rt_copy(const struct rt6_info *ort,
+				    const struct in6_addr *dest);
 static struct dst_entry	*ip6_dst_check(struct dst_entry *dst, u32 cook=
ie);
 static unsigned int	 ip6_default_advmss(const struct dst_entry *dst);
 static unsigned int	 ip6_default_mtu(const struct dst_entry *dst);
@@ -683,7 +684,8 @@ int ip6_ins_rt(struct rt6_info *rt)
 	return __ip6_ins_rt(rt, &info);
 }
=20
-static struct rt6_info *rt6_alloc_cow(struct rt6_info *ort, const stru=
ct in6_addr *daddr,
+static struct rt6_info *rt6_alloc_cow(const struct rt6_info *ort,
+				      const struct in6_addr *daddr,
 				      const struct in6_addr *saddr)
 {
 	struct rt6_info *rt;
@@ -692,7 +694,7 @@ static struct rt6_info *rt6_alloc_cow(struct rt6_in=
fo *ort, const struct in6_add
 	 *	Clone the route.
 	 */
=20
-	rt =3D ip6_rt_copy(ort);
+	rt =3D ip6_rt_copy(ort, daddr);
=20
 	if (rt) {
 		struct neighbour *neigh;
@@ -700,12 +702,11 @@ static struct rt6_info *rt6_alloc_cow(struct rt6_=
info *ort, const struct in6_add
=20
 		if (!(rt->rt6i_flags&RTF_GATEWAY)) {
 			if (rt->rt6i_dst.plen !=3D 128 &&
-			    ipv6_addr_equal(&rt->rt6i_dst.addr, daddr))
+			    ipv6_addr_equal(&ort->rt6i_dst.addr, daddr))
 				rt->rt6i_flags |=3D RTF_ANYCAST;
 			ipv6_addr_copy(&rt->rt6i_gateway, daddr);
 		}
=20
-		ipv6_addr_copy(&rt->rt6i_dst.addr, daddr);
 		rt->rt6i_dst.plen =3D 128;
 		rt->rt6i_flags |=3D RTF_CACHE;
 		rt->dst.flags |=3D DST_HOST;
@@ -752,11 +753,12 @@ static struct rt6_info *rt6_alloc_cow(struct rt6_=
info *ort, const struct in6_add
 	return rt;
 }
=20
-static struct rt6_info *rt6_alloc_clone(struct rt6_info *ort, const st=
ruct in6_addr *daddr)
+static struct rt6_info *rt6_alloc_clone(struct rt6_info *ort,
+					const struct in6_addr *daddr)
 {
-	struct rt6_info *rt =3D ip6_rt_copy(ort);
+	struct rt6_info *rt =3D ip6_rt_copy(ort, daddr);
+
 	if (rt) {
-		ipv6_addr_copy(&rt->rt6i_dst.addr, daddr);
 		rt->rt6i_dst.plen =3D 128;
 		rt->rt6i_flags |=3D RTF_CACHE;
 		rt->dst.flags |=3D DST_HOST;
@@ -900,7 +902,10 @@ struct dst_entry *ip6_blackhole_route(struct net *=
net, struct dst_entry *dst_ori
 		new->input =3D dst_discard;
 		new->output =3D dst_discard;
=20
-		dst_copy_metrics(new, &ort->dst);
+		if (dst_metrics_read_only(&ort->dst))
+			new->_metrics =3D ort->dst._metrics;
+		else
+			dst_copy_metrics(new, &ort->dst);
 		rt->rt6i_idev =3D ort->rt6i_idev;
 		if (rt->rt6i_idev)
 			in6_dev_hold(rt->rt6i_idev);
@@ -1060,6 +1065,7 @@ struct dst_entry *icmp6_dst_alloc(struct net_devi=
ce *dev,
 	rt->rt6i_idev     =3D idev;
 	rt->rt6i_nexthop  =3D neigh;
 	atomic_set(&rt->dst.__refcnt, 1);
+	ipv6_addr_copy(&rt->rt6i_dst.addr, addr);
 	dst_metric_set(&rt->dst, RTAX_HOPLIMIT, 255);
 	rt->dst.output  =3D ip6_output;
=20
@@ -1577,7 +1583,7 @@ void rt6_redirect(const struct in6_addr *dest, co=
nst struct in6_addr *src,
 	if (neigh =3D=3D rt->dst.neighbour)
 		goto out;
=20
-	nrt =3D ip6_rt_copy(rt);
+	nrt =3D ip6_rt_copy(rt, dest);
 	if (nrt =3D=3D NULL)
 		goto out;
=20
@@ -1585,7 +1591,6 @@ void rt6_redirect(const struct in6_addr *dest, co=
nst struct in6_addr *src,
 	if (on_link)
 		nrt->rt6i_flags &=3D ~RTF_GATEWAY;
=20
-	ipv6_addr_copy(&nrt->rt6i_dst.addr, dest);
 	nrt->rt6i_dst.plen =3D 128;
 	nrt->dst.flags |=3D DST_HOST;
=20
@@ -1723,7 +1728,8 @@ void rt6_pmtu_discovery(const struct in6_addr *da=
ddr, const struct in6_addr *sad
  *	Misc support functions
  */
=20
-static struct rt6_info * ip6_rt_copy(struct rt6_info *ort)
+static struct rt6_info *ip6_rt_copy(const struct rt6_info *ort,
+				    const struct in6_addr *dest)
 {
 	struct net *net =3D dev_net(ort->rt6i_dev);
 	struct rt6_info *rt =3D ip6_dst_alloc(&net->ipv6.ip6_dst_ops,
@@ -1733,6 +1739,8 @@ static struct rt6_info * ip6_rt_copy(struct rt6_i=
nfo *ort)
 		rt->dst.input =3D ort->dst.input;
 		rt->dst.output =3D ort->dst.output;
=20
+		ipv6_addr_copy(&rt->rt6i_dst.addr, dest);
+		rt->rt6i_dst.plen =3D ort->rt6i_dst.plen;
 		dst_copy_metrics(&rt->dst, &ort->dst);
 		rt->dst.error =3D ort->dst.error;
 		rt->rt6i_idev =3D ort->rt6i_idev;
@@ -1745,7 +1753,6 @@ static struct rt6_info * ip6_rt_copy(struct rt6_i=
nfo *ort)
 		rt->rt6i_flags =3D ort->rt6i_flags & ~RTF_EXPIRES;
 		rt->rt6i_metric =3D 0;
=20
-		memcpy(&rt->rt6i_dst, &ort->rt6i_dst, sizeof(struct rt6key));
 #ifdef CONFIG_IPV6_SUBTREES
 		memcpy(&rt->rt6i_src, &ort->rt6i_src, sizeof(struct rt6key));
 #endif
=09

