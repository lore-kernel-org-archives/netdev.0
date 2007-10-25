From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 1/4] e1000e: Fix jumbo frame receive code.
Date: Thu, 25 Oct 2007 13:57:44 -0700
Message-ID: <20071025205744.32645.59503.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, auke-jan.h.kok@intel.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:38731 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752206AbXJYU56 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2007 16:57:58 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix allocation and freeing of jumbo frames where several bugs
were recently introduced by cleanups after we forked this code
from e1000. This moves ps_pages to buffer_info where it really
belongs and makes it a dynamically allocated array. The penalty
is not that high since it's allocated outside of the buffer_info
struct anyway.

Without this patch all jumbo frames are completely broken and the
driver panics.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/e1000.h  |    4 +-
 drivers/net/e1000e/netdev.c |  102 ++++++++++++++++++++++---------------------
 2 files changed, 54 insertions(+), 52 deletions(-)

diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index d2499bb..811eada 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -123,6 +123,8 @@ struct e1000_buffer {
 		};
 		/* RX */
 		struct page *page;
+		/* arrays of page information for packet split */
+		struct e1000_ps_page *ps_pages;
 	};
 
 };
@@ -142,8 +144,6 @@ struct e1000_ring {
 	/* array of buffer information structs */
 	struct e1000_buffer *buffer_info;
 
-	/* arrays of page information for packet split */
-	struct e1000_ps_page *ps_pages;
 	struct sk_buff *rx_skb_top;
 
 	struct e1000_queue_stats stats;
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 033e124..46c5ac6 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -245,37 +245,36 @@ static void e1000_alloc_rx_buffers_ps(struct e1000_adapter *adapter,
 		rx_desc = E1000_RX_DESC_PS(*rx_ring, i);
 
 		for (j = 0; j < PS_PAGE_BUFFERS; j++) {
-			ps_page = &rx_ring->ps_pages[(i * PS_PAGE_BUFFERS)
-						     + j];
-			if (j < adapter->rx_ps_pages) {
+			ps_page = &buffer_info->ps_pages[j];
+			if (j >= adapter->rx_ps_pages) {
+				/* all unused desc entries get hw null ptr */
+				rx_desc->read.buffer_addr[j+1] = ~0;
+				continue;
+			}
+			if (!ps_page->page) {
+				ps_page->page = alloc_page(GFP_ATOMIC);
 				if (!ps_page->page) {
-					ps_page->page = alloc_page(GFP_ATOMIC);
-					if (!ps_page->page) {
-						adapter->alloc_rx_buff_failed++;
-						goto no_buffers;
-					}
-					ps_page->dma = pci_map_page(pdev,
-							   ps_page->page,
-							   0, PAGE_SIZE,
-							   PCI_DMA_FROMDEVICE);
-					if (pci_dma_mapping_error(
-							ps_page->dma)) {
-						dev_err(&adapter->pdev->dev,
-						  "RX DMA page map failed\n");
-						adapter->rx_dma_failed++;
-						goto no_buffers;
-					}
+					adapter->alloc_rx_buff_failed++;
+					goto no_buffers;
+				}
+				ps_page->dma = pci_map_page(pdev,
+						   ps_page->page,
+						   0, PAGE_SIZE,
+						   PCI_DMA_FROMDEVICE);
+				if (pci_dma_mapping_error(ps_page->dma)) {
+					dev_err(&adapter->pdev->dev,
+					  "RX DMA page map failed\n");
+					adapter->rx_dma_failed++;
+					goto no_buffers;
 				}
-				/*
-				 * Refresh the desc even if buffer_addrs
-				 * didn't change because each write-back
-				 * erases this info.
-				 */
-				rx_desc->read.buffer_addr[j+1] =
-				     cpu_to_le64(ps_page->dma);
-			} else {
-				rx_desc->read.buffer_addr[j+1] = ~0;
 			}
+			/*
+			 * Refresh the desc even if buffer_addrs
+			 * didn't change because each write-back
+			 * erases this info.
+			 */
+			rx_desc->read.buffer_addr[j+1] =
+			     cpu_to_le64(ps_page->dma);
 		}
 
 		skb = netdev_alloc_skb(netdev,
@@ -953,7 +952,7 @@ static bool e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
 		    ((length + l1) <= adapter->rx_ps_bsize0)) {
 			u8 *vaddr;
 
-			ps_page = &rx_ring->ps_pages[i * PS_PAGE_BUFFERS];
+			ps_page = &buffer_info->ps_pages[0];
 
 			/* there is no documentation about how to call
 			 * kmap_atomic, so we can't hold the mapping
@@ -977,7 +976,7 @@ static bool e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
 			if (!length)
 				break;
 
-			ps_page = &rx_ring->ps_pages[(i * PS_PAGE_BUFFERS) + j];
+			ps_page = &buffer_info->ps_pages[j];
 			pci_unmap_page(pdev, ps_page->dma, PAGE_SIZE,
 				       PCI_DMA_FROMDEVICE);
 			ps_page->dma = 0;
@@ -1043,7 +1042,6 @@ static void e1000_clean_rx_ring(struct e1000_adapter *adapter)
 	struct e1000_buffer *buffer_info;
 	struct e1000_ps_page *ps_page;
 	struct pci_dev *pdev = adapter->pdev;
-	unsigned long size;
 	unsigned int i, j;
 
 	/* Free all the Rx ring sk_buffs */
@@ -1075,8 +1073,7 @@ static void e1000_clean_rx_ring(struct e1000_adapter *adapter)
 		}
 
 		for (j = 0; j < PS_PAGE_BUFFERS; j++) {
-			ps_page = &rx_ring->ps_pages[(i * PS_PAGE_BUFFERS)
-						     + j];
+			ps_page = &buffer_info->ps_pages[j];
 			if (!ps_page->page)
 				break;
 			pci_unmap_page(pdev, ps_page->dma, PAGE_SIZE,
@@ -1093,12 +1090,6 @@ static void e1000_clean_rx_ring(struct e1000_adapter *adapter)
 		rx_ring->rx_skb_top = NULL;
 	}
 
-	size = sizeof(struct e1000_buffer) * rx_ring->count;
-	memset(rx_ring->buffer_info, 0, size);
-	size = sizeof(struct e1000_ps_page)
-	       * (rx_ring->count * PS_PAGE_BUFFERS);
-	memset(rx_ring->ps_pages, 0, size);
-
 	/* Zero out the descriptor ring */
 	memset(rx_ring->desc, 0, rx_ring->size);
 
@@ -1421,7 +1412,8 @@ err:
 int e1000e_setup_rx_resources(struct e1000_adapter *adapter)
 {
 	struct e1000_ring *rx_ring = adapter->rx_ring;
-	int size, desc_len, err = -ENOMEM;
+	struct e1000_buffer *buffer_info;
+	int i, size, desc_len, err = -ENOMEM;
 
 	size = sizeof(struct e1000_buffer) * rx_ring->count;
 	rx_ring->buffer_info = vmalloc(size);
@@ -1429,11 +1421,14 @@ int e1000e_setup_rx_resources(struct e1000_adapter *adapter)
 		goto err;
 	memset(rx_ring->buffer_info, 0, size);
 
-	rx_ring->ps_pages = kcalloc(rx_ring->count * PS_PAGE_BUFFERS,
-				    sizeof(struct e1000_ps_page),
-				    GFP_KERNEL);
-	if (!rx_ring->ps_pages)
-		goto err;
+	for (i = 0; i < rx_ring->count; i++) {
+		buffer_info = &rx_ring->buffer_info[i];
+		buffer_info->ps_pages = kcalloc(PS_PAGE_BUFFERS,
+						sizeof(struct e1000_ps_page),
+						GFP_KERNEL);
+		if (!buffer_info->ps_pages)
+			goto err_pages;
+	}
 
 	desc_len = sizeof(union e1000_rx_desc_packet_split);
 
@@ -1443,16 +1438,21 @@ int e1000e_setup_rx_resources(struct e1000_adapter *adapter)
 
 	err = e1000_alloc_ring_dma(adapter, rx_ring);
 	if (err)
-		goto err;
+		goto err_pages;
 
 	rx_ring->next_to_clean = 0;
 	rx_ring->next_to_use = 0;
 	rx_ring->rx_skb_top = NULL;
 
 	return 0;
+
+err_pages:
+	for (i = 0; i < rx_ring->count; i++) {
+		buffer_info = &rx_ring->buffer_info[i];
+		kfree(buffer_info->ps_pages);
+	}
 err:
 	vfree(rx_ring->buffer_info);
-	kfree(rx_ring->ps_pages);
 	ndev_err(adapter->netdev,
 	"Unable to allocate memory for the transmit descriptor ring\n");
 	return err;
@@ -1518,15 +1518,17 @@ void e1000e_free_rx_resources(struct e1000_adapter *adapter)
 {
 	struct pci_dev *pdev = adapter->pdev;
 	struct e1000_ring *rx_ring = adapter->rx_ring;
+	int i;
 
 	e1000_clean_rx_ring(adapter);
 
+	for (i = 0; i < rx_ring->count; i++) {
+		kfree(rx_ring->buffer_info[i].ps_pages);
+	}
+
 	vfree(rx_ring->buffer_info);
 	rx_ring->buffer_info = NULL;
 
-	kfree(rx_ring->ps_pages);
-	rx_ring->ps_pages = NULL;
-
 	dma_free_coherent(&pdev->dev, rx_ring->size, rx_ring->desc,
 			  rx_ring->dma);
 	rx_ring->desc = NULL;
