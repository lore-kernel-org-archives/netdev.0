From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 02/10] bnxt_en: Add bp->rx_dir field for rx buffer DMA direction.
Date: Mon, 30 Jan 2017 20:49:27 -0500
Message-ID: <1485827375-20421-3-git-send-email-michael.chan@broadcom.com>
References: <1485827375-20421-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:36681 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751702AbdAaBur (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 20:50:47 -0500
Received: by mail-pf0-f172.google.com with SMTP id 189so96674753pfu.3
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 17:49:57 -0800 (PST)
In-Reply-To: <1485827375-20421-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When driver is running in XDP mode, rx buffers are DMA mapped as
DMA_BIDIRECTIONAL.  Add a field so the code will map/unmap rx buffers
according to this field.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 22 ++++++++++------------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h |  1 +
 2 files changed, 11 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index d419199..c343ade 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -584,7 +584,7 @@ static inline u8 *__bnxt_alloc_rx_data(struct bnxt *bp, dma_addr_t *mapping,
 		return NULL;
 
 	*mapping = dma_map_single(&pdev->dev, data + BNXT_RX_DMA_OFFSET,
-				  bp->rx_buf_use_size, PCI_DMA_FROMDEVICE);
+				  bp->rx_buf_use_size, bp->rx_dir);
 
 	if (dma_mapping_error(&pdev->dev, *mapping)) {
 		kfree(data);
@@ -771,7 +771,7 @@ static struct sk_buff *bnxt_rx_skb(struct bnxt *bp,
 
 	skb = build_skb(data, 0);
 	dma_unmap_single(&bp->pdev->dev, dma_addr, bp->rx_buf_use_size,
-			 PCI_DMA_FROMDEVICE);
+			 bp->rx_dir);
 	if (!skb) {
 		kfree(data);
 		return NULL;
@@ -877,15 +877,14 @@ static inline struct sk_buff *bnxt_copy_skb(struct bnxt_napi *bnapi, u8 *data,
 	if (!skb)
 		return NULL;
 
-	dma_sync_single_for_cpu(&pdev->dev, mapping,
-				bp->rx_copy_thresh, PCI_DMA_FROMDEVICE);
+	dma_sync_single_for_cpu(&pdev->dev, mapping, bp->rx_copy_thresh,
+				bp->rx_dir);
 
 	memcpy(skb->data - NET_IP_ALIGN, data - NET_IP_ALIGN,
 	       len + NET_IP_ALIGN);
 
-	dma_sync_single_for_device(&pdev->dev, mapping,
-				   bp->rx_copy_thresh,
-				   PCI_DMA_FROMDEVICE);
+	dma_sync_single_for_device(&pdev->dev, mapping, bp->rx_copy_thresh,
+				   bp->rx_dir);
 
 	skb_put(skb, len);
 	return skb;
@@ -1260,7 +1259,7 @@ static inline struct sk_buff *bnxt_tpa_end(struct bnxt *bp,
 
 		skb = build_skb(data, 0);
 		dma_unmap_single(&bp->pdev->dev, mapping, bp->rx_buf_use_size,
-				 PCI_DMA_FROMDEVICE);
+				 bp->rx_dir);
 
 		if (!skb) {
 			kfree(data);
@@ -1879,8 +1878,7 @@ static void bnxt_free_rx_skbs(struct bnxt *bp)
 				dma_unmap_single(
 					&pdev->dev,
 					dma_unmap_addr(tpa_info, mapping),
-					bp->rx_buf_use_size,
-					PCI_DMA_FROMDEVICE);
+					bp->rx_buf_use_size, bp->rx_dir);
 
 				tpa_info->data = NULL;
 
@@ -1897,8 +1895,7 @@ static void bnxt_free_rx_skbs(struct bnxt *bp)
 
 			dma_unmap_single(&pdev->dev,
 					 dma_unmap_addr(rx_buf, mapping),
-					 bp->rx_buf_use_size,
-					 PCI_DMA_FROMDEVICE);
+					 bp->rx_buf_use_size, bp->rx_dir);
 
 			rx_buf->data = NULL;
 
@@ -2563,6 +2560,7 @@ void bnxt_set_ring_params(struct bnxt *bp)
 
 static int bnxt_set_rx_skb_mode(struct bnxt *bp)
 {
+	bp->rx_dir = DMA_FROM_DEVICE;
 	bp->rx_skb_func = bnxt_rx_skb;
 	return 0;
 }
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 33302b0..b0da02d 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -997,6 +997,7 @@ struct bnxt {
 
 	u32			rx_buf_size;
 	u32			rx_buf_use_size;	/* useable size */
+	enum dma_data_direction	rx_dir;
 	u32			rx_ring_size;
 	u32			rx_agg_ring_size;
 	u32			rx_copy_thresh;
-- 
1.8.3.1
