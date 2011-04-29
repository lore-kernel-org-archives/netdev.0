From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/3] net: Use non-zero allocations in dst_alloc().
Date: Thu, 28 Apr 2011 22:25:12 -0700 (PDT)
Message-ID: <20110428.222512.104062615.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37478
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752550Ab1D2FZp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2011 01:25:45 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 9F24024C087
	for <netdev@vger.kernel.org>; Thu, 28 Apr 2011 22:25:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Make dst_alloc() and it's users explicitly initialize the entire
entry.

The zero'ing done by kmem_cache_zalloc() was almost entirely
redundant.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/dst.c         |   20 ++++++++++--
 net/decnet/dn_route.c  |    2 +
 net/ipv4/route.c       |   78 +++++++++++++++++++++++++++++-------------------
 net/ipv6/route.c       |    8 ++++-
 net/xfrm/xfrm_policy.c |    1 +
 5 files changed, 74 insertions(+), 35 deletions(-)

diff --git a/net/core/dst.c b/net/core/dst.c
index 9505778..30f0093 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -175,22 +175,36 @@ void *dst_alloc(struct dst_ops *ops, struct net_device *dev,
 		if (ops->gc(ops))
 			return NULL;
 	}
-	dst = kmem_cache_zalloc(ops->kmem_cachep, GFP_ATOMIC);
+	dst = kmem_cache_alloc(ops->kmem_cachep, GFP_ATOMIC);
 	if (!dst)
 		return NULL;
-	dst->ops = ops;
+	dst->child = NULL;
 	dst->dev = dev;
 	if (dev)
 		dev_hold(dev);
+	dst->ops = ops;
 	dst_init_metrics(dst, dst_default_metrics, true);
+	dst->expires = 0UL;
 	dst->path = dst;
+	dst->neighbour = NULL;
+	dst->hh = NULL;
+#ifdef CONFIG_XFRM
+	dst->xfrm = NULL;
+#endif
 	dst->input = dst_discard;
 	dst->output = dst_discard;
-
+	dst->error = 0;
 	dst->obsolete = initial_obsolete;
+	dst->header_len = 0;
+	dst->trailer_len = 0;
+#ifdef CONFIG_IP_ROUTE_CLASSID
+	dst->tclassid = 0;
+#endif
 	atomic_set(&dst->__refcnt, initial_ref);
+	dst->__use = 0;
 	dst->lastuse = jiffies;
 	dst->flags = flags;
+	dst->next = NULL;
 #if RT_CACHE_DEBUG >= 2
 	atomic_inc(&dst_total);
 #endif
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index f489b08..74544bc 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -1129,6 +1129,7 @@ make_route:
 	if (rt == NULL)
 		goto e_nobufs;
 
+	memset(&rt->fld, 0, sizeof(rt->fld));
 	rt->fld.saddr        = oldflp->saddr;
 	rt->fld.daddr        = oldflp->daddr;
 	rt->fld.flowidn_oif  = oldflp->flowidn_oif;
@@ -1398,6 +1399,7 @@ make_route:
 	if (rt == NULL)
 		goto e_nobufs;
 
+	memset(&rt->fld, 0, sizeof(rt->fld));
 	rt->rt_saddr      = fld.saddr;
 	rt->rt_daddr      = fld.daddr;
 	rt->rt_gateway    = fld.daddr;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index b471d89..fb9211a 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1830,7 +1830,6 @@ static void rt_set_nexthop(struct rtable *rt, const struct flowi4 *oldflp4,
 #endif
 	set_class_tag(rt, itag);
 #endif
-	rt->rt_type = type;
 }
 
 static struct rtable *rt_dst_alloc(struct net_device *dev,
@@ -1877,25 +1876,28 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	if (!rth)
 		goto e_nobufs;
 
+#ifdef CONFIG_IP_ROUTE_CLASSID
+	rth->dst.tclassid = itag;
+#endif
 	rth->dst.output = ip_rt_bug;
 
 	rth->rt_key_dst	= daddr;
-	rth->rt_dst	= daddr;
-	rth->rt_tos	= tos;
-	rth->rt_mark    = skb->mark;
 	rth->rt_key_src	= saddr;
+	rth->rt_genid	= rt_genid(dev_net(dev));
+	rth->rt_flags	= RTCF_MULTICAST;
+	rth->rt_type	= RTN_MULTICAST;
+	rth->rt_tos	= tos;
+	rth->rt_dst	= daddr;
 	rth->rt_src	= saddr;
-#ifdef CONFIG_IP_ROUTE_CLASSID
-	rth->dst.tclassid = itag;
-#endif
 	rth->rt_route_iif = dev->ifindex;
 	rth->rt_iif	= dev->ifindex;
 	rth->rt_oif	= 0;
+	rth->rt_mark    = skb->mark;
 	rth->rt_gateway	= daddr;
 	rth->rt_spec_dst= spec_dst;
-	rth->rt_genid	= rt_genid(dev_net(dev));
-	rth->rt_flags	= RTCF_MULTICAST;
-	rth->rt_type	= RTN_MULTICAST;
+	rth->rt_peer_genid = 0;
+	rth->peer = NULL;
+	rth->fi = NULL;
 	if (our) {
 		rth->dst.input= ip_local_deliver;
 		rth->rt_flags |= RTCF_LOCAL;
@@ -2017,25 +2019,28 @@ static int __mkroute_input(struct sk_buff *skb,
 	}
 
 	rth->rt_key_dst	= daddr;
-	rth->rt_dst	= daddr;
-	rth->rt_tos	= tos;
-	rth->rt_mark    = skb->mark;
 	rth->rt_key_src	= saddr;
+	rth->rt_genid = rt_genid(dev_net(rth->dst.dev));
+	rth->rt_flags = flags;
+	rth->rt_type = res->type;
+	rth->rt_tos	= tos;
+	rth->rt_dst	= daddr;
 	rth->rt_src	= saddr;
-	rth->rt_gateway	= daddr;
 	rth->rt_route_iif = in_dev->dev->ifindex;
 	rth->rt_iif 	= in_dev->dev->ifindex;
 	rth->rt_oif 	= 0;
+	rth->rt_mark    = skb->mark;
+	rth->rt_gateway	= daddr;
 	rth->rt_spec_dst= spec_dst;
+	rth->rt_peer_genid = 0;
+	rth->peer = NULL;
+	rth->fi = NULL;
 
 	rth->dst.input = ip_forward;
 	rth->dst.output = ip_output;
-	rth->rt_genid = rt_genid(dev_net(rth->dst.dev));
 
 	rt_set_nexthop(rth, NULL, res, res->fi, res->type, itag);
 
-	rth->rt_flags = flags;
-
 	*result = rth;
 	err = 0;
  cleanup:
@@ -2187,30 +2192,37 @@ local_input:
 	if (!rth)
 		goto e_nobufs;
 
+	rth->dst.input= ip_local_deliver;
 	rth->dst.output= ip_rt_bug;
-	rth->rt_genid = rt_genid(net);
+#ifdef CONFIG_IP_ROUTE_CLASSID
+	rth->dst.tclassid = itag;
+#endif
 
 	rth->rt_key_dst	= daddr;
-	rth->rt_dst	= daddr;
-	rth->rt_tos	= tos;
-	rth->rt_mark    = skb->mark;
 	rth->rt_key_src	= saddr;
+	rth->rt_genid = rt_genid(net);
+	rth->rt_flags 	= flags|RTCF_LOCAL;
+	rth->rt_type	= res.type;
+	rth->rt_tos	= tos;
+	rth->rt_dst	= daddr;
 	rth->rt_src	= saddr;
 #ifdef CONFIG_IP_ROUTE_CLASSID
 	rth->dst.tclassid = itag;
 #endif
 	rth->rt_route_iif = dev->ifindex;
 	rth->rt_iif	= dev->ifindex;
+	rth->rt_oif	= 0;
+	rth->rt_mark    = skb->mark;
 	rth->rt_gateway	= daddr;
 	rth->rt_spec_dst= spec_dst;
-	rth->dst.input= ip_local_deliver;
-	rth->rt_flags 	= flags|RTCF_LOCAL;
+	rth->rt_peer_genid = 0;
+	rth->peer = NULL;
+	rth->fi = NULL;
 	if (res.type == RTN_UNREACHABLE) {
 		rth->dst.input= ip_error;
 		rth->dst.error= -err;
 		rth->rt_flags 	&= ~RTCF_LOCAL;
 	}
-	rth->rt_type	= res.type;
 	hash = rt_hash(daddr, saddr, fl4.flowi4_iif, rt_genid(net));
 	rth = rt_intern_hash(hash, rth, skb, fl4.flowi4_iif);
 	err = 0;
@@ -2391,20 +2403,25 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 	if (!rth)
 		return ERR_PTR(-ENOBUFS);
 
+	rth->dst.output = ip_output;
+
 	rth->rt_key_dst	= oldflp4->daddr;
-	rth->rt_tos	= tos;
 	rth->rt_key_src	= oldflp4->saddr;
-	rth->rt_oif	= oldflp4->flowi4_oif;
-	rth->rt_mark    = oldflp4->flowi4_mark;
+	rth->rt_genid = rt_genid(dev_net(dev_out));
+	rth->rt_flags	= flags;
+	rth->rt_type	= type;
+	rth->rt_tos	= tos;
 	rth->rt_dst	= fl4->daddr;
 	rth->rt_src	= fl4->saddr;
 	rth->rt_route_iif = 0;
 	rth->rt_iif	= oldflp4->flowi4_oif ? : dev_out->ifindex;
+	rth->rt_oif	= oldflp4->flowi4_oif;
+	rth->rt_mark    = oldflp4->flowi4_mark;
 	rth->rt_gateway = fl4->daddr;
 	rth->rt_spec_dst= fl4->saddr;
-
-	rth->dst.output=ip_output;
-	rth->rt_genid = rt_genid(dev_net(dev_out));
+	rth->rt_peer_genid = 0;
+	rth->peer = NULL;
+	rth->fi = NULL;
 
 	RT_CACHE_STAT_INC(out_slow_tot);
 
@@ -2432,7 +2449,6 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 
 	rt_set_nexthop(rth, oldflp4, res, fi, type, 0);
 
-	rth->rt_flags = flags;
 	return rth;
 }
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index e8b2bb9..f1be5c5 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -230,7 +230,11 @@ static struct rt6_info ip6_blk_hole_entry_template = {
 static inline struct rt6_info *ip6_dst_alloc(struct dst_ops *ops,
 					     struct net_device *dev)
 {
-	return (struct rt6_info *)dst_alloc(ops, dev, 0, 0, 0);
+	struct rt6_info *rt = dst_alloc(ops, dev, 0, 0, 0);
+
+	memset(&rt->rt6i_table, 0, sizeof(*rt) - sizeof(struct dst_entry));
+
+	return rt;
 }
 
 static void ip6_dst_destroy(struct dst_entry *dst)
@@ -887,6 +891,8 @@ struct dst_entry *ip6_blackhole_route(struct net *net, struct dst_entry *dst_ori
 
 	rt = dst_alloc(&ip6_dst_blackhole_ops, ort->dst.dev, 1, 0, 0);
 	if (rt) {
+		memset(&rt->rt6i_table, 0, sizeof(*rt) - sizeof(struct dst_entry));
+
 		new = &rt->dst;
 
 		new->__use = 1;
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 70552c4..00bcb88 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1349,6 +1349,7 @@ static inline struct xfrm_dst *xfrm_alloc_dst(struct net *net, int family)
 		BUG();
 	}
 	xdst = dst_alloc(dst_ops, NULL, 0, 0, 0);
+	memset(&xdst->u.rt6.rt6i_table, 0, sizeof(*xdst) - sizeof(struct dst_entry));
 	xfrm_policy_put_afinfo(afinfo);
 
 	if (likely(xdst))
-- 
1.7.4.5

