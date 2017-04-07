From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 03/12] ftgmac100: Merge ftgmac100_xmit() into ftgmac100_hard_start_xmit()
Date: Fri,  7 Apr 2017 13:30:56 +1000
Message-ID: <20170407033105.29558-4-benh@kernel.crashing.org>
References: <20170407033105.29558-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:39164 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753945AbdDGDby (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Apr 2017 23:31:54 -0400
In-Reply-To: <20170407033105.29558-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This will make subsequent rework of the tx path simpler

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 58 ++++++++++++++------------------
 1 file changed, 25 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 3966c7a..6fa070a 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -628,12 +628,33 @@ static void ftgmac100_tx_complete(struct ftgmac100 *priv)
 		;
 }
 
-static int ftgmac100_xmit(struct ftgmac100 *priv, struct sk_buff *skb,
-			  dma_addr_t map)
+static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
+				     struct net_device *netdev)
 {
-	struct net_device *netdev = priv->netdev;
-	struct ftgmac100_txdes *txdes;
 	unsigned int len = (skb->len < ETH_ZLEN) ? ETH_ZLEN : skb->len;
+	struct ftgmac100 *priv = netdev_priv(netdev);
+	struct ftgmac100_txdes *txdes;
+	dma_addr_t map;
+
+	if (unlikely(skb->len > MAX_PKT_SIZE)) {
+		if (net_ratelimit())
+			netdev_dbg(netdev, "tx packet too big\n");
+
+		netdev->stats.tx_dropped++;
+		kfree_skb(skb);
+		return NETDEV_TX_OK;
+	}
+
+	map = dma_map_single(priv->dev, skb->data, skb_headlen(skb), DMA_TO_DEVICE);
+	if (unlikely(dma_mapping_error(priv->dev, map))) {
+		/* drop packet */
+		if (net_ratelimit())
+			netdev_err(netdev, "map socket buffer failed\n");
+
+		netdev->stats.tx_dropped++;
+		kfree_skb(skb);
+		return NETDEV_TX_OK;
+	}
 
 	txdes = ftgmac100_current_txdes(priv);
 	ftgmac100_tx_pointer_advance(priv);
@@ -674,35 +695,6 @@ static int ftgmac100_xmit(struct ftgmac100 *priv, struct sk_buff *skb,
 	return NETDEV_TX_OK;
 }
 
-static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
-				     struct net_device *netdev)
-{
-	struct ftgmac100 *priv = netdev_priv(netdev);
-	dma_addr_t map;
-
-	if (unlikely(skb->len > MAX_PKT_SIZE)) {
-		if (net_ratelimit())
-			netdev_dbg(netdev, "tx packet too big\n");
-
-		netdev->stats.tx_dropped++;
-		kfree_skb(skb);
-		return NETDEV_TX_OK;
-	}
-
-	map = dma_map_single(priv->dev, skb->data, skb_headlen(skb), DMA_TO_DEVICE);
-	if (unlikely(dma_mapping_error(priv->dev, map))) {
-		/* drop packet */
-		if (net_ratelimit())
-			netdev_err(netdev, "map socket buffer failed\n");
-
-		netdev->stats.tx_dropped++;
-		kfree_skb(skb);
-		return NETDEV_TX_OK;
-	}
-
-	return ftgmac100_xmit(priv, skb, map);
-}
-
 static void ftgmac100_free_buffers(struct ftgmac100 *priv)
 {
 	int i;
-- 
2.9.3
