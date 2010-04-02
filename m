From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: [PATCH] bnx2: use the dma state API instead of the pci equivalents
Date: Fri, 2 Apr 2010 11:56:57 +0900
Message-ID: <20100402115025A.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sh.osrg.net ([192.16.179.4]:48535 "EHLO sh.osrg.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759089Ab0DBC5A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Apr 2010 22:57:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The DMA API is preferred.

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
---
 drivers/net/bnx2.c |   40 ++++++++++++++++++++--------------------
 drivers/net/bnx2.h |    6 +++---
 2 files changed, 23 insertions(+), 23 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 381887b..c55e46f 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -2668,7 +2668,7 @@ bnx2_alloc_rx_page(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr, u16 index)
 	}
 
 	rx_pg->page = page;
-	pci_unmap_addr_set(rx_pg, mapping, mapping);
+	dma_unmap_addr_set(rx_pg, mapping, mapping);
 	rxbd->rx_bd_haddr_hi = (u64) mapping >> 32;
 	rxbd->rx_bd_haddr_lo = (u64) mapping & 0xffffffff;
 	return 0;
@@ -2683,7 +2683,7 @@ bnx2_free_rx_page(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr, u16 index)
 	if (!page)
 		return;
 
-	pci_unmap_page(bp->pdev, pci_unmap_addr(rx_pg, mapping), PAGE_SIZE,
+	pci_unmap_page(bp->pdev, dma_unmap_addr(rx_pg, mapping), PAGE_SIZE,
 		       PCI_DMA_FROMDEVICE);
 
 	__free_page(page);
@@ -2715,7 +2715,7 @@ bnx2_alloc_rx_skb(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr, u16 index)
 	}
 
 	rx_buf->skb = skb;
-	pci_unmap_addr_set(rx_buf, mapping, mapping);
+	dma_unmap_addr_set(rx_buf, mapping, mapping);
 
 	rxbd->rx_bd_haddr_hi = (u64) mapping >> 32;
 	rxbd->rx_bd_haddr_lo = (u64) mapping & 0xffffffff;
@@ -2814,7 +2814,7 @@ bnx2_tx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 			}
 		}
 
-		pci_unmap_single(bp->pdev, pci_unmap_addr(tx_buf, mapping),
+		pci_unmap_single(bp->pdev, dma_unmap_addr(tx_buf, mapping),
 			skb_headlen(skb), PCI_DMA_TODEVICE);
 
 		tx_buf->skb = NULL;
@@ -2824,7 +2824,7 @@ bnx2_tx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 			sw_cons = NEXT_TX_BD(sw_cons);
 
 			pci_unmap_page(bp->pdev,
-				pci_unmap_addr(
+				dma_unmap_addr(
 					&txr->tx_buf_ring[TX_RING_IDX(sw_cons)],
 					mapping),
 				skb_shinfo(skb)->frags[i].size,
@@ -2906,8 +2906,8 @@ bnx2_reuse_rx_skb_pages(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr,
 		if (prod != cons) {
 			prod_rx_pg->page = cons_rx_pg->page;
 			cons_rx_pg->page = NULL;
-			pci_unmap_addr_set(prod_rx_pg, mapping,
-				pci_unmap_addr(cons_rx_pg, mapping));
+			dma_unmap_addr_set(prod_rx_pg, mapping,
+				dma_unmap_addr(cons_rx_pg, mapping));
 
 			prod_bd->rx_bd_haddr_hi = cons_bd->rx_bd_haddr_hi;
 			prod_bd->rx_bd_haddr_lo = cons_bd->rx_bd_haddr_lo;
@@ -2931,7 +2931,7 @@ bnx2_reuse_rx_skb(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr,
 	prod_rx_buf = &rxr->rx_buf_ring[prod];
 
 	pci_dma_sync_single_for_device(bp->pdev,
-		pci_unmap_addr(cons_rx_buf, mapping),
+		dma_unmap_addr(cons_rx_buf, mapping),
 		BNX2_RX_OFFSET + BNX2_RX_COPY_THRESH, PCI_DMA_FROMDEVICE);
 
 	rxr->rx_prod_bseq += bp->rx_buf_use_size;
@@ -2941,8 +2941,8 @@ bnx2_reuse_rx_skb(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr,
 	if (cons == prod)
 		return;
 
-	pci_unmap_addr_set(prod_rx_buf, mapping,
-			pci_unmap_addr(cons_rx_buf, mapping));
+	dma_unmap_addr_set(prod_rx_buf, mapping,
+			dma_unmap_addr(cons_rx_buf, mapping));
 
 	cons_bd = &rxr->rx_desc_ring[RX_RING(cons)][RX_IDX(cons)];
 	prod_bd = &rxr->rx_desc_ring[RX_RING(prod)][RX_IDX(prod)];
@@ -3015,7 +3015,7 @@ bnx2_rx_skb(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr, struct sk_buff *skb,
 			/* Don't unmap yet.  If we're unable to allocate a new
 			 * page, we need to recycle the page and the DMA addr.
 			 */
-			mapping_old = pci_unmap_addr(rx_pg, mapping);
+			mapping_old = dma_unmap_addr(rx_pg, mapping);
 			if (i == pages - 1)
 				frag_len -= 4;
 
@@ -3096,7 +3096,7 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 
 		rx_buf->skb = NULL;
 
-		dma_addr = pci_unmap_addr(rx_buf, mapping);
+		dma_addr = dma_unmap_addr(rx_buf, mapping);
 
 		pci_dma_sync_single_for_cpu(bp->pdev, dma_addr,
 			BNX2_RX_OFFSET + BNX2_RX_COPY_THRESH,
@@ -5310,7 +5310,7 @@ bnx2_free_tx_skbs(struct bnx2 *bp)
 			}
 
 			pci_unmap_single(bp->pdev,
-					 pci_unmap_addr(tx_buf, mapping),
+					 dma_unmap_addr(tx_buf, mapping),
 					 skb_headlen(skb),
 					 PCI_DMA_TODEVICE);
 
@@ -5321,7 +5321,7 @@ bnx2_free_tx_skbs(struct bnx2 *bp)
 			for (k = 0; k < last; k++, j++) {
 				tx_buf = &txr->tx_buf_ring[TX_RING_IDX(j)];
 				pci_unmap_page(bp->pdev,
-					pci_unmap_addr(tx_buf, mapping),
+					dma_unmap_addr(tx_buf, mapping),
 					skb_shinfo(skb)->frags[k].size,
 					PCI_DMA_TODEVICE);
 			}
@@ -5351,7 +5351,7 @@ bnx2_free_rx_skbs(struct bnx2 *bp)
 				continue;
 
 			pci_unmap_single(bp->pdev,
-					 pci_unmap_addr(rx_buf, mapping),
+					 dma_unmap_addr(rx_buf, mapping),
 					 bp->rx_buf_use_size,
 					 PCI_DMA_FROMDEVICE);
 
@@ -5761,7 +5761,7 @@ bnx2_run_loopback(struct bnx2 *bp, int loopback_mode)
 	skb_reserve(rx_skb, BNX2_RX_OFFSET);
 
 	pci_dma_sync_single_for_cpu(bp->pdev,
-		pci_unmap_addr(rx_buf, mapping),
+		dma_unmap_addr(rx_buf, mapping),
 		bp->rx_buf_size, PCI_DMA_FROMDEVICE);
 
 	if (rx_hdr->l2_fhdr_status &
@@ -6420,7 +6420,7 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	tx_buf = &txr->tx_buf_ring[ring_prod];
 	tx_buf->skb = skb;
-	pci_unmap_addr_set(tx_buf, mapping, mapping);
+	dma_unmap_addr_set(tx_buf, mapping, mapping);
 
 	txbd = &txr->tx_desc_ring[ring_prod];
 
@@ -6445,7 +6445,7 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			len, PCI_DMA_TODEVICE);
 		if (pci_dma_mapping_error(bp->pdev, mapping))
 			goto dma_error;
-		pci_unmap_addr_set(&txr->tx_buf_ring[ring_prod], mapping,
+		dma_unmap_addr_set(&txr->tx_buf_ring[ring_prod], mapping,
 				   mapping);
 
 		txbd->tx_bd_haddr_hi = (u64) mapping >> 32;
@@ -6482,7 +6482,7 @@ dma_error:
 	ring_prod = TX_RING_IDX(prod);
 	tx_buf = &txr->tx_buf_ring[ring_prod];
 	tx_buf->skb = NULL;
-	pci_unmap_single(bp->pdev, pci_unmap_addr(tx_buf, mapping),
+	pci_unmap_single(bp->pdev, dma_unmap_addr(tx_buf, mapping),
 			 skb_headlen(skb), PCI_DMA_TODEVICE);
 
 	/* unmap remaining mapped pages */
@@ -6490,7 +6490,7 @@ dma_error:
 		prod = NEXT_TX_BD(prod);
 		ring_prod = TX_RING_IDX(prod);
 		tx_buf = &txr->tx_buf_ring[ring_prod];
-		pci_unmap_page(bp->pdev, pci_unmap_addr(tx_buf, mapping),
+		pci_unmap_page(bp->pdev, dma_unmap_addr(tx_buf, mapping),
 			       skb_shinfo(skb)->frags[i].size,
 			       PCI_DMA_TODEVICE);
 	}
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index cd4b0e4..ab34a5d 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6551,17 +6551,17 @@ struct l2_fhdr {
 
 struct sw_bd {
 	struct sk_buff		*skb;
-	DECLARE_PCI_UNMAP_ADDR(mapping)
+	DEFINE_DMA_UNMAP_ADDR(mapping);
 };
 
 struct sw_pg {
 	struct page		*page;
-	DECLARE_PCI_UNMAP_ADDR(mapping)
+	DEFINE_DMA_UNMAP_ADDR(mapping);
 };
 
 struct sw_tx_bd {
 	struct sk_buff		*skb;
-	DECLARE_PCI_UNMAP_ADDR(mapping)
+	DEFINE_DMA_UNMAP_ADDR(mapping);
 	unsigned short		is_gso;
 	unsigned short		nr_frags;
 };
-- 
1.7.0

