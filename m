From: Moni Shoua <monis@voltaire.com>
Subject: [ofa-general] [PATCH V7 1/8] IB/ipoib: Bound the net device to the
 ipoib_neigh structue
Date: Mon, 15 Oct 2007 18:03:54 +0200
Message-ID: <47138F6A.8040103@voltaire.com>
References: <47138EB7.40703@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org
To: jgarzik@pobox.com,  fubar@us.ibm.com,  rdreier@cisco.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <47138EB7.40703@gmail.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org


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
index 6545fa7..1b3327a 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib.h
+++ b/drivers/infiniband/ulp/ipoib/ipoib.h
@@ -349,6 +349,7 @@ #endif
 	struct sk_buff_head queue;
 
 	struct neighbour   *neighbour;
+	struct net_device *dev;
 
 	struct list_head    list;
 };
@@ -365,7 +366,8 @@ static inline struct ipoib_neigh **to_ip
 				     INFINIBAND_ALEN, sizeof(void *));
 }
 
-struct ipoib_neigh *ipoib_neigh_alloc(struct neighbour *neigh);
+struct ipoib_neigh *ipoib_neigh_alloc(struct neighbour *neigh,
+				      struct net_device *dev);
 void ipoib_neigh_free(struct net_device *dev, struct ipoib_neigh *neigh);
 
 extern struct workqueue_struct *ipoib_workqueue;
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index e072f3c..cae026c 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -517,7 +517,7 @@ static void neigh_add_path(struct sk_buf
 	struct ipoib_path *path;
 	struct ipoib_neigh *neigh;
 
-	neigh = ipoib_neigh_alloc(skb->dst->neighbour);
+	neigh = ipoib_neigh_alloc(skb->dst->neighbour, skb->dev);
 	if (!neigh) {
 		++dev->stats.tx_dropped;
 		dev_kfree_skb_any(skb);
@@ -817,6 +817,13 @@ static void ipoib_neigh_cleanup(struct n
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
@@ -824,13 +831,10 @@ static void ipoib_neigh_cleanup(struct n
 
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
 
@@ -838,7 +842,8 @@ static void ipoib_neigh_cleanup(struct n
 		ipoib_put_ah(ah);
 }
 
-struct ipoib_neigh *ipoib_neigh_alloc(struct neighbour *neighbour)
+struct ipoib_neigh *ipoib_neigh_alloc(struct neighbour *neighbour,
+				      struct net_device *dev)
 {
 	struct ipoib_neigh *neigh;
 
@@ -847,6 +852,7 @@ struct ipoib_neigh *ipoib_neigh_alloc(st
 		return NULL;
 
 	neigh->neighbour = neighbour;
+	neigh->dev = dev;
 	*to_ipoib_neigh(neighbour) = neigh;
 	skb_queue_head_init(&neigh->queue);
 	ipoib_cm_set(neigh, NULL);
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
index 827820e..9bcfc7a 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
@@ -705,7 +705,8 @@ out:
 		if (skb->dst            &&
 		    skb->dst->neighbour &&
 		    !*to_ipoib_neigh(skb->dst->neighbour)) {
-			struct ipoib_neigh *neigh = ipoib_neigh_alloc(skb->dst->neighbour);
+			struct ipoib_neigh *neigh = ipoib_neigh_alloc(skb->dst->neighbour,
+									skb->dev);
 
 			if (neigh) {
 				kref_get(&mcast->ah->ref);
