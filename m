From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-2.6] net: Keep TX queues stopped as long as the
 physical device is absent
Date: Mon, 16 May 2011 22:04:51 +0100
Message-ID: <1305579891.2885.44.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:57416 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751868Ab1EPVEy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 17:04:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netif_device_detach() stops all TX queues, but there is nothing to
prevent them from being restarted.  In fact, netif_tx_unlock() may now
do this.  Add another queue state flag that is set while the device is
absent, and make netif_tx_queue_frozen_or_stopped() test it.  Rename the
function to netif_tx_queue_blocked() since it makes little sense to keep
adding flags to its name.

This bug appears to have been present forever, but had little effect
before commit c3f26a269c2421f97f10cf8ed05d5099b573af4d ('netdev: Fix
lockdep warnings in multiqueue configurations.').

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
Cc: stable@kernel.org
---
 include/linux/netdevice.h |   19 +++++++++++++++----
 net/core/dev.c            |   16 ++++++++++++++++
 net/core/netpoll.c        |    2 +-
 net/core/pktgen.c         |    2 +-
 net/sched/sch_generic.c   |    6 +++---
 net/sched/sch_teql.c      |    2 +-
 6 files changed, 37 insertions(+), 10 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 0249fe7..1727723 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -544,8 +544,10 @@ static inline void napi_synchronize(const struct napi_struct *n)
 enum netdev_queue_state_t {
 	__QUEUE_STATE_XOFF,
 	__QUEUE_STATE_FROZEN,
-#define QUEUE_STATE_XOFF_OR_FROZEN ((1 << __QUEUE_STATE_XOFF)		| \
-				    (1 << __QUEUE_STATE_FROZEN))
+	__QUEUE_STATE_ABSENT,
+#define QUEUE_STATE_BLOCKED ((1 << __QUEUE_STATE_XOFF)		| \
+			     (1 << __QUEUE_STATE_FROZEN)	| \
+			     (1 << __QUEUE_STATE_ABSENT))
 };
 
 struct netdev_queue {
@@ -1897,9 +1899,18 @@ static inline int netif_queue_stopped(const struct net_device *dev)
 	return netif_tx_queue_stopped(netdev_get_tx_queue(dev, 0));
 }
 
-static inline int netif_tx_queue_frozen_or_stopped(const struct netdev_queue *dev_queue)
+/**
+ *	netif_tx_queue_blocked - test if TX queue is blocked for any reason
+ *	@dev_queue: Transmit queue
+ *
+ *	Test whether transmit queue is blocked.  This could happen
+ *	because it was explicitly stopped (usually due to a hardware
+ *	queue filling up), because the device transmit state is locked,
+ *	or because the hardware device was detached.
+ */
+static inline int netif_tx_queue_blocked(const struct netdev_queue *dev_queue)
 {
-	return dev_queue->state & QUEUE_STATE_XOFF_OR_FROZEN;
+	return dev_queue->state & QUEUE_STATE_BLOCKED;
 }
 
 /**
diff --git a/net/core/dev.c b/net/core/dev.c
index 9200944..6b1205a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1740,6 +1740,14 @@ EXPORT_SYMBOL(dev_kfree_skb_any);
  */
 void netif_device_detach(struct net_device *dev)
 {
+	struct netdev_queue *txq;
+	unsigned int i;
+
+	for (i = 0; i < dev->num_tx_queues; i++) {
+		txq = netdev_get_tx_queue(dev, i);
+		set_bit(__QUEUE_STATE_ABSENT, &txq->state);
+	}
+
 	if (test_and_clear_bit(__LINK_STATE_PRESENT, &dev->state) &&
 	    netif_running(dev)) {
 		netif_tx_stop_all_queues(dev);
@@ -1755,6 +1763,14 @@ EXPORT_SYMBOL(netif_device_detach);
  */
 void netif_device_attach(struct net_device *dev)
 {
+	struct netdev_queue *txq;
+	unsigned int i;
+
+	for (i = 0; i < dev->num_tx_queues; i++) {
+		txq = netdev_get_tx_queue(dev, i);
+		clear_bit(__QUEUE_STATE_ABSENT, &txq->state);
+	}
+
 	if (!test_and_set_bit(__LINK_STATE_PRESENT, &dev->state) &&
 	    netif_running(dev)) {
 		netif_tx_wake_all_queues(dev);
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 06be243..dac4c2c 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -75,7 +75,7 @@ static void queue_process(struct work_struct *work)
 
 		local_irq_save(flags);
 		__netif_tx_lock(txq, smp_processor_id());
-		if (netif_tx_queue_frozen_or_stopped(txq) ||
+		if (netif_tx_queue_blocked(txq) ||
 		    ops->ndo_start_xmit(skb, dev) != NETDEV_TX_OK) {
 			skb_queue_head(&npinfo->txq, skb);
 			__netif_tx_unlock(txq);
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index aeeece7..8dcf293 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3478,7 +3478,7 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 
 	__netif_tx_lock_bh(txq);
 
-	if (unlikely(netif_tx_queue_frozen_or_stopped(txq))) {
+	if (unlikely(netif_tx_queue_blocked(txq))) {
 		ret = NETDEV_TX_BUSY;
 		pkt_dev->last_ok = 0;
 		goto unlock;
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index c84b659..df6d01b 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -60,7 +60,7 @@ static inline struct sk_buff *dequeue_skb(struct Qdisc *q)
 
 		/* check the reason of requeuing without tx lock first */
 		txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
-		if (!netif_tx_queue_frozen_or_stopped(txq)) {
+		if (!netif_tx_queue_blocked(txq)) {
 			q->gso_skb = NULL;
 			q->q.qlen--;
 		} else
@@ -121,7 +121,7 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
 	spin_unlock(root_lock);
 
 	HARD_TX_LOCK(dev, txq, smp_processor_id());
-	if (!netif_tx_queue_frozen_or_stopped(txq))
+	if (!netif_tx_queue_blocked(txq))
 		ret = dev_hard_start_xmit(skb, dev, txq);
 
 	HARD_TX_UNLOCK(dev, txq);
@@ -143,7 +143,7 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
 		ret = dev_requeue_skb(skb, q);
 	}
 
-	if (ret && netif_tx_queue_frozen_or_stopped(txq))
+	if (ret && netif_tx_queue_blocked(txq))
 		ret = 0;
 
 	return ret;
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index 45cd300..f876462 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -312,7 +312,7 @@ restart:
 			if (__netif_tx_trylock(slave_txq)) {
 				unsigned int length = qdisc_pkt_len(skb);
 
-				if (!netif_tx_queue_frozen_or_stopped(slave_txq) &&
+				if (!netif_tx_queue_blocked(slave_txq) &&
 				    slave_ops->ndo_start_xmit(skb, slave) == NETDEV_TX_OK) {
 					txq_trans_update(slave_txq);
 					__netif_tx_unlock(slave_txq);
-- 
1.7.4


-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

