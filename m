From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next v2 04/12] bnxt_en: Parameterize RX buffer offsets.
Date: Thu,  2 Feb 2017 11:55:32 -0500
Message-ID: <1486054540-366-5-git-send-email-michael.chan@broadcom.com>
References: <1486054540-366-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:35502 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751377AbdBBQ4A (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 11:56:00 -0500
Received: by mail-pf0-f169.google.com with SMTP id f144so6486914pfa.2
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 08:56:00 -0800 (PST)
In-Reply-To: <1486054540-366-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert the global constants BNXT_RX_OFFSET and BNXT_RX_DMA_OFFSET to
device parameters.  This will make it easier to support XDP with
headroom support which requires different RX buffer offsets.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 15 +++++++++------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h |  2 ++
 2 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 7a6a1f8..77d1074 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -583,7 +583,7 @@ static inline u8 *__bnxt_alloc_rx_data(struct bnxt *bp, dma_addr_t *mapping,
 	if (!data)
 		return NULL;
 
-	*mapping = dma_map_single(&pdev->dev, data + BNXT_RX_DMA_OFFSET,
+	*mapping = dma_map_single(&pdev->dev, data + bp->rx_dma_offset,
 				  bp->rx_buf_use_size, bp->rx_dir);
 
 	if (dma_mapping_error(&pdev->dev, *mapping)) {
@@ -607,7 +607,7 @@ static inline int bnxt_alloc_rx_data(struct bnxt *bp,
 		return -ENOMEM;
 
 	rx_buf->data = data;
-	rx_buf->data_ptr = data + BNXT_RX_OFFSET;
+	rx_buf->data_ptr = data + bp->rx_offset;
 	rx_buf->mapping = mapping;
 
 	rxbd->rx_bd_haddr = cpu_to_le64(mapping);
@@ -776,7 +776,7 @@ static struct sk_buff *bnxt_rx_skb(struct bnxt *bp,
 		return NULL;
 	}
 
-	skb_reserve(skb, BNXT_RX_OFFSET);
+	skb_reserve(skb, bp->rx_offset);
 	skb_put(skb, offset_and_len & 0xffff);
 	return skb;
 }
@@ -1253,7 +1253,7 @@ static inline struct sk_buff *bnxt_tpa_end(struct bnxt *bp,
 		}
 
 		tpa_info->data = new_data;
-		tpa_info->data_ptr = new_data + BNXT_RX_OFFSET;
+		tpa_info->data_ptr = new_data + bp->rx_offset;
 		tpa_info->mapping = new_mapping;
 
 		skb = build_skb(data, 0);
@@ -1265,7 +1265,7 @@ static inline struct sk_buff *bnxt_tpa_end(struct bnxt *bp,
 			bnxt_abort_tpa(bp, bnapi, cp_cons, agg_bufs);
 			return NULL;
 		}
-		skb_reserve(skb, BNXT_RX_OFFSET);
+		skb_reserve(skb, bp->rx_offset);
 		skb_put(skb, len);
 	}
 
@@ -2329,7 +2329,7 @@ static int bnxt_init_one_rx_ring(struct bnxt *bp, int ring_nr)
 					return -ENOMEM;
 
 				rxr->rx_tpa[i].data = data;
-				rxr->rx_tpa[i].data_ptr = data + BNXT_RX_OFFSET;
+				rxr->rx_tpa[i].data_ptr = data + bp->rx_offset;
 				rxr->rx_tpa[i].mapping = mapping;
 			}
 		} else {
@@ -2345,6 +2345,9 @@ static int bnxt_init_rx_rings(struct bnxt *bp)
 {
 	int i, rc = 0;
 
+	bp->rx_offset = BNXT_RX_OFFSET;
+	bp->rx_dma_offset = BNXT_RX_DMA_OFFSET;
+
 	for (i = 0; i < bp->rx_nr_rings; i++) {
 		rc = bnxt_init_one_rx_ring(bp, i);
 		if (rc)
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index b8bad06..5e0ec9b 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -997,6 +997,8 @@ struct bnxt {
 
 	u32			rx_buf_size;
 	u32			rx_buf_use_size;	/* useable size */
+	u16			rx_offset;
+	u16			rx_dma_offset;
 	enum dma_data_direction	rx_dir;
 	u32			rx_ring_size;
 	u32			rx_agg_ring_size;
-- 
1.8.3.1
