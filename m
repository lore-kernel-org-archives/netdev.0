From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: [jkirsher/net-queue PATCH] i40e: Fix memory leak related filter
 programming status
Date: Wed, 04 Oct 2017 08:44:43 -0700
Message-ID: <20171004153903.13100.38029.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: akp@cohaesio.com
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:37372 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752409AbdJDPoq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 11:44:46 -0400
Received: by mail-pf0-f194.google.com with SMTP id e69so12621432pfg.4
        for <netdev@vger.kernel.org>; Wed, 04 Oct 2017 08:44:46 -0700 (PDT)
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
---

I'm submitting this for Jeff's net queue to undergo some additional testing
before being submitted for net or stable to address the memory leak isue. The
testing for this should be pretty straight forward since ATR filters seem
to cause the issue it should be possible to trigger a pretty signficant
amount of memory loss running something like a netperf TCP_CRR test for an
extended period of time which will trigger multiple socket
creation/destruction.

Anders, feel free to test this patch. If you need to grab a copy of the
diff instead of trying to work with applying the patch through email you
should be able to find a copy at the following URL shortly after I submit
this to intel-wired-lan:
	http://patchwork.ozlabs.org/project/intel-wired-lan/list/

 drivers/net/ethernet/intel/i40e/i40e_txrx.c |   63 +++++++++++++++------------
 1 file changed, 36 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 94311e3e4f43..d4ae24674a70 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1038,6 +1038,32 @@ static bool i40e_set_new_dynamic_itr(struct i40e_ring_container *rc)
 }
 
 /**
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
+/**
  * i40e_rx_is_programming_status - check for programming status descriptor
  * @qw: qword representing status_error_len in CPU ordering
  *
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
 
@@ -1648,32 +1683,6 @@ static bool i40e_cleanup_headers(struct i40e_ring *rx_ring, struct sk_buff *skb,
 }
 
 /**
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
-/**
  * i40e_page_is_reusable - check if any reuse is possible
  * @page: page struct to check
  *
