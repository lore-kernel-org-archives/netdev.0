From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/13] i40e/i40evf: Break i40e_fetch_rx_buffer up to allow for reuse of frag code
Date: Wed, 29 Mar 2017 03:12:12 -0700
Message-ID: <20170329101215.24513-11-jeffrey.t.kirsher@intel.com>
References: <20170329101215.24513-1-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:54616 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755087AbdC2KM0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 29 Mar 2017 06:12:26 -0400
In-Reply-To: <20170329101215.24513-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch is meant to clean up the code in preparation for us adding
support for build_skb.  Specifically we deconstruct i40e_fetch_buffer into
several functions so that those functions can later be reused when we add a
path for build_skb.

Specifically with this change we split out the code for adding a page to an
exiting skb.

Change-ID: Iab1efbab6b8b97cb60ab9fdd0be1d37a056a154d
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 138 ++++++++++++--------------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 138 ++++++++++++--------------
 2 files changed, 130 insertions(+), 146 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index bba41ce08124..ebffca0cefac 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1687,61 +1687,23 @@ static bool i40e_can_reuse_rx_page(struct i40e_rx_buffer *rx_buffer)
  * @size: packet length from rx_desc
  *
  * This function will add the data contained in rx_buffer->page to the skb.
- * This is done either through a direct copy if the data in the buffer is
- * less than the skb header size, otherwise it will just attach the page as
- * a frag to the skb.
+ * It will just attach the page as a frag to the skb.
  *
- * The function will then update the page offset if necessary and return
- * true if the buffer can be reused by the adapter.
+ * The function will then update the page offset.
  **/
 static void i40e_add_rx_frag(struct i40e_ring *rx_ring,
 			     struct i40e_rx_buffer *rx_buffer,
 			     struct sk_buff *skb,
 			     unsigned int size)
 {
-	struct page *page = rx_buffer->page;
-	unsigned char *va = page_address(page) + rx_buffer->page_offset;
 #if (PAGE_SIZE < 8192)
 	unsigned int truesize = I40E_RXBUFFER_2048;
 #else
-	unsigned int truesize = ALIGN(size, L1_CACHE_BYTES);
+	unsigned int truesize = SKB_DATA_ALIGN(size);
 #endif
-	unsigned int pull_len;
-
-	if (unlikely(skb_is_nonlinear(skb)))
-		goto add_tail_frag;
-
-	/* will the data fit in the skb we allocated? if so, just
-	 * copy it as it is pretty small anyway
-	 */
-	if (size <= I40E_RX_HDR_SIZE) {
-		memcpy(__skb_put(skb, size), va, ALIGN(size, sizeof(long)));
-
-		/* page is to be freed, increase pagecnt_bias instead of
-		 * decreasing page count.
-		 */
-		rx_buffer->pagecnt_bias++;
-		return;
-	}
-
-	/* we need the header to contain the greater of either
-	 * ETH_HLEN or 60 bytes if the skb->len is less than
-	 * 60 for skb_pad.
-	 */
-	pull_len = eth_get_headlen(va, I40E_RX_HDR_SIZE);
-
-	/* align pull length to size of long to optimize
-	 * memcpy performance
-	 */
-	memcpy(__skb_put(skb, pull_len), va, ALIGN(pull_len, sizeof(long)));
-
-	/* update all of the pointers */
-	va += pull_len;
-	size -= pull_len;
 
-add_tail_frag:
-	skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags, page,
-			(unsigned long)va & ~PAGE_MASK, size, truesize);
+	skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags, rx_buffer->page,
+			rx_buffer->page_offset, size, truesize);
 
 	/* page is being used so we must update the page offset */
 #if (PAGE_SIZE < 8192)
@@ -1781,45 +1743,66 @@ static struct i40e_rx_buffer *i40e_get_rx_buffer(struct i40e_ring *rx_ring,
 }
 
 /**
- * i40e_fetch_rx_buffer - Allocate skb and populate it
+ * i40e_construct_skb - Allocate skb and populate it
  * @rx_ring: rx descriptor ring to transact packets on
  * @rx_buffer: rx buffer to pull data from
  * @size: size of buffer to add to skb
  *
- * This function allocates an skb on the fly, and populates it with the page
- * data from the current receive descriptor, taking care to set up the skb
- * correctly, as well as handling calling the page recycle function if
- * necessary.
+ * This function allocates an skb.  It then populates it with the page
+ * data from the current receive descriptor, taking care to set up the
+ * skb correctly.
  */
-static inline
-struct sk_buff *i40e_fetch_rx_buffer(struct i40e_ring *rx_ring,
-				     struct i40e_rx_buffer *rx_buffer,
-				     struct sk_buff *skb,
-				     unsigned int size)
+static struct sk_buff *i40e_construct_skb(struct i40e_ring *rx_ring,
+					  struct i40e_rx_buffer *rx_buffer,
+					  unsigned int size)
 {
-	if (likely(!skb)) {
-		void *page_addr = page_address(rx_buffer->page) +
-				  rx_buffer->page_offset;
+	void *va = page_address(rx_buffer->page) + rx_buffer->page_offset;
+#if (PAGE_SIZE < 8192)
+	unsigned int truesize = I40E_RXBUFFER_2048;
+#else
+	unsigned int truesize = SKB_DATA_ALIGN(size);
+#endif
+	unsigned int headlen;
+	struct sk_buff *skb;
 
-		/* prefetch first cache line of first page */
-		prefetch(page_addr);
+	/* prefetch first cache line of first page */
+	prefetch(va);
 #if L1_CACHE_BYTES < 128
-		prefetch(page_addr + L1_CACHE_BYTES);
+	prefetch(va + L1_CACHE_BYTES);
 #endif
 
-		/* allocate a skb to store the frags */
-		skb = __napi_alloc_skb(&rx_ring->q_vector->napi,
-				       I40E_RX_HDR_SIZE,
-				       GFP_ATOMIC | __GFP_NOWARN);
-		if (unlikely(!skb)) {
-			rx_ring->rx_stats.alloc_buff_failed++;
-			rx_buffer->pagecnt_bias++;
-			return NULL;
-		}
-	}
+	/* allocate a skb to store the frags */
+	skb = __napi_alloc_skb(&rx_ring->q_vector->napi,
+			       I40E_RX_HDR_SIZE,
+			       GFP_ATOMIC | __GFP_NOWARN);
+	if (unlikely(!skb))
+		return NULL;
+
+	/* Determine available headroom for copy */
+	headlen = size;
+	if (headlen > I40E_RX_HDR_SIZE)
+		headlen = eth_get_headlen(va, I40E_RX_HDR_SIZE);
 
-	/* pull page into skb */
-	i40e_add_rx_frag(rx_ring, rx_buffer, skb, size);
+	/* align pull length to size of long to optimize memcpy performance */
+	memcpy(__skb_put(skb, headlen), va, ALIGN(headlen, sizeof(long)));
+
+	/* update all of the pointers */
+	size -= headlen;
+	if (size) {
+		skb_add_rx_frag(skb, 0, rx_buffer->page,
+				rx_buffer->page_offset + headlen,
+				size, truesize);
+
+		/* buffer is used by skb, update page_offset */
+#if (PAGE_SIZE < 8192)
+		rx_buffer->page_offset ^= truesize;
+#else
+		rx_buffer->page_offset += truesize;
+#endif
+	} else {
+		/* buffer is unused, reset bias back to rx_buffer */
+		rx_buffer->pagecnt_bias++;
+	}
 
 	return skb;
 }
@@ -1944,9 +1927,18 @@ static int i40e_clean_rx_irq(struct i40e_ring *rx_ring, int budget)
 
 		rx_buffer = i40e_get_rx_buffer(rx_ring, size);
 
-		skb = i40e_fetch_rx_buffer(rx_ring, rx_buffer, skb, size);
-		if (!skb)
+		/* retrieve a buffer from the ring */
+		if (skb)
+			i40e_add_rx_frag(rx_ring, rx_buffer, skb, size);
+		else
+			skb = i40e_construct_skb(rx_ring, rx_buffer, size);
+
+		/* exit if we failed to retrieve a buffer */
+		if (!skb) {
+			rx_ring->rx_stats.alloc_buff_failed++;
+			rx_buffer->pagecnt_bias++;
 			break;
+		}
 
 		i40e_put_rx_buffer(rx_ring, rx_buffer);
 		cleaned_count++;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 06b37790202a..95e383af41c4 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1045,61 +1045,23 @@ static bool i40e_can_reuse_rx_page(struct i40e_rx_buffer *rx_buffer)
  * @size: packet length from rx_desc
  *
  * This function will add the data contained in rx_buffer->page to the skb.
- * This is done either through a direct copy if the data in the buffer is
- * less than the skb header size, otherwise it will just attach the page as
- * a frag to the skb.
+ * It will just attach the page as a frag to the skb.
  *
- * The function will then update the page offset if necessary and return
- * true if the buffer can be reused by the adapter.
+ * The function will then update the page offset.
  **/
 static void i40e_add_rx_frag(struct i40e_ring *rx_ring,
 			     struct i40e_rx_buffer *rx_buffer,
 			     struct sk_buff *skb,
 			     unsigned int size)
 {
-	struct page *page = rx_buffer->page;
-	unsigned char *va = page_address(page) + rx_buffer->page_offset;
 #if (PAGE_SIZE < 8192)
 	unsigned int truesize = I40E_RXBUFFER_2048;
 #else
-	unsigned int truesize = ALIGN(size, L1_CACHE_BYTES);
+	unsigned int truesize = SKB_DATA_ALIGN(size);
 #endif
-	unsigned int pull_len;
-
-	if (unlikely(skb_is_nonlinear(skb)))
-		goto add_tail_frag;
-
-	/* will the data fit in the skb we allocated? if so, just
-	 * copy it as it is pretty small anyway
-	 */
-	if (size <= I40E_RX_HDR_SIZE) {
-		memcpy(__skb_put(skb, size), va, ALIGN(size, sizeof(long)));
-
-		/* page is to be freed, increase pagecnt_bias instead of
-		 * decreasing page count.
-		 */
-		rx_buffer->pagecnt_bias++;
-		return;
-	}
-
-	/* we need the header to contain the greater of either
-	 * ETH_HLEN or 60 bytes if the skb->len is less than
-	 * 60 for skb_pad.
-	 */
-	pull_len = eth_get_headlen(va, I40E_RX_HDR_SIZE);
-
-	/* align pull length to size of long to optimize
-	 * memcpy performance
-	 */
-	memcpy(__skb_put(skb, pull_len), va, ALIGN(pull_len, sizeof(long)));
-
-	/* update all of the pointers */
-	va += pull_len;
-	size -= pull_len;
 
-add_tail_frag:
-	skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags, page,
-			(unsigned long)va & ~PAGE_MASK, size, truesize);
+	skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags, rx_buffer->page,
+			rx_buffer->page_offset, size, truesize);
 
 	/* page is being used so we must update the page offset */
 #if (PAGE_SIZE < 8192)
@@ -1139,45 +1101,66 @@ static struct i40e_rx_buffer *i40e_get_rx_buffer(struct i40e_ring *rx_ring,
 }
 
 /**
- * i40evf_fetch_rx_buffer - Allocate skb and populate it
+ * i40e_construct_skb - Allocate skb and populate it
  * @rx_ring: rx descriptor ring to transact packets on
  * @rx_buffer: rx buffer to pull data from
  * @size: size of buffer to add to skb
  *
- * This function allocates an skb on the fly, and populates it with the page
- * data from the current receive descriptor, taking care to set up the skb
- * correctly, as well as handling calling the page recycle function if
- * necessary.
+ * This function allocates an skb.  It then populates it with the page
+ * data from the current receive descriptor, taking care to set up the
+ * skb correctly.
  */
-static inline
-struct sk_buff *i40evf_fetch_rx_buffer(struct i40e_ring *rx_ring,
-				       struct i40e_rx_buffer *rx_buffer,
-				       struct sk_buff *skb,
-				       unsigned int size)
+static struct sk_buff *i40e_construct_skb(struct i40e_ring *rx_ring,
+					  struct i40e_rx_buffer *rx_buffer,
+					  unsigned int size)
 {
-	if (likely(!skb)) {
-		void *page_addr = page_address(rx_buffer->page) +
-				  rx_buffer->page_offset;
+	void *va = page_address(rx_buffer->page) + rx_buffer->page_offset;
+#if (PAGE_SIZE < 8192)
+	unsigned int truesize = I40E_RXBUFFER_2048;
+#else
+	unsigned int truesize = SKB_DATA_ALIGN(size);
+#endif
+	unsigned int headlen;
+	struct sk_buff *skb;
 
-		/* prefetch first cache line of first page */
-		prefetch(page_addr);
+	/* prefetch first cache line of first page */
+	prefetch(va);
 #if L1_CACHE_BYTES < 128
-		prefetch(page_addr + L1_CACHE_BYTES);
+	prefetch(va + L1_CACHE_BYTES);
 #endif
 
-		/* allocate a skb to store the frags */
-		skb = __napi_alloc_skb(&rx_ring->q_vector->napi,
-				       I40E_RX_HDR_SIZE,
-				       GFP_ATOMIC | __GFP_NOWARN);
-		if (unlikely(!skb)) {
-			rx_ring->rx_stats.alloc_buff_failed++;
-			rx_buffer->pagecnt_bias++;
-			return NULL;
-		}
-	}
+	/* allocate a skb to store the frags */
+	skb = __napi_alloc_skb(&rx_ring->q_vector->napi,
+			       I40E_RX_HDR_SIZE,
+			       GFP_ATOMIC | __GFP_NOWARN);
+	if (unlikely(!skb))
+		return NULL;
+
+	/* Determine available headroom for copy */
+	headlen = size;
+	if (headlen > I40E_RX_HDR_SIZE)
+		headlen = eth_get_headlen(va, I40E_RX_HDR_SIZE);
 
-	/* pull page into skb */
-	i40e_add_rx_frag(rx_ring, rx_buffer, skb, size);
+	/* align pull length to size of long to optimize memcpy performance */
+	memcpy(__skb_put(skb, headlen), va, ALIGN(headlen, sizeof(long)));
+
+	/* update all of the pointers */
+	size -= headlen;
+	if (size) {
+		skb_add_rx_frag(skb, 0, rx_buffer->page,
+				rx_buffer->page_offset + headlen,
+				size, truesize);
+
+		/* buffer is used by skb, update page_offset */
+#if (PAGE_SIZE < 8192)
+		rx_buffer->page_offset ^= truesize;
+#else
+		rx_buffer->page_offset += truesize;
+#endif
+	} else {
+		/* buffer is unused, reset bias back to rx_buffer */
+		rx_buffer->pagecnt_bias++;
+	}
 
 	return skb;
 }
@@ -1297,9 +1280,18 @@ static int i40e_clean_rx_irq(struct i40e_ring *rx_ring, int budget)
 
 		rx_buffer = i40e_get_rx_buffer(rx_ring, size);
 
-		skb = i40evf_fetch_rx_buffer(rx_ring, rx_buffer, skb, size);
-		if (!skb)
+		/* retrieve a buffer from the ring */
+		if (skb)
+			i40e_add_rx_frag(rx_ring, rx_buffer, skb, size);
+		else
+			skb = i40e_construct_skb(rx_ring, rx_buffer, size);
+
+		/* exit if we failed to retrieve a buffer */
+		if (!skb) {
+			rx_ring->rx_stats.alloc_buff_failed++;
+			rx_buffer->pagecnt_bias++;
 			break;
+		}
 
 		i40e_put_rx_buffer(rx_ring, rx_buffer);
 		cleaned_count++;
-- 
2.12.0
