From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH net] bnx2x: fix DMA API usage
Date: Fri, 26 Jun 2015 17:49:59 +0200
Message-ID: <1435333800-22447-1-git-send-email-mschmidt@redhat.com>
Cc: Gabriel Krisman Bertazi <krisman@linux.vnet.ibm.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39698 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752252AbbFZPuD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jun 2015 11:50:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With CONFIG_DMA_API_DEBUG=y bnx2x triggers the error "DMA-API: device
driver frees DMA memory with wrong function".
On archs where PAGE_SIZE > SGE_PAGE_SIZE it also triggers "DMA-API:
device driver frees DMA memory with different size".

Fix this by making the mapping and unmapping symmetric:
 - Do not map the whole pool page at once. Instead map the
   SGE_PAGE_SIZE-sized pieces individually, so they can be unmapped in
   the same manner.
 - What's mapped using dma_map_page() must be unmapped using
   dma_unmap_page().

Tested on ppc64.

Fixes: 4cace675d687 ("bnx2x: Alloc 4k fragment for each rx ring buffer element")
Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h     |  1 -
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 23 ++++++++++-------------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h | 12 ++----------
 3 files changed, 12 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index b4bfdd29fb..cd4ae76bbf 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -530,7 +530,6 @@ enum bnx2x_tpa_mode_t {
 
 struct bnx2x_alloc_pool {
 	struct page	*page;
-	dma_addr_t	dma;
 	unsigned int	offset;
 };
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 45e7c65f41..a90d736433 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -563,23 +563,20 @@ static int bnx2x_alloc_rx_sge(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 			return -ENOMEM;
 		}
 
-		pool->dma = dma_map_page(&bp->pdev->dev, pool->page, 0,
-					 PAGE_SIZE, DMA_FROM_DEVICE);
-		if (unlikely(dma_mapping_error(&bp->pdev->dev,
-					       pool->dma))) {
-			__free_pages(pool->page, PAGES_PER_SGE_SHIFT);
-			pool->page = NULL;
-			BNX2X_ERR("Can't map sge\n");
-			return -ENOMEM;
-		}
 		pool->offset = 0;
 	}
 
+	mapping = dma_map_page(&bp->pdev->dev, pool->page,
+			       pool->offset, SGE_PAGE_SIZE, DMA_FROM_DEVICE);
+	if (unlikely(dma_mapping_error(&bp->pdev->dev, mapping))) {
+		BNX2X_ERR("Can't map sge\n");
+		return -ENOMEM;
+	}
+
 	get_page(pool->page);
 	sw_buf->page = pool->page;
 	sw_buf->offset = pool->offset;
 
-	mapping = pool->dma + sw_buf->offset;
 	dma_unmap_addr_set(sw_buf, mapping, mapping);
 
 	sge->addr_hi = cpu_to_le32(U64_HI(mapping));
@@ -648,9 +645,9 @@ static int bnx2x_fill_frag_skb(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 			return err;
 		}
 
-		dma_unmap_single(&bp->pdev->dev,
-				 dma_unmap_addr(&old_rx_pg, mapping),
-				 SGE_PAGE_SIZE, DMA_FROM_DEVICE);
+		dma_unmap_page(&bp->pdev->dev,
+			       dma_unmap_addr(&old_rx_pg, mapping),
+			       SGE_PAGE_SIZE, DMA_FROM_DEVICE);
 		/* Add one frag and update the appropriate fields in the skb */
 		if (fp->mode == TPA_MODE_LRO)
 			skb_fill_page_desc(skb, j, old_rx_pg.page,
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index 2b30081ec2..03b7404d5b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -807,8 +807,8 @@ static inline void bnx2x_free_rx_sge(struct bnx2x *bp,
 	/* Since many fragments can share the same page, make sure to
 	 * only unmap and free the page once.
 	 */
-	dma_unmap_single(&bp->pdev->dev, dma_unmap_addr(sw_buf, mapping),
-			 SGE_PAGE_SIZE, DMA_FROM_DEVICE);
+	dma_unmap_page(&bp->pdev->dev, dma_unmap_addr(sw_buf, mapping),
+		       SGE_PAGE_SIZE, DMA_FROM_DEVICE);
 
 	put_page(page);
 
@@ -974,14 +974,6 @@ static inline void bnx2x_free_rx_mem_pool(struct bnx2x *bp,
 	if (!pool->page)
 		return;
 
-	/* Page was not fully fragmented.  Unmap unused space */
-	if (pool->offset < PAGE_SIZE) {
-		dma_addr_t dma = pool->dma + pool->offset;
-		int size = PAGE_SIZE - pool->offset;
-
-		dma_unmap_single(&bp->pdev->dev, dma, size, DMA_FROM_DEVICE);
-	}
-
 	put_page(pool->page);
 
 	pool->page = NULL;
-- 
2.4.3
