From: David Miller <davem@davemloft.net>
Subject: [PATCH 19/19] net: Kill dst->_neighbour, accessors, and final uses.
Date: Tue, 03 Jul 2012 02:47:12 -0700 (PDT)
Message-ID: <20120703.024712.1321327852649965345.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36868 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752656Ab2GCJrM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2012 05:47:12 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 488CC584120
	for <netdev@vger.kernel.org>; Tue,  3 Jul 2012 02:47:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


No longer used.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/dst.h |   17 +----------------
 net/core/dst.c    |   18 ------------------
 2 files changed, 1 insertion(+), 34 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 295a705..b2634e4 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -42,7 +42,7 @@ struct dst_entry {
 		struct dst_entry        *from;
 	};
 	struct dst_entry	*path;
-	struct neighbour __rcu	*_neighbour;
+	void			*__pad0;
 #ifdef CONFIG_XFRM
 	struct xfrm_state	*xfrm;
 #else
@@ -96,21 +96,6 @@ struct dst_entry {
 	};
 };
 
-static inline struct neighbour *dst_get_neighbour_noref(struct dst_entry *dst)
-{
-	return rcu_dereference(dst->_neighbour);
-}
-
-static inline struct neighbour *dst_get_neighbour_noref_raw(struct dst_entry *dst)
-{
-	return rcu_dereference_raw(dst->_neighbour);
-}
-
-static inline void dst_set_neighbour(struct dst_entry *dst, struct neighbour *neigh)
-{
-	rcu_assign_pointer(dst->_neighbour, neigh);
-}
-
 extern u32 *dst_cow_metrics_generic(struct dst_entry *dst, unsigned long old);
 extern const u32 dst_default_metrics[RTAX_MAX];
 
diff --git a/net/core/dst.c b/net/core/dst.c
index a6e19a2..07bacff 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -171,7 +171,6 @@ void *dst_alloc(struct dst_ops *ops, struct net_device *dev,
 	dst_init_metrics(dst, dst_default_metrics, true);
 	dst->expires = 0UL;
 	dst->path = dst;
-	RCU_INIT_POINTER(dst->_neighbour, NULL);
 #ifdef CONFIG_XFRM
 	dst->xfrm = NULL;
 #endif
@@ -225,19 +224,12 @@ EXPORT_SYMBOL(__dst_free);
 struct dst_entry *dst_destroy(struct dst_entry * dst)
 {
 	struct dst_entry *child;
-	struct neighbour *neigh;
 
 	smp_rmb();
 
 again:
-	neigh = rcu_dereference_protected(dst->_neighbour, 1);
 	child = dst->child;
 
-	if (neigh) {
-		RCU_INIT_POINTER(dst->_neighbour, NULL);
-		neigh_release(neigh);
-	}
-
 	if (!(dst->flags & DST_NOCOUNT))
 		dst_entries_add(dst->ops, -1);
 
@@ -361,19 +353,9 @@ static void dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 	if (!unregister) {
 		dst->input = dst->output = dst_discard;
 	} else {
-		struct neighbour *neigh;
-
 		dst->dev = dev_net(dst->dev)->loopback_dev;
 		dev_hold(dst->dev);
 		dev_put(dev);
-		rcu_read_lock();
-		neigh = dst_get_neighbour_noref(dst);
-		if (neigh && neigh->dev == dev) {
-			neigh->dev = dst->dev;
-			dev_hold(dst->dev);
-			dev_put(dev);
-		}
-		rcu_read_unlock();
 	}
 }
 
-- 
1.7.10
