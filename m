From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 10/41]bnx2x: Flow control enhancement
Date: Thu, 12 Feb 2009 20:36:43 +0200
Message-ID: <1234463803.1863.142.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2939 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755691AbZBLSpH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 13:45:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 10/41]bnx2x: Flow control enhancement
Setting better HW thresholds and enabling FW capabilities for better
enforcement. Also set the HW to more efficiently use the internal buffers if
this is a single port design

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h         |    2 +-
 drivers/net/bnx2x_fw_defs.h |    5 ++
 drivers/net/bnx2x_hsi.h     |   35 ++++++++++++++++
 drivers/net/bnx2x_main.c    |   96 +++++++++++++++++++++++++++++++++++++++----
 drivers/net/bnx2x_reg.h     |   29 +++++++++++++
 5 files changed, 157 insertions(+), 10 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index b40d4f1..8c2124e 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -846,7 +846,7 @@ struct bnx2x {
 	u32			flags;
 #define PCIX_FLAG			1
 #define PCI_32BIT_FLAG			2
-#define ONE_TDMA_FLAG			4	/* no longer used */
+#define ONE_PORT_FLAG			4
 #define NO_WOL_FLAG			8
 #define USING_DAC_FLAG			0x10
 #define USING_MSIX_FLAG			0x20
diff --git a/drivers/net/bnx2x_fw_defs.h b/drivers/net/bnx2x_fw_defs.h
index 59bb132..f6dacb0 100644
--- a/drivers/net/bnx2x_fw_defs.h
+++ b/drivers/net/bnx2x_fw_defs.h
@@ -107,6 +107,9 @@
 #define USTORM_DEF_SB_HOST_STATUS_BLOCK_OFFSET(function) \
 	(IS_E1H_OFFSET ? (0x9508 + ((function>>1) * 0x40) + \
 	((function&1) * 0x100)) : (0x1908 + (function * 0x40)))
+#define USTORM_ETH_RING_PAUSE_DATA_OFFSET(port, clientId) \
+	(IS_E1H_OFFSET ? (0x8020 + (port * 0x4b0) + (clientId * 0x30)) : \
+	0xffffffff)
 #define USTORM_ETH_STATS_QUERY_ADDR_OFFSET(function) \
 	(IS_E1H_OFFSET ? (0x2a50 + (function * 0x8)) : (0x1d98 + \
 	(function * 0x8)))
@@ -120,6 +123,8 @@
 #define USTORM_MEM_WORKAROUND_ADDRESS_OFFSET(function) \
 	(IS_E1H_OFFSET ? (0x2408 + (function * 0x8)) : (0x5308 + \
 	(function * 0x8)))
+#define USTORM_PAUSE_ENABLED_OFFSET(port) \
+	(IS_E1H_OFFSET ? (0x2ad4 + (port * 0x8)) : 0xffffffff)
 #define USTORM_PER_COUNTER_ID_STATS_OFFSET(port, stats_counter_id) \
 	(IS_E1H_OFFSET ? (0x2450 + (port * 0x2d0) + (stats_counter_id * \
 	0x28)) : (0x4740 + (port * 0x2d0) + (stats_counter_id * 0x28)))
diff --git a/drivers/net/bnx2x_hsi.h b/drivers/net/bnx2x_hsi.h
index a4a6039..b0f41d1 100644
--- a/drivers/net/bnx2x_hsi.h
+++ b/drivers/net/bnx2x_hsi.h
@@ -2615,6 +2615,41 @@ struct tstorm_eth_tpa_exist {
 
 
 /*
+ * rx rings pause data for E1h only
+ */
+struct ustorm_eth_rx_pause_data_e1h {
+#if defined(__BIG_ENDIAN)
+	u16 bd_thr_low;
+	u16 cqe_thr_low;
+#elif defined(__LITTLE_ENDIAN)
+	u16 cqe_thr_low;
+	u16 bd_thr_low;
+#endif
+#if defined(__BIG_ENDIAN)
+	u16 cos;
+	u16 sge_thr_low;
+#elif defined(__LITTLE_ENDIAN)
+	u16 sge_thr_low;
+	u16 cos;
+#endif
+#if defined(__BIG_ENDIAN)
+	u16 bd_thr_high;
+	u16 cqe_thr_high;
+#elif defined(__LITTLE_ENDIAN)
+	u16 cqe_thr_high;
+	u16 bd_thr_high;
+#endif
+#if defined(__BIG_ENDIAN)
+	u16 reserved0;
+	u16 sge_thr_high;
+#elif defined(__LITTLE_ENDIAN)
+	u16 sge_thr_high;
+	u16 reserved0;
+#endif
+};
+
+
+/*
  * Three RX producers for ETH
  */
 struct ustorm_eth_rx_producers {
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index ce55e84..77793bb 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -2165,6 +2165,19 @@ static void bnx2x_link_attn(struct bnx2x *bp)
 
 	if (bp->link_vars.link_up) {
 
+		/* dropless flow control */
+		if (CHIP_IS_E1H(bp)) {
+			int port = BP_PORT(bp);
+			u32 pause_enabled = 0;
+
+			if (bp->link_vars.flow_ctrl & BNX2X_FLOW_CTRL_TX)
+				pause_enabled = 1;
+
+			REG_WR(bp, BAR_USTRORM_INTMEM +
+			       USTORM_PAUSE_ENABLED_OFFSET(port),
+			       pause_enabled);
+		}
+
 		if (bp->link_vars.mac_type == MAC_TYPE_BMAC) {
 			struct host_port_stats *pstats;
 
@@ -4909,6 +4922,38 @@ static void bnx2x_init_internal_func(struct bnx2x *bp)
 			 max_agg_size);
 	}
 
+	/* dropless flow control */
+	if (CHIP_IS_E1H(bp)) {
+		struct ustorm_eth_rx_pause_data_e1h rx_pause = {0};
+
+		rx_pause.bd_thr_low = 250;
+		rx_pause.cqe_thr_low = 250;
+		rx_pause.cos = 1;
+		rx_pause.sge_thr_low = 0;
+		rx_pause.bd_thr_high = 350;
+		rx_pause.cqe_thr_high = 350;
+		rx_pause.sge_thr_high = 0;
+
+		for_each_rx_queue(bp, i) {
+			struct bnx2x_fastpath *fp = &bp->fp[i];
+
+			if (!fp->disable_tpa) {
+				rx_pause.sge_thr_low = 150;
+				rx_pause.sge_thr_high = 250;
+			}
+
+
+			offset = BAR_USTRORM_INTMEM +
+				 USTORM_ETH_RING_PAUSE_DATA_OFFSET(port,
+								   fp->cl_id);
+			for (j = 0;
+			     j < sizeof(struct ustorm_eth_rx_pause_data_e1h)/4;
+			     j++)
+				REG_WR(bp, offset + j*4,
+				       ((u32 *)&rx_pause)[j]);
+		}
+	}
+
 	memset(&(bp->cmng), 0, sizeof(struct cmng_struct_per_port));
 
 	/* Init rate shaping and fairness contexts */
@@ -5437,14 +5482,6 @@ static int bnx2x_init_common(struct bnx2x *bp)
 	}
 
 	bnx2x_init_block(bp, BRB1_COMMON_START, BRB1_COMMON_END);
-	if (CHIP_REV_IS_SLOW(bp)) {
-		/* fix for emulation and FPGA for no pause */
-		REG_WR(bp, BRB1_REG_PAUSE_HIGH_THRESHOLD_0, 513);
-		REG_WR(bp, BRB1_REG_PAUSE_HIGH_THRESHOLD_1, 513);
-		REG_WR(bp, BRB1_REG_PAUSE_LOW_THRESHOLD_0, 0);
-		REG_WR(bp, BRB1_REG_PAUSE_LOW_THRESHOLD_1, 0);
-	}
-
 	bnx2x_init_block(bp, PRS_COMMON_START, PRS_COMMON_END);
 	REG_WR(bp, PRS_REG_A_PRSU_20, 0xf);
 	/* set NIC mode */
@@ -5626,6 +5663,7 @@ static int bnx2x_init_common(struct bnx2x *bp)
 static int bnx2x_init_port(struct bnx2x *bp)
 {
 	int port = BP_PORT(bp);
+	u32 low, high;
 	u32 val;
 
 	DP(BNX2X_MSG_MCP, "starting port init  port %x\n", port);
@@ -5672,7 +5710,32 @@ static int bnx2x_init_port(struct bnx2x *bp)
 			     func ? TIMERS_PORT1_END : TIMERS_PORT0_END);
 #endif
 	/* Port DQ comes here */
-	/* Port BRB1 comes here */
+
+	bnx2x_init_block(bp, (port ? BRB1_PORT1_START : BRB1_PORT0_START),
+			     (port ? BRB1_PORT1_END : BRB1_PORT0_END));
+	if (CHIP_REV_IS_SLOW(bp) && !CHIP_IS_E1H(bp)) {
+		/* no pause for emulation and FPGA */
+		low = 0;
+		high = 513;
+	} else {
+		if (IS_E1HMF(bp))
+			low = ((bp->flags & ONE_PORT_FLAG) ? 160 : 246);
+		else if (bp->dev->mtu > 4096) {
+			if (bp->flags & ONE_PORT_FLAG)
+				low = 160;
+			else {
+				val = bp->dev->mtu;
+				/* (24*1024 + val*4)/256 */
+				low = 96 + (val/64) + ((val % 64) ? 1 : 0);
+			}
+		} else
+			low = ((bp->flags & ONE_PORT_FLAG) ? 80 : 160);
+		high = low + 56;	/* 14*1024/256 */
+	}
+	REG_WR(bp, BRB1_REG_PAUSE_LOW_THRESHOLD_0 + port*4, low);
+	REG_WR(bp, BRB1_REG_PAUSE_HIGH_THRESHOLD_0 + port*4, high);
+
+
 	/* Port PRS comes here */
 	/* Port TSDM comes here */
 	/* Port CSDM comes here */
@@ -5754,6 +5817,14 @@ static int bnx2x_init_port(struct bnx2x *bp)
 		REG_WR(bp, NIG_REG_LLH0_BRB1_DRV_MASK_MF + port*4,
 		       (IS_E1HMF(bp) ? 0x1 : 0x2));
 
+		/* support pause requests from USDM, TSDM and BRB */
+		REG_WR(bp, NIG_REG_LLFC_EGRESS_SRC_ENABLE_0 + port*4, 0x7);
+
+		{
+			REG_WR(bp, NIG_REG_LLFC_ENABLE_0 + port*4, 0);
+			REG_WR(bp, NIG_REG_LLFC_OUT_EN_0 + port*4, 0);
+			REG_WR(bp, NIG_REG_PAUSE_ENABLE_0 + port*4, 1);
+		}
 	}
 
 	/* Port MCP comes here */
@@ -7331,6 +7402,13 @@ static void __devinit bnx2x_get_common_hwinfo(struct bnx2x *bp)
 	bp->link_params.chip_id = bp->common.chip_id;
 	BNX2X_DEV_INFO("chip ID is 0x%x\n", id);
 
+	val = (REG_RD(bp, 0x2874) & 0x55);
+	if ((bp->common.chip_id & 0x1) ||
+	    (CHIP_IS_E1(bp) && val) || (CHIP_IS_E1H(bp) && (val == 0x55))) {
+		bp->flags |= ONE_PORT_FLAG;
+		BNX2X_DEV_INFO("single port device\n");
+	}
+
 	val = REG_RD(bp, MCP_REG_MCPR_NVM_CFG4);
 	bp->common.flash_size = (NVRAM_1MB_SIZE <<
 				 (val & MCPR_NVM_CFG4_FLASH_SIZE));
diff --git a/drivers/net/bnx2x_reg.h b/drivers/net/bnx2x_reg.h
index b654d5d..713b5f9 100644
--- a/drivers/net/bnx2x_reg.h
+++ b/drivers/net/bnx2x_reg.h
@@ -30,8 +30,20 @@
    address BRB1_IND_FREE_LIST_PRS_CRDT+1 initialize free tail. At address
    BRB1_IND_FREE_LIST_PRS_CRDT+2 initialize parser initial credit. */
 #define BRB1_REG_FREE_LIST_PRS_CRDT				 0x60200
+/* [RW 10] The number of free blocks above which the High_llfc signal to
+   interface #n is de-asserted. */
+#define BRB1_REG_HIGH_LLFC_HIGH_THRESHOLD_0			 0x6014c
+/* [RW 10] The number of free blocks below which the High_llfc signal to
+   interface #n is asserted. */
+#define BRB1_REG_HIGH_LLFC_LOW_THRESHOLD_0			 0x6013c
 /* [RW 23] LL RAM data. */
 #define BRB1_REG_LL_RAM 					 0x61000
+/* [RW 10] The number of free blocks above which the Low_llfc signal to
+   interface #n is de-asserted. */
+#define BRB1_REG_LOW_LLFC_HIGH_THRESHOLD_0			 0x6016c
+/* [RW 10] The number of free blocks below which the Low_llfc signal to
+   interface #n is asserted. */
+#define BRB1_REG_LOW_LLFC_LOW_THRESHOLD_0			 0x6015c
 /* [R 24] The number of full blocks. */
 #define BRB1_REG_NUM_OF_FULL_BLOCKS				 0x60090
 /* [ST 32] The number of cycles that the write_full signal towards MAC #0
@@ -1684,6 +1696,19 @@
 /* [RW 4] led mode for port0: 0 MAC; 1-3 PHY1; 4 MAC2; 5-7 PHY4; 8-MAC3;
    9-11PHY7; 12 MAC4; 13-15 PHY10; */
 #define NIG_REG_LED_MODE_P0					 0x102f0
+/* [RW 3] for port0 enable for llfc ppp and pause. b0 - brb1 enable; b1-
+   tsdm enable; b2- usdm enable */
+#define NIG_REG_LLFC_EGRESS_SRC_ENABLE_0			 0x16070
+/* [RW 1] SAFC enable for port0. This register may get 1 only when
+   ~ppp_enable.ppp_enable = 0 and pause_enable.pause_enable =0 for the same
+   port */
+#define NIG_REG_LLFC_ENABLE_0					 0x16208
+/* [RW 16] classes are high-priority for port0 */
+#define NIG_REG_LLFC_HIGH_PRIORITY_CLASSES_0			 0x16058
+/* [RW 16] classes are low-priority for port0 */
+#define NIG_REG_LLFC_LOW_PRIORITY_CLASSES_0			 0x16060
+/* [RW 1] Output enable of message to LLFC BMAC IF for port0 */
+#define NIG_REG_LLFC_OUT_EN_0					 0x160c8
 #define NIG_REG_LLH0_ACPI_PAT_0_CRC				 0x1015c
 #define NIG_REG_LLH0_ACPI_PAT_6_LEN				 0x10154
 #define NIG_REG_LLH0_BRB1_DRV_MASK				 0x10244
@@ -1754,6 +1779,10 @@
 #define NIG_REG_NIG_INT_STS_1					 0x103c0
 /* [R 32] Parity register #0 read */
 #define NIG_REG_NIG_PRTY_STS					 0x103d0
+/* [RW 1] Pause enable for port0. This register may get 1 only when
+   ~safc_enable.safc_enable = 0 and ppp_enable.ppp_enable =0 for the same
+   port */
+#define NIG_REG_PAUSE_ENABLE_0					 0x160c0
 /* [RW 1] Input enable for RX PBF LP IF */
 #define NIG_REG_PBF_LB_IN_EN					 0x100b4
 /* [RW 1] Value of this register will be transmitted to port swap when
-- 
1.5.4.3




