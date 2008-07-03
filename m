From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: [PATCH 06/39]: netdev: ->ingress_lock is no longer needed.
Date: Thu, 03 Jul 2008 00:03:03 -0700 (PDT)
Message-ID: <20080703.000303.167904111.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vinay-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, krkumar2-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
	Matheos.Worku-UdXhSnd/wVw@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Every qdisc is assosciated with a queue, and in the
case of ingress qdiscs that will now be netdev->rx_queue
so using that queue's lock is the thing to do.

Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 drivers/net/ifb.c         |    8 ++++----
 include/linux/netdevice.h |    2 --
 net/core/dev.c            |   12 +++++++-----
 net/sched/sch_api.c       |    3 +--
 net/sched/sch_generic.c   |   10 +++++-----
 5 files changed, 17 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index bc3de27..ccbd655 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -229,13 +229,13 @@ module_param(numifbs, int, 0);
 MODULE_PARM_DESC(numifbs, "Number of ifb devices");
 
 /*
- * dev_ifb->tx_queue.lock is usually taken after dev->ingress_lock,
+ * dev_ifb->tx_queue.lock is usually taken after dev->rx_queue.lock,
  * reversely to e.g. qdisc_lock_tree(). It should be safe until
- * ifb doesn't take dev->tx_queue.lock with dev_ifb->ingress_lock.
+ * ifb doesn't take dev->tx_queue.lock with dev_ifb->rx_queue.lock.
  * But lockdep should know that ifb has different locks from dev.
  */
 static struct lock_class_key ifb_tx_queue_lock_key;
-static struct lock_class_key ifb_ingress_lock_key;
+static struct lock_class_key ifb_rx_queue_lock_key;
 
 
 static int __init ifb_init_one(int index)
@@ -259,7 +259,7 @@ static int __init ifb_init_one(int index)
 		goto err;
 
 	lockdep_set_class(&dev_ifb->tx_queue.lock, &ifb_tx_queue_lock_key);
-	lockdep_set_class(&dev_ifb->ingress_lock, &ifb_ingress_lock_key);
+	lockdep_set_class(&dev_ifb->rx_queue.lock, &ifb_rx_queue_lock_key);
 
 	return 0;
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 40542e3..ec88b46 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -632,8 +632,6 @@ struct net_device
 	struct netdev_queue	rx_queue;
 	struct netdev_queue	tx_queue;
 
-	/* ingress path synchronizer */
-	spinlock_t		ingress_lock;
 	struct Qdisc		*qdisc_ingress;
 
 /*
diff --git a/net/core/dev.c b/net/core/dev.c
index 8565f94..7013562 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2014,10 +2014,11 @@ static inline struct sk_buff *handle_macvlan(struct sk_buff *skb,
  */
 static int ing_filter(struct sk_buff *skb)
 {
-	struct Qdisc *q;
 	struct net_device *dev = skb->dev;
-	int result = TC_ACT_OK;
 	u32 ttl = G_TC_RTTL(skb->tc_verd);
+	struct netdev_queue *rxq;
+	int result = TC_ACT_OK;
+	struct Qdisc *q;
 
 	if (MAX_RED_LOOP < ttl++) {
 		printk(KERN_WARNING
@@ -2029,10 +2030,12 @@ static int ing_filter(struct sk_buff *skb)
 	skb->tc_verd = SET_TC_RTTL(skb->tc_verd, ttl);
 	skb->tc_verd = SET_TC_AT(skb->tc_verd, AT_INGRESS);
 
-	spin_lock(&dev->ingress_lock);
+	rxq = &dev->rx_queue;
+
+	spin_lock(&rxq->lock);
 	if ((q = dev->qdisc_ingress) != NULL)
 		result = q->enqueue(skb, q);
-	spin_unlock(&dev->ingress_lock);
+	spin_unlock(&rxq->lock);
 
 	return result;
 }
@@ -3795,7 +3798,6 @@ int register_netdevice(struct net_device *dev)
 	spin_lock_init(&dev->_xmit_lock);
 	netdev_set_lockdep_class(&dev->_xmit_lock, dev->type);
 	dev->xmit_lock_owner = -1;
-	spin_lock_init(&dev->ingress_lock);
 
 	dev->iflink = -1;
 
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index e3feb88..c33e65a 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -497,12 +497,11 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
 
 	sch->parent = parent;
 
+	sch->stats_lock = &dev_queue->lock;
 	if (handle == TC_H_INGRESS) {
 		sch->flags |= TCQ_F_INGRESS;
-		sch->stats_lock = &dev->ingress_lock;
 		handle = TC_H_MAKE(TC_H_INGRESS, 0);
 	} else {
-		sch->stats_lock = &dev_queue->lock;
 		if (handle == 0) {
 			handle = qdisc_alloc_handle(dev);
 			err = -ENOMEM;
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index ee8f9f7..804d44b 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -35,24 +35,24 @@
  * - enqueue, dequeue are serialized via top level device
  *   spinlock queue->lock.
  * - ingress filtering is serialized via top level device
- *   spinlock dev->ingress_lock.
+ *   spinlock dev->rx_queue.lock.
  * - updates to tree and tree walking are only done under the rtnl mutex.
  */
 
 void qdisc_lock_tree(struct net_device *dev)
 	__acquires(dev->tx_queue.lock)
-	__acquires(dev->ingress_lock)
+	__acquires(dev->rx_queue.lock)
 {
 	spin_lock_bh(&dev->tx_queue.lock);
-	spin_lock(&dev->ingress_lock);
+	spin_lock(&dev->rx_queue.lock);
 }
 EXPORT_SYMBOL(qdisc_lock_tree);
 
 void qdisc_unlock_tree(struct net_device *dev)
-	__releases(dev->ingress_lock)
+	__releases(dev->rx_queue.lock)
 	__releases(dev->tx_queue.lock)
 {
-	spin_unlock(&dev->ingress_lock);
+	spin_unlock(&dev->rx_queue.lock);
 	spin_unlock_bh(&dev->tx_queue.lock);
 }
 EXPORT_SYMBOL(qdisc_unlock_tree);
-- 
1.5.6

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
