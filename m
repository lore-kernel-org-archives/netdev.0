From: Yuval Mintz <yuvalmin@broadcom.com>
Subject: [PATCH net-next 7/9] bnx2x: Fix bnx2x_panic_dump for VFs
Date: Mon, 10 Feb 2014 17:17:00 +0200
Message-ID: <1392045422-5437-8-git-send-email-yuvalmin@broadcom.com>
References: <1392045422-5437-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ariele@broadcom.com>, Yuval Mintz <yuvalmin@broadcom.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:27660 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752151AbaBJPRQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 10:17:16 -0500
In-Reply-To: <1392045422-5437-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bnx2x_panic_dump() prints all kind of driver information, including slowpath
information. Since VFs don't initialize slowpath information, a VF reaching
this flow will likely cause a panic in the system as it will access NULL
pointers.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
---
Notice although this is a bug fix it's intended to net-next; The reason is
that practically all of the bnx2x_panic() calls are made either as a result
of bad FW/HW access, or due to some flow if driver was compiled with
BNX2X_STOP_ON_ERROR. As the former is impossible for a VF, this in practice
only fixes issues when BNX2X_STOP_ON_ERROR is used, which isn't mainstream.
Also, it doesn't pass checkpatch (as it doesn't change print format).
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 97 ++++++++++++++----------
 1 file changed, 57 insertions(+), 40 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 7245059..8ff5326 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -918,7 +918,7 @@ void bnx2x_panic_dump(struct bnx2x *bp, bool disable_int)
 	u16 start = 0, end = 0;
 	u8 cos;
 #endif
-	if (disable_int)
+	if (IS_PF(bp) && disable_int)
 		bnx2x_int_disable(bp);
 
 	bp->stats_state = STATS_STATE_DISABLED;
@@ -929,33 +929,41 @@ void bnx2x_panic_dump(struct bnx2x *bp, bool disable_int)
 
 	/* Indices */
 	/* Common */
-	BNX2X_ERR("def_idx(0x%x)  def_att_idx(0x%x)  attn_state(0x%x)  spq_prod_idx(0x%x) next_stats_cnt(0x%x)\n",
-		  bp->def_idx, bp->def_att_idx, bp->attn_state,
-		  bp->spq_prod_idx, bp->stats_counter);
-	BNX2X_ERR("DSB: attn bits(0x%x)  ack(0x%x)  id(0x%x)  idx(0x%x)\n",
-		  bp->def_status_blk->atten_status_block.attn_bits,
-		  bp->def_status_blk->atten_status_block.attn_bits_ack,
-		  bp->def_status_blk->atten_status_block.status_block_id,
-		  bp->def_status_blk->atten_status_block.attn_bits_index);
-	BNX2X_ERR("     def (");
-	for (i = 0; i < HC_SP_SB_MAX_INDICES; i++)
-		pr_cont("0x%x%s",
-			bp->def_status_blk->sp_sb.index_values[i],
-			(i == HC_SP_SB_MAX_INDICES - 1) ? ")  " : " ");
-
-	for (i = 0; i < sizeof(struct hc_sp_status_block_data)/sizeof(u32); i++)
-		*((u32 *)&sp_sb_data + i) = REG_RD(bp, BAR_CSTRORM_INTMEM +
-			CSTORM_SP_STATUS_BLOCK_DATA_OFFSET(func) +
-			i*sizeof(u32));
-
-	pr_cont("igu_sb_id(0x%x)  igu_seg_id(0x%x) pf_id(0x%x)  vnic_id(0x%x)  vf_id(0x%x)  vf_valid (0x%x) state(0x%x)\n",
-	       sp_sb_data.igu_sb_id,
-	       sp_sb_data.igu_seg_id,
-	       sp_sb_data.p_func.pf_id,
-	       sp_sb_data.p_func.vnic_id,
-	       sp_sb_data.p_func.vf_id,
-	       sp_sb_data.p_func.vf_valid,
-	       sp_sb_data.state);
+	if (IS_PF(bp)) {
+		struct host_sp_status_block *def_sb = bp->def_status_blk;
+		int data_size, cstorm_offset;
+
+		BNX2X_ERR("def_idx(0x%x)  def_att_idx(0x%x)  attn_state(0x%x)  spq_prod_idx(0x%x) next_stats_cnt(0x%x)\n",
+			  bp->def_idx, bp->def_att_idx, bp->attn_state,
+			  bp->spq_prod_idx, bp->stats_counter);
+		BNX2X_ERR("DSB: attn bits(0x%x)  ack(0x%x)  id(0x%x)  idx(0x%x)\n",
+			  def_sb->atten_status_block.attn_bits,
+			  def_sb->atten_status_block.attn_bits_ack,
+			  def_sb->atten_status_block.status_block_id,
+			  def_sb->atten_status_block.attn_bits_index);
+		BNX2X_ERR("     def (");
+		for (i = 0; i < HC_SP_SB_MAX_INDICES; i++)
+			pr_cont("0x%x%s",
+				def_sb->sp_sb.index_values[i],
+				(i == HC_SP_SB_MAX_INDICES - 1) ? ")  " : " ");
+
+		data_size = sizeof(struct hc_sp_status_block_data) /
+			    sizeof(u32);
+		cstorm_offset = CSTORM_SP_STATUS_BLOCK_DATA_OFFSET(func);
+		for (i = 0; i < data_size; i++)
+			*((u32 *)&sp_sb_data + i) =
+				REG_RD(bp, BAR_CSTRORM_INTMEM + cstorm_offset +
+					   i * sizeof(u32));
+
+		pr_cont("igu_sb_id(0x%x)  igu_seg_id(0x%x) pf_id(0x%x)  vnic_id(0x%x)  vf_id(0x%x)  vf_valid (0x%x) state(0x%x)\n",
+			sp_sb_data.igu_sb_id,
+			sp_sb_data.igu_seg_id,
+			sp_sb_data.p_func.pf_id,
+			sp_sb_data.p_func.vnic_id,
+			sp_sb_data.p_func.vf_id,
+			sp_sb_data.p_func.vf_valid,
+			sp_sb_data.state);
+	}
 
 	for_each_eth_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];
@@ -1013,6 +1021,11 @@ void bnx2x_panic_dump(struct bnx2x *bp, bool disable_int)
 			pr_cont("0x%x%s",
 			       fp->sb_index_values[j],
 			       (j == loop - 1) ? ")" : " ");
+
+		/* VF cannot access FW refelection for status block */
+		if (IS_VF(bp))
+			continue;
+
 		/* fw sb data */
 		data_size = CHIP_IS_E1x(bp) ?
 			sizeof(struct hc_status_block_data_e1x) :
@@ -1064,16 +1077,18 @@ void bnx2x_panic_dump(struct bnx2x *bp, bool disable_int)
 	}
 
 #ifdef BNX2X_STOP_ON_ERROR
-
-	/* event queue */
-	BNX2X_ERR("eq cons %x prod %x\n", bp->eq_cons, bp->eq_prod);
-	for (i = 0; i < NUM_EQ_DESC; i++) {
-		u32 *data = (u32 *)&bp->eq_ring[i].message.data;
-
-		BNX2X_ERR("event queue [%d]: header: opcode %d, error %d\n",
-			  i, bp->eq_ring[i].message.opcode,
-			  bp->eq_ring[i].message.error);
-		BNX2X_ERR("data: %x %x %x\n", data[0], data[1], data[2]);
+	if (IS_PF(bp)) {
+		/* event queue */
+		BNX2X_ERR("eq cons %x prod %x\n", bp->eq_cons, bp->eq_prod);
+		for (i = 0; i < NUM_EQ_DESC; i++) {
+			u32 *data = (u32 *)&bp->eq_ring[i].message.data;
+
+			BNX2X_ERR("event queue [%d]: header: opcode %d, error %d\n",
+				  i, bp->eq_ring[i].message.opcode,
+				  bp->eq_ring[i].message.error);
+			BNX2X_ERR("data: %x %x %x\n",
+				  data[0], data[1], data[2]);
+		}
 	}
 
 	/* Rings */
@@ -1140,8 +1155,10 @@ void bnx2x_panic_dump(struct bnx2x *bp, bool disable_int)
 		}
 	}
 #endif
-	bnx2x_fw_dump(bp);
-	bnx2x_mc_assert(bp);
+	if (IS_PF(bp)) {
+		bnx2x_fw_dump(bp);
+		bnx2x_mc_assert(bp);
+	}
 	BNX2X_ERR("end crash dump -----------------\n");
 }
 
-- 
1.8.1.227.g44fe835
