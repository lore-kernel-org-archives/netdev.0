From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 1/9] IB/ipoib: Bound the net device to the ipoib_neigh structue
Date: Tue,  9 Oct 2007 19:43:36 -0700
Message-ID: <1191984225129-git-send-email-fubar@us.ibm.com>
References: <1191984224957-git-send-email-fubar@us.ibm.com>
Cc: Moni Shoua <monis@voltaire.com>
To: netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:55241 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751983AbXJJCnt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 22:43:49 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l9A1Z9Vb009693
	for <netdev@vger.kernel.org>; Tue, 9 Oct 2007 21:35:09 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9A2hk7J477450
	for <netdev@vger.kernel.org>; Tue, 9 Oct 2007 20:43:46 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9A2hkQS001990
	for <netdev@vger.kernel.org>; Tue, 9 Oct 2007 20:43:46 -0600
In-Reply-To: <1191984224957-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Moni Shoua <monis@voltaire.com>

IPoIB uses a two layer neighboring scheme, such that for each struct neighbour
whose device is an ipoib one, there is a struct ipoib_neigh buddy which is
created on demand at the tx flow by an ipoib_neigh_alloc(skb->dst->neighbour)
call.

When using the bonding driver, neighbours are created by the net stack on behalf
of the bonding (master) device. On the tx flow the bonding code gets an skb such
that skb->dev points to the master device, it changes this skb to point on the
slave device and calls the slave hard_start_xmit function.

Under this scheme, ipoib_neigh_destructor assumption that for each struct
neighbour it gets, n->dev is an ipoib device and hence netdev_priv(n->dev)
can be casted to struct ipoib_dev_priv is buggy.

To fix it, this patch adds a dev field to struct ipoib_neigh which is used
instead of the struct neighbour dev one, when n->dev->flags has the
IFF_MASTER bit set.

Signed-off-by: Moni Shoua <monis at voltaire.com>
Signed-off-by: Or Gerlitz <ogerlitz at voltaire.com>
Acked-by: Roland Dreier <rdreier@cisco.com>
---
 drivers/infiniband/ulp/ipoib/ipoib.h           |    4 +++-
 drivers/infiniband/ulp/ipoib/ipoib_main.c      |   24 +++++++++++++++---------
 drivers/infiniband/ulp/ipoib/ipoib_multicast.c |    3 ++-
 3 files changed, 20 insertions(+), 11 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib.h b/drivers/infiniband/ulp/ipoib/ipoib.h
index 34c6128..1fa2df6 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib.h
+++ b/drivers/infiniband/ulp/ipoib/ipoib.h
@@ -328,6 +328,7 @@ struct ipoib_neigh {
 	struct sk_buff_head queue;
 
 	struct neighbour   *neighbour;
+	struct net_device *dev;
 
 	struct list_head    list;
 };
@@ -344,7 +345,8 @@ static inline struct ipoib_neigh **to_ipoib_neigh(struct neighbour *neigh)
 				     INFINIBAND_ALEN, sizeof(void *));
 }
 
-struct ipoib_neigh *ipoib_neigh_alloc(struct neighbour *neigh);
+struct ipoib_neigh *ipoib_neigh_alloc(struct neighbour *neigh,
+				      struct net_device *dev);
 void ipoib_neigh_free(struct net_device *dev, struct ipoib_neigh *neigh);
 
 extern struct workqueue_struct *ipoib_workqueue;
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index 855c9de..bbfe8f2 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -515,7 +515,7 @@ static void neigh_add_path(struct sk_buff *skb, struct net_device *dev)
 	struct ipoib_path *path;
 	struct ipoib_neigh *neigh;
 
-	neigh = ipoib_neigh_alloc(skb->dst->neighbour);
+	neigh = ipoib_neigh_alloc(skb->dst->neighbour, skb->dev);
 	if (!neigh) {
 		++dev->stats.tx_dropped;
 		dev_kfree_skb_any(skb);
@@ -815,6 +815,13 @@ static void ipoib_neigh_cleanup(struct neighbour *n)
 	unsigned long flags;
 	struct ipoib_ah *ah = NULL;
 
+	neigh = *to_ipoib_neigh(n);
+	if (neigh) {
+		priv = netdev_priv(neigh->dev);
+		ipoib_dbg(priv, "neigh_destructor for bonding device: %s\n",
+			  n->dev->name);
+	} else
+		return;
 	ipoib_dbg(priv,
 		  "neigh_cleanup for %06x " IPOIB_GID_FMT "\n",
 		  IPOIB_QPN(n->ha),
@@ -822,13 +829,10 @@ static void ipoib_neigh_cleanup(struct neighbour *n)
 
 	spin_lock_irqsave(&priv->lock, flags);
 
-	neigh = *to_ipoib_neigh(n);
-	if (neigh) {
-		if (neigh->ah)
-			ah = neigh->ah;
-		list_del(&neigh->list);
-		ipoib_neigh_free(n->dev, neigh);
-	}
+	if (neigh->ah)
+		ah = neigh->ah;
+	list_del(&neigh->list);
+	ipoib_neigh_free(n->dev, neigh);
 
 	spin_unlock_irqrestore(&priv->lock, flags);
 
@@ -836,7 +840,8 @@ static void ipoib_neigh_cleanup(struct neighbour *n)
 		ipoib_put_ah(ah);
 }
 
-struct ipoib_neigh *ipoib_neigh_alloc(struct neighbour *neighbour)
+struct ipoib_neigh *ipoib_neigh_alloc(struct neighbour *neighbour,
+				      struct net_device *dev)
 {
 	struct ipoib_neigh *neigh;
 
@@ -845,6 +850,7 @@ struct ipoib_neigh *ipoib_neigh_alloc(struct neighbour *neighbour)
 		return NULL;
 
 	neigh->neighbour = neighbour;
+	neigh->dev = dev;
 	*to_ipoib_neigh(neighbour) = neigh;
 	skb_queue_head_init(&neigh->queue);
 	ipoib_cm_set(neigh, NULL);
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
index 98e904a..274f0ae 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
@@ -727,7 +727,8 @@ out:
 		if (skb->dst            &&
 		    skb->dst->neighbour &&
 		    !*to_ipoib_neigh(skb->dst->neighbour)) {
-			struct ipoib_neigh *neigh = ipoib_neigh_alloc(skb->dst->neighbour);
+			struct ipoib_neigh *neigh = ipoib_neigh_alloc(skb->dst->neighbour,
+									skb->dev);
 
 			if (neigh) {
 				kref_get(&mcast->ah->ref);
-- 
1.5.3.1

