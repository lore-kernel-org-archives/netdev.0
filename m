From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net v2 4/6] ipv4: introduce rt_uses_gateway
Date: Tue,  9 Oct 2012 00:41:18 +0300
Message-ID: <1349732480-19978-5-git-send-email-ja@ssi.bg>
References: <1349732480-19978-1-git-send-email-ja@ssi.bg>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:44338 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751692Ab2JHVgD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Oct 2012 17:36:03 -0400
Received: from ja.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.14.4/8.14.4) with ESMTP id q98LfY9I020026
	for <netdev@vger.kernel.org>; Tue, 9 Oct 2012 00:41:34 +0300
Received: (from root@localhost)
	by ja.ssi.bg (8.14.4/8.14.4/Submit) id q98LfYXk020025
	for netdev@vger.kernel.org; Tue, 9 Oct 2012 00:41:34 +0300
In-Reply-To: <1349732480-19978-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Add new flag to remember when route is via gateway.
We will use it to allow rt_gateway to contain address of
directly connected host for the cases when DST_NOCACHE is
used or when the NH exception caches per-destination route
without DST_NOCACHE flag, i.e. when routes are not used for
other destinations. By this way we force the neighbour
resolving to work with the routed destination but we
can use different address in the packet, feature needed
for IPVS-DR where original packet for virtual IP is routed
via route to real IP.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/route.h             |    3 +-
 net/ipv4/inet_connection_sock.c |    4 +-
 net/ipv4/ip_forward.c           |    2 +-
 net/ipv4/ip_output.c            |    4 +-
 net/ipv4/route.c                |   48 +++++++++++++++++++++-----------------
 net/ipv4/xfrm4_policy.c         |    1 +
 6 files changed, 34 insertions(+), 28 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index da22243..bc40b63 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -48,7 +48,8 @@ struct rtable {
 	int			rt_genid;
 	unsigned int		rt_flags;
 	__u16			rt_type;
-	__u16			rt_is_input;
+	__u8			rt_is_input;
+	__u8			rt_uses_gateway;
 
 	int			rt_iif;
 
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index f0c5b9c..d34ce29 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -406,7 +406,7 @@ struct dst_entry *inet_csk_route_req(struct sock *sk,
 	rt = ip_route_output_flow(net, fl4, sk);
 	if (IS_ERR(rt))
 		goto no_route;
-	if (opt && opt->opt.is_strictroute && rt->rt_gateway)
+	if (opt && opt->opt.is_strictroute && rt->rt_uses_gateway)
 		goto route_err;
 	return &rt->dst;
 
@@ -442,7 +442,7 @@ struct dst_entry *inet_csk_route_child_sock(struct sock *sk,
 	rt = ip_route_output_flow(net, fl4, sk);
 	if (IS_ERR(rt))
 		goto no_route;
-	if (opt && opt->opt.is_strictroute && rt->rt_gateway)
+	if (opt && opt->opt.is_strictroute && rt->rt_uses_gateway)
 		goto route_err;
 	rcu_read_unlock();
 	return &rt->dst;
diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index 7f35ac2..694de3b 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -85,7 +85,7 @@ int ip_forward(struct sk_buff *skb)
 
 	rt = skb_rtable(skb);
 
-	if (opt->is_strictroute && rt->rt_gateway)
+	if (opt->is_strictroute && rt->rt_uses_gateway)
 		goto sr_failed;
 
 	if (unlikely(skb->len > dst_mtu(&rt->dst) && !skb_is_gso(skb) &&
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 24a29a3..6537a40 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -193,7 +193,7 @@ static inline int ip_finish_output2(struct sk_buff *skb)
 	}
 
 	rcu_read_lock_bh();
-	nexthop = rt->rt_gateway ? rt->rt_gateway : ip_hdr(skb)->daddr;
+	nexthop = (__force u32) rt_nexthop(rt, ip_hdr(skb)->daddr);
 	neigh = __ipv4_neigh_lookup_noref(dev, nexthop);
 	if (unlikely(!neigh))
 		neigh = __neigh_create(&arp_tbl, &nexthop, dev, false);
@@ -371,7 +371,7 @@ int ip_queue_xmit(struct sk_buff *skb, struct flowi *fl)
 	skb_dst_set_noref(skb, &rt->dst);
 
 packet_routed:
-	if (inet_opt && inet_opt->opt.is_strictroute && rt->rt_gateway)
+	if (inet_opt && inet_opt->opt.is_strictroute && rt->rt_uses_gateway)
 		goto no_route;
 
 	/* OK, we know where to send it, allocate and build IP header. */
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 5b0180f..3a116cb 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1126,7 +1126,7 @@ static unsigned int ipv4_mtu(const struct dst_entry *dst)
 	mtu = dst->dev->mtu;
 
 	if (unlikely(dst_metric_locked(dst, RTAX_MTU))) {
-		if (rt->rt_gateway && mtu > 576)
+		if (rt->rt_uses_gateway && mtu > 576)
 			mtu = 576;
 	}
 
@@ -1177,7 +1177,9 @@ static bool rt_bind_exception(struct rtable *rt, struct fib_nh_exception *fnhe,
 		if (fnhe->fnhe_gw) {
 			rt->rt_flags |= RTCF_REDIRECTED;
 			rt->rt_gateway = fnhe->fnhe_gw;
-		}
+			rt->rt_uses_gateway = 1;
+		} else if (!rt->rt_gateway)
+			rt->rt_gateway = daddr;
 
 		orig = rcu_dereference(fnhe->fnhe_rth);
 		rcu_assign_pointer(fnhe->fnhe_rth, rt);
@@ -1186,13 +1188,6 @@ static bool rt_bind_exception(struct rtable *rt, struct fib_nh_exception *fnhe,
 
 		fnhe->fnhe_stamp = jiffies;
 		ret = true;
-	} else {
-		/* Routes we intend to cache in nexthop exception have
-		 * the DST_NOCACHE bit clear.  However, if we are
-		 * unsuccessful at storing this route into the cache
-		 * we really need to set it.
-		 */
-		rt->dst.flags |= DST_NOCACHE;
 	}
 	spin_unlock_bh(&fnhe_lock);
 
@@ -1215,15 +1210,8 @@ static bool rt_cache_route(struct fib_nh *nh, struct rtable *rt)
 	if (prev == orig) {
 		if (orig)
 			rt_free(orig);
-	} else {
-		/* Routes we intend to cache in the FIB nexthop have
-		 * the DST_NOCACHE bit clear.  However, if we are
-		 * unsuccessful at storing this route into the cache
-		 * we really need to set it.
-		 */
-		rt->dst.flags |= DST_NOCACHE;
+	} else
 		ret = false;
-	}
 
 	return ret;
 }
@@ -1284,8 +1272,10 @@ static void rt_set_nexthop(struct rtable *rt, __be32 daddr,
 	if (fi) {
 		struct fib_nh *nh = &FIB_RES_NH(*res);
 
-		if (nh->nh_gw && nh->nh_scope == RT_SCOPE_LINK)
+		if (nh->nh_gw && nh->nh_scope == RT_SCOPE_LINK) {
 			rt->rt_gateway = nh->nh_gw;
+			rt->rt_uses_gateway = 1;
+		}
 		dst_init_metrics(&rt->dst, fi->fib_metrics, true);
 #ifdef CONFIG_IP_ROUTE_CLASSID
 		rt->dst.tclassid = nh->nh_tclassid;
@@ -1294,8 +1284,18 @@ static void rt_set_nexthop(struct rtable *rt, __be32 daddr,
 			cached = rt_bind_exception(rt, fnhe, daddr);
 		else if (!(rt->dst.flags & DST_NOCACHE))
 			cached = rt_cache_route(nh, rt);
-	}
-	if (unlikely(!cached))
+		if (unlikely(!cached)) {
+			/* Routes we intend to cache in nexthop exception or
+			 * FIB nexthop have the DST_NOCACHE bit clear.
+			 * However, if we are unsuccessful at storing this
+			 * route into the cache we really need to set it.
+			 */
+			rt->dst.flags |= DST_NOCACHE;
+			if (!rt->rt_gateway)
+				rt->rt_gateway = daddr;
+			rt_add_uncached_list(rt);
+		}
+	} else
 		rt_add_uncached_list(rt);
 
 #ifdef CONFIG_IP_ROUTE_CLASSID
@@ -1363,6 +1363,7 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	rth->rt_iif	= 0;
 	rth->rt_pmtu	= 0;
 	rth->rt_gateway	= 0;
+	rth->rt_uses_gateway = 0;
 	INIT_LIST_HEAD(&rth->rt_uncached);
 	if (our) {
 		rth->dst.input= ip_local_deliver;
@@ -1432,7 +1433,6 @@ static int __mkroute_input(struct sk_buff *skb,
 		return -EINVAL;
 	}
 
-
 	err = fib_validate_source(skb, saddr, daddr, tos, FIB_RES_OIF(*res),
 				  in_dev->dev, in_dev, &itag);
 	if (err < 0) {
@@ -1488,6 +1488,7 @@ static int __mkroute_input(struct sk_buff *skb,
 	rth->rt_iif 	= 0;
 	rth->rt_pmtu	= 0;
 	rth->rt_gateway	= 0;
+	rth->rt_uses_gateway = 0;
 	INIT_LIST_HEAD(&rth->rt_uncached);
 
 	rth->dst.input = ip_forward;
@@ -1658,6 +1659,7 @@ local_input:
 	rth->rt_iif	= 0;
 	rth->rt_pmtu	= 0;
 	rth->rt_gateway	= 0;
+	rth->rt_uses_gateway = 0;
 	INIT_LIST_HEAD(&rth->rt_uncached);
 	if (res.type == RTN_UNREACHABLE) {
 		rth->dst.input= ip_error;
@@ -1826,6 +1828,7 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 	rth->rt_iif	= orig_oif ? : 0;
 	rth->rt_pmtu	= 0;
 	rth->rt_gateway = 0;
+	rth->rt_uses_gateway = 0;
 	INIT_LIST_HEAD(&rth->rt_uncached);
 
 	RT_CACHE_STAT_INC(out_slow_tot);
@@ -2104,6 +2107,7 @@ struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_or
 		rt->rt_flags = ort->rt_flags;
 		rt->rt_type = ort->rt_type;
 		rt->rt_gateway = ort->rt_gateway;
+		rt->rt_uses_gateway = ort->rt_uses_gateway;
 
 		INIT_LIST_HEAD(&rt->rt_uncached);
 
@@ -2182,7 +2186,7 @@ static int rt_fill_info(struct net *net,  __be32 dst, __be32 src,
 		if (nla_put_be32(skb, RTA_PREFSRC, fl4->saddr))
 			goto nla_put_failure;
 	}
-	if (rt->rt_gateway &&
+	if (rt->rt_uses_gateway &&
 	    nla_put_be32(skb, RTA_GATEWAY, rt->rt_gateway))
 		goto nla_put_failure;
 
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 681ea2f..05c5ab8 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -91,6 +91,7 @@ static int xfrm4_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
 					      RTCF_LOCAL);
 	xdst->u.rt.rt_type = rt->rt_type;
 	xdst->u.rt.rt_gateway = rt->rt_gateway;
+	xdst->u.rt.rt_uses_gateway = rt->rt_uses_gateway;
 	xdst->u.rt.rt_pmtu = rt->rt_pmtu;
 	INIT_LIST_HEAD(&xdst->u.rt.rt_uncached);
 
-- 
1.7.3.4
