From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH v2 12/12] ftgmac100: Remove tx descriptor accessors
Date: Mon, 10 Apr 2017 11:15:26 +1000
Message-ID: <20170410011526.4509-13-benh@kernel.crashing.org>
References: <20170410011526.4509-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:56963 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751236AbdDJBQX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 9 Apr 2017 21:16:23 -0400
In-Reply-To: <20170410011526.4509-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Directly access the fields when needed. The accessors add clutter
not clarity and in some cases cause unnecessary read-modify-write
type access on the slow (uncached) descriptor memory.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

v2. - Adjust for changes in previous patches
---
 drivers/net/ethernet/faraday/ftgmac100.c | 175 ++++++++++++-------------------
 drivers/net/ethernet/faraday/ftgmac100.h |   8 +-
 2 files changed, 69 insertions(+), 114 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 2a4d903..98b8956 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -466,77 +466,13 @@ static bool ftgmac100_rx_packet(struct ftgmac100 *priv, int *processed)
 	return true;
 }
 
-static bool ftgmac100_txdes_owned_by_dma(struct ftgmac100_txdes *txdes)
+static u32 ftgmac100_base_tx_ctlstat(struct ftgmac100 *priv,
+				     unsigned int index)
 {
-	return txdes->txdes0 & cpu_to_le32(FTGMAC100_TXDES0_TXDMA_OWN);
-}
-
-static void ftgmac100_txdes_set_dma_own(struct ftgmac100_txdes *txdes)
-{
-	txdes->txdes0 |= cpu_to_le32(FTGMAC100_TXDES0_TXDMA_OWN);
-}
-
-static void ftgmac100_txdes_set_end_of_ring(const struct ftgmac100 *priv,
-					    struct ftgmac100_txdes *txdes)
-{
-	txdes->txdes0 |= cpu_to_le32(priv->txdes0_edotr_mask);
-}
-
-static void ftgmac100_txdes_set_first_segment(struct ftgmac100_txdes *txdes)
-{
-	txdes->txdes0 |= cpu_to_le32(FTGMAC100_TXDES0_FTS);
-}
-
-static inline bool ftgmac100_txdes_get_first_segment(struct ftgmac100_txdes *txdes)
-{
-	return (txdes->txdes0 & cpu_to_le32(FTGMAC100_TXDES0_FTS)) != 0;
-}
-
-static void ftgmac100_txdes_set_last_segment(struct ftgmac100_txdes *txdes)
-{
-	txdes->txdes0 |= cpu_to_le32(FTGMAC100_TXDES0_LTS);
-}
-
-static inline bool ftgmac100_txdes_get_last_segment(struct ftgmac100_txdes *txdes)
-{
-	return (txdes->txdes0 & cpu_to_le32(FTGMAC100_TXDES0_LTS)) != 0;
-}
-
-static void ftgmac100_txdes_set_buffer_size(struct ftgmac100_txdes *txdes,
-					    unsigned int len)
-{
-	txdes->txdes0 |= cpu_to_le32(FTGMAC100_TXDES0_TXBUF_SIZE(len));
-}
-
-static inline unsigned int ftgmac100_txdes_get_buffer_size(struct ftgmac100_txdes *txdes)
-{
-	return FTGMAC100_TXDES0_TXBUF_SIZE(cpu_to_le32(txdes->txdes0));
-}
-
-static void ftgmac100_txdes_set_tcpcs(struct ftgmac100_txdes *txdes)
-{
-	txdes->txdes1 |= cpu_to_le32(FTGMAC100_TXDES1_TCP_CHKSUM);
-}
-
-static void ftgmac100_txdes_set_udpcs(struct ftgmac100_txdes *txdes)
-{
-	txdes->txdes1 |= cpu_to_le32(FTGMAC100_TXDES1_UDP_CHKSUM);
-}
-
-static void ftgmac100_txdes_set_ipcs(struct ftgmac100_txdes *txdes)
-{
-	txdes->txdes1 |= cpu_to_le32(FTGMAC100_TXDES1_IP_CHKSUM);
-}
-
-static void ftgmac100_txdes_set_dma_addr(struct ftgmac100_txdes *txdes,
-					 dma_addr_t addr)
-{
-	txdes->txdes3 = cpu_to_le32(addr);
-}
-
-static dma_addr_t ftgmac100_txdes_get_dma_addr(struct ftgmac100_txdes *txdes)
-{
-	return (dma_addr_t)le32_to_cpu(txdes->txdes3);
+	if (index == (TX_QUEUE_ENTRIES - 1))
+		return priv->txdes0_edotr_mask;
+	else
+		return 0;
 }
 
 static int ftgmac100_next_tx_pointer(int pointer)
@@ -564,29 +500,24 @@ static bool ftgmac100_tx_buf_cleanable(struct ftgmac100 *priv)
 static void ftgmac100_free_tx_packet(struct ftgmac100 *priv,
 				     unsigned int pointer,
 				     struct sk_buff *skb,
-				     struct ftgmac100_txdes *txdes)
+				     struct ftgmac100_txdes *txdes,
+				     u32 ctl_stat)
 {
-	dma_addr_t map = ftgmac100_txdes_get_dma_addr(txdes);
+	dma_addr_t map = le32_to_cpu(txdes->txdes3);
+	size_t len;
 
-	if (ftgmac100_txdes_get_first_segment(txdes)) {
-		dma_unmap_single(priv->dev, map, skb_headlen(skb),
-				 DMA_TO_DEVICE);
+	if (ctl_stat & FTGMAC100_TXDES0_FTS) {
+		len = skb_headlen(skb);
+		dma_unmap_single(priv->dev, map, len, DMA_TO_DEVICE);
 	} else {
-		dma_unmap_page(priv->dev, map,
-			       ftgmac100_txdes_get_buffer_size(txdes),
-			       DMA_TO_DEVICE);
+		len = FTGMAC100_TXDES0_TXBUF_SIZE(ctl_stat);
+		dma_unmap_page(priv->dev, map, len, DMA_TO_DEVICE);
 	}
 
-	if (ftgmac100_txdes_get_last_segment(txdes))
+	/* Free SKB on last segment */
+	if (ctl_stat & FTGMAC100_TXDES0_LTS)
 		dev_kfree_skb(skb);
 	priv->tx_skbs[pointer] = NULL;
-
-	/* Clear txdes0 except end of ring bit, clear txdes1 as we
-	 * only "OR" into it, leave 2 and 3 alone as 2 is unused
-	 * and 3 will be overwritten entirely
-	 */
-	txdes->txdes0 &= cpu_to_le32(priv->txdes0_edotr_mask);
-	txdes->txdes1 = 0;
 }
 
 static bool ftgmac100_tx_complete_packet(struct ftgmac100 *priv)
@@ -595,17 +526,20 @@ static bool ftgmac100_tx_complete_packet(struct ftgmac100 *priv)
 	struct ftgmac100_txdes *txdes;
 	struct sk_buff *skb;
 	unsigned int pointer;
+	u32 ctl_stat;
 
 	pointer = priv->tx_clean_pointer;
 	txdes = &priv->descs->txdes[pointer];
 
-	if (ftgmac100_txdes_owned_by_dma(txdes))
+	ctl_stat = le32_to_cpu(txdes->txdes0);
+	if (ctl_stat & FTGMAC100_TXDES0_TXDMA_OWN)
 		return false;
 
 	skb = priv->tx_skbs[pointer];
 	netdev->stats.tx_packets++;
 	netdev->stats.tx_bytes += skb->len;
-	ftgmac100_free_tx_packet(priv, pointer, skb, txdes);
+	ftgmac100_free_tx_packet(priv, pointer, skb, txdes, ctl_stat);
+	txdes->txdes0 = cpu_to_le32(ctl_stat & priv->txdes0_edotr_mask);
 
 	priv->tx_clean_pointer = ftgmac100_next_tx_pointer(pointer);
 
@@ -642,6 +576,7 @@ static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
 	struct ftgmac100 *priv = netdev_priv(netdev);
 	struct ftgmac100_txdes *txdes, *first;
 	unsigned int pointer, nfrags, len, i, j;
+	u32 f_ctl_stat, ctl_stat, csum_vlan;
 	dma_addr_t map;
 
 	/* The HW doesn't pad small frames */
@@ -677,26 +612,34 @@ static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
 	pointer = priv->tx_pointer;
 	txdes = first = &priv->descs->txdes[pointer];
 
-	/* Setup it up with the packet head. We don't set the OWN bit yet. */
+	/* Setup it up with the packet head. Don't write the head to the
+	 * ring just yet
+	 */
 	priv->tx_skbs[pointer] = skb;
-	ftgmac100_txdes_set_dma_addr(txdes, map);
-	ftgmac100_txdes_set_buffer_size(txdes, len);
-	ftgmac100_txdes_set_first_segment(txdes);
+	f_ctl_stat = ftgmac100_base_tx_ctlstat(priv, pointer);
+	f_ctl_stat |= FTGMAC100_TXDES0_TXDMA_OWN;
+	f_ctl_stat |= FTGMAC100_TXDES0_TXBUF_SIZE(len);
+	f_ctl_stat |= FTGMAC100_TXDES0_FTS;
+	if (nfrags == 0)
+		f_ctl_stat |= FTGMAC100_TXDES0_LTS;
+	txdes->txdes3 = cpu_to_le32(map);
 
 	/* Setup HW checksumming */
+	csum_vlan = 0;
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		__be16 protocol = skb->protocol;
 
 		if (protocol == cpu_to_be16(ETH_P_IP)) {
 			u8 ip_proto = ip_hdr(skb)->protocol;
 
-			ftgmac100_txdes_set_ipcs(txdes);
+			csum_vlan |= FTGMAC100_TXDES1_IP_CHKSUM;
 			if (ip_proto == IPPROTO_TCP)
-				ftgmac100_txdes_set_tcpcs(txdes);
+				csum_vlan |= FTGMAC100_TXDES1_TCP_CHKSUM;
 			else if (ip_proto == IPPROTO_UDP)
-				ftgmac100_txdes_set_udpcs(txdes);
+				csum_vlan |= FTGMAC100_TXDES1_UDP_CHKSUM;
 		}
 	}
+	txdes->txdes1 = cpu_to_le32(csum_vlan);
 
 	/* Next descriptor */
 	pointer = ftgmac100_next_tx_pointer(pointer);
@@ -716,20 +659,24 @@ static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
 		/* Setup descriptor */
 		priv->tx_skbs[pointer] = skb;
 		txdes = &priv->descs->txdes[pointer];
-		ftgmac100_txdes_set_dma_addr(txdes, map);
-		ftgmac100_txdes_set_buffer_size(txdes, len);
-		ftgmac100_txdes_set_dma_own(txdes);
+		ctl_stat = ftgmac100_base_tx_ctlstat(priv, pointer);
+		ctl_stat |= FTGMAC100_TXDES0_TXDMA_OWN;
+		ctl_stat |= FTGMAC100_TXDES0_TXBUF_SIZE(len);
+		if (i == (nfrags - 1))
+			ctl_stat |= FTGMAC100_TXDES0_LTS;
+		txdes->txdes0 = cpu_to_le32(ctl_stat);
+		txdes->txdes1 = 0;
+		txdes->txdes3 = cpu_to_le32(map);
+
+		/* Next one */
 		pointer = ftgmac100_next_tx_pointer(pointer);
 	}
 
-	/* Tag last fragment */
-	ftgmac100_txdes_set_last_segment(txdes);
-
 	/* Order the previous packet and descriptor udpates
-	 * before setting the OWN bit.
+	 * before setting the OWN bit on the first descriptor.
 	 */
 	dma_wmb();
-	ftgmac100_txdes_set_dma_own(first);
+	first->txdes0 = cpu_to_le32(f_ctl_stat);
 
 	/* Update next TX pointer */
 	priv->tx_pointer = pointer;
@@ -756,13 +703,16 @@ static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
 
 	/* Free head */
 	pointer = priv->tx_pointer;
-	ftgmac100_free_tx_packet(priv, pointer, skb, first);
+	ftgmac100_free_tx_packet(priv, pointer, skb, first, f_ctl_stat);
+	first->txdes0 = cpu_to_le32(f_ctl_stat & priv->txdes0_edotr_mask);
 
 	/* Then all fragments */
 	for (j = 0; j < i; j++) {
 		pointer = ftgmac100_next_tx_pointer(pointer);
 		txdes = &priv->descs->txdes[pointer];
-		ftgmac100_free_tx_packet(priv, pointer, skb, txdes);
+		ctl_stat = le32_to_cpu(txdes->txdes0);
+		ftgmac100_free_tx_packet(priv, pointer, skb, txdes, ctl_stat);
+		txdes->txdes0 = cpu_to_le32(ctl_stat & priv->txdes0_edotr_mask);
 	}
 
 	/* This cannot be reached if we successfully mapped the
@@ -800,8 +750,10 @@ static void ftgmac100_free_buffers(struct ftgmac100 *priv)
 		struct ftgmac100_txdes *txdes = &priv->descs->txdes[i];
 		struct sk_buff *skb = priv->tx_skbs[i];
 
-		if (skb)
-			ftgmac100_free_tx_packet(priv, i, skb, txdes);
+		if (!skb)
+			continue;
+		ftgmac100_free_tx_packet(priv, i, skb, txdes,
+					 le32_to_cpu(txdes->txdes0));
 	}
 }
 
@@ -841,6 +793,7 @@ static int ftgmac100_alloc_rings(struct ftgmac100 *priv)
 static void ftgmac100_init_rings(struct ftgmac100 *priv)
 {
 	struct ftgmac100_rxdes *rxdes;
+	struct ftgmac100_txdes *txdes;
 	int i;
 
 	/* Initialize RX ring */
@@ -853,9 +806,11 @@ static void ftgmac100_init_rings(struct ftgmac100 *priv)
 	rxdes->rxdes0 |= cpu_to_le32(priv->rxdes0_edorr_mask);
 
 	/* Initialize TX ring */
-	for (i = 0; i < TX_QUEUE_ENTRIES; i++)
-		priv->descs->txdes[i].txdes0 = 0;
-	ftgmac100_txdes_set_end_of_ring(priv, &priv->descs->txdes[i -1]);
+	for (i = 0; i < TX_QUEUE_ENTRIES; i++) {
+		txdes = &priv->descs->txdes[i];
+		txdes->txdes0 = 0;
+	}
+	txdes->txdes0 |= cpu_to_le32(priv->txdes0_edotr_mask);
 }
 
 static int ftgmac100_alloc_rx_buffers(struct ftgmac100 *priv)
diff --git a/drivers/net/ethernet/faraday/ftgmac100.h b/drivers/net/ethernet/faraday/ftgmac100.h
index 9124785..97912c4 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.h
+++ b/drivers/net/ethernet/faraday/ftgmac100.h
@@ -202,10 +202,10 @@
  * Transmit descriptor, aligned to 16 bytes
  */
 struct ftgmac100_txdes {
-	unsigned int	txdes0;
-	unsigned int	txdes1;
-	unsigned int	txdes2;	/* not used by HW */
-	unsigned int	txdes3;	/* TXBUF_BADR */
+	__le32	txdes0; /* Control & status bits */
+	__le32	txdes1; /* Irq, checksum and vlan control */
+	__le32	txdes2; /* Reserved */
+	__le32	txdes3; /* DMA buffer address */
 } __attribute__ ((aligned(16)));
 
 #define FTGMAC100_TXDES0_TXBUF_SIZE(x)	((x) & 0x3fff)
-- 
2.9.3
