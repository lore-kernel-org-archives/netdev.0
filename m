From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/12] i40e/i40evf: Add support for using order 1 pages with a 3K buffer
Date: Sat,  8 Apr 2017 02:55:51 -0700
Message-ID: <20170408095553.78307-11-jeffrey.t.kirsher@intel.com>
References: <20170408095553.78307-1-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:26215 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752046AbdDHJ4N (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 8 Apr 2017 05:56:13 -0400
In-Reply-To: <20170408095553.78307-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

There are situations where adding padding to the front and back of an Rx
buffer will require that we add additional padding.  Specifically if
NET_IP_ALIGN is non-zero, or the MTU size is larger than 7.5K we would need
to use 2K buffers which leaves us with no room for the padding.

To preemptively address these cases I am adding support for 3K buffers to
the Rx path so that we can provide the additional padding needed in the
event of NET_IP_ALIGN being non-zero or a cache line being greater than 64.

Change-ID: I938bc1ba611285428df39a613cd66f98e60b55c7
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c     |  3 ++-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c     | 27 +++++++++++++------------
 drivers/net/ethernet/intel/i40e/i40e_txrx.h     | 12 +++++++++++
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c   | 27 +++++++++++++------------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h   | 12 +++++++++++
 drivers/net/ethernet/intel/i40evf/i40evf_main.c |  6 ++++++
 6 files changed, 60 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 3b1dab7a7cc9..97489d69029a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -3085,7 +3085,8 @@ static int i40e_vsi_configure_rx(struct i40e_vsi *vsi)
 #endif
 	} else {
 		vsi->max_frame = I40E_MAX_RXBUFFER;
-		vsi->rx_buf_len = I40E_RXBUFFER_2048;
+		vsi->rx_buf_len = (PAGE_SIZE < 8192) ? I40E_RXBUFFER_3072 :
+						       I40E_RXBUFFER_2048;
 	}
 
 	/* set up individual rings */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index e95428c7aba0..bee16726c104 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1138,14 +1138,15 @@ void i40e_clean_rx_ring(struct i40e_ring *rx_ring)
 		dma_sync_single_range_for_cpu(rx_ring->dev,
 					      rx_bi->dma,
 					      rx_bi->page_offset,
-					      I40E_RXBUFFER_2048,
+					      rx_ring->rx_buf_len,
 					      DMA_FROM_DEVICE);
 
 		/* free resources associated with mapping */
 		dma_unmap_page_attrs(rx_ring->dev, rx_bi->dma,
-				     PAGE_SIZE,
+				     i40e_rx_pg_size(rx_ring),
 				     DMA_FROM_DEVICE,
 				     I40E_RX_DMA_ATTR);
+
 		__page_frag_cache_drain(rx_bi->page, rx_bi->pagecnt_bias);
 
 		rx_bi->page = NULL;
@@ -1267,7 +1268,7 @@ static bool i40e_alloc_mapped_page(struct i40e_ring *rx_ring,
 	}
 
 	/* alloc new page for storage */
-	page = dev_alloc_page();
+	page = dev_alloc_pages(i40e_rx_pg_order(rx_ring));
 	if (unlikely(!page)) {
 		rx_ring->rx_stats.alloc_page_failed++;
 		return false;
@@ -1275,7 +1276,7 @@ static bool i40e_alloc_mapped_page(struct i40e_ring *rx_ring,
 
 	/* map page for use */
 	dma = dma_map_page_attrs(rx_ring->dev, page, 0,
-				 PAGE_SIZE,
+				 i40e_rx_pg_size(rx_ring),
 				 DMA_FROM_DEVICE,
 				 I40E_RX_DMA_ATTR);
 
@@ -1283,7 +1284,7 @@ static bool i40e_alloc_mapped_page(struct i40e_ring *rx_ring,
 	 * there isn't much point in holding memory we can't use
 	 */
 	if (dma_mapping_error(rx_ring->dev, dma)) {
-		__free_pages(page, 0);
+		__free_pages(page, i40e_rx_pg_order(rx_ring));
 		rx_ring->rx_stats.alloc_page_failed++;
 		return false;
 	}
@@ -1343,7 +1344,7 @@ bool i40e_alloc_rx_buffers(struct i40e_ring *rx_ring, u16 cleaned_count)
 		/* sync the buffer for use by the device */
 		dma_sync_single_range_for_device(rx_ring->dev, bi->dma,
 						 bi->page_offset,
-						 I40E_RXBUFFER_2048,
+						 rx_ring->rx_buf_len,
 						 DMA_FROM_DEVICE);
 
 		/* Refresh the desc even if buffer_addrs didn't change
@@ -1645,9 +1646,6 @@ static inline bool i40e_page_is_reusable(struct page *page)
  **/
 static bool i40e_can_reuse_rx_page(struct i40e_rx_buffer *rx_buffer)
 {
-#if (PAGE_SIZE >= 8192)
-	unsigned int last_offset = PAGE_SIZE - I40E_RXBUFFER_2048;
-#endif
 	unsigned int pagecnt_bias = rx_buffer->pagecnt_bias;
 	struct page *page = rx_buffer->page;
 
@@ -1660,7 +1658,9 @@ static bool i40e_can_reuse_rx_page(struct i40e_rx_buffer *rx_buffer)
 	if (unlikely((page_count(page) - pagecnt_bias) > 1))
 		return false;
 #else
-	if (rx_buffer->page_offset > last_offset)
+#define I40E_LAST_OFFSET \
+	(SKB_WITH_OVERHEAD(PAGE_SIZE) - I40E_RXBUFFER_2048)
+	if (rx_buffer->page_offset > I40E_LAST_OFFSET)
 		return false;
 #endif
 
@@ -1694,7 +1694,7 @@ static void i40e_add_rx_frag(struct i40e_ring *rx_ring,
 			     unsigned int size)
 {
 #if (PAGE_SIZE < 8192)
-	unsigned int truesize = I40E_RXBUFFER_2048;
+	unsigned int truesize = i40e_rx_pg_size(rx_ring) / 2;
 #else
 	unsigned int truesize = SKB_DATA_ALIGN(size);
 #endif
@@ -1755,7 +1755,7 @@ static struct sk_buff *i40e_construct_skb(struct i40e_ring *rx_ring,
 {
 	void *va = page_address(rx_buffer->page) + rx_buffer->page_offset;
 #if (PAGE_SIZE < 8192)
-	unsigned int truesize = I40E_RXBUFFER_2048;
+	unsigned int truesize = i40e_rx_pg_size(rx_ring) / 2;
 #else
 	unsigned int truesize = SKB_DATA_ALIGN(size);
 #endif
@@ -1821,7 +1821,8 @@ static void i40e_put_rx_buffer(struct i40e_ring *rx_ring,
 		rx_ring->rx_stats.page_reuse_count++;
 	} else {
 		/* we are not reusing the buffer so unmap it */
-		dma_unmap_page_attrs(rx_ring->dev, rx_buffer->dma, PAGE_SIZE,
+		dma_unmap_page_attrs(rx_ring->dev, rx_buffer->dma,
+				     i40e_rx_pg_size(rx_ring),
 				     DMA_FROM_DEVICE, I40E_RX_DMA_ATTR);
 		__page_frag_cache_drain(rx_buffer->page,
 					rx_buffer->pagecnt_bias);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index bc66ec4954d9..2f618539a436 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -119,6 +119,7 @@ enum i40e_dyn_idx_t {
 #define I40E_RXBUFFER_256   256
 #define I40E_RXBUFFER_1536  1536  /* 128B aligned standard Ethernet frame */
 #define I40E_RXBUFFER_2048  2048
+#define I40E_RXBUFFER_3072  3072  /* Used for large frames w/ padding */
 #define I40E_MAX_RXBUFFER   9728  /* largest size for single descriptor */
 
 /* NOTE: netdev_alloc_skb reserves up to 64 bytes, NET_IP_ALIGN means we
@@ -389,6 +390,17 @@ struct i40e_ring_container {
 #define i40e_for_each_ring(pos, head) \
 	for (pos = (head).ring; pos != NULL; pos = pos->next)
 
+static inline unsigned int i40e_rx_pg_order(struct i40e_ring *ring)
+{
+#if (PAGE_SIZE < 8192)
+	if (ring->rx_buf_len > (PAGE_SIZE / 2))
+		return 1;
+#endif
+	return 0;
+}
+
+#define i40e_rx_pg_size(_ring) (PAGE_SIZE << i40e_rx_pg_order(_ring))
+
 bool i40e_alloc_rx_buffers(struct i40e_ring *rxr, u16 cleaned_count);
 netdev_tx_t i40e_lan_xmit_frame(struct sk_buff *skb, struct net_device *netdev);
 void i40e_clean_tx_ring(struct i40e_ring *tx_ring);
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 95e383af41c4..6b60c19a794b 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -509,14 +509,15 @@ void i40evf_clean_rx_ring(struct i40e_ring *rx_ring)
 		dma_sync_single_range_for_cpu(rx_ring->dev,
 					      rx_bi->dma,
 					      rx_bi->page_offset,
-					      I40E_RXBUFFER_2048,
+					      rx_ring->rx_buf_len,
 					      DMA_FROM_DEVICE);
 
 		/* free resources associated with mapping */
 		dma_unmap_page_attrs(rx_ring->dev, rx_bi->dma,
-				     PAGE_SIZE,
+				     i40e_rx_pg_size(rx_ring),
 				     DMA_FROM_DEVICE,
 				     I40E_RX_DMA_ATTR);
+
 		__page_frag_cache_drain(rx_bi->page, rx_bi->pagecnt_bias);
 
 		rx_bi->page = NULL;
@@ -638,7 +639,7 @@ static bool i40e_alloc_mapped_page(struct i40e_ring *rx_ring,
 	}
 
 	/* alloc new page for storage */
-	page = dev_alloc_page();
+	page = dev_alloc_pages(i40e_rx_pg_order(rx_ring));
 	if (unlikely(!page)) {
 		rx_ring->rx_stats.alloc_page_failed++;
 		return false;
@@ -646,7 +647,7 @@ static bool i40e_alloc_mapped_page(struct i40e_ring *rx_ring,
 
 	/* map page for use */
 	dma = dma_map_page_attrs(rx_ring->dev, page, 0,
-				 PAGE_SIZE,
+				 i40e_rx_pg_size(rx_ring),
 				 DMA_FROM_DEVICE,
 				 I40E_RX_DMA_ATTR);
 
@@ -654,7 +655,7 @@ static bool i40e_alloc_mapped_page(struct i40e_ring *rx_ring,
 	 * there isn't much point in holding memory we can't use
 	 */
 	if (dma_mapping_error(rx_ring->dev, dma)) {
-		__free_pages(page, 0);
+		__free_pages(page, i40e_rx_pg_order(rx_ring));
 		rx_ring->rx_stats.alloc_page_failed++;
 		return false;
 	}
@@ -714,7 +715,7 @@ bool i40evf_alloc_rx_buffers(struct i40e_ring *rx_ring, u16 cleaned_count)
 		/* sync the buffer for use by the device */
 		dma_sync_single_range_for_device(rx_ring->dev, bi->dma,
 						 bi->page_offset,
-						 I40E_RXBUFFER_2048,
+						 rx_ring->rx_buf_len,
 						 DMA_FROM_DEVICE);
 
 		/* Refresh the desc even if buffer_addrs didn't change
@@ -1006,9 +1007,6 @@ static inline bool i40e_page_is_reusable(struct page *page)
  **/
 static bool i40e_can_reuse_rx_page(struct i40e_rx_buffer *rx_buffer)
 {
-#if (PAGE_SIZE >= 8192)
-	unsigned int last_offset = PAGE_SIZE - I40E_RXBUFFER_2048;
-#endif
 	unsigned int pagecnt_bias = rx_buffer->pagecnt_bias;
 	struct page *page = rx_buffer->page;
 
@@ -1021,7 +1019,9 @@ static bool i40e_can_reuse_rx_page(struct i40e_rx_buffer *rx_buffer)
 	if (unlikely((page_count(page) - pagecnt_bias) > 1))
 		return false;
 #else
-	if (rx_buffer->page_offset > last_offset)
+#define I40E_LAST_OFFSET \
+	(SKB_WITH_OVERHEAD(PAGE_SIZE) - I40E_RXBUFFER_2048)
+	if (rx_buffer->page_offset > I40E_LAST_OFFSET)
 		return false;
 #endif
 
@@ -1055,7 +1055,7 @@ static void i40e_add_rx_frag(struct i40e_ring *rx_ring,
 			     unsigned int size)
 {
 #if (PAGE_SIZE < 8192)
-	unsigned int truesize = I40E_RXBUFFER_2048;
+	unsigned int truesize = i40e_rx_pg_size(rx_ring) / 2;
 #else
 	unsigned int truesize = SKB_DATA_ALIGN(size);
 #endif
@@ -1116,7 +1116,7 @@ static struct sk_buff *i40e_construct_skb(struct i40e_ring *rx_ring,
 {
 	void *va = page_address(rx_buffer->page) + rx_buffer->page_offset;
 #if (PAGE_SIZE < 8192)
-	unsigned int truesize = I40E_RXBUFFER_2048;
+	unsigned int truesize = i40e_rx_pg_size(rx_ring) / 2;
 #else
 	unsigned int truesize = SKB_DATA_ALIGN(size);
 #endif
@@ -1182,7 +1182,8 @@ static void i40e_put_rx_buffer(struct i40e_ring *rx_ring,
 		rx_ring->rx_stats.page_reuse_count++;
 	} else {
 		/* we are not reusing the buffer so unmap it */
-		dma_unmap_page_attrs(rx_ring->dev, rx_buffer->dma, PAGE_SIZE,
+		dma_unmap_page_attrs(rx_ring->dev, rx_buffer->dma,
+				     i40e_rx_pg_size(rx_ring),
 				     DMA_FROM_DEVICE, I40E_RX_DMA_ATTR);
 		__page_frag_cache_drain(rx_buffer->page,
 					rx_buffer->pagecnt_bias);
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
index 3bb4d732e467..dc82f65267ec 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
@@ -106,6 +106,7 @@ enum i40e_dyn_idx_t {
 #define I40E_RXBUFFER_256   256
 #define I40E_RXBUFFER_1536  1536  /* 128B aligned standard Ethernet frame */
 #define I40E_RXBUFFER_2048  2048
+#define I40E_RXBUFFER_3072  3072  /* Used for large frames w/ padding */
 #define I40E_MAX_RXBUFFER   9728  /* largest size for single descriptor */
 
 /* NOTE: netdev_alloc_skb reserves up to 64 bytes, NET_IP_ALIGN means we
@@ -376,6 +377,17 @@ struct i40e_ring_container {
 #define i40e_for_each_ring(pos, head) \
 	for (pos = (head).ring; pos != NULL; pos = pos->next)
 
+static inline unsigned int i40e_rx_pg_order(struct i40e_ring *ring)
+{
+#if (PAGE_SIZE < 8192)
+	if (ring->rx_buf_len > (PAGE_SIZE / 2))
+		return 1;
+#endif
+	return 0;
+}
+
+#define i40e_rx_pg_size(_ring) (PAGE_SIZE << i40e_rx_pg_order(_ring))
+
 bool i40evf_alloc_rx_buffers(struct i40e_ring *rxr, u16 cleaned_count);
 netdev_tx_t i40evf_xmit_frame(struct sk_buff *skb, struct net_device *netdev);
 void i40evf_clean_tx_ring(struct i40e_ring *tx_ring);
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index c690aba8e8d1..7d00abae6104 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -694,6 +694,12 @@ static void i40evf_configure_rx(struct i40evf_adapter *adapter)
 	/* Legacy Rx will always default to a 2048 buffer size. */
 #if (PAGE_SIZE < 8192)
 	if (!(adapter->flags & I40EVF_FLAG_LEGACY_RX)) {
+		/* For jumbo frames on systems with 4K pages we have to use
+		 * an order 1 page, so we might as well increase the size
+		 * of our Rx buffer to make better use of the available space
+		 */
+		rx_buf_len = I40E_RXBUFFER_3072;
+
 		/* We use a 1536 buffer size for configurations with
 		 * standard Ethernet mtu.  On x86 this gives us enough room
 		 * for shared info and 192 bytes of padding.
-- 
2.12.2
