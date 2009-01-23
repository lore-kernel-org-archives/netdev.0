From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 03/21] [next] qlge: Clean and optimize rx buf queue refill.
Date: Fri, 23 Jan 2009 07:16:21 -0800
Message-ID: <1232723799-8620-3-git-send-email-ron.mercer@qlogic.com>
References: <20090123151513.GA8526@linux-ox1b.qlogic.org>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:48587 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754237AbZAWPRu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 10:17:50 -0500
In-Reply-To: <20090123151513.GA8526@linux-ox1b.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rx buffers are passed to the chip in chunks of 16. This patch
causes the queue to be updated once at the end instead of every
16 buffers.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |   41 +++++++++++++++++++++++++++--------------
 1 files changed, 27 insertions(+), 14 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index e6f9146..340a8ac 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -922,8 +922,10 @@ static void ql_write_cq_idx(struct rx_ring *rx_ring)
 /* Process (refill) a large buffer queue. */
 static void ql_update_lbq(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 {
-	int clean_idx = rx_ring->lbq_clean_idx;
+	u32 clean_idx = rx_ring->lbq_clean_idx;
+	u32 start_idx = clean_idx;
 	struct bq_desc *lbq_desc;
+	struct page *page;
 	u64 map;
 	int i;
 
@@ -937,19 +939,22 @@ static void ql_update_lbq(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 				QPRINTK(qdev, RX_STATUS, DEBUG,
 					"lbq: getting new page for index %d.\n",
 					lbq_desc->index);
-				lbq_desc->p.lbq_page = alloc_page(GFP_ATOMIC);
-				if (lbq_desc->p.lbq_page == NULL) {
-					QPRINTK(qdev, RX_STATUS, ERR,
+				page = alloc_page(GFP_ATOMIC);
+				if (page == NULL) {
+					QPRINTK(qdev, DRV, ERR,
 						"Couldn't get a page.\n");
 					return;
 				}
+				lbq_desc->p.lbq_page = page;
 				map = pci_map_page(qdev->pdev,
-						   lbq_desc->p.lbq_page,
+						   page,
 						   0, PAGE_SIZE,
 						   PCI_DMA_FROMDEVICE);
 				if (pci_dma_mapping_error(qdev->pdev, map)) {
-					QPRINTK(qdev, RX_STATUS, ERR,
+					QPRINTK(qdev, DRV, ERR,
 						"PCI mapping failed.\n");
+					put_page(page);
+					lbq_desc->p.lbq_page = NULL;
 					return;
 				}
 				pci_unmap_addr_set(lbq_desc, mapaddr, map);
@@ -965,20 +970,25 @@ static void ql_update_lbq(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 		rx_ring->lbq_prod_idx += 16;
 		if (rx_ring->lbq_prod_idx == rx_ring->lbq_len)
 			rx_ring->lbq_prod_idx = 0;
+		rx_ring->lbq_free_cnt -= 16;
+	}
+
+	if (start_idx != clean_idx) {
 		QPRINTK(qdev, RX_STATUS, DEBUG,
 			"lbq: updating prod idx = %d.\n",
 			rx_ring->lbq_prod_idx);
 		ql_write_db_reg(rx_ring->lbq_prod_idx,
 				rx_ring->lbq_prod_idx_db_reg);
-		rx_ring->lbq_free_cnt -= 16;
 	}
 }
 
 /* Process (refill) a small buffer queue. */
 static void ql_update_sbq(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 {
-	int clean_idx = rx_ring->sbq_clean_idx;
+	u32 clean_idx = rx_ring->sbq_clean_idx;
+	u32 start_idx = clean_idx;
 	struct bq_desc *sbq_desc;
+	struct sk_buff *skb;
 	u64 map;
 	int i;
 
@@ -992,18 +1002,19 @@ static void ql_update_sbq(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 				QPRINTK(qdev, RX_STATUS, DEBUG,
 					"sbq: getting new skb for index %d.\n",
 					sbq_desc->index);
-				sbq_desc->p.skb =
+				skb =
 				    netdev_alloc_skb(qdev->ndev,
 						     rx_ring->sbq_buf_size);
-				if (sbq_desc->p.skb == NULL) {
+				if (skb == NULL) {
 					QPRINTK(qdev, PROBE, ERR,
 						"Couldn't get an skb.\n");
 					rx_ring->sbq_clean_idx = clean_idx;
 					return;
 				}
-				skb_reserve(sbq_desc->p.skb, QLGE_SB_PAD);
+				sbq_desc->p.skb = skb;
+				skb_reserve(skb, QLGE_SB_PAD);
 				map = pci_map_single(qdev->pdev,
-						     sbq_desc->p.skb->data,
+						     skb->data,
 						     rx_ring->sbq_buf_size /
 						     2, PCI_DMA_FROMDEVICE);
 				if (pci_dma_mapping_error(qdev->pdev, map)) {
@@ -1025,13 +1036,15 @@ static void ql_update_sbq(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 		rx_ring->sbq_prod_idx += 16;
 		if (rx_ring->sbq_prod_idx == rx_ring->sbq_len)
 			rx_ring->sbq_prod_idx = 0;
+		rx_ring->sbq_free_cnt -= 16;
+	}
+
+	if (start_idx != clean_idx) {
 		QPRINTK(qdev, RX_STATUS, DEBUG,
 			"sbq: updating prod idx = %d.\n",
 			rx_ring->sbq_prod_idx);
 		ql_write_db_reg(rx_ring->sbq_prod_idx,
 				rx_ring->sbq_prod_idx_db_reg);
-
-		rx_ring->sbq_free_cnt -= 16;
 	}
 }
 
-- 
1.6.0.2

