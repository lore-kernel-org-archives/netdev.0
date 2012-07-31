From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/2] ipv4: Properly purge netdev references on uncached
 routes.
Date: Tue, 31 Jul 2012 15:20:33 -0700 (PDT)
Message-ID: <20120731.152033.1148018322961121079.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41073 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753436Ab2GaWUe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2012 18:20:34 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 2B878582E8E
	for <netdev@vger.kernel.org>; Tue, 31 Jul 2012 15:20:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When a device is unregistered, we have to purge all of the
references to it that may exist in the entire system.

If a route is uncached, we currently have no way of accomplishing
this.

So create a global list that is scanned when a network device goes
down.  This mirrors the logic in net/core/dst.c's dst_ifdown().

Signed-off-by: David S. Miller <davem@davemloft.net>
---

This is just a respin of what I posted the other day, against Eric's
fixes of today.  Pushed to 'net'.

diff --git a/include/net/route.h b/include/net/route.h
index 8c52bc6..776a27f 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -57,6 +57,8 @@ struct rtable {
 
 	/* Miscellaneous cached information */
 	u32			rt_pmtu;
+
+	struct list_head	rt_uncached;
 };
 
 static inline bool rt_is_input_route(const struct rtable *rt)
@@ -107,6 +109,7 @@ extern struct ip_rt_acct __percpu *ip_rt_acct;
 struct in_device;
 extern int		ip_rt_init(void);
 extern void		rt_cache_flush(struct net *net, int how);
+extern void		rt_flush_dev(struct net_device *dev);
 extern struct rtable *__ip_route_output_key(struct net *, struct flowi4 *flp);
 extern struct rtable *ip_route_output_flow(struct net *, struct flowi4 *flp,
 					   struct sock *sk);
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 8732cc7..c43ae3f 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -1046,6 +1046,7 @@ static int fib_netdev_event(struct notifier_block *this, unsigned long event, vo
 
 	if (event == NETDEV_UNREGISTER) {
 		fib_disable_ip(dev, 2, -1);
+		rt_flush_dev(dev);
 		return NOTIFY_DONE;
 	}
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index b102eeb..c035251 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -147,6 +147,7 @@ static void		 ip_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
 					   struct sk_buff *skb, u32 mtu);
 static void		 ip_do_redirect(struct dst_entry *dst, struct sock *sk,
 					struct sk_buff *skb);
+static void		ipv4_dst_destroy(struct dst_entry *dst);
 
 static void ipv4_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 			    int how)
@@ -170,6 +171,7 @@ static struct dst_ops ipv4_dst_ops = {
 	.default_advmss =	ipv4_default_advmss,
 	.mtu =			ipv4_mtu,
 	.cow_metrics =		ipv4_cow_metrics,
+	.destroy =		ipv4_dst_destroy,
 	.ifdown =		ipv4_dst_ifdown,
 	.negative_advice =	ipv4_negative_advice,
 	.link_failure =		ipv4_link_failure,
@@ -1175,9 +1177,11 @@ static struct fib_nh_exception *find_exception(struct fib_nh *nh, __be32 daddr)
 	return NULL;
 }
 
-static void rt_bind_exception(struct rtable *rt, struct fib_nh_exception *fnhe,
+static bool rt_bind_exception(struct rtable *rt, struct fib_nh_exception *fnhe,
 			      __be32 daddr)
 {
+	bool ret = false;
+
 	spin_lock_bh(&fnhe_lock);
 
 	if (daddr == fnhe->fnhe_daddr) {
@@ -1203,6 +1207,7 @@ static void rt_bind_exception(struct rtable *rt, struct fib_nh_exception *fnhe,
 			rt_free(orig);
 
 		fnhe->fnhe_stamp = jiffies;
+		ret = true;
 	} else {
 		/* Routes we intend to cache in nexthop exception have
 		 * the DST_NOCACHE bit clear.  However, if we are
@@ -1212,11 +1217,14 @@ static void rt_bind_exception(struct rtable *rt, struct fib_nh_exception *fnhe,
 		rt->dst.flags |= DST_NOCACHE;
 	}
 	spin_unlock_bh(&fnhe_lock);
+
+	return ret;
 }
 
-static void rt_cache_route(struct fib_nh *nh, struct rtable *rt)
+static bool rt_cache_route(struct fib_nh *nh, struct rtable *rt)
 {
 	struct rtable *orig, *prev, **p;
+	bool ret = true;
 
 	if (rt_is_input_route(rt)) {
 		p = (struct rtable **)&nh->nh_rth_input;
@@ -1239,6 +1247,48 @@ static void rt_cache_route(struct fib_nh *nh, struct rtable *rt)
 		 */
 nocache:
 		rt->dst.flags |= DST_NOCACHE;
+		ret = false;
+	}
+
+	return ret;
+}
+
+static DEFINE_SPINLOCK(rt_uncached_lock);
+static LIST_HEAD(rt_uncached_list);
+
+static void rt_add_uncached_list(struct rtable *rt)
+{
+	spin_lock_bh(&rt_uncached_lock);
+	list_add_tail(&rt->rt_uncached, &rt_uncached_list);
+	spin_unlock_bh(&rt_uncached_lock);
+}
+
+static void ipv4_dst_destroy(struct dst_entry *dst)
+{
+	struct rtable *rt = (struct rtable *) dst;
+
+	if (dst->flags & DST_NOCACHE) {
+		spin_lock_bh(&rt_uncached_lock);
+		list_del(&rt->rt_uncached);
+		spin_unlock_bh(&rt_uncached_lock);
+	}
+}
+
+void rt_flush_dev(struct net_device *dev)
+{
+	if (!list_empty(&rt_uncached_list)) {
+		struct net *net = dev_net(dev);
+		struct rtable *rt;
+
+		spin_lock_bh(&rt_uncached_lock);
+		list_for_each_entry(rt, &rt_uncached_list, rt_uncached) {
+			if (rt->dst.dev != dev)
+				continue;
+			rt->dst.dev = net->loopback_dev;
+			dev_hold(rt->dst.dev);
+			dev_put(dev);
+		}
+		spin_unlock_bh(&rt_uncached_lock);
 	}
 }
 
@@ -1254,6 +1304,8 @@ static void rt_set_nexthop(struct rtable *rt, __be32 daddr,
 			   struct fib_nh_exception *fnhe,
 			   struct fib_info *fi, u16 type, u32 itag)
 {
+	bool cached = false;
+
 	if (fi) {
 		struct fib_nh *nh = &FIB_RES_NH(*res);
 
@@ -1264,10 +1316,12 @@ static void rt_set_nexthop(struct rtable *rt, __be32 daddr,
 		rt->dst.tclassid = nh->nh_tclassid;
 #endif
 		if (unlikely(fnhe))
-			rt_bind_exception(rt, fnhe, daddr);
+			cached = rt_bind_exception(rt, fnhe, daddr);
 		else if (!(rt->dst.flags & DST_NOCACHE))
-			rt_cache_route(nh, rt);
+			cached = rt_cache_route(nh, rt);
 	}
+	if (unlikely(!cached))
+		rt_add_uncached_list(rt);
 
 #ifdef CONFIG_IP_ROUTE_CLASSID
 #ifdef CONFIG_IP_MULTIPLE_TABLES
@@ -1334,6 +1388,7 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	rth->rt_iif	= 0;
 	rth->rt_pmtu	= 0;
 	rth->rt_gateway	= 0;
+	INIT_LIST_HEAD(&rth->rt_uncached);
 	if (our) {
 		rth->dst.input= ip_local_deliver;
 		rth->rt_flags |= RTCF_LOCAL;
@@ -1459,6 +1514,7 @@ static int __mkroute_input(struct sk_buff *skb,
 	rth->rt_iif 	= 0;
 	rth->rt_pmtu	= 0;
 	rth->rt_gateway	= 0;
+	INIT_LIST_HEAD(&rth->rt_uncached);
 
 	rth->dst.input = ip_forward;
 	rth->dst.output = ip_output;
@@ -1625,6 +1681,7 @@ local_input:
 	rth->rt_iif	= 0;
 	rth->rt_pmtu	= 0;
 	rth->rt_gateway	= 0;
+	INIT_LIST_HEAD(&rth->rt_uncached);
 	if (res.type == RTN_UNREACHABLE) {
 		rth->dst.input= ip_error;
 		rth->dst.error= -err;
@@ -1792,6 +1849,7 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 	rth->rt_iif	= orig_oif ? : 0;
 	rth->rt_pmtu	= 0;
 	rth->rt_gateway = 0;
+	INIT_LIST_HEAD(&rth->rt_uncached);
 
 	RT_CACHE_STAT_INC(out_slow_tot);
 
@@ -2071,6 +2129,8 @@ struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_or
 		rt->rt_type = ort->rt_type;
 		rt->rt_gateway = ort->rt_gateway;
 
+		INIT_LIST_HEAD(&rt->rt_uncached);
+
 		dst_free(new);
 	}
 
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index c628184..681ea2f 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -92,6 +92,7 @@ static int xfrm4_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
 	xdst->u.rt.rt_type = rt->rt_type;
 	xdst->u.rt.rt_gateway = rt->rt_gateway;
 	xdst->u.rt.rt_pmtu = rt->rt_pmtu;
+	INIT_LIST_HEAD(&xdst->u.rt.rt_uncached);
 
 	return 0;
 }
-- 
1.7.10.4
