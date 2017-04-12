From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH v2 07/10] ftgmac100: Open code remaining register writes
Date: Wed, 12 Apr 2017 13:27:07 +1000
Message-ID: <20170412032710.17546-8-benh@kernel.crashing.org>
References: <20170412032710.17546-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:41869 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752741AbdDLD1t (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Apr 2017 23:27:49 -0400
In-Reply-To: <20170412032710.17546-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The helpers just take space but don't provide much value. Simple
one line comments are more explanatory.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 53 ++++++++++++--------------------
 1 file changed, 20 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 35c54e8..c679a09 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -93,29 +93,6 @@ struct ftgmac100 {
 	bool is_aspeed;
 };
 
-static void ftgmac100_set_rx_ring_base(struct ftgmac100 *priv, dma_addr_t addr)
-{
-	iowrite32(addr, priv->base + FTGMAC100_OFFSET_RXR_BADR);
-}
-
-static void ftgmac100_set_rx_buffer_size(struct ftgmac100 *priv,
-		unsigned int size)
-{
-	size = FTGMAC100_RBSR_SIZE(size);
-	iowrite32(size, priv->base + FTGMAC100_OFFSET_RBSR);
-}
-
-static void ftgmac100_set_normal_prio_tx_ring_base(struct ftgmac100 *priv,
-						   dma_addr_t addr)
-{
-	iowrite32(addr, priv->base + FTGMAC100_OFFSET_NPTXR_BADR);
-}
-
-static void ftgmac100_txdma_normal_prio_start_polling(struct ftgmac100 *priv)
-{
-	iowrite32(1, priv->base + FTGMAC100_OFFSET_NPTXPD);
-}
-
 static int ftgmac100_reset_mac(struct ftgmac100 *priv, u32 maccr)
 {
 	struct net_device *netdev = priv->netdev;
@@ -233,18 +210,27 @@ static int ftgmac100_set_mac_addr(struct net_device *dev, void *p)
 
 static void ftgmac100_init_hw(struct ftgmac100 *priv)
 {
-	/* setup ring buffer base registers */
-	ftgmac100_set_rx_ring_base(priv,
-				   priv->descs_dma_addr +
-				   offsetof(struct ftgmac100_descs, rxdes));
-	ftgmac100_set_normal_prio_tx_ring_base(priv,
-					       priv->descs_dma_addr +
-					       offsetof(struct ftgmac100_descs, txdes));
 
-	ftgmac100_set_rx_buffer_size(priv, RX_BUF_SIZE);
 
-	iowrite32(FTGMAC100_APTC_RXPOLL_CNT(1), priv->base + FTGMAC100_OFFSET_APTC);
+	/* Setup RX ring buffer base */
+	iowrite32(priv->descs_dma_addr +
+		  offsetof(struct ftgmac100_descs, rxdes),
+		  priv->base + FTGMAC100_OFFSET_RXR_BADR);
 
+	/* Setup TX ring buffer base */
+	iowrite32(priv->descs_dma_addr +
+		  offsetof(struct ftgmac100_descs, txdes),
+		  priv->base + FTGMAC100_OFFSET_NPTXR_BADR);
+
+	/* Configure RX buffer size */
+	iowrite32(FTGMAC100_RBSR_SIZE(RX_BUF_SIZE),
+		  priv->base + FTGMAC100_OFFSET_RBSR);
+
+	/* Set RX descriptor autopoll */
+	iowrite32(FTGMAC100_APTC_RXPOLL_CNT(1),
+		  priv->base + FTGMAC100_OFFSET_APTC);
+
+	/* Write MAC address */
 	ftgmac100_write_mac_addr(priv, priv->netdev->dev_addr);
 }
 
@@ -704,7 +690,8 @@ static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
 			netif_wake_queue(netdev);
 	}
 
-	ftgmac100_txdma_normal_prio_start_polling(priv);
+	/* Poke transmitter to read the updated TX descriptors */
+	iowrite32(1, priv->base + FTGMAC100_OFFSET_NPTXPD);
 
 	return NETDEV_TX_OK;
 
-- 
2.9.3
