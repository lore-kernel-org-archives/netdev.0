From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 11/34]bnx2x: Endianness issues
Date: Wed, 14 Jan 2009 18:43:15 +0200
Message-ID: <1231951395.11301.132.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1340 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763203AbZANQoD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 11:44:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding missing le_to_cpu and disabling wrong HW endianity flag (the two complete
each other)

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index ba56d1c..d32b98f 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -1454,7 +1454,7 @@ static int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 		DP(NETIF_MSG_RX_STATUS, "CQE type %x  err %x  status %x"
 		   "  queue %x  vlan %x  len %u\n", CQE_TYPE(cqe_fp_flags),
 		   cqe_fp_flags, cqe->fast_path_cqe.status_flags,
-		   cqe->fast_path_cqe.rss_hash_result,
+		   le32_to_cpu(cqe->fast_path_cqe.rss_hash_result),
 		   le16_to_cpu(cqe->fast_path_cqe.vlan_tag),
 		   le16_to_cpu(cqe->fast_path_cqe.pkt_len));
 
@@ -2837,8 +2837,10 @@ static void bnx2x_attn_int_deasserted(struct bnx2x *bp, u32 deasserted)
 static void bnx2x_attn_int(struct bnx2x *bp)
 {
 	/* read local copy of bits */
-	u32 attn_bits = bp->def_status_blk->atten_status_block.attn_bits;
-	u32 attn_ack = bp->def_status_blk->atten_status_block.attn_bits_ack;
+	u32 attn_bits = le32_to_cpu(bp->def_status_blk->atten_status_block.
+								attn_bits);
+	u32 attn_ack = le32_to_cpu(bp->def_status_blk->atten_status_block.
+								attn_bits_ack);
 	u32 attn_state = bp->attn_state;
 
 	/* look for changed bits */
@@ -2886,7 +2888,7 @@ static void bnx2x_sp_task(struct work_struct *work)
 	if (status & 0x2)
 		bp->stats_pending = 0;
 
-	bnx2x_ack_sb(bp, DEF_SB_ID, ATTENTION_ID, bp->def_att_idx,
+	bnx2x_ack_sb(bp, DEF_SB_ID, ATTENTION_ID, le16_to_cpu(bp->def_att_idx),
 		     IGU_INT_NOP, 1);
 	bnx2x_ack_sb(bp, DEF_SB_ID, USTORM_ID, le16_to_cpu(bp->def_u_idx),
 		     IGU_INT_NOP, 1);
@@ -5177,7 +5179,6 @@ static int bnx2x_init_common(struct bnx2x *bp)
 	REG_WR(bp, PXP2_REG_RQ_SRC_ENDIAN_M, 1);
 	REG_WR(bp, PXP2_REG_RQ_CDU_ENDIAN_M, 1);
 	REG_WR(bp, PXP2_REG_RQ_DBG_ENDIAN_M, 1);
-	REG_WR(bp, PXP2_REG_RQ_HC_ENDIAN_M, 1);
 
 /*	REG_WR(bp, PXP2_REG_RD_PBF_SWAP_MODE, 1); */
 	REG_WR(bp, PXP2_REG_RD_QM_SWAP_MODE, 1);
-- 
1.5.4.3




