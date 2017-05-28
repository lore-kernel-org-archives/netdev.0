From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 08/10] qed: Print multi-bit attentions properly
Date: Sun, 28 May 2017 18:01:58 +0300
Message-ID: <1495983720-10853-9-git-send-email-Yuval.Mintz@cavium.com>
References: <1495983720-10853-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0042.outbound.protection.outlook.com ([104.47.42.42]:26240
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751012AbdE1PEL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 28 May 2017 11:04:11 -0400
In-Reply-To: <1495983720-10853-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In strucuture reflecting the AEU hw block some entries
represent multiple HW bits, and the associated name is in fact
a pattern.
Today, whenever such an attention would be asserted the resulted
prints would show the pattern string instead of indicating which
of the possible bits was set.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_int.c | 38 +++++++++++++++++++++++++++----
 1 file changed, 33 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_int.c b/drivers/net/ethernet/qlogic/qed/qed_int.c
index de6f60c..e19a002 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_int.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_int.c
@@ -749,19 +749,19 @@ static void qed_int_attn_print(struct qed_hwfn *p_hwfn,
 qed_int_deassertion_aeu_bit(struct qed_hwfn *p_hwfn,
 			    struct aeu_invert_reg_bit *p_aeu,
 			    u32 aeu_en_reg,
-			    u32 bitmask)
+			    const char *p_bit_name, u32 bitmask)
 {
 	bool b_fatal = false;
 	int rc = -EINVAL;
 	u32 val;
 
 	DP_INFO(p_hwfn, "Deasserted attention `%s'[%08x]\n",
-		p_aeu->bit_name, bitmask);
+		p_bit_name, bitmask);
 
 	/* Call callback before clearing the interrupt status */
 	if (p_aeu->cb) {
 		DP_INFO(p_hwfn, "`%s (attention)': Calling Callback function\n",
-			p_aeu->bit_name);
+			p_bit_name);
 		rc = p_aeu->cb(p_hwfn);
 	}
 
@@ -782,7 +782,7 @@ static void qed_int_attn_print(struct qed_hwfn *p_hwfn,
 	val = qed_rd(p_hwfn, p_hwfn->p_dpc_ptt, aeu_en_reg);
 	qed_wr(p_hwfn, p_hwfn->p_dpc_ptt, aeu_en_reg, (val & ~bitmask));
 	DP_INFO(p_hwfn, "`%s' - Disabled future attentions\n",
-		p_aeu->bit_name);
+		p_bit_name);
 
 out:
 	return rc;
@@ -894,8 +894,8 @@ static int qed_int_deassertion(struct qed_hwfn  *p_hwfn,
 			 * previous assertion.
 			 */
 			for (j = 0, bit_idx = 0; bit_idx < 32; j++) {
+				long unsigned int bitmask;
 				u8 bit, bit_len;
-				u32 bitmask;
 
 				p_aeu = &sb_attn_sw->p_aeu_desc[i].bits[j];
 				p_aeu = qed_int_aeu_translate(p_hwfn, p_aeu);
@@ -909,11 +909,39 @@ static int qed_int_deassertion(struct qed_hwfn  *p_hwfn,
 				}
 
 				bitmask = bits & (((1 << bit_len) - 1) << bit);
+				bitmask >>= bit;
+
 				if (bitmask) {
+					u32 flags = p_aeu->flags;
+					char bit_name[30];
+					u8 num;
+
+					num = (u8)find_first_bit(&bitmask,
+								 bit_len);
+
+					/* Some bits represent more than a
+					 * a single interrupt. Correctly print
+					 * their name.
+					 */
+					if (ATTENTION_LENGTH(flags) > 2 ||
+					    ((flags & ATTENTION_PAR_INT) &&
+					     ATTENTION_LENGTH(flags) > 1))
+						snprintf(bit_name, 30,
+							 p_aeu->bit_name, num);
+					else
+						strncpy(bit_name,
+							p_aeu->bit_name, 30);
+
+					/* We now need to pass bitmask in its
+					 * correct position.
+					 */
+					bitmask <<= bit;
+
 					/* Handle source of the attention */
 					qed_int_deassertion_aeu_bit(p_hwfn,
 								    p_aeu,
 								    aeu_en,
+								    bit_name,
 								    bitmask);
 				}
 
-- 
1.9.3
