From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH net-next 03/12]bnx2x: New link code
Date: Tue, 17 Jun 2008 11:32:44 +0300
Message-ID: <1213691564.5817.62.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Michael Chan" <mchan@broadcom.com>,
	"Yaniv Rosner" <yanivr@broadcom.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2841 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756177AbYFQIdJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 04:33:09 -0400
Received: from mail-irva-8.broadcom.com (mail-irva-8 [10.11.18.52]) by
 mail-irva-10.broadcom.com (Postfix) with ESMTP id 83BAC2B0 for
 <netdev@vger.kernel.org>; Tue, 17 Jun 2008 01:32:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

New Link code:
Moving all the link related code (including the calculations, the
initialization of the MAC and PHY and the external PHY's code) into
a separated file. The changes from the code that used to be part of
bnx2x.c (now called bnx2x_main.c) are:
- Using separate structures for link inputs and link outputs to clearly 
  identify what was configured and what is the outcome
- Adding code to read external PHY FW version and print it as part of 
  ethtool -i
- Adding code to upgrade external PHY FW from ethtool -E with special 
  magic number - Changing the link down indication to ERR level
- Adding a lock on all PHY access to prevent an interrupt and 
  setting changes to overlap
- Adding support for emulation and FPGA (small chunk of code that really 
  helps in the lab) - Adding support for 1G on BCM8706 PHY
- Adding clear debug print incase of fan failure (the PHY type is now 
  "failure")

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eliezer Tamir <eliezert@broadcom.com>
Signed-off-by: Eilong Greenstein <eilong@broadcom.com>
---
 drivers/net/Makefile     |    2 +-
 drivers/net/bnx2x.h      |  180 +---
 drivers/net/bnx2x_init.h |    7 -
 drivers/net/bnx2x_main.c | 3094 +++++-----------------------------------------
 drivers/net/bnx2x_reg.h  | 1938 ++++++++++++++++++++++-------
 5 files changed, 1825 insertions(+), 3396 deletions(-)

diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index e84e771..29c6697 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -67,7 +67,7 @@ obj-$(CONFIG_FEALNX) += fealnx.o
 obj-$(CONFIG_TIGON3) += tg3.o
 obj-$(CONFIG_BNX2) += bnx2.o
 obj-$(CONFIG_BNX2X) += bnx2x.o
-bnx2x-objs := bnx2x_main.o
+bnx2x-objs := bnx2x_main.o bnx2x_link.o
 spidernet-y += spider_net.o spider_net_ethtool.o
 obj-$(CONFIG_SPIDER_NET) += spidernet.o sungem_phy.o
 obj-$(CONFIG_GELIC_NET) += ps3_gelic.o
diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 4f0c0d3..7411025 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -89,6 +89,12 @@
 #define REG_RD_IND(bp, offset)  	bnx2x_reg_rd_ind(bp, offset)
 #define REG_WR_IND(bp, offset, val)     bnx2x_reg_wr_ind(bp, offset, val)
 
+#define REG_RD_DMAE(bp, offset, valp, len32) \
+	do { \
+		bnx2x_read_dmae(bp, offset, len32);\
+		memcpy(valp, bnx2x_sp(bp, wb_data[0]), len32 * 4); \
+	} while (0)
+
 #define REG_WR_DMAE(bp, offset, val, len32) \
 	do { \
 		memcpy(bnx2x_sp(bp, wb_data[0]), val, len32 * 4); \
@@ -541,11 +547,8 @@ struct bnx2x {
 	int     		pm_cap;
 	int     		pcie_cap;
 
-	/* Used to synchronize phy accesses */
-	spinlock_t      	phy_lock;
-
-	struct work_struct      reset_task;
-	struct work_struct      sp_task;
+	struct work_struct	sp_task;
+	struct work_struct	reset_task;
 
 	struct timer_list       timer;
 	int     		timer_interval;
@@ -567,6 +570,8 @@ struct bnx2x {
 #define CHIP_REV_FPGA   		0x0000f000
 #define CHIP_REV_IS_SLOW(bp)    	((CHIP_REV(bp) == CHIP_REV_EMUL) || \
 					 (CHIP_REV(bp) == CHIP_REV_FPGA))
+#define CHIP_REV_IS_EMUL(bp)		(CHIP_REV(bp) == CHIP_REV_EMUL)
+#define CHIP_REV_IS_FPGA(bp)		(CHIP_REV(bp) == CHIP_REV_FPGA)
 
 #define CHIP_METAL(bp)  		(((bp)->chip_id) & 0x00000ff0)
 #define CHIP_BOND_ID(bp)		(((bp)->chip_id) & 0x0000000f)
@@ -577,84 +582,29 @@ struct bnx2x {
 
 	u32     		hw_config;
 	u32			board;
-	u32			serdes_config;
-	u32     		lane_config;
-	u32     		ext_phy_config;
-#define XGXS_EXT_PHY_TYPE(bp)   	(bp->ext_phy_config & \
-					 PORT_HW_CFG_XGXS_EXT_PHY_TYPE_MASK)
-#define SERDES_EXT_PHY_TYPE(bp) 	(bp->ext_phy_config & \
-					 PORT_HW_CFG_SERDES_EXT_PHY_TYPE_MASK)
-
-	u32     		speed_cap_mask;
-	u32     		link_config;
-#define SWITCH_CFG_1G   		PORT_FEATURE_CON_SWITCH_1G_SWITCH
-#define SWITCH_CFG_10G  		PORT_FEATURE_CON_SWITCH_10G_SWITCH
-#define SWITCH_CFG_AUTO_DETECT  	PORT_FEATURE_CON_SWITCH_AUTO_DETECT
-#define SWITCH_CFG_ONE_TIME_DETECT      \
-				PORT_FEATURE_CON_SWITCH_ONE_TIME_DETECT
-
-	u8      		ser_lane;
-	u8      		rx_lane_swap;
-	u8      		tx_lane_swap;
-
-	u8      		link_up;
-	u8			phy_link_up;
+
+	struct link_params	link_params;
+
+	struct link_vars	link_vars;
+
+	u32			link_config;
 
 	u32     		supported;
 /* link settings - missing defines */
 #define SUPPORTED_2500baseT_Full	(1 << 15)
 
-	u32     		phy_flags;
-/*#define PHY_SERDES_FLAG       		0x1*/
-#define PHY_BMAC_FLAG   		0x2
-#define PHY_EMAC_FLAG   		0x4
-#define PHY_XGXS_FLAG   		0x8
-#define PHY_SGMII_FLAG  		0x10
-#define PHY_INT_MODE_MASK_FLAG  	0x300
-#define PHY_INT_MODE_AUTO_POLLING_FLAG  0x100
-#define PHY_INT_MODE_LINK_READY_FLAG    0x200
-
 	u32     		phy_addr;
+
+	/* used to synchronize phy accesses */
+	struct mutex		phy_mutex;
+
 	u32     		phy_id;
 
-	u32     		autoneg;
-#define AUTONEG_CL37    		SHARED_HW_CFG_AN_ENABLE_CL37
-#define AUTONEG_CL73    		SHARED_HW_CFG_AN_ENABLE_CL73
-#define AUTONEG_BAM     		SHARED_HW_CFG_AN_ENABLE_BAM
-#define AUTONEG_PARALLEL		\
-				SHARED_HW_CFG_AN_ENABLE_PARALLEL_DETECTION
-#define AUTONEG_SGMII_FIBER_AUTODET     \
-				SHARED_HW_CFG_AN_EN_SGMII_FIBER_AUTO_DETECT
-#define AUTONEG_REMOTE_PHY      	SHARED_HW_CFG_AN_ENABLE_REMOTE_PHY
-
-	u32     		req_autoneg;
-#define AUTONEG_SPEED   		0x1
-#define AUTONEG_FLOW_CTRL       	0x2
-
-	u32     		req_line_speed;
-/* link settings - missing defines */
-#define SPEED_12000     		12000
-#define SPEED_12500     		12500
-#define SPEED_13000     		13000
-#define SPEED_15000     		15000
-#define SPEED_16000     		16000
-
-	u32     		req_duplex;
-	u32     		req_flow_ctrl;
-#define FLOW_CTRL_AUTO  		PORT_FEATURE_FLOW_CONTROL_AUTO
-#define FLOW_CTRL_TX    		PORT_FEATURE_FLOW_CONTROL_TX
-#define FLOW_CTRL_RX    		PORT_FEATURE_FLOW_CONTROL_RX
-#define FLOW_CTRL_BOTH  		PORT_FEATURE_FLOW_CONTROL_BOTH
-#define FLOW_CTRL_NONE  		PORT_FEATURE_FLOW_CONTROL_NONE
 
 	u32     		advertising;
 /* link settings - missing defines */
 #define ADVERTISED_2500baseT_Full       (1 << 15)
 
-	u32     		link_status;
-	u32     		line_speed;
-	u32     		duplex;
-	u32     		flow_ctrl;
 
 	u32     		bc_ver;
 
@@ -764,6 +714,11 @@ struct bnx2x {
 
 #define DMAE_LEN32_MAX  		0x400
 
+void bnx2x_read_dmae(struct bnx2x *bp, u32 src_addr, u32 len32);
+void bnx2x_write_dmae(struct bnx2x *bp, dma_addr_t dma_addr, u32 dst_addr,
+		      u32 len32);
+int bnx2x_set_gpio(struct bnx2x *bp, int gpio_num, u32 mode);
+
 
 /* MC hsi */
 #define RX_COPY_THRESH  		92
@@ -889,91 +844,6 @@ struct bnx2x {
 			 (1 << PARSING_FLAGS_OVER_ETHERNET_PROTOCOL_SHIFT))
 
 
-#define MDIO_AN_CL73_OR_37_COMPLETE \
-		(MDIO_GP_STATUS_TOP_AN_STATUS1_CL73_AUTONEG_COMPLETE | \
-		 MDIO_GP_STATUS_TOP_AN_STATUS1_CL37_AUTONEG_COMPLETE)
-
-#define GP_STATUS_PAUSE_RSOLUTION_TXSIDE \
-			MDIO_GP_STATUS_TOP_AN_STATUS1_PAUSE_RSOLUTION_TXSIDE
-#define GP_STATUS_PAUSE_RSOLUTION_RXSIDE \
-			MDIO_GP_STATUS_TOP_AN_STATUS1_PAUSE_RSOLUTION_RXSIDE
-#define GP_STATUS_SPEED_MASK \
-			MDIO_GP_STATUS_TOP_AN_STATUS1_ACTUAL_SPEED_MASK
-#define GP_STATUS_10M   MDIO_GP_STATUS_TOP_AN_STATUS1_ACTUAL_SPEED_10M
-#define GP_STATUS_100M  MDIO_GP_STATUS_TOP_AN_STATUS1_ACTUAL_SPEED_100M
-#define GP_STATUS_1G    MDIO_GP_STATUS_TOP_AN_STATUS1_ACTUAL_SPEED_1G
-#define GP_STATUS_2_5G  MDIO_GP_STATUS_TOP_AN_STATUS1_ACTUAL_SPEED_2_5G
-#define GP_STATUS_5G    MDIO_GP_STATUS_TOP_AN_STATUS1_ACTUAL_SPEED_5G
-#define GP_STATUS_6G    MDIO_GP_STATUS_TOP_AN_STATUS1_ACTUAL_SPEED_6G
-#define GP_STATUS_10G_HIG \
-			MDIO_GP_STATUS_TOP_AN_STATUS1_ACTUAL_SPEED_10G_HIG
-#define GP_STATUS_10G_CX4 \
-			MDIO_GP_STATUS_TOP_AN_STATUS1_ACTUAL_SPEED_10G_CX4
-#define GP_STATUS_12G_HIG \
-			MDIO_GP_STATUS_TOP_AN_STATUS1_ACTUAL_SPEED_12G_HIG
-#define GP_STATUS_12_5G MDIO_GP_STATUS_TOP_AN_STATUS1_ACTUAL_SPEED_12_5G
-#define GP_STATUS_13G   MDIO_GP_STATUS_TOP_AN_STATUS1_ACTUAL_SPEED_13G
-#define GP_STATUS_15G   MDIO_GP_STATUS_TOP_AN_STATUS1_ACTUAL_SPEED_15G
-#define GP_STATUS_16G   MDIO_GP_STATUS_TOP_AN_STATUS1_ACTUAL_SPEED_16G
-#define GP_STATUS_1G_KX MDIO_GP_STATUS_TOP_AN_STATUS1_ACTUAL_SPEED_1G_KX
-#define GP_STATUS_10G_KX4 \
-			MDIO_GP_STATUS_TOP_AN_STATUS1_ACTUAL_SPEED_10G_KX4
-
-#define LINK_10THD      		LINK_STATUS_SPEED_AND_DUPLEX_10THD
-#define LINK_10TFD      		LINK_STATUS_SPEED_AND_DUPLEX_10TFD
-#define LINK_100TXHD    		LINK_STATUS_SPEED_AND_DUPLEX_100TXHD
-#define LINK_100T4      		LINK_STATUS_SPEED_AND_DUPLEX_100T4
-#define LINK_100TXFD    		LINK_STATUS_SPEED_AND_DUPLEX_100TXFD
-#define LINK_1000THD    		LINK_STATUS_SPEED_AND_DUPLEX_1000THD
-#define LINK_1000TFD    		LINK_STATUS_SPEED_AND_DUPLEX_1000TFD
-#define LINK_1000XFD    		LINK_STATUS_SPEED_AND_DUPLEX_1000XFD
-#define LINK_2500THD    		LINK_STATUS_SPEED_AND_DUPLEX_2500THD
-#define LINK_2500TFD    		LINK_STATUS_SPEED_AND_DUPLEX_2500TFD
-#define LINK_2500XFD    		LINK_STATUS_SPEED_AND_DUPLEX_2500XFD
-#define LINK_10GTFD     		LINK_STATUS_SPEED_AND_DUPLEX_10GTFD
-#define LINK_10GXFD     		LINK_STATUS_SPEED_AND_DUPLEX_10GXFD
-#define LINK_12GTFD     		LINK_STATUS_SPEED_AND_DUPLEX_12GTFD
-#define LINK_12GXFD     		LINK_STATUS_SPEED_AND_DUPLEX_12GXFD
-#define LINK_12_5GTFD   		LINK_STATUS_SPEED_AND_DUPLEX_12_5GTFD
-#define LINK_12_5GXFD   		LINK_STATUS_SPEED_AND_DUPLEX_12_5GXFD
-#define LINK_13GTFD     		LINK_STATUS_SPEED_AND_DUPLEX_13GTFD
-#define LINK_13GXFD     		LINK_STATUS_SPEED_AND_DUPLEX_13GXFD
-#define LINK_15GTFD     		LINK_STATUS_SPEED_AND_DUPLEX_15GTFD
-#define LINK_15GXFD     		LINK_STATUS_SPEED_AND_DUPLEX_15GXFD
-#define LINK_16GTFD     		LINK_STATUS_SPEED_AND_DUPLEX_16GTFD
-#define LINK_16GXFD     		LINK_STATUS_SPEED_AND_DUPLEX_16GXFD
-
-#define NIG_STATUS_XGXS0_LINK10G \
-		NIG_STATUS_INTERRUPT_PORT0_REG_STATUS_XGXS0_LINK10G
-#define NIG_STATUS_XGXS0_LINK_STATUS \
-		NIG_STATUS_INTERRUPT_PORT0_REG_STATUS_XGXS0_LINK_STATUS
-#define NIG_STATUS_XGXS0_LINK_STATUS_SIZE \
-		NIG_STATUS_INTERRUPT_PORT0_REG_STATUS_XGXS0_LINK_STATUS_SIZE
-#define NIG_STATUS_SERDES0_LINK_STATUS \
-		NIG_STATUS_INTERRUPT_PORT0_REG_STATUS_SERDES0_LINK_STATUS
-#define NIG_MASK_MI_INT \
-		NIG_MASK_INTERRUPT_PORT0_REG_MASK_EMAC0_MISC_MI_INT
-#define NIG_MASK_XGXS0_LINK10G \
-		NIG_MASK_INTERRUPT_PORT0_REG_MASK_XGXS0_LINK10G
-#define NIG_MASK_XGXS0_LINK_STATUS \
-		NIG_MASK_INTERRUPT_PORT0_REG_MASK_XGXS0_LINK_STATUS
-#define NIG_MASK_SERDES0_LINK_STATUS \
-		NIG_MASK_INTERRUPT_PORT0_REG_MASK_SERDES0_LINK_STATUS
-
-#define XGXS_RESET_BITS \
-	(MISC_REGISTERS_RESET_REG_3_MISC_NIG_MUX_XGXS0_RSTB_HW |   \
-	 MISC_REGISTERS_RESET_REG_3_MISC_NIG_MUX_XGXS0_IDDQ |      \
-	 MISC_REGISTERS_RESET_REG_3_MISC_NIG_MUX_XGXS0_PWRDWN |    \
-	 MISC_REGISTERS_RESET_REG_3_MISC_NIG_MUX_XGXS0_PWRDWN_SD | \
-	 MISC_REGISTERS_RESET_REG_3_MISC_NIG_MUX_XGXS0_TXD_FIFO_RSTB)
-
-#define SERDES_RESET_BITS \
-	(MISC_REGISTERS_RESET_REG_3_MISC_NIG_MUX_SERDES0_RSTB_HW | \
-	 MISC_REGISTERS_RESET_REG_3_MISC_NIG_MUX_SERDES0_IDDQ |    \
-	 MISC_REGISTERS_RESET_REG_3_MISC_NIG_MUX_SERDES0_PWRDWN |  \
-	 MISC_REGISTERS_RESET_REG_3_MISC_NIG_MUX_SERDES0_PWRDWN_SD)
-
-
 #define BNX2X_MC_ASSERT_BITS \
 	(GENERAL_ATTEN_OFFSET(TSTORM_FATAL_ASSERT_ATTENTION_BIT) | \
 	 GENERAL_ATTEN_OFFSET(USTORM_FATAL_ASSERT_ATTENTION_BIT) | \
diff --git a/drivers/net/bnx2x_init.h b/drivers/net/bnx2x_init.h
index dcaecc5..2771386 100644
--- a/drivers/net/bnx2x_init.h
+++ b/drivers/net/bnx2x_init.h
@@ -86,10 +86,6 @@ union init_op {
 #include "bnx2x_init_values.h"
 
 static void bnx2x_reg_wr_ind(struct bnx2x *bp, u32 addr, u32 val);
-
-static void bnx2x_write_dmae(struct bnx2x *bp, dma_addr_t dma_addr,
-			     u32 dst_addr, u32 len32);
-
 static int bnx2x_gunzip(struct bnx2x *bp, u8 *zbuf, int len);
 
 static void bnx2x_init_str_wr(struct bnx2x *bp, u32 addr, const u32 *data,
@@ -106,9 +102,6 @@ static void bnx2x_init_str_wr(struct bnx2x *bp, u32 addr, const u32 *data,
 	}
 }
 
-#define INIT_MEM_WR(reg, data, reg_off, len) \
-	bnx2x_init_str_wr(bp, reg + reg_off*4, data, len)
-
 static void bnx2x_init_ind_wr(struct bnx2x *bp, u32 addr, const u32 *data,
 			      u16 len)
 {
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 7bdb5af..9d1f730 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -60,6 +60,7 @@
 #include "bnx2x_reg.h"
 #include "bnx2x_fw_defs.h"
 #include "bnx2x_hsi.h"
+#include "bnx2x_link.h"
 #include "bnx2x.h"
 #include "bnx2x_init.h"
 
@@ -173,7 +174,7 @@ static void bnx2x_post_dmae(struct bnx2x *bp, struct dmae_command *dmae,
 	REG_WR(bp, dmae_reg_go_c[idx], 1);
 }
 
-static void bnx2x_write_dmae(struct bnx2x *bp, dma_addr_t dma_addr,
+void bnx2x_write_dmae(struct bnx2x *bp, dma_addr_t dma_addr,
 			     u32 dst_addr, u32 len32)
 {
 	struct dmae_command *dmae = &bp->dmae;
@@ -235,8 +236,7 @@ static void bnx2x_write_dmae(struct bnx2x *bp, dma_addr_t dma_addr,
 	}
 }
 
-#ifdef BNX2X_DMAE_RD
-static void bnx2x_read_dmae(struct bnx2x *bp, u32 src_addr, u32 len32)
+void bnx2x_read_dmae(struct bnx2x *bp, u32 src_addr, u32 len32)
 {
 	struct dmae_command *dmae = &bp->dmae;
 	int port = bp->port;
@@ -293,7 +293,6 @@ static void bnx2x_read_dmae(struct bnx2x *bp, u32 src_addr, u32 len32)
 	   bp->slowpath->wb_data[2], bp->slowpath->wb_data[3]);
 */
 }
-#endif
 
 static int bnx2x_mc_assert(struct bnx2x *bp)
 {
@@ -1134,67 +1133,19 @@ static irqreturn_t bnx2x_interrupt(int irq, void *dev_instance)
 
 /* end of fast path */
 
-/* PHY/MAC */
+
+/* Link */
 
 /*
  * General service functions
  */
 
-static void bnx2x_leds_set(struct bnx2x *bp, unsigned int speed)
-{
-	int port = bp->port;
-
-	NIG_WR(NIG_REG_LED_MODE_P0 + port*4,
-	       ((bp->hw_config & SHARED_HW_CFG_LED_MODE_MASK) >>
-		SHARED_HW_CFG_LED_MODE_SHIFT));
-	NIG_WR(NIG_REG_LED_CONTROL_OVERRIDE_TRAFFIC_P0 + port*4, 0);
-
-	/* Set blinking rate to ~15.9Hz */
-	NIG_WR(NIG_REG_LED_CONTROL_BLINK_RATE_P0 + port*4,
-	       LED_BLINK_RATE_VAL);
-	NIG_WR(NIG_REG_LED_CONTROL_BLINK_RATE_ENA_P0 + port*4, 1);
-
-	/* On Ax chip versions for speeds less than 10G
-	   LED scheme is different */
-	if ((CHIP_REV(bp) == CHIP_REV_Ax) && (speed < SPEED_10000)) {
-		NIG_WR(NIG_REG_LED_CONTROL_OVERRIDE_TRAFFIC_P0 + port*4, 1);
-		NIG_WR(NIG_REG_LED_CONTROL_TRAFFIC_P0 + port*4, 0);
-		NIG_WR(NIG_REG_LED_CONTROL_BLINK_TRAFFIC_P0 + port*4, 1);
-	}
-}
-
-static void bnx2x_leds_unset(struct bnx2x *bp)
-{
-	int port = bp->port;
-
-	NIG_WR(NIG_REG_LED_10G_P0 + port*4, 0);
-	NIG_WR(NIG_REG_LED_MODE_P0 + port*4, SHARED_HW_CFG_LED_MAC1);
-}
-
-static u32 bnx2x_bits_en(struct bnx2x *bp, u32 reg, u32 bits)
-{
-	u32 val = REG_RD(bp, reg);
-
-	val |= bits;
-	REG_WR(bp, reg, val);
-	return val;
-}
-
-static u32 bnx2x_bits_dis(struct bnx2x *bp, u32 reg, u32 bits)
-{
-	u32 val = REG_RD(bp, reg);
-
-	val &= ~bits;
-	REG_WR(bp, reg, val);
-	return val;
-}
-
 static int bnx2x_hw_lock(struct bnx2x *bp, u32 resource)
 {
-	u32 cnt;
 	u32 lock_status;
 	u32 resource_bit = (1 << resource);
-	u8 func = bp->port;
+	u8 port = bp->port;
+	int cnt;
 
 	/* Validating that the resource is within range */
 	if (resource > HW_LOCK_MAX_RESOURCE_VALUE) {
@@ -1205,7 +1156,7 @@ static int bnx2x_hw_lock(struct bnx2x *bp, u32 resource)
 	}
 
 	/* Validating that the resource is not already taken */
-	lock_status = REG_RD(bp, MISC_REG_DRIVER_CONTROL_1 + func*8);
+	lock_status = REG_RD(bp, MISC_REG_DRIVER_CONTROL_1 + port*8);
 	if (lock_status & resource_bit) {
 		DP(NETIF_MSG_HW, "lock_status 0x%x  resource_bit 0x%x\n",
 		   lock_status, resource_bit);
@@ -1215,9 +1166,9 @@ static int bnx2x_hw_lock(struct bnx2x *bp, u32 resource)
 	/* Try for 1 second every 5ms */
 	for (cnt = 0; cnt < 200; cnt++) {
 		/* Try to acquire the lock */
-		REG_WR(bp, MISC_REG_DRIVER_CONTROL_1 + func*8 + 4,
+		REG_WR(bp, MISC_REG_DRIVER_CONTROL_1 + port*8 + 4,
 		       resource_bit);
-		lock_status = REG_RD(bp, MISC_REG_DRIVER_CONTROL_1 + func*8);
+		lock_status = REG_RD(bp, MISC_REG_DRIVER_CONTROL_1 + port*8);
 		if (lock_status & resource_bit)
 			return 0;
 
@@ -1231,7 +1182,7 @@ static int bnx2x_hw_unlock(struct bnx2x *bp, u32 resource)
 {
 	u32 lock_status;
 	u32 resource_bit = (1 << resource);
-	u8 func = bp->port;
+	u8 port = bp->port;
 
 	/* Validating that the resource is within range */
 	if (resource > HW_LOCK_MAX_RESOURCE_VALUE) {
@@ -1242,18 +1193,41 @@ static int bnx2x_hw_unlock(struct bnx2x *bp, u32 resource)
 	}
 
 	/* Validating that the resource is currently taken */
-	lock_status = REG_RD(bp, MISC_REG_DRIVER_CONTROL_1 + func*8);
+	lock_status = REG_RD(bp, MISC_REG_DRIVER_CONTROL_1 + port*8);
 	if (!(lock_status & resource_bit)) {
 		DP(NETIF_MSG_HW, "lock_status 0x%x  resource_bit 0x%x\n",
 		   lock_status, resource_bit);
 		return -EFAULT;
 	}
 
-	REG_WR(bp, MISC_REG_DRIVER_CONTROL_1 + func*8, resource_bit);
+	REG_WR(bp, MISC_REG_DRIVER_CONTROL_1 + port*8, resource_bit);
 	return 0;
 }
 
-static int bnx2x_set_gpio(struct bnx2x *bp, int gpio_num, u32 mode)
+/* HW Lock for shared dual port PHYs */
+static void bnx2x_phy_hw_lock(struct bnx2x *bp)
+{
+	u32 ext_phy_type = XGXS_EXT_PHY_TYPE(bp->link_params.ext_phy_config);
+
+	mutex_lock(&bp->phy_mutex);
+
+	if ((ext_phy_type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072) ||
+	    (ext_phy_type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073))
+		bnx2x_hw_lock(bp, HW_LOCK_RESOURCE_8072_MDIO);
+}
+
+static void bnx2x_phy_hw_unlock(struct bnx2x *bp)
+{
+	u32 ext_phy_type = XGXS_EXT_PHY_TYPE(bp->link_params.ext_phy_config);
+
+	if ((ext_phy_type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072) ||
+	    (ext_phy_type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073))
+		bnx2x_hw_unlock(bp, HW_LOCK_RESOURCE_8072_MDIO);
+
+	mutex_unlock(&bp->phy_mutex);
+}
+
+int bnx2x_set_gpio(struct bnx2x *bp, int gpio_num, u32 mode)
 {
 	/* The GPIO should be swapped if swap register is set and active */
 	int gpio_port = (REG_RD(bp, NIG_REG_PORT_SWAP) &&
@@ -1352,1281 +1326,45 @@ static int bnx2x_set_spio(struct bnx2x *bp, int spio_num, u32 mode)
 	return 0;
 }
 
-static int bnx2x_mdio22_write(struct bnx2x *bp, u32 reg, u32 val)
-{
-	int port = bp->port;
-	u32 emac_base = port ? GRCBASE_EMAC1 : GRCBASE_EMAC0;
-	u32 tmp;
-	int i, rc;
-
-/*      DP(NETIF_MSG_HW, "phy_addr 0x%x  reg 0x%x  val 0x%08x\n",
-	   bp->phy_addr, reg, val); */
-
-	if (bp->phy_flags & PHY_INT_MODE_AUTO_POLLING_FLAG) {
-
-		tmp = REG_RD(bp, emac_base + EMAC_REG_EMAC_MDIO_MODE);
-		tmp &= ~EMAC_MDIO_MODE_AUTO_POLL;
-		EMAC_WR(EMAC_REG_EMAC_MDIO_MODE, tmp);
-		REG_RD(bp, emac_base + EMAC_REG_EMAC_MDIO_MODE);
-		udelay(40);
-	}
-
-	tmp = ((bp->phy_addr << 21) | (reg << 16) |
-	       (val & EMAC_MDIO_COMM_DATA) |
-	       EMAC_MDIO_COMM_COMMAND_WRITE_22 |
-	       EMAC_MDIO_COMM_START_BUSY);
-	EMAC_WR(EMAC_REG_EMAC_MDIO_COMM, tmp);
-
-	for (i = 0; i < 50; i++) {
-		udelay(10);
-
-		tmp = REG_RD(bp, emac_base + EMAC_REG_EMAC_MDIO_COMM);
-		if (!(tmp & EMAC_MDIO_COMM_START_BUSY)) {
-			udelay(5);
-			break;
-		}
-	}
-
-	if (tmp & EMAC_MDIO_COMM_START_BUSY) {
-		BNX2X_ERR("write phy register failed\n");
-
-		rc = -EBUSY;
-	} else {
-		rc = 0;
-	}
-
-	if (bp->phy_flags & PHY_INT_MODE_AUTO_POLLING_FLAG) {
-
-		tmp = REG_RD(bp, emac_base + EMAC_REG_EMAC_MDIO_MODE);
-		tmp |= EMAC_MDIO_MODE_AUTO_POLL;
-		EMAC_WR(EMAC_REG_EMAC_MDIO_MODE, tmp);
-	}
-
-	return rc;
-}
-
-static int bnx2x_mdio22_read(struct bnx2x *bp, u32 reg, u32 *ret_val)
-{
-	int port = bp->port;
-	u32 emac_base = port ? GRCBASE_EMAC1 : GRCBASE_EMAC0;
-	u32 val;
-	int i, rc;
-
-	if (bp->phy_flags & PHY_INT_MODE_AUTO_POLLING_FLAG) {
-
-		val = REG_RD(bp, emac_base + EMAC_REG_EMAC_MDIO_MODE);
-		val &= ~EMAC_MDIO_MODE_AUTO_POLL;
-		EMAC_WR(EMAC_REG_EMAC_MDIO_MODE, val);
-		REG_RD(bp, emac_base + EMAC_REG_EMAC_MDIO_MODE);
-		udelay(40);
-	}
-
-	val = ((bp->phy_addr << 21) | (reg << 16) |
-	       EMAC_MDIO_COMM_COMMAND_READ_22 |
-	       EMAC_MDIO_COMM_START_BUSY);
-	EMAC_WR(EMAC_REG_EMAC_MDIO_COMM, val);
-
-	for (i = 0; i < 50; i++) {
-		udelay(10);
-
-		val = REG_RD(bp, emac_base + EMAC_REG_EMAC_MDIO_COMM);
-		if (!(val & EMAC_MDIO_COMM_START_BUSY)) {
-			val &= EMAC_MDIO_COMM_DATA;
-			break;
-		}
-	}
-
-	if (val & EMAC_MDIO_COMM_START_BUSY) {
-		BNX2X_ERR("read phy register failed\n");
-
-		*ret_val = 0x0;
-		rc = -EBUSY;
-	} else {
-		*ret_val = val;
-		rc = 0;
-	}
-
-	if (bp->phy_flags & PHY_INT_MODE_AUTO_POLLING_FLAG) {
-
-		val = REG_RD(bp, emac_base + EMAC_REG_EMAC_MDIO_MODE);
-		val |= EMAC_MDIO_MODE_AUTO_POLL;
-		EMAC_WR(EMAC_REG_EMAC_MDIO_MODE, val);
-	}
-
-/*      DP(NETIF_MSG_HW, "phy_addr 0x%x  reg 0x%x  ret_val 0x%08x\n",
-	   bp->phy_addr, reg, *ret_val); */
-
-	return rc;
-}
-
-static int bnx2x_mdio45_ctrl_write(struct bnx2x *bp, u32 mdio_ctrl,
-				   u32 phy_addr, u32 reg, u32 addr, u32 val)
-{
-	u32 tmp;
-	int i, rc = 0;
-
-	/* set clause 45 mode, slow down the MDIO clock to 2.5MHz
-	 * (a value of 49==0x31) and make sure that the AUTO poll is off
-	 */
-	tmp = REG_RD(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE);
-	tmp &= ~(EMAC_MDIO_MODE_AUTO_POLL | EMAC_MDIO_MODE_CLOCK_CNT);
-	tmp |= (EMAC_MDIO_MODE_CLAUSE_45 |
-		(49 << EMAC_MDIO_MODE_CLOCK_CNT_BITSHIFT));
-	REG_WR(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE, tmp);
-	REG_RD(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE);
-	udelay(40);
-
-	/* address */
-	tmp = ((phy_addr << 21) | (reg << 16) | addr |
-	       EMAC_MDIO_COMM_COMMAND_ADDRESS |
-	       EMAC_MDIO_COMM_START_BUSY);
-	REG_WR(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_COMM, tmp);
-
-	for (i = 0; i < 50; i++) {
-		udelay(10);
-
-		tmp = REG_RD(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_COMM);
-		if (!(tmp & EMAC_MDIO_COMM_START_BUSY)) {
-			udelay(5);
-			break;
-		}
-	}
-	if (tmp & EMAC_MDIO_COMM_START_BUSY) {
-		BNX2X_ERR("write phy register failed\n");
-
-		rc = -EBUSY;
-
-	} else {
-		/* data */
-		tmp = ((phy_addr << 21) | (reg << 16) | val |
-		       EMAC_MDIO_COMM_COMMAND_WRITE_45 |
-		       EMAC_MDIO_COMM_START_BUSY);
-		REG_WR(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_COMM, tmp);
-
-		for (i = 0; i < 50; i++) {
-			udelay(10);
-
-			tmp = REG_RD(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_COMM);
-			if (!(tmp & EMAC_MDIO_COMM_START_BUSY)) {
-				udelay(5);
-				break;
-			}
-		}
-
-		if (tmp & EMAC_MDIO_COMM_START_BUSY) {
-			BNX2X_ERR("write phy register failed\n");
-
-			rc = -EBUSY;
-		}
-	}
-
-	/* unset clause 45 mode, set the MDIO clock to a faster value
-	 * (0x13 => 6.25Mhz) and restore the AUTO poll if needed
-	 */
-	tmp = REG_RD(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE);
-	tmp &= ~(EMAC_MDIO_MODE_CLAUSE_45 | EMAC_MDIO_MODE_CLOCK_CNT);
-	tmp |= (0x13 << EMAC_MDIO_MODE_CLOCK_CNT_BITSHIFT);
-	if (bp->phy_flags & PHY_INT_MODE_AUTO_POLLING_FLAG)
-		tmp |= EMAC_MDIO_MODE_AUTO_POLL;
-	REG_WR(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE, tmp);
-
-	return rc;
-}
-
-static int bnx2x_mdio45_write(struct bnx2x *bp, u32 phy_addr, u32 reg,
-			      u32 addr, u32 val)
-{
-	u32 emac_base = bp->port ? GRCBASE_EMAC1 : GRCBASE_EMAC0;
-
-	return bnx2x_mdio45_ctrl_write(bp, emac_base, phy_addr,
-				       reg, addr, val);
-}
-
-static int bnx2x_mdio45_ctrl_read(struct bnx2x *bp, u32 mdio_ctrl,
-				  u32 phy_addr, u32 reg, u32 addr,
-				  u32 *ret_val)
-{
-	u32 val;
-	int i, rc = 0;
-
-	/* set clause 45 mode, slow down the MDIO clock to 2.5MHz
-	 * (a value of 49==0x31) and make sure that the AUTO poll is off
-	 */
-	val = REG_RD(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE);
-	val &= ~(EMAC_MDIO_MODE_AUTO_POLL | EMAC_MDIO_MODE_CLOCK_CNT);
-	val |= (EMAC_MDIO_MODE_CLAUSE_45 |
-		(49 << EMAC_MDIO_MODE_CLOCK_CNT_BITSHIFT));
-	REG_WR(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE, val);
-	REG_RD(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE);
-	udelay(40);
-
-	/* address */
-	val = ((phy_addr << 21) | (reg << 16) | addr |
-	       EMAC_MDIO_COMM_COMMAND_ADDRESS |
-	       EMAC_MDIO_COMM_START_BUSY);
-	REG_WR(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_COMM, val);
-
-	for (i = 0; i < 50; i++) {
-		udelay(10);
-
-		val = REG_RD(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_COMM);
-		if (!(val & EMAC_MDIO_COMM_START_BUSY)) {
-			udelay(5);
-			break;
-		}
-	}
-	if (val & EMAC_MDIO_COMM_START_BUSY) {
-		BNX2X_ERR("read phy register failed\n");
-
-		*ret_val = 0;
-		rc = -EBUSY;
-
-	} else {
-		/* data */
-		val = ((phy_addr << 21) | (reg << 16) |
-		       EMAC_MDIO_COMM_COMMAND_READ_45 |
-		       EMAC_MDIO_COMM_START_BUSY);
-		REG_WR(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_COMM, val);
-
-		for (i = 0; i < 50; i++) {
-			udelay(10);
-
-			val = REG_RD(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_COMM);
-			if (!(val & EMAC_MDIO_COMM_START_BUSY)) {
-				val &= EMAC_MDIO_COMM_DATA;
-				break;
-			}
-		}
-
-		if (val & EMAC_MDIO_COMM_START_BUSY) {
-			BNX2X_ERR("read phy register failed\n");
-
-			val = 0;
-			rc = -EBUSY;
-		}
-
-		*ret_val = val;
-	}
-
-	/* unset clause 45 mode, set the MDIO clock to a faster value
-	 * (0x13 => 6.25Mhz) and restore the AUTO poll if needed
-	 */
-	val = REG_RD(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE);
-	val &= ~(EMAC_MDIO_MODE_CLAUSE_45 | EMAC_MDIO_MODE_CLOCK_CNT);
-	val |= (0x13 << EMAC_MDIO_MODE_CLOCK_CNT_BITSHIFT);
-	if (bp->phy_flags & PHY_INT_MODE_AUTO_POLLING_FLAG)
-		val |= EMAC_MDIO_MODE_AUTO_POLL;
-	REG_WR(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE, val);
-
-	return rc;
-}
-
-static int bnx2x_mdio45_read(struct bnx2x *bp, u32 phy_addr, u32 reg,
-			     u32 addr, u32 *ret_val)
-{
-	u32 emac_base = bp->port ? GRCBASE_EMAC1 : GRCBASE_EMAC0;
-
-	return bnx2x_mdio45_ctrl_read(bp, emac_base, phy_addr,
-				      reg, addr, ret_val);
-}
-
-static int bnx2x_mdio45_vwrite(struct bnx2x *bp, u32 phy_addr, u32 reg,
-			       u32 addr, u32 val)
-{
-	int i;
-	u32 rd_val;
-
-	might_sleep();
-	for (i = 0; i < 10; i++) {
-		bnx2x_mdio45_write(bp, phy_addr, reg, addr, val);
-		msleep(5);
-		bnx2x_mdio45_read(bp, phy_addr, reg, addr, &rd_val);
-		/* if the read value is not the same as the value we wrote,
-		   we should write it again */
-		if (rd_val == val)
-			return 0;
-	}
-	BNX2X_ERR("MDIO write in CL45 failed\n");
-	return -EBUSY;
-}
-
-/*
- * link management
- */
-
-static void bnx2x_pause_resolve(struct bnx2x *bp, u32 pause_result)
-{
-	switch (pause_result) {			/* ASYM P ASYM P */
-	case 0xb:				/*   1  0   1  1 */
-		bp->flow_ctrl = FLOW_CTRL_TX;
-		break;
-
-	case 0xe:				/*   1  1   1  0 */
-		bp->flow_ctrl = FLOW_CTRL_RX;
-		break;
-
-	case 0x5:				/*   0  1   0  1 */
-	case 0x7:				/*   0  1   1  1 */
-	case 0xd:				/*   1  1   0  1 */
-	case 0xf:				/*   1  1   1  1 */
-		bp->flow_ctrl = FLOW_CTRL_BOTH;
-		break;
-
-	default:
-		break;
-	}
-}
-
-static u8 bnx2x_ext_phy_resove_fc(struct bnx2x *bp)
-{
-	u32 ext_phy_addr;
-	u32 ld_pause;	/* local */
-	u32 lp_pause;	/* link partner */
-	u32 an_complete; /* AN complete */
-	u32 pause_result;
-	u8 ret = 0;
-
-	ext_phy_addr = ((bp->ext_phy_config &
-			 PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
-					PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT);
-
-	/* read twice */
-	bnx2x_mdio45_read(bp, ext_phy_addr,
-			  EXT_PHY_KR_AUTO_NEG_DEVAD,
-			  EXT_PHY_KR_STATUS, &an_complete);
-	bnx2x_mdio45_read(bp, ext_phy_addr,
-			  EXT_PHY_KR_AUTO_NEG_DEVAD,
-			  EXT_PHY_KR_STATUS, &an_complete);
-
-	if (an_complete & EXT_PHY_KR_AUTO_NEG_COMPLETE) {
-		ret = 1;
-		bnx2x_mdio45_read(bp, ext_phy_addr,
-				  EXT_PHY_KR_AUTO_NEG_DEVAD,
-				  EXT_PHY_KR_AUTO_NEG_ADVERT, &ld_pause);
-		bnx2x_mdio45_read(bp, ext_phy_addr,
-				  EXT_PHY_KR_AUTO_NEG_DEVAD,
-				  EXT_PHY_KR_LP_AUTO_NEG, &lp_pause);
-		pause_result = (ld_pause &
-				EXT_PHY_KR_AUTO_NEG_ADVERT_PAUSE_MASK) >> 8;
-		pause_result |= (lp_pause &
-				 EXT_PHY_KR_AUTO_NEG_ADVERT_PAUSE_MASK) >> 10;
-		DP(NETIF_MSG_LINK, "Ext PHY pause result 0x%x \n",
-		   pause_result);
-		bnx2x_pause_resolve(bp, pause_result);
-	}
-	return ret;
-}
-
-static void bnx2x_flow_ctrl_resolve(struct bnx2x *bp, u32 gp_status)
-{
-	u32 ld_pause;	/* local driver */
-	u32 lp_pause;	/* link partner */
-	u32 pause_result;
-
-	bp->flow_ctrl = 0;
-
-	/* resolve from gp_status in case of AN complete and not sgmii */
-	if ((bp->req_autoneg & AUTONEG_FLOW_CTRL) &&
-	    (gp_status & MDIO_AN_CL73_OR_37_COMPLETE) &&
-	    (!(bp->phy_flags & PHY_SGMII_FLAG)) &&
-	    (XGXS_EXT_PHY_TYPE(bp) == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT)) {
-
-		MDIO_SET_REG_BANK(bp, MDIO_REG_BANK_COMBO_IEEE0);
-		bnx2x_mdio22_read(bp, MDIO_COMBO_IEEE0_AUTO_NEG_ADV,
-				  &ld_pause);
-		bnx2x_mdio22_read(bp,
-			MDIO_COMBO_IEEE0_AUTO_NEG_LINK_PARTNER_ABILITY1,
-				  &lp_pause);
-		pause_result = (ld_pause &
-				MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_MASK)>>5;
-		pause_result |= (lp_pause &
-				 MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_MASK)>>7;
-		DP(NETIF_MSG_LINK, "pause_result 0x%x\n", pause_result);
-		bnx2x_pause_resolve(bp, pause_result);
-	} else if (!(bp->req_autoneg & AUTONEG_FLOW_CTRL) ||
-		   !(bnx2x_ext_phy_resove_fc(bp))) {
-		/* forced speed */
-		if (bp->req_autoneg & AUTONEG_FLOW_CTRL) {
-			switch (bp->req_flow_ctrl) {
-			case FLOW_CTRL_AUTO:
-				if (bp->dev->mtu <= 4500)
-					bp->flow_ctrl = FLOW_CTRL_BOTH;
-				else
-					bp->flow_ctrl = FLOW_CTRL_TX;
-				break;
-
-			case FLOW_CTRL_TX:
-				bp->flow_ctrl = FLOW_CTRL_TX;
-				break;
-
-			case FLOW_CTRL_RX:
-				if (bp->dev->mtu <= 4500)
-					bp->flow_ctrl = FLOW_CTRL_RX;
-				break;
-
-			case FLOW_CTRL_BOTH:
-				if (bp->dev->mtu <= 4500)
-					bp->flow_ctrl = FLOW_CTRL_BOTH;
-				else
-					bp->flow_ctrl = FLOW_CTRL_TX;
-				break;
-
-			case FLOW_CTRL_NONE:
-			default:
-				break;
-			}
-		} else { /* forced mode */
-			switch (bp->req_flow_ctrl) {
-			case FLOW_CTRL_AUTO:
-				DP(NETIF_MSG_LINK, "req_flow_ctrl 0x%x while"
-						   " req_autoneg 0x%x\n",
-				   bp->req_flow_ctrl, bp->req_autoneg);
-				break;
-
-			case FLOW_CTRL_TX:
-			case FLOW_CTRL_RX:
-			case FLOW_CTRL_BOTH:
-				bp->flow_ctrl = bp->req_flow_ctrl;
-				break;
-
-			case FLOW_CTRL_NONE:
-			default:
-				break;
-			}
-		}
-	}
-	DP(NETIF_MSG_LINK, "flow_ctrl 0x%x\n", bp->flow_ctrl);
-}
-
-static void bnx2x_link_settings_status(struct bnx2x *bp, u32 gp_status)
-{
-	bp->link_status = 0;
-
-	if (gp_status & MDIO_GP_STATUS_TOP_AN_STATUS1_LINK_STATUS) {
-		DP(NETIF_MSG_LINK, "phy link up\n");
-
-		bp->phy_link_up = 1;
-		bp->link_status |= LINK_STATUS_LINK_UP;
-
-		if (gp_status & MDIO_GP_STATUS_TOP_AN_STATUS1_DUPLEX_STATUS)
-			bp->duplex = DUPLEX_FULL;
-		else
-			bp->duplex = DUPLEX_HALF;
-
-		bnx2x_flow_ctrl_resolve(bp, gp_status);
-
-		switch (gp_status & GP_STATUS_SPEED_MASK) {
-		case GP_STATUS_10M:
-			bp->line_speed = SPEED_10;
-			if (bp->duplex == DUPLEX_FULL)
-				bp->link_status |= LINK_10TFD;
-			else
-				bp->link_status |= LINK_10THD;
-			break;
-
-		case GP_STATUS_100M:
-			bp->line_speed = SPEED_100;
-			if (bp->duplex == DUPLEX_FULL)
-				bp->link_status |= LINK_100TXFD;
-			else
-				bp->link_status |= LINK_100TXHD;
-			break;
-
-		case GP_STATUS_1G:
-		case GP_STATUS_1G_KX:
-			bp->line_speed = SPEED_1000;
-			if (bp->duplex == DUPLEX_FULL)
-				bp->link_status |= LINK_1000TFD;
-			else
-				bp->link_status |= LINK_1000THD;
-			break;
-
-		case GP_STATUS_2_5G:
-			bp->line_speed = SPEED_2500;
-			if (bp->duplex == DUPLEX_FULL)
-				bp->link_status |= LINK_2500TFD;
-			else
-				bp->link_status |= LINK_2500THD;
-			break;
-
-		case GP_STATUS_5G:
-		case GP_STATUS_6G:
-			BNX2X_ERR("link speed unsupported  gp_status 0x%x\n",
-				  gp_status);
-			break;
-
-		case GP_STATUS_10G_KX4:
-		case GP_STATUS_10G_HIG:
-		case GP_STATUS_10G_CX4:
-			bp->line_speed = SPEED_10000;
-			bp->link_status |= LINK_10GTFD;
-			break;
-
-		case GP_STATUS_12G_HIG:
-			bp->line_speed = SPEED_12000;
-			bp->link_status |= LINK_12GTFD;
-			break;
-
-		case GP_STATUS_12_5G:
-			bp->line_speed = SPEED_12500;
-			bp->link_status |= LINK_12_5GTFD;
-			break;
-
-		case GP_STATUS_13G:
-			bp->line_speed = SPEED_13000;
-			bp->link_status |= LINK_13GTFD;
-			break;
-
-		case GP_STATUS_15G:
-			bp->line_speed = SPEED_15000;
-			bp->link_status |= LINK_15GTFD;
-			break;
-
-		case GP_STATUS_16G:
-			bp->line_speed = SPEED_16000;
-			bp->link_status |= LINK_16GTFD;
-			break;
-
-		default:
-			BNX2X_ERR("link speed unsupported  gp_status 0x%x\n",
-				  gp_status);
-			break;
-		}
-
-		bp->link_status |= LINK_STATUS_SERDES_LINK;
-
-		if (bp->req_autoneg & AUTONEG_SPEED) {
-			bp->link_status |= LINK_STATUS_AUTO_NEGOTIATE_ENABLED;
-
-			if (gp_status & MDIO_AN_CL73_OR_37_COMPLETE)
-				bp->link_status |=
-					LINK_STATUS_AUTO_NEGOTIATE_COMPLETE;
-
-			if (bp->autoneg & AUTONEG_PARALLEL)
-				bp->link_status |=
-					LINK_STATUS_PARALLEL_DETECTION_USED;
-		}
-
-		if (bp->flow_ctrl & FLOW_CTRL_TX)
-		       bp->link_status |= LINK_STATUS_TX_FLOW_CONTROL_ENABLED;
-
-		if (bp->flow_ctrl & FLOW_CTRL_RX)
-		       bp->link_status |= LINK_STATUS_RX_FLOW_CONTROL_ENABLED;
-
-	} else { /* link_down */
-		DP(NETIF_MSG_LINK, "phy link down\n");
-
-		bp->phy_link_up = 0;
-
-		bp->line_speed = 0;
-		bp->duplex = DUPLEX_FULL;
-		bp->flow_ctrl = 0;
-	}
-
-	DP(NETIF_MSG_LINK, "gp_status 0x%x  phy_link_up %d\n"
-	   DP_LEVEL "  line_speed %d  duplex %d  flow_ctrl 0x%x"
-		    "  link_status 0x%x\n",
-	   gp_status, bp->phy_link_up, bp->line_speed, bp->duplex,
-	   bp->flow_ctrl, bp->link_status);
-}
-
-static void bnx2x_link_int_ack(struct bnx2x *bp, int is_10g)
-{
-	int port = bp->port;
-
-	/* first reset all status
-	 * we assume only one line will be change at a time */
-	bnx2x_bits_dis(bp, NIG_REG_STATUS_INTERRUPT_PORT0 + port*4,
-		       (NIG_STATUS_XGXS0_LINK10G |
-			NIG_STATUS_XGXS0_LINK_STATUS |
-			NIG_STATUS_SERDES0_LINK_STATUS));
-	if (bp->phy_link_up) {
-		if (is_10g) {
-			/* Disable the 10G link interrupt
-			 * by writing 1 to the status register
-			 */
-			DP(NETIF_MSG_LINK, "10G XGXS phy link up\n");
-			bnx2x_bits_en(bp,
-				      NIG_REG_STATUS_INTERRUPT_PORT0 + port*4,
-				      NIG_STATUS_XGXS0_LINK10G);
-
-		} else if (bp->phy_flags & PHY_XGXS_FLAG) {
-			/* Disable the link interrupt
-			 * by writing 1 to the relevant lane
-			 * in the status register
-			 */
-			DP(NETIF_MSG_LINK, "1G XGXS phy link up\n");
-			bnx2x_bits_en(bp,
-				      NIG_REG_STATUS_INTERRUPT_PORT0 + port*4,
-				      ((1 << bp->ser_lane) <<
-				       NIG_STATUS_XGXS0_LINK_STATUS_SIZE));
-
-		} else { /* SerDes */
-			DP(NETIF_MSG_LINK, "SerDes phy link up\n");
-			/* Disable the link interrupt
-			 * by writing 1 to the status register
-			 */
-			bnx2x_bits_en(bp,
-				      NIG_REG_STATUS_INTERRUPT_PORT0 + port*4,
-				      NIG_STATUS_SERDES0_LINK_STATUS);
-		}
-
-	} else { /* link_down */
-	}
-}
-
-static int bnx2x_ext_phy_is_link_up(struct bnx2x *bp)
+static void bnx2x_calc_fc_adv(struct bnx2x *bp)
 {
-	u32 ext_phy_type;
-	u32 ext_phy_addr;
-	u32 val1 = 0, val2;
-	u32 rx_sd, pcs_status;
-
-	if (bp->phy_flags & PHY_XGXS_FLAG) {
-		ext_phy_addr = ((bp->ext_phy_config &
-				 PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
-				PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT);
-
-		ext_phy_type = XGXS_EXT_PHY_TYPE(bp);
-		switch (ext_phy_type) {
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT:
-			DP(NETIF_MSG_LINK, "XGXS Direct\n");
-			val1 = 1;
-			break;
-
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705:
-			DP(NETIF_MSG_LINK, "XGXS 8705\n");
-			bnx2x_mdio45_read(bp, ext_phy_addr,
-					  EXT_PHY_OPT_WIS_DEVAD,
-					  EXT_PHY_OPT_LASI_STATUS, &val1);
-			DP(NETIF_MSG_LINK, "8705 LASI status 0x%x\n", val1);
-
-			bnx2x_mdio45_read(bp, ext_phy_addr,
-					  EXT_PHY_OPT_WIS_DEVAD,
-					  EXT_PHY_OPT_LASI_STATUS, &val1);
-			DP(NETIF_MSG_LINK, "8705 LASI status 0x%x\n", val1);
-
-			bnx2x_mdio45_read(bp, ext_phy_addr,
-					  EXT_PHY_OPT_PMA_PMD_DEVAD,
-					  EXT_PHY_OPT_PMD_RX_SD, &rx_sd);
-			DP(NETIF_MSG_LINK, "8705 rx_sd 0x%x\n", rx_sd);
-			val1 = (rx_sd & 0x1);
-			break;
-
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706:
-			DP(NETIF_MSG_LINK, "XGXS 8706\n");
-			bnx2x_mdio45_read(bp, ext_phy_addr,
-					  EXT_PHY_OPT_PMA_PMD_DEVAD,
-					  EXT_PHY_OPT_LASI_STATUS, &val1);
-			DP(NETIF_MSG_LINK, "8706 LASI status 0x%x\n", val1);
-
-			bnx2x_mdio45_read(bp, ext_phy_addr,
-					  EXT_PHY_OPT_PMA_PMD_DEVAD,
-					  EXT_PHY_OPT_LASI_STATUS, &val1);
-			DP(NETIF_MSG_LINK, "8706 LASI status 0x%x\n", val1);
-
-			bnx2x_mdio45_read(bp, ext_phy_addr,
-					  EXT_PHY_OPT_PMA_PMD_DEVAD,
-					  EXT_PHY_OPT_PMD_RX_SD, &rx_sd);
-			bnx2x_mdio45_read(bp, ext_phy_addr,
-					  EXT_PHY_OPT_PCS_DEVAD,
-					  EXT_PHY_OPT_PCS_STATUS, &pcs_status);
-			bnx2x_mdio45_read(bp, ext_phy_addr,
-					  EXT_PHY_AUTO_NEG_DEVAD,
-					  EXT_PHY_OPT_AN_LINK_STATUS, &val2);
-
-			DP(NETIF_MSG_LINK, "8706 rx_sd 0x%x"
-			   "  pcs_status 0x%x 1Gbps link_status 0x%x 0x%x\n",
-			   rx_sd, pcs_status, val2, (val2 & (1<<1)));
-			/* link is up if both bit 0 of pmd_rx_sd and
-			 * bit 0 of pcs_status are set, or if the autoneg bit
-			   1 is set
-			 */
-			val1 = ((rx_sd & pcs_status & 0x1) || (val2 & (1<<1)));
-			break;
-
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072:
-			bnx2x_hw_lock(bp, HW_LOCK_RESOURCE_8072_MDIO);
-
-			/* clear the interrupt LASI status register */
-			bnx2x_mdio45_ctrl_read(bp, GRCBASE_EMAC0,
-					       ext_phy_addr,
-					       EXT_PHY_KR_PCS_DEVAD,
-					       EXT_PHY_KR_LASI_STATUS, &val2);
-			bnx2x_mdio45_ctrl_read(bp, GRCBASE_EMAC0,
-					       ext_phy_addr,
-					       EXT_PHY_KR_PCS_DEVAD,
-					       EXT_PHY_KR_LASI_STATUS, &val1);
-			DP(NETIF_MSG_LINK, "KR LASI status 0x%x->0x%x\n",
-			   val2, val1);
-			/* Check the LASI */
-			bnx2x_mdio45_ctrl_read(bp, GRCBASE_EMAC0,
-					       ext_phy_addr,
-					       EXT_PHY_KR_PMA_PMD_DEVAD,
-					       0x9003, &val2);
-			bnx2x_mdio45_ctrl_read(bp, GRCBASE_EMAC0,
-					       ext_phy_addr,
-					       EXT_PHY_KR_PMA_PMD_DEVAD,
-					       0x9003, &val1);
-			DP(NETIF_MSG_LINK, "KR 0x9003 0x%x->0x%x\n",
-			   val2, val1);
-			/* Check the link status */
-			bnx2x_mdio45_ctrl_read(bp, GRCBASE_EMAC0,
-					       ext_phy_addr,
-					       EXT_PHY_KR_PCS_DEVAD,
-					       EXT_PHY_KR_PCS_STATUS, &val2);
-			DP(NETIF_MSG_LINK, "KR PCS status 0x%x\n", val2);
-			/* Check the link status on 1.1.2 */
-			bnx2x_mdio45_ctrl_read(bp, GRCBASE_EMAC0,
-					  ext_phy_addr,
-					  EXT_PHY_OPT_PMA_PMD_DEVAD,
-					  EXT_PHY_KR_STATUS, &val2);
-			bnx2x_mdio45_ctrl_read(bp, GRCBASE_EMAC0,
-					  ext_phy_addr,
-					  EXT_PHY_OPT_PMA_PMD_DEVAD,
-					  EXT_PHY_KR_STATUS, &val1);
-			DP(NETIF_MSG_LINK,
-			   "KR PMA status 0x%x->0x%x\n", val2, val1);
-			val1 = ((val1 & 4) == 4);
-			/* If 1G was requested assume the link is up */
-			if (!(bp->req_autoneg & AUTONEG_SPEED) &&
-			    (bp->req_line_speed == SPEED_1000))
-				val1 = 1;
-			bnx2x_hw_unlock(bp, HW_LOCK_RESOURCE_8072_MDIO);
-			break;
-
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101:
-			bnx2x_mdio45_read(bp, ext_phy_addr,
-					  EXT_PHY_OPT_PMA_PMD_DEVAD,
-					  EXT_PHY_OPT_LASI_STATUS, &val2);
-			bnx2x_mdio45_read(bp, ext_phy_addr,
-					  EXT_PHY_OPT_PMA_PMD_DEVAD,
-					  EXT_PHY_OPT_LASI_STATUS, &val1);
-			DP(NETIF_MSG_LINK,
-			   "10G-base-T LASI status 0x%x->0x%x\n", val2, val1);
-			bnx2x_mdio45_read(bp, ext_phy_addr,
-					  EXT_PHY_OPT_PMA_PMD_DEVAD,
-					  EXT_PHY_KR_STATUS, &val2);
-			bnx2x_mdio45_read(bp, ext_phy_addr,
-					  EXT_PHY_OPT_PMA_PMD_DEVAD,
-					  EXT_PHY_KR_STATUS, &val1);
-			DP(NETIF_MSG_LINK,
-			   "10G-base-T PMA status 0x%x->0x%x\n", val2, val1);
-			val1 = ((val1 & 4) == 4);
-			/* if link is up
-			 * print the AN outcome of the SFX7101 PHY
-			 */
-			if (val1) {
-				bnx2x_mdio45_read(bp, ext_phy_addr,
-						  EXT_PHY_KR_AUTO_NEG_DEVAD,
-						  0x21, &val2);
-				DP(NETIF_MSG_LINK,
-				   "SFX7101 AN status 0x%x->%s\n", val2,
-				   (val2 & (1<<14)) ? "Master" : "Slave");
-			}
-			break;
-
-		default:
-			DP(NETIF_MSG_LINK, "BAD XGXS ext_phy_config 0x%x\n",
-			   bp->ext_phy_config);
-			val1 = 0;
-			break;
-		}
-
-	} else { /* SerDes */
-		ext_phy_type = SERDES_EXT_PHY_TYPE(bp);
-		switch (ext_phy_type) {
-		case PORT_HW_CFG_SERDES_EXT_PHY_TYPE_DIRECT:
-			DP(NETIF_MSG_LINK, "SerDes Direct\n");
-			val1 = 1;
-			break;
-
-		case PORT_HW_CFG_SERDES_EXT_PHY_TYPE_BCM5482:
-			DP(NETIF_MSG_LINK, "SerDes 5482\n");
-			val1 = 1;
-			break;
-
-		default:
-			DP(NETIF_MSG_LINK, "BAD SerDes ext_phy_config 0x%x\n",
-			   bp->ext_phy_config);
-			val1 = 0;
-			break;
-		}
-	}
-
-	return val1;
-}
-
-static void bnx2x_bmac_enable(struct bnx2x *bp, int is_lb)
-{
-	int port = bp->port;
-	u32 bmac_addr = port ? NIG_REG_INGRESS_BMAC1_MEM :
-			       NIG_REG_INGRESS_BMAC0_MEM;
-	u32 wb_write[2];
-	u32 val;
-
-	DP(NETIF_MSG_LINK, "enabling BigMAC\n");
-	/* reset and unreset the BigMac */
-	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_CLEAR,
-	       (MISC_REGISTERS_RESET_REG_2_RST_BMAC0 << port));
-	msleep(5);
-	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_SET,
-	       (MISC_REGISTERS_RESET_REG_2_RST_BMAC0 << port));
-
-	/* enable access for bmac registers */
-	NIG_WR(NIG_REG_BMAC0_REGS_OUT_EN + port*4, 0x1);
-
-	/* XGXS control */
-	wb_write[0] = 0x3c;
-	wb_write[1] = 0;
-	REG_WR_DMAE(bp, bmac_addr + BIGMAC_REGISTER_BMAC_XGXS_CONTROL,
-		    wb_write, 2);
-
-	/* tx MAC SA */
-	wb_write[0] = ((bp->dev->dev_addr[2] << 24) |
-		       (bp->dev->dev_addr[3] << 16) |
-		       (bp->dev->dev_addr[4] << 8) |
-			bp->dev->dev_addr[5]);
-	wb_write[1] = ((bp->dev->dev_addr[0] << 8) |
-			bp->dev->dev_addr[1]);
-	REG_WR_DMAE(bp, bmac_addr + BIGMAC_REGISTER_TX_SOURCE_ADDR,
-		    wb_write, 2);
-
-	/* tx control */
-	val = 0xc0;
-	if (bp->flow_ctrl & FLOW_CTRL_TX)
-		val |= 0x800000;
-	wb_write[0] = val;
-	wb_write[1] = 0;
-	REG_WR_DMAE(bp, bmac_addr + BIGMAC_REGISTER_TX_CONTROL, wb_write, 2);
-
-	/* set tx mtu */
-	wb_write[0] = ETH_MAX_JUMBO_PACKET_SIZE + ETH_OVREHEAD; /* -CRC */
-	wb_write[1] = 0;
-	REG_WR_DMAE(bp, bmac_addr + BIGMAC_REGISTER_TX_MAX_SIZE, wb_write, 2);
-
-	/* mac control */
-	val = 0x3;
-	if (is_lb) {
-		val |= 0x4;
-		DP(NETIF_MSG_LINK, "enable bmac loopback\n");
-	}
-	wb_write[0] = val;
-	wb_write[1] = 0;
-	REG_WR_DMAE(bp, bmac_addr + BIGMAC_REGISTER_BMAC_CONTROL,
-		    wb_write, 2);
-
-	/* rx control set to don't strip crc */
-	val = 0x14;
-	if (bp->flow_ctrl & FLOW_CTRL_RX)
-		val |= 0x20;
-	wb_write[0] = val;
-	wb_write[1] = 0;
-	REG_WR_DMAE(bp, bmac_addr + BIGMAC_REGISTER_RX_CONTROL, wb_write, 2);
-
-	/* set rx mtu */
-	wb_write[0] = ETH_MAX_JUMBO_PACKET_SIZE + ETH_OVREHEAD;
-	wb_write[1] = 0;
-	REG_WR_DMAE(bp, bmac_addr + BIGMAC_REGISTER_RX_MAX_SIZE, wb_write, 2);
-
-	/* set cnt max size */
-	wb_write[0] = ETH_MAX_JUMBO_PACKET_SIZE + ETH_OVREHEAD; /* -VLAN */
-	wb_write[1] = 0;
-	REG_WR_DMAE(bp, bmac_addr + BIGMAC_REGISTER_CNT_MAX_SIZE,
-		    wb_write, 2);
-
-	/* configure safc */
-	wb_write[0] = 0x1000200;
-	wb_write[1] = 0;
-	REG_WR_DMAE(bp, bmac_addr + BIGMAC_REGISTER_RX_LLFC_MSG_FLDS,
-		    wb_write, 2);
-
-	/* fix for emulation */
-	if (CHIP_REV(bp) == CHIP_REV_EMUL) {
-		wb_write[0] = 0xf000;
-		wb_write[1] = 0;
-		REG_WR_DMAE(bp,
-			    bmac_addr + BIGMAC_REGISTER_TX_PAUSE_THRESHOLD,
-			    wb_write, 2);
-	}
-
-	/* reset old bmac stats */
-	memset(&bp->old_bmac, 0, sizeof(struct bmac_stats));
-
-	NIG_WR(NIG_REG_XCM0_OUT_EN + port*4, 0x0);
-
-	/* select XGXS */
-	NIG_WR(NIG_REG_XGXS_SERDES0_MODE_SEL + port*4, 0x1);
-	NIG_WR(NIG_REG_XGXS_LANE_SEL_P0 + port*4, 0x0);
-
-	/* disable the NIG in/out to the emac */
-	NIG_WR(NIG_REG_EMAC0_IN_EN + port*4, 0x0);
-	NIG_WR(NIG_REG_EMAC0_PAUSE_OUT_EN + port*4, 0x0);
-	NIG_WR(NIG_REG_EGRESS_EMAC0_OUT_EN + port*4, 0x0);
-
-	/* enable the NIG in/out to the bmac */
-	NIG_WR(NIG_REG_EGRESS_EMAC0_PORT + port*4, 0x0);
-
-	NIG_WR(NIG_REG_BMAC0_IN_EN + port*4, 0x1);
-	val = 0;
-	if (bp->flow_ctrl & FLOW_CTRL_TX)
-		val = 1;
-	NIG_WR(NIG_REG_BMAC0_PAUSE_OUT_EN + port*4, val);
-	NIG_WR(NIG_REG_BMAC0_OUT_EN + port*4, 0x1);
-
-	bp->phy_flags |= PHY_BMAC_FLAG;
-
-	bp->stats_state = STATS_STATE_ENABLE;
-}
-
-static void bnx2x_bmac_rx_disable(struct bnx2x *bp)
-{
-	int port = bp->port;
-	u32 bmac_addr = port ? NIG_REG_INGRESS_BMAC1_MEM :
-			       NIG_REG_INGRESS_BMAC0_MEM;
-	u32 wb_write[2];
-
-	/* Only if the bmac is out of reset */
-	if (REG_RD(bp, MISC_REG_RESET_REG_2) &
-			(MISC_REGISTERS_RESET_REG_2_RST_BMAC0 << port)) {
-		/* Clear Rx Enable bit in BMAC_CONTROL register */
-#ifdef BNX2X_DMAE_RD
-		bnx2x_read_dmae(bp, bmac_addr +
-				BIGMAC_REGISTER_BMAC_CONTROL, 2);
-		wb_write[0] = *bnx2x_sp(bp, wb_data[0]);
-		wb_write[1] = *bnx2x_sp(bp, wb_data[1]);
-#else
-		wb_write[0] = REG_RD(bp,
-				bmac_addr + BIGMAC_REGISTER_BMAC_CONTROL);
-		wb_write[1] = REG_RD(bp,
-				bmac_addr + BIGMAC_REGISTER_BMAC_CONTROL + 4);
-#endif
-		wb_write[0] &= ~BMAC_CONTROL_RX_ENABLE;
-		REG_WR_DMAE(bp, bmac_addr + BIGMAC_REGISTER_BMAC_CONTROL,
-			    wb_write, 2);
-		msleep(1);
-	}
-}
-
-static void bnx2x_emac_enable(struct bnx2x *bp)
-{
-	int port = bp->port;
-	u32 emac_base = port ? GRCBASE_EMAC1 : GRCBASE_EMAC0;
-	u32 val;
-	int timeout;
-
-	DP(NETIF_MSG_LINK, "enabling EMAC\n");
-	/* reset and unreset the emac core */
-	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_CLEAR,
-	       (MISC_REGISTERS_RESET_REG_2_RST_EMAC0_HARD_CORE << port));
-	msleep(5);
-	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_SET,
-	       (MISC_REGISTERS_RESET_REG_2_RST_EMAC0_HARD_CORE << port));
-
-	/* enable emac and not bmac */
-	NIG_WR(NIG_REG_EGRESS_EMAC0_PORT + port*4, 1);
-
-	/* for paladium */
-	if (CHIP_REV(bp) == CHIP_REV_EMUL) {
-		/* Use lane 1 (of lanes 0-3) */
-		NIG_WR(NIG_REG_XGXS_LANE_SEL_P0 + port*4, 1);
-		NIG_WR(NIG_REG_XGXS_SERDES0_MODE_SEL + port*4, 1);
-	}
-	/* for fpga */
-	else if (CHIP_REV(bp) == CHIP_REV_FPGA) {
-		/* Use lane 1 (of lanes 0-3) */
-		NIG_WR(NIG_REG_XGXS_LANE_SEL_P0 + port*4, 1);
-		NIG_WR(NIG_REG_XGXS_SERDES0_MODE_SEL + port*4, 0);
-	}
-	/* ASIC */
-	else {
-		if (bp->phy_flags & PHY_XGXS_FLAG) {
-			DP(NETIF_MSG_LINK, "XGXS\n");
-			/* select the master lanes (out of 0-3) */
-			NIG_WR(NIG_REG_XGXS_LANE_SEL_P0 + port*4,
-			       bp->ser_lane);
-			/* select XGXS */
-			NIG_WR(NIG_REG_XGXS_SERDES0_MODE_SEL + port*4, 1);
-
-		} else { /* SerDes */
-			DP(NETIF_MSG_LINK, "SerDes\n");
-			/* select SerDes */
-			NIG_WR(NIG_REG_XGXS_SERDES0_MODE_SEL + port*4, 0);
-		}
-	}
-
-	/* enable emac */
-	NIG_WR(NIG_REG_NIG_EMAC0_EN + port*4, 1);
-
-	/* init emac - use read-modify-write */
-	/* self clear reset */
-	val = REG_RD(bp, emac_base + EMAC_REG_EMAC_MODE);
-	EMAC_WR(EMAC_REG_EMAC_MODE, (val | EMAC_MODE_RESET));
-
-	timeout = 200;
-	while (val & EMAC_MODE_RESET) {
-		val = REG_RD(bp, emac_base + EMAC_REG_EMAC_MODE);
-		DP(NETIF_MSG_LINK, "EMAC reset reg is %u\n", val);
-		if (!timeout) {
-			BNX2X_ERR("EMAC timeout!\n");
-			break;
-		}
-		timeout--;
-	}
-
-	/* reset tx part */
-	EMAC_WR(EMAC_REG_EMAC_TX_MODE, EMAC_TX_MODE_RESET);
-
-	timeout = 200;
-	while (val & EMAC_TX_MODE_RESET) {
-		val = REG_RD(bp, emac_base + EMAC_REG_EMAC_TX_MODE);
-		DP(NETIF_MSG_LINK, "EMAC reset reg is %u\n", val);
-		if (!timeout) {
-			BNX2X_ERR("EMAC timeout!\n");
-			break;
-		}
-		timeout--;
-	}
-
-	if (CHIP_REV_IS_SLOW(bp)) {
-		/* config GMII mode */
-		val = REG_RD(bp, emac_base + EMAC_REG_EMAC_MODE);
-		EMAC_WR(EMAC_REG_EMAC_MODE, (val | EMAC_MODE_PORT_GMII));
-
-	} else { /* ASIC */
-		/* pause enable/disable */
-		bnx2x_bits_dis(bp, emac_base + EMAC_REG_EMAC_RX_MODE,
-			       EMAC_RX_MODE_FLOW_EN);
-		if (bp->flow_ctrl & FLOW_CTRL_RX)
-			bnx2x_bits_en(bp, emac_base + EMAC_REG_EMAC_RX_MODE,
-				      EMAC_RX_MODE_FLOW_EN);
-
-		bnx2x_bits_dis(bp, emac_base + EMAC_REG_EMAC_TX_MODE,
-			       EMAC_TX_MODE_EXT_PAUSE_EN);
-		if (bp->flow_ctrl & FLOW_CTRL_TX)
-			bnx2x_bits_en(bp, emac_base + EMAC_REG_EMAC_TX_MODE,
-				      EMAC_TX_MODE_EXT_PAUSE_EN);
-	}
-
-	/* KEEP_VLAN_TAG, promiscuous */
-	val = REG_RD(bp, emac_base + EMAC_REG_EMAC_RX_MODE);
-	val |= EMAC_RX_MODE_KEEP_VLAN_TAG | EMAC_RX_MODE_PROMISCUOUS;
-	EMAC_WR(EMAC_REG_EMAC_RX_MODE, val);
-
-	/* identify magic packets */
-	val = REG_RD(bp, emac_base + EMAC_REG_EMAC_MODE);
-	EMAC_WR(EMAC_REG_EMAC_MODE, (val | EMAC_MODE_MPKT));
-
-	/* enable emac for jumbo packets */
-	EMAC_WR(EMAC_REG_EMAC_RX_MTU_SIZE,
-		(EMAC_RX_MTU_SIZE_JUMBO_ENA |
-		 (ETH_MAX_JUMBO_PACKET_SIZE + ETH_OVREHEAD))); /* -VLAN */
-
-	/* strip CRC */
-	NIG_WR(NIG_REG_NIG_INGRESS_EMAC0_NO_CRC + port*4, 0x1);
-
-	val = ((bp->dev->dev_addr[0] << 8) |
-		bp->dev->dev_addr[1]);
-	EMAC_WR(EMAC_REG_EMAC_MAC_MATCH, val);
-
-	val = ((bp->dev->dev_addr[2] << 24) |
-	       (bp->dev->dev_addr[3] << 16) |
-	       (bp->dev->dev_addr[4] << 8) |
-		bp->dev->dev_addr[5]);
-	EMAC_WR(EMAC_REG_EMAC_MAC_MATCH + 4, val);
-
-	/* disable the NIG in/out to the bmac */
-	NIG_WR(NIG_REG_BMAC0_IN_EN + port*4, 0x0);
-	NIG_WR(NIG_REG_BMAC0_PAUSE_OUT_EN + port*4, 0x0);
-	NIG_WR(NIG_REG_BMAC0_OUT_EN + port*4, 0x0);
-
-	/* enable the NIG in/out to the emac */
-	NIG_WR(NIG_REG_EMAC0_IN_EN + port*4, 0x1);
-	val = 0;
-	if (bp->flow_ctrl & FLOW_CTRL_TX)
-		val = 1;
-	NIG_WR(NIG_REG_EMAC0_PAUSE_OUT_EN + port*4, val);
-	NIG_WR(NIG_REG_EGRESS_EMAC0_OUT_EN + port*4, 0x1);
-
-	if (CHIP_REV(bp) == CHIP_REV_FPGA) {
-		/* take the BigMac out of reset */
-		REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_SET,
-		       (MISC_REGISTERS_RESET_REG_2_RST_BMAC0 << port));
-
-		/* enable access for bmac registers */
-		NIG_WR(NIG_REG_BMAC0_REGS_OUT_EN + port*4, 0x1);
-	}
-
-	bp->phy_flags |= PHY_EMAC_FLAG;
-
-	bp->stats_state = STATS_STATE_ENABLE;
-}
-
-static void bnx2x_emac_program(struct bnx2x *bp)
-{
-	u16 mode = 0;
-	int port = bp->port;
-
-	DP(NETIF_MSG_LINK, "setting link speed & duplex\n");
-	bnx2x_bits_dis(bp, GRCBASE_EMAC0 + port*0x400 + EMAC_REG_EMAC_MODE,
-		       (EMAC_MODE_25G_MODE |
-			EMAC_MODE_PORT_MII_10M |
-			EMAC_MODE_HALF_DUPLEX));
-	switch (bp->line_speed) {
-	case SPEED_10:
-		mode |= EMAC_MODE_PORT_MII_10M;
+	switch (bp->link_vars.ieee_fc) {
+	case MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_NONE:
+		bp->advertising &= ~(ADVERTISED_Asym_Pause |
+					  ADVERTISED_Pause);
 		break;
-
-	case SPEED_100:
-		mode |= EMAC_MODE_PORT_MII;
-		break;
-
-	case SPEED_1000:
-		mode |= EMAC_MODE_PORT_GMII;
+	case MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH:
+		bp->advertising |= (ADVERTISED_Asym_Pause |
+					 ADVERTISED_Pause);
 		break;
-
-	case SPEED_2500:
-		mode |= (EMAC_MODE_25G_MODE | EMAC_MODE_PORT_GMII);
+	case MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_ASYMMETRIC:
+		bp->advertising |= ADVERTISED_Asym_Pause;
 		break;
-
 	default:
-		/* 10G not valid for EMAC */
-		BNX2X_ERR("Invalid line_speed 0x%x\n", bp->line_speed);
+		bp->advertising &= ~(ADVERTISED_Asym_Pause |
+					  ADVERTISED_Pause);
 		break;
 	}
-
-	if (bp->duplex == DUPLEX_HALF)
-		mode |= EMAC_MODE_HALF_DUPLEX;
-	bnx2x_bits_en(bp, GRCBASE_EMAC0 + port*0x400 + EMAC_REG_EMAC_MODE,
-		      mode);
-
-	bnx2x_leds_set(bp, bp->line_speed);
-}
-
-static void bnx2x_set_sgmii_tx_driver(struct bnx2x *bp)
-{
-	u32 lp_up2;
-	u32 tx_driver;
-
-	/* read precomp */
-	MDIO_SET_REG_BANK(bp, MDIO_REG_BANK_OVER_1G);
-	bnx2x_mdio22_read(bp, MDIO_OVER_1G_LP_UP2, &lp_up2);
-
-	MDIO_SET_REG_BANK(bp, MDIO_REG_BANK_TX0);
-	bnx2x_mdio22_read(bp, MDIO_TX0_TX_DRIVER, &tx_driver);
-
-	/* bits [10:7] at lp_up2, positioned at [15:12] */
-	lp_up2 = (((lp_up2 & MDIO_OVER_1G_LP_UP2_PREEMPHASIS_MASK) >>
-		   MDIO_OVER_1G_LP_UP2_PREEMPHASIS_SHIFT) <<
-		  MDIO_TX0_TX_DRIVER_PREEMPHASIS_SHIFT);
-
-	if ((lp_up2 != 0) &&
-	    (lp_up2 != (tx_driver & MDIO_TX0_TX_DRIVER_PREEMPHASIS_MASK))) {
-		/* replace tx_driver bits [15:12] */
-		tx_driver &= ~MDIO_TX0_TX_DRIVER_PREEMPHASIS_MASK;
-		tx_driver |= lp_up2;
-		bnx2x_mdio22_write(bp, MDIO_TX0_TX_DRIVER, tx_driver);
-	}
-}
-
-static void bnx2x_pbf_update(struct bnx2x *bp)
-{
-	int port = bp->port;
-	u32 init_crd, crd;
-	u32 count = 1000;
-	u32 pause = 0;
-
-	/* disable port */
-	REG_WR(bp, PBF_REG_DISABLE_NEW_TASK_PROC_P0 + port*4, 0x1);
-
-	/* wait for init credit */
-	init_crd = REG_RD(bp, PBF_REG_P0_INIT_CRD + port*4);
-	crd = REG_RD(bp, PBF_REG_P0_CREDIT + port*8);
-	DP(NETIF_MSG_LINK, "init_crd 0x%x  crd 0x%x\n", init_crd, crd);
-
-	while ((init_crd != crd) && count) {
-		msleep(5);
-
-		crd = REG_RD(bp, PBF_REG_P0_CREDIT + port*8);
-		count--;
-	}
-	crd = REG_RD(bp, PBF_REG_P0_CREDIT + port*8);
-	if (init_crd != crd)
-		BNX2X_ERR("BUG! init_crd 0x%x != crd 0x%x\n", init_crd, crd);
-
-	if (bp->flow_ctrl & FLOW_CTRL_RX)
-		pause = 1;
-	REG_WR(bp, PBF_REG_P0_PAUSE_ENABLE + port*4, pause);
-	if (pause) {
-		/* update threshold */
-		REG_WR(bp, PBF_REG_P0_ARB_THRSH + port*4, 0);
-		/* update init credit */
-		init_crd = 778; 	/* (800-18-4) */
-
-	} else {
-		u32 thresh = (ETH_MAX_JUMBO_PACKET_SIZE + ETH_OVREHEAD)/16;
-
-		/* update threshold */
-		REG_WR(bp, PBF_REG_P0_ARB_THRSH + port*4, thresh);
-		/* update init credit */
-		switch (bp->line_speed) {
-		case SPEED_10:
-		case SPEED_100:
-		case SPEED_1000:
-			init_crd = thresh + 55 - 22;
-			break;
-
-		case SPEED_2500:
-			init_crd = thresh + 138 - 22;
-			break;
-
-		case SPEED_10000:
-			init_crd = thresh + 553 - 22;
-			break;
-
-		default:
-			BNX2X_ERR("Invalid line_speed 0x%x\n",
-				  bp->line_speed);
-			break;
-		}
-	}
-	REG_WR(bp, PBF_REG_P0_INIT_CRD + port*4, init_crd);
-	DP(NETIF_MSG_LINK, "PBF updated to speed %d credit %d\n",
-	   bp->line_speed, init_crd);
-
-	/* probe the credit changes */
-	REG_WR(bp, PBF_REG_INIT_P0 + port*4, 0x1);
-	msleep(5);
-	REG_WR(bp, PBF_REG_INIT_P0 + port*4, 0x0);
-
-	/* enable port */
-	REG_WR(bp, PBF_REG_DISABLE_NEW_TASK_PROC_P0 + port*4, 0x0);
-}
-
-static void bnx2x_update_mng(struct bnx2x *bp)
-{
-	if (!nomcp)
-		SHMEM_WR(bp, port_mb[bp->port].link_status,
-			 bp->link_status);
 }
 
 static void bnx2x_link_report(struct bnx2x *bp)
 {
-	if (bp->link_up) {
-		netif_carrier_on(bp->dev);
+	if (bp->link_vars.link_up) {
+		if (bp->state == BNX2X_STATE_OPEN)
+			netif_carrier_on(bp->dev);
 		printk(KERN_INFO PFX "%s NIC Link is Up, ", bp->dev->name);
 
-		printk("%d Mbps ", bp->line_speed);
+		printk("%d Mbps ", bp->link_vars.line_speed);
 
-		if (bp->duplex == DUPLEX_FULL)
+		if (bp->link_vars.duplex == DUPLEX_FULL)
 			printk("full duplex");
 		else
 			printk("half duplex");
 
-		if (bp->flow_ctrl) {
-			if (bp->flow_ctrl & FLOW_CTRL_RX) {
+		if (bp->link_vars.flow_ctrl != FLOW_CTRL_NONE) {
+			if (bp->link_vars.flow_ctrl & FLOW_CTRL_RX) {
 				printk(", receive ");
-				if (bp->flow_ctrl & FLOW_CTRL_TX)
+				if (bp->link_vars.flow_ctrl & FLOW_CTRL_TX)
 					printk("& transmit ");
 			} else {
 				printk(", transmit ");
@@ -2637,1318 +1375,78 @@ static void bnx2x_link_report(struct bnx2x *bp)
 
 	} else { /* link_down */
 		netif_carrier_off(bp->dev);
-		printk(KERN_INFO PFX "%s NIC Link is Down\n", bp->dev->name);
+		printk(KERN_ERR PFX "%s NIC Link is Down\n", bp->dev->name);
 	}
 }
 
-static void bnx2x_link_up(struct bnx2x *bp)
+static u8 bnx2x_initial_phy_init(struct bnx2x *bp)
 {
-	int port = bp->port;
-
-	/* PBF - link up */
-	bnx2x_pbf_update(bp);
-
-	/* disable drain */
-	NIG_WR(NIG_REG_EGRESS_DRAIN0_MODE + port*4, 0);
-
-	/* update shared memory */
-	bnx2x_update_mng(bp);
-
-	/* indicate link up */
-	bnx2x_link_report(bp);
-}
-
-static void bnx2x_link_down(struct bnx2x *bp)
-{
-	int port = bp->port;
-
-	/* notify stats */
-	if (bp->stats_state != STATS_STATE_DISABLE) {
-		bp->stats_state = STATS_STATE_STOP;
-		DP(BNX2X_MSG_STATS, "stats_state - STOP\n");
-	}
-
-	/* indicate no mac active */
-	bp->phy_flags &= ~(PHY_BMAC_FLAG | PHY_EMAC_FLAG);
-
-	/* update shared memory */
-	bnx2x_update_mng(bp);
+	u8 rc;
 
-	/* activate nig drain */
-	NIG_WR(NIG_REG_EGRESS_DRAIN0_MODE + port*4, 1);
+	/* Initialize link parameters structure variables */
+	bp->link_params.mtu = bp->dev->mtu;
 
-	/* reset BigMac */
-	bnx2x_bmac_rx_disable(bp);
-	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_CLEAR,
-	       (MISC_REGISTERS_RESET_REG_2_RST_BMAC0 << port));
-
-	/* indicate link down */
-	bnx2x_link_report(bp);
-}
-
-static void bnx2x_init_mac_stats(struct bnx2x *bp);
-
-/* This function is called upon link interrupt */
-static void bnx2x_link_update(struct bnx2x *bp)
-{
-	int port = bp->port;
-	int i;
-	u32 gp_status;
-	int link_10g;
-
-	DP(NETIF_MSG_LINK, "port %x, %s, int_status 0x%x,"
-	   " int_mask 0x%x, saved_mask 0x%x, MI_INT %x, SERDES_LINK %x,"
-	   " 10G %x, XGXS_LINK %x\n", port,
-	   (bp->phy_flags & PHY_XGXS_FLAG)? "XGXS":"SerDes",
-	   REG_RD(bp, NIG_REG_STATUS_INTERRUPT_PORT0 + port*4),
-	   REG_RD(bp, NIG_REG_MASK_INTERRUPT_PORT0 + port*4), bp->nig_mask,
-	   REG_RD(bp, NIG_REG_EMAC0_STATUS_MISC_MI_INT + port*0x18),
-	   REG_RD(bp, NIG_REG_SERDES0_STATUS_LINK_STATUS + port*0x3c),
-	   REG_RD(bp, NIG_REG_XGXS0_STATUS_LINK10G + port*0x68),
-	   REG_RD(bp, NIG_REG_XGXS0_STATUS_LINK_STATUS + port*0x68)
-	);
-
-	might_sleep();
-	MDIO_SET_REG_BANK(bp, MDIO_REG_BANK_GP_STATUS);
-	/* avoid fast toggling */
-	for (i = 0; i < 10; i++) {
-		msleep(10);
-		bnx2x_mdio22_read(bp, MDIO_GP_STATUS_TOP_AN_STATUS1,
-				  &gp_status);
-	}
-
-	bnx2x_link_settings_status(bp, gp_status);
-
-	/* anything 10 and over uses the bmac */
-	link_10g = ((bp->line_speed >= SPEED_10000) &&
-		    (bp->line_speed <= SPEED_16000));
-
-	bnx2x_link_int_ack(bp, link_10g);
-
-	/* link is up only if both local phy and external phy are up */
-	bp->link_up = (bp->phy_link_up && bnx2x_ext_phy_is_link_up(bp));
-	if (bp->link_up) {
-		if (link_10g) {
-			bnx2x_bmac_enable(bp, 0);
-			bnx2x_leds_set(bp, SPEED_10000);
-
-		} else {
-			bnx2x_emac_enable(bp);
-			bnx2x_emac_program(bp);
-
-			/* AN complete? */
-			if (gp_status & MDIO_AN_CL73_OR_37_COMPLETE) {
-				if (!(bp->phy_flags & PHY_SGMII_FLAG))
-					bnx2x_set_sgmii_tx_driver(bp);
-			}
-		}
-		bnx2x_link_up(bp);
-
-	} else { /* link down */
-		bnx2x_leds_unset(bp);
-		bnx2x_link_down(bp);
-	}
-
-	bnx2x_init_mac_stats(bp);
-}
+	bnx2x_phy_hw_lock(bp);
+	rc = bnx2x_phy_init(&bp->link_params, &bp->link_vars);
+	bnx2x_phy_hw_unlock(bp);
 
-/*
- * Init service functions
- */
-
-static void bnx2x_set_aer_mmd(struct bnx2x *bp)
-{
-	u16 offset = (bp->phy_flags & PHY_XGXS_FLAG) ?
-					(bp->phy_addr + bp->ser_lane) : 0;
-
-	MDIO_SET_REG_BANK(bp, MDIO_REG_BANK_AER_BLOCK);
-	bnx2x_mdio22_write(bp, MDIO_AER_BLOCK_AER_REG, 0x3800 + offset);
-}
-
-static void bnx2x_set_master_ln(struct bnx2x *bp)
-{
-	u32 new_master_ln;
-
-	/* set the master_ln for AN */
-	MDIO_SET_REG_BANK(bp, MDIO_REG_BANK_XGXS_BLOCK2);
-	bnx2x_mdio22_read(bp, MDIO_XGXS_BLOCK2_TEST_MODE_LANE,
-			  &new_master_ln);
-	bnx2x_mdio22_write(bp, MDIO_XGXS_BLOCK2_TEST_MODE_LANE,
-			   (new_master_ln | bp->ser_lane));
-}
-
-static void bnx2x_reset_unicore(struct bnx2x *bp)
-{
-	u32 mii_control;
-	int i;
-
-	MDIO_SET_REG_BANK(bp, MDIO_REG_BANK_COMBO_IEEE0);
-	bnx2x_mdio22_read(bp, MDIO_COMBO_IEEE0_MII_CONTROL, &mii_control);
-	/* reset the unicore */
-	bnx2x_mdio22_write(bp, MDIO_COMBO_IEEE0_MII_CONTROL,
-			   (mii_control | MDIO_COMBO_IEEO_MII_CONTROL_RESET));
-
-	/* wait for the reset to self clear */
-	for (i = 0; i < MDIO_ACCESS_TIMEOUT; i++) {
-		udelay(5);
-
-		/* the reset erased the previous bank value */
-		MDIO_SET_REG_BANK(bp, MDIO_REG_BANK_COMBO_IEEE0);
-		bnx2x_mdio22_read(bp, MDIO_COMBO_IEEE0_MII_CONTROL,
-				  &mii_control);
-
-		if (!(mii_control & MDIO_COMBO_IEEO_MII_CONTROL_RESET)) {
-			udelay(5);
-			return;
-		}
-	}
-
-	BNX2X_ERR("BUG! %s (0x%x) is still in reset!\n",
-		  (bp->phy_flags & PHY_XGXS_FLAG)? "XGXS":"SerDes",
-		  bp->phy_addr);
-}
-
-static void bnx2x_set_swap_lanes(struct bnx2x *bp)
-{
-	/* Each two bits represents a lane number:
-	   No swap is 0123 => 0x1b no need to enable the swap */
-
-	MDIO_SET_REG_BANK(bp, MDIO_REG_BANK_XGXS_BLOCK2);
-	if (bp->rx_lane_swap != 0x1b) {
-		bnx2x_mdio22_write(bp, MDIO_XGXS_BLOCK2_RX_LN_SWAP,
-				   (bp->rx_lane_swap |
-				    MDIO_XGXS_BLOCK2_RX_LN_SWAP_ENABLE |
-				   MDIO_XGXS_BLOCK2_RX_LN_SWAP_FORCE_ENABLE));
-	} else {
-		bnx2x_mdio22_write(bp, MDIO_XGXS_BLOCK2_RX_LN_SWAP, 0);
-	}
-
-	if (bp->tx_lane_swap != 0x1b) {
-		bnx2x_mdio22_write(bp, MDIO_XGXS_BLOCK2_TX_LN_SWAP,
-				   (bp->tx_lane_swap |
-				    MDIO_XGXS_BLOCK2_TX_LN_SWAP_ENABLE));
-	} else {
-		bnx2x_mdio22_write(bp, MDIO_XGXS_BLOCK2_TX_LN_SWAP, 0);
-	}
-}
-
-static void bnx2x_set_parallel_detection(struct bnx2x *bp)
-{
-	u32 control2;
-
-	MDIO_SET_REG_BANK(bp, MDIO_REG_BANK_SERDES_DIGITAL);
-	bnx2x_mdio22_read(bp, MDIO_SERDES_DIGITAL_A_1000X_CONTROL2,
-			  &control2);
-
-	if (bp->autoneg & AUTONEG_PARALLEL) {
-		control2 |= MDIO_SERDES_DIGITAL_A_1000X_CONTROL2_PRL_DT_EN;
-	} else {
-		control2 &= ~MDIO_SERDES_DIGITAL_A_1000X_CONTROL2_PRL_DT_EN;
-	}
-	bnx2x_mdio22_write(bp, MDIO_SERDES_DIGITAL_A_1000X_CONTROL2,
-			   control2);
-
-	if (bp->phy_flags & PHY_XGXS_FLAG) {
-		DP(NETIF_MSG_LINK, "XGXS\n");
-		MDIO_SET_REG_BANK(bp, MDIO_REG_BANK_10G_PARALLEL_DETECT);
-
-		bnx2x_mdio22_write(bp,
-				MDIO_10G_PARALLEL_DETECT_PAR_DET_10G_LINK,
-			       MDIO_10G_PARALLEL_DETECT_PAR_DET_10G_LINK_CNT);
-
-		bnx2x_mdio22_read(bp,
-				MDIO_10G_PARALLEL_DETECT_PAR_DET_10G_CONTROL,
-				&control2);
-
-		if (bp->autoneg & AUTONEG_PARALLEL) {
-			control2 |=
-		    MDIO_10G_PARALLEL_DETECT_PAR_DET_10G_CONTROL_PARDET10G_EN;
-		} else {
-			control2 &=
-		   ~MDIO_10G_PARALLEL_DETECT_PAR_DET_10G_CONTROL_PARDET10G_EN;
-		}
-		bnx2x_mdio22_write(bp,
-				MDIO_10G_PARALLEL_DETECT_PAR_DET_10G_CONTROL,
-				control2);
-
-		/* Disable parallel detection of HiG */
-		MDIO_SET_REG_BANK(bp, MDIO_REG_BANK_XGXS_BLOCK2);
-		bnx2x_mdio22_write(bp, MDIO_XGXS_BLOCK2_UNICORE_MODE_10G,
-				MDIO_XGXS_BLOCK2_UNICORE_MODE_10G_CX4_XGXS |
-				MDIO_XGXS_BLOCK2_UNICORE_MODE_10G_HIGIG_XGXS);
-	}
-}
-
-static void bnx2x_set_autoneg(struct bnx2x *bp)
-{
-	u32 reg_val;
-
-	/* CL37 Autoneg */
-	MDIO_SET_REG_BANK(bp, MDIO_REG_BANK_COMBO_IEEE0);
-	bnx2x_mdio22_read(bp, MDIO_COMBO_IEEE0_MII_CONTROL, &reg_val);
-	if ((bp->req_autoneg & AUTONEG_SPEED) &&
-	    (bp->autoneg & AUTONEG_CL37)) {
-		/* CL37 Autoneg Enabled */
-		reg_val |= MDIO_COMBO_IEEO_MII_CONTROL_AN_EN;
-	} else {
-		/* CL37 Autoneg Disabled */
-		reg_val &= ~(MDIO_COMBO_IEEO_MII_CONTROL_AN_EN |
-			     MDIO_COMBO_IEEO_MII_CONTROL_RESTART_AN);
-	}
-	bnx2x_mdio22_write(bp, MDIO_COMBO_IEEE0_MII_CONTROL, reg_val);
-
-	/* Enable/Disable Autodetection */
-	MDIO_SET_REG_BANK(bp, MDIO_REG_BANK_SERDES_DIGITAL);
-	bnx2x_mdio22_read(bp, MDIO_SERDES_DIGITAL_A_1000X_CONTROL1, &reg_val);
-	reg_val &= ~MDIO_SERDES_DIGITAL_A_1000X_CONTROL1_SIGNAL_DETECT_EN;
-
-	if ((bp->req_autoneg & AUTONEG_SPEED) &&
-	    (bp->autoneg & AUTONEG_SGMII_FIBER_AUTODET)) {
-		reg_val |= MDIO_SERDES_DIGITAL_A_1000X_CONTROL1_AUTODET;
-	} else {
-		reg_val &= ~MDIO_SERDES_DIGITAL_A_1000X_CONTROL1_AUTODET;
-	}
-	bnx2x_mdio22_write(bp, MDIO_SERDES_DIGITAL_A_1000X_CONTROL1, reg_val);
-
-	/* Enable TetonII and BAM autoneg */
-	MDIO_SET_REG_BANK(bp, MDIO_REG_BANK_BAM_NEXT_PAGE);
-	bnx2x_mdio22_read(bp, MDIO_BAM_NEXT_PAGE_MP5_NEXT_PAGE_CTRL,
-			  &reg_val);
-	if ((bp->req_autoneg & AUTONEG_SPEED) &&
-	    (bp->autoneg & AUTONEG_CL37) && (bp->autoneg & AUTONEG_BAM)) {
-		/* Enable BAM aneg Mode and TetonII aneg Mode */
-		reg_val |= (MDIO_BAM_NEXT_PAGE_MP5_NEXT_PAGE_CTRL_BAM_MODE |
-			    MDIO_BAM_NEXT_PAGE_MP5_NEXT_PAGE_CTRL_TETON_AN);
-	} else {
-		/* TetonII and BAM Autoneg Disabled */
-		reg_val &= ~(MDIO_BAM_NEXT_PAGE_MP5_NEXT_PAGE_CTRL_BAM_MODE |
-			     MDIO_BAM_NEXT_PAGE_MP5_NEXT_PAGE_CTRL_TETON_AN);
-	}
-	bnx2x_mdio22_write(bp, MDIO_BAM_NEXT_PAGE_MP5_NEXT_PAGE_CTRL,
-			   reg_val);
-
-	/* Enable Clause 73 Aneg */
-	if ((bp->req_autoneg & AUTONEG_SPEED) &&
-	    (bp->autoneg & AUTONEG_CL73)) {
-		/* Enable BAM Station Manager */
-		MDIO_SET_REG_BANK(bp, MDIO_REG_BANK_CL73_USERB0);
-		bnx2x_mdio22_write(bp, MDIO_CL73_USERB0_CL73_BAM_CTRL1,
-				   (MDIO_CL73_USERB0_CL73_BAM_CTRL1_BAM_EN |
-			MDIO_CL73_USERB0_CL73_BAM_CTRL1_BAM_STATION_MNGR_EN |
-			MDIO_CL73_USERB0_CL73_BAM_CTRL1_BAM_NP_AFTER_BP_EN));
-
-		/* Merge CL73 and CL37 aneg resolution */
-		bnx2x_mdio22_read(bp, MDIO_CL73_USERB0_CL73_BAM_CTRL3,
-				  &reg_val);
-		bnx2x_mdio22_write(bp, MDIO_CL73_USERB0_CL73_BAM_CTRL3,
-				   (reg_val |
-			MDIO_CL73_USERB0_CL73_BAM_CTRL3_USE_CL73_HCD_MR));
-
-		/* Set the CL73 AN speed */
-		MDIO_SET_REG_BANK(bp, MDIO_REG_BANK_CL73_IEEEB1);
-		bnx2x_mdio22_read(bp, MDIO_CL73_IEEEB1_AN_ADV2, &reg_val);
-		/* In the SerDes we support only the 1G.
-		   In the XGXS we support the 10G KX4
-		   but we currently do not support the KR */
-		if (bp->phy_flags & PHY_XGXS_FLAG) {
-			DP(NETIF_MSG_LINK, "XGXS\n");
-			/* 10G KX4 */
-			reg_val |= MDIO_CL73_IEEEB1_AN_ADV2_ADVR_10G_KX4;
-		} else {
-			DP(NETIF_MSG_LINK, "SerDes\n");
-			/* 1000M KX */
-			reg_val |= MDIO_CL73_IEEEB1_AN_ADV2_ADVR_1000M_KX;
-		}
-		bnx2x_mdio22_write(bp, MDIO_CL73_IEEEB1_AN_ADV2, reg_val);
-
-		/* CL73 Autoneg Enabled */
-		reg_val = MDIO_CL73_IEEEB0_CL73_AN_CONTROL_AN_EN;
-	} else {
-		/* CL73 Autoneg Disabled */
-		reg_val = 0;
-	}
-	MDIO_SET_REG_BANK(bp, MDIO_REG_BANK_CL73_IEEEB0);
-	bnx2x_mdio22_write(bp, MDIO_CL73_IEEEB0_CL73_AN_CONTROL, reg_val);
-}
-
-/* program SerDes, forced speed */
-static void bnx2x_program_serdes(struct bnx2x *bp)
-{
-	u32 reg_val;
-
-	/* program duplex, disable autoneg */
-	MDIO_SET_REG_BANK(bp, MDIO_REG_BANK_COMBO_IEEE0);
-	bnx2x_mdio22_read(bp, MDIO_COMBO_IEEE0_MII_CONTROL, &reg_val);
-	reg_val &= ~(MDIO_COMBO_IEEO_MII_CONTROL_FULL_DUPLEX |
-		     MDIO_COMBO_IEEO_MII_CONTROL_AN_EN);
-	if (bp->req_duplex == DUPLEX_FULL)
-		reg_val |= MDIO_COMBO_IEEO_MII_CONTROL_FULL_DUPLEX;
-	bnx2x_mdio22_write(bp, MDIO_COMBO_IEEE0_MII_CONTROL, reg_val);
-
-	/* program speed
-	   - needed only if the speed is greater than 1G (2.5G or 10G) */
-	if (bp->req_line_speed > SPEED_1000) {
-		MDIO_SET_REG_BANK(bp, MDIO_REG_BANK_SERDES_DIGITAL);
-		bnx2x_mdio22_read(bp, MDIO_SERDES_DIGITAL_MISC1, &reg_val);
-		/* clearing the speed value before setting the right speed */
-		reg_val &= ~MDIO_SERDES_DIGITAL_MISC1_FORCE_SPEED_MASK;
-		reg_val |= (MDIO_SERDES_DIGITAL_MISC1_REFCLK_SEL_156_25M |
-			    MDIO_SERDES_DIGITAL_MISC1_FORCE_SPEED_SEL);
-		if (bp->req_line_speed == SPEED_10000)
-			reg_val |=
-				MDIO_SERDES_DIGITAL_MISC1_FORCE_SPEED_10G_CX4;
-		bnx2x_mdio22_write(bp, MDIO_SERDES_DIGITAL_MISC1, reg_val);
-	}
-}
-
-static void bnx2x_set_brcm_cl37_advertisment(struct bnx2x *bp)
-{
-	u32 val = 0;
-
-	/* configure the 48 bits for BAM AN */
-	MDIO_SET_REG_BANK(bp, MDIO_REG_BANK_OVER_1G);
-
-	/* set extended capabilities */
-	if (bp->advertising & ADVERTISED_2500baseX_Full)
-		val |= MDIO_OVER_1G_UP1_2_5G;
-	if (bp->advertising & ADVERTISED_10000baseT_Full)
-		val |= MDIO_OVER_1G_UP1_10G;
-	bnx2x_mdio22_write(bp, MDIO_OVER_1G_UP1, val);
-
-	bnx2x_mdio22_write(bp, MDIO_OVER_1G_UP3, 0);
-}
-
-static void bnx2x_set_ieee_aneg_advertisment(struct bnx2x *bp)
-{
-	u32 an_adv;
-
-	/* for AN, we are always publishing full duplex */
-	an_adv = MDIO_COMBO_IEEE0_AUTO_NEG_ADV_FULL_DUPLEX;
-
-	/* resolve pause mode and advertisement
-	 * Please refer to Table 28B-3 of the 802.3ab-1999 spec */
-	if (bp->req_autoneg & AUTONEG_FLOW_CTRL) {
-		switch (bp->req_flow_ctrl) {
-		case FLOW_CTRL_AUTO:
-			if (bp->dev->mtu <= 4500) {
-				an_adv |=
-				     MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH;
-				bp->advertising |= (ADVERTISED_Pause |
-						    ADVERTISED_Asym_Pause);
-			} else {
-				an_adv |=
-			       MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_ASYMMETRIC;
-				bp->advertising |= ADVERTISED_Asym_Pause;
-			}
-			break;
-
-		case FLOW_CTRL_TX:
-			an_adv |=
-			       MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_ASYMMETRIC;
-			bp->advertising |= ADVERTISED_Asym_Pause;
-			break;
-
-		case FLOW_CTRL_RX:
-			if (bp->dev->mtu <= 4500) {
-				an_adv |=
-				     MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH;
-				bp->advertising |= (ADVERTISED_Pause |
-						    ADVERTISED_Asym_Pause);
-			} else {
-				an_adv |=
-				     MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_NONE;
-				bp->advertising &= ~(ADVERTISED_Pause |
-						     ADVERTISED_Asym_Pause);
-			}
-			break;
-
-		case FLOW_CTRL_BOTH:
-			if (bp->dev->mtu <= 4500) {
-				an_adv |=
-				     MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH;
-				bp->advertising |= (ADVERTISED_Pause |
-						    ADVERTISED_Asym_Pause);
-			} else {
-				an_adv |=
-			       MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_ASYMMETRIC;
-				bp->advertising |= ADVERTISED_Asym_Pause;
-			}
-			break;
-
-		case FLOW_CTRL_NONE:
-		default:
-			an_adv |= MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_NONE;
-			bp->advertising &= ~(ADVERTISED_Pause |
-					     ADVERTISED_Asym_Pause);
-			break;
-		}
-	} else { /* forced mode */
-		switch (bp->req_flow_ctrl) {
-		case FLOW_CTRL_AUTO:
-			DP(NETIF_MSG_LINK, "req_flow_ctrl 0x%x while"
-					   " req_autoneg 0x%x\n",
-			   bp->req_flow_ctrl, bp->req_autoneg);
-			break;
-
-		case FLOW_CTRL_TX:
-			an_adv |=
-			       MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_ASYMMETRIC;
-			bp->advertising |= ADVERTISED_Asym_Pause;
-			break;
-
-		case FLOW_CTRL_RX:
-		case FLOW_CTRL_BOTH:
-			an_adv |= MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH;
-			bp->advertising |= (ADVERTISED_Pause |
-					    ADVERTISED_Asym_Pause);
-			break;
-
-		case FLOW_CTRL_NONE:
-		default:
-			an_adv |= MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_NONE;
-			bp->advertising &= ~(ADVERTISED_Pause |
-					     ADVERTISED_Asym_Pause);
-			break;
-		}
-	}
-
-	MDIO_SET_REG_BANK(bp, MDIO_REG_BANK_COMBO_IEEE0);
-	bnx2x_mdio22_write(bp, MDIO_COMBO_IEEE0_AUTO_NEG_ADV, an_adv);
-}
-
-static void bnx2x_restart_autoneg(struct bnx2x *bp)
-{
-	if (bp->autoneg & AUTONEG_CL73) {
-		/* enable and restart clause 73 aneg */
-		u32 an_ctrl;
-
-		MDIO_SET_REG_BANK(bp, MDIO_REG_BANK_CL73_IEEEB0);
-		bnx2x_mdio22_read(bp, MDIO_CL73_IEEEB0_CL73_AN_CONTROL,
-				  &an_ctrl);
-		bnx2x_mdio22_write(bp, MDIO_CL73_IEEEB0_CL73_AN_CONTROL,
-				   (an_ctrl |
-				    MDIO_CL73_IEEEB0_CL73_AN_CONTROL_AN_EN |
-				MDIO_CL73_IEEEB0_CL73_AN_CONTROL_RESTART_AN));
-
-	} else {
-		/* Enable and restart BAM/CL37 aneg */
-		u32 mii_control;
-
-		MDIO_SET_REG_BANK(bp, MDIO_REG_BANK_COMBO_IEEE0);
-		bnx2x_mdio22_read(bp, MDIO_COMBO_IEEE0_MII_CONTROL,
-				  &mii_control);
-		bnx2x_mdio22_write(bp, MDIO_COMBO_IEEE0_MII_CONTROL,
-				   (mii_control |
-				    MDIO_COMBO_IEEO_MII_CONTROL_AN_EN |
-				    MDIO_COMBO_IEEO_MII_CONTROL_RESTART_AN));
-	}
-}
-
-static void bnx2x_initialize_sgmii_process(struct bnx2x *bp)
-{
-	u32 control1;
-
-	/* in SGMII mode, the unicore is always slave */
-	MDIO_SET_REG_BANK(bp, MDIO_REG_BANK_SERDES_DIGITAL);
-	bnx2x_mdio22_read(bp, MDIO_SERDES_DIGITAL_A_1000X_CONTROL1,
-			  &control1);
-	control1 |= MDIO_SERDES_DIGITAL_A_1000X_CONTROL1_INVERT_SIGNAL_DETECT;
-	/* set sgmii mode (and not fiber) */
-	control1 &= ~(MDIO_SERDES_DIGITAL_A_1000X_CONTROL1_FIBER_MODE |
-		      MDIO_SERDES_DIGITAL_A_1000X_CONTROL1_AUTODET |
-		      MDIO_SERDES_DIGITAL_A_1000X_CONTROL1_MSTR_MODE);
-	bnx2x_mdio22_write(bp, MDIO_SERDES_DIGITAL_A_1000X_CONTROL1,
-			   control1);
-
-	/* if forced speed */
-	if (!(bp->req_autoneg & AUTONEG_SPEED)) {
-		/* set speed, disable autoneg */
-		u32 mii_control;
-
-		MDIO_SET_REG_BANK(bp, MDIO_REG_BANK_COMBO_IEEE0);
-		bnx2x_mdio22_read(bp, MDIO_COMBO_IEEE0_MII_CONTROL,
-				  &mii_control);
-		mii_control &= ~(MDIO_COMBO_IEEO_MII_CONTROL_AN_EN |
-			       MDIO_COMBO_IEEO_MII_CONTROL_MAN_SGMII_SP_MASK |
-				 MDIO_COMBO_IEEO_MII_CONTROL_FULL_DUPLEX);
-
-		switch (bp->req_line_speed) {
-		case SPEED_100:
-			mii_control |=
-				MDIO_COMBO_IEEO_MII_CONTROL_MAN_SGMII_SP_100;
-			break;
-		case SPEED_1000:
-			mii_control |=
-				MDIO_COMBO_IEEO_MII_CONTROL_MAN_SGMII_SP_1000;
-			break;
-		case SPEED_10:
-			/* there is nothing to set for 10M */
-			break;
-		default:
-			/* invalid speed for SGMII */
-			DP(NETIF_MSG_LINK, "Invalid req_line_speed 0x%x\n",
-			   bp->req_line_speed);
-			break;
-		}
-
-		/* setting the full duplex */
-		if (bp->req_duplex == DUPLEX_FULL)
-			mii_control |=
-				MDIO_COMBO_IEEO_MII_CONTROL_FULL_DUPLEX;
-		bnx2x_mdio22_write(bp, MDIO_COMBO_IEEE0_MII_CONTROL,
-				   mii_control);
-
-	} else { /* AN mode */
-		/* enable and restart AN */
-		bnx2x_restart_autoneg(bp);
-	}
-}
-
-static void bnx2x_link_int_enable(struct bnx2x *bp)
-{
-	int port = bp->port;
-	u32 ext_phy_type;
-	u32 mask;
-
-	/* setting the status to report on link up
-	   for either XGXS or SerDes */
-	bnx2x_bits_dis(bp, NIG_REG_STATUS_INTERRUPT_PORT0 + port*4,
-		       (NIG_STATUS_XGXS0_LINK10G |
-			NIG_STATUS_XGXS0_LINK_STATUS |
-			NIG_STATUS_SERDES0_LINK_STATUS));
-
-	if (bp->phy_flags & PHY_XGXS_FLAG) {
-		mask = (NIG_MASK_XGXS0_LINK10G |
-			NIG_MASK_XGXS0_LINK_STATUS);
-		DP(NETIF_MSG_LINK, "enabled XGXS interrupt\n");
-		ext_phy_type = XGXS_EXT_PHY_TYPE(bp);
-		if ((ext_phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT) &&
-		    (ext_phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_FAILURE) &&
-		    (ext_phy_type !=
-				PORT_HW_CFG_XGXS_EXT_PHY_TYPE_NOT_CONN)) {
-			mask |= NIG_MASK_MI_INT;
-			DP(NETIF_MSG_LINK, "enabled external phy int\n");
-		}
-
-	} else { /* SerDes */
-		mask = NIG_MASK_SERDES0_LINK_STATUS;
-		DP(NETIF_MSG_LINK, "enabled SerDes interrupt\n");
-		ext_phy_type = SERDES_EXT_PHY_TYPE(bp);
-		if ((ext_phy_type !=
-				PORT_HW_CFG_SERDES_EXT_PHY_TYPE_DIRECT) &&
-		    (ext_phy_type !=
-				PORT_HW_CFG_SERDES_EXT_PHY_TYPE_NOT_CONN)) {
-			mask |= NIG_MASK_MI_INT;
-			DP(NETIF_MSG_LINK, "enabled external phy int\n");
-		}
-	}
-	bnx2x_bits_en(bp,
-		      NIG_REG_MASK_INTERRUPT_PORT0 + port*4,
-		      mask);
-	DP(NETIF_MSG_LINK, "port %x, %s, int_status 0x%x,"
-	   " int_mask 0x%x, MI_INT %x, SERDES_LINK %x,"
-	   " 10G %x, XGXS_LINK %x\n", port,
-	   (bp->phy_flags & PHY_XGXS_FLAG)? "XGXS":"SerDes",
-	   REG_RD(bp, NIG_REG_STATUS_INTERRUPT_PORT0 + port*4),
-	   REG_RD(bp, NIG_REG_MASK_INTERRUPT_PORT0 + port*4),
-	   REG_RD(bp, NIG_REG_EMAC0_STATUS_MISC_MI_INT + port*0x18),
-	   REG_RD(bp, NIG_REG_SERDES0_STATUS_LINK_STATUS + port*0x3c),
-	   REG_RD(bp, NIG_REG_XGXS0_STATUS_LINK10G + port*0x68),
-	   REG_RD(bp, NIG_REG_XGXS0_STATUS_LINK_STATUS + port*0x68)
-	);
-}
-
-static void bnx2x_bcm8072_external_rom_boot(struct bnx2x *bp)
-{
-	u32 ext_phy_addr = ((bp->ext_phy_config &
-			     PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
-			    PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT);
-	u32 fw_ver1, fw_ver2;
-
-	/* Need to wait 200ms after reset */
-	msleep(200);
-	/* Boot port from external ROM
-	 * Set ser_boot_ctl bit in the MISC_CTRL1 register
-	 */
-	bnx2x_mdio45_ctrl_write(bp, GRCBASE_EMAC0, ext_phy_addr,
-				EXT_PHY_KR_PMA_PMD_DEVAD,
-				EXT_PHY_KR_MISC_CTRL1, 0x0001);
-
-	/* Reset internal microprocessor */
-	bnx2x_mdio45_ctrl_write(bp, GRCBASE_EMAC0, ext_phy_addr,
-				EXT_PHY_KR_PMA_PMD_DEVAD, EXT_PHY_KR_GEN_CTRL,
-				EXT_PHY_KR_ROM_RESET_INTERNAL_MP);
-	/* set micro reset = 0 */
-	bnx2x_mdio45_ctrl_write(bp, GRCBASE_EMAC0, ext_phy_addr,
-				EXT_PHY_KR_PMA_PMD_DEVAD, EXT_PHY_KR_GEN_CTRL,
-				EXT_PHY_KR_ROM_MICRO_RESET);
-	/* Reset internal microprocessor */
-	bnx2x_mdio45_ctrl_write(bp, GRCBASE_EMAC0, ext_phy_addr,
-				EXT_PHY_KR_PMA_PMD_DEVAD, EXT_PHY_KR_GEN_CTRL,
-				EXT_PHY_KR_ROM_RESET_INTERNAL_MP);
-	/* wait for 100ms for code download via SPI port */
-	msleep(100);
-
-	/* Clear ser_boot_ctl bit */
-	bnx2x_mdio45_ctrl_write(bp, GRCBASE_EMAC0, ext_phy_addr,
-				EXT_PHY_KR_PMA_PMD_DEVAD,
-				EXT_PHY_KR_MISC_CTRL1, 0x0000);
-	/* Wait 100ms */
-	msleep(100);
-
-	/* Print the PHY FW version */
-	bnx2x_mdio45_ctrl_read(bp, GRCBASE_EMAC0, ext_phy_addr,
-			       EXT_PHY_KR_PMA_PMD_DEVAD,
-			       0xca19, &fw_ver1);
-	bnx2x_mdio45_ctrl_read(bp, GRCBASE_EMAC0, ext_phy_addr,
-			       EXT_PHY_KR_PMA_PMD_DEVAD,
-			       0xca1a, &fw_ver2);
-	DP(NETIF_MSG_LINK,
-	   "8072 FW version 0x%x:0x%x\n", fw_ver1, fw_ver2);
-}
-
-static void bnx2x_bcm8072_force_10G(struct bnx2x *bp)
-{
-	u32 ext_phy_addr = ((bp->ext_phy_config &
-			     PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
-			    PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT);
-
-	/* Force KR or KX */
-	bnx2x_mdio45_ctrl_write(bp, GRCBASE_EMAC0, ext_phy_addr,
-				EXT_PHY_KR_PMA_PMD_DEVAD, EXT_PHY_KR_CTRL,
-				0x2040);
-	bnx2x_mdio45_ctrl_write(bp, GRCBASE_EMAC0, ext_phy_addr,
-				EXT_PHY_KR_PMA_PMD_DEVAD, EXT_PHY_KR_CTRL2,
-				0x000b);
-	bnx2x_mdio45_ctrl_write(bp, GRCBASE_EMAC0, ext_phy_addr,
-				EXT_PHY_KR_PMA_PMD_DEVAD, EXT_PHY_KR_PMD_CTRL,
-				0x0000);
-	bnx2x_mdio45_ctrl_write(bp, GRCBASE_EMAC0, ext_phy_addr,
-				EXT_PHY_KR_AUTO_NEG_DEVAD, EXT_PHY_KR_CTRL,
-				0x0000);
-}
-
-static void bnx2x_ext_phy_init(struct bnx2x *bp)
-{
-	u32 ext_phy_type;
-	u32 ext_phy_addr;
-	u32 cnt;
-	u32 ctrl;
-	u32 val = 0;
-
-	if (bp->phy_flags & PHY_XGXS_FLAG) {
-		ext_phy_addr = ((bp->ext_phy_config &
-				 PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
-				PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT);
-
-		ext_phy_type = XGXS_EXT_PHY_TYPE(bp);
-		/* Make sure that the soft reset is off (expect for the 8072:
-		 * due to the lock, it will be done inside the specific
-		 * handling)
-		 */
-		if ((ext_phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT) &&
-		    (ext_phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_FAILURE) &&
-		   (ext_phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_NOT_CONN) &&
-		    (ext_phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072)) {
-			/* Wait for soft reset to get cleared upto 1 sec */
-			for (cnt = 0; cnt < 1000; cnt++) {
-				bnx2x_mdio45_read(bp, ext_phy_addr,
-						  EXT_PHY_OPT_PMA_PMD_DEVAD,
-						  EXT_PHY_OPT_CNTL, &ctrl);
-				if (!(ctrl & (1<<15)))
-					break;
-				msleep(1);
-			}
-			DP(NETIF_MSG_LINK,
-			   "control reg 0x%x (after %d ms)\n", ctrl, cnt);
-		}
-
-		switch (ext_phy_type) {
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT:
-			DP(NETIF_MSG_LINK, "XGXS Direct\n");
-			break;
-
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705:
-			DP(NETIF_MSG_LINK, "XGXS 8705\n");
-
-			bnx2x_mdio45_vwrite(bp, ext_phy_addr,
-					    EXT_PHY_OPT_PMA_PMD_DEVAD,
-					    EXT_PHY_OPT_PMD_MISC_CNTL,
-					    0x8288);
-			bnx2x_mdio45_vwrite(bp, ext_phy_addr,
-					    EXT_PHY_OPT_PMA_PMD_DEVAD,
-					    EXT_PHY_OPT_PHY_IDENTIFIER,
-					    0x7fbf);
-			bnx2x_mdio45_vwrite(bp, ext_phy_addr,
-					    EXT_PHY_OPT_PMA_PMD_DEVAD,
-					    EXT_PHY_OPT_CMU_PLL_BYPASS,
-					    0x0100);
-			bnx2x_mdio45_vwrite(bp, ext_phy_addr,
-					    EXT_PHY_OPT_WIS_DEVAD,
-					    EXT_PHY_OPT_LASI_CNTL, 0x1);
-			break;
-
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706:
-			DP(NETIF_MSG_LINK, "XGXS 8706\n");
-
-			if (!(bp->req_autoneg & AUTONEG_SPEED)) {
-				/* Force speed */
-				if (bp->req_line_speed == SPEED_10000) {
-					DP(NETIF_MSG_LINK,
-					   "XGXS 8706 force 10Gbps\n");
-					bnx2x_mdio45_vwrite(bp, ext_phy_addr,
-						EXT_PHY_OPT_PMA_PMD_DEVAD,
-						EXT_PHY_OPT_PMD_DIGITAL_CNT,
-						0x400);
-				} else {
-					/* Force 1Gbps */
-					DP(NETIF_MSG_LINK,
-					   "XGXS 8706 force 1Gbps\n");
-
-					bnx2x_mdio45_vwrite(bp, ext_phy_addr,
-						EXT_PHY_OPT_PMA_PMD_DEVAD,
-						EXT_PHY_OPT_CNTL,
-						0x0040);
-
-					bnx2x_mdio45_vwrite(bp, ext_phy_addr,
-						EXT_PHY_OPT_PMA_PMD_DEVAD,
-						EXT_PHY_OPT_CNTL2,
-						0x000D);
-				}
-
-				/* Enable LASI */
-				bnx2x_mdio45_vwrite(bp, ext_phy_addr,
-						    EXT_PHY_OPT_PMA_PMD_DEVAD,
-						    EXT_PHY_OPT_LASI_CNTL,
-						    0x1);
-			} else {
-				/* AUTONEG */
-				/* Allow CL37 through CL73 */
-				DP(NETIF_MSG_LINK, "XGXS 8706 AutoNeg\n");
-				bnx2x_mdio45_vwrite(bp, ext_phy_addr,
-						    EXT_PHY_AUTO_NEG_DEVAD,
-						    EXT_PHY_OPT_AN_CL37_CL73,
-						    0x040c);
-
-				/* Enable Full-Duplex advertisment on CL37 */
-				bnx2x_mdio45_vwrite(bp, ext_phy_addr,
-						    EXT_PHY_AUTO_NEG_DEVAD,
-						    EXT_PHY_OPT_AN_CL37_FD,
-						    0x0020);
-				/* Enable CL37 AN */
-				bnx2x_mdio45_vwrite(bp, ext_phy_addr,
-						    EXT_PHY_AUTO_NEG_DEVAD,
-						    EXT_PHY_OPT_AN_CL37_AN,
-						    0x1000);
-				/* Advertise 10G/1G support */
-				if (bp->advertising &
-				    ADVERTISED_1000baseT_Full)
-					val = (1<<5);
-				if (bp->advertising &
-				    ADVERTISED_10000baseT_Full)
-					val |= (1<<7);
-
-				bnx2x_mdio45_vwrite(bp, ext_phy_addr,
-						    EXT_PHY_AUTO_NEG_DEVAD,
-						    EXT_PHY_OPT_AN_ADV, val);
-				/* Enable LASI */
-				bnx2x_mdio45_vwrite(bp, ext_phy_addr,
-						    EXT_PHY_OPT_PMA_PMD_DEVAD,
-						    EXT_PHY_OPT_LASI_CNTL,
-						    0x1);
-
-				/* Enable clause 73 AN */
-				bnx2x_mdio45_write(bp, ext_phy_addr,
-						   EXT_PHY_AUTO_NEG_DEVAD,
-						   EXT_PHY_OPT_CNTL,
-						   0x1200);
-			}
-			break;
-
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072:
-			bnx2x_hw_lock(bp, HW_LOCK_RESOURCE_8072_MDIO);
-			/* Wait for soft reset to get cleared upto 1 sec */
-			for (cnt = 0; cnt < 1000; cnt++) {
-				bnx2x_mdio45_ctrl_read(bp, GRCBASE_EMAC0,
-						ext_phy_addr,
-						EXT_PHY_OPT_PMA_PMD_DEVAD,
-						EXT_PHY_OPT_CNTL, &ctrl);
-				if (!(ctrl & (1<<15)))
-					break;
-				msleep(1);
-			}
-			DP(NETIF_MSG_LINK,
-			   "8072 control reg 0x%x (after %d ms)\n",
-			   ctrl, cnt);
-
-			bnx2x_bcm8072_external_rom_boot(bp);
-			DP(NETIF_MSG_LINK, "Finshed loading 8072 KR ROM\n");
-
-			/* enable LASI */
-			bnx2x_mdio45_ctrl_write(bp, GRCBASE_EMAC0,
-						ext_phy_addr,
-						EXT_PHY_KR_PMA_PMD_DEVAD,
-						0x9000, 0x0400);
-			bnx2x_mdio45_ctrl_write(bp, GRCBASE_EMAC0,
-						ext_phy_addr,
-						EXT_PHY_KR_PMA_PMD_DEVAD,
-						EXT_PHY_KR_LASI_CNTL, 0x0004);
-
-			/* If this is forced speed, set to KR or KX
-			 * (all other are not supported)
-			 */
-			if (!(bp->req_autoneg & AUTONEG_SPEED)) {
-				if (bp->req_line_speed == SPEED_10000) {
-					bnx2x_bcm8072_force_10G(bp);
-					DP(NETIF_MSG_LINK,
-					   "Forced speed 10G on 8072\n");
-					/* unlock */
-					bnx2x_hw_unlock(bp,
-						HW_LOCK_RESOURCE_8072_MDIO);
-					break;
-				} else
-					val = (1<<5);
-			} else {
-
-				/* Advertise 10G/1G support */
-				if (bp->advertising &
-						ADVERTISED_1000baseT_Full)
-					val = (1<<5);
-				if (bp->advertising &
-						ADVERTISED_10000baseT_Full)
-					val |= (1<<7);
-			}
-			bnx2x_mdio45_ctrl_write(bp, GRCBASE_EMAC0,
-					ext_phy_addr,
-					EXT_PHY_KR_AUTO_NEG_DEVAD,
-					0x11, val);
-			/* Add support for CL37 ( passive mode ) I */
-			bnx2x_mdio45_ctrl_write(bp, GRCBASE_EMAC0,
-						ext_phy_addr,
-						EXT_PHY_KR_AUTO_NEG_DEVAD,
-						0x8370, 0x040c);
-			/* Add support for CL37 ( passive mode ) II */
-			bnx2x_mdio45_ctrl_write(bp, GRCBASE_EMAC0,
-						ext_phy_addr,
-						EXT_PHY_KR_AUTO_NEG_DEVAD,
-						0xffe4, 0x20);
-			/* Add support for CL37 ( passive mode ) III */
-			bnx2x_mdio45_ctrl_write(bp, GRCBASE_EMAC0,
-						ext_phy_addr,
-						EXT_PHY_KR_AUTO_NEG_DEVAD,
-						0xffe0, 0x1000);
-			/* Restart autoneg */
-			msleep(500);
-			bnx2x_mdio45_ctrl_write(bp, GRCBASE_EMAC0,
-					ext_phy_addr,
-					EXT_PHY_KR_AUTO_NEG_DEVAD,
-					EXT_PHY_KR_CTRL, 0x1200);
-			DP(NETIF_MSG_LINK, "8072 Autoneg Restart: "
-			   "1G %ssupported  10G %ssupported\n",
-			   (val & (1<<5)) ? "" : "not ",
-			   (val & (1<<7)) ? "" : "not ");
-
-			/* unlock */
-			bnx2x_hw_unlock(bp, HW_LOCK_RESOURCE_8072_MDIO);
-			break;
-
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101:
-			DP(NETIF_MSG_LINK,
-			   "Setting the SFX7101 LASI indication\n");
-			bnx2x_mdio45_vwrite(bp, ext_phy_addr,
-					    EXT_PHY_OPT_PMA_PMD_DEVAD,
-					    EXT_PHY_OPT_LASI_CNTL, 0x1);
-			DP(NETIF_MSG_LINK,
-			   "Setting the SFX7101 LED to blink on traffic\n");
-			bnx2x_mdio45_vwrite(bp, ext_phy_addr,
-					    EXT_PHY_OPT_PMA_PMD_DEVAD,
-					    0xC007, (1<<3));
-
-			/* read modify write pause advertizing */
-			bnx2x_mdio45_read(bp, ext_phy_addr,
-					  EXT_PHY_KR_AUTO_NEG_DEVAD,
-					  EXT_PHY_KR_AUTO_NEG_ADVERT, &val);
-			val &= ~EXT_PHY_KR_AUTO_NEG_ADVERT_PAUSE_BOTH;
-			/* Please refer to Table 28B-3 of 802.3ab-1999 spec. */
-			if (bp->advertising & ADVERTISED_Pause)
-				val |= EXT_PHY_KR_AUTO_NEG_ADVERT_PAUSE;
-
-			if (bp->advertising & ADVERTISED_Asym_Pause) {
-				val |=
-				 EXT_PHY_KR_AUTO_NEG_ADVERT_PAUSE_ASYMMETRIC;
-			}
-			DP(NETIF_MSG_LINK, "SFX7101 AN advertize 0x%x\n", val);
-			bnx2x_mdio45_vwrite(bp, ext_phy_addr,
-					    EXT_PHY_KR_AUTO_NEG_DEVAD,
-					    EXT_PHY_KR_AUTO_NEG_ADVERT, val);
-			/* Restart autoneg */
-			bnx2x_mdio45_read(bp, ext_phy_addr,
-					  EXT_PHY_KR_AUTO_NEG_DEVAD,
-					  EXT_PHY_KR_CTRL, &val);
-			val |= 0x200;
-			bnx2x_mdio45_write(bp, ext_phy_addr,
-					    EXT_PHY_KR_AUTO_NEG_DEVAD,
-					    EXT_PHY_KR_CTRL, val);
-			break;
-
-		default:
-			BNX2X_ERR("BAD XGXS ext_phy_config 0x%x\n",
-				  bp->ext_phy_config);
-			break;
-		}
-
-	} else { /* SerDes */
-/*		ext_phy_addr = ((bp->ext_phy_config &
-				 PORT_HW_CFG_SERDES_EXT_PHY_ADDR_MASK) >>
-				PORT_HW_CFG_SERDES_EXT_PHY_ADDR_SHIFT);
-*/
-		ext_phy_type = SERDES_EXT_PHY_TYPE(bp);
-		switch (ext_phy_type) {
-		case PORT_HW_CFG_SERDES_EXT_PHY_TYPE_DIRECT:
-			DP(NETIF_MSG_LINK, "SerDes Direct\n");
-			break;
-
-		case PORT_HW_CFG_SERDES_EXT_PHY_TYPE_BCM5482:
-			DP(NETIF_MSG_LINK, "SerDes 5482\n");
-			break;
-
-		default:
-			DP(NETIF_MSG_LINK, "BAD SerDes ext_phy_config 0x%x\n",
-			   bp->ext_phy_config);
-			break;
-		}
-	}
-}
-
-static void bnx2x_ext_phy_reset(struct bnx2x *bp)
-{
-	u32 ext_phy_type;
-	u32 ext_phy_addr = ((bp->ext_phy_config &
-			     PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
-			    PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT);
-	u32 board = (bp->board & SHARED_HW_CFG_BOARD_TYPE_MASK);
-
-	/* The PHY reset is controled by GPIO 1
-	 * Give it 1ms of reset pulse
-	 */
-	if ((board != SHARED_HW_CFG_BOARD_TYPE_BCM957710T1002G) &&
-	    (board != SHARED_HW_CFG_BOARD_TYPE_BCM957710T1003G)) {
-		bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_1,
-			       MISC_REGISTERS_GPIO_OUTPUT_LOW);
-		msleep(1);
-		bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_1,
-			       MISC_REGISTERS_GPIO_OUTPUT_HIGH);
-	}
-
-	if (bp->phy_flags & PHY_XGXS_FLAG) {
-		ext_phy_type = XGXS_EXT_PHY_TYPE(bp);
-		switch (ext_phy_type) {
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT:
-			DP(NETIF_MSG_LINK, "XGXS Direct\n");
-			break;
-
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705:
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706:
-			DP(NETIF_MSG_LINK, "XGXS 8705/8706\n");
-			bnx2x_mdio45_write(bp, ext_phy_addr,
-					   EXT_PHY_OPT_PMA_PMD_DEVAD,
-					   EXT_PHY_OPT_CNTL, 0xa040);
-			break;
-
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072:
-			DP(NETIF_MSG_LINK, "XGXS 8072\n");
-			bnx2x_hw_lock(bp, HW_LOCK_RESOURCE_8072_MDIO);
-			bnx2x_mdio45_ctrl_write(bp, GRCBASE_EMAC0,
-						ext_phy_addr,
-						EXT_PHY_KR_PMA_PMD_DEVAD,
-						0, 1<<15);
-			bnx2x_hw_unlock(bp, HW_LOCK_RESOURCE_8072_MDIO);
-			break;
-
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101:
-			DP(NETIF_MSG_LINK, "XGXS SFX7101\n");
-			break;
-
-		default:
-			DP(NETIF_MSG_LINK, "BAD XGXS ext_phy_config 0x%x\n",
-			   bp->ext_phy_config);
-			break;
-		}
-
-	} else { /* SerDes */
-		ext_phy_type = SERDES_EXT_PHY_TYPE(bp);
-		switch (ext_phy_type) {
-		case PORT_HW_CFG_SERDES_EXT_PHY_TYPE_DIRECT:
-			DP(NETIF_MSG_LINK, "SerDes Direct\n");
-			break;
-
-		case PORT_HW_CFG_SERDES_EXT_PHY_TYPE_BCM5482:
-			DP(NETIF_MSG_LINK, "SerDes 5482\n");
-			break;
+	if (bp->link_vars.link_up)
+		bnx2x_link_report(bp);
 
-		default:
-			DP(NETIF_MSG_LINK, "BAD SerDes ext_phy_config 0x%x\n",
-			   bp->ext_phy_config);
-			break;
-		}
-	}
+	bnx2x_calc_fc_adv(bp);
+	return rc;
 }
 
-static void bnx2x_link_initialize(struct bnx2x *bp)
+static void bnx2x_link_set(struct bnx2x *bp)
 {
-	int port = bp->port;
-
-	/* disable attentions */
-	bnx2x_bits_dis(bp, NIG_REG_MASK_INTERRUPT_PORT0 + port*4,
-		       (NIG_MASK_XGXS0_LINK_STATUS |
-			NIG_MASK_XGXS0_LINK10G |
-			NIG_MASK_SERDES0_LINK_STATUS |
-			NIG_MASK_MI_INT));
-
-	/* Activate the external PHY */
-	bnx2x_ext_phy_reset(bp);
-
-	bnx2x_set_aer_mmd(bp);
-
-	if (bp->phy_flags & PHY_XGXS_FLAG)
-		bnx2x_set_master_ln(bp);
-
-	/* reset the SerDes and wait for reset bit return low */
-	bnx2x_reset_unicore(bp);
-
-	bnx2x_set_aer_mmd(bp);
-
-	/* setting the masterLn_def again after the reset */
-	if (bp->phy_flags & PHY_XGXS_FLAG) {
-		bnx2x_set_master_ln(bp);
-		bnx2x_set_swap_lanes(bp);
-	}
-
-	/* Set Parallel Detect */
-	if (bp->req_autoneg & AUTONEG_SPEED)
-		bnx2x_set_parallel_detection(bp);
-
-	if (bp->phy_flags & PHY_XGXS_FLAG) {
-		if (bp->req_line_speed &&
-		    bp->req_line_speed < SPEED_1000) {
-			bp->phy_flags |= PHY_SGMII_FLAG;
-		} else {
-			bp->phy_flags &= ~PHY_SGMII_FLAG;
-		}
-	}
-
-	if (!(bp->phy_flags & PHY_SGMII_FLAG)) {
-		u16 bank, rx_eq;
-
-		rx_eq = ((bp->serdes_config &
-			  PORT_HW_CFG_SERDES_RX_DRV_EQUALIZER_MASK) >>
-			 PORT_HW_CFG_SERDES_RX_DRV_EQUALIZER_SHIFT);
-
-		DP(NETIF_MSG_LINK, "setting rx eq to %d\n", rx_eq);
-		for (bank = MDIO_REG_BANK_RX0; bank <= MDIO_REG_BANK_RX_ALL;
-			    bank += (MDIO_REG_BANK_RX1 - MDIO_REG_BANK_RX0)) {
-			MDIO_SET_REG_BANK(bp, bank);
-			bnx2x_mdio22_write(bp, MDIO_RX0_RX_EQ_BOOST,
-					   ((rx_eq &
-				MDIO_RX0_RX_EQ_BOOST_EQUALIZER_CTRL_MASK) |
-				MDIO_RX0_RX_EQ_BOOST_OFFSET_CTRL));
-		}
-
-		/* forced speed requested? */
-		if (!(bp->req_autoneg & AUTONEG_SPEED)) {
-			DP(NETIF_MSG_LINK, "not SGMII, no AN\n");
-
-			/* disable autoneg */
-			bnx2x_set_autoneg(bp);
-
-			/* program speed and duplex */
-			bnx2x_program_serdes(bp);
-
-		} else { /* AN_mode */
-			DP(NETIF_MSG_LINK, "not SGMII, AN\n");
-
-			/* AN enabled */
-			bnx2x_set_brcm_cl37_advertisment(bp);
-
-			/* program duplex & pause advertisement (for aneg) */
-			bnx2x_set_ieee_aneg_advertisment(bp);
+	bnx2x_phy_hw_lock(bp);
+	bnx2x_phy_init(&bp->link_params, &bp->link_vars);
+	bnx2x_phy_hw_unlock(bp);
 
-			/* enable autoneg */
-			bnx2x_set_autoneg(bp);
-
-			/* enable and restart AN */
-			bnx2x_restart_autoneg(bp);
-		}
-
-	} else { /* SGMII mode */
-		DP(NETIF_MSG_LINK, "SGMII\n");
-
-		bnx2x_initialize_sgmii_process(bp);
-	}
-
-	/* init ext phy and enable link state int */
-	bnx2x_ext_phy_init(bp);
-
-	/* enable the interrupt */
-	bnx2x_link_int_enable(bp);
+	bnx2x_calc_fc_adv(bp);
 }
 
-static void bnx2x_phy_deassert(struct bnx2x *bp)
+static void bnx2x__link_reset(struct bnx2x *bp)
 {
-	int port = bp->port;
-	u32 val;
-
-	if (bp->phy_flags & PHY_XGXS_FLAG) {
-		DP(NETIF_MSG_LINK, "XGXS\n");
-		val = XGXS_RESET_BITS;
-
-	} else { /* SerDes */
-		DP(NETIF_MSG_LINK, "SerDes\n");
-		val = SERDES_RESET_BITS;
-	}
-
-	val = val << (port*16);
-
-	/* reset and unreset the SerDes/XGXS */
-	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_3_CLEAR, val);
-	msleep(5);
-	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_3_SET, val);
+	bnx2x_phy_hw_lock(bp);
+	bnx2x_link_reset(&bp->link_params, &bp->link_vars);
+	bnx2x_phy_hw_unlock(bp);
 }
 
-static int bnx2x_phy_init(struct bnx2x *bp)
+static u8 bnx2x_link_test(struct bnx2x *bp)
 {
-	DP(NETIF_MSG_LINK, "started\n");
-	if (CHIP_REV(bp) == CHIP_REV_FPGA) {
-		bp->phy_flags |= PHY_EMAC_FLAG;
-		bp->link_up = 1;
-		bp->line_speed = SPEED_10000;
-		bp->duplex = DUPLEX_FULL;
-		NIG_WR(NIG_REG_EGRESS_DRAIN0_MODE + bp->port*4, 0);
-		bnx2x_emac_enable(bp);
-		bnx2x_link_report(bp);
-		return 0;
+	u8 rc;
 
-	} else if (CHIP_REV(bp) == CHIP_REV_EMUL) {
-		bp->phy_flags |= PHY_BMAC_FLAG;
-		bp->link_up = 1;
-		bp->line_speed = SPEED_10000;
-		bp->duplex = DUPLEX_FULL;
-		NIG_WR(NIG_REG_EGRESS_DRAIN0_MODE + bp->port*4, 0);
-		bnx2x_bmac_enable(bp, 0);
-		bnx2x_link_report(bp);
-		return 0;
+	bnx2x_phy_hw_lock(bp);
+	rc = bnx2x_test_link(&bp->link_params, &bp->link_vars);
+	bnx2x_phy_hw_unlock(bp);
 
-	} else {
-		bnx2x_phy_deassert(bp);
-		bnx2x_link_initialize(bp);
-	}
-
-	return 0;
+	return rc;
 }
 
-static void bnx2x_link_reset(struct bnx2x *bp)
+/* This function is called upon link interrupt */
+static void bnx2x_link_attn(struct bnx2x *bp)
 {
-	int port = bp->port;
-	u32 board = (bp->board & SHARED_HW_CFG_BOARD_TYPE_MASK);
-
-	/* update shared memory */
-	bp->link_status = 0;
-	bnx2x_update_mng(bp);
-
-	/* disable attentions */
-	bnx2x_bits_dis(bp, NIG_REG_MASK_INTERRUPT_PORT0 + port*4,
-		       (NIG_MASK_XGXS0_LINK_STATUS |
-			NIG_MASK_XGXS0_LINK10G |
-			NIG_MASK_SERDES0_LINK_STATUS |
-			NIG_MASK_MI_INT));
-
-	/* activate nig drain */
-	NIG_WR(NIG_REG_EGRESS_DRAIN0_MODE + port*4, 1);
-
-	/* disable nig egress interface */
-	NIG_WR(NIG_REG_BMAC0_OUT_EN + port*4, 0);
-	NIG_WR(NIG_REG_EGRESS_EMAC0_OUT_EN + port*4, 0);
-
-	/* Stop BigMac rx */
-	bnx2x_bmac_rx_disable(bp);
-
-	/* disable emac */
-	NIG_WR(NIG_REG_NIG_EMAC0_EN + port*4, 0);
-
-	msleep(10);
-
-	/* The PHY reset is controled by GPIO 1
-	 * Hold it as output low
-	 */
-	if ((board != SHARED_HW_CFG_BOARD_TYPE_BCM957710T1002G) &&
-	    (board != SHARED_HW_CFG_BOARD_TYPE_BCM957710T1003G)) {
-		bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_1,
-			       MISC_REGISTERS_GPIO_OUTPUT_LOW);
-		DP(NETIF_MSG_LINK, "reset external PHY\n");
-	}
-
-	/* reset the SerDes/XGXS */
-	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_3_CLEAR,
-	       (0x1ff << (port*16)));
-
-	/* reset BigMac */
-	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_CLEAR,
-	       (MISC_REGISTERS_RESET_REG_2_RST_BMAC0 << port));
+	bnx2x_phy_hw_lock(bp);
+	bnx2x_link_update(&bp->link_params, &bp->link_vars);
+	bnx2x_phy_hw_unlock(bp);
 
-	/* disable nig ingress interface */
-	NIG_WR(NIG_REG_BMAC0_IN_EN + port*4, 0);
-	NIG_WR(NIG_REG_EMAC0_IN_EN + port*4, 0);
-
-	/* set link down */
-	bp->link_up = 0;
+	/* indicate link status */
+	bnx2x_link_report(bp);
 }
 
-#ifdef BNX2X_XGXS_LB
-static void bnx2x_set_xgxs_loopback(struct bnx2x *bp, int is_10g)
+static void bnx2x__link_status_update(struct bnx2x *bp)
 {
-	int port = bp->port;
-
-	if (is_10g) {
-		u32 md_devad;
-
-		DP(NETIF_MSG_LINK, "XGXS 10G loopback enable\n");
-
-		/* change the uni_phy_addr in the nig */
-		REG_RD(bp, (NIG_REG_XGXS0_CTRL_MD_DEVAD + port*0x18),
-		       &md_devad);
-		NIG_WR(NIG_REG_XGXS0_CTRL_MD_DEVAD + port*0x18, 0x5);
-
-		/* change the aer mmd */
-		MDIO_SET_REG_BANK(bp, MDIO_REG_BANK_AER_BLOCK);
-		bnx2x_mdio22_write(bp, MDIO_AER_BLOCK_AER_REG, 0x2800);
-
-		/* config combo IEEE0 control reg for loopback */
-		MDIO_SET_REG_BANK(bp, MDIO_REG_BANK_CL73_IEEEB0);
-		bnx2x_mdio22_write(bp, MDIO_CL73_IEEEB0_CL73_AN_CONTROL,
-				   0x6041);
-
-		/* set aer mmd back */
-		bnx2x_set_aer_mmd(bp);
-
-		/* and md_devad */
-		NIG_WR(NIG_REG_XGXS0_CTRL_MD_DEVAD + port*0x18, md_devad);
-
-	} else {
-		u32 mii_control;
+	if (bp->state != BNX2X_STATE_OPEN)
+		return;
 
-		DP(NETIF_MSG_LINK, "XGXS 1G loopback enable\n");
+	bnx2x_link_status_update(&bp->link_params, &bp->link_vars);
 
-		MDIO_SET_REG_BANK(bp, MDIO_REG_BANK_COMBO_IEEE0);
-		bnx2x_mdio22_read(bp, MDIO_COMBO_IEEE0_MII_CONTROL,
-				  &mii_control);
-		bnx2x_mdio22_write(bp, MDIO_COMBO_IEEE0_MII_CONTROL,
-				   (mii_control |
-				    MDIO_COMBO_IEEO_MII_CONTROL_LOOPBACK));
-	}
+	/* indicate link status */
+	bnx2x_link_report(bp);
 }
-#endif
 
-/* end of PHY/MAC */
+/* end of Link */
 
 /* slow path */
 
@@ -4112,7 +1610,7 @@ static void bnx2x_attn_int_asserted(struct bnx2x *bp, u32 asserted)
 			bp->nig_mask = REG_RD(bp, nig_int_mask_addr);
 			REG_WR(bp, nig_int_mask_addr, 0);
 
-			bnx2x_link_update(bp);
+			bnx2x_link_attn(bp);
 
 			/* handle unicore attn? */
 		}
@@ -4195,14 +1693,14 @@ static inline void bnx2x_attn_int_deasserted0(struct bnx2x *bp, u32 attn)
 			bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
 				       MISC_REGISTERS_GPIO_OUTPUT_LOW);
 			/* mark the failure */
-			bp->ext_phy_config &=
+			bp->link_params.ext_phy_config &=
 					~PORT_HW_CFG_XGXS_EXT_PHY_TYPE_MASK;
-			bp->ext_phy_config |=
+			bp->link_params.ext_phy_config |=
 					PORT_HW_CFG_XGXS_EXT_PHY_TYPE_FAILURE;
 			SHMEM_WR(bp,
 				 dev_info.port_hw_config[port].
 							external_phy_config,
-				 bp->ext_phy_config);
+				 bp->link_params.ext_phy_config);
 			/* log the failure */
 			printk(KERN_ERR PFX "Fan Failure on Network"
 			       " Controller %s has caused the driver to"
@@ -4579,7 +2077,7 @@ static void bnx2x_init_mac_stats(struct bnx2x *bp)
 #endif
 			  (port ? DMAE_CMD_PORT_1 : DMAE_CMD_PORT_0));
 
-		if (bp->link_up)
+		if (bp->link_vars.link_up)
 			opcode |= (DMAE_CMD_C_DST_GRC | DMAE_CMD_C_ENABLE);
 
 		dmae = bnx2x_sp(bp, dmae[bp->executer_idx++]);
@@ -4592,7 +2090,7 @@ static void bnx2x_init_mac_stats(struct bnx2x *bp)
 		dmae->dst_addr_hi = 0;
 		dmae->len = (offsetof(struct bnx2x_eth_stats, mac_stx_end) -
 			     sizeof(u32)) >> 2;
-		if (bp->link_up) {
+		if (bp->link_vars.link_up) {
 			dmae->comp_addr_lo = dmae_reg_go_c[loader_idx] >> 2;
 			dmae->comp_addr_hi = 0;
 			dmae->comp_val = 1;
@@ -4603,7 +2101,7 @@ static void bnx2x_init_mac_stats(struct bnx2x *bp)
 		}
 	}
 
-	if (!bp->link_up) {
+	if (!bp->link_vars.link_up) {
 		/* no need to collect statistics in link down */
 		return;
 	}
@@ -4618,7 +2116,7 @@ static void bnx2x_init_mac_stats(struct bnx2x *bp)
 #endif
 		  (port ? DMAE_CMD_PORT_1 : DMAE_CMD_PORT_0));
 
-	if (bp->phy_flags & PHY_BMAC_FLAG) {
+	if (bp->link_vars.mac_type == MAC_TYPE_BMAC) {
 
 		mac_addr = (port ? NIG_REG_INGRESS_BMAC1_MEM :
 				   NIG_REG_INGRESS_BMAC0_MEM);
@@ -4655,7 +2153,7 @@ static void bnx2x_init_mac_stats(struct bnx2x *bp)
 		dmae->comp_addr_hi = 0;
 		dmae->comp_val = 1;
 
-	} else if (bp->phy_flags & PHY_EMAC_FLAG) {
+	} else if (bp->link_vars.mac_type == MAC_TYPE_EMAC) {
 
 		mac_addr = (port ? GRCBASE_EMAC1 : GRCBASE_EMAC0);
 
@@ -5098,10 +2596,10 @@ static void bnx2x_update_stats(struct bnx2x *bp)
 
 	if (!bnx2x_update_storm_stats(bp)) {
 
-		if (bp->phy_flags & PHY_BMAC_FLAG) {
+		if (bp->link_vars.mac_type == MAC_TYPE_BMAC) {
 			bnx2x_update_bmac_stats(bp);
 
-		} else if (bp->phy_flags & PHY_EMAC_FLAG) {
+		} else if (bp->link_vars.mac_type == MAC_TYPE_EMAC) {
 			bnx2x_update_emac_stats(bp);
 
 		} else { /* unreached */
@@ -6567,7 +4065,7 @@ static int bnx2x_function_init(struct bnx2x *bp, int mode)
 		break;
 	}
 
-	bnx2x_link_reset(bp);
+	bnx2x__link_reset(bp);
 
 	/* Reset PCIE errors for debug */
 	REG_WR(bp, 0x2114, 0xffffffff);
@@ -7209,7 +4707,7 @@ static int bnx2x_nic_load(struct bnx2x *bp, int req_irq)
 
 	bnx2x_set_mac_addr(bp);
 
-	bnx2x_phy_init(bp);
+	bnx2x_initial_phy_init(bp);
 
 	/* Start fast path */
 	if (req_irq) { /* IRQ is only requested from bnx2x_open */
@@ -7434,7 +4932,7 @@ static int bnx2x_nic_unload(struct bnx2x *bp, int free_irq)
 	}
 
 unload_error:
-	bnx2x_link_reset(bp);
+	bnx2x__link_reset(bp);
 
 	if (!nomcp)
 		reset_code = bnx2x_fw_command(bp, reset_code);
@@ -7476,13 +4974,12 @@ static void bnx2x_link_settings_supported(struct bnx2x *bp, u32 switch_cfg)
 	int port = bp->port;
 	u32 ext_phy_type;
 
-	bp->phy_flags = 0;
-
 	switch (switch_cfg) {
 	case SWITCH_CFG_1G:
 		BNX2X_DEV_INFO("switch_cfg 0x%x (1G)\n", switch_cfg);
 
-		ext_phy_type = SERDES_EXT_PHY_TYPE(bp);
+		ext_phy_type =
+			SERDES_EXT_PHY_TYPE(bp->link_params.ext_phy_config);
 		switch (ext_phy_type) {
 		case PORT_HW_CFG_SERDES_EXT_PHY_TYPE_DIRECT:
 			BNX2X_DEV_INFO("ext_phy_type 0x%x (Direct)\n",
@@ -7504,8 +5001,6 @@ static void bnx2x_link_settings_supported(struct bnx2x *bp, u32 switch_cfg)
 			BNX2X_DEV_INFO("ext_phy_type 0x%x (5482)\n",
 				       ext_phy_type);
 
-			bp->phy_flags |= PHY_SGMII_FLAG;
-
 			bp->supported |= (SUPPORTED_10baseT_Half |
 					  SUPPORTED_10baseT_Full |
 					  SUPPORTED_100baseT_Half |
@@ -7520,7 +5015,7 @@ static void bnx2x_link_settings_supported(struct bnx2x *bp, u32 switch_cfg)
 		default:
 			BNX2X_ERR("NVRAM config error. "
 				  "BAD SerDes ext_phy_config 0x%x\n",
-				  bp->ext_phy_config);
+				  bp->link_params.ext_phy_config);
 			return;
 		}
 
@@ -7532,9 +5027,8 @@ static void bnx2x_link_settings_supported(struct bnx2x *bp, u32 switch_cfg)
 	case SWITCH_CFG_10G:
 		BNX2X_DEV_INFO("switch_cfg 0x%x (10G)\n", switch_cfg);
 
-		bp->phy_flags |= PHY_XGXS_FLAG;
-
-		ext_phy_type = XGXS_EXT_PHY_TYPE(bp);
+		ext_phy_type =
+			XGXS_EXT_PHY_TYPE(bp->link_params.ext_phy_config);
 		switch (ext_phy_type) {
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT:
 			BNX2X_DEV_INFO("ext_phy_type 0x%x (Direct)\n",
@@ -7587,6 +5081,19 @@ static void bnx2x_link_settings_supported(struct bnx2x *bp, u32 switch_cfg)
 					  SUPPORTED_Asym_Pause);
 			break;
 
+		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073:
+			BNX2X_DEV_INFO("ext_phy_type 0x%x (8073)\n",
+				       ext_phy_type);
+
+			bp->supported |= (SUPPORTED_10000baseT_Full |
+					  SUPPORTED_2500baseX_Full |
+					  SUPPORTED_1000baseT_Full |
+					  SUPPORTED_FIBRE |
+					  SUPPORTED_Autoneg |
+					  SUPPORTED_Pause |
+					  SUPPORTED_Asym_Pause);
+			break;
+
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101:
 			BNX2X_DEV_INFO("ext_phy_type 0x%x (SFX7101)\n",
 				       ext_phy_type);
@@ -7598,10 +5105,15 @@ static void bnx2x_link_settings_supported(struct bnx2x *bp, u32 switch_cfg)
 					  SUPPORTED_Asym_Pause);
 			break;
 
+		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_FAILURE:
+			BNX2X_ERR("XGXS PHY Failure detected 0x%x\n",
+				  bp->link_params.ext_phy_config);
+			break;
+
 		default:
 			BNX2X_ERR("NVRAM config error. "
 				  "BAD XGXS ext_phy_config 0x%x\n",
-				  bp->ext_phy_config);
+				  bp->link_params.ext_phy_config);
 			return;
 		}
 
@@ -7609,17 +5121,6 @@ static void bnx2x_link_settings_supported(struct bnx2x *bp, u32 switch_cfg)
 				      port*0x18);
 		BNX2X_DEV_INFO("phy_addr 0x%x\n", bp->phy_addr);
 
-		bp->ser_lane = ((bp->lane_config &
-				 PORT_HW_CFG_LANE_SWAP_CFG_MASTER_MASK) >>
-				PORT_HW_CFG_LANE_SWAP_CFG_MASTER_SHIFT);
-		bp->rx_lane_swap = ((bp->lane_config &
-				     PORT_HW_CFG_LANE_SWAP_CFG_RX_MASK) >>
-				    PORT_HW_CFG_LANE_SWAP_CFG_RX_SHIFT);
-		bp->tx_lane_swap = ((bp->lane_config &
-				     PORT_HW_CFG_LANE_SWAP_CFG_TX_MASK) >>
-				    PORT_HW_CFG_LANE_SWAP_CFG_TX_SHIFT);
-		BNX2X_DEV_INFO("rx_lane_swap 0x%x  tx_lane_swap 0x%x\n",
-			       bp->rx_lane_swap, bp->tx_lane_swap);
 		break;
 
 	default:
@@ -7627,32 +5128,36 @@ static void bnx2x_link_settings_supported(struct bnx2x *bp, u32 switch_cfg)
 			  bp->link_config);
 		return;
 	}
+	bp->link_params.phy_addr = bp->phy_addr;
 
 	/* mask what we support according to speed_cap_mask */
-	if (!(bp->speed_cap_mask &
-	      PORT_HW_CFG_SPEED_CAPABILITY_D0_10M_HALF))
+	if (!(bp->link_params.speed_cap_mask &
+				PORT_HW_CFG_SPEED_CAPABILITY_D0_10M_HALF))
 		bp->supported &= ~SUPPORTED_10baseT_Half;
 
-	if (!(bp->speed_cap_mask &
-	      PORT_HW_CFG_SPEED_CAPABILITY_D0_10M_FULL))
+	if (!(bp->link_params.speed_cap_mask &
+				PORT_HW_CFG_SPEED_CAPABILITY_D0_10M_FULL))
 		bp->supported &= ~SUPPORTED_10baseT_Full;
 
-	if (!(bp->speed_cap_mask &
-	      PORT_HW_CFG_SPEED_CAPABILITY_D0_100M_HALF))
+	if (!(bp->link_params.speed_cap_mask &
+				PORT_HW_CFG_SPEED_CAPABILITY_D0_100M_HALF))
 		bp->supported &= ~SUPPORTED_100baseT_Half;
 
-	if (!(bp->speed_cap_mask &
-	      PORT_HW_CFG_SPEED_CAPABILITY_D0_100M_FULL))
+	if (!(bp->link_params.speed_cap_mask &
+				PORT_HW_CFG_SPEED_CAPABILITY_D0_100M_FULL))
 		bp->supported &= ~SUPPORTED_100baseT_Full;
 
-	if (!(bp->speed_cap_mask & PORT_HW_CFG_SPEED_CAPABILITY_D0_1G))
+	if (!(bp->link_params.speed_cap_mask &
+					PORT_HW_CFG_SPEED_CAPABILITY_D0_1G))
 		bp->supported &= ~(SUPPORTED_1000baseT_Half |
 				   SUPPORTED_1000baseT_Full);
 
-	if (!(bp->speed_cap_mask & PORT_HW_CFG_SPEED_CAPABILITY_D0_2_5G))
+	if (!(bp->link_params.speed_cap_mask &
+					PORT_HW_CFG_SPEED_CAPABILITY_D0_2_5G))
 		bp->supported &= ~SUPPORTED_2500baseX_Full;
 
-	if (!(bp->speed_cap_mask & PORT_HW_CFG_SPEED_CAPABILITY_D0_10G))
+	if (!(bp->link_params.speed_cap_mask &
+					PORT_HW_CFG_SPEED_CAPABILITY_D0_10G))
 		bp->supported &= ~SUPPORTED_10000baseT_Full;
 
 	BNX2X_DEV_INFO("supported 0x%x\n", bp->supported);
@@ -7660,20 +5165,23 @@ static void bnx2x_link_settings_supported(struct bnx2x *bp, u32 switch_cfg)
 
 static void bnx2x_link_settings_requested(struct bnx2x *bp)
 {
-	bp->req_autoneg = 0;
-	bp->req_duplex = DUPLEX_FULL;
+	bp->link_params.req_duplex = DUPLEX_FULL;
 
 	switch (bp->link_config & PORT_FEATURE_LINK_SPEED_MASK) {
 	case PORT_FEATURE_LINK_SPEED_AUTO:
 		if (bp->supported & SUPPORTED_Autoneg) {
-			bp->req_autoneg |= AUTONEG_SPEED;
-			bp->req_line_speed = 0;
+			bp->link_params.req_line_speed = SPEED_AUTO_NEG;
 			bp->advertising = bp->supported;
 		} else {
-			if (XGXS_EXT_PHY_TYPE(bp) ==
-				PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705) {
+			u32 ext_phy_type =
+			    XGXS_EXT_PHY_TYPE(bp->link_params.ext_phy_config);
+
+			if ((ext_phy_type ==
+			     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705) ||
+			    (ext_phy_type ==
+			     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706)) {
 				/* force 10G, no AN */
-				bp->req_line_speed = SPEED_10000;
+				bp->link_params.req_line_speed = SPEED_10000;
 				bp->advertising =
 						(ADVERTISED_10000baseT_Full |
 						 ADVERTISED_FIBRE);
@@ -7689,86 +5197,92 @@ static void bnx2x_link_settings_requested(struct bnx2x *bp)
 
 	case PORT_FEATURE_LINK_SPEED_10M_FULL:
 		if (bp->supported & SUPPORTED_10baseT_Full) {
-			bp->req_line_speed = SPEED_10;
+			bp->link_params.req_line_speed = SPEED_10;
 			bp->advertising = (ADVERTISED_10baseT_Full |
 					   ADVERTISED_TP);
 		} else {
 			BNX2X_ERR("NVRAM config error. "
 				  "Invalid link_config 0x%x"
 				  "  speed_cap_mask 0x%x\n",
-				  bp->link_config, bp->speed_cap_mask);
+				  bp->link_config,
+				  bp->link_params.speed_cap_mask);
 			return;
 		}
 		break;
 
 	case PORT_FEATURE_LINK_SPEED_10M_HALF:
 		if (bp->supported & SUPPORTED_10baseT_Half) {
-			bp->req_line_speed = SPEED_10;
-			bp->req_duplex = DUPLEX_HALF;
+			bp->link_params.req_line_speed = SPEED_10;
+			bp->link_params.req_duplex = DUPLEX_HALF;
 			bp->advertising = (ADVERTISED_10baseT_Half |
 					   ADVERTISED_TP);
 		} else {
 			BNX2X_ERR("NVRAM config error. "
 				  "Invalid link_config 0x%x"
 				  "  speed_cap_mask 0x%x\n",
-				  bp->link_config, bp->speed_cap_mask);
+				  bp->link_config,
+				  bp->link_params.speed_cap_mask);
 			return;
 		}
 		break;
 
 	case PORT_FEATURE_LINK_SPEED_100M_FULL:
 		if (bp->supported & SUPPORTED_100baseT_Full) {
-			bp->req_line_speed = SPEED_100;
+			bp->link_params.req_line_speed = SPEED_100;
 			bp->advertising = (ADVERTISED_100baseT_Full |
 					   ADVERTISED_TP);
 		} else {
 			BNX2X_ERR("NVRAM config error. "
 				  "Invalid link_config 0x%x"
 				  "  speed_cap_mask 0x%x\n",
-				  bp->link_config, bp->speed_cap_mask);
+				  bp->link_config,
+				  bp->link_params.speed_cap_mask);
 			return;
 		}
 		break;
 
 	case PORT_FEATURE_LINK_SPEED_100M_HALF:
 		if (bp->supported & SUPPORTED_100baseT_Half) {
-			bp->req_line_speed = SPEED_100;
-			bp->req_duplex = DUPLEX_HALF;
+			bp->link_params.req_line_speed = SPEED_100;
+			bp->link_params.req_duplex = DUPLEX_HALF;
 			bp->advertising = (ADVERTISED_100baseT_Half |
 					   ADVERTISED_TP);
 		} else {
 			BNX2X_ERR("NVRAM config error. "
 				  "Invalid link_config 0x%x"
 				  "  speed_cap_mask 0x%x\n",
-				  bp->link_config, bp->speed_cap_mask);
+				  bp->link_config,
+				  bp->link_params.speed_cap_mask);
 			return;
 		}
 		break;
 
 	case PORT_FEATURE_LINK_SPEED_1G:
 		if (bp->supported & SUPPORTED_1000baseT_Full) {
-			bp->req_line_speed = SPEED_1000;
+			bp->link_params.req_line_speed = SPEED_1000;
 			bp->advertising = (ADVERTISED_1000baseT_Full |
 					   ADVERTISED_TP);
 		} else {
 			BNX2X_ERR("NVRAM config error. "
 				  "Invalid link_config 0x%x"
 				  "  speed_cap_mask 0x%x\n",
-				  bp->link_config, bp->speed_cap_mask);
+				  bp->link_config,
+				  bp->link_params.speed_cap_mask);
 			return;
 		}
 		break;
 
 	case PORT_FEATURE_LINK_SPEED_2_5G:
 		if (bp->supported & SUPPORTED_2500baseX_Full) {
-			bp->req_line_speed = SPEED_2500;
+			bp->link_params.req_line_speed = SPEED_2500;
 			bp->advertising = (ADVERTISED_2500baseX_Full |
 					   ADVERTISED_TP);
 		} else {
 			BNX2X_ERR("NVRAM config error. "
 				  "Invalid link_config 0x%x"
 				  "  speed_cap_mask 0x%x\n",
-				  bp->link_config, bp->speed_cap_mask);
+				  bp->link_config,
+				  bp->link_params.speed_cap_mask);
 			return;
 		}
 		break;
@@ -7777,14 +5291,15 @@ static void bnx2x_link_settings_requested(struct bnx2x *bp)
 	case PORT_FEATURE_LINK_SPEED_10G_KX4:
 	case PORT_FEATURE_LINK_SPEED_10G_KR:
 		if (bp->supported & SUPPORTED_10000baseT_Full) {
-			bp->req_line_speed = SPEED_10000;
+			bp->link_params.req_line_speed = SPEED_10000;
 			bp->advertising = (ADVERTISED_10000baseT_Full |
 					   ADVERTISED_FIBRE);
 		} else {
 			BNX2X_ERR("NVRAM config error. "
 				  "Invalid link_config 0x%x"
 				  "  speed_cap_mask 0x%x\n",
-				  bp->link_config, bp->speed_cap_mask);
+				  bp->link_config,
+				  bp->link_params.speed_cap_mask);
 			return;
 		}
 		break;
@@ -7793,30 +5308,30 @@ static void bnx2x_link_settings_requested(struct bnx2x *bp)
 		BNX2X_ERR("NVRAM config error. "
 			  "BAD link speed link_config 0x%x\n",
 			  bp->link_config);
-		bp->req_autoneg |= AUTONEG_SPEED;
-		bp->req_line_speed = 0;
+		bp->link_params.req_line_speed = SPEED_AUTO_NEG;
 		bp->advertising = bp->supported;
 		break;
 	}
 	BNX2X_DEV_INFO("req_line_speed %d  req_duplex %d\n",
-		       bp->req_line_speed, bp->req_duplex);
+		       bp->link_params.req_line_speed,
+		       bp->link_params.req_duplex);
 
-	bp->req_flow_ctrl = (bp->link_config &
+	bp->link_params.req_flow_ctrl = (bp->link_config &
 			     PORT_FEATURE_FLOW_CONTROL_MASK);
-	if ((bp->req_flow_ctrl == FLOW_CTRL_AUTO) &&
-	    (bp->supported & SUPPORTED_Autoneg))
-		bp->req_autoneg |= AUTONEG_FLOW_CTRL;
+	if ((bp->link_params.req_flow_ctrl == FLOW_CTRL_AUTO) &&
+	    (!bp->supported & SUPPORTED_Autoneg))
+		bp->link_params.req_flow_ctrl = FLOW_CTRL_NONE;
 
-	BNX2X_DEV_INFO("req_autoneg 0x%x  req_flow_ctrl 0x%x"
-		       "  advertising 0x%x\n",
-		       bp->req_autoneg, bp->req_flow_ctrl, bp->advertising);
+	BNX2X_DEV_INFO("req_flow_ctrl 0x%x"
+		       " advertising 0x%x\n",
+		       bp->link_params.req_flow_ctrl,
+		       bp->advertising);
 }
 
 static void bnx2x_get_hwinfo(struct bnx2x *bp)
 {
 	u32 val, val2, val3, val4, id;
 	int port = bp->port;
-	u32 switch_cfg;
 
 	bp->shmem_base = REG_RD(bp, MISC_REG_SHARED_MEM_ADDR);
 	BNX2X_DEV_INFO("shmem offset is %x\n", bp->shmem_base);
@@ -7834,6 +5349,8 @@ static void bnx2x_get_hwinfo(struct bnx2x *bp)
 	bp->chip_id = id;
 	BNX2X_DEV_INFO("chip ID is %x\n", id);
 
+	bp->link_params.bp = bp;
+
 	if (!bp->shmem_base || (bp->shmem_base != 0xAF900)) {
 		BNX2X_DEV_INFO("MCP not active\n");
 		nomcp = 1;
@@ -7850,35 +5367,32 @@ static void bnx2x_get_hwinfo(struct bnx2x *bp)
 
 	bp->hw_config = SHMEM_RD(bp, dev_info.shared_hw_config.config);
 	bp->board = SHMEM_RD(bp, dev_info.shared_hw_config.board);
-	bp->serdes_config =
+	bp->link_params.serdes_config =
 		SHMEM_RD(bp, dev_info.port_hw_config[port].serdes_config);
-	bp->lane_config =
+	bp->link_params.lane_config =
 		SHMEM_RD(bp, dev_info.port_hw_config[port].lane_config);
-	bp->ext_phy_config =
+	bp->link_params.ext_phy_config =
 		SHMEM_RD(bp,
 			 dev_info.port_hw_config[port].external_phy_config);
-	bp->speed_cap_mask =
+	bp->link_params.speed_cap_mask =
 		SHMEM_RD(bp,
 			 dev_info.port_hw_config[port].speed_capability_mask);
 
 	bp->link_config =
 		SHMEM_RD(bp, dev_info.port_feature_config[port].link_config);
 
-	BNX2X_DEV_INFO("hw_config (%08x) board (%08x)  serdes_config (%08x)\n"
-	     KERN_INFO "  lane_config (%08x)  ext_phy_config (%08x)\n"
-	     KERN_INFO "  speed_cap_mask (%08x)  link_config (%08x)"
-		       "  fw_seq (%08x)\n",
-		       bp->hw_config, bp->board, bp->serdes_config,
-		       bp->lane_config, bp->ext_phy_config,
-		       bp->speed_cap_mask, bp->link_config, bp->fw_seq);
-
-	switch_cfg = (bp->link_config & PORT_FEATURE_CONNECTED_SWITCH_MASK);
-	bnx2x_link_settings_supported(bp, switch_cfg);
+	BNX2X_DEV_INFO("serdes_config (%08x)  lane_config (%08x)\n"
+	     KERN_INFO "  ext_phy_config (%08x)  speed_cap_mask (%08x)"
+		       "  link_config (%08x)\n",
+		       bp->link_params.serdes_config,
+		       bp->link_params.lane_config,
+		       bp->link_params.ext_phy_config,
+		       bp->link_params.speed_cap_mask,
+		       bp->link_config);
 
-	bp->autoneg = (bp->hw_config & SHARED_HW_CFG_AN_ENABLE_MASK);
-	/* for now disable cl73 */
-	bp->autoneg &= ~SHARED_HW_CFG_AN_ENABLE_CL73;
-	BNX2X_DEV_INFO("autoneg 0x%x\n", bp->autoneg);
+	bp->link_params.switch_cfg = (bp->link_config &
+				      PORT_FEATURE_CONNECTED_SWITCH_MASK);
+	bnx2x_link_settings_supported(bp, bp->link_params.switch_cfg);
 
 	bnx2x_link_settings_requested(bp);
 
@@ -7890,8 +5404,9 @@ static void bnx2x_get_hwinfo(struct bnx2x *bp)
 	bp->dev->dev_addr[3] = (u8)(val >> 16 & 0xff);
 	bp->dev->dev_addr[4] = (u8)(val >> 8  & 0xff);
 	bp->dev->dev_addr[5] = (u8)(val & 0xff);
+	memcpy(bp->link_params.mac_addr, bp->dev->dev_addr, ETH_ALEN);
+	memcpy(bp->dev->perm_addr, bp->dev->dev_addr, ETH_ALEN);
 
-	memcpy(bp->dev->perm_addr, bp->dev->dev_addr, 6);
 
 
 	val = SHMEM_RD(bp, dev_info.shared_hw_config.part_num);
@@ -7944,21 +5459,23 @@ static int bnx2x_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	cmd->advertising = bp->advertising;
 
 	if (netif_carrier_ok(dev)) {
-		cmd->speed = bp->line_speed;
-		cmd->duplex = bp->duplex;
+		cmd->speed = bp->link_vars.line_speed;
+		cmd->duplex = bp->link_vars.duplex;
 	} else {
-		cmd->speed = bp->req_line_speed;
-		cmd->duplex = bp->req_duplex;
+		cmd->speed = bp->link_params.req_line_speed;
+		cmd->duplex = bp->link_params.req_duplex;
 	}
 
-	if (bp->phy_flags & PHY_XGXS_FLAG) {
-		u32 ext_phy_type = XGXS_EXT_PHY_TYPE(bp);
+	if (bp->link_params.switch_cfg == SWITCH_CFG_10G) {
+		u32 ext_phy_type =
+			XGXS_EXT_PHY_TYPE(bp->link_params.ext_phy_config);
 
 		switch (ext_phy_type) {
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT:
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705:
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706:
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072:
+		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073:
 			cmd->port = PORT_FIBRE;
 			break;
 
@@ -7966,9 +5483,15 @@ static int bnx2x_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 			cmd->port = PORT_TP;
 			break;
 
+		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_FAILURE:
+			BNX2X_ERR("XGXS PHY Failure detected 0x%x\n",
+				  bp->link_params.ext_phy_config);
+			break;
+
 		default:
 			DP(NETIF_MSG_LINK, "BAD XGXS ext_phy_config 0x%x\n",
-			   bp->ext_phy_config);
+			   bp->link_params.ext_phy_config);
+			break;
 		}
 	} else
 		cmd->port = PORT_TP;
@@ -7976,7 +5499,7 @@ static int bnx2x_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	cmd->phy_address = bp->phy_addr;
 	cmd->transceiver = XCVR_INTERNAL;
 
-	if (bp->req_autoneg & AUTONEG_SPEED)
+	if (bp->link_params.req_line_speed == SPEED_AUTO_NEG)
 		cmd->autoneg = AUTONEG_ENABLE;
 	else
 		cmd->autoneg = AUTONEG_DISABLE;
@@ -8017,9 +5540,8 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		/* advertise the requested speed and duplex if supported */
 		cmd->advertising &= bp->supported;
 
-		bp->req_autoneg |= AUTONEG_SPEED;
-		bp->req_line_speed = 0;
-		bp->req_duplex = DUPLEX_FULL;
+		bp->link_params.req_line_speed = SPEED_AUTO_NEG;
+		bp->link_params.req_duplex = DUPLEX_FULL;
 		bp->advertising |= (ADVERTISED_Autoneg | cmd->advertising);
 
 	} else { /* forced speed */
@@ -8125,34 +5647,45 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 			return -EINVAL;
 		}
 
-		bp->req_autoneg &= ~AUTONEG_SPEED;
-		bp->req_line_speed = cmd->speed;
-		bp->req_duplex = cmd->duplex;
+		bp->link_params.req_line_speed = cmd->speed;
+		bp->link_params.req_duplex = cmd->duplex;
 		bp->advertising = advertising;
 	}
 
-	DP(NETIF_MSG_LINK, "req_autoneg 0x%x  req_line_speed %d\n"
+	DP(NETIF_MSG_LINK, "req_line_speed %d\n"
 	   DP_LEVEL "  req_duplex %d  advertising 0x%x\n",
-	   bp->req_autoneg, bp->req_line_speed, bp->req_duplex,
+	   bp->link_params.req_line_speed, bp->link_params.req_duplex,
 	   bp->advertising);
 
 	bnx2x_stop_stats(bp);
-	bnx2x_link_initialize(bp);
+	bnx2x_link_set(bp);
 
 	return 0;
 }
 
+#define PHY_FW_VER_LEN			10
+
 static void bnx2x_get_drvinfo(struct net_device *dev,
 			      struct ethtool_drvinfo *info)
 {
 	struct bnx2x *bp = netdev_priv(dev);
+	char phy_fw_ver[PHY_FW_VER_LEN];
 
 	strcpy(info->driver, DRV_MODULE_NAME);
 	strcpy(info->version, DRV_MODULE_VERSION);
-	snprintf(info->fw_version, 32, "%d.%d.%d:%d (BC VER %x)",
+
+	phy_fw_ver[0] = '\0';
+	bnx2x_phy_hw_lock(bp);
+	bnx2x_get_ext_phy_fw_version(&bp->link_params,
+				     (bp->state != BNX2X_STATE_CLOSED),
+				     phy_fw_ver, PHY_FW_VER_LEN);
+	bnx2x_phy_hw_unlock(bp);
+
+	snprintf(info->fw_version, 32, "%d.%d.%d:%d BC:%x%s%s",
 		 BCM_5710_FW_MAJOR_VERSION, BCM_5710_FW_MINOR_VERSION,
-		 BCM_5710_FW_REVISION_VERSION, BCM_5710_FW_COMPILE_FLAGS,
-		 bp->bc_ver);
+		 BCM_5710_FW_REVISION_VERSION,
+		 BCM_5710_FW_COMPILE_FLAGS, bp->bc_ver,
+		 ((phy_fw_ver[0] != '\0')? " PHY:":""), phy_fw_ver);
 	strcpy(info->bus_info, pci_name(bp->pdev));
 	info->n_stats = BNX2X_NUM_STATS;
 	info->testinfo_len = BNX2X_NUM_TESTS;
@@ -8220,7 +5753,7 @@ static int bnx2x_nway_reset(struct net_device *dev)
 	}
 
 	bnx2x_stop_stats(bp);
-	bnx2x_link_initialize(bp);
+	bnx2x_link_set(bp);
 
 	return 0;
 }
@@ -8604,7 +6137,22 @@ static int bnx2x_set_eeprom(struct net_device *dev,
 
 	/* parameters already validated in ethtool_set_eeprom */
 
-	rc = bnx2x_nvram_write(bp, eeprom->offset, eebuf, eeprom->len);
+	/* If the magic number is PHY (0x00504859) upgrade the PHY FW */
+	if (eeprom->magic == 0x00504859) {
+
+		bnx2x_phy_hw_lock(bp);
+		rc = bnx2x_flash_download(bp, bp->port,
+				     bp->link_params.ext_phy_config,
+				     (bp->state != BNX2X_STATE_CLOSED),
+				     eebuf, eeprom->len);
+		rc |= bnx2x_link_reset(&bp->link_params,
+				       &bp->link_vars);
+		rc |= bnx2x_phy_init(&bp->link_params,
+				     &bp->link_vars);
+		bnx2x_phy_hw_unlock(bp);
+
+	} else
+		rc = bnx2x_nvram_write(bp, eeprom->offset, eebuf, eeprom->len);
 
 	return rc;
 }
@@ -8690,10 +6238,12 @@ static void bnx2x_get_pauseparam(struct net_device *dev,
 {
 	struct bnx2x *bp = netdev_priv(dev);
 
-	epause->autoneg =
-		((bp->req_autoneg & AUTONEG_FLOW_CTRL) == AUTONEG_FLOW_CTRL);
-	epause->rx_pause = ((bp->flow_ctrl & FLOW_CTRL_RX) == FLOW_CTRL_RX);
-	epause->tx_pause = ((bp->flow_ctrl & FLOW_CTRL_TX) == FLOW_CTRL_TX);
+	epause->autoneg = (bp->link_params.req_flow_ctrl == FLOW_CTRL_AUTO);
+
+	epause->rx_pause = ((bp->link_vars.flow_ctrl & FLOW_CTRL_RX) ==
+			    FLOW_CTRL_RX);
+	epause->tx_pause = ((bp->link_vars.flow_ctrl & FLOW_CTRL_TX) ==
+			    FLOW_CTRL_TX);
 
 	DP(NETIF_MSG_LINK, "ethtool_pauseparam: cmd %d\n"
 	   DP_LEVEL "  autoneg %d  rx_pause %d  tx_pause %d\n",
@@ -8715,26 +6265,27 @@ static int bnx2x_set_pauseparam(struct net_device *dev,
 			return -EINVAL;
 		}
 
-		bp->req_autoneg |= AUTONEG_FLOW_CTRL;
-	} else
-		bp->req_autoneg &= ~AUTONEG_FLOW_CTRL;
-
-	bp->req_flow_ctrl = FLOW_CTRL_AUTO;
-
-	if (epause->rx_pause)
-		bp->req_flow_ctrl |= FLOW_CTRL_RX;
-	if (epause->tx_pause)
-		bp->req_flow_ctrl |= FLOW_CTRL_TX;
+		bp->link_params.req_flow_ctrl = FLOW_CTRL_AUTO;
+	} else {
+		if (epause->rx_pause)
+			bp->link_params.req_flow_ctrl |= FLOW_CTRL_RX;
+		else
+			bp->link_params.req_flow_ctrl &= ~FLOW_CTRL_RX;
+		if (epause->tx_pause)
+			bp->link_params.req_flow_ctrl |= FLOW_CTRL_TX;
+		else
+			bp->link_params.req_flow_ctrl &= ~FLOW_CTRL_TX;
+	}
 
-	if (!(bp->req_autoneg & AUTONEG_FLOW_CTRL) &&
-	    (bp->req_flow_ctrl == FLOW_CTRL_AUTO))
-		bp->req_flow_ctrl = FLOW_CTRL_NONE;
+	if (!(bp->link_params.req_line_speed == SPEED_AUTO_NEG) &&
+	    (bp->link_params.req_flow_ctrl == FLOW_CTRL_AUTO))
+		bp->link_params.req_flow_ctrl = FLOW_CTRL_NONE;
 
-	DP(NETIF_MSG_LINK, "req_autoneg 0x%x  req_flow_ctrl 0x%x\n",
-	   bp->req_autoneg, bp->req_flow_ctrl);
+	DP(NETIF_MSG_LINK, "req_flow_ctrl 0x%x\n",
+	   bp->link_params.req_flow_ctrl);
 
 	bnx2x_stop_stats(bp);
-	bnx2x_link_initialize(bp);
+	bnx2x_link_set(bp);
 
 	return 0;
 }
@@ -8942,18 +6493,25 @@ static int bnx2x_phys_id(struct net_device *dev, u32 data)
 		data = 2;
 
 	for (i = 0; i < (data * 2); i++) {
-		if ((i % 2) == 0) {
-			bnx2x_leds_set(bp, SPEED_1000);
-		} else {
-			bnx2x_leds_unset(bp);
-		}
+		if ((i % 2) == 0)
+			bnx2x_set_led(bp, bp->port, LED_MODE_OPER, SPEED_1000,
+				      bp->link_params.hw_led_mode,
+				      bp->link_params.chip_id);
+		else
+			bnx2x_set_led(bp, bp->port, LED_MODE_OFF, 0,
+				      bp->link_params.hw_led_mode,
+				      bp->link_params.chip_id);
+
 		msleep_interruptible(500);
 		if (signal_pending(current))
 			break;
 	}
 
-	if (bp->link_up)
-		bnx2x_leds_set(bp, bp->line_speed);
+	if (bp->link_vars.link_up)
+		bnx2x_set_led(bp, bp->port, LED_MODE_OPER,
+			      bp->link_vars.line_speed,
+			      bp->link_params.hw_led_mode,
+			      bp->link_params.chip_id);
 
 	return 0;
 }
@@ -9469,7 +7027,7 @@ static int bnx2x_change_mac_addr(struct net_device *dev, void *p)
 	return 0;
 }
 
-/* Called with rtnl_lock */
+/* called with rtnl_lock */
 static int bnx2x_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
 	struct mii_ioctl_data *data = if_mii(ifr);
@@ -9481,19 +7039,19 @@ static int bnx2x_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		data->phy_id = bp->phy_addr;
 
 		/* fallthrough */
+
 	case SIOCGMIIREG: {
-		u32 mii_regval;
+		u16 mii_regval;
 
-		spin_lock_bh(&bp->phy_lock);
-		if (bp->state == BNX2X_STATE_OPEN) {
-			err = bnx2x_mdio22_read(bp, data->reg_num & 0x1f,
-						&mii_regval);
+		if (!netif_running(dev))
+			return -EAGAIN;
 
-			data->val_out = mii_regval;
-		} else {
-			err = -EAGAIN;
-		}
-		spin_unlock_bh(&bp->phy_lock);
+		mutex_lock(&bp->phy_mutex);
+		err = bnx2x_cl45_read(bp, bp->port, 0, bp->phy_addr,
+				      DEFAULT_PHY_DEV_ADDR,
+				      (data->reg_num & 0x1f), &mii_regval);
+		data->val_out = mii_regval;
+		mutex_unlock(&bp->phy_mutex);
 		return err;
 	}
 
@@ -9501,14 +7059,14 @@ static int bnx2x_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
 
-		spin_lock_bh(&bp->phy_lock);
-		if (bp->state == BNX2X_STATE_OPEN) {
-			err = bnx2x_mdio22_write(bp, data->reg_num & 0x1f,
-						 data->val_in);
-		} else {
-			err = -EAGAIN;
-		}
-		spin_unlock_bh(&bp->phy_lock);
+		if (!netif_running(dev))
+			return -EAGAIN;
+
+		mutex_lock(&bp->phy_mutex);
+		err = bnx2x_cl45_write(bp, bp->port, 0, bp->phy_addr,
+				       DEFAULT_PHY_DEV_ADDR,
+				       (data->reg_num & 0x1f), data->val_in);
+		mutex_unlock(&bp->phy_mutex);
 		return err;
 
 	default:
@@ -9681,8 +7239,6 @@ static int __devinit bnx2x_init_board(struct pci_dev *pdev,
 	bp->dev = dev;
 	bp->pdev = pdev;
 
-	spin_lock_init(&bp->phy_lock);
-
 	INIT_WORK(&bp->reset_task, bnx2x_reset_task);
 	INIT_WORK(&bp->sp_task, bnx2x_sp_task);
 
diff --git a/drivers/net/bnx2x_reg.h b/drivers/net/bnx2x_reg.h
index 5a1aa0b..82cf0ec 100644
--- a/drivers/net/bnx2x_reg.h
+++ b/drivers/net/bnx2x_reg.h
@@ -72,6 +72,8 @@
 #define CCM_REG_CCM_INT_MASK					 0xd01e4
 /* [R 11] Interrupt register #0 read */
 #define CCM_REG_CCM_INT_STS					 0xd01d8
+/* [R 27] Parity register #0 read */
+#define CCM_REG_CCM_PRTY_STS					 0xd01e8
 /* [RW 3] The size of AG context region 0 in REG-pairs. Designates the MS
    REG-pair number (e.g. if region 0 is 6 REG-pairs; the value should be 5).
    Is used to determine the number of the AG context REG-pairs written back;
@@ -190,25 +192,20 @@
    weight 8 (the most prioritised); 1 stands for weight 1(least
    prioritised); 2 stands for weight 2; tc. */
 #define CCM_REG_PBF_WEIGHT					 0xd00ac
-/* [RW 6] The physical queue number of queue number 1 per port index. */
 #define CCM_REG_PHYS_QNUM1_0					 0xd0134
 #define CCM_REG_PHYS_QNUM1_1					 0xd0138
-/* [RW 6] The physical queue number of queue number 2 per port index. */
 #define CCM_REG_PHYS_QNUM2_0					 0xd013c
 #define CCM_REG_PHYS_QNUM2_1					 0xd0140
-/* [RW 6] The physical queue number of queue number 3 per port index. */
 #define CCM_REG_PHYS_QNUM3_0					 0xd0144
-/* [RW 6] The physical queue number of queue number 0 with QOS equal 0 port
-   index 0. */
+#define CCM_REG_PHYS_QNUM3_1					 0xd0148
 #define CCM_REG_QOS_PHYS_QNUM0_0				 0xd0114
 #define CCM_REG_QOS_PHYS_QNUM0_1				 0xd0118
-/* [RW 6] The physical queue number of queue number 0 with QOS equal 1 port
-   index 0. */
 #define CCM_REG_QOS_PHYS_QNUM1_0				 0xd011c
 #define CCM_REG_QOS_PHYS_QNUM1_1				 0xd0120
-/* [RW 6] The physical queue number of queue number 0 with QOS equal 2 port
-   index 0. */
 #define CCM_REG_QOS_PHYS_QNUM2_0				 0xd0124
+#define CCM_REG_QOS_PHYS_QNUM2_1				 0xd0128
+#define CCM_REG_QOS_PHYS_QNUM3_0				 0xd012c
+#define CCM_REG_QOS_PHYS_QNUM3_1				 0xd0130
 /* [RW 1] STORM - CM Interface enable. If 0 - the valid input is
    disregarded; acknowledge output is deasserted; all other signals are
    treated as usual; if 1 - normal activity. */
@@ -253,6 +250,7 @@
    mechanism. The fields are: [5:0] - message length; [12:6] - message
    pointer; 18:13] - next pointer. */
 #define CCM_REG_XX_DESCR_TABLE					 0xd0300
+#define CCM_REG_XX_DESCR_TABLE_SIZE				 36
 /* [R 7] Used to read the value of XX protection Free counter. */
 #define CCM_REG_XX_FREE 					 0xd0184
 /* [RW 6] Initial value for the credit counter; responsible for fulfilling
@@ -296,6 +294,8 @@
 /* [WB 24] MATT ram access. each entry has the following
    format:{RegionLength[11:0]; egionOffset[11:0]} */
 #define CDU_REG_MATT						 0x101100
+/* [RW 1] when this bit is set the CDU operates in e1hmf mode */
+#define CDU_REG_MF_MODE 					 0x101050
 /* [R 1] indication the initializing the activity counter by the hardware
    was done. */
 #define CFC_REG_AC_INIT_DONE					 0x104078
@@ -330,6 +330,9 @@
    field allows changing the priorities of the weighted-round-robin arbiter
    which selects which CFC load client should be served next */
 #define CFC_REG_LCREQ_WEIGHTS					 0x104084
+/* [RW 16] Link List ram access; data = {prev_lcid; ext_lcid} */
+#define CFC_REG_LINK_LIST					 0x104c00
+#define CFC_REG_LINK_LIST_SIZE					 256
 /* [R 1] indication the initializing the link list by the hardware was done. */
 #define CFC_REG_LL_INIT_DONE					 0x104074
 /* [R 9] Number of allocated LCIDs which are at empty state */
@@ -342,6 +345,45 @@
 #define CFC_REG_NUM_LCIDS_LEAVING				 0x104018
 /* [RW 8] The event id for aggregated interrupt 0 */
 #define CSDM_REG_AGG_INT_EVENT_0				 0xc2038
+#define CSDM_REG_AGG_INT_EVENT_1				 0xc203c
+#define CSDM_REG_AGG_INT_EVENT_10				 0xc2060
+#define CSDM_REG_AGG_INT_EVENT_11				 0xc2064
+#define CSDM_REG_AGG_INT_EVENT_12				 0xc2068
+#define CSDM_REG_AGG_INT_EVENT_13				 0xc206c
+#define CSDM_REG_AGG_INT_EVENT_14				 0xc2070
+#define CSDM_REG_AGG_INT_EVENT_15				 0xc2074
+#define CSDM_REG_AGG_INT_EVENT_16				 0xc2078
+#define CSDM_REG_AGG_INT_EVENT_17				 0xc207c
+#define CSDM_REG_AGG_INT_EVENT_18				 0xc2080
+#define CSDM_REG_AGG_INT_EVENT_19				 0xc2084
+#define CSDM_REG_AGG_INT_EVENT_2				 0xc2040
+#define CSDM_REG_AGG_INT_EVENT_20				 0xc2088
+#define CSDM_REG_AGG_INT_EVENT_21				 0xc208c
+#define CSDM_REG_AGG_INT_EVENT_22				 0xc2090
+#define CSDM_REG_AGG_INT_EVENT_23				 0xc2094
+#define CSDM_REG_AGG_INT_EVENT_24				 0xc2098
+#define CSDM_REG_AGG_INT_EVENT_25				 0xc209c
+#define CSDM_REG_AGG_INT_EVENT_26				 0xc20a0
+#define CSDM_REG_AGG_INT_EVENT_27				 0xc20a4
+#define CSDM_REG_AGG_INT_EVENT_28				 0xc20a8
+#define CSDM_REG_AGG_INT_EVENT_29				 0xc20ac
+#define CSDM_REG_AGG_INT_EVENT_3				 0xc2044
+#define CSDM_REG_AGG_INT_EVENT_30				 0xc20b0
+#define CSDM_REG_AGG_INT_EVENT_31				 0xc20b4
+#define CSDM_REG_AGG_INT_EVENT_4				 0xc2048
+/* [RW 1] The T bit for aggregated interrupt 0 */
+#define CSDM_REG_AGG_INT_T_0					 0xc20b8
+#define CSDM_REG_AGG_INT_T_1					 0xc20bc
+#define CSDM_REG_AGG_INT_T_10					 0xc20e0
+#define CSDM_REG_AGG_INT_T_11					 0xc20e4
+#define CSDM_REG_AGG_INT_T_12					 0xc20e8
+#define CSDM_REG_AGG_INT_T_13					 0xc20ec
+#define CSDM_REG_AGG_INT_T_14					 0xc20f0
+#define CSDM_REG_AGG_INT_T_15					 0xc20f4
+#define CSDM_REG_AGG_INT_T_16					 0xc20f8
+#define CSDM_REG_AGG_INT_T_17					 0xc20fc
+#define CSDM_REG_AGG_INT_T_18					 0xc2100
+#define CSDM_REG_AGG_INT_T_19					 0xc2104
 /* [RW 13] The start address in the internal RAM for the cfc_rsp lcid */
 #define CSDM_REG_CFC_RSP_START_ADDR				 0xc2008
 /* [RW 16] The maximum value of the competion counter #0 */
@@ -358,6 +400,9 @@
 /* [RW 32] Interrupt mask register #0 read/write */
 #define CSDM_REG_CSDM_INT_MASK_0				 0xc229c
 #define CSDM_REG_CSDM_INT_MASK_1				 0xc22ac
+/* [R 32] Interrupt register #0 read */
+#define CSDM_REG_CSDM_INT_STS_0 				 0xc2290
+#define CSDM_REG_CSDM_INT_STS_1 				 0xc22a0
 /* [RW 11] Parity mask register #0 read/write */
 #define CSDM_REG_CSDM_PRTY_MASK 				 0xc22bc
 /* [R 11] Parity register #0 read */
@@ -443,6 +488,9 @@
 /* [RW 32] Interrupt mask register #0 read/write */
 #define CSEM_REG_CSEM_INT_MASK_0				 0x200110
 #define CSEM_REG_CSEM_INT_MASK_1				 0x200120
+/* [R 32] Interrupt register #0 read */
+#define CSEM_REG_CSEM_INT_STS_0 				 0x200104
+#define CSEM_REG_CSEM_INT_STS_1 				 0x200114
 /* [RW 32] Parity mask register #0 read/write */
 #define CSEM_REG_CSEM_PRTY_MASK_0				 0x200130
 #define CSEM_REG_CSEM_PRTY_MASK_1				 0x200140
@@ -453,9 +501,8 @@
 #define CSEM_REG_ENABLE_OUT					 0x2000a8
 /* [RW 32] This address space contains all registers and memories that are
    placed in SEM_FAST block. The SEM_FAST registers are described in
-   appendix B. In order to access the SEM_FAST registers the base address
-   CSEM_REGISTERS_FAST_MEMORY (Offset: 0x220000) should be added to each
-   SEM_FAST register offset. */
+   appendix B. In order to access the sem_fast registers the base address
+   ~fast_memory.fast_memory should be added to eachsem_fast register offset. */
 #define CSEM_REG_FAST_MEMORY					 0x220000
 /* [RW 1] Disables input messages from FIC0 May be updated during run_time
    by the microcode */
@@ -466,6 +513,7 @@
 /* [RW 15] Interrupt table Read and write access to it is not possible in
    the middle of the work */
 #define CSEM_REG_INT_TABLE					 0x200400
+#define CSEM_REG_INT_TABLE_SIZE 				 256
 /* [ST 24] Statistics register. The number of messages that entered through
    FIC0 */
 #define CSEM_REG_MSG_NUM_FIC0					 0x200000
@@ -630,6 +678,8 @@
 #define DORQ_REG_AGG_CMD3					 0x17006c
 /* [RW 28] UCM Header. */
 #define DORQ_REG_CMHEAD_RX					 0x170050
+/* [RW 32] Doorbell address for RBC doorbells (function 0). */
+#define DORQ_REG_DB_ADDR0					 0x17008c
 /* [RW 5] Interrupt mask register #0 read/write */
 #define DORQ_REG_DORQ_INT_MASK					 0x170180
 /* [R 5] Interrupt register #0 read */
@@ -690,75 +740,33 @@
 #define HC_CONFIG_0_REG_SINGLE_ISR_EN_0 			 (0x1<<1)
 #define HC_REG_AGG_INT_0					 0x108050
 #define HC_REG_AGG_INT_1					 0x108054
-/* [RW 16] attention bit and attention acknowledge bits status for port 0
-   and 1 according to the following address map: addr 0 - attn_bit_0; addr 1
-   - attn_ack_bit_0; addr 2 - attn_bit_1; addr 3 - attn_ack_bit_1; */
 #define HC_REG_ATTN_BIT 					 0x108120
-/* [RW 16] attn bits status index for attn bit msg; addr 0 - function 0;
-   addr 1 - functin 1 */
 #define HC_REG_ATTN_IDX 					 0x108100
-/* [RW 32] port 0 lower 32 bits address field for attn messag. */
 #define HC_REG_ATTN_MSG0_ADDR_L 				 0x108018
-/* [RW 32] port 1 lower 32 bits address field for attn messag. */
 #define HC_REG_ATTN_MSG1_ADDR_L 				 0x108020
-/* [RW 8] status block number for attn bit msg - function 0; */
 #define HC_REG_ATTN_NUM_P0					 0x108038
-/* [RW 8] status block number for attn bit msg - function 1 */
 #define HC_REG_ATTN_NUM_P1					 0x10803c
 #define HC_REG_CONFIG_0 					 0x108000
 #define HC_REG_CONFIG_1 					 0x108004
+#define HC_REG_FUNC_NUM_P0					 0x1080ac
+#define HC_REG_FUNC_NUM_P1					 0x1080b0
 /* [RW 3] Parity mask register #0 read/write */
 #define HC_REG_HC_PRTY_MASK					 0x1080a0
 /* [R 3] Parity register #0 read */
 #define HC_REG_HC_PRTY_STS					 0x108094
-/* [RW 17] status block interrupt mask; one in each bit means unmask; zerow
-   in each bit means mask; bit 0 - default SB; bit 1 - SB_0; bit 2 - SB_1...
-   bit 16- SB_15; addr 0 - port 0; addr 1 - port 1 */
 #define HC_REG_INT_MASK 					 0x108108
-/* [RW 16] port 0 attn bit condition monitoring; each bit that is set will
-   lock a change fron 0 to 1 in the corresponding attention signals that
-   comes from the AEU */
 #define HC_REG_LEADING_EDGE_0					 0x108040
 #define HC_REG_LEADING_EDGE_1					 0x108048
-/* [RW 16] all producer and consumer of port 0 according to the following
-   addresses; U_prod: 0-15; C_prod: 16-31; U_cons: 32-47; C_cons:48-63;
-   Defoult_prod: U/C/X/T/Attn-64/65/66/67/68; Defoult_cons:
-   U/C/X/T/Attn-69/70/71/72/73 */
 #define HC_REG_P0_PROD_CONS					 0x108200
-/* [RW 16] all producer and consumer of port 1according to the following
-   addresses; U_prod: 0-15; C_prod: 16-31; U_cons: 32-47; C_cons:48-63;
-   Defoult_prod: U/C/X/T/Attn-64/65/66/67/68; Defoult_cons:
-   U/C/X/T/Attn-69/70/71/72/73 */
 #define HC_REG_P1_PROD_CONS					 0x108400
-/* [W 1] This register is write only and has 4 addresses as follow: 0 =
-   clear all PBA bits port 0; 1 = clear all pending interrupts request
-   port0; 2 = clear all PBA bits port 1; 3 = clear all pending interrupts
-   request port1; here is no meaning for the data in this register */
 #define HC_REG_PBA_COMMAND					 0x108140
 #define HC_REG_PCI_CONFIG_0					 0x108010
 #define HC_REG_PCI_CONFIG_1					 0x108014
-/* [RW 24] all counters acording to the following address: LSB: 0=read; 1=
-   read_clear; 0-71 = HW counters (the inside order is the same as the
-   interrupt table in the spec); 72-219 = SW counters 1 (stops after first
-   consumer upd) the inside order is: 72-103 - U_non_default_p0; 104-135
-   C_non_defaul_p0; 36-145 U/C/X/T/Attn_default_p0; 146-177
-   U_non_default_p1; 178-209 C_non_defaul_p1; 10-219 U/C/X/T/Attn_default_p1
-   ; 220-367 = SW counters 2 (stops when prod=cons) the inside order is:
-   220-251 - U_non_default_p0; 252-283 C_non_defaul_p0; 84-293
-   U/C/X/T/Attn_default_p0; 294-325 U_non_default_p1; 326-357
-   C_non_defaul_p1; 58-367 U/C/X/T/Attn_default_p1 ; 368-515 = mailbox
-   counters; (the inside order of the mailbox counter is 368-431 U and C
-   non_default_p0; 432-441 U/C/X/T/Attn_default_p0; 442-505 U and C
-   non_default_p1; 506-515 U/C/X/T/Attn_default_p1) */
 #define HC_REG_STATISTIC_COUNTERS				 0x109000
-/* [RW 16] port 0 attn bit condition monitoring; each bit that is set will
-   lock a change fron 1 to 0 in the corresponding attention signals that
-   comes from the AEU */
 #define HC_REG_TRAILING_EDGE_0					 0x108044
 #define HC_REG_TRAILING_EDGE_1					 0x10804c
 #define HC_REG_UC_RAM_ADDR_0					 0x108028
 #define HC_REG_UC_RAM_ADDR_1					 0x108030
-/* [RW 16] ustorm address for coalesc now message */
 #define HC_REG_USTORM_ADDR_FOR_COALESCE 			 0x108068
 #define HC_REG_VQID_0						 0x108008
 #define HC_REG_VQID_1						 0x10800c
@@ -883,14 +891,16 @@
    rom_parity; [29] MCP Latched ump_rx_parity; [30] MCP Latched
    ump_tx_parity; [31] MCP Latched scpad_parity; */
 #define MISC_REG_AEU_AFTER_INVERT_4_MCP 			 0xa458
-/* [W 11] write to this register results with the clear of the latched
+/* [W 14] write to this register results with the clear of the latched
    signals; one in d0 clears RBCR latch; one in d1 clears RBCT latch; one in
    d2 clears RBCN latch; one in d3 clears RBCU latch; one in d4 clears RBCP
    latch; one in d5 clears GRC Latched timeout attention; one in d6 clears
    GRC Latched reserved access attention; one in d7 clears Latched
    rom_parity; one in d8 clears Latched ump_rx_parity; one in d9 clears
-   Latched ump_tx_parity; one in d10 clears Latched scpad_parity; read from
-   this register return zero */
+   Latched ump_tx_parity; one in d10 clears Latched scpad_parity (both
+   ports); one in d11 clears pxpv_misc_mps_attn; one in d12 clears
+   pxp_misc_exp_rom_attn0; one in d13 clears pxp_misc_exp_rom_attn1; read
+   from this register return zero */
 #define MISC_REG_AEU_CLR_LATCH_SIGNAL				 0xa45c
 /* [RW 32] first 32b for enabling the output for function 0 output0. mapped
    as follows: [0] NIG attention for function0; [1] NIG attention for
@@ -907,7 +917,11 @@
    TSEMI Hw interrupt; [30] PBF Parity error; [31] PBF Hw interrupt; */
 #define MISC_REG_AEU_ENABLE1_FUNC_0_OUT_0			 0xa06c
 #define MISC_REG_AEU_ENABLE1_FUNC_0_OUT_1			 0xa07c
+#define MISC_REG_AEU_ENABLE1_FUNC_0_OUT_2			 0xa08c
 #define MISC_REG_AEU_ENABLE1_FUNC_0_OUT_3			 0xa09c
+#define MISC_REG_AEU_ENABLE1_FUNC_0_OUT_5			 0xa0bc
+#define MISC_REG_AEU_ENABLE1_FUNC_0_OUT_6			 0xa0cc
+#define MISC_REG_AEU_ENABLE1_FUNC_0_OUT_7			 0xa0dc
 /* [RW 32] first 32b for enabling the output for function 1 output0. mapped
    as follows: [0] NIG attention for function0; [1] NIG attention for
    function1; [2] GPIO1 function 1; [3] GPIO2 function 1; [4] GPIO3 function
@@ -923,9 +937,13 @@
    TSEMI Hw interrupt; [30] PBF Parity error; [31] PBF Hw interrupt; */
 #define MISC_REG_AEU_ENABLE1_FUNC_1_OUT_0			 0xa10c
 #define MISC_REG_AEU_ENABLE1_FUNC_1_OUT_1			 0xa11c
+#define MISC_REG_AEU_ENABLE1_FUNC_1_OUT_2			 0xa12c
 #define MISC_REG_AEU_ENABLE1_FUNC_1_OUT_3			 0xa13c
-/* [RW 32] first 32b for enabling the output for close the gate nig 0.
-   mapped as follows: [0] NIG attention for function0; [1] NIG attention for
+#define MISC_REG_AEU_ENABLE1_FUNC_1_OUT_5			 0xa15c
+#define MISC_REG_AEU_ENABLE1_FUNC_1_OUT_6			 0xa16c
+#define MISC_REG_AEU_ENABLE1_FUNC_1_OUT_7			 0xa17c
+/* [RW 32] first 32b for enabling the output for close the gate nig. mapped
+   as follows: [0] NIG attention for function0; [1] NIG attention for
    function1; [2] GPIO1 function 0; [3] GPIO2 function 0; [4] GPIO3 function
    0; [5] GPIO4 function 0; [6] GPIO1 function 1; [7] GPIO2 function 1; [8]
    GPIO3 function 1; [9] GPIO4 function 1; [10] PCIE glue/PXP VPD event
@@ -939,8 +957,8 @@
    TSEMI Hw interrupt; [30] PBF Parity error; [31] PBF Hw interrupt; */
 #define MISC_REG_AEU_ENABLE1_NIG_0				 0xa0ec
 #define MISC_REG_AEU_ENABLE1_NIG_1				 0xa18c
-/* [RW 32] first 32b for enabling the output for close the gate pxp 0.
-   mapped as follows: [0] NIG attention for function0; [1] NIG attention for
+/* [RW 32] first 32b for enabling the output for close the gate pxp. mapped
+   as follows: [0] NIG attention for function0; [1] NIG attention for
    function1; [2] GPIO1 function 0; [3] GPIO2 function 0; [4] GPIO3 function
    0; [5] GPIO4 function 0; [6] GPIO1 function 1; [7] GPIO2 function 1; [8]
    GPIO3 function 1; [9] GPIO4 function 1; [10] PCIE glue/PXP VPD event
@@ -984,34 +1002,34 @@
    interrupt; */
 #define MISC_REG_AEU_ENABLE2_FUNC_1_OUT_0			 0xa110
 #define MISC_REG_AEU_ENABLE2_FUNC_1_OUT_1			 0xa120
-/* [RW 32] second 32b for enabling the output for close the gate nig 0.
-   mapped as follows: [0] PBClient Parity error; [1] PBClient Hw interrupt;
-   [2] QM Parity error; [3] QM Hw interrupt; [4] Timers Parity error; [5]
-   Timers Hw interrupt; [6] XSDM Parity error; [7] XSDM Hw interrupt; [8]
-   XCM Parity error; [9] XCM Hw interrupt; [10] XSEMI Parity error; [11]
-   XSEMI Hw interrupt; [12] DoorbellQ Parity error; [13] DoorbellQ Hw
-   interrupt; [14] NIG Parity error; [15] NIG Hw interrupt; [16] Vaux PCI
-   core Parity error; [17] Vaux PCI core Hw interrupt; [18] Debug Parity
-   error; [19] Debug Hw interrupt; [20] USDM Parity error; [21] USDM Hw
-   interrupt; [22] UCM Parity error; [23] UCM Hw interrupt; [24] USEMI
-   Parity error; [25] USEMI Hw interrupt; [26] UPB Parity error; [27] UPB Hw
-   interrupt; [28] CSDM Parity error; [29] CSDM Hw interrupt; [30] CCM
-   Parity error; [31] CCM Hw interrupt; */
+/* [RW 32] second 32b for enabling the output for close the gate nig. mapped
+   as follows: [0] PBClient Parity error; [1] PBClient Hw interrupt; [2] QM
+   Parity error; [3] QM Hw interrupt; [4] Timers Parity error; [5] Timers Hw
+   interrupt; [6] XSDM Parity error; [7] XSDM Hw interrupt; [8] XCM Parity
+   error; [9] XCM Hw interrupt; [10] XSEMI Parity error; [11] XSEMI Hw
+   interrupt; [12] DoorbellQ Parity error; [13] DoorbellQ Hw interrupt; [14]
+   NIG Parity error; [15] NIG Hw interrupt; [16] Vaux PCI core Parity error;
+   [17] Vaux PCI core Hw interrupt; [18] Debug Parity error; [19] Debug Hw
+   interrupt; [20] USDM Parity error; [21] USDM Hw interrupt; [22] UCM
+   Parity error; [23] UCM Hw interrupt; [24] USEMI Parity error; [25] USEMI
+   Hw interrupt; [26] UPB Parity error; [27] UPB Hw interrupt; [28] CSDM
+   Parity error; [29] CSDM Hw interrupt; [30] CCM Parity error; [31] CCM Hw
+   interrupt; */
 #define MISC_REG_AEU_ENABLE2_NIG_0				 0xa0f0
 #define MISC_REG_AEU_ENABLE2_NIG_1				 0xa190
-/* [RW 32] second 32b for enabling the output for close the gate pxp 0.
-   mapped as follows: [0] PBClient Parity error; [1] PBClient Hw interrupt;
-   [2] QM Parity error; [3] QM Hw interrupt; [4] Timers Parity error; [5]
-   Timers Hw interrupt; [6] XSDM Parity error; [7] XSDM Hw interrupt; [8]
-   XCM Parity error; [9] XCM Hw interrupt; [10] XSEMI Parity error; [11]
-   XSEMI Hw interrupt; [12] DoorbellQ Parity error; [13] DoorbellQ Hw
-   interrupt; [14] NIG Parity error; [15] NIG Hw interrupt; [16] Vaux PCI
-   core Parity error; [17] Vaux PCI core Hw interrupt; [18] Debug Parity
-   error; [19] Debug Hw interrupt; [20] USDM Parity error; [21] USDM Hw
-   interrupt; [22] UCM Parity error; [23] UCM Hw interrupt; [24] USEMI
-   Parity error; [25] USEMI Hw interrupt; [26] UPB Parity error; [27] UPB Hw
-   interrupt; [28] CSDM Parity error; [29] CSDM Hw interrupt; [30] CCM
-   Parity error; [31] CCM Hw interrupt; */
+/* [RW 32] second 32b for enabling the output for close the gate pxp. mapped
+   as follows: [0] PBClient Parity error; [1] PBClient Hw interrupt; [2] QM
+   Parity error; [3] QM Hw interrupt; [4] Timers Parity error; [5] Timers Hw
+   interrupt; [6] XSDM Parity error; [7] XSDM Hw interrupt; [8] XCM Parity
+   error; [9] XCM Hw interrupt; [10] XSEMI Parity error; [11] XSEMI Hw
+   interrupt; [12] DoorbellQ Parity error; [13] DoorbellQ Hw interrupt; [14]
+   NIG Parity error; [15] NIG Hw interrupt; [16] Vaux PCI core Parity error;
+   [17] Vaux PCI core Hw interrupt; [18] Debug Parity error; [19] Debug Hw
+   interrupt; [20] USDM Parity error; [21] USDM Hw interrupt; [22] UCM
+   Parity error; [23] UCM Hw interrupt; [24] USEMI Parity error; [25] USEMI
+   Hw interrupt; [26] UPB Parity error; [27] UPB Hw interrupt; [28] CSDM
+   Parity error; [29] CSDM Hw interrupt; [30] CCM Parity error; [31] CCM Hw
+   interrupt; */
 #define MISC_REG_AEU_ENABLE2_PXP_0				 0xa100
 #define MISC_REG_AEU_ENABLE2_PXP_1				 0xa1a0
 /* [RW 32] third 32b for enabling the output for function 0 output0. mapped
@@ -1044,34 +1062,34 @@
    attn1; */
 #define MISC_REG_AEU_ENABLE3_FUNC_1_OUT_0			 0xa114
 #define MISC_REG_AEU_ENABLE3_FUNC_1_OUT_1			 0xa124
-/* [RW 32] third 32b for enabling the output for close the gate nig 0.
-   mapped as follows: [0] CSEMI Parity error; [1] CSEMI Hw interrupt; [2]
-   PXP Parity error; [3] PXP Hw interrupt; [4] PXPpciClockClient Parity
-   error; [5] PXPpciClockClient Hw interrupt; [6] CFC Parity error; [7] CFC
-   Hw interrupt; [8] CDU Parity error; [9] CDU Hw interrupt; [10] DMAE
-   Parity error; [11] DMAE Hw interrupt; [12] IGU (HC) Parity error; [13]
-   IGU (HC) Hw interrupt; [14] MISC Parity error; [15] MISC Hw interrupt;
-   [16] pxp_misc_mps_attn; [17] Flash event; [18] SMB event; [19] MCP attn0;
-   [20] MCP attn1; [21] SW timers attn_1 func0; [22] SW timers attn_2 func0;
-   [23] SW timers attn_3 func0; [24] SW timers attn_4 func0; [25] PERST;
-   [26] SW timers attn_1 func1; [27] SW timers attn_2 func1; [28] SW timers
-   attn_3 func1; [29] SW timers attn_4 func1; [30] General attn0; [31]
-   General attn1; */
+/* [RW 32] third 32b for enabling the output for close the gate nig. mapped
+   as follows: [0] CSEMI Parity error; [1] CSEMI Hw interrupt; [2] PXP
+   Parity error; [3] PXP Hw interrupt; [4] PXPpciClockClient Parity error;
+   [5] PXPpciClockClient Hw interrupt; [6] CFC Parity error; [7] CFC Hw
+   interrupt; [8] CDU Parity error; [9] CDU Hw interrupt; [10] DMAE Parity
+   error; [11] DMAE Hw interrupt; [12] IGU (HC) Parity error; [13] IGU (HC)
+   Hw interrupt; [14] MISC Parity error; [15] MISC Hw interrupt; [16]
+   pxp_misc_mps_attn; [17] Flash event; [18] SMB event; [19] MCP attn0; [20]
+   MCP attn1; [21] SW timers attn_1 func0; [22] SW timers attn_2 func0; [23]
+   SW timers attn_3 func0; [24] SW timers attn_4 func0; [25] PERST; [26] SW
+   timers attn_1 func1; [27] SW timers attn_2 func1; [28] SW timers attn_3
+   func1; [29] SW timers attn_4 func1; [30] General attn0; [31] General
+   attn1; */
 #define MISC_REG_AEU_ENABLE3_NIG_0				 0xa0f4
 #define MISC_REG_AEU_ENABLE3_NIG_1				 0xa194
-/* [RW 32] third 32b for enabling the output for close the gate pxp 0.
-   mapped as follows: [0] CSEMI Parity error; [1] CSEMI Hw interrupt; [2]
-   PXP Parity error; [3] PXP Hw interrupt; [4] PXPpciClockClient Parity
-   error; [5] PXPpciClockClient Hw interrupt; [6] CFC Parity error; [7] CFC
-   Hw interrupt; [8] CDU Parity error; [9] CDU Hw interrupt; [10] DMAE
-   Parity error; [11] DMAE Hw interrupt; [12] IGU (HC) Parity error; [13]
-   IGU (HC) Hw interrupt; [14] MISC Parity error; [15] MISC Hw interrupt;
-   [16] pxp_misc_mps_attn; [17] Flash event; [18] SMB event; [19] MCP attn0;
-   [20] MCP attn1; [21] SW timers attn_1 func0; [22] SW timers attn_2 func0;
-   [23] SW timers attn_3 func0; [24] SW timers attn_4 func0; [25] PERST;
-   [26] SW timers attn_1 func1; [27] SW timers attn_2 func1; [28] SW timers
-   attn_3 func1; [29] SW timers attn_4 func1; [30] General attn0; [31]
-   General attn1; */
+/* [RW 32] third 32b for enabling the output for close the gate pxp. mapped
+   as follows: [0] CSEMI Parity error; [1] CSEMI Hw interrupt; [2] PXP
+   Parity error; [3] PXP Hw interrupt; [4] PXPpciClockClient Parity error;
+   [5] PXPpciClockClient Hw interrupt; [6] CFC Parity error; [7] CFC Hw
+   interrupt; [8] CDU Parity error; [9] CDU Hw interrupt; [10] DMAE Parity
+   error; [11] DMAE Hw interrupt; [12] IGU (HC) Parity error; [13] IGU (HC)
+   Hw interrupt; [14] MISC Parity error; [15] MISC Hw interrupt; [16]
+   pxp_misc_mps_attn; [17] Flash event; [18] SMB event; [19] MCP attn0; [20]
+   MCP attn1; [21] SW timers attn_1 func0; [22] SW timers attn_2 func0; [23]
+   SW timers attn_3 func0; [24] SW timers attn_4 func0; [25] PERST; [26] SW
+   timers attn_1 func1; [27] SW timers attn_2 func1; [28] SW timers attn_3
+   func1; [29] SW timers attn_4 func1; [30] General attn0; [31] General
+   attn1; */
 #define MISC_REG_AEU_ENABLE3_PXP_0				 0xa104
 #define MISC_REG_AEU_ENABLE3_PXP_1				 0xa1a4
 /* [RW 32] fourth 32b for enabling the output for function 0 output0.mapped
@@ -1088,6 +1106,10 @@
    Latched ump_tx_parity; [31] MCP Latched scpad_parity; */
 #define MISC_REG_AEU_ENABLE4_FUNC_0_OUT_0			 0xa078
 #define MISC_REG_AEU_ENABLE4_FUNC_0_OUT_2			 0xa098
+#define MISC_REG_AEU_ENABLE4_FUNC_0_OUT_4			 0xa0b8
+#define MISC_REG_AEU_ENABLE4_FUNC_0_OUT_5			 0xa0c8
+#define MISC_REG_AEU_ENABLE4_FUNC_0_OUT_6			 0xa0d8
+#define MISC_REG_AEU_ENABLE4_FUNC_0_OUT_7			 0xa0e8
 /* [RW 32] fourth 32b for enabling the output for function 1 output0.mapped
    as follows: [0] General attn2; [1] General attn3; [2] General attn4; [3]
    General attn5; [4] General attn6; [5] General attn7; [6] General attn8;
@@ -1102,34 +1124,36 @@
    Latched ump_tx_parity; [31] MCP Latched scpad_parity; */
 #define MISC_REG_AEU_ENABLE4_FUNC_1_OUT_0			 0xa118
 #define MISC_REG_AEU_ENABLE4_FUNC_1_OUT_2			 0xa138
-/* [RW 32] fourth 32b for enabling the output for close the gate nig
-   0.mapped as follows: [0] General attn2; [1] General attn3; [2] General
-   attn4; [3] General attn5; [4] General attn6; [5] General attn7; [6]
-   General attn8; [7] General attn9; [8] General attn10; [9] General attn11;
-   [10] General attn12; [11] General attn13; [12] General attn14; [13]
-   General attn15; [14] General attn16; [15] General attn17; [16] General
-   attn18; [17] General attn19; [18] General attn20; [19] General attn21;
-   [20] Main power interrupt; [21] RBCR Latched attn; [22] RBCT Latched
-   attn; [23] RBCN Latched attn; [24] RBCU Latched attn; [25] RBCP Latched
-   attn; [26] GRC Latched timeout attention; [27] GRC Latched reserved
-   access attention; [28] MCP Latched rom_parity; [29] MCP Latched
-   ump_rx_parity; [30] MCP Latched ump_tx_parity; [31] MCP Latched
-   scpad_parity; */
+#define MISC_REG_AEU_ENABLE4_FUNC_1_OUT_4			 0xa158
+#define MISC_REG_AEU_ENABLE4_FUNC_1_OUT_5			 0xa168
+#define MISC_REG_AEU_ENABLE4_FUNC_1_OUT_6			 0xa178
+#define MISC_REG_AEU_ENABLE4_FUNC_1_OUT_7			 0xa188
+/* [RW 32] fourth 32b for enabling the output for close the gate nig.mapped
+   as follows: [0] General attn2; [1] General attn3; [2] General attn4; [3]
+   General attn5; [4] General attn6; [5] General attn7; [6] General attn8;
+   [7] General attn9; [8] General attn10; [9] General attn11; [10] General
+   attn12; [11] General attn13; [12] General attn14; [13] General attn15;
+   [14] General attn16; [15] General attn17; [16] General attn18; [17]
+   General attn19; [18] General attn20; [19] General attn21; [20] Main power
+   interrupt; [21] RBCR Latched attn; [22] RBCT Latched attn; [23] RBCN
+   Latched attn; [24] RBCU Latched attn; [25] RBCP Latched attn; [26] GRC
+   Latched timeout attention; [27] GRC Latched reserved access attention;
+   [28] MCP Latched rom_parity; [29] MCP Latched ump_rx_parity; [30] MCP
+   Latched ump_tx_parity; [31] MCP Latched scpad_parity; */
 #define MISC_REG_AEU_ENABLE4_NIG_0				 0xa0f8
 #define MISC_REG_AEU_ENABLE4_NIG_1				 0xa198
-/* [RW 32] fourth 32b for enabling the output for close the gate pxp
-   0.mapped as follows: [0] General attn2; [1] General attn3; [2] General
-   attn4; [3] General attn5; [4] General attn6; [5] General attn7; [6]
-   General attn8; [7] General attn9; [8] General attn10; [9] General attn11;
-   [10] General attn12; [11] General attn13; [12] General attn14; [13]
-   General attn15; [14] General attn16; [15] General attn17; [16] General
-   attn18; [17] General attn19; [18] General attn20; [19] General attn21;
-   [20] Main power interrupt; [21] RBCR Latched attn; [22] RBCT Latched
-   attn; [23] RBCN Latched attn; [24] RBCU Latched attn; [25] RBCP Latched
-   attn; [26] GRC Latched timeout attention; [27] GRC Latched reserved
-   access attention; [28] MCP Latched rom_parity; [29] MCP Latched
-   ump_rx_parity; [30] MCP Latched ump_tx_parity; [31] MCP Latched
-   scpad_parity; */
+/* [RW 32] fourth 32b for enabling the output for close the gate pxp.mapped
+   as follows: [0] General attn2; [1] General attn3; [2] General attn4; [3]
+   General attn5; [4] General attn6; [5] General attn7; [6] General attn8;
+   [7] General attn9; [8] General attn10; [9] General attn11; [10] General
+   attn12; [11] General attn13; [12] General attn14; [13] General attn15;
+   [14] General attn16; [15] General attn17; [16] General attn18; [17]
+   General attn19; [18] General attn20; [19] General attn21; [20] Main power
+   interrupt; [21] RBCR Latched attn; [22] RBCT Latched attn; [23] RBCN
+   Latched attn; [24] RBCU Latched attn; [25] RBCP Latched attn; [26] GRC
+   Latched timeout attention; [27] GRC Latched reserved access attention;
+   [28] MCP Latched rom_parity; [29] MCP Latched ump_rx_parity; [30] MCP
+   Latched ump_tx_parity; [31] MCP Latched scpad_parity; */
 #define MISC_REG_AEU_ENABLE4_PXP_0				 0xa108
 #define MISC_REG_AEU_ENABLE4_PXP_1				 0xa1a8
 /* [RW 1] set/clr general attention 0; this will set/clr bit 94 in the aeu
@@ -1148,6 +1172,7 @@
 #define MISC_REG_AEU_GENERAL_ATTN_19				 0xa04c
 #define MISC_REG_AEU_GENERAL_ATTN_10				 0xa028
 #define MISC_REG_AEU_GENERAL_ATTN_11				 0xa02c
+#define MISC_REG_AEU_GENERAL_ATTN_12				 0xa030
 #define MISC_REG_AEU_GENERAL_ATTN_2				 0xa008
 #define MISC_REG_AEU_GENERAL_ATTN_20				 0xa050
 #define MISC_REG_AEU_GENERAL_ATTN_21				 0xa054
@@ -1158,6 +1183,7 @@
 #define MISC_REG_AEU_GENERAL_ATTN_7				 0xa01c
 #define MISC_REG_AEU_GENERAL_ATTN_8				 0xa020
 #define MISC_REG_AEU_GENERAL_ATTN_9				 0xa024
+#define MISC_REG_AEU_GENERAL_MASK				 0xa61c
 /* [RW 32] first 32b for inverting the input for function 0; for each bit:
    0= do not invert; 1= invert; mapped as follows: [0] NIG attention for
    function0; [1] NIG attention for function1; [2] GPIO1 mcp; [3] GPIO2 mcp;
@@ -1189,10 +1215,29 @@
 #define MISC_REG_AEU_INVERTER_2_FUNC_0				 0xa230
 #define MISC_REG_AEU_INVERTER_2_FUNC_1				 0xa240
 /* [RW 10] [7:0] = mask 8 attention output signals toward IGU function0;
-   [9:8] = mask close the gates signals of function 0 toward PXP [8] and NIG
-   [9]. Zero = mask; one = unmask */
+   [9:8] = raserved. Zero = mask; one = unmask */
 #define MISC_REG_AEU_MASK_ATTN_FUNC_0				 0xa060
 #define MISC_REG_AEU_MASK_ATTN_FUNC_1				 0xa064
+/* [RW 1] If set a system kill occurred */
+#define MISC_REG_AEU_SYS_KILL_OCCURRED				 0xa610
+/* [RW 32] Represent the status of the input vector to the AEU when a system
+   kill occurred. The register is reset in por reset. Mapped as follows: [0]
+   NIG attention for function0; [1] NIG attention for function1; [2] GPIO1
+   mcp; [3] GPIO2 mcp; [4] GPIO3 mcp; [5] GPIO4 mcp; [6] GPIO1 function 1;
+   [7] GPIO2 function 1; [8] GPIO3 function 1; [9] GPIO4 function 1; [10]
+   PCIE glue/PXP VPD event function0; [11] PCIE glue/PXP VPD event
+   function1; [12] PCIE glue/PXP Expansion ROM event0; [13] PCIE glue/PXP
+   Expansion ROM event1; [14] SPIO4; [15] SPIO5; [16] MSI/X indication for
+   mcp; [17] MSI/X indication for function 1; [18] BRB Parity error; [19]
+   BRB Hw interrupt; [20] PRS Parity error; [21] PRS Hw interrupt; [22] SRC
+   Parity error; [23] SRC Hw interrupt; [24] TSDM Parity error; [25] TSDM Hw
+   interrupt; [26] TCM Parity error; [27] TCM Hw interrupt; [28] TSEMI
+   Parity error; [29] TSEMI Hw interrupt; [30] PBF Parity error; [31] PBF Hw
+   interrupt; */
+#define MISC_REG_AEU_SYS_KILL_STATUS_0				 0xa600
+#define MISC_REG_AEU_SYS_KILL_STATUS_1				 0xa604
+#define MISC_REG_AEU_SYS_KILL_STATUS_2				 0xa608
+#define MISC_REG_AEU_SYS_KILL_STATUS_3				 0xa60c
 /* [R 4] This field indicates the type of the device. '0' - 2 Ports; '1' - 1
    Port. */
 #define MISC_REG_BOND_ID					 0xa400
@@ -1206,8 +1251,80 @@
    starts at 0x0 for the A0 tape-out and increments by one for each
    all-layer tape-out. */
 #define MISC_REG_CHIP_REV					 0xa40c
-/* [RW 32] The following driver registers(1..6) represent 6 drivers and 32
-   clients. Each client can be controlled by one driver only. One in each
+/* [RW 32] The following driver registers(1...16) represent 16 drivers and
+   32 clients. Each client can be controlled by one driver only. One in each
+   bit represent that this driver control the appropriate client (Ex: bit 5
+   is set means this driver control client number 5). addr1 = set; addr0 =
+   clear; read from both addresses will give the same result = status. write
+   to address 1 will set a request to control all the clients that their
+   appropriate bit (in the write command) is set. if the client is free (the
+   appropriate bit in all the other drivers is clear) one will be written to
+   that driver register; if the client isn't free the bit will remain zero.
+   if the appropriate bit is set (the driver request to gain control on a
+   client it already controls the ~MISC_REGISTERS_INT_STS.GENERIC_SW
+   interrupt will be asserted). write to address 0 will set a request to
+   free all the clients that their appropriate bit (in the write command) is
+   set. if the appropriate bit is clear (the driver request to free a client
+   it doesn't controls the ~MISC_REGISTERS_INT_STS.GENERIC_SW interrupt will
+   be asserted). */
+#define MISC_REG_DRIVER_CONTROL_10				 0xa3e0
+#define MISC_REG_DRIVER_CONTROL_10_SIZE 			 2
+/* [RW 32] The following driver registers(1...16) represent 16 drivers and
+   32 clients. Each client can be controlled by one driver only. One in each
+   bit represent that this driver control the appropriate client (Ex: bit 5
+   is set means this driver control client number 5). addr1 = set; addr0 =
+   clear; read from both addresses will give the same result = status. write
+   to address 1 will set a request to control all the clients that their
+   appropriate bit (in the write command) is set. if the client is free (the
+   appropriate bit in all the other drivers is clear) one will be written to
+   that driver register; if the client isn't free the bit will remain zero.
+   if the appropriate bit is set (the driver request to gain control on a
+   client it already controls the ~MISC_REGISTERS_INT_STS.GENERIC_SW
+   interrupt will be asserted). write to address 0 will set a request to
+   free all the clients that their appropriate bit (in the write command) is
+   set. if the appropriate bit is clear (the driver request to free a client
+   it doesn't controls the ~MISC_REGISTERS_INT_STS.GENERIC_SW interrupt will
+   be asserted). */
+#define MISC_REG_DRIVER_CONTROL_11				 0xa3e8
+#define MISC_REG_DRIVER_CONTROL_11_SIZE 			 2
+/* [RW 32] The following driver registers(1...16) represent 16 drivers and
+   32 clients. Each client can be controlled by one driver only. One in each
+   bit represent that this driver control the appropriate client (Ex: bit 5
+   is set means this driver control client number 5). addr1 = set; addr0 =
+   clear; read from both addresses will give the same result = status. write
+   to address 1 will set a request to control all the clients that their
+   appropriate bit (in the write command) is set. if the client is free (the
+   appropriate bit in all the other drivers is clear) one will be written to
+   that driver register; if the client isn't free the bit will remain zero.
+   if the appropriate bit is set (the driver request to gain control on a
+   client it already controls the ~MISC_REGISTERS_INT_STS.GENERIC_SW
+   interrupt will be asserted). write to address 0 will set a request to
+   free all the clients that their appropriate bit (in the write command) is
+   set. if the appropriate bit is clear (the driver request to free a client
+   it doesn't controls the ~MISC_REGISTERS_INT_STS.GENERIC_SW interrupt will
+   be asserted). */
+#define MISC_REG_DRIVER_CONTROL_12				 0xa3f0
+#define MISC_REG_DRIVER_CONTROL_12_SIZE 			 2
+/* [RW 32] The following driver registers(1...16) represent 16 drivers and
+   32 clients. Each client can be controlled by one driver only. One in each
+   bit represent that this driver control the appropriate client (Ex: bit 5
+   is set means this driver control client number 5). addr1 = set; addr0 =
+   clear; read from both addresses will give the same result = status. write
+   to address 1 will set a request to control all the clients that their
+   appropriate bit (in the write command) is set. if the client is free (the
+   appropriate bit in all the other drivers is clear) one will be written to
+   that driver register; if the client isn't free the bit will remain zero.
+   if the appropriate bit is set (the driver request to gain control on a
+   client it already controls the ~MISC_REGISTERS_INT_STS.GENERIC_SW
+   interrupt will be asserted). write to address 0 will set a request to
+   free all the clients that their appropriate bit (in the write command) is
+   set. if the appropriate bit is clear (the driver request to free a client
+   it doesn't controls the ~MISC_REGISTERS_INT_STS.GENERIC_SW interrupt will
+   be asserted). */
+#define MISC_REG_DRIVER_CONTROL_13				 0xa3f8
+#define MISC_REG_DRIVER_CONTROL_13_SIZE 			 2
+/* [RW 32] The following driver registers(1...16) represent 16 drivers and
+   32 clients. Each client can be controlled by one driver only. One in each
    bit represent that this driver control the appropriate client (Ex: bit 5
    is set means this driver control client number 5). addr1 = set; addr0 =
    clear; read from both addresses will give the same result = status. write
@@ -1223,6 +1340,47 @@
    it doesn't controls the ~MISC_REGISTERS_INT_STS.GENERIC_SW interrupt will
    be asserted). */
 #define MISC_REG_DRIVER_CONTROL_1				 0xa510
+#define MISC_REG_DRIVER_CONTROL_14				 0xa5e0
+#define MISC_REG_DRIVER_CONTROL_14_SIZE 			 2
+/* [RW 32] The following driver registers(1...16) represent 16 drivers and
+   32 clients. Each client can be controlled by one driver only. One in each
+   bit represent that this driver control the appropriate client (Ex: bit 5
+   is set means this driver control client number 5). addr1 = set; addr0 =
+   clear; read from both addresses will give the same result = status. write
+   to address 1 will set a request to control all the clients that their
+   appropriate bit (in the write command) is set. if the client is free (the
+   appropriate bit in all the other drivers is clear) one will be written to
+   that driver register; if the client isn't free the bit will remain zero.
+   if the appropriate bit is set (the driver request to gain control on a
+   client it already controls the ~MISC_REGISTERS_INT_STS.GENERIC_SW
+   interrupt will be asserted). write to address 0 will set a request to
+   free all the clients that their appropriate bit (in the write command) is
+   set. if the appropriate bit is clear (the driver request to free a client
+   it doesn't controls the ~MISC_REGISTERS_INT_STS.GENERIC_SW interrupt will
+   be asserted). */
+#define MISC_REG_DRIVER_CONTROL_15				 0xa5e8
+#define MISC_REG_DRIVER_CONTROL_15_SIZE 			 2
+/* [RW 32] The following driver registers(1...16) represent 16 drivers and
+   32 clients. Each client can be controlled by one driver only. One in each
+   bit represent that this driver control the appropriate client (Ex: bit 5
+   is set means this driver control client number 5). addr1 = set; addr0 =
+   clear; read from both addresses will give the same result = status. write
+   to address 1 will set a request to control all the clients that their
+   appropriate bit (in the write command) is set. if the client is free (the
+   appropriate bit in all the other drivers is clear) one will be written to
+   that driver register; if the client isn't free the bit will remain zero.
+   if the appropriate bit is set (the driver request to gain control on a
+   client it already controls the ~MISC_REGISTERS_INT_STS.GENERIC_SW
+   interrupt will be asserted). write to address 0 will set a request to
+   free all the clients that their appropriate bit (in the write command) is
+   set. if the appropriate bit is clear (the driver request to free a client
+   it doesn't controls the ~MISC_REGISTERS_INT_STS.GENERIC_SW interrupt will
+   be asserted). */
+#define MISC_REG_DRIVER_CONTROL_16				 0xa5f0
+#define MISC_REG_DRIVER_CONTROL_16_SIZE 			 2
+/* [RW 1] e1hmf for WOL. If clr WOL signal o the PXP will be send on bit 0
+   only. */
+#define MISC_REG_E1HMF_MODE					 0xa5f8
 /* [RW 32] GPIO. [31-28] FLOAT port 0; [27-24] FLOAT port 0; When any of
    these bits is written as a '1'; the corresponding SPIO bit will turn off
    it's drivers and become an input. This is the reset state of all GPIO
@@ -1240,6 +1398,18 @@
    This is the result value of the pin; not the drive value. Writing these
    bits will have not effect. */
 #define MISC_REG_GPIO						 0xa490
+/* [R 28] this field hold the last information that caused reserved
+   attention. bits [19:0] - address; [22:20] function; [23] reserved;
+   [27:24] the master thatcaused the attention - according to the following
+   encodeing:1 = pxp; 2 = mcp; 3 = usdm; 4 = tsdm; 5 = xsdm; 6 = csdm; 7 =
+   dbu; 8 = dmae */
+#define MISC_REG_GRC_RSV_ATTN					 0xa3c0
+/* [R 28] this field hold the last information that caused timeout
+   attention. bits [19:0] - address; [22:20] function; [23] reserved;
+   [27:24] the master thatcaused the attention - according to the following
+   encodeing:1 = pxp; 2 = mcp; 3 = usdm; 4 = tsdm; 5 = xsdm; 6 = csdm; 7 =
+   dbu; 8 = dmae */
+#define MISC_REG_GRC_TIMEOUT_ATTN				 0xa3c4
 /* [RW 1] Setting this bit enables a timer in the GRC block to timeout any
    access that does not finish within
    ~misc_registers_grc_timout_val.grc_timeout_val cycles. When this bit is
@@ -1282,6 +1452,11 @@
 #define MISC_REG_MISC_PRTY_MASK 				 0xa398
 /* [R 1] Parity register #0 read */
 #define MISC_REG_MISC_PRTY_STS					 0xa38c
+#define MISC_REG_NIG_WOL_P0					 0xa270
+#define MISC_REG_NIG_WOL_P1					 0xa274
+/* [R 1] If set indicate that the pcie_rst_b was asserted without perst
+   assertion */
+#define MISC_REG_PCIE_HOT_RESET 				 0xa618
 /* [RW 32] 32 LSB of storm PLL first register; reset val = 0x 071d2911.
    inside order of the bits is: [0] P1 divider[0] (reset value 1); [1] P1
    divider[1] (reset value 0); [2] P1 divider[2] (reset value 0); [3] P1
@@ -1303,7 +1478,7 @@
 #define MISC_REG_PLL_STORM_CTRL_2				 0xa298
 #define MISC_REG_PLL_STORM_CTRL_3				 0xa29c
 #define MISC_REG_PLL_STORM_CTRL_4				 0xa2a0
-/* [RW 32] reset reg#1; rite/read one = the specific block is out of reset;
+/* [RW 32] reset reg#2; rite/read one = the specific block is out of reset;
    write/read zero = the specific block is in reset; addr 0-wr- the write
    value will be written to the register; addr 1-set - one will be written
    to all the bits that have the value of one in the data written (bits that
@@ -1311,14 +1486,12 @@
    written to all the bits that have the value of one in the data written
    (bits that have the value of zero will not be change); addr 3-ignore;
    read ignore from all addr except addr 00; inside order of the bits is:
-   [0] rst_brb1; [1] rst_prs; [2] rst_src; [3] rst_tsdm; [4] rst_tsem; [5]
-   rst_tcm; [6] rst_rbcr; [7] rst_nig; [8] rst_usdm; [9] rst_ucm; [10]
-   rst_usem; [11] rst_upb; [12] rst_ccm; [13] rst_csem; [14] rst_csdm; [15]
-   rst_rbcu; [16] rst_pbf; [17] rst_qm; [18] rst_tm; [19] rst_dorq; [20]
-   rst_xcm; [21] rst_xsdm; [22] rst_xsem; [23] rst_rbct; [24] rst_cdu; [25]
-   rst_cfc; [26] rst_pxp; [27] rst_pxpv; [28] rst_rbcp; [29] rst_hc; [30]
-   rst_dmae; [31] rst_semi_rtc; */
-#define MISC_REG_RESET_REG_1					 0xa580
+   [0] rst_bmac0; [1] rst_bmac1; [2] rst_emac0; [3] rst_emac1; [4] rst_grc;
+   [5] rst_mcp_n_reset_reg_hard_core; [6] rst_ mcp_n_hard_core_rst_b; [7]
+   rst_ mcp_n_reset_cmn_cpu; [8] rst_ mcp_n_reset_cmn_core; [9] rst_rbcn;
+   [10] rst_dbg; [11] rst_misc_core; [12] rst_dbue (UART); [13]
+   Pci_resetmdio_n; [14] rst_emac0_hard_core; [15] rst_emac1_hard_core; 16]
+   rst_pxp_rq_rd_wr; 31:17] reserved */
 #define MISC_REG_RESET_REG_2					 0xa590
 /* [RW 20] 20 bit GRC address where the scratch-pad of the MCP that is
    shared with the driver resides */
@@ -1345,7 +1518,7 @@
    select VAUX supply. (This is an output pin only; it is not controlled by
    the SET and CLR fields; it is controlled by the Main Power SM; the FLOAT
    field is not applicable for this pin; only the VALUE fields is relevant -
-   it reflects the output value); [3] reserved; [4] spio_4; [5] spio_5; [6]
+   it reflects the output value); [3] port swap [4] spio_4; [5] spio_5; [6]
    Bit 0 of UMP device ID select; read by UMP firmware; [7] Bit 1 of UMP
    device ID select; read by UMP firmware. */
 #define MISC_REG_SPIO						 0xa4fc
@@ -1394,8 +1567,9 @@
 #define NIG_REG_BRB1_PAUSE_IN_EN				 0x100c8
 /* [RW 1] output enable for RX BRB1 LP IF */
 #define NIG_REG_BRB_LB_OUT_EN					 0x10100
-/* [WB_W 72] Debug packet to LP from RBC; Data spelling:[63:0] data; 64]
-   error; [67:65]eop_bvalid; [68]eop; [69]sop; [70]port_id; 71]flush */
+/* [WB_W 82] Debug packet to LP from RBC; Data spelling:[63:0] data; 64]
+   error; [67:65]eop_bvalid; [68]eop; [69]sop; [70]port_id; 71]flush;
+   72:73]-vnic_num; 81:74]-sideband_info */
 #define NIG_REG_DEBUG_PACKET_LB 				 0x10800
 /* [RW 1] Input enable for TX Debug packet */
 #define NIG_REG_EGRESS_DEBUG_IN_EN				 0x100dc
@@ -1409,6 +1583,8 @@
 /* [RW 1] MAC configuration for packets of port0. If 1 - all packet outputs
    to emac for port0; other way to bmac for port0 */
 #define NIG_REG_EGRESS_EMAC0_PORT				 0x10058
+/* [RW 32] TX_MNG_FIFO in NIG_TX_PORT0; data[31:0] written in FIFO order. */
+#define NIG_REG_EGRESS_MNG0_FIFO				 0x1045c
 /* [RW 1] Input enable for TX PBF user packet port0 IF */
 #define NIG_REG_EGRESS_PBF0_IN_EN				 0x100cc
 /* [RW 1] Input enable for TX PBF user packet port1 IF */
@@ -1438,6 +1614,8 @@
 #define NIG_REG_INGRESS_EOP_LB_FIFO				 0x104e4
 /* [RW 1] led 10g for port 0 */
 #define NIG_REG_LED_10G_P0					 0x10320
+/* [RW 1] led 10g for port 1 */
+#define NIG_REG_LED_10G_P1					 0x10324
 /* [RW 1] Port0: This bit is set to enable the use of the
    ~nig_registers_led_control_blink_rate_p0.led_control_blink_rate_p0 field
    defined below. If this bit is cleared; then the blink rate will be about
@@ -1470,19 +1648,47 @@
 /* [RW 4] led mode for port0: 0 MAC; 1-3 PHY1; 4 MAC2; 5-7 PHY4; 8-MAC3;
    9-11PHY7; 12 MAC4; 13-15 PHY10; */
 #define NIG_REG_LED_MODE_P0					 0x102f0
+#define NIG_REG_LLH0_ACPI_PAT_0_CRC				 0x1015c
+#define NIG_REG_LLH0_ACPI_PAT_6_LEN				 0x10154
 #define NIG_REG_LLH0_BRB1_DRV_MASK				 0x10244
+#define NIG_REG_LLH0_BRB1_DRV_MASK_MF				 0x16048
 /* [RW 1] send to BRB1 if no match on any of RMP rules. */
 #define NIG_REG_LLH0_BRB1_NOT_MCP				 0x1025c
+/* [RW 2] Determine the classification participants. 0: no classification.1:
+   classification upon VLAN id. 2: classification upon MAC address. 3:
+   classification upon both VLAN id & MAC addr. */
+#define NIG_REG_LLH0_CLS_TYPE					 0x16080
 /* [RW 32] cm header for llh0 */
 #define NIG_REG_LLH0_CM_HEADER					 0x1007c
+#define NIG_REG_LLH0_DEST_IP_0_1				 0x101dc
+#define NIG_REG_LLH0_DEST_MAC_0_0				 0x101c0
+/* [RW 16] destination TCP address 1. The LLH will look for this address in
+   all incoming packets. */
+#define NIG_REG_LLH0_DEST_TCP_0 				 0x10220
+/* [RW 16] destination UDP address 1 The LLH will look for this address in
+   all incoming packets. */
+#define NIG_REG_LLH0_DEST_UDP_0 				 0x10214
 #define NIG_REG_LLH0_ERROR_MASK 				 0x1008c
 /* [RW 8] event id for llh0 */
 #define NIG_REG_LLH0_EVENT_ID					 0x10084
+#define NIG_REG_LLH0_FUNC_EN					 0x160fc
+#define NIG_REG_LLH0_FUNC_VLAN_ID				 0x16100
+/* [RW 1] Determine the IP version to look for in
+   ~nig_registers_llh0_dest_ip_0.llh0_dest_ip_0. 0 - IPv6; 1-IPv4 */
+#define NIG_REG_LLH0_IPV4_IPV6_0				 0x10208
+/* [RW 1] t bit for llh0 */
+#define NIG_REG_LLH0_T_BIT					 0x10074
+/* [RW 12] VLAN ID 1. In case of VLAN packet the LLH will look for this ID. */
+#define NIG_REG_LLH0_VLAN_ID_0					 0x1022c
 /* [RW 8] init credit counter for port0 in LLH */
 #define NIG_REG_LLH0_XCM_INIT_CREDIT				 0x10554
 #define NIG_REG_LLH0_XCM_MASK					 0x10130
 /* [RW 1] send to BRB1 if no match on any of RMP rules. */
 #define NIG_REG_LLH1_BRB1_NOT_MCP				 0x102dc
+/* [RW 2] Determine the classification participants. 0: no classification.1:
+   classification upon VLAN id. 2: classification upon MAC address. 3:
+   classification upon both VLAN id & MAC addr. */
+#define NIG_REG_LLH1_CLS_TYPE					 0x16084
 /* [RW 32] cm header for llh1 */
 #define NIG_REG_LLH1_CM_HEADER					 0x10080
 #define NIG_REG_LLH1_ERROR_MASK 				 0x10090
@@ -1491,13 +1697,26 @@
 /* [RW 8] init credit counter for port1 in LLH */
 #define NIG_REG_LLH1_XCM_INIT_CREDIT				 0x10564
 #define NIG_REG_LLH1_XCM_MASK					 0x10134
+/* [RW 1] When this bit is set; the LLH will expect all packets to be with
+   e1hov */
+#define NIG_REG_LLH_E1HOV_MODE					 0x160d8
+/* [RW 1] When this bit is set; the LLH will classify the packet before
+   sending it to the BRB or calculating WoL on it. */
+#define NIG_REG_LLH_MF_MODE					 0x16024
 #define NIG_REG_MASK_INTERRUPT_PORT0				 0x10330
 #define NIG_REG_MASK_INTERRUPT_PORT1				 0x10334
 /* [RW 1] Output signal from NIG to EMAC0. When set enables the EMAC0 block. */
 #define NIG_REG_NIG_EMAC0_EN					 0x1003c
+/* [RW 1] Output signal from NIG to EMAC1. When set enables the EMAC1 block. */
+#define NIG_REG_NIG_EMAC1_EN					 0x10040
 /* [RW 1] Output signal from NIG to TX_EMAC0. When set indicates to the
    EMAC0 to strip the CRC from the ingress packets. */
 #define NIG_REG_NIG_INGRESS_EMAC0_NO_CRC			 0x10044
+/* [R 32] Interrupt register #0 read */
+#define NIG_REG_NIG_INT_STS_0					 0x103b0
+#define NIG_REG_NIG_INT_STS_1					 0x103c0
+/* [R 32] Parity register #0 read */
+#define NIG_REG_NIG_PRTY_STS					 0x103d0
 /* [RW 1] Input enable for RX PBF LP IF */
 #define NIG_REG_PBF_LB_IN_EN					 0x100b4
 /* [RW 1] Value of this register will be transmitted to port swap when
@@ -1529,8 +1748,12 @@
 #define NIG_REG_XCM0_OUT_EN					 0x100f0
 /* [RW 1] output enable for RX_XCM1 IF */
 #define NIG_REG_XCM1_OUT_EN					 0x100f4
+/* [RW 1] control to xgxs - remote PHY in-band MDIO */
+#define NIG_REG_XGXS0_CTRL_EXTREMOTEMDIOST			 0x10348
 /* [RW 5] control to xgxs - CL45 DEVAD */
 #define NIG_REG_XGXS0_CTRL_MD_DEVAD				 0x1033c
+/* [RW 1] control to xgxs; 0 - clause 45; 1 - clause 22 */
+#define NIG_REG_XGXS0_CTRL_MD_ST				 0x10338
 /* [RW 5] control to xgxs - CL22 PHY_ADD and CL45 PRTAD */
 #define NIG_REG_XGXS0_CTRL_PHY_ADDR				 0x10340
 /* [R 1] status from xgxs0 that inputs to interrupt logic of link10g. */
@@ -1658,11 +1881,15 @@
 #define PRS_REG_CM_HDR_TYPE_4					 0x40088
 /* [RW 32] The CM header in case there was not a match on the connection */
 #define PRS_REG_CM_NO_MATCH_HDR 				 0x400b8
+/* [RW 1] Indicates if in e1hov mode. 0=non-e1hov mode; 1=e1hov mode. */
+#define PRS_REG_E1HOV_MODE					 0x401c8
 /* [RW 8] The 8-bit event ID for a match and packet type 1. Used in packet
    start message to TCM. */
 #define PRS_REG_EVENT_ID_1					 0x40054
 #define PRS_REG_EVENT_ID_2					 0x40058
 #define PRS_REG_EVENT_ID_3					 0x4005c
+/* [RW 16] The Ethernet type value for FCoE */
+#define PRS_REG_FCOE_TYPE					 0x401d0
 /* [RW 8] Context region for flush packet with packet type 0. Used in CFC
    load request message. */
 #define PRS_REG_FLUSH_REGIONS_TYPE_0				 0x40004
@@ -1732,6 +1959,11 @@
 #define PXP2_REG_HST_HEADER_FIFO_STATUS 			 0x120478
 #define PXP2_REG_PGL_CONTROL0					 0x120490
 #define PXP2_REG_PGL_CONTROL1					 0x120514
+/* [RW 32] third dword data of expansion rom request. this register is
+   special. reading from it provides a vector outstanding read requests. if
+   a bit is zero it means that a read request on the corresponding tag did
+   not finish yet (not all completions have arrived for it) */
+#define PXP2_REG_PGL_EXP_ROM2					 0x120808
 /* [RW 32] Inbound interrupt table for CSDM: bits[31:16]-mask;
    its[15:0]-address */
 #define PXP2_REG_PGL_INT_CSDM_0 				 0x1204f4
@@ -1775,8 +2007,7 @@
 /* [R 1] this bit indicates that a read request was blocked because of
    bus_master_en was deasserted */
 #define PXP2_REG_PGL_READ_BLOCKED				 0x120568
-/* [R 6] debug only */
-#define PXP2_REG_PGL_TXR_CDTS					 0x120528
+#define PXP2_REG_PGL_TAGS_LIMIT 				 0x1205a8
 /* [R 18] debug only */
 #define PXP2_REG_PGL_TXW_CDTS					 0x12052c
 /* [R 1] this bit indicates that a write request was blocked because of
@@ -1828,6 +2059,7 @@
 #define PXP2_REG_PSWRQ_QM0_L2P					 0x120038
 #define PXP2_REG_PSWRQ_SRC0_L2P 				 0x120054
 #define PXP2_REG_PSWRQ_TM0_L2P					 0x12001c
+#define PXP2_REG_PSWRQ_TSDM0_L2P				 0x1200e0
 /* [RW 25] Interrupt mask register #0 read/write */
 #define PXP2_REG_PXP2_INT_MASK					 0x120578
 /* [R 25] Interrupt register #0 read */
@@ -2016,8 +2248,12 @@
 #define PXP2_REG_RQ_BW_WR_UBOUND29				 0x1202a4
 /* [RW 7] Bandwidth upper bound for VQ30 */
 #define PXP2_REG_RQ_BW_WR_UBOUND30				 0x1202a8
+/* [RW 18] external first_mem_addr field in L2P table for CDU module port 0 */
+#define PXP2_REG_RQ_CDU0_EFIRST_MEM_ADDR			 0x120008
 /* [RW 2] Endian mode for cdu */
 #define PXP2_REG_RQ_CDU_ENDIAN_M				 0x1201a0
+#define PXP2_REG_RQ_CDU_FIRST_ILT				 0x12061c
+#define PXP2_REG_RQ_CDU_LAST_ILT				 0x120620
 /* [RW 3] page size in L2P table for CDU module; -4k; -8k; -16k; -32k; -64k;
    -128k */
 #define PXP2_REG_RQ_CDU_P_SIZE					 0x120018
@@ -2029,14 +2265,26 @@
 /* [RW 1] When '1'; requests will enter input buffers but wont get out
    towards the glue */
 #define PXP2_REG_RQ_DISABLE_INPUTS				 0x120330
+/* [RW 1] 1 - SR will be aligned by 64B; 0 - SR will be aligned by 8B */
+#define PXP2_REG_RQ_DRAM_ALIGN					 0x1205b0
+/* [RW 1] If 1 ILT failiue will not result in ELT access; An interrupt will
+   be asserted */
+#define PXP2_REG_RQ_ELT_DISABLE 				 0x12066c
 /* [RW 2] Endian mode for hc */
 #define PXP2_REG_RQ_HC_ENDIAN_M 				 0x1201a8
+/* [RW 1] when '0' ILT logic will work as in A0; otherwise B0; for back
+   compatibility needs; Note that different registers are used per mode */
+#define PXP2_REG_RQ_ILT_MODE					 0x1205b4
 /* [WB 53] Onchip address table */
 #define PXP2_REG_RQ_ONCHIP_AT					 0x122000
+/* [WB 53] Onchip address table - B0 */
+#define PXP2_REG_RQ_ONCHIP_AT_B0				 0x128000
 /* [RW 13] Pending read limiter threshold; in Dwords */
 #define PXP2_REG_RQ_PDR_LIMIT					 0x12033c
 /* [RW 2] Endian mode for qm */
 #define PXP2_REG_RQ_QM_ENDIAN_M 				 0x120194
+#define PXP2_REG_RQ_QM_FIRST_ILT				 0x120634
+#define PXP2_REG_RQ_QM_LAST_ILT 				 0x120638
 /* [RW 3] page size in L2P table for QM module; -4k; -8k; -16k; -32k; -64k;
    -128k */
 #define PXP2_REG_RQ_QM_P_SIZE					 0x120050
@@ -2050,16 +2298,22 @@
 #define PXP2_REG_RQ_RD_MBS1					 0x120168
 /* [RW 2] Endian mode for src */
 #define PXP2_REG_RQ_SRC_ENDIAN_M				 0x12019c
+#define PXP2_REG_RQ_SRC_FIRST_ILT				 0x12063c
+#define PXP2_REG_RQ_SRC_LAST_ILT				 0x120640
 /* [RW 3] page size in L2P table for SRC module; -4k; -8k; -16k; -32k; -64k;
    -128k */
 #define PXP2_REG_RQ_SRC_P_SIZE					 0x12006c
 /* [RW 2] Endian mode for tm */
 #define PXP2_REG_RQ_TM_ENDIAN_M 				 0x120198
+#define PXP2_REG_RQ_TM_FIRST_ILT				 0x120644
+#define PXP2_REG_RQ_TM_LAST_ILT 				 0x120648
 /* [RW 3] page size in L2P table for TM module; -4k; -8k; -16k; -32k; -64k;
    -128k */
 #define PXP2_REG_RQ_TM_P_SIZE					 0x120034
 /* [R 5] Number of entries in the ufifo; his fifo has l2p completions */
 #define PXP2_REG_RQ_UFIFO_NUM_OF_ENTRY				 0x12080c
+/* [RW 18] external first_mem_addr field in L2P table for USDM module port 0 */
+#define PXP2_REG_RQ_USDM0_EFIRST_MEM_ADDR			 0x120094
 /* [R 8] Number of entries occupied by vq 0 in pswrq memory */
 #define PXP2_REG_RQ_VQ0_ENTRY_CNT				 0x120810
 /* [R 8] Number of entries occupied by vq 10 in pswrq memory */
@@ -2130,19 +2384,63 @@
 /* [RW 3] Max burst size filed for write requests port 1; 000 - 128B;
    001:256B; 010: 512B; */
 #define PXP2_REG_RQ_WR_MBS1					 0x120164
+/* [RW 2] 0 - 128B;  - 256B;  - 512B;  - 1024B; when the payload in the
+   buffer reaches this number has_payload will be asserted */
+#define PXP2_REG_WR_CDU_MPS					 0x1205f0
+/* [RW 2] 0 - 128B;  - 256B;  - 512B;  - 1024B; when the payload in the
+   buffer reaches this number has_payload will be asserted */
+#define PXP2_REG_WR_CSDM_MPS					 0x1205d0
+/* [RW 2] 0 - 128B;  - 256B;  - 512B;  - 1024B; when the payload in the
+   buffer reaches this number has_payload will be asserted */
+#define PXP2_REG_WR_DBG_MPS					 0x1205e8
+/* [RW 2] 0 - 128B;  - 256B;  - 512B;  - 1024B; when the payload in the
+   buffer reaches this number has_payload will be asserted */
+#define PXP2_REG_WR_DMAE_MPS					 0x1205ec
 /* [RW 10] if Number of entries in dmae fifo will be higer than this
    threshold then has_payload indication will be asserted; the default value
    should be equal to &gt;  write MBS size! */
 #define PXP2_REG_WR_DMAE_TH					 0x120368
+/* [RW 2] 0 - 128B;  - 256B;  - 512B;  - 1024B; when the payload in the
+   buffer reaches this number has_payload will be asserted */
+#define PXP2_REG_WR_HC_MPS					 0x1205c8
+/* [RW 2] 0 - 128B;  - 256B;  - 512B;  - 1024B; when the payload in the
+   buffer reaches this number has_payload will be asserted */
+#define PXP2_REG_WR_QM_MPS					 0x1205dc
+/* [RW 1] 0 - working in A0 mode;  - working in B0 mode */
+#define PXP2_REG_WR_REV_MODE					 0x120670
+/* [RW 2] 0 - 128B;  - 256B;  - 512B;  - 1024B; when the payload in the
+   buffer reaches this number has_payload will be asserted */
+#define PXP2_REG_WR_SRC_MPS					 0x1205e4
+/* [RW 2] 0 - 128B;  - 256B;  - 512B;  - 1024B; when the payload in the
+   buffer reaches this number has_payload will be asserted */
+#define PXP2_REG_WR_TM_MPS					 0x1205e0
+/* [RW 2] 0 - 128B;  - 256B;  - 512B;  - 1024B; when the payload in the
+   buffer reaches this number has_payload will be asserted */
+#define PXP2_REG_WR_TSDM_MPS					 0x1205d4
 /* [RW 10] if Number of entries in usdmdp fifo will be higer than this
    threshold then has_payload indication will be asserted; the default value
    should be equal to &gt;  write MBS size! */
 #define PXP2_REG_WR_USDMDP_TH					 0x120348
+/* [RW 2] 0 - 128B;  - 256B;  - 512B;  - 1024B; when the payload in the
+   buffer reaches this number has_payload will be asserted */
+#define PXP2_REG_WR_USDM_MPS					 0x1205cc
+/* [RW 2] 0 - 128B;  - 256B;  - 512B;  - 1024B; when the payload in the
+   buffer reaches this number has_payload will be asserted */
+#define PXP2_REG_WR_XSDM_MPS					 0x1205d8
 /* [R 1] debug only: Indication if PSWHST arbiter is idle */
 #define PXP_REG_HST_ARB_IS_IDLE 				 0x103004
 /* [R 8] debug only: A bit mask for all PSWHST arbiter clients. '1' means
    this client is waiting for the arbiter. */
 #define PXP_REG_HST_CLIENTS_WAITING_TO_ARB			 0x103008
+/* [R 1] debug only: '1' means this PSWHST is discarding doorbells. This bit
+   should update accoring to 'hst_discard_doorbells' register when the state
+   machine is idle */
+#define PXP_REG_HST_DISCARD_DOORBELLS_STATUS			 0x1030a0
+/* [R 6] debug only: A bit mask for all PSWHST internal write clients. '1'
+   means this PSWHST is discarding inputs from this client. Each bit should
+   update accoring to 'hst_discard_internal_writes' register when the state
+   machine is idle. */
+#define PXP_REG_HST_DISCARD_INTERNAL_WRITES_STATUS		 0x10309c
 /* [WB 160] Used for initialization of the inbound interrupts memory */
 #define PXP_REG_HST_INBOUND_INT 				 0x103800
 /* [RW 32] Interrupt mask register #0 read/write */
@@ -2165,18 +2463,25 @@
 #define QM_REG_ACTCTRINITVAL_3					 0x16804c
 /* [RW 32] The base logical address (in bytes) of each physical queue. The
    index I represents the physical queue number. The 12 lsbs are ignore and
-   considered zero so practically there are only 20 bits in this register. */
+   considered zero so practically there are only 20 bits in this register;
+   queues 63-0 */
 #define QM_REG_BASEADDR 					 0x168900
 /* [RW 16] The byte credit cost for each task. This value is for both ports */
 #define QM_REG_BYTECRDCOST					 0x168234
 /* [RW 16] The initial byte credit value for both ports. */
 #define QM_REG_BYTECRDINITVAL					 0x168238
 /* [RW 32] A bit per physical queue. If the bit is cleared then the physical
-   queue uses port 0 else it uses port 1. */
+   queue uses port 0 else it uses port 1; queues 31-0 */
 #define QM_REG_BYTECRDPORT_LSB					 0x168228
 /* [RW 32] A bit per physical queue. If the bit is cleared then the physical
-   queue uses port 0 else it uses port 1. */
+   queue uses port 0 else it uses port 1; queues 95-64 */
+#define QM_REG_BYTECRDPORT_LSB_EXT_A				 0x16e520
+/* [RW 32] A bit per physical queue. If the bit is cleared then the physical
+   queue uses port 0 else it uses port 1; queues 63-32 */
 #define QM_REG_BYTECRDPORT_MSB					 0x168224
+/* [RW 32] A bit per physical queue. If the bit is cleared then the physical
+   queue uses port 0 else it uses port 1; queues 127-96 */
+#define QM_REG_BYTECRDPORT_MSB_EXT_A				 0x16e51c
 /* [RW 16] The byte credit value that if above the QM is considered almost
    full */
 #define QM_REG_BYTECREDITAFULLTHR				 0x168094
@@ -2203,7 +2508,7 @@
 #define QM_REG_CMINTVOQMASK_6					 0x16820c
 #define QM_REG_CMINTVOQMASK_7					 0x168210
 /* [RW 20] The number of connections divided by 16 which dictates the size
-   of each queue per port 0 */
+   of each queue which belongs to even function number. */
 #define QM_REG_CONNNUM_0					 0x168020
 /* [R 6] Keep the fill level of the fifo from write client 4 */
 #define QM_REG_CQM_WRC_FIFOLVL					 0x168018
@@ -2216,74 +2521,179 @@
    bypass enable */
 #define QM_REG_ENBYPVOQMASK					 0x16823c
 /* [RW 32] A bit mask per each physical queue. If a bit is set then the
-   physical queue uses the byte credit */
+   physical queue uses the byte credit; queues 31-0 */
 #define QM_REG_ENBYTECRD_LSB					 0x168220
 /* [RW 32] A bit mask per each physical queue. If a bit is set then the
-   physical queue uses the byte credit */
+   physical queue uses the byte credit; queues 95-64 */
+#define QM_REG_ENBYTECRD_LSB_EXT_A				 0x16e518
+/* [RW 32] A bit mask per each physical queue. If a bit is set then the
+   physical queue uses the byte credit; queues 63-32 */
 #define QM_REG_ENBYTECRD_MSB					 0x16821c
+/* [RW 32] A bit mask per each physical queue. If a bit is set then the
+   physical queue uses the byte credit; queues 127-96 */
+#define QM_REG_ENBYTECRD_MSB_EXT_A				 0x16e514
 /* [RW 4] If cleared then the secondary interface will not be served by the
    RR arbiter */
 #define QM_REG_ENSEC						 0x1680f0
-/* [RW 32] A bit vector per each physical queue which selects which function
-   number to use on PCI access for that queue. */
+/* [RW 32] NA */
 #define QM_REG_FUNCNUMSEL_LSB					 0x168230
-/* [RW 32] A bit vector per each physical queue which selects which function
-   number to use on PCI access for that queue. */
+/* [RW 32] NA */
 #define QM_REG_FUNCNUMSEL_MSB					 0x16822c
 /* [RW 32] A mask register to mask the Almost empty signals which will not
-   be use for the almost empty indication to the HW block */
+   be use for the almost empty indication to the HW block; queues 31:0 */
 #define QM_REG_HWAEMPTYMASK_LSB 				 0x168218
 /* [RW 32] A mask register to mask the Almost empty signals which will not
-   be use for the almost empty indication to the HW block */
+   be use for the almost empty indication to the HW block; queues 95-64 */
+#define QM_REG_HWAEMPTYMASK_LSB_EXT_A				 0x16e510
+/* [RW 32] A mask register to mask the Almost empty signals which will not
+   be use for the almost empty indication to the HW block; queues 63:32 */
 #define QM_REG_HWAEMPTYMASK_MSB 				 0x168214
+/* [RW 32] A mask register to mask the Almost empty signals which will not
+   be use for the almost empty indication to the HW block; queues 127-96 */
+#define QM_REG_HWAEMPTYMASK_MSB_EXT_A				 0x16e50c
 /* [RW 4] The number of outstanding request to CFC */
 #define QM_REG_OUTLDREQ 					 0x168804
 /* [RC 1] A flag to indicate that overflow error occurred in one of the
    queues. */
 #define QM_REG_OVFERROR 					 0x16805c
-/* [RC 6] the Q were the qverflow occurs */
+/* [RC 7] the Q were the qverflow occurs */
 #define QM_REG_OVFQNUM						 0x168058
-/* [R 32] Pause state for physical queues 31-0 */
+/* [R 16] Pause state for physical queues 15-0 */
 #define QM_REG_PAUSESTATE0					 0x168410
-/* [R 32] Pause state for physical queues 64-32 */
+/* [R 16] Pause state for physical queues 31-16 */
 #define QM_REG_PAUSESTATE1					 0x168414
+/* [R 16] Pause state for physical queues 47-32 */
+#define QM_REG_PAUSESTATE2					 0x16e684
+/* [R 16] Pause state for physical queues 63-48 */
+#define QM_REG_PAUSESTATE3					 0x16e688
+/* [R 16] Pause state for physical queues 79-64 */
+#define QM_REG_PAUSESTATE4					 0x16e68c
+/* [R 16] Pause state for physical queues 95-80 */
+#define QM_REG_PAUSESTATE5					 0x16e690
+/* [R 16] Pause state for physical queues 111-96 */
+#define QM_REG_PAUSESTATE6					 0x16e694
+/* [R 16] Pause state for physical queues 127-112 */
+#define QM_REG_PAUSESTATE7					 0x16e698
 /* [RW 2] The PCI attributes field used in the PCI request. */
 #define QM_REG_PCIREQAT 					 0x168054
 /* [R 16] The byte credit of port 0 */
 #define QM_REG_PORT0BYTECRD					 0x168300
 /* [R 16] The byte credit of port 1 */
 #define QM_REG_PORT1BYTECRD					 0x168304
-/* [WB 54] Pointer Table Memory; The mapping is as follow: ptrtbl[53:30]
-   read pointer; ptrtbl[29:6] write pointer; ptrtbl[5:4] read bank0;
-   ptrtbl[3:2] read bank 1; ptrtbl[1:0] write bank; */
+/* [RW 3] pci function number of queues 15-0 */
+#define QM_REG_PQ2PCIFUNC_0					 0x16e6bc
+#define QM_REG_PQ2PCIFUNC_1					 0x16e6c0
+#define QM_REG_PQ2PCIFUNC_2					 0x16e6c4
+#define QM_REG_PQ2PCIFUNC_3					 0x16e6c8
+#define QM_REG_PQ2PCIFUNC_4					 0x16e6cc
+#define QM_REG_PQ2PCIFUNC_5					 0x16e6d0
+#define QM_REG_PQ2PCIFUNC_6					 0x16e6d4
+#define QM_REG_PQ2PCIFUNC_7					 0x16e6d8
+/* [WB 54] Pointer Table Memory for queues 63-0; The mapping is as follow:
+   ptrtbl[53:30] read pointer; ptrtbl[29:6] write pointer; ptrtbl[5:4] read
+   bank0; ptrtbl[3:2] read bank 1; ptrtbl[1:0] write bank; */
 #define QM_REG_PTRTBL						 0x168a00
+/* [WB 54] Pointer Table Memory for queues 127-64; The mapping is as follow:
+   ptrtbl[53:30] read pointer; ptrtbl[29:6] write pointer; ptrtbl[5:4] read
+   bank0; ptrtbl[3:2] read bank 1; ptrtbl[1:0] write bank; */
+#define QM_REG_PTRTBL_EXT_A					 0x16e200
 /* [RW 2] Interrupt mask register #0 read/write */
 #define QM_REG_QM_INT_MASK					 0x168444
 /* [R 2] Interrupt register #0 read */
 #define QM_REG_QM_INT_STS					 0x168438
-/* [RW 9] Parity mask register #0 read/write */
+/* [RW 12] Parity mask register #0 read/write */
 #define QM_REG_QM_PRTY_MASK					 0x168454
-/* [R 9] Parity register #0 read */
+/* [R 12] Parity register #0 read */
 #define QM_REG_QM_PRTY_STS					 0x168448
 /* [R 32] Current queues in pipeline: Queues from 32 to 63 */
 #define QM_REG_QSTATUS_HIGH					 0x16802c
+/* [R 32] Current queues in pipeline: Queues from 96 to 127 */
+#define QM_REG_QSTATUS_HIGH_EXT_A				 0x16e408
 /* [R 32] Current queues in pipeline: Queues from 0 to 31 */
 #define QM_REG_QSTATUS_LOW					 0x168028
-/* [R 24] The number of tasks queued for each queue */
+/* [R 32] Current queues in pipeline: Queues from 64 to 95 */
+#define QM_REG_QSTATUS_LOW_EXT_A				 0x16e404
+/* [R 24] The number of tasks queued for each queue; queues 63-0 */
 #define QM_REG_QTASKCTR_0					 0x168308
+/* [R 24] The number of tasks queued for each queue; queues 127-64 */
+#define QM_REG_QTASKCTR_EXT_A_0 				 0x16e584
 /* [RW 4] Queue tied to VOQ */
 #define QM_REG_QVOQIDX_0					 0x1680f4
 #define QM_REG_QVOQIDX_10					 0x16811c
+#define QM_REG_QVOQIDX_100					 0x16e49c
+#define QM_REG_QVOQIDX_101					 0x16e4a0
+#define QM_REG_QVOQIDX_102					 0x16e4a4
+#define QM_REG_QVOQIDX_103					 0x16e4a8
+#define QM_REG_QVOQIDX_104					 0x16e4ac
+#define QM_REG_QVOQIDX_105					 0x16e4b0
+#define QM_REG_QVOQIDX_106					 0x16e4b4
+#define QM_REG_QVOQIDX_107					 0x16e4b8
+#define QM_REG_QVOQIDX_108					 0x16e4bc
+#define QM_REG_QVOQIDX_109					 0x16e4c0
+#define QM_REG_QVOQIDX_100					 0x16e49c
+#define QM_REG_QVOQIDX_101					 0x16e4a0
+#define QM_REG_QVOQIDX_102					 0x16e4a4
+#define QM_REG_QVOQIDX_103					 0x16e4a8
+#define QM_REG_QVOQIDX_104					 0x16e4ac
+#define QM_REG_QVOQIDX_105					 0x16e4b0
+#define QM_REG_QVOQIDX_106					 0x16e4b4
+#define QM_REG_QVOQIDX_107					 0x16e4b8
+#define QM_REG_QVOQIDX_108					 0x16e4bc
+#define QM_REG_QVOQIDX_109					 0x16e4c0
 #define QM_REG_QVOQIDX_11					 0x168120
+#define QM_REG_QVOQIDX_110					 0x16e4c4
+#define QM_REG_QVOQIDX_111					 0x16e4c8
+#define QM_REG_QVOQIDX_112					 0x16e4cc
+#define QM_REG_QVOQIDX_113					 0x16e4d0
+#define QM_REG_QVOQIDX_114					 0x16e4d4
+#define QM_REG_QVOQIDX_115					 0x16e4d8
+#define QM_REG_QVOQIDX_116					 0x16e4dc
+#define QM_REG_QVOQIDX_117					 0x16e4e0
+#define QM_REG_QVOQIDX_118					 0x16e4e4
+#define QM_REG_QVOQIDX_119					 0x16e4e8
+#define QM_REG_QVOQIDX_110					 0x16e4c4
+#define QM_REG_QVOQIDX_111					 0x16e4c8
+#define QM_REG_QVOQIDX_112					 0x16e4cc
+#define QM_REG_QVOQIDX_113					 0x16e4d0
+#define QM_REG_QVOQIDX_114					 0x16e4d4
+#define QM_REG_QVOQIDX_115					 0x16e4d8
+#define QM_REG_QVOQIDX_116					 0x16e4dc
+#define QM_REG_QVOQIDX_117					 0x16e4e0
+#define QM_REG_QVOQIDX_118					 0x16e4e4
+#define QM_REG_QVOQIDX_119					 0x16e4e8
 #define QM_REG_QVOQIDX_12					 0x168124
+#define QM_REG_QVOQIDX_120					 0x16e4ec
+#define QM_REG_QVOQIDX_121					 0x16e4f0
+#define QM_REG_QVOQIDX_122					 0x16e4f4
+#define QM_REG_QVOQIDX_123					 0x16e4f8
+#define QM_REG_QVOQIDX_124					 0x16e4fc
+#define QM_REG_QVOQIDX_125					 0x16e500
+#define QM_REG_QVOQIDX_126					 0x16e504
+#define QM_REG_QVOQIDX_127					 0x16e508
+#define QM_REG_QVOQIDX_120					 0x16e4ec
+#define QM_REG_QVOQIDX_121					 0x16e4f0
+#define QM_REG_QVOQIDX_122					 0x16e4f4
+#define QM_REG_QVOQIDX_123					 0x16e4f8
+#define QM_REG_QVOQIDX_124					 0x16e4fc
+#define QM_REG_QVOQIDX_125					 0x16e500
+#define QM_REG_QVOQIDX_126					 0x16e504
+#define QM_REG_QVOQIDX_127					 0x16e508
 #define QM_REG_QVOQIDX_13					 0x168128
 #define QM_REG_QVOQIDX_14					 0x16812c
 #define QM_REG_QVOQIDX_15					 0x168130
 #define QM_REG_QVOQIDX_16					 0x168134
 #define QM_REG_QVOQIDX_17					 0x168138
 #define QM_REG_QVOQIDX_21					 0x168148
+#define QM_REG_QVOQIDX_22					 0x16814c
+#define QM_REG_QVOQIDX_23					 0x168150
+#define QM_REG_QVOQIDX_24					 0x168154
 #define QM_REG_QVOQIDX_25					 0x168158
+#define QM_REG_QVOQIDX_26					 0x16815c
+#define QM_REG_QVOQIDX_27					 0x168160
+#define QM_REG_QVOQIDX_28					 0x168164
 #define QM_REG_QVOQIDX_29					 0x168168
+#define QM_REG_QVOQIDX_30					 0x16816c
+#define QM_REG_QVOQIDX_31					 0x168170
 #define QM_REG_QVOQIDX_32					 0x168174
 #define QM_REG_QVOQIDX_33					 0x168178
 #define QM_REG_QVOQIDX_34					 0x16817c
@@ -2328,17 +2738,95 @@
 #define QM_REG_QVOQIDX_61					 0x1681e8
 #define QM_REG_QVOQIDX_62					 0x1681ec
 #define QM_REG_QVOQIDX_63					 0x1681f0
+#define QM_REG_QVOQIDX_64					 0x16e40c
+#define QM_REG_QVOQIDX_65					 0x16e410
+#define QM_REG_QVOQIDX_66					 0x16e414
+#define QM_REG_QVOQIDX_67					 0x16e418
+#define QM_REG_QVOQIDX_68					 0x16e41c
+#define QM_REG_QVOQIDX_69					 0x16e420
 #define QM_REG_QVOQIDX_60					 0x1681e4
 #define QM_REG_QVOQIDX_61					 0x1681e8
 #define QM_REG_QVOQIDX_62					 0x1681ec
 #define QM_REG_QVOQIDX_63					 0x1681f0
+#define QM_REG_QVOQIDX_64					 0x16e40c
+#define QM_REG_QVOQIDX_65					 0x16e410
+#define QM_REG_QVOQIDX_69					 0x16e420
 #define QM_REG_QVOQIDX_7					 0x168110
+#define QM_REG_QVOQIDX_70					 0x16e424
+#define QM_REG_QVOQIDX_71					 0x16e428
+#define QM_REG_QVOQIDX_72					 0x16e42c
+#define QM_REG_QVOQIDX_73					 0x16e430
+#define QM_REG_QVOQIDX_74					 0x16e434
+#define QM_REG_QVOQIDX_75					 0x16e438
+#define QM_REG_QVOQIDX_76					 0x16e43c
+#define QM_REG_QVOQIDX_77					 0x16e440
+#define QM_REG_QVOQIDX_78					 0x16e444
+#define QM_REG_QVOQIDX_79					 0x16e448
+#define QM_REG_QVOQIDX_70					 0x16e424
+#define QM_REG_QVOQIDX_71					 0x16e428
+#define QM_REG_QVOQIDX_72					 0x16e42c
+#define QM_REG_QVOQIDX_73					 0x16e430
+#define QM_REG_QVOQIDX_74					 0x16e434
+#define QM_REG_QVOQIDX_75					 0x16e438
+#define QM_REG_QVOQIDX_76					 0x16e43c
+#define QM_REG_QVOQIDX_77					 0x16e440
+#define QM_REG_QVOQIDX_78					 0x16e444
+#define QM_REG_QVOQIDX_79					 0x16e448
 #define QM_REG_QVOQIDX_8					 0x168114
+#define QM_REG_QVOQIDX_80					 0x16e44c
+#define QM_REG_QVOQIDX_81					 0x16e450
+#define QM_REG_QVOQIDX_82					 0x16e454
+#define QM_REG_QVOQIDX_83					 0x16e458
+#define QM_REG_QVOQIDX_84					 0x16e45c
+#define QM_REG_QVOQIDX_85					 0x16e460
+#define QM_REG_QVOQIDX_86					 0x16e464
+#define QM_REG_QVOQIDX_87					 0x16e468
+#define QM_REG_QVOQIDX_88					 0x16e46c
+#define QM_REG_QVOQIDX_89					 0x16e470
+#define QM_REG_QVOQIDX_80					 0x16e44c
+#define QM_REG_QVOQIDX_81					 0x16e450
+#define QM_REG_QVOQIDX_85					 0x16e460
+#define QM_REG_QVOQIDX_86					 0x16e464
+#define QM_REG_QVOQIDX_87					 0x16e468
+#define QM_REG_QVOQIDX_88					 0x16e46c
+#define QM_REG_QVOQIDX_89					 0x16e470
 #define QM_REG_QVOQIDX_9					 0x168118
-/* [R 24] Remaining pause timeout for port 0 */
+#define QM_REG_QVOQIDX_90					 0x16e474
+#define QM_REG_QVOQIDX_91					 0x16e478
+#define QM_REG_QVOQIDX_92					 0x16e47c
+#define QM_REG_QVOQIDX_93					 0x16e480
+#define QM_REG_QVOQIDX_94					 0x16e484
+#define QM_REG_QVOQIDX_95					 0x16e488
+#define QM_REG_QVOQIDX_96					 0x16e48c
+#define QM_REG_QVOQIDX_97					 0x16e490
+#define QM_REG_QVOQIDX_98					 0x16e494
+#define QM_REG_QVOQIDX_99					 0x16e498
+#define QM_REG_QVOQIDX_90					 0x16e474
+#define QM_REG_QVOQIDX_91					 0x16e478
+#define QM_REG_QVOQIDX_92					 0x16e47c
+#define QM_REG_QVOQIDX_93					 0x16e480
+#define QM_REG_QVOQIDX_94					 0x16e484
+#define QM_REG_QVOQIDX_95					 0x16e488
+#define QM_REG_QVOQIDX_96					 0x16e48c
+#define QM_REG_QVOQIDX_97					 0x16e490
+#define QM_REG_QVOQIDX_98					 0x16e494
+#define QM_REG_QVOQIDX_99					 0x16e498
+/* [R 24] Remaining pause timeout for queues 15-0 */
 #define QM_REG_REMAINPAUSETM0					 0x168418
-/* [R 24] Remaining pause timeout for port 1 */
+/* [R 24] Remaining pause timeout for queues 31-16 */
 #define QM_REG_REMAINPAUSETM1					 0x16841c
+/* [R 24] Remaining pause timeout for queues 47-32 */
+#define QM_REG_REMAINPAUSETM2					 0x16e69c
+/* [R 24] Remaining pause timeout for queues 63-48 */
+#define QM_REG_REMAINPAUSETM3					 0x16e6a0
+/* [R 24] Remaining pause timeout for queues 79-64 */
+#define QM_REG_REMAINPAUSETM4					 0x16e6a4
+/* [R 24] Remaining pause timeout for queues 95-80 */
+#define QM_REG_REMAINPAUSETM5					 0x16e6a8
+/* [R 24] Remaining pause timeout for queues 111-96 */
+#define QM_REG_REMAINPAUSETM6					 0x16e6ac
+/* [R 24] Remaining pause timeout for queues 127-112 */
+#define QM_REG_REMAINPAUSETM7					 0x16e6b0
 /* [RW 1] Initialization bit command */
 #define QM_REG_SOFT_RESET					 0x168428
 /* [RW 8] The credit cost per every task in the QM. A value per each VOQ */
@@ -2372,44 +2860,103 @@
 #define QM_REG_VOQINITCREDIT_4					 0x168070
 #define QM_REG_VOQINITCREDIT_5					 0x168074
 /* [RW 1] The port of which VOQ belongs */
+#define QM_REG_VOQPORT_0					 0x1682a0
 #define QM_REG_VOQPORT_1					 0x1682a4
 #define QM_REG_VOQPORT_10					 0x1682c8
 #define QM_REG_VOQPORT_11					 0x1682cc
 #define QM_REG_VOQPORT_2					 0x1682a8
-/* [RW 32] The physical queue number associated with each VOQ */
+/* [RW 32] The physical queue number associated with each VOQ; queues 31-0 */
 #define QM_REG_VOQQMASK_0_LSB					 0x168240
-/* [RW 32] The physical queue number associated with each VOQ */
+/* [RW 32] The physical queue number associated with each VOQ; queues 95-64 */
+#define QM_REG_VOQQMASK_0_LSB_EXT_A				 0x16e524
+/* [RW 32] The physical queue number associated with each VOQ; queues 63-32 */
 #define QM_REG_VOQQMASK_0_MSB					 0x168244
-/* [RW 32] The physical queue number associated with each VOQ */
+/* [RW 32] The physical queue number associated with each VOQ; queues 127-96 */
+#define QM_REG_VOQQMASK_0_MSB_EXT_A				 0x16e528
+/* [RW 32] The physical queue number associated with each VOQ; queues 31-0 */
+#define QM_REG_VOQQMASK_10_LSB					 0x168290
+/* [RW 32] The physical queue number associated with each VOQ; queues 95-64 */
+#define QM_REG_VOQQMASK_10_LSB_EXT_A				 0x16e574
+/* [RW 32] The physical queue number associated with each VOQ; queues 63-32 */
+#define QM_REG_VOQQMASK_10_MSB					 0x168294
+/* [RW 32] The physical queue number associated with each VOQ; queues 127-96 */
+#define QM_REG_VOQQMASK_10_MSB_EXT_A				 0x16e578
+/* [RW 32] The physical queue number associated with each VOQ; queues 31-0 */
+#define QM_REG_VOQQMASK_11_LSB					 0x168298
+/* [RW 32] The physical queue number associated with each VOQ; queues 95-64 */
+#define QM_REG_VOQQMASK_11_LSB_EXT_A				 0x16e57c
+/* [RW 32] The physical queue number associated with each VOQ; queues 63-32 */
+#define QM_REG_VOQQMASK_11_MSB					 0x16829c
+/* [RW 32] The physical queue number associated with each VOQ; queues 127-96 */
+#define QM_REG_VOQQMASK_11_MSB_EXT_A				 0x16e580
+/* [RW 32] The physical queue number associated with each VOQ; queues 31-0 */
+#define QM_REG_VOQQMASK_1_LSB					 0x168248
+/* [RW 32] The physical queue number associated with each VOQ; queues 95-64 */
+#define QM_REG_VOQQMASK_1_LSB_EXT_A				 0x16e52c
+/* [RW 32] The physical queue number associated with each VOQ; queues 63-32 */
 #define QM_REG_VOQQMASK_1_MSB					 0x16824c
-/* [RW 32] The physical queue number associated with each VOQ */
+/* [RW 32] The physical queue number associated with each VOQ; queues 127-96 */
+#define QM_REG_VOQQMASK_1_MSB_EXT_A				 0x16e530
+/* [RW 32] The physical queue number associated with each VOQ; queues 31-0 */
 #define QM_REG_VOQQMASK_2_LSB					 0x168250
-/* [RW 32] The physical queue number associated with each VOQ */
+/* [RW 32] The physical queue number associated with each VOQ; queues 95-64 */
+#define QM_REG_VOQQMASK_2_LSB_EXT_A				 0x16e534
+/* [RW 32] The physical queue number associated with each VOQ; queues 63-32 */
 #define QM_REG_VOQQMASK_2_MSB					 0x168254
-/* [RW 32] The physical queue number associated with each VOQ */
+/* [RW 32] The physical queue number associated with each VOQ; queues 127-96 */
+#define QM_REG_VOQQMASK_2_MSB_EXT_A				 0x16e538
+/* [RW 32] The physical queue number associated with each VOQ; queues 31-0 */
 #define QM_REG_VOQQMASK_3_LSB					 0x168258
-/* [RW 32] The physical queue number associated with each VOQ */
+/* [RW 32] The physical queue number associated with each VOQ; queues 95-64 */
+#define QM_REG_VOQQMASK_3_LSB_EXT_A				 0x16e53c
+/* [RW 32] The physical queue number associated with each VOQ; queues 127-96 */
+#define QM_REG_VOQQMASK_3_MSB_EXT_A				 0x16e540
+/* [RW 32] The physical queue number associated with each VOQ; queues 31-0 */
 #define QM_REG_VOQQMASK_4_LSB					 0x168260
-/* [RW 32] The physical queue number associated with each VOQ */
+/* [RW 32] The physical queue number associated with each VOQ; queues 95-64 */
+#define QM_REG_VOQQMASK_4_LSB_EXT_A				 0x16e544
+/* [RW 32] The physical queue number associated with each VOQ; queues 63-32 */
 #define QM_REG_VOQQMASK_4_MSB					 0x168264
-/* [RW 32] The physical queue number associated with each VOQ */
+/* [RW 32] The physical queue number associated with each VOQ; queues 127-96 */
+#define QM_REG_VOQQMASK_4_MSB_EXT_A				 0x16e548
+/* [RW 32] The physical queue number associated with each VOQ; queues 31-0 */
 #define QM_REG_VOQQMASK_5_LSB					 0x168268
-/* [RW 32] The physical queue number associated with each VOQ */
+/* [RW 32] The physical queue number associated with each VOQ; queues 95-64 */
+#define QM_REG_VOQQMASK_5_LSB_EXT_A				 0x16e54c
+/* [RW 32] The physical queue number associated with each VOQ; queues 63-32 */
 #define QM_REG_VOQQMASK_5_MSB					 0x16826c
-/* [RW 32] The physical queue number associated with each VOQ */
+/* [RW 32] The physical queue number associated with each VOQ; queues 127-96 */
+#define QM_REG_VOQQMASK_5_MSB_EXT_A				 0x16e550
+/* [RW 32] The physical queue number associated with each VOQ; queues 31-0 */
 #define QM_REG_VOQQMASK_6_LSB					 0x168270
-/* [RW 32] The physical queue number associated with each VOQ */
+/* [RW 32] The physical queue number associated with each VOQ; queues 95-64 */
+#define QM_REG_VOQQMASK_6_LSB_EXT_A				 0x16e554
+/* [RW 32] The physical queue number associated with each VOQ; queues 63-32 */
 #define QM_REG_VOQQMASK_6_MSB					 0x168274
-/* [RW 32] The physical queue number associated with each VOQ */
+/* [RW 32] The physical queue number associated with each VOQ; queues 127-96 */
+#define QM_REG_VOQQMASK_6_MSB_EXT_A				 0x16e558
+/* [RW 32] The physical queue number associated with each VOQ; queues 31-0 */
 #define QM_REG_VOQQMASK_7_LSB					 0x168278
-/* [RW 32] The physical queue number associated with each VOQ */
+/* [RW 32] The physical queue number associated with each VOQ; queues 95-64 */
+#define QM_REG_VOQQMASK_7_LSB_EXT_A				 0x16e55c
+/* [RW 32] The physical queue number associated with each VOQ; queues 63-32 */
 #define QM_REG_VOQQMASK_7_MSB					 0x16827c
-/* [RW 32] The physical queue number associated with each VOQ */
+/* [RW 32] The physical queue number associated with each VOQ; queues 127-96 */
+#define QM_REG_VOQQMASK_7_MSB_EXT_A				 0x16e560
+/* [RW 32] The physical queue number associated with each VOQ; queues 31-0 */
 #define QM_REG_VOQQMASK_8_LSB					 0x168280
-/* [RW 32] The physical queue number associated with each VOQ */
+/* [RW 32] The physical queue number associated with each VOQ; queues 95-64 */
+#define QM_REG_VOQQMASK_8_LSB_EXT_A				 0x16e564
+/* [RW 32] The physical queue number associated with each VOQ; queues 63-32 */
 #define QM_REG_VOQQMASK_8_MSB					 0x168284
-/* [RW 32] The physical queue number associated with each VOQ */
+/* [RW 32] The physical queue number associated with each VOQ; queues 127-96 */
+#define QM_REG_VOQQMASK_8_MSB_EXT_A				 0x16e568
+/* [RW 32] The physical queue number associated with each VOQ; queues 31-0 */
 #define QM_REG_VOQQMASK_9_LSB					 0x168288
+/* [RW 32] The physical queue number associated with each VOQ; queues 95-64 */
+#define QM_REG_VOQQMASK_9_LSB_EXT_A				 0x16e56c
+/* [RW 32] The physical queue number associated with each VOQ; queues 127-96 */
+#define QM_REG_VOQQMASK_9_MSB_EXT_A				 0x16e570
 /* [RW 32] Wrr weights */
 #define QM_REG_WRRWEIGHTS_0					 0x16880c
 #define QM_REG_WRRWEIGHTS_1					 0x168810
@@ -2431,14 +2978,78 @@
 #define QM_REG_WRRWEIGHTS_15					 0x168828
 #define QM_REG_WRRWEIGHTS_15_SIZE				 1
 /* [RW 32] Wrr weights */
+#define QM_REG_WRRWEIGHTS_16					 0x16e000
+#define QM_REG_WRRWEIGHTS_16_SIZE				 1
+/* [RW 32] Wrr weights */
+#define QM_REG_WRRWEIGHTS_17					 0x16e004
+#define QM_REG_WRRWEIGHTS_17_SIZE				 1
+/* [RW 32] Wrr weights */
+#define QM_REG_WRRWEIGHTS_18					 0x16e008
+#define QM_REG_WRRWEIGHTS_18_SIZE				 1
+/* [RW 32] Wrr weights */
+#define QM_REG_WRRWEIGHTS_19					 0x16e00c
+#define QM_REG_WRRWEIGHTS_19_SIZE				 1
+/* [RW 32] Wrr weights */
 #define QM_REG_WRRWEIGHTS_10					 0x168814
 #define QM_REG_WRRWEIGHTS_11					 0x168818
 #define QM_REG_WRRWEIGHTS_12					 0x16881c
 #define QM_REG_WRRWEIGHTS_13					 0x168820
 #define QM_REG_WRRWEIGHTS_14					 0x168824
 #define QM_REG_WRRWEIGHTS_15					 0x168828
+#define QM_REG_WRRWEIGHTS_16					 0x16e000
+#define QM_REG_WRRWEIGHTS_17					 0x16e004
+#define QM_REG_WRRWEIGHTS_18					 0x16e008
+#define QM_REG_WRRWEIGHTS_19					 0x16e00c
 #define QM_REG_WRRWEIGHTS_2					 0x16882c
+#define QM_REG_WRRWEIGHTS_20					 0x16e010
+#define QM_REG_WRRWEIGHTS_20_SIZE				 1
+/* [RW 32] Wrr weights */
+#define QM_REG_WRRWEIGHTS_21					 0x16e014
+#define QM_REG_WRRWEIGHTS_21_SIZE				 1
+/* [RW 32] Wrr weights */
+#define QM_REG_WRRWEIGHTS_22					 0x16e018
+#define QM_REG_WRRWEIGHTS_22_SIZE				 1
+/* [RW 32] Wrr weights */
+#define QM_REG_WRRWEIGHTS_23					 0x16e01c
+#define QM_REG_WRRWEIGHTS_23_SIZE				 1
+/* [RW 32] Wrr weights */
+#define QM_REG_WRRWEIGHTS_24					 0x16e020
+#define QM_REG_WRRWEIGHTS_24_SIZE				 1
+/* [RW 32] Wrr weights */
+#define QM_REG_WRRWEIGHTS_25					 0x16e024
+#define QM_REG_WRRWEIGHTS_25_SIZE				 1
+/* [RW 32] Wrr weights */
+#define QM_REG_WRRWEIGHTS_26					 0x16e028
+#define QM_REG_WRRWEIGHTS_26_SIZE				 1
+/* [RW 32] Wrr weights */
+#define QM_REG_WRRWEIGHTS_27					 0x16e02c
+#define QM_REG_WRRWEIGHTS_27_SIZE				 1
+/* [RW 32] Wrr weights */
+#define QM_REG_WRRWEIGHTS_28					 0x16e030
+#define QM_REG_WRRWEIGHTS_28_SIZE				 1
+/* [RW 32] Wrr weights */
+#define QM_REG_WRRWEIGHTS_29					 0x16e034
+#define QM_REG_WRRWEIGHTS_29_SIZE				 1
+/* [RW 32] Wrr weights */
+#define QM_REG_WRRWEIGHTS_20					 0x16e010
+#define QM_REG_WRRWEIGHTS_21					 0x16e014
+#define QM_REG_WRRWEIGHTS_22					 0x16e018
+#define QM_REG_WRRWEIGHTS_23					 0x16e01c
+#define QM_REG_WRRWEIGHTS_24					 0x16e020
+#define QM_REG_WRRWEIGHTS_25					 0x16e024
+#define QM_REG_WRRWEIGHTS_26					 0x16e028
+#define QM_REG_WRRWEIGHTS_27					 0x16e02c
+#define QM_REG_WRRWEIGHTS_28					 0x16e030
+#define QM_REG_WRRWEIGHTS_29					 0x16e034
 #define QM_REG_WRRWEIGHTS_3					 0x168830
+#define QM_REG_WRRWEIGHTS_30					 0x16e038
+#define QM_REG_WRRWEIGHTS_30_SIZE				 1
+/* [RW 32] Wrr weights */
+#define QM_REG_WRRWEIGHTS_31					 0x16e03c
+#define QM_REG_WRRWEIGHTS_31_SIZE				 1
+/* [RW 32] Wrr weights */
+#define QM_REG_WRRWEIGHTS_30					 0x16e038
+#define QM_REG_WRRWEIGHTS_31					 0x16e03c
 #define QM_REG_WRRWEIGHTS_4					 0x168834
 #define QM_REG_WRRWEIGHTS_5					 0x168838
 #define QM_REG_WRRWEIGHTS_6					 0x16883c
@@ -2447,6 +3058,70 @@
 #define QM_REG_WRRWEIGHTS_9					 0x168848
 /* [R 6] Keep the fill level of the fifo from write client 1 */
 #define QM_REG_XQM_WRC_FIFOLVL					 0x168000
+#define BRB1_BRB1_INT_STS_REG_ADDRESS_ERROR			 (0x1<<0)
+#define BRB1_BRB1_INT_STS_REG_ADDRESS_ERROR_SIZE		 0
+#define BRB1_BRB1_INT_STS_CLR_REG_ADDRESS_ERROR 		 (0x1<<0)
+#define BRB1_BRB1_INT_STS_CLR_REG_ADDRESS_ERROR_SIZE		 0
+#define BRB1_BRB1_INT_STS_WR_REG_ADDRESS_ERROR			 (0x1<<0)
+#define BRB1_BRB1_INT_STS_WR_REG_ADDRESS_ERROR_SIZE		 0
+#define BRB1_BRB1_INT_MASK_REG_ADDRESS_ERROR			 (0x1<<0)
+#define BRB1_BRB1_INT_MASK_REG_ADDRESS_ERROR_SIZE		 0
+#define CCM_CCM_INT_STS_REG_ADDRESS_ERROR			 (0x1<<0)
+#define CCM_CCM_INT_STS_REG_ADDRESS_ERROR_SIZE			 0
+#define CCM_CCM_INT_STS_CLR_REG_ADDRESS_ERROR			 (0x1<<0)
+#define CCM_CCM_INT_STS_CLR_REG_ADDRESS_ERROR_SIZE		 0
+#define CCM_CCM_INT_STS_WR_REG_ADDRESS_ERROR			 (0x1<<0)
+#define CCM_CCM_INT_STS_WR_REG_ADDRESS_ERROR_SIZE		 0
+#define CCM_CCM_INT_MASK_REG_ADDRESS_ERROR			 (0x1<<0)
+#define CCM_CCM_INT_MASK_REG_ADDRESS_ERROR_SIZE 		 0
+#define CDU_CDU_INT_STS_REG_ADDRESS_ERROR			 (0x1<<0)
+#define CDU_CDU_INT_STS_REG_ADDRESS_ERROR_SIZE			 0
+#define CDU_CDU_INT_STS_CLR_REG_ADDRESS_ERROR			 (0x1<<0)
+#define CDU_CDU_INT_STS_CLR_REG_ADDRESS_ERROR_SIZE		 0
+#define CDU_CDU_INT_STS_WR_REG_ADDRESS_ERROR			 (0x1<<0)
+#define CDU_CDU_INT_STS_WR_REG_ADDRESS_ERROR_SIZE		 0
+#define CDU_CDU_INT_MASK_REG_ADDRESS_ERROR			 (0x1<<0)
+#define CDU_CDU_INT_MASK_REG_ADDRESS_ERROR_SIZE 		 0
+#define CFC_CFC_INT_STS_REG_ADDRESS_ERROR			 (0x1<<0)
+#define CFC_CFC_INT_STS_REG_ADDRESS_ERROR_SIZE			 0
+#define CFC_CFC_INT_STS_CLR_REG_ADDRESS_ERROR			 (0x1<<0)
+#define CFC_CFC_INT_STS_CLR_REG_ADDRESS_ERROR_SIZE		 0
+#define CFC_CFC_INT_STS_WR_REG_ADDRESS_ERROR			 (0x1<<0)
+#define CFC_CFC_INT_STS_WR_REG_ADDRESS_ERROR_SIZE		 0
+#define CFC_CFC_INT_MASK_REG_ADDRESS_ERROR			 (0x1<<0)
+#define CFC_CFC_INT_MASK_REG_ADDRESS_ERROR_SIZE 		 0
+#define CSDM_CSDM_INT_STS_0_REG_ADDRESS_ERROR			 (0x1<<0)
+#define CSDM_CSDM_INT_STS_0_REG_ADDRESS_ERROR_SIZE		 0
+#define CSDM_CSDM_INT_STS_CLR_0_REG_ADDRESS_ERROR		 (0x1<<0)
+#define CSDM_CSDM_INT_STS_CLR_0_REG_ADDRESS_ERROR_SIZE		 0
+#define CSDM_CSDM_INT_STS_WR_0_REG_ADDRESS_ERROR		 (0x1<<0)
+#define CSDM_CSDM_INT_STS_WR_0_REG_ADDRESS_ERROR_SIZE		 0
+#define CSDM_CSDM_INT_MASK_0_REG_ADDRESS_ERROR			 (0x1<<0)
+#define CSDM_CSDM_INT_MASK_0_REG_ADDRESS_ERROR_SIZE		 0
+#define CSEM_CSEM_INT_STS_0_REG_ADDRESS_ERROR			 (0x1<<0)
+#define CSEM_CSEM_INT_STS_0_REG_ADDRESS_ERROR_SIZE		 0
+#define CSEM_CSEM_INT_STS_CLR_0_REG_ADDRESS_ERROR		 (0x1<<0)
+#define CSEM_CSEM_INT_STS_CLR_0_REG_ADDRESS_ERROR_SIZE		 0
+#define CSEM_CSEM_INT_STS_WR_0_REG_ADDRESS_ERROR		 (0x1<<0)
+#define CSEM_CSEM_INT_STS_WR_0_REG_ADDRESS_ERROR_SIZE		 0
+#define CSEM_CSEM_INT_MASK_0_REG_ADDRESS_ERROR			 (0x1<<0)
+#define CSEM_CSEM_INT_MASK_0_REG_ADDRESS_ERROR_SIZE		 0
+#define DBG_DBG_INT_STS_REG_ADDRESS_ERROR			 (0x1<<0)
+#define DBG_DBG_INT_STS_REG_ADDRESS_ERROR_SIZE			 0
+#define DBG_DBG_INT_STS_CLR_REG_ADDRESS_ERROR			 (0x1<<0)
+#define DBG_DBG_INT_STS_CLR_REG_ADDRESS_ERROR_SIZE		 0
+#define DBG_DBG_INT_STS_WR_REG_ADDRESS_ERROR			 (0x1<<0)
+#define DBG_DBG_INT_STS_WR_REG_ADDRESS_ERROR_SIZE		 0
+#define DBG_DBG_INT_MASK_REG_ADDRESS_ERROR			 (0x1<<0)
+#define DBG_DBG_INT_MASK_REG_ADDRESS_ERROR_SIZE 		 0
+#define DMAE_DMAE_INT_STS_REG_ADDRESS_ERROR			 (0x1<<0)
+#define DMAE_DMAE_INT_STS_REG_ADDRESS_ERROR_SIZE		 0
+#define DMAE_DMAE_INT_STS_CLR_REG_ADDRESS_ERROR 		 (0x1<<0)
+#define DMAE_DMAE_INT_STS_CLR_REG_ADDRESS_ERROR_SIZE		 0
+#define DMAE_DMAE_INT_STS_WR_REG_ADDRESS_ERROR			 (0x1<<0)
+#define DMAE_DMAE_INT_STS_WR_REG_ADDRESS_ERROR_SIZE		 0
+#define DMAE_DMAE_INT_MASK_REG_ADDRESS_ERROR			 (0x1<<0)
+#define DMAE_DMAE_INT_MASK_REG_ADDRESS_ERROR_SIZE		 0
 #define DORQ_DORQ_INT_STS_REG_ADDRESS_ERROR			 (0x1<<0)
 #define DORQ_DORQ_INT_STS_REG_ADDRESS_ERROR_SIZE		 0
 #define DORQ_DORQ_INT_STS_CLR_REG_ADDRESS_ERROR 		 (0x1<<0)
@@ -2455,6 +3130,22 @@
 #define DORQ_DORQ_INT_STS_WR_REG_ADDRESS_ERROR_SIZE		 0
 #define DORQ_DORQ_INT_MASK_REG_ADDRESS_ERROR			 (0x1<<0)
 #define DORQ_DORQ_INT_MASK_REG_ADDRESS_ERROR_SIZE		 0
+#define HC_HC_INT_STS_REG_ADDRESS_ERROR 			 (0x1<<0)
+#define HC_HC_INT_STS_REG_ADDRESS_ERROR_SIZE			 0
+#define HC_HC_INT_STS_CLR_REG_ADDRESS_ERROR			 (0x1<<0)
+#define HC_HC_INT_STS_CLR_REG_ADDRESS_ERROR_SIZE		 0
+#define HC_HC_INT_STS_WR_REG_ADDRESS_ERROR			 (0x1<<0)
+#define HC_HC_INT_STS_WR_REG_ADDRESS_ERROR_SIZE 		 0
+#define HC_HC_INT_MASK_REG_ADDRESS_ERROR			 (0x1<<0)
+#define HC_HC_INT_MASK_REG_ADDRESS_ERROR_SIZE			 0
+#define MISC_MISC_INT_STS_REG_ADDRESS_ERROR			 (0x1<<0)
+#define MISC_MISC_INT_STS_REG_ADDRESS_ERROR_SIZE		 0
+#define MISC_MISC_INT_STS_CLR_REG_ADDRESS_ERROR 		 (0x1<<0)
+#define MISC_MISC_INT_STS_CLR_REG_ADDRESS_ERROR_SIZE		 0
+#define MISC_MISC_INT_STS_WR_REG_ADDRESS_ERROR			 (0x1<<0)
+#define MISC_MISC_INT_STS_WR_REG_ADDRESS_ERROR_SIZE		 0
+#define MISC_MISC_INT_MASK_REG_ADDRESS_ERROR			 (0x1<<0)
+#define MISC_MISC_INT_MASK_REG_ADDRESS_ERROR_SIZE		 0
 #define NIG_NIG_INT_STS_0_REG_ADDRESS_ERROR			 (0x1<<0)
 #define NIG_NIG_INT_STS_0_REG_ADDRESS_ERROR_SIZE		 0
 #define NIG_NIG_INT_STS_CLR_0_REG_ADDRESS_ERROR 		 (0x1<<0)
@@ -2463,6 +3154,70 @@
 #define NIG_NIG_INT_STS_WR_0_REG_ADDRESS_ERROR_SIZE		 0
 #define NIG_NIG_INT_MASK_0_REG_ADDRESS_ERROR			 (0x1<<0)
 #define NIG_NIG_INT_MASK_0_REG_ADDRESS_ERROR_SIZE		 0
+#define PBF_PBF_INT_STS_REG_ADDRESS_ERROR			 (0x1<<0)
+#define PBF_PBF_INT_STS_REG_ADDRESS_ERROR_SIZE			 0
+#define PBF_PBF_INT_STS_CLR_REG_ADDRESS_ERROR			 (0x1<<0)
+#define PBF_PBF_INT_STS_CLR_REG_ADDRESS_ERROR_SIZE		 0
+#define PBF_PBF_INT_STS_WR_REG_ADDRESS_ERROR			 (0x1<<0)
+#define PBF_PBF_INT_STS_WR_REG_ADDRESS_ERROR_SIZE		 0
+#define PBF_PBF_INT_MASK_REG_ADDRESS_ERROR			 (0x1<<0)
+#define PBF_PBF_INT_MASK_REG_ADDRESS_ERROR_SIZE 		 0
+#define PB_PB_INT_STS_REG_ADDRESS_ERROR 			 (0x1<<0)
+#define PB_PB_INT_STS_REG_ADDRESS_ERROR_SIZE			 0
+#define PB_PB_INT_STS_CLR_REG_ADDRESS_ERROR			 (0x1<<0)
+#define PB_PB_INT_STS_CLR_REG_ADDRESS_ERROR_SIZE		 0
+#define PB_PB_INT_STS_WR_REG_ADDRESS_ERROR			 (0x1<<0)
+#define PB_PB_INT_STS_WR_REG_ADDRESS_ERROR_SIZE 		 0
+#define PB_PB_INT_MASK_REG_ADDRESS_ERROR			 (0x1<<0)
+#define PB_PB_INT_MASK_REG_ADDRESS_ERROR_SIZE			 0
+#define PRS_PRS_INT_STS_REG_ADDRESS_ERROR			 (0x1<<0)
+#define PRS_PRS_INT_STS_REG_ADDRESS_ERROR_SIZE			 0
+#define PRS_PRS_INT_STS_CLR_REG_ADDRESS_ERROR			 (0x1<<0)
+#define PRS_PRS_INT_STS_CLR_REG_ADDRESS_ERROR_SIZE		 0
+#define PRS_PRS_INT_STS_WR_REG_ADDRESS_ERROR			 (0x1<<0)
+#define PRS_PRS_INT_STS_WR_REG_ADDRESS_ERROR_SIZE		 0
+#define PRS_PRS_INT_MASK_REG_ADDRESS_ERROR			 (0x1<<0)
+#define PRS_PRS_INT_MASK_REG_ADDRESS_ERROR_SIZE 		 0
+#define PXP2_PXP2_INT_STS_0_REG_ADDRESS_ERROR			 (0x1<<0)
+#define PXP2_PXP2_INT_STS_0_REG_ADDRESS_ERROR_SIZE		 0
+#define PXP2_PXP2_INT_STS_CLR_0_REG_ADDRESS_ERROR		 (0x1<<0)
+#define PXP2_PXP2_INT_STS_CLR_0_REG_ADDRESS_ERROR_SIZE		 0
+#define PXP2_PXP2_INT_STS_WR_0_REG_ADDRESS_ERROR		 (0x1<<0)
+#define PXP2_PXP2_INT_STS_WR_0_REG_ADDRESS_ERROR_SIZE		 0
+#define PXP2_PXP2_INT_MASK_0_REG_ADDRESS_ERROR			 (0x1<<0)
+#define PXP2_PXP2_INT_MASK_0_REG_ADDRESS_ERROR_SIZE		 0
+#define PXP_PXP_INT_STS_0_REG_ADDRESS_ERROR			 (0x1<<0)
+#define PXP_PXP_INT_STS_0_REG_ADDRESS_ERROR_SIZE		 0
+#define PXP_PXP_INT_STS_CLR_0_REG_ADDRESS_ERROR 		 (0x1<<0)
+#define PXP_PXP_INT_STS_CLR_0_REG_ADDRESS_ERROR_SIZE		 0
+#define PXP_PXP_INT_STS_WR_0_REG_ADDRESS_ERROR			 (0x1<<0)
+#define PXP_PXP_INT_STS_WR_0_REG_ADDRESS_ERROR_SIZE		 0
+#define PXP_PXP_INT_MASK_0_REG_ADDRESS_ERROR			 (0x1<<0)
+#define PXP_PXP_INT_MASK_0_REG_ADDRESS_ERROR_SIZE		 0
+#define QM_QM_INT_STS_REG_ADDRESS_ERROR 			 (0x1<<0)
+#define QM_QM_INT_STS_REG_ADDRESS_ERROR_SIZE			 0
+#define QM_QM_INT_STS_CLR_REG_ADDRESS_ERROR			 (0x1<<0)
+#define QM_QM_INT_STS_CLR_REG_ADDRESS_ERROR_SIZE		 0
+#define QM_QM_INT_STS_WR_REG_ADDRESS_ERROR			 (0x1<<0)
+#define QM_QM_INT_STS_WR_REG_ADDRESS_ERROR_SIZE 		 0
+#define QM_QM_INT_MASK_REG_ADDRESS_ERROR			 (0x1<<0)
+#define QM_QM_INT_MASK_REG_ADDRESS_ERROR_SIZE			 0
+#define SEM_FAST_SEM_FAST_INT_STS_REG_ADDRESS_ERROR		 (0x1<<0)
+#define SEM_FAST_SEM_FAST_INT_STS_REG_ADDRESS_ERROR_SIZE	 0
+#define SEM_FAST_SEM_FAST_INT_STS_CLR_REG_ADDRESS_ERROR 	 (0x1<<0)
+#define SEM_FAST_SEM_FAST_INT_STS_CLR_REG_ADDRESS_ERROR_SIZE	 0
+#define SEM_FAST_SEM_FAST_INT_STS_WR_REG_ADDRESS_ERROR		 (0x1<<0)
+#define SEM_FAST_SEM_FAST_INT_STS_WR_REG_ADDRESS_ERROR_SIZE	 0
+#define SEM_FAST_SEM_FAST_INT_MASK_REG_ADDRESS_ERROR		 (0x1<<0)
+#define SEM_FAST_SEM_FAST_INT_MASK_REG_ADDRESS_ERROR_SIZE	 0
+#define SRC_SRC_INT_STS_REG_ADDRESS_ERROR			 (0x1<<0)
+#define SRC_SRC_INT_STS_REG_ADDRESS_ERROR_SIZE			 0
+#define SRC_SRC_INT_STS_CLR_REG_ADDRESS_ERROR			 (0x1<<0)
+#define SRC_SRC_INT_STS_CLR_REG_ADDRESS_ERROR_SIZE		 0
+#define SRC_SRC_INT_STS_WR_REG_ADDRESS_ERROR			 (0x1<<0)
+#define SRC_SRC_INT_STS_WR_REG_ADDRESS_ERROR_SIZE		 0
+#define SRC_SRC_INT_MASK_REG_ADDRESS_ERROR			 (0x1<<0)
+#define SRC_SRC_INT_MASK_REG_ADDRESS_ERROR_SIZE 		 0
 #define TCM_TCM_INT_STS_REG_ADDRESS_ERROR			 (0x1<<0)
 #define TCM_TCM_INT_STS_REG_ADDRESS_ERROR_SIZE			 0
 #define TCM_TCM_INT_STS_CLR_REG_ADDRESS_ERROR			 (0x1<<0)
@@ -2471,6 +3226,78 @@
 #define TCM_TCM_INT_STS_WR_REG_ADDRESS_ERROR_SIZE		 0
 #define TCM_TCM_INT_MASK_REG_ADDRESS_ERROR			 (0x1<<0)
 #define TCM_TCM_INT_MASK_REG_ADDRESS_ERROR_SIZE 		 0
+#define TM_TM_INT_STS_REG_ADDRESS_ERROR 			 (0x1<<0)
+#define TM_TM_INT_STS_REG_ADDRESS_ERROR_SIZE			 0
+#define TM_TM_INT_STS_CLR_REG_ADDRESS_ERROR			 (0x1<<0)
+#define TM_TM_INT_STS_CLR_REG_ADDRESS_ERROR_SIZE		 0
+#define TM_TM_INT_STS_WR_REG_ADDRESS_ERROR			 (0x1<<0)
+#define TM_TM_INT_STS_WR_REG_ADDRESS_ERROR_SIZE 		 0
+#define TM_TM_INT_MASK_REG_ADDRESS_ERROR			 (0x1<<0)
+#define TM_TM_INT_MASK_REG_ADDRESS_ERROR_SIZE			 0
+#define TSDM_TSDM_INT_STS_0_REG_ADDRESS_ERROR			 (0x1<<0)
+#define TSDM_TSDM_INT_STS_0_REG_ADDRESS_ERROR_SIZE		 0
+#define TSDM_TSDM_INT_STS_CLR_0_REG_ADDRESS_ERROR		 (0x1<<0)
+#define TSDM_TSDM_INT_STS_CLR_0_REG_ADDRESS_ERROR_SIZE		 0
+#define TSDM_TSDM_INT_STS_WR_0_REG_ADDRESS_ERROR		 (0x1<<0)
+#define TSDM_TSDM_INT_STS_WR_0_REG_ADDRESS_ERROR_SIZE		 0
+#define TSDM_TSDM_INT_MASK_0_REG_ADDRESS_ERROR			 (0x1<<0)
+#define TSDM_TSDM_INT_MASK_0_REG_ADDRESS_ERROR_SIZE		 0
+#define TSEM_TSEM_INT_STS_0_REG_ADDRESS_ERROR			 (0x1<<0)
+#define TSEM_TSEM_INT_STS_0_REG_ADDRESS_ERROR_SIZE		 0
+#define TSEM_TSEM_INT_STS_CLR_0_REG_ADDRESS_ERROR		 (0x1<<0)
+#define TSEM_TSEM_INT_STS_CLR_0_REG_ADDRESS_ERROR_SIZE		 0
+#define TSEM_TSEM_INT_STS_WR_0_REG_ADDRESS_ERROR		 (0x1<<0)
+#define TSEM_TSEM_INT_STS_WR_0_REG_ADDRESS_ERROR_SIZE		 0
+#define TSEM_TSEM_INT_MASK_0_REG_ADDRESS_ERROR			 (0x1<<0)
+#define TSEM_TSEM_INT_MASK_0_REG_ADDRESS_ERROR_SIZE		 0
+#define UCM_UCM_INT_STS_REG_ADDRESS_ERROR			 (0x1<<0)
+#define UCM_UCM_INT_STS_REG_ADDRESS_ERROR_SIZE			 0
+#define UCM_UCM_INT_STS_CLR_REG_ADDRESS_ERROR			 (0x1<<0)
+#define UCM_UCM_INT_STS_CLR_REG_ADDRESS_ERROR_SIZE		 0
+#define UCM_UCM_INT_STS_WR_REG_ADDRESS_ERROR			 (0x1<<0)
+#define UCM_UCM_INT_STS_WR_REG_ADDRESS_ERROR_SIZE		 0
+#define UCM_UCM_INT_MASK_REG_ADDRESS_ERROR			 (0x1<<0)
+#define UCM_UCM_INT_MASK_REG_ADDRESS_ERROR_SIZE 		 0
+#define USDM_USDM_INT_STS_0_REG_ADDRESS_ERROR			 (0x1<<0)
+#define USDM_USDM_INT_STS_0_REG_ADDRESS_ERROR_SIZE		 0
+#define USDM_USDM_INT_STS_CLR_0_REG_ADDRESS_ERROR		 (0x1<<0)
+#define USDM_USDM_INT_STS_CLR_0_REG_ADDRESS_ERROR_SIZE		 0
+#define USDM_USDM_INT_STS_WR_0_REG_ADDRESS_ERROR		 (0x1<<0)
+#define USDM_USDM_INT_STS_WR_0_REG_ADDRESS_ERROR_SIZE		 0
+#define USDM_USDM_INT_MASK_0_REG_ADDRESS_ERROR			 (0x1<<0)
+#define USDM_USDM_INT_MASK_0_REG_ADDRESS_ERROR_SIZE		 0
+#define USEM_USEM_INT_STS_0_REG_ADDRESS_ERROR			 (0x1<<0)
+#define USEM_USEM_INT_STS_0_REG_ADDRESS_ERROR_SIZE		 0
+#define USEM_USEM_INT_STS_CLR_0_REG_ADDRESS_ERROR		 (0x1<<0)
+#define USEM_USEM_INT_STS_CLR_0_REG_ADDRESS_ERROR_SIZE		 0
+#define USEM_USEM_INT_STS_WR_0_REG_ADDRESS_ERROR		 (0x1<<0)
+#define USEM_USEM_INT_STS_WR_0_REG_ADDRESS_ERROR_SIZE		 0
+#define USEM_USEM_INT_MASK_0_REG_ADDRESS_ERROR			 (0x1<<0)
+#define USEM_USEM_INT_MASK_0_REG_ADDRESS_ERROR_SIZE		 0
+#define XCM_XCM_INT_STS_REG_ADDRESS_ERROR			 (0x1<<0)
+#define XCM_XCM_INT_STS_REG_ADDRESS_ERROR_SIZE			 0
+#define XCM_XCM_INT_STS_CLR_REG_ADDRESS_ERROR			 (0x1<<0)
+#define XCM_XCM_INT_STS_CLR_REG_ADDRESS_ERROR_SIZE		 0
+#define XCM_XCM_INT_STS_WR_REG_ADDRESS_ERROR			 (0x1<<0)
+#define XCM_XCM_INT_STS_WR_REG_ADDRESS_ERROR_SIZE		 0
+#define XCM_XCM_INT_MASK_REG_ADDRESS_ERROR			 (0x1<<0)
+#define XCM_XCM_INT_MASK_REG_ADDRESS_ERROR_SIZE 		 0
+#define XSDM_XSDM_INT_STS_0_REG_ADDRESS_ERROR			 (0x1<<0)
+#define XSDM_XSDM_INT_STS_0_REG_ADDRESS_ERROR_SIZE		 0
+#define XSDM_XSDM_INT_STS_CLR_0_REG_ADDRESS_ERROR		 (0x1<<0)
+#define XSDM_XSDM_INT_STS_CLR_0_REG_ADDRESS_ERROR_SIZE		 0
+#define XSDM_XSDM_INT_STS_WR_0_REG_ADDRESS_ERROR		 (0x1<<0)
+#define XSDM_XSDM_INT_STS_WR_0_REG_ADDRESS_ERROR_SIZE		 0
+#define XSDM_XSDM_INT_MASK_0_REG_ADDRESS_ERROR			 (0x1<<0)
+#define XSDM_XSDM_INT_MASK_0_REG_ADDRESS_ERROR_SIZE		 0
+#define XSEM_XSEM_INT_STS_0_REG_ADDRESS_ERROR			 (0x1<<0)
+#define XSEM_XSEM_INT_STS_0_REG_ADDRESS_ERROR_SIZE		 0
+#define XSEM_XSEM_INT_STS_CLR_0_REG_ADDRESS_ERROR		 (0x1<<0)
+#define XSEM_XSEM_INT_STS_CLR_0_REG_ADDRESS_ERROR_SIZE		 0
+#define XSEM_XSEM_INT_STS_WR_0_REG_ADDRESS_ERROR		 (0x1<<0)
+#define XSEM_XSEM_INT_STS_WR_0_REG_ADDRESS_ERROR_SIZE		 0
+#define XSEM_XSEM_INT_MASK_0_REG_ADDRESS_ERROR			 (0x1<<0)
+#define XSEM_XSEM_INT_MASK_0_REG_ADDRESS_ERROR_SIZE		 0
 #define CFC_DEBUG1_REG_WRITE_AC 				 (0x1<<4)
 #define CFC_DEBUG1_REG_WRITE_AC_SIZE				 4
 /* [R 1] debug only: This bit indicates wheter indicates that external
@@ -2483,6 +3310,14 @@
    ~dbg_registers_debug_target=0 (internal buffer) */
 #define DBG_REG_WRAP_ON_INT_BUFFER				 0xc128
 #define DBG_REG_WRAP_ON_INT_BUFFER_SIZE 			 1
+#define QM_QM_PRTY_STS_REG_WRBUFF				 (0x1<<8)
+#define QM_QM_PRTY_STS_REG_WRBUFF_SIZE				 8
+#define QM_QM_PRTY_STS_CLR_REG_WRBUFF				 (0x1<<8)
+#define QM_QM_PRTY_STS_CLR_REG_WRBUFF_SIZE			 8
+#define QM_QM_PRTY_STS_WR_REG_WRBUFF				 (0x1<<8)
+#define QM_QM_PRTY_STS_WR_REG_WRBUFF_SIZE			 8
+#define QM_QM_PRTY_MASK_REG_WRBUFF				 (0x1<<8)
+#define QM_QM_PRTY_MASK_REG_WRBUFF_SIZE 			 8
 /* [RW 32] Wrr weights */
 #define QM_REG_WRRWEIGHTS_0					 0x16880c
 #define QM_REG_WRRWEIGHTS_0_SIZE				 1
@@ -2531,20 +3366,67 @@
 /* [RW 32] Wrr weights */
 #define QM_REG_WRRWEIGHTS_9					 0x168848
 #define QM_REG_WRRWEIGHTS_9_SIZE				 1
-/* [RW 22] Number of free element in the free list of T2 entries - port 0. */
+/* [RW 32] Wrr weights */
+#define QM_REG_WRRWEIGHTS_16					 0x16e000
+#define QM_REG_WRRWEIGHTS_16_SIZE				 1
+/* [RW 32] Wrr weights */
+#define QM_REG_WRRWEIGHTS_17					 0x16e004
+#define QM_REG_WRRWEIGHTS_17_SIZE				 1
+/* [RW 32] Wrr weights */
+#define QM_REG_WRRWEIGHTS_18					 0x16e008
+#define QM_REG_WRRWEIGHTS_18_SIZE				 1
+/* [RW 32] Wrr weights */
+#define QM_REG_WRRWEIGHTS_19					 0x16e00c
+#define QM_REG_WRRWEIGHTS_19_SIZE				 1
+/* [RW 32] Wrr weights */
+#define QM_REG_WRRWEIGHTS_20					 0x16e010
+#define QM_REG_WRRWEIGHTS_20_SIZE				 1
+/* [RW 32] Wrr weights */
+#define QM_REG_WRRWEIGHTS_21					 0x16e014
+#define QM_REG_WRRWEIGHTS_21_SIZE				 1
+/* [RW 32] Wrr weights */
+#define QM_REG_WRRWEIGHTS_22					 0x16e018
+#define QM_REG_WRRWEIGHTS_22_SIZE				 1
+/* [RW 32] Wrr weights */
+#define QM_REG_WRRWEIGHTS_23					 0x16e01c
+#define QM_REG_WRRWEIGHTS_23_SIZE				 1
+/* [RW 32] Wrr weights */
+#define QM_REG_WRRWEIGHTS_24					 0x16e020
+#define QM_REG_WRRWEIGHTS_24_SIZE				 1
+/* [RW 32] Wrr weights */
+#define QM_REG_WRRWEIGHTS_25					 0x16e024
+#define QM_REG_WRRWEIGHTS_25_SIZE				 1
+/* [RW 32] Wrr weights */
+#define QM_REG_WRRWEIGHTS_26					 0x16e028
+#define QM_REG_WRRWEIGHTS_26_SIZE				 1
+/* [RW 32] Wrr weights */
+#define QM_REG_WRRWEIGHTS_27					 0x16e02c
+#define QM_REG_WRRWEIGHTS_27_SIZE				 1
+/* [RW 32] Wrr weights */
+#define QM_REG_WRRWEIGHTS_28					 0x16e030
+#define QM_REG_WRRWEIGHTS_28_SIZE				 1
+/* [RW 32] Wrr weights */
+#define QM_REG_WRRWEIGHTS_29					 0x16e034
+#define QM_REG_WRRWEIGHTS_29_SIZE				 1
+/* [RW 32] Wrr weights */
+#define QM_REG_WRRWEIGHTS_30					 0x16e038
+#define QM_REG_WRRWEIGHTS_30_SIZE				 1
+/* [RW 32] Wrr weights */
+#define QM_REG_WRRWEIGHTS_31					 0x16e03c
+#define QM_REG_WRRWEIGHTS_31_SIZE				 1
 #define SRC_REG_COUNTFREE0					 0x40500
-/* [WB 64] First free element in the free list of T2 entries - port 0. */
+/* [RW 1] If clr the searcher is compatible to E1 A0 - support only two
+   ports. If set the searcher support 8 functions. */
+#define SRC_REG_E1HMF_ENABLE					 0x404cc
 #define SRC_REG_FIRSTFREE0					 0x40510
 #define SRC_REG_KEYRSS0_0					 0x40408
+#define SRC_REG_KEYRSS0_7					 0x40424
 #define SRC_REG_KEYRSS1_9					 0x40454
-/* [WB 64] Last free element in the free list of T2 entries - port 0. */
 #define SRC_REG_LASTFREE0					 0x40530
-/* [RW 5] The number of hash bits used for the search (h); Values can be 8
-   to 24. */
 #define SRC_REG_NUMBER_HASH_BITS0				 0x40400
 /* [RW 1] Reset internal state machines. */
 #define SRC_REG_SOFT_RST					 0x4049c
-/* [R 1] Interrupt register #0 read */
+/* [R 3] Interrupt register #0 read */
 #define SRC_REG_SRC_INT_STS					 0x404ac
 /* [RW 3] Parity mask register #0 read/write */
 #define SRC_REG_SRC_PRTY_MASK					 0x404c8
@@ -2637,11 +3519,14 @@
    weight 8 (the most prioritised); 1 stands for weight 1(least
    prioritised); 2 stands for weight 2; tc. */
 #define TCM_REG_PBF_WEIGHT					 0x500b4
-/* [RW 6] The physical queue number 0 per port index. */
 #define TCM_REG_PHYS_QNUM0_0					 0x500e0
 #define TCM_REG_PHYS_QNUM0_1					 0x500e4
-/* [RW 6] The physical queue number 1 per port index. */
 #define TCM_REG_PHYS_QNUM1_0					 0x500e8
+#define TCM_REG_PHYS_QNUM1_1					 0x500ec
+#define TCM_REG_PHYS_QNUM2_0					 0x500f0
+#define TCM_REG_PHYS_QNUM2_1					 0x500f4
+#define TCM_REG_PHYS_QNUM3_0					 0x500f8
+#define TCM_REG_PHYS_QNUM3_1					 0x500fc
 /* [RW 1] Input prs Interface enable. If 0 - the valid input is disregarded;
    acknowledge output is deasserted; all other signals are treated as usual;
    if 1 - normal activity. */
@@ -2670,6 +3555,8 @@
 #define TCM_REG_TCM_INT_MASK					 0x501dc
 /* [R 11] Interrupt register #0 read */
 #define TCM_REG_TCM_INT_STS					 0x501d0
+/* [R 27] Parity register #0 read */
+#define TCM_REG_TCM_PRTY_STS					 0x501e0
 /* [RW 3] The size of AG context region 0 in REG-pairs. Designates the MS
    REG-pair number (e.g. if region 0 is 6 REG-pairs; the value should be 5).
    Is used to determine the number of the AG context REG-pairs written back;
@@ -2729,6 +3616,7 @@
    mechanism. The fields are: [5:0] - length of the message; 15:6] - message
    pointer; 20:16] - next pointer. */
 #define TCM_REG_XX_DESCR_TABLE					 0x50280
+#define TCM_REG_XX_DESCR_TABLE_SIZE				 32
 /* [R 6] Use to read the value of XX protection Free counter. */
 #define TCM_REG_XX_FREE 					 0x50178
 /* [RW 6] Initial value for the credit counter; responsible for fulfilling
@@ -2780,7 +3668,7 @@
 /* [RW 4] Load value for expiration credit cnt. CFC max number of
    outstanding load requests for timers (expiration) context loading. */
 #define TM_REG_EXP_CRDCNT_VAL					 0x164238
-/* [RW 18] Linear0 Max active cid. */
+/* [RW 18] Linear0 Max active cid (in banks of 32 entries). */
 #define TM_REG_LIN0_MAX_ACTIVE_CID				 0x164048
 /* [WB 64] Linear0 phy address. */
 #define TM_REG_LIN0_PHY_ADDR					 0x164270
@@ -2804,6 +3692,21 @@
 #define TM_REG_TM_INT_STS					 0x1640f0
 /* [RW 8] The event id for aggregated interrupt 0 */
 #define TSDM_REG_AGG_INT_EVENT_0				 0x42038
+#define TSDM_REG_AGG_INT_EVENT_2				 0x42040
+#define TSDM_REG_AGG_INT_EVENT_20				 0x42088
+#define TSDM_REG_AGG_INT_EVENT_21				 0x4208c
+#define TSDM_REG_AGG_INT_EVENT_22				 0x42090
+#define TSDM_REG_AGG_INT_EVENT_23				 0x42094
+#define TSDM_REG_AGG_INT_EVENT_24				 0x42098
+#define TSDM_REG_AGG_INT_EVENT_25				 0x4209c
+#define TSDM_REG_AGG_INT_EVENT_26				 0x420a0
+#define TSDM_REG_AGG_INT_EVENT_27				 0x420a4
+#define TSDM_REG_AGG_INT_EVENT_28				 0x420a8
+#define TSDM_REG_AGG_INT_EVENT_29				 0x420ac
+#define TSDM_REG_AGG_INT_EVENT_3				 0x42044
+#define TSDM_REG_AGG_INT_EVENT_30				 0x420b0
+#define TSDM_REG_AGG_INT_EVENT_31				 0x420b4
+#define TSDM_REG_AGG_INT_EVENT_4				 0x42048
 /* [RW 13] The start address in the internal RAM for the cfc_rsp lcid */
 #define TSDM_REG_CFC_RSP_START_ADDR				 0x42008
 /* [RW 16] The maximum value of the competion counter #0 */
@@ -2868,6 +3771,9 @@
 /* [RW 32] Interrupt mask register #0 read/write */
 #define TSDM_REG_TSDM_INT_MASK_0				 0x4229c
 #define TSDM_REG_TSDM_INT_MASK_1				 0x422ac
+/* [R 32] Interrupt register #0 read */
+#define TSDM_REG_TSDM_INT_STS_0 				 0x42290
+#define TSDM_REG_TSDM_INT_STS_1 				 0x422a0
 /* [RW 11] Parity mask register #0 read/write */
 #define TSDM_REG_TSDM_PRTY_MASK 				 0x422bc
 /* [R 11] Parity register #0 read */
@@ -2908,9 +3814,8 @@
 #define TSEM_REG_ENABLE_OUT					 0x1800a8
 /* [RW 32] This address space contains all registers and memories that are
    placed in SEM_FAST block. The SEM_FAST registers are described in
-   appendix B. In order to access the SEM_FAST registers the base address
-   TSEM_REGISTERS_FAST_MEMORY (Offset: 0x1a0000) should be added to each
-   SEM_FAST register offset. */
+   appendix B. In order to access the sem_fast registers the base address
+   ~fast_memory.fast_memory should be added to eachsem_fast register offset. */
 #define TSEM_REG_FAST_MEMORY					 0x1a0000
 /* [RW 1] Disables input messages from FIC0 May be updated during run_time
    by the microcode */
@@ -2921,6 +3826,7 @@
 /* [RW 15] Interrupt table Read and write access to it is not possible in
    the middle of the work */
 #define TSEM_REG_INT_TABLE					 0x180400
+#define TSEM_REG_INT_TABLE_SIZE 				 256
 /* [ST 24] Statistics register. The number of messages that entered through
    FIC0 */
 #define TSEM_REG_MSG_NUM_FIC0					 0x180000
@@ -2993,6 +3899,9 @@
 /* [RW 32] Interrupt mask register #0 read/write */
 #define TSEM_REG_TSEM_INT_MASK_0				 0x180100
 #define TSEM_REG_TSEM_INT_MASK_1				 0x180110
+/* [R 32] Interrupt register #0 read */
+#define TSEM_REG_TSEM_INT_STS_0 				 0x1800f4
+#define TSEM_REG_TSEM_INT_STS_1 				 0x180104
 /* [RW 32] Parity mask register #0 read/write */
 #define TSEM_REG_TSEM_PRTY_MASK_0				 0x180120
 #define TSEM_REG_TSEM_PRTY_MASK_1				 0x180130
@@ -3088,12 +3997,15 @@
 #define UCM_REG_N_SM_CTX_LD_2					 0xe005c
 #define UCM_REG_N_SM_CTX_LD_3					 0xe0060
 #define UCM_REG_N_SM_CTX_LD_4					 0xe0064
-/* [RW 6] The physical queue number 0 per port index (CID[23]) */
+#define UCM_REG_N_SM_CTX_LD_5					 0xe0068
 #define UCM_REG_PHYS_QNUM0_0					 0xe0110
 #define UCM_REG_PHYS_QNUM0_1					 0xe0114
-/* [RW 6] The physical queue number 1 per port index (CID[23]) */
 #define UCM_REG_PHYS_QNUM1_0					 0xe0118
 #define UCM_REG_PHYS_QNUM1_1					 0xe011c
+#define UCM_REG_PHYS_QNUM2_0					 0xe0120
+#define UCM_REG_PHYS_QNUM2_1					 0xe0124
+#define UCM_REG_PHYS_QNUM3_0					 0xe0128
+#define UCM_REG_PHYS_QNUM3_1					 0xe012c
 /* [RW 8] The Event ID for Timers formatting in case of stop done. */
 #define UCM_REG_STOP_EVNT_ID					 0xe00ac
 /* [RC 1] Set when the message length mismatch (relative to last indication)
@@ -3132,6 +4044,8 @@
 #define UCM_REG_UCM_INT_MASK					 0xe01d4
 /* [R 11] Interrupt register #0 read */
 #define UCM_REG_UCM_INT_STS					 0xe01c8
+/* [R 27] Parity register #0 read */
+#define UCM_REG_UCM_PRTY_STS					 0xe01d8
 /* [RW 2] The size of AG context region 0 in REG-pairs. Designates the MS
    REG-pair number (e.g. if region 0 is 6 REG-pairs; the value should be 5).
    Is used to determine the number of the AG context REG-pairs written back;
@@ -3189,6 +4103,7 @@
    mechanism. The fields are:[5:0] - message length; 14:6] - message
    pointer; 19:15] - next pointer. */
 #define UCM_REG_XX_DESCR_TABLE					 0xe0280
+#define UCM_REG_XX_DESCR_TABLE_SIZE				 32
 /* [R 6] Use to read the XX protection Free counter. */
 #define UCM_REG_XX_FREE 					 0xe016c
 /* [RW 6] Initial value for the credit counter; responsible for fulfilling
@@ -3218,6 +4133,21 @@
 #define USDM_REG_AGG_INT_EVENT_17				 0xc407c
 #define USDM_REG_AGG_INT_EVENT_18				 0xc4080
 #define USDM_REG_AGG_INT_EVENT_19				 0xc4084
+#define USDM_REG_AGG_INT_EVENT_2				 0xc4040
+#define USDM_REG_AGG_INT_EVENT_20				 0xc4088
+#define USDM_REG_AGG_INT_EVENT_21				 0xc408c
+#define USDM_REG_AGG_INT_EVENT_22				 0xc4090
+#define USDM_REG_AGG_INT_EVENT_23				 0xc4094
+#define USDM_REG_AGG_INT_EVENT_24				 0xc4098
+#define USDM_REG_AGG_INT_EVENT_25				 0xc409c
+#define USDM_REG_AGG_INT_EVENT_26				 0xc40a0
+#define USDM_REG_AGG_INT_EVENT_27				 0xc40a4
+#define USDM_REG_AGG_INT_EVENT_28				 0xc40a8
+#define USDM_REG_AGG_INT_EVENT_29				 0xc40ac
+#define USDM_REG_AGG_INT_EVENT_3				 0xc4044
+#define USDM_REG_AGG_INT_EVENT_30				 0xc40b0
+#define USDM_REG_AGG_INT_EVENT_31				 0xc40b4
+#define USDM_REG_AGG_INT_EVENT_4				 0xc4048
 /* [RW 1] For each aggregated interrupt index whether the mode is normal (0)
    or auto-mask-mode (1) */
 #define USDM_REG_AGG_INT_MODE_0 				 0xc41b8
@@ -3298,6 +4228,9 @@
 /* [RW 32] Interrupt mask register #0 read/write */
 #define USDM_REG_USDM_INT_MASK_0				 0xc42a0
 #define USDM_REG_USDM_INT_MASK_1				 0xc42b0
+/* [R 32] Interrupt register #0 read */
+#define USDM_REG_USDM_INT_STS_0 				 0xc4294
+#define USDM_REG_USDM_INT_STS_1 				 0xc42a4
 /* [RW 11] Parity mask register #0 read/write */
 #define USDM_REG_USDM_PRTY_MASK 				 0xc42c0
 /* [R 11] Parity register #0 read */
@@ -3338,9 +4271,8 @@
 #define USEM_REG_ENABLE_OUT					 0x3000a8
 /* [RW 32] This address space contains all registers and memories that are
    placed in SEM_FAST block. The SEM_FAST registers are described in
-   appendix B. In order to access the SEM_FAST registers... the base address
-   USEM_REGISTERS_FAST_MEMORY (Offset: 0x320000) should be added to each
-   SEM_FAST register offset. */
+   appendix B. In order to access the sem_fast registers the base address
+   ~fast_memory.fast_memory should be added to eachsem_fast register offset. */
 #define USEM_REG_FAST_MEMORY					 0x320000
 /* [RW 1] Disables input messages from FIC0 May be updated during run_time
    by the microcode */
@@ -3351,6 +4283,7 @@
 /* [RW 15] Interrupt table Read and write access to it is not possible in
    the middle of the work */
 #define USEM_REG_INT_TABLE					 0x300400
+#define USEM_REG_INT_TABLE_SIZE 				 256
 /* [ST 24] Statistics register. The number of messages that entered through
    FIC0 */
 #define USEM_REG_MSG_NUM_FIC0					 0x300000
@@ -3423,6 +4356,9 @@
 /* [RW 32] Interrupt mask register #0 read/write */
 #define USEM_REG_USEM_INT_MASK_0				 0x300110
 #define USEM_REG_USEM_INT_MASK_1				 0x300120
+/* [R 32] Interrupt register #0 read */
+#define USEM_REG_USEM_INT_STS_0 				 0x300104
+#define USEM_REG_USEM_INT_STS_1 				 0x300114
 /* [RW 32] Parity mask register #0 read/write */
 #define USEM_REG_USEM_PRTY_MASK_0				 0x300130
 #define USEM_REG_USEM_PRTY_MASK_1				 0x300140
@@ -3491,11 +4427,8 @@
    writes the initial credit value; read returns the current value of the
    credit counter. Must be initialized to 64 at start-up. */
 #define XCM_REG_FIC1_INIT_CRD					 0x20410
-/* [RW 8] The maximum delayed ACK counter value.Must be at least 2. Per port
-   value. */
 #define XCM_REG_GLB_DEL_ACK_MAX_CNT_0				 0x20118
 #define XCM_REG_GLB_DEL_ACK_MAX_CNT_1				 0x2011c
-/* [RW 28] The delayed ACK timeout in ticks. Per port value. */
 #define XCM_REG_GLB_DEL_ACK_TMR_VAL_0				 0x20108
 #define XCM_REG_GLB_DEL_ACK_TMR_VAL_1				 0x2010c
 /* [RW 1] Arbitratiojn between Input Arbiter groups: 0 - fair Round-Robin; 1
@@ -3545,6 +4478,7 @@
 #define XCM_REG_N_SM_CTX_LD_2					 0x20068
 #define XCM_REG_N_SM_CTX_LD_3					 0x2006c
 #define XCM_REG_N_SM_CTX_LD_4					 0x20070
+#define XCM_REG_N_SM_CTX_LD_5					 0x20074
 /* [RW 1] Input pbf Interface enable. If 0 - the valid input is disregarded;
    acknowledge output is deasserted; all other signals are treated as usual;
    if 1 - normal activity. */
@@ -3556,6 +4490,8 @@
    weight 8 (the most prioritised); 1 stands for weight 1(least
    prioritised); 2 stands for weight 2; tc. */
 #define XCM_REG_PBF_WEIGHT					 0x200d0
+#define XCM_REG_PHYS_QNUM3_0					 0x20100
+#define XCM_REG_PHYS_QNUM3_1					 0x20104
 /* [RW 8] The Event ID for Timers formatting in case of stop done. */
 #define XCM_REG_STOP_EVNT_ID					 0x200b8
 /* [RC 1] Set at message length mismatch (relative to last indication) at
@@ -3603,53 +4539,17 @@
    weight 8 (the most prioritised); 1 stands for weight 1(least
    prioritised); 2 stands for weight 2; tc. */
 #define XCM_REG_USEM_WEIGHT					 0x200c8
-/* [RW 2] DA counter command; used in case of window update doorbell.The
-   first index stands for the value DaEnable of that connection. The second
-   index stands for port number. */
 #define XCM_REG_WU_DA_CNT_CMD00 				 0x201d4
-/* [RW 2] DA counter command; used in case of window update doorbell.The
-   first index stands for the value DaEnable of that connection. The second
-   index stands for port number. */
 #define XCM_REG_WU_DA_CNT_CMD01 				 0x201d8
-/* [RW 2] DA counter command; used in case of window update doorbell.The
-   first index stands for the value DaEnable of that connection. The second
-   index stands for port number. */
 #define XCM_REG_WU_DA_CNT_CMD10 				 0x201dc
-/* [RW 2] DA counter command; used in case of window update doorbell.The
-   first index stands for the value DaEnable of that connection. The second
-   index stands for port number. */
 #define XCM_REG_WU_DA_CNT_CMD11 				 0x201e0
-/* [RW 8] DA counter update value used in case of window update doorbell.The
-   first index stands for the value DaEnable of that connection. The second
-   index stands for port number. */
 #define XCM_REG_WU_DA_CNT_UPD_VAL00				 0x201e4
-/* [RW 8] DA counter update value; used in case of window update
-   doorbell.The first index stands for the value DaEnable of that
-   connection. The second index stands for port number. */
 #define XCM_REG_WU_DA_CNT_UPD_VAL01				 0x201e8
-/* [RW 8] DA counter update value; used in case of window update
-   doorbell.The first index stands for the value DaEnable of that
-   connection. The second index stands for port number. */
 #define XCM_REG_WU_DA_CNT_UPD_VAL10				 0x201ec
-/* [RW 8] DA counter update value; used in case of window update
-   doorbell.The first index stands for the value DaEnable of that
-   connection. The second index stands for port number. */
 #define XCM_REG_WU_DA_CNT_UPD_VAL11				 0x201f0
-/* [RW 1] DA timer command; used in case of window update doorbell.The first
-   index stands for the value DaEnable of that connection. The second index
-   stands for port number. */
 #define XCM_REG_WU_DA_SET_TMR_CNT_FLG_CMD00			 0x201c4
-/* [RW 1] DA timer command; used in case of window update doorbell.The first
-   index stands for the value DaEnable of that connection. The second index
-   stands for port number. */
 #define XCM_REG_WU_DA_SET_TMR_CNT_FLG_CMD01			 0x201c8
-/* [RW 1] DA timer command; used in case of window update doorbell.The first
-   index stands for the value DaEnable of that connection. The second index
-   stands for port number. */
 #define XCM_REG_WU_DA_SET_TMR_CNT_FLG_CMD10			 0x201cc
-/* [RW 1] DA timer command; used in case of window update doorbell.The first
-   index stands for the value DaEnable of that connection. The second index
-   stands for port number. */
 #define XCM_REG_WU_DA_SET_TMR_CNT_FLG_CMD11			 0x201d0
 /* [RW 1] CM - CFC Interface enable. If 0 - the valid input is disregarded;
    acknowledge output is deasserted; all other signals are treated as usual;
@@ -3659,6 +4559,8 @@
 #define XCM_REG_XCM_INT_MASK					 0x202b4
 /* [R 14] Interrupt register #0 read */
 #define XCM_REG_XCM_INT_STS					 0x202a8
+/* [R 30] Parity register #0 read */
+#define XCM_REG_XCM_PRTY_STS					 0x202b8
 /* [RW 4] The size of AG context region 0 in REG-pairs. Designates the MS
    REG-pair number (e.g. if region 0 is 6 REG-pairs; the value should be 5).
    Is used to determine the number of the AG context REG-pairs written back;
@@ -3715,6 +4617,7 @@
    mechanism. The fields are: [5:0] - message length; 11:6] - message
    pointer; 16:12] - next pointer. */
 #define XCM_REG_XX_DESCR_TABLE					 0x20480
+#define XCM_REG_XX_DESCR_TABLE_SIZE				 32
 /* [R 6] Used to read the XX protection Free counter. */
 #define XCM_REG_XX_FREE 					 0x20240
 /* [RW 6] Initial value for the credit counter; responsible for fulfilling
@@ -3728,7 +4631,7 @@
 #define XCM_REG_XX_MSG_NUM					 0x20428
 /* [RW 8] The Event ID; sent to the STORM in case of XX overflow. */
 #define XCM_REG_XX_OVFL_EVNT_ID 				 0x20058
-/* [RW 15] Indirect access to the XX table of the XX protection mechanism.
+/* [RW 16] Indirect access to the XX table of the XX protection mechanism.
    The fields are:[4:0] - tail pointer; 9:5] - Link List size; 14:10] -
    header pointer. */
 #define XCM_REG_XX_TABLE					 0x20500
@@ -3745,6 +4648,9 @@
 #define XSDM_REG_AGG_INT_EVENT_17				 0x16607c
 #define XSDM_REG_AGG_INT_EVENT_18				 0x166080
 #define XSDM_REG_AGG_INT_EVENT_19				 0x166084
+#define XSDM_REG_AGG_INT_EVENT_10				 0x166060
+#define XSDM_REG_AGG_INT_EVENT_11				 0x166064
+#define XSDM_REG_AGG_INT_EVENT_12				 0x166068
 #define XSDM_REG_AGG_INT_EVENT_2				 0x166040
 #define XSDM_REG_AGG_INT_EVENT_20				 0x166088
 #define XSDM_REG_AGG_INT_EVENT_21				 0x16608c
@@ -3756,6 +4662,15 @@
 #define XSDM_REG_AGG_INT_EVENT_27				 0x1660a4
 #define XSDM_REG_AGG_INT_EVENT_28				 0x1660a8
 #define XSDM_REG_AGG_INT_EVENT_29				 0x1660ac
+#define XSDM_REG_AGG_INT_EVENT_3				 0x166044
+#define XSDM_REG_AGG_INT_EVENT_30				 0x1660b0
+#define XSDM_REG_AGG_INT_EVENT_31				 0x1660b4
+#define XSDM_REG_AGG_INT_EVENT_4				 0x166048
+#define XSDM_REG_AGG_INT_EVENT_5				 0x16604c
+#define XSDM_REG_AGG_INT_EVENT_6				 0x166050
+#define XSDM_REG_AGG_INT_EVENT_7				 0x166054
+#define XSDM_REG_AGG_INT_EVENT_8				 0x166058
+#define XSDM_REG_AGG_INT_EVENT_9				 0x16605c
 /* [RW 1] For each aggregated interrupt index whether the mode is normal (0)
    or auto-mask-mode (1) */
 #define XSDM_REG_AGG_INT_MODE_0 				 0x1661b8
@@ -3832,6 +4747,9 @@
 /* [RW 32] Interrupt mask register #0 read/write */
 #define XSDM_REG_XSDM_INT_MASK_0				 0x16629c
 #define XSDM_REG_XSDM_INT_MASK_1				 0x1662ac
+/* [R 32] Interrupt register #0 read */
+#define XSDM_REG_XSDM_INT_STS_0 				 0x166290
+#define XSDM_REG_XSDM_INT_STS_1 				 0x1662a0
 /* [RW 11] Parity mask register #0 read/write */
 #define XSDM_REG_XSDM_PRTY_MASK 				 0x1662bc
 /* [R 11] Parity register #0 read */
@@ -3872,9 +4790,8 @@
 #define XSEM_REG_ENABLE_OUT					 0x2800a8
 /* [RW 32] This address space contains all registers and memories that are
    placed in SEM_FAST block. The SEM_FAST registers are described in
-   appendix B. In order to access the SEM_FAST registers the base address
-   XSEM_REGISTERS_FAST_MEMORY (Offset: 0x2a0000) should be added to each
-   SEM_FAST register offset. */
+   appendix B. In order to access the sem_fast registers the base address
+   ~fast_memory.fast_memory should be added to eachsem_fast register offset. */
 #define XSEM_REG_FAST_MEMORY					 0x2a0000
 /* [RW 1] Disables input messages from FIC0 May be updated during run_time
    by the microcode */
@@ -3885,6 +4802,7 @@
 /* [RW 15] Interrupt table Read and write access to it is not possible in
    the middle of the work */
 #define XSEM_REG_INT_TABLE					 0x280400
+#define XSEM_REG_INT_TABLE_SIZE 				 256
 /* [ST 24] Statistics register. The number of messages that entered through
    FIC0 */
 #define XSEM_REG_MSG_NUM_FIC0					 0x280000
@@ -3957,6 +4875,9 @@
 /* [RW 32] Interrupt mask register #0 read/write */
 #define XSEM_REG_XSEM_INT_MASK_0				 0x280110
 #define XSEM_REG_XSEM_INT_MASK_1				 0x280120
+/* [R 32] Interrupt register #0 read */
+#define XSEM_REG_XSEM_INT_STS_0 				 0x280104
+#define XSEM_REG_XSEM_INT_STS_1 				 0x280114
 /* [RW 32] Parity mask register #0 read/write */
 #define XSEM_REG_XSEM_PRTY_MASK_0				 0x280130
 #define XSEM_REG_XSEM_PRTY_MASK_1				 0x280140
@@ -3993,10 +4914,14 @@
 #define BIGMAC_REGISTER_TX_SOURCE_ADDR				 (0x08<<3)
 #define BIGMAC_REGISTER_TX_STAT_GTBYT				 (0x20<<3)
 #define BIGMAC_REGISTER_TX_STAT_GTPKT				 (0x0C<<3)
+#define EMAC_LED_1000MB_OVERRIDE				 (1L<<1)
+#define EMAC_LED_100MB_OVERRIDE 				 (1L<<2)
+#define EMAC_LED_10MB_OVERRIDE					 (1L<<3)
+#define EMAC_LED_2500MB_OVERRIDE				 (1L<<12)
+#define EMAC_LED_OVERRIDE					 (1L<<0)
+#define EMAC_LED_TRAFFIC					 (1L<<6)
 #define EMAC_MDIO_COMM_COMMAND_ADDRESS				 (0L<<26)
-#define EMAC_MDIO_COMM_COMMAND_READ_22				 (2L<<26)
 #define EMAC_MDIO_COMM_COMMAND_READ_45				 (3L<<26)
-#define EMAC_MDIO_COMM_COMMAND_WRITE_22 			 (1L<<26)
 #define EMAC_MDIO_COMM_COMMAND_WRITE_45 			 (1L<<26)
 #define EMAC_MDIO_COMM_DATA					 (0xffffL<<0)
 #define EMAC_MDIO_COMM_START_BUSY				 (1L<<29)
@@ -4013,6 +4938,7 @@
 #define EMAC_MODE_PORT_MII					 (1L<<2)
 #define EMAC_MODE_PORT_MII_10M					 (3L<<2)
 #define EMAC_MODE_RESET 					 (1L<<0)
+#define EMAC_REG_EMAC_LED					 0xc
 #define EMAC_REG_EMAC_MAC_MATCH 				 0x10
 #define EMAC_REG_EMAC_MDIO_COMM 				 0xac
 #define EMAC_REG_EMAC_MDIO_MODE 				 0xb4
@@ -4030,14 +4956,16 @@
 #define EMAC_RX_MODE_PROMISCUOUS				 (1L<<8)
 #define EMAC_RX_MTU_SIZE_JUMBO_ENA				 (1L<<31)
 #define EMAC_TX_MODE_EXT_PAUSE_EN				 (1L<<3)
-#define EMAC_TX_MODE_RESET					 (1L<<0)
+#define MISC_REGISTERS_GPIO_0					 0
 #define MISC_REGISTERS_GPIO_1					 1
 #define MISC_REGISTERS_GPIO_2					 2
 #define MISC_REGISTERS_GPIO_3					 3
 #define MISC_REGISTERS_GPIO_CLR_POS				 16
 #define MISC_REGISTERS_GPIO_FLOAT				 (0xffL<<24)
 #define MISC_REGISTERS_GPIO_FLOAT_POS				 24
+#define MISC_REGISTERS_GPIO_HIGH				 1
 #define MISC_REGISTERS_GPIO_INPUT_HI_Z				 2
+#define MISC_REGISTERS_GPIO_LOW 				 0
 #define MISC_REGISTERS_GPIO_OUTPUT_HIGH 			 1
 #define MISC_REGISTERS_GPIO_OUTPUT_LOW				 0
 #define MISC_REGISTERS_GPIO_PORT_SHIFT				 4
@@ -4127,7 +5055,7 @@
 #define AEU_INPUTS_ATTN_BITS_XSEMI_PARITY_ERROR 	      (1<<10)
 #define RESERVED_GENERAL_ATTENTION_BIT_0	0
 
-#define EVEREST_GEN_ATTN_IN_USE_MASK		0x3e0
+#define EVEREST_GEN_ATTN_IN_USE_MASK		0x3ffe0
 #define EVEREST_LATCHED_ATTN_IN_USE_MASK	0xffe00000
 
 #define RESERVED_GENERAL_ATTENTION_BIT_6	6
@@ -4156,6 +5084,17 @@
 /* mcp error attention bit */
 #define MCP_FATAL_ASSERT_ATTENTION_BIT	      RESERVED_GENERAL_ATTENTION_BIT_11
 
+/*E1H NIG status sync attention mapped to group 4-7*/
+#define LINK_SYNC_ATTENTION_BIT_FUNC_0	    RESERVED_GENERAL_ATTENTION_BIT_12
+#define LINK_SYNC_ATTENTION_BIT_FUNC_1	    RESERVED_GENERAL_ATTENTION_BIT_13
+#define LINK_SYNC_ATTENTION_BIT_FUNC_2	    RESERVED_GENERAL_ATTENTION_BIT_14
+#define LINK_SYNC_ATTENTION_BIT_FUNC_3	    RESERVED_GENERAL_ATTENTION_BIT_15
+#define LINK_SYNC_ATTENTION_BIT_FUNC_4	    RESERVED_GENERAL_ATTENTION_BIT_16
+#define LINK_SYNC_ATTENTION_BIT_FUNC_5	    RESERVED_GENERAL_ATTENTION_BIT_17
+#define LINK_SYNC_ATTENTION_BIT_FUNC_6	    RESERVED_GENERAL_ATTENTION_BIT_18
+#define LINK_SYNC_ATTENTION_BIT_FUNC_7	    RESERVED_GENERAL_ATTENTION_BIT_19
+
+
 #define LATCHED_ATTN_RBCR			23
 #define LATCHED_ATTN_RBCT			24
 #define LATCHED_ATTN_RBCN			25
@@ -4221,22 +5160,41 @@
 #define PCICFG_OFFSET					0x2000
 #define PCICFG_VENDOR_ID_OFFSET 			0x00
 #define PCICFG_DEVICE_ID_OFFSET 			0x02
-#define PCICFG_SUBSYSTEM_VENDOR_ID_OFFSET		0x2c
-#define PCICFG_SUBSYSTEM_ID_OFFSET			0x2e
-#define PCICFG_INT_LINE 				0x3c
-#define PCICFG_INT_PIN					0x3d
+#define PCICFG_COMMAND_OFFSET				0x04
+#define PCICFG_STATUS_OFFSET				0x06
+#define PCICFG_REVESION_ID				    0x08
 #define PCICFG_CACHE_LINE_SIZE				0x0c
 #define PCICFG_LATENCY_TIMER				0x0d
-#define PCICFG_REVESION_ID				0x08
-#define PCICFG_BAR_1_LOW				0x10
-#define PCICFG_BAR_1_HIGH				0x14
-#define PCICFG_BAR_2_LOW				0x18
-#define PCICFG_BAR_2_HIGH				0x1c
-#define PCICFG_GRC_ADDRESS				0x78
-#define PCICFG_GRC_DATA 				0x80
+#define PCICFG_BAR_1_LOW				    0x10
+#define PCICFG_BAR_1_HIGH				    0x14
+#define PCICFG_BAR_2_LOW				    0x18
+#define PCICFG_BAR_2_HIGH				    0x1c
+#define PCICFG_SUBSYSTEM_VENDOR_ID_OFFSET	0x2c
+#define PCICFG_SUBSYSTEM_ID_OFFSET			0x2e
+#define PCICFG_INT_LINE 				    0x3c
+#define PCICFG_INT_PIN					    0x3d
+#define PCICFG_PM_CSR_OFFSET			0x4c
+#define PCICFG_GRC_ADDRESS				    0x78
+#define PCICFG_GRC_DATA 				    0x80
 #define PCICFG_DEVICE_CONTROL				0xb4
 #define PCICFG_LINK_CONTROL				0xbc
 
+#define PCICFG_COMMAND_IO_SPACE 		    (1<<0)
+#define PCICFG_COMMAND_MEM_SPACE		    (1<<1)
+#define PCICFG_COMMAND_BUS_MASTER		    (1<<2)
+#define PCICFG_COMMAND_SPECIAL_CYCLES		    (1<<3)
+#define PCICFG_COMMAND_MWI_CYCLES		    (1<<4)
+#define PCICFG_COMMAND_VGA_SNOOP		    (1<<5)
+#define PCICFG_COMMAND_PERR_ENA 		    (1<<6)
+#define PCICFG_COMMAND_STEPPING 		    (1<<7)
+#define PCICFG_COMMAND_SERR_ENA 		    (1<<8)
+#define PCICFG_COMMAND_FAST_B2B 		    (1<<9)
+#define PCICFG_COMMAND_INT_DISABLE		    (1<<10)
+#define PCICFG_COMMAND_RESERVED 		    (0x1f<<11)
+
+#define PCICFG_PM_CSR_STATE			    (0x3<<0)
+#define PCICFG_PM_CSR_PME_STATUS		    (1<<15)
+
 #define BAR_USTRORM_INTMEM				0x400000
 #define BAR_CSTRORM_INTMEM				0x410000
 #define BAR_XSTRORM_INTMEM				0x420000
@@ -4336,7 +5294,7 @@
 #define MDIO_CL73_IEEEB0_CL73_AN_CONTROL_MAIN_RST	0x8000
 
 #define MDIO_REG_BANK_CL73_IEEEB1			0x10
-#define MDIO_CL73_IEEEB1_AN_ADV2			0x01
+#define MDIO_CL73_IEEEB1_AN_ADV2				0x01
 #define MDIO_CL73_IEEEB1_AN_ADV2_ADVR_1000M		0x0000
 #define MDIO_CL73_IEEEB1_AN_ADV2_ADVR_1000M_KX		0x0020
 #define MDIO_CL73_IEEEB1_AN_ADV2_ADVR_10G_KX4		0x0040
@@ -4365,7 +5323,7 @@
 #define MDIO_REG_BANK_RX_ALL				0x80f0
 #define MDIO_RX_ALL_RX_EQ_BOOST 			0x1c
 #define MDIO_RX_ALL_RX_EQ_BOOST_EQUALIZER_CTRL_MASK	0x7
-#define MDIO_RX_ALL_RX_EQ_BOOST_OFFSET_CTRL		0x10
+#define MDIO_RX_ALL_RX_EQ_BOOST_OFFSET_CTRL	0x10
 
 #define MDIO_REG_BANK_TX0				0x8060
 #define MDIO_TX0_TX_DRIVER				0x17
@@ -4392,213 +5350,265 @@
 #define MDIO_XGXS_BLOCK2_RX_LN_SWAP			0x10
 #define MDIO_XGXS_BLOCK2_RX_LN_SWAP_ENABLE		0x8000
 #define MDIO_XGXS_BLOCK2_RX_LN_SWAP_FORCE_ENABLE	0x4000
-#define MDIO_XGXS_BLOCK2_TX_LN_SWAP			0x11
+#define MDIO_XGXS_BLOCK2_TX_LN_SWAP		0x11
 #define MDIO_XGXS_BLOCK2_TX_LN_SWAP_ENABLE		0x8000
-#define MDIO_XGXS_BLOCK2_UNICORE_MODE_10G		0x14
+#define MDIO_XGXS_BLOCK2_UNICORE_MODE_10G	0x14
 #define MDIO_XGXS_BLOCK2_UNICORE_MODE_10G_CX4_XGXS	0x0001
 #define MDIO_XGXS_BLOCK2_UNICORE_MODE_10G_HIGIG_XGXS	0x0010
-#define MDIO_XGXS_BLOCK2_TEST_MODE_LANE 		0x15
+#define MDIO_XGXS_BLOCK2_TEST_MODE_LANE 	0x15
 
 #define MDIO_REG_BANK_GP_STATUS 			0x8120
-#define MDIO_GP_STATUS_TOP_AN_STATUS1			    0x1B
-#define MDIO_GP_STATUS_TOP_AN_STATUS1_CL73_AUTONEG_COMPLETE 0x0001
-#define MDIO_GP_STATUS_TOP_AN_STATUS1_CL37_AUTONEG_COMPLETE 0x0002
-#define MDIO_GP_STATUS_TOP_AN_STATUS1_LINK_STATUS	    0x0004
-#define MDIO_GP_STATUS_TOP_AN_STATUS1_DUPLEX_STATUS	    0x0008
-#define MDIO_GP_STATUS_TOP_AN_STATUS1_CL73_MR_LP_NP_AN_ABLE 0x0010
-#define MDIO_GP_STATUS_TOP_AN_STATUS1_CL73_LP_NP_BAM_ABLE   0x0020
-
-#define MDIO_GP_STATUS_TOP_AN_STATUS1_PAUSE_RSOLUTION_TXSIDE 0x0040
-#define MDIO_GP_STATUS_TOP_AN_STATUS1_PAUSE_RSOLUTION_RXSIDE 0x0080
-#define MDIO_GP_STATUS_TOP_AN_STATUS1_ACTUAL_SPEED_MASK     0x3f00
-#define MDIO_GP_STATUS_TOP_AN_STATUS1_ACTUAL_SPEED_10M	    0x0000
-#define MDIO_GP_STATUS_TOP_AN_STATUS1_ACTUAL_SPEED_100M     0x0100
-#define MDIO_GP_STATUS_TOP_AN_STATUS1_ACTUAL_SPEED_1G	    0x0200
-#define MDIO_GP_STATUS_TOP_AN_STATUS1_ACTUAL_SPEED_2_5G     0x0300
-#define MDIO_GP_STATUS_TOP_AN_STATUS1_ACTUAL_SPEED_5G	    0x0400
-#define MDIO_GP_STATUS_TOP_AN_STATUS1_ACTUAL_SPEED_6G	    0x0500
-#define MDIO_GP_STATUS_TOP_AN_STATUS1_ACTUAL_SPEED_10G_HIG  0x0600
-#define MDIO_GP_STATUS_TOP_AN_STATUS1_ACTUAL_SPEED_10G_CX4  0x0700
-#define MDIO_GP_STATUS_TOP_AN_STATUS1_ACTUAL_SPEED_12G_HIG  0x0800
-#define MDIO_GP_STATUS_TOP_AN_STATUS1_ACTUAL_SPEED_12_5G    0x0900
-#define MDIO_GP_STATUS_TOP_AN_STATUS1_ACTUAL_SPEED_13G	    0x0A00
-#define MDIO_GP_STATUS_TOP_AN_STATUS1_ACTUAL_SPEED_15G	    0x0B00
-#define MDIO_GP_STATUS_TOP_AN_STATUS1_ACTUAL_SPEED_16G	    0x0C00
-#define MDIO_GP_STATUS_TOP_AN_STATUS1_ACTUAL_SPEED_1G_KX    0x0D00
-#define MDIO_GP_STATUS_TOP_AN_STATUS1_ACTUAL_SPEED_10G_KX4  0x0E00
+#define MDIO_GP_STATUS_TOP_AN_STATUS1				0x1B
+#define MDIO_GP_STATUS_TOP_AN_STATUS1_CL73_AUTONEG_COMPLETE	0x0001
+#define MDIO_GP_STATUS_TOP_AN_STATUS1_CL37_AUTONEG_COMPLETE	0x0002
+#define MDIO_GP_STATUS_TOP_AN_STATUS1_LINK_STATUS		0x0004
+#define MDIO_GP_STATUS_TOP_AN_STATUS1_DUPLEX_STATUS		0x0008
+#define MDIO_GP_STATUS_TOP_AN_STATUS1_CL73_MR_LP_NP_AN_ABLE	0x0010
+#define MDIO_GP_STATUS_TOP_AN_STATUS1_CL73_LP_NP_BAM_ABLE	0x0020
+#define MDIO_GP_STATUS_TOP_AN_STATUS1_PAUSE_RSOLUTION_TXSIDE	0x0040
+#define MDIO_GP_STATUS_TOP_AN_STATUS1_PAUSE_RSOLUTION_RXSIDE	0x0080
+#define MDIO_GP_STATUS_TOP_AN_STATUS1_ACTUAL_SPEED_MASK 	0x3f00
+#define MDIO_GP_STATUS_TOP_AN_STATUS1_ACTUAL_SPEED_10M		0x0000
+#define MDIO_GP_STATUS_TOP_AN_STATUS1_ACTUAL_SPEED_100M 	0x0100
+#define MDIO_GP_STATUS_TOP_AN_STATUS1_ACTUAL_SPEED_1G		0x0200
+#define MDIO_GP_STATUS_TOP_AN_STATUS1_ACTUAL_SPEED_2_5G 	0x0300
+#define MDIO_GP_STATUS_TOP_AN_STATUS1_ACTUAL_SPEED_5G		0x0400
+#define MDIO_GP_STATUS_TOP_AN_STATUS1_ACTUAL_SPEED_6G		0x0500
+#define MDIO_GP_STATUS_TOP_AN_STATUS1_ACTUAL_SPEED_10G_HIG	0x0600
+#define MDIO_GP_STATUS_TOP_AN_STATUS1_ACTUAL_SPEED_10G_CX4	0x0700
+#define MDIO_GP_STATUS_TOP_AN_STATUS1_ACTUAL_SPEED_12G_HIG	0x0800
+#define MDIO_GP_STATUS_TOP_AN_STATUS1_ACTUAL_SPEED_12_5G	0x0900
+#define MDIO_GP_STATUS_TOP_AN_STATUS1_ACTUAL_SPEED_13G		0x0A00
+#define MDIO_GP_STATUS_TOP_AN_STATUS1_ACTUAL_SPEED_15G		0x0B00
+#define MDIO_GP_STATUS_TOP_AN_STATUS1_ACTUAL_SPEED_16G		0x0C00
+#define MDIO_GP_STATUS_TOP_AN_STATUS1_ACTUAL_SPEED_1G_KX	0x0D00
+#define MDIO_GP_STATUS_TOP_AN_STATUS1_ACTUAL_SPEED_10G_KX4	0x0E00
 
 
 #define MDIO_REG_BANK_10G_PARALLEL_DETECT		0x8130
-#define MDIO_10G_PARALLEL_DETECT_PAR_DET_10G_CONTROL	    0x11
-#define MDIO_10G_PARALLEL_DETECT_PAR_DET_10G_CONTROL_PARDET10G_EN 0x1
-#define MDIO_10G_PARALLEL_DETECT_PAR_DET_10G_LINK	    0x13
-#define MDIO_10G_PARALLEL_DETECT_PAR_DET_10G_LINK_CNT	    (0xb71<<1)
+#define MDIO_10G_PARALLEL_DETECT_PAR_DET_10G_CONTROL		0x11
+#define MDIO_10G_PARALLEL_DETECT_PAR_DET_10G_CONTROL_PARDET10G_EN	0x1
+#define MDIO_10G_PARALLEL_DETECT_PAR_DET_10G_LINK		0x13
+#define MDIO_10G_PARALLEL_DETECT_PAR_DET_10G_LINK_CNT		(0xb71<<1)
 
 #define MDIO_REG_BANK_SERDES_DIGITAL			0x8300
-#define MDIO_SERDES_DIGITAL_A_1000X_CONTROL1		0x10
-#define MDIO_SERDES_DIGITAL_A_1000X_CONTROL1_FIBER_MODE 0x0001
-#define MDIO_SERDES_DIGITAL_A_1000X_CONTROL1_TBI_IF	0x0002
-#define MDIO_SERDES_DIGITAL_A_1000X_CONTROL1_SIGNAL_DETECT_EN	  0x0004
-#define MDIO_SERDES_DIGITAL_A_1000X_CONTROL1_INVERT_SIGNAL_DETECT 0x0008
-#define MDIO_SERDES_DIGITAL_A_1000X_CONTROL1_AUTODET	0x0010
-#define MDIO_SERDES_DIGITAL_A_1000X_CONTROL1_MSTR_MODE	0x0020
-#define MDIO_SERDES_DIGITAL_A_1000X_CONTROL2		0x11
-#define MDIO_SERDES_DIGITAL_A_1000X_CONTROL2_PRL_DT_EN	0x0001
-#define MDIO_SERDES_DIGITAL_A_1000X_CONTROL2_AN_FST_TMR 0x0040
-#define MDIO_SERDES_DIGITAL_A_1000X_STATUS1		0x14
-#define MDIO_SERDES_DIGITAL_A_1000X_STATUS1_DUPLEX	0x0004
-#define MDIO_SERDES_DIGITAL_A_1000X_STATUS1_SPEED_MASK	0x0018
-#define MDIO_SERDES_DIGITAL_A_1000X_STATUS1_SPEED_SHIFT 3
-#define MDIO_SERDES_DIGITAL_A_1000X_STATUS1_SPEED_2_5G	0x0018
-#define MDIO_SERDES_DIGITAL_A_1000X_STATUS1_SPEED_1G	0x0010
-#define MDIO_SERDES_DIGITAL_A_1000X_STATUS1_SPEED_100M	0x0008
-#define MDIO_SERDES_DIGITAL_A_1000X_STATUS1_SPEED_10M	0x0000
-#define MDIO_SERDES_DIGITAL_MISC1			0x18
-#define MDIO_SERDES_DIGITAL_MISC1_REFCLK_SEL_MASK	0xE000
-#define MDIO_SERDES_DIGITAL_MISC1_REFCLK_SEL_25M	0x0000
-#define MDIO_SERDES_DIGITAL_MISC1_REFCLK_SEL_100M	0x2000
-#define MDIO_SERDES_DIGITAL_MISC1_REFCLK_SEL_125M	0x4000
-#define MDIO_SERDES_DIGITAL_MISC1_REFCLK_SEL_156_25M	0x6000
-#define MDIO_SERDES_DIGITAL_MISC1_REFCLK_SEL_187_5M	0x8000
-#define MDIO_SERDES_DIGITAL_MISC1_FORCE_SPEED_SEL	0x0010
-#define MDIO_SERDES_DIGITAL_MISC1_FORCE_SPEED_MASK	0x000f
-#define MDIO_SERDES_DIGITAL_MISC1_FORCE_SPEED_2_5G	0x0000
-#define MDIO_SERDES_DIGITAL_MISC1_FORCE_SPEED_5G	0x0001
-#define MDIO_SERDES_DIGITAL_MISC1_FORCE_SPEED_6G	0x0002
-#define MDIO_SERDES_DIGITAL_MISC1_FORCE_SPEED_10G_HIG	0x0003
-#define MDIO_SERDES_DIGITAL_MISC1_FORCE_SPEED_10G_CX4	0x0004
-#define MDIO_SERDES_DIGITAL_MISC1_FORCE_SPEED_12G	0x0005
-#define MDIO_SERDES_DIGITAL_MISC1_FORCE_SPEED_12_5G	0x0006
-#define MDIO_SERDES_DIGITAL_MISC1_FORCE_SPEED_13G	0x0007
-#define MDIO_SERDES_DIGITAL_MISC1_FORCE_SPEED_15G	0x0008
-#define MDIO_SERDES_DIGITAL_MISC1_FORCE_SPEED_16G	0x0009
+#define MDIO_SERDES_DIGITAL_A_1000X_CONTROL1			0x10
+#define MDIO_SERDES_DIGITAL_A_1000X_CONTROL1_FIBER_MODE 		0x0001
+#define MDIO_SERDES_DIGITAL_A_1000X_CONTROL1_TBI_IF			0x0002
+#define MDIO_SERDES_DIGITAL_A_1000X_CONTROL1_SIGNAL_DETECT_EN		0x0004
+#define MDIO_SERDES_DIGITAL_A_1000X_CONTROL1_INVERT_SIGNAL_DETECT	0x0008
+#define MDIO_SERDES_DIGITAL_A_1000X_CONTROL1_AUTODET			0x0010
+#define MDIO_SERDES_DIGITAL_A_1000X_CONTROL1_MSTR_MODE			0x0020
+#define MDIO_SERDES_DIGITAL_A_1000X_CONTROL2			0x11
+#define MDIO_SERDES_DIGITAL_A_1000X_CONTROL2_PRL_DT_EN			0x0001
+#define MDIO_SERDES_DIGITAL_A_1000X_CONTROL2_AN_FST_TMR 		0x0040
+#define MDIO_SERDES_DIGITAL_A_1000X_STATUS1			0x14
+#define MDIO_SERDES_DIGITAL_A_1000X_STATUS1_DUPLEX			0x0004
+#define MDIO_SERDES_DIGITAL_A_1000X_STATUS1_SPEED_MASK			0x0018
+#define MDIO_SERDES_DIGITAL_A_1000X_STATUS1_SPEED_SHIFT 		3
+#define MDIO_SERDES_DIGITAL_A_1000X_STATUS1_SPEED_2_5G			0x0018
+#define MDIO_SERDES_DIGITAL_A_1000X_STATUS1_SPEED_1G			0x0010
+#define MDIO_SERDES_DIGITAL_A_1000X_STATUS1_SPEED_100M			0x0008
+#define MDIO_SERDES_DIGITAL_A_1000X_STATUS1_SPEED_10M			0x0000
+#define MDIO_SERDES_DIGITAL_MISC1				0x18
+#define MDIO_SERDES_DIGITAL_MISC1_REFCLK_SEL_MASK			0xE000
+#define MDIO_SERDES_DIGITAL_MISC1_REFCLK_SEL_25M			0x0000
+#define MDIO_SERDES_DIGITAL_MISC1_REFCLK_SEL_100M			0x2000
+#define MDIO_SERDES_DIGITAL_MISC1_REFCLK_SEL_125M			0x4000
+#define MDIO_SERDES_DIGITAL_MISC1_REFCLK_SEL_156_25M			0x6000
+#define MDIO_SERDES_DIGITAL_MISC1_REFCLK_SEL_187_5M			0x8000
+#define MDIO_SERDES_DIGITAL_MISC1_FORCE_SPEED_SEL			0x0010
+#define MDIO_SERDES_DIGITAL_MISC1_FORCE_SPEED_MASK			0x000f
+#define MDIO_SERDES_DIGITAL_MISC1_FORCE_SPEED_2_5G			0x0000
+#define MDIO_SERDES_DIGITAL_MISC1_FORCE_SPEED_5G			0x0001
+#define MDIO_SERDES_DIGITAL_MISC1_FORCE_SPEED_6G			0x0002
+#define MDIO_SERDES_DIGITAL_MISC1_FORCE_SPEED_10G_HIG			0x0003
+#define MDIO_SERDES_DIGITAL_MISC1_FORCE_SPEED_10G_CX4			0x0004
+#define MDIO_SERDES_DIGITAL_MISC1_FORCE_SPEED_12G			0x0005
+#define MDIO_SERDES_DIGITAL_MISC1_FORCE_SPEED_12_5G			0x0006
+#define MDIO_SERDES_DIGITAL_MISC1_FORCE_SPEED_13G			0x0007
+#define MDIO_SERDES_DIGITAL_MISC1_FORCE_SPEED_15G			0x0008
+#define MDIO_SERDES_DIGITAL_MISC1_FORCE_SPEED_16G			0x0009
 
 #define MDIO_REG_BANK_OVER_1G				0x8320
-#define MDIO_OVER_1G_DIGCTL_3_4 			0x14
-#define MDIO_OVER_1G_DIGCTL_3_4_MP_ID_MASK		0xffe0
-#define MDIO_OVER_1G_DIGCTL_3_4_MP_ID_SHIFT		5
-#define MDIO_OVER_1G_UP1				0x19
-#define MDIO_OVER_1G_UP1_2_5G				0x0001
-#define MDIO_OVER_1G_UP1_5G				0x0002
-#define MDIO_OVER_1G_UP1_6G				0x0004
-#define MDIO_OVER_1G_UP1_10G				0x0010
-#define MDIO_OVER_1G_UP1_10GH				0x0008
-#define MDIO_OVER_1G_UP1_12G				0x0020
-#define MDIO_OVER_1G_UP1_12_5G				0x0040
-#define MDIO_OVER_1G_UP1_13G				0x0080
-#define MDIO_OVER_1G_UP1_15G				0x0100
-#define MDIO_OVER_1G_UP1_16G				0x0200
-#define MDIO_OVER_1G_UP2				0x1A
-#define MDIO_OVER_1G_UP2_IPREDRIVER_MASK		0x0007
-#define MDIO_OVER_1G_UP2_IDRIVER_MASK			0x0038
-#define MDIO_OVER_1G_UP2_PREEMPHASIS_MASK		0x03C0
-#define MDIO_OVER_1G_UP3				0x1B
-#define MDIO_OVER_1G_UP3_HIGIG2 			0x0001
-#define MDIO_OVER_1G_LP_UP1				0x1C
-#define MDIO_OVER_1G_LP_UP2				0x1D
-#define MDIO_OVER_1G_LP_UP2_MR_ADV_OVER_1G_MASK 	0x03ff
-#define MDIO_OVER_1G_LP_UP2_PREEMPHASIS_MASK		0x0780
-#define MDIO_OVER_1G_LP_UP2_PREEMPHASIS_SHIFT		7
-#define MDIO_OVER_1G_LP_UP3				0x1E
+#define MDIO_OVER_1G_DIGCTL_3_4 				0x14
+#define MDIO_OVER_1G_DIGCTL_3_4_MP_ID_MASK				0xffe0
+#define MDIO_OVER_1G_DIGCTL_3_4_MP_ID_SHIFT				5
+#define MDIO_OVER_1G_UP1					0x19
+#define MDIO_OVER_1G_UP1_2_5G						0x0001
+#define MDIO_OVER_1G_UP1_5G						0x0002
+#define MDIO_OVER_1G_UP1_6G						0x0004
+#define MDIO_OVER_1G_UP1_10G						0x0010
+#define MDIO_OVER_1G_UP1_10GH						0x0008
+#define MDIO_OVER_1G_UP1_12G						0x0020
+#define MDIO_OVER_1G_UP1_12_5G						0x0040
+#define MDIO_OVER_1G_UP1_13G						0x0080
+#define MDIO_OVER_1G_UP1_15G						0x0100
+#define MDIO_OVER_1G_UP1_16G						0x0200
+#define MDIO_OVER_1G_UP2					0x1A
+#define MDIO_OVER_1G_UP2_IPREDRIVER_MASK				0x0007
+#define MDIO_OVER_1G_UP2_IDRIVER_MASK					0x0038
+#define MDIO_OVER_1G_UP2_PREEMPHASIS_MASK				0x03C0
+#define MDIO_OVER_1G_UP3					0x1B
+#define MDIO_OVER_1G_UP3_HIGIG2 					0x0001
+#define MDIO_OVER_1G_LP_UP1					0x1C
+#define MDIO_OVER_1G_LP_UP2					0x1D
+#define MDIO_OVER_1G_LP_UP2_MR_ADV_OVER_1G_MASK 			0x03ff
+#define MDIO_OVER_1G_LP_UP2_PREEMPHASIS_MASK				0x0780
+#define MDIO_OVER_1G_LP_UP2_PREEMPHASIS_SHIFT				7
+#define MDIO_OVER_1G_LP_UP3						0x1E
 
 #define MDIO_REG_BANK_BAM_NEXT_PAGE			0x8350
-#define MDIO_BAM_NEXT_PAGE_MP5_NEXT_PAGE_CTRL		0x10
-#define MDIO_BAM_NEXT_PAGE_MP5_NEXT_PAGE_CTRL_BAM_MODE	0x0001
-#define MDIO_BAM_NEXT_PAGE_MP5_NEXT_PAGE_CTRL_TETON_AN	0x0002
+#define MDIO_BAM_NEXT_PAGE_MP5_NEXT_PAGE_CTRL			0x10
+#define MDIO_BAM_NEXT_PAGE_MP5_NEXT_PAGE_CTRL_BAM_MODE			0x0001
+#define MDIO_BAM_NEXT_PAGE_MP5_NEXT_PAGE_CTRL_TETON_AN			0x0002
+
+#define MDIO_REG_BANK_CL73_USERB0		0x8370
+#define MDIO_CL73_USERB0_CL73_BAM_CTRL1 			0x12
+#define MDIO_CL73_USERB0_CL73_BAM_CTRL1_BAM_EN				0x8000
+#define MDIO_CL73_USERB0_CL73_BAM_CTRL1_BAM_STATION_MNGR_EN		0x4000
+#define MDIO_CL73_USERB0_CL73_BAM_CTRL1_BAM_NP_AFTER_BP_EN		0x2000
+#define MDIO_CL73_USERB0_CL73_BAM_CTRL3 			0x14
+#define MDIO_CL73_USERB0_CL73_BAM_CTRL3_USE_CL73_HCD_MR 		0x0001
+
+#define MDIO_REG_BANK_AER_BLOCK 		0xFFD0
+#define MDIO_AER_BLOCK_AER_REG					0x1E
+
+#define MDIO_REG_BANK_COMBO_IEEE0		0xFFE0
+#define MDIO_COMBO_IEEE0_MII_CONTROL				0x10
+#define MDIO_COMBO_IEEO_MII_CONTROL_MAN_SGMII_SP_MASK			0x2040
+#define MDIO_COMBO_IEEO_MII_CONTROL_MAN_SGMII_SP_10			0x0000
+#define MDIO_COMBO_IEEO_MII_CONTROL_MAN_SGMII_SP_100			0x2000
+#define MDIO_COMBO_IEEO_MII_CONTROL_MAN_SGMII_SP_1000			0x0040
+#define MDIO_COMBO_IEEO_MII_CONTROL_FULL_DUPLEX 			0x0100
+#define MDIO_COMBO_IEEO_MII_CONTROL_RESTART_AN				0x0200
+#define MDIO_COMBO_IEEO_MII_CONTROL_AN_EN				0x1000
+#define MDIO_COMBO_IEEO_MII_CONTROL_LOOPBACK				0x4000
+#define MDIO_COMBO_IEEO_MII_CONTROL_RESET				0x8000
+#define MDIO_COMBO_IEEE0_MII_STATUS				0x11
+#define MDIO_COMBO_IEEE0_MII_STATUS_LINK_PASS				0x0004
+#define MDIO_COMBO_IEEE0_MII_STATUS_AUTONEG_COMPLETE			0x0020
+#define MDIO_COMBO_IEEE0_AUTO_NEG_ADV				0x14
+#define MDIO_COMBO_IEEE0_AUTO_NEG_ADV_FULL_DUPLEX			0x0020
+#define MDIO_COMBO_IEEE0_AUTO_NEG_ADV_HALF_DUPLEX			0x0040
+#define MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_MASK			0x0180
+#define MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_NONE			0x0000
+#define MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_SYMMETRIC			0x0080
+#define MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_ASYMMETRIC			0x0100
+#define MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH			0x0180
+#define MDIO_COMBO_IEEE0_AUTO_NEG_ADV_NEXT_PAGE 			0x8000
+#define MDIO_COMBO_IEEE0_AUTO_NEG_LINK_PARTNER_ABILITY1 	0x15
+#define MDIO_COMBO_IEEE0_AUTO_NEG_LINK_PARTNER_ABILITY1_NEXT_PAGE	0x8000
+#define MDIO_COMBO_IEEE0_AUTO_NEG_LINK_PARTNER_ABILITY1_ACK		0x4000
+#define MDIO_COMBO_IEEE0_AUTO_NEG_LINK_PARTNER_ABILITY1_PAUSE_MASK	0x0180
+#define MDIO_COMBO_IEEE0_AUTO_NEG_LINK_PARTNER_ABILITY1_PAUSE_NONE	0x0000
+#define MDIO_COMBO_IEEE0_AUTO_NEG_LINK_PARTNER_ABILITY1_PAUSE_BOTH	0x0180
+#define MDIO_COMBO_IEEE0_AUTO_NEG_LINK_PARTNER_ABILITY1_HALF_DUP_CAP	0x0040
+#define MDIO_COMBO_IEEE0_AUTO_NEG_LINK_PARTNER_ABILITY1_FULL_DUP_CAP	0x0020
+/*WhenthelinkpartnerisinSGMIImode(bit0=1),then
+bit15=link,bit12=duplex,bits11:10=speed,bit14=acknowledge.
+Theotherbitsarereservedandshouldbezero*/
+#define MDIO_COMBO_IEEE0_AUTO_NEG_LINK_PARTNER_ABILITY1_SGMII_MODE	0x0001
+
+
+#define MDIO_PMA_DEVAD			0x1
+/*ieee*/
+#define MDIO_PMA_REG_CTRL		0x0
+#define MDIO_PMA_REG_STATUS		0x1
+#define MDIO_PMA_REG_10G_CTRL2		0x7
+#define MDIO_PMA_REG_RX_SD		0xa
+/*bcm*/
+#define MDIO_PMA_REG_BCM_CTRL		0x0096
+#define MDIO_PMA_REG_FEC_CTRL		0x00ab
+#define MDIO_PMA_REG_RX_ALARM_CTRL	0x9000
+#define MDIO_PMA_REG_LASI_CTRL		0x9002
+#define MDIO_PMA_REG_RX_ALARM		0x9003
+#define MDIO_PMA_REG_TX_ALARM		0x9004
+#define MDIO_PMA_REG_LASI_STATUS	0x9005
+#define MDIO_PMA_REG_PHY_IDENTIFIER	0xc800
+#define MDIO_PMA_REG_DIGITAL_CTRL	0xc808
+#define MDIO_PMA_REG_DIGITAL_STATUS	0xc809
+#define MDIO_PMA_REG_CMU_PLL_BYPASS	0xca09
+#define MDIO_PMA_REG_MISC_CTRL		0xca0a
+#define MDIO_PMA_REG_GEN_CTRL		0xca10
+#define MDIO_PMA_REG_GEN_CTRL_ROM_RESET_INTERNAL_MP	0x0188
+#define MDIO_PMA_REG_GEN_CTRL_ROM_MICRO_RESET		0x018a
+#define MDIO_PMA_REG_ROM_VER1		0xca19
+#define MDIO_PMA_REG_ROM_VER2		0xca1a
+#define MDIO_PMA_REG_EDC_FFE_MAIN	0xca1b
+#define MDIO_PMA_REG_PLL_BANDWIDTH	0xca1d
+#define MDIO_PMA_REG_CDR_BANDWIDTH	0xca46
+#define MDIO_PMA_REG_MISC_CTRL1 	0xca85
+
+#define MDIO_PMA_REG_7101_RESET 	0xc000
+#define MDIO_PMA_REG_7107_LED_CNTL	0xc007
+#define MDIO_PMA_REG_7101_VER1		0xc026
+#define MDIO_PMA_REG_7101_VER2		0xc027
+
+
+#define MDIO_WIS_DEVAD			0x2
+/*bcm*/
+#define MDIO_WIS_REG_LASI_CNTL		0x9002
+#define MDIO_WIS_REG_LASI_STATUS	0x9005
+
+#define MDIO_PCS_DEVAD			0x3
+#define MDIO_PCS_REG_STATUS		0x0020
+#define MDIO_PCS_REG_LASI_STATUS	0x9005
+#define MDIO_PCS_REG_7101_DSP_ACCESS	0xD000
+#define MDIO_PCS_REG_7101_SPI_MUX	0xD008
+#define MDIO_PCS_REG_7101_SPI_CTRL_ADDR 0xE12A
+#define MDIO_PCS_REG_7101_SPI_RESET_BIT (5)
+#define MDIO_PCS_REG_7101_SPI_FIFO_ADDR 0xE02A
+#define MDIO_PCS_REG_7101_SPI_FIFO_ADDR_WRITE_ENABLE_CMD (6)
+#define MDIO_PCS_REG_7101_SPI_FIFO_ADDR_BULK_ERASE_CMD	 (0xC7)
+#define MDIO_PCS_REG_7101_SPI_FIFO_ADDR_PAGE_PROGRAM_CMD (2)
+#define MDIO_PCS_REG_7101_SPI_BYTES_TO_TRANSFER_ADDR 0xE028
+
 
-#define MDIO_REG_BANK_CL73_USERB0			0x8370
-#define MDIO_CL73_USERB0_CL73_BAM_CTRL1 		0x12
-#define MDIO_CL73_USERB0_CL73_BAM_CTRL1_BAM_EN			0x8000
-#define MDIO_CL73_USERB0_CL73_BAM_CTRL1_BAM_STATION_MNGR_EN	0x4000
-#define MDIO_CL73_USERB0_CL73_BAM_CTRL1_BAM_NP_AFTER_BP_EN	0x2000
-#define MDIO_CL73_USERB0_CL73_BAM_CTRL3 		0x14
-#define MDIO_CL73_USERB0_CL73_BAM_CTRL3_USE_CL73_HCD_MR 0x0001
+#define MDIO_XS_DEVAD			0x4
+#define MDIO_XS_PLL_SEQUENCER		0x8000
+#define MDIO_XS_SFX7101_XGXS_TEST1	0xc00a
 
-#define MDIO_REG_BANK_AER_BLOCK 			0xFFD0
-#define MDIO_AER_BLOCK_AER_REG				0x1E
+#define MDIO_AN_DEVAD			0x7
+/*ieee*/
+#define MDIO_AN_REG_CTRL		0x0000
+#define MDIO_AN_REG_STATUS		0x0001
+#define MDIO_AN_REG_STATUS_AN_COMPLETE		0x0020
+#define MDIO_AN_REG_ADV_PAUSE		0x0010
+#define MDIO_AN_REG_ADV_PAUSE_PAUSE		0x0400
+#define MDIO_AN_REG_ADV_PAUSE_ASYMMETRIC	0x0800
+#define MDIO_AN_REG_ADV_PAUSE_BOTH		0x0C00
+#define MDIO_AN_REG_ADV_PAUSE_MASK		0x0C00
+#define MDIO_AN_REG_ADV 		0x0011
+#define MDIO_AN_REG_ADV2		0x0012
+#define MDIO_AN_REG_LP_AUTO_NEG 	0x0013
+#define MDIO_AN_REG_MASTER_STATUS	0x0021
+/*bcm*/
+#define MDIO_AN_REG_LINK_STATUS 	0x8304
+#define MDIO_AN_REG_CL37_CL73		0x8370
+#define MDIO_AN_REG_CL37_AN		0xffe0
+#define MDIO_AN_REG_CL37_FD		0xffe4
 
-#define MDIO_REG_BANK_COMBO_IEEE0			0xFFE0
-#define MDIO_COMBO_IEEE0_MII_CONTROL			0x10
-#define MDIO_COMBO_IEEO_MII_CONTROL_MAN_SGMII_SP_MASK	0x2040
-#define MDIO_COMBO_IEEO_MII_CONTROL_MAN_SGMII_SP_10	0x0000
-#define MDIO_COMBO_IEEO_MII_CONTROL_MAN_SGMII_SP_100	0x2000
-#define MDIO_COMBO_IEEO_MII_CONTROL_MAN_SGMII_SP_1000	0x0040
-#define MDIO_COMBO_IEEO_MII_CONTROL_FULL_DUPLEX 	0x0100
-#define MDIO_COMBO_IEEO_MII_CONTROL_RESTART_AN		0x0200
-#define MDIO_COMBO_IEEO_MII_CONTROL_AN_EN		0x1000
-#define MDIO_COMBO_IEEO_MII_CONTROL_LOOPBACK		0x4000
-#define MDIO_COMBO_IEEO_MII_CONTROL_RESET		0x8000
-#define MDIO_COMBO_IEEE0_MII_STATUS			0x11
-#define MDIO_COMBO_IEEE0_MII_STATUS_LINK_PASS		0x0004
-#define MDIO_COMBO_IEEE0_MII_STATUS_AUTONEG_COMPLETE	0x0020
-#define MDIO_COMBO_IEEE0_AUTO_NEG_ADV			0x14
-#define MDIO_COMBO_IEEE0_AUTO_NEG_ADV_FULL_DUPLEX	0x0020
-#define MDIO_COMBO_IEEE0_AUTO_NEG_ADV_HALF_DUPLEX	0x0040
-#define MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_MASK	0x0180
-#define MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_NONE	0x0000
-#define MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_SYMMETRIC	0x0080
-#define MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_ASYMMETRIC	0x0100
-#define MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH	0x0180
-#define MDIO_COMBO_IEEE0_AUTO_NEG_ADV_NEXT_PAGE 	0x8000
-#define MDIO_COMBO_IEEE0_AUTO_NEG_LINK_PARTNER_ABILITY1 0x15
-#define MDIO_COMBO_IEEE0_AUTO_NEG_LINK_PARTNER_ABILITY1_NEXT_PAGE    0x8000
-#define MDIO_COMBO_IEEE0_AUTO_NEG_LINK_PARTNER_ABILITY1_ACK	     0x4000
-#define MDIO_COMBO_IEEE0_AUTO_NEG_LINK_PARTNER_ABILITY1_PAUSE_MASK   0x0180
-#define MDIO_COMBO_IEEE0_AUTO_NEG_LINK_PARTNER_ABILITY1_PAUSE_NONE\
-	0x0000
-#define MDIO_COMBO_IEEE0_AUTO_NEG_LINK_PARTNER_ABILITY1_PAUSE_BOTH\
-	0x0180
-#define MDIO_COMBO_IEEE0_AUTO_NEG_LINK_PARTNER_ABILITY1_HALF_DUP_CAP 0x0040
-#define MDIO_COMBO_IEEE0_AUTO_NEG_LINK_PARTNER_ABILITY1_FULL_DUP_CAP 0x0020
-#define MDIO_COMBO_IEEE0_AUTO_NEG_LINK_PARTNER_ABILITY1_SGMII_MODE   0x0001
 
+#define IGU_FUNC_BASE			0x0400
 
-#define EXT_PHY_AUTO_NEG_DEVAD				0x7
-#define EXT_PHY_OPT_PMA_PMD_DEVAD			0x1
-#define EXT_PHY_OPT_WIS_DEVAD				0x2
-#define EXT_PHY_OPT_PCS_DEVAD				0x3
-#define EXT_PHY_OPT_PHY_XS_DEVAD			0x4
-#define EXT_PHY_OPT_CNTL				0x0
-#define EXT_PHY_OPT_CNTL2				0x7
-#define EXT_PHY_OPT_PMD_RX_SD				0xa
-#define EXT_PHY_OPT_PMD_MISC_CNTL			0xca0a
-#define EXT_PHY_OPT_PHY_IDENTIFIER			0xc800
-#define EXT_PHY_OPT_PMD_DIGITAL_CNT			0xc808
-#define EXT_PHY_OPT_PMD_DIGITAL_SATUS			0xc809
-#define EXT_PHY_OPT_CMU_PLL_BYPASS			0xca09
-#define EXT_PHY_OPT_LASI_CNTL				0x9002
-#define EXT_PHY_OPT_RX_ALARM				0x9003
-#define EXT_PHY_OPT_LASI_STATUS 			0x9005
-#define EXT_PHY_OPT_PCS_STATUS				0x0020
-#define EXT_PHY_OPT_XGXS_LANE_STATUS			0x0018
-#define EXT_PHY_OPT_AN_LINK_STATUS			0x8304
-#define EXT_PHY_OPT_AN_CL37_CL73			0x8370
-#define EXT_PHY_OPT_AN_CL37_FD				0xffe4
-#define EXT_PHY_OPT_AN_CL37_AN				0xffe0
-#define EXT_PHY_OPT_AN_ADV				0x11
+#define IGU_ADDR_MSIX			0x0000
+#define IGU_ADDR_INT_ACK		0x0200
+#define IGU_ADDR_PROD_UPD		0x0201
+#define IGU_ADDR_ATTN_BITS_UPD	0x0202
+#define IGU_ADDR_ATTN_BITS_SET	0x0203
+#define IGU_ADDR_ATTN_BITS_CLR	0x0204
+#define IGU_ADDR_COALESCE_NOW	0x0205
+#define IGU_ADDR_SIMD_MASK		0x0206
+#define IGU_ADDR_SIMD_NOMASK	0x0207
+#define IGU_ADDR_MSI_CTL		0x0210
+#define IGU_ADDR_MSI_ADDR_LO	0x0211
+#define IGU_ADDR_MSI_ADDR_HI	0x0212
+#define IGU_ADDR_MSI_DATA		0x0213
 
-#define EXT_PHY_KR_PMA_PMD_DEVAD			0x1
-#define EXT_PHY_KR_PCS_DEVAD				0x3
-#define EXT_PHY_KR_AUTO_NEG_DEVAD			0x7
-#define EXT_PHY_KR_CTRL 				0x0000
-#define EXT_PHY_KR_STATUS				0x0001
-#define EXT_PHY_KR_AUTO_NEG_COMPLETE		    	0x0020
-#define EXT_PHY_KR_AUTO_NEG_ADVERT			0x0010
-#define EXT_PHY_KR_AUTO_NEG_ADVERT_PAUSE	    	0x0400
-#define EXT_PHY_KR_AUTO_NEG_ADVERT_PAUSE_ASYMMETRIC 	0x0800
-#define EXT_PHY_KR_AUTO_NEG_ADVERT_PAUSE_BOTH	    	0x0C00
-#define EXT_PHY_KR_AUTO_NEG_ADVERT_PAUSE_MASK	    	0x0C00
-#define EXT_PHY_KR_LP_AUTO_NEG				0x0013
-#define EXT_PHY_KR_CTRL2				0x0007
-#define EXT_PHY_KR_PCS_STATUS				0x0020
-#define EXT_PHY_KR_PMD_CTRL				0x0096
-#define EXT_PHY_KR_LASI_CNTL				0x9002
-#define EXT_PHY_KR_LASI_STATUS				0x9005
-#define EXT_PHY_KR_MISC_CTRL1				0xca85
-#define EXT_PHY_KR_GEN_CTRL				0xca10
-#define EXT_PHY_KR_ROM_CODE				0xca19
-#define EXT_PHY_KR_ROM_RESET_INTERNAL_MP		0x0188
-#define EXT_PHY_KR_ROM_MICRO_RESET			0x018a
+#define IGU_INT_ENABLE			0
+#define IGU_INT_DISABLE 		1
+#define IGU_INT_NOP				2
+#define IGU_INT_NOP2			3
 
-#define EXT_PHY_SFX7101_XGXS_TEST1	    0xc00a
 
-- 
1.5.5




