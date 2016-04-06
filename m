From: Petri Gynther <pgynther@google.com>
Subject: [PATCH net-next] net: bcmgenet: add BQL support
Date: Tue,  5 Apr 2016 17:50:01 -0700
Message-ID: <1459903801-83727-1-git-send-email-pgynther@google.com>
Cc: davem@davemloft.net, f.fainelli@gmail.com, opendmb@gmail.com,
	jaedon.shin@gmail.com, Petri Gynther <pgynther@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36406 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759231AbcDFAuP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 20:50:15 -0400
Received: by mail-pa0-f48.google.com with SMTP id bx7so5033150pad.3
        for <netdev@vger.kernel.org>; Tue, 05 Apr 2016 17:50:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add Byte Queue Limits (BQL) support to bcmgenet driver.

Signed-off-by: Petri Gynther <pgynther@google.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 16 +++++++++++++++-
 1 file changed, 15 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index f7b42b9..9fcd514 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1221,8 +1221,10 @@ static unsigned int __bcmgenet_tx_reclaim(struct net_device *dev,
 	dev->stats.tx_packets += pkts_compl;
 	dev->stats.tx_bytes += bytes_compl;
 
+	txq = netdev_get_tx_queue(dev, ring->queue);
+	netdev_tx_completed_queue(txq, pkts_compl, bytes_compl);
+
 	if (ring->free_bds > (MAX_SKB_FRAGS + 1)) {
-		txq = netdev_get_tx_queue(dev, ring->queue);
 		if (netif_tx_queue_stopped(txq))
 			netif_tx_wake_queue(txq);
 	}
@@ -1516,6 +1518,8 @@ static netdev_tx_t bcmgenet_xmit(struct sk_buff *skb, struct net_device *dev)
 	ring->prod_index += nr_frags + 1;
 	ring->prod_index &= DMA_P_INDEX_MASK;
 
+	netdev_tx_sent_queue(txq, GENET_CB(skb)->bytes_sent);
+
 	if (ring->free_bds <= (MAX_SKB_FRAGS + 1))
 		netif_tx_stop_queue(txq);
 
@@ -2809,6 +2813,8 @@ static void bcmgenet_hfb_init(struct bcmgenet_priv *priv)
 static void bcmgenet_netif_start(struct net_device *dev)
 {
 	struct bcmgenet_priv *priv = netdev_priv(dev);
+	int i;
+	struct netdev_queue *txq;
 
 	/* Start the network engine */
 	bcmgenet_enable_rx_napi(priv);
@@ -2816,6 +2822,14 @@ static void bcmgenet_netif_start(struct net_device *dev)
 
 	umac_enable_set(priv, CMD_TX_EN | CMD_RX_EN, true);
 
+	for (i = 0; i < priv->hw_params->tx_queues; i++) {
+		txq = netdev_get_tx_queue(dev, priv->tx_rings[i].queue);
+		netdev_tx_reset_queue(txq);
+	}
+
+	txq = netdev_get_tx_queue(dev, priv->tx_rings[DESC_INDEX].queue);
+	netdev_tx_reset_queue(txq);
+
 	netif_tx_start_all_queues(dev);
 
 	/* Monitor link interrupts now */
-- 
2.8.0.rc3.226.g39d4020
