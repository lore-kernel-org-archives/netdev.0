From: "Eliezer Tamir" <eliezert@broadcom.com>
Subject: [PATCH 2.6.25 7/12][BNX2X]: fix HW attentions and error
 handling
Date: Wed, 27 Feb 2008 14:24:37 +0200
Message-ID: <1204115077.8232.361.camel@lb-tlvb-eliezer.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, jeff@garzik.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1076 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754664AbYB0MYz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Feb 2008 07:24:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2X]: fix HW attentions and error handling

Some of the HW attentions, used to indicate an error were not properly acked.
This will cause the driver to endlessly receive interrupts when such an error happens.
Had to break the code into smaller chunks because it got too nested.

Signed-off-by: Eliezer Tamir <eliezert@broadcom.com>
---
 drivers/net/bnx2x.c |  229 +++++++++++++++++++++++++++++++++------------------
 1 files changed, 150 insertions(+), 79 deletions(-)

diff --git a/drivers/net/bnx2x.c b/drivers/net/bnx2x.c
index 6f987fa..b99e3b7 100644
--- a/drivers/net/bnx2x.c
+++ b/drivers/net/bnx2x.c
@@ -4089,8 +4089,8 @@ static void bnx2x_attn_int_asserted(struct bnx2x *bp, u32 asserted)
 	u32 igu_addr = (IGU_ADDR_ATTN_BITS_SET + IGU_PORT_BASE * port) * 8;
 	u32 aeu_addr = port ? MISC_REG_AEU_MASK_ATTN_FUNC_1 :
 			      MISC_REG_AEU_MASK_ATTN_FUNC_0;
-	u32 nig_mask_addr = port ? NIG_REG_MASK_INTERRUPT_PORT1 :
-				   NIG_REG_MASK_INTERRUPT_PORT0;
+	u32 nig_int_mask_addr = port ? NIG_REG_MASK_INTERRUPT_PORT1 :
+				       NIG_REG_MASK_INTERRUPT_PORT0;
 
 	if (~bp->aeu_mask & (asserted & 0xff))
 		BNX2X_ERR("IGU ERROR\n");
@@ -4108,15 +4108,11 @@ static void bnx2x_attn_int_asserted(struct bnx2x *bp, u32 asserted)
 
 	if (asserted & ATTN_HARD_WIRED_MASK) {
 		if (asserted & ATTN_NIG_FOR_FUNC) {
-			u32 nig_status_port;
-			u32 nig_int_addr = port ?
-					NIG_REG_STATUS_INTERRUPT_PORT1 :
-					NIG_REG_STATUS_INTERRUPT_PORT0;
 
-			bp->nig_mask = REG_RD(bp, nig_mask_addr);
-			REG_WR(bp, nig_mask_addr, 0);
+			/* save nig interrupt mask */
+			bp->nig_mask = REG_RD(bp, nig_int_mask_addr);
+			REG_WR(bp, nig_int_mask_addr, 0);
 
-			nig_status_port = REG_RD(bp, nig_int_addr);
 			bnx2x_link_update(bp);
 
 			/* handle unicore attn? */
@@ -4169,15 +4165,132 @@ static void bnx2x_attn_int_asserted(struct bnx2x *bp, u32 asserted)
 
 	/* now set back the mask */
 	if (asserted & ATTN_NIG_FOR_FUNC)
-		REG_WR(bp, nig_mask_addr, bp->nig_mask);
+		REG_WR(bp, nig_int_mask_addr, bp->nig_mask);
 }
 
-static void bnx2x_attn_int_deasserted(struct bnx2x *bp, u32 deasserted)
+static inline void bnx2x_attn_int_deasserted0(struct bnx2x *bp, u32 attn)
 {
 	int port = bp->port;
-	int index;
+	int reg_offset;
+	u32 val;
+
+	if (attn & AEU_INPUTS_ATTN_BITS_SPIO5) {
+
+		reg_offset = (port ? MISC_REG_AEU_ENABLE1_FUNC_1_OUT_0 :
+				     MISC_REG_AEU_ENABLE1_FUNC_0_OUT_0);
+
+		val = REG_RD(bp, reg_offset);
+		val &= ~AEU_INPUTS_ATTN_BITS_SPIO5;
+		REG_WR(bp, reg_offset, val);
+
+		BNX2X_ERR("SPIO5 hw attention\n");
+
+		switch (bp->board & SHARED_HW_CFG_BOARD_TYPE_MASK) {
+		case SHARED_HW_CFG_BOARD_TYPE_BCM957710A1022G:
+			/* Fan failure attention */
+
+			/* The PHY reset is controled by GPIO 1 */
+			bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_1,
+				       MISC_REGISTERS_GPIO_OUTPUT_LOW);
+			/* Low power mode is controled by GPIO 2 */
+			bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
+				       MISC_REGISTERS_GPIO_OUTPUT_LOW);
+			/* mark the failure */
+			bp->ext_phy_config &=
+					~PORT_HW_CFG_XGXS_EXT_PHY_TYPE_MASK;
+			bp->ext_phy_config |=
+					PORT_HW_CFG_XGXS_EXT_PHY_TYPE_FAILURE;
+			SHMEM_WR(bp,
+				 dev_info.port_hw_config[port].
+							external_phy_config,
+				 bp->ext_phy_config);
+			/* log the failure */
+			printk(KERN_ERR PFX "Fan Failure on Network"
+			       " Controller %s has caused the driver to"
+			       " shutdown the card to prevent permanent"
+			       " damage.  Please contact Dell Support for"
+			       " assistance\n", bp->dev->name);
+			break;
+
+		default:
+			break;
+		}
+	}
+}
+
+static inline void bnx2x_attn_int_deasserted1(struct bnx2x *bp, u32 attn)
+{
+	u32 val;
+
+	if (attn & BNX2X_DOORQ_ASSERT) {
+
+		val = REG_RD(bp, DORQ_REG_DORQ_INT_STS_CLR);
+		BNX2X_ERR("DB hw attention 0x%x\n", val);
+		/* DORQ discard attention */
+		if (val & 0x2)
+			BNX2X_ERR("FATAL error from DORQ\n");
+	}
+}
+
+static inline void bnx2x_attn_int_deasserted2(struct bnx2x *bp, u32 attn)
+{
+	u32 val;
+
+	if (attn & AEU_INPUTS_ATTN_BITS_CFC_HW_INTERRUPT) {
+
+		val = REG_RD(bp, CFC_REG_CFC_INT_STS_CLR);
+		BNX2X_ERR("CFC hw attention 0x%x\n", val);
+		/* CFC error attention */
+		if (val & 0x2)
+			BNX2X_ERR("FATAL error from CFC\n");
+	}
+
+	if (attn & AEU_INPUTS_ATTN_BITS_PXP_HW_INTERRUPT) {
+
+		val = REG_RD(bp, PXP_REG_PXP_INT_STS_CLR_0);
+		BNX2X_ERR("PXP hw attention 0x%x\n", val);
+		/* RQ_USDMDP_FIFO_OVERFLOW */
+		if (val & 0x18000)
+			BNX2X_ERR("FATAL error from PXP\n");
+	}
+}
+
+static inline void bnx2x_attn_int_deasserted3(struct bnx2x *bp, u32 attn)
+{
+	if (attn & EVEREST_GEN_ATTN_IN_USE_MASK) {
+
+		if (attn & BNX2X_MC_ASSERT_BITS) {
+
+			BNX2X_ERR("MC assert!\n");
+			REG_WR(bp, MISC_REG_AEU_GENERAL_ATTN_10, 0);
+			REG_WR(bp, MISC_REG_AEU_GENERAL_ATTN_9, 0);
+			REG_WR(bp, MISC_REG_AEU_GENERAL_ATTN_8, 0);
+			REG_WR(bp, MISC_REG_AEU_GENERAL_ATTN_7, 0);
+			bnx2x_panic();
+
+		} else if (attn & BNX2X_MCP_ASSERT) {
+
+			BNX2X_ERR("MCP assert!\n");
+			REG_WR(bp, MISC_REG_AEU_GENERAL_ATTN_11, 0);
+			bnx2x_mc_assert(bp);
+
+		} else
+			BNX2X_ERR("Unknown HW assert! (attn 0x%x)\n", attn);
+	}
+
+	if (attn & EVEREST_LATCHED_ATTN_IN_USE_MASK) {
+
+		REG_WR(bp, MISC_REG_AEU_CLR_LATCH_SIGNAL, 0x7ff);
+		BNX2X_ERR("LATCHED attention 0x%x (masked)\n", attn);
+	}
+}
+
+static void bnx2x_attn_int_deasserted(struct bnx2x *bp, u32 deasserted)
+{
 	struct attn_route attn;
 	struct attn_route group_mask;
+	int port = bp->port;
+	int index;
 	u32 reg_addr;
 	u32 val;
 
@@ -4198,64 +4311,14 @@ static void bnx2x_attn_int_deasserted(struct bnx2x *bp, u32 deasserted)
 			DP(NETIF_MSG_HW, "group[%d]: %llx\n", index,
 			   (unsigned long long)group_mask.sig[0]);
 
-			if (attn.sig[3] & group_mask.sig[3] &
-			    EVEREST_GEN_ATTN_IN_USE_MASK) {
-
-				if (attn.sig[3] & BNX2X_MC_ASSERT_BITS) {
-
-					BNX2X_ERR("MC assert!\n");
-					bnx2x_panic();
-
-				} else if (attn.sig[3] & BNX2X_MCP_ASSERT) {
-
-					BNX2X_ERR("MCP assert!\n");
-					REG_WR(bp,
-					     MISC_REG_AEU_GENERAL_ATTN_11, 0);
-					bnx2x_mc_assert(bp);
-
-				} else {
-					BNX2X_ERR("UNKOWEN HW ASSERT!\n");
-				}
-			}
-
-			if (attn.sig[1] & group_mask.sig[1] &
-			    BNX2X_DOORQ_ASSERT) {
-
-				val = REG_RD(bp, DORQ_REG_DORQ_INT_STS_CLR);
-				BNX2X_ERR("DB hw attention 0x%x\n", val);
-				/* DORQ discard attention */
-				if (val & 0x2)
-					BNX2X_ERR("FATAL error from DORQ\n");
-			}
-
-			if (attn.sig[2] & group_mask.sig[2] &
-			    AEU_INPUTS_ATTN_BITS_CFC_HW_INTERRUPT) {
-
-				val = REG_RD(bp, CFC_REG_CFC_INT_STS_CLR);
-				BNX2X_ERR("CFC hw attention 0x%x\n", val);
-				/* CFC error attention */
-				if (val & 0x2)
-					BNX2X_ERR("FATAL error from CFC\n");
-			}
-
-			if (attn.sig[2] & group_mask.sig[2] &
-			    AEU_INPUTS_ATTN_BITS_PXP_HW_INTERRUPT) {
-
-				val = REG_RD(bp, PXP_REG_PXP_INT_STS_CLR_0);
-				BNX2X_ERR("PXP hw attention 0x%x\n", val);
-				/* RQ_USDMDP_FIFO_OVERFLOW */
-				if (val & 0x18000)
-					BNX2X_ERR("FATAL error from PXP\n");
-			}
-
-			if (attn.sig[3] & group_mask.sig[3] &
-			    EVEREST_LATCHED_ATTN_IN_USE_MASK) {
-
-				REG_WR(bp, MISC_REG_AEU_CLR_LATCH_SIGNAL,
-				       0x7ff);
-				DP(NETIF_MSG_HW, "got latched bits 0x%x\n",
-				   attn.sig[3]);
-			}
+			bnx2x_attn_int_deasserted3(bp,
+					attn.sig[3] & group_mask.sig[3]);
+			bnx2x_attn_int_deasserted1(bp,
+					attn.sig[1] & group_mask.sig[1]);
+			bnx2x_attn_int_deasserted2(bp,
+					attn.sig[2] & group_mask.sig[2]);
+			bnx2x_attn_int_deasserted0(bp,
+					attn.sig[0] & group_mask.sig[0]);
 
 			if ((attn.sig[0] & group_mask.sig[0] &
 						HW_INTERRUT_ASSERT_SET_0) ||
@@ -4263,7 +4326,15 @@ static void bnx2x_attn_int_deasserted(struct bnx2x *bp, u32 deasserted)
 						HW_INTERRUT_ASSERT_SET_1) ||
 			    (attn.sig[2] & group_mask.sig[2] &
 						HW_INTERRUT_ASSERT_SET_2))
-				BNX2X_ERR("FATAL HW block attention\n");
+				BNX2X_ERR("FATAL HW block attention"
+					  "  set0 0x%x  set1 0x%x"
+					  "  set2 0x%x\n",
+					  (attn.sig[0] & group_mask.sig[0] &
+					   HW_INTERRUT_ASSERT_SET_0),
+					  (attn.sig[1] & group_mask.sig[1] &
+					   HW_INTERRUT_ASSERT_SET_1),
+					  (attn.sig[2] & group_mask.sig[2] &
+					   HW_INTERRUT_ASSERT_SET_2));
 
 			if ((attn.sig[0] & group_mask.sig[0] &
 						HW_PRTY_ASSERT_SET_0) ||
@@ -4271,7 +4342,7 @@ static void bnx2x_attn_int_deasserted(struct bnx2x *bp, u32 deasserted)
 						HW_PRTY_ASSERT_SET_1) ||
 			    (attn.sig[2] & group_mask.sig[2] &
 						HW_PRTY_ASSERT_SET_2))
-				BNX2X_ERR("FATAL HW block parity attention\n");
+			       BNX2X_ERR("FATAL HW block parity attention\n");
 		}
 	}
 
@@ -4336,7 +4407,7 @@ static void bnx2x_sp_task(struct work_struct *work)
 
 	/* Return here if interrupt is disabled */
 	if (unlikely(atomic_read(&bp->intr_sem) != 0)) {
-		DP(NETIF_MSG_INTR, "called but intr_sem not 0, returning\n");
+		DP(BNX2X_MSG_SP, "called but intr_sem not 0, returning\n");
 		return;
 	}
 
@@ -4346,12 +4417,11 @@ static void bnx2x_sp_task(struct work_struct *work)
 
 	DP(NETIF_MSG_INTR, "got a slowpath interrupt (updated %x)\n", status);
 
-	if (status & 0x1) {
-		/* HW attentions */
+	/* HW attentions */
+	if (status & 0x1)
 		bnx2x_attn_int(bp);
-	}
 
-	/* CStorm events: query_stats, cfc delete ramrods */
+	/* CStorm events: query_stats, port delete ramrod */
 	if (status & 0x2)
 		bp->stat_pending = 0;
 
@@ -4365,6 +4435,7 @@ static void bnx2x_sp_task(struct work_struct *work)
 		     IGU_INT_NOP, 1);
 	bnx2x_ack_sb(bp, DEF_SB_ID, TSTORM_ID, le16_to_cpu(bp->def_t_idx),
 		     IGU_INT_ENABLE, 1);
+
 }
 
 static irqreturn_t bnx2x_msix_sp_int(int irq, void *dev_instance)
@@ -4374,11 +4445,11 @@ static irqreturn_t bnx2x_msix_sp_int(int irq, void *dev_instance)
 
 	/* Return here if interrupt is disabled */
 	if (unlikely(atomic_read(&bp->intr_sem) != 0)) {
-		DP(NETIF_MSG_INTR, "called but intr_sem not 0, returning\n");
+		DP(BNX2X_MSG_SP, "called but intr_sem not 0, returning\n");
 		return IRQ_HANDLED;
 	}
 
-	bnx2x_ack_sb(bp, 16, XSTORM_ID, 0, IGU_INT_DISABLE, 0);
+	bnx2x_ack_sb(bp, DEF_SB_ID, XSTORM_ID, 0, IGU_INT_DISABLE, 0);
 
 #ifdef BNX2X_STOP_ON_ERROR
 	if (unlikely(bp->panic))
-- 
1.5.3.2




