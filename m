From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/7] ixgbe: Let the Rx buffer allocation clear status bits instead of cleanup
Date: Fri, 10 Feb 2012 16:08:20 -0800
Message-ID: <1328918904-11511-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1328918904-11511-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:22454 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754862Ab2BKAI3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Feb 2012 19:08:29 -0500
In-Reply-To: <1328918904-11511-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change makes it so that we always clear the status/error bits in the
Rx descriptor in the allocation path instead of the cleanup path.  The
advantage to this is that we spend less time modifying data.  As such we
can modify the data once and then let it go cold in the cache instead of
writing it, reading it, and then writing it again.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  155 +++++++++++++++----------
 1 files changed, 93 insertions(+), 62 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 762f3377..538577b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1101,8 +1101,75 @@ static inline void ixgbe_release_rx_desc(struct ixgbe_ring *rx_ring, u32 val)
 	writel(val, rx_ring->tail);
 }
 
+static bool ixgbe_alloc_mapped_skb(struct ixgbe_ring *rx_ring,
+				   struct ixgbe_rx_buffer *bi)
+{
+	struct sk_buff *skb = bi->skb;
+	dma_addr_t dma = bi->dma;
+
+	if (dma)
+		return true;
+
+	if (likely(!skb)) {
+		skb = netdev_alloc_skb_ip_align(rx_ring->netdev,
+						rx_ring->rx_buf_len);
+		bi->skb = skb;
+		if (!skb) {
+			rx_ring->rx_stats.alloc_rx_buff_failed++;
+			return false;
+		}
+
+		/* initialize skb for ring */
+		skb_record_rx_queue(skb, rx_ring->queue_index);
+	}
+
+	dma = dma_map_single(rx_ring->dev, skb->data,
+			     rx_ring->rx_buf_len, DMA_FROM_DEVICE);
+
+	if (dma_mapping_error(rx_ring->dev, dma)) {
+		rx_ring->rx_stats.alloc_rx_buff_failed++;
+		return false;
+	}
+
+	bi->dma = dma;
+	return true;
+}
+
+static bool ixgbe_alloc_mapped_page(struct ixgbe_ring *rx_ring,
+				    struct ixgbe_rx_buffer *bi)
+{
+	struct page *page = bi->page;
+	dma_addr_t page_dma = bi->page_dma;
+	unsigned int page_offset = bi->page_offset ^ (PAGE_SIZE / 2);
+
+	if (page_dma)
+		return true;
+
+	if (!page) {
+		page = alloc_page(GFP_ATOMIC | __GFP_COLD);
+		bi->page = page;
+		if (unlikely(!page)) {
+			rx_ring->rx_stats.alloc_rx_page_failed++;
+			return false;
+		}
+	}
+
+	page_dma = dma_map_page(rx_ring->dev, page,
+				page_offset, PAGE_SIZE / 2,
+				DMA_FROM_DEVICE);
+
+	if (dma_mapping_error(rx_ring->dev, page_dma)) {
+		rx_ring->rx_stats.alloc_rx_page_failed++;
+		return false;
+	}
+
+	bi->page_dma = page_dma;
+	bi->page_offset = page_offset;
+	return true;
+}
+
 /**
- * ixgbe_alloc_rx_buffers - Replace used receive buffers; packet split
+ * ixgbe_alloc_rx_buffers - Replace used receive buffers
  * @rx_ring: ring to place buffers on
  * @cleaned_count: number of buffers to replace
  **/
@@ -1110,82 +1177,48 @@ void ixgbe_alloc_rx_buffers(struct ixgbe_ring *rx_ring, u16 cleaned_count)
 {
 	union ixgbe_adv_rx_desc *rx_desc;
 	struct ixgbe_rx_buffer *bi;
-	struct sk_buff *skb;
 	u16 i = rx_ring->next_to_use;
 
-	/* do nothing if no valid netdev defined */
-	if (!rx_ring->netdev)
+	/* nothing to do or no valid netdev defined */
+	if (!cleaned_count || !rx_ring->netdev)
 		return;
 
-	while (cleaned_count--) {
-		rx_desc = IXGBE_RX_DESC_ADV(rx_ring, i);
-		bi = &rx_ring->rx_buffer_info[i];
-		skb = bi->skb;
-
-		if (!skb) {
-			skb = netdev_alloc_skb_ip_align(rx_ring->netdev,
-							rx_ring->rx_buf_len);
-			if (!skb) {
-				rx_ring->rx_stats.alloc_rx_buff_failed++;
-				goto no_buffers;
-			}
-			/* initialize queue mapping */
-			skb_record_rx_queue(skb, rx_ring->queue_index);
-			bi->skb = skb;
-		}
+	rx_desc = IXGBE_RX_DESC_ADV(rx_ring, i);
+	bi = &rx_ring->rx_buffer_info[i];
+	i -= rx_ring->count;
 
-		if (!bi->dma) {
-			bi->dma = dma_map_single(rx_ring->dev,
-						 skb->data,
-						 rx_ring->rx_buf_len,
-						 DMA_FROM_DEVICE);
-			if (dma_mapping_error(rx_ring->dev, bi->dma)) {
-				rx_ring->rx_stats.alloc_rx_buff_failed++;
-				bi->dma = 0;
-				goto no_buffers;
-			}
-		}
+	while (cleaned_count--) {
+		if (!ixgbe_alloc_mapped_skb(rx_ring, bi))
+			break;
 
+		/* Refresh the desc even if buffer_addrs didn't change
+		 * because each write-back erases this info. */
 		if (ring_is_ps_enabled(rx_ring)) {
-			if (!bi->page) {
-				bi->page = alloc_page(GFP_ATOMIC | __GFP_COLD);
-				if (!bi->page) {
-					rx_ring->rx_stats.alloc_rx_page_failed++;
-					goto no_buffers;
-				}
-			}
+			rx_desc->read.hdr_addr = cpu_to_le64(bi->dma);
 
-			if (!bi->page_dma) {
-				/* use a half page if we're re-using */
-				bi->page_offset ^= PAGE_SIZE / 2;
-				bi->page_dma = dma_map_page(rx_ring->dev,
-							    bi->page,
-							    bi->page_offset,
-							    PAGE_SIZE / 2,
-							    DMA_FROM_DEVICE);
-				if (dma_mapping_error(rx_ring->dev,
-						      bi->page_dma)) {
-					rx_ring->rx_stats.alloc_rx_page_failed++;
-					bi->page_dma = 0;
-					goto no_buffers;
-				}
-			}
+			if (!ixgbe_alloc_mapped_page(rx_ring, bi))
+				break;
 
-			/* Refresh the desc even if buffer_addrs didn't change
-			 * because each write-back erases this info. */
 			rx_desc->read.pkt_addr = cpu_to_le64(bi->page_dma);
-			rx_desc->read.hdr_addr = cpu_to_le64(bi->dma);
 		} else {
 			rx_desc->read.pkt_addr = cpu_to_le64(bi->dma);
-			rx_desc->read.hdr_addr = 0;
 		}
 
+		rx_desc++;
+		bi++;
 		i++;
-		if (i == rx_ring->count)
-			i = 0;
+		if (unlikely(!i)) {
+			rx_desc = IXGBE_RX_DESC_ADV(rx_ring, 0);
+			bi = rx_ring->rx_buffer_info;
+			i -= rx_ring->count;
+		}
+
+		/* clear the hdr_addr for the next_to_use descriptor */
+		rx_desc->read.hdr_addr = 0;
 	}
 
-no_buffers:
+	i += rx_ring->count;
+
 	if (rx_ring->next_to_use != i) {
 		rx_ring->next_to_use = i;
 		ixgbe_release_rx_desc(rx_ring, i);
@@ -1593,8 +1626,6 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 
 		budget--;
 next_desc:
-		rx_desc->wb.upper.status_error = 0;
-
 		if (!budget)
 			break;
 
-- 
1.7.7.6
