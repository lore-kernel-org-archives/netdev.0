From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 13/24] ixgbe: recycle pages in packet split mode
Date: Mon, 08 Sep 2008 21:48:06 -0700
Message-ID: <20080909044806.18904.56939.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080909044734.18904.93208.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.168]:57666 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752618AbYIIEsI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 00:48:08 -0400
Received: by wf-out-1314.google.com with SMTP id 27so1867513wfd.4
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2008 21:48:08 -0700 (PDT)
In-Reply-To: <20080909044734.18904.93208.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

most of the time we only need 1500 bytes for a packet which means
we don't need a whole 4k page for each packet.  Share the allocation
by using a reference count to the page and giving half to two
receive descriptors.  This can enable us to use packet split mode
all the time due to the performance increase of allocating half
the pages.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h      |    1 +
 drivers/net/ixgbe/ixgbe_main.c |   49 +++++++++++++++++++++++++---------------
 2 files changed, 32 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 064af67..71ddac6 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -114,6 +114,7 @@ struct ixgbe_rx_buffer {
 	dma_addr_t dma;
 	struct page *page;
 	dma_addr_t page_dma;
+	unsigned int page_offset;
 };
 
 struct ixgbe_queue_stats {
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index a78be56..e277cc5 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -493,16 +493,24 @@ static void ixgbe_alloc_rx_buffers(struct ixgbe_adapter *adapter,
 	while (cleaned_count--) {
 		rx_desc = IXGBE_RX_DESC_ADV(*rx_ring, i);
 
-		if (!bi->page &&
+		if (!bi->page_dma &&
 		    (adapter->flags & IXGBE_FLAG_RX_PS_ENABLED)) {
-			bi->page = alloc_page(GFP_ATOMIC);
 			if (!bi->page) {
-				adapter->alloc_rx_page_failed++;
-				goto no_buffers;
+				bi->page = alloc_page(GFP_ATOMIC);
+				if (!bi->page) {
+					adapter->alloc_rx_page_failed++;
+					goto no_buffers;
+				}
+				bi->page_offset = 0;
+			} else {
+				/* use a half page if we're re-using */
+				bi->page_offset ^= (PAGE_SIZE / 2);
 			}
-			bi->page_dma = pci_map_page(pdev, bi->page, 0,
-	                                            PAGE_SIZE,
-	                                            PCI_DMA_FROMDEVICE);
+
+			bi->page_dma = pci_map_page(pdev, bi->page,
+			                            bi->page_offset,
+			                            (PAGE_SIZE / 2),
+			                            PCI_DMA_FROMDEVICE);
 		}
 
 		if (!bi->skb) {
@@ -596,7 +604,7 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_adapter *adapter,
 		if (adapter->flags & IXGBE_FLAG_RX_PS_ENABLED) {
 			hdr_info = le16_to_cpu(ixgbe_get_hdr_info(rx_desc));
 			len = (hdr_info & IXGBE_RXDADV_HDRBUFLEN_MASK) >>
-	                       IXGBE_RXDADV_HDRBUFLEN_SHIFT;
+			       IXGBE_RXDADV_HDRBUFLEN_SHIFT;
 			if (hdr_info & IXGBE_RXDADV_SPH)
 				adapter->rx_hdr_split++;
 			if (len > IXGBE_RX_HDR_SIZE)
@@ -620,11 +628,18 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_adapter *adapter,
 
 		if (upper_len) {
 			pci_unmap_page(pdev, rx_buffer_info->page_dma,
-				       PAGE_SIZE, PCI_DMA_FROMDEVICE);
+			               PAGE_SIZE / 2, PCI_DMA_FROMDEVICE);
 			rx_buffer_info->page_dma = 0;
 			skb_fill_page_desc(skb, skb_shinfo(skb)->nr_frags,
-					   rx_buffer_info->page, 0, upper_len);
-			rx_buffer_info->page = NULL;
+			                   rx_buffer_info->page,
+			                   rx_buffer_info->page_offset,
+			                   upper_len);
+
+			if ((rx_ring->rx_buf_len > (PAGE_SIZE / 2)) ||
+			    (page_count(rx_buffer_info->page) != 1))
+				rx_buffer_info->page = NULL;
+			else
+				get_page(rx_buffer_info->page);
 
 			skb->len += upper_len;
 			skb->data_len += upper_len;
@@ -647,6 +662,7 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_adapter *adapter,
 			rx_buffer_info->skb = next_buffer->skb;
 			rx_buffer_info->dma = next_buffer->dma;
 			next_buffer->skb = skb;
+			next_buffer->dma = 0;
 			adapter->non_eop_descs++;
 			goto next_desc;
 		}
@@ -1534,10 +1550,7 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 	int rx_buf_len;
 
 	/* Decide whether to use packet split mode or not */
-	if (netdev->mtu > ETH_DATA_LEN)
-		adapter->flags |= IXGBE_FLAG_RX_PS_ENABLED;
-	else
-		adapter->flags &= ~IXGBE_FLAG_RX_PS_ENABLED;
+	adapter->flags |= IXGBE_FLAG_RX_PS_ENABLED;
 
 	/* Set the RX buffer length according to the mode */
 	if (adapter->flags & IXGBE_FLAG_RX_PS_ENABLED) {
@@ -2018,12 +2031,12 @@ static void ixgbe_clean_rx_ring(struct ixgbe_adapter *adapter,
 		}
 		if (!rx_buffer_info->page)
 			continue;
-		pci_unmap_page(pdev, rx_buffer_info->page_dma, PAGE_SIZE,
-			       PCI_DMA_FROMDEVICE);
+		pci_unmap_page(pdev, rx_buffer_info->page_dma, PAGE_SIZE / 2,
+		               PCI_DMA_FROMDEVICE);
 		rx_buffer_info->page_dma = 0;
-
 		put_page(rx_buffer_info->page);
 		rx_buffer_info->page = NULL;
+		rx_buffer_info->page_offset = 0;
 	}
 
 	size = sizeof(struct ixgbe_rx_buffer) * rx_ring->count;

