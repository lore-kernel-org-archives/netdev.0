From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/9] net: Do txq_trans_update() in netdev_start_xmit()
Date: Mon, 01 Sep 2014 15:24:38 -0700 (PDT)
Message-ID: <20140901.152438.1000592701792724604.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44720 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752529AbaIAWYj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 18:24:39 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id CC33958FF2F
	for <netdev@vger.kernel.org>; Mon,  1 Sep 2014 15:24:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


That way we don't have to audit every call site to make sure it is
doing this properly.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/wan/dlci.c    |  6 ++++--
 include/linux/netdevice.h | 10 ++++++++--
 net/core/dev.c            |  7 ++-----
 net/core/netpoll.c        |  4 +---
 net/core/pktgen.c         |  3 +--
 net/packet/af_packet.c    |  7 ++-----
 net/sched/sch_teql.c      |  3 +--
 7 files changed, 19 insertions(+), 21 deletions(-)

diff --git a/drivers/net/wan/dlci.c b/drivers/net/wan/dlci.c
index 81b22a1..6427e82 100644
--- a/drivers/net/wan/dlci.c
+++ b/drivers/net/wan/dlci.c
@@ -192,8 +192,10 @@ static netdev_tx_t dlci_transmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct dlci_local *dlp = netdev_priv(dev);
 
-	if (skb)
-		netdev_start_xmit(skb, dlp->slave);
+	if (skb) {
+		struct netdev_queue *txq = skb_get_tx_queue(dev, skb);
+		netdev_start_xmit(skb, dlp->slave, txq);
+	}
 	return NETDEV_TX_OK;
 }
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 456eb1f..1617180 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3437,11 +3437,17 @@ static inline netdev_tx_t __netdev_start_xmit(const struct net_device_ops *ops,
 	return ops->ndo_start_xmit(skb, dev);
 }
 
-static inline netdev_tx_t netdev_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static inline netdev_tx_t netdev_start_xmit(struct sk_buff *skb, struct net_device *dev,
+					    struct netdev_queue *txq)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
+	int rc;
 
-	return __netdev_start_xmit(ops, skb, dev);
+	rc = __netdev_start_xmit(ops, skb, dev);
+	if (rc == NETDEV_TX_OK)
+		txq_trans_update(txq);
+
+	return rc;
 }
 
 int netdev_class_create_file_ns(struct class_attribute *class_attr,
diff --git a/net/core/dev.c b/net/core/dev.c
index a6077ef..6392ada 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2666,10 +2666,8 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 
 		skb_len = skb->len;
 		trace_net_dev_start_xmit(skb, dev);
-		rc = netdev_start_xmit(skb, dev);
+		rc = netdev_start_xmit(skb, dev, txq);
 		trace_net_dev_xmit(skb, rc, dev, skb_len);
-		if (rc == NETDEV_TX_OK)
-			txq_trans_update(txq);
 		return rc;
 	}
 
@@ -2685,7 +2683,7 @@ gso:
 
 		skb_len = nskb->len;
 		trace_net_dev_start_xmit(nskb, dev);
-		rc = netdev_start_xmit(nskb, dev);
+		rc = netdev_start_xmit(nskb, dev, txq);
 		trace_net_dev_xmit(nskb, rc, dev, skb_len);
 		if (unlikely(rc != NETDEV_TX_OK)) {
 			if (rc & ~NETDEV_TX_MASK)
@@ -2694,7 +2692,6 @@ gso:
 			skb->next = nskb;
 			return rc;
 		}
-		txq_trans_update(txq);
 		if (unlikely(netif_xmit_stopped(txq) && skb->next))
 			return NETDEV_TX_BUSY;
 	} while (skb->next);
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 12b1df9..05bc57e 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -91,9 +91,7 @@ static int netpoll_start_xmit(struct sk_buff *skb, struct net_device *dev,
 		skb->vlan_tci = 0;
 	}
 
-	status = netdev_start_xmit(skb, dev);
-	if (status == NETDEV_TX_OK)
-		txq_trans_update(txq);
+	status = netdev_start_xmit(skb, dev, txq);
 
 out:
 	return status;
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index d81b540..34bd2ff 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3335,11 +3335,10 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 		goto unlock;
 	}
 	atomic_inc(&(pkt_dev->skb->users));
-	ret = netdev_start_xmit(pkt_dev->skb, odev);
+	ret = netdev_start_xmit(pkt_dev->skb, odev, txq);
 
 	switch (ret) {
 	case NETDEV_TX_OK:
-		txq_trans_update(txq);
 		pkt_dev->last_ok = 1;
 		pkt_dev->sofar++;
 		pkt_dev->seq_num++;
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index b7a7f5a..fe305a0 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -258,11 +258,8 @@ static int packet_direct_xmit(struct sk_buff *skb)
 	local_bh_disable();
 
 	HARD_TX_LOCK(dev, txq, smp_processor_id());
-	if (!netif_xmit_frozen_or_drv_stopped(txq)) {
-		ret = netdev_start_xmit(skb, dev);
-		if (ret == NETDEV_TX_OK)
-			txq_trans_update(txq);
-	}
+	if (!netif_xmit_frozen_or_drv_stopped(txq))
+		ret = netdev_start_xmit(skb, dev, txq);
 	HARD_TX_UNLOCK(dev, txq);
 
 	local_bh_enable();
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index 64cd93c..193dc2c 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -316,8 +316,7 @@ restart:
 				unsigned int length = qdisc_pkt_len(skb);
 
 				if (!netif_xmit_frozen_or_stopped(slave_txq) &&
-				    netdev_start_xmit(skb, slave) == NETDEV_TX_OK) {
-					txq_trans_update(slave_txq);
+				    netdev_start_xmit(skb, slave, slave_txq) == NETDEV_TX_OK) {
 					__netif_tx_unlock(slave_txq);
 					master->slaves = NEXT_SLAVE(q);
 					netif_wake_queue(dev);
-- 
1.7.11.7
