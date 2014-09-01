From: David Miller <davem@davemloft.net>
Subject: [PATCH 4/9] net: Pass a "more" indication down into
 netdev_start_xmit() code paths.
Date: Mon, 01 Sep 2014 15:24:54 -0700 (PDT)
Message-ID: <20140901.152454.408917069371597628.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44734 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752529AbaIAWYz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 18:24:55 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id CD57B590970
	for <netdev@vger.kernel.org>; Mon,  1 Sep 2014 15:24:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


For now it will always be false.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/wan/dlci.c    | 2 +-
 include/linux/netdevice.h | 9 +++++----
 net/atm/mpc.c             | 2 +-
 net/core/dev.c            | 2 +-
 net/core/netpoll.c        | 2 +-
 net/core/pktgen.c         | 2 +-
 net/packet/af_packet.c    | 2 +-
 net/sched/sch_teql.c      | 3 ++-
 8 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/drivers/net/wan/dlci.c b/drivers/net/wan/dlci.c
index 6427e82..ae6ecf4 100644
--- a/drivers/net/wan/dlci.c
+++ b/drivers/net/wan/dlci.c
@@ -194,7 +194,7 @@ static netdev_tx_t dlci_transmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (skb) {
 		struct netdev_queue *txq = skb_get_tx_queue(dev, skb);
-		netdev_start_xmit(skb, dlp->slave, txq);
+		netdev_start_xmit(skb, dlp->slave, txq, false);
 	}
 	return NETDEV_TX_OK;
 }
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 1617180..5050218 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3431,19 +3431,20 @@ int __init dev_proc_init(void);
 #endif
 
 static inline netdev_tx_t __netdev_start_xmit(const struct net_device_ops *ops,
-					      struct sk_buff *skb, struct net_device *dev)
+					      struct sk_buff *skb, struct net_device *dev,
+					      bool more)
 {
-	skb->xmit_more = 0;
+	skb->xmit_more = more ? 1 : 0;
 	return ops->ndo_start_xmit(skb, dev);
 }
 
 static inline netdev_tx_t netdev_start_xmit(struct sk_buff *skb, struct net_device *dev,
-					    struct netdev_queue *txq)
+					    struct netdev_queue *txq, bool more)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
 	int rc;
 
-	rc = __netdev_start_xmit(ops, skb, dev);
+	rc = __netdev_start_xmit(ops, skb, dev, more);
 	if (rc == NETDEV_TX_OK)
 		txq_trans_update(txq);
 
diff --git a/net/atm/mpc.c b/net/atm/mpc.c
index d662da1..0e98222 100644
--- a/net/atm/mpc.c
+++ b/net/atm/mpc.c
@@ -599,7 +599,7 @@ static netdev_tx_t mpc_send_packet(struct sk_buff *skb,
 	}
 
 non_ip:
-	return __netdev_start_xmit(mpc->old_ops, skb, dev);
+	return __netdev_start_xmit(mpc->old_ops, skb, dev, false);
 }
 
 static int atm_mpoa_vcc_attach(struct atm_vcc *vcc, void __user *arg)
diff --git a/net/core/dev.c b/net/core/dev.c
index ab7bb80..f0ed5a6 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2610,7 +2610,7 @@ static int xmit_one(struct sk_buff *skb, struct net_device *dev,
 
 	len = skb->len;
 	trace_net_dev_start_xmit(skb, dev);
-	rc = netdev_start_xmit(skb, dev, txq);
+	rc = netdev_start_xmit(skb, dev, txq, false);
 	trace_net_dev_xmit(skb, rc, dev, len);
 
 	return rc;
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 05bc57e..e6645b4 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -91,7 +91,7 @@ static int netpoll_start_xmit(struct sk_buff *skb, struct net_device *dev,
 		skb->vlan_tci = 0;
 	}
 
-	status = netdev_start_xmit(skb, dev, txq);
+	status = netdev_start_xmit(skb, dev, txq, false);
 
 out:
 	return status;
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 34bd2ff..5b36a94 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3335,7 +3335,7 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 		goto unlock;
 	}
 	atomic_inc(&(pkt_dev->skb->users));
-	ret = netdev_start_xmit(pkt_dev->skb, odev, txq);
+	ret = netdev_start_xmit(pkt_dev->skb, odev, txq, false);
 
 	switch (ret) {
 	case NETDEV_TX_OK:
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index fe305a0..87d20f4 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -259,7 +259,7 @@ static int packet_direct_xmit(struct sk_buff *skb)
 
 	HARD_TX_LOCK(dev, txq, smp_processor_id());
 	if (!netif_xmit_frozen_or_drv_stopped(txq))
-		ret = netdev_start_xmit(skb, dev, txq);
+		ret = netdev_start_xmit(skb, dev, txq, false);
 	HARD_TX_UNLOCK(dev, txq);
 
 	local_bh_enable();
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index 193dc2c..aaa8d03 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -316,7 +316,8 @@ restart:
 				unsigned int length = qdisc_pkt_len(skb);
 
 				if (!netif_xmit_frozen_or_stopped(slave_txq) &&
-				    netdev_start_xmit(skb, slave, slave_txq) == NETDEV_TX_OK) {
+				    netdev_start_xmit(skb, slave, slave_txq, false) ==
+				    NETDEV_TX_OK) {
 					__netif_tx_unlock(slave_txq);
 					master->slaves = NEXT_SLAVE(q);
 					netif_wake_queue(dev);
-- 
1.7.11.7
