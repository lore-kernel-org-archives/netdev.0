From: David Miller <davem@davemloft.net>
Subject: [PATCH] net: Abstract default MTU metric calculation behind an
 accessor.
Date: Tue, 14 Dec 2010 13:20:04 -0800 (PST)
Message-ID: <20101214.132004.59683222.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48887
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760140Ab0LNVTg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Dec 2010 16:19:36 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id E730424C088
	for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 13:20:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Like RTAX_ADVMSS, make the default calculation go through a dst_ops
method rather than caching the computation in the routing cache
entries.

Now dst metrics are pretty much left as-is when new entries are
created, thus optimizing metric sharing becomes a real possibility.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/dst.h      |   15 ++++++++-------
 include/net/dst_ops.h  |    1 +
 net/decnet/dn_route.c  |   10 ++++++++--
 net/ipv4/route.c       |   29 ++++++++++++++++++++---------
 net/ipv6/route.c       |   37 ++++++++++++++++---------------------
 net/xfrm/xfrm_policy.c |    7 +++++++
 6 files changed, 60 insertions(+), 39 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 03a1c3d..93b0310 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -113,7 +113,8 @@ static inline u32
 dst_metric(const struct dst_entry *dst, const int metric)
 {
 	WARN_ON_ONCE(metric == RTAX_HOPLIMIT ||
-		     metric == RTAX_ADVMSS);
+		     metric == RTAX_ADVMSS ||
+		     metric == RTAX_MTU);
 	return dst_metric_raw(dst, metric);
 }
 
@@ -156,11 +157,11 @@ dst_feature(const struct dst_entry *dst, u32 feature)
 
 static inline u32 dst_mtu(const struct dst_entry *dst)
 {
-	u32 mtu = dst_metric(dst, RTAX_MTU);
-	/*
-	 * Alexey put it here, so ask him about it :)
-	 */
-	barrier();
+	u32 mtu = dst_metric_raw(dst, RTAX_MTU);
+
+	if (!mtu)
+		mtu = dst->ops->default_mtu(dst);
+
 	return mtu;
 }
 
@@ -186,7 +187,7 @@ dst_allfrag(const struct dst_entry *dst)
 }
 
 static inline int
-dst_metric_locked(struct dst_entry *dst, int metric)
+dst_metric_locked(const struct dst_entry *dst, int metric)
 {
 	return dst_metric(dst, RTAX_LOCK) & (1<<metric);
 }
diff --git a/include/net/dst_ops.h b/include/net/dst_ops.h
index 15fb7af..21a320b 100644
--- a/include/net/dst_ops.h
+++ b/include/net/dst_ops.h
@@ -17,6 +17,7 @@ struct dst_ops {
 	int			(*gc)(struct dst_ops *ops);
 	struct dst_entry *	(*check)(struct dst_entry *, __u32 cookie);
 	unsigned int		(*default_advmss)(const struct dst_entry *);
+	unsigned int		(*default_mtu)(const struct dst_entry *);
 	void			(*destroy)(struct dst_entry *);
 	void			(*ifdown)(struct dst_entry *,
 					  struct net_device *dev, int how);
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index b8a5c05..5e63636 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -111,6 +111,7 @@ static unsigned long dn_rt_deadline;
 static int dn_dst_gc(struct dst_ops *ops);
 static struct dst_entry *dn_dst_check(struct dst_entry *, __u32);
 static unsigned int dn_dst_default_advmss(const struct dst_entry *dst);
+static unsigned int dn_dst_default_mtu(const struct dst_entry *dst);
 static struct dst_entry *dn_dst_negative_advice(struct dst_entry *);
 static void dn_dst_link_failure(struct sk_buff *);
 static void dn_dst_update_pmtu(struct dst_entry *dst, u32 mtu);
@@ -131,6 +132,7 @@ static struct dst_ops dn_dst_ops = {
 	.gc =			dn_dst_gc,
 	.check =		dn_dst_check,
 	.default_advmss =	dn_dst_default_advmss,
+	.default_mtu =		dn_dst_default_mtu,
 	.negative_advice =	dn_dst_negative_advice,
 	.link_failure =		dn_dst_link_failure,
 	.update_pmtu =		dn_dst_update_pmtu,
@@ -803,6 +805,11 @@ static unsigned int dn_dst_default_advmss(const struct dst_entry *dst)
 	return dn_mss_from_pmtu(dst->dev, dst_mtu(dst));
 }
 
+static unsigned int dn_dst_default_mtu(const struct dst_entry *dst)
+{
+	return dst->dev->mtu;
+}
+
 static int dn_rt_set_next_hop(struct dn_route *rt, struct dn_fib_res *res)
 {
 	struct dn_fib_info *fi = res->fi;
@@ -825,8 +832,7 @@ static int dn_rt_set_next_hop(struct dn_route *rt, struct dn_fib_res *res)
 		rt->dst.neighbour = n;
 	}
 
-	if (dst_metric(&rt->dst, RTAX_MTU) == 0 ||
-	    dst_metric(&rt->dst, RTAX_MTU) > rt->dst.dev->mtu)
+	if (dst_metric(&rt->dst, RTAX_MTU) > rt->dst.dev->mtu)
 		dst_metric_set(&rt->dst, RTAX_MTU, rt->dst.dev->mtu);
 	metric = dst_metric_raw(&rt->dst, RTAX_ADVMSS);
 	if (metric) {
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 8099733..ae52096 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -140,6 +140,7 @@ static unsigned long expires_ljiffies;
 
 static struct dst_entry *ipv4_dst_check(struct dst_entry *dst, u32 cookie);
 static unsigned int	 ipv4_default_advmss(const struct dst_entry *dst);
+static unsigned int	 ipv4_default_mtu(const struct dst_entry *dst);
 static void		 ipv4_dst_destroy(struct dst_entry *dst);
 static struct dst_entry *ipv4_negative_advice(struct dst_entry *dst);
 static void		 ipv4_link_failure(struct sk_buff *skb);
@@ -157,6 +158,7 @@ static struct dst_ops ipv4_dst_ops = {
 	.gc =			rt_garbage_collect,
 	.check =		ipv4_dst_check,
 	.default_advmss =	ipv4_default_advmss,
+	.default_mtu =		ipv4_default_mtu,
 	.destroy =		ipv4_dst_destroy,
 	.ifdown =		ipv4_dst_ifdown,
 	.negative_advice =	ipv4_negative_advice,
@@ -1812,6 +1814,23 @@ static unsigned int ipv4_default_advmss(const struct dst_entry *dst)
 	return advmss;
 }
 
+static unsigned int ipv4_default_mtu(const struct dst_entry *dst)
+{
+	unsigned int mtu = dst->dev->mtu;
+
+	if (unlikely(dst_metric_locked(dst, RTAX_MTU))) {
+		const struct rtable *rt = (const struct rtable *) dst;
+
+		if (rt->rt_gateway != rt->rt_dst && mtu > 576)
+			mtu = 576;
+	}
+
+	if (mtu > IP_MAX_MTU)
+		mtu = IP_MAX_MTU;
+
+	return mtu;
+}
+
 static void rt_set_nexthop(struct rtable *rt, struct fib_result *res, u32 itag)
 {
 	struct dst_entry *dst = &rt->dst;
@@ -1822,18 +1841,10 @@ static void rt_set_nexthop(struct rtable *rt, struct fib_result *res, u32 itag)
 		    FIB_RES_NH(*res).nh_scope == RT_SCOPE_LINK)
 			rt->rt_gateway = FIB_RES_GW(*res);
 		dst_import_metrics(dst, fi->fib_metrics);
-		if (fi->fib_mtu == 0) {
-			dst_metric_set(dst, RTAX_MTU, dst->dev->mtu);
-			if (dst_metric_locked(dst, RTAX_MTU) &&
-			    rt->rt_gateway != rt->rt_dst &&
-			    dst->dev->mtu > 576)
-				dst_metric_set(dst, RTAX_MTU, 576);
-		}
 #ifdef CONFIG_NET_CLS_ROUTE
 		dst->tclassid = FIB_RES_NH(*res).nh_tclassid;
 #endif
-	} else
-		dst_metric_set(dst, RTAX_MTU, dst->dev->mtu);
+	}
 
 	if (dst_mtu(dst) > IP_MAX_MTU)
 		dst_metric_set(dst, RTAX_MTU, IP_MAX_MTU);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index d9cb832..e7efb26 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -77,6 +77,7 @@
 static struct rt6_info * ip6_rt_copy(struct rt6_info *ort);
 static struct dst_entry	*ip6_dst_check(struct dst_entry *dst, u32 cookie);
 static unsigned int	 ip6_default_advmss(const struct dst_entry *dst);
+static unsigned int	 ip6_default_mtu(const struct dst_entry *dst);
 static struct dst_entry *ip6_negative_advice(struct dst_entry *);
 static void		ip6_dst_destroy(struct dst_entry *);
 static void		ip6_dst_ifdown(struct dst_entry *,
@@ -105,6 +106,7 @@ static struct dst_ops ip6_dst_ops_template = {
 	.gc_thresh		=	1024,
 	.check			=	ip6_dst_check,
 	.default_advmss		=	ip6_default_advmss,
+	.default_mtu		=	ip6_default_mtu,
 	.destroy		=	ip6_dst_destroy,
 	.ifdown			=	ip6_dst_ifdown,
 	.negative_advice	=	ip6_negative_advice,
@@ -937,8 +939,6 @@ static void ip6_rt_update_pmtu(struct dst_entry *dst, u32 mtu)
 	}
 }
 
-static int ipv6_get_mtu(struct net_device *dev);
-
 static unsigned int ip6_default_advmss(const struct dst_entry *dst)
 {
 	struct net_device *dev = dst->dev;
@@ -961,6 +961,20 @@ static unsigned int ip6_default_advmss(const struct dst_entry *dst)
 	return mtu;
 }
 
+static unsigned int ip6_default_mtu(const struct dst_entry *dst)
+{
+	unsigned int mtu = IPV6_MIN_MTU;
+	struct inet6_dev *idev;
+
+	rcu_read_lock();
+	idev = __in6_dev_get(dst->dev);
+	if (idev)
+		mtu = idev->cnf.mtu6;
+	rcu_read_unlock();
+
+	return mtu;
+}
+
 static struct dst_entry *icmp6_dst_gc_list;
 static DEFINE_SPINLOCK(icmp6_dst_lock);
 
@@ -995,7 +1009,6 @@ struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 	rt->rt6i_nexthop  = neigh;
 	atomic_set(&rt->dst.__refcnt, 1);
 	dst_metric_set(&rt->dst, RTAX_HOPLIMIT, 255);
-	dst_metric_set(&rt->dst, RTAX_MTU, ipv6_get_mtu(rt->rt6i_dev));
 	rt->dst.output  = ip6_output;
 
 #if 0	/* there's no chance to use these for ndisc */
@@ -1094,19 +1107,6 @@ out:
    Remove it only when all the things will work!
  */
 
-static int ipv6_get_mtu(struct net_device *dev)
-{
-	int mtu = IPV6_MIN_MTU;
-	struct inet6_dev *idev;
-
-	rcu_read_lock();
-	idev = __in6_dev_get(dev);
-	if (idev)
-		mtu = idev->cnf.mtu6;
-	rcu_read_unlock();
-	return mtu;
-}
-
 int ip6_dst_hoplimit(struct dst_entry *dst)
 {
 	int hoplimit = dst_metric_raw(dst, RTAX_HOPLIMIT);
@@ -1315,8 +1315,6 @@ install_route:
 		}
 	}
 
-	if (!dst_mtu(&rt->dst))
-		dst_metric_set(&rt->dst, RTAX_MTU, ipv6_get_mtu(dev));
 	rt->dst.dev = dev;
 	rt->rt6i_idev = idev;
 	rt->rt6i_table = table;
@@ -1541,8 +1539,6 @@ void rt6_redirect(struct in6_addr *dest, struct in6_addr *src,
 
 	ipv6_addr_copy(&nrt->rt6i_gateway, (struct in6_addr*)neigh->primary_key);
 	nrt->rt6i_nexthop = neigh_clone(neigh);
-	/* Reset pmtu, it may be better */
-	dst_metric_set(&nrt->dst, RTAX_MTU, ipv6_get_mtu(neigh->dev));
 
 	if (ip6_ins_rt(nrt))
 		goto out;
@@ -1971,7 +1967,6 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 	rt->dst.output = ip6_output;
 	rt->rt6i_dev = net->loopback_dev;
 	rt->rt6i_idev = idev;
-	dst_metric_set(&rt->dst, RTAX_MTU, ipv6_get_mtu(rt->rt6i_dev));
 	dst_metric_set(&rt->dst, RTAX_HOPLIMIT, -1);
 	rt->dst.obsolete = -1;
 
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 36936c8..8b3ef40 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2366,6 +2366,11 @@ static unsigned int xfrm_default_advmss(const struct dst_entry *dst)
 	return dst_metric_advmss(dst->path);
 }
 
+static unsigned int xfrm_default_mtu(const struct dst_entry *dst)
+{
+	return dst_mtu(dst->path);
+}
+
 int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo)
 {
 	struct net *net;
@@ -2385,6 +2390,8 @@ int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo)
 			dst_ops->check = xfrm_dst_check;
 		if (likely(dst_ops->default_advmss == NULL))
 			dst_ops->default_advmss = xfrm_default_advmss;
+		if (likely(dst_ops->default_mtu == NULL))
+			dst_ops->default_mtu = xfrm_default_mtu;
 		if (likely(dst_ops->negative_advice == NULL))
 			dst_ops->negative_advice = xfrm_negative_advice;
 		if (likely(dst_ops->link_failure == NULL))
-- 
1.7.3.2

