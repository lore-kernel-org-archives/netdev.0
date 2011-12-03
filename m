From: David Miller <davem@davemloft.net>
Subject: [PATCH 9/9] infiniband: ipoib: Sanitize neighbour handling in
 ipoib_main.c
Date: Fri, 02 Dec 2011 21:52:44 -0500 (EST)
Message-ID: <20111202.215244.855136989490171080.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roland@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52098 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756267Ab1LCCwq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 21:52:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Reduce the number of dst_get_neighbour_noref() calls within a single
call chain.  Primarily by passing the neighbour pointer down to the
helper functions.

Handle dst_get_neighbour_noref() returning NULL in ipoib_start_xmit()
by incrementing the dropped counter and freeing the packet.  We don't
want it to fall through into the ARP/RARP/multicast handling, since
that should only happen when skb_dst() is NULL.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/infiniband/ulp/ipoib/ipoib_main.c |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index eef6786..3514ca0 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -556,15 +556,13 @@ static int path_rec_start(struct net_device *dev,
 }
 
 /* called with rcu_read_lock */
-static void neigh_add_path(struct sk_buff *skb, struct net_device *dev)
+static void neigh_add_path(struct sk_buff *skb, struct neighbour *n, struct net_device *dev)
 {
 	struct ipoib_dev_priv *priv = netdev_priv(dev);
 	struct ipoib_path *path;
 	struct ipoib_neigh *neigh;
-	struct neighbour *n;
 	unsigned long flags;
 
-	n = dst_get_neighbour_noref(skb_dst(skb));
 	neigh = ipoib_neigh_alloc(n, skb->dev);
 	if (!neigh) {
 		++dev->stats.tx_dropped;
@@ -638,16 +636,13 @@ err_drop:
 }
 
 /* called with rcu_read_lock */
-static void ipoib_path_lookup(struct sk_buff *skb, struct net_device *dev)
+static void ipoib_path_lookup(struct sk_buff *skb, struct neighbour *n, struct net_device *dev)
 {
 	struct ipoib_dev_priv *priv = netdev_priv(skb->dev);
-	struct dst_entry *dst = skb_dst(skb);
-	struct neighbour *n;
 
 	/* Look up path record for unicasts */
-	n = dst_get_neighbour_noref(dst);
 	if (n->ha[4] != 0xff) {
-		neigh_add_path(skb, dev);
+		neigh_add_path(skb, n, dev);
 		return;
 	}
 
@@ -723,12 +718,17 @@ static int ipoib_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	unsigned long flags;
 
 	rcu_read_lock();
-	if (likely(skb_dst(skb)))
+	if (likely(skb_dst(skb))) {
 		n = dst_get_neighbour_noref(skb_dst(skb));
-
+		if (!n) {
+			++dev->stats.tx_dropped;
+			dev_kfree_skb_any(skb);
+			goto unlock;
+		}
+	}
 	if (likely(n)) {
 		if (unlikely(!*to_ipoib_neigh(n))) {
-			ipoib_path_lookup(skb, dev);
+			ipoib_path_lookup(skb, n, dev);
 			goto unlock;
 		}
 
@@ -751,7 +751,7 @@ static int ipoib_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			list_del(&neigh->list);
 			ipoib_neigh_free(dev, neigh);
 			spin_unlock_irqrestore(&priv->lock, flags);
-			ipoib_path_lookup(skb, dev);
+			ipoib_path_lookup(skb, n, dev);
 			goto unlock;
 		}
 
-- 
1.7.7.3
