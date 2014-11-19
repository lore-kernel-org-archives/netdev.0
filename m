From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/15] ixgbevf: Change receive model to use double buffered page based receives
Date: Tue, 18 Nov 2014 20:10:48 -0800
Message-ID: <1416370256-16834-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1416370256-16834-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:39897 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754512AbaKSELK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Nov 2014 23:11:10 -0500
In-Reply-To: <1416370256-16834-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch changes the basic receive path for ixgbevf so that instead of
receiving the data into an skb it is received into a double buffered page.
The main change is that the receives will be done in pages only and then
pull the header out of the page and copy it into the sk_buff data.

This has the advantages of reduced cache misses and improved performance on
IOMMU enabled systems.

CC: Alexander Duyck <alexander.h.duyck@redhat.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |  24 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 452 +++++++++++++++-------
 2 files changed, 331 insertions(+), 145 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index 72a354b..2362001 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -58,8 +58,9 @@ struct ixgbevf_tx_buffer {
 };
 
 struct ixgbevf_rx_buffer {
-	struct sk_buff *skb;
 	dma_addr_t dma;
+	struct page *page;
+	unsigned int page_offset;
 };
 
 struct ixgbevf_stats {
@@ -91,9 +92,10 @@ struct ixgbevf_ring {
 	void *desc;			/* descriptor ring memory */
 	dma_addr_t dma;			/* phys. address of descriptor ring */
 	unsigned int size;		/* length in bytes */
-	unsigned int count;		/* amount of descriptors */
-	unsigned int next_to_use;
-	unsigned int next_to_clean;
+	u16 count;			/* amount of descriptors */
+	u16 next_to_use;
+	u16 next_to_clean;
+	u16 next_to_alloc;
 
 	union {
 		struct ixgbevf_tx_buffer *tx_buffer_info;
@@ -109,12 +111,11 @@ struct ixgbevf_ring {
 
 	u64 hw_csum_rx_error;
 	u8 __iomem *tail;
+	struct sk_buff *skb;
 
 	u16 reg_idx; /* holds the special value that gets the hardware register
 		      * offset associated with this ring, which is different
 		      * for DCB and RSS modes */
-
-	u16 rx_buf_len;
 	int queue_index; /* needed for multiqueue queue management */
 };
 
@@ -133,12 +134,10 @@ struct ixgbevf_ring {
 
 /* Supported Rx Buffer Sizes */
 #define IXGBEVF_RXBUFFER_256   256    /* Used for packet split */
-#define IXGBEVF_RXBUFFER_2K    2048
-#define IXGBEVF_RXBUFFER_4K    4096
-#define IXGBEVF_RXBUFFER_8K    8192
-#define IXGBEVF_RXBUFFER_10K   10240
+#define IXGBEVF_RXBUFFER_2048	2048
 
 #define IXGBEVF_RX_HDR_SIZE IXGBEVF_RXBUFFER_256
+#define IXGBEVF_RX_BUFSZ	IXGBEVF_RXBUFFER_2048
 
 #define MAXIMUM_ETHERNET_VLAN_SIZE (VLAN_ETH_FRAME_LEN + ETH_FCS_LEN)
 
@@ -430,11 +429,6 @@ enum ixbgevf_state_t {
 	__IXGBEVF_WORK_INIT,
 };
 
-struct ixgbevf_cb {
-	struct sk_buff *prev;
-};
-#define IXGBE_CB(skb) ((struct ixgbevf_cb *)(skb)->cb)
-
 enum ixgbevf_boards {
 	board_82599_vf,
 	board_X540_vf,
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 20bebd2..2ca7c96 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -422,8 +422,7 @@ static void ixgbevf_process_skb_fields(struct ixgbevf_ring *rx_ring,
  * that this is in fact a non-EOP buffer.
  **/
 static bool ixgbevf_is_non_eop(struct ixgbevf_ring *rx_ring,
-			       union ixgbe_adv_rx_desc *rx_desc,
-			       struct sk_buff *skb)
+			       union ixgbe_adv_rx_desc *rx_desc)
 {
 	u32 ntc = rx_ring->next_to_clean + 1;
 
@@ -439,37 +438,40 @@ static bool ixgbevf_is_non_eop(struct ixgbevf_ring *rx_ring,
 	return true;
 }
 
-static bool ixgbevf_alloc_mapped_skb(struct ixgbevf_ring *rx_ring,
-				     struct ixgbevf_rx_buffer *bi)
+static bool ixgbevf_alloc_mapped_page(struct ixgbevf_ring *rx_ring,
+				      struct ixgbevf_rx_buffer *bi)
 {
-	struct sk_buff *skb = bi->skb;
+	struct page *page = bi->page;
 	dma_addr_t dma = bi->dma;
 
-	if (unlikely(skb))
+	/* since we are recycling buffers we should seldom need to alloc */
+	if (likely(page))
 		return true;
 
-	skb = netdev_alloc_skb_ip_align(rx_ring->netdev,
-					rx_ring->rx_buf_len);
-	if (unlikely(!skb)) {
-		rx_ring->rx_stats.alloc_rx_buff_failed++;
+	/* alloc new page for storage */
+	page = dev_alloc_page();
+	if (unlikely(!page)) {
+		rx_ring->rx_stats.alloc_rx_page_failed++;
 		return false;
 	}
 
-	dma = dma_map_single(rx_ring->dev, skb->data,
-			     rx_ring->rx_buf_len, DMA_FROM_DEVICE);
+	/* map page for use */
+	dma = dma_map_page(rx_ring->dev, page, 0,
+			   PAGE_SIZE, DMA_FROM_DEVICE);
 
 	/* if mapping failed free memory back to system since
 	 * there isn't much point in holding memory we can't use
 	 */
 	if (dma_mapping_error(rx_ring->dev, dma)) {
-		dev_kfree_skb_any(skb);
+		__free_page(page);
 
 		rx_ring->rx_stats.alloc_rx_buff_failed++;
 		return false;
 	}
 
-	bi->skb = skb;
 	bi->dma = dma;
+	bi->page = page;
+	bi->page_offset = 0;
 
 	return true;
 }
@@ -495,13 +497,13 @@ static void ixgbevf_alloc_rx_buffers(struct ixgbevf_ring *rx_ring,
 	i -= rx_ring->count;
 
 	do {
-		if (!ixgbevf_alloc_mapped_skb(rx_ring, bi))
+		if (!ixgbevf_alloc_mapped_page(rx_ring, bi))
 			break;
 
 		/* Refresh the desc even if pkt_addr didn't change
 		 * because each write-back erases this info.
 		 */
-		rx_desc->read.pkt_addr = cpu_to_le64(bi->dma);
+		rx_desc->read.pkt_addr = cpu_to_le64(bi->dma + bi->page_offset);
 
 		rx_desc++;
 		bi++;
@@ -524,6 +526,9 @@ static void ixgbevf_alloc_rx_buffers(struct ixgbevf_ring *rx_ring,
 		/* record the next descriptor to use */
 		rx_ring->next_to_use = i;
 
+		/* update next to alloc since we have filled the ring */
+		rx_ring->next_to_alloc = i;
+
 		/* Force memory writes to complete before letting h/w
 		 * know there are new descriptors to fetch.  (Only
 		 * applicable for weak-ordered memory model archs,
@@ -534,6 +539,257 @@ static void ixgbevf_alloc_rx_buffers(struct ixgbevf_ring *rx_ring,
 	}
 }
 
+/* ixgbevf_pull_tail - ixgbevf specific version of skb_pull_tail
+ * @rx_ring: Rx descriptor ring packet is being transacted on
+ * @skb: pointer to current skb being adjusted
+ *
+ * This function is an ixgbevf specific version of __pskb_pull_tail.  The
+ * main difference between this version and the original function is that
+ * this function can make several assumptions about the state of things
+ * that allow for significant optimizations versus the standard function.
+ * As a result we can do things like drop a frag and maintain an accurate
+ * truesize for the skb.
+ */
+static void ixgbevf_pull_tail(struct ixgbevf_ring *rx_ring,
+			      struct sk_buff *skb)
+{
+	struct skb_frag_struct *frag = &skb_shinfo(skb)->frags[0];
+	unsigned char *va;
+	unsigned int pull_len;
+
+	/* it is valid to use page_address instead of kmap since we are
+	 * working with pages allocated out of the lomem pool per
+	 * alloc_page(GFP_ATOMIC)
+	 */
+	va = skb_frag_address(frag);
+
+	/* we need the header to contain the greater of either ETH_HLEN or
+	 * 60 bytes if the skb->len is less than 60 for skb_pad.
+	 */
+	pull_len = eth_get_headlen(va, IXGBEVF_RX_HDR_SIZE);
+
+	/* align pull length to size of long to optimize memcpy performance */
+	skb_copy_to_linear_data(skb, va, ALIGN(pull_len, sizeof(long)));
+
+	/* update all of the pointers */
+	skb_frag_size_sub(frag, pull_len);
+	frag->page_offset += pull_len;
+	skb->data_len -= pull_len;
+	skb->tail += pull_len;
+}
+
+/* ixgbevf_cleanup_headers - Correct corrupted or empty headers
+ * @rx_ring: Rx descriptor ring packet is being transacted on
+ * @rx_desc: pointer to the EOP Rx descriptor
+ * @skb: pointer to current skb being fixed
+ *
+ * Check for corrupted packet headers caused by senders on the local L2
+ * embedded NIC switch not setting up their Tx Descriptors right.  These
+ * should be very rare.
+ *
+ * Also address the case where we are pulling data in on pages only
+ * and as such no data is present in the skb header.
+ *
+ * In addition if skb is not at least 60 bytes we need to pad it so that
+ * it is large enough to qualify as a valid Ethernet frame.
+ *
+ * Returns true if an error was encountered and skb was freed.
+ */
+static bool ixgbevf_cleanup_headers(struct ixgbevf_ring *rx_ring,
+				    union ixgbe_adv_rx_desc *rx_desc,
+				    struct sk_buff *skb)
+{
+	/* verify that the packet does not have any known errors */
+	if (unlikely(ixgbevf_test_staterr(rx_desc,
+					  IXGBE_RXDADV_ERR_FRAME_ERR_MASK))) {
+		struct net_device *netdev = rx_ring->netdev;
+
+		if (!(netdev->features & NETIF_F_RXALL)) {
+			dev_kfree_skb_any(skb);
+			return true;
+		}
+	}
+
+	/* place header in linear portion of buffer */
+	if (skb_is_nonlinear(skb))
+		ixgbevf_pull_tail(rx_ring, skb);
+
+	/* if skb_pad returns an error the skb was freed */
+	if (unlikely(skb->len < 60)) {
+		int pad_len = 60 - skb->len;
+
+		if (skb_pad(skb, pad_len))
+			return true;
+		__skb_put(skb, pad_len);
+	}
+
+	return false;
+}
+
+/* ixgbevf_reuse_rx_page - page flip buffer and store it back on the ring
+ * @rx_ring: Rx descriptor ring to store buffers on
+ * @old_buff: donor buffer to have page reused
+ *
+ * Synchronizes page for reuse by the adapter
+ */
+static void ixgbevf_reuse_rx_page(struct ixgbevf_ring *rx_ring,
+				  struct ixgbevf_rx_buffer *old_buff)
+{
+	struct ixgbevf_rx_buffer *new_buff;
+	u16 nta = rx_ring->next_to_alloc;
+
+	new_buff = &rx_ring->rx_buffer_info[nta];
+
+	/* update, and store next to alloc */
+	nta++;
+	rx_ring->next_to_alloc = (nta < rx_ring->count) ? nta : 0;
+
+	/* transfer page from old buffer to new buffer */
+	new_buff->page = old_buff->page;
+	new_buff->dma = old_buff->dma;
+	new_buff->page_offset = old_buff->page_offset;
+
+	/* sync the buffer for use by the device */
+	dma_sync_single_range_for_device(rx_ring->dev, new_buff->dma,
+					 new_buff->page_offset,
+					 IXGBEVF_RX_BUFSZ,
+					 DMA_FROM_DEVICE);
+}
+
+/* ixgbevf_add_rx_frag - Add contents of Rx buffer to sk_buff
+ * @rx_ring: Rx descriptor ring to transact packets on
+ * @rx_buffer: buffer containing page to add
+ * @rx_desc: descriptor containing length of buffer written by hardware
+ * @skb: sk_buff to place the data into
+ *
+ * This function will add the data contained in rx_buffer->page to the skb.
+ * This is done either through a direct copy if the data in the buffer is
+ * less than the skb header size, otherwise it will just attach the page as
+ * a frag to the skb.
+ *
+ * The function will then update the page offset if necessary and return
+ * true if the buffer can be reused by the adapter.
+ */
+static bool ixgbevf_add_rx_frag(struct ixgbevf_ring *rx_ring,
+				struct ixgbevf_rx_buffer *rx_buffer,
+				union ixgbe_adv_rx_desc *rx_desc,
+				struct sk_buff *skb)
+{
+	struct page *page = rx_buffer->page;
+	unsigned int size = le16_to_cpu(rx_desc->wb.upper.length);
+#if (PAGE_SIZE < 8192)
+	unsigned int truesize = IXGBEVF_RX_BUFSZ;
+#else
+	unsigned int truesize = ALIGN(size, L1_CACHE_BYTES);
+#endif
+
+	if ((size <= IXGBEVF_RX_HDR_SIZE) && !skb_is_nonlinear(skb)) {
+		unsigned char *va = page_address(page) + rx_buffer->page_offset;
+
+		memcpy(__skb_put(skb, size), va, ALIGN(size, sizeof(long)));
+
+		/* we can reuse buffer as-is, just make sure it is local */
+		if (likely(page_to_nid(page) == numa_node_id()))
+			return true;
+
+		/* this page cannot be reused so discard it */
+		put_page(page);
+		return false;
+	}
+
+	skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags, page,
+			rx_buffer->page_offset, size, truesize);
+
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
+	rx_buffer->page_offset ^= IXGBEVF_RX_BUFSZ;
+
+	/* since we are the only owner of the page and we need to
+	 * increment it.
+	 */
+	atomic_inc(&page->_count);
+#else
+	/* move offset up to the next cache line */
+	rx_buffer->page_offset += truesize;
+
+	if (rx_buffer->page_offset > (PAGE_SIZE - IXGBEVF_RX_BUFSZ))
+		return false;
+
+	/* bump ref count on page before it is given to the stack */
+	get_page(page);
+#endif
+
+	return true;
+}
+
+static struct sk_buff *ixgbevf_fetch_rx_buffer(struct ixgbevf_ring *rx_ring,
+					       union ixgbe_adv_rx_desc *rx_desc,
+					       struct sk_buff *skb)
+{
+	struct ixgbevf_rx_buffer *rx_buffer;
+	struct page *page;
+
+	rx_buffer = &rx_ring->rx_buffer_info[rx_ring->next_to_clean];
+	page = rx_buffer->page;
+	prefetchw(page);
+
+	if (likely(!skb)) {
+		void *page_addr = page_address(page) +
+				  rx_buffer->page_offset;
+
+		/* prefetch first cache line of first page */
+		prefetch(page_addr);
+#if L1_CACHE_BYTES < 128
+		prefetch(page_addr + L1_CACHE_BYTES);
+#endif
+
+		/* allocate a skb to store the frags */
+		skb = netdev_alloc_skb_ip_align(rx_ring->netdev,
+						IXGBEVF_RX_HDR_SIZE);
+		if (unlikely(!skb)) {
+			rx_ring->rx_stats.alloc_rx_buff_failed++;
+			return NULL;
+		}
+
+		/* we will be copying header into skb->data in
+		 * pskb_may_pull so it is in our interest to prefetch
+		 * it now to avoid a possible cache miss
+		 */
+		prefetchw(skb->data);
+	}
+
+	/* we are reusing so sync this buffer for CPU use */
+	dma_sync_single_range_for_cpu(rx_ring->dev,
+				      rx_buffer->dma,
+				      rx_buffer->page_offset,
+				      IXGBEVF_RX_BUFSZ,
+				      DMA_FROM_DEVICE);
+
+	/* pull page into skb */
+	if (ixgbevf_add_rx_frag(rx_ring, rx_buffer, rx_desc, skb)) {
+		/* hand second half of page back to the ring */
+		ixgbevf_reuse_rx_page(rx_ring, rx_buffer);
+	} else {
+		/* we are not reusing the buffer so unmap it */
+		dma_unmap_page(rx_ring->dev, rx_buffer->dma,
+			       PAGE_SIZE, DMA_FROM_DEVICE);
+	}
+
+	/* clear contents of buffer_info */
+	rx_buffer->dma = 0;
+	rx_buffer->page = NULL;
+
+	return skb;
+}
+
 static inline void ixgbevf_irq_enable_queues(struct ixgbevf_adapter *adapter,
 					     u32 qmask)
 {
@@ -548,12 +804,10 @@ static int ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
 {
 	unsigned int total_rx_bytes = 0, total_rx_packets = 0;
 	u16 cleaned_count = ixgbevf_desc_unused(rx_ring);
+	struct sk_buff *skb = rx_ring->skb;
 
 	do {
 		union ixgbe_adv_rx_desc *rx_desc;
-		struct ixgbevf_rx_buffer *rx_buffer;
-		struct sk_buff *skb;
-		u16 ntc;
 
 		/* return some buffers to hardware, one at a time is too slow */
 		if (cleaned_count >= IXGBEVF_RX_BUFFER_WRITE) {
@@ -561,9 +815,7 @@ static int ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
 			cleaned_count = 0;
 		}
 
-		ntc = rx_ring->next_to_clean;
-		rx_desc = IXGBEVF_RX_DESC(rx_ring, ntc);
-		rx_buffer = &rx_ring->rx_buffer_info[ntc];
+		rx_desc = IXGBEVF_RX_DESC(rx_ring, rx_ring->next_to_clean);
 
 		if (!ixgbevf_test_staterr(rx_desc, IXGBE_RXD_STAT_DD))
 			break;
@@ -574,40 +826,22 @@ static int ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
 		 */
 		rmb();
 
-		skb = rx_buffer->skb;
-		prefetch(skb->data);
-
-		/* pull the header of the skb in */
-		__skb_put(skb, le16_to_cpu(rx_desc->wb.upper.length));
-
-		dma_unmap_single(rx_ring->dev, rx_buffer->dma,
-				 rx_ring->rx_buf_len,
-				 DMA_FROM_DEVICE);
+		/* retrieve a buffer from the ring */
+		skb = ixgbevf_fetch_rx_buffer(rx_ring, rx_desc, skb);
 
-		/* clear skb reference in buffer info structure */
-		rx_buffer->skb = NULL;
-		rx_buffer->dma = 0;
+		/* exit if we failed to retrieve a buffer */
+		if (!skb)
+			break;
 
 		cleaned_count++;
 
-		/* place incomplete frames back on ring for completion */
-		if (ixgbevf_is_non_eop(rx_ring, rx_desc, skb))
+		/* fetch next buffer in frame if non-eop */
+		if (ixgbevf_is_non_eop(rx_ring, rx_desc))
 			continue;
 
-		/* we should not be chaining buffers, if we did drop the skb */
-		if (IXGBE_CB(skb)->prev) {
-			do {
-				struct sk_buff *this = skb;
-				skb = IXGBE_CB(skb)->prev;
-				dev_kfree_skb(this);
-			} while (skb);
-			continue;
-		}
-
-		/* ERR_MASK will only have valid bits if EOP set */
-		if (unlikely(ixgbevf_test_staterr(rx_desc,
-					    IXGBE_RXDADV_ERR_FRAME_ERR_MASK))) {
-			dev_kfree_skb_irq(skb);
+		/* verify the packet layout is correct */
+		if (ixgbevf_cleanup_headers(rx_ring, rx_desc, skb)) {
+			skb = NULL;
 			continue;
 		}
 
@@ -631,10 +865,16 @@ static int ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
 
 		ixgbevf_rx_skb(q_vector, skb);
 
+		/* reset skb pointer */
+		skb = NULL;
+
 		/* update budget accounting */
 		budget--;
 	} while (likely(budget));
 
+	/* place incomplete frames back on ring for completion */
+	rx_ring->skb = skb;
+
 	u64_stats_update_begin(&rx_ring->syncp);
 	rx_ring->stats.packets += total_rx_packets;
 	rx_ring->stats.bytes += total_rx_bytes;
@@ -642,9 +882,6 @@ static int ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
 	q_vector->rx.total_packets += total_rx_packets;
 	q_vector->rx.total_bytes += total_rx_bytes;
 
-	if (cleaned_count)
-		ixgbevf_alloc_rx_buffers(rx_ring, cleaned_count);
-
 	return total_rx_packets;
 }
 
@@ -1275,19 +1512,15 @@ static void ixgbevf_configure_tx(struct ixgbevf_adapter *adapter)
 
 static void ixgbevf_configure_srrctl(struct ixgbevf_adapter *adapter, int index)
 {
-	struct ixgbevf_ring *rx_ring;
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 srrctl;
 
-	rx_ring = adapter->rx_ring[index];
-
 	srrctl = IXGBE_SRRCTL_DROP_EN;
 
+	srrctl |= IXGBEVF_RX_HDR_SIZE << IXGBE_SRRCTL_BSIZEHDRSIZE_SHIFT;
+	srrctl |= IXGBEVF_RX_BUFSZ >> IXGBE_SRRCTL_BSIZEPKT_SHIFT;
 	srrctl |= IXGBE_SRRCTL_DESCTYPE_ADV_ONEBUF;
 
-	srrctl |= ALIGN(rx_ring->rx_buf_len, 1024) >>
-		  IXGBE_SRRCTL_BSIZEPKT_SHIFT;
-
 	IXGBE_WRITE_REG(hw, IXGBE_VFSRRCTL(index), srrctl);
 }
 
@@ -1306,40 +1539,6 @@ static void ixgbevf_setup_psrtype(struct ixgbevf_adapter *adapter)
 	IXGBE_WRITE_REG(hw, IXGBE_VFPSRTYPE, psrtype);
 }
 
-static void ixgbevf_set_rx_buffer_len(struct ixgbevf_adapter *adapter)
-{
-	struct ixgbe_hw *hw = &adapter->hw;
-	struct net_device *netdev = adapter->netdev;
-	int max_frame = netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
-	int i;
-	u16 rx_buf_len;
-
-	/* notify the PF of our intent to use this size of frame */
-	ixgbevf_rlpml_set_vf(hw, max_frame);
-
-	/* PF will allow an extra 4 bytes past for vlan tagged frames */
-	max_frame += VLAN_HLEN;
-
-	/*
-	 * Allocate buffer sizes that fit well into 32K and
-	 * take into account max frame size of 9.5K
-	 */
-	if ((hw->mac.type == ixgbe_mac_X540_vf) &&
-	    (max_frame <= MAXIMUM_ETHERNET_VLAN_SIZE))
-		rx_buf_len = MAXIMUM_ETHERNET_VLAN_SIZE;
-	else if (max_frame <= IXGBEVF_RXBUFFER_2K)
-		rx_buf_len = IXGBEVF_RXBUFFER_2K;
-	else if (max_frame <= IXGBEVF_RXBUFFER_4K)
-		rx_buf_len = IXGBEVF_RXBUFFER_4K;
-	else if (max_frame <= IXGBEVF_RXBUFFER_8K)
-		rx_buf_len = IXGBEVF_RXBUFFER_8K;
-	else
-		rx_buf_len = IXGBEVF_RXBUFFER_10K;
-
-	for (i = 0; i < adapter->num_rx_queues; i++)
-		adapter->rx_ring[i]->rx_buf_len = rx_buf_len;
-}
-
 #define IXGBEVF_MAX_RX_DESC_POLL 10
 static void ixgbevf_disable_rx_queue(struct ixgbevf_adapter *adapter,
 				     struct ixgbevf_ring *ring)
@@ -1417,12 +1616,13 @@ static void ixgbevf_configure_rx_ring(struct ixgbevf_adapter *adapter,
 	/* reset ntu and ntc to place SW in sync with hardwdare */
 	ring->next_to_clean = 0;
 	ring->next_to_use = 0;
+	ring->next_to_alloc = 0;
 
 	ixgbevf_configure_srrctl(adapter, reg_idx);
 
-	/* prevent DMA from exceeding buffer space available */
-	rxdctl &= ~IXGBE_RXDCTL_RLPMLMASK;
-	rxdctl |= ring->rx_buf_len | IXGBE_RXDCTL_RLPML_EN;
+	/* allow any size packet since we can handle overflow */
+	rxdctl &= ~IXGBE_RXDCTL_RLPML_EN;
+
 	rxdctl |= IXGBE_RXDCTL_ENABLE | IXGBE_RXDCTL_VME;
 	IXGBE_WRITE_REG(hw, IXGBE_VFRXDCTL(reg_idx), rxdctl);
 
@@ -1439,11 +1639,13 @@ static void ixgbevf_configure_rx_ring(struct ixgbevf_adapter *adapter,
 static void ixgbevf_configure_rx(struct ixgbevf_adapter *adapter)
 {
 	int i;
+	struct ixgbe_hw *hw = &adapter->hw;
+	struct net_device *netdev = adapter->netdev;
 
 	ixgbevf_setup_psrtype(adapter);
 
-	/* set_rx_buffer_len must be called before ring initialization */
-	ixgbevf_set_rx_buffer_len(adapter);
+	/* notify the PF of our intent to use this size of frame */
+	ixgbevf_rlpml_set_vf(hw, netdev->mtu + ETH_HLEN + ETH_FCS_LEN);
 
 	/* Setup the HW Rx Head and Tail Descriptor Pointers and
 	 * the Base and Length of the Rx Descriptor Ring */
@@ -1748,32 +1950,32 @@ void ixgbevf_up(struct ixgbevf_adapter *adapter)
  **/
 static void ixgbevf_clean_rx_ring(struct ixgbevf_ring *rx_ring)
 {
+	struct device *dev = rx_ring->dev;
 	unsigned long size;
 	unsigned int i;
 
+	/* Free Rx ring sk_buff */
+	if (rx_ring->skb) {
+		dev_kfree_skb(rx_ring->skb);
+		rx_ring->skb = NULL;
+	}
+
+	/* ring already cleared, nothing to do */
 	if (!rx_ring->rx_buffer_info)
 		return;
 
-	/* Free all the Rx ring sk_buffs */
+	/* Free all the Rx ring pages */
 	for (i = 0; i < rx_ring->count; i++) {
-		struct ixgbevf_rx_buffer *rx_buffer_info;
+		struct ixgbevf_rx_buffer *rx_buffer;
 
-		rx_buffer_info = &rx_ring->rx_buffer_info[i];
-		if (rx_buffer_info->dma) {
-			dma_unmap_single(rx_ring->dev, rx_buffer_info->dma,
-					 rx_ring->rx_buf_len,
-					 DMA_FROM_DEVICE);
-			rx_buffer_info->dma = 0;
-		}
-		if (rx_buffer_info->skb) {
-			struct sk_buff *skb = rx_buffer_info->skb;
-			rx_buffer_info->skb = NULL;
-			do {
-				struct sk_buff *this = skb;
-				skb = IXGBE_CB(skb)->prev;
-				dev_kfree_skb(this);
-			} while (skb);
-		}
+		rx_buffer = &rx_ring->rx_buffer_info[i];
+		if (rx_buffer->dma)
+			dma_unmap_page(dev, rx_buffer->dma,
+				       PAGE_SIZE, DMA_FROM_DEVICE);
+		rx_buffer->dma = 0;
+		if (rx_buffer->page)
+			__free_page(rx_buffer->page);
+		rx_buffer->page = NULL;
 	}
 
 	size = sizeof(struct ixgbevf_rx_buffer) * rx_ring->count;
@@ -3320,21 +3522,11 @@ static int ixgbevf_set_mac(struct net_device *netdev, void *p)
 static int ixgbevf_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_hw *hw = &adapter->hw;
 	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN;
-	int max_possible_frame = MAXIMUM_ETHERNET_VLAN_SIZE;
-
-	switch (adapter->hw.api_version) {
-	case ixgbe_mbox_api_11:
-		max_possible_frame = IXGBE_MAX_JUMBO_FRAME_SIZE;
-		break;
-	default:
-		if (adapter->hw.mac.type == ixgbe_mac_X540_vf)
-			max_possible_frame = IXGBE_MAX_JUMBO_FRAME_SIZE;
-		break;
-	}
 
 	/* MTU < 68 is an error and causes problems on some kernels */
-	if ((new_mtu < 68) || (max_frame > max_possible_frame))
+	if ((new_mtu < 68) || (max_frame > IXGBE_MAX_JUMBO_FRAME_SIZE))
 		return -EINVAL;
 
 	hw_dbg(&adapter->hw, "changing MTU from %d to %d\n",
@@ -3342,8 +3534,8 @@ static int ixgbevf_change_mtu(struct net_device *netdev, int new_mtu)
 	/* must set new MTU before calling down or up */
 	netdev->mtu = new_mtu;
 
-	if (netif_running(netdev))
-		ixgbevf_reinit_locked(adapter);
+	/* notify the PF of our intent to use this size of frame */
+	ixgbevf_rlpml_set_vf(hw, max_frame);
 
 	return 0;
 }
-- 
1.9.3
