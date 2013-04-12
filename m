From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/11] ixgbe: Support using build_skb in the case that jumbo frames are disabled
Date: Fri, 12 Apr 2013 04:24:16 -0700
Message-ID: <1365765866-15741-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1365765866-15741-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:11922 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752922Ab3DLLYe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Apr 2013 07:24:34 -0400
In-Reply-To: <1365765866-15741-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change makes it so that we can enable the use of build_skb for cases
where jumbo frames are disabled.  The advantage to this is that we do not have
to perform a memcpy to populate the header and as a result we see a
significant performance improvement.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |   7 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 163 ++++++++++++++++++++------
 2 files changed, 137 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index a8e10cf..e5bc1d7 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -207,6 +207,7 @@ enum ixgbe_ring_state_t {
 	__IXGBE_RX_RSC_ENABLED,
 	__IXGBE_RX_CSUM_UDP_ZERO_ERR,
 	__IXGBE_RX_FCOE,
+	__IXGBE_RX_BUILD_SKB_ENABLED,
 };
 
 #define check_for_tx_hang(ring) \
@@ -221,6 +222,12 @@ enum ixgbe_ring_state_t {
 	set_bit(__IXGBE_RX_RSC_ENABLED, &(ring)->state)
 #define clear_ring_rsc_enabled(ring) \
 	clear_bit(__IXGBE_RX_RSC_ENABLED, &(ring)->state)
+#define ring_uses_build_skb(ring) \
+	test_bit(__IXGBE_RX_BUILD_SKB_ENABLED, &(ring)->state)
+#define set_ring_build_skb_enabled(ring) \
+	set_bit(__IXGBE_RX_BUILD_SKB_ENABLED, &(ring)->state)
+#define clear_ring_build_skb_enabled(ring) \
+	clear_bit(__IXGBE_RX_BUILD_SKB_ENABLED, &(ring)->state)
 struct ixgbe_ring {
 	struct ixgbe_ring *next;	/* pointer to next ring in q_vector */
 	struct ixgbe_q_vector *q_vector; /* backpointer to host q_vector */
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 1339932..0c51a9f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1227,6 +1227,14 @@ static bool ixgbe_alloc_mapped_page(struct ixgbe_ring *rx_ring,
 	return true;
 }
 
+static inline unsigned int ixgbe_rx_offset(struct ixgbe_ring *rx_ring)
+{
+	if (ring_uses_build_skb(rx_ring))
+		return NET_SKB_PAD + NET_IP_ALIGN;
+	else
+		return 0;
+}
+
 /**
  * ixgbe_alloc_rx_buffers - Replace used receive buffers
  * @rx_ring: ring to place buffers on
@@ -1254,7 +1262,9 @@ void ixgbe_alloc_rx_buffers(struct ixgbe_ring *rx_ring, u16 cleaned_count)
 		 * Refresh the desc even if buffer_addrs didn't change
 		 * because each write-back erases this info.
 		 */
-		rx_desc->read.pkt_addr = cpu_to_le64(bi->dma + bi->page_offset);
+		rx_desc->read.pkt_addr = cpu_to_le64(bi->dma +
+						     bi->page_offset +
+						     ixgbe_rx_offset(rx_ring));
 
 		rx_desc++;
 		bi++;
@@ -1673,6 +1683,47 @@ static void ixgbe_reuse_rx_page(struct ixgbe_ring *rx_ring,
 					 DMA_FROM_DEVICE);
 }
 
+static bool ixgbe_can_reuse_rx_page(struct ixgbe_ring *rx_ring,
+				    struct ixgbe_rx_buffer *rx_buffer,
+				    struct page *page,
+				    unsigned int truesize)
+{
+#if (PAGE_SIZE >= 8192)
+	unsigned int last_offset = ixgbe_rx_pg_size(rx_ring) -
+				   ixgbe_rx_bufsz(rx_ring);
+
+#endif
+	/* avoid re-using remote pages */
+	if (unlikely(page_to_nid(page) != numa_node_id()))
+		return false;
+
+#if (PAGE_SIZE < 8192)
+	/* if we are only owner of page we can reuse it */
+	if (unlikely(page_count(page) != 1))
+		return false;
+
+	/* flip page offset to other buffer */
+	rx_buffer->page_offset ^= truesize;
+
+	/* since we are the only owner of the page and we need to
+	 * increment it, just set the value to 2 in order to avoid
+	 * an unnecessary locked operation
+	 */
+	atomic_set(&page->_count, 2);
+#else
+	/* move offset up to the next cache line */
+	rx_buffer->page_offset += truesize;
+
+	if (rx_buffer->page_offset > last_offset)
+		return false;
+
+	/* bump ref count on page before it is given to the stack */
+	get_page(page);
+#endif
+
+	return true;
+}
+
 /**
  * ixgbe_add_rx_frag - Add contents of Rx buffer to sk_buff
  * @rx_ring: rx descriptor ring to transact packets on
@@ -1699,8 +1750,6 @@ static bool ixgbe_add_rx_frag(struct ixgbe_ring *rx_ring,
 	unsigned int truesize = ixgbe_rx_bufsz(rx_ring);
 #else
 	unsigned int truesize = ALIGN(size, L1_CACHE_BYTES);
-	unsigned int last_offset = ixgbe_rx_pg_size(rx_ring) -
-				   ixgbe_rx_bufsz(rx_ring);
 #endif
 
 	if ((size <= IXGBE_RX_HDR_SIZE) && !skb_is_nonlinear(skb)) {
@@ -1720,36 +1769,82 @@ static bool ixgbe_add_rx_frag(struct ixgbe_ring *rx_ring,
 	skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags, page,
 			rx_buffer->page_offset, size, truesize);
 
-	/* avoid re-using remote pages */
-	if (unlikely(page_to_nid(page) != numa_node_id()))
-		return false;
+	return ixgbe_can_reuse_rx_page(rx_ring, rx_buffer, page, truesize);
+}
 
+static struct sk_buff *ixgbe_build_rx_buffer(struct ixgbe_ring *rx_ring,
+					     union ixgbe_adv_rx_desc *rx_desc)
+{
+	struct ixgbe_rx_buffer *rx_buffer;
+	struct sk_buff *skb;
+	struct page *page;
+	void *page_addr;
+	unsigned int size = le16_to_cpu(rx_desc->wb.upper.length);
 #if (PAGE_SIZE < 8192)
-	/* if we are only owner of page we can reuse it */
-	if (unlikely(page_count(page) != 1))
-		return false;
+	unsigned int truesize = ixgbe_rx_bufsz(rx_ring);
+#else
+	unsigned int truesize = SKB_DATA_ALIGN(sizeof(struct skb_shared_info)) +
+				SKB_DATA_ALIGN(NET_SKB_PAD +
+					       NET_IP_ALIGN +
+					       size);
+#endif
 
-	/* flip page offset to other buffer */
-	rx_buffer->page_offset ^= truesize;
+	/* If we spanned a buffer we have a huge mess so test for it */
+	BUG_ON(unlikely(!ixgbe_test_staterr(rx_desc, IXGBE_RXD_STAT_EOP)));
 
-	/*
-	 * since we are the only owner of the page and we need to
-	 * increment it, just set the value to 2 in order to avoid
-	 * an unecessary locked operation
-	 */
-	atomic_set(&page->_count, 2);
-#else
-	/* move offset up to the next cache line */
-	rx_buffer->page_offset += truesize;
+	/* Guarantee this function can be used by verifying buffer sizes */
+	BUILD_BUG_ON(SKB_WITH_OVERHEAD(IXGBE_RXBUFFER_2K) < (NET_SKB_PAD +
+							     NET_IP_ALIGN +
+							     VLAN_HLEN +
+							     ETH_FRAME_LEN +
+							     ETH_FCS_LEN));
 
-	if (rx_buffer->page_offset > last_offset)
-		return false;
+	rx_buffer = &rx_ring->rx_buffer_info[rx_ring->next_to_clean];
+	page = rx_buffer->page;
+	prefetchw(page);
 
-	/* bump ref count on page before it is given to the stack */
-	get_page(page);
+	page_addr = page_address(page) + rx_buffer->page_offset;
+
+	/* prefetch first cache line of first page */
+	prefetch(page_addr + NET_SKB_PAD + NET_IP_ALIGN);
+#if L1_CACHE_BYTES < 128
+	prefetch(page_addr + L1_CACHE_BYTES + NET_SKB_PAD + NET_IP_ALIGN);
 #endif
 
-	return true;
+	/* build an skb to go around the page buffer */
+	skb = build_skb(page_addr, truesize);
+	if (unlikely(!skb)) {
+		rx_ring->rx_stats.alloc_rx_buff_failed++;
+		return NULL;
+	}
+
+	/* we are reusing so sync this buffer for CPU use */
+	dma_sync_single_range_for_cpu(rx_ring->dev,
+				      rx_buffer->dma,
+				      rx_buffer->page_offset,
+				      ixgbe_rx_bufsz(rx_ring),
+				      DMA_FROM_DEVICE);
+
+	/* update pointers within the skb to store the data */
+	skb_reserve(skb, NET_IP_ALIGN + NET_SKB_PAD);
+	__skb_put(skb, size);
+
+	if (ixgbe_can_reuse_rx_page(rx_ring, rx_buffer, page, truesize)) {
+		/* hand second half of page back to the ring */
+		ixgbe_reuse_rx_page(rx_ring, rx_buffer);
+	} else {
+		/* we are not reusing the buffer so unmap it */
+		dma_unmap_page(rx_ring->dev, rx_buffer->dma,
+			       ixgbe_rx_pg_size(rx_ring),
+			       DMA_FROM_DEVICE);
+	}
+
+	/* clear contents of buffer_info */
+	rx_buffer->skb = NULL;
+	rx_buffer->dma = 0;
+	rx_buffer->page = NULL;
+
+	return skb;
 }
 
 static struct sk_buff *ixgbe_fetch_rx_buffer(struct ixgbe_ring *rx_ring,
@@ -1883,7 +1978,10 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 		rmb();
 
 		/* retrieve a buffer from the ring */
-		skb = ixgbe_fetch_rx_buffer(rx_ring, rx_desc);
+		if (ring_uses_build_skb(rx_ring))
+			skb = ixgbe_build_rx_buffer(rx_ring, rx_desc);
+		else
+			skb = ixgbe_fetch_rx_buffer(rx_ring, rx_desc);
 
 		/* exit if we failed to retrieve a buffer */
 		if (!skb)
@@ -3312,7 +3410,6 @@ static void ixgbe_set_rx_buffer_len(struct ixgbe_adapter *adapter)
 		max_frame = IXGBE_FCOE_JUMBO_FRAME_SIZE;
 
 #endif /* IXGBE_FCOE */
-
 	/* adjust max frame to be at least the size of a standard frame */
 	if (max_frame < (ETH_FRAME_LEN + ETH_FCS_LEN))
 		max_frame = (ETH_FRAME_LEN + ETH_FCS_LEN);
@@ -3330,16 +3427,16 @@ static void ixgbe_set_rx_buffer_len(struct ixgbe_adapter *adapter)
 	hlreg0 |= IXGBE_HLREG0_JUMBOEN;
 	IXGBE_WRITE_REG(hw, IXGBE_HLREG0, hlreg0);
 
-	/*
-	 * Setup the HW Rx Head and Tail Descriptor Pointers and
-	 * the Base and Length of the Rx Descriptor Ring
-	 */
+	/* Setup the ring features based on max frame size */
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		rx_ring = adapter->rx_ring[i];
+		clear_ring_rsc_enabled(rx_ring);
+		clear_ring_build_skb_enabled(rx_ring);
+
 		if (adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED)
 			set_ring_rsc_enabled(rx_ring);
-		else
-			clear_ring_rsc_enabled(rx_ring);
+		else if (max_frame <= (ETH_FRAME_LEN + ETH_FCS_LEN))
+			set_ring_build_skb_enabled(rx_ring);
 	}
 }
 
-- 
1.7.11.7
