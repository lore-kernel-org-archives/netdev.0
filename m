From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] net: add skb_get_tx_queue() helper
Date: Tue, 26 Aug 2014 23:06:48 +0200
Message-ID: <1409087208-25809-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26415 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754228AbaHZVGu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2014 17:06:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace occurences of skb_get_queue_mapping() and follow-up
netdev_get_tx_queue() with an actual helper function.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/linux/netdevice.h | 8 ++++++++
 net/core/netpoll.c        | 2 +-
 net/core/pktgen.c         | 4 +---
 net/packet/af_packet.c    | 4 +---
 net/sched/sch_generic.c   | 6 ++++--
 5 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 039b237..200ee4f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1747,6 +1747,14 @@ struct netdev_queue *netdev_get_tx_queue(const struct net_device *dev,
 	return &dev->_tx[index];
 }
 
+static inline struct netdev_queue *skb_get_tx_queue(const struct net_device *dev,
+						    const struct sk_buff *skb)
+{
+	u16 index = skb_get_queue_mapping(skb);
+
+	return netdev_get_tx_queue(dev, index);
+}
+
 static inline void netdev_for_each_tx_queue(struct net_device *dev,
 					    void (*f)(struct net_device *,
 						      struct netdev_queue *,
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index a5ad068..12b1df9 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -115,7 +115,7 @@ static void queue_process(struct work_struct *work)
 			continue;
 		}
 
-		txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
+		txq = skb_get_tx_queue(dev, skb);
 
 		local_irq_save(flags);
 		HARD_TX_LOCK(dev, txq, smp_processor_id());
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 83e2b4b..d81b540 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3286,7 +3286,6 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 {
 	struct net_device *odev = pkt_dev->odev;
 	struct netdev_queue *txq;
-	u16 queue_map;
 	int ret;
 
 	/* If device is offline, then don't send */
@@ -3324,8 +3323,7 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 	if (pkt_dev->delay && pkt_dev->last_ok)
 		spin(pkt_dev, pkt_dev->next_tx);
 
-	queue_map = skb_get_queue_mapping(pkt_dev->skb);
-	txq = netdev_get_tx_queue(odev, queue_map);
+	txq = skb_get_tx_queue(odev, pkt_dev->skb);
 
 	local_bh_disable();
 
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 0dfa990..b7a7f5a 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -243,7 +243,6 @@ static int packet_direct_xmit(struct sk_buff *skb)
 	netdev_features_t features;
 	struct netdev_queue *txq;
 	int ret = NETDEV_TX_BUSY;
-	u16 queue_map;
 
 	if (unlikely(!netif_running(dev) ||
 		     !netif_carrier_ok(dev)))
@@ -254,8 +253,7 @@ static int packet_direct_xmit(struct sk_buff *skb)
 	    __skb_linearize(skb))
 		goto drop;
 
-	queue_map = skb_get_queue_mapping(skb);
-	txq = netdev_get_tx_queue(dev, queue_map);
+	txq = skb_get_tx_queue(dev, skb);
 
 	local_bh_disable();
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index fc04fe9..05b3f5d 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -63,7 +63,7 @@ static inline struct sk_buff *dequeue_skb(struct Qdisc *q)
 
 	if (unlikely(skb)) {
 		/* check the reason of requeuing without tx lock first */
-		txq = netdev_get_tx_queue(txq->dev, skb_get_queue_mapping(skb));
+		txq = skb_get_tx_queue(txq->dev, skb);
 		if (!netif_xmit_frozen_or_stopped(txq)) {
 			q->gso_skb = NULL;
 			q->q.qlen--;
@@ -183,10 +183,12 @@ static inline int qdisc_restart(struct Qdisc *q)
 	skb = dequeue_skb(q);
 	if (unlikely(!skb))
 		return 0;
+
 	WARN_ON_ONCE(skb_dst_is_noref(skb));
+
 	root_lock = qdisc_lock(q);
 	dev = qdisc_dev(q);
-	txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
+	txq = skb_get_tx_queue(dev, skb);
 
 	return sch_direct_xmit(skb, q, dev, txq, root_lock);
 }
-- 
1.7.11.7
