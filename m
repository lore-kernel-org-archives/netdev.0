From: "Eliezer Tamir" <eliezert@broadcom.com>
Subject: [PATCH 2.6.25 4/8][BNX2X]: rework slowpath and hw attentions
Date: Wed, 20 Feb 2008 19:34:01 +0200
Message-ID: <1203528841.8232.92.camel@lb-tlvb-eliezer.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1713 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759303AbYBTReP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Feb 2008 12:34:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2X]: rework slowpath and hw attentions


Signed-off-by: Eliezer Tamir <eliezert@broadcom.com>
---
 drivers/net/bnx2x.c         |  466 +++++++++++++++++++++++++++----------------
 drivers/net/bnx2x.h         |    3 -
 drivers/net/bnx2x_fw_defs.h |    7 +-
 3 files changed, 294 insertions(+), 182 deletions(-)

diff --git a/drivers/net/bnx2x.c b/drivers/net/bnx2x.c
index 0188cb6..d2258f5 100644
--- a/drivers/net/bnx2x.c
+++ b/drivers/net/bnx2x.c
@@ -445,7 +445,7 @@ static void bnx2x_panic_dump(struct bnx2x *bp)
 	DP(BNX2X_MSG_STATS, "stats_state - DISABLE\n");
 }
 
-static void bnx2x_enable_int(struct bnx2x *bp)
+static void bnx2x_int_enable(struct bnx2x *bp)
 {
 	int port = bp->port;
 	u32 addr = port ? HC_REG_CONFIG_1 : HC_REG_CONFIG_0;
@@ -458,18 +458,26 @@ static void bnx2x_enable_int(struct bnx2x *bp)
 			HC_CONFIG_0_REG_ATTN_BIT_EN_0);
 	} else {
 		val |= (HC_CONFIG_0_REG_SINGLE_ISR_EN_0 |
+			HC_CONFIG_0_REG_MSI_MSIX_INT_EN_0 |
 			HC_CONFIG_0_REG_INT_LINE_EN_0 |
 			HC_CONFIG_0_REG_ATTN_BIT_EN_0);
+
+		/* Errata A0.158 workaround */
+		DP(NETIF_MSG_INTR, "write %x to HC %d (addr 0x%x)  MSI-X %d\n",
+		   val, port, addr, msix);
+
+		REG_WR(bp, addr, val);
+
 		val &= ~HC_CONFIG_0_REG_MSI_MSIX_INT_EN_0;
 	}
 
-	DP(NETIF_MSG_INTR, "write %x to HC %d (addr 0x%x)  msi %d\n",
+	DP(NETIF_MSG_INTR, "write %x to HC %d (addr 0x%x)  MSI-X %d\n",
 	   val, port, addr, msix);
 
 	REG_WR(bp, addr, val);
 }
 
-static void bnx2x_disable_int(struct bnx2x *bp)
+static void bnx2x_int_disable(struct bnx2x *bp)
 {
 	int port = bp->port;
 	u32 addr = port ? HC_REG_CONFIG_1 : HC_REG_CONFIG_0;
@@ -488,7 +496,7 @@ static void bnx2x_disable_int(struct bnx2x *bp)
 		BNX2X_ERR("BUG! proper val not read from IGU!\n");
 }
 
-static void bnx2x_disable_int_sync(struct bnx2x *bp)
+static void bnx2x_int_disable_sync(struct bnx2x *bp)
 {
 
 	int msix = (bp->flags & USING_MSIX_FLAG) ? 1 : 0;
@@ -496,7 +504,7 @@ static void bnx2x_disable_int_sync(struct bnx2x *bp)
 
 	atomic_inc(&bp->intr_sem);
 	/* prevent the HW from sending interrupts */
-	bnx2x_disable_int(bp);
+	bnx2x_int_disable(bp);
 
 	/* make sure all ISRs are done */
 	if (msix) {
@@ -522,7 +530,7 @@ static void bnx2x_disable_int_sync(struct bnx2x *bp)
 static inline void bnx2x_ack_sb(struct bnx2x *bp, u8 id,
 				u8 storm, u16 index, u8 op, u8 update)
 {
-	u32 igu_addr = (IGU_ADDR_INT_ACK + IGU_PORT_BASE * bp->port) * 8;
+	u32 igu_addr = (IGU_ADDR_INT_ACK + IGU_FUNC_BASE * bp->port) * 8;
 	struct igu_ack_register igu_ack;
 
 	igu_ack.status_block_index = index;
@@ -570,7 +578,7 @@ static inline int bnx2x_has_work(struct bnx2x_fastpath *fp)
 
 static u16 bnx2x_ack_int(struct bnx2x *bp)
 {
-	u32 igu_addr = (IGU_ADDR_SIMD_MASK + IGU_PORT_BASE * bp->port) * 8;
+	u32 igu_addr = (IGU_ADDR_SIMD_MASK + IGU_FUNC_BASE * bp->port) * 8;
 	u32 result = REG_RD(bp, BAR_IGU_INTMEM + igu_addr);
 
 /*      DP(NETIF_MSG_INTR, "read 0x%08x from IGU addr 0x%x\n",
@@ -4079,11 +4087,11 @@ static inline u16 bnx2x_update_dsb_idx(struct bnx2x *bp)
 static void bnx2x_attn_int_asserted(struct bnx2x *bp, u32 asserted)
 {
 	int port = bp->port;
-	u32 igu_addr = (IGU_ADDR_ATTN_BITS_SET + IGU_PORT_BASE * port) * 8;
+	u32 igu_addr = (IGU_ADDR_ATTN_BITS_SET + IGU_FUNC_BASE * port) * 8;
 	u32 aeu_addr = port ? MISC_REG_AEU_MASK_ATTN_FUNC_1 :
 			      MISC_REG_AEU_MASK_ATTN_FUNC_0;
-	u32 nig_mask_addr = port ? NIG_REG_MASK_INTERRUPT_PORT1 :
-				   NIG_REG_MASK_INTERRUPT_PORT0;
+	u32 nig_int_mask_addr = port ? NIG_REG_MASK_INTERRUPT_PORT1 :
+				       NIG_REG_MASK_INTERRUPT_PORT0;
 
 	if (~bp->aeu_mask & (asserted & 0xff))
 		BNX2X_ERR("IGU ERROR\n");
@@ -4101,15 +4109,11 @@ static void bnx2x_attn_int_asserted(struct bnx2x *bp, u32 asserted)
 
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
@@ -4162,15 +4166,132 @@ static void bnx2x_attn_int_asserted(struct bnx2x *bp, u32 asserted)
 
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
 
@@ -4191,64 +4312,14 @@ static void bnx2x_attn_int_deasserted(struct bnx2x *bp, u32 deasserted)
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
@@ -4256,7 +4327,15 @@ static void bnx2x_attn_int_deasserted(struct bnx2x *bp, u32 deasserted)
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
@@ -4264,16 +4343,16 @@ static void bnx2x_attn_int_deasserted(struct bnx2x *bp, u32 deasserted)
 						HW_PRTY_ASSERT_SET_1) ||
 			    (attn.sig[2] & group_mask.sig[2] &
 						HW_PRTY_ASSERT_SET_2))
-				BNX2X_ERR("FATAL HW block parity attention\n");
+			       BNX2X_ERR("FATAL HW block parity attention\n");
 		}
 	}
 
 	bnx2x_unlock_alr(bp);
 
-	reg_addr = (IGU_ADDR_ATTN_BITS_CLR + IGU_PORT_BASE * port) * 8;
+	reg_addr = (IGU_ADDR_ATTN_BITS_CLR + IGU_FUNC_BASE * port) * 8;
 
 	val = ~deasserted;
-/*      DP(NETIF_MSG_INTR, "write 0x%08x to IGU addr 0x%x\n",
+/*	DP(NETIF_MSG_INTR, "write 0x%08x to IGU addr 0x%x\n",
 	   val, BAR_IGU_INTMEM + reg_addr); */
 	REG_WR(bp, BAR_IGU_INTMEM + reg_addr, val);
 
@@ -4329,7 +4408,7 @@ static void bnx2x_sp_task(struct work_struct *work)
 
 	/* Return here if interrupt is disabled */
 	if (unlikely(atomic_read(&bp->intr_sem) != 0)) {
-		DP(NETIF_MSG_INTR, "called but intr_sem not 0, returning\n");
+		DP(BNX2X_MSG_SP, "called but intr_sem not 0, returning\n");
 		return;
 	}
 
@@ -4339,12 +4418,11 @@ static void bnx2x_sp_task(struct work_struct *work)
 
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
 
@@ -4358,6 +4436,7 @@ static void bnx2x_sp_task(struct work_struct *work)
 		     IGU_INT_NOP, 1);
 	bnx2x_ack_sb(bp, DEF_SB_ID, TSTORM_ID, le16_to_cpu(bp->def_t_idx),
 		     IGU_INT_ENABLE, 1);
+
 }
 
 static irqreturn_t bnx2x_msix_sp_int(int irq, void *dev_instance)
@@ -4367,11 +4446,11 @@ static irqreturn_t bnx2x_msix_sp_int(int irq, void *dev_instance)
 
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
@@ -5711,7 +5790,7 @@ static void bnx2x_nic_init(struct bnx2x *bp)
 	bnx2x_init_internal(bp);
 	bnx2x_init_stats(bp);
 	bnx2x_init_ind_table(bp);
-	bnx2x_enable_int(bp);
+	bnx2x_int_enable(bp);
 
 }
 
@@ -6803,14 +6882,11 @@ static void bnx2x_free_msix_irqs(struct bnx2x *bp)
 		   "state(%x)\n", i, bp->msix_table[i + 1].vector,
 		   bnx2x_fp(bp, i, state));
 
-		if (bnx2x_fp(bp, i, state) != BNX2X_FP_STATE_CLOSED) {
-
-			free_irq(bp->msix_table[i + 1].vector, &bp->fp[i]);
-			bnx2x_fp(bp, i, state) = BNX2X_FP_STATE_CLOSED;
-
-		} else
-			DP(NETIF_MSG_IFDOWN, "irq not freed\n");
+		if (bnx2x_fp(bp, i, state) != BNX2X_FP_STATE_CLOSED)
+			BNX2X_ERR("IRQ of fp #%d being freed while "
+				  "state != closed\n", i);
 
+		free_irq(bp->msix_table[i + 1].vector, &bp->fp[i]);
 	}
 
 }
@@ -6840,7 +6916,7 @@ static int bnx2x_enable_msix(struct bnx2x *bp)
 
 	if (pci_enable_msix(bp->pdev, &bp->msix_table[0],
 				     bp->num_queues + 1)){
-		BNX2X_ERR("failed to enable msix\n");
+		BNX2X_LOG("failed to enable MSI-X\n");
 		return -1;
 
 	}
@@ -6857,8 +6933,6 @@ static int bnx2x_req_msix_irqs(struct bnx2x *bp)
 
 	int i, rc;
 
-	DP(NETIF_MSG_IFUP, "about to request sp irq\n");
-
 	rc = request_irq(bp->msix_table[0].vector, bnx2x_msix_sp_int, 0,
 			 bp->dev->name, bp->dev);
 
@@ -6873,7 +6947,8 @@ static int bnx2x_req_msix_irqs(struct bnx2x *bp)
 				 bp->dev->name, &bp->fp[i]);
 
 		if (rc) {
-			BNX2X_ERR("request fp #%d irq failed\n", i);
+			BNX2X_ERR("request fp #%d irq failed  "
+				  "rc %d\n", i, rc);
 			bnx2x_free_msix_irqs(bp);
 			return -EBUSY;
 		}
@@ -7006,12 +7081,13 @@ static int bnx2x_setup_multi(struct bnx2x *bp, int index)
 	/* reset IGU state */
 	bnx2x_ack_sb(bp, index, CSTORM_ID, 0, IGU_INT_ENABLE, 0);
 
+	/* SETUP ramrod */
 	bp->fp[index].state = BNX2X_FP_STATE_OPENING;
 	bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_CLIENT_SETUP, index, 0, index, 0);
 
 	/* Wait for completion */
 	return bnx2x_wait_ramrod(bp, BNX2X_FP_STATE_OPEN, index,
-				 &(bp->fp[index].state), 1);
+				 &(bp->fp[index].state), 0);
 
 }
 
@@ -7021,8 +7097,8 @@ static void bnx2x_set_rx_mode(struct net_device *dev);
 
 static int bnx2x_nic_load(struct bnx2x *bp, int req_irq)
 {
-	int rc;
-	int i = 0;
+	u32 load_code;
+	int i;
 
 	bp->state = BNX2X_STATE_OPENING_WAIT4_LOAD;
 
@@ -7032,12 +7108,17 @@ static int bnx2x_nic_load(struct bnx2x *bp, int req_irq)
 	   initialized, otherwise - not.
 	*/
 	if (!nomcp) {
-		rc = bnx2x_fw_command(bp, DRV_MSG_CODE_LOAD_REQ);
-		if (rc == FW_MSG_CODE_DRV_LOAD_REFUSED) {
+		load_code = bnx2x_fw_command(bp, DRV_MSG_CODE_LOAD_REQ);
+		if (!load_code) {
+			BNX2X_ERR("MCP response failure, unloading\n");
+			return -EBUSY;
+		}
+		if (load_code == FW_MSG_CODE_DRV_LOAD_REFUSED) {
+			BNX2X_ERR("MCP refused load request, unloading\n");
 			return -EBUSY; /* other port in diagnostic mode */
 		}
 	} else {
-		rc = FW_MSG_CODE_DRV_LOAD_COMMON;
+		load_code = FW_MSG_CODE_DRV_LOAD_COMMON;
 	}
 
 	/* if we can't use msix we only need one fp,
@@ -7075,13 +7156,13 @@ static int bnx2x_nic_load(struct bnx2x *bp, int req_irq)
 		if (bp->flags & USING_MSIX_FLAG) {
 			if (bnx2x_req_msix_irqs(bp)) {
 				pci_disable_msix(bp->pdev);
-				goto out_error;
+				goto load_error;
 			}
 
 		} else {
 			if (bnx2x_req_irq(bp)) {
 				BNX2X_ERR("IRQ request failed, aborting\n");
-				goto out_error;
+				goto load_error;
 			}
 		}
 	}
@@ -7092,9 +7173,10 @@ static int bnx2x_nic_load(struct bnx2x *bp, int req_irq)
 
 
 	/* Initialize HW */
-	if (bnx2x_function_init(bp, (rc == FW_MSG_CODE_DRV_LOAD_COMMON))) {
+	if (bnx2x_function_init(bp,
+				(load_code == FW_MSG_CODE_DRV_LOAD_COMMON))) {
 		BNX2X_ERR("HW init failed, aborting\n");
-		goto out_error;
+		goto load_error;
 	}
 
 
@@ -7106,11 +7188,10 @@ static int bnx2x_nic_load(struct bnx2x *bp, int req_irq)
 
 	/* Send LOAD_DONE command to MCP */
 	if (!nomcp) {
-		rc = bnx2x_fw_command(bp, DRV_MSG_CODE_LOAD_DONE);
-		DP(NETIF_MSG_IFUP, "rc = 0x%x\n", rc);
-		if (!rc) {
+		load_code = bnx2x_fw_command(bp, DRV_MSG_CODE_LOAD_DONE);
+		if (!load_code) {
 			BNX2X_ERR("MCP response failure, unloading\n");
-			goto int_disable;
+			goto load_int_disable;
 		}
 	}
 
@@ -7122,11 +7203,11 @@ static int bnx2x_nic_load(struct bnx2x *bp, int req_irq)
 		napi_enable(&bnx2x_fp(bp, i, napi));
 
 	if (bnx2x_setup_leading(bp))
-		goto stop_netif;
+		goto load_stop_netif;
 
 	for_each_nondefault_queue(bp, i)
 		if (bnx2x_setup_multi(bp, i))
-			goto stop_netif;
+			goto load_stop_netif;
 
 	bnx2x_set_mac_addr(bp);
 
@@ -7150,42 +7231,24 @@ static int bnx2x_nic_load(struct bnx2x *bp, int req_irq)
 
 	return 0;
 
-stop_netif:
+load_stop_netif:
 	for_each_queue(bp, i)
 		napi_disable(&bnx2x_fp(bp, i, napi));
 
-int_disable:
-	bnx2x_disable_int_sync(bp);
+load_int_disable:
+	bnx2x_int_disable_sync(bp);
 
 	bnx2x_free_skbs(bp);
 	bnx2x_free_irq(bp);
 
-out_error:
+load_error:
 	bnx2x_free_mem(bp);
 
 	/* TBD we really need to reset the chip
 	   if we want to recover from this */
-	return rc;
+	return -EBUSY;
 }
 
-static void bnx2x_netif_stop(struct bnx2x *bp)
-{
-	int i;
-
-	bp->rx_mode = BNX2X_RX_MODE_NONE;
-	bnx2x_set_storm_rx_mode(bp);
-
-	bnx2x_disable_int_sync(bp);
-	bnx2x_link_reset(bp);
-
-	for_each_queue(bp, i)
-		napi_disable(&bnx2x_fp(bp, i, napi));
-
-	if (netif_running(bp->dev)) {
-		netif_tx_disable(bp->dev);
-		bp->dev->trans_start = jiffies; /* prevent tx timeout */
-	}
-}
 
 static void bnx2x_reset_chip(struct bnx2x *bp, u32 reset_code)
 {
@@ -7276,7 +7339,7 @@ static void bnx2x_stop_leading(struct bnx2x *bp)
 
 	dsb_sp_prod_idx = *bp->dsb_sp_prod;
 
-	/* Send CFC_DELETE ramrod */
+	/* Send PORT_DELETE ramrod */
 	bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_PORT_DEL, 0, 0, 0, 1);
 
 	/* Wait for completion to arrive on default status block
@@ -7297,29 +7360,48 @@ static void bnx2x_stop_leading(struct bnx2x *bp)
 }
 
 
-static int bnx2x_nic_unload(struct bnx2x *bp, int fre_irq)
+static int bnx2x_nic_unload(struct bnx2x *bp, int free_irq)
 {
 	u32 reset_code = 0;
-	int rc;
-	int i;
+	int i, timeout;
 
 	bp->state = BNX2X_STATE_CLOSING_WAIT4_HALT;
 
-	cancel_work_sync(&bp->reset_task);
-
-	/* Delete the timer: do it before disabling interrupts, as it
-	   may be still STAT_QUERY ramrod pending after stopping the timer */
 	del_timer_sync(&bp->timer);
 
+	bp->rx_mode = BNX2X_RX_MODE_NONE;
+	bnx2x_set_storm_rx_mode(bp);
+
+	if (netif_running(bp->dev)) {
+		netif_tx_disable(bp->dev);
+		bp->dev->trans_start = jiffies;	/* prevent tx timeout */
+	}
+
+	/* Wait until all fast path tasks complete */
+	for_each_queue(bp, i) {
+		struct bnx2x_fastpath *fp = &bp->fp[i];
+
+		timeout = 1000;
+		while (bnx2x_has_work(fp) && (timeout--))
+			msleep(1);
+		if (!timeout)
+			BNX2X_ERR("timeout waiting for queue[%d]\n", i);
+	}
+
 	/* Wait until stat ramrod returns and all SP tasks complete */
-	while (bp->stat_pending && (bp->spq_left != MAX_SPQ_PENDING))
+	timeout = 1000;
+	while ((bp->stat_pending || (bp->spq_left != MAX_SPQ_PENDING)) &&
+	       (timeout--))
 		msleep(1);
 
-	/* Stop fast path, disable MAC, disable interrupts, disable napi */
-	bnx2x_netif_stop(bp);
+	for_each_queue(bp, i)
+		napi_disable(&bnx2x_fp(bp, i, napi));
+	/* Disable interrupts after Tx and Rx are disabled on stack level */
+	bnx2x_int_disable_sync(bp);
 
 	if (bp->flags & NO_WOL_FLAG)
 		reset_code = DRV_MSG_CODE_UNLOAD_REQ_WOL_MCP;
+
 	else if (bp->wol) {
 		u32 emac_base = bp->port ? GRCBASE_EMAC0 : GRCBASE_EMAC1;
 		u8 *mac_addr = bp->dev->dev_addr;
@@ -7336,28 +7418,37 @@ static int bnx2x_nic_unload(struct bnx2x *bp, int fre_irq)
 		EMAC_WR(EMAC_REG_EMAC_MAC_MATCH + 4, val);
 
 		reset_code = DRV_MSG_CODE_UNLOAD_REQ_WOL_EN;
+
 	} else
 		reset_code = DRV_MSG_CODE_UNLOAD_REQ_WOL_DIS;
 
+	/* Close multi and leading connections */
 	for_each_nondefault_queue(bp, i)
 		if (bnx2x_stop_multi(bp, i))
-			goto error;
-
+			goto unload_error;
 
 	bnx2x_stop_leading(bp);
+	if ((bp->state != BNX2X_STATE_CLOSING_WAIT4_UNLOAD) ||
+	    (bp->fp[0].state != BNX2X_FP_STATE_CLOSED)) {
+		DP(NETIF_MSG_IFDOWN, "failed to close leading properly!"
+		   "state 0x%x  fp[0].state 0x%x",
+		   bp->state, bp->fp[0].state);
+	}
+
+unload_error:
+	bnx2x_link_reset(bp);
 
-error:
 	if (!nomcp)
-		rc = bnx2x_fw_command(bp, reset_code);
+		reset_code = bnx2x_fw_command(bp, reset_code);
 	else
-		rc = FW_MSG_CODE_DRV_UNLOAD_COMMON;
+		reset_code = FW_MSG_CODE_DRV_UNLOAD_COMMON;
 
 	/* Release IRQs */
-	if (fre_irq)
+	if (free_irq)
 		bnx2x_free_irq(bp);
 
 	/* Reset the chip */
-	bnx2x_reset_chip(bp, rc);
+	bnx2x_reset_chip(bp, reset_code);
 
 	/* Report UNLOAD_DONE to MCP */
 	if (!nomcp)
@@ -7368,8 +7459,7 @@ error:
 	bnx2x_free_mem(bp);
 
 	bp->state = BNX2X_STATE_CLOSED;
-	/* Set link down */
-	bp->link_up = 0;
+
 	netif_carrier_off(bp->dev);
 
 	return 0;
@@ -9385,16 +9475,13 @@ static int bnx2x_open(struct net_device *dev)
 /* Called with rtnl_lock */
 static int bnx2x_close(struct net_device *dev)
 {
-	int rc;
 	struct bnx2x *bp = netdev_priv(dev);
 
 	/* Unload the driver, release IRQs */
-	rc = bnx2x_nic_unload(bp, 1);
-	if (rc) {
-		BNX2X_ERR("bnx2x_nic_unload failed: %d\n", rc);
-		return rc;
-	}
-	bnx2x_set_power_state(bp, PCI_D3hot);
+	bnx2x_nic_unload(bp, 1);
+
+	if (!CHIP_REV_IS_SLOW(bp))
+		bnx2x_set_power_state(bp, PCI_D3hot);
 
 	return 0;
 }
@@ -9537,10 +9624,18 @@ static void bnx2x_reset_task(struct work_struct *work)
 	if (!netif_running(bp->dev))
 		return;
 
-	bnx2x_netif_stop(bp);
+	rtnl_lock();
+
+	if (bp->state != BNX2X_STATE_OPEN) {
+		DP(NETIF_MSG_TX_ERR, "state is %x, returning\n", bp->state);
+		goto reset_task_exit;
+	}
 
 	bnx2x_nic_unload(bp, 0);
 	bnx2x_nic_load(bp, 0);
+
+reset_task_exit:
+	rtnl_unlock();
 }
 
 static int __devinit bnx2x_init_board(struct pci_dev *pdev,
@@ -9826,7 +9921,15 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 static void __devexit bnx2x_remove_one(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
-	struct bnx2x *bp = netdev_priv(dev);
+	struct bnx2x *bp;
+
+	if (!dev) {
+		/* we get here if init_one() fails */
+		printk(KERN_ERR PFX "BAD net device from bnx2x_init_one\n");
+		return;
+	}
+
+	bp = netdev_priv(dev);
 
 	unregister_netdev(dev);
 
@@ -9845,34 +9948,43 @@ static void __devexit bnx2x_remove_one(struct pci_dev *pdev)
 static int bnx2x_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
-	struct bnx2x *bp = netdev_priv(dev);
-	int rc;
+	struct bnx2x *bp;
+
+	if (!dev)
+		return 0;
 
 	if (!netif_running(dev))
 		return 0;
 
-	rc = bnx2x_nic_unload(bp, 0);
-	if (!rc)
-		return rc;
+	bp = netdev_priv(dev);
+
+	bnx2x_nic_unload(bp, 0);
 
 	netif_device_detach(dev);
-	pci_save_state(pdev);
 
+	pci_save_state(pdev);
 	bnx2x_set_power_state(bp, pci_choose_state(pdev, state));
+
 	return 0;
 }
 
 static int bnx2x_resume(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
-	struct bnx2x *bp = netdev_priv(dev);
+	struct bnx2x *bp;
 	int rc;
 
+	if (!dev) {
+		printk(KERN_ERR PFX "BAD net device from bnx2x_init_one\n");
+		return -ENODEV;
+	}
+
 	if (!netif_running(dev))
 		return 0;
 
-	pci_restore_state(pdev);
+	bp = netdev_priv(dev);
 
+	pci_restore_state(pdev);
 	bnx2x_set_power_state(bp, PCI_D0);
 	netif_device_attach(dev);
 
diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 568e075..0cdcb1b 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -545,8 +545,6 @@ struct bnx2x {
 	spinlock_t      	phy_lock;
 
 	struct work_struct      reset_task;
-	u16     		in_reset_task;
-
 	struct work_struct      sp_task;
 
 	struct timer_list       timer;
@@ -560,7 +558,6 @@ struct bnx2x {
 #define CHIP_ID(bp)     		(((bp)->chip_id) & 0xfffffff0)
 
 #define CHIP_NUM(bp)    		(((bp)->chip_id) & 0xffff0000)
-#define CHIP_NUM_5710   		0x57100000
 
 #define CHIP_REV(bp)    		(((bp)->chip_id) & 0x0000f000)
 #define CHIP_REV_Ax     		0x00000000
diff --git a/drivers/net/bnx2x_fw_defs.h b/drivers/net/bnx2x_fw_defs.h
index 62a6eb8..eadabb8 100644
--- a/drivers/net/bnx2x_fw_defs.h
+++ b/drivers/net/bnx2x_fw_defs.h
@@ -1,6 +1,6 @@
 /* bnx2x_fw_defs.h: Broadcom Everest network driver.
  *
- * Copyright (c) 2007 Broadcom Corporation
+ * Copyright (c) 2007-2008 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -8,6 +8,7 @@
  */
 
 
+#define CSTORM_ASSERT_LIST_INDEX_OFFSET 		0x1000
 #define CSTORM_DEF_SB_HC_DISABLE_OFFSET(port, index)\
 	(0x1922 + (port * 0x40) + (index * 0x4))
 #define CSTORM_DEF_SB_HOST_SB_ADDR_OFFSET(port)\
@@ -21,6 +22,7 @@
 #define CSTORM_SB_HOST_SB_ADDR_OFFSET(port, cpu_id)\
 	(0x1400 + (port * 0x280) + (cpu_id * 0x28))
 #define CSTORM_STATS_FLAGS_OFFSET(port) 		(0x5108 + (port * 0x8))
+#define TSTORM_ASSERT_LIST_INDEX_OFFSET 		0x1000
 #define TSTORM_CLIENT_CONFIG_OFFSET(port, client_id)\
 	(0x1510 + (port * 0x240) + (client_id * 0x20))
 #define TSTORM_DEF_SB_HC_DISABLE_OFFSET(port, index)\
@@ -41,6 +43,7 @@
 #define TSTORM_RCQ_PROD_OFFSET(port, client_id)\
 	(0x1508 + (port * 0x240) + (client_id * 0x20))
 #define TSTORM_STATS_FLAGS_OFFSET(port) 		(0x4b90 + (port * 0x8))
+#define USTORM_ASSERT_LIST_INDEX_OFFSET 		0x1000
 #define USTORM_DEF_SB_HC_DISABLE_OFFSET(port, index)\
 	(0x191a + (port * 0x28) + (index * 0x4))
 #define USTORM_DEF_SB_HOST_SB_ADDR_OFFSET(port)\
@@ -121,7 +124,7 @@
 /* Host coalescing constants */
 
 /* IGU constants */
-#define IGU_PORT_BASE				0x0400
+#define IGU_FUNC_BASE				0x0400
 
 #define IGU_ADDR_MSIX				0x0000
 #define IGU_ADDR_INT_ACK			0x0200
-- 
1.5.3.2




