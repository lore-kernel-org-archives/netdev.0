From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: [PATCH] bnx2x: use the dma state API instead of the pci equivalents
Date: Fri, 2 Apr 2010 11:56:57 +0900
Message-ID: <20100402115054A.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sh.osrg.net ([192.16.179.4]:48536 "EHLO sh.osrg.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759091Ab0DBC5A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Apr 2010 22:57:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The DMA API is preferred.

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
---
 drivers/net/bnx2x.h      |    4 ++--
 drivers/net/bnx2x_main.c |   28 ++++++++++++++--------------
 2 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 3c48a7a..ae9c89e 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -163,7 +163,7 @@ do {								 \
 
 struct sw_rx_bd {
 	struct sk_buff	*skb;
-	DECLARE_PCI_UNMAP_ADDR(mapping)
+	DEFINE_DMA_UNMAP_ADDR(mapping);
 };
 
 struct sw_tx_bd {
@@ -176,7 +176,7 @@ struct sw_tx_bd {
 
 struct sw_rx_page {
 	struct page	*page;
-	DECLARE_PCI_UNMAP_ADDR(mapping)
+	DEFINE_DMA_UNMAP_ADDR(mapping);
 };
 
 union db_prod {
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 6c042a7..2a77611 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -1086,7 +1086,7 @@ static inline void bnx2x_free_rx_sge(struct bnx2x *bp,
 	if (!page)
 		return;
 
-	pci_unmap_page(bp->pdev, pci_unmap_addr(sw_buf, mapping),
+	pci_unmap_page(bp->pdev, dma_unmap_addr(sw_buf, mapping),
 		       SGE_PAGE_SIZE*PAGES_PER_SGE, PCI_DMA_FROMDEVICE);
 	__free_pages(page, PAGES_PER_SGE_SHIFT);
 
@@ -1123,7 +1123,7 @@ static inline int bnx2x_alloc_rx_sge(struct bnx2x *bp,
 	}
 
 	sw_buf->page = page;
-	pci_unmap_addr_set(sw_buf, mapping, mapping);
+	dma_unmap_addr_set(sw_buf, mapping, mapping);
 
 	sge->addr_hi = cpu_to_le32(U64_HI(mapping));
 	sge->addr_lo = cpu_to_le32(U64_LO(mapping));
@@ -1151,7 +1151,7 @@ static inline int bnx2x_alloc_rx_skb(struct bnx2x *bp,
 	}
 
 	rx_buf->skb = skb;
-	pci_unmap_addr_set(rx_buf, mapping, mapping);
+	dma_unmap_addr_set(rx_buf, mapping, mapping);
 
 	rx_bd->addr_hi = cpu_to_le32(U64_HI(mapping));
 	rx_bd->addr_lo = cpu_to_le32(U64_LO(mapping));
@@ -1174,12 +1174,12 @@ static void bnx2x_reuse_rx_skb(struct bnx2x_fastpath *fp,
 	struct eth_rx_bd *prod_bd = &fp->rx_desc_ring[prod];
 
 	pci_dma_sync_single_for_device(bp->pdev,
-				       pci_unmap_addr(cons_rx_buf, mapping),
+				       dma_unmap_addr(cons_rx_buf, mapping),
 				       RX_COPY_THRESH, PCI_DMA_FROMDEVICE);
 
 	prod_rx_buf->skb = cons_rx_buf->skb;
-	pci_unmap_addr_set(prod_rx_buf, mapping,
-			   pci_unmap_addr(cons_rx_buf, mapping));
+	dma_unmap_addr_set(prod_rx_buf, mapping,
+			   dma_unmap_addr(cons_rx_buf, mapping));
 	*prod_bd = *cons_bd;
 }
 
@@ -1285,7 +1285,7 @@ static void bnx2x_tpa_start(struct bnx2x_fastpath *fp, u16 queue,
 	prod_rx_buf->skb = fp->tpa_pool[queue].skb;
 	mapping = pci_map_single(bp->pdev, fp->tpa_pool[queue].skb->data,
 				 bp->rx_buf_size, PCI_DMA_FROMDEVICE);
-	pci_unmap_addr_set(prod_rx_buf, mapping, mapping);
+	dma_unmap_addr_set(prod_rx_buf, mapping, mapping);
 
 	/* move partial skb from cons to pool (don't unmap yet) */
 	fp->tpa_pool[queue] = *cons_rx_buf;
@@ -1361,7 +1361,7 @@ static int bnx2x_fill_frag_skb(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 		}
 
 		/* Unmap the page as we r going to pass it to the stack */
-		pci_unmap_page(bp->pdev, pci_unmap_addr(&old_rx_pg, mapping),
+		pci_unmap_page(bp->pdev, dma_unmap_addr(&old_rx_pg, mapping),
 			      SGE_PAGE_SIZE*PAGES_PER_SGE, PCI_DMA_FROMDEVICE);
 
 		/* Add one frag and update the appropriate fields in the skb */
@@ -1389,7 +1389,7 @@ static void bnx2x_tpa_stop(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 	/* Unmap skb in the pool anyway, as we are going to change
 	   pool entry status to BNX2X_TPA_STOP even if new skb allocation
 	   fails. */
-	pci_unmap_single(bp->pdev, pci_unmap_addr(rx_buf, mapping),
+	pci_unmap_single(bp->pdev, dma_unmap_addr(rx_buf, mapping),
 			 bp->rx_buf_size, PCI_DMA_FROMDEVICE);
 
 	if (likely(new_skb)) {
@@ -1621,7 +1621,7 @@ static int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 			}
 
 			pci_dma_sync_single_for_device(bp->pdev,
-					pci_unmap_addr(rx_buf, mapping),
+					dma_unmap_addr(rx_buf, mapping),
 						       pad + RX_COPY_THRESH,
 						       PCI_DMA_FROMDEVICE);
 			prefetch(skb);
@@ -1666,7 +1666,7 @@ static int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 			} else
 			if (likely(bnx2x_alloc_rx_skb(bp, fp, bd_prod) == 0)) {
 				pci_unmap_single(bp->pdev,
-					pci_unmap_addr(rx_buf, mapping),
+					dma_unmap_addr(rx_buf, mapping),
 						 bp->rx_buf_size,
 						 PCI_DMA_FROMDEVICE);
 				skb_reserve(skb, pad);
@@ -4941,7 +4941,7 @@ static inline void bnx2x_free_tpa_pool(struct bnx2x *bp,
 
 		if (fp->tpa_state[i] == BNX2X_TPA_START)
 			pci_unmap_single(bp->pdev,
-					 pci_unmap_addr(rx_buf, mapping),
+					 dma_unmap_addr(rx_buf, mapping),
 					 bp->rx_buf_size, PCI_DMA_FROMDEVICE);
 
 		dev_kfree_skb(skb);
@@ -4978,7 +4978,7 @@ static void bnx2x_init_rx_rings(struct bnx2x *bp)
 					fp->disable_tpa = 1;
 					break;
 				}
-				pci_unmap_addr_set((struct sw_rx_bd *)
+				dma_unmap_addr_set((struct sw_rx_bd *)
 							&bp->fp->tpa_pool[i],
 						   mapping, 0);
 				fp->tpa_state[i] = BNX2X_TPA_STOP;
@@ -6907,7 +6907,7 @@ static void bnx2x_free_rx_skbs(struct bnx2x *bp)
 				continue;
 
 			pci_unmap_single(bp->pdev,
-					 pci_unmap_addr(rx_buf, mapping),
+					 dma_unmap_addr(rx_buf, mapping),
 					 bp->rx_buf_size, PCI_DMA_FROMDEVICE);
 
 			rx_buf->skb = NULL;
-- 
1.7.0

