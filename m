From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 2/4] qed: Add support for HW attentions
Date: Sun, 28 Feb 2016 12:26:53 +0200
Message-ID: <1456655215-16345-3-git-send-email-Yuval.Mintz@qlogic.com>
References: <1456655215-16345-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:7378 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757351AbcB1K1G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2016 05:27:06 -0500
In-Reply-To: <1456655215-16345-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

HW is capable of generating attentnions for a multitude of reasons,
but current driver is enabling attention generation only for management
firmware [required for link notifications].

This patch enables almost all of the possible reasons for HW attentions,
logging the HW block generating the attention and preventing further
attentions from that source [to prevent possible attention flood].
It also lays the infrastructure for additional exploration of the various
attentions.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_int.c      | 395 ++++++++++++++++++++++---
 drivers/net/ethernet/qlogic/qed/qed_reg_addr.h |   2 +
 2 files changed, 357 insertions(+), 40 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_int.c b/drivers/net/ethernet/qlogic/qed/qed_int.c
index 7fd1be6..c914ac5 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_int.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_int.c
@@ -42,21 +42,210 @@ struct qed_sb_sp_info {
 #define SB_ATTN_ALIGNED_SIZE(p_hwfn) \
 	ALIGNED_TYPE_SIZE(struct atten_status_block, p_hwfn)
 
-#define ATTN_STATE_BITS (0xfff)
+struct aeu_invert_reg_bit {
+	char bit_name[30];
+
+#define ATTENTION_PARITY                (1 << 0)
+
+#define ATTENTION_LENGTH_MASK           (0x00000ff0)
+#define ATTENTION_LENGTH_SHIFT          (4)
+#define ATTENTION_LENGTH(flags)         (((flags) & ATTENTION_LENGTH_MASK) >> \
+					 ATTENTION_LENGTH_SHIFT)
+#define ATTENTION_SINGLE                (1 << ATTENTION_LENGTH_SHIFT)
+#define ATTENTION_PAR                   (ATTENTION_SINGLE | ATTENTION_PARITY)
+#define ATTENTION_PAR_INT               ((2 << ATTENTION_LENGTH_SHIFT) | \
+					 ATTENTION_PARITY)
+
+/* Multiple bits start with this offset */
+#define ATTENTION_OFFSET_MASK           (0x000ff000)
+#define ATTENTION_OFFSET_SHIFT          (12)
+	unsigned int flags;
+};
+
+struct aeu_invert_reg {
+	struct aeu_invert_reg_bit bits[32];
+};
+
+#define MAX_ATTN_GRPS           (8)
+#define NUM_ATTN_REGS           (9)
+
+/* Notice aeu_invert_reg must be defined in the same order of bits as HW;  */
+static struct aeu_invert_reg aeu_descs[NUM_ATTN_REGS] = {
+	{
+		{       /* After Invert 1 */
+			{"GPIO0 function%d",
+			 (32 << ATTENTION_LENGTH_SHIFT)},
+		}
+	},
+
+	{
+		{       /* After Invert 2 */
+			{"PGLUE config_space", ATTENTION_SINGLE},
+			{"PGLUE misc_flr", ATTENTION_SINGLE},
+			{"PGLUE B RBC", ATTENTION_PAR_INT},
+			{"PGLUE misc_mctp", ATTENTION_SINGLE},
+			{"Flash event", ATTENTION_SINGLE},
+			{"SMB event", ATTENTION_SINGLE},
+			{"Main Power", ATTENTION_SINGLE},
+			{"SW timers #%d", (8 << ATTENTION_LENGTH_SHIFT) |
+					  (1 << ATTENTION_OFFSET_SHIFT)},
+			{"PCIE glue/PXP VPD %d",
+			 (16 << ATTENTION_LENGTH_SHIFT)},
+		}
+	},
+
+	{
+		{       /* After Invert 3 */
+			{"General Attention %d",
+			 (32 << ATTENTION_LENGTH_SHIFT)},
+		}
+	},
+
+	{
+		{       /* After Invert 4 */
+			{"General Attention 32", ATTENTION_SINGLE},
+			{"General Attention %d",
+			 (2 << ATTENTION_LENGTH_SHIFT) |
+			 (33 << ATTENTION_OFFSET_SHIFT)},
+			{"General Attention 35", ATTENTION_SINGLE},
+			{"CNIG port %d", (4 << ATTENTION_LENGTH_SHIFT)},
+			{"MCP CPU", ATTENTION_SINGLE},
+			{"MCP Watchdog timer", ATTENTION_SINGLE},
+			{"MCP M2P", ATTENTION_SINGLE},
+			{"AVS stop status ready", ATTENTION_SINGLE},
+			{"MSTAT", ATTENTION_PAR_INT},
+			{"MSTAT per-path", ATTENTION_PAR_INT},
+			{"Reserved %d", (6 << ATTENTION_LENGTH_SHIFT)},
+			{"NIG", ATTENTION_PAR_INT},
+			{"BMB/OPTE/MCP", ATTENTION_PAR_INT},
+			{"BTB",	ATTENTION_PAR_INT},
+			{"BRB",	ATTENTION_PAR_INT},
+			{"PRS",	ATTENTION_PAR_INT},
+		}
+	},
+
+	{
+		{       /* After Invert 5 */
+			{"SRC", ATTENTION_PAR_INT},
+			{"PB Client1", ATTENTION_PAR_INT},
+			{"PB Client2", ATTENTION_PAR_INT},
+			{"RPB", ATTENTION_PAR_INT},
+			{"PBF", ATTENTION_PAR_INT},
+			{"QM", ATTENTION_PAR_INT},
+			{"TM", ATTENTION_PAR_INT},
+			{"MCM",  ATTENTION_PAR_INT},
+			{"MSDM", ATTENTION_PAR_INT},
+			{"MSEM", ATTENTION_PAR_INT},
+			{"PCM", ATTENTION_PAR_INT},
+			{"PSDM", ATTENTION_PAR_INT},
+			{"PSEM", ATTENTION_PAR_INT},
+			{"TCM", ATTENTION_PAR_INT},
+			{"TSDM", ATTENTION_PAR_INT},
+			{"TSEM", ATTENTION_PAR_INT},
+		}
+	},
+
+	{
+		{       /* After Invert 6 */
+			{"UCM", ATTENTION_PAR_INT},
+			{"USDM", ATTENTION_PAR_INT},
+			{"USEM", ATTENTION_PAR_INT},
+			{"XCM",	ATTENTION_PAR_INT},
+			{"XSDM", ATTENTION_PAR_INT},
+			{"XSEM", ATTENTION_PAR_INT},
+			{"YCM",	ATTENTION_PAR_INT},
+			{"YSDM", ATTENTION_PAR_INT},
+			{"YSEM", ATTENTION_PAR_INT},
+			{"XYLD", ATTENTION_PAR_INT},
+			{"TMLD", ATTENTION_PAR_INT},
+			{"MYLD", ATTENTION_PAR_INT},
+			{"YULD", ATTENTION_PAR_INT},
+			{"DORQ", ATTENTION_PAR_INT},
+			{"DBG", ATTENTION_PAR_INT},
+			{"IPC",	ATTENTION_PAR_INT},
+		}
+	},
+
+	{
+		{       /* After Invert 7 */
+			{"CCFC", ATTENTION_PAR_INT},
+			{"CDU", ATTENTION_PAR_INT},
+			{"DMAE", ATTENTION_PAR_INT},
+			{"IGU", ATTENTION_PAR_INT},
+			{"ATC", ATTENTION_PAR_INT},
+			{"CAU", ATTENTION_PAR_INT},
+			{"PTU", ATTENTION_PAR_INT},
+			{"PRM", ATTENTION_PAR_INT},
+			{"TCFC", ATTENTION_PAR_INT},
+			{"RDIF", ATTENTION_PAR_INT},
+			{"TDIF", ATTENTION_PAR_INT},
+			{"RSS", ATTENTION_PAR_INT},
+			{"MISC", ATTENTION_PAR_INT},
+			{"MISCS", ATTENTION_PAR_INT},
+			{"PCIE", ATTENTION_PAR},
+			{"Vaux PCI core", ATTENTION_SINGLE},
+			{"PSWRQ", ATTENTION_PAR_INT},
+		}
+	},
+
+	{
+		{       /* After Invert 8 */
+			{"PSWRQ (pci_clk)", ATTENTION_PAR_INT},
+			{"PSWWR", ATTENTION_PAR_INT},
+			{"PSWWR (pci_clk)", ATTENTION_PAR_INT},
+			{"PSWRD", ATTENTION_PAR_INT},
+			{"PSWRD (pci_clk)", ATTENTION_PAR_INT},
+			{"PSWHST", ATTENTION_PAR_INT},
+			{"PSWHST (pci_clk)", ATTENTION_PAR_INT},
+			{"GRC",	ATTENTION_PAR_INT},
+			{"CPMU", ATTENTION_PAR_INT},
+			{"NCSI", ATTENTION_PAR_INT},
+			{"MSEM PRAM", ATTENTION_PAR},
+			{"PSEM PRAM", ATTENTION_PAR},
+			{"TSEM PRAM", ATTENTION_PAR},
+			{"USEM PRAM", ATTENTION_PAR},
+			{"XSEM PRAM", ATTENTION_PAR},
+			{"YSEM PRAM", ATTENTION_PAR},
+			{"pxp_misc_mps", ATTENTION_PAR},
+			{"PCIE glue/PXP Exp. ROM", ATTENTION_SINGLE},
+			{"PERST_B assertion", ATTENTION_SINGLE},
+			{"PERST_B deassertion", ATTENTION_SINGLE},
+			{"Reserved %d", (2 << ATTENTION_LENGTH_SHIFT)},
+		}
+	},
+
+	{
+		{       /* After Invert 9 */
+			{"MCP Latched memory", ATTENTION_PAR},
+			{"MCP Latched scratchpad cache", ATTENTION_SINGLE},
+			{"MCP Latched ump_tx", ATTENTION_PAR},
+			{"MCP Latched scratchpad", ATTENTION_PAR},
+			{"Reserved %d", (28 << ATTENTION_LENGTH_SHIFT)},
+		}
+	},
+};
+
+#define ATTN_STATE_BITS         (0xfff)
 #define ATTN_BITS_MASKABLE      (0x3ff)
 struct qed_sb_attn_info {
 	/* Virtual & Physical address of the SB */
 	struct atten_status_block       *sb_attn;
-	dma_addr_t		      sb_phys;
+	dma_addr_t			sb_phys;
 
 	/* Last seen running index */
-	u16			     index;
+	u16				index;
+
+	/* A mask of the AEU bits resulting in a parity error */
+	u32				parity_mask[NUM_ATTN_REGS];
+
+	/* A pointer to the attention description structure */
+	struct aeu_invert_reg		*p_aeu_desc;
 
 	/* Previously asserted attentions, which are still unasserted */
-	u16			     known_attn;
+	u16				known_attn;
 
 	/* Cleanup address for the link's general hw attention */
-	u32			     mfw_attn_addr;
+	u32				mfw_attn_addr;
 };
 
 static inline u16 qed_attn_update_idx(struct qed_hwfn *p_hwfn,
@@ -128,6 +317,39 @@ static int qed_int_assertion(struct qed_hwfn *p_hwfn,
 }
 
 /**
+ * @brief qed_int_deassertion_aeu_bit - handles the effects of a single
+ * cause of the attention
+ *
+ * @param p_hwfn
+ * @param p_aeu - descriptor of an AEU bit which caused the attention
+ * @param aeu_en_reg - register offset of the AEU enable reg. which configured
+ *  this bit to this group.
+ * @param bit_index - index of this bit in the aeu_en_reg
+ *
+ * @return int
+ */
+static int
+qed_int_deassertion_aeu_bit(struct qed_hwfn *p_hwfn,
+			    struct aeu_invert_reg_bit *p_aeu,
+			    u32 aeu_en_reg,
+			    u32 bitmask)
+{
+	int rc = -EINVAL;
+	u32 val, mask = ~bitmask;
+
+	DP_INFO(p_hwfn, "Deasserted attention `%s'[%08x]\n",
+		p_aeu->bit_name, bitmask);
+
+	/* Prevent this Attention from being asserted in the future */
+	val = qed_rd(p_hwfn, p_hwfn->p_dpc_ptt, aeu_en_reg);
+	qed_wr(p_hwfn, p_hwfn->p_dpc_ptt, aeu_en_reg, (val & mask));
+	DP_INFO(p_hwfn, "`%s' - Disabled future attentions\n",
+		p_aeu->bit_name);
+
+	return rc;
+}
+
+/**
  * @brief - handles deassertion of previously asserted attentions.
  *
  * @param p_hwfn
@@ -139,17 +361,110 @@ static int qed_int_deassertion(struct qed_hwfn  *p_hwfn,
 			       u16 deasserted_bits)
 {
 	struct qed_sb_attn_info *sb_attn_sw = p_hwfn->p_sb_attn;
-	u32 aeu_mask;
+	u32 aeu_inv_arr[NUM_ATTN_REGS], aeu_mask;
+	u8 i, j, k, bit_idx;
+	int rc = 0;
+
+	/* Read the attention registers in the AEU */
+	for (i = 0; i < NUM_ATTN_REGS; i++) {
+		aeu_inv_arr[i] = qed_rd(p_hwfn, p_hwfn->p_dpc_ptt,
+					MISC_REG_AEU_AFTER_INVERT_1_IGU +
+					i * 0x4);
+		DP_VERBOSE(p_hwfn, NETIF_MSG_INTR,
+			   "Deasserted bits [%d]: %08x\n",
+			   i, aeu_inv_arr[i]);
+	}
+
+	/* Find parity attentions first */
+	for (i = 0; i < NUM_ATTN_REGS; i++) {
+		struct aeu_invert_reg *p_aeu = &sb_attn_sw->p_aeu_desc[i];
+		u32 en = qed_rd(p_hwfn, p_hwfn->p_dpc_ptt,
+				MISC_REG_AEU_ENABLE1_IGU_OUT_0 +
+				i * sizeof(u32));
+		u32 parities;
+
+		/* Skip register in which no parity bit is currently set */
+		parities = sb_attn_sw->parity_mask[i] & aeu_inv_arr[i] & en;
+		if (!parities)
+			continue;
 
-	if (deasserted_bits != 0x100)
-		DP_ERR(p_hwfn, "Unexpected - non-link deassertion\n");
+		for (j = 0, bit_idx = 0; bit_idx < 32; j++) {
+			struct aeu_invert_reg_bit *p_bit = &p_aeu->bits[j];
+
+			if ((p_bit->flags & ATTENTION_PARITY) &&
+			    !!(parities & (1 << bit_idx))) {
+				DP_INFO(p_hwfn,
+					"%s[%d] parity attention is set\n",
+					p_bit->bit_name, bit_idx);
+			}
+
+			bit_idx += ATTENTION_LENGTH(p_bit->flags);
+		}
+	}
+
+	/* Find non-parity cause for attention and act */
+	for (k = 0; k < MAX_ATTN_GRPS; k++) {
+		struct aeu_invert_reg_bit *p_aeu;
+
+		/* Handle only groups whose attention is currently deasserted */
+		if (!(deasserted_bits & (1 << k)))
+			continue;
+
+		for (i = 0; i < NUM_ATTN_REGS; i++) {
+			u32 aeu_en = MISC_REG_AEU_ENABLE1_IGU_OUT_0 +
+				     i * sizeof(u32) +
+				     k * sizeof(u32) * NUM_ATTN_REGS;
+			u32 en, bits;
+
+			en = qed_rd(p_hwfn, p_hwfn->p_dpc_ptt, aeu_en);
+			bits = aeu_inv_arr[i] & en;
+
+			/* Skip if no bit from this group is currently set */
+			if (!bits)
+				continue;
+
+			/* Find all set bits from current register which belong
+			 * to current group, making them responsible for the
+			 * previous assertion.
+			 */
+			for (j = 0, bit_idx = 0; bit_idx < 32; j++) {
+				u8 bit, bit_len;
+				u32 bitmask;
+
+				p_aeu = &sb_attn_sw->p_aeu_desc[i].bits[j];
+
+				/* No need to handle parity-only bits */
+				if (p_aeu->flags == ATTENTION_PAR)
+					continue;
+
+				bit = bit_idx;
+				bit_len = ATTENTION_LENGTH(p_aeu->flags);
+				if (p_aeu->flags & ATTENTION_PAR_INT) {
+					/* Skip Parity */
+					bit++;
+					bit_len--;
+				}
+
+				bitmask = bits & (((1 << bit_len) - 1) << bit);
+				if (bitmask) {
+					/* Handle source of the attention */
+					qed_int_deassertion_aeu_bit(p_hwfn,
+								    p_aeu,
+								    aeu_en,
+								    bitmask);
+				}
+
+				bit_idx += ATTENTION_LENGTH(p_aeu->flags);
+			}
+		}
+	}
 
 	/* Clear IGU indication for the deasserted bits */
 	DIRECT_REG_WR((u8 __iomem *)p_hwfn->regview +
-		      GTT_BAR0_MAP_REG_IGU_CMD +
-		      ((IGU_CMD_ATTN_BIT_CLR_UPPER -
-			IGU_CMD_INT_ACK_BASE) << 3),
-		      ~((u32)deasserted_bits));
+				    GTT_BAR0_MAP_REG_IGU_CMD +
+				    ((IGU_CMD_ATTN_BIT_CLR_UPPER -
+				      IGU_CMD_INT_ACK_BASE) << 3),
+				    ~((u32)deasserted_bits));
 
 	/* Unmask deasserted attentions in IGU */
 	aeu_mask = qed_rd(p_hwfn, p_hwfn->p_dpc_ptt,
@@ -160,7 +475,7 @@ static int qed_int_deassertion(struct qed_hwfn  *p_hwfn,
 	/* Clear deassertion from inner state */
 	sb_attn_sw->known_attn &= ~deasserted_bits;
 
-	return 0;
+	return rc;
 }
 
 static int qed_int_attentions(struct qed_hwfn *p_hwfn)
@@ -379,10 +694,31 @@ static void qed_int_sb_attn_init(struct qed_hwfn *p_hwfn,
 				 dma_addr_t sb_phy_addr)
 {
 	struct qed_sb_attn_info *sb_info = p_hwfn->p_sb_attn;
+	int i, j, k;
 
 	sb_info->sb_attn = sb_virt_addr;
 	sb_info->sb_phys = sb_phy_addr;
 
+	/* Set the pointer to the AEU descriptors */
+	sb_info->p_aeu_desc = aeu_descs;
+
+	/* Calculate Parity Masks */
+	memset(sb_info->parity_mask, 0, sizeof(u32) * NUM_ATTN_REGS);
+	for (i = 0; i < NUM_ATTN_REGS; i++) {
+		/* j is array index, k is bit index */
+		for (j = 0, k = 0; k < 32; j++) {
+			unsigned int flags = aeu_descs[i].bits[j].flags;
+
+			if (flags & ATTENTION_PARITY)
+				sb_info->parity_mask[i] |= 1 << k;
+
+			k += ATTENTION_LENGTH(flags);
+		}
+		DP_VERBOSE(p_hwfn, NETIF_MSG_INTR,
+			   "Attn Mask [Reg %d]: 0x%08x\n",
+			   i, sb_info->parity_mask[i]);
+	}
+
 	/* Set the address of cleanup for the mcp attention */
 	sb_info->mfw_attn_addr = (p_hwfn->rel_pf_id << 3) +
 				 MISC_REG_AEU_GENERAL_ATTN_0;
@@ -694,25 +1030,6 @@ static int qed_int_sp_sb_alloc(struct qed_hwfn *p_hwfn,
 	return 0;
 }
 
-static void qed_int_sp_sb_setup(struct qed_hwfn *p_hwfn,
-				struct qed_ptt *p_ptt)
-{
-	if (!p_hwfn)
-		return;
-
-	if (p_hwfn->p_sp_sb)
-		qed_int_sb_setup(p_hwfn, p_ptt, &p_hwfn->p_sp_sb->sb_info);
-	else
-		DP_NOTICE(p_hwfn->cdev,
-			  "Failed to setup Slow path status block - NULL pointer\n");
-
-	if (p_hwfn->p_sb_attn)
-		qed_int_sb_attn_setup(p_hwfn, p_ptt);
-	else
-		DP_NOTICE(p_hwfn->cdev,
-			  "Failed to setup attentions status block - NULL pointer\n");
-}
-
 int qed_int_register_cb(struct qed_hwfn *p_hwfn,
 			qed_int_comp_cb_t comp_cb,
 			void *cookie,
@@ -788,16 +1105,13 @@ void qed_int_igu_enable_int(struct qed_hwfn *p_hwfn,
 int qed_int_igu_enable(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
 		       enum qed_int_mode int_mode)
 {
-	int rc, i;
-
-	/* Mask non-link attentions */
-	for (i = 0; i < 9; i++)
-		qed_wr(p_hwfn, p_ptt,
-		       MISC_REG_AEU_ENABLE1_IGU_OUT_0 + (i << 2), 0);
+	int rc;
 
-	/* Configure AEU signal change to produce attentions for link */
+	/* Configure AEU signal change to produce attentions */
+	qed_wr(p_hwfn, p_ptt, IGU_REG_ATTENTION_ENABLE, 0);
 	qed_wr(p_hwfn, p_ptt, IGU_REG_LEADING_EDGE_LATCH, 0xfff);
 	qed_wr(p_hwfn, p_ptt, IGU_REG_TRAILING_EDGE_LATCH, 0xfff);
+	qed_wr(p_hwfn, p_ptt, IGU_REG_ATTENTION_ENABLE, 0xfff);
 
 	/* Flush the writes to IGU */
 	mmiowb();
@@ -1139,7 +1453,8 @@ void qed_int_free(struct qed_hwfn *p_hwfn)
 void qed_int_setup(struct qed_hwfn *p_hwfn,
 		   struct qed_ptt *p_ptt)
 {
-	qed_int_sp_sb_setup(p_hwfn, p_ptt);
+	qed_int_sb_setup(p_hwfn, p_ptt, &p_hwfn->p_sp_sb->sb_info);
+	qed_int_sb_attn_setup(p_hwfn, p_ptt);
 	qed_int_sp_dpc_setup(p_hwfn);
 }
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h b/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
index e8df123..2286e75 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
@@ -333,6 +333,8 @@
 	0x180800UL
 #define  MISC_REG_AEU_ENABLE1_IGU_OUT_0 \
 	0x00849cUL
+#define MISC_REG_AEU_AFTER_INVERT_1_IGU	\
+	0x0087b4UL
 #define  MISC_REG_AEU_MASK_ATTN_IGU \
 	0x008494UL
 #define  IGU_REG_CLEANUP_STATUS_0 \
-- 
1.9.3
