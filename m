From: David Miller <davem@davemloft.net>
Subject: [PATCH 08/39]: netdev: Kill qdisc_ingress, use
 netdev->rx_queue.qdisc instead.
Date: Thu, 03 Jul 2008 00:03:14 -0700 (PDT)
Message-ID: <20080703.000314.213545851.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vinay@linux.vnet.ibm.com, krkumar2@in.ibm.com, mchan@broadcom.com,
	Matheos.Worku@Sun.COM, linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47485
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756778AbYGCHDP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 03:03:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Now that our qdisc management is bi-directional, per-queue, and fully
orthogonal, there is no reason to have a special ingress qdisc
pointer in struct net_device.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netdevice.h |    3 ---
 net/core/dev.c            |    4 ++--
 net/sched/sch_api.c       |   11 ++++++-----
 3 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e1e033b..1151d17 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -634,9 +634,6 @@ struct net_device
 
 	struct netdev_queue	rx_queue;
 	struct netdev_queue	tx_queue;
-
-	struct Qdisc		*qdisc_ingress;
-
 	unsigned long		tx_queue_len;	/* Max frames per queue allowed */
 
 	/* Partially transmitted GSO packet. */
diff --git a/net/core/dev.c b/net/core/dev.c
index 3ccb6da..8e38948 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2033,7 +2033,7 @@ static int ing_filter(struct sk_buff *skb)
 	rxq = &dev->rx_queue;
 
 	spin_lock(&rxq->lock);
-	if ((q = dev->qdisc_ingress) != NULL)
+	if ((q = rxq->qdisc) != NULL)
 		result = q->enqueue(skb, q);
 	spin_unlock(&rxq->lock);
 
@@ -2044,7 +2044,7 @@ static inline struct sk_buff *handle_ing(struct sk_buff *skb,
 					 struct packet_type **pt_prev,
 					 int *ret, struct net_device *orig_dev)
 {
-	if (!skb->dev->qdisc_ingress)
+	if (!skb->dev->rx_queue.qdisc)
 		goto out;
 
 	if (*pt_prev) {
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 4a51729..a2e62b3 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -346,14 +346,15 @@ dev_graft_qdisc(struct net_device *dev, struct Qdisc *qdisc)
 
 	qdisc_lock_tree(dev);
 	if (qdisc && qdisc->flags&TCQ_F_INGRESS) {
-		oqdisc = dev->qdisc_ingress;
+		dev_queue = &dev->rx_queue;
+		oqdisc = dev_queue->qdisc;
 		/* Prune old scheduler */
 		if (oqdisc && atomic_read(&oqdisc->refcnt) <= 1) {
 			/* delete */
 			qdisc_reset(oqdisc);
-			dev->qdisc_ingress = NULL;
+			dev_queue->qdisc = NULL;
 		} else {  /* new */
-			dev->qdisc_ingress = qdisc;
+			dev_queue->qdisc = qdisc;
 		}
 
 	} else {
@@ -635,7 +636,7 @@ static int tc_get_qdisc(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 					return -ENOENT;
 				q = qdisc_leaf(p, clid);
 			} else { /* ingress */
-				q = dev->qdisc_ingress;
+				q = dev->rx_queue.qdisc;
 			}
 		} else {
 			struct netdev_queue *dev_queue = &dev->tx_queue;
@@ -710,7 +711,7 @@ replay:
 					return -ENOENT;
 				q = qdisc_leaf(p, clid);
 			} else { /*ingress */
-				q = dev->qdisc_ingress;
+				q = dev->rx_queue.qdisc;
 			}
 		} else {
 			struct netdev_queue *dev_queue = &dev->tx_queue;
-- 
1.5.6

