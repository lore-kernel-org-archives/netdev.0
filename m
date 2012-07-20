From: David Miller <davem@davemloft.net>
Subject: [PATCH 16/16] ipv4: Kill rt->fi
Date: Fri, 20 Jul 2012 14:27:02 -0700 (PDT)
Message-ID: <20120720.142702.661752484230616670.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55723 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753594Ab2GTV1D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 17:27:03 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 3330A583619
	for <netdev@vger.kernel.org>; Fri, 20 Jul 2012 14:27:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It's not really needed.

We only grabbed a reference to the fib_info for the sake of fib_info
local metrics.

However, fib_info objects are freed using RCU, as are therefore their
private metrics (if any).

We would have triggered a route cache flush if we eliminated a
reference to a fib_info object in the routing tables.

Therefore, any existing cached routes will first check and see that
they have been invalidated before an errant reference to these
metric values would occur.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/route.h |    1 -
 net/ipv4/route.c    |   32 +-------------------------------
 2 files changed, 1 insertion(+), 32 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index 4bafe0b..60d611d 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -56,7 +56,6 @@ struct rtable {
 
 	/* Miscellaneous cached information */
 	u32			rt_pmtu;
-	struct fib_info		*fi; /* for client ref to shared metrics */
 };
 
 static inline bool rt_is_input_route(const struct rtable *rt)
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index fac4c4a..9add088 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -141,7 +141,6 @@ static int ip_rt_min_advmss __read_mostly	= 256;
 static struct dst_entry *ipv4_dst_check(struct dst_entry *dst, u32 cookie);
 static unsigned int	 ipv4_default_advmss(const struct dst_entry *dst);
 static unsigned int	 ipv4_mtu(const struct dst_entry *dst);
-static void		 ipv4_dst_destroy(struct dst_entry *dst);
 static struct dst_entry *ipv4_negative_advice(struct dst_entry *dst);
 static void		 ipv4_link_failure(struct sk_buff *skb);
 static void		 ip_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
@@ -171,7 +170,6 @@ static struct dst_ops ipv4_dst_ops = {
 	.default_advmss =	ipv4_default_advmss,
 	.mtu =			ipv4_mtu,
 	.cow_metrics =		ipv4_cow_metrics,
-	.destroy =		ipv4_dst_destroy,
 	.ifdown =		ipv4_dst_ifdown,
 	.negative_advice =	ipv4_negative_advice,
 	.link_failure =		ipv4_link_failure,
@@ -1034,17 +1032,6 @@ static struct dst_entry *ipv4_dst_check(struct dst_entry *dst, u32 cookie)
 	return dst;
 }
 
-static void ipv4_dst_destroy(struct dst_entry *dst)
-{
-	struct rtable *rt = (struct rtable *) dst;
-
-	if (rt->fi) {
-		fib_info_put(rt->fi);
-		rt->fi = NULL;
-	}
-}
-
-
 static void ipv4_link_failure(struct sk_buff *skb)
 {
 	struct rtable *rt;
@@ -1158,15 +1145,6 @@ static unsigned int ipv4_mtu(const struct dst_entry *dst)
 	return mtu;
 }
 
-static void rt_init_metrics(struct rtable *rt, struct fib_info *fi)
-{
-	if (fi->fib_metrics != (u32 *) dst_default_metrics) {
-		rt->fi = fi;
-		atomic_inc(&fi->fib_clntref);
-	}
-	dst_init_metrics(&rt->dst, fi->fib_metrics, true);
-}
-
 static struct fib_nh_exception *find_exception(struct fib_nh *nh, __be32 daddr)
 {
 	struct fnhe_hash_bucket *hash = nh->nh_exceptions;
@@ -1261,7 +1239,7 @@ static void rt_set_nexthop(struct rtable *rt, __be32 daddr,
 			rt->rt_gateway = nh->nh_gw;
 		if (unlikely(fnhe))
 			rt_bind_exception(rt, fnhe, daddr);
-		rt_init_metrics(rt, fi);
+		dst_init_metrics(&rt->dst, fi->fib_metrics, true);
 #ifdef CONFIG_IP_ROUTE_CLASSID
 		rt->dst.tclassid = nh->nh_tclassid;
 #endif
@@ -1334,7 +1312,6 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	rth->rt_iif	= dev->ifindex;
 	rth->rt_pmtu	= 0;
 	rth->rt_gateway	= 0;
-	rth->fi = NULL;
 	if (our) {
 		rth->dst.input= ip_local_deliver;
 		rth->rt_flags |= RTCF_LOCAL;
@@ -1464,7 +1441,6 @@ static int __mkroute_input(struct sk_buff *skb,
 	rth->rt_iif 	= in_dev->dev->ifindex;
 	rth->rt_pmtu	= 0;
 	rth->rt_gateway	= 0;
-	rth->fi = NULL;
 
 	rth->dst.input = ip_forward;
 	rth->dst.output = ip_output;
@@ -1642,7 +1618,6 @@ local_input:
 	rth->rt_iif	= dev->ifindex;
 	rth->rt_pmtu	= 0;
 	rth->rt_gateway	= 0;
-	rth->fi = NULL;
 	if (res.type == RTN_UNREACHABLE) {
 		rth->dst.input= ip_error;
 		rth->dst.error= -err;
@@ -1807,7 +1782,6 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 	rth->rt_iif	= orig_oif ? : dev_out->ifindex;
 	rth->rt_pmtu	= 0;
 	rth->rt_gateway = 0;
-	rth->fi = NULL;
 
 	RT_CACHE_STAT_INC(out_slow_tot);
 
@@ -2052,7 +2026,6 @@ static u32 *ipv4_rt_blackhole_cow_metrics(struct dst_entry *dst,
 static struct dst_ops ipv4_dst_blackhole_ops = {
 	.family			=	AF_INET,
 	.protocol		=	cpu_to_be16(ETH_P_IP),
-	.destroy		=	ipv4_dst_destroy,
 	.check			=	ipv4_blackhole_dst_check,
 	.mtu			=	ipv4_blackhole_mtu,
 	.default_advmss		=	ipv4_default_advmss,
@@ -2087,9 +2060,6 @@ struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_or
 		rt->rt_flags = ort->rt_flags;
 		rt->rt_type = ort->rt_type;
 		rt->rt_gateway = ort->rt_gateway;
-		rt->fi = ort->fi;
-		if (rt->fi)
-			atomic_inc(&rt->fi->fib_clntref);
 
 		dst_free(new);
 	}
-- 
1.7.10.4
