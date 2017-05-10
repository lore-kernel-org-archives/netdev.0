From: Shannon Nelson <shannon.nelson@oracle.com>
Subject: [PATCH v2 net-next] bnxt: add dma mapping attributes
Date: Tue,  9 May 2017 18:30:12 -0700
Message-ID: <1494379812-282087-1-git-send-email-shannon.nelson@oracle.com>
Cc: sparclinux@vger.kernel.org, michael.chan@broadcom.com,
        Shannon Nelson <shannon.nelson@oracle.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <sparclinux-owner@vger.kernel.org>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On the SPARC platform we need to use the DMA_ATTR_WEAK_ORDERING attribute
in our Rx path dma mapping in order to get the expected performance out
of the receive path.  Adding it to the Tx path has little effect, so
that's not a part of this patch.

Signed-off-by: Shannon Nelson <shannon.nelson@oracle.com>
Reviewed-by: Tushar Dave <tushar.n.dave@oracle.com>
Reviewed-by: Tom Saeger <tom.saeger@oracle.com>
---
v2: simplify by getting rid of the driver-specific ifdef and define

 drivers/net/ethernet/broadcom/bnxt/bnxt.c |   56 +++++++++++++++++-----------
 1 files changed, 34 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 1f1e54b..687f852 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -582,7 +582,8 @@ static void bnxt_tx_int(struct bnxt *bp, struct bnxt_napi *bnapi, int nr_pkts)
 	if (!page)
 		return NULL;
 
-	*mapping = dma_map_page(dev, page, 0, PAGE_SIZE, bp->rx_dir);
+	*mapping = dma_map_page_attrs(dev, page, 0, PAGE_SIZE, bp->rx_dir,
+				      DMA_ATTR_WEAK_ORDERING);
 	if (dma_mapping_error(dev, *mapping)) {
 		__free_page(page);
 		return NULL;
@@ -601,8 +602,9 @@ static void bnxt_tx_int(struct bnxt *bp, struct bnxt_napi *bnapi, int nr_pkts)
 	if (!data)
 		return NULL;
 
-	*mapping = dma_map_single(&pdev->dev, data + bp->rx_dma_offset,
-				  bp->rx_buf_use_size, bp->rx_dir);
+	*mapping = dma_map_single_attrs(&pdev->dev, data + bp->rx_dma_offset,
+					bp->rx_buf_use_size, bp->rx_dir,
+					DMA_ATTR_WEAK_ORDERING);
 
 	if (dma_mapping_error(&pdev->dev, *mapping)) {
 		kfree(data);
@@ -705,8 +707,9 @@ static inline int bnxt_alloc_rx_page(struct bnxt *bp,
 			return -ENOMEM;
 	}
 
-	mapping = dma_map_page(&pdev->dev, page, offset, BNXT_RX_PAGE_SIZE,
-			       PCI_DMA_FROMDEVICE);
+	mapping = dma_map_page_attrs(&pdev->dev, page, offset,
+				     BNXT_RX_PAGE_SIZE, PCI_DMA_FROMDEVICE,
+				     DMA_ATTR_WEAK_ORDERING);
 	if (dma_mapping_error(&pdev->dev, mapping)) {
 		__free_page(page);
 		return -EIO;
@@ -799,7 +802,8 @@ static void bnxt_reuse_rx_agg_bufs(struct bnxt_napi *bnapi, u16 cp_cons,
 		return NULL;
 	}
 	dma_addr -= bp->rx_dma_offset;
-	dma_unmap_page(&bp->pdev->dev, dma_addr, PAGE_SIZE, bp->rx_dir);
+	dma_unmap_page_attrs(&bp->pdev->dev, dma_addr, PAGE_SIZE, bp->rx_dir,
+			     DMA_ATTR_WEAK_ORDERING);
 
 	if (unlikely(!payload))
 		payload = eth_get_headlen(data_ptr, len);
@@ -841,8 +845,8 @@ static void bnxt_reuse_rx_agg_bufs(struct bnxt_napi *bnapi, u16 cp_cons,
 	}
 
 	skb = build_skb(data, 0);
-	dma_unmap_single(&bp->pdev->dev, dma_addr, bp->rx_buf_use_size,
-			 bp->rx_dir);
+	dma_unmap_single_attrs(&bp->pdev->dev, dma_addr, bp->rx_buf_use_size,
+			       bp->rx_dir, DMA_ATTR_WEAK_ORDERING);
 	if (!skb) {
 		kfree(data);
 		return NULL;
@@ -909,8 +913,9 @@ static void bnxt_reuse_rx_agg_bufs(struct bnxt_napi *bnapi, u16 cp_cons,
 			return NULL;
 		}
 
-		dma_unmap_page(&pdev->dev, mapping, BNXT_RX_PAGE_SIZE,
-			       PCI_DMA_FROMDEVICE);
+		dma_unmap_page_attrs(&pdev->dev, mapping, BNXT_RX_PAGE_SIZE,
+				     PCI_DMA_FROMDEVICE,
+				     DMA_ATTR_WEAK_ORDERING);
 
 		skb->data_len += frag_len;
 		skb->len += frag_len;
@@ -1329,8 +1334,9 @@ static void bnxt_abort_tpa(struct bnxt *bp, struct bnxt_napi *bnapi,
 		tpa_info->mapping = new_mapping;
 
 		skb = build_skb(data, 0);
-		dma_unmap_single(&bp->pdev->dev, mapping, bp->rx_buf_use_size,
-				 bp->rx_dir);
+		dma_unmap_single_attrs(&bp->pdev->dev, mapping,
+				       bp->rx_buf_use_size, bp->rx_dir,
+				       DMA_ATTR_WEAK_ORDERING);
 
 		if (!skb) {
 			kfree(data);
@@ -1971,9 +1977,11 @@ static void bnxt_free_rx_skbs(struct bnxt *bp)
 				if (!data)
 					continue;
 
-				dma_unmap_single(&pdev->dev, tpa_info->mapping,
-						 bp->rx_buf_use_size,
-						 bp->rx_dir);
+				dma_unmap_single_attrs(&pdev->dev,
+						       tpa_info->mapping,
+						       bp->rx_buf_use_size,
+						       bp->rx_dir,
+						       DMA_ATTR_WEAK_ORDERING);
 
 				tpa_info->data = NULL;
 
@@ -1993,13 +2001,15 @@ static void bnxt_free_rx_skbs(struct bnxt *bp)
 
 			if (BNXT_RX_PAGE_MODE(bp)) {
 				mapping -= bp->rx_dma_offset;
-				dma_unmap_page(&pdev->dev, mapping,
-					       PAGE_SIZE, bp->rx_dir);
+				dma_unmap_page_attrs(&pdev->dev, mapping,
+						     PAGE_SIZE, bp->rx_dir,
+						     DMA_ATTR_WEAK_ORDERING);
 				__free_page(data);
 			} else {
-				dma_unmap_single(&pdev->dev, mapping,
-						 bp->rx_buf_use_size,
-						 bp->rx_dir);
+				dma_unmap_single_attrs(&pdev->dev, mapping,
+						       bp->rx_buf_use_size,
+						       bp->rx_dir,
+						       DMA_ATTR_WEAK_ORDERING);
 				kfree(data);
 			}
 		}
@@ -2012,8 +2022,10 @@ static void bnxt_free_rx_skbs(struct bnxt *bp)
 			if (!page)
 				continue;
 
-			dma_unmap_page(&pdev->dev, rx_agg_buf->mapping,
-				       BNXT_RX_PAGE_SIZE, PCI_DMA_FROMDEVICE);
+			dma_unmap_page_attrs(&pdev->dev, rx_agg_buf->mapping,
+					     BNXT_RX_PAGE_SIZE,
+					     PCI_DMA_FROMDEVICE,
+					     DMA_ATTR_WEAK_ORDERING);
 
 			rx_agg_buf->page = NULL;
 			__clear_bit(j, rxr->rx_agg_bmap);
-- 
1.7.1

