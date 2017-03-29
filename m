From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/13] i40e/i40evf: Pull code for grabbing and syncing rx_buffer from fetch_buffer
Date: Wed, 29 Mar 2017 03:12:10 -0700
Message-ID: <20170329101215.24513-9-jeffrey.t.kirsher@intel.com>
References: <20170329101215.24513-1-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:54616 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755302AbdC2KMZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 29 Mar 2017 06:12:25 -0400
In-Reply-To: <20170329101215.24513-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch pulls the code responsible for fetching the Rx buffer and
synchronizing DMA into a function, specifically called i40e_get_rx_buffer.

The general idea is to allow for better code reuse by pulling this out of
i40e_fetch_rx_buffer.  We dropped a couple of prefetches since the time
between the prefetch being called and the data being accessed was too small
to be useful.

Change-ID: I4885fce4b2637dbedc8e16431169d23d3d7e79b9
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 58 ++++++++++++++++-----------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 58 ++++++++++++++++-----------
 2 files changed, 68 insertions(+), 48 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 012e55354043..f2256d8c5e35 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1754,9 +1754,35 @@ static bool i40e_add_rx_frag(struct i40e_ring *rx_ring,
 }
 
 /**
+ * i40e_get_rx_buffer - Fetch Rx buffer and synchronize data for use
+ * @rx_ring: rx descriptor ring to transact packets on
+ * @size: size of buffer to add to skb
+ *
+ * This function will pull an Rx buffer from the ring and synchronize it
+ * for use by the CPU.
+ */
+static struct i40e_rx_buffer *i40e_get_rx_buffer(struct i40e_ring *rx_ring,
+						 const unsigned int size)
+{
+	struct i40e_rx_buffer *rx_buffer;
+
+	rx_buffer = &rx_ring->rx_bi[rx_ring->next_to_clean];
+	prefetchw(rx_buffer->page);
+
+	/* we are reusing so sync this buffer for CPU use */
+	dma_sync_single_range_for_cpu(rx_ring->dev,
+				      rx_buffer->dma,
+				      rx_buffer->page_offset,
+				      size,
+				      DMA_FROM_DEVICE);
+
+	return rx_buffer;
+}
+
+/**
  * i40e_fetch_rx_buffer - Allocate skb and populate it
  * @rx_ring: rx descriptor ring to transact packets on
- * @rx_desc: descriptor containing info written by hardware
+ * @rx_buffer: rx buffer to pull data from
  * @size: size of buffer to add to skb
  *
  * This function allocates an skb on the fly, and populates it with the page
@@ -1766,19 +1792,13 @@ static bool i40e_add_rx_frag(struct i40e_ring *rx_ring,
  */
 static inline
 struct sk_buff *i40e_fetch_rx_buffer(struct i40e_ring *rx_ring,
-				     union i40e_rx_desc *rx_desc,
+				     struct i40e_rx_buffer *rx_buffer,
 				     struct sk_buff *skb,
 				     unsigned int size)
 {
-	struct i40e_rx_buffer *rx_buffer;
-	struct page *page;
-
-	rx_buffer = &rx_ring->rx_bi[rx_ring->next_to_clean];
-	page = rx_buffer->page;
-	prefetchw(page);
-
 	if (likely(!skb)) {
-		void *page_addr = page_address(page) + rx_buffer->page_offset;
+		void *page_addr = page_address(rx_buffer->page) +
+				  rx_buffer->page_offset;
 
 		/* prefetch first cache line of first page */
 		prefetch(page_addr);
@@ -1794,21 +1814,8 @@ struct sk_buff *i40e_fetch_rx_buffer(struct i40e_ring *rx_ring,
 			rx_ring->rx_stats.alloc_buff_failed++;
 			return NULL;
 		}
-
-		/* we will be copying header into skb->data in
-		 * pskb_may_pull so it is in our interest to prefetch
-		 * it now to avoid a possible cache miss
-		 */
-		prefetchw(skb->data);
 	}
 
-	/* we are reusing so sync this buffer for CPU use */
-	dma_sync_single_range_for_cpu(rx_ring->dev,
-				      rx_buffer->dma,
-				      rx_buffer->page_offset,
-				      size,
-				      DMA_FROM_DEVICE);
-
 	/* pull page into skb */
 	if (i40e_add_rx_frag(rx_ring, rx_buffer, size, skb)) {
 		/* hand second half of page back to the ring */
@@ -1886,6 +1893,7 @@ static int i40e_clean_rx_irq(struct i40e_ring *rx_ring, int budget)
 	bool failure = false;
 
 	while (likely(total_rx_packets < budget)) {
+		struct i40e_rx_buffer *rx_buffer;
 		union i40e_rx_desc *rx_desc;
 		unsigned int size;
 		u16 vlan_tag;
@@ -1918,7 +1926,9 @@ static int i40e_clean_rx_irq(struct i40e_ring *rx_ring, int budget)
 		 */
 		dma_rmb();
 
-		skb = i40e_fetch_rx_buffer(rx_ring, rx_desc, skb, size);
+		rx_buffer = i40e_get_rx_buffer(rx_ring, size);
+
+		skb = i40e_fetch_rx_buffer(rx_ring, rx_buffer, skb, size);
 		if (!skb)
 			break;
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index e41eb46b02fe..2320ec4d95ee 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1113,9 +1113,35 @@ static bool i40e_add_rx_frag(struct i40e_ring *rx_ring,
 }
 
 /**
+ * i40e_get_rx_buffer - Fetch Rx buffer and synchronize data for use
+ * @rx_ring: rx descriptor ring to transact packets on
+ * @size: size of buffer to add to skb
+ *
+ * This function will pull an Rx buffer from the ring and synchronize it
+ * for use by the CPU.
+ */
+static struct i40e_rx_buffer *i40e_get_rx_buffer(struct i40e_ring *rx_ring,
+						 const unsigned int size)
+{
+	struct i40e_rx_buffer *rx_buffer;
+
+	rx_buffer = &rx_ring->rx_bi[rx_ring->next_to_clean];
+	prefetchw(rx_buffer->page);
+
+	/* we are reusing so sync this buffer for CPU use */
+	dma_sync_single_range_for_cpu(rx_ring->dev,
+				      rx_buffer->dma,
+				      rx_buffer->page_offset,
+				      size,
+				      DMA_FROM_DEVICE);
+
+	return rx_buffer;
+}
+
+/**
  * i40evf_fetch_rx_buffer - Allocate skb and populate it
  * @rx_ring: rx descriptor ring to transact packets on
- * @rx_desc: descriptor containing info written by hardware
+ * @rx_buffer: rx buffer to pull data from
  * @size: size of buffer to add to skb
  *
  * This function allocates an skb on the fly, and populates it with the page
@@ -1125,19 +1151,13 @@ static bool i40e_add_rx_frag(struct i40e_ring *rx_ring,
  */
 static inline
 struct sk_buff *i40evf_fetch_rx_buffer(struct i40e_ring *rx_ring,
-				       union i40e_rx_desc *rx_desc,
+				       struct i40e_rx_buffer *rx_buffer,
 				       struct sk_buff *skb,
 				       unsigned int size)
 {
-	struct i40e_rx_buffer *rx_buffer;
-	struct page *page;
-
-	rx_buffer = &rx_ring->rx_bi[rx_ring->next_to_clean];
-	page = rx_buffer->page;
-	prefetchw(page);
-
 	if (likely(!skb)) {
-		void *page_addr = page_address(page) + rx_buffer->page_offset;
+		void *page_addr = page_address(rx_buffer->page) +
+				  rx_buffer->page_offset;
 
 		/* prefetch first cache line of first page */
 		prefetch(page_addr);
@@ -1153,21 +1173,8 @@ struct sk_buff *i40evf_fetch_rx_buffer(struct i40e_ring *rx_ring,
 			rx_ring->rx_stats.alloc_buff_failed++;
 			return NULL;
 		}
-
-		/* we will be copying header into skb->data in
-		 * pskb_may_pull so it is in our interest to prefetch
-		 * it now to avoid a possible cache miss
-		 */
-		prefetchw(skb->data);
 	}
 
-	/* we are reusing so sync this buffer for CPU use */
-	dma_sync_single_range_for_cpu(rx_ring->dev,
-				      rx_buffer->dma,
-				      rx_buffer->page_offset,
-				      size,
-				      DMA_FROM_DEVICE);
-
 	/* pull page into skb */
 	if (i40e_add_rx_frag(rx_ring, rx_buffer, size, skb)) {
 		/* hand second half of page back to the ring */
@@ -1240,6 +1247,7 @@ static int i40e_clean_rx_irq(struct i40e_ring *rx_ring, int budget)
 	bool failure = false;
 
 	while (likely(total_rx_packets < budget)) {
+		struct i40e_rx_buffer *rx_buffer;
 		union i40e_rx_desc *rx_desc;
 		unsigned int size;
 		u16 vlan_tag;
@@ -1272,7 +1280,9 @@ static int i40e_clean_rx_irq(struct i40e_ring *rx_ring, int budget)
 		 */
 		dma_rmb();
 
-		skb = i40evf_fetch_rx_buffer(rx_ring, rx_desc, skb, size);
+		rx_buffer = i40e_get_rx_buffer(rx_ring, size);
+
+		skb = i40evf_fetch_rx_buffer(rx_ring, rx_buffer, skb, size);
 		if (!skb)
 			break;
 
-- 
2.12.0
