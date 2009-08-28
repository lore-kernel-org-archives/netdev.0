From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 06/17] tg3: Clarify rx buffer relationships
Date: Fri, 28 Aug 2009 16:58:46 -0700
Message-ID: <1251585283.29678@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2848 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752633AbZH2Weu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Aug 2009 18:34:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch attempts to document the various rx buffer sizes used by the
driver and how they relate to each other.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/tg3.c |   42 +++++++++++++++++++++++-------------------
 drivers/net/tg3.h |    2 +-
 2 files changed, 24 insertions(+), 20 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 5e74a19..a2a5f31 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -125,8 +125,15 @@
 				 TG3_TX_RING_SIZE)
 #define NEXT_TX(N)		(((N) + 1) & (TG3_TX_RING_SIZE - 1))
 
-#define RX_PKT_BUF_SZ		(1536 + tp->rx_offset + 64)
-#define RX_JUMBO_PKT_BUF_SZ	(9046 + tp->rx_offset + 64)
+#define TG3_DMA_BYTE_ENAB		64
+
+#define TG3_RX_STD_DMA_SZ		1536
+#define TG3_RX_JMB_DMA_SZ		9046
+
+#define TG3_RX_DMA_TO_MAP_SZ(x)		((x) + TG3_DMA_BYTE_ENAB)
+
+#define TG3_RX_STD_MAP_SZ		TG3_RX_DMA_TO_MAP_SZ(TG3_RX_STD_DMA_SZ)
+#define TG3_RX_JMB_MAP_SZ		TG3_RX_DMA_TO_MAP_SZ(TG3_RX_JMB_DMA_SZ)
 
 /* minimum number of free TX descriptors required to wake up TX process */
 #define TG3_TX_WAKEUP_THRESH(tp)		((tp)->tx_pending / 4)
@@ -4354,7 +4361,7 @@ static int tg3_alloc_rx_skb(struct tg3 *tp, u32 opaque_key,
 		map = &tp->rx_std_buffers[dest_idx];
 		if (src_idx >= 0)
 			src_map = &tp->rx_std_buffers[src_idx];
-		skb_size = tp->rx_pkt_buf_sz;
+		skb_size = tp->rx_pkt_map_sz;
 		break;
 
 	case RXD_OPAQUE_RING_JUMBO:
@@ -4363,7 +4370,7 @@ static int tg3_alloc_rx_skb(struct tg3 *tp, u32 opaque_key,
 		map = &tp->rx_jumbo_buffers[dest_idx];
 		if (src_idx >= 0)
 			src_map = &tp->rx_jumbo_buffers[src_idx];
-		skb_size = RX_JUMBO_PKT_BUF_SZ;
+		skb_size = TG3_RX_JMB_MAP_SZ;
 		break;
 
 	default:
@@ -4376,14 +4383,13 @@ static int tg3_alloc_rx_skb(struct tg3 *tp, u32 opaque_key,
 	 * Callers depend upon this behavior and assume that
 	 * we leave everything unchanged if we fail.
 	 */
-	skb = netdev_alloc_skb(tp->dev, skb_size);
+	skb = netdev_alloc_skb(tp->dev, skb_size + tp->rx_offset);
 	if (skb == NULL)
 		return -ENOMEM;
 
 	skb_reserve(skb, tp->rx_offset);
 
-	mapping = pci_map_single(tp->pdev, skb->data,
-				 skb_size - tp->rx_offset,
+	mapping = pci_map_single(tp->pdev, skb->data, skb_size,
 				 PCI_DMA_FROMDEVICE);
 
 	map->skb = skb;
@@ -4540,8 +4546,7 @@ static int tg3_rx(struct tg3 *tp, int budget)
 			if (skb_size < 0)
 				goto drop_it;
 
-			pci_unmap_single(tp->pdev, dma_addr,
-					 skb_size - tp->rx_offset,
+			pci_unmap_single(tp->pdev, dma_addr, skb_size,
 					 PCI_DMA_FROMDEVICE);
 
 			skb_put(skb, len);
@@ -5531,7 +5536,7 @@ static void tg3_free_rings(struct tg3 *tp)
 			continue;
 		pci_unmap_single(tp->pdev,
 				 pci_unmap_addr(rxp, mapping),
-				 tp->rx_pkt_buf_sz - tp->rx_offset,
+				 tp->rx_pkt_map_sz,
 				 PCI_DMA_FROMDEVICE);
 		dev_kfree_skb_any(rxp->skb);
 		rxp->skb = NULL;
@@ -5544,7 +5549,7 @@ static void tg3_free_rings(struct tg3 *tp)
 			continue;
 		pci_unmap_single(tp->pdev,
 				 pci_unmap_addr(rxp, mapping),
-				 RX_JUMBO_PKT_BUF_SZ - tp->rx_offset,
+				 TG3_RX_JMB_MAP_SZ,
 				 PCI_DMA_FROMDEVICE);
 		dev_kfree_skb_any(rxp->skb);
 		rxp->skb = NULL;
@@ -5581,7 +5586,7 @@ static void tg3_free_rings(struct tg3 *tp)
  */
 static int tg3_init_rings(struct tg3 *tp)
 {
-	u32 i;
+	u32 i, rx_pkt_dma_sz;
 
 	/* Free up all the SKBs. */
 	tg3_free_rings(tp);
@@ -5592,10 +5597,11 @@ static int tg3_init_rings(struct tg3 *tp)
 	memset(tp->rx_rcb, 0, TG3_RX_RCB_RING_BYTES(tp));
 	memset(tp->tx_ring, 0, TG3_TX_RING_BYTES);
 
-	tp->rx_pkt_buf_sz = RX_PKT_BUF_SZ;
+	rx_pkt_dma_sz = TG3_RX_STD_DMA_SZ;
 	if ((tp->tg3_flags2 & TG3_FLG2_5780_CLASS) &&
-	    (tp->dev->mtu > ETH_DATA_LEN))
-		tp->rx_pkt_buf_sz = RX_JUMBO_PKT_BUF_SZ;
+	    tp->dev->mtu > ETH_DATA_LEN)
+		rx_pkt_dma_sz = TG3_RX_JMB_DMA_SZ;
+	tp->rx_pkt_map_sz = TG3_RX_DMA_TO_MAP_SZ(rx_pkt_dma_sz);
 
 	/* Initialize invariants of the rings, we only set this
 	 * stuff once.  This works because the card does not
@@ -5605,8 +5611,7 @@ static int tg3_init_rings(struct tg3 *tp)
 		struct tg3_rx_buffer_desc *rxd;
 
 		rxd = &tp->rx_std[i];
-		rxd->idx_len = (tp->rx_pkt_buf_sz - tp->rx_offset - 64)
-			<< RXD_LEN_SHIFT;
+		rxd->idx_len = rx_pkt_dma_sz << RXD_LEN_SHIFT;
 		rxd->type_flags = (RXD_FLAG_END << RXD_FLAGS_SHIFT);
 		rxd->opaque = (RXD_OPAQUE_RING_STD |
 			       (i << RXD_OPAQUE_INDEX_SHIFT));
@@ -5617,8 +5622,7 @@ static int tg3_init_rings(struct tg3 *tp)
 			struct tg3_rx_buffer_desc *rxd;
 
 			rxd = &tp->rx_jumbo[i];
-			rxd->idx_len = (RX_JUMBO_PKT_BUF_SZ - tp->rx_offset - 64)
-				<< RXD_LEN_SHIFT;
+			rxd->idx_len = TG3_RX_JMB_DMA_SZ << RXD_LEN_SHIFT;
 			rxd->type_flags = (RXD_FLAG_END << RXD_FLAGS_SHIFT) |
 				RXD_FLAG_JUMBO;
 			rxd->opaque = (RXD_OPAQUE_RING_JUMBO |
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 5efae2c..d029b4b 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2571,7 +2571,7 @@ struct tg3 {
 	struct tg3_rx_buffer_desc	*rx_rcb;
 	dma_addr_t			rx_rcb_mapping;
 
-	u32				rx_pkt_buf_sz;
+	u32				rx_pkt_map_sz;
 
 	/* begin "everything else" cacheline(s) section */
 	struct net_device_stats		net_stats;
-- 
1.6.3.3


