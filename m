From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] igb: use build_skb()
Date: Thu, 02 Aug 2012 17:51:32 +0200
Message-ID: <1343922692.9299.231.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:51258 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751017Ab2HBPvj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2012 11:51:39 -0400
Received: by eaac11 with SMTP id c11so948439eaa.19
        for <netdev@vger.kernel.org>; Thu, 02 Aug 2012 08:51:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

By using netdev_alloc_frag() & build_skb() instead of legacy
netdev_alloc_skb_ip_align() calls, we reduce number of cache misses in
RX path and size of working set.

For a given rx workload, number of 'inuse' sk_buff can be reduced to a
very minimum, especially when packets are dropped by our stack.

(Before this patch, default sk_buff allocation was 2048 sk_buffs in rx
ring buffer)

They are initialized right before being delivered to stack, so can stay
hot in cpu caches.

Ethernet header prefetching is more effective (old prefetch of skb->data
paid a stall to access skb->data pointer)

I have 15% performance increase in a RX stress test, removing SLUB slow
path in the profiles.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>
---
 drivers/net/ethernet/intel/igb/igb.h         |    8 ++
 drivers/net/ethernet/intel/igb/igb_ethtool.c |   14 ++--
 drivers/net/ethernet/intel/igb/igb_main.c    |   56 ++++++++++-------
 3 files changed, 49 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index 9e572dd..e43b160 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -135,6 +135,11 @@ struct vf_data_storage {
 #define IGB_RXBUFFER_16384 16384
 #define IGB_RX_HDR_LEN     IGB_RXBUFFER_512
 
+/* size of fragments allocated with netdev_alloc_frag() */
+#define IGB_FRAGSZ							\
+	(SKB_DATA_ALIGN(IGB_RX_HDR_LEN + NET_SKB_PAD + NET_IP_ALIGN) +	\
+	 SKB_DATA_ALIGN(sizeof(struct skb_shared_info)))		
+
 /* How many Tx Descriptors do we need to call netif_wake_queue ? */
 #define IGB_TX_QUEUE_WAKE	16
 /* How many Rx Buffers do we bundle into one write to the hardware ? */
@@ -173,7 +178,7 @@ struct igb_tx_buffer {
 };
 
 struct igb_rx_buffer {
-	struct sk_buff *skb;
+	void *data;
 	dma_addr_t dma;
 	struct page *page;
 	dma_addr_t page_dma;
@@ -242,6 +247,7 @@ struct igb_ring {
 	u16 next_to_clean ____cacheline_aligned_in_smp;
 	u16 next_to_use;
 
+	struct sk_buff *skb;
 	union {
 		/* TX */
 		struct {
diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index a19c84c..e6fc5cb 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -1636,12 +1636,12 @@ static void igb_create_lbtest_frame(struct sk_buff *skb,
 	memset(&skb->data[frame_size + 12], 0xAF, 1);
 }
 
-static int igb_check_lbtest_frame(struct sk_buff *skb, unsigned int frame_size)
+static int igb_check_lbtest_frame(const u8 *data, unsigned int frame_size)
 {
 	frame_size /= 2;
-	if (*(skb->data + 3) == 0xFF) {
-		if ((*(skb->data + frame_size + 10) == 0xBE) &&
-		   (*(skb->data + frame_size + 12) == 0xAF)) {
+	if (*(data + 3) == 0xFF) {
+		if ((*(data + frame_size + 10) == 0xBE) &&
+		   (*(data + frame_size + 12) == 0xAF)) {
 			return 0;
 		}
 	}
@@ -1675,8 +1675,10 @@ static int igb_clean_test_rings(struct igb_ring *rx_ring,
 				 DMA_FROM_DEVICE);
 		rx_buffer_info->dma = 0;
 
-		/* verify contents of skb */
-		if (!igb_check_lbtest_frame(rx_buffer_info->skb, size))
+		/* verify contents of buffer */
+		if (!igb_check_lbtest_frame(rx_buffer_info->data +
+					    NET_SKB_PAD + NET_IP_ALIGN,
+					    size))
 			count++;
 
 		/* unmap buffer on tx side */
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index b7c2d50..8b732c9 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -538,14 +538,14 @@ rx_ring_summary:
 					"--------- %p%s\n", "RWB", i,
 					le64_to_cpu(u0->a),
 					le64_to_cpu(u0->b),
-					buffer_info->skb, next_desc);
+					buffer_info->data, next_desc);
 			} else {
 				pr_info("%s[0x%03X]     %016llX %016llX %016llX"
 					" %p%s\n", "R  ", i,
 					le64_to_cpu(u0->a),
 					le64_to_cpu(u0->b),
 					(u64)buffer_info->dma,
-					buffer_info->skb, next_desc);
+					buffer_info->data, next_desc);
 
 				if (netif_msg_pktdata(adapter)) {
 					print_hex_dump(KERN_INFO, "",
@@ -3379,7 +3379,7 @@ static void igb_clean_rx_ring(struct igb_ring *rx_ring)
 	if (!rx_ring->rx_buffer_info)
 		return;
 
-	/* Free all the Rx ring sk_buffs */
+	/* Free all the Rx ring frags */
 	for (i = 0; i < rx_ring->count; i++) {
 		struct igb_rx_buffer *buffer_info = &rx_ring->rx_buffer_info[i];
 		if (buffer_info->dma) {
@@ -3390,9 +3390,9 @@ static void igb_clean_rx_ring(struct igb_ring *rx_ring)
 			buffer_info->dma = 0;
 		}
 
-		if (buffer_info->skb) {
-			dev_kfree_skb(buffer_info->skb);
-			buffer_info->skb = NULL;
+		if (buffer_info->data) {
+			put_page(virt_to_head_page(buffer_info->data));
+			buffer_info->data = NULL;
 		}
 		if (buffer_info->page_dma) {
 			dma_unmap_page(rx_ring->dev,
@@ -3407,6 +3407,8 @@ static void igb_clean_rx_ring(struct igb_ring *rx_ring)
 			buffer_info->page_offset = 0;
 		}
 	}
+	kfree_skb(rx_ring->skb);
+	rx_ring->skb = NULL;
 
 	size = sizeof(struct igb_rx_buffer) * rx_ring->count;
 	memset(rx_ring->rx_buffer_info, 0, size);
@@ -6078,11 +6080,13 @@ static bool igb_clean_rx_irq(struct igb_q_vector *q_vector, int budget)
 
 	while (igb_test_staterr(rx_desc, E1000_RXD_STAT_DD)) {
 		struct igb_rx_buffer *buffer_info = &rx_ring->rx_buffer_info[i];
-		struct sk_buff *skb = buffer_info->skb;
+		struct sk_buff *skb = rx_ring->skb;
+		void *data = buffer_info->data;
 		union e1000_adv_rx_desc *next_rxd;
 
-		buffer_info->skb = NULL;
-		prefetch(skb->data);
+		prefetch(data + NET_SKB_PAD);
+		buffer_info->data = NULL;
+		rx_ring->skb = NULL;
 
 		i++;
 		if (i == rx_ring->count)
@@ -6091,6 +6095,15 @@ static bool igb_clean_rx_irq(struct igb_q_vector *q_vector, int budget)
 		next_rxd = IGB_RX_DESC(rx_ring, i);
 		prefetch(next_rxd);
 
+		if (!skb) {
+			skb = build_skb(data, IGB_FRAGSZ);
+			if (unlikely(!skb)) {
+				rx_ring->rx_stats.alloc_failed++;
+				buffer_info->data = data;
+				goto next_desc;
+			}
+			skb_reserve(skb, NET_SKB_PAD + NET_IP_ALIGN);
+		}
 		/*
 		 * This memory barrier is needed to keep us from reading
 		 * any other fields out of the rx_desc until we know the
@@ -6118,6 +6131,8 @@ static bool igb_clean_rx_irq(struct igb_q_vector *q_vector, int budget)
 			skb->data_len += length;
 			skb->truesize += PAGE_SIZE / 2;
 
+			skb_propagate_pfmemalloc(buffer_info->page, skb);
+
 			if ((page_count(buffer_info->page) != 1) ||
 			    (page_to_nid(buffer_info->page) != current_node))
 				buffer_info->page = NULL;
@@ -6132,9 +6147,9 @@ static bool igb_clean_rx_irq(struct igb_q_vector *q_vector, int budget)
 		if (!igb_test_staterr(rx_desc, E1000_RXD_STAT_EOP)) {
 			struct igb_rx_buffer *next_buffer;
 			next_buffer = &rx_ring->rx_buffer_info[i];
-			buffer_info->skb = next_buffer->skb;
+			buffer_info->data = next_buffer->data;
 			buffer_info->dma = next_buffer->dma;
-			next_buffer->skb = skb;
+			rx_ring->skb = skb;
 			next_buffer->dma = 0;
 			goto next_desc;
 		}
@@ -6158,6 +6173,7 @@ static bool igb_clean_rx_irq(struct igb_q_vector *q_vector, int budget)
 
 		skb->protocol = eth_type_trans(skb, rx_ring->netdev);
 
+		skb_record_rx_queue(skb, rx_ring->queue_index);
 		napi_gro_receive(&q_vector->napi, skb);
 
 		budget--;
@@ -6193,26 +6209,22 @@ next_desc:
 static bool igb_alloc_mapped_skb(struct igb_ring *rx_ring,
 				 struct igb_rx_buffer *bi)
 {
-	struct sk_buff *skb = bi->skb;
+	void *data = bi->data;
 	dma_addr_t dma = bi->dma;
 
 	if (dma)
 		return true;
 
-	if (likely(!skb)) {
-		skb = netdev_alloc_skb_ip_align(rx_ring->netdev,
-						IGB_RX_HDR_LEN);
-		bi->skb = skb;
-		if (!skb) {
+	if (likely(!data)) {
+		data = netdev_alloc_frag(IGB_FRAGSZ);
+		bi->data = data;
+		if (!data) {
 			rx_ring->rx_stats.alloc_failed++;
 			return false;
 		}
-
-		/* initialize skb for ring */
-		skb_record_rx_queue(skb, rx_ring->queue_index);
 	}
 
-	dma = dma_map_single(rx_ring->dev, skb->data,
+	dma = dma_map_single(rx_ring->dev, data + NET_SKB_PAD + NET_IP_ALIGN,
 			     IGB_RX_HDR_LEN, DMA_FROM_DEVICE);
 
 	if (dma_mapping_error(rx_ring->dev, dma)) {
@@ -6235,7 +6247,7 @@ static bool igb_alloc_mapped_page(struct igb_ring *rx_ring,
 		return true;
 
 	if (!page) {
-		page = __skb_alloc_page(GFP_ATOMIC, bi->skb);
+		page = alloc_page(GFP_ATOMIC | __GFP_COLD);
 		bi->page = page;
 		if (unlikely(!page)) {
 			rx_ring->rx_stats.alloc_failed++;
