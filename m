From: David Miller <davem@davemloft.net>
Subject: [RFC PATCH 07/12] xfrm: Move child route linkage into xfrm_dst.
Date: Wed, 25 Oct 2017 23:03:59 +0900 (KST)
Message-ID: <20171025.230359.995821396512483745.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48346 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932095AbdJYOED (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 10:04:03 -0400
Received: from localhost (unknown [106.252.28.196])
        (using TLSv1 with cipher AES256-SHA (256/256 bits))
        (Client did not present a certificate)
        (Authenticated sender: davem-davemloft)
        by shards.monkeyblade.net (Postfix) with ESMTPSA id 21ACE133F06AD
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 07:04:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


XFRM bundle child chains look like this:

	xdst1 --> xdst2 --> xdst3 --> path_dst

All of xdstN are xfrm_dst objects and xdst->u.dst.xfrm is non-NULL.
The final child pointer in the chain, here called 'path_dst', is some
other kind of route such as an ipv4 or ipv6 one.

The xfrm output path pops routes, one at a time, via the child
pointer, until we hit one which has a dst->xfrm pointer which
is NULL.

We can easily preserve the above mechanisms with child sitting
only in the xfrm_dst structure.  All children in the chain
before we break out of the xfrm_output() loop have dst->xfrm
non-NULL and are therefore xfrm_dst objects.

Since we break out of the loop when we find dst->xfrm NULL, we
will not try to dereference 'dst' as if it were an xfrm_dst.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/dst.h  | 12 +-----------
 include/net/xfrm.h | 14 ++++++++++++--
 net/core/dst.c     |  2 +-
 net/core/pktgen.c  | 12 ++++++------
 4 files changed, 20 insertions(+), 20 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 360d214..1e96e5e 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -34,7 +34,6 @@ struct sk_buff;
 struct dst_entry {
 	struct net_device       *dev;
 	struct rcu_head		rcu_head;
-	struct dst_entry	*child;
 	struct  dst_ops	        *ops;
 	unsigned long		_metrics;
 	unsigned long           expires;
@@ -88,7 +87,7 @@ struct dst_entry {
 	 * Align __refcnt to a 64 bytes alignment
 	 * (L1_CACHE_SIZE would be too much)
 	 */
-	long			__pad_to_align_refcnt[2];
+	long			__pad_to_align_refcnt[3];
 #endif
 	/*
 	 * __refcnt wants to be on a different cache line from
@@ -242,15 +241,6 @@ dst_metric_locked(const struct dst_entry *dst, int metric)
 	return dst_metric(dst, RTAX_LOCK) & (1<<metric);
 }

-static inline struct dst_entry *dst_child(const struct dst_entry *dst)
-{
-#ifdef CONFIG_XFRM
-	if (dst->xfrm)
-		return dst->child;
-#endif
-	return NULL;
-}
-
 static inline void dst_hold(struct dst_entry *dst)
 {
 	/*
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 572a9cc..f805eb6 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -983,6 +983,7 @@ struct xfrm_dst {
 		struct rt6_info		rt6;
 	} u;
 	struct dst_entry *route;
+	struct dst_entry *child;
 	struct xfrm_policy *pols[XFRM_POLICY_TYPE_MAX];
 	int num_pols, num_xfrms;
 	u32 xfrm_genid;
@@ -993,6 +994,15 @@ struct xfrm_dst {
 	u32 path_cookie;
 };

+static inline struct dst_entry *dst_child(const struct dst_entry *dst)
+{
+#ifdef CONFIG_XFRM
+	if (dst->xfrm)
+		return ((struct xfrm_dst *)dst)->child;
+#endif
+	return NULL;
+}
+
 #ifdef CONFIG_XFRM
 static inline void xfrm_dst_destroy(struct xfrm_dst *xdst)
 {
@@ -1004,14 +1014,14 @@ static inline void xfrm_dst_destroy(struct xfrm_dst *xdst)

 static inline struct xfrm_dst *xfrm_dst_child(const struct xfrm_dst *xdst)
 {
-	struct dst_entry *child = dst_child(&xdst->u.dst);
+	struct dst_entry *child = xdst->child;

 	return (struct xfrm_dst *) child;
 }

 static inline void xfrm_dst_set_child(struct xfrm_dst *xdst, struct dst_entry *child)
 {
-	xdst->u.dst.child = child;
+	xdst->child = child;
 }
 #endif

diff --git a/net/core/dst.c b/net/core/dst.c
index 3f83669..fb12e34 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -21,6 +21,7 @@
 #include <linux/sched.h>
 #include <linux/prefetch.h>
 #include <net/lwtunnel.h>
+#include <net/xfrm.h>

 #include <net/dst.h>
 #include <net/dst_metadata.h>
@@ -62,7 +63,6 @@ void dst_init(struct dst_entry *dst, struct dst_ops *ops,
 	      struct net_device *dev, int initial_ref, int initial_obsolete,
 	      unsigned short flags)
 {
-	dst->child = NULL;
 	dst->dev = dev;
 	if (dev)
 		dev_hold(dev);
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 6e1e10f..099b0a2 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -399,7 +399,7 @@ struct pktgen_dev {
 	__u8	ipsmode;		/* IPSEC mode (config) */
 	__u8	ipsproto;		/* IPSEC type (config) */
 	__u32	spi;
-	struct dst_entry dst;
+	struct xfrm_dst xdst;
 	struct dst_ops dstops;
 #endif
 	char result[512];
@@ -2609,7 +2609,7 @@ static int pktgen_output_ipsec(struct sk_buff *skb, struct pktgen_dev *pkt_dev)
 	 * supports both transport/tunnel mode + ESP/AH type.
 	 */
 	if ((x->props.mode == XFRM_MODE_TUNNEL) && (pkt_dev->spi != 0))
-		skb->_skb_refdst = (unsigned long)&pkt_dev->dst | SKB_DST_NOREF;
+		skb->_skb_refdst = (unsigned long)&pkt_dev->xdst.u.dst | SKB_DST_NOREF;

 	rcu_read_lock_bh();
 	err = x->outer_mode->output(x, skb);
@@ -3734,10 +3734,10 @@ static int pktgen_add_device(struct pktgen_thread *t, const char *ifname)
 	 * performance under such circumstance.
 	 */
 	pkt_dev->dstops.family = AF_INET;
-	pkt_dev->dst.dev = pkt_dev->odev;
-	dst_init_metrics(&pkt_dev->dst, pktgen_dst_metrics, false);
-	pkt_dev->dst.child = &pkt_dev->dst;
-	pkt_dev->dst.ops = &pkt_dev->dstops;
+	pkt_dev->xdst.u.dst.dev = pkt_dev->odev;
+	dst_init_metrics(&pkt_dev->xdst.u.dst, pktgen_dst_metrics, false);
+	pkt_dev->xdst.child = &pkt_dev->xdst.u.dst;
+	pkt_dev->xdst.u.dst.ops = &pkt_dev->dstops;
 #endif

 	return add_dev_to_thread(t, pkt_dev);
--
2.1.2.532.g19b5d50
---
 include/net/dst.h         |  3 +--
 include/net/xfrm.h        | 13 +++++++++----
 net/core/dst.c            |  9 ++++++---
 net/core/pktgen.c         | 12 ++++++------
 net/netfilter/xt_policy.c |  3 ++-
 net/xfrm/xfrm_device.c    |  2 +-
 6 files changed, 25 insertions(+), 17 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 2409e7795ad5..6c6f0140759d 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -34,7 +34,6 @@ struct sk_buff;
 struct dst_entry {
 	struct net_device       *dev;
 	struct rcu_head		rcu_head;
-	struct dst_entry	*child;
 	struct  dst_ops	        *ops;
 	unsigned long		_metrics;
 	unsigned long           expires;
@@ -88,7 +87,7 @@ struct dst_entry {
 	 * Align __refcnt to a 64 bytes alignment
 	 * (L1_CACHE_SIZE would be too much)
 	 */
-	long			__pad_to_align_refcnt[2];
+	long			__pad_to_align_refcnt[3];
 #endif
 	/*
 	 * __refcnt wants to be on a different cache line from
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 5a4cc05ff9e8..6509ba4316c7 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -983,6 +983,7 @@ struct xfrm_dst {
 		struct rt6_info		rt6;
 	} u;
 	struct dst_entry *route;
+	struct dst_entry *child;
 	struct xfrm_policy *pols[XFRM_POLICY_TYPE_MAX];
 	int num_pols, num_xfrms;
 	u32 xfrm_genid;
@@ -997,15 +998,17 @@ struct xfrm_dst {
 static inline struct dst_entry *xfrm_dst_child(const struct dst_entry *dst)
 {
 #ifdef CONFIG_XFRM
-	if (dst->xfrm)
-		return dst->child;
+	if (dst->xfrm) {
+		struct xfrm_dst *xdst = (struct xfrm_dst *) dst;
+		return xdst->child;
+	}
 #endif
 	return NULL;
 }
 
 static inline void xfrm_dst_set_child(struct xfrm_dst *xdst, struct dst_entry *child)
 {
-	xdst->u.dst.child = child;
+	xdst->child = child;
 }
 
 static inline void xfrm_dst_destroy(struct xfrm_dst *xdst)
@@ -1879,12 +1882,14 @@ bool xfrm_dev_offload_ok(struct sk_buff *skb, struct xfrm_state *x);
 static inline bool xfrm_dst_offload_ok(struct dst_entry *dst)
 {
 	struct xfrm_state *x = dst->xfrm;
+	struct xfrm_dst *xdst;
 
 	if (!x || !x->type_offload)
 		return false;
 
+	xdst = (struct xfrm_dst *) dst;
 	if (x->xso.offload_handle && (x->xso.dev == dst->path->dev) &&
-	    !dst->child->xfrm)
+	    !xdst->child->xfrm)
 		return true;
 
 	return false;
diff --git a/net/core/dst.c b/net/core/dst.c
index 6a3c21b8fc8d..5cf96179e8e0 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -21,6 +21,7 @@
 #include <linux/sched.h>
 #include <linux/prefetch.h>
 #include <net/lwtunnel.h>
+#include <net/xfrm.h>
 
 #include <net/dst.h>
 #include <net/dst_metadata.h>
@@ -62,7 +63,6 @@ void dst_init(struct dst_entry *dst, struct dst_ops *ops,
 	      struct net_device *dev, int initial_ref, int initial_obsolete,
 	      unsigned short flags)
 {
-	dst->child = NULL;
 	dst->dev = dev;
 	if (dev)
 		dev_hold(dev);
@@ -121,8 +121,11 @@ struct dst_entry *dst_destroy(struct dst_entry * dst)
 	smp_rmb();
 
 #ifdef CONFIG_XFRM
-	if (dst->xfrm)
-		child = dst->child;
+	if (dst->xfrm) {
+		struct xfrm_dst *xdst = (struct xfrm_dst *) dst;
+
+		child = xdst->child;
+	}
 #endif
 	if (!(dst->flags & DST_NOCOUNT))
 		dst_entries_add(dst->ops, -1);
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 6e1e10ff433a..099b0a2f6bb2 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -399,7 +399,7 @@ struct pktgen_dev {
 	__u8	ipsmode;		/* IPSEC mode (config) */
 	__u8	ipsproto;		/* IPSEC type (config) */
 	__u32	spi;
-	struct dst_entry dst;
+	struct xfrm_dst xdst;
 	struct dst_ops dstops;
 #endif
 	char result[512];
@@ -2609,7 +2609,7 @@ static int pktgen_output_ipsec(struct sk_buff *skb, struct pktgen_dev *pkt_dev)
 	 * supports both transport/tunnel mode + ESP/AH type.
 	 */
 	if ((x->props.mode == XFRM_MODE_TUNNEL) && (pkt_dev->spi != 0))
-		skb->_skb_refdst = (unsigned long)&pkt_dev->dst | SKB_DST_NOREF;
+		skb->_skb_refdst = (unsigned long)&pkt_dev->xdst.u.dst | SKB_DST_NOREF;
 
 	rcu_read_lock_bh();
 	err = x->outer_mode->output(x, skb);
@@ -3734,10 +3734,10 @@ static int pktgen_add_device(struct pktgen_thread *t, const char *ifname)
 	 * performance under such circumstance.
 	 */
 	pkt_dev->dstops.family = AF_INET;
-	pkt_dev->dst.dev = pkt_dev->odev;
-	dst_init_metrics(&pkt_dev->dst, pktgen_dst_metrics, false);
-	pkt_dev->dst.child = &pkt_dev->dst;
-	pkt_dev->dst.ops = &pkt_dev->dstops;
+	pkt_dev->xdst.u.dst.dev = pkt_dev->odev;
+	dst_init_metrics(&pkt_dev->xdst.u.dst, pktgen_dst_metrics, false);
+	pkt_dev->xdst.child = &pkt_dev->xdst.u.dst;
+	pkt_dev->xdst.u.dst.ops = &pkt_dev->dstops;
 #endif
 
 	return add_dev_to_thread(t, pkt_dev);
diff --git a/net/netfilter/xt_policy.c b/net/netfilter/xt_policy.c
index 2b4ab189bba7..5639fb03bdd9 100644
--- a/net/netfilter/xt_policy.c
+++ b/net/netfilter/xt_policy.c
@@ -93,7 +93,8 @@ match_policy_out(const struct sk_buff *skb, const struct xt_policy_info *info,
 	if (dst->xfrm == NULL)
 		return -1;
 
-	for (i = 0; dst && dst->xfrm; dst = dst->child, i++) {
+	for (i = 0; dst && dst->xfrm;
+	     dst = ((struct xfrm_dst *)dst)->child, i++) {
 		pos = strict ? i : 0;
 		if (pos >= info->len)
 			return 0;
diff --git a/net/xfrm/xfrm_device.c b/net/xfrm/xfrm_device.c
index 30e5746085b8..c5851ddddd2a 100644
--- a/net/xfrm/xfrm_device.c
+++ b/net/xfrm/xfrm_device.c
@@ -121,7 +121,7 @@ bool xfrm_dev_offload_ok(struct sk_buff *skb, struct xfrm_state *x)
 		return false;
 
 	if ((x->xso.offload_handle && (dev == dst->path->dev)) &&
-	     !dst->child->xfrm && x->type->get_mtu) {
+	     !xdst->child->xfrm && x->type->get_mtu) {
 		mtu = x->type->get_mtu(x, xdst->child_mtu_cached);
 
 		if (skb->len <= mtu)
-- 
2.13.6
