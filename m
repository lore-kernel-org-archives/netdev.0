From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/2] i40e: Fix memory leak related filter programming status
Date: Tue, 10 Oct 2017 08:14:16 -0700
Message-ID: <20171010151416.43149-3-jeffrey.t.kirsher@intel.com>
References: <20171010151416.43149-1-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:50722 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932367AbdJJPOh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 10 Oct 2017 11:14:37 -0400
In-Reply-To: <20171010151416.43149-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

It looks like we weren't correctly placing the pages from buffers that had
been used to return a filter programming status back on the ring. As a
result they were being overwritten and tracking of the pages was lost.

This change works to correct that by incorporating part of
i40e_put_rx_buffer into the programming status handler code. As a result we
should now be correctly placing the pages for those buffers on the
re-allocation list instead of letting them stay in place.

Fixes: 0e626ff7ccbf ("i40e: Fix support for flow director programming status")
Reported-by: Anders K. Pedersen <akp@cohaesio.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Anders K Pedersen <akp@cohaesio.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 63 ++++++++++++++++-------------
 1 file changed, 36 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 1519dfb851d0..2756131495f0 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1037,6 +1037,32 @@ static bool i40e_set_new_dynamic_itr(struct i40e_ring_container *rc)
 	return false;
 }
 
+/**
+ * i40e_reuse_rx_page - page flip buffer and store it back on the ring
+ * @rx_ring: rx descriptor ring to store buffers on
+ * @old_buff: donor buffer to have page reused
+ *
+ * Synchronizes page for reuse by the adapter
+ **/
+static void i40e_reuse_rx_page(struct i40e_ring *rx_ring,
+			       struct i40e_rx_buffer *old_buff)
+{
+	struct i40e_rx_buffer *new_buff;
+	u16 nta = rx_ring->next_to_alloc;
+
+	new_buff = &rx_ring->rx_bi[nta];
+
+	/* update, and store next to alloc */
+	nta++;
+	rx_ring->next_to_alloc = (nta < rx_ring->count) ? nta : 0;
+
+	/* transfer page from old buffer to new buffer */
+	new_buff->dma		= old_buff->dma;
+	new_buff->page		= old_buff->page;
+	new_buff->page_offset	= old_buff->page_offset;
+	new_buff->pagecnt_bias	= old_buff->pagecnt_bias;
+}
+
 /**
  * i40e_rx_is_programming_status - check for programming status descriptor
  * @qw: qword representing status_error_len in CPU ordering
@@ -1071,15 +1097,24 @@ static void i40e_clean_programming_status(struct i40e_ring *rx_ring,
 					  union i40e_rx_desc *rx_desc,
 					  u64 qw)
 {
-	u32 ntc = rx_ring->next_to_clean + 1;
+	struct i40e_rx_buffer *rx_buffer;
+	u32 ntc = rx_ring->next_to_clean;
 	u8 id;
 
 	/* fetch, update, and store next to clean */
+	rx_buffer = &rx_ring->rx_bi[ntc++];
 	ntc = (ntc < rx_ring->count) ? ntc : 0;
 	rx_ring->next_to_clean = ntc;
 
 	prefetch(I40E_RX_DESC(rx_ring, ntc));
 
+	/* place unused page back on the ring */
+	i40e_reuse_rx_page(rx_ring, rx_buffer);
+	rx_ring->rx_stats.page_reuse_count++;
+
+	/* clear contents of buffer_info */
+	rx_buffer->page = NULL;
+
 	id = (qw & I40E_RX_PROG_STATUS_DESC_QW1_PROGID_MASK) >>
 		  I40E_RX_PROG_STATUS_DESC_QW1_PROGID_SHIFT;
 
@@ -1638,32 +1673,6 @@ static bool i40e_cleanup_headers(struct i40e_ring *rx_ring, struct sk_buff *skb,
 	return false;
 }
 
-/**
- * i40e_reuse_rx_page - page flip buffer and store it back on the ring
- * @rx_ring: rx descriptor ring to store buffers on
- * @old_buff: donor buffer to have page reused
- *
- * Synchronizes page for reuse by the adapter
- **/
-static void i40e_reuse_rx_page(struct i40e_ring *rx_ring,
-			       struct i40e_rx_buffer *old_buff)
-{
-	struct i40e_rx_buffer *new_buff;
-	u16 nta = rx_ring->next_to_alloc;
-
-	new_buff = &rx_ring->rx_bi[nta];
-
-	/* update, and store next to alloc */
-	nta++;
-	rx_ring->next_to_alloc = (nta < rx_ring->count) ? nta : 0;
-
-	/* transfer page from old buffer to new buffer */
-	new_buff->dma		= old_buff->dma;
-	new_buff->page		= old_buff->page;
-	new_buff->page_offset	= old_buff->page_offset;
-	new_buff->pagecnt_bias	= old_buff->pagecnt_bias;
-}
-
 /**
  * i40e_page_is_reusable - check if any reuse is possible
  * @page: page struct to check
-- 
2.14.2
