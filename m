From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 02/10] ftgmac100: Drop support for fragmented receive
Date: Thu,  6 Apr 2017 11:02:44 +1000
Message-ID: <20170406010252.29208-3-benh@kernel.crashing.org>
References: <20170406010252.29208-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:37912 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756375AbdDFBDO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 5 Apr 2017 21:03:14 -0400
In-Reply-To: <20170406010252.29208-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We don't support jumbo frames, we will never receive a
fragmented packet, the RX buffer is always big enough,
if not then it's a runaway packet that can be dropped.

So take out the loop that handles such things in
ftgmac100_rx_packet() which will help with subsequent
simplifications and improvements to the RX path

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 37 ++++++++++++++++----------------
 1 file changed, 18 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index c77a65b..ee73a57 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -532,13 +532,19 @@ static bool ftgmac100_rx_packet(struct ftgmac100 *priv, int *processed)
 	struct net_device *netdev = priv->netdev;
 	struct ftgmac100_rxdes *rxdes;
 	struct sk_buff *skb;
-	bool done = false;
+	struct page *page;
+	unsigned int size;
+	dma_addr_t map;
 
 	rxdes = ftgmac100_rx_locate_first_segment(priv);
 	if (!rxdes)
 		return false;
 
-	if (unlikely(ftgmac100_rx_packet_error(priv, rxdes))) {
+	/* We don't support segmented rx frames, so drop these
+	 * along with packets with errors.
+	 */
+	if (unlikely(!ftgmac100_rxdes_last_segment(rxdes) ||
+		     ftgmac100_rx_packet_error(priv, rxdes))) {
 		ftgmac100_rx_drop_packet(priv);
 		return true;
 	}
@@ -565,28 +571,21 @@ static bool ftgmac100_rx_packet(struct ftgmac100 *priv, int *processed)
 	    (ftgmac100_rxdes_is_udp(rxdes) && !ftgmac100_rxdes_udpcs_err(rxdes)))
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 
-	do {
-		dma_addr_t map = ftgmac100_rxdes_get_dma_addr(rxdes);
-		struct page *page = ftgmac100_rxdes_get_page(priv, rxdes);
-		unsigned int size;
+	map = ftgmac100_rxdes_get_dma_addr(rxdes);
 
-		dma_unmap_page(priv->dev, map, RX_BUF_SIZE, DMA_FROM_DEVICE);
-
-		size = ftgmac100_rxdes_data_length(rxdes);
-		skb_fill_page_desc(skb, skb_shinfo(skb)->nr_frags, page, 0, size);
+	dma_unmap_page(priv->dev, map, RX_BUF_SIZE, DMA_FROM_DEVICE);
 
-		skb->len += size;
-		skb->data_len += size;
-		skb->truesize += PAGE_SIZE;
+	size = ftgmac100_rxdes_data_length(rxdes);
+	skb_fill_page_desc(skb, skb_shinfo(skb)->nr_frags, page, 0, size);
 
-		if (ftgmac100_rxdes_last_segment(rxdes))
-			done = true;
+	skb->len += size;
+	skb->data_len += size;
+	skb->truesize += PAGE_SIZE;
 
-		ftgmac100_alloc_rx_page(priv, rxdes, GFP_ATOMIC);
+	ftgmac100_alloc_rx_page(priv, rxdes, GFP_ATOMIC);
 
-		ftgmac100_rx_pointer_advance(priv);
-		rxdes = ftgmac100_current_rxdes(priv);
-	} while (!done);
+	ftgmac100_rx_pointer_advance(priv);
+	rxdes = ftgmac100_current_rxdes(priv);
 
 	/* Small frames are copied into linear part of skb to free one page */
 	if (skb->len <= 128) {
-- 
2.9.3
