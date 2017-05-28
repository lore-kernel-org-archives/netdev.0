From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 09/10] qed: Mask parities after occurance
Date: Sun, 28 May 2017 18:01:59 +0300
Message-ID: <1495983720-10853-10-git-send-email-Yuval.Mintz@cavium.com>
References: <1495983720-10853-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0088.outbound.protection.outlook.com ([104.47.33.88]:36112
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751082AbdE1PEI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 28 May 2017 11:04:08 -0400
In-Reply-To: <1495983720-10853-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Parities might exhibit a flood behavior since we re-enable the
attention line without preventing the parity from re-triggering the
assertion.
Mask the source in AEU until the parity would be handled.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_int.c | 36 ++++++++++++++++++++-----------
 1 file changed, 23 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_int.c b/drivers/net/ethernet/qlogic/qed/qed_int.c
index e19a002..6ac6d80 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_int.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_int.c
@@ -793,16 +793,18 @@ static void qed_int_attn_print(struct qed_hwfn *p_hwfn,
  *
  * @param p_hwfn
  * @param p_aeu - descriptor of an AEU bit which caused the parity
+ * @param aeu_en_reg - address of the AEU enable register
  * @param bit_index
  */
 static void qed_int_deassertion_parity(struct qed_hwfn *p_hwfn,
 				       struct aeu_invert_reg_bit *p_aeu,
-				       u8 bit_index)
+				       u32 aeu_en_reg, u8 bit_index)
 {
-	u32 block_id = p_aeu->block_index;
+	u32 block_id = p_aeu->block_index, mask, val;
 
-	DP_INFO(p_hwfn->cdev, "%s[%d] parity attention is set\n",
-		p_aeu->bit_name, bit_index);
+	DP_NOTICE(p_hwfn->cdev,
+		  "%s parity attention is set [address 0x%08x, bit %d]\n",
+		  p_aeu->bit_name, aeu_en_reg, bit_index);
 
 	if (block_id != MAX_BLOCK_ID) {
 		qed_int_attn_print(p_hwfn, block_id, ATTN_TYPE_PARITY, false);
@@ -815,6 +817,13 @@ static void qed_int_deassertion_parity(struct qed_hwfn *p_hwfn,
 					   ATTN_TYPE_PARITY, false);
 		}
 	}
+
+	/* Prevent this parity error from being re-asserted */
+	mask = ~BIT(bit_index);
+	val = qed_rd(p_hwfn, p_hwfn->p_dpc_ptt, aeu_en_reg);
+	qed_wr(p_hwfn, p_hwfn->p_dpc_ptt, aeu_en_reg, val & mask);
+	DP_INFO(p_hwfn, "`%s' - Disabled future parity errors\n",
+		p_aeu->bit_name);
 }
 
 /**
@@ -829,7 +838,7 @@ static int qed_int_deassertion(struct qed_hwfn  *p_hwfn,
 			       u16 deasserted_bits)
 {
 	struct qed_sb_attn_info *sb_attn_sw = p_hwfn->p_sb_attn;
-	u32 aeu_inv_arr[NUM_ATTN_REGS], aeu_mask;
+	u32 aeu_inv_arr[NUM_ATTN_REGS], aeu_mask, aeu_en, en;
 	u8 i, j, k, bit_idx;
 	int rc = 0;
 
@@ -846,11 +855,11 @@ static int qed_int_deassertion(struct qed_hwfn  *p_hwfn,
 	/* Find parity attentions first */
 	for (i = 0; i < NUM_ATTN_REGS; i++) {
 		struct aeu_invert_reg *p_aeu = &sb_attn_sw->p_aeu_desc[i];
-		u32 en = qed_rd(p_hwfn, p_hwfn->p_dpc_ptt,
-				MISC_REG_AEU_ENABLE1_IGU_OUT_0 +
-				i * sizeof(u32));
 		u32 parities;
 
+		aeu_en = MISC_REG_AEU_ENABLE1_IGU_OUT_0 + i * sizeof(u32);
+		en = qed_rd(p_hwfn, p_hwfn->p_dpc_ptt, aeu_en);
+
 		/* Skip register in which no parity bit is currently set */
 		parities = sb_attn_sw->parity_mask[i] & aeu_inv_arr[i] & en;
 		if (!parities)
@@ -862,7 +871,7 @@ static int qed_int_deassertion(struct qed_hwfn  *p_hwfn,
 			if (qed_int_is_parity_flag(p_hwfn, p_bit) &&
 			    !!(parities & BIT(bit_idx)))
 				qed_int_deassertion_parity(p_hwfn, p_bit,
-							   bit_idx);
+							   aeu_en, bit_idx);
 
 			bit_idx += ATTENTION_LENGTH(p_bit->flags);
 		}
@@ -877,10 +886,11 @@ static int qed_int_deassertion(struct qed_hwfn  *p_hwfn,
 			continue;
 
 		for (i = 0; i < NUM_ATTN_REGS; i++) {
-			u32 aeu_en = MISC_REG_AEU_ENABLE1_IGU_OUT_0 +
-				     i * sizeof(u32) +
-				     k * sizeof(u32) * NUM_ATTN_REGS;
-			u32 en, bits;
+			u32 bits;
+
+			aeu_en = MISC_REG_AEU_ENABLE1_IGU_OUT_0 +
+				 i * sizeof(u32) +
+				 k * sizeof(u32) * NUM_ATTN_REGS;
 
 			en = qed_rd(p_hwfn, p_hwfn->p_dpc_ptt, aeu_en);
 			bits = aeu_inv_arr[i] & en;
-- 
1.9.3
