From: Tom Herbert <therbert@google.com>
Subject: [RFC PATCH v2 2/9] net: Add queue state xoff flag for stack
Date: Sun, 7 Aug 2011 21:44:36 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.1108072141280.14333@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:12041 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899Ab1HHEol (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 00:44:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From c3a8c0ace2322f9ccf78089936a504af9c9e0c7f Mon Sep 17 00:00:00 2001
From: Tom Herbert <therbert@google.com>
Date: Thu, 14 Jul 2011 22:08:27 -0700
Subject: [PATCH 2/9] net: Add queue state xoff flag for stack

Create separate queue state flags so that either the stack or drivers
can turn on XOFF.  Added a set of functions usedin the stack to determine
if a queue is really stopped (either by stack of driver)

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/netdevice.h |   32 +++++++++++++++++++++-----------
 net/core/dev.c            |    4 ++--
 net/core/netpoll.c        |    4 ++--
 net/core/pktgen.c         |    2 +-
 net/sched/sch_generic.c   |    8 ++++----
 net/sched/sch_multiq.c    |    6 ++++--
 net/sched/sch_teql.c      |    6 +++---
 7 files changed, 37 insertions(+), 25 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ddee79b..4115b4d 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -516,10 +516,13 @@ static inline void napi_synchronize(const struct napi_struct *n)
 #endif
 
 enum netdev_queue_state_t {
-	__QUEUE_STATE_XOFF,
+	__QUEUE_STATE_DRV_XOFF,
+	__QUEUE_STATE_STACK_XOFF,
 	__QUEUE_STATE_FROZEN,
-#define QUEUE_STATE_XOFF_OR_FROZEN ((1 << __QUEUE_STATE_XOFF)		| \
-				    (1 << __QUEUE_STATE_FROZEN))
+#define QUEUE_STATE_ANY_XOFF ((1 << __QUEUE_STATE_DRV_XOFF)		| \
+			      (1 << __QUEUE_STATE_STACK_XOFF))
+#define QUEUE_STATE_ANY_XOFF_OR_FROZEN (QUEUE_STATE_ANY_XOFF		| \
+					(1 << __QUEUE_STATE_FROZEN))
 };
 
 struct netdev_queue {
@@ -1778,7 +1781,7 @@ extern void __netif_schedule(struct Qdisc *q);
 
 static inline void netif_schedule_queue(struct netdev_queue *txq)
 {
-	if (!test_bit(__QUEUE_STATE_XOFF, &txq->state))
+	if (!(txq->state & QUEUE_STATE_ANY_XOFF))
 		__netif_schedule(txq->qdisc);
 }
 
@@ -1792,7 +1795,7 @@ static inline void netif_tx_schedule_all(struct net_device *dev)
 
 static inline void netif_tx_start_queue(struct netdev_queue *dev_queue)
 {
-	clear_bit(__QUEUE_STATE_XOFF, &dev_queue->state);
+	clear_bit(__QUEUE_STATE_DRV_XOFF, &dev_queue->state);
 }
 
 /**
@@ -1824,7 +1827,7 @@ static inline void netif_tx_wake_queue(struct netdev_queue *dev_queue)
 		return;
 	}
 #endif
-	if (test_and_clear_bit(__QUEUE_STATE_XOFF, &dev_queue->state))
+	if (test_and_clear_bit(__QUEUE_STATE_DRV_XOFF, &dev_queue->state))
 		__netif_schedule(dev_queue->qdisc);
 }
 
@@ -1856,7 +1859,7 @@ static inline void netif_tx_stop_queue(struct netdev_queue *dev_queue)
 		pr_info("netif_stop_queue() cannot be called before register_netdev()\n");
 		return;
 	}
-	set_bit(__QUEUE_STATE_XOFF, &dev_queue->state);
+	set_bit(__QUEUE_STATE_DRV_XOFF, &dev_queue->state);
 }
 
 /**
@@ -1883,7 +1886,7 @@ static inline void netif_tx_stop_all_queues(struct net_device *dev)
 
 static inline int netif_tx_queue_stopped(const struct netdev_queue *dev_queue)
 {
-	return test_bit(__QUEUE_STATE_XOFF, &dev_queue->state);
+	return test_bit(__QUEUE_STATE_DRV_XOFF, &dev_queue->state);
 }
 
 /**
@@ -1897,9 +1900,16 @@ static inline int netif_queue_stopped(const struct net_device *dev)
 	return netif_tx_queue_stopped(netdev_get_tx_queue(dev, 0));
 }
 
-static inline int netif_tx_queue_frozen_or_stopped(const struct netdev_queue *dev_queue)
+static inline int netif_xmit_stopped(const struct netdev_queue *dev_queue)
 {
-	return dev_queue->state & QUEUE_STATE_XOFF_OR_FROZEN;
+	return dev_queue->state & QUEUE_STATE_ANY_XOFF;
+}
+
+static inline int netif_xmit_frozen_or_stopped(const struct netdev_queue *dev_queue)
+{
+	return dev_queue->state & QUEUE_STATE_ANY_XOFF_OR_FROZEN;
+}
+
 }
 
 /**
@@ -1986,7 +1996,7 @@ static inline void netif_wake_subqueue(struct net_device *dev, u16 queue_index)
 	if (netpoll_trap())
 		return;
 #endif
-	if (test_and_clear_bit(__QUEUE_STATE_XOFF, &txq->state))
+	if (test_and_clear_bit(__QUEUE_STATE_DRV_XOFF, &txq->state))
 		__netif_schedule(txq->qdisc);
 }
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 17d67b5..a7f8c38 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2190,7 +2190,7 @@ gso:
 			return rc;
 		}
 		txq_trans_update(txq);
-		if (unlikely(netif_tx_queue_stopped(txq) && skb->next))
+		if (unlikely(netif_xmit_stopped(txq) && skb->next))
 			return NETDEV_TX_BUSY;
 	} while (skb->next);
 
@@ -2464,7 +2464,7 @@ int dev_queue_xmit(struct sk_buff *skb)
 
 			HARD_TX_LOCK(dev, txq, cpu);
 
-			if (!netif_tx_queue_stopped(txq)) {
+			if (!netif_xmit_stopped(txq)) {
 				__this_cpu_inc(xmit_recursion);
 				rc = dev_hard_start_xmit(skb, dev, txq);
 				__this_cpu_dec(xmit_recursion);
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index adf84dd..9c71328 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -75,7 +75,7 @@ static void queue_process(struct work_struct *work)
 
 		local_irq_save(flags);
 		__netif_tx_lock(txq, smp_processor_id());
-		if (netif_tx_queue_frozen_or_stopped(txq) ||
+		if (netif_xmit_frozen_or_stopped(txq) ||
 		    ops->ndo_start_xmit(skb, dev) != NETDEV_TX_OK) {
 			skb_queue_head(&npinfo->txq, skb);
 			__netif_tx_unlock(txq);
@@ -316,7 +316,7 @@ void netpoll_send_skb_on_dev(struct netpoll *np, struct sk_buff *skb,
 		for (tries = jiffies_to_usecs(1)/USEC_PER_POLL;
 		     tries > 0; --tries) {
 			if (__netif_tx_trylock(txq)) {
-				if (!netif_tx_queue_stopped(txq)) {
+				if (!netif_xmit_stopped(txq)) {
 					status = ops->ndo_start_xmit(skb, dev);
 					if (status == NETDEV_TX_OK)
 						txq_trans_update(txq);
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index e35a6fb..5c481c5 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3342,7 +3342,7 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 
 	__netif_tx_lock_bh(txq);
 
-	if (unlikely(netif_tx_queue_frozen_or_stopped(txq))) {
+	if (unlikely(netif_xmit_frozen_or_stopped(txq))) {
 		ret = NETDEV_TX_BUSY;
 		pkt_dev->last_ok = 0;
 		goto unlock;
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 69fca27..7c84f08 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -60,7 +60,7 @@ static inline struct sk_buff *dequeue_skb(struct Qdisc *q)
 
 		/* check the reason of requeuing without tx lock first */
 		txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
-		if (!netif_tx_queue_frozen_or_stopped(txq)) {
+		if (!netif_xmit_frozen_or_stopped(txq)) {
 			q->gso_skb = NULL;
 			q->q.qlen--;
 		} else
@@ -121,7 +121,7 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
 	spin_unlock(root_lock);
 
 	HARD_TX_LOCK(dev, txq, smp_processor_id());
-	if (!netif_tx_queue_frozen_or_stopped(txq))
+	if (!netif_xmit_frozen_or_stopped(txq))
 		ret = dev_hard_start_xmit(skb, dev, txq);
 
 	HARD_TX_UNLOCK(dev, txq);
@@ -143,7 +143,7 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
 		ret = dev_requeue_skb(skb, q);
 	}
 
-	if (ret && netif_tx_queue_frozen_or_stopped(txq))
+	if (ret && netif_xmit_frozen_or_stopped(txq))
 		ret = 0;
 
 	return ret;
@@ -242,7 +242,7 @@ static void dev_watchdog(unsigned long arg)
 				 * old device drivers set dev->trans_start
 				 */
 				trans_start = txq->trans_start ? : dev->trans_start;
-				if (netif_tx_queue_stopped(txq) &&
+				if (netif_xmit_stopped(txq) &&
 				    time_after(jiffies, (trans_start +
 							 dev->watchdog_timeo))) {
 					some_queue_timedout = 1;
diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
index edc1950..49131d7 100644
--- a/net/sched/sch_multiq.c
+++ b/net/sched/sch_multiq.c
@@ -107,7 +107,8 @@ static struct sk_buff *multiq_dequeue(struct Qdisc *sch)
 		/* Check that target subqueue is available before
 		 * pulling an skb to avoid head-of-line blocking.
 		 */
-		if (!__netif_subqueue_stopped(qdisc_dev(sch), q->curband)) {
+		if (!netif_xmit_stopped(
+		    netdev_get_tx_queue(qdisc_dev(sch), q->curband))) {
 			qdisc = q->queues[q->curband];
 			skb = qdisc->dequeue(qdisc);
 			if (skb) {
@@ -138,7 +139,8 @@ static struct sk_buff *multiq_peek(struct Qdisc *sch)
 		/* Check that target subqueue is available before
 		 * pulling an skb to avoid head-of-line blocking.
 		 */
-		if (!__netif_subqueue_stopped(qdisc_dev(sch), curband)) {
+		if (!netif_xmit_stopped(
+		    netdev_get_tx_queue(qdisc_dev(sch), curband))) {
 			qdisc = q->queues[curband];
 			skb = qdisc->ops->peek(qdisc);
 			if (skb)
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index a3b7120..283bfe3 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -301,7 +301,7 @@ restart:
 
 		if (slave_txq->qdisc_sleeping != q)
 			continue;
-		if (__netif_subqueue_stopped(slave, subq) ||
+		if (netif_xmit_stopped(netdev_get_tx_queue(slave, subq)) ||
 		    !netif_running(slave)) {
 			busy = 1;
 			continue;
@@ -312,7 +312,7 @@ restart:
 			if (__netif_tx_trylock(slave_txq)) {
 				unsigned int length = qdisc_pkt_len(skb);
 
-				if (!netif_tx_queue_frozen_or_stopped(slave_txq) &&
+				if (!netif_xmit_frozen_or_stopped(slave_txq) &&
 				    slave_ops->ndo_start_xmit(skb, slave) == NETDEV_TX_OK) {
 					txq_trans_update(slave_txq);
 					__netif_tx_unlock(slave_txq);
@@ -324,7 +324,7 @@ restart:
 				}
 				__netif_tx_unlock(slave_txq);
 			}
-			if (netif_queue_stopped(dev))
+			if (netif_xmit_stopped(netdev_get_tx_queue(dev, 0)))
 				busy = 1;
 			break;
 		case 1:
-- 
1.7.3.1

