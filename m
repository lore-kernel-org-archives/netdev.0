From: Tom Herbert <therbert@google.com>
Subject: [PATCH v3 02/10] net: Add queue state xoff flag for stack
Date: Tue, 22 Nov 2011 21:52:29 -0800 (PST)
Message-ID: <alpine.DEB.2.00.1111222139180.14467@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f202.google.com ([209.85.216.202]:53329 "EHLO
	mail-qy0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750952Ab1KWFwc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 00:52:32 -0500
Received: by qyk10 with SMTP id 10so107368qyk.1
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2011 21:52:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Create separate queue state flags so that either the stack or drivers
can turn on XOFF.  Added a set of functions used in the stack to determine
if a queue is really stopped (either by stack or driver)

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/netdevice.h |   41 ++++++++++++++++++++++++++++++-----------
 net/core/dev.c            |    4 ++--
 net/core/netpoll.c        |    4 ++--
 net/core/pktgen.c         |    2 +-
 net/sched/sch_generic.c   |    8 ++++----
 net/sched/sch_multiq.c    |    6 ++++--
 net/sched/sch_teql.c      |    6 +++---
 7 files changed, 46 insertions(+), 25 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index cbeb586..dfb50ed 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -516,11 +516,23 @@ static inline void napi_synchronize(const struct napi_struct *n)
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
+/*
+ * __QUEUE_STATE_DRV_XOFF is used by drivers to stop the transmit queue.  The
+ * netif_tx_* functions below are used to manipulate this flag.  The
+ * __QUEUE_STATE_STACK_XOFF flag is used by the stack to stop the transmit
+ * queue independently.  The netif_xmit_*stopped functions below are called
+ * to check if the queue has been stopped by the driver or stack (either
+ * of the XOFF bits are set in the state).  Drivers should not need to call
+ * netif_xmit*stopped functions, they should only be using netif_tx_*.
+ */
 
 struct netdev_queue {
 /*
@@ -1783,7 +1795,7 @@ extern void __netif_schedule(struct Qdisc *q);
 
 static inline void netif_schedule_queue(struct netdev_queue *txq)
 {
-	if (!test_bit(__QUEUE_STATE_XOFF, &txq->state))
+	if (!(txq->state & QUEUE_STATE_ANY_XOFF))
 		__netif_schedule(txq->qdisc);
 }
 
@@ -1797,7 +1809,7 @@ static inline void netif_tx_schedule_all(struct net_device *dev)
 
 static inline void netif_tx_start_queue(struct netdev_queue *dev_queue)
 {
-	clear_bit(__QUEUE_STATE_XOFF, &dev_queue->state);
+	clear_bit(__QUEUE_STATE_DRV_XOFF, &dev_queue->state);
 }
 
 /**
@@ -1829,7 +1841,7 @@ static inline void netif_tx_wake_queue(struct netdev_queue *dev_queue)
 		return;
 	}
 #endif
-	if (test_and_clear_bit(__QUEUE_STATE_XOFF, &dev_queue->state))
+	if (test_and_clear_bit(__QUEUE_STATE_DRV_XOFF, &dev_queue->state))
 		__netif_schedule(dev_queue->qdisc);
 }
 
@@ -1861,7 +1873,7 @@ static inline void netif_tx_stop_queue(struct netdev_queue *dev_queue)
 		pr_info("netif_stop_queue() cannot be called before register_netdev()\n");
 		return;
 	}
-	set_bit(__QUEUE_STATE_XOFF, &dev_queue->state);
+	set_bit(__QUEUE_STATE_DRV_XOFF, &dev_queue->state);
 }
 
 /**
@@ -1888,7 +1900,7 @@ static inline void netif_tx_stop_all_queues(struct net_device *dev)
 
 static inline int netif_tx_queue_stopped(const struct netdev_queue *dev_queue)
 {
-	return test_bit(__QUEUE_STATE_XOFF, &dev_queue->state);
+	return test_bit(__QUEUE_STATE_DRV_XOFF, &dev_queue->state);
 }
 
 /**
@@ -1902,9 +1914,16 @@ static inline int netif_queue_stopped(const struct net_device *dev)
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
@@ -1991,7 +2010,7 @@ static inline void netif_wake_subqueue(struct net_device *dev, u16 queue_index)
 	if (netpoll_trap())
 		return;
 #endif
-	if (test_and_clear_bit(__QUEUE_STATE_XOFF, &txq->state))
+	if (test_and_clear_bit(__QUEUE_STATE_DRV_XOFF, &txq->state))
 		__netif_schedule(txq->qdisc);
 }
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 6ba50a1..8ca56c0 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2256,7 +2256,7 @@ gso:
 			return rc;
 		}
 		txq_trans_update(txq);
-		if (unlikely(netif_tx_queue_stopped(txq) && skb->next))
+		if (unlikely(netif_xmit_stopped(txq) && skb->next))
 			return NETDEV_TX_BUSY;
 	} while (skb->next);
 
@@ -2530,7 +2530,7 @@ int dev_queue_xmit(struct sk_buff *skb)
 
 			HARD_TX_LOCK(dev, txq, cpu);
 
-			if (!netif_tx_queue_stopped(txq)) {
+			if (!netif_xmit_stopped(txq)) {
 				__this_cpu_inc(xmit_recursion);
 				rc = dev_hard_start_xmit(skb, dev, txq);
 				__this_cpu_dec(xmit_recursion);
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index cf64c1f..f1667f8 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -76,7 +76,7 @@ static void queue_process(struct work_struct *work)
 
 		local_irq_save(flags);
 		__netif_tx_lock(txq, smp_processor_id());
-		if (netif_tx_queue_frozen_or_stopped(txq) ||
+		if (netif_xmit_frozen_or_stopped(txq) ||
 		    ops->ndo_start_xmit(skb, dev) != NETDEV_TX_OK) {
 			skb_queue_head(&npinfo->txq, skb);
 			__netif_tx_unlock(txq);
@@ -317,7 +317,7 @@ void netpoll_send_skb_on_dev(struct netpoll *np, struct sk_buff *skb,
 		for (tries = jiffies_to_usecs(1)/USEC_PER_POLL;
 		     tries > 0; --tries) {
 			if (__netif_tx_trylock(txq)) {
-				if (!netif_tx_queue_stopped(txq)) {
+				if (!netif_xmit_stopped(txq)) {
 					status = ops->ndo_start_xmit(skb, dev);
 					if (status == NETDEV_TX_OK)
 						txq_trans_update(txq);
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 0001c24..de2f017 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3345,7 +3345,7 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 
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
