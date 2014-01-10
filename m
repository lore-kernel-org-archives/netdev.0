From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 01/12] net: qdisc: use rcu prefix and silence sparse
 warnings
Date: Fri, 10 Jan 2014 01:37:09 -0800
Message-ID: <20140110093707.7193.69803.stgit@nitbit.x32>
References: <20140110092041.7193.5952.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: xiyou.wangcong@gmail.com, jhs@mojatatu.com, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f42.google.com ([209.85.219.42]:46910 "EHLO
	mail-oa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750793AbaAJJh1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 04:37:27 -0500
Received: by mail-oa0-f42.google.com with SMTP id n16so4746048oag.1
        for <netdev@vger.kernel.org>; Fri, 10 Jan 2014 01:37:26 -0800 (PST)
In-Reply-To: <20140110092041.7193.5952.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add __rcu notation to qdisc handling by doing this we can make
smatch output more legible. And anyways some of the cases should
be using rcu_dereference() see qdisc_all_tx_empty(),
qdisc_tx_chainging(), and so on.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/linux/netdevice.h |   41 ++++------------------------------
 include/net/sch_generic.h |   29 +++++++++++++++++++-----
 net/core/dev.c            |   54 +++++++++++++++++++++++++++++++++++++++++++--
 net/sched/sch_generic.c   |    4 ++-
 net/sched/sch_mqprio.c    |    4 ++-
 net/sched/sch_teql.c      |    9 ++++----
 6 files changed, 89 insertions(+), 52 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 88afa80..797e473 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -546,7 +546,7 @@ struct netdev_queue {
  * read mostly part
  */
 	struct net_device	*dev;
-	struct Qdisc		*qdisc;
+	struct Qdisc __rcu	*qdisc;
 	struct Qdisc		*qdisc_sleeping;
 #ifdef CONFIG_SYSFS
 	struct kobject		kobj;
@@ -1987,13 +1987,8 @@ static inline void input_queue_tail_incr_save(struct softnet_data *sd,
 
 DECLARE_PER_CPU_ALIGNED(struct softnet_data, softnet_data);
 
-void __netif_schedule(struct Qdisc *q);
-
-static inline void netif_schedule_queue(struct netdev_queue *txq)
-{
-	if (!(txq->state & QUEUE_STATE_ANY_XOFF))
-		__netif_schedule(txq->qdisc);
-}
+extern void __netif_schedule(struct Qdisc *q);
+extern void netif_schedule_queue(struct netdev_queue *txq);
 
 static inline void netif_tx_schedule_all(struct net_device *dev)
 {
@@ -2029,17 +2024,7 @@ static inline void netif_tx_start_all_queues(struct net_device *dev)
 	}
 }
 
-static inline void netif_tx_wake_queue(struct netdev_queue *dev_queue)
-{
-#ifdef CONFIG_NETPOLL_TRAP
-	if (netpoll_trap()) {
-		netif_tx_start_queue(dev_queue);
-		return;
-	}
-#endif
-	if (test_and_clear_bit(__QUEUE_STATE_DRV_XOFF, &dev_queue->state))
-		__netif_schedule(dev_queue->qdisc);
-}
+extern void netif_tx_wake_queue(struct netdev_queue *dev_queue);
 
 /**
  *	netif_wake_queue - restart transmit
@@ -2288,23 +2273,7 @@ static inline bool netif_subqueue_stopped(const struct net_device *dev,
 	return __netif_subqueue_stopped(dev, skb_get_queue_mapping(skb));
 }
 
-/**
- *	netif_wake_subqueue - allow sending packets on subqueue
- *	@dev: network device
- *	@queue_index: sub queue index
- *
- * Resume individual transmit queue of a device with multiple transmit queues.
- */
-static inline void netif_wake_subqueue(struct net_device *dev, u16 queue_index)
-{
-	struct netdev_queue *txq = netdev_get_tx_queue(dev, queue_index);
-#ifdef CONFIG_NETPOLL_TRAP
-	if (netpoll_trap())
-		return;
-#endif
-	if (test_and_clear_bit(__QUEUE_STATE_DRV_XOFF, &txq->state))
-		__netif_schedule(txq->qdisc);
-}
+extern void netif_wake_subqueue(struct net_device *dev, u16 queue_index);
 
 #ifdef CONFIG_XPS
 int netif_set_xps_queue(struct net_device *dev, const struct cpumask *mask,
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 013d96d..3e10a2a 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -259,7 +259,9 @@ static inline spinlock_t *qdisc_lock(struct Qdisc *qdisc)
 
 static inline struct Qdisc *qdisc_root(const struct Qdisc *qdisc)
 {
-	return qdisc->dev_queue->qdisc;
+	struct Qdisc *q = rcu_dereference(qdisc->dev_queue->qdisc);
+
+	return q;
 }
 
 static inline struct Qdisc *qdisc_root_sleeping(const struct Qdisc *qdisc)
@@ -384,7 +386,7 @@ static inline void qdisc_reset_all_tx_gt(struct net_device *dev, unsigned int i)
 	struct Qdisc *qdisc;
 
 	for (; i < dev->num_tx_queues; i++) {
-		qdisc = netdev_get_tx_queue(dev, i)->qdisc;
+		qdisc = rtnl_dereference(netdev_get_tx_queue(dev, i)->qdisc);
 		if (qdisc) {
 			spin_lock_bh(qdisc_lock(qdisc));
 			qdisc_reset(qdisc);
@@ -402,13 +404,18 @@ static inline void qdisc_reset_all_tx(struct net_device *dev)
 static inline bool qdisc_all_tx_empty(const struct net_device *dev)
 {
 	unsigned int i;
+
+	rcu_read_lock();
 	for (i = 0; i < dev->num_tx_queues; i++) {
 		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
-		const struct Qdisc *q = txq->qdisc;
+		const struct Qdisc *q = rcu_dereference(txq->qdisc);
 
-		if (q->q.qlen)
+		if (q->q.qlen) {
+			rcu_read_unlock();
 			return false;
+		}
 	}
+	rcu_read_unlock();
 	return true;
 }
 
@@ -416,11 +423,16 @@ static inline bool qdisc_all_tx_empty(const struct net_device *dev)
 static inline bool qdisc_tx_changing(const struct net_device *dev)
 {
 	unsigned int i;
+
+	rcu_read_lock();
 	for (i = 0; i < dev->num_tx_queues; i++) {
 		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
-		if (txq->qdisc != txq->qdisc_sleeping)
+		if (rcu_dereference(txq->qdisc) != txq->qdisc_sleeping) {
+			rcu_read_unlock();
 			return true;
+		}
 	}
+	rcu_read_unlock();
 	return false;
 }
 
@@ -428,11 +440,16 @@ static inline bool qdisc_tx_changing(const struct net_device *dev)
 static inline bool qdisc_tx_is_noop(const struct net_device *dev)
 {
 	unsigned int i;
+
+	rcu_read_lock();
 	for (i = 0; i < dev->num_tx_queues; i++) {
 		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
-		if (txq->qdisc != &noop_qdisc)
+		if (rcu_dereference(txq->qdisc) != &noop_qdisc) {
+			rcu_read_unlock();
 			return false;
+		}
 	}
+	rcu_read_unlock();
 	return true;
 }
 
diff --git a/net/core/dev.c b/net/core/dev.c
index cc9ab80..9f761e7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2154,6 +2154,56 @@ static struct dev_kfree_skb_cb *get_kfree_skb_cb(const struct sk_buff *skb)
 	return (struct dev_kfree_skb_cb *)skb->cb;
 }
 
+void netif_schedule_queue(struct netdev_queue *txq)
+{
+	rcu_read_lock();
+	if (!(txq->state & QUEUE_STATE_ANY_XOFF)) {
+		struct Qdisc *q = rcu_dereference(txq->qdisc);
+
+		__netif_schedule(q);
+	}
+	rcu_read_unlock();
+}
+EXPORT_SYMBOL(netif_schedule_queue);
+
+/**
+ *	netif_wake_subqueue - allow sending packets on subqueue
+ *	@dev: network device
+ *	@queue_index: sub queue index
+ *
+ * Resume individual transmit queue of a device with multiple transmit queues.
+ */
+void netif_wake_subqueue(struct net_device *dev, u16 queue_index)
+{
+	struct netdev_queue *txq = netdev_get_tx_queue(dev, queue_index);
+#ifdef CONFIG_NETPOLL_TRAP
+	if (netpoll_trap())
+		return;
+#endif
+	if (test_and_clear_bit(__QUEUE_STATE_DRV_XOFF, &txq->state)) {
+		struct Qdisc *q = rcu_dereference(txq->qdisc);
+
+		__netif_schedule(q);
+	}
+}
+EXPORT_SYMBOL(netif_wake_subqueue);
+
+void netif_tx_wake_queue(struct netdev_queue *dev_queue)
+{
+#ifdef CONFIG_NETPOLL_TRAP
+	if (netpoll_trap()) {
+		netif_tx_start_queue(dev_queue);
+		return;
+	}
+#endif
+	if (test_and_clear_bit(__QUEUE_STATE_DRV_XOFF, &dev_queue->state)) {
+		struct Qdisc *q = rcu_dereference(dev_queue->qdisc);
+
+		__netif_schedule(q);
+	}
+}
+EXPORT_SYMBOL(netif_tx_wake_queue);
+
 void __dev_kfree_skb_irq(struct sk_buff *skb, enum skb_free_reason reason)
 {
 	unsigned long flags;
@@ -3375,7 +3425,7 @@ static int ing_filter(struct sk_buff *skb, struct netdev_queue *rxq)
 	skb->tc_verd = SET_TC_RTTL(skb->tc_verd, ttl);
 	skb->tc_verd = SET_TC_AT(skb->tc_verd, AT_INGRESS);
 
-	q = rxq->qdisc;
+	q = rcu_dereference(rxq->qdisc);
 	if (q != &noop_qdisc) {
 		spin_lock(qdisc_lock(q));
 		if (likely(!test_bit(__QDISC_STATE_DEACTIVATED, &q->state)))
@@ -3392,7 +3442,7 @@ static inline struct sk_buff *handle_ing(struct sk_buff *skb,
 {
 	struct netdev_queue *rxq = rcu_dereference(skb->dev->ingress_queue);
 
-	if (!rxq || rxq->qdisc == &noop_qdisc)
+	if (!rxq || rcu_dereference_bh(rxq->qdisc) == &noop_qdisc)
 		goto out;
 
 	if (*pt_prev) {
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 32bb942..71d7cd9 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -776,7 +776,7 @@ static void dev_deactivate_queue(struct net_device *dev,
 	struct Qdisc *qdisc_default = _qdisc_default;
 	struct Qdisc *qdisc;
 
-	qdisc = dev_queue->qdisc;
+	qdisc = rtnl_dereference(dev_queue->qdisc);
 	if (qdisc) {
 		spin_lock_bh(qdisc_lock(qdisc));
 
@@ -869,7 +869,7 @@ static void dev_init_scheduler_queue(struct net_device *dev,
 {
 	struct Qdisc *qdisc = _qdisc;
 
-	dev_queue->qdisc = qdisc;
+	rcu_assign_pointer(dev_queue->qdisc, qdisc);
 	dev_queue->qdisc_sleeping = qdisc;
 }
 
diff --git a/net/sched/sch_mqprio.c b/net/sched/sch_mqprio.c
index 6749e2f..e1b112f 100644
--- a/net/sched/sch_mqprio.c
+++ b/net/sched/sch_mqprio.c
@@ -231,7 +231,7 @@ static int mqprio_dump(struct Qdisc *sch, struct sk_buff *skb)
 	memset(&sch->qstats, 0, sizeof(sch->qstats));
 
 	for (i = 0; i < dev->num_tx_queues; i++) {
-		qdisc = netdev_get_tx_queue(dev, i)->qdisc;
+		qdisc = rtnl_dereference(netdev_get_tx_queue(dev, i)->qdisc);
 		spin_lock_bh(qdisc_lock(qdisc));
 		sch->q.qlen		+= qdisc->q.qlen;
 		sch->bstats.bytes	+= qdisc->bstats.bytes;
@@ -340,7 +340,7 @@ static int mqprio_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 		spin_unlock_bh(d->lock);
 
 		for (i = tc.offset; i < tc.offset + tc.count; i++) {
-			qdisc = netdev_get_tx_queue(dev, i)->qdisc;
+			qdisc = rtnl_dereference(netdev_get_tx_queue(dev, i)->qdisc);
 			spin_lock_bh(qdisc_lock(qdisc));
 			bstats.bytes      += qdisc->bstats.bytes;
 			bstats.packets    += qdisc->bstats.packets;
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index 4741671..b35ba70 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -100,7 +100,8 @@ teql_dequeue(struct Qdisc *sch)
 	skb = __skb_dequeue(&dat->q);
 	dat_queue = netdev_get_tx_queue(dat->m->dev, 0);
 	if (skb == NULL) {
-		struct net_device *m = qdisc_dev(dat_queue->qdisc);
+		struct Qdisc *q = rcu_dereference_bh(dat_queue->qdisc);
+		struct net_device *m = qdisc_dev(q);
 		if (m) {
 			dat->m->slaves = sch;
 			netif_wake_queue(m);
@@ -157,9 +158,9 @@ teql_destroy(struct Qdisc *sch)
 						txq = netdev_get_tx_queue(master->dev, 0);
 						master->slaves = NULL;
 
-						root_lock = qdisc_root_sleeping_lock(txq->qdisc);
+						root_lock = qdisc_root_sleeping_lock(rtnl_dereference(txq->qdisc));
 						spin_lock_bh(root_lock);
-						qdisc_reset(txq->qdisc);
+						qdisc_reset(rtnl_dereference(txq->qdisc));
 						spin_unlock_bh(root_lock);
 					}
 				}
@@ -266,7 +267,7 @@ static inline int teql_resolve(struct sk_buff *skb,
 	struct dst_entry *dst = skb_dst(skb);
 	int res;
 
-	if (txq->qdisc == &noop_qdisc)
+	if (rcu_dereference_bh(txq->qdisc) == &noop_qdisc)
 		return -ENODEV;
 
 	if (!dev->header_ops || !dst)
