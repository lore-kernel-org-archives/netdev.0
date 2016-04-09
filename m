From: Petri Gynther <pgynther@google.com>
Subject: [PATCH net-next v2] net: bcmgenet: add BQL support
Date: Sat,  9 Apr 2016 00:20:36 -0700
Message-ID: <1460186436-84848-1-git-send-email-pgynther@google.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, f.fainelli@gmail.com,
	opendmb@gmail.com, jaedon.shin@gmail.com,
	Petri Gynther <pgynther@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:36848 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751774AbcDIHUt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Apr 2016 03:20:49 -0400
Received: by mail-pf0-f177.google.com with SMTP id e128so89395999pfe.3
        for <netdev@vger.kernel.org>; Sat, 09 Apr 2016 00:20:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add Byte Queue Limits (BQL) support to bcmgenet driver.

Signed-off-by: Petri Gynther <pgynther@google.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index f7b42b9..c286ae8 100644
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
 
@@ -2364,6 +2368,7 @@ static int bcmgenet_dma_teardown(struct bcmgenet_priv *priv)
 static void bcmgenet_fini_dma(struct bcmgenet_priv *priv)
 {
 	int i;
+	struct netdev_queue *txq;
 
 	bcmgenet_fini_rx_napi(priv);
 	bcmgenet_fini_tx_napi(priv);
@@ -2378,6 +2383,14 @@ static void bcmgenet_fini_dma(struct bcmgenet_priv *priv)
 		}
 	}
 
+	for (i = 0; i < priv->hw_params->tx_queues; i++) {
+		txq = netdev_get_tx_queue(priv->dev, priv->tx_rings[i].queue);
+		netdev_tx_reset_queue(txq);
+	}
+
+	txq = netdev_get_tx_queue(priv->dev, priv->tx_rings[DESC_INDEX].queue);
+	netdev_tx_reset_queue(txq);
+
 	bcmgenet_free_rx_buffers(priv);
 	kfree(priv->rx_cbs);
 	kfree(priv->tx_cbs);
-- 
2.8.0.rc3.226.g39d4020
