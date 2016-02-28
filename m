From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 4/4] qed: Print additional HW attention info
Date: Sun, 28 Feb 2016 12:26:55 +0200
Message-ID: <1456655215-16345-5-git-send-email-Yuval.Mintz@qlogic.com>
References: <1456655215-16345-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:42611 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757356AbcB1K1N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2016 05:27:13 -0500
In-Reply-To: <1456655215-16345-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch utilizes the attention infrastructure to log additional
information that relates only to specific HW blocks.
For some of those HW blocks, it also stops automatically disabling the
attention generation as the attention is considered benign and thus
should only be logged; No fear of it flooding the system.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_int.c      | 526 ++++++++++++++++++++-----
 drivers/net/ethernet/qlogic/qed/qed_reg_addr.h |  58 +++
 2 files changed, 479 insertions(+), 105 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_int.c b/drivers/net/ethernet/qlogic/qed/qed_int.c
index c8bca77..58fe664 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_int.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_int.c
@@ -66,6 +66,9 @@ struct aeu_invert_reg_bit {
 #define ATTENTION_OFFSET_SHIFT          (12)
 	unsigned int flags;
 
+	/* Callback to call if attention will be triggered */
+	int (*cb)(struct qed_hwfn *p_hwfn);
+
 	enum block_id block_index;
 };
 
@@ -1285,170 +1288,463 @@ static struct attn_hw_block attn_blocks[] = {
 	{"misc_aeu", { {0, 0, NULL, NULL} } },
 	{"bar0_map", { {0, 0, NULL, NULL} } },};
 
+/* Specific HW attention callbacks */
+static int qed_mcp_attn_cb(struct qed_hwfn *p_hwfn)
+{
+	u32 tmp = qed_rd(p_hwfn, p_hwfn->p_dpc_ptt, MCP_REG_CPU_STATE);
+
+	/* This might occur on certain instances; Log it once then mask it */
+	DP_INFO(p_hwfn->cdev, "MCP_REG_CPU_STATE: %08x - Masking...\n",
+		tmp);
+	qed_wr(p_hwfn, p_hwfn->p_dpc_ptt, MCP_REG_CPU_EVENT_MASK,
+	       0xffffffff);
+
+	return 0;
+}
+
+#define QED_PSWHST_ATTENTION_INCORRECT_ACCESS		(0x1)
+#define ATTENTION_INCORRECT_ACCESS_WR_MASK		(0x1)
+#define ATTENTION_INCORRECT_ACCESS_WR_SHIFT		(0)
+#define ATTENTION_INCORRECT_ACCESS_CLIENT_MASK		(0xf)
+#define ATTENTION_INCORRECT_ACCESS_CLIENT_SHIFT		(1)
+#define ATTENTION_INCORRECT_ACCESS_VF_VALID_MASK	(0x1)
+#define ATTENTION_INCORRECT_ACCESS_VF_VALID_SHIFT	(5)
+#define ATTENTION_INCORRECT_ACCESS_VF_ID_MASK		(0xff)
+#define ATTENTION_INCORRECT_ACCESS_VF_ID_SHIFT		(6)
+#define ATTENTION_INCORRECT_ACCESS_PF_ID_MASK		(0xf)
+#define ATTENTION_INCORRECT_ACCESS_PF_ID_SHIFT		(14)
+#define ATTENTION_INCORRECT_ACCESS_BYTE_EN_MASK		(0xff)
+#define ATTENTION_INCORRECT_ACCESS_BYTE_EN_SHIFT	(18)
+static int qed_pswhst_attn_cb(struct qed_hwfn *p_hwfn)
+{
+	u32 tmp = qed_rd(p_hwfn, p_hwfn->p_dpc_ptt,
+			 PSWHST_REG_INCORRECT_ACCESS_VALID);
+
+	if (tmp & QED_PSWHST_ATTENTION_INCORRECT_ACCESS) {
+		u32 addr, data, length;
+
+		addr = qed_rd(p_hwfn, p_hwfn->p_dpc_ptt,
+			      PSWHST_REG_INCORRECT_ACCESS_ADDRESS);
+		data = qed_rd(p_hwfn, p_hwfn->p_dpc_ptt,
+			      PSWHST_REG_INCORRECT_ACCESS_DATA);
+		length = qed_rd(p_hwfn, p_hwfn->p_dpc_ptt,
+				PSWHST_REG_INCORRECT_ACCESS_LENGTH);
+
+		DP_INFO(p_hwfn->cdev,
+			"Incorrect access to %08x of length %08x - PF [%02x] VF [%04x] [valid %02x] client [%02x] write [%02x] Byte-Enable [%04x] [%08x]\n",
+			addr, length,
+			(u8) GET_FIELD(data, ATTENTION_INCORRECT_ACCESS_PF_ID),
+			(u8) GET_FIELD(data, ATTENTION_INCORRECT_ACCESS_VF_ID),
+			(u8) GET_FIELD(data,
+				       ATTENTION_INCORRECT_ACCESS_VF_VALID),
+			(u8) GET_FIELD(data,
+				       ATTENTION_INCORRECT_ACCESS_CLIENT),
+			(u8) GET_FIELD(data, ATTENTION_INCORRECT_ACCESS_WR),
+			(u8) GET_FIELD(data,
+				       ATTENTION_INCORRECT_ACCESS_BYTE_EN),
+			data);
+	}
+
+	return 0;
+}
+
+#define QED_GRC_ATTENTION_VALID_BIT	(1 << 0)
+#define QED_GRC_ATTENTION_ADDRESS_MASK	(0x7fffff)
+#define QED_GRC_ATTENTION_ADDRESS_SHIFT	(0)
+#define QED_GRC_ATTENTION_RDWR_BIT	(1 << 23)
+#define QED_GRC_ATTENTION_MASTER_MASK	(0xf)
+#define QED_GRC_ATTENTION_MASTER_SHIFT	(24)
+#define QED_GRC_ATTENTION_PF_MASK	(0xf)
+#define QED_GRC_ATTENTION_PF_SHIFT	(0)
+#define QED_GRC_ATTENTION_VF_MASK	(0xff)
+#define QED_GRC_ATTENTION_VF_SHIFT	(4)
+#define QED_GRC_ATTENTION_PRIV_MASK	(0x3)
+#define QED_GRC_ATTENTION_PRIV_SHIFT	(14)
+#define QED_GRC_ATTENTION_PRIV_VF	(0)
+static const char *attn_master_to_str(u8 master)
+{
+	switch (master) {
+	case 1: return "PXP";
+	case 2: return "MCP";
+	case 3: return "MSDM";
+	case 4: return "PSDM";
+	case 5: return "YSDM";
+	case 6: return "USDM";
+	case 7: return "TSDM";
+	case 8: return "XSDM";
+	case 9: return "DBU";
+	case 10: return "DMAE";
+	default:
+		return "Unkown";
+	}
+}
+
+static int qed_grc_attn_cb(struct qed_hwfn *p_hwfn)
+{
+	u32 tmp, tmp2;
+
+	/* We've already cleared the timeout interrupt register, so we learn
+	 * of interrupts via the validity register
+	 */
+	tmp = qed_rd(p_hwfn, p_hwfn->p_dpc_ptt,
+		     GRC_REG_TIMEOUT_ATTN_ACCESS_VALID);
+	if (!(tmp & QED_GRC_ATTENTION_VALID_BIT))
+		goto out;
+
+	/* Read the GRC timeout information */
+	tmp = qed_rd(p_hwfn, p_hwfn->p_dpc_ptt,
+		     GRC_REG_TIMEOUT_ATTN_ACCESS_DATA_0);
+	tmp2 = qed_rd(p_hwfn, p_hwfn->p_dpc_ptt,
+		      GRC_REG_TIMEOUT_ATTN_ACCESS_DATA_1);
+
+	DP_INFO(p_hwfn->cdev,
+		"GRC timeout [%08x:%08x] - %s Address [%08x] [Master %s] [PF: %02x %s %02x]\n",
+		tmp2, tmp,
+		(tmp & QED_GRC_ATTENTION_RDWR_BIT) ? "Write to" : "Read from",
+		GET_FIELD(tmp, QED_GRC_ATTENTION_ADDRESS) << 2,
+		attn_master_to_str(GET_FIELD(tmp, QED_GRC_ATTENTION_MASTER)),
+		GET_FIELD(tmp2, QED_GRC_ATTENTION_PF),
+		(GET_FIELD(tmp2, QED_GRC_ATTENTION_PRIV) ==
+		 QED_GRC_ATTENTION_PRIV_VF) ? "VF" : "(Ireelevant)",
+		GET_FIELD(tmp2, QED_GRC_ATTENTION_VF));
+
+out:
+	/* Regardles of anything else, clean the validity bit */
+	qed_wr(p_hwfn, p_hwfn->p_dpc_ptt,
+	       GRC_REG_TIMEOUT_ATTN_ACCESS_VALID, 0);
+	return 0;
+}
+
+#define PGLUE_ATTENTION_VALID			(1 << 29)
+#define PGLUE_ATTENTION_RD_VALID		(1 << 26)
+#define PGLUE_ATTENTION_DETAILS_PFID_MASK	(0xf)
+#define PGLUE_ATTENTION_DETAILS_PFID_SHIFT	(20)
+#define PGLUE_ATTENTION_DETAILS_VF_VALID_MASK	(0x1)
+#define PGLUE_ATTENTION_DETAILS_VF_VALID_SHIFT	(19)
+#define PGLUE_ATTENTION_DETAILS_VFID_MASK	(0xff)
+#define PGLUE_ATTENTION_DETAILS_VFID_SHIFT	(24)
+#define PGLUE_ATTENTION_DETAILS2_WAS_ERR_MASK	(0x1)
+#define PGLUE_ATTENTION_DETAILS2_WAS_ERR_SHIFT	(21)
+#define PGLUE_ATTENTION_DETAILS2_BME_MASK	(0x1)
+#define PGLUE_ATTENTION_DETAILS2_BME_SHIFT	(22)
+#define PGLUE_ATTENTION_DETAILS2_FID_EN_MASK	(0x1)
+#define PGLUE_ATTENTION_DETAILS2_FID_EN_SHIFT	(23)
+#define PGLUE_ATTENTION_ICPL_VALID		(1 << 23)
+#define PGLUE_ATTENTION_ZLR_VALID		(1 << 25)
+#define PGLUE_ATTENTION_ILT_VALID		(1 << 23)
+static int qed_pglub_rbc_attn_cb(struct qed_hwfn *p_hwfn)
+{
+	u32 tmp;
+
+	tmp = qed_rd(p_hwfn, p_hwfn->p_dpc_ptt,
+		     PGLUE_B_REG_TX_ERR_WR_DETAILS2);
+	if (tmp & PGLUE_ATTENTION_VALID) {
+		u32 addr_lo, addr_hi, details;
+
+		addr_lo = qed_rd(p_hwfn, p_hwfn->p_dpc_ptt,
+				 PGLUE_B_REG_TX_ERR_WR_ADD_31_0);
+		addr_hi = qed_rd(p_hwfn, p_hwfn->p_dpc_ptt,
+				 PGLUE_B_REG_TX_ERR_WR_ADD_63_32);
+		details = qed_rd(p_hwfn, p_hwfn->p_dpc_ptt,
+				 PGLUE_B_REG_TX_ERR_WR_DETAILS);
+
+		DP_INFO(p_hwfn,
+			"Illegal write by chip to [%08x:%08x] blocked.\n"
+			"Details: %08x [PFID %02x, VFID %02x, VF_VALID %02x]\n"
+			"Details2 %08x [Was_error %02x BME deassert %02x FID_enable deassert %02x]\n",
+			addr_hi, addr_lo, details,
+			(u8)GET_FIELD(details, PGLUE_ATTENTION_DETAILS_PFID),
+			(u8)GET_FIELD(details, PGLUE_ATTENTION_DETAILS_VFID),
+			GET_FIELD(details,
+				  PGLUE_ATTENTION_DETAILS_VF_VALID) ? 1 : 0,
+			tmp,
+			GET_FIELD(tmp,
+				  PGLUE_ATTENTION_DETAILS2_WAS_ERR) ? 1 : 0,
+			GET_FIELD(tmp,
+				  PGLUE_ATTENTION_DETAILS2_BME) ? 1 : 0,
+			GET_FIELD(tmp,
+				  PGLUE_ATTENTION_DETAILS2_FID_EN) ? 1 : 0);
+	}
+
+	tmp = qed_rd(p_hwfn, p_hwfn->p_dpc_ptt,
+		     PGLUE_B_REG_TX_ERR_RD_DETAILS2);
+	if (tmp & PGLUE_ATTENTION_RD_VALID) {
+		u32 addr_lo, addr_hi, details;
+
+		addr_lo = qed_rd(p_hwfn, p_hwfn->p_dpc_ptt,
+				 PGLUE_B_REG_TX_ERR_RD_ADD_31_0);
+		addr_hi = qed_rd(p_hwfn, p_hwfn->p_dpc_ptt,
+				 PGLUE_B_REG_TX_ERR_RD_ADD_63_32);
+		details = qed_rd(p_hwfn, p_hwfn->p_dpc_ptt,
+				 PGLUE_B_REG_TX_ERR_RD_DETAILS);
+
+		DP_INFO(p_hwfn,
+			"Illegal read by chip from [%08x:%08x] blocked.\n"
+			" Details: %08x [PFID %02x, VFID %02x, VF_VALID %02x]\n"
+			" Details2 %08x [Was_error %02x BME deassert %02x FID_enable deassert %02x]\n",
+			addr_hi, addr_lo, details,
+			(u8)GET_FIELD(details, PGLUE_ATTENTION_DETAILS_PFID),
+			(u8)GET_FIELD(details, PGLUE_ATTENTION_DETAILS_VFID),
+			GET_FIELD(details,
+				  PGLUE_ATTENTION_DETAILS_VF_VALID) ? 1 : 0,
+			tmp,
+			GET_FIELD(tmp, PGLUE_ATTENTION_DETAILS2_WAS_ERR) ? 1
+									 : 0,
+			GET_FIELD(tmp, PGLUE_ATTENTION_DETAILS2_BME) ? 1 : 0,
+			GET_FIELD(tmp, PGLUE_ATTENTION_DETAILS2_FID_EN) ? 1
+									: 0);
+	}
+
+	tmp = qed_rd(p_hwfn, p_hwfn->p_dpc_ptt,
+		     PGLUE_B_REG_TX_ERR_WR_DETAILS_ICPL);
+	if (tmp & PGLUE_ATTENTION_ICPL_VALID)
+		DP_INFO(p_hwfn, "ICPL eror - %08x\n", tmp);
+
+	tmp = qed_rd(p_hwfn, p_hwfn->p_dpc_ptt,
+		     PGLUE_B_REG_MASTER_ZLR_ERR_DETAILS);
+	if (tmp & PGLUE_ATTENTION_ZLR_VALID) {
+		u32 addr_hi, addr_lo;
+
+		addr_lo = qed_rd(p_hwfn, p_hwfn->p_dpc_ptt,
+				 PGLUE_B_REG_MASTER_ZLR_ERR_ADD_31_0);
+		addr_hi = qed_rd(p_hwfn, p_hwfn->p_dpc_ptt,
+				 PGLUE_B_REG_MASTER_ZLR_ERR_ADD_63_32);
+
+		DP_INFO(p_hwfn, "ZLR eror - %08x [Address %08x:%08x]\n",
+			tmp, addr_hi, addr_lo);
+	}
+
+	tmp = qed_rd(p_hwfn, p_hwfn->p_dpc_ptt,
+		     PGLUE_B_REG_VF_ILT_ERR_DETAILS2);
+	if (tmp & PGLUE_ATTENTION_ILT_VALID) {
+		u32 addr_hi, addr_lo, details;
+
+		addr_lo = qed_rd(p_hwfn, p_hwfn->p_dpc_ptt,
+				 PGLUE_B_REG_VF_ILT_ERR_ADD_31_0);
+		addr_hi = qed_rd(p_hwfn, p_hwfn->p_dpc_ptt,
+				 PGLUE_B_REG_VF_ILT_ERR_ADD_63_32);
+		details = qed_rd(p_hwfn, p_hwfn->p_dpc_ptt,
+				 PGLUE_B_REG_VF_ILT_ERR_DETAILS);
+
+		DP_INFO(p_hwfn,
+			"ILT error - Details %08x Details2 %08x [Address %08x:%08x]\n",
+			details, tmp, addr_hi, addr_lo);
+	}
+
+	/* Clear the indications */
+	qed_wr(p_hwfn, p_hwfn->p_dpc_ptt,
+	       PGLUE_B_REG_LATCHED_ERRORS_CLR, (1 << 2));
+
+	return 0;
+}
+
+#define QED_DORQ_ATTENTION_REASON_MASK	(0xfffff)
+#define QED_DORQ_ATTENTION_OPAQUE_MASK (0xffff)
+#define QED_DORQ_ATTENTION_SIZE_MASK	(0x7f)
+#define QED_DORQ_ATTENTION_SIZE_SHIFT	(16)
+static int qed_dorq_attn_cb(struct qed_hwfn *p_hwfn)
+{
+	u32 reason;
+
+	reason = qed_rd(p_hwfn, p_hwfn->p_dpc_ptt, DORQ_REG_DB_DROP_REASON) &
+			QED_DORQ_ATTENTION_REASON_MASK;
+	if (reason) {
+		u32 details = qed_rd(p_hwfn, p_hwfn->p_dpc_ptt,
+				     DORQ_REG_DB_DROP_DETAILS);
+
+		DP_INFO(p_hwfn->cdev,
+			"DORQ db_drop: adress 0x%08x Opaque FID 0x%04x Size [bytes] 0x%08x Reason: 0x%08x\n",
+			qed_rd(p_hwfn, p_hwfn->p_dpc_ptt,
+			       DORQ_REG_DB_DROP_DETAILS_ADDRESS),
+			(u16)(details & QED_DORQ_ATTENTION_OPAQUE_MASK),
+			GET_FIELD(details, QED_DORQ_ATTENTION_SIZE) * 4,
+			reason);
+	}
+
+	return -EINVAL;
+}
+
 /* Notice aeu_invert_reg must be defined in the same order of bits as HW;  */
 static struct aeu_invert_reg aeu_descs[NUM_ATTN_REGS] = {
 	{
 		{       /* After Invert 1 */
 			{"GPIO0 function%d",
-			 (32 << ATTENTION_LENGTH_SHIFT), MAX_BLOCK_ID},
+			 (32 << ATTENTION_LENGTH_SHIFT), NULL, MAX_BLOCK_ID},
 		}
 	},
 
 	{
 		{       /* After Invert 2 */
-			{"PGLUE config_space", ATTENTION_SINGLE, MAX_BLOCK_ID},
-			{"PGLUE misc_flr", ATTENTION_SINGLE, MAX_BLOCK_ID},
-			{"PGLUE B RBC", ATTENTION_PAR_INT, BLOCK_PGLUE_B},
-			{"PGLUE misc_mctp", ATTENTION_SINGLE, MAX_BLOCK_ID},
-			{"Flash event", ATTENTION_SINGLE, MAX_BLOCK_ID},
-			{"SMB event", ATTENTION_SINGLE, MAX_BLOCK_ID},
-			{"Main Power", ATTENTION_SINGLE, MAX_BLOCK_ID},
+			{"PGLUE config_space", ATTENTION_SINGLE,
+			 NULL, MAX_BLOCK_ID},
+			{"PGLUE misc_flr", ATTENTION_SINGLE,
+			 NULL, MAX_BLOCK_ID},
+			{"PGLUE B RBC", ATTENTION_PAR_INT,
+			 qed_pglub_rbc_attn_cb, BLOCK_PGLUE_B},
+			{"PGLUE misc_mctp", ATTENTION_SINGLE,
+			 NULL, MAX_BLOCK_ID},
+			{"Flash event", ATTENTION_SINGLE, NULL, MAX_BLOCK_ID},
+			{"SMB event", ATTENTION_SINGLE,	NULL, MAX_BLOCK_ID},
+			{"Main Power", ATTENTION_SINGLE, NULL, MAX_BLOCK_ID},
 			{"SW timers #%d", (8 << ATTENTION_LENGTH_SHIFT) |
 					  (1 << ATTENTION_OFFSET_SHIFT),
-			 MAX_BLOCK_ID},
+			 NULL, MAX_BLOCK_ID},
 			{"PCIE glue/PXP VPD %d",
-			 (16 << ATTENTION_LENGTH_SHIFT), BLOCK_PGLCS},
+			 (16 << ATTENTION_LENGTH_SHIFT), NULL, BLOCK_PGLCS},
 		}
 	},
 
 	{
 		{       /* After Invert 3 */
 			{"General Attention %d",
-			 (32 << ATTENTION_LENGTH_SHIFT), MAX_BLOCK_ID},
+			 (32 << ATTENTION_LENGTH_SHIFT), NULL, MAX_BLOCK_ID},
 		}
 	},
 
 	{
 		{       /* After Invert 4 */
 			{"General Attention 32", ATTENTION_SINGLE,
-			 MAX_BLOCK_ID},
+			 NULL, MAX_BLOCK_ID},
 			{"General Attention %d",
 			 (2 << ATTENTION_LENGTH_SHIFT) |
-			 (33 << ATTENTION_OFFSET_SHIFT), MAX_BLOCK_ID},
+			 (33 << ATTENTION_OFFSET_SHIFT), NULL, MAX_BLOCK_ID},
 			{"General Attention 35", ATTENTION_SINGLE,
-			 MAX_BLOCK_ID},
+			 NULL, MAX_BLOCK_ID},
 			{"CNIG port %d", (4 << ATTENTION_LENGTH_SHIFT),
-			 BLOCK_CNIG},
-			{"MCP CPU", ATTENTION_SINGLE, MAX_BLOCK_ID},
-			{"MCP Watchdog timer", ATTENTION_SINGLE, MAX_BLOCK_ID},
-			{"MCP M2P", ATTENTION_SINGLE, MAX_BLOCK_ID},
+			 NULL, BLOCK_CNIG},
+			{"MCP CPU", ATTENTION_SINGLE,
+			 qed_mcp_attn_cb, MAX_BLOCK_ID},
+			{"MCP Watchdog timer", ATTENTION_SINGLE,
+			 NULL, MAX_BLOCK_ID},
+			{"MCP M2P", ATTENTION_SINGLE, NULL, MAX_BLOCK_ID},
 			{"AVS stop status ready", ATTENTION_SINGLE,
-			 MAX_BLOCK_ID},
-			{"MSTAT", ATTENTION_PAR_INT, MAX_BLOCK_ID},
-			{"MSTAT per-path", ATTENTION_PAR_INT, MAX_BLOCK_ID},
+			 NULL, MAX_BLOCK_ID},
+			{"MSTAT", ATTENTION_PAR_INT, NULL, MAX_BLOCK_ID},
+			{"MSTAT per-path", ATTENTION_PAR_INT,
+			 NULL, MAX_BLOCK_ID},
 			{"Reserved %d", (6 << ATTENTION_LENGTH_SHIFT),
-			 MAX_BLOCK_ID},
-			{"NIG", ATTENTION_PAR_INT, BLOCK_NIG},
-			{"BMB/OPTE/MCP", ATTENTION_PAR_INT, BLOCK_BMB},
-			{"BTB",	ATTENTION_PAR_INT, BLOCK_BTB},
-			{"BRB",	ATTENTION_PAR_INT, BLOCK_BRB},
-			{"PRS",	ATTENTION_PAR_INT, BLOCK_PRS},
+			 NULL, MAX_BLOCK_ID},
+			{"NIG", ATTENTION_PAR_INT, NULL, BLOCK_NIG},
+			{"BMB/OPTE/MCP", ATTENTION_PAR_INT, NULL, BLOCK_BMB},
+			{"BTB",	ATTENTION_PAR_INT, NULL, BLOCK_BTB},
+			{"BRB",	ATTENTION_PAR_INT, NULL, BLOCK_BRB},
+			{"PRS",	ATTENTION_PAR_INT, NULL, BLOCK_PRS},
 		}
 	},
 
 	{
 		{       /* After Invert 5 */
-			{"SRC", ATTENTION_PAR_INT, BLOCK_SRC},
-			{"PB Client1", ATTENTION_PAR_INT, BLOCK_PBF_PB1},
-			{"PB Client2", ATTENTION_PAR_INT, BLOCK_PBF_PB2},
-			{"RPB", ATTENTION_PAR_INT, BLOCK_RPB},
-			{"PBF", ATTENTION_PAR_INT, BLOCK_PBF},
-			{"QM", ATTENTION_PAR_INT, BLOCK_QM},
-			{"TM", ATTENTION_PAR_INT, BLOCK_TM},
-			{"MCM",  ATTENTION_PAR_INT, BLOCK_MCM},
-			{"MSDM", ATTENTION_PAR_INT, BLOCK_MSDM},
-			{"MSEM", ATTENTION_PAR_INT, BLOCK_MSEM},
-			{"PCM", ATTENTION_PAR_INT, BLOCK_PCM},
-			{"PSDM", ATTENTION_PAR_INT, BLOCK_PSDM},
-			{"PSEM", ATTENTION_PAR_INT, BLOCK_PSEM},
-			{"TCM", ATTENTION_PAR_INT, BLOCK_TCM},
-			{"TSDM", ATTENTION_PAR_INT, BLOCK_TSDM},
-			{"TSEM", ATTENTION_PAR_INT, BLOCK_TSEM},
+			{"SRC", ATTENTION_PAR_INT, NULL, BLOCK_SRC},
+			{"PB Client1", ATTENTION_PAR_INT, NULL, BLOCK_PBF_PB1},
+			{"PB Client2", ATTENTION_PAR_INT, NULL, BLOCK_PBF_PB2},
+			{"RPB", ATTENTION_PAR_INT, NULL, BLOCK_RPB},
+			{"PBF", ATTENTION_PAR_INT, NULL, BLOCK_PBF},
+			{"QM", ATTENTION_PAR_INT, NULL, BLOCK_QM},
+			{"TM", ATTENTION_PAR_INT, NULL, BLOCK_TM},
+			{"MCM",  ATTENTION_PAR_INT, NULL, BLOCK_MCM},
+			{"MSDM", ATTENTION_PAR_INT, NULL, BLOCK_MSDM},
+			{"MSEM", ATTENTION_PAR_INT, NULL, BLOCK_MSEM},
+			{"PCM", ATTENTION_PAR_INT, NULL, BLOCK_PCM},
+			{"PSDM", ATTENTION_PAR_INT, NULL, BLOCK_PSDM},
+			{"PSEM", ATTENTION_PAR_INT, NULL, BLOCK_PSEM},
+			{"TCM", ATTENTION_PAR_INT, NULL, BLOCK_TCM},
+			{"TSDM", ATTENTION_PAR_INT, NULL, BLOCK_TSDM},
+			{"TSEM", ATTENTION_PAR_INT, NULL, BLOCK_TSEM},
 		}
 	},
 
 	{
 		{       /* After Invert 6 */
-			{"UCM", ATTENTION_PAR_INT, BLOCK_UCM},
-			{"USDM", ATTENTION_PAR_INT, BLOCK_USDM},
-			{"USEM", ATTENTION_PAR_INT, BLOCK_USEM},
-			{"XCM",	ATTENTION_PAR_INT, BLOCK_XCM},
-			{"XSDM", ATTENTION_PAR_INT, BLOCK_XSDM},
-			{"XSEM", ATTENTION_PAR_INT, BLOCK_XSEM},
-			{"YCM",	ATTENTION_PAR_INT, BLOCK_YCM},
-			{"YSDM", ATTENTION_PAR_INT, BLOCK_YSDM},
-			{"YSEM", ATTENTION_PAR_INT, BLOCK_YSEM},
-			{"XYLD", ATTENTION_PAR_INT, BLOCK_XYLD},
-			{"TMLD", ATTENTION_PAR_INT, BLOCK_TMLD},
-			{"MYLD", ATTENTION_PAR_INT, BLOCK_MULD},
-			{"YULD", ATTENTION_PAR_INT, BLOCK_YULD},
-			{"DORQ", ATTENTION_PAR_INT, BLOCK_DORQ},
-			{"DBG", ATTENTION_PAR_INT, BLOCK_DBG},
-			{"IPC",	ATTENTION_PAR_INT, BLOCK_IPC},
+			{"UCM", ATTENTION_PAR_INT, NULL, BLOCK_UCM},
+			{"USDM", ATTENTION_PAR_INT, NULL, BLOCK_USDM},
+			{"USEM", ATTENTION_PAR_INT, NULL, BLOCK_USEM},
+			{"XCM",	ATTENTION_PAR_INT, NULL, BLOCK_XCM},
+			{"XSDM", ATTENTION_PAR_INT, NULL, BLOCK_XSDM},
+			{"XSEM", ATTENTION_PAR_INT, NULL, BLOCK_XSEM},
+			{"YCM",	ATTENTION_PAR_INT, NULL, BLOCK_YCM},
+			{"YSDM", ATTENTION_PAR_INT, NULL, BLOCK_YSDM},
+			{"YSEM", ATTENTION_PAR_INT, NULL, BLOCK_YSEM},
+			{"XYLD", ATTENTION_PAR_INT, NULL, BLOCK_XYLD},
+			{"TMLD", ATTENTION_PAR_INT, NULL, BLOCK_TMLD},
+			{"MYLD", ATTENTION_PAR_INT, NULL, BLOCK_MULD},
+			{"YULD", ATTENTION_PAR_INT, NULL, BLOCK_YULD},
+			{"DORQ", ATTENTION_PAR_INT,
+			 qed_dorq_attn_cb, BLOCK_DORQ},
+			{"DBG", ATTENTION_PAR_INT, NULL, BLOCK_DBG},
+			{"IPC",	ATTENTION_PAR_INT, NULL, BLOCK_IPC},
 		}
 	},
 
 	{
 		{       /* After Invert 7 */
-			{"CCFC", ATTENTION_PAR_INT, BLOCK_CCFC},
-			{"CDU", ATTENTION_PAR_INT, BLOCK_CDU},
-			{"DMAE", ATTENTION_PAR_INT, BLOCK_DMAE},
-			{"IGU", ATTENTION_PAR_INT, BLOCK_IGU},
-			{"ATC", ATTENTION_PAR_INT, MAX_BLOCK_ID},
-			{"CAU", ATTENTION_PAR_INT, BLOCK_CAU},
-			{"PTU", ATTENTION_PAR_INT, BLOCK_PTU},
-			{"PRM", ATTENTION_PAR_INT, BLOCK_PRM},
-			{"TCFC", ATTENTION_PAR_INT, BLOCK_TCFC},
-			{"RDIF", ATTENTION_PAR_INT, BLOCK_RDIF},
-			{"TDIF", ATTENTION_PAR_INT, BLOCK_TDIF},
-			{"RSS", ATTENTION_PAR_INT, BLOCK_RSS},
-			{"MISC", ATTENTION_PAR_INT, BLOCK_MISC},
-			{"MISCS", ATTENTION_PAR_INT, BLOCK_MISCS},
-			{"PCIE", ATTENTION_PAR, BLOCK_PCIE},
-			{"Vaux PCI core", ATTENTION_SINGLE, BLOCK_PGLCS},
-			{"PSWRQ", ATTENTION_PAR_INT, BLOCK_PSWRQ},
+			{"CCFC", ATTENTION_PAR_INT, NULL, BLOCK_CCFC},
+			{"CDU", ATTENTION_PAR_INT, NULL, BLOCK_CDU},
+			{"DMAE", ATTENTION_PAR_INT, NULL, BLOCK_DMAE},
+			{"IGU", ATTENTION_PAR_INT, NULL, BLOCK_IGU},
+			{"ATC", ATTENTION_PAR_INT, NULL, MAX_BLOCK_ID},
+			{"CAU", ATTENTION_PAR_INT, NULL, BLOCK_CAU},
+			{"PTU", ATTENTION_PAR_INT, NULL, BLOCK_PTU},
+			{"PRM", ATTENTION_PAR_INT, NULL, BLOCK_PRM},
+			{"TCFC", ATTENTION_PAR_INT, NULL, BLOCK_TCFC},
+			{"RDIF", ATTENTION_PAR_INT, NULL, BLOCK_RDIF},
+			{"TDIF", ATTENTION_PAR_INT, NULL, BLOCK_TDIF},
+			{"RSS", ATTENTION_PAR_INT, NULL, BLOCK_RSS},
+			{"MISC", ATTENTION_PAR_INT, NULL, BLOCK_MISC},
+			{"MISCS", ATTENTION_PAR_INT, NULL, BLOCK_MISCS},
+			{"PCIE", ATTENTION_PAR, NULL, BLOCK_PCIE},
+			{"Vaux PCI core", ATTENTION_SINGLE, NULL, BLOCK_PGLCS},
+			{"PSWRQ", ATTENTION_PAR_INT, NULL, BLOCK_PSWRQ},
 		}
 	},
 
 	{
 		{       /* After Invert 8 */
-			{"PSWRQ (pci_clk)", ATTENTION_PAR_INT, BLOCK_PSWRQ2},
-			{"PSWWR", ATTENTION_PAR_INT, BLOCK_PSWWR},
-			{"PSWWR (pci_clk)", ATTENTION_PAR_INT, BLOCK_PSWWR2},
-			{"PSWRD", ATTENTION_PAR_INT, BLOCK_PSWRD},
-			{"PSWRD (pci_clk)", ATTENTION_PAR_INT, BLOCK_PSWRD2},
-			{"PSWHST", ATTENTION_PAR_INT, BLOCK_PSWHST},
-			{"PSWHST (pci_clk)", ATTENTION_PAR_INT, BLOCK_PSWHST2},
-			{"GRC",	ATTENTION_PAR_INT, BLOCK_GRC},
-			{"CPMU", ATTENTION_PAR_INT, BLOCK_CPMU},
-			{"NCSI", ATTENTION_PAR_INT, BLOCK_NCSI},
-			{"MSEM PRAM", ATTENTION_PAR, MAX_BLOCK_ID},
-			{"PSEM PRAM", ATTENTION_PAR, MAX_BLOCK_ID},
-			{"TSEM PRAM", ATTENTION_PAR, MAX_BLOCK_ID},
-			{"USEM PRAM", ATTENTION_PAR, MAX_BLOCK_ID},
-			{"XSEM PRAM", ATTENTION_PAR, MAX_BLOCK_ID},
-			{"YSEM PRAM", ATTENTION_PAR, MAX_BLOCK_ID},
-			{"pxp_misc_mps", ATTENTION_PAR, BLOCK_PGLCS},
+			{"PSWRQ (pci_clk)", ATTENTION_PAR_INT,
+			 NULL, BLOCK_PSWRQ2},
+			{"PSWWR", ATTENTION_PAR_INT, NULL, BLOCK_PSWWR},
+			{"PSWWR (pci_clk)", ATTENTION_PAR_INT,
+			 NULL, BLOCK_PSWWR2},
+			{"PSWRD", ATTENTION_PAR_INT, NULL, BLOCK_PSWRD},
+			{"PSWRD (pci_clk)", ATTENTION_PAR_INT,
+			 NULL, BLOCK_PSWRD2},
+			{"PSWHST", ATTENTION_PAR_INT,
+			 qed_pswhst_attn_cb, BLOCK_PSWHST},
+			{"PSWHST (pci_clk)", ATTENTION_PAR_INT,
+			 NULL, BLOCK_PSWHST2},
+			{"GRC",	ATTENTION_PAR_INT,
+			 qed_grc_attn_cb, BLOCK_GRC},
+			{"CPMU", ATTENTION_PAR_INT, NULL, BLOCK_CPMU},
+			{"NCSI", ATTENTION_PAR_INT, NULL, BLOCK_NCSI},
+			{"MSEM PRAM", ATTENTION_PAR, NULL, MAX_BLOCK_ID},
+			{"PSEM PRAM", ATTENTION_PAR, NULL, MAX_BLOCK_ID},
+			{"TSEM PRAM", ATTENTION_PAR, NULL, MAX_BLOCK_ID},
+			{"USEM PRAM", ATTENTION_PAR, NULL, MAX_BLOCK_ID},
+			{"XSEM PRAM", ATTENTION_PAR, NULL, MAX_BLOCK_ID},
+			{"YSEM PRAM", ATTENTION_PAR, NULL, MAX_BLOCK_ID},
+			{"pxp_misc_mps", ATTENTION_PAR, NULL, BLOCK_PGLCS},
 			{"PCIE glue/PXP Exp. ROM", ATTENTION_SINGLE,
-			 BLOCK_PGLCS},
-			{"PERST_B assertion", ATTENTION_SINGLE, MAX_BLOCK_ID},
+			 NULL, BLOCK_PGLCS},
+			{"PERST_B assertion", ATTENTION_SINGLE,
+			 NULL, MAX_BLOCK_ID},
 			{"PERST_B deassertion", ATTENTION_SINGLE,
-			 MAX_BLOCK_ID},
+			 NULL, MAX_BLOCK_ID},
 			{"Reserved %d", (2 << ATTENTION_LENGTH_SHIFT),
-			 MAX_BLOCK_ID},
+			 NULL, MAX_BLOCK_ID},
 		}
 	},
 
 	{
 		{       /* After Invert 9 */
-			{"MCP Latched memory", ATTENTION_PAR, MAX_BLOCK_ID},
+			{"MCP Latched memory", ATTENTION_PAR,
+			 NULL, MAX_BLOCK_ID},
 			{"MCP Latched scratchpad cache", ATTENTION_SINGLE,
-			 MAX_BLOCK_ID},
-			{"MCP Latched ump_tx", ATTENTION_PAR, MAX_BLOCK_ID},
+			 NULL, MAX_BLOCK_ID},
+			{"MCP Latched ump_tx", ATTENTION_PAR,
+			 NULL, MAX_BLOCK_ID},
 			{"MCP Latched scratchpad", ATTENTION_PAR,
-			 MAX_BLOCK_ID},
+			 NULL, MAX_BLOCK_ID},
 			{"Reserved %d", (28 << ATTENTION_LENGTH_SHIFT),
-			 MAX_BLOCK_ID},
+			 NULL, MAX_BLOCK_ID},
 		}
 	},
 };
@@ -1585,14 +1881,22 @@ qed_int_deassertion_aeu_bit(struct qed_hwfn *p_hwfn,
 			    u32 bitmask)
 {
 	int rc = -EINVAL;
-	u32 val, mask = ~bitmask;
+	u32 val;
 
 	DP_INFO(p_hwfn, "Deasserted attention `%s'[%08x]\n",
 		p_aeu->bit_name, bitmask);
 
+	/* Call callback before clearing the interrupt status */
+	if (p_aeu->cb) {
+		DP_INFO(p_hwfn, "`%s (attention)': Calling Callback function\n",
+			p_aeu->bit_name);
+		rc = p_aeu->cb(p_hwfn);
+	}
+
 	/* Handle HW block interrupt registers */
 	if (p_aeu->block_index != MAX_BLOCK_ID) {
 		struct attn_hw_block *p_block;
+		u32 mask;
 		int i;
 
 		p_block = &attn_blocks[p_aeu->block_index];
@@ -1603,7 +1907,14 @@ qed_int_deassertion_aeu_bit(struct qed_hwfn *p_hwfn,
 			u32 sts_addr;
 
 			p_reg_desc = p_block->chip_regs[0].int_regs[i];
-			sts_addr = p_reg_desc->sts_addr;
+
+			/* In case of fatal attention, don't clear the status
+			 * so it would appear in following idle check.
+			 */
+			if (rc == 0)
+				sts_addr = p_reg_desc->sts_clr_addr;
+			else
+				sts_addr = p_reg_desc->sts_addr;
 
 			val = qed_rd(p_hwfn, p_hwfn->p_dpc_ptt, sts_addr);
 			mask = qed_rd(p_hwfn, p_hwfn->p_dpc_ptt,
@@ -1615,12 +1926,17 @@ qed_int_deassertion_aeu_bit(struct qed_hwfn *p_hwfn,
 		}
 	}
 
+	/* If the attention is benign, no need to prevent it */
+	if (!rc)
+		goto out;
+
 	/* Prevent this Attention from being asserted in the future */
 	val = qed_rd(p_hwfn, p_hwfn->p_dpc_ptt, aeu_en_reg);
-	qed_wr(p_hwfn, p_hwfn->p_dpc_ptt, aeu_en_reg, (val & mask));
+	qed_wr(p_hwfn, p_hwfn->p_dpc_ptt, aeu_en_reg, (val & ~bitmask));
 	DP_INFO(p_hwfn, "`%s' - Disabled future attentions\n",
 		p_aeu->bit_name);
 
+out:
 	return rc;
 }
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h b/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
index 2286e75..c15b162 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
@@ -127,8 +127,20 @@
 	0x00c000UL
 #define  DORQ_REG_IFEN \
 	0x100040UL
+#define DORQ_REG_DB_DROP_REASON \
+	0x100a2cUL
+#define DORQ_REG_DB_DROP_DETAILS \
+	0x100a24UL
+#define DORQ_REG_DB_DROP_DETAILS_ADDRESS \
+	0x100a1cUL
 #define  GRC_REG_TIMEOUT_EN \
 	0x050404UL
+#define GRC_REG_TIMEOUT_ATTN_ACCESS_VALID \
+	0x050054UL
+#define GRC_REG_TIMEOUT_ATTN_ACCESS_DATA_0 \
+	0x05004cUL
+#define GRC_REG_TIMEOUT_ATTN_ACCESS_DATA_1 \
+	0x050050UL
 #define  IGU_REG_BLOCK_CONFIGURATION \
 	0x180040UL
 #define  MCM_REG_INIT \
@@ -155,6 +167,40 @@
 	0x1100000UL
 #define  PGLUE_B_REG_ADMIN_PER_PF_REGION	\
 	0x2a9000UL
+#define PGLUE_B_REG_TX_ERR_WR_DETAILS2 \
+	0x2aa150UL
+#define PGLUE_B_REG_TX_ERR_WR_ADD_31_0 \
+	0x2aa144UL
+#define PGLUE_B_REG_TX_ERR_WR_ADD_63_32 \
+	0x2aa148UL
+#define PGLUE_B_REG_TX_ERR_WR_DETAILS \
+	0x2aa14cUL
+#define PGLUE_B_REG_TX_ERR_RD_ADD_31_0 \
+	0x2aa154UL
+#define PGLUE_B_REG_TX_ERR_RD_ADD_63_32 \
+	0x2aa158UL
+#define PGLUE_B_REG_TX_ERR_RD_DETAILS \
+	0x2aa15cUL
+#define PGLUE_B_REG_TX_ERR_RD_DETAILS2 \
+	0x2aa160UL
+#define PGLUE_B_REG_TX_ERR_WR_DETAILS_ICPL \
+	0x2aa164UL
+#define PGLUE_B_REG_MASTER_ZLR_ERR_DETAILS \
+	0x2aa54cUL
+#define PGLUE_B_REG_MASTER_ZLR_ERR_ADD_31_0 \
+	0x2aa544UL
+#define PGLUE_B_REG_MASTER_ZLR_ERR_ADD_63_32 \
+	0x2aa548UL
+#define PGLUE_B_REG_VF_ILT_ERR_ADD_31_0 \
+	0x2aae74UL
+#define PGLUE_B_REG_VF_ILT_ERR_ADD_63_32 \
+	0x2aae78UL
+#define PGLUE_B_REG_VF_ILT_ERR_DETAILS \
+	0x2aae7cUL
+#define PGLUE_B_REG_VF_ILT_ERR_DETAILS2 \
+	0x2aae80UL
+#define PGLUE_B_REG_LATCHED_ERRORS_CLR \
+	0x2aa3bcUL
 #define  PRM_REG_DISABLE_PRM \
 	0x230000UL
 #define  PRS_REG_SOFT_RST \
@@ -171,6 +217,14 @@
 	0x2a0040UL
 #define  PSWHST2_REG_DBGSYN_ALMOST_FULL_THR \
 	0x29e050UL
+#define PSWHST_REG_INCORRECT_ACCESS_VALID \
+	0x2a0070UL
+#define PSWHST_REG_INCORRECT_ACCESS_ADDRESS \
+	0x2a0074UL
+#define PSWHST_REG_INCORRECT_ACCESS_DATA \
+	0x2a0068UL
+#define PSWHST_REG_INCORRECT_ACCESS_LENGTH \
+	0x2a006cUL
 #define  PSWRD_REG_DBG_SELECT \
 	0x29c040UL
 #define  PSWRD2_REG_CONF11 \
@@ -365,6 +419,10 @@
 		0x7 << 0)
 #define  MCP_REG_NVM_CFG4_FLASH_SIZE_SHIFT \
 	0
+#define MCP_REG_CPU_STATE \
+	0xe05004UL
+#define MCP_REG_CPU_EVENT_MASK \
+	0xe05008UL
 #define PGLUE_B_REG_PF_BAR0_SIZE \
 	0x2aae60UL
 #define PGLUE_B_REG_PF_BAR1_SIZE \
-- 
1.9.3
