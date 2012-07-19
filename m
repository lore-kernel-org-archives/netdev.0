From: David Miller <davem@davemloft.net>
Subject: [PATCH 11/16] ipv4: Cache input routes in fib_info nexthops.
Date: Thu, 19 Jul 2012 14:35:49 -0700 (PDT)
Message-ID: <20120719.143549.1214861493400600386.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48294 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751499Ab2GSVfw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 17:35:52 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 49FFA5845A1
	for <netdev@vger.kernel.org>; Thu, 19 Jul 2012 14:35:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Caching input routes is slightly simpler than output routes, since we
don't need to be concerned with nexthop exceptions.  (locally
destined, and routed packets, never trigger PMTU events or redirects
that will be processed by us).

However, we have to elide caching for the DIRECTSRC and non-zero itag
cases.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip_fib.h     |    1 +
 net/ipv4/fib_semantics.c |    2 ++
 net/ipv4/route.c         |   55 ++++++++++++++++++++++++++++++++++++----------
 3 files changed, 46 insertions(+), 12 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index fb62c59..e69c3a4 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -82,6 +82,7 @@ struct fib_nh {
 	__be32			nh_saddr;
 	int			nh_saddr_genid;
 	struct rtable		*nh_rth_output;
+	struct rtable		*nh_rth_input;
 	struct fnhe_hash_bucket	*nh_exceptions;
 };
 
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 83d0f42..e55171f 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -173,6 +173,8 @@ static void free_fib_info_rcu(struct rcu_head *head)
 			free_nh_exceptions(nexthop_nh);
 		if (nexthop_nh->nh_rth_output)
 			dst_release(&nexthop_nh->nh_rth_output->dst);
+		if (nexthop_nh->nh_rth_input)
+			dst_release(&nexthop_nh->nh_rth_input->dst);
 	} endfor_nexthops(fi);
 
 	release_net(fi->fib_net);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 8d8b3b2..fe0aad9 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1225,6 +1225,9 @@ static void rt_cache_route(struct fib_nh *nh, struct rtable *rt)
 {
 	struct rtable *orig, *prev, **p = &nh->nh_rth_output;
 
+	if (rt_is_input_route(rt))
+		p = &nh->nh_rth_input;
+
 	orig = *p;
 
 	prev = cmpxchg(p, orig, rt);
@@ -1235,6 +1238,11 @@ static void rt_cache_route(struct fib_nh *nh, struct rtable *rt)
 	}
 }
 
+static bool rt_cache_valid(struct rtable *rt)
+{
+	return (rt && rt->dst.obsolete == DST_OBSOLETE_FORCE_CHK);
+}
+
 static void rt_set_nexthop(struct rtable *rt, __be32 daddr,
 			   const struct fib_result *res,
 			   struct fib_nh_exception *fnhe,
@@ -1251,8 +1259,7 @@ static void rt_set_nexthop(struct rtable *rt, __be32 daddr,
 #ifdef CONFIG_IP_ROUTE_CLASSID
 		rt->dst.tclassid = nh->nh_tclassid;
 #endif
-		if (!(rt->dst.flags & DST_HOST) &&
-		    rt_is_output_route(rt))
+		if (!(rt->dst.flags & DST_HOST))
 			rt_cache_route(nh, rt);
 	}
 
@@ -1378,11 +1385,11 @@ static int __mkroute_input(struct sk_buff *skb,
 			   __be32 daddr, __be32 saddr, u32 tos,
 			   struct rtable **result)
 {
-	struct fib_nh_exception *fnhe;
 	struct rtable *rth;
 	int err;
 	struct in_device *out_dev;
 	unsigned int flags = 0;
+	bool do_cache;
 	u32 itag;
 
 	/* get a working reference to the output device */
@@ -1425,13 +1432,21 @@ static int __mkroute_input(struct sk_buff *skb,
 		}
 	}
 
-	fnhe = NULL;
-	if (res->fi)
-		fnhe = find_exception(&FIB_RES_NH(*res), daddr);
+	do_cache = false;
+	if (res->fi) {
+		if (!(flags & RTCF_DIRECTSRC) && !itag) {
+			rth = FIB_RES_NH(*res).nh_rth_input;
+			if (rt_cache_valid(rth)) {
+				dst_use(&rth->dst, jiffies);
+				goto out;
+			}
+			do_cache = true;
+		}
+	}
 
 	rth = rt_dst_alloc(out_dev->dev,
 			   IN_DEV_CONF_GET(in_dev, NOPOLICY),
-			   IN_DEV_CONF_GET(out_dev, NOXFRM), false);
+			   IN_DEV_CONF_GET(out_dev, NOXFRM), do_cache);
 	if (!rth) {
 		err = -ENOBUFS;
 		goto cleanup;
@@ -1450,8 +1465,8 @@ static int __mkroute_input(struct sk_buff *skb,
 	rth->dst.input = ip_forward;
 	rth->dst.output = ip_output;
 
-	rt_set_nexthop(rth, daddr, res, fnhe, res->fi, res->type, itag);
-
+	rt_set_nexthop(rth, daddr, res, NULL, res->fi, res->type, itag);
+out:
 	*result = rth;
 	err = 0;
  cleanup:
@@ -1503,6 +1518,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	struct rtable	*rth;
 	int		err = -EINVAL;
 	struct net    *net = dev_net(dev);
+	bool do_cache;
 
 	/* IP on this device is disabled. */
 
@@ -1516,6 +1532,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	if (ipv4_is_multicast(saddr) || ipv4_is_lbcast(saddr))
 		goto martian_source;
 
+	res.fi = NULL;
 	if (ipv4_is_lbcast(daddr) || (saddr == 0 && daddr == 0))
 		goto brd_input;
 
@@ -1591,8 +1608,20 @@ brd_input:
 	RT_CACHE_STAT_INC(in_brd);
 
 local_input:
+	do_cache = false;
+	if (res.fi) {
+		if (!(flags & RTCF_DIRECTSRC) && !itag) {
+			rth = FIB_RES_NH(res).nh_rth_input;
+			if (rt_cache_valid(rth)) {
+				dst_use(&rth->dst, jiffies);
+				goto set_and_out;
+			}
+			do_cache = true;
+		}
+	}
+
 	rth = rt_dst_alloc(net->loopback_dev,
-			   IN_DEV_CONF_GET(in_dev, NOPOLICY), false, false);
+			   IN_DEV_CONF_GET(in_dev, NOPOLICY), false, do_cache);
 	if (!rth)
 		goto e_nobufs;
 
@@ -1616,6 +1645,9 @@ local_input:
 		rth->dst.error= -err;
 		rth->rt_flags 	&= ~RTCF_LOCAL;
 	}
+	if (do_cache)
+		rt_cache_route(&FIB_RES_NH(res), rth);
+set_and_out:
 	skb_dst_set(skb, &rth->dst);
 	err = 0;
 	goto out;
@@ -1750,8 +1782,7 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 		fnhe = find_exception(&FIB_RES_NH(*res), fl4->daddr);
 		if (!fnhe) {
 			rth = FIB_RES_NH(*res).nh_rth_output;
-			if (rth &&
-			    rth->dst.obsolete == DST_OBSOLETE_FORCE_CHK) {
+			if (rt_cache_valid(rth)) {
 				dst_use(&rth->dst, jiffies);
 				return rth;
 			}
-- 
1.7.10.4
