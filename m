From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: add netif_tx_queue_frozen_or_stopped
Date: Tue, 23 Nov 2010 21:42:02 +0100
Message-ID: <1290544922.2866.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:34034 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752546Ab0KWUmJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Nov 2010 15:42:09 -0500
Received: by wwa36 with SMTP id 36so9107175wwa.1
        for <netdev@vger.kernel.org>; Tue, 23 Nov 2010 12:42:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When testing struct netdev_queue state against FROZEN bit, we also test
XOFF bit. We can test both bits at once and save some cycles.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/netdevice.h |    6 ++++--
 net/core/netpoll.c        |    3 +--
 net/core/pktgen.c         |    2 +-
 net/sched/sch_generic.c   |    8 +++-----
 net/sched/sch_teql.c      |    3 +--
 5 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index b45c1b8..0a03d8a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -493,6 +493,8 @@ static inline void napi_synchronize(const struct napi_struct *n)
 enum netdev_queue_state_t {
 	__QUEUE_STATE_XOFF,
 	__QUEUE_STATE_FROZEN,
+#define QUEUE_STATE_XOFF_OR_FROZEN ((1 << __QUEUE_STATE_XOFF)		| \
+				    (1 << __QUEUE_STATE_FROZEN))
 };
 
 struct netdev_queue {
@@ -1599,9 +1601,9 @@ static inline int netif_queue_stopped(const struct net_device *dev)
 	return netif_tx_queue_stopped(netdev_get_tx_queue(dev, 0));
 }
 
-static inline int netif_tx_queue_frozen(const struct netdev_queue *dev_queue)
+static inline int netif_tx_queue_frozen_or_stopped(const struct netdev_queue *dev_queue)
 {
-	return test_bit(__QUEUE_STATE_FROZEN, &dev_queue->state);
+	return dev_queue->state & QUEUE_STATE_XOFF_OR_FROZEN;
 }
 
 /**
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 4e98ffa..ee38acb 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -76,8 +76,7 @@ static void queue_process(struct work_struct *work)
 
 		local_irq_save(flags);
 		__netif_tx_lock(txq, smp_processor_id());
-		if (netif_tx_queue_stopped(txq) ||
-		    netif_tx_queue_frozen(txq) ||
+		if (netif_tx_queue_frozen_or_stopped(txq) ||
 		    ops->ndo_start_xmit(skb, dev) != NETDEV_TX_OK) {
 			skb_queue_head(&npinfo->txq, skb);
 			__netif_tx_unlock(txq);
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 2e57830..2953b2a 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3527,7 +3527,7 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 
 	__netif_tx_lock_bh(txq);
 
-	if (unlikely(netif_tx_queue_stopped(txq) || netif_tx_queue_frozen(txq))) {
+	if (unlikely(netif_tx_queue_frozen_or_stopped(txq))) {
 		ret = NETDEV_TX_BUSY;
 		pkt_dev->last_ok = 0;
 		goto unlock;
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 5dbb3cd..470e046 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -60,8 +60,7 @@ static inline struct sk_buff *dequeue_skb(struct Qdisc *q)
 
 		/* check the reason of requeuing without tx lock first */
 		txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
-		if (!netif_tx_queue_stopped(txq) &&
-		    !netif_tx_queue_frozen(txq)) {
+		if (!netif_tx_queue_frozen_or_stopped(txq)) {
 			q->gso_skb = NULL;
 			q->q.qlen--;
 		} else
@@ -122,7 +121,7 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
 	spin_unlock(root_lock);
 
 	HARD_TX_LOCK(dev, txq, smp_processor_id());
-	if (!netif_tx_queue_stopped(txq) && !netif_tx_queue_frozen(txq))
+	if (!netif_tx_queue_frozen_or_stopped(txq))
 		ret = dev_hard_start_xmit(skb, dev, txq);
 
 	HARD_TX_UNLOCK(dev, txq);
@@ -144,8 +143,7 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
 		ret = dev_requeue_skb(skb, q);
 	}
 
-	if (ret && (netif_tx_queue_stopped(txq) ||
-		    netif_tx_queue_frozen(txq)))
+	if (ret && netif_tx_queue_frozen_or_stopped(txq))
 		ret = 0;
 
 	return ret;
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index 401af95..106479a 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -309,8 +309,7 @@ restart:
 			if (__netif_tx_trylock(slave_txq)) {
 				unsigned int length = qdisc_pkt_len(skb);
 
-				if (!netif_tx_queue_stopped(slave_txq) &&
-				    !netif_tx_queue_frozen(slave_txq) &&
+				if (!netif_tx_queue_frozen_or_stopped(slave_txq) &&
 				    slave_ops->ndo_start_xmit(skb, slave) == NETDEV_TX_OK) {
 					txq_trans_update(slave_txq);
 					__netif_tx_unlock(slave_txq);


