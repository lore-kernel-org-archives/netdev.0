From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Subject: RE: ixgbe: normalize frag_list usage
Date: Tue, 5 Oct 2010 15:45:32 -0700
Message-ID: <80769D7B14936844A23C0C43D9FBCF0F25B97A24B5@orsmsx501.amr.corp.intel.com>
References: <20101003.235400.229759758.davem@davemloft.net>
	<4CAA1722.7070405@intel.com> <20101004.113258.212671454.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:17139 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754719Ab0JEWpg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 18:45:36 -0400
In-Reply-To: <20101004.113258.212671454.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net]
>Sent: Monday, October 04, 2010 11:33 AM
>To: Duyck, Alexander H
>Cc: Kirsher, Jeffrey T; Brandeburg, Jesse; Allan, Bruce W;
>netdev@vger.kernel.org
>Subject: Re: ixgbe: normalize frag_list usage
>
>From: Alexander Duyck <alexander.h.duyck@intel.com>
>Date: Mon, 04 Oct 2010 11:04:18 -0700
>
>> This will not work for RSC due to the fact that it assumes only one
>> RSC context is active per ring and that is not the case.  There can
>be
>> multiple RSC combined flows interlaced on the ring.
>
>Thanks for looking at this Alexander.
>
>I must have mis-understood what the current code is doing.
>
>It looked like RSC packets always show up in-order in the RX ring.
>
>And that they are scanned for by simply combining any sequence of
>non-EOP packets up to and including the final EOP one into a frag
>list.
>
>Are the RSC packets are identified via something else entirely?

Dave,

The patch below is kind of what I had in mind for a way to do RSC and maintain
the pointer scheme you are looking for.  Consider this patch an RFC for now
since I based this off of Jeff's internal testing tree and so it would need
some modification to apply cleanly to net-next.

The only deviation from a standard frag list is that we are appending the tail
before it actually has any data in it so we have to break things into three
steps.  One to add the tail to the end of the frag list, one to merge the
length from the tail into the head, and finally one to clean-up the head->prev
pointer.

If this works for you I will send it to Jeff to add to his tree for testing.

Thanks,

Alex

---

ixgbe: change RSC to use a normalize frag_list usage

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change drops the RSC queue approach and instead creates a normalized
frag_list skb but the tail is kept active and regularly merged into the
host SKB every time it is completed.  In order to identify the tail skb
as a tail we set the next pointer to the head skb, and the head skb prev
pointer to the tail.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 drivers/net/ixgbe/ixgbe.h      |    2 -
 drivers/net/ixgbe/ixgbe_main.c |   96 +++++++++++++++++++++++-----------------
 2 files changed, 56 insertions(+), 42 deletions(-)


diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index b9a1e70..2c7a296 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -470,7 +470,7 @@ enum ixbge_state_t {
 
 struct ixgbe_rsc_cb {
 	dma_addr_t dma;
-	u16 skb_cnt;
+	u16 append_cnt;
 	bool delay_unmap;
 };
 #define IXGBE_RSC_CB(skb) ((struct ixgbe_rsc_cb *)(skb)->cb)
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 221d5ef..c3774b9 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1251,34 +1251,46 @@ static inline u16 ixgbe_get_hlen(union ixgbe_adv_rx_desc *rx_desc)
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
-
-	while (skb->prev) {
-		struct sk_buff *prev = skb->prev;
-		frag_list_size += skb->len;
-		skb->prev = NULL;
-		skb = prev;
-		skb_cnt++;
+	if (tail->next) {
+		struct sk_buff *head = tail->next;
+		head->len += tail->len;
+		head->data_len += tail->len;
+		head->truesize += tail->len;
+		tail->next = NULL;
+		return head;
 	}
+	return tail;
+}
 
-	skb_shinfo(skb)->frag_list = skb->next;
-	skb->next = NULL;
-	skb->len += frag_list_size;
-	skb->data_len += frag_list_size;
-	skb->truesize += frag_list_size;
-	IXGBE_RSC_CB(skb)->skb_cnt = skb_cnt;
-
-	return skb;
+/**
+ * ixgbe_append_active_tail - add empty skb to the end of a frag_list
+ * @head: skb that will host the frag_list
+ * @tail: skb to add to the end of the frag_list
+ *
+ * This function adds a yet to be completed skb to the end of a frag_list.
+ * It is an in-between step while we are still waiting for the data to be
+ * placed into the yet to be completed skb.  A back pointer from tail to
+ * head is placed in tail->next so we can later merge it into the host skb.
+ * The head->prev pointer is used to track the tail of the frag_list.
+ **/
+static inline void ixgbe_append_active_tail(struct sk_buff *head,
+					    struct sk_buff *tail)
+{
+	if (skb_shinfo(head)->frag_list)
+		head->prev->next = tail;
+	else
+		skb_shinfo(head)->frag_list = tail;
+	head->prev = tail;
+	tail->next = head;
 }
 
 static inline bool ixgbe_get_rsc_state(union ixgbe_adv_rx_desc *rx_desc)
@@ -1328,7 +1340,7 @@ static void ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 			u16 hlen;
 			if (pkt_is_rsc &&
 			    !(staterr & IXGBE_RXD_STAT_EOP) &&
-			    !skb->prev) {
+			    !skb->next) {
 				/*
 				 * When HWRSC is enabled, delay unmapping
 				 * of the first packet. It carries the
@@ -1397,6 +1409,8 @@ static void ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 			next_buffer = &rx_ring->rx_buffer_info[i];
 		}
 
+		skb = ixgbe_merge_active_tail(skb);
+
 		if (!(staterr & IXGBE_RXD_STAT_EOP)) {
 			if (ring_is_ps_enabled(rx_ring)) {
 				rx_buffer_info->skb = next_buffer->skb;
@@ -1404,15 +1418,16 @@ static void ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 				next_buffer->skb = skb;
 				next_buffer->dma = 0;
 			} else {
-				skb->next = next_buffer->skb;
-				skb->next->prev = skb;
+				ixgbe_append_active_tail(skb,
+							 next_buffer->skb);
+				IXGBE_RSC_CB(skb)->append_cnt++;
 			}
 			rx_ring->rx_stats.non_eop_descs++;
 			goto next_desc;
 		}
 
 		if (skb->prev) {
-			skb = ixgbe_transform_rsc_queue(skb);
+			skb->prev = NULL;
 			/* if we got here without RSC the packet is invalid */
 			if (!pkt_is_rsc) {
 				__pskb_trim(skb, 0);
@@ -1437,7 +1452,7 @@ static void ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 					skb_shinfo(skb)->nr_frags;
 			else
 				rx_ring->rx_stats.rsc_count +=
-					IXGBE_RSC_CB(skb)->skb_cnt;
+					IXGBE_RSC_CB(skb)->append_cnt + 1;
 			rx_ring->rx_stats.rsc_flush++;
 		}
 
@@ -3907,19 +3922,18 @@ static void ixgbe_clean_rx_ring(struct ixgbe_ring *rx_ring)
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
+			skb->prev = NULL;
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
