From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 22/41]bnx2x: Pre emphasis configuration
Date: Thu, 12 Feb 2009 20:37:14 +0200
Message-ID: <1234463834.1863.154.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2495 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758130AbZBLSpI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 13:45:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 22/41]bnx2x: Pre emphasis configuration
Supporting non-default pre-emphasis settings for the internal and some external
PHYs

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_hsi.h  |   45 +++++-----------
 drivers/net/bnx2x_link.c |  130 ++++++++++++++++++++++++++++++++++-----------
 drivers/net/bnx2x_link.h |    4 +-
 drivers/net/bnx2x_main.c |   31 +++++++++--
 drivers/net/bnx2x_reg.h  |   36 +++++++++++++
 5 files changed, 177 insertions(+), 69 deletions(-)

diff --git a/drivers/net/bnx2x_hsi.h b/drivers/net/bnx2x_hsi.h
index 7a62bfd..8452605 100644
--- a/drivers/net/bnx2x_hsi.h
+++ b/drivers/net/bnx2x_hsi.h
@@ -178,36 +178,21 @@ struct port_hw_cfg {			    /* port 0: 0x12c  port 1: 0x2bc */
 	u32 rdma_mac_lower;
 
 	u32 serdes_config;
-	/* for external PHY, or forced mode or during AN */
-#define PORT_HW_CFG_SERDES_TX_DRV_PRE_EMPHASIS_MASK 0xffff0000
-#define PORT_HW_CFG_SERDES_TX_DRV_PRE_EMPHASIS_SHIFT  16
-
-#define PORT_HW_CFG_SERDES_RX_DRV_EQUALIZER_MASK    0x0000ffff
-#define PORT_HW_CFG_SERDES_RX_DRV_EQUALIZER_SHIFT   0
-
-	u16 serdes_tx_driver_pre_emphasis[16];
-	u16 serdes_rx_driver_equalizer[16];
-
-	u32 xgxs_config_lane0;
-	u32 xgxs_config_lane1;
-	u32 xgxs_config_lane2;
-	u32 xgxs_config_lane3;
-	/* for external PHY, or forced mode or during AN */
-#define PORT_HW_CFG_XGXS_TX_DRV_PRE_EMPHASIS_MASK   0xffff0000
-#define PORT_HW_CFG_XGXS_TX_DRV_PRE_EMPHASIS_SHIFT  16
-
-#define PORT_HW_CFG_XGXS_RX_DRV_EQUALIZER_MASK	    0x0000ffff
-#define PORT_HW_CFG_XGXS_RX_DRV_EQUALIZER_SHIFT     0
-
-	u16 xgxs_tx_driver_pre_emphasis_lane0[16];
-	u16 xgxs_tx_driver_pre_emphasis_lane1[16];
-	u16 xgxs_tx_driver_pre_emphasis_lane2[16];
-	u16 xgxs_tx_driver_pre_emphasis_lane3[16];
-
-	u16 xgxs_rx_driver_equalizer_lane0[16];
-	u16 xgxs_rx_driver_equalizer_lane1[16];
-	u16 xgxs_rx_driver_equalizer_lane2[16];
-	u16 xgxs_rx_driver_equalizer_lane3[16];
+#define PORT_HW_CFG_SERDES_TX_DRV_PRE_EMPHASIS_MASK	      0x0000FFFF
+#define PORT_HW_CFG_SERDES_TX_DRV_PRE_EMPHASIS_SHIFT	      0
+
+#define PORT_HW_CFG_SERDES_RX_DRV_EQUALIZER_MASK	      0xFFFF0000
+#define PORT_HW_CFG_SERDES_RX_DRV_EQUALIZER_SHIFT	      16
+
+
+	u32 Reserved0[16];				    /* 0x158 */
+
+	/*  for external PHY, or forced mode or during AN */
+	u16 xgxs_config_rx[4];				    /* 0x198 */
+
+	u16 xgxs_config_tx[4];				    /* 0x1A0 */
+
+	u32 Reserved1[64];				    /* 0x1A8 */
 
 	u32 lane_config;
 #define PORT_HW_CFG_LANE_SWAP_CFG_MASK		    0x0000ffff
diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index b61a7a2..4a594b8 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -1758,33 +1758,39 @@ static void bnx2x_set_gmii_tx_driver(struct link_params *params)
 	struct bnx2x *bp = params->bp;
 	u16 lp_up2;
 	u16 tx_driver;
+	u16 bank;
 
 	/* read precomp */
-
 	CL45_RD_OVER_CL22(bp, params->port,
 			      params->phy_addr,
 			      MDIO_REG_BANK_OVER_1G,
 			      MDIO_OVER_1G_LP_UP2, &lp_up2);
 
-	CL45_RD_OVER_CL22(bp, params->port,
-			      params->phy_addr,
-			      MDIO_REG_BANK_TX0,
-			      MDIO_TX0_TX_DRIVER, &tx_driver);
-
 	/* bits [10:7] at lp_up2, positioned at [15:12] */
 	lp_up2 = (((lp_up2 & MDIO_OVER_1G_LP_UP2_PREEMPHASIS_MASK) >>
 		   MDIO_OVER_1G_LP_UP2_PREEMPHASIS_SHIFT) <<
 		  MDIO_TX0_TX_DRIVER_PREEMPHASIS_SHIFT);
 
-	if ((lp_up2 != 0) &&
-	    (lp_up2 != (tx_driver & MDIO_TX0_TX_DRIVER_PREEMPHASIS_MASK))) {
-		/* replace tx_driver bits [15:12] */
-		tx_driver &= ~MDIO_TX0_TX_DRIVER_PREEMPHASIS_MASK;
-		tx_driver |= lp_up2;
-		CL45_WR_OVER_CL22(bp, params->port,
+	if (lp_up2 == 0)
+		return;
+
+	for (bank = MDIO_REG_BANK_TX0; bank <= MDIO_REG_BANK_TX3;
+	      bank += (MDIO_REG_BANK_TX1 - MDIO_REG_BANK_TX0)) {
+		CL45_RD_OVER_CL22(bp, params->port,
 				      params->phy_addr,
-				      MDIO_REG_BANK_TX0,
-				      MDIO_TX0_TX_DRIVER, tx_driver);
+				      bank,
+				      MDIO_TX0_TX_DRIVER, &tx_driver);
+
+		/* replace tx_driver bits [15:12] */
+		if (lp_up2 !=
+		    (tx_driver & MDIO_TX0_TX_DRIVER_PREEMPHASIS_MASK)) {
+			tx_driver &= ~MDIO_TX0_TX_DRIVER_PREEMPHASIS_MASK;
+			tx_driver |= lp_up2;
+			CL45_WR_OVER_CL22(bp, params->port,
+					      params->phy_addr,
+					      bank,
+					      MDIO_TX0_TX_DRIVER, tx_driver);
+		}
 	}
 }
 
@@ -2890,31 +2896,40 @@ static void bnx2x_ext_phy_set_pause(struct link_params *params,
 		       MDIO_AN_DEVAD,
 		       MDIO_AN_REG_ADV_PAUSE, val);
 }
+static void bnx2x_set_preemphasis(struct link_params *params)
+{
+	u16 bank, i = 0;
+	struct bnx2x *bp = params->bp;
 
+	for (bank = MDIO_REG_BANK_RX0, i = 0; bank <= MDIO_REG_BANK_RX3;
+	      bank += (MDIO_REG_BANK_RX1-MDIO_REG_BANK_RX0), i++) {
+			CL45_WR_OVER_CL22(bp, params->port,
+					      params->phy_addr,
+					      bank,
+					      MDIO_RX0_RX_EQ_BOOST,
+					      params->xgxs_config_rx[i]);
+	}
+
+	for (bank = MDIO_REG_BANK_TX0, i = 0; bank <= MDIO_REG_BANK_TX3;
+		      bank += (MDIO_REG_BANK_TX1 - MDIO_REG_BANK_TX0), i++) {
+			CL45_WR_OVER_CL22(bp, params->port,
+					      params->phy_addr,
+					      bank,
+					      MDIO_TX0_TX_DRIVER,
+					      params->xgxs_config_tx[i]);
+	}
+}
 
 static void bnx2x_init_internal_phy(struct link_params *params,
 				struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
-	u8 port = params->port;
 	if (!(vars->phy_flags & PHY_SGMII_FLAG)) {
-		u16 bank, rx_eq;
-
-		rx_eq = ((params->serdes_config &
-			  PORT_HW_CFG_SERDES_RX_DRV_EQUALIZER_MASK) >>
-			 PORT_HW_CFG_SERDES_RX_DRV_EQUALIZER_SHIFT);
-
-		DP(NETIF_MSG_LINK, "setting rx eq to 0x%x\n", rx_eq);
-		for (bank = MDIO_REG_BANK_RX0; bank <= MDIO_REG_BANK_RX_ALL;
-		      bank += (MDIO_REG_BANK_RX1-MDIO_REG_BANK_RX0)) {
-			CL45_WR_OVER_CL22(bp, port,
-					      params->phy_addr,
-					      bank ,
-					      MDIO_RX0_RX_EQ_BOOST,
-					      ((rx_eq &
-				MDIO_RX0_RX_EQ_BOOST_EQUALIZER_CTRL_MASK) |
-				MDIO_RX0_RX_EQ_BOOST_OFFSET_CTRL));
-		}
+		if ((XGXS_EXT_PHY_TYPE(params->ext_phy_config) ==
+		     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT) &&
+		    (params->feature_config_flags &
+		     FEATURE_CONFIG_OVERRIDE_PREEMPHASIS_ENABLED))
+			bnx2x_set_preemphasis(params);
 
 		/* forced speed requested? */
 		if (vars->line_speed != SPEED_AUTO_NEG) {
@@ -3038,6 +3053,35 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 			}
 			DP(NETIF_MSG_LINK, "XGXS 8706 is initialized "
 				"after %d ms\n", cnt);
+			if ((params->feature_config_flags &
+			     FEATURE_CONFIG_OVERRIDE_PREEMPHASIS_ENABLED)) {
+				u8 i;
+				u16 reg;
+				for (i = 0; i < 4; i++) {
+					reg = MDIO_XS_8706_REG_BANK_RX0 +
+						i*(MDIO_XS_8706_REG_BANK_RX1 -
+						   MDIO_XS_8706_REG_BANK_RX0);
+					bnx2x_cl45_read(bp, params->port,
+						      ext_phy_type,
+						      ext_phy_addr,
+						      MDIO_XS_DEVAD,
+						      reg, &val);
+					/* Clear first 3 bits of the control */
+					val &= ~0x7;
+					/* Set control bits according to
+					configuation */
+					val |= (params->xgxs_config_rx[i] &
+						0x7);
+					DP(NETIF_MSG_LINK, "Setting RX"
+						 "Equalizer to BCM8706 reg 0x%x"
+						 " <-- val 0x%x\n", reg, val);
+					bnx2x_cl45_write(bp, params->port,
+						       ext_phy_type,
+						       ext_phy_addr,
+						       MDIO_XS_DEVAD,
+						       reg, val);
+				}
+			}
 			/* Force speed */
 			/* First enable LASI */
 			bnx2x_cl45_write(bp, params->port,
@@ -3170,6 +3214,28 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 					       ext_phy_addr, MDIO_PMA_DEVAD,
 					       MDIO_PMA_REG_LASI_CTRL, 1);
 			}
+
+			/* Set TX PreEmphasis if needed */
+			if ((params->feature_config_flags &
+			     FEATURE_CONFIG_OVERRIDE_PREEMPHASIS_ENABLED)) {
+				DP(NETIF_MSG_LINK, "Setting TX_CTRL1 0x%x,"
+					 "TX_CTRL2 0x%x\n",
+					 params->xgxs_config_tx[0],
+					 params->xgxs_config_tx[1]);
+				bnx2x_cl45_write(bp, params->port,
+					       ext_phy_type,
+					       ext_phy_addr,
+					       MDIO_PMA_DEVAD,
+					       MDIO_PMA_REG_8726_TX_CTRL1,
+					       params->xgxs_config_tx[0]);
+
+				bnx2x_cl45_write(bp, params->port,
+					       ext_phy_type,
+					       ext_phy_addr,
+					       MDIO_PMA_DEVAD,
+					       MDIO_PMA_REG_8726_TX_CTRL2,
+					       params->xgxs_config_tx[1]);
+			}
 			break;
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072:
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073:
diff --git a/drivers/net/bnx2x_link.h b/drivers/net/bnx2x_link.h
index 1318683..38254d0 100644
--- a/drivers/net/bnx2x_link.h
+++ b/drivers/net/bnx2x_link.h
@@ -77,7 +77,6 @@ struct link_params {
 #define SWITCH_CFG_AUTO_DETECT	PORT_FEATURE_CON_SWITCH_AUTO_DETECT
 
 	u16 hw_led_mode; /* part of the hw_config read from the shmem */
-	u32 serdes_config;
 	u32 lane_config;
 	u32 ext_phy_config;
 #define XGXS_EXT_PHY_TYPE(ext_phy_config)	(ext_phy_config & \
@@ -89,6 +88,9 @@ struct link_params {
 
 	/* phy_addr populated by the CLC */
 	u8 phy_addr;
+	u16 xgxs_config_rx[4]; /* preemphasis values for the rx side */
+
+	u16 xgxs_config_tx[4]; /* preemphasis values for the tx side */
 	u32 feature_config_flags;
 #define FEATURE_CONFIG_OVERRIDE_PREEMPHASIS_ENABLED (1<<0)
 #define FEATURE_CONFIG_MODULE_ENFORCMENT_ENABLED	(2<<0)
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 0d2d556..60a4e94 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -7550,6 +7550,15 @@ static void __devinit bnx2x_get_common_hwinfo(struct bnx2x *bp)
 					SHARED_HW_CFG_LED_MODE_MASK) >>
 				       SHARED_HW_CFG_LED_MODE_SHIFT);
 
+	bp->link_params.feature_config_flags = 0;
+	val = SHMEM_RD(bp, dev_info.shared_feature_config.config);
+	if (val & SHARED_FEAT_CFG_OVERRIDE_PREEMPHASIS_CFG_ENABLED)
+		bp->link_params.feature_config_flags |=
+				FEATURE_CONFIG_OVERRIDE_PREEMPHASIS_ENABLED;
+	else
+		bp->link_params.feature_config_flags &=
+				~FEATURE_CONFIG_OVERRIDE_PREEMPHASIS_ENABLED;
+
 	val = SHMEM_RD(bp, dev_info.bc_rev) >> 8;
 	bp->common.bc_ver = val;
 	BNX2X_DEV_INFO("bc_ver %X\n", val);
@@ -7972,12 +7981,11 @@ static void __devinit bnx2x_get_port_hwinfo(struct bnx2x *bp)
 	int port = BP_PORT(bp);
 	u32 val, val2;
 	u32 config;
+	u16 i;
 
 	bp->link_params.bp = bp;
 	bp->link_params.port = port;
 
-	bp->link_params.serdes_config =
-		SHMEM_RD(bp, dev_info.port_hw_config[port].serdes_config);
 	bp->link_params.lane_config =
 		SHMEM_RD(bp, dev_info.port_hw_config[port].lane_config);
 	bp->link_params.ext_phy_config =
@@ -7990,6 +7998,19 @@ static void __devinit bnx2x_get_port_hwinfo(struct bnx2x *bp)
 	bp->port.link_config =
 		SHMEM_RD(bp, dev_info.port_feature_config[port].link_config);
 
+	/* Get the 4 lanes xgxs config rx and tx */
+	for (i = 0; i < 2; i++) {
+		val = SHMEM_RD(bp,
+			   dev_info.port_hw_config[port].xgxs_config_rx[i<<1]);
+		bp->link_params.xgxs_config_rx[i << 1] = ((val>>16) & 0xffff);
+		bp->link_params.xgxs_config_rx[(i << 1) + 1] = (val & 0xffff);
+
+		val = SHMEM_RD(bp,
+			   dev_info.port_hw_config[port].xgxs_config_tx[i<<1]);
+		bp->link_params.xgxs_config_tx[i << 1] = ((val>>16) & 0xffff);
+		bp->link_params.xgxs_config_tx[(i << 1) + 1] = (val & 0xffff);
+	}
+
 	config = SHMEM_RD(bp, dev_info.port_feature_config[port].config);
 	if (config & PORT_FEAT_CFG_OPT_MDL_ENFRCMNT_ENABLED)
 		bp->link_params.feature_config_flags |=
@@ -7998,10 +8019,8 @@ static void __devinit bnx2x_get_port_hwinfo(struct bnx2x *bp)
 		bp->link_params.feature_config_flags &=
 				~FEATURE_CONFIG_MODULE_ENFORCMENT_ENABLED;
 
-	BNX2X_DEV_INFO("serdes_config 0x%08x  lane_config 0x%08x\n"
-	     KERN_INFO "  ext_phy_config 0x%08x  speed_cap_mask 0x%08x"
-		       "  link_config 0x%08x\n",
-		       bp->link_params.serdes_config,
+	BNX2X_DEV_INFO("lane_config 0x%08x  ext_phy_config 0x%08x"
+		       "  speed_cap_mask 0x%08x  link_config 0x%08x\n",
 		       bp->link_params.lane_config,
 		       bp->link_params.ext_phy_config,
 		       bp->link_params.speed_cap_mask, bp->port.link_config);
diff --git a/drivers/net/bnx2x_reg.h b/drivers/net/bnx2x_reg.h
index d3086e9..08e703d 100644
--- a/drivers/net/bnx2x_reg.h
+++ b/drivers/net/bnx2x_reg.h
@@ -5603,6 +5603,42 @@
 #define MDIO_TX0_TX_DRIVER_IFULLSPD_SHIFT		1
 #define MDIO_TX0_TX_DRIVER_ICBUF1T			1
 
+#define MDIO_REG_BANK_TX1				0x8070
+#define MDIO_TX1_TX_DRIVER				0x17
+#define MDIO_TX0_TX_DRIVER_PREEMPHASIS_MASK		0xf000
+#define MDIO_TX0_TX_DRIVER_PREEMPHASIS_SHIFT		12
+#define MDIO_TX0_TX_DRIVER_IDRIVER_MASK 		0x0f00
+#define MDIO_TX0_TX_DRIVER_IDRIVER_SHIFT		8
+#define MDIO_TX0_TX_DRIVER_IPREDRIVER_MASK		0x00f0
+#define MDIO_TX0_TX_DRIVER_IPREDRIVER_SHIFT		4
+#define MDIO_TX0_TX_DRIVER_IFULLSPD_MASK		0x000e
+#define MDIO_TX0_TX_DRIVER_IFULLSPD_SHIFT		1
+#define MDIO_TX0_TX_DRIVER_ICBUF1T			1
+
+#define MDIO_REG_BANK_TX2				0x8080
+#define MDIO_TX2_TX_DRIVER				0x17
+#define MDIO_TX0_TX_DRIVER_PREEMPHASIS_MASK		0xf000
+#define MDIO_TX0_TX_DRIVER_PREEMPHASIS_SHIFT		12
+#define MDIO_TX0_TX_DRIVER_IDRIVER_MASK 		0x0f00
+#define MDIO_TX0_TX_DRIVER_IDRIVER_SHIFT		8
+#define MDIO_TX0_TX_DRIVER_IPREDRIVER_MASK		0x00f0
+#define MDIO_TX0_TX_DRIVER_IPREDRIVER_SHIFT		4
+#define MDIO_TX0_TX_DRIVER_IFULLSPD_MASK		0x000e
+#define MDIO_TX0_TX_DRIVER_IFULLSPD_SHIFT		1
+#define MDIO_TX0_TX_DRIVER_ICBUF1T			1
+
+#define MDIO_REG_BANK_TX3				0x8090
+#define MDIO_TX3_TX_DRIVER				0x17
+#define MDIO_TX0_TX_DRIVER_PREEMPHASIS_MASK		0xf000
+#define MDIO_TX0_TX_DRIVER_PREEMPHASIS_SHIFT		12
+#define MDIO_TX0_TX_DRIVER_IDRIVER_MASK 		0x0f00
+#define MDIO_TX0_TX_DRIVER_IDRIVER_SHIFT		8
+#define MDIO_TX0_TX_DRIVER_IPREDRIVER_MASK		0x00f0
+#define MDIO_TX0_TX_DRIVER_IPREDRIVER_SHIFT		4
+#define MDIO_TX0_TX_DRIVER_IFULLSPD_MASK		0x000e
+#define MDIO_TX0_TX_DRIVER_IFULLSPD_SHIFT		1
+#define MDIO_TX0_TX_DRIVER_ICBUF1T			1
+
 #define MDIO_REG_BANK_XGXS_BLOCK0			0x8000
 #define MDIO_BLOCK0_XGXS_CONTROL			0x10
 
-- 
1.5.4.3




