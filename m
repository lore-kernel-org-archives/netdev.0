From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 03/11] IB/ipoib: Bound the net device to the ipoib_neigh structue
Date: Fri, 14 Sep 2007 16:40:22 -0700
Message-ID: <11898132352341-git-send-email-fubar@us.ibm.com>
References: <11898132301664-git-send-email-fubar@us.ibm.com>
 <11898132322950-git-send-email-fubar@us.ibm.com>
 <1189813234208-git-send-email-fubar@us.ibm.com>
Cc: monisonlists@gmail.com, ogerlitz@voltaire.com, jgarzik@pobox.com,
	davem@davemloft.net, general@lists.openfabrics.org,
	Moni Shoua <monis@voltaire.com>
To: netdev@vger.kernel.org, rdreier@cisco.com, monis@voltaire.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:45480 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754421AbXINXki (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2007 19:40:38 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8ENeceA024819
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 19:40:38 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8ENec34564078
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 19:40:38 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8ENebNx008592
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 19:40:37 -0400
In-Reply-To: <1189813234208-git-send-email-fubar@us.ibm.com>
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

Signed-off-by: Moni Shoua <monis@voltaire.com>
Signed-off-by: Or Gerlitz <ogerlitz@voltaire.com>
Acked-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/infiniband/ulp/ipoib/ipoib.h           |    4 +++-
 drivers/infiniband/ulp/ipoib/ipoib_main.c      |   17 +++++++++++++++--
 drivers/infiniband/ulp/ipoib/ipoib_multicast.c |    3 ++-
 3 files changed, 20 insertions(+), 4 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib.h b/drivers/infiniband/ulp/ipoib/ipoib.h
index 285c143..a13730c 100644
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
index 97a9661..cb26cfd 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -511,7 +511,7 @@ static void neigh_add_path(struct sk_buff *skb, struct net_device *dev)
 	struct ipoib_path *path;
 	struct ipoib_neigh *neigh;
 
-	neigh = ipoib_neigh_alloc(skb->dst->neighbour);
+	neigh = ipoib_neigh_alloc(skb->dst->neighbour, skb->dev);
 	if (!neigh) {
 		++priv->stats.tx_dropped;
 		dev_kfree_skb_any(skb);
@@ -830,6 +830,17 @@ static void ipoib_neigh_cleanup(struct neighbour *n)
 	unsigned long flags;
 	struct ipoib_ah *ah = NULL;
 
+	if (n->dev->flags & IFF_MASTER) {
+		/* n->dev is not an IPoIB device and we have
+			to take priv from elsewhere */
+		neigh = *to_ipoib_neigh(n);
+		if (neigh) {
+			priv = netdev_priv(neigh->dev);
+			ipoib_dbg(priv, "neigh_destructor for bonding device: %s\n",
+				  n->dev->name);
+		} else
+			return;
+	}
 	ipoib_dbg(priv,
 		  "neigh_cleanup for %06x " IPOIB_GID_FMT "\n",
 		  IPOIB_QPN(n->ha),
@@ -851,7 +862,8 @@ static void ipoib_neigh_cleanup(struct neighbour *n)
 		ipoib_put_ah(ah);
 }
 
-struct ipoib_neigh *ipoib_neigh_alloc(struct neighbour *neighbour)
+struct ipoib_neigh *ipoib_neigh_alloc(struct neighbour *neighbour,
+				      struct net_device *dev)
 {
 	struct ipoib_neigh *neigh;
 
@@ -860,6 +872,7 @@ struct ipoib_neigh *ipoib_neigh_alloc(struct neighbour *neighbour)
 		return NULL;
 
 	neigh->neighbour = neighbour;
+	neigh->dev = dev;
 	*to_ipoib_neigh(neighbour) = neigh;
 	skb_queue_head_init(&neigh->queue);
 	ipoib_cm_set(neigh, NULL);
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
index aae3670..ed0f0bb 100644
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
1.5.2-rc2.GIT

