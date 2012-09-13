From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net-next PATCH 1/3] bnx2x: link code refactoring
Date: Thu, 13 Sep 2012 15:56:19 +0300
Message-ID: <1347540981-16198-2-git-send-email-yuvalmin@broadcom.com>
References: <1347540981-16198-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yaniv Rosner" <yaniv.rosner@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3281 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751254Ab2IMNVD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Sep 2012 09:21:03 -0400
In-Reply-To: <1347540981-16198-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yaniv Rosner <yaniv.rosner@broadcom.com>

Separate the interrupt setting part of each external PHY to a specific
function.
This allows calling the interrupt setting in case of link-flap avoidance,
since some link owners may not enable the interrupt on their own.

Signed-off-by: Yaniv Rosner <yaniv.rosner@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |  192 +++++++++++++---------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h |    1 +
 2 files changed, 114 insertions(+), 79 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index f4beb46..05620ef 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -7203,6 +7203,22 @@ static void bnx2x_8073_set_pause_cl37(struct link_params *params,
 	msleep(500);
 }
 
+static void bnx2x_8073_specific_func(struct bnx2x_phy *phy,
+				     struct link_params *params,
+				     u32 action)
+{
+	struct bnx2x *bp = params->bp;
+	switch (action) {
+	case PHY_INIT:
+		/* Enable LASI */
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_PMA_DEVAD, MDIO_PMA_LASI_RXCTRL, (1<<2));
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_PMA_DEVAD, MDIO_PMA_LASI_CTRL,  0x0004);
+		break;
+	}
+}
+
 static int bnx2x_8073_config_init(struct bnx2x_phy *phy,
 				  struct link_params *params,
 				  struct link_vars *vars)
@@ -7223,12 +7239,7 @@ static int bnx2x_8073_config_init(struct bnx2x_phy *phy,
 	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_1,
 		       MISC_REGISTERS_GPIO_OUTPUT_HIGH, gpio_port);
 
-	/* Enable LASI */
-	bnx2x_cl45_write(bp, phy,
-			 MDIO_PMA_DEVAD, MDIO_PMA_LASI_RXCTRL, (1<<2));
-	bnx2x_cl45_write(bp, phy,
-			 MDIO_PMA_DEVAD, MDIO_PMA_LASI_CTRL,  0x0004);
-
+	bnx2x_8073_specific_func(phy, params, PHY_INIT);
 	bnx2x_8073_set_pause_cl37(params, phy, vars);
 
 	bnx2x_cl45_read(bp, phy,
@@ -8263,7 +8274,7 @@ static void bnx2x_8727_specific_func(struct bnx2x_phy *phy,
 				     u32 action)
 {
 	struct bnx2x *bp = params->bp;
-
+	u16 val;
 	switch (action) {
 	case DISABLE_TX:
 		bnx2x_sfp_set_transmitter(params, phy, 0);
@@ -8272,6 +8283,40 @@ static void bnx2x_8727_specific_func(struct bnx2x_phy *phy,
 		if (!(phy->flags & FLAGS_SFP_NOT_APPROVED))
 			bnx2x_sfp_set_transmitter(params, phy, 1);
 		break;
+	case PHY_INIT:
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_PMA_DEVAD, MDIO_PMA_LASI_RXCTRL,
+				 (1<<2) | (1<<5));
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_PMA_DEVAD, MDIO_PMA_LASI_TXCTRL,
+				 0);
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_PMA_DEVAD, MDIO_PMA_LASI_CTRL, 0x0006);
+		/* Make MOD_ABS give interrupt on change */
+		bnx2x_cl45_read(bp, phy, MDIO_PMA_DEVAD,
+				MDIO_PMA_REG_8727_PCS_OPT_CTRL,
+				&val);
+		val |= (1<<12);
+		if (phy->flags & FLAGS_NOC)
+			val |= (3<<5);
+		/* Set 8727 GPIOs to input to allow reading from the 8727 GPIO0
+		 * status which reflect SFP+ module over-current
+		 */
+		if (!(phy->flags & FLAGS_NOC))
+			val &= 0xff8f; /* Reset bits 4-6 */
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_PMA_DEVAD, MDIO_PMA_REG_8727_PCS_OPT_CTRL,
+				 val);
+
+		/* Set 2-wire transfer rate of SFP+ module EEPROM
+		 * to 100Khz since some DACs(direct attached cables) do
+		 * not work at 400Khz.
+		 */
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_PMA_DEVAD,
+				 MDIO_PMA_REG_8727_TWO_WIRE_SLAVE_ADDR,
+				 0xa001);
+		break;
 	default:
 		DP(NETIF_MSG_LINK, "Function 0x%x not supported by 8727\n",
 		   action);
@@ -9054,28 +9099,15 @@ static int bnx2x_8727_config_init(struct bnx2x_phy *phy,
 				  struct link_vars *vars)
 {
 	u32 tx_en_mode;
-	u16 tmp1, val, mod_abs, tmp2;
-	u16 rx_alarm_ctrl_val;
-	u16 lasi_ctrl_val;
+	u16 tmp1, mod_abs, tmp2;
 	struct bnx2x *bp = params->bp;
 	/* Enable PMD link, MOD_ABS_FLT, and 1G link alarm */
 
 	bnx2x_wait_reset_complete(bp, phy, params);
-	rx_alarm_ctrl_val = (1<<2) | (1<<5) ;
-	/* Should be 0x6 to enable XS on Tx side. */
-	lasi_ctrl_val = 0x0006;
 
 	DP(NETIF_MSG_LINK, "Initializing BCM8727\n");
-	/* Enable LASI */
-	bnx2x_cl45_write(bp, phy,
-			 MDIO_PMA_DEVAD, MDIO_PMA_LASI_RXCTRL,
-			 rx_alarm_ctrl_val);
-	bnx2x_cl45_write(bp, phy,
-			 MDIO_PMA_DEVAD, MDIO_PMA_LASI_TXCTRL,
-			 0);
-	bnx2x_cl45_write(bp, phy,
-			 MDIO_PMA_DEVAD, MDIO_PMA_LASI_CTRL, lasi_ctrl_val);
 
+	bnx2x_8727_specific_func(phy, params, PHY_INIT);
 	/* Initially configure MOD_ABS to interrupt when module is
 	 * presence( bit 8)
 	 */
@@ -9091,25 +9123,9 @@ static int bnx2x_8727_config_init(struct bnx2x_phy *phy,
 	bnx2x_cl45_write(bp, phy,
 			 MDIO_PMA_DEVAD, MDIO_PMA_REG_PHY_IDENTIFIER, mod_abs);
 
-
 	/* Enable/Disable PHY transmitter output */
 	bnx2x_set_disable_pmd_transmit(params, phy, 0);
 
-	/* Make MOD_ABS give interrupt on change */
-	bnx2x_cl45_read(bp, phy, MDIO_PMA_DEVAD, MDIO_PMA_REG_8727_PCS_OPT_CTRL,
-			&val);
-	val |= (1<<12);
-	if (phy->flags & FLAGS_NOC)
-		val |= (3<<5);
-
-	/* Set 8727 GPIOs to input to allow reading from the 8727 GPIO0
-	 * status which reflect SFP+ module over-current
-	 */
-	if (!(phy->flags & FLAGS_NOC))
-		val &= 0xff8f; /* Reset bits 4-6 */
-	bnx2x_cl45_write(bp, phy,
-			 MDIO_PMA_DEVAD, MDIO_PMA_REG_8727_PCS_OPT_CTRL, val);
-
 	bnx2x_8727_power_module(bp, phy, 1);
 
 	bnx2x_cl45_read(bp, phy,
@@ -9119,13 +9135,7 @@ static int bnx2x_8727_config_init(struct bnx2x_phy *phy,
 			MDIO_PMA_DEVAD, MDIO_PMA_LASI_RXSTAT, &tmp1);
 
 	bnx2x_8727_config_speed(phy, params);
-	/* Set 2-wire transfer rate of SFP+ module EEPROM
-	 * to 100Khz since some DACs(direct attached cables) do
-	 * not work at 400Khz.
-	 */
-	bnx2x_cl45_write(bp, phy,
-			 MDIO_PMA_DEVAD, MDIO_PMA_REG_8727_TWO_WIRE_SLAVE_ADDR,
-			 0xa001);
+
 
 	/* Set TX PreEmphasis if needed */
 	if ((params->feature_config_flags &
@@ -9554,6 +9564,29 @@ static void bnx2x_848xx_set_led(struct bnx2x *bp,
 			 0xFFFB, 0xFFFD);
 }
 
+static void bnx2x_848xx_specific_func(struct bnx2x_phy *phy,
+				      struct link_params *params,
+				      u32 action)
+{
+	struct bnx2x *bp = params->bp;
+	switch (action) {
+	case PHY_INIT:
+		if (phy->type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833) {
+			/* Save spirom version */
+			bnx2x_save_848xx_spirom_version(phy, bp, params->port);
+		}
+		/* This phy uses the NIG latch mechanism since link indication
+		 * arrives through its LED4 and not via its LASI signal, so we
+		 * get steady signal instead of clear on read
+		 */
+		bnx2x_bits_en(bp, NIG_REG_LATCH_BC_0 + params->port*4,
+			      1 << NIG_LATCH_BC_ENABLE_MI_INT);
+
+		bnx2x_848xx_set_led(bp, phy);
+		break;
+	}
+}
+
 static int bnx2x_848xx_cmn_config_init(struct bnx2x_phy *phy,
 				       struct link_params *params,
 				       struct link_vars *vars)
@@ -9561,22 +9594,10 @@ static int bnx2x_848xx_cmn_config_init(struct bnx2x_phy *phy,
 	struct bnx2x *bp = params->bp;
 	u16 autoneg_val, an_1000_val, an_10_100_val, an_10g_val;
 
-	if (phy->type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833) {
-		/* Save spirom version */
-		bnx2x_save_848xx_spirom_version(phy, bp, params->port);
-	}
-	/* This phy uses the NIG latch mechanism since link indication
-	 * arrives through its LED4 and not via its LASI signal, so we
-	 * get steady signal instead of clear on read
-	 */
-	bnx2x_bits_en(bp, NIG_REG_LATCH_BC_0 + params->port*4,
-		      1 << NIG_LATCH_BC_ENABLE_MI_INT);
-
+	bnx2x_848xx_specific_func(phy, params, PHY_INIT);
 	bnx2x_cl45_write(bp, phy,
 			 MDIO_PMA_DEVAD, MDIO_PMA_REG_CTRL, 0x0000);
 
-	bnx2x_848xx_set_led(bp, phy);
-
 	/* set 1000 speed advertisement */
 	bnx2x_cl45_read(bp, phy,
 			MDIO_AN_DEVAD, MDIO_AN_REG_8481_1000T_CTRL,
@@ -10565,6 +10586,35 @@ static void bnx2x_848xx_set_link_led(struct bnx2x_phy *phy,
 /******************************************************************/
 /*			54618SE PHY SECTION			  */
 /******************************************************************/
+static void bnx2x_54618se_specific_func(struct bnx2x_phy *phy,
+					struct link_params *params,
+					u32 action)
+{
+	struct bnx2x *bp = params->bp;
+	u16 temp;
+	switch (action) {
+	case PHY_INIT:
+		/* Configure LED4: set to INTR (0x6). */
+		/* Accessing shadow register 0xe. */
+		bnx2x_cl22_write(bp, phy,
+				 MDIO_REG_GPHY_SHADOW,
+				 MDIO_REG_GPHY_SHADOW_LED_SEL2);
+		bnx2x_cl22_read(bp, phy,
+				MDIO_REG_GPHY_SHADOW,
+				&temp);
+		temp &= ~(0xf << 4);
+		temp |= (0x6 << 4);
+		bnx2x_cl22_write(bp, phy,
+				 MDIO_REG_GPHY_SHADOW,
+				 MDIO_REG_GPHY_SHADOW_WR_ENA | temp);
+		/* Configure INTR based on link status change. */
+		bnx2x_cl22_write(bp, phy,
+				 MDIO_REG_INTR_MASK,
+				 ~MDIO_REG_INTR_MASK_LINK_STATUS);
+		break;
+	}
+}
+
 static int bnx2x_54618se_config_init(struct bnx2x_phy *phy,
 					       struct link_params *params,
 					       struct link_vars *vars)
@@ -10602,24 +10652,8 @@ static int bnx2x_54618se_config_init(struct bnx2x_phy *phy,
 	/* Wait for GPHY to reset */
 	msleep(50);
 
-	/* Configure LED4: set to INTR (0x6). */
-	/* Accessing shadow register 0xe. */
-	bnx2x_cl22_write(bp, phy,
-			MDIO_REG_GPHY_SHADOW,
-			MDIO_REG_GPHY_SHADOW_LED_SEL2);
-	bnx2x_cl22_read(bp, phy,
-			MDIO_REG_GPHY_SHADOW,
-			&temp);
-	temp &= ~(0xf << 4);
-	temp |= (0x6 << 4);
-	bnx2x_cl22_write(bp, phy,
-			MDIO_REG_GPHY_SHADOW,
-			MDIO_REG_GPHY_SHADOW_WR_ENA | temp);
-	/* Configure INTR based on link status change. */
-	bnx2x_cl22_write(bp, phy,
-			MDIO_REG_INTR_MASK,
-			~MDIO_REG_INTR_MASK_LINK_STATUS);
 
+	bnx2x_54618se_specific_func(phy, params, PHY_INIT);
 	/* Flip the signal detect polarity (set 0x1c.0x1e[8]). */
 	bnx2x_cl22_write(bp, phy,
 			MDIO_REG_GPHY_SHADOW,
@@ -11349,7 +11383,7 @@ static struct bnx2x_phy phy_8073 = {
 	.format_fw_ver	= (format_fw_ver_t)bnx2x_format_ver,
 	.hw_reset	= (hw_reset_t)NULL,
 	.set_link_led	= (set_link_led_t)NULL,
-	.phy_specific_func = (phy_specific_func_t)NULL
+	.phy_specific_func = (phy_specific_func_t)bnx2x_8073_specific_func
 };
 static struct bnx2x_phy phy_8705 = {
 	.type		= PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705,
@@ -11542,7 +11576,7 @@ static struct bnx2x_phy phy_84823 = {
 	.format_fw_ver	= (format_fw_ver_t)bnx2x_848xx_format_ver,
 	.hw_reset	= (hw_reset_t)NULL,
 	.set_link_led	= (set_link_led_t)bnx2x_848xx_set_link_led,
-	.phy_specific_func = (phy_specific_func_t)NULL
+	.phy_specific_func = (phy_specific_func_t)bnx2x_848xx_specific_func
 };
 
 static struct bnx2x_phy phy_84833 = {
@@ -11578,7 +11612,7 @@ static struct bnx2x_phy phy_84833 = {
 	.format_fw_ver	= (format_fw_ver_t)bnx2x_848xx_format_ver,
 	.hw_reset	= (hw_reset_t)bnx2x_84833_hw_reset_phy,
 	.set_link_led	= (set_link_led_t)bnx2x_848xx_set_link_led,
-	.phy_specific_func = (phy_specific_func_t)NULL
+	.phy_specific_func = (phy_specific_func_t)bnx2x_848xx_specific_func
 };
 
 static struct bnx2x_phy phy_54618se = {
@@ -11612,7 +11646,7 @@ static struct bnx2x_phy phy_54618se = {
 	.format_fw_ver	= (format_fw_ver_t)NULL,
 	.hw_reset	= (hw_reset_t)NULL,
 	.set_link_led	= (set_link_led_t)bnx2x_5461x_set_link_led,
-	.phy_specific_func = (phy_specific_func_t)NULL
+	.phy_specific_func = (phy_specific_func_t)bnx2x_54618se_specific_func
 };
 /*****************************************************************/
 /*                                                               */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
index 51cac81..600ffda 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
@@ -216,6 +216,7 @@ struct bnx2x_phy {
 	phy_specific_func_t phy_specific_func;
 #define DISABLE_TX	1
 #define ENABLE_TX	2
+#define PHY_INIT	3
 };
 
 /* Inputs parameters to the CLC */
-- 
1.7.9.rc2
