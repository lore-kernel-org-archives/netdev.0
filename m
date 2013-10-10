From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/13] i40e: Do not directly increment Tx next_to_use
Date: Wed,  9 Oct 2013 23:41:02 -0700
Message-ID: <1381387271-29605-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1381387271-29605-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:14054 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753016Ab3JJGlT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Oct 2013 02:41:19 -0400
In-Reply-To: <1381387271-29605-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Avoid directly incrementing next_to_use for multiple reasons.  The main
reason being that if we directly increment it then it can attain a state
where it is equal to the ring count.  Technically this is a state it
should not be able to reach but the way this is written it now can.

This patch pulls the value off into a register and then increments it
and writes back either the value or 0 depending on if the value is equal
to the ring count.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 46 ++++++++++++++++-------------
 1 file changed, 25 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 3bc3efa..e8db4dc 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -73,11 +73,12 @@ int i40e_program_fdir_filter(struct i40e_fdir_data *fdir_data,
 		goto dma_fail;
 
 	/* grab the next descriptor */
-	fdir_desc = I40E_TX_FDIRDESC(tx_ring, tx_ring->next_to_use);
-	tx_buf = &tx_ring->tx_bi[tx_ring->next_to_use];
-	tx_ring->next_to_use++;
-	if (tx_ring->next_to_use == tx_ring->count)
-		tx_ring->next_to_use = 0;
+	i = tx_ring->next_to_use;
+	fdir_desc = I40E_TX_FDIRDESC(tx_ring, i);
+	tx_buf = &tx_ring->tx_bi[i];
+
+	i++;
+	tx_ring->next_to_use = (i < tx_ring->count) ? i : 0;
 
 	fdir_desc->qindex_flex_ptype_vsi = cpu_to_le32((fdir_data->q_index
 					     << I40E_TXD_FLTR_QW0_QINDEX_SHIFT)
@@ -134,11 +135,11 @@ int i40e_program_fdir_filter(struct i40e_fdir_data *fdir_data,
 	fdir_desc->fd_id = cpu_to_le32(fdir_data->fd_id);
 
 	/* Now program a dummy descriptor */
-	tx_desc = I40E_TX_DESC(tx_ring, tx_ring->next_to_use);
-	tx_buf = &tx_ring->tx_bi[tx_ring->next_to_use];
-	tx_ring->next_to_use++;
-	if (tx_ring->next_to_use == tx_ring->count)
-		tx_ring->next_to_use = 0;
+	i = tx_ring->next_to_use;
+	tx_desc = I40E_TX_DESC(tx_ring, i);
+
+	i++;
+	tx_ring->next_to_use = (i < tx_ring->count) ? i : 0;
 
 	tx_desc->buffer_addr = cpu_to_le64(dma);
 	td_cmd = I40E_TX_DESC_CMD_EOP |
@@ -148,9 +149,6 @@ int i40e_program_fdir_filter(struct i40e_fdir_data *fdir_data,
 	tx_desc->cmd_type_offset_bsz =
 		build_ctob(td_cmd, 0, I40E_FDIR_MAX_RAW_PACKET_LOOKUP, 0);
 
-	/* Mark the data descriptor to be watched */
-	tx_buf->next_to_watch = tx_desc;
-
 	/* Force memory writes to complete before letting h/w
 	 * know there are new descriptors to fetch.  (Only
 	 * applicable for weak-ordered memory model archs,
@@ -158,6 +156,9 @@ int i40e_program_fdir_filter(struct i40e_fdir_data *fdir_data,
 	 */
 	wmb();
 
+	/* Mark the data descriptor to be watched */
+	tx_buf->next_to_watch = tx_desc;
+
 	writel(tx_ring->next_to_use, tx_ring->tail);
 	return 0;
 
@@ -1143,6 +1144,7 @@ static void i40e_atr(struct i40e_ring *tx_ring, struct sk_buff *skb,
 	struct tcphdr *th;
 	unsigned int hlen;
 	u32 flex_ptype, dtype_cmd;
+	u16 i;
 
 	/* make sure ATR is enabled */
 	if (!(pf->flags & I40E_FLAG_FDIR_ATR_ENABLED))
@@ -1182,10 +1184,11 @@ static void i40e_atr(struct i40e_ring *tx_ring, struct sk_buff *skb,
 	tx_ring->atr_count = 0;
 
 	/* grab the next descriptor */
-	fdir_desc = I40E_TX_FDIRDESC(tx_ring, tx_ring->next_to_use);
-	tx_ring->next_to_use++;
-	if (tx_ring->next_to_use == tx_ring->count)
-		tx_ring->next_to_use = 0;
+	i = tx_ring->next_to_use;
+	fdir_desc = I40E_TX_FDIRDESC(tx_ring, i);
+
+	i++;
+	tx_ring->next_to_use = (i < tx_ring->count) ? i : 0;
 
 	flex_ptype = (tx_ring->queue_index << I40E_TXD_FLTR_QW0_QINDEX_SHIFT) &
 		      I40E_TXD_FLTR_QW0_QINDEX_MASK;
@@ -1481,15 +1484,16 @@ static void i40e_create_tx_ctx(struct i40e_ring *tx_ring,
 			       const u32 cd_tunneling, const u32 cd_l2tag2)
 {
 	struct i40e_tx_context_desc *context_desc;
+	int i = tx_ring->next_to_use;
 
 	if (!cd_type_cmd_tso_mss && !cd_tunneling && !cd_l2tag2)
 		return;
 
 	/* grab the next descriptor */
-	context_desc = I40E_TX_CTXTDESC(tx_ring, tx_ring->next_to_use);
-	tx_ring->next_to_use++;
-	if (tx_ring->next_to_use == tx_ring->count)
-		tx_ring->next_to_use = 0;
+	context_desc = I40E_TX_CTXTDESC(tx_ring, i);
+
+	i++;
+	tx_ring->next_to_use = (i < tx_ring->count) ? i : 0;
 
 	/* cpu_to_le32 and assign to struct fields */
 	context_desc->tunneling_params = cpu_to_le32(cd_tunneling);
-- 
1.8.3.1
