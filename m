From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/4] ipv6: Get rid of rt6i_nexthop macro.
Date: Mon, 18 Jul 2011 01:25:10 -0700 (PDT)
Message-ID: <20110718.012510.2058584207693475315.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57617 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754772Ab1GRIZM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 04:25:12 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p6I8PAW5028275
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 18 Jul 2011 01:25:11 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It just makes it harder to see 1) what the code is doing
and 2) grep for all users of dst{->,.}neighbour

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip6_fib.h |    1 -
 net/ipv6/addrconf.c   |    2 +-
 net/ipv6/ip6_fib.c    |    2 +-
 net/ipv6/ndisc.c      |    4 ++--
 net/ipv6/route.c      |   30 +++++++++++++++---------------
 5 files changed, 19 insertions(+), 20 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 477ef75..5735a0f 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -87,7 +87,6 @@ struct rt6_info {
 	struct dst_entry		dst;
 
 #define rt6i_dev			dst.dev
-#define rt6i_nexthop			dst.neighbour
 #define rt6i_expires			dst.expires
 
 	/*
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index fc6d377..48cd03d 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -656,7 +656,7 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr, int pfxlen,
 	 * layer address of our nexhop router
 	 */
 
-	if (rt->rt6i_nexthop == NULL)
+	if (rt->dst.neighbour == NULL)
 		ifa->flags &= ~IFA_F_OPTIMISTIC;
 
 	ifa->idev = idev;
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 3030bdf..158df23 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1455,7 +1455,7 @@ static int fib6_age(struct rt6_info *rt, void *arg)
 			RT6_TRACE("aging clone %p\n", rt);
 			return -1;
 		} else if ((rt->rt6i_flags & RTF_GATEWAY) &&
-			   (!(rt->rt6i_nexthop->flags & NTF_ROUTER))) {
+			   (!(rt->dst.neighbour->flags & NTF_ROUTER))) {
 			RT6_TRACE("purging route %p via non-router but gateway\n",
 				  rt);
 			return -1;
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index e08ce55..a997d41 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1238,7 +1238,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 	rt = rt6_get_dflt_router(&ipv6_hdr(skb)->saddr, skb->dev);
 
 	if (rt)
-		neigh = rt->rt6i_nexthop;
+		neigh = rt->dst.neighbour;
 
 	if (rt && lifetime == 0) {
 		neigh_clone(neigh);
@@ -1259,7 +1259,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 			return;
 		}
 
-		neigh = rt->rt6i_nexthop;
+		neigh = rt->dst.neighbour;
 		if (neigh == NULL) {
 			ND_PRINTK0(KERN_ERR
 				   "ICMPv6 RA: %s() got default router without neighbour.\n",
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index f032d77..c1515a3 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -356,7 +356,7 @@ out:
 #ifdef CONFIG_IPV6_ROUTER_PREF
 static void rt6_probe(struct rt6_info *rt)
 {
-	struct neighbour *neigh = rt ? rt->rt6i_nexthop : NULL;
+	struct neighbour *neigh = rt ? rt->dst.neighbour : NULL;
 	/*
 	 * Okay, this does not seem to be appropriate
 	 * for now, however, we need to check if it
@@ -404,7 +404,7 @@ static inline int rt6_check_dev(struct rt6_info *rt, int oif)
 
 static inline int rt6_check_neigh(struct rt6_info *rt)
 {
-	struct neighbour *neigh = rt->rt6i_nexthop;
+	struct neighbour *neigh = rt->dst.neighbour;
 	int m;
 	if (rt->rt6i_flags & RTF_NONEXTHOP ||
 	    !(rt->rt6i_flags & RTF_GATEWAY))
@@ -745,7 +745,7 @@ static struct rt6_info *rt6_alloc_cow(struct rt6_info *ort, const struct in6_add
 			dst_free(&rt->dst);
 			return NULL;
 		}
-		rt->rt6i_nexthop = neigh;
+		rt->dst.neighbour = neigh;
 
 	}
 
@@ -760,7 +760,7 @@ static struct rt6_info *rt6_alloc_clone(struct rt6_info *ort, const struct in6_a
 		rt->rt6i_dst.plen = 128;
 		rt->rt6i_flags |= RTF_CACHE;
 		rt->dst.flags |= DST_HOST;
-		rt->rt6i_nexthop = neigh_clone(ort->rt6i_nexthop);
+		rt->dst.neighbour = neigh_clone(ort->dst.neighbour);
 	}
 	return rt;
 }
@@ -794,7 +794,7 @@ restart:
 	dst_hold(&rt->dst);
 	read_unlock_bh(&table->tb6_lock);
 
-	if (!rt->rt6i_nexthop && !(rt->rt6i_flags & RTF_NONEXTHOP))
+	if (!rt->dst.neighbour && !(rt->rt6i_flags & RTF_NONEXTHOP))
 		nrt = rt6_alloc_cow(rt, &fl6->daddr, &fl6->saddr);
 	else if (!(rt->dst.flags & DST_HOST))
 		nrt = rt6_alloc_clone(rt, &fl6->daddr);
@@ -1058,7 +1058,7 @@ struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 	}
 
 	rt->rt6i_idev     = idev;
-	rt->rt6i_nexthop  = neigh;
+	rt->dst.neighbour  = neigh;
 	atomic_set(&rt->dst.__refcnt, 1);
 	dst_metric_set(&rt->dst, RTAX_HOPLIMIT, 255);
 	rt->dst.output  = ip6_output;
@@ -1338,10 +1338,10 @@ int ip6_route_add(struct fib6_config *cfg)
 		rt->rt6i_prefsrc.plen = 0;
 
 	if (cfg->fc_flags & (RTF_GATEWAY | RTF_NONEXTHOP)) {
-		rt->rt6i_nexthop = __neigh_lookup_errno(&nd_tbl, &rt->rt6i_gateway, dev);
-		if (IS_ERR(rt->rt6i_nexthop)) {
-			err = PTR_ERR(rt->rt6i_nexthop);
-			rt->rt6i_nexthop = NULL;
+		rt->dst.neighbour = __neigh_lookup_errno(&nd_tbl, &rt->rt6i_gateway, dev);
+		if (IS_ERR(rt->dst.neighbour)) {
+			err = PTR_ERR(rt->dst.neighbour);
+			rt->dst.neighbour = NULL;
 			goto out;
 		}
 	}
@@ -1590,7 +1590,7 @@ void rt6_redirect(const struct in6_addr *dest, const struct in6_addr *src,
 	nrt->dst.flags |= DST_HOST;
 
 	ipv6_addr_copy(&nrt->rt6i_gateway, (struct in6_addr*)neigh->primary_key);
-	nrt->rt6i_nexthop = neigh_clone(neigh);
+	nrt->dst.neighbour = neigh_clone(neigh);
 
 	if (ip6_ins_rt(nrt))
 		goto out;
@@ -1670,7 +1670,7 @@ again:
 	   1. It is connected route. Action: COW
 	   2. It is gatewayed route or NONEXTHOP route. Action: clone it.
 	 */
-	if (!rt->rt6i_nexthop && !(rt->rt6i_flags & RTF_NONEXTHOP))
+	if (!rt->dst.neighbour && !(rt->rt6i_flags & RTF_NONEXTHOP))
 		nrt = rt6_alloc_cow(rt, daddr, saddr);
 	else
 		nrt = rt6_alloc_clone(rt, daddr);
@@ -2035,7 +2035,7 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 
 		return ERR_CAST(neigh);
 	}
-	rt->rt6i_nexthop = neigh;
+	rt->dst.neighbour = neigh;
 
 	ipv6_addr_copy(&rt->rt6i_dst.addr, addr);
 	rt->rt6i_dst.plen = 128;
@@ -2594,8 +2594,8 @@ static int rt6_info_route(struct rt6_info *rt, void *p_arg)
 	seq_puts(m, "00000000000000000000000000000000 00 ");
 #endif
 
-	if (rt->rt6i_nexthop) {
-		seq_printf(m, "%pi6", rt->rt6i_nexthop->primary_key);
+	if (rt->dst.neighbour) {
+		seq_printf(m, "%pi6", rt->dst.neighbour->primary_key);
 	} else {
 		seq_puts(m, "00000000000000000000000000000000");
 	}
-- 
1.7.6

