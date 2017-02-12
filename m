From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/14] i40e/i40evf: Limit DMA sync of RX buffers to actual packet size
Date: Sat, 11 Feb 2017 21:30:17 -0800
Message-ID: <20170212053028.98581-4-jeffrey.t.kirsher@intel.com>
References: <20170212053028.98581-1-jeffrey.t.kirsher@intel.com>
Cc: Scott Peterson <scott.d.peterson@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:30258 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750905AbdBLFac (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 12 Feb 2017 00:30:32 -0500
In-Reply-To: <20170212053028.98581-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Peterson <scott.d.peterson@intel.com>

On packet RX, we perform a DMA sync for CPU before passing the
packet up.  Here we limit that sync to the actual length of the
incoming packet, rather than always syncing the entire buffer.

Change-ID: I626aaf6c37275a8ce9e81efcaa773f327b331487
Signed-off-by: Scott Peterson <scott.d.peterson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 16 +++++++++-------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 16 +++++++++-------
 2 files changed, 18 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index f5baeb1..4852445 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1525,7 +1525,7 @@ static inline bool i40e_page_is_reserved(struct page *page)
  * i40e_add_rx_frag - Add contents of Rx buffer to sk_buff
  * @rx_ring: rx descriptor ring to transact packets on
  * @rx_buffer: buffer containing page to add
- * @rx_desc: descriptor containing length of buffer written by hardware
+ * @size: packet length from rx_desc
  * @skb: sk_buff to place the data into
  *
  * This function will add the data contained in rx_buffer->page to the skb.
@@ -1538,13 +1538,10 @@ static inline bool i40e_page_is_reserved(struct page *page)
  **/
 static bool i40e_add_rx_frag(struct i40e_ring *rx_ring,
 			     struct i40e_rx_buffer *rx_buffer,
-			     union i40e_rx_desc *rx_desc,
+			     unsigned int size,
 			     struct sk_buff *skb)
 {
 	struct page *page = rx_buffer->page;
-	u64 qword = le64_to_cpu(rx_desc->wb.qword1.status_error_len);
-	unsigned int size = (qword & I40E_RXD_QW1_LENGTH_PBUF_MASK) >>
-			    I40E_RXD_QW1_LENGTH_PBUF_SHIFT;
 #if (PAGE_SIZE < 8192)
 	unsigned int truesize = I40E_RXBUFFER_2048;
 #else
@@ -1613,6 +1610,11 @@ static inline
 struct sk_buff *i40e_fetch_rx_buffer(struct i40e_ring *rx_ring,
 				     union i40e_rx_desc *rx_desc)
 {
+	u64 local_status_error_len =
+		le64_to_cpu(rx_desc->wb.qword1.status_error_len);
+	unsigned int size =
+		(local_status_error_len & I40E_RXD_QW1_LENGTH_PBUF_MASK) >>
+		I40E_RXD_QW1_LENGTH_PBUF_SHIFT;
 	struct i40e_rx_buffer *rx_buffer;
 	struct sk_buff *skb;
 	struct page *page;
@@ -1654,11 +1656,11 @@ struct sk_buff *i40e_fetch_rx_buffer(struct i40e_ring *rx_ring,
 	dma_sync_single_range_for_cpu(rx_ring->dev,
 				      rx_buffer->dma,
 				      rx_buffer->page_offset,
-				      I40E_RXBUFFER_2048,
+				      size,
 				      DMA_FROM_DEVICE);
 
 	/* pull page into skb */
-	if (i40e_add_rx_frag(rx_ring, rx_buffer, rx_desc, skb)) {
+	if (i40e_add_rx_frag(rx_ring, rx_buffer, size, skb)) {
 		/* hand second half of page back to the ring */
 		i40e_reuse_rx_page(rx_ring, rx_buffer);
 		rx_ring->rx_stats.page_reuse_count++;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index d4e4882..4264d91 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1003,7 +1003,7 @@ static inline bool i40e_page_is_reserved(struct page *page)
  * i40e_add_rx_frag - Add contents of Rx buffer to sk_buff
  * @rx_ring: rx descriptor ring to transact packets on
  * @rx_buffer: buffer containing page to add
- * @rx_desc: descriptor containing length of buffer written by hardware
+ * @size: packet length from rx_desc
  * @skb: sk_buff to place the data into
  *
  * This function will add the data contained in rx_buffer->page to the skb.
@@ -1016,13 +1016,10 @@ static inline bool i40e_page_is_reserved(struct page *page)
  **/
 static bool i40e_add_rx_frag(struct i40e_ring *rx_ring,
 			     struct i40e_rx_buffer *rx_buffer,
-			     union i40e_rx_desc *rx_desc,
+			     unsigned int size,
 			     struct sk_buff *skb)
 {
 	struct page *page = rx_buffer->page;
-	u64 qword = le64_to_cpu(rx_desc->wb.qword1.status_error_len);
-	unsigned int size = (qword & I40E_RXD_QW1_LENGTH_PBUF_MASK) >>
-			    I40E_RXD_QW1_LENGTH_PBUF_SHIFT;
 #if (PAGE_SIZE < 8192)
 	unsigned int truesize = I40E_RXBUFFER_2048;
 #else
@@ -1091,6 +1088,11 @@ static inline
 struct sk_buff *i40evf_fetch_rx_buffer(struct i40e_ring *rx_ring,
 				       union i40e_rx_desc *rx_desc)
 {
+	u64 local_status_error_len =
+		le64_to_cpu(rx_desc->wb.qword1.status_error_len);
+	unsigned int size =
+		(local_status_error_len & I40E_RXD_QW1_LENGTH_PBUF_MASK) >>
+		I40E_RXD_QW1_LENGTH_PBUF_SHIFT;
 	struct i40e_rx_buffer *rx_buffer;
 	struct sk_buff *skb;
 	struct page *page;
@@ -1132,11 +1134,11 @@ struct sk_buff *i40evf_fetch_rx_buffer(struct i40e_ring *rx_ring,
 	dma_sync_single_range_for_cpu(rx_ring->dev,
 				      rx_buffer->dma,
 				      rx_buffer->page_offset,
-				      I40E_RXBUFFER_2048,
+				      size,
 				      DMA_FROM_DEVICE);
 
 	/* pull page into skb */
-	if (i40e_add_rx_frag(rx_ring, rx_buffer, rx_desc, skb)) {
+	if (i40e_add_rx_frag(rx_ring, rx_buffer, size, skb)) {
 		/* hand second half of page back to the ring */
 		i40e_reuse_rx_page(rx_ring, rx_buffer);
 		rx_ring->rx_stats.page_reuse_count++;
-- 
2.10.2
