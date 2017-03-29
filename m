From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/13] i40e/i40evf: Pull out code for cleaning up Rx buffers
Date: Wed, 29 Mar 2017 03:12:11 -0700
Message-ID: <20170329101215.24513-10-jeffrey.t.kirsher@intel.com>
References: <20170329101215.24513-1-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:21132 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755599AbdC2KMj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 29 Mar 2017 06:12:39 -0400
In-Reply-To: <20170329101215.24513-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch pulls out the code responsible for handling buffer recycling and
page counting and distributes it through several functions.  This allows us
to commonize the bits that handle either freeing or recycling the buffers.

As far as the page count tracking one change to the logic is that
pagecnt_bias is decremented as soon as we call i40e_get_rx_buffer.  It is
then the responsibility of the function that pulls the data to either
increment the pagecnt_bias if the buffer can be recycled as-is, or to
update page_offset so that we are pointing at the correct location for
placement of the next buffer.

Change-ID: Ibac576360cb7f0b1627f2a993d13c1a8a2bf60af
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 73 +++++++++++++++++----------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 72 ++++++++++++++++----------
 2 files changed, 89 insertions(+), 56 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index f2256d8c5e35..bba41ce08124 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1294,6 +1294,8 @@ static bool i40e_alloc_mapped_page(struct i40e_ring *rx_ring,
 	bi->dma = dma;
 	bi->page = page;
 	bi->page_offset = 0;
+
+	/* initialize pagecnt_bias to 1 representing we fully own page */
 	bi->pagecnt_bias = 1;
 
 	return true;
@@ -1622,8 +1624,6 @@ static inline bool i40e_page_is_reusable(struct page *page)
  * the adapter for another receive
  *
  * @rx_buffer: buffer containing the page
- * @page: page address from rx_buffer
- * @truesize: actual size of the buffer in this page
  *
  * If page is reusable, rx_buffer->page_offset is adjusted to point to
  * an unused region in the page.
@@ -1646,14 +1646,13 @@ static inline bool i40e_page_is_reusable(struct page *page)
  *
  * In either case, if the page is reusable its refcount is increased.
  **/
-static bool i40e_can_reuse_rx_page(struct i40e_rx_buffer *rx_buffer,
-				   struct page *page,
-				   const unsigned int truesize)
+static bool i40e_can_reuse_rx_page(struct i40e_rx_buffer *rx_buffer)
 {
 #if (PAGE_SIZE >= 8192)
 	unsigned int last_offset = PAGE_SIZE - I40E_RXBUFFER_2048;
 #endif
-	unsigned int pagecnt_bias = rx_buffer->pagecnt_bias--;
+	unsigned int pagecnt_bias = rx_buffer->pagecnt_bias;
+	struct page *page = rx_buffer->page;
 
 	/* Is any reuse possible? */
 	if (unlikely(!i40e_page_is_reusable(page)))
@@ -1661,15 +1660,9 @@ static bool i40e_can_reuse_rx_page(struct i40e_rx_buffer *rx_buffer,
 
 #if (PAGE_SIZE < 8192)
 	/* if we are only owner of page we can reuse it */
-	if (unlikely(page_count(page) != pagecnt_bias))
+	if (unlikely((page_count(page) - pagecnt_bias) > 1))
 		return false;
-
-	/* flip page offset to other buffer */
-	rx_buffer->page_offset ^= truesize;
 #else
-	/* move offset up to the next cache line */
-	rx_buffer->page_offset += truesize;
-
 	if (rx_buffer->page_offset > last_offset)
 		return false;
 #endif
@@ -1678,10 +1671,11 @@ static bool i40e_can_reuse_rx_page(struct i40e_rx_buffer *rx_buffer,
 	 * the pagecnt_bias and page count so that we fully restock the
 	 * number of references the driver holds.
 	 */
-	if (unlikely(pagecnt_bias == 1)) {
+	if (unlikely(!pagecnt_bias)) {
 		page_ref_add(page, USHRT_MAX);
 		rx_buffer->pagecnt_bias = USHRT_MAX;
 	}
+
 	return true;
 }
 
@@ -1689,8 +1683,8 @@ static bool i40e_can_reuse_rx_page(struct i40e_rx_buffer *rx_buffer,
  * i40e_add_rx_frag - Add contents of Rx buffer to sk_buff
  * @rx_ring: rx descriptor ring to transact packets on
  * @rx_buffer: buffer containing page to add
- * @size: packet length from rx_desc
  * @skb: sk_buff to place the data into
+ * @size: packet length from rx_desc
  *
  * This function will add the data contained in rx_buffer->page to the skb.
  * This is done either through a direct copy if the data in the buffer is
@@ -1700,10 +1694,10 @@ static bool i40e_can_reuse_rx_page(struct i40e_rx_buffer *rx_buffer,
  * The function will then update the page offset if necessary and return
  * true if the buffer can be reused by the adapter.
  **/
-static bool i40e_add_rx_frag(struct i40e_ring *rx_ring,
+static void i40e_add_rx_frag(struct i40e_ring *rx_ring,
 			     struct i40e_rx_buffer *rx_buffer,
-			     unsigned int size,
-			     struct sk_buff *skb)
+			     struct sk_buff *skb,
+			     unsigned int size)
 {
 	struct page *page = rx_buffer->page;
 	unsigned char *va = page_address(page) + rx_buffer->page_offset;
@@ -1723,12 +1717,11 @@ static bool i40e_add_rx_frag(struct i40e_ring *rx_ring,
 	if (size <= I40E_RX_HDR_SIZE) {
 		memcpy(__skb_put(skb, size), va, ALIGN(size, sizeof(long)));
 
-		/* page is reusable, we can reuse buffer as-is */
-		if (likely(i40e_page_is_reusable(page)))
-			return true;
-
-		/* this page cannot be reused so discard it */
-		return false;
+		/* page is to be freed, increase pagecnt_bias instead of
+		 * decreasing page count.
+		 */
+		rx_buffer->pagecnt_bias++;
+		return;
 	}
 
 	/* we need the header to contain the greater of either
@@ -1750,7 +1743,12 @@ static bool i40e_add_rx_frag(struct i40e_ring *rx_ring,
 	skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags, page,
 			(unsigned long)va & ~PAGE_MASK, size, truesize);
 
-	return i40e_can_reuse_rx_page(rx_buffer, page, truesize);
+	/* page is being used so we must update the page offset */
+#if (PAGE_SIZE < 8192)
+	rx_buffer->page_offset ^= truesize;
+#else
+	rx_buffer->page_offset += truesize;
+#endif
 }
 
 /**
@@ -1776,6 +1774,9 @@ static struct i40e_rx_buffer *i40e_get_rx_buffer(struct i40e_ring *rx_ring,
 				      size,
 				      DMA_FROM_DEVICE);
 
+	/* We have pulled a buffer for use, so decrement pagecnt_bias */
+	rx_buffer->pagecnt_bias--;
+
 	return rx_buffer;
 }
 
@@ -1812,12 +1813,29 @@ struct sk_buff *i40e_fetch_rx_buffer(struct i40e_ring *rx_ring,
 				       GFP_ATOMIC | __GFP_NOWARN);
 		if (unlikely(!skb)) {
 			rx_ring->rx_stats.alloc_buff_failed++;
+			rx_buffer->pagecnt_bias++;
 			return NULL;
 		}
 	}
 
 	/* pull page into skb */
-	if (i40e_add_rx_frag(rx_ring, rx_buffer, size, skb)) {
+	i40e_add_rx_frag(rx_ring, rx_buffer, skb, size);
+
+	return skb;
+}
+
+/**
+ * i40e_put_rx_buffer - Clean up used buffer and either recycle or free
+ * @rx_ring: rx descriptor ring to transact packets on
+ * @rx_buffer: rx buffer to pull data from
+ *
+ * This function will clean up the contents of the rx_buffer.  It will
+ * either recycle the bufer or unmap it and free the associated resources.
+ */
+static void i40e_put_rx_buffer(struct i40e_ring *rx_ring,
+			       struct i40e_rx_buffer *rx_buffer)
+{
+	if (i40e_can_reuse_rx_page(rx_buffer)) {
 		/* hand second half of page back to the ring */
 		i40e_reuse_rx_page(rx_ring, rx_buffer);
 		rx_ring->rx_stats.page_reuse_count++;
@@ -1831,8 +1849,6 @@ struct sk_buff *i40e_fetch_rx_buffer(struct i40e_ring *rx_ring,
 
 	/* clear contents of buffer_info */
 	rx_buffer->page = NULL;
-
-	return skb;
 }
 
 /**
@@ -1932,6 +1948,7 @@ static int i40e_clean_rx_irq(struct i40e_ring *rx_ring, int budget)
 		if (!skb)
 			break;
 
+		i40e_put_rx_buffer(rx_ring, rx_buffer);
 		cleaned_count++;
 
 		if (i40e_is_non_eop(rx_ring, rx_desc, skb))
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 2320ec4d95ee..06b37790202a 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -662,6 +662,8 @@ static bool i40e_alloc_mapped_page(struct i40e_ring *rx_ring,
 	bi->dma = dma;
 	bi->page = page;
 	bi->page_offset = 0;
+
+	/* initialize pagecnt_bias to 1 representing we fully own page */
 	bi->pagecnt_bias = 1;
 
 	return true;
@@ -980,8 +982,6 @@ static inline bool i40e_page_is_reusable(struct page *page)
  * the adapter for another receive
  *
  * @rx_buffer: buffer containing the page
- * @page: page address from rx_buffer
- * @truesize: actual size of the buffer in this page
  *
  * If page is reusable, rx_buffer->page_offset is adjusted to point to
  * an unused region in the page.
@@ -1004,14 +1004,13 @@ static inline bool i40e_page_is_reusable(struct page *page)
  *
  * In either case, if the page is reusable its refcount is increased.
  **/
-static bool i40e_can_reuse_rx_page(struct i40e_rx_buffer *rx_buffer,
-				   struct page *page,
-				   const unsigned int truesize)
+static bool i40e_can_reuse_rx_page(struct i40e_rx_buffer *rx_buffer)
 {
 #if (PAGE_SIZE >= 8192)
 	unsigned int last_offset = PAGE_SIZE - I40E_RXBUFFER_2048;
 #endif
-	unsigned int pagecnt_bias = rx_buffer->pagecnt_bias--;
+	unsigned int pagecnt_bias = rx_buffer->pagecnt_bias;
+	struct page *page = rx_buffer->page;
 
 	/* Is any reuse possible? */
 	if (unlikely(!i40e_page_is_reusable(page)))
@@ -1019,15 +1018,9 @@ static bool i40e_can_reuse_rx_page(struct i40e_rx_buffer *rx_buffer,
 
 #if (PAGE_SIZE < 8192)
 	/* if we are only owner of page we can reuse it */
-	if (unlikely(page_count(page) != pagecnt_bias))
+	if (unlikely((page_count(page) - pagecnt_bias) > 1))
 		return false;
-
-	/* flip page offset to other buffer */
-	rx_buffer->page_offset ^= truesize;
 #else
-	/* move offset up to the next cache line */
-	rx_buffer->page_offset += truesize;
-
 	if (rx_buffer->page_offset > last_offset)
 		return false;
 #endif
@@ -1036,7 +1029,7 @@ static bool i40e_can_reuse_rx_page(struct i40e_rx_buffer *rx_buffer,
 	 * the pagecnt_bias and page count so that we fully restock the
 	 * number of references the driver holds.
 	 */
-	if (unlikely(pagecnt_bias == 1)) {
+	if (unlikely(!pagecnt_bias)) {
 		page_ref_add(page, USHRT_MAX);
 		rx_buffer->pagecnt_bias = USHRT_MAX;
 	}
@@ -1048,8 +1041,8 @@ static bool i40e_can_reuse_rx_page(struct i40e_rx_buffer *rx_buffer,
  * i40e_add_rx_frag - Add contents of Rx buffer to sk_buff
  * @rx_ring: rx descriptor ring to transact packets on
  * @rx_buffer: buffer containing page to add
- * @size: packet length from rx_desc
  * @skb: sk_buff to place the data into
+ * @size: packet length from rx_desc
  *
  * This function will add the data contained in rx_buffer->page to the skb.
  * This is done either through a direct copy if the data in the buffer is
@@ -1059,10 +1052,10 @@ static bool i40e_can_reuse_rx_page(struct i40e_rx_buffer *rx_buffer,
  * The function will then update the page offset if necessary and return
  * true if the buffer can be reused by the adapter.
  **/
-static bool i40e_add_rx_frag(struct i40e_ring *rx_ring,
+static void i40e_add_rx_frag(struct i40e_ring *rx_ring,
 			     struct i40e_rx_buffer *rx_buffer,
-			     unsigned int size,
-			     struct sk_buff *skb)
+			     struct sk_buff *skb,
+			     unsigned int size)
 {
 	struct page *page = rx_buffer->page;
 	unsigned char *va = page_address(page) + rx_buffer->page_offset;
@@ -1082,12 +1075,11 @@ static bool i40e_add_rx_frag(struct i40e_ring *rx_ring,
 	if (size <= I40E_RX_HDR_SIZE) {
 		memcpy(__skb_put(skb, size), va, ALIGN(size, sizeof(long)));
 
-		/* page is reusable, we can reuse buffer as-is */
-		if (likely(i40e_page_is_reusable(page)))
-			return true;
-
-		/* this page cannot be reused so discard it */
-		return false;
+		/* page is to be freed, increase pagecnt_bias instead of
+		 * decreasing page count.
+		 */
+		rx_buffer->pagecnt_bias++;
+		return;
 	}
 
 	/* we need the header to contain the greater of either
@@ -1109,7 +1101,12 @@ static bool i40e_add_rx_frag(struct i40e_ring *rx_ring,
 	skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags, page,
 			(unsigned long)va & ~PAGE_MASK, size, truesize);
 
-	return i40e_can_reuse_rx_page(rx_buffer, page, truesize);
+	/* page is being used so we must update the page offset */
+#if (PAGE_SIZE < 8192)
+	rx_buffer->page_offset ^= truesize;
+#else
+	rx_buffer->page_offset += truesize;
+#endif
 }
 
 /**
@@ -1135,6 +1132,9 @@ static struct i40e_rx_buffer *i40e_get_rx_buffer(struct i40e_ring *rx_ring,
 				      size,
 				      DMA_FROM_DEVICE);
 
+	/* We have pulled a buffer for use, so decrement pagecnt_bias */
+	rx_buffer->pagecnt_bias--;
+
 	return rx_buffer;
 }
 
@@ -1171,12 +1171,29 @@ struct sk_buff *i40evf_fetch_rx_buffer(struct i40e_ring *rx_ring,
 				       GFP_ATOMIC | __GFP_NOWARN);
 		if (unlikely(!skb)) {
 			rx_ring->rx_stats.alloc_buff_failed++;
+			rx_buffer->pagecnt_bias++;
 			return NULL;
 		}
 	}
 
 	/* pull page into skb */
-	if (i40e_add_rx_frag(rx_ring, rx_buffer, size, skb)) {
+	i40e_add_rx_frag(rx_ring, rx_buffer, skb, size);
+
+	return skb;
+}
+
+/**
+ * i40e_put_rx_buffer - Clean up used buffer and either recycle or free
+ * @rx_ring: rx descriptor ring to transact packets on
+ * @rx_buffer: rx buffer to pull data from
+ *
+ * This function will clean up the contents of the rx_buffer.  It will
+ * either recycle the bufer or unmap it and free the associated resources.
+ */
+static void i40e_put_rx_buffer(struct i40e_ring *rx_ring,
+			       struct i40e_rx_buffer *rx_buffer)
+{
+	if (i40e_can_reuse_rx_page(rx_buffer)) {
 		/* hand second half of page back to the ring */
 		i40e_reuse_rx_page(rx_ring, rx_buffer);
 		rx_ring->rx_stats.page_reuse_count++;
@@ -1190,8 +1207,6 @@ struct sk_buff *i40evf_fetch_rx_buffer(struct i40e_ring *rx_ring,
 
 	/* clear contents of buffer_info */
 	rx_buffer->page = NULL;
-
-	return skb;
 }
 
 /**
@@ -1286,6 +1301,7 @@ static int i40e_clean_rx_irq(struct i40e_ring *rx_ring, int budget)
 		if (!skb)
 			break;
 
+		i40e_put_rx_buffer(rx_ring, rx_buffer);
 		cleaned_count++;
 
 		if (i40e_is_non_eop(rx_ring, rx_desc, skb))
-- 
2.12.0
