From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH net-next 1/2] cxgb3: move away from LLTX
Date: Fri, 29 May 2009 00:58:24 -0700
Message-ID: <20090529075823.30669.28885.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:18219 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753862AbZE2H6Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 03:58:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

cxgb3 no longer advertizes LLTX.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/cxgb3_main.c |    1 -
 drivers/net/cxgb3/sge.c        |   18 +++++++-----------
 2 files changed, 7 insertions(+), 12 deletions(-)


diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 0b87fee..1fe4b07 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -3059,7 +3059,6 @@ static int __devinit init_one(struct pci_dev *pdev,
 		netdev->mem_start = mmio_start;
 		netdev->mem_end = mmio_start + mmio_len - 1;
 		netdev->features |= NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO;
-		netdev->features |= NETIF_F_LLTX;
 		netdev->features |= NETIF_F_GRO;
 		if (pci_using_dac)
 			netdev->features |= NETIF_F_HIGHDMA;
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index 73d569e..0b97882 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -1241,7 +1241,6 @@ int t3_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 	q = &qs->txq[TXQ_ETH];
 	txq = netdev_get_tx_queue(dev, qidx);
 
-	spin_lock(&q->lock);
 	reclaim_completed_tx(adap, q, TX_RECLAIM_CHUNK);
 
 	credits = q->size - q->in_use;
@@ -1252,7 +1251,6 @@ int t3_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 		dev_err(&adap->pdev->dev,
 			"%s: Tx ring %u full while queue awake!\n",
 			dev->name, q->cntxt_id & 7);
-		spin_unlock(&q->lock);
 		return NETDEV_TX_BUSY;
 	}
 
@@ -1286,9 +1284,6 @@ int t3_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (vlan_tx_tag_present(skb) && pi->vlan_grp)
 		qs->port_stats[SGE_PSTAT_VLANINS]++;
 
-	dev->trans_start = jiffies;
-	spin_unlock(&q->lock);
-
 	/*
 	 * We do not use Tx completion interrupts to free DMAd Tx packets.
 	 * This is good for performamce but means that we rely on new Tx
@@ -2858,11 +2853,12 @@ static void sge_timer_tx(unsigned long data)
 	unsigned int tbd[SGE_TXQ_PER_SET] = {0, 0};
 	unsigned long next_period;
 
-	if (spin_trylock(&qs->txq[TXQ_ETH].lock)) {
-		tbd[TXQ_ETH] = reclaim_completed_tx(adap, &qs->txq[TXQ_ETH],
-						    TX_RECLAIM_TIMER_CHUNK);
-		spin_unlock(&qs->txq[TXQ_ETH].lock);
+	if (__netif_tx_trylock(qs->tx_q)) {
+                tbd[TXQ_ETH] = reclaim_completed_tx(adap, &qs->txq[TXQ_ETH],
+                                                     TX_RECLAIM_TIMER_CHUNK);
+		__netif_tx_unlock(qs->tx_q);
 	}
+
 	if (spin_trylock(&qs->txq[TXQ_OFLD].lock)) {
 		tbd[TXQ_OFLD] = reclaim_completed_tx(adap, &qs->txq[TXQ_OFLD],
 						     TX_RECLAIM_TIMER_CHUNK);
@@ -2870,8 +2866,8 @@ static void sge_timer_tx(unsigned long data)
 	}
 
 	next_period = TX_RECLAIM_PERIOD >>
-		      (max(tbd[TXQ_ETH], tbd[TXQ_OFLD]) /
-		       TX_RECLAIM_TIMER_CHUNK);
+                      (max(tbd[TXQ_ETH], tbd[TXQ_OFLD]) /
+                      TX_RECLAIM_TIMER_CHUNK);
 	mod_timer(&qs->tx_reclaim_timer, jiffies + next_period);
 }
 

