From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 09/10] ftgmac100: Remove rx descriptor accessors
Date: Thu,  6 Apr 2017 11:02:51 +1000
Message-ID: <20170406010252.29208-10-benh@kernel.crashing.org>
References: <20170406010252.29208-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:37951 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756512AbdDFBDt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 5 Apr 2017 21:03:49 -0400
In-Reply-To: <20170406010252.29208-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Directly access the fields when needed. The accessors add clutter
not clarity and in some cases cause unnecessary read-modify-write
type access on the slow (uncached) descriptor memory.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 152 +++++++++----------------------
 drivers/net/ethernet/faraday/ftgmac100.h |  16 +++-
 2 files changed, 53 insertions(+), 115 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 594af30..e42ef8f 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -276,92 +276,6 @@ static void ftgmac100_stop_hw(struct ftgmac100 *priv)
 	iowrite32(0, priv->base + FTGMAC100_OFFSET_MACCR);
 }
 
-static bool ftgmac100_rxdes_first_segment(struct ftgmac100_rxdes *rxdes)
-{
-	return rxdes->rxdes0 & cpu_to_le32(FTGMAC100_RXDES0_FRS);
-}
-
-static bool ftgmac100_rxdes_last_segment(struct ftgmac100_rxdes *rxdes)
-{
-	return rxdes->rxdes0 & cpu_to_le32(FTGMAC100_RXDES0_LRS);
-}
-
-static bool ftgmac100_rxdes_packet_ready(struct ftgmac100_rxdes *rxdes)
-{
-	return rxdes->rxdes0 & cpu_to_le32(FTGMAC100_RXDES0_RXPKT_RDY);
-}
-
-#define RXDES0_ANY_ERROR		( \
-	FTGMAC100_RXDES0_RX_ERR		| \
-	FTGMAC100_RXDES0_CRC_ERR	| \
-	FTGMAC100_RXDES0_FTL		| \
-	FTGMAC100_RXDES0_RUNT		| \
-	FTGMAC100_RXDES0_RX_ODD_NB)
-
-static inline bool ftgmac100_rxdes_any_error(struct ftgmac100_rxdes *rxdes)
-{
-	return rxdes->rxdes0 & cpu_to_le32(RXDES0_ANY_ERROR);
-}
-
-static bool ftgmac100_rxdes_rx_error(struct ftgmac100_rxdes *rxdes)
-{
-	return rxdes->rxdes0 & cpu_to_le32(FTGMAC100_RXDES0_RX_ERR);
-}
-
-static bool ftgmac100_rxdes_crc_error(struct ftgmac100_rxdes *rxdes)
-{
-	return rxdes->rxdes0 & cpu_to_le32(FTGMAC100_RXDES0_CRC_ERR);
-}
-
-static bool ftgmac100_rxdes_frame_too_long(struct ftgmac100_rxdes *rxdes)
-{
-	return rxdes->rxdes0 & cpu_to_le32(FTGMAC100_RXDES0_FTL);
-}
-
-static bool ftgmac100_rxdes_runt(struct ftgmac100_rxdes *rxdes)
-{
-	return rxdes->rxdes0 & cpu_to_le32(FTGMAC100_RXDES0_RUNT);
-}
-
-static bool ftgmac100_rxdes_odd_nibble(struct ftgmac100_rxdes *rxdes)
-{
-	return rxdes->rxdes0 & cpu_to_le32(FTGMAC100_RXDES0_RX_ODD_NB);
-}
-
-static unsigned int ftgmac100_rxdes_data_length(struct ftgmac100_rxdes *rxdes)
-{
-	return le32_to_cpu(rxdes->rxdes0) & FTGMAC100_RXDES0_VDBC;
-}
-
-static bool ftgmac100_rxdes_multicast(struct ftgmac100_rxdes *rxdes)
-{
-	return rxdes->rxdes0 & cpu_to_le32(FTGMAC100_RXDES0_MULTICAST);
-}
-
-static void ftgmac100_rxdes_set_end_of_ring(const struct ftgmac100 *priv,
-					    struct ftgmac100_rxdes *rxdes)
-{
-	rxdes->rxdes0 |= cpu_to_le32(priv->rxdes0_edorr_mask);
-}
-
-static void ftgmac100_rxdes_set_dma_addr(struct ftgmac100_rxdes *rxdes,
-					 dma_addr_t addr)
-{
-	rxdes->rxdes3 = cpu_to_le32(addr);
-}
-
-static dma_addr_t ftgmac100_rxdes_get_dma_addr(struct ftgmac100_rxdes *rxdes)
-{
-	return le32_to_cpu(rxdes->rxdes3);
-}
-
-static inline bool ftgmac100_rxdes_csum_err(struct ftgmac100_rxdes *rxdes)
-{
-	return !!(rxdes->rxdes1 & cpu_to_le32(FTGMAC100_RXDES1_TCP_CHKSUM_ERR |
-					      FTGMAC100_RXDES1_UDP_CHKSUM_ERR |
-					      FTGMAC100_RXDES1_IP_CHKSUM_ERR));
-}
-
 static int ftgmac100_alloc_rx_buf(struct ftgmac100 *priv, unsigned int entry,
 				  struct ftgmac100_rxdes *rxdes, gfp_t gfp)
 {
@@ -393,13 +307,16 @@ static int ftgmac100_alloc_rx_buf(struct ftgmac100 *priv, unsigned int entry,
 	priv->rx_skbs[entry] = skb;
 
 	/* Store DMA address into RX desc */
-	ftgmac100_rxdes_set_dma_addr(rxdes, map);
+	rxdes->rxdes3 = cpu_to_le32(map);
 
 	/* Ensure the above is ordered vs clearing the OWN bit */
 	dma_wmb();
 
-	/* Clean rxdes0 (which resets own bit) */
-	rxdes->rxdes0 &= cpu_to_le32(priv->rxdes0_edorr_mask);
+	/* Clean status (which resets own bit) */
+	if (entry == (RX_QUEUE_ENTRIES - 1))
+		rxdes->rxdes0 = cpu_to_le32(priv->rxdes0_edorr_mask);
+	else
+		rxdes->rxdes0 = 0;
 
 	return 0;
 }
@@ -409,20 +326,19 @@ static int ftgmac100_next_rx_pointer(int pointer)
 	return (pointer + 1) & (RX_QUEUE_ENTRIES - 1);
 }
 
-static void ftgmac100_rx_packet_error(struct ftgmac100 *priv,
-				      struct ftgmac100_rxdes *rxdes)
+static void ftgmac100_rx_packet_error(struct ftgmac100 *priv, u32 status)
 {
 	struct net_device *netdev = priv->netdev;
 
-	if (ftgmac100_rxdes_rx_error(rxdes))
+	if (status & FTGMAC100_RXDES0_RX_ERR)
 		netdev->stats.rx_errors++;
 
-	if (ftgmac100_rxdes_crc_error(rxdes))
+	if (status & FTGMAC100_RXDES0_CRC_ERR)
 		netdev->stats.rx_crc_errors++;
 
-	if (ftgmac100_rxdes_frame_too_long(rxdes) ||
-	    ftgmac100_rxdes_runt(rxdes) ||
-	    ftgmac100_rxdes_odd_nibble(rxdes))
+	if (status & (FTGMAC100_RXDES0_FTL |
+		      FTGMAC100_RXDES0_RUNT |
+		      FTGMAC100_RXDES0_RX_ODD_NB))
 		netdev->stats.rx_length_errors++;
 }
 
@@ -432,27 +348,31 @@ static bool ftgmac100_rx_packet(struct ftgmac100 *priv, int *processed)
 	struct ftgmac100_rxdes *rxdes;
 	struct sk_buff *skb;
 	unsigned int pointer, size;
+	u32 status;
 	dma_addr_t map;
 
 	/* Grab next RX descriptor */
 	pointer = priv->rx_pointer;
 	rxdes = &priv->descs->rxdes[pointer];
 
+	/* Grab descriptor status */
+	status = le32_to_cpu(rxdes->rxdes0);
+
 	/* Do we have a packet ? */
-	if (!ftgmac100_rxdes_packet_ready(rxdes))
+	if (!(status & FTGMAC100_RXDES0_RXPKT_RDY))
 		return false;
 
 	/* Order subsequent reads with the test for the ready bit */
 	dma_rmb();
 
 	/* We don't cope with fragmented RX packets */
-	if (unlikely(!ftgmac100_rxdes_first_segment(rxdes) ||
-		     !ftgmac100_rxdes_last_segment(rxdes)))
+	if (unlikely(!(status & FTGMAC100_RXDES0_FRS) ||
+		     !(status & FTGMAC100_RXDES0_LRS)))
 		goto drop;
 
 	/* Any error (other than csum offload) flagged ? */
-	if (unlikely(ftgmac100_rxdes_any_error(rxdes))) {
-		ftgmac100_rx_packet_error(priv, rxdes);
+	if (unlikely(status & RXDES0_ANY_ERROR)) {
+		ftgmac100_rx_packet_error(priv, status);
 		goto drop;
 	}
 
@@ -465,7 +385,7 @@ static bool ftgmac100_rx_packet(struct ftgmac100 *priv, int *processed)
 		goto drop;
 	}
 
-	if (unlikely(ftgmac100_rxdes_multicast(rxdes)))
+	if (unlikely(status & FTGMAC100_RXDES0_MULTICAST))
 		netdev->stats.multicast++;
 
 	/* If the HW found checksum errors, bounce it to software.
@@ -487,11 +407,12 @@ static bool ftgmac100_rx_packet(struct ftgmac100 *priv, int *processed)
 	}
 
 	/* Grab received size annd transfer to skb */
-	size = ftgmac100_rxdes_data_length(rxdes);
+	size = status & FTGMAC100_RXDES0_VDBC;
 	skb_put(skb, size);
 
 	/* Tear down DMA mapping, do necessary cache management */
-	map = ftgmac100_rxdes_get_dma_addr(rxdes);
+	map = le32_to_cpu(rxdes->rxdes3);
+
 #if defined(CONFIG_ARM) && !defined(CONFIG_ARM_DMA_USE_IOMMU)
 	/* When we don't have an iommu, we can save cycles by not
 	 * invalidating the cache for the part of the packet that
@@ -523,7 +444,7 @@ static bool ftgmac100_rx_packet(struct ftgmac100 *priv, int *processed)
 
  drop:
 	/* Clean rxdes0 (which resets own bit) */
-	rxdes->rxdes0 &= cpu_to_le32(priv->rxdes0_edorr_mask);
+	rxdes->rxdes0 = cpu_to_le32(status & priv->rxdes0_edorr_mask);
 	priv->rx_pointer = ftgmac100_next_rx_pointer(pointer);
 	netdev->stats.rx_dropped++;
 	return true;
@@ -745,7 +666,7 @@ static void ftgmac100_free_buffers(struct ftgmac100 *priv)
 	for (i = 0; i < RX_QUEUE_ENTRIES; i++) {
 		struct ftgmac100_rxdes *rxdes = &priv->descs->rxdes[i];
 		struct sk_buff *skb = priv->rx_skbs[i];
-		dma_addr_t map = ftgmac100_rxdes_get_dma_addr(rxdes);
+		dma_addr_t map = le32_to_cpu(rxdes->rxdes3);
 
 		if (!skb)
 			continue;
@@ -804,15 +725,17 @@ static int ftgmac100_alloc_rings(struct ftgmac100 *priv)
 
 static void ftgmac100_init_rings(struct ftgmac100 *priv)
 {
+	struct ftgmac100_rxdes *rxdes;
 	int i;
 
 	/* Initialize RX ring */
 	for (i = 0; i < RX_QUEUE_ENTRIES; i++) {
-		struct ftgmac100_rxdes *rxdes = &priv->descs->rxdes[i];
-		ftgmac100_rxdes_set_dma_addr(rxdes, priv->rx_scratch_dma);
+		rxdes = &priv->descs->rxdes[i];
 		rxdes->rxdes0 = 0;
+		rxdes->rxdes3 = cpu_to_le32(priv->rx_scratch_dma);
 	}
-	ftgmac100_rxdes_set_end_of_ring(priv, &priv->descs->rxdes[i - 1]);
+	/* Mark the end of the ring */
+	rxdes->rxdes0 |= cpu_to_le32(priv->rxdes0_edorr_mask);
 
 	/* Initialize TX ring */
 	for (i = 0; i < TX_QUEUE_ENTRIES; i++)
@@ -1028,6 +951,14 @@ static irqreturn_t ftgmac100_interrupt(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
+static bool ftgmac100_check_rx(struct ftgmac100 *priv)
+{
+	struct ftgmac100_rxdes *rxdes = &priv->descs->rxdes[priv->rx_pointer];
+
+	/* Do we have a packet ? */
+	return !!(rxdes->rxdes0 & cpu_to_le32(FTGMAC100_RXDES0_RXPKT_RDY));
+}
+
 static int ftgmac100_poll(struct napi_struct *napi, int budget)
 {
 	struct ftgmac100 *priv = container_of(napi, struct ftgmac100, napi);
@@ -1067,8 +998,7 @@ static int ftgmac100_poll(struct napi_struct *napi, int budget)
 		 */
 		iowrite32(FTGMAC100_INT_RXTX,
 			  priv->base + FTGMAC100_OFFSET_ISR);
-		if (ftgmac100_rxdes_packet_ready
-		    (ftgmac100_current_rxdes(priv)) || priv->tx_pending)
+		if (ftgmac100_check_rx(priv) || priv->tx_pending)
 			return budget;
 
 		/* deschedule NAPI */
diff --git a/drivers/net/ethernet/faraday/ftgmac100.h b/drivers/net/ethernet/faraday/ftgmac100.h
index c4d5cc1..9124785 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.h
+++ b/drivers/net/ethernet/faraday/ftgmac100.h
@@ -227,10 +227,10 @@ struct ftgmac100_txdes {
  * Receive descriptor, aligned to 16 bytes
  */
 struct ftgmac100_rxdes {
-	unsigned int	rxdes0;
-	unsigned int	rxdes1;
-	unsigned int	rxdes2;	/* not used by HW */
-	unsigned int	rxdes3;	/* RXBUF_BADR */
+	__le32	rxdes0; /* Control & status bits */
+	__le32	rxdes1;	/* Checksum and vlan status */
+	__le32	rxdes2; /* length/type on AST2500 */
+	__le32	rxdes3;	/* DMA buffer address */
 } __attribute__ ((aligned(16)));
 
 #define FTGMAC100_RXDES0_VDBC		0x3fff
@@ -248,6 +248,14 @@ struct ftgmac100_rxdes {
 #define FTGMAC100_RXDES0_FRS		(1 << 29)
 #define FTGMAC100_RXDES0_RXPKT_RDY	(1 << 31)
 
+/* Errors we care about for dropping packets */
+#define RXDES0_ANY_ERROR		( \
+	FTGMAC100_RXDES0_RX_ERR		| \
+	FTGMAC100_RXDES0_CRC_ERR	| \
+	FTGMAC100_RXDES0_FTL		| \
+	FTGMAC100_RXDES0_RUNT		| \
+	FTGMAC100_RXDES0_RX_ODD_NB)
+
 #define FTGMAC100_RXDES1_VLANTAG_CI	0xffff
 #define FTGMAC100_RXDES1_PROT_MASK	(0x3 << 20)
 #define FTGMAC100_RXDES1_PROT_NONIP	(0x0 << 20)
-- 
2.9.3
