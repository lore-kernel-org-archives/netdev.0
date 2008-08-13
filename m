From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 10/25] bnx2x: PBA Table Page Alignment Workaround
Date: Wed, 13 Aug 2008 17:14:04 +0300
Message-ID: <1218636844.547.86.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4376 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756040AbYHMOOW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2008 10:14:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PBA Table Page Alignment Workaround
The PBA table starts on the middle of the page and that's causing very
low performance with virtualization. The solution is not to update via
the BAR directly but via chip access to the same memory

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |   92 +++++++++++---------------
 drivers/net/bnx2x_reg.h  |  162 ++++++++++++++++++++++++++--------------------
 2 files changed, 130 insertions(+), 124 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index a4177e9..b2886db 100755
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -685,7 +685,8 @@ static void bnx2x_int_disable_sync(struct bnx2x *bp)
 static inline void bnx2x_ack_sb(struct bnx2x *bp, u8 sb_id,
 				u8 storm, u16 index, u8 op, u8 update)
 {
-	u32 igu_addr = (IGU_ADDR_INT_ACK + IGU_FUNC_BASE * BP_FUNC(bp)) * 8;
+	u32 hc_addr = (HC_REG_COMMAND_REG + BP_PORT(bp)*32 +
+		       COMMAND_REG_INT_ACK);
 	struct igu_ack_register igu_ack;
 
 	igu_ack.status_block_index = index;
@@ -695,9 +696,9 @@ static inline void bnx2x_ack_sb(struct bnx2x *bp, u8 sb_id,
 			 (update << IGU_ACK_REGISTER_UPDATE_INDEX_SHIFT) |
 			 (op << IGU_ACK_REGISTER_INTERRUPT_MODE_SHIFT));
 
-	DP(BNX2X_MSG_OFF, "write 0x%08x to IGU addr 0x%x\n",
-	   (*(u32 *)&igu_ack), BAR_IGU_INTMEM + igu_addr);
-	REG_WR(bp, BAR_IGU_INTMEM + igu_addr, (*(u32 *)&igu_ack));
+	DP(BNX2X_MSG_OFF, "write 0x%08x to HC addr 0x%x\n",
+	   (*(u32 *)&igu_ack), hc_addr);
+	REG_WR(bp, hc_addr, (*(u32 *)&igu_ack));
 }
 
 static inline u16 bnx2x_update_fpsb_idx(struct bnx2x_fastpath *fp)
@@ -719,19 +720,13 @@ static inline u16 bnx2x_update_fpsb_idx(struct bnx2x_fastpath *fp)
 
 static u16 bnx2x_ack_int(struct bnx2x *bp)
 {
-	u32 igu_addr = (IGU_ADDR_SIMD_MASK + IGU_FUNC_BASE * BP_FUNC(bp)) * 8;
-	u32 result = REG_RD(bp, BAR_IGU_INTMEM + igu_addr);
+	u32 hc_addr = (HC_REG_COMMAND_REG + BP_PORT(bp)*32 +
+		       COMMAND_REG_SIMD_MASK);
+	u32 result = REG_RD(bp, hc_addr);
 
-	DP(BNX2X_MSG_OFF, "read 0x%08x from IGU addr 0x%x\n",
-	   result, BAR_IGU_INTMEM + igu_addr);
+	DP(BNX2X_MSG_OFF, "read 0x%08x from HC addr 0x%x\n",
+	   result, hc_addr);
 
-#ifdef IGU_DEBUG
-#warning IGU_DEBUG active
-	if (result == 0) {
-		BNX2X_ERR("read %x from IGU\n", result);
-		REG_WR(bp, TM_REG_TIMER_SOFT_RST, 0);
-	}
-#endif
 	return result;
 }
 
@@ -2444,8 +2439,8 @@ static inline u16 bnx2x_update_dsb_idx(struct bnx2x *bp)
 static void bnx2x_attn_int_asserted(struct bnx2x *bp, u32 asserted)
 {
 	int port = BP_PORT(bp);
-	int func = BP_FUNC(bp);
-	u32 igu_addr = (IGU_ADDR_ATTN_BITS_SET + IGU_FUNC_BASE * func) * 8;
+	u32 hc_addr = (HC_REG_COMMAND_REG + port*32 +
+		       COMMAND_REG_ATTN_BITS_SET);
 	u32 aeu_addr = port ? MISC_REG_AEU_MASK_ATTN_FUNC_1 :
 			      MISC_REG_AEU_MASK_ATTN_FUNC_0;
 	u32 nig_int_mask_addr = port ? NIG_REG_MASK_INTERRUPT_PORT1 :
@@ -2523,9 +2518,9 @@ static void bnx2x_attn_int_asserted(struct bnx2x *bp, u32 asserted)
 
 	} /* if hardwired */
 
-	DP(NETIF_MSG_HW, "about to mask 0x%08x at IGU addr 0x%x\n",
-	   asserted, BAR_IGU_INTMEM + igu_addr);
-	REG_WR(bp, BAR_IGU_INTMEM + igu_addr, asserted);
+	DP(NETIF_MSG_HW, "about to mask 0x%08x at HC addr 0x%x\n",
+	   asserted, hc_addr);
+	REG_WR(bp, hc_addr, asserted);
 
 	/* now set back the mask */
 	if (asserted & ATTN_NIG_FOR_FUNC)
@@ -2764,12 +2759,12 @@ static void bnx2x_attn_int_deasserted(struct bnx2x *bp, u32 deasserted)
 
 	bnx2x_release_alr(bp);
 
-	reg_addr = (IGU_ADDR_ATTN_BITS_CLR + IGU_FUNC_BASE * BP_FUNC(bp)) * 8;
+	reg_addr = (HC_REG_COMMAND_REG + port*32 + COMMAND_REG_ATTN_BITS_CLR);
 
 	val = ~deasserted;
 	DP(NETIF_MSG_HW, "about to mask 0x%08x at HC addr 0x%x\n",
 	   val, reg_addr);
-	REG_WR(bp, BAR_IGU_INTMEM + reg_addr, val);
+	REG_WR(bp, reg_addr, val);
 
 	if (~bp->attn_state & deasserted)
 		BNX2X_ERR("IGU ERROR\n");
@@ -3998,8 +3993,8 @@ static void bnx2x_zero_sb(struct bnx2x *bp, int sb_id)
 			sizeof(struct cstorm_def_status_block)/4);
 }
 
-static void bnx2x_init_sb(struct bnx2x *bp, int sb_id,
-			  struct host_status_block *sb,	dma_addr_t mapping)
+static void bnx2x_init_sb(struct bnx2x *bp, struct host_status_block *sb,
+			  dma_addr_t mapping, int sb_id)
 {
 	int port = BP_PORT(bp);
 	int func = BP_FUNC(bp);
@@ -4075,7 +4070,6 @@ static void bnx2x_init_def_sb(struct bnx2x *bp,
 					    atten_status_block);
 	def_sb->atten_status_block.status_block_id = sb_id;
 
-	bp->def_att_idx = 0;
 	bp->attn_state = 0;
 
 	reg_offset = (port ? MISC_REG_AEU_ENABLE1_FUNC_1_OUT_0 :
@@ -4109,17 +4103,13 @@ static void bnx2x_init_def_sb(struct bnx2x *bp,
 					    u_def_status_block);
 	def_sb->u_def_status_block.status_block_id = sb_id;
 
-	bp->def_u_idx = 0;
-
 	REG_WR(bp, BAR_USTRORM_INTMEM +
 	       USTORM_DEF_SB_HOST_SB_ADDR_OFFSET(func), U64_LO(section));
 	REG_WR(bp, BAR_USTRORM_INTMEM +
 	       ((USTORM_DEF_SB_HOST_SB_ADDR_OFFSET(func)) + 4),
 	       U64_HI(section));
-	REG_WR8(bp, BAR_USTRORM_INTMEM +  DEF_USB_FUNC_OFF +
+	REG_WR8(bp, BAR_USTRORM_INTMEM + DEF_USB_FUNC_OFF +
 		USTORM_DEF_SB_HOST_STATUS_BLOCK_OFFSET(func), func);
-	REG_WR(bp, BAR_USTRORM_INTMEM + USTORM_HC_BTR_OFFSET(func),
-	       BNX2X_BTR);
 
 	for (index = 0; index < HC_USTORM_DEF_SB_NUM_INDICES; index++)
 		REG_WR16(bp, BAR_USTRORM_INTMEM +
@@ -4130,17 +4120,13 @@ static void bnx2x_init_def_sb(struct bnx2x *bp,
 					    c_def_status_block);
 	def_sb->c_def_status_block.status_block_id = sb_id;
 
-	bp->def_c_idx = 0;
-
 	REG_WR(bp, BAR_CSTRORM_INTMEM +
 	       CSTORM_DEF_SB_HOST_SB_ADDR_OFFSET(func), U64_LO(section));
 	REG_WR(bp, BAR_CSTRORM_INTMEM +
 	       ((CSTORM_DEF_SB_HOST_SB_ADDR_OFFSET(func)) + 4),
 	       U64_HI(section));
-	REG_WR8(bp, BAR_CSTRORM_INTMEM +  DEF_CSB_FUNC_OFF +
+	REG_WR8(bp, BAR_CSTRORM_INTMEM + DEF_CSB_FUNC_OFF +
 		CSTORM_DEF_SB_HOST_STATUS_BLOCK_OFFSET(func), func);
-	REG_WR(bp, BAR_CSTRORM_INTMEM + CSTORM_HC_BTR_OFFSET(func),
-	       BNX2X_BTR);
 
 	for (index = 0; index < HC_CSTORM_DEF_SB_NUM_INDICES; index++)
 		REG_WR16(bp, BAR_CSTRORM_INTMEM +
@@ -4151,17 +4137,13 @@ static void bnx2x_init_def_sb(struct bnx2x *bp,
 					    t_def_status_block);
 	def_sb->t_def_status_block.status_block_id = sb_id;
 
-	bp->def_t_idx = 0;
-
 	REG_WR(bp, BAR_TSTRORM_INTMEM +
 	       TSTORM_DEF_SB_HOST_SB_ADDR_OFFSET(func), U64_LO(section));
 	REG_WR(bp, BAR_TSTRORM_INTMEM +
 	       ((TSTORM_DEF_SB_HOST_SB_ADDR_OFFSET(func)) + 4),
 	       U64_HI(section));
-	REG_WR8(bp, BAR_TSTRORM_INTMEM +  DEF_TSB_FUNC_OFF +
+	REG_WR8(bp, BAR_TSTRORM_INTMEM + DEF_TSB_FUNC_OFF +
 		TSTORM_DEF_SB_HOST_STATUS_BLOCK_OFFSET(func), func);
-	REG_WR(bp, BAR_TSTRORM_INTMEM + TSTORM_HC_BTR_OFFSET(func),
-	       BNX2X_BTR);
 
 	for (index = 0; index < HC_TSTORM_DEF_SB_NUM_INDICES; index++)
 		REG_WR16(bp, BAR_TSTRORM_INTMEM +
@@ -4172,17 +4154,13 @@ static void bnx2x_init_def_sb(struct bnx2x *bp,
 					    x_def_status_block);
 	def_sb->x_def_status_block.status_block_id = sb_id;
 
-	bp->def_x_idx = 0;
-
 	REG_WR(bp, BAR_XSTRORM_INTMEM +
 	       XSTORM_DEF_SB_HOST_SB_ADDR_OFFSET(func), U64_LO(section));
 	REG_WR(bp, BAR_XSTRORM_INTMEM +
 	       ((XSTORM_DEF_SB_HOST_SB_ADDR_OFFSET(func)) + 4),
 	       U64_HI(section));
-	REG_WR8(bp, BAR_XSTRORM_INTMEM +  DEF_XSB_FUNC_OFF +
+	REG_WR8(bp, BAR_XSTRORM_INTMEM + DEF_XSB_FUNC_OFF +
 		XSTORM_DEF_SB_HOST_STATUS_BLOCK_OFFSET(func), func);
-	REG_WR(bp, BAR_XSTRORM_INTMEM + XSTORM_HC_BTR_OFFSET(func),
-	       BNX2X_BTR);
 
 	for (index = 0; index < HC_XSTORM_DEF_SB_NUM_INDICES; index++)
 		REG_WR16(bp, BAR_XSTRORM_INTMEM +
@@ -4205,21 +4183,25 @@ static void bnx2x_update_coalesce(struct bnx2x *bp)
 		/* HC_INDEX_U_ETH_RX_CQ_CONS */
 		REG_WR8(bp, BAR_USTRORM_INTMEM +
 			USTORM_SB_HC_TIMEOUT_OFFSET(port, sb_id,
-						   HC_INDEX_U_ETH_RX_CQ_CONS),
+						    U_SB_ETH_RX_CQ_INDEX),
 			bp->rx_ticks/12);
 		REG_WR16(bp, BAR_USTRORM_INTMEM +
 			 USTORM_SB_HC_DISABLE_OFFSET(port, sb_id,
-						   HC_INDEX_U_ETH_RX_CQ_CONS),
+						     U_SB_ETH_RX_CQ_INDEX),
+			 bp->rx_ticks ? 0 : 1);
+		REG_WR16(bp, BAR_USTRORM_INTMEM +
+			 USTORM_SB_HC_DISABLE_OFFSET(port, sb_id,
+						     U_SB_ETH_RX_BD_INDEX),
 			 bp->rx_ticks ? 0 : 1);
 
 		/* HC_INDEX_C_ETH_TX_CQ_CONS */
 		REG_WR8(bp, BAR_CSTRORM_INTMEM +
 			CSTORM_SB_HC_TIMEOUT_OFFSET(port, sb_id,
-						   HC_INDEX_C_ETH_TX_CQ_CONS),
+						    C_SB_ETH_TX_CQ_INDEX),
 			bp->tx_ticks/12);
 		REG_WR16(bp, BAR_CSTRORM_INTMEM +
 			 CSTORM_SB_HC_DISABLE_OFFSET(port, sb_id,
-						   HC_INDEX_C_ETH_TX_CQ_CONS),
+						     C_SB_ETH_TX_CQ_INDEX),
 			 bp->tx_ticks ? 0 : 1);
 	}
 }
@@ -4494,7 +4476,7 @@ static void bnx2x_init_context(struct bnx2x *bp)
 		}
 
 		context->cstorm_st_context.sb_index_number =
-						HC_INDEX_C_ETH_TX_CQ_CONS;
+						C_SB_ETH_TX_CQ_INDEX;
 		context->cstorm_st_context.status_block_id = sb_id;
 
 		context->xstorm_ag_context.cdu_reserved =
@@ -4773,12 +4755,14 @@ static void bnx2x_nic_init(struct bnx2x *bp, u32 load_code)
 		DP(NETIF_MSG_IFUP,
 		   "bnx2x_init_sb(%p,%p) index %d  cl_id %d  sb %d\n",
 		   bp, fp->status_blk, i, FP_CL_ID(fp), FP_SB_ID(fp));
-		bnx2x_init_sb(bp, FP_SB_ID(fp), fp->status_blk,
-			      fp->status_blk_mapping);
+		bnx2x_init_sb(bp, fp->status_blk, fp->status_blk_mapping,
+			      FP_SB_ID(fp));
+		bnx2x_update_fpsb_idx(fp);
 	}
 
-	bnx2x_init_def_sb(bp, bp->def_status_blk,
-			  bp->def_status_blk_mapping, DEF_SB_ID);
+	bnx2x_init_def_sb(bp, bp->def_status_blk, bp->def_status_blk_mapping,
+			  DEF_SB_ID);
+	bnx2x_update_dsb_idx(bp);
 	bnx2x_update_coalesce(bp);
 	bnx2x_init_rx_rings(bp);
 	bnx2x_init_tx_ring(bp);
diff --git a/drivers/net/bnx2x_reg.h b/drivers/net/bnx2x_reg.h
index f72ffd2..a85ff20 100644
--- a/drivers/net/bnx2x_reg.h
+++ b/drivers/net/bnx2x_reg.h
@@ -740,6 +740,7 @@
 #define HC_REG_ATTN_MSG1_ADDR_L 				 0x108020
 #define HC_REG_ATTN_NUM_P0					 0x108038
 #define HC_REG_ATTN_NUM_P1					 0x10803c
+#define HC_REG_COMMAND_REG					 0x108180
 #define HC_REG_CONFIG_0 					 0x108000
 #define HC_REG_CONFIG_1 					 0x108004
 #define HC_REG_FUNC_NUM_P0					 0x1080ac
@@ -5168,59 +5169,73 @@
 #define GRCBASE_MISC_AEU	GRCBASE_MISC
 
 
-/*the offset of the configuration space in the pci core register*/
+/* offset of configuration space in the pci core register */
 #define PCICFG_OFFSET					0x2000
 #define PCICFG_VENDOR_ID_OFFSET 			0x00
 #define PCICFG_DEVICE_ID_OFFSET 			0x02
 #define PCICFG_COMMAND_OFFSET				0x04
+#define PCICFG_COMMAND_IO_SPACE 		(1<<0)
+#define PCICFG_COMMAND_MEM_SPACE		(1<<1)
+#define PCICFG_COMMAND_BUS_MASTER		(1<<2)
+#define PCICFG_COMMAND_SPECIAL_CYCLES		(1<<3)
+#define PCICFG_COMMAND_MWI_CYCLES		(1<<4)
+#define PCICFG_COMMAND_VGA_SNOOP		(1<<5)
+#define PCICFG_COMMAND_PERR_ENA 		(1<<6)
+#define PCICFG_COMMAND_STEPPING 		(1<<7)
+#define PCICFG_COMMAND_SERR_ENA 		(1<<8)
+#define PCICFG_COMMAND_FAST_B2B 		(1<<9)
+#define PCICFG_COMMAND_INT_DISABLE		(1<<10)
+#define PCICFG_COMMAND_RESERVED 		(0x1f<<11)
 #define PCICFG_STATUS_OFFSET				0x06
-#define PCICFG_REVESION_ID				    0x08
+#define PCICFG_REVESION_ID				0x08
 #define PCICFG_CACHE_LINE_SIZE				0x0c
 #define PCICFG_LATENCY_TIMER				0x0d
-#define PCICFG_BAR_1_LOW				    0x10
-#define PCICFG_BAR_1_HIGH				    0x14
-#define PCICFG_BAR_2_LOW				    0x18
-#define PCICFG_BAR_2_HIGH				    0x1c
-#define PCICFG_SUBSYSTEM_VENDOR_ID_OFFSET	0x2c
+#define PCICFG_BAR_1_LOW				0x10
+#define PCICFG_BAR_1_HIGH				0x14
+#define PCICFG_BAR_2_LOW				0x18
+#define PCICFG_BAR_2_HIGH				0x1c
+#define PCICFG_SUBSYSTEM_VENDOR_ID_OFFSET		0x2c
 #define PCICFG_SUBSYSTEM_ID_OFFSET			0x2e
-#define PCICFG_INT_LINE 				    0x3c
-#define PCICFG_INT_PIN					    0x3d
-#define PCICFG_PM_CSR_OFFSET			0x4c
-#define PCICFG_GRC_ADDRESS				    0x78
-#define PCICFG_GRC_DATA 				    0x80
+#define PCICFG_INT_LINE 				0x3c
+#define PCICFG_INT_PIN					0x3d
+#define PCICFG_PM_CAPABILITY				0x48
+#define PCICFG_PM_CAPABILITY_VERSION		(0x3<<16)
+#define PCICFG_PM_CAPABILITY_CLOCK		(1<<19)
+#define PCICFG_PM_CAPABILITY_RESERVED		(1<<20)
+#define PCICFG_PM_CAPABILITY_DSI		(1<<21)
+#define PCICFG_PM_CAPABILITY_AUX_CURRENT	(0x7<<22)
+#define PCICFG_PM_CAPABILITY_D1_SUPPORT 	(1<<25)
+#define PCICFG_PM_CAPABILITY_D2_SUPPORT 	(1<<26)
+#define PCICFG_PM_CAPABILITY_PME_IN_D0		(1<<27)
+#define PCICFG_PM_CAPABILITY_PME_IN_D1		(1<<28)
+#define PCICFG_PM_CAPABILITY_PME_IN_D2		(1<<29)
+#define PCICFG_PM_CAPABILITY_PME_IN_D3_HOT	(1<<30)
+#define PCICFG_PM_CAPABILITY_PME_IN_D3_COLD	(1<<31)
+#define PCICFG_PM_CSR_OFFSET				0x4c
+#define PCICFG_PM_CSR_STATE			(0x3<<0)
+#define PCICFG_PM_CSR_PME_ENABLE		(1<<8)
+#define PCICFG_PM_CSR_PME_STATUS		(1<<15)
+#define PCICFG_GRC_ADDRESS				0x78
+#define PCICFG_GRC_DATA 				0x80
 #define PCICFG_DEVICE_CONTROL				0xb4
 #define PCICFG_LINK_CONTROL				0xbc
 
-#define PCICFG_COMMAND_IO_SPACE 		    (1<<0)
-#define PCICFG_COMMAND_MEM_SPACE		    (1<<1)
-#define PCICFG_COMMAND_BUS_MASTER		    (1<<2)
-#define PCICFG_COMMAND_SPECIAL_CYCLES		    (1<<3)
-#define PCICFG_COMMAND_MWI_CYCLES		    (1<<4)
-#define PCICFG_COMMAND_VGA_SNOOP		    (1<<5)
-#define PCICFG_COMMAND_PERR_ENA 		    (1<<6)
-#define PCICFG_COMMAND_STEPPING 		    (1<<7)
-#define PCICFG_COMMAND_SERR_ENA 		    (1<<8)
-#define PCICFG_COMMAND_FAST_B2B 		    (1<<9)
-#define PCICFG_COMMAND_INT_DISABLE		    (1<<10)
-#define PCICFG_COMMAND_RESERVED 		    (0x1f<<11)
-
-#define PCICFG_PM_CSR_STATE			    (0x3<<0)
-#define PCICFG_PM_CSR_PME_STATUS		    (1<<15)
 
 #define BAR_USTRORM_INTMEM				0x400000
 #define BAR_CSTRORM_INTMEM				0x410000
 #define BAR_XSTRORM_INTMEM				0x420000
 #define BAR_TSTRORM_INTMEM				0x430000
 
+/* for accessing the IGU in case of status block ACK */
 #define BAR_IGU_INTMEM					0x440000
 
 #define BAR_DOORBELL_OFFSET				0x800000
 
 #define BAR_ME_REGISTER 				0x450000
 
-
-#define GRC_CONFIG_2_SIZE_REG		    0x408 /* config_2 offset */
-#define PCI_CONFIG_2_BAR1_SIZE			    (0xfL<<0)
+/* config_2 offset */
+#define GRC_CONFIG_2_SIZE_REG				0x408
+#define PCI_CONFIG_2_BAR1_SIZE			(0xfL<<0)
 #define PCI_CONFIG_2_BAR1_SIZE_DISABLED 	(0L<<0)
 #define PCI_CONFIG_2_BAR1_SIZE_64K		(1L<<0)
 #define PCI_CONFIG_2_BAR1_SIZE_128K		(2L<<0)
@@ -5237,11 +5252,11 @@
 #define PCI_CONFIG_2_BAR1_SIZE_256M		(13L<<0)
 #define PCI_CONFIG_2_BAR1_SIZE_512M		(14L<<0)
 #define PCI_CONFIG_2_BAR1_SIZE_1G		(15L<<0)
-#define PCI_CONFIG_2_BAR1_64ENA 		    (1L<<4)
-#define PCI_CONFIG_2_EXP_ROM_RETRY		    (1L<<5)
-#define PCI_CONFIG_2_CFG_CYCLE_RETRY		    (1L<<6)
-#define PCI_CONFIG_2_FIRST_CFG_DONE		    (1L<<7)
-#define PCI_CONFIG_2_EXP_ROM_SIZE		    (0xffL<<8)
+#define PCI_CONFIG_2_BAR1_64ENA 		(1L<<4)
+#define PCI_CONFIG_2_EXP_ROM_RETRY		(1L<<5)
+#define PCI_CONFIG_2_CFG_CYCLE_RETRY		(1L<<6)
+#define PCI_CONFIG_2_FIRST_CFG_DONE		(1L<<7)
+#define PCI_CONFIG_2_EXP_ROM_SIZE		(0xffL<<8)
 #define PCI_CONFIG_2_EXP_ROM_SIZE_DISABLED	(0L<<8)
 #define PCI_CONFIG_2_EXP_ROM_SIZE_2K		(1L<<8)
 #define PCI_CONFIG_2_EXP_ROM_SIZE_4K		(2L<<8)
@@ -5258,46 +5273,44 @@
 #define PCI_CONFIG_2_EXP_ROM_SIZE_8M		(13L<<8)
 #define PCI_CONFIG_2_EXP_ROM_SIZE_16M		(14L<<8)
 #define PCI_CONFIG_2_EXP_ROM_SIZE_32M		(15L<<8)
-#define PCI_CONFIG_2_BAR_PREFETCH		    (1L<<16)
-#define PCI_CONFIG_2_RESERVED0			    (0x7fffL<<17)
+#define PCI_CONFIG_2_BAR_PREFETCH		(1L<<16)
+#define PCI_CONFIG_2_RESERVED0			(0x7fffL<<17)
 
 /* config_3 offset */
-#define GRC_CONFIG_3_SIZE_REG				(0x40c)
-#define PCI_CONFIG_3_STICKY_BYTE		    (0xffL<<0)
-#define PCI_CONFIG_3_FORCE_PME			    (1L<<24)
-#define PCI_CONFIG_3_PME_STATUS 		    (1L<<25)
-#define PCI_CONFIG_3_PME_ENABLE 		    (1L<<26)
-#define PCI_CONFIG_3_PM_STATE			    (0x3L<<27)
-#define PCI_CONFIG_3_VAUX_PRESET		    (1L<<30)
-#define PCI_CONFIG_3_PCI_POWER			    (1L<<31)
-
-/* config_2 offset */
-#define GRC_CONFIG_2_SIZE_REG		    0x408
+#define GRC_CONFIG_3_SIZE_REG				0x40c
+#define PCI_CONFIG_3_STICKY_BYTE		(0xffL<<0)
+#define PCI_CONFIG_3_FORCE_PME			(1L<<24)
+#define PCI_CONFIG_3_PME_STATUS 		(1L<<25)
+#define PCI_CONFIG_3_PME_ENABLE 		(1L<<26)
+#define PCI_CONFIG_3_PM_STATE			(0x3L<<27)
+#define PCI_CONFIG_3_VAUX_PRESET		(1L<<30)
+#define PCI_CONFIG_3_PCI_POWER			(1L<<31)
 
 #define GRC_BAR2_CONFIG 				0x4e0
-#define PCI_CONFIG_2_BAR2_SIZE			    (0xfL<<0)
-#define PCI_CONFIG_2_BAR2_SIZE_DISABLED 	    (0L<<0)
-#define PCI_CONFIG_2_BAR2_SIZE_64K		    (1L<<0)
-#define PCI_CONFIG_2_BAR2_SIZE_128K		    (2L<<0)
-#define PCI_CONFIG_2_BAR2_SIZE_256K		    (3L<<0)
-#define PCI_CONFIG_2_BAR2_SIZE_512K		    (4L<<0)
-#define PCI_CONFIG_2_BAR2_SIZE_1M		    (5L<<0)
-#define PCI_CONFIG_2_BAR2_SIZE_2M		    (6L<<0)
-#define PCI_CONFIG_2_BAR2_SIZE_4M		    (7L<<0)
-#define PCI_CONFIG_2_BAR2_SIZE_8M		    (8L<<0)
-#define PCI_CONFIG_2_BAR2_SIZE_16M		    (9L<<0)
-#define PCI_CONFIG_2_BAR2_SIZE_32M		    (10L<<0)
-#define PCI_CONFIG_2_BAR2_SIZE_64M		    (11L<<0)
-#define PCI_CONFIG_2_BAR2_SIZE_128M		    (12L<<0)
-#define PCI_CONFIG_2_BAR2_SIZE_256M		    (13L<<0)
-#define PCI_CONFIG_2_BAR2_SIZE_512M		    (14L<<0)
-#define PCI_CONFIG_2_BAR2_SIZE_1G		    (15L<<0)
-#define PCI_CONFIG_2_BAR2_64ENA 		    (1L<<4)
+#define PCI_CONFIG_2_BAR2_SIZE			(0xfL<<0)
+#define PCI_CONFIG_2_BAR2_SIZE_DISABLED 	(0L<<0)
+#define PCI_CONFIG_2_BAR2_SIZE_64K		(1L<<0)
+#define PCI_CONFIG_2_BAR2_SIZE_128K		(2L<<0)
+#define PCI_CONFIG_2_BAR2_SIZE_256K		(3L<<0)
+#define PCI_CONFIG_2_BAR2_SIZE_512K		(4L<<0)
+#define PCI_CONFIG_2_BAR2_SIZE_1M		(5L<<0)
+#define PCI_CONFIG_2_BAR2_SIZE_2M		(6L<<0)
+#define PCI_CONFIG_2_BAR2_SIZE_4M		(7L<<0)
+#define PCI_CONFIG_2_BAR2_SIZE_8M		(8L<<0)
+#define PCI_CONFIG_2_BAR2_SIZE_16M		(9L<<0)
+#define PCI_CONFIG_2_BAR2_SIZE_32M		(10L<<0)
+#define PCI_CONFIG_2_BAR2_SIZE_64M		(11L<<0)
+#define PCI_CONFIG_2_BAR2_SIZE_128M		(12L<<0)
+#define PCI_CONFIG_2_BAR2_SIZE_256M		(13L<<0)
+#define PCI_CONFIG_2_BAR2_SIZE_512M		(14L<<0)
+#define PCI_CONFIG_2_BAR2_SIZE_1G		(15L<<0)
+#define PCI_CONFIG_2_BAR2_64ENA 		(1L<<4)
+
+#define PCI_PM_DATA_A					0x410
+#define PCI_PM_DATA_B					0x414
+#define PCI_ID_VAL1					0x434
+#define PCI_ID_VAL2					0x438
 
-#define PCI_PM_DATA_A					(0x410)
-#define PCI_PM_DATA_B					(0x414)
-#define PCI_ID_VAL1					(0x434)
-#define PCI_ID_VAL2					(0x438)
 
 #define MDIO_REG_BANK_CL73_IEEEB0			0x0
 #define MDIO_CL73_IEEEB0_CL73_AN_CONTROL		0x0
@@ -5624,4 +5637,13 @@ Theotherbitsarereservedandshouldbezero*/
 #define IGU_INT_NOP				2
 #define IGU_INT_NOP2			3
 
+#define COMMAND_REG_INT_ACK	    0x0
+#define COMMAND_REG_PROD_UPD	    0x4
+#define COMMAND_REG_ATTN_BITS_UPD   0x8
+#define COMMAND_REG_ATTN_BITS_SET   0xc
+#define COMMAND_REG_ATTN_BITS_CLR   0x10
+#define COMMAND_REG_COALESCE_NOW    0x14
+#define COMMAND_REG_SIMD_MASK	    0x18
+#define COMMAND_REG_SIMD_NOMASK     0x1c
+
 
-- 
1.5.3.2




