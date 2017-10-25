From: David Miller <davem@davemloft.net>
Subject: [RFC PATCH 09/12] xfrm: Move dst->path into struct xfrm_dst
Date: Wed, 25 Oct 2017 23:04:25 +0900 (KST)
Message-ID: <20171025.230425.1046232201960529227.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48358 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932301AbdJYOE2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 10:04:28 -0400
Received: from localhost (unknown [106.252.28.196])
        (using TLSv1 with cipher AES256-SHA (256/256 bits))
        (Client did not present a certificate)
        (Authenticated sender: davem-davemloft)
        by shards.monkeyblade.net (Postfix) with ESMTPSA id 411DD133F06AD
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 07:04:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The first member of an IPSEC route bundle chain sets it's dst->path to
the underlying ipv4/ipv6 route that carries the bundle.

Stated another way, if one were to follow the xfrm_dst->child chain of
the bundle, the final non-NULL pointer would be the path and point to
either an ipv4 or an ipv6 route.

This is largely used to make sure that PMTU events propagate down to
the correct ipv4 or ipv6 route.

When we don't have the top of an IPSEC bundle 'dst->path == dst'.

Move it down into xfrm_dst and key off of dst->xfrm.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/dst.h       |  3 +--
 include/net/xfrm.h      | 15 ++++++++++++++-
 net/bridge/br_nf_core.c |  1 -
 net/core/dst.c          |  1 -
 net/ipv4/route.c        |  2 +-
 net/ipv6/ip6_output.c   |  4 ++--
 net/ipv6/route.c        |  6 ------
 net/xfrm/xfrm_device.c  |  2 +-
 net/xfrm/xfrm_policy.c  | 28 ++++++++++++++--------------
 9 files changed, 33 insertions(+), 29 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 9ec3fd59c3e7..ca6495f237d5 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -37,7 +37,6 @@ struct dst_entry {
 	struct  dst_ops	        *ops;
 	unsigned long		_metrics;
 	unsigned long           expires;
-	struct dst_entry	*path;
 #ifdef CONFIG_XFRM
 	struct xfrm_state	*xfrm;
 #else
@@ -86,7 +85,7 @@ struct dst_entry {
 	 * Align __refcnt to a 64 bytes alignment
 	 * (L1_CACHE_SIZE would be too much)
 	 */
-	long			__pad_to_align_refcnt[4];
+	long			__pad_to_align_refcnt[5];
 #endif
 	/*
 	 * __refcnt wants to be on a different cache line from
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 6509ba4316c7..1fc54c96e266 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -984,6 +984,7 @@ struct xfrm_dst {
 	} u;
 	struct dst_entry *route;
 	struct dst_entry *child;
+	struct dst_entry *path;
 	struct xfrm_policy *pols[XFRM_POLICY_TYPE_MAX];
 	int num_pols, num_xfrms;
 	u32 xfrm_genid;
@@ -994,7 +995,18 @@ struct xfrm_dst {
 	u32 path_cookie;
 };
 
+static struct dst_entry *xfrm_dst_path(const struct dst_entry *dst)
+{
 #ifdef CONFIG_XFRM
+	if (dst->xfrm) {
+		const struct xfrm_dst *xdst = (const struct xfrm_dst *) dst;
+ 
+		return xdst->path;
+	}
+#endif
+	return (struct dst_entry *) dst;
+}
+
 static inline struct dst_entry *xfrm_dst_child(const struct dst_entry *dst)
 {
 #ifdef CONFIG_XFRM
@@ -1006,6 +1018,7 @@ static inline struct dst_entry *xfrm_dst_child(const struct dst_entry *dst)
 	return NULL;
 }
 
+#ifdef CONFIG_XFRM
 static inline void xfrm_dst_set_child(struct xfrm_dst *xdst, struct dst_entry *child)
 {
 	xdst->child = child;
@@ -1888,7 +1901,7 @@ static inline bool xfrm_dst_offload_ok(struct dst_entry *dst)
 		return false;
 
 	xdst = (struct xfrm_dst *) dst;
-	if (x->xso.offload_handle && (x->xso.dev == dst->path->dev) &&
+	if (x->xso.offload_handle && (x->xso.dev == xfrm_dst_path(dst)->dev) &&
 	    !xdst->child->xfrm)
 		return true;
 
diff --git a/net/bridge/br_nf_core.c b/net/bridge/br_nf_core.c
index 20cbb727df4d..8e2d7cfa4e16 100644
--- a/net/bridge/br_nf_core.c
+++ b/net/bridge/br_nf_core.c
@@ -78,7 +78,6 @@ void br_netfilter_rtable_init(struct net_bridge *br)
 
 	atomic_set(&rt->dst.__refcnt, 1);
 	rt->dst.dev = br->dev;
-	rt->dst.path = &rt->dst;
 	dst_init_metrics(&rt->dst, br_dst_default_metrics, true);
 	rt->dst.flags	= DST_NOXFRM | DST_FAKE_RTABLE;
 	rt->dst.ops = &fake_dst_ops;
diff --git a/net/core/dst.c b/net/core/dst.c
index cf2076c0eb22..9bc3bb6e94ef 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -69,7 +69,6 @@ void dst_init(struct dst_entry *dst, struct dst_ops *ops,
 	dst->ops = ops;
 	dst_init_metrics(dst, dst_default_metrics.metrics, true);
 	dst->expires = 0UL;
-	dst->path = dst;
 #ifdef CONFIG_XFRM
 	dst->xfrm = NULL;
 #endif
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index bc40bd411196..5ff6e3edcd3e 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1102,7 +1102,7 @@ void ipv4_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, u32 mtu)
 		new = true;
 	}
 
-	__ip_rt_update_pmtu((struct rtable *) rt->dst.path, &fl4, mtu);
+	__ip_rt_update_pmtu((struct rtable *) xfrm_dst_path(&rt->dst), &fl4, mtu);
 
 	if (!dst_check(&rt->dst, 0)) {
 		if (new)
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 5110a418cc4d..176d74fb3b4d 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1201,13 +1201,13 @@ static int ip6_setup_cork(struct sock *sk, struct inet_cork_full *cork,
 		      rt->dst.dev->mtu : dst_mtu(&rt->dst);
 	else
 		mtu = np->pmtudisc >= IPV6_PMTUDISC_PROBE ?
-		      rt->dst.dev->mtu : dst_mtu(rt->dst.path);
+		      rt->dst.dev->mtu : dst_mtu(xfrm_dst_path(&rt->dst));
 	if (np->frag_size < mtu) {
 		if (np->frag_size)
 			mtu = np->frag_size;
 	}
 	cork->base.fragsize = mtu;
-	if (dst_allfrag(rt->dst.path))
+	if (dst_allfrag(xfrm_dst_path(&rt->dst)))
 		cork->base.flags |= IPCORK_ALLFRAG;
 	cork->base.length = 0;
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 475c57e8fa90..1eb0bfed015f 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -4584,8 +4584,6 @@ static int __net_init ip6_route_net_init(struct net *net)
 					   GFP_KERNEL);
 	if (!net->ipv6.ip6_null_entry)
 		goto out_ip6_dst_entries;
-	net->ipv6.ip6_null_entry->dst.path =
-		(struct dst_entry *)net->ipv6.ip6_null_entry;
 	net->ipv6.ip6_null_entry->dst.ops = &net->ipv6.ip6_dst_ops;
 	dst_init_metrics(&net->ipv6.ip6_null_entry->dst,
 			 ip6_template_metrics, true);
@@ -4597,8 +4595,6 @@ static int __net_init ip6_route_net_init(struct net *net)
 					       GFP_KERNEL);
 	if (!net->ipv6.ip6_prohibit_entry)
 		goto out_ip6_null_entry;
-	net->ipv6.ip6_prohibit_entry->dst.path =
-		(struct dst_entry *)net->ipv6.ip6_prohibit_entry;
 	net->ipv6.ip6_prohibit_entry->dst.ops = &net->ipv6.ip6_dst_ops;
 	dst_init_metrics(&net->ipv6.ip6_prohibit_entry->dst,
 			 ip6_template_metrics, true);
@@ -4608,8 +4604,6 @@ static int __net_init ip6_route_net_init(struct net *net)
 					       GFP_KERNEL);
 	if (!net->ipv6.ip6_blk_hole_entry)
 		goto out_ip6_prohibit_entry;
-	net->ipv6.ip6_blk_hole_entry->dst.path =
-		(struct dst_entry *)net->ipv6.ip6_blk_hole_entry;
 	net->ipv6.ip6_blk_hole_entry->dst.ops = &net->ipv6.ip6_dst_ops;
 	dst_init_metrics(&net->ipv6.ip6_blk_hole_entry->dst,
 			 ip6_template_metrics, true);
diff --git a/net/xfrm/xfrm_device.c b/net/xfrm/xfrm_device.c
index c5851ddddd2a..c61a7d46b412 100644
--- a/net/xfrm/xfrm_device.c
+++ b/net/xfrm/xfrm_device.c
@@ -120,7 +120,7 @@ bool xfrm_dev_offload_ok(struct sk_buff *skb, struct xfrm_state *x)
 	if (!x->type_offload || x->encap)
 		return false;
 
-	if ((x->xso.offload_handle && (dev == dst->path->dev)) &&
+	if ((x->xso.offload_handle && (dev == xfrm_dst_path(dst)->dev)) &&
 	     !xdst->child->xfrm && x->type->get_mtu) {
 		mtu = x->type->get_mtu(x, xdst->child_mtu_cached);
 
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 206ac90ff4f0..7b80ee7486db 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1625,7 +1625,7 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
 	}
 
 	xfrm_dst_set_child(xdst_prev, dst);
-	xdst0->u.dst.path = dst;
+	xdst0->path = dst;
 
 	err = -ENODEV;
 	dev = dst->dev;
@@ -1872,8 +1872,8 @@ static void xfrm_policy_queue_process(struct timer_list *t)
 	xfrm_decode_session(skb, &fl, dst->ops->family);
 	spin_unlock(&pq->hold_queue.lock);
 
-	dst_hold(dst->path);
-	dst = xfrm_lookup(net, dst->path, &fl, sk, 0);
+	dst_hold(xfrm_dst_path(dst));
+	dst = xfrm_lookup(net, xfrm_dst_path(dst), &fl, sk, 0);
 	if (IS_ERR(dst))
 		goto purge_queue;
 
@@ -1902,8 +1902,8 @@ static void xfrm_policy_queue_process(struct timer_list *t)
 		skb = __skb_dequeue(&list);
 
 		xfrm_decode_session(skb, &fl, skb_dst(skb)->ops->family);
-		dst_hold(skb_dst(skb)->path);
-		dst = xfrm_lookup(net, skb_dst(skb)->path, &fl, skb->sk, 0);
+		dst_hold(xfrm_dst_path(skb_dst(skb)));
+		dst = xfrm_lookup(net, xfrm_dst_path(skb_dst(skb)), &fl, skb->sk, 0);
 		if (IS_ERR(dst)) {
 			kfree_skb(skb);
 			continue;
@@ -2005,7 +2005,7 @@ static struct xfrm_dst *xfrm_create_dummy_bundle(struct net *net,
 
 	dst_hold(dst);
 	xfrm_dst_set_child(xdst, dst);
-	dst1->path = dst;
+	xdst->path = dst;
 
 	xfrm_init_path((struct xfrm_dst *)dst1, dst, 0);
 
@@ -2624,7 +2624,7 @@ static int xfrm_bundle_ok(struct xfrm_dst *first)
 	struct xfrm_dst *last;
 	u32 mtu;
 
-	if (!dst_check(dst->path, ((struct xfrm_dst *)dst)->path_cookie) ||
+	if (!dst_check(xfrm_dst_path(dst), ((struct xfrm_dst *)dst)->path_cookie) ||
 	    (dst->dev && !netif_running(dst->dev)))
 		return 0;
 
@@ -2685,22 +2685,20 @@ static int xfrm_bundle_ok(struct xfrm_dst *first)
 
 static unsigned int xfrm_default_advmss(const struct dst_entry *dst)
 {
-	return dst_metric_advmss(dst->path);
+	return dst_metric_advmss(xfrm_dst_path(dst));
 }
 
 static unsigned int xfrm_mtu(const struct dst_entry *dst)
 {
 	unsigned int mtu = dst_metric_raw(dst, RTAX_MTU);
 
-	return mtu ? : dst_mtu(dst->path);
+	return mtu ? : dst_mtu(xfrm_dst_path(dst));
 }
 
 static const void *xfrm_get_dst_nexthop(const struct dst_entry *dst,
 					const void *daddr)
 {
-	const struct dst_entry *path = dst->path;
-
-	for (; dst != path; dst = xfrm_dst_child(dst)) {
+	while (dst->xfrm) {
 		const struct xfrm_state *xfrm = dst->xfrm;
 
 		if (xfrm->props.mode == XFRM_MODE_TRANSPORT)
@@ -2709,6 +2707,8 @@ static const void *xfrm_get_dst_nexthop(const struct dst_entry *dst,
 			daddr = xfrm->coaddr;
 		else if (!(xfrm->type->flags & XFRM_TYPE_LOCAL_COADDR))
 			daddr = &xfrm->id.daddr;
+
+		dst = xfrm_dst_child(dst);
 	}
 	return daddr;
 }
@@ -2717,7 +2717,7 @@ static struct neighbour *xfrm_neigh_lookup(const struct dst_entry *dst,
 					   struct sk_buff *skb,
 					   const void *daddr)
 {
-	const struct dst_entry *path = dst->path;
+	const struct dst_entry *path = xfrm_dst_path(dst);
 
 	if (!skb)
 		daddr = xfrm_get_dst_nexthop(dst, daddr);
@@ -2726,7 +2726,7 @@ static struct neighbour *xfrm_neigh_lookup(const struct dst_entry *dst,
 
 static void xfrm_confirm_neigh(const struct dst_entry *dst, const void *daddr)
 {
-	const struct dst_entry *path = dst->path;
+	const struct dst_entry *path = xfrm_dst_path(dst);
 
 	daddr = xfrm_get_dst_nexthop(dst, daddr);
 	path->ops->confirm_neigh(path, daddr);
-- 
2.13.6
