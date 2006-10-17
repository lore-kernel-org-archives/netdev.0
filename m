From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: [PATCH 12/13] [RFC] [IPV6] Make sure route cache entries have a valid
 source address.
Date: Tue, 17 Oct 2006 03:26:02 +0300
Message-ID: <4534231A.6070903@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Thomas Graf <tgraf@suug.ch>, kim.nordlund@nokia.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from neon.tcs.hut.fi ([130.233.215.20]:17170 "EHLO neon.tcs.hut.fi")
	by vger.kernel.org with ESMTP id S1422980AbWJQA0E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2006 20:26:04 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Leaving out the source address from routing cache entries when
using routing subtrees causes all kinds of problems. Make sure
this doesn't happen.

Signed-off-by: Ville Nuorvala <vnuorval@tcs.hut.fi>
---
 net/ipv6/route.c |   31 +++++++++++++++++--------------
 1 files changed, 17 insertions(+), 14 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 7cd7747..7c3438e 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -594,29 +594,28 @@ static struct rt6_info *rt6_alloc_cow(st

 		ipv6_addr_copy(&rt->rt6i_dst.addr, daddr);
 		rt->rt6i_dst.plen = 128;
-		rt->rt6i_flags |= RTF_CACHE;
-		rt->u.dst.flags |= DST_HOST;
-
 #ifdef CONFIG_IPV6_SUBTREES
-		if (rt->rt6i_src.plen && saddr) {
-			ipv6_addr_copy(&rt->rt6i_src.addr, saddr);
-			rt->rt6i_src.plen = 128;
-		}
+		ipv6_addr_copy(&rt->rt6i_src.addr, saddr);
+		rt->rt6i_src.plen = 128;
 #endif
-
+		rt->rt6i_flags |= RTF_CACHE;
+		rt->u.dst.flags |= DST_HOST;
 		rt->rt6i_nexthop = ndisc_get_neigh(rt->rt6i_dev, &rt->rt6i_gateway);
-
 	}

 	return rt;
 }

-static struct rt6_info *rt6_alloc_clone(struct rt6_info *ort, struct in6_addr *daddr)
+static struct rt6_info *rt6_alloc_clone(struct rt6_info *ort, struct in6_addr *daddr, struct
in6_addr *saddr)
 {
 	struct rt6_info *rt = ip6_rt_copy(ort);
 	if (rt) {
 		ipv6_addr_copy(&rt->rt6i_dst.addr, daddr);
 		rt->rt6i_dst.plen = 128;
+#ifdef CONFIG_IPV6_SUBTREES
+		ipv6_addr_copy(&rt->rt6i_src.addr, saddr);
+		rt->rt6i_src.plen = 128;
+#endif
 		rt->rt6i_flags |= RTF_CACHE;
 		rt->u.dst.flags |= DST_HOST;
 		rt->rt6i_nexthop = neigh_clone(ort->rt6i_nexthop);
@@ -654,7 +653,7 @@ restart:
 		nrt = rt6_alloc_cow(rt, &fl->fl6_dst, &fl->fl6_src);
 	else {
 #if CLONE_OFFLINK_ROUTE
-		nrt = rt6_alloc_clone(rt, &fl->fl6_dst);
+		nrt = rt6_alloc_clone(rt, &fl->fl6_dst, &fl->fl6_src);
 #else
 		goto out2;
 #endif
@@ -756,10 +755,10 @@ restart:
 		ipv6_addr_copy(&fl->fl6_src, &saddr);
 	}
 	if (!rt->rt6i_nexthop && !(rt->rt6i_flags & RTF_NONEXTHOP))
-		nrt = rt6_alloc_cow(rt, &fl->fl6_dst, &fl->fl6_src);
+		nrt = rt6_alloc_cow(rt, &fl->fl6_dst, &saddr);
 	else {
 #if CLONE_OFFLINK_ROUTE
-		nrt = rt6_alloc_clone(rt, &fl->fl6_dst);
+		nrt = rt6_alloc_clone(rt, &fl->fl6_dst, &saddr);
 #else
 		goto out2;
 #endif
@@ -1429,6 +1428,10 @@ void rt6_redirect(struct in6_addr *dest,

 	ipv6_addr_copy(&nrt->rt6i_dst.addr, dest);
 	nrt->rt6i_dst.plen = 128;
+#ifdef CONFIG_IPV6_SUBTREES
+	ipv6_addr_copy(&nrt->rt6i_src.addr, src);
+	nrt->rt6i_src.plen = 128;
+#endif
 	nrt->u.dst.flags |= DST_HOST;

 	ipv6_addr_copy(&nrt->rt6i_gateway, (struct in6_addr*)neigh->primary_key);
@@ -1511,7 +1514,7 @@ void rt6_pmtu_discovery(struct in6_addr
 	if (!rt->rt6i_nexthop && !(rt->rt6i_flags & RTF_NONEXTHOP))
 		nrt = rt6_alloc_cow(rt, daddr, saddr);
 	else
-		nrt = rt6_alloc_clone(rt, daddr);
+		nrt = rt6_alloc_clone(rt, daddr, saddr);

 	if (nrt) {
 		nrt->u.dst.metrics[RTAX_MTU-1] = pmtu;
-- 
1.4.2.3

