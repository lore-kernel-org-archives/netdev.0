From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: [PATCH 28/31]: pkt_sched: Kill netdev_queue lock.
Date: Thu, 17 Jul 2008 05:18:12 -0700 (PDT)
Message-ID: <20080717.051812.254693359.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


We can simply use the qdisc->q.lock for all of the
qdisc tree synchronization.

Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 drivers/net/ifb.c         |   20 --------------------
 include/linux/netdevice.h |    1 -
 include/net/sch_generic.h |    7 ++++++-
 net/core/dev.c            |    9 +++++----
 net/mac80211/wme.c        |   19 ++++++++++++-------
 net/sched/sch_generic.c   |   32 +++++++++++++++-----------------
 net/sched/sch_teql.c      |    7 +++++--
 7 files changed, 43 insertions(+), 52 deletions(-)

diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index 897b05e..0960e69 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -35,7 +35,6 @@
 #include <linux/moduleparam.h>
 #include <net/pkt_sched.h>
 #include <net/net_namespace.h>
-#include <linux/lockdep.h>
 
 #define TX_TIMEOUT  (2*HZ)
 
@@ -228,22 +227,6 @@ static struct rtnl_link_ops ifb_link_ops __read_mostly = {
 module_param(numifbs, int, 0);
 MODULE_PARM_DESC(numifbs, "Number of ifb devices");
 
-/*
- * dev_ifb's TX queue lock is usually taken after dev->rx_queue.lock,
- * reversely to e.g. qdisc_lock_tree(). It should be safe until
- * ifb doesn't take dev's TX queue lock with dev_ifb->rx_queue.lock.
- * But lockdep should know that ifb has different locks from dev.
- */
-static struct lock_class_key ifb_tx_queue_lock_key;
-static struct lock_class_key ifb_rx_queue_lock_key;
-
-static void set_tx_lockdep_key(struct net_device *dev,
-			       struct netdev_queue *txq,
-			       void *_unused)
-{
-	lockdep_set_class(&txq->lock, &ifb_tx_queue_lock_key);
-}
-
 static int __init ifb_init_one(int index)
 {
 	struct net_device *dev_ifb;
@@ -264,9 +247,6 @@ static int __init ifb_init_one(int index)
 	if (err < 0)
 		goto err;
 
-	netdev_for_each_tx_queue(dev_ifb, set_tx_lockdep_key, NULL);
-	lockdep_set_class(&dev_ifb->rx_queue.lock, &ifb_rx_queue_lock_key);
-
 	return 0;
 
 err:
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3170bce..9c5a688 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -443,7 +443,6 @@ enum netdev_queue_state_t
 };
 
 struct netdev_queue {
-	spinlock_t		lock;
 	struct net_device	*dev;
 	struct Qdisc		*qdisc;
 	unsigned long		state;
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 1eef8d0..2902a42 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -163,6 +163,11 @@ struct tcf_proto
 	struct tcf_proto_ops	*ops;
 };
 
+static inline spinlock_t *qdisc_lock(struct Qdisc *qdisc)
+{
+	return &qdisc->q.lock;
+}
+
 static inline struct Qdisc *qdisc_root(struct Qdisc *qdisc)
 {
 	return qdisc->dev_queue->qdisc;
@@ -172,7 +177,7 @@ static inline spinlock_t *qdisc_root_lock(struct Qdisc *qdisc)
 {
 	struct Qdisc *root = qdisc_root(qdisc);
 
-	return &root->dev_queue->lock;
+	return qdisc_lock(root);
 }
 
 static inline struct net_device *qdisc_dev(struct Qdisc *qdisc)
diff --git a/net/core/dev.c b/net/core/dev.c
index 6741e34..32a1377 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2080,10 +2080,12 @@ static int ing_filter(struct sk_buff *skb)
 
 	rxq = &dev->rx_queue;
 
-	spin_lock(&rxq->lock);
-	if ((q = rxq->qdisc) != NULL)
+	q = rxq->qdisc;
+	if (q) {
+		spin_lock(qdisc_lock(q));
 		result = q->enqueue(skb, q);
-	spin_unlock(&rxq->lock);
+		spin_unlock(qdisc_lock(q));
+	}
 
 	return result;
 }
@@ -4173,7 +4175,6 @@ static void netdev_init_one_queue(struct net_device *dev,
 				  struct netdev_queue *queue,
 				  void *_unused)
 {
-	spin_lock_init(&queue->lock);
 	queue->dev = dev;
 }
 
diff --git a/net/mac80211/wme.c b/net/mac80211/wme.c
index b21cfec..6e8099e 100644
--- a/net/mac80211/wme.c
+++ b/net/mac80211/wme.c
@@ -237,12 +237,14 @@ void ieee80211_ht_agg_queue_remove(struct ieee80211_local *local,
 		ieee80211_requeue(local, agg_queue);
 	} else {
 		struct netdev_queue *txq;
+		spinlock_t *root_lock;
 
 		txq = netdev_get_tx_queue(local->mdev, agg_queue);
+		root_lock = qdisc_root_lock(txq->qdisc);
 
-		spin_lock_bh(&txq->lock);
+		spin_lock_bh(root_lock);
 		qdisc_reset(txq->qdisc);
-		spin_unlock_bh(&txq->lock);
+		spin_unlock_bh(root_lock);
 	}
 }
 
@@ -250,6 +252,7 @@ void ieee80211_requeue(struct ieee80211_local *local, int queue)
 {
 	struct netdev_queue *txq = netdev_get_tx_queue(local->mdev, queue);
 	struct sk_buff_head list;
+	spinlock_t *root_lock;
 	struct Qdisc *qdisc;
 	u32 len;
 
@@ -261,14 +264,15 @@ void ieee80211_requeue(struct ieee80211_local *local, int queue)
 
 	skb_queue_head_init(&list);
 
-	spin_lock(&txq->lock);
+	root_lock = qdisc_root_lock(qdisc);
+	spin_lock(root_lock);
 	for (len = qdisc->q.qlen; len > 0; len--) {
 		struct sk_buff *skb = qdisc->dequeue(qdisc);
 
 		if (skb)
 			__skb_queue_tail(&list, skb);
 	}
-	spin_unlock(&txq->lock);
+	spin_unlock(root_lock);
 
 	for (len = list.qlen; len > 0; len--) {
 		struct sk_buff *skb = __skb_dequeue(&list);
@@ -280,12 +284,13 @@ void ieee80211_requeue(struct ieee80211_local *local, int queue)
 
 		txq = netdev_get_tx_queue(local->mdev, new_queue);
 
-		spin_lock(&txq->lock);
 
 		qdisc = rcu_dereference(txq->qdisc);
-		qdisc->enqueue(skb, qdisc);
+		root_lock = qdisc_root_lock(qdisc);
 
-		spin_unlock(&txq->lock);
+		spin_lock(root_lock);
+		qdisc->enqueue(skb, qdisc);
+		spin_unlock(root_lock);
 	}
 
 out_unlock:
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 3d53e92..8fc580b 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -96,15 +96,15 @@ static inline int handle_dev_cpu_collision(struct sk_buff *skb,
 }
 
 /*
- * NOTE: Called under queue->lock with locally disabled BH.
+ * NOTE: Called under qdisc_lock(q) with locally disabled BH.
  *
  * __QDISC_STATE_RUNNING guarantees only one CPU can process
- * this qdisc at a time. queue->lock serializes queue accesses for
- * this queue AND txq->qdisc pointer itself.
+ * this qdisc at a time. qdisc_lock(q) serializes queue accesses for
+ * this queue.
  *
  *  netif_tx_lock serializes accesses to device driver.
  *
- *  queue->lock and netif_tx_lock are mutually exclusive,
+ *  qdisc_lock(q) and netif_tx_lock are mutually exclusive,
  *  if one is grabbed, another must be free.
  *
  * Note, that this procedure can be called by a watchdog timer
@@ -317,7 +317,6 @@ struct Qdisc_ops noop_qdisc_ops __read_mostly = {
 };
 
 static struct netdev_queue noop_netdev_queue = {
-	.lock		=	__SPIN_LOCK_UNLOCKED(noop_netdev_queue.lock),
 	.qdisc		=	&noop_qdisc,
 };
 
@@ -327,6 +326,7 @@ struct Qdisc noop_qdisc = {
 	.flags		=	TCQ_F_BUILTIN,
 	.ops		=	&noop_qdisc_ops,
 	.list		=	LIST_HEAD_INIT(noop_qdisc.list),
+	.q.lock		=	__SPIN_LOCK_UNLOCKED(noop_qdisc.q.lock),
 	.dev_queue	=	&noop_netdev_queue,
 };
 EXPORT_SYMBOL(noop_qdisc);
@@ -498,7 +498,7 @@ errout:
 }
 EXPORT_SYMBOL(qdisc_create_dflt);
 
-/* Under queue->lock and BH! */
+/* Under qdisc_root_lock(qdisc) and BH! */
 
 void qdisc_reset(struct Qdisc *qdisc)
 {
@@ -526,10 +526,12 @@ static void __qdisc_destroy(struct rcu_head *head)
 	module_put(ops->owner);
 	dev_put(qdisc_dev(qdisc));
 
+	kfree_skb(qdisc->gso_skb);
+
 	kfree((char *) qdisc - qdisc->padded);
 }
 
-/* Under queue->lock and BH! */
+/* Under qdisc_root_lock(qdisc) and BH! */
 
 void qdisc_destroy(struct Qdisc *qdisc)
 {
@@ -586,13 +588,12 @@ static void transition_one_qdisc(struct net_device *dev,
 				 struct netdev_queue *dev_queue,
 				 void *_need_watchdog)
 {
+	struct Qdisc *new_qdisc = dev_queue->qdisc_sleeping;
 	int *need_watchdog_p = _need_watchdog;
 
-	spin_lock_bh(&dev_queue->lock);
-	rcu_assign_pointer(dev_queue->qdisc, dev_queue->qdisc_sleeping);
-	if (dev_queue->qdisc != &noqueue_qdisc)
+	rcu_assign_pointer(dev_queue->qdisc, new_qdisc);
+	if (new_qdisc != &noqueue_qdisc)
 		*need_watchdog_p = 1;
-	spin_unlock_bh(&dev_queue->lock);
 }
 
 void dev_activate(struct net_device *dev)
@@ -629,19 +630,16 @@ static void dev_deactivate_queue(struct net_device *dev,
 	struct sk_buff *skb = NULL;
 	struct Qdisc *qdisc;
 
-	spin_lock_bh(&dev_queue->lock);
-
 	qdisc = dev_queue->qdisc;
 	if (qdisc) {
+		spin_lock_bh(qdisc_lock(qdisc));
+
 		dev_queue->qdisc = qdisc_default;
 		qdisc_reset(qdisc);
 
-		skb = qdisc->gso_skb;
-		qdisc->gso_skb = NULL;
+		spin_unlock_bh(qdisc_lock(qdisc));
 	}
 
-	spin_unlock_bh(&dev_queue->lock);
-
 	kfree_skb(skb);
 }
 
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index ade3372..8b0ff34 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -156,12 +156,15 @@ teql_destroy(struct Qdisc* sch)
 					master->slaves = NEXT_SLAVE(q);
 					if (q == master->slaves) {
 						struct netdev_queue *txq;
+						spinlock_t *root_lock;
 
 						txq = netdev_get_tx_queue(master->dev, 0);
 						master->slaves = NULL;
-						spin_lock_bh(&txq->lock);
+
+						root_lock = qdisc_root_lock(txq->qdisc);
+						spin_lock_bh(root_lock);
 						qdisc_reset(txq->qdisc);
-						spin_unlock_bh(&txq->lock);
+						spin_unlock_bh(root_lock);
 					}
 				}
 				skb_queue_purge(&dat->q);
-- 
1.5.6.2.255.gbed62

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
