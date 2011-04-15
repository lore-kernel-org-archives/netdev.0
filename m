From: David Miller <davem@davemloft.net>
Subject: [PATCH v5 4/7] net: Make dst_alloc() take more explicit
 initializations.
Date: Fri, 15 Apr 2011 15:39:47 -0700 (PDT)
Message-ID: <20110415.153947.115924027.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38634
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752966Ab1DOWkW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 18:40:22 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 6804924C088
	for <netdev@vger.kernel.org>; Fri, 15 Apr 2011 15:39:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Now the dst->dev, dev->obsolete, and dst->flags values can
be specified as well.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/dst.h      |    3 ++-
 net/core/dst.c         |   18 +++++++++++++-----
 net/decnet/dn_route.c  |   13 ++-----------
 net/ipv4/route.c       |   48 +++++++++++++++++++-----------------------------
 net/ipv6/route.c       |   29 +++++++++++------------------
 net/xfrm/xfrm_policy.c |    2 +-
 6 files changed, 48 insertions(+), 65 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 75b95df..9fc2ada 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -352,7 +352,8 @@ static inline struct dst_entry *skb_dst_pop(struct sk_buff *skb)
 }
 
 extern int dst_discard(struct sk_buff *skb);
-extern void *dst_alloc(struct dst_ops * ops, int initial_ref);
+extern void *dst_alloc(struct dst_ops * ops, struct net_device *dev,
+		       int initial_ref, int initial_obsolete, int flags);
 extern void __dst_free(struct dst_entry * dst);
 extern struct dst_entry *dst_destroy(struct dst_entry * dst);
 
diff --git a/net/core/dst.c b/net/core/dst.c
index 91104d3..9505778 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -166,7 +166,8 @@ EXPORT_SYMBOL(dst_discard);
 
 const u32 dst_default_metrics[RTAX_MAX];
 
-void *dst_alloc(struct dst_ops *ops, int initial_ref)
+void *dst_alloc(struct dst_ops *ops, struct net_device *dev,
+		int initial_ref, int initial_obsolete, int flags)
 {
 	struct dst_entry *dst;
 
@@ -177,12 +178,19 @@ void *dst_alloc(struct dst_ops *ops, int initial_ref)
 	dst = kmem_cache_zalloc(ops->kmem_cachep, GFP_ATOMIC);
 	if (!dst)
 		return NULL;
-	atomic_set(&dst->__refcnt, initial_ref);
 	dst->ops = ops;
-	dst->lastuse = jiffies;
-	dst->path = dst;
-	dst->input = dst->output = dst_discard;
+	dst->dev = dev;
+	if (dev)
+		dev_hold(dev);
 	dst_init_metrics(dst, dst_default_metrics, true);
+	dst->path = dst;
+	dst->input = dst_discard;
+	dst->output = dst_discard;
+
+	dst->obsolete = initial_obsolete;
+	atomic_set(&dst->__refcnt, initial_ref);
+	dst->lastuse = jiffies;
+	dst->flags = flags;
 #if RT_CACHE_DEBUG >= 2
 	atomic_inc(&dst_total);
 #endif
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 9f09d4f..f489b08 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -1125,13 +1125,10 @@ make_route:
 	if (dev_out->flags & IFF_LOOPBACK)
 		flags |= RTCF_LOCAL;
 
-	rt = dst_alloc(&dn_dst_ops, 0);
+	rt = dst_alloc(&dn_dst_ops, dev_out, 1, 0, DST_HOST);
 	if (rt == NULL)
 		goto e_nobufs;
 
-	atomic_set(&rt->dst.__refcnt, 1);
-	rt->dst.flags   = DST_HOST;
-
 	rt->fld.saddr        = oldflp->saddr;
 	rt->fld.daddr        = oldflp->daddr;
 	rt->fld.flowidn_oif  = oldflp->flowidn_oif;
@@ -1146,8 +1143,6 @@ make_route:
 	rt->rt_dst_map    = fld.daddr;
 	rt->rt_src_map    = fld.saddr;
 
-	rt->dst.dev = dev_out;
-	dev_hold(dev_out);
 	rt->dst.neighbour = neigh;
 	neigh = NULL;
 
@@ -1399,7 +1394,7 @@ static int dn_route_input_slow(struct sk_buff *skb)
 	}
 
 make_route:
-	rt = dst_alloc(&dn_dst_ops, 0);
+	rt = dst_alloc(&dn_dst_ops, out_dev, 0, 0, DST_HOST);
 	if (rt == NULL)
 		goto e_nobufs;
 
@@ -1419,9 +1414,7 @@ make_route:
 	rt->fld.flowidn_iif  = in_dev->ifindex;
 	rt->fld.flowidn_mark = fld.flowidn_mark;
 
-	rt->dst.flags = DST_HOST;
 	rt->dst.neighbour = neigh;
-	rt->dst.dev = out_dev;
 	rt->dst.lastuse = jiffies;
 	rt->dst.output = dn_rt_bug;
 	switch(res.type) {
@@ -1440,8 +1433,6 @@ make_route:
 			rt->dst.input = dst_discard;
 	}
 	rt->rt_flags = flags;
-	if (rt->dst.dev)
-		dev_hold(rt->dst.dev);
 
 	err = dn_rt_set_next_hop(rt, &res);
 	if (err)
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index f66898c..61a96ca 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1113,21 +1113,17 @@ static void rt_set_nexthop(struct rtable *rt, const struct flowi4 *oldflp4,
 	rt->rt_type = type;
 }
 
-static struct rtable *rt_dst_alloc(bool nopolicy, bool noxfrm)
+static struct rtable *rt_dst_alloc(struct net_device *dev,
+				   bool nopolicy, bool noxfrm)
 {
-	struct rtable *rt = dst_alloc(&ipv4_dst_ops, 1);
-	if (rt) {
-		rt->dst.obsolete = -1;
-
-		/* To avoid expensive rcu stuff for this uncached dst, we set
-		 * DST_NOCACHE so that dst_release() can free dst without
-		 * waiting a grace period.
-		 */
-		rt->dst.flags = DST_NOCACHE | DST_HOST |
-			(nopolicy ? DST_NOPOLICY : 0) |
-			(noxfrm ? DST_NOXFRM : 0);
-	}
-	return rt;
+	/* To avoid expensive rcu stuff for this uncached dst, we set
+	 * DST_NOCACHE so that dst_release() can free dst without
+	 * waiting a grace period.
+	 */
+	return dst_alloc(&ipv4_dst_ops, dev, 1, -1,
+			 DST_NOCACHE | DST_HOST |
+			 (nopolicy ? DST_NOPOLICY : 0) |
+			 (noxfrm ? DST_NOXFRM : 0));
 }
 
 /* called in rcu_read_lock() section */
@@ -1159,7 +1155,8 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 		if (err < 0)
 			goto e_err;
 	}
-	rth = rt_dst_alloc(IN_DEV_CONF_GET(in_dev, NOPOLICY), false);
+	rth = rt_dst_alloc(init_net.loopback_dev,
+			   IN_DEV_CONF_GET(in_dev, NOPOLICY), false);
 	if (!rth)
 		goto e_nobufs;
 
@@ -1176,8 +1173,6 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 #endif
 	rth->rt_route_iif = dev->ifindex;
 	rth->rt_iif	= dev->ifindex;
-	rth->dst.dev	= init_net.loopback_dev;
-	dev_hold(rth->dst.dev);
 	rth->rt_oif	= 0;
 	rth->rt_gateway	= daddr;
 	rth->rt_spec_dst= spec_dst;
@@ -1295,7 +1290,8 @@ static int __mkroute_input(struct sk_buff *skb,
 		}
 	}
 
-	rth = rt_dst_alloc(IN_DEV_CONF_GET(in_dev, NOPOLICY),
+	rth = rt_dst_alloc(out_dev->dev,
+			   IN_DEV_CONF_GET(in_dev, NOPOLICY),
 			   IN_DEV_CONF_GET(out_dev, NOXFRM));
 	if (!rth) {
 		err = -ENOBUFS;
@@ -1311,8 +1307,6 @@ static int __mkroute_input(struct sk_buff *skb,
 	rth->rt_gateway	= daddr;
 	rth->rt_route_iif = in_dev->dev->ifindex;
 	rth->rt_iif 	= in_dev->dev->ifindex;
-	rth->dst.dev	= (out_dev)->dev;
-	dev_hold(rth->dst.dev);
 	rth->rt_oif 	= 0;
 	rth->rt_spec_dst= spec_dst;
 
@@ -1465,7 +1459,8 @@ brd_input:
 	RT_CACHE_STAT_INC(in_brd);
 
 local_input:
-	rth = rt_dst_alloc(IN_DEV_CONF_GET(in_dev, NOPOLICY), false);
+	rth = rt_dst_alloc(net->loopback_dev,
+			   IN_DEV_CONF_GET(in_dev, NOPOLICY), false);
 	if (!rth)
 		goto e_nobufs;
 
@@ -1483,8 +1478,6 @@ local_input:
 #endif
 	rth->rt_route_iif = dev->ifindex;
 	rth->rt_iif	= dev->ifindex;
-	rth->dst.dev	= net->loopback_dev;
-	dev_hold(rth->dst.dev);
 	rth->rt_gateway	= daddr;
 	rth->rt_spec_dst= spec_dst;
 	rth->dst.input= ip_local_deliver;
@@ -1631,7 +1624,8 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 			fi = NULL;
 	}
 
-	rth = rt_dst_alloc(IN_DEV_CONF_GET(in_dev, NOPOLICY),
+	rth = rt_dst_alloc(dev_out,
+			   IN_DEV_CONF_GET(in_dev, NOPOLICY),
 			   IN_DEV_CONF_GET(in_dev, NOXFRM));
 	if (!rth)
 		return ERR_PTR(-ENOBUFS);
@@ -1645,10 +1639,6 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 	rth->rt_src	= fl4->saddr;
 	rth->rt_route_iif = 0;
 	rth->rt_iif	= oldflp4->flowi4_oif ? : dev_out->ifindex;
-	/* get references to the devices that are to be hold by the routing
-	   cache entry */
-	rth->dst.dev	= dev_out;
-	dev_hold(dev_out);
 	rth->rt_gateway = fl4->daddr;
 	rth->rt_spec_dst= fl4->saddr;
 
@@ -1901,7 +1891,7 @@ static struct dst_ops ipv4_dst_blackhole_ops = {
 
 struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_orig)
 {
-	struct rtable *rt = dst_alloc(&ipv4_dst_blackhole_ops, 1);
+	struct rtable *rt = dst_alloc(&ipv4_dst_blackhole_ops, NULL, 1, 0, 0);
 	struct rtable *ort = (struct rtable *) dst_orig;
 
 	if (rt) {
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 843406f..d3f55cc 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -220,9 +220,10 @@ static struct rt6_info ip6_blk_hole_entry_template = {
 #endif
 
 /* allocate dst with ip6_dst_ops */
-static inline struct rt6_info *ip6_dst_alloc(struct dst_ops *ops)
+static inline struct rt6_info *ip6_dst_alloc(struct dst_ops *ops,
+					     struct net_device *dev)
 {
-	return (struct rt6_info *)dst_alloc(ops, 0);
+	return (struct rt6_info *)dst_alloc(ops, dev, 0, 0, 0);
 }
 
 static void ip6_dst_destroy(struct dst_entry *dst)
@@ -874,10 +875,10 @@ EXPORT_SYMBOL(ip6_route_output);
 
 struct dst_entry *ip6_blackhole_route(struct net *net, struct dst_entry *dst_orig)
 {
-	struct rt6_info *rt = dst_alloc(&ip6_dst_blackhole_ops, 1);
-	struct rt6_info *ort = (struct rt6_info *) dst_orig;
+	struct rt6_info *rt, *ort = (struct rt6_info *) dst_orig;
 	struct dst_entry *new = NULL;
 
+	rt = dst_alloc(&ip6_dst_blackhole_ops, ort->dst.dev, 1, 0, 0);
 	if (rt) {
 		new = &rt->dst;
 
@@ -886,9 +887,6 @@ struct dst_entry *ip6_blackhole_route(struct net *net, struct dst_entry *dst_ori
 		new->output = dst_discard;
 
 		dst_copy_metrics(new, &ort->dst);
-		new->dev = ort->dst.dev;
-		if (new->dev)
-			dev_hold(new->dev);
 		rt->rt6i_idev = ort->rt6i_idev;
 		if (rt->rt6i_idev)
 			in6_dev_hold(rt->rt6i_idev);
@@ -1031,13 +1029,12 @@ struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 	if (unlikely(idev == NULL))
 		return NULL;
 
-	rt = ip6_dst_alloc(&net->ipv6.ip6_dst_ops);
+	rt = ip6_dst_alloc(&net->ipv6.ip6_dst_ops, dev);
 	if (unlikely(rt == NULL)) {
 		in6_dev_put(idev);
 		goto out;
 	}
 
-	dev_hold(dev);
 	if (neigh)
 		neigh_hold(neigh);
 	else {
@@ -1046,7 +1043,6 @@ struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 			neigh = NULL;
 	}
 
-	rt->rt6i_dev	  = dev;
 	rt->rt6i_idev     = idev;
 	rt->rt6i_nexthop  = neigh;
 	atomic_set(&rt->dst.__refcnt, 1);
@@ -1205,7 +1201,7 @@ int ip6_route_add(struct fib6_config *cfg)
 		goto out;
 	}
 
-	rt = ip6_dst_alloc(&net->ipv6.ip6_dst_ops);
+	rt = ip6_dst_alloc(&net->ipv6.ip6_dst_ops, NULL);
 
 	if (rt == NULL) {
 		err = -ENOMEM;
@@ -1714,7 +1710,8 @@ void rt6_pmtu_discovery(struct in6_addr *daddr, struct in6_addr *saddr,
 static struct rt6_info * ip6_rt_copy(struct rt6_info *ort)
 {
 	struct net *net = dev_net(ort->rt6i_dev);
-	struct rt6_info *rt = ip6_dst_alloc(&net->ipv6.ip6_dst_ops);
+	struct rt6_info *rt = ip6_dst_alloc(&net->ipv6.ip6_dst_ops,
+					    ort->dst.dev);
 
 	if (rt) {
 		rt->dst.input = ort->dst.input;
@@ -1722,9 +1719,6 @@ static struct rt6_info * ip6_rt_copy(struct rt6_info *ort)
 
 		dst_copy_metrics(&rt->dst, &ort->dst);
 		rt->dst.error = ort->dst.error;
-		rt->dst.dev = ort->dst.dev;
-		if (rt->dst.dev)
-			dev_hold(rt->dst.dev);
 		rt->rt6i_idev = ort->rt6i_idev;
 		if (rt->rt6i_idev)
 			in6_dev_hold(rt->rt6i_idev);
@@ -1994,7 +1988,8 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 				    int anycast)
 {
 	struct net *net = dev_net(idev->dev);
-	struct rt6_info *rt = ip6_dst_alloc(&net->ipv6.ip6_dst_ops);
+	struct rt6_info *rt = ip6_dst_alloc(&net->ipv6.ip6_dst_ops,
+					    net->loopback_dev);
 	struct neighbour *neigh;
 
 	if (rt == NULL) {
@@ -2004,13 +1999,11 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 		return ERR_PTR(-ENOMEM);
 	}
 
-	dev_hold(net->loopback_dev);
 	in6_dev_hold(idev);
 
 	rt->dst.flags = DST_HOST;
 	rt->dst.input = ip6_input;
 	rt->dst.output = ip6_output;
-	rt->rt6i_dev = net->loopback_dev;
 	rt->rt6i_idev = idev;
 	dst_metric_set(&rt->dst, RTAX_HOPLIMIT, -1);
 	rt->dst.obsolete = -1;
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 15792d8..70552c4 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1348,7 +1348,7 @@ static inline struct xfrm_dst *xfrm_alloc_dst(struct net *net, int family)
 	default:
 		BUG();
 	}
-	xdst = dst_alloc(dst_ops, 0);
+	xdst = dst_alloc(dst_ops, NULL, 0, 0, 0);
 	xfrm_policy_put_afinfo(afinfo);
 
 	if (likely(xdst))
-- 
1.7.4.3

