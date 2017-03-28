From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 3/3] bnxt_en: Fix DMA unmapping of the RX buffers in XDP mode during shutdown.
Date: Tue, 28 Mar 2017 19:47:31 -0400
Message-ID: <1490744851-19985-4-git-send-email-michael.chan@broadcom.com>
References: <1490744851-19985-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f170.google.com ([209.85.128.170]:34527 "EHLO
        mail-wr0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932654AbdC1Xsc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 19:48:32 -0400
Received: by mail-wr0-f170.google.com with SMTP id l43so59477wre.1
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 16:48:30 -0700 (PDT)
In-Reply-To: <1490744851-19985-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In bnxt_free_rx_skbs(), which is called to free up all RX buffers during
shutdown, we need to unmap the page if we are running in XDP mode.

Fixes: c61fb99cae51 ("bnxt_en: Add RX page mode support.")
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 6c856878..1f1e54b 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -1983,20 +1983,25 @@ static void bnxt_free_rx_skbs(struct bnxt *bp)
 
 		for (j = 0; j < max_idx; j++) {
 			struct bnxt_sw_rx_bd *rx_buf = &rxr->rx_buf_ring[j];
+			dma_addr_t mapping = rx_buf->mapping;
 			void *data = rx_buf->data;
 
 			if (!data)
 				continue;
 
-			dma_unmap_single(&pdev->dev, rx_buf->mapping,
-					 bp->rx_buf_use_size, bp->rx_dir);
-
 			rx_buf->data = NULL;
 
-			if (BNXT_RX_PAGE_MODE(bp))
+			if (BNXT_RX_PAGE_MODE(bp)) {
+				mapping -= bp->rx_dma_offset;
+				dma_unmap_page(&pdev->dev, mapping,
+					       PAGE_SIZE, bp->rx_dir);
 				__free_page(data);
-			else
+			} else {
+				dma_unmap_single(&pdev->dev, mapping,
+						 bp->rx_buf_use_size,
+						 bp->rx_dir);
 				kfree(data);
+			}
 		}
 
 		for (j = 0; j < max_agg_idx; j++) {
-- 
1.8.3.1
