From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Subject: [RFC] ixgbe: v3 normalize frag_list usage
Date: Fri, 8 Oct 2010 16:57:40 -0700
Message-ID: <80769D7B14936844A23C0C43D9FBCF0F25BC8DEC85@orsmsx501.amr.corp.intel.com>
References: <4CAA1722.7070405@intel.com>
	<20101004.113258.212671454.davem@davemloft.net>
	<80769D7B14936844A23C0C43D9FBCF0F25B97A24B5@orsmsx501.amr.corp.intel.com>
 <20101006.235837.241424681.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:43130 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759496Ab0JHX5p convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Oct 2010 19:57:45 -0400
In-Reply-To: <20101006.235837.241424681.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Below is the new and improved version of the RSC chaining approach.  Basically
I am holding off on merging the SKB into the frame until the SKB has data in
order to make it take a more standard approach.

Let me know if this will work with the new pointer structure.

Thanks,

Alex

---

This change drops the RSC queue approach and instead creates a normalized
frag_list skb but the tail is kept active and regularly merged into the
host SKB every time it is completed.  In order to identify the tail skb
as a tail we set the head pointer in the RSC CB block of the skb. To locate
the head we just need to check to see if skb->prev is set and make sure to
clean up the pointer before we pass it up to the stack.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 drivers/net/ixgbe/ixgbe.h      |    3 +
 drivers/net/ixgbe/ixgbe_main.c |   96 +++++++++++++++++++++++-----------------
 2 files changed, 58 insertions(+), 41 deletions(-)


diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index a62d19c..397f9e1 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -469,8 +469,9 @@ enum ixbge_state_t {
 };
 
 struct ixgbe_rsc_cb {
+	struct sk_buff *head;
 	dma_addr_t dma;
-	u16 skb_cnt;
+	u16 append_cnt;
 	bool delay_unmap;
 };
 #define IXGBE_RSC_CB(skb) ((struct ixgbe_rsc_cb *)(skb)->cb)
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 8edce66..104a833 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1251,34 +1251,51 @@ static inline u16 ixgbe_get_hlen(union ixgbe_adv_rx_desc *rx_desc)
 }
 
 /**
- * ixgbe_transform_rsc_queue - change rsc queue into a full packet
- * @skb: pointer to the last skb in the rsc queue
+ * ixgbe_merge_active_tail - merge active tail into frag_list skb
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
+	struct sk_buff *head = IXGBE_RSC_CB(tail)->head;
 
-	while (skb->prev) {
-		struct sk_buff *prev = skb->prev;
-		frag_list_size += skb->len;
-		skb->prev = NULL;
-		skb = prev;
-		skb_cnt++;
-	}
+	if (!head)
+		return tail;
+
+	IXGBE_RSC_CB(tail)->head = NULL;
+
+	if (head->prev)
+		head->prev->next = tail;
+	else
+		skb_shinfo(head)->frag_list = tail;
+
+	head->len += tail->len;
+	head->data_len += tail->len;
+	head->truesize += tail->len;
 
-	skb_shinfo(skb)->frag_list = skb->next;
-	skb->next = NULL;
-	skb->len += frag_list_size;
-	skb->data_len += frag_list_size;
-	skb->truesize += frag_list_size;
-	IXGBE_RSC_CB(skb)->skb_cnt = skb_cnt;
+	head->prev = tail;
+	IXGBE_RSC_CB(head)->append_cnt++;
 
-	return skb;
+	return head;
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
+	if (head->prev) {
+		head->prev = NULL;
+		return true;
+	}
+	return false;
 }
 
 static inline bool ixgbe_get_rsc_state(union ixgbe_adv_rx_desc *rx_desc)
@@ -1397,6 +1414,8 @@ static void ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 			next_buffer = &rx_ring->rx_buffer_info[i];
 		}
 
+		skb = ixgbe_merge_active_tail(skb);
+
 		if (!(staterr & IXGBE_RXD_STAT_EOP)) {
 			if (ring_is_ps_enabled(rx_ring)) {
 				rx_buffer_info->skb = next_buffer->skb;
@@ -1404,15 +1423,13 @@ static void ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 				next_buffer->skb = skb;
 				next_buffer->dma = 0;
 			} else {
-				skb->next = next_buffer->skb;
-				skb->next->prev = skb;
+				IXGBE_RSC_CB(next_buffer->skb)->head = skb;
 			}
 			rx_ring->rx_stats.non_eop_descs++;
 			goto next_desc;
 		}
 
-		if (skb->prev) {
-			skb = ixgbe_transform_rsc_queue(skb);
+		if (ixgbe_close_active_frag_list(skb)) {
 			/* if we got here without RSC the packet is invalid */
 			if (!pkt_is_rsc) {
 				__pskb_trim(skb, 0);
@@ -1437,7 +1454,7 @@ static void ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 					skb_shinfo(skb)->nr_frags;
 			else
 				rx_ring->rx_stats.rsc_count +=
-					IXGBE_RSC_CB(skb)->skb_cnt;
+					IXGBE_RSC_CB(skb)->append_cnt;
 			rx_ring->rx_stats.rsc_flush++;
 		}
 
@@ -3907,19 +3924,18 @@ static void ixgbe_clean_rx_ring(struct ixgbe_ring *rx_ring)
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
+			if (IXGBE_RSC_CB(skb)->delay_unmap) {
+				dma_unmap_single(dev,
+						 IXGBE_RSC_CB(skb)->dma,
+						 rx_ring->rx_buf_len,
+						 DMA_FROM_DEVICE);
+				IXGBE_RSC_CB(skb)->dma = 0;
+				IXGBE_RSC_CB(skb)->delay_unmap = false;
+			}
+			dev_kfree_skb(skb);
 		}
 		if (!rx_buffer_info->page)
 			continue;
