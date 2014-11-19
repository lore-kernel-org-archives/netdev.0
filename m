From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/15] ixgbevf: Update Rx next to clean in real time
Date: Tue, 18 Nov 2014 20:10:47 -0800
Message-ID: <1416370256-16834-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1416370256-16834-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:39897 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754480AbaKSELH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Nov 2014 23:11:07 -0500
In-Reply-To: <1416370256-16834-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Since the next_to_clean value is only accessed by the Rx interrupt handler
we can save on stack space by just storing our updated values back in
next_to_clean instead of using the stack variable i.  This should help to
reduce stack space and we can further collapse the size of the function.

Also removed  non_eop_descs counter as it was never shown in the stats.

CC: Alexander Duyck <alexander.h.duyck@redhat.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |  2 -
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 55 +++++++++++++++--------
 2 files changed, 36 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index 90d5751..72a354b 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -79,7 +79,6 @@ struct ixgbevf_tx_queue_stats {
 };
 
 struct ixgbevf_rx_queue_stats {
-	u64 non_eop_descs;
 	u64 alloc_rx_page_failed;
 	u64 alloc_rx_buff_failed;
 	u64 csum_err;
@@ -372,7 +371,6 @@ struct ixgbevf_adapter {
 	struct ixgbevf_ring *rx_ring[MAX_TX_QUEUES]; /* One per active queue */
 	u64 hw_csum_rx_error;
 	u64 hw_rx_no_dma_resources;
-	u64 non_eop_descs;
 	int num_msix_vectors;
 	u32 alloc_rx_page_failed;
 	u32 alloc_rx_buff_failed;
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 2206992..20bebd2 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -410,6 +410,35 @@ static void ixgbevf_process_skb_fields(struct ixgbevf_ring *rx_ring,
 	skb->protocol = eth_type_trans(skb, rx_ring->netdev);
 }
 
+/**
+ * ixgbevf_is_non_eop - process handling of non-EOP buffers
+ * @rx_ring: Rx ring being processed
+ * @rx_desc: Rx descriptor for current buffer
+ * @skb: current socket buffer containing buffer in progress
+ *
+ * This function updates next to clean.  If the buffer is an EOP buffer
+ * this function exits returning false, otherwise it will place the
+ * sk_buff in the next buffer to be chained and return true indicating
+ * that this is in fact a non-EOP buffer.
+ **/
+static bool ixgbevf_is_non_eop(struct ixgbevf_ring *rx_ring,
+			       union ixgbe_adv_rx_desc *rx_desc,
+			       struct sk_buff *skb)
+{
+	u32 ntc = rx_ring->next_to_clean + 1;
+
+	/* fetch, update, and store next to clean */
+	ntc = (ntc < rx_ring->count) ? ntc : 0;
+	rx_ring->next_to_clean = ntc;
+
+	prefetch(IXGBEVF_RX_DESC(rx_ring, ntc));
+
+	if (likely(ixgbevf_test_staterr(rx_desc, IXGBE_RXD_STAT_EOP)))
+		return false;
+
+	return true;
+}
+
 static bool ixgbevf_alloc_mapped_skb(struct ixgbevf_ring *rx_ring,
 				     struct ixgbevf_rx_buffer *bi)
 {
@@ -517,16 +546,14 @@ static int ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
 				struct ixgbevf_ring *rx_ring,
 				int budget)
 {
-	unsigned int i;
 	unsigned int total_rx_bytes = 0, total_rx_packets = 0;
 	u16 cleaned_count = ixgbevf_desc_unused(rx_ring);
 
-	i = rx_ring->next_to_clean;
-
 	do {
-		union ixgbe_adv_rx_desc *rx_desc, *next_rxd;
+		union ixgbe_adv_rx_desc *rx_desc;
 		struct ixgbevf_rx_buffer *rx_buffer;
 		struct sk_buff *skb;
+		u16 ntc;
 
 		/* return some buffers to hardware, one at a time is too slow */
 		if (cleaned_count >= IXGBEVF_RX_BUFFER_WRITE) {
@@ -534,8 +561,9 @@ static int ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
 			cleaned_count = 0;
 		}
 
-		rx_desc = IXGBEVF_RX_DESC(rx_ring, i);
-		rx_buffer = &rx_ring->rx_buffer_info[i];
+		ntc = rx_ring->next_to_clean;
+		rx_desc = IXGBEVF_RX_DESC(rx_ring, ntc);
+		rx_buffer = &rx_ring->rx_buffer_info[ntc];
 
 		if (!ixgbevf_test_staterr(rx_desc, IXGBE_RXD_STAT_DD))
 			break;
@@ -562,19 +590,9 @@ static int ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
 
 		cleaned_count++;
 
-		i++;
-		if (i == rx_ring->count)
-			i = 0;
-
-		next_rxd = IXGBEVF_RX_DESC(rx_ring, i);
-		prefetch(next_rxd);
-
-		if (!(ixgbevf_test_staterr(rx_desc, IXGBE_RXD_STAT_EOP))) {
-			skb->next = rx_ring->rx_buffer_info[i].skb;
-			IXGBE_CB(skb->next)->prev = skb;
-			rx_ring->rx_stats.non_eop_descs++;
+		/* place incomplete frames back on ring for completion */
+		if (ixgbevf_is_non_eop(rx_ring, rx_desc, skb))
 			continue;
-		}
 
 		/* we should not be chaining buffers, if we did drop the skb */
 		if (IXGBE_CB(skb)->prev) {
@@ -617,7 +635,6 @@ static int ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
 		budget--;
 	} while (likely(budget));
 
-	rx_ring->next_to_clean = i;
 	u64_stats_update_begin(&rx_ring->syncp);
 	rx_ring->stats.packets += total_rx_packets;
 	rx_ring->stats.bytes += total_rx_bytes;
-- 
1.9.3
