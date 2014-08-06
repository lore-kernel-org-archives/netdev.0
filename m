From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [PATCH] myri10ge: check for pci_map_page errors
Date: Wed, 6 Aug 2014 15:25:16 +0200
Message-ID: <20140806132516.GA3222@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hyong-Youb Kim <hykim@myri.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43464 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751770AbaHFN1P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Aug 2014 09:27:15 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On IOMMU systems DMA mapping can fail, we need to check for that
possibility.

Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
---
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c | 21 ++++++++++++++++++---
 1 file changed, 18 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
index f3d5d79..17f869a 100644
--- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
+++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
@@ -872,6 +872,10 @@ static int myri10ge_dma_test(struct myri10ge_priv *mgp, int test_type)
 		return -ENOMEM;
 	dmatest_bus = pci_map_page(mgp->pdev, dmatest_page, 0, PAGE_SIZE,
 				   DMA_BIDIRECTIONAL);
+	if (unlikely(pci_dma_mapping_error(mgp->pdev, dmatest_bus))) {
+		__free_page(dmatest_page);
+		return -ENOMEM;
+	}
 
 	/* Run a small DMA test.
 	 * The magic multipliers to the length tell the firmware
@@ -1293,6 +1297,7 @@ myri10ge_alloc_rx_pages(struct myri10ge_priv *mgp, struct myri10ge_rx_buf *rx,
 			int bytes, int watchdog)
 {
 	struct page *page;
+	dma_addr_t bus;
 	int idx;
 #if MYRI10GE_ALLOC_SIZE > 4096
 	int end_offset;
@@ -1317,11 +1322,21 @@ myri10ge_alloc_rx_pages(struct myri10ge_priv *mgp, struct myri10ge_rx_buf *rx,
 					rx->watchdog_needed = 1;
 				return;
 			}
+
+			bus = pci_map_page(mgp->pdev, page, 0,
+					   MYRI10GE_ALLOC_SIZE,
+					   PCI_DMA_FROMDEVICE);
+			if (unlikely(pci_dma_mapping_error(mgp->pdev, bus))) {
+				__free_pages(page, MYRI10GE_ALLOC_ORDER);
+				if (rx->fill_cnt - rx->cnt < 16)
+					rx->watchdog_needed = 1;
+				return;
+			}
+
 			rx->page = page;
 			rx->page_offset = 0;
-			rx->bus = pci_map_page(mgp->pdev, page, 0,
-					       MYRI10GE_ALLOC_SIZE,
-					       PCI_DMA_FROMDEVICE);
+			rx->bus = bus;
+
 		}
 		rx->info[idx].page = rx->page;
 		rx->info[idx].page_offset = rx->page_offset;
-- 
1.9.0
