From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/15] ixgbevf: Update ixgbevf_alloc_rx_buffers to handle clearing of status bits
Date: Tue, 18 Nov 2014 20:10:42 -0800
Message-ID: <1416370256-16834-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1416370256-16834-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:39897 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754168AbaKSELC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Nov 2014 23:11:02 -0500
In-Reply-To: <1416370256-16834-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Instead of clearing the status bits in the cleanup it makes more sense to
just clear the status bits on allocation.  This way we can leave the Rx
descriptor rings as a read only memory block until we actually have buffers
to give back to the hardware.

CC: Alexander Duyck <alexander.h.duyck@redhat.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 132 +++++++++++++---------
 1 file changed, 80 insertions(+), 52 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 030a219..deda74d 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -143,21 +143,6 @@ u32 ixgbevf_read_reg(struct ixgbe_hw *hw, u32 reg)
 	return value;
 }
 
-static inline void ixgbevf_release_rx_desc(struct ixgbevf_ring *rx_ring,
-					   u32 val)
-{
-	rx_ring->next_to_use = val;
-
-	/*
-	 * Force memory writes to complete before letting h/w
-	 * know there are new descriptors to fetch.  (Only
-	 * applicable for weak-ordered memory model archs,
-	 * such as IA-64).
-	 */
-	wmb();
-	ixgbevf_write_tail(rx_ring, val);
-}
-
 /**
  * ixgbevf_set_ivar - set IVAR registers - maps interrupt causes to vectors
  * @adapter: pointer to adapter struct
@@ -424,52 +409,99 @@ static inline void ixgbevf_rx_checksum(struct ixgbevf_ring *ring,
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 }
 
+static bool ixgbevf_alloc_mapped_skb(struct ixgbevf_ring *rx_ring,
+				     struct ixgbevf_rx_buffer *bi)
+{
+	struct sk_buff *skb = bi->skb;
+	dma_addr_t dma = bi->dma;
+
+	if (unlikely(skb))
+		return true;
+
+	skb = netdev_alloc_skb_ip_align(rx_ring->netdev,
+					rx_ring->rx_buf_len);
+	if (unlikely(!skb)) {
+		rx_ring->rx_stats.alloc_rx_buff_failed++;
+		return false;
+	}
+
+	dma = dma_map_single(rx_ring->dev, skb->data,
+			     rx_ring->rx_buf_len, DMA_FROM_DEVICE);
+
+	/* if mapping failed free memory back to system since
+	 * there isn't much point in holding memory we can't use
+	 */
+	if (dma_mapping_error(rx_ring->dev, dma)) {
+		dev_kfree_skb_any(skb);
+
+		rx_ring->rx_stats.alloc_rx_buff_failed++;
+		return false;
+	}
+
+	bi->skb = skb;
+	bi->dma = dma;
+
+	return true;
+}
+
 /**
  * ixgbevf_alloc_rx_buffers - Replace used receive buffers; packet split
  * @rx_ring: rx descriptor ring (for a specific queue) to setup buffers on
+ * @cleaned_count: number of buffers to replace
  **/
 static void ixgbevf_alloc_rx_buffers(struct ixgbevf_ring *rx_ring,
-				     int cleaned_count)
+				     u16 cleaned_count)
 {
 	union ixgbe_adv_rx_desc *rx_desc;
 	struct ixgbevf_rx_buffer *bi;
 	unsigned int i = rx_ring->next_to_use;
 
-	while (cleaned_count--) {
-		rx_desc = IXGBEVF_RX_DESC(rx_ring, i);
-		bi = &rx_ring->rx_buffer_info[i];
-
-		if (!bi->skb) {
-			struct sk_buff *skb;
+	/* nothing to do or no valid netdev defined */
+	if (!cleaned_count || !rx_ring->netdev)
+		return;
 
-			skb = netdev_alloc_skb_ip_align(rx_ring->netdev,
-							rx_ring->rx_buf_len);
-			if (!skb)
-				goto no_buffers;
+	rx_desc = IXGBEVF_RX_DESC(rx_ring, i);
+	bi = &rx_ring->rx_buffer_info[i];
+	i -= rx_ring->count;
 
-			bi->skb = skb;
+	do {
+		if (!ixgbevf_alloc_mapped_skb(rx_ring, bi))
+			break;
 
-			bi->dma = dma_map_single(rx_ring->dev, skb->data,
-						 rx_ring->rx_buf_len,
-						 DMA_FROM_DEVICE);
-			if (dma_mapping_error(rx_ring->dev, bi->dma)) {
-				dev_kfree_skb(skb);
-				bi->skb = NULL;
-				dev_err(rx_ring->dev, "Rx DMA map failed\n");
-				break;
-			}
-		}
+		/* Refresh the desc even if pkt_addr didn't change
+		 * because each write-back erases this info.
+		 */
 		rx_desc->read.pkt_addr = cpu_to_le64(bi->dma);
 
+		rx_desc++;
+		bi++;
 		i++;
-		if (i == rx_ring->count)
-			i = 0;
-	}
+		if (unlikely(!i)) {
+			rx_desc = IXGBEVF_RX_DESC(rx_ring, 0);
+			bi = rx_ring->rx_buffer_info;
+			i -= rx_ring->count;
+		}
+
+		/* clear the hdr_addr for the next_to_use descriptor */
+		rx_desc->read.hdr_addr = 0;
+
+		cleaned_count--;
+	} while (cleaned_count);
 
-no_buffers:
-	rx_ring->rx_stats.alloc_rx_buff_failed++;
-	if (rx_ring->next_to_use != i)
-		ixgbevf_release_rx_desc(rx_ring, i);
+	i += rx_ring->count;
+
+	if (rx_ring->next_to_use != i) {
+		/* record the next descriptor to use */
+		rx_ring->next_to_use = i;
+
+		/* Force memory writes to complete before letting h/w
+		 * know there are new descriptors to fetch.  (Only
+		 * applicable for weak-ordered memory model archs,
+		 * such as IA-64).
+		 */
+		wmb();
+		ixgbevf_write_tail(rx_ring, i);
+	}
 }
 
 static inline void ixgbevf_irq_enable_queues(struct ixgbevf_adapter *adapter,
@@ -489,8 +521,8 @@ static int ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
 	struct sk_buff *skb;
 	unsigned int i;
 	u32 len, staterr;
-	int cleaned_count = 0;
 	unsigned int total_rx_bytes = 0, total_rx_packets = 0;
+	u16 cleaned_count = ixgbevf_desc_unused(rx_ring);
 
 	i = rx_ring->next_to_clean;
 	rx_desc = IXGBEVF_RX_DESC(rx_ring, i);
@@ -571,8 +603,6 @@ static int ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
 		ixgbevf_rx_skb(q_vector, skb, staterr, rx_desc);
 
 next_desc:
-		rx_desc->wb.upper.status_error = 0;
-
 		/* return some buffers to hardware, one at a time is too slow */
 		if (cleaned_count >= IXGBEVF_RX_BUFFER_WRITE) {
 			ixgbevf_alloc_rx_buffers(rx_ring, cleaned_count);
@@ -587,11 +617,6 @@ next_desc:
 	}
 
 	rx_ring->next_to_clean = i;
-	cleaned_count = ixgbevf_desc_unused(rx_ring);
-
-	if (cleaned_count)
-		ixgbevf_alloc_rx_buffers(rx_ring, cleaned_count);
-
 	u64_stats_update_begin(&rx_ring->syncp);
 	rx_ring->stats.packets += total_rx_packets;
 	rx_ring->stats.bytes += total_rx_bytes;
@@ -599,6 +624,9 @@ next_desc:
 	q_vector->rx.total_packets += total_rx_packets;
 	q_vector->rx.total_bytes += total_rx_bytes;
 
+	if (cleaned_count)
+		ixgbevf_alloc_rx_buffers(rx_ring, cleaned_count);
+
 	return total_rx_packets;
 }
 
-- 
1.9.3
