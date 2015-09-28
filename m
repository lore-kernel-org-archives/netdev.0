From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/5] i40e: Fix RS bit update in Tx path and disable force WB workaround
Date: Mon, 28 Sep 2015 12:33:19 -0700
Message-ID: <1443468800-37102-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1443468800-37102-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai <anjali.singhai@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:40771 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751905AbbI1Tda (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Sep 2015 15:33:30 -0400
In-Reply-To: <1443468800-37102-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai <anjali.singhai@intel.com>

This patch fixes the issue of forcing WB too often causing us to not
benefit from NAPI.

Without this patch we were forcing WB/arming interrupt too often taking
away the benefits of NAPI and causing a performance impact.

With this patch we disable force WB in the clean routine for X710
and XL710 adapters. X722 adapters do not enable interrupt to force
a WB and benefit from WB_ON_ITR and hence force WB is left enabled
for those adapters.
For XL710 and X710 adapters if we have less than 4 packets pending
a software Interrupt triggered from service task will force a WB.

This patch also changes the conditions for setting RS bit as described
in code comments. This optimizes when the HW does a tail bump and when
it does a WB. It also optimizes when we do a wmb.

Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 129 ++++++++++++++++++----------
 drivers/net/ethernet/intel/i40e/i40e_txrx.h |   2 +
 2 files changed, 87 insertions(+), 44 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index d699fc9..3ce4900 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -726,17 +726,22 @@ static bool i40e_clean_tx_irq(struct i40e_ring *tx_ring, int budget)
 	tx_ring->q_vector->tx.total_bytes += total_bytes;
 	tx_ring->q_vector->tx.total_packets += total_packets;
 
-	/* check to see if there are any non-cache aligned descriptors
-	 * waiting to be written back, and kick the hardware to force
-	 * them to be written back in case of napi polling
-	 */
-	if (budget &&
-	    !((i & WB_STRIDE) == WB_STRIDE) &&
-	    !test_bit(__I40E_DOWN, &tx_ring->vsi->state) &&
-	    (I40E_DESC_UNUSED(tx_ring) != tx_ring->count))
-		tx_ring->arm_wb = true;
-	else
-		tx_ring->arm_wb = false;
+	if (tx_ring->flags & I40E_TXR_FLAGS_WB_ON_ITR) {
+		unsigned int j = 0;
+
+		/* check to see if there are < 4 descriptors
+		 * waiting to be written back, then kick the hardware to force
+		 * them to be written back in case we stay in NAPI.
+		 * In this mode on X722 we do not enable Interrupt.
+		 */
+		j = i40e_get_tx_pending(tx_ring);
+
+		if (budget &&
+		    ((j / (WB_STRIDE + 1)) == 0) && (j != 0) &&
+		    !test_bit(__I40E_DOWN, &tx_ring->vsi->state) &&
+		    (I40E_DESC_UNUSED(tx_ring) != tx_ring->count))
+			tx_ring->arm_wb = true;
+	}
 
 	netdev_tx_completed_queue(netdev_get_tx_queue(tx_ring->netdev,
 						      tx_ring->queue_index),
@@ -2500,6 +2505,9 @@ static inline void i40e_tx_map(struct i40e_ring *tx_ring, struct sk_buff *skb,
 	u32 td_tag = 0;
 	dma_addr_t dma;
 	u16 gso_segs;
+	u16 desc_count = 0;
+	bool tail_bump = true;
+	bool do_rs = false;
 
 	if (tx_flags & I40E_TX_FLAGS_HW_VLAN) {
 		td_cmd |= I40E_TX_DESC_CMD_IL2TAG1;
@@ -2540,6 +2548,8 @@ static inline void i40e_tx_map(struct i40e_ring *tx_ring, struct sk_buff *skb,
 
 			tx_desc++;
 			i++;
+			desc_count++;
+
 			if (i == tx_ring->count) {
 				tx_desc = I40E_TX_DESC(tx_ring, 0);
 				i = 0;
@@ -2559,6 +2569,8 @@ static inline void i40e_tx_map(struct i40e_ring *tx_ring, struct sk_buff *skb,
 
 		tx_desc++;
 		i++;
+		desc_count++;
+
 		if (i == tx_ring->count) {
 			tx_desc = I40E_TX_DESC(tx_ring, 0);
 			i = 0;
@@ -2573,34 +2585,6 @@ static inline void i40e_tx_map(struct i40e_ring *tx_ring, struct sk_buff *skb,
 		tx_bi = &tx_ring->tx_bi[i];
 	}
 
-	/* Place RS bit on last descriptor of any packet that spans across the
-	 * 4th descriptor (WB_STRIDE aka 0x3) in a 64B cacheline.
-	 */
-	if (((i & WB_STRIDE) != WB_STRIDE) &&
-	    (first <= &tx_ring->tx_bi[i]) &&
-	    (first >= &tx_ring->tx_bi[i & ~WB_STRIDE])) {
-		tx_desc->cmd_type_offset_bsz =
-			build_ctob(td_cmd, td_offset, size, td_tag) |
-			cpu_to_le64((u64)I40E_TX_DESC_CMD_EOP <<
-					 I40E_TXD_QW1_CMD_SHIFT);
-	} else {
-		tx_desc->cmd_type_offset_bsz =
-			build_ctob(td_cmd, td_offset, size, td_tag) |
-			cpu_to_le64((u64)I40E_TXD_CMD <<
-					 I40E_TXD_QW1_CMD_SHIFT);
-	}
-
-	netdev_tx_sent_queue(netdev_get_tx_queue(tx_ring->netdev,
-						 tx_ring->queue_index),
-			     first->bytecount);
-
-	/* Force memory writes to complete before letting h/w
-	 * know there are new descriptors to fetch.  (Only
-	 * applicable for weak-ordered memory model archs,
-	 * such as IA-64).
-	 */
-	wmb();
-
 	/* set next_to_watch value indicating a packet is present */
 	first->next_to_watch = tx_desc;
 
@@ -2610,15 +2594,72 @@ static inline void i40e_tx_map(struct i40e_ring *tx_ring, struct sk_buff *skb,
 
 	tx_ring->next_to_use = i;
 
+	netdev_tx_sent_queue(netdev_get_tx_queue(tx_ring->netdev,
+						 tx_ring->queue_index),
+						 first->bytecount);
 	i40e_maybe_stop_tx(tx_ring, DESC_NEEDED);
+
+	/* Algorithm to optimize tail and RS bit setting:
+	 * if xmit_more is supported
+	 *	if xmit_more is true
+	 *		do not update tail and do not mark RS bit.
+	 *	if xmit_more is false and last xmit_more was false
+	 *		if every packet spanned less than 4 desc
+	 *			then set RS bit on 4th packet and update tail
+	 *			on every packet
+	 *		else
+	 *			update tail and set RS bit on every packet.
+	 *	if xmit_more is false and last_xmit_more was true
+	 *		update tail and set RS bit.
+	 *
+	 * Optimization: wmb to be issued only in case of tail update.
+	 * Also optimize the Descriptor WB path for RS bit with the same
+	 * algorithm.
+	 *
+	 * Note: If there are less than 4 packets
+	 * pending and interrupts were disabled the service task will
+	 * trigger a force WB.
+	 */
+	if (skb->xmit_more  &&
+	    !netif_xmit_stopped(netdev_get_tx_queue(tx_ring->netdev,
+						    tx_ring->queue_index))) {
+		tx_ring->flags |= I40E_TXR_FLAGS_LAST_XMIT_MORE_SET;
+		tail_bump = false;
+	} else if (!skb->xmit_more &&
+		   !netif_xmit_stopped(netdev_get_tx_queue(tx_ring->netdev,
+						       tx_ring->queue_index)) &&
+		   (!(tx_ring->flags & I40E_TXR_FLAGS_LAST_XMIT_MORE_SET)) &&
+		   (tx_ring->packet_stride < WB_STRIDE) &&
+		   (desc_count < WB_STRIDE)) {
+		tx_ring->packet_stride++;
+	} else {
+		tx_ring->packet_stride = 0;
+		tx_ring->flags &= ~I40E_TXR_FLAGS_LAST_XMIT_MORE_SET;
+		do_rs = true;
+	}
+	if (do_rs)
+		tx_ring->packet_stride = 0;
+
+	tx_desc->cmd_type_offset_bsz =
+			build_ctob(td_cmd, td_offset, size, td_tag) |
+			cpu_to_le64((u64)(do_rs ? I40E_TXD_CMD :
+						  I40E_TX_DESC_CMD_EOP) <<
+						  I40E_TXD_QW1_CMD_SHIFT);
+
 	/* notify HW of packet */
-	if (!skb->xmit_more ||
-	    netif_xmit_stopped(netdev_get_tx_queue(tx_ring->netdev,
-						   tx_ring->queue_index)))
-		writel(i, tx_ring->tail);
-	else
+	if (!tail_bump)
 		prefetchw(tx_desc + 1);
 
+	if (tail_bump) {
+		/* Force memory writes to complete before letting h/w
+		 * know there are new descriptors to fetch.  (Only
+		 * applicable for weak-ordered memory model archs,
+		 * such as IA-64).
+		 */
+		wmb();
+		writel(i, tx_ring->tail);
+	}
+
 	return;
 
 dma_error:
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index 977cb5b..a3978c2 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -256,10 +256,12 @@ struct i40e_ring {
 
 	bool ring_active;		/* is ring online or not */
 	bool arm_wb;		/* do something to arm write back */
+	u8 packet_stride;
 
 	u16 flags;
 #define I40E_TXR_FLAGS_WB_ON_ITR	BIT(0)
 #define I40E_TXR_FLAGS_OUTER_UDP_CSUM	BIT(1)
+#define I40E_TXR_FLAGS_LAST_XMIT_MORE_SET BIT(2)
 
 	/* stats structs */
 	struct i40e_queue_stats	stats;
-- 
2.4.3
