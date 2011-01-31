From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net-next 07/10] bnx2x: Add support for new PHY BCM84833
Date: Mon, 31 Jan 2011 16:22:41 +0200
Message-ID: <1296483761.17181.117.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3424 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755837Ab1AaOZh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jan 2011 09:25:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for new PHY BCM84833. This PHY is very similar to the BCM84823, only it has different register offset compared to the BCM84823, which needs to be handled correctly.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_hsi.h  |    1 +
 drivers/net/bnx2x/bnx2x_link.c |  110 ++++++++++++++++++++++++++++++----------
 2 files changed, 84 insertions(+), 27 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_hsi.h b/drivers/net/bnx2x/bnx2x_hsi.h
index 34e313c..7c35f4e 100644
--- a/drivers/net/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/bnx2x/bnx2x_hsi.h
@@ -459,6 +459,7 @@ struct port_hw_cfg {			    /* port 0: 0x12c  port 1: 0x2bc */
 #define PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727	    0x00000900
 #define PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727_NOC   0x00000a00
 #define PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84823	    0x00000b00
+#define PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833	    0x00000d00
 #define PORT_HW_CFG_XGXS_EXT_PHY_TYPE_FAILURE	    0x0000fd00
 #define PORT_HW_CFG_XGXS_EXT_PHY_TYPE_NOT_CONN	    0x0000ff00
 
diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index 6007dce..aeaeea1 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -6036,19 +6036,23 @@ static void bnx2x_8727_link_reset(struct bnx2x_phy *phy,
 static void bnx2x_save_848xx_spirom_version(struct bnx2x_phy *phy,
 					   struct link_params *params)
 {
-	u16 val, fw_ver1, fw_ver2, cnt;
+	u16 val, fw_ver1, fw_ver2, cnt, adj;
 	struct bnx2x *bp = params->bp;
 
+	adj = 0;
+	if (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833)
+		adj = -1;
+
 	/* For the 32 bits registers in 848xx, access via MDIO2ARM interface.*/
 	/* (1) set register 0xc200_0014(SPI_BRIDGE_CTRL_2) to 0x03000000 */
-	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA819, 0x0014);
-	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA81A, 0xc200);
-	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA81B, 0x0000);
-	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA81C, 0x0300);
-	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA817, 0x0009);
+	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA819 + adj, 0x0014);
+	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA81A + adj, 0xc200);
+	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA81B + adj, 0x0000);
+	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA81C + adj, 0x0300);
+	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA817 + adj, 0x0009);
 
 	for (cnt = 0; cnt < 100; cnt++) {
-		bnx2x_cl45_read(bp, phy, MDIO_PMA_DEVAD, 0xA818, &val);
+		bnx2x_cl45_read(bp, phy, MDIO_PMA_DEVAD, 0xA818 + adj, &val);
 		if (val & 1)
 			break;
 		udelay(5);
@@ -6062,11 +6066,11 @@ static void bnx2x_save_848xx_spirom_version(struct bnx2x_phy *phy,
 

 	/* 2) read register 0xc200_0000 (SPI_FW_STATUS) */
-	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA819, 0x0000);
-	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA81A, 0xc200);
-	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA817, 0x000A);
+	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA819 + adj, 0x0000);
+	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA81A + adj, 0xc200);
+	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA817 + adj, 0x000A);
 	for (cnt = 0; cnt < 100; cnt++) {
-		bnx2x_cl45_read(bp, phy, MDIO_PMA_DEVAD, 0xA818, &val);
+		bnx2x_cl45_read(bp, phy, MDIO_PMA_DEVAD, 0xA818 + adj, &val);
 		if (val & 1)
 			break;
 		udelay(5);
@@ -6079,9 +6083,9 @@ static void bnx2x_save_848xx_spirom_version(struct bnx2x_phy *phy,
 	}
 
 	/* lower 16 bits of the register SPI_FW_STATUS */
-	bnx2x_cl45_read(bp, phy, MDIO_PMA_DEVAD, 0xA81B, &fw_ver1);
+	bnx2x_cl45_read(bp, phy, MDIO_PMA_DEVAD, 0xA81B + adj, &fw_ver1);
 	/* upper 16 bits of register SPI_FW_STATUS */
-	bnx2x_cl45_read(bp, phy, MDIO_PMA_DEVAD, 0xA81C, &fw_ver2);
+	bnx2x_cl45_read(bp, phy, MDIO_PMA_DEVAD, 0xA81C + adj, &fw_ver2);
 
 	bnx2x_save_spirom_version(bp, params->port, (fw_ver2<<16) | fw_ver1,
 				  phy->ver_addr);
@@ -6090,49 +6094,53 @@ static void bnx2x_save_848xx_spirom_version(struct bnx2x_phy *phy,
 static void bnx2x_848xx_set_led(struct bnx2x *bp,
 				struct bnx2x_phy *phy)
 {
-	u16 val;
+	u16 val, adj;
+
+	adj = 0;
+	if (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833)
+		adj = -1;
 
 	/* PHYC_CTL_LED_CTL */
 	bnx2x_cl45_read(bp, phy,
 			MDIO_PMA_DEVAD,
-			MDIO_PMA_REG_8481_LINK_SIGNAL, &val);
+			MDIO_PMA_REG_8481_LINK_SIGNAL + adj, &val);
 	val &= 0xFE00;
 	val |= 0x0092;
 
 	bnx2x_cl45_write(bp, phy,
 			 MDIO_PMA_DEVAD,
-			 MDIO_PMA_REG_8481_LINK_SIGNAL, val);
+			 MDIO_PMA_REG_8481_LINK_SIGNAL + adj, val);
 
 	bnx2x_cl45_write(bp, phy,
 			 MDIO_PMA_DEVAD,
-			 MDIO_PMA_REG_8481_LED1_MASK,
+			 MDIO_PMA_REG_8481_LED1_MASK + adj,
 			 0x80);
 
 	bnx2x_cl45_write(bp, phy,
 			 MDIO_PMA_DEVAD,
-			 MDIO_PMA_REG_8481_LED2_MASK,
+			 MDIO_PMA_REG_8481_LED2_MASK + adj,
 			 0x18);
 
 	/* Select activity source by Tx and Rx, as suggested by PHY AE */
 	bnx2x_cl45_write(bp, phy,
 			 MDIO_PMA_DEVAD,
-			 MDIO_PMA_REG_8481_LED3_MASK,
+			 MDIO_PMA_REG_8481_LED3_MASK + adj,
 			 0x0006);
 
 	/* Select the closest activity blink rate to that in 10/100/1000 */
 	bnx2x_cl45_write(bp, phy,
 			MDIO_PMA_DEVAD,
-			MDIO_PMA_REG_8481_LED3_BLINK,
+			MDIO_PMA_REG_8481_LED3_BLINK + adj,
 			0);
 
 	bnx2x_cl45_read(bp, phy,
 			MDIO_PMA_DEVAD,
-			MDIO_PMA_REG_84823_CTL_LED_CTL_1, &val);
+			MDIO_PMA_REG_84823_CTL_LED_CTL_1 + adj, &val);
 	val |= MDIO_PMA_REG_84823_LED3_STRETCH_EN; /* stretch_en for LED3*/
 
 	bnx2x_cl45_write(bp, phy,
 			 MDIO_PMA_DEVAD,
-			 MDIO_PMA_REG_84823_CTL_LED_CTL_1, val);
+			 MDIO_PMA_REG_84823_CTL_LED_CTL_1 + adj, val);
 
 	/* 'Interrupt Mask' */
 	bnx2x_cl45_write(bp, phy,
@@ -6291,12 +6299,15 @@ static u8 bnx2x_848x3_config_init(struct bnx2x_phy *phy,
 {
 	struct bnx2x *bp = params->bp;
 	u8 port, initialize = 1;
-	u16 val;
+	u16 val, adj;
 	u16 temp;
 	u32 actual_phy_selection;
 	u8 rc = 0;
 
 	/* This is just for MDIO_CTL_REG_84823_MEDIA register. */
+	adj = 0;
+	if (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833)
+		adj = 3;
 
 	msleep(1);
 	if (CHIP_IS_E2(bp))
@@ -6321,7 +6332,7 @@ static u8 bnx2x_848x3_config_init(struct bnx2x_phy *phy,
 	/* Set dual-media configuration according to configuration */
 
 	bnx2x_cl45_read(bp, phy, MDIO_CTL_DEVAD,
-			MDIO_CTL_REG_84823_MEDIA, &val);
+			MDIO_CTL_REG_84823_MEDIA + adj, &val);
 	val &= ~(MDIO_CTL_REG_84823_MEDIA_MAC_MASK |
 		 MDIO_CTL_REG_84823_MEDIA_LINE_MASK |
 		 MDIO_CTL_REG_84823_MEDIA_COPPER_CORE_DOWN |
@@ -6354,7 +6365,7 @@ static u8 bnx2x_848x3_config_init(struct bnx2x_phy *phy,
 		val |= MDIO_CTL_REG_84823_MEDIA_FIBER_1G;
 
 	bnx2x_cl45_write(bp, phy, MDIO_CTL_DEVAD,
-			 MDIO_CTL_REG_84823_MEDIA, val);
+			 MDIO_CTL_REG_84823_MEDIA + adj, val);
 	DP(NETIF_MSG_LINK, "Multi_phy config = 0x%x, Media control = 0x%x\n",
 		   params->multi_phy_config, val);
 
@@ -6370,15 +6381,20 @@ static u8 bnx2x_848xx_read_status(struct bnx2x_phy *phy,
 				  struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
-	u16 val, val1, val2;
+	u16 val, val1, val2, adj;
 	u8 link_up = 0;
 
+	/* Reg offset adjustment for 84833 */
+	adj = 0;
+	if (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833)
+		adj = -1;
+
 	/* Check 10G-BaseT link status */
 	/* Check PMD signal ok */
 	bnx2x_cl45_read(bp, phy,
 			MDIO_AN_DEVAD, 0xFFFA, &val1);
 	bnx2x_cl45_read(bp, phy,
-			MDIO_PMA_DEVAD, MDIO_PMA_REG_8481_PMD_SIGNAL,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_8481_PMD_SIGNAL + adj,
 			&val2);
 	DP(NETIF_MSG_LINK, "BCM848xx: PMD_SIGNAL 1.a811 = 0x%x\n", val2);
 
@@ -7191,6 +7207,43 @@ static struct bnx2x_phy phy_84823 = {
 	.phy_specific_func = (phy_specific_func_t)NULL
 };
 
+static struct bnx2x_phy phy_84833 = {
+	.type		= PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833,
+	.addr		= 0xff,
+	.flags		= FLAGS_FAN_FAILURE_DET_REQ |
+			    FLAGS_REARM_LATCH_SIGNAL,
+	.def_md_devad	= 0,
+	.reserved	= 0,
+	.rx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
+	.tx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
+	.mdio_ctrl	= 0,
+	.supported	= (SUPPORTED_10baseT_Half |
+			   SUPPORTED_10baseT_Full |
+			   SUPPORTED_100baseT_Half |
+			   SUPPORTED_100baseT_Full |
+			   SUPPORTED_1000baseT_Full |
+			   SUPPORTED_10000baseT_Full |
+			   SUPPORTED_TP |
+			   SUPPORTED_Autoneg |
+			   SUPPORTED_Pause |
+			   SUPPORTED_Asym_Pause),
+	.media_type	= ETH_PHY_BASE_T,
+	.ver_addr	= 0,
+	.req_flow_ctrl	= 0,
+	.req_line_speed	= 0,
+	.speed_cap_mask	= 0,
+	.req_duplex	= 0,
+	.rsrv		= 0,
+	.config_init	= (config_init_t)bnx2x_848x3_config_init,
+	.read_status	= (read_status_t)bnx2x_848xx_read_status,
+	.link_reset	= (link_reset_t)bnx2x_848x3_link_reset,
+	.config_loopback = (config_loopback_t)NULL,
+	.format_fw_ver	= (format_fw_ver_t)bnx2x_848xx_format_ver,
+	.hw_reset	= (hw_reset_t)NULL,
+	.set_link_led	= (set_link_led_t)bnx2x_848xx_set_link_led,
+	.phy_specific_func = (phy_specific_func_t)NULL
+};
+
 /*****************************************************************/
 /*                                                               */
 /* Populate the phy according. Main function: bnx2x_populate_phy   */
@@ -7344,6 +7397,9 @@ static u8 bnx2x_populate_ext_phy(struct bnx2x *bp,
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84823:
 		*phy = phy_84823;
 		break;
+	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833:
+		*phy = phy_84833;
+		break;
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101:
 		*phy = phy_7101;
 		break;
-- 
1.7.1





