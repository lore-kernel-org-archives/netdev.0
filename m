From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 06/10] ftgmac100: Simplify rx pointer handling in the rx path
Date: Thu,  6 Apr 2017 11:02:48 +1000
Message-ID: <20170406010252.29208-7-benh@kernel.crashing.org>
References: <20170406010252.29208-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:37938 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756450AbdDFBDb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 5 Apr 2017 21:03:31 -0400
In-Reply-To: <20170406010252.29208-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We don't handle fragmented RX packets, so the "looping"
helpers to locate the first segment of a packet or to
drop a packet aren't actually helping.

Take them out and simplify ftgmac100_rx_packet() further
as a result.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 92 +++++++++-----------------------
 1 file changed, 24 insertions(+), 68 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 0bfcfdd..95d46db 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -429,34 +429,6 @@ static int ftgmac100_next_rx_pointer(int pointer)
 	return (pointer + 1) & (RX_QUEUE_ENTRIES - 1);
 }
 
-static void ftgmac100_rx_pointer_advance(struct ftgmac100 *priv)
-{
-	priv->rx_pointer = ftgmac100_next_rx_pointer(priv->rx_pointer);
-}
-
-static struct ftgmac100_rxdes *ftgmac100_current_rxdes(struct ftgmac100 *priv)
-{
-	return &priv->descs->rxdes[priv->rx_pointer];
-}
-
-static struct ftgmac100_rxdes *
-ftgmac100_rx_locate_first_segment(struct ftgmac100 *priv)
-{
-	struct ftgmac100_rxdes *rxdes = ftgmac100_current_rxdes(priv);
-
-	while (ftgmac100_rxdes_packet_ready(rxdes)) {
-		if (ftgmac100_rxdes_first_segment(rxdes))
-			return rxdes;
-
-		ftgmac100_rxdes_set_dma_own(priv, rxdes);
-		ftgmac100_rx_pointer_advance(priv);
-		rxdes = ftgmac100_current_rxdes(priv);
-	}
-
-	return NULL;
-}
-
-
 static void ftgmac100_rx_packet_error(struct ftgmac100 *priv,
 				      struct ftgmac100_rxdes *rxdes)
 {
@@ -474,51 +446,32 @@ static void ftgmac100_rx_packet_error(struct ftgmac100 *priv,
 		netdev->stats.rx_length_errors++;
 }
 
-static void ftgmac100_rx_drop_packet(struct ftgmac100 *priv)
-{
-	struct net_device *netdev = priv->netdev;
-	struct ftgmac100_rxdes *rxdes = ftgmac100_current_rxdes(priv);
-	bool done = false;
-
-	if (net_ratelimit())
-		netdev_dbg(netdev, "drop packet %p\n", rxdes);
-
-	do {
-		if (ftgmac100_rxdes_last_segment(rxdes))
-			done = true;
-
-		ftgmac100_rxdes_set_dma_own(priv, rxdes);
-		ftgmac100_rx_pointer_advance(priv);
-		rxdes = ftgmac100_current_rxdes(priv);
-	} while (!done && ftgmac100_rxdes_packet_ready(rxdes));
-
-	netdev->stats.rx_dropped++;
-}
-
 static bool ftgmac100_rx_packet(struct ftgmac100 *priv, int *processed)
 {
 	struct net_device *netdev = priv->netdev;
 	struct ftgmac100_rxdes *rxdes;
 	struct sk_buff *skb;
 	struct page *page;
-	unsigned int size;
+	unsigned int pointer, size;
 	dma_addr_t map;
 
-	rxdes = ftgmac100_rx_locate_first_segment(priv);
-	if (!rxdes)
+	/* Grab next RX descriptor */
+	pointer = priv->rx_pointer;
+	rxdes = &priv->descs->rxdes[pointer];
+
+	/* Do we have a packet ? */
+	if (!ftgmac100_rxdes_packet_ready(rxdes))
 		return false;
 
-	/* We don't support segmented rx frames, so drop these
-	 * along with packets with errors.
-	 */
-	if (unlikely(!ftgmac100_rxdes_last_segment(rxdes))) {
-		ftgmac100_rx_drop_packet(priv);
-		return true;
-	}
+	/* We don't cope with fragmented RX packets */
+	if (unlikely(!ftgmac100_rxdes_first_segment(rxdes) ||
+		     !ftgmac100_rxdes_last_segment(rxdes)))
+		goto drop;
+
+	/* Any error (other than csum offload) flagged ? */
 	if (unlikely(ftgmac100_rxdes_any_error(rxdes))) {
 		ftgmac100_rx_packet_error(priv, rxdes);
-		ftgmac100_rx_drop_packet(priv);
-		return true;
+		goto drop;
 	}
 
 	/* If the packet had no buffer (failed to allocate earlier)
@@ -527,8 +480,7 @@ static bool ftgmac100_rx_packet(struct ftgmac100 *priv, int *processed)
 	page = ftgmac100_rxdes_get_page(priv, rxdes);
 	if (!page) {
 		ftgmac100_alloc_rx_page(priv, rxdes, GFP_ATOMIC);
-		ftgmac100_rx_pointer_advance(priv);
-		return true;
+		goto drop;
 	}
 
 	/* start processing */
@@ -536,9 +488,7 @@ static bool ftgmac100_rx_packet(struct ftgmac100 *priv, int *processed)
 	if (unlikely(!skb)) {
 		if (net_ratelimit())
 			netdev_err(netdev, "rx skb alloc failed\n");
-
-		ftgmac100_rx_drop_packet(priv);
-		return true;
+		goto drop;
 	}
 
 	if (unlikely(ftgmac100_rxdes_multicast(rxdes)))
@@ -575,8 +525,7 @@ static bool ftgmac100_rx_packet(struct ftgmac100 *priv, int *processed)
 
 	ftgmac100_alloc_rx_page(priv, rxdes, GFP_ATOMIC);
 
-	ftgmac100_rx_pointer_advance(priv);
-	rxdes = ftgmac100_current_rxdes(priv);
+	priv->rx_pointer = ftgmac100_next_rx_pointer(pointer);
 
 	/* Small frames are copied into linear part of skb to free one page */
 	if (skb->len <= 128) {
@@ -599,6 +548,13 @@ static bool ftgmac100_rx_packet(struct ftgmac100 *priv, int *processed)
 
 	(*processed)++;
 	return true;
+
+ drop:
+	/* Clean rxdes0 (which resets own bit) */
+	rxdes->rxdes0 &= cpu_to_le32(priv->rxdes0_edorr_mask);
+	priv->rx_pointer = ftgmac100_next_rx_pointer(pointer);
+	netdev->stats.rx_dropped++;
+	return true;
 }
 
 static void ftgmac100_txdes_reset(const struct ftgmac100 *priv,
-- 
2.9.3
