From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 11/12] ftgmac100: Add support for fragmented tx
Date: Fri,  7 Apr 2017 13:31:04 +1000
Message-ID: <20170407033105.29558-12-benh@kernel.crashing.org>
References: <20170407033105.29558-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:39161 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753736AbdDGDbn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Apr 2017 23:31:43 -0400
In-Reply-To: <20170407033105.29558-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add NETIF_F_SG and create multiple TX ring entries for skb fragments.

On reclaim, the skb is only freed on the segment marked as "last".

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>

# Conflicts:
#	drivers/net/ethernet/faraday/ftgmac100.c
---
 drivers/net/ethernet/faraday/ftgmac100.c | 121 +++++++++++++++++++++++++------
 1 file changed, 97 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index a68a7c4..1496141 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -45,7 +45,7 @@
 #define RX_BUF_SIZE		MAX_PKT_SIZE	/* must be smaller than 0x3fff */
 
 /* Min number of tx ring entries before stopping queue */
-#define TX_THRESHOLD		(1)
+#define TX_THRESHOLD		(MAX_SKB_FRAGS + 1)
 
 struct ftgmac100_descs {
 	struct ftgmac100_rxdes rxdes[RX_QUEUE_ENTRIES];
@@ -487,20 +487,30 @@ static void ftgmac100_txdes_set_first_segment(struct ftgmac100_txdes *txdes)
 	txdes->txdes0 |= cpu_to_le32(FTGMAC100_TXDES0_FTS);
 }
 
+static inline bool ftgmac100_txdes_get_first_segment(struct ftgmac100_txdes *txdes)
+{
+	return (txdes->txdes0 & cpu_to_le32(FTGMAC100_TXDES0_FTS)) != 0;
+}
+
 static void ftgmac100_txdes_set_last_segment(struct ftgmac100_txdes *txdes)
 {
 	txdes->txdes0 |= cpu_to_le32(FTGMAC100_TXDES0_LTS);
 }
 
+static inline bool ftgmac100_txdes_get_last_segment(struct ftgmac100_txdes *txdes)
+{
+	return (txdes->txdes0 & cpu_to_le32(FTGMAC100_TXDES0_LTS)) != 0;
+}
+
 static void ftgmac100_txdes_set_buffer_size(struct ftgmac100_txdes *txdes,
 					    unsigned int len)
 {
 	txdes->txdes0 |= cpu_to_le32(FTGMAC100_TXDES0_TXBUF_SIZE(len));
 }
 
-static void ftgmac100_txdes_set_txint(struct ftgmac100_txdes *txdes)
+static inline unsigned int ftgmac100_txdes_get_buffer_size(struct ftgmac100_txdes *txdes)
 {
-	txdes->txdes1 |= cpu_to_le32(FTGMAC100_TXDES1_TXIC);
+	return FTGMAC100_TXDES0_TXBUF_SIZE(cpu_to_le32(txdes->txdes0));
 }
 
 static void ftgmac100_txdes_set_tcpcs(struct ftgmac100_txdes *txdes)
@@ -526,7 +536,7 @@ static void ftgmac100_txdes_set_dma_addr(struct ftgmac100_txdes *txdes,
 
 static dma_addr_t ftgmac100_txdes_get_dma_addr(struct ftgmac100_txdes *txdes)
 {
-	return le32_to_cpu(txdes->txdes3);
+	return (dma_addr_t)le32_to_cpu(txdes->txdes3);
 }
 
 static int ftgmac100_next_tx_pointer(int pointer)
@@ -556,13 +566,22 @@ static void ftgmac100_free_tx_packet(struct ftgmac100 *priv,
 				     struct sk_buff *skb,
 				     struct ftgmac100_txdes *txdes)
 {
-	dma_addr_t map;
+	dma_addr_t map = ftgmac100_txdes_get_dma_addr(txdes);
 
-	map = ftgmac100_txdes_get_dma_addr(txdes);
+	if (ftgmac100_txdes_get_first_segment(txdes)) {
+		size_t len = skb_headlen(skb);
 
-	dma_unmap_single(priv->dev, map, skb_headlen(skb), DMA_TO_DEVICE);
+		if (skb_shinfo(skb)->nr_frags == 0 && len < ETH_ZLEN)
+			len = ETH_ZLEN;
+		dma_unmap_single(priv->dev, map, len, DMA_TO_DEVICE);
+	} else {
+		dma_unmap_page(priv->dev, map,
+			       ftgmac100_txdes_get_buffer_size(txdes),
+			       DMA_TO_DEVICE);
+	}
 
-	dev_kfree_skb(skb);
+	if (ftgmac100_txdes_get_last_segment(txdes))
+		dev_kfree_skb(skb);
 	priv->tx_skbs[pointer] = NULL;
 
 	/* Clear txdes0 except end of ring bit, clear txdes1 as we
@@ -623,10 +642,9 @@ static void ftgmac100_tx_complete(struct ftgmac100 *priv)
 static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
 				     struct net_device *netdev)
 {
-	unsigned int len = (skb->len < ETH_ZLEN) ? ETH_ZLEN : skb->len;
 	struct ftgmac100 *priv = netdev_priv(netdev);
-	struct ftgmac100_txdes *txdes;
-	unsigned int pointer;
+	struct ftgmac100_txdes *txdes, *first;
+	unsigned int pointer, nfrags, len, i, j;
 	dma_addr_t map;
 
 	/* The HW doesn't pad small frames */
@@ -642,26 +660,35 @@ static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
 		goto drop;
 	}
 
-	map = dma_map_single(priv->dev, skb->data, skb_headlen(skb), DMA_TO_DEVICE);
-	if (unlikely(dma_mapping_error(priv->dev, map))) {
-		/* drop packet */
+	/* Do we have a limit on #fragments ? I yet have to get a reply
+	 * from Aspeed. If there's one I haven't hit it.
+	 */
+	nfrags = skb_shinfo(skb)->nr_frags;
+
+	/* Get header len and pad for non-fragmented packets */
+	len = skb_headlen(skb);
+	if (nfrags == 0 && len < ETH_ZLEN)
+		len = ETH_ZLEN;
+
+	/* Map the packet head */
+	map = dma_map_single(priv->dev, skb->data, len, DMA_TO_DEVICE);
+	if (dma_mapping_error(priv->dev, map)) {
 		if (net_ratelimit())
-			netdev_err(netdev, "map socket buffer failed\n");
+			netdev_err(netdev, "map tx packet head failed\n");
 		goto drop;
 	}
 
 	/* Grab the next free tx descriptor */
 	pointer = priv->tx_pointer;
-	txdes = &priv->descs->txdes[pointer];
+	txdes = first = &priv->descs->txdes[pointer];
 
-	/* setup TX descriptor */
+	/* Setup it up with the packet head. We don't set the OWN bit yet. */
 	priv->tx_skbs[pointer] = skb;
 	ftgmac100_txdes_set_dma_addr(txdes, map);
 	ftgmac100_txdes_set_buffer_size(txdes, len);
-
 	ftgmac100_txdes_set_first_segment(txdes);
-	ftgmac100_txdes_set_last_segment(txdes);
-	ftgmac100_txdes_set_txint(txdes);
+
+	/* Setup HW checksumming */
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		__be16 protocol = skb->protocol;
 
@@ -676,14 +703,41 @@ static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
 		}
 	}
 
+	/* Next descriptor */
+	pointer = ftgmac100_next_tx_pointer(pointer);
+
+	/* Add the fragments */
+	for (i = 0; i < nfrags; i++) {
+		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+
+		len = frag->size;
+
+		/* Map it */
+		map = skb_frag_dma_map(priv->dev, frag, 0, len,
+				       DMA_TO_DEVICE);
+		if (dma_mapping_error(priv->dev, map))
+			goto dma_err;
+
+		/* Setup descriptor */
+		priv->tx_skbs[pointer] = skb;
+		txdes = &priv->descs->txdes[pointer];
+		ftgmac100_txdes_set_dma_addr(txdes, map);
+		ftgmac100_txdes_set_buffer_size(txdes, len);
+		ftgmac100_txdes_set_dma_own(txdes);
+		pointer = ftgmac100_next_tx_pointer(pointer);
+	}
+
+	/* Tag last fragment */
+	ftgmac100_txdes_set_last_segment(txdes);
+
 	/* Order the previous packet and descriptor udpates
 	 * before setting the OWN bit.
 	 */
 	dma_wmb();
-	ftgmac100_txdes_set_dma_own(txdes);
+	ftgmac100_txdes_set_dma_own(first);
 
 	/* Update next TX pointer */
-	priv->tx_pointer = ftgmac100_next_tx_pointer(pointer);
+	priv->tx_pointer = pointer;
 
 	/* If there isn't enough room for all the fragments of a new packet
 	 * in the TX ring, stop the queue. The sequence below is race free
@@ -701,6 +755,25 @@ static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
 
 	return NETDEV_TX_OK;
 
+ dma_err:
+	if (net_ratelimit())
+		netdev_err(netdev, "map tx fragment failed\n");
+
+	/* Free head */
+	pointer = priv->tx_pointer;
+	ftgmac100_free_tx_packet(priv, pointer, skb, first);
+
+	/* Then all fragments */
+	for (j = 0; j < i; j++) {
+		pointer = ftgmac100_next_tx_pointer(pointer);
+		txdes = &priv->descs->txdes[pointer];
+		ftgmac100_free_tx_packet(priv, pointer, skb, txdes);
+	}
+
+	/* This cannot be reached if we successfully mapped the
+	 * last fragment, so we know ftgmac100_free_tx_packet()
+	 * hasn't freed the skb yet.
+	 */
  drop:
 	/* Drop the packet */
 	dev_kfree_skb_any(skb);
@@ -1440,12 +1513,12 @@ static int ftgmac100_probe(struct platform_device *pdev)
 	 * when NCSI is enabled on the interface. It doesn't work
 	 * in that case.
 	 */
-	netdev->features = NETIF_F_RXCSUM | NETIF_F_IP_CSUM | NETIF_F_GRO;
+	netdev->features = NETIF_F_RXCSUM | NETIF_F_IP_CSUM |
+		NETIF_F_GRO | NETIF_F_SG;
 	if (priv->use_ncsi &&
 	    of_get_property(pdev->dev.of_node, "no-hw-checksum", NULL))
 		netdev->features &= ~NETIF_F_IP_CSUM;
 
-
 	/* register network device */
 	err = register_netdev(netdev);
 	if (err) {
-- 
2.9.3
