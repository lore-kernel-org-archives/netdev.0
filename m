From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 02/12] ftgmac100: Move ftgmac100_hard_start_xmit() around
Date: Fri,  7 Apr 2017 13:30:55 +1000
Message-ID: <20170407033105.29558-3-benh@kernel.crashing.org>
References: <20170407033105.29558-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:39167 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753424AbdDGDbs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Apr 2017 23:31:48 -0400
In-Reply-To: <20170407033105.29558-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move it below ftgmac100_xmit() and the rest of the tx path

No code change.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 59 ++++++++++++++++----------------
 1 file changed, 30 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index f4b719214..3966c7a 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -63,6 +63,7 @@ struct ftgmac100 {
 	u32 rxdes0_edorr_mask;
 
 	/* Tx ring */
+	struct sk_buff *tx_skbs[TX_QUEUE_ENTRIES];
 	unsigned int tx_clean_pointer;
 	unsigned int tx_pointer;
 	unsigned int tx_pending;
@@ -673,6 +674,35 @@ static int ftgmac100_xmit(struct ftgmac100 *priv, struct sk_buff *skb,
 	return NETDEV_TX_OK;
 }
 
+static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
+				     struct net_device *netdev)
+{
+	struct ftgmac100 *priv = netdev_priv(netdev);
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
+
+	return ftgmac100_xmit(priv, skb, map);
+}
+
 static void ftgmac100_free_buffers(struct ftgmac100 *priv)
 {
 	int i;
@@ -1210,35 +1240,6 @@ static int ftgmac100_stop(struct net_device *netdev)
 	return 0;
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
 /* optional */
 static int ftgmac100_do_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 {
-- 
2.9.3
