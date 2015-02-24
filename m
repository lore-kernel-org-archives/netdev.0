From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 06/16] i40e/i40evf: Refactor the receive routines
Date: Mon, 23 Feb 2015 18:11:11 -0800
Message-ID: <1424743881-30485-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1424743881-30485-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:57876 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752411AbbBXCLa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Feb 2015 21:11:30 -0500
In-Reply-To: <1424743881-30485-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Split the receive hot path code into two, one for packet split and one
for single buffer. This improves receive performance since we only need
to check if the ring is in packet split mode once per NAPI poll time,
not several times per packet. The single buffer code is further improved
by the removal of a bunch of code and several variables that are not
needed. On a receive-oriented test this can improve single-threaded
throughput.

Also refactor the packet split receive path to use a fixed buffer for
headers, like ixgbe does. This vastly reduces the number of DMA mappings
and unmappings we need to do, allowing for much better performance in
the presence of an IOMMU.

Lastly, correct packet split descriptor types now that we are actually
using them.

Change-ID: I3a194a93af3d2c31e77ff17644ac7376da6f3e4b
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by:  Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c     |   9 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c     | 419 ++++++++++++++++++------
 drivers/net/ethernet/intel/i40e/i40e_txrx.h     |  17 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c   | 401 +++++++++++++++++------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h   |  17 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c |   2 +-
 6 files changed, 651 insertions(+), 214 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index cbe281b..10ad1ee 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -2591,7 +2591,12 @@ static int i40e_configure_rx_ring(struct i40e_ring *ring)
 	ring->tail = hw->hw_addr + I40E_QRX_TAIL(pf_q);
 	writel(0, ring->tail);
 
-	i40e_alloc_rx_buffers(ring, I40E_DESC_UNUSED(ring));
+	if (ring_is_ps_enabled(ring)) {
+		i40e_alloc_rx_headers(ring);
+		i40e_alloc_rx_buffers_ps(ring, I40E_DESC_UNUSED(ring));
+	} else {
+		i40e_alloc_rx_buffers_1buf(ring, I40E_DESC_UNUSED(ring));
+	}
 
 	return 0;
 }
@@ -7300,7 +7305,7 @@ static int i40e_sw_init(struct i40e_pf *pf)
 	pf->flags = I40E_FLAG_RX_CSUM_ENABLED |
 		    I40E_FLAG_MSI_ENABLED     |
 		    I40E_FLAG_MSIX_ENABLED    |
-		    I40E_FLAG_RX_1BUF_ENABLED;
+		    I40E_FLAG_RX_PS_ENABLED;
 
 	/* Set default ITR */
 	pf->rx_itr_default = I40E_ITR_DYNAMIC | I40E_ITR_RX_DEF;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 2206d2d..f8c863b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -25,6 +25,7 @@
  ******************************************************************************/
 
 #include <linux/prefetch.h>
+#include <net/busy_poll.h>
 #include "i40e.h"
 #include "i40e_prototype.h"
 
@@ -1025,6 +1026,22 @@ void i40e_clean_rx_ring(struct i40e_ring *rx_ring)
 	if (!rx_ring->rx_bi)
 		return;
 
+	if (ring_is_ps_enabled(rx_ring)) {
+		int bufsz = ALIGN(rx_ring->rx_hdr_len, 256) * rx_ring->count;
+
+		rx_bi = &rx_ring->rx_bi[0];
+		if (rx_bi->hdr_buf) {
+			dma_free_coherent(dev,
+					  bufsz,
+					  rx_bi->hdr_buf,
+					  rx_bi->dma);
+			for (i = 0; i < rx_ring->count; i++) {
+				rx_bi = &rx_ring->rx_bi[i];
+				rx_bi->dma = 0;
+				rx_bi->hdr_buf = 0;
+			}
+		}
+	}
 	/* Free all the Rx ring sk_buffs */
 	for (i = 0; i < rx_ring->count; i++) {
 		rx_bi = &rx_ring->rx_bi[i];
@@ -1083,6 +1100,37 @@ void i40e_free_rx_resources(struct i40e_ring *rx_ring)
 }
 
 /**
+ * i40e_alloc_rx_headers - allocate rx header buffers
+ * @rx_ring: ring to alloc buffers
+ *
+ * Allocate rx header buffers for the entire ring. As these are static,
+ * this is only called when setting up a new ring.
+ **/
+void i40e_alloc_rx_headers(struct i40e_ring *rx_ring)
+{
+	struct device *dev = rx_ring->dev;
+	struct i40e_rx_buffer *rx_bi;
+	dma_addr_t dma;
+	void *buffer;
+	int buf_size;
+	int i;
+
+	if (rx_ring->rx_bi[0].hdr_buf)
+		return;
+	/* Make sure the buffers don't cross cache line boundaries. */
+	buf_size = ALIGN(rx_ring->rx_hdr_len, 256);
+	buffer = dma_alloc_coherent(dev, buf_size * rx_ring->count,
+				    &dma, GFP_KERNEL);
+	if (!buffer)
+		return;
+	for (i = 0; i < rx_ring->count; i++) {
+		rx_bi = &rx_ring->rx_bi[i];
+		rx_bi->dma = dma + (i * buf_size);
+		rx_bi->hdr_buf = buffer + (i * buf_size);
+	}
+}
+
+/**
  * i40e_setup_rx_descriptors - Allocate Rx descriptors
  * @rx_ring: Rx descriptor ring (for a specific queue) to setup
  *
@@ -1142,11 +1190,76 @@ static inline void i40e_release_rx_desc(struct i40e_ring *rx_ring, u32 val)
 }
 
 /**
- * i40e_alloc_rx_buffers - Replace used receive buffers; packet split
+ * i40e_alloc_rx_buffers_ps - Replace used receive buffers; packet split
  * @rx_ring: ring to place buffers on
  * @cleaned_count: number of buffers to replace
  **/
-void i40e_alloc_rx_buffers(struct i40e_ring *rx_ring, u16 cleaned_count)
+void i40e_alloc_rx_buffers_ps(struct i40e_ring *rx_ring, u16 cleaned_count)
+{
+	u16 i = rx_ring->next_to_use;
+	union i40e_rx_desc *rx_desc;
+	struct i40e_rx_buffer *bi;
+
+	/* do nothing if no valid netdev defined */
+	if (!rx_ring->netdev || !cleaned_count)
+		return;
+
+	while (cleaned_count--) {
+		rx_desc = I40E_RX_DESC(rx_ring, i);
+		bi = &rx_ring->rx_bi[i];
+
+		if (bi->skb) /* desc is in use */
+			goto no_buffers;
+		if (!bi->page) {
+			bi->page = alloc_page(GFP_ATOMIC);
+			if (!bi->page) {
+				rx_ring->rx_stats.alloc_page_failed++;
+				goto no_buffers;
+			}
+		}
+
+		if (!bi->page_dma) {
+			/* use a half page if we're re-using */
+			bi->page_offset ^= PAGE_SIZE / 2;
+			bi->page_dma = dma_map_page(rx_ring->dev,
+						    bi->page,
+						    bi->page_offset,
+						    PAGE_SIZE / 2,
+						    DMA_FROM_DEVICE);
+			if (dma_mapping_error(rx_ring->dev,
+					      bi->page_dma)) {
+				rx_ring->rx_stats.alloc_page_failed++;
+				bi->page_dma = 0;
+				goto no_buffers;
+			}
+		}
+
+		dma_sync_single_range_for_device(rx_ring->dev,
+						 bi->dma,
+						 0,
+						 rx_ring->rx_hdr_len,
+						 DMA_FROM_DEVICE);
+		/* Refresh the desc even if buffer_addrs didn't change
+		 * because each write-back erases this info.
+		 */
+		rx_desc->read.pkt_addr = cpu_to_le64(bi->page_dma);
+		rx_desc->read.hdr_addr = cpu_to_le64(bi->dma);
+		i++;
+		if (i == rx_ring->count)
+			i = 0;
+	}
+
+no_buffers:
+	if (rx_ring->next_to_use != i)
+		i40e_release_rx_desc(rx_ring, i);
+}
+
+/**
+ * i40e_alloc_rx_buffers_1buf - Replace used receive buffers; single buffer
+ * @rx_ring: ring to place buffers on
+ * @cleaned_count: number of buffers to replace
+ **/
+void i40e_alloc_rx_buffers_1buf(struct i40e_ring *rx_ring, u16 cleaned_count)
 {
 	u16 i = rx_ring->next_to_use;
 	union i40e_rx_desc *rx_desc;
@@ -1186,40 +1299,8 @@ void i40e_alloc_rx_buffers(struct i40e_ring *rx_ring, u16 cleaned_count)
 			}
 		}
 
-		if (ring_is_ps_enabled(rx_ring)) {
-			if (!bi->page) {
-				bi->page = alloc_page(GFP_ATOMIC);
-				if (!bi->page) {
-					rx_ring->rx_stats.alloc_page_failed++;
-					goto no_buffers;
-				}
-			}
-
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
-					rx_ring->rx_stats.alloc_page_failed++;
-					bi->page_dma = 0;
-					goto no_buffers;
-				}
-			}
-
-			/* Refresh the desc even if buffer_addrs didn't change
-			 * because each write-back erases this info.
-			 */
-			rx_desc->read.pkt_addr = cpu_to_le64(bi->page_dma);
-			rx_desc->read.hdr_addr = cpu_to_le64(bi->dma);
-		} else {
-			rx_desc->read.pkt_addr = cpu_to_le64(bi->dma);
-			rx_desc->read.hdr_addr = 0;
-		}
+		rx_desc->read.pkt_addr = cpu_to_le64(bi->dma);
+		rx_desc->read.hdr_addr = 0;
 		i++;
 		if (i == rx_ring->count)
 			i = 0;
@@ -1404,13 +1485,13 @@ static inline enum pkt_hash_types i40e_ptype_to_hash(u8 ptype)
 }
 
 /**
- * i40e_clean_rx_irq - Reclaim resources after receive completes
+ * i40e_clean_rx_irq_ps - Reclaim resources after receive; packet split
  * @rx_ring:  rx ring to clean
  * @budget:   how many cleans we're allowed
  *
  * Returns true if there's any budget left (e.g. the clean is finished)
  **/
-static int i40e_clean_rx_irq(struct i40e_ring *rx_ring, int budget)
+static int i40e_clean_rx_irq_ps(struct i40e_ring *rx_ring, int budget)
 {
 	unsigned int total_rx_bytes = 0, total_rx_packets = 0;
 	u16 rx_packet_len, rx_header_len, rx_sph, rx_hbo;
@@ -1426,25 +1507,51 @@ static int i40e_clean_rx_irq(struct i40e_ring *rx_ring, int budget)
 	if (budget <= 0)
 		return 0;
 
-	rx_desc = I40E_RX_DESC(rx_ring, i);
-	qword = le64_to_cpu(rx_desc->wb.qword1.status_error_len);
-	rx_status = (qword & I40E_RXD_QW1_STATUS_MASK) >>
-		    I40E_RXD_QW1_STATUS_SHIFT;
-
-	while (rx_status & (1 << I40E_RX_DESC_STATUS_DD_SHIFT)) {
-		union i40e_rx_desc *next_rxd;
+	do {
 		struct i40e_rx_buffer *rx_bi;
 		struct sk_buff *skb;
 		u16 vlan_tag;
+		/* return some buffers to hardware, one at a time is too slow */
+		if (cleaned_count >= I40E_RX_BUFFER_WRITE) {
+			i40e_alloc_rx_buffers_ps(rx_ring, cleaned_count);
+			cleaned_count = 0;
+		}
+
+		i = rx_ring->next_to_clean;
+		rx_desc = I40E_RX_DESC(rx_ring, i);
+		qword = le64_to_cpu(rx_desc->wb.qword1.status_error_len);
+		rx_status = (qword & I40E_RXD_QW1_STATUS_MASK) >>
+			I40E_RXD_QW1_STATUS_SHIFT;
+
+		if (!(rx_status & (1 << I40E_RX_DESC_STATUS_DD_SHIFT)))
+			break;
+
+		/* This memory barrier is needed to keep us from reading
+		 * any other fields out of the rx_desc until we know the
+		 * DD bit is set.
+		 */
+		rmb();
 		if (i40e_rx_is_programming_status(qword)) {
 			i40e_clean_programming_status(rx_ring, rx_desc);
-			I40E_RX_NEXT_DESC_PREFETCH(rx_ring, i, next_rxd);
-			goto next_desc;
+			I40E_RX_INCREMENT(rx_ring, i);
+			continue;
 		}
 		rx_bi = &rx_ring->rx_bi[i];
 		skb = rx_bi->skb;
-		prefetch(skb->data);
-
+		if (likely(!skb)) {
+			skb = netdev_alloc_skb_ip_align(rx_ring->netdev,
+							rx_ring->rx_hdr_len);
+			if (!skb)
+				rx_ring->rx_stats.alloc_buff_failed++;
+			/* initialize queue mapping */
+			skb_record_rx_queue(skb, rx_ring->queue_index);
+			/* we are reusing so sync this buffer for CPU use */
+			dma_sync_single_range_for_cpu(rx_ring->dev,
+						      rx_bi->dma,
+						      0,
+						      rx_ring->rx_hdr_len,
+						      DMA_FROM_DEVICE);
+		}
 		rx_packet_len = (qword & I40E_RXD_QW1_LENGTH_PBUF_MASK) >>
 				I40E_RXD_QW1_LENGTH_PBUF_SHIFT;
 		rx_header_len = (qword & I40E_RXD_QW1_LENGTH_HBUF_MASK) >>
@@ -1459,40 +1566,30 @@ static int i40e_clean_rx_irq(struct i40e_ring *rx_ring, int budget)
 
 		rx_ptype = (qword & I40E_RXD_QW1_PTYPE_MASK) >>
 			   I40E_RXD_QW1_PTYPE_SHIFT;
+		prefetch(rx_bi->page);
 		rx_bi->skb = NULL;
-
-		/* This memory barrier is needed to keep us from reading
-		 * any other fields out of the rx_desc until we know the
-		 * STATUS_DD bit is set
-		 */
-		rmb();
-
-		/* Get the header and possibly the whole packet
-		 * If this is an skb from previous receive dma will be 0
-		 */
-		if (rx_bi->dma) {
-			u16 len;
-
+		cleaned_count++;
+		if (rx_hbo || rx_sph) {
+			int len;
 			if (rx_hbo)
 				len = I40E_RX_HDR_SIZE;
-			else if (rx_sph)
-				len = rx_header_len;
-			else if (rx_packet_len)
-				len = rx_packet_len;   /* 1buf/no split found */
 			else
-				len = rx_header_len;   /* split always mode */
-
-			skb_put(skb, len);
-			dma_unmap_single(rx_ring->dev,
-					 rx_bi->dma,
-					 rx_ring->rx_buf_len,
-					 DMA_FROM_DEVICE);
-			rx_bi->dma = 0;
+				len = rx_header_len;
+			memcpy(__skb_put(skb, len), rx_bi->hdr_buf, len);
+		} else if (skb->len == 0) {
+			int len;
+
+			len = (rx_packet_len > skb_headlen(skb) ?
+				skb_headlen(skb) : rx_packet_len);
+			memcpy(__skb_put(skb, len),
+			       rx_bi->page + rx_bi->page_offset,
+			       len);
+			rx_bi->page_offset += len;
+			rx_packet_len -= len;
 		}
 
 		/* Get the rest of the data if this was a header split */
-		if (ring_is_ps_enabled(rx_ring) && rx_packet_len) {
-
+		if (rx_packet_len) {
 			skb_fill_page_desc(skb, skb_shinfo(skb)->nr_frags,
 					   rx_bi->page,
 					   rx_bi->page_offset,
@@ -1514,22 +1611,16 @@ static int i40e_clean_rx_irq(struct i40e_ring *rx_ring, int budget)
 				       DMA_FROM_DEVICE);
 			rx_bi->page_dma = 0;
 		}
-		I40E_RX_NEXT_DESC_PREFETCH(rx_ring, i, next_rxd);
+		I40E_RX_INCREMENT(rx_ring, i);
 
 		if (unlikely(
 		    !(rx_status & (1 << I40E_RX_DESC_STATUS_EOF_SHIFT)))) {
 			struct i40e_rx_buffer *next_buffer;
 
 			next_buffer = &rx_ring->rx_bi[i];
-
-			if (ring_is_ps_enabled(rx_ring)) {
-				rx_bi->skb = next_buffer->skb;
-				rx_bi->dma = next_buffer->dma;
-				next_buffer->skb = skb;
-				next_buffer->dma = 0;
-			}
+			next_buffer->skb = skb;
 			rx_ring->rx_stats.non_eop_descs++;
-			goto next_desc;
+			continue;
 		}
 
 		/* ERR_MASK will only have valid bits if EOP set */
@@ -1538,7 +1629,7 @@ static int i40e_clean_rx_irq(struct i40e_ring *rx_ring, int budget)
 			/* TODO: shouldn't we increment a counter indicating the
 			 * drop?
 			 */
-			goto next_desc;
+			continue;
 		}
 
 		skb_set_hash(skb, i40e_rx_hash(rx_ring, rx_desc),
@@ -1564,33 +1655,149 @@ static int i40e_clean_rx_irq(struct i40e_ring *rx_ring, int budget)
 #ifdef I40E_FCOE
 		if (!i40e_fcoe_handle_offload(rx_ring, rx_desc, skb)) {
 			dev_kfree_skb_any(skb);
-			goto next_desc;
+			continue;
 		}
 #endif
+		skb_mark_napi_id(skb, &rx_ring->q_vector->napi);
 		i40e_receive_skb(rx_ring, skb, vlan_tag);
 
 		rx_ring->netdev->last_rx = jiffies;
-		budget--;
-next_desc:
 		rx_desc->wb.qword1.status_error_len = 0;
-		if (!budget)
-			break;
 
-		cleaned_count++;
+	} while (likely(total_rx_packets < budget));
+
+	u64_stats_update_begin(&rx_ring->syncp);
+	rx_ring->stats.packets += total_rx_packets;
+	rx_ring->stats.bytes += total_rx_bytes;
+	u64_stats_update_end(&rx_ring->syncp);
+	rx_ring->q_vector->rx.total_packets += total_rx_packets;
+	rx_ring->q_vector->rx.total_bytes += total_rx_bytes;
+
+	return total_rx_packets;
+}
+
+/**
+ * i40e_clean_rx_irq_1buf - Reclaim resources after receive; single buffer
+ * @rx_ring:  rx ring to clean
+ * @budget:   how many cleans we're allowed
+ *
+ * Returns number of packets cleaned
+ **/
+static int i40e_clean_rx_irq_1buf(struct i40e_ring *rx_ring, int budget)
+{
+	unsigned int total_rx_bytes = 0, total_rx_packets = 0;
+	u16 cleaned_count = I40E_DESC_UNUSED(rx_ring);
+	struct i40e_vsi *vsi = rx_ring->vsi;
+	union i40e_rx_desc *rx_desc;
+	u32 rx_error, rx_status;
+	u16 rx_packet_len;
+	u8 rx_ptype;
+	u64 qword;
+	u16 i;
+
+	do {
+		struct i40e_rx_buffer *rx_bi;
+		struct sk_buff *skb;
+		u16 vlan_tag;
 		/* return some buffers to hardware, one at a time is too slow */
 		if (cleaned_count >= I40E_RX_BUFFER_WRITE) {
-			i40e_alloc_rx_buffers(rx_ring, cleaned_count);
+			i40e_alloc_rx_buffers_1buf(rx_ring, cleaned_count);
 			cleaned_count = 0;
 		}
 
-		/* use prefetched values */
-		rx_desc = next_rxd;
+		i = rx_ring->next_to_clean;
+		rx_desc = I40E_RX_DESC(rx_ring, i);
 		qword = le64_to_cpu(rx_desc->wb.qword1.status_error_len);
 		rx_status = (qword & I40E_RXD_QW1_STATUS_MASK) >>
-			    I40E_RXD_QW1_STATUS_SHIFT;
-	}
+			I40E_RXD_QW1_STATUS_SHIFT;
+
+		if (!(rx_status & (1 << I40E_RX_DESC_STATUS_DD_SHIFT)))
+			break;
+
+		/* This memory barrier is needed to keep us from reading
+		 * any other fields out of the rx_desc until we know the
+		 * DD bit is set.
+		 */
+		rmb();
+
+		if (i40e_rx_is_programming_status(qword)) {
+			i40e_clean_programming_status(rx_ring, rx_desc);
+			I40E_RX_INCREMENT(rx_ring, i);
+			continue;
+		}
+		rx_bi = &rx_ring->rx_bi[i];
+		skb = rx_bi->skb;
+		prefetch(skb->data);
+
+		rx_packet_len = (qword & I40E_RXD_QW1_LENGTH_PBUF_MASK) >>
+				I40E_RXD_QW1_LENGTH_PBUF_SHIFT;
+
+		rx_error = (qword & I40E_RXD_QW1_ERROR_MASK) >>
+			   I40E_RXD_QW1_ERROR_SHIFT;
+		rx_error &= ~(1 << I40E_RX_DESC_ERROR_HBO_SHIFT);
+
+		rx_ptype = (qword & I40E_RXD_QW1_PTYPE_MASK) >>
+			   I40E_RXD_QW1_PTYPE_SHIFT;
+		rx_bi->skb = NULL;
+		cleaned_count++;
+
+		/* Get the header and possibly the whole packet
+		 * If this is an skb from previous receive dma will be 0
+		 */
+		skb_put(skb, rx_packet_len);
+		dma_unmap_single(rx_ring->dev, rx_bi->dma, rx_ring->rx_buf_len,
+				 DMA_FROM_DEVICE);
+		rx_bi->dma = 0;
+
+		I40E_RX_INCREMENT(rx_ring, i);
+
+		if (unlikely(
+		    !(rx_status & (1 << I40E_RX_DESC_STATUS_EOF_SHIFT)))) {
+			rx_ring->rx_stats.non_eop_descs++;
+			continue;
+		}
+
+		/* ERR_MASK will only have valid bits if EOP set */
+		if (unlikely(rx_error & (1 << I40E_RX_DESC_ERROR_RXE_SHIFT))) {
+			dev_kfree_skb_any(skb);
+			/* TODO: shouldn't we increment a counter indicating the
+			 * drop?
+			 */
+			continue;
+		}
+
+		skb_set_hash(skb, i40e_rx_hash(rx_ring, rx_desc),
+			     i40e_ptype_to_hash(rx_ptype));
+		if (unlikely(rx_status & I40E_RXD_QW1_STATUS_TSYNVALID_MASK)) {
+			i40e_ptp_rx_hwtstamp(vsi->back, skb, (rx_status &
+					   I40E_RXD_QW1_STATUS_TSYNINDX_MASK) >>
+					   I40E_RXD_QW1_STATUS_TSYNINDX_SHIFT);
+			rx_ring->last_rx_timestamp = jiffies;
+		}
+
+		/* probably a little skewed due to removing CRC */
+		total_rx_bytes += skb->len;
+		total_rx_packets++;
+
+		skb->protocol = eth_type_trans(skb, rx_ring->netdev);
+
+		i40e_rx_checksum(vsi, skb, rx_status, rx_error, rx_ptype);
+
+		vlan_tag = rx_status & (1 << I40E_RX_DESC_STATUS_L2TAG1P_SHIFT)
+			 ? le16_to_cpu(rx_desc->wb.qword0.lo_dword.l2tag1)
+			 : 0;
+#ifdef I40E_FCOE
+		if (!i40e_fcoe_handle_offload(rx_ring, rx_desc, skb)) {
+			dev_kfree_skb_any(skb);
+			continue;
+		}
+#endif
+		i40e_receive_skb(rx_ring, skb, vlan_tag);
+
+		rx_ring->netdev->last_rx = jiffies;
+		rx_desc->wb.qword1.status_error_len = 0;
+	} while (likely(total_rx_packets < budget));
 
-	rx_ring->next_to_clean = i;
 	u64_stats_update_begin(&rx_ring->syncp);
 	rx_ring->stats.packets += total_rx_packets;
 	rx_ring->stats.bytes += total_rx_bytes;
@@ -1598,10 +1805,7 @@ next_desc:
 	rx_ring->q_vector->rx.total_packets += total_rx_packets;
 	rx_ring->q_vector->rx.total_bytes += total_rx_bytes;
 
-	if (cleaned_count)
-		i40e_alloc_rx_buffers(rx_ring, cleaned_count);
-
-	return budget > 0;
+	return total_rx_packets;
 }
 
 /**
@@ -1622,6 +1826,7 @@ int i40e_napi_poll(struct napi_struct *napi, int budget)
 	bool clean_complete = true;
 	bool arm_wb = false;
 	int budget_per_ring;
+	int cleaned;
 
 	if (test_bit(__I40E_DOWN, &vsi->state)) {
 		napi_complete(napi);
@@ -1641,8 +1846,14 @@ int i40e_napi_poll(struct napi_struct *napi, int budget)
 	 */
 	budget_per_ring = max(budget/q_vector->num_ringpairs, 1);
 
-	i40e_for_each_ring(ring, q_vector->rx)
-		clean_complete &= i40e_clean_rx_irq(ring, budget_per_ring);
+	i40e_for_each_ring(ring, q_vector->rx) {
+		if (ring_is_ps_enabled(ring))
+			cleaned = i40e_clean_rx_irq_ps(ring, budget_per_ring);
+		else
+			cleaned = i40e_clean_rx_irq_1buf(ring, budget_per_ring);
+		/* if we didn't clean as many as budgeted, we must be done */
+		clean_complete &= (budget_per_ring != cleaned);
+	}
 
 	/* If work not completed, return budget and polling will return */
 	if (!clean_complete) {
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index 18b0023..38449b2 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -96,6 +96,14 @@ enum i40e_dyn_idx_t {
 
 /* How many Rx Buffers do we bundle into one write to the hardware ? */
 #define I40E_RX_BUFFER_WRITE	16	/* Must be power of 2 */
+#define I40E_RX_INCREMENT(r, i) \
+	do {					\
+		(i)++;				\
+		if ((i) == (r)->count)		\
+			i = 0;			\
+		r->next_to_clean = i;		\
+	} while (0)
+
 #define I40E_RX_NEXT_DESC(r, i, n)		\
 	do {					\
 		(i)++;				\
@@ -151,6 +159,7 @@ struct i40e_tx_buffer {
 
 struct i40e_rx_buffer {
 	struct sk_buff *skb;
+	void *hdr_buf;
 	dma_addr_t dma;
 	struct page *page;
 	dma_addr_t page_dma;
@@ -223,8 +232,8 @@ struct i40e_ring {
 	u16 rx_buf_len;
 	u8  dtype;
 #define I40E_RX_DTYPE_NO_SPLIT      0
-#define I40E_RX_DTYPE_SPLIT_ALWAYS  1
-#define I40E_RX_DTYPE_HEADER_SPLIT  2
+#define I40E_RX_DTYPE_HEADER_SPLIT  1
+#define I40E_RX_DTYPE_SPLIT_ALWAYS  2
 	u8  hsplit;
 #define I40E_RX_SPLIT_L2      0x1
 #define I40E_RX_SPLIT_IP      0x2
@@ -280,7 +289,9 @@ struct i40e_ring_container {
 #define i40e_for_each_ring(pos, head) \
 	for (pos = (head).ring; pos != NULL; pos = pos->next)
 
-void i40e_alloc_rx_buffers(struct i40e_ring *rxr, u16 cleaned_count);
+void i40e_alloc_rx_buffers_ps(struct i40e_ring *rxr, u16 cleaned_count);
+void i40e_alloc_rx_buffers_1buf(struct i40e_ring *rxr, u16 cleaned_count);
+void i40e_alloc_rx_headers(struct i40e_ring *rxr);
 netdev_tx_t i40e_lan_xmit_frame(struct sk_buff *skb, struct net_device *netdev);
 void i40e_clean_tx_ring(struct i40e_ring *tx_ring);
 void i40e_clean_rx_ring(struct i40e_ring *rx_ring);
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 2900438..fc7e2d0 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -25,6 +25,7 @@
  ******************************************************************************/
 
 #include <linux/prefetch.h>
+#include <net/busy_poll.h>
 
 #include "i40evf.h"
 #include "i40e_prototype.h"
@@ -523,6 +524,22 @@ void i40evf_clean_rx_ring(struct i40e_ring *rx_ring)
 	if (!rx_ring->rx_bi)
 		return;
 
+	if (ring_is_ps_enabled(rx_ring)) {
+		int bufsz = ALIGN(rx_ring->rx_hdr_len, 256) * rx_ring->count;
+
+		rx_bi = &rx_ring->rx_bi[0];
+		if (rx_bi->hdr_buf) {
+			dma_free_coherent(dev,
+					  bufsz,
+					  rx_bi->hdr_buf,
+					  rx_bi->dma);
+			for (i = 0; i < rx_ring->count; i++) {
+				rx_bi = &rx_ring->rx_bi[i];
+				rx_bi->dma = 0;
+				rx_bi->hdr_buf = 0;
+			}
+		}
+	}
 	/* Free all the Rx ring sk_buffs */
 	for (i = 0; i < rx_ring->count; i++) {
 		rx_bi = &rx_ring->rx_bi[i];
@@ -581,6 +598,37 @@ void i40evf_free_rx_resources(struct i40e_ring *rx_ring)
 }
 
 /**
+ * i40evf_alloc_rx_headers - allocate rx header buffers
+ * @rx_ring: ring to alloc buffers
+ *
+ * Allocate rx header buffers for the entire ring. As these are static,
+ * this is only called when setting up a new ring.
+ **/
+void i40evf_alloc_rx_headers(struct i40e_ring *rx_ring)
+{
+	struct device *dev = rx_ring->dev;
+	struct i40e_rx_buffer *rx_bi;
+	dma_addr_t dma;
+	void *buffer;
+	int buf_size;
+	int i;
+
+	if (rx_ring->rx_bi[0].hdr_buf)
+		return;
+	/* Make sure the buffers don't cross cache line boundaries. */
+	buf_size = ALIGN(rx_ring->rx_hdr_len, 256);
+	buffer = dma_alloc_coherent(dev, buf_size * rx_ring->count,
+				    &dma, GFP_KERNEL);
+	if (!buffer)
+		return;
+	for (i = 0; i < rx_ring->count; i++) {
+		rx_bi = &rx_ring->rx_bi[i];
+		rx_bi->dma = dma + (i * buf_size);
+		rx_bi->hdr_buf = buffer + (i * buf_size);
+	}
+}
+
+/**
  * i40evf_setup_rx_descriptors - Allocate Rx descriptors
  * @rx_ring: Rx descriptor ring (for a specific queue) to setup
  *
@@ -640,11 +688,76 @@ static inline void i40e_release_rx_desc(struct i40e_ring *rx_ring, u32 val)
 }
 
 /**
- * i40evf_alloc_rx_buffers - Replace used receive buffers; packet split
+ * i40evf_alloc_rx_buffers_ps - Replace used receive buffers; packet split
  * @rx_ring: ring to place buffers on
  * @cleaned_count: number of buffers to replace
  **/
-void i40evf_alloc_rx_buffers(struct i40e_ring *rx_ring, u16 cleaned_count)
+void i40evf_alloc_rx_buffers_ps(struct i40e_ring *rx_ring, u16 cleaned_count)
+{
+	u16 i = rx_ring->next_to_use;
+	union i40e_rx_desc *rx_desc;
+	struct i40e_rx_buffer *bi;
+
+	/* do nothing if no valid netdev defined */
+	if (!rx_ring->netdev || !cleaned_count)
+		return;
+
+	while (cleaned_count--) {
+		rx_desc = I40E_RX_DESC(rx_ring, i);
+		bi = &rx_ring->rx_bi[i];
+
+		if (bi->skb) /* desc is in use */
+			goto no_buffers;
+		if (!bi->page) {
+			bi->page = alloc_page(GFP_ATOMIC);
+			if (!bi->page) {
+				rx_ring->rx_stats.alloc_page_failed++;
+				goto no_buffers;
+			}
+		}
+
+		if (!bi->page_dma) {
+			/* use a half page if we're re-using */
+			bi->page_offset ^= PAGE_SIZE / 2;
+			bi->page_dma = dma_map_page(rx_ring->dev,
+						    bi->page,
+						    bi->page_offset,
+						    PAGE_SIZE / 2,
+						    DMA_FROM_DEVICE);
+			if (dma_mapping_error(rx_ring->dev,
+					      bi->page_dma)) {
+				rx_ring->rx_stats.alloc_page_failed++;
+				bi->page_dma = 0;
+				goto no_buffers;
+			}
+		}
+
+		dma_sync_single_range_for_device(rx_ring->dev,
+						 bi->dma,
+						 0,
+						 rx_ring->rx_hdr_len,
+						 DMA_FROM_DEVICE);
+		/* Refresh the desc even if buffer_addrs didn't change
+		 * because each write-back erases this info.
+		 */
+		rx_desc->read.pkt_addr = cpu_to_le64(bi->page_dma);
+		rx_desc->read.hdr_addr = cpu_to_le64(bi->dma);
+		i++;
+		if (i == rx_ring->count)
+			i = 0;
+	}
+
+no_buffers:
+	if (rx_ring->next_to_use != i)
+		i40e_release_rx_desc(rx_ring, i);
+}
+
+/**
+ * i40evf_alloc_rx_buffers_1buf - Replace used receive buffers; single buffer
+ * @rx_ring: ring to place buffers on
+ * @cleaned_count: number of buffers to replace
+ **/
+void i40evf_alloc_rx_buffers_1buf(struct i40e_ring *rx_ring, u16 cleaned_count)
 {
 	u16 i = rx_ring->next_to_use;
 	union i40e_rx_desc *rx_desc;
@@ -684,40 +797,8 @@ void i40evf_alloc_rx_buffers(struct i40e_ring *rx_ring, u16 cleaned_count)
 			}
 		}
 
-		if (ring_is_ps_enabled(rx_ring)) {
-			if (!bi->page) {
-				bi->page = alloc_page(GFP_ATOMIC);
-				if (!bi->page) {
-					rx_ring->rx_stats.alloc_page_failed++;
-					goto no_buffers;
-				}
-			}
-
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
-					rx_ring->rx_stats.alloc_page_failed++;
-					bi->page_dma = 0;
-					goto no_buffers;
-				}
-			}
-
-			/* Refresh the desc even if buffer_addrs didn't change
-			 * because each write-back erases this info.
-			 */
-			rx_desc->read.pkt_addr = cpu_to_le64(bi->page_dma);
-			rx_desc->read.hdr_addr = cpu_to_le64(bi->dma);
-		} else {
-			rx_desc->read.pkt_addr = cpu_to_le64(bi->dma);
-			rx_desc->read.hdr_addr = 0;
-		}
+		rx_desc->read.pkt_addr = cpu_to_le64(bi->dma);
+		rx_desc->read.hdr_addr = 0;
 		i++;
 		if (i == rx_ring->count)
 			i = 0;
@@ -900,13 +981,13 @@ static inline enum pkt_hash_types i40e_ptype_to_hash(u8 ptype)
 }
 
 /**
- * i40e_clean_rx_irq - Reclaim resources after receive completes
+ * i40e_clean_rx_irq_ps - Reclaim resources after receive; packet split
  * @rx_ring:  rx ring to clean
  * @budget:   how many cleans we're allowed
  *
  * Returns true if there's any budget left (e.g. the clean is finished)
  **/
-static int i40e_clean_rx_irq(struct i40e_ring *rx_ring, int budget)
+static int i40e_clean_rx_irq_ps(struct i40e_ring *rx_ring, int budget)
 {
 	unsigned int total_rx_bytes = 0, total_rx_packets = 0;
 	u16 rx_packet_len, rx_header_len, rx_sph, rx_hbo;
@@ -919,20 +1000,46 @@ static int i40e_clean_rx_irq(struct i40e_ring *rx_ring, int budget)
 	u8 rx_ptype;
 	u64 qword;
 
-	rx_desc = I40E_RX_DESC(rx_ring, i);
-	qword = le64_to_cpu(rx_desc->wb.qword1.status_error_len);
-	rx_status = (qword & I40E_RXD_QW1_STATUS_MASK) >>
-		    I40E_RXD_QW1_STATUS_SHIFT;
-
-	while (rx_status & (1 << I40E_RX_DESC_STATUS_DD_SHIFT)) {
-		union i40e_rx_desc *next_rxd;
+	do {
 		struct i40e_rx_buffer *rx_bi;
 		struct sk_buff *skb;
 		u16 vlan_tag;
+		/* return some buffers to hardware, one at a time is too slow */
+		if (cleaned_count >= I40E_RX_BUFFER_WRITE) {
+			i40evf_alloc_rx_buffers_ps(rx_ring, cleaned_count);
+			cleaned_count = 0;
+		}
+
+		i = rx_ring->next_to_clean;
+		rx_desc = I40E_RX_DESC(rx_ring, i);
+		qword = le64_to_cpu(rx_desc->wb.qword1.status_error_len);
+		rx_status = (qword & I40E_RXD_QW1_STATUS_MASK) >>
+			I40E_RXD_QW1_STATUS_SHIFT;
+
+		if (!(rx_status & (1 << I40E_RX_DESC_STATUS_DD_SHIFT)))
+			break;
+
+		/* This memory barrier is needed to keep us from reading
+		 * any other fields out of the rx_desc until we know the
+		 * DD bit is set.
+		 */
+		rmb();
 		rx_bi = &rx_ring->rx_bi[i];
 		skb = rx_bi->skb;
-		prefetch(skb->data);
-
+		if (likely(!skb)) {
+			skb = netdev_alloc_skb_ip_align(rx_ring->netdev,
+							rx_ring->rx_hdr_len);
+			if (!skb)
+				rx_ring->rx_stats.alloc_buff_failed++;
+			/* initialize queue mapping */
+			skb_record_rx_queue(skb, rx_ring->queue_index);
+			/* we are reusing so sync this buffer for CPU use */
+			dma_sync_single_range_for_cpu(rx_ring->dev,
+						      rx_bi->dma,
+						      0,
+						      rx_ring->rx_hdr_len,
+						      DMA_FROM_DEVICE);
+		}
 		rx_packet_len = (qword & I40E_RXD_QW1_LENGTH_PBUF_MASK) >>
 				I40E_RXD_QW1_LENGTH_PBUF_SHIFT;
 		rx_header_len = (qword & I40E_RXD_QW1_LENGTH_HBUF_MASK) >>
@@ -947,40 +1054,30 @@ static int i40e_clean_rx_irq(struct i40e_ring *rx_ring, int budget)
 
 		rx_ptype = (qword & I40E_RXD_QW1_PTYPE_MASK) >>
 			   I40E_RXD_QW1_PTYPE_SHIFT;
+		prefetch(rx_bi->page);
 		rx_bi->skb = NULL;
-
-		/* This memory barrier is needed to keep us from reading
-		 * any other fields out of the rx_desc until we know the
-		 * STATUS_DD bit is set
-		 */
-		rmb();
-
-		/* Get the header and possibly the whole packet
-		 * If this is an skb from previous receive dma will be 0
-		 */
-		if (rx_bi->dma) {
-			u16 len;
-
+		cleaned_count++;
+		if (rx_hbo || rx_sph) {
+			int len;
 			if (rx_hbo)
 				len = I40E_RX_HDR_SIZE;
-			else if (rx_sph)
-				len = rx_header_len;
-			else if (rx_packet_len)
-				len = rx_packet_len;   /* 1buf/no split found */
 			else
-				len = rx_header_len;   /* split always mode */
-
-			skb_put(skb, len);
-			dma_unmap_single(rx_ring->dev,
-					 rx_bi->dma,
-					 rx_ring->rx_buf_len,
-					 DMA_FROM_DEVICE);
-			rx_bi->dma = 0;
+				len = rx_header_len;
+			memcpy(__skb_put(skb, len), rx_bi->hdr_buf, len);
+		} else if (skb->len == 0) {
+			int len;
+
+			len = (rx_packet_len > skb_headlen(skb) ?
+				skb_headlen(skb) : rx_packet_len);
+			memcpy(__skb_put(skb, len),
+			       rx_bi->page + rx_bi->page_offset,
+			       len);
+			rx_bi->page_offset += len;
+			rx_packet_len -= len;
 		}
 
 		/* Get the rest of the data if this was a header split */
-		if (ring_is_ps_enabled(rx_ring) && rx_packet_len) {
-
+		if (rx_packet_len) {
 			skb_fill_page_desc(skb, skb_shinfo(skb)->nr_frags,
 					   rx_bi->page,
 					   rx_bi->page_offset,
@@ -1002,22 +1099,16 @@ static int i40e_clean_rx_irq(struct i40e_ring *rx_ring, int budget)
 				       DMA_FROM_DEVICE);
 			rx_bi->page_dma = 0;
 		}
-		I40E_RX_NEXT_DESC_PREFETCH(rx_ring, i, next_rxd);
+		I40E_RX_INCREMENT(rx_ring, i);
 
 		if (unlikely(
 		    !(rx_status & (1 << I40E_RX_DESC_STATUS_EOF_SHIFT)))) {
 			struct i40e_rx_buffer *next_buffer;
 
 			next_buffer = &rx_ring->rx_bi[i];
-
-			if (ring_is_ps_enabled(rx_ring)) {
-				rx_bi->skb = next_buffer->skb;
-				rx_bi->dma = next_buffer->dma;
-				next_buffer->skb = skb;
-				next_buffer->dma = 0;
-			}
+			next_buffer->skb = skb;
 			rx_ring->rx_stats.non_eop_descs++;
-			goto next_desc;
+			continue;
 		}
 
 		/* ERR_MASK will only have valid bits if EOP set */
@@ -1026,7 +1117,7 @@ static int i40e_clean_rx_irq(struct i40e_ring *rx_ring, int budget)
 			/* TODO: shouldn't we increment a counter indicating the
 			 * drop?
 			 */
-			goto next_desc;
+			continue;
 		}
 
 		skb_set_hash(skb, i40e_rx_hash(rx_ring, rx_desc),
@@ -1042,30 +1133,134 @@ static int i40e_clean_rx_irq(struct i40e_ring *rx_ring, int budget)
 		vlan_tag = rx_status & (1 << I40E_RX_DESC_STATUS_L2TAG1P_SHIFT)
 			 ? le16_to_cpu(rx_desc->wb.qword0.lo_dword.l2tag1)
 			 : 0;
+#ifdef I40E_FCOE
+		if (!i40e_fcoe_handle_offload(rx_ring, rx_desc, skb)) {
+			dev_kfree_skb_any(skb);
+			continue;
+		}
+#endif
+		skb_mark_napi_id(skb, &rx_ring->q_vector->napi);
 		i40e_receive_skb(rx_ring, skb, vlan_tag);
 
 		rx_ring->netdev->last_rx = jiffies;
-		budget--;
-next_desc:
 		rx_desc->wb.qword1.status_error_len = 0;
-		if (!budget)
-			break;
 
-		cleaned_count++;
+	} while (likely(total_rx_packets < budget));
+
+	u64_stats_update_begin(&rx_ring->syncp);
+	rx_ring->stats.packets += total_rx_packets;
+	rx_ring->stats.bytes += total_rx_bytes;
+	u64_stats_update_end(&rx_ring->syncp);
+	rx_ring->q_vector->rx.total_packets += total_rx_packets;
+	rx_ring->q_vector->rx.total_bytes += total_rx_bytes;
+
+	return total_rx_packets;
+}
+
+/**
+ * i40e_clean_rx_irq_1buf - Reclaim resources after receive; single buffer
+ * @rx_ring:  rx ring to clean
+ * @budget:   how many cleans we're allowed
+ *
+ * Returns number of packets cleaned
+ **/
+static int i40e_clean_rx_irq_1buf(struct i40e_ring *rx_ring, int budget)
+{
+	unsigned int total_rx_bytes = 0, total_rx_packets = 0;
+	u16 cleaned_count = I40E_DESC_UNUSED(rx_ring);
+	struct i40e_vsi *vsi = rx_ring->vsi;
+	union i40e_rx_desc *rx_desc;
+	u32 rx_error, rx_status;
+	u16 rx_packet_len;
+	u8 rx_ptype;
+	u64 qword;
+	u16 i;
+
+	do {
+		struct i40e_rx_buffer *rx_bi;
+		struct sk_buff *skb;
+		u16 vlan_tag;
 		/* return some buffers to hardware, one at a time is too slow */
 		if (cleaned_count >= I40E_RX_BUFFER_WRITE) {
-			i40evf_alloc_rx_buffers(rx_ring, cleaned_count);
+			i40evf_alloc_rx_buffers_1buf(rx_ring, cleaned_count);
 			cleaned_count = 0;
 		}
 
-		/* use prefetched values */
-		rx_desc = next_rxd;
+		i = rx_ring->next_to_clean;
+		rx_desc = I40E_RX_DESC(rx_ring, i);
 		qword = le64_to_cpu(rx_desc->wb.qword1.status_error_len);
 		rx_status = (qword & I40E_RXD_QW1_STATUS_MASK) >>
-			    I40E_RXD_QW1_STATUS_SHIFT;
-	}
+			I40E_RXD_QW1_STATUS_SHIFT;
+
+		if (!(rx_status & (1 << I40E_RX_DESC_STATUS_DD_SHIFT)))
+			break;
+
+		/* This memory barrier is needed to keep us from reading
+		 * any other fields out of the rx_desc until we know the
+		 * DD bit is set.
+		 */
+		rmb();
+
+		rx_bi = &rx_ring->rx_bi[i];
+		skb = rx_bi->skb;
+		prefetch(skb->data);
+
+		rx_packet_len = (qword & I40E_RXD_QW1_LENGTH_PBUF_MASK) >>
+				I40E_RXD_QW1_LENGTH_PBUF_SHIFT;
+
+		rx_error = (qword & I40E_RXD_QW1_ERROR_MASK) >>
+			   I40E_RXD_QW1_ERROR_SHIFT;
+		rx_error &= ~(1 << I40E_RX_DESC_ERROR_HBO_SHIFT);
+
+		rx_ptype = (qword & I40E_RXD_QW1_PTYPE_MASK) >>
+			   I40E_RXD_QW1_PTYPE_SHIFT;
+		rx_bi->skb = NULL;
+		cleaned_count++;
+
+		/* Get the header and possibly the whole packet
+		 * If this is an skb from previous receive dma will be 0
+		 */
+		skb_put(skb, rx_packet_len);
+		dma_unmap_single(rx_ring->dev, rx_bi->dma, rx_ring->rx_buf_len,
+				 DMA_FROM_DEVICE);
+		rx_bi->dma = 0;
+
+		I40E_RX_INCREMENT(rx_ring, i);
+
+		if (unlikely(
+		    !(rx_status & (1 << I40E_RX_DESC_STATUS_EOF_SHIFT)))) {
+			rx_ring->rx_stats.non_eop_descs++;
+			continue;
+		}
+
+		/* ERR_MASK will only have valid bits if EOP set */
+		if (unlikely(rx_error & (1 << I40E_RX_DESC_ERROR_RXE_SHIFT))) {
+			dev_kfree_skb_any(skb);
+			/* TODO: shouldn't we increment a counter indicating the
+			 * drop?
+			 */
+			continue;
+		}
+
+		skb_set_hash(skb, i40e_rx_hash(rx_ring, rx_desc),
+			     i40e_ptype_to_hash(rx_ptype));
+		/* probably a little skewed due to removing CRC */
+		total_rx_bytes += skb->len;
+		total_rx_packets++;
+
+		skb->protocol = eth_type_trans(skb, rx_ring->netdev);
+
+		i40e_rx_checksum(vsi, skb, rx_status, rx_error, rx_ptype);
+
+		vlan_tag = rx_status & (1 << I40E_RX_DESC_STATUS_L2TAG1P_SHIFT)
+			 ? le16_to_cpu(rx_desc->wb.qword0.lo_dword.l2tag1)
+			 : 0;
+		i40e_receive_skb(rx_ring, skb, vlan_tag);
+
+		rx_ring->netdev->last_rx = jiffies;
+		rx_desc->wb.qword1.status_error_len = 0;
+	} while (likely(total_rx_packets < budget));
 
-	rx_ring->next_to_clean = i;
 	u64_stats_update_begin(&rx_ring->syncp);
 	rx_ring->stats.packets += total_rx_packets;
 	rx_ring->stats.bytes += total_rx_bytes;
@@ -1073,10 +1268,7 @@ next_desc:
 	rx_ring->q_vector->rx.total_packets += total_rx_packets;
 	rx_ring->q_vector->rx.total_bytes += total_rx_bytes;
 
-	if (cleaned_count)
-		i40evf_alloc_rx_buffers(rx_ring, cleaned_count);
-
-	return budget > 0;
+	return total_rx_packets;
 }
 
 /**
@@ -1097,6 +1289,7 @@ int i40evf_napi_poll(struct napi_struct *napi, int budget)
 	bool clean_complete = true;
 	bool arm_wb = false;
 	int budget_per_ring;
+	int cleaned;
 
 	if (test_bit(__I40E_DOWN, &vsi->state)) {
 		napi_complete(napi);
@@ -1116,8 +1309,14 @@ int i40evf_napi_poll(struct napi_struct *napi, int budget)
 	 */
 	budget_per_ring = max(budget/q_vector->num_ringpairs, 1);
 
-	i40e_for_each_ring(ring, q_vector->rx)
-		clean_complete &= i40e_clean_rx_irq(ring, budget_per_ring);
+	i40e_for_each_ring(ring, q_vector->rx) {
+		if (ring_is_ps_enabled(ring))
+			cleaned = i40e_clean_rx_irq_ps(ring, budget_per_ring);
+		else
+			cleaned = i40e_clean_rx_irq_1buf(ring, budget_per_ring);
+		/* if we didn't clean as many as budgeted, we must be done */
+		clean_complete &= (budget_per_ring != cleaned);
+	}
 
 	/* If work not completed, return budget and polling will return */
 	if (!clean_complete) {
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
index 4e15903..ffdda71 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
@@ -96,6 +96,14 @@ enum i40e_dyn_idx_t {
 
 /* How many Rx Buffers do we bundle into one write to the hardware ? */
 #define I40E_RX_BUFFER_WRITE	16	/* Must be power of 2 */
+#define I40E_RX_INCREMENT(r, i) \
+	do {					\
+		(i)++;				\
+		if ((i) == (r)->count)		\
+			i = 0;			\
+		r->next_to_clean = i;		\
+	} while (0)
+
 #define I40E_RX_NEXT_DESC(r, i, n)		\
 	do {					\
 		(i)++;				\
@@ -150,6 +158,7 @@ struct i40e_tx_buffer {
 
 struct i40e_rx_buffer {
 	struct sk_buff *skb;
+	void *hdr_buf;
 	dma_addr_t dma;
 	struct page *page;
 	dma_addr_t page_dma;
@@ -222,8 +231,8 @@ struct i40e_ring {
 	u16 rx_buf_len;
 	u8  dtype;
 #define I40E_RX_DTYPE_NO_SPLIT      0
-#define I40E_RX_DTYPE_SPLIT_ALWAYS  1
-#define I40E_RX_DTYPE_HEADER_SPLIT  2
+#define I40E_RX_DTYPE_HEADER_SPLIT  1
+#define I40E_RX_DTYPE_SPLIT_ALWAYS  2
 	u8  hsplit;
 #define I40E_RX_SPLIT_L2      0x1
 #define I40E_RX_SPLIT_IP      0x2
@@ -277,7 +286,9 @@ struct i40e_ring_container {
 #define i40e_for_each_ring(pos, head) \
 	for (pos = (head).ring; pos != NULL; pos = pos->next)
 
-void i40evf_alloc_rx_buffers(struct i40e_ring *rxr, u16 cleaned_count);
+void i40evf_alloc_rx_buffers_ps(struct i40e_ring *rxr, u16 cleaned_count);
+void i40evf_alloc_rx_buffers_1buf(struct i40e_ring *rxr, u16 cleaned_count);
+void i40evf_alloc_rx_headers(struct i40e_ring *rxr);
 netdev_tx_t i40evf_xmit_frame(struct sk_buff *skb, struct net_device *netdev);
 void i40evf_clean_tx_ring(struct i40e_ring *tx_ring);
 void i40evf_clean_rx_ring(struct i40e_ring *rx_ring);
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 8d8c201..4f079e0 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -920,7 +920,7 @@ static void i40evf_configure(struct i40evf_adapter *adapter)
 	for (i = 0; i < adapter->num_active_queues; i++) {
 		struct i40e_ring *ring = adapter->rx_rings[i];
 
-		i40evf_alloc_rx_buffers(ring, ring->count);
+		i40evf_alloc_rx_buffers_1buf(ring, ring->count);
 		ring->next_to_use = ring->count - 1;
 		writel(ring->next_to_use, ring->tail);
 	}
-- 
1.9.3
