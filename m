From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/7] ixgbe: Minor refactor of RSC
Date: Fri, 10 Feb 2012 16:08:18 -0800
Message-ID: <1328918904-11511-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1328918904-11511-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:22454 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754877Ab2BKAI2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Feb 2012 19:08:28 -0500
In-Reply-To: <1328918904-11511-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change addresses several issue.

First I had left the use of the next and prev skb pointers floating around
in the code and they were overdue to be pulled since I had rewritten the
RSC code in the out-of-tree driver some time ago to address issues brought
up by David Miller in regards to this.

I am also now defaulting to always leaving the first buffer unmapped on any
packet and then unmapping it after we read the EOP descriptor.  This allows
a simplification of the path with less branching.

Instead of counting packets received the code was changed some time ago to
track the number of buffers received.  This leads to inaccurate counting
when you compare numbers of packets received by the hardware versus what is
tracked by the software.  To correct this I am revising things so that the
append_cnt value for RSC accurately tracks the number of frames received.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |   10 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  235 +++++++++++++++----------
 2 files changed, 147 insertions(+), 98 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index e6aeb64..fca0553 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -535,12 +535,16 @@ enum ixbge_state_t {
 	__IXGBE_IN_SFP_INIT,
 };
 
-struct ixgbe_rsc_cb {
+struct ixgbe_cb {
+	union {				/* Union defining head/tail partner */
+		struct sk_buff *head;
+		struct sk_buff *tail;
+	};
 	dma_addr_t dma;
-	u16 skb_cnt;
+	u16 append_cnt;
 	bool delay_unmap;
 };
-#define IXGBE_RSC_CB(skb) ((struct ixgbe_rsc_cb *)(skb)->cb)
+#define IXGBE_CB(skb) ((struct ixgbe_cb *)(skb)->cb)
 
 enum ixgbe_boards {
 	board_82598,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index ecc46ce..18e474c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1207,40 +1207,96 @@ static inline u16 ixgbe_get_hlen(union ixgbe_adv_rx_desc *rx_desc)
 }
 
 /**
- * ixgbe_transform_rsc_queue - change rsc queue into a full packet
- * @skb: pointer to the last skb in the rsc queue
+ * ixgbe_merge_active_tail - merge active tail into lro skb
+ * @tail: pointer to active tail in frag_list
  *
- * This function changes a queue full of hw rsc buffers into a completed
- * packet.  It uses the ->prev pointers to find the first packet and then
- * turns it into the frag list owner.
+ * This function merges the length and data of an active tail into the
+ * skb containing the frag_list.  It resets the tail's pointer to the head,
+ * but it leaves the heads pointer to tail intact.
  **/
-static inline struct sk_buff *ixgbe_transform_rsc_queue(struct sk_buff *skb)
+static inline struct sk_buff *ixgbe_merge_active_tail(struct sk_buff *tail)
 {
-	unsigned int frag_list_size = 0;
-	unsigned int skb_cnt = 1;
+	struct sk_buff *head = IXGBE_CB(tail)->head;
 
-	while (skb->prev) {
-		struct sk_buff *prev = skb->prev;
-		frag_list_size += skb->len;
-		skb->prev = NULL;
-		skb = prev;
-		skb_cnt++;
+	if (!head)
+		return tail;
+
+	head->len += tail->len;
+	head->data_len += tail->len;
+	head->truesize += tail->len;
+
+	IXGBE_CB(tail)->head = NULL;
+
+	return head;
+}
+
+/**
+ * ixgbe_add_active_tail - adds an active tail into the skb frag_list
+ * @head: pointer to the start of the skb
+ * @tail: pointer to active tail to add to frag_list
+ *
+ * This function adds an active tail to the end of the frag list.  This tail
+ * will still be receiving data so we cannot yet ad it's stats to the main
+ * skb.  That is done via ixgbe_merge_active_tail.
+ **/
+static inline void ixgbe_add_active_tail(struct sk_buff *head,
+					 struct sk_buff *tail)
+{
+	struct sk_buff *old_tail = IXGBE_CB(head)->tail;
+
+	if (old_tail) {
+		ixgbe_merge_active_tail(old_tail);
+		old_tail->next = tail;
+	} else {
+		skb_shinfo(head)->frag_list = tail;
 	}
 
-	skb_shinfo(skb)->frag_list = skb->next;
-	skb->next = NULL;
-	skb->len += frag_list_size;
-	skb->data_len += frag_list_size;
-	skb->truesize += frag_list_size;
-	IXGBE_RSC_CB(skb)->skb_cnt = skb_cnt;
+	IXGBE_CB(tail)->head = head;
+	IXGBE_CB(head)->tail = tail;
+}
+
+/**
+ * ixgbe_close_active_frag_list - cleanup pointers on a frag_list skb
+ * @head: pointer to head of an active frag list
+ *
+ * This function will clear the frag_tail_tracker pointer on an active
+ * frag_list and returns true if the pointer was actually set
+ **/
+static inline bool ixgbe_close_active_frag_list(struct sk_buff *head)
+{
+	struct sk_buff *tail = IXGBE_CB(head)->tail;
+
+	if (!tail)
+		return false;
 
-	return skb;
+	ixgbe_merge_active_tail(tail);
+
+	IXGBE_CB(head)->tail = NULL;
+
+	return true;
 }
 
-static inline bool ixgbe_get_rsc_state(union ixgbe_adv_rx_desc *rx_desc)
+static void ixgbe_get_rsc_cnt(struct ixgbe_ring *rx_ring,
+			      union ixgbe_adv_rx_desc *rx_desc,
+			      struct sk_buff *skb)
 {
-	return !!(le32_to_cpu(rx_desc->wb.lower.lo_dword.data) &
-		IXGBE_RXDADV_RSCCNT_MASK);
+	__le32 rsc_enabled;
+	u32 rsc_cnt;
+
+	if (!ring_is_rsc_enabled(rx_ring))
+		return;
+
+	rsc_enabled = rx_desc->wb.lower.lo_dword.data &
+		      cpu_to_le32(IXGBE_RXDADV_RSCCNT_MASK);
+
+	/* If this is an RSC frame rsc_cnt should be non-zero */
+	if (!rsc_enabled)
+		return;
+
+	rsc_cnt = le32_to_cpu(rsc_enabled);
+	rsc_cnt >>= IXGBE_RXDADV_RSCCNT_SHIFT;
+
+	IXGBE_CB(skb)->append_cnt += rsc_cnt - 1;
 }
 
 static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
@@ -1249,7 +1305,7 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 {
 	struct ixgbe_adapter *adapter = q_vector->adapter;
 	union ixgbe_adv_rx_desc *rx_desc, *next_rxd;
-	struct ixgbe_rx_buffer *rx_buffer_info, *next_buffer;
+	struct ixgbe_rx_buffer *rx_buffer_info;
 	struct sk_buff *skb;
 	unsigned int total_rx_bytes = 0, total_rx_packets = 0;
 	const int current_node = numa_node_id();
@@ -1259,7 +1315,6 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 	u32 staterr;
 	u16 i;
 	u16 cleaned_count = 0;
-	bool pkt_is_rsc = false;
 
 	i = rx_ring->next_to_clean;
 	rx_desc = IXGBE_RX_DESC_ADV(rx_ring, i);
@@ -1276,32 +1331,9 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 		rx_buffer_info->skb = NULL;
 		prefetch(skb->data);
 
-		if (ring_is_rsc_enabled(rx_ring))
-			pkt_is_rsc = ixgbe_get_rsc_state(rx_desc);
-
 		/* linear means we are building an skb from multiple pages */
 		if (!skb_is_nonlinear(skb)) {
 			u16 hlen;
-			if (pkt_is_rsc &&
-			    !(staterr & IXGBE_RXD_STAT_EOP) &&
-			    !skb->prev) {
-				/*
-				 * When HWRSC is enabled, delay unmapping
-				 * of the first packet. It carries the
-				 * header information, HW may still
-				 * access the header after the writeback.
-				 * Only unmap it when EOP is reached
-				 */
-				IXGBE_RSC_CB(skb)->delay_unmap = true;
-				IXGBE_RSC_CB(skb)->dma = rx_buffer_info->dma;
-			} else {
-				dma_unmap_single(rx_ring->dev,
-						 rx_buffer_info->dma,
-						 rx_ring->rx_buf_len,
-						 DMA_FROM_DEVICE);
-			}
-			rx_buffer_info->dma = 0;
-
 			if (ring_is_ps_enabled(rx_ring)) {
 				hlen = ixgbe_get_hlen(rx_desc);
 				upper_len = le16_to_cpu(rx_desc->wb.upper.length);
@@ -1310,6 +1342,23 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 			}
 
 			skb_put(skb, hlen);
+
+			/*
+			 * Delay unmapping of the first packet. It carries the
+			 * header information, HW may still access the header
+			 * after writeback.  Only unmap it when EOP is reached
+			 */
+			if (!IXGBE_CB(skb)->head) {
+				IXGBE_CB(skb)->delay_unmap = true;
+				IXGBE_CB(skb)->dma = rx_buffer_info->dma;
+			} else {
+				skb = ixgbe_merge_active_tail(skb);
+				dma_unmap_single(rx_ring->dev,
+						 rx_buffer_info->dma,
+						 rx_ring->rx_buf_len,
+						 DMA_FROM_DEVICE);
+			}
+			rx_buffer_info->dma = 0;
 		} else {
 			/* assume packet split since header is unmapped */
 			upper_len = le16_to_cpu(rx_desc->wb.upper.length);
@@ -1337,6 +1386,8 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 			skb->truesize += PAGE_SIZE / 2;
 		}
 
+		ixgbe_get_rsc_cnt(rx_ring, rx_desc, skb);
+
 		i++;
 		if (i == rx_ring->count)
 			i = 0;
@@ -1345,55 +1396,50 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 		prefetch(next_rxd);
 		cleaned_count++;
 
-		if (pkt_is_rsc) {
-			u32 nextp = (staterr & IXGBE_RXDADV_NEXTP_MASK) >>
-				     IXGBE_RXDADV_NEXTP_SHIFT;
+		if (!(staterr & IXGBE_RXD_STAT_EOP)) {
+			struct ixgbe_rx_buffer *next_buffer;
+			u32 nextp;
+
+			if (IXGBE_CB(skb)->append_cnt) {
+				nextp = staterr & IXGBE_RXDADV_NEXTP_MASK;
+				nextp >>= IXGBE_RXDADV_NEXTP_SHIFT;
+			} else {
+				nextp = i;
+			}
+
 			next_buffer = &rx_ring->rx_buffer_info[nextp];
-		} else {
-			next_buffer = &rx_ring->rx_buffer_info[i];
-		}
 
-		if (!(staterr & IXGBE_RXD_STAT_EOP)) {
 			if (ring_is_ps_enabled(rx_ring)) {
 				rx_buffer_info->skb = next_buffer->skb;
 				rx_buffer_info->dma = next_buffer->dma;
 				next_buffer->skb = skb;
 				next_buffer->dma = 0;
 			} else {
-				skb->next = next_buffer->skb;
-				skb->next->prev = skb;
+				struct sk_buff *next_skb = next_buffer->skb;
+				ixgbe_add_active_tail(skb, next_skb);
+				IXGBE_CB(next_skb)->head = skb;
 			}
 			rx_ring->rx_stats.non_eop_descs++;
 			goto next_desc;
 		}
 
-		if (skb->prev) {
-			skb = ixgbe_transform_rsc_queue(skb);
+		dma_unmap_single(rx_ring->dev,
+				 IXGBE_CB(skb)->dma,
+				 rx_ring->rx_buf_len,
+				 DMA_FROM_DEVICE);
+		IXGBE_CB(skb)->dma = 0;
+		IXGBE_CB(skb)->delay_unmap = false;
+
+		if (ixgbe_close_active_frag_list(skb) &&
+		    !IXGBE_CB(skb)->append_cnt) {
 			/* if we got here without RSC the packet is invalid */
-			if (!pkt_is_rsc) {
-				__pskb_trim(skb, 0);
-				rx_buffer_info->skb = skb;
-				goto next_desc;
-			}
+			dev_kfree_skb_any(skb);
+			goto next_desc;
 		}
 
-		if (ring_is_rsc_enabled(rx_ring)) {
-			if (IXGBE_RSC_CB(skb)->delay_unmap) {
-				dma_unmap_single(rx_ring->dev,
-						 IXGBE_RSC_CB(skb)->dma,
-						 rx_ring->rx_buf_len,
-						 DMA_FROM_DEVICE);
-				IXGBE_RSC_CB(skb)->dma = 0;
-				IXGBE_RSC_CB(skb)->delay_unmap = false;
-			}
-		}
-		if (pkt_is_rsc) {
-			if (ring_is_ps_enabled(rx_ring))
-				rx_ring->rx_stats.rsc_count +=
-					skb_shinfo(skb)->nr_frags;
-			else
-				rx_ring->rx_stats.rsc_count +=
-					IXGBE_RSC_CB(skb)->skb_cnt;
+		if (IXGBE_CB(skb)->append_cnt) {
+			rx_ring->rx_stats.rsc_count +=
+					IXGBE_CB(skb)->append_cnt;
 			rx_ring->rx_stats.rsc_flush++;
 		}
 
@@ -3881,19 +3927,18 @@ static void ixgbe_clean_rx_ring(struct ixgbe_ring *rx_ring)
 		if (rx_buffer_info->skb) {
 			struct sk_buff *skb = rx_buffer_info->skb;
 			rx_buffer_info->skb = NULL;
-			do {
-				struct sk_buff *this = skb;
-				if (IXGBE_RSC_CB(this)->delay_unmap) {
-					dma_unmap_single(dev,
-							 IXGBE_RSC_CB(this)->dma,
-							 rx_ring->rx_buf_len,
-							 DMA_FROM_DEVICE);
-					IXGBE_RSC_CB(this)->dma = 0;
-					IXGBE_RSC_CB(skb)->delay_unmap = false;
-				}
-				skb = skb->prev;
-				dev_kfree_skb(this);
-			} while (skb);
+			/* We need to clean up RSC frag lists */
+			skb = ixgbe_merge_active_tail(skb);
+			ixgbe_close_active_frag_list(skb);
+			if (IXGBE_CB(skb)->delay_unmap) {
+				dma_unmap_single(dev,
+						 IXGBE_CB(skb)->dma,
+						 rx_ring->rx_buf_len,
+						 DMA_FROM_DEVICE);
+				IXGBE_CB(skb)->dma = 0;
+				IXGBE_CB(skb)->delay_unmap = false;
+			}
+			dev_kfree_skb(skb);
 		}
 		if (!rx_buffer_info->page)
 			continue;
-- 
1.7.7.6
