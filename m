From: David Miller <davem@davemloft.net>
Subject: [PATCH 17/39]: netdev: Move gso_skb into netdev_queue.
Date: Thu, 03 Jul 2008 00:04:04 -0700 (PDT)
Message-ID: <20080703.000404.38890089.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vinay@linux.vnet.ibm.com, krkumar2@in.ibm.com, mchan@broadcom.com,
	Matheos.Worku@Sun.COM, linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47564
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757689AbYGCHEF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 03:04:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netdevice.h |    4 +---
 net/sched/sch_generic.c   |   42 +++++++++++++++++++++++-------------------
 2 files changed, 24 insertions(+), 22 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 60f7665..e9e0cd4 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -452,6 +452,7 @@ struct netdev_queue {
 	spinlock_t		lock;
 	struct net_device	*dev;
 	struct Qdisc		*qdisc;
+	struct sk_buff		*gso_skb;
 	struct Qdisc		*qdisc_sleeping;
 	struct list_head	qdisc_list;
 	struct netdev_queue	*next_sched;
@@ -635,9 +636,6 @@ struct net_device
 	struct netdev_queue	tx_queue;
 	unsigned long		tx_queue_len;	/* Max frames per queue allowed */
 
-	/* Partially transmitted GSO packet. */
-	struct sk_buff		*gso_skb;
-
 /*
  * One part is mostly used on xmit path (device)
  */
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 6e7068c..96f16a8 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -63,10 +63,11 @@ static inline int qdisc_qlen(struct Qdisc *q)
 }
 
 static inline int dev_requeue_skb(struct sk_buff *skb, struct net_device *dev,
+				  struct netdev_queue *dev_queue,
 				  struct Qdisc *q)
 {
 	if (unlikely(skb->next))
-		dev->gso_skb = skb;
+		dev_queue->gso_skb = skb;
 	else
 		q->ops->requeue(skb, q);
 
@@ -75,12 +76,13 @@ static inline int dev_requeue_skb(struct sk_buff *skb, struct net_device *dev,
 }
 
 static inline struct sk_buff *dev_dequeue_skb(struct net_device *dev,
+					      struct netdev_queue *dev_queue,
 					      struct Qdisc *q)
 {
 	struct sk_buff *skb;
 
-	if ((skb = dev->gso_skb))
-		dev->gso_skb = NULL;
+	if ((skb = dev_queue->gso_skb))
+		dev_queue->gso_skb = NULL;
 	else
 		skb = q->dequeue(q);
 
@@ -89,6 +91,7 @@ static inline struct sk_buff *dev_dequeue_skb(struct net_device *dev,
 
 static inline int handle_dev_cpu_collision(struct sk_buff *skb,
 					   struct net_device *dev,
+					   struct netdev_queue *dev_queue,
 					   struct Qdisc *q)
 {
 	int ret;
@@ -111,7 +114,7 @@ static inline int handle_dev_cpu_collision(struct sk_buff *skb,
 		 * some time.
 		 */
 		__get_cpu_var(netdev_rx_stat).cpu_collision++;
-		ret = dev_requeue_skb(skb, dev, q);
+		ret = dev_requeue_skb(skb, dev, dev_queue, q);
 	}
 
 	return ret;
@@ -144,7 +147,7 @@ static inline int qdisc_restart(struct net_device *dev)
 	int ret = NETDEV_TX_BUSY;
 
 	/* Dequeue packet */
-	if (unlikely((skb = dev_dequeue_skb(dev, q)) == NULL))
+	if (unlikely((skb = dev_dequeue_skb(dev, dev_queue, q)) == NULL))
 		return 0;
 
 
@@ -167,7 +170,7 @@ static inline int qdisc_restart(struct net_device *dev)
 
 	case NETDEV_TX_LOCKED:
 		/* Driver try lock failed */
-		ret = handle_dev_cpu_collision(skb, dev, q);
+		ret = handle_dev_cpu_collision(skb, dev, dev_queue, q);
 		break;
 
 	default:
@@ -176,7 +179,7 @@ static inline int qdisc_restart(struct net_device *dev)
 			printk(KERN_WARNING "BUG %s code %d qlen %d\n",
 			       dev->name, ret, q->q.qlen);
 
-		ret = dev_requeue_skb(skb, dev, q);
+		ret = dev_requeue_skb(skb, dev, dev_queue, q);
 		break;
 	}
 
@@ -578,31 +581,32 @@ void dev_activate(struct net_device *dev)
 	spin_unlock_bh(&dev_queue->lock);
 }
 
-static void dev_deactivate_queue(struct net_device *dev,
-				 struct netdev_queue *dev_queue,
+static void dev_deactivate_queue(struct netdev_queue *dev_queue,
 				 struct Qdisc *qdisc_default)
 {
-	struct Qdisc *qdisc = dev_queue->qdisc;
+	struct Qdisc *qdisc;
+	struct sk_buff *skb;
+
+	spin_lock_bh(&dev_queue->lock);
 
+	qdisc = dev_queue->qdisc;
 	if (qdisc) {
 		dev_queue->qdisc = qdisc_default;
 		qdisc_reset(qdisc);
 	}
+	skb = dev_queue->gso_skb;
+	dev_queue->gso_skb = NULL;
+
+	spin_unlock_bh(&dev_queue->lock);
+
+	kfree_skb(skb);
 }
 
 void dev_deactivate(struct net_device *dev)
 {
-	struct sk_buff *skb;
 	int running;
 
-	spin_lock_bh(&dev->tx_queue.lock);
-	dev_deactivate_queue(dev, &dev->tx_queue, &noop_qdisc);
-
-	skb = dev->gso_skb;
-	dev->gso_skb = NULL;
-	spin_unlock_bh(&dev->tx_queue.lock);
-
-	kfree_skb(skb);
+	dev_deactivate_queue(&dev->tx_queue, &noop_qdisc);
 
 	dev_watchdog_down(dev);
 
-- 
1.5.6

