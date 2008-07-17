From: David Miller <davem@davemloft.net>
Subject: [PATCH 18/31]: pkt_sched: Schedule qdiscs instead of netdev_queue.
Date: Thu, 17 Jul 2008 05:17:14 -0700 (PDT)
Message-ID: <20080717.051714.235082907.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, johannes@sipsolutions.net,
	linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51665
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755363AbYGQMRP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 08:17:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When we have shared qdiscs, packets come out of the qdiscs
for multiple transmit queues.

Therefore it doesn't make any sense to schedule the transmit
queue when logically we cannot know ahead of time the TX
queue of the SKB that the qdisc->dequeue() will give us.

Just for sanity I added a BUG check to make sure we never
get into a state where the noop_qdisc is scheduled.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netdevice.h |   12 +++----
 include/net/pkt_sched.h   |   11 ++----
 include/net/sch_generic.h |    2 +
 net/core/dev.c            |   68 ++++++++++++++++++--------------------------
 net/sched/sch_api.c       |    3 +-
 net/sched/sch_cbq.c       |    2 +-
 net/sched/sch_generic.c   |   30 +++++++++----------
 7 files changed, 55 insertions(+), 73 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9240a95..1e839fa 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -275,7 +275,6 @@ enum netdev_state_t
 {
 	__LINK_STATE_START,
 	__LINK_STATE_PRESENT,
-	__LINK_STATE_SCHED,
 	__LINK_STATE_NOCARRIER,
 	__LINK_STATE_LINKWATCH_PENDING,
 	__LINK_STATE_DORMANT,
@@ -452,7 +451,6 @@ struct netdev_queue {
 	int			xmit_lock_owner;
 	struct Qdisc		*qdisc_sleeping;
 	struct list_head	qdisc_list;
-	struct netdev_queue	*next_sched;
 } ____cacheline_aligned_in_smp;
 
 /*
@@ -969,7 +967,7 @@ static inline int unregister_gifconf(unsigned int family)
  */
 struct softnet_data
 {
-	struct netdev_queue	*output_queue;
+	struct Qdisc		*output_queue;
 	struct sk_buff_head	input_pkt_queue;
 	struct list_head	poll_list;
 	struct sk_buff		*completion_queue;
@@ -984,12 +982,12 @@ DECLARE_PER_CPU(struct softnet_data,softnet_data);
 
 #define HAVE_NETIF_QUEUE
 
-extern void __netif_schedule(struct netdev_queue *txq);
+extern void __netif_schedule(struct Qdisc *q);
 
 static inline void netif_schedule_queue(struct netdev_queue *txq)
 {
 	if (!test_bit(__QUEUE_STATE_XOFF, &txq->state))
-		__netif_schedule(txq);
+		__netif_schedule(txq->qdisc);
 }
 
 static inline void netif_tx_schedule_all(struct net_device *dev)
@@ -1042,7 +1040,7 @@ static inline void netif_tx_wake_queue(struct netdev_queue *dev_queue)
 	}
 #endif
 	if (test_and_clear_bit(__QUEUE_STATE_XOFF, &dev_queue->state))
-		__netif_schedule(dev_queue);
+		__netif_schedule(dev_queue->qdisc);
 }
 
 static inline void netif_wake_queue(struct net_device *dev)
@@ -1186,7 +1184,7 @@ static inline void netif_wake_subqueue(struct net_device *dev, u16 queue_index)
 		return;
 #endif
 	if (test_and_clear_bit(__QUEUE_STATE_XOFF, &txq->state))
-		__netif_schedule(txq);
+		__netif_schedule(txq->qdisc);
 }
 
 /**
diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index 06a442d..e4e3005 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -84,15 +84,12 @@ extern struct qdisc_rate_table *qdisc_get_rtab(struct tc_ratespec *r,
 		struct nlattr *tab);
 extern void qdisc_put_rtab(struct qdisc_rate_table *tab);
 
-extern void __qdisc_run(struct netdev_queue *txq);
+extern void __qdisc_run(struct Qdisc *q);
 
-static inline void qdisc_run(struct netdev_queue *txq)
+static inline void qdisc_run(struct Qdisc *q)
 {
-	struct Qdisc *q = txq->qdisc;
-
-	if (!netif_tx_queue_stopped(txq) &&
-	    !test_and_set_bit(__QDISC_STATE_RUNNING, &q->state))
-		__qdisc_run(txq);
+	if (!test_and_set_bit(__QDISC_STATE_RUNNING, &q->state))
+		__qdisc_run(q);
 }
 
 extern int tc_classify_compat(struct sk_buff *skb, struct tcf_proto *tp,
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 9241782..3cc4b5c 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -26,6 +26,7 @@ struct qdisc_rate_table
 enum qdisc_state_t
 {
 	__QDISC_STATE_RUNNING,
+	__QDISC_STATE_SCHED,
 };
 
 struct Qdisc
@@ -45,6 +46,7 @@ struct Qdisc
 	struct sk_buff		*gso_skb;
 	struct sk_buff_head	q;
 	struct netdev_queue	*dev_queue;
+	struct Qdisc		*next_sched;
 	struct list_head	list;
 
 	struct gnet_stats_basic	bstats;
diff --git a/net/core/dev.c b/net/core/dev.c
index 467bfb3..0b909b7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1323,18 +1323,18 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
 }
 
 
-void __netif_schedule(struct netdev_queue *txq)
+void __netif_schedule(struct Qdisc *q)
 {
-	struct net_device *dev = txq->dev;
+	BUG_ON(q == &noop_qdisc);
 
-	if (!test_and_set_bit(__LINK_STATE_SCHED, &dev->state)) {
+	if (!test_and_set_bit(__QDISC_STATE_SCHED, &q->state)) {
 		struct softnet_data *sd;
 		unsigned long flags;
 
 		local_irq_save(flags);
 		sd = &__get_cpu_var(softnet_data);
-		txq->next_sched = sd->output_queue;
-		sd->output_queue = txq;
+		q->next_sched = sd->output_queue;
+		sd->output_queue = q;
 		raise_softirq_irqoff(NET_TX_SOFTIRQ);
 		local_irq_restore(flags);
 	}
@@ -1771,37 +1771,23 @@ gso:
 	rcu_read_lock_bh();
 
 	txq = dev_pick_tx(dev, skb);
-	spin_lock_prefetch(&txq->lock);
-
-	/* Updates of qdisc are serialized by queue->lock.
-	 * The struct Qdisc which is pointed to by qdisc is now a
-	 * rcu structure - it may be accessed without acquiring
-	 * a lock (but the structure may be stale.) The freeing of the
-	 * qdisc will be deferred until it's known that there are no
-	 * more references to it.
-	 *
-	 * If the qdisc has an enqueue function, we still need to
-	 * hold the queue->lock before calling it, since queue->lock
-	 * also serializes access to the device queue.
-	 */
-
 	q = rcu_dereference(txq->qdisc);
+
 #ifdef CONFIG_NET_CLS_ACT
 	skb->tc_verd = SET_TC_AT(skb->tc_verd,AT_EGRESS);
 #endif
 	if (q->enqueue) {
-		/* Grab device queue */
-		spin_lock(&txq->lock);
-		q = txq->qdisc;
-		if (q->enqueue) {
-			rc = q->enqueue(skb, q);
-			qdisc_run(txq);
-			spin_unlock(&txq->lock);
-
-			rc = rc == NET_XMIT_BYPASS ? NET_XMIT_SUCCESS : rc;
-			goto out;
-		}
-		spin_unlock(&txq->lock);
+		spinlock_t *root_lock = qdisc_root_lock(q);
+
+		spin_lock(root_lock);
+
+		rc = q->enqueue(skb, q);
+		qdisc_run(q);
+
+		spin_unlock(root_lock);
+
+		rc = rc == NET_XMIT_BYPASS ? NET_XMIT_SUCCESS : rc;
+		goto out;
 	}
 
 	/* The device has no queue. Common case for software devices:
@@ -1974,7 +1960,7 @@ static void net_tx_action(struct softirq_action *h)
 	}
 
 	if (sd->output_queue) {
-		struct netdev_queue *head;
+		struct Qdisc *head;
 
 		local_irq_disable();
 		head = sd->output_queue;
@@ -1982,18 +1968,20 @@ static void net_tx_action(struct softirq_action *h)
 		local_irq_enable();
 
 		while (head) {
-			struct netdev_queue *txq = head;
-			struct net_device *dev = txq->dev;
+			struct Qdisc *q = head;
+			spinlock_t *root_lock;
+
 			head = head->next_sched;
 
 			smp_mb__before_clear_bit();
-			clear_bit(__LINK_STATE_SCHED, &dev->state);
+			clear_bit(__QDISC_STATE_SCHED, &q->state);
 
-			if (spin_trylock(&txq->lock)) {
-				qdisc_run(txq);
-				spin_unlock(&txq->lock);
+			root_lock = qdisc_root_lock(q);
+			if (spin_trylock(root_lock)) {
+				qdisc_run(q);
+				spin_unlock(root_lock);
 			} else {
-				netif_schedule_queue(txq);
+				__netif_schedule(q);
 			}
 		}
 	}
@@ -4459,7 +4447,7 @@ static int dev_cpu_callback(struct notifier_block *nfb,
 			    void *ocpu)
 {
 	struct sk_buff **list_skb;
-	struct netdev_queue **list_net;
+	struct Qdisc **list_net;
 	struct sk_buff *skb;
 	unsigned int cpu, oldcpu = (unsigned long)ocpu;
 	struct softnet_data *sd, *oldsd;
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 19c244a..8e8c5be 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -294,11 +294,10 @@ static enum hrtimer_restart qdisc_watchdog(struct hrtimer *timer)
 {
 	struct qdisc_watchdog *wd = container_of(timer, struct qdisc_watchdog,
 						 timer);
-	struct netdev_queue *txq = wd->qdisc->dev_queue;
 
 	wd->qdisc->flags &= ~TCQ_F_THROTTLED;
 	smp_wmb();
-	netif_schedule_queue(txq);
+	__netif_schedule(wd->qdisc);
 
 	return HRTIMER_NORESTART;
 }
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 37ae653..a3953bb 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -650,7 +650,7 @@ static enum hrtimer_restart cbq_undelay(struct hrtimer *timer)
 	}
 
 	sch->flags &= ~TCQ_F_THROTTLED;
-	netif_schedule_queue(sch->dev_queue);
+	__netif_schedule(sch);
 	return HRTIMER_NORESTART;
 }
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 739a871..dd5c4e7 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -72,16 +72,14 @@ static inline int qdisc_qlen(struct Qdisc *q)
 	return q->q.qlen;
 }
 
-static inline int dev_requeue_skb(struct sk_buff *skb,
-				  struct netdev_queue *dev_queue,
-				  struct Qdisc *q)
+static inline int dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
 {
 	if (unlikely(skb->next))
 		q->gso_skb = skb;
 	else
 		q->ops->requeue(skb, q);
 
-	netif_schedule_queue(dev_queue);
+	__netif_schedule(q);
 	return 0;
 }
 
@@ -121,7 +119,7 @@ static inline int handle_dev_cpu_collision(struct sk_buff *skb,
 		 * some time.
 		 */
 		__get_cpu_var(netdev_rx_stat).cpu_collision++;
-		ret = dev_requeue_skb(skb, dev_queue, q);
+		ret = dev_requeue_skb(skb, q);
 	}
 
 	return ret;
@@ -146,9 +144,9 @@ static inline int handle_dev_cpu_collision(struct sk_buff *skb,
  *				>0 - queue is not empty.
  *
  */
-static inline int qdisc_restart(struct netdev_queue *txq,
-				struct Qdisc *q)
+static inline int qdisc_restart(struct Qdisc *q)
 {
+	struct netdev_queue *txq;
 	int ret = NETDEV_TX_BUSY;
 	struct net_device *dev;
 	spinlock_t *root_lock;
@@ -163,7 +161,8 @@ static inline int qdisc_restart(struct netdev_queue *txq,
 	/* And release qdisc */
 	spin_unlock(root_lock);
 
-	dev = txq->dev;
+	dev = qdisc_dev(q);
+	txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
 
 	HARD_TX_LOCK(dev, txq, smp_processor_id());
 	if (!netif_subqueue_stopped(dev, skb))
@@ -189,29 +188,28 @@ static inline int qdisc_restart(struct netdev_queue *txq,
 			printk(KERN_WARNING "BUG %s code %d qlen %d\n",
 			       dev->name, ret, q->q.qlen);
 
-		ret = dev_requeue_skb(skb, txq, q);
+		ret = dev_requeue_skb(skb, q);
 		break;
 	}
 
+	if (ret && netif_tx_queue_stopped(txq))
+		ret = 0;
+
 	return ret;
 }
 
-void __qdisc_run(struct netdev_queue *txq)
+void __qdisc_run(struct Qdisc *q)
 {
 	unsigned long start_time = jiffies;
-	struct Qdisc *q = txq->qdisc;
-
-	while (qdisc_restart(txq, q)) {
-		if (netif_tx_queue_stopped(txq))
-			break;
 
+	while (qdisc_restart(q)) {
 		/*
 		 * Postpone processing if
 		 * 1. another process needs the CPU;
 		 * 2. we've been doing it for too long.
 		 */
 		if (need_resched() || jiffies != start_time) {
-			netif_schedule_queue(txq);
+			__netif_schedule(q);
 			break;
 		}
 	}
-- 
1.5.6.2.255.gbed62

