From: "Yaniv Rosner" <yaniv.rosner@broadcom.com>
Subject: [PATCH net-next 09/10] bnx2x: Change LED scheme for dual-media
Date: Wed, 8 Sep 2010 00:41:23 +0300
Message-ID: <1283895683.5452.69.camel@lb-tlvb-yanivr.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3992 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932457Ab0IGSXP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Sep 2010 14:23:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change LED scheme for dual-media

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com> 
---
 drivers/net/bnx2x/bnx2x_ethtool.c |    9 +-
 drivers/net/bnx2x/bnx2x_hsi.h     |    2 +
 drivers/net/bnx2x/bnx2x_link.c    |  345 +++++++++++++++++++++++++++++++++----
 drivers/net/bnx2x/bnx2x_link.h    |    9 +-
 drivers/net/bnx2x/bnx2x_reg.h     |   17 +-
 5 files changed, 336 insertions(+), 46 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_ethtool.c b/drivers/net/bnx2x/bnx2x_ethtool.c
index d058f97..6f939c5 100644
--- a/drivers/net/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/bnx2x/bnx2x_ethtool.c
@@ -1954,10 +1954,11 @@ static int bnx2x_phys_id(struct net_device *dev, u32 data)
 
 	for (i = 0; i < (data * 2); i++) {
 		if ((i % 2) == 0)
-			bnx2x_set_led(&bp->link_params, LED_MODE_OPER,
-				      SPEED_1000);
+			bnx2x_set_led(&bp->link_params, &bp->link_vars,
+				      LED_MODE_OPER, SPEED_1000);
 		else
-			bnx2x_set_led(&bp->link_params, LED_MODE_OFF, 0);
+			bnx2x_set_led(&bp->link_params, &bp->link_vars,
+				      LED_MODE_OFF, 0);
 
 		msleep_interruptible(500);
 		if (signal_pending(current))
@@ -1965,7 +1966,7 @@ static int bnx2x_phys_id(struct net_device *dev, u32 data)
 	}
 
 	if (bp->link_vars.link_up)
-		bnx2x_set_led(&bp->link_params, LED_MODE_OPER,
+		bnx2x_set_led(&bp->link_params, &bp->link_vars, LED_MODE_OPER,
 			      bp->link_vars.line_speed);
 
 	return 0;
diff --git a/drivers/net/bnx2x/bnx2x_hsi.h b/drivers/net/bnx2x/bnx2x_hsi.h
index bab3b2d..60d141c 100644
--- a/drivers/net/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/bnx2x/bnx2x_hsi.h
@@ -78,6 +78,8 @@ struct shared_hw_cfg {					 /* NVRAM Offset */
 #define SHARED_HW_CFG_LED_PHY11 		    0x000b0000
 #define SHARED_HW_CFG_LED_MAC4			    0x000c0000
 #define SHARED_HW_CFG_LED_PHY8			    0x000d0000
+#define SHARED_HW_CFG_LED_EXTPHY1		    0x000e0000
+
 
 #define SHARED_HW_CFG_AN_ENABLE_MASK		    0x3f000000
 #define SHARED_HW_CFG_AN_ENABLE_SHIFT		    24
diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index f095dbb..33cb785 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -976,7 +976,6 @@ void bnx2x_link_status_update(struct link_params *params,
 			default:
 				break;
 		}
-
 		vars->flow_ctrl = 0;
 		if (vars->link_status & LINK_STATUS_TX_FLOW_CONTROL_ENABLED)
 			vars->flow_ctrl |= BNX2X_FLOW_CTRL_TX;
@@ -1561,7 +1560,6 @@ static void bnx2x_pause_resolve(struct link_vars *vars, u32 pause_result)
 		vars->link_status |= LINK_STATUS_LINK_PARTNER_SYMMETRIC_PAUSE;
 	if (pause_result & (1<<1))
 		vars->link_status |= LINK_STATUS_LINK_PARTNER_ASYMMETRIC_PAUSE;
-
 }
 
 static u8 bnx2x_direct_parallel_detect_used(struct bnx2x_phy *phy,
@@ -1755,6 +1753,7 @@ static u8 bnx2x_link_settings_status(struct bnx2x_phy *phy,
 				MDIO_REG_BANK_GP_STATUS,
 				MDIO_GP_STATUS_TOP_AN_STATUS1,
 				&gp_status);
+
 	if (phy->req_line_speed == SPEED_AUTO_NEG)
 		vars->link_status |= LINK_STATUS_AUTO_NEGOTIATE_ENABLED;
 	if (gp_status & MDIO_GP_STATUS_TOP_AN_STATUS1_LINK_STATUS) {
@@ -1858,7 +1857,6 @@ static u8 bnx2x_link_settings_status(struct bnx2x_phy *phy,
 
 		vars->line_speed = new_line_speed;
 
-
 	} else { /* link_down */
 		DP(NETIF_MSG_LINK, "phy link down\n");
 
@@ -1964,7 +1962,7 @@ static u8 bnx2x_emac_program(struct link_params *params,
 		    GRCBASE_EMAC0 + port*0x400 + EMAC_REG_EMAC_MODE,
 		    mode);
 
-	bnx2x_set_led(params, LED_MODE_OPER, vars->line_speed);
+	bnx2x_set_led(params, vars, LED_MODE_OPER, vars->line_speed);
 	return 0;
 }
 
@@ -2187,7 +2185,7 @@ static void bnx2x_rearm_latch_signal(struct bnx2x *bp, u8 port,
 
 		/* For all latched-signal=up : Re-Arm Latch signals */
 		REG_WR(bp, NIG_REG_LATCH_STATUS_0 + port*8,
-			   (latch_status & 0xfffe) | (latch_status & 1));
+			     (latch_status & 0xfffe) | (latch_status & 1));
 	}
 	/* For all latched-signal=up,Write original_signal to status */
 }
@@ -2496,18 +2494,29 @@ u8 bnx2x_override_led_value(struct bnx2x *bp, u8 port,
 	return 0;
 }
 
-u8 bnx2x_set_led(struct link_params *params, u8 mode, u32 speed)
+
+u8 bnx2x_set_led(struct link_params *params,
+		 struct link_vars *vars, u8 mode, u32 speed)
 {
 	u8 port = params->port;
 	u16 hw_led_mode = params->hw_led_mode;
-	u8 rc = 0;
+	u8 rc = 0, phy_idx;
 	u32 tmp;
 	u32 emac_base = port ? GRCBASE_EMAC1 : GRCBASE_EMAC0;
 	struct bnx2x *bp = params->bp;
 	DP(NETIF_MSG_LINK, "bnx2x_set_led: port %x, mode %d\n", port, mode);
 	DP(NETIF_MSG_LINK, "speed 0x%x, hw_led_mode 0x%x\n",
 		 speed, hw_led_mode);
+	/* In case */
+	for (phy_idx = EXT_PHY1; phy_idx < MAX_PHYS; phy_idx++) {
+		if (params->phy[phy_idx].set_link_led) {
+			params->phy[phy_idx].set_link_led(
+				&params->phy[phy_idx], params, mode);
+		}
+	}
+
 	switch (mode) {
+	case LED_MODE_FRONT_PANEL_OFF:
 	case LED_MODE_OFF:
 		REG_WR(bp, NIG_REG_LED_10G_P0 + port*4, 0);
 		REG_WR(bp, NIG_REG_LED_MODE_P0 + port*4,
@@ -2518,7 +2527,18 @@ u8 bnx2x_set_led(struct link_params *params, u8 mode, u32 speed)
 		break;
 
 	case LED_MODE_OPER:
+		/**
+		 * For all other phys, OPER mode is same as ON, so in case
+		 * link is down, do nothing
+		 **/
+		if (!vars->link_up)
+			break;
+	case LED_MODE_ON:
 		if (SINGLE_MEDIA_DIRECT(params)) {
+			/**
+			* This is a work-around for HW issue found when link
+			* is up in CL73
+			*/
 			REG_WR(bp, NIG_REG_LED_MODE_P0 + port*4, 0);
 			REG_WR(bp, NIG_REG_LED_10G_P0 + port*4, 1);
 		} else {
@@ -2718,7 +2738,7 @@ static u8 bnx2x_update_link_down(struct link_params *params,
 	u8 port = params->port;
 
 	DP(NETIF_MSG_LINK, "Port %x: Link is down\n", port);
-	bnx2x_set_led(params, LED_MODE_OFF, 0);
+	bnx2x_set_led(params, vars, LED_MODE_OFF, 0);
 
 	/* indicate no mac active */
 	vars->mac_type = MAC_TYPE_NONE;
@@ -2753,6 +2773,7 @@ static u8 bnx2x_update_link_up(struct link_params *params,
 	u8 rc = 0;
 
 	vars->link_status |= LINK_STATUS_LINK_UP;
+
 	if (vars->flow_ctrl & BNX2X_FLOW_CTRL_TX)
 		vars->link_status |=
 			LINK_STATUS_TX_FLOW_CONTROL_ENABLED;
@@ -2760,9 +2781,11 @@ static u8 bnx2x_update_link_up(struct link_params *params,
 	if (vars->flow_ctrl & BNX2X_FLOW_CTRL_RX)
 		vars->link_status |=
 			LINK_STATUS_RX_FLOW_CONTROL_ENABLED;
+
 	if (link_10g) {
 		bnx2x_bmac_enable(params, vars, 0);
-		bnx2x_set_led(params, LED_MODE_OPER, SPEED_10000);
+		bnx2x_set_led(params, vars,
+			      LED_MODE_OPER, SPEED_10000);
 	} else {
 		rc = bnx2x_emac_program(params, vars);
 
@@ -4685,6 +4708,53 @@ static void bnx2x_8726_link_reset(struct bnx2x_phy *phy,
 /******************************************************************/
 /*			BCM8727 PHY SECTION			  */
 /******************************************************************/
+
+static void bnx2x_8727_set_link_led(struct bnx2x_phy *phy,
+				    struct link_params *params, u8 mode)
+{
+	struct bnx2x *bp = params->bp;
+	u16 led_mode_bitmask = 0;
+	u16 gpio_pins_bitmask = 0;
+	u16 val;
+	/* Only NOC flavor requires to set the LED specifically */
+	if (!(phy->flags & FLAGS_NOC))
+		return;
+	switch (mode) {
+	case LED_MODE_FRONT_PANEL_OFF:
+	case LED_MODE_OFF:
+		led_mode_bitmask = 0;
+		gpio_pins_bitmask = 0x03;
+		break;
+	case LED_MODE_ON:
+		led_mode_bitmask = 0;
+		gpio_pins_bitmask = 0x02;
+		break;
+	case LED_MODE_OPER:
+		led_mode_bitmask = 0x60;
+		gpio_pins_bitmask = 0x11;
+		break;
+	}
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD,
+			MDIO_PMA_REG_8727_PCS_OPT_CTRL,
+			&val);
+	val &= 0xff8f;
+	val |= led_mode_bitmask;
+	bnx2x_cl45_write(bp, phy,
+			 MDIO_PMA_DEVAD,
+			 MDIO_PMA_REG_8727_PCS_OPT_CTRL,
+			 val);
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD,
+			MDIO_PMA_REG_8727_GPIO_CTRL,
+			&val);
+	val &= 0xffe0;
+	val |= gpio_pins_bitmask;
+	bnx2x_cl45_write(bp, phy,
+			 MDIO_PMA_DEVAD,
+			 MDIO_PMA_REG_8727_GPIO_CTRL,
+			 val);
+}
 static void bnx2x_8727_hw_reset(struct bnx2x_phy *phy,
 				struct link_params *params) {
 	u32 swap_val, swap_override;
@@ -4732,7 +4802,9 @@ static u8 bnx2x_8727_config_init(struct bnx2x_phy *phy,
 	(bit 9).
 	When the EDC is off it locks onto a reference clock and
 	avoids becoming 'lost'.*/
-	mod_abs &= ~((1<<8) | (1<<9));
+	mod_abs &= ~(1<<8);
+	if (!(phy->flags & FLAGS_NOC))
+		mod_abs &= ~(1<<9);
 	bnx2x_cl45_write(bp, phy,
 			 MDIO_PMA_DEVAD, MDIO_PMA_REG_PHY_IDENTIFIER, mod_abs);
 
@@ -4741,15 +4813,15 @@ static u8 bnx2x_8727_config_init(struct bnx2x_phy *phy,
 	bnx2x_cl45_read(bp, phy, MDIO_PMA_DEVAD, MDIO_PMA_REG_8727_PCS_OPT_CTRL,
 			&val);
 	val |= (1<<12);
-	bnx2x_cl45_write(bp, phy,
-			 MDIO_PMA_DEVAD, MDIO_PMA_REG_8727_PCS_OPT_CTRL, val);
-	/* Set 8727 GPIOs to input to allow reading from the
-	8727 GPIO0 status which reflect SFP+ module
-	over-current */
+	if (phy->flags & FLAGS_NOC)
+		val |= (3<<5);
 
-	bnx2x_cl45_read(bp, phy, MDIO_PMA_DEVAD, MDIO_PMA_REG_8727_PCS_OPT_CTRL,
-			&val);
-	val &= 0xff8f; /* Reset bits 4-6 */
+	/**
+	 * Set 8727 GPIOs to input to allow reading from the 8727 GPIO0
+	 * status which reflect SFP+ module over-current
+	 */
+	if (!(phy->flags & FLAGS_NOC))
+		val &= 0xff8f; /* Reset bits 4-6 */
 	bnx2x_cl45_write(bp, phy,
 			 MDIO_PMA_DEVAD, MDIO_PMA_REG_8727_PCS_OPT_CTRL, val);
 
@@ -4863,7 +4935,9 @@ static void bnx2x_8727_handle_mod_abs(struct bnx2x_phy *phy,
 			(bit 9).
 			When the EDC is off it locks onto a reference clock and
 			avoids becoming 'lost'.*/
-		mod_abs &= ~((1<<8)|(1<<9));
+		mod_abs &= ~(1<<8);
+		if (!(phy->flags & FLAGS_NOC))
+			mod_abs &= ~(1<<9);
 		bnx2x_cl45_write(bp, phy,
 			       MDIO_PMA_DEVAD,
 			       MDIO_PMA_REG_PHY_IDENTIFIER, mod_abs);
@@ -4887,7 +4961,9 @@ static void bnx2x_8727_handle_mod_abs(struct bnx2x_phy *phy,
 		   2. Restore the default polarity of the OPRXLOS signal and
 		this signal will then correctly indicate the presence or
 		absence of the Rx signal. (bit 9) */
-		mod_abs |= ((1<<8)|(1<<9));
+		mod_abs |= (1<<8);
+		if (!(phy->flags & FLAGS_NOC))
+			mod_abs |= (1<<9);
 		bnx2x_cl45_write(bp, phy,
 				 MDIO_PMA_DEVAD,
 				 MDIO_PMA_REG_PHY_IDENTIFIER, mod_abs);
@@ -5306,21 +5382,22 @@ static u8 bnx2x_848x3_config_init(struct bnx2x_phy *phy,
 				  struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
-	u8 initialize = 1;
+	u8 port = params->port, initialize = 1;
 	u16 val;
 	u16 temp;
 	u32 actual_phy_selection;
 	u8 rc = 0;
+
+	/* This is just for MDIO_CTL_REG_84823_MEDIA register. */
+
 	msleep(1);
 	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_3,
 		       MISC_REGISTERS_GPIO_OUTPUT_HIGH,
-		       params->port);
+		       port);
 	msleep(200); /* 100 is not enough */
 
-	/**
-	 * BCM84823 requires that XGXS links up first @ 10G for normal
-	 * behavior
-	 */
+	/* BCM84823 requires that XGXS links up first @ 10G for normal
+	behavior */
 	temp = vars->line_speed;
 	vars->line_speed = SPEED_10000;
 	bnx2x_set_autoneg(&params->phy[INT_PHY], params, vars, 0);
@@ -5495,6 +5572,184 @@ static void bnx2x_848x3_link_reset(struct bnx2x_phy *phy,
 			    port);
 }
 
+static void bnx2x_848xx_set_link_led(struct bnx2x_phy *phy,
+				     struct link_params *params, u8 mode)
+{
+	struct bnx2x *bp = params->bp;
+	u16 val;
+
+	switch (mode) {
+	case LED_MODE_OFF:
+
+		DP(NETIF_MSG_LINK, "Port 0x%x: LED MODE OFF\n", params->port);
+
+		if ((params->hw_led_mode << SHARED_HW_CFG_LED_MODE_SHIFT) ==
+		    SHARED_HW_CFG_LED_EXTPHY1) {
+
+			/* Set LED masks */
+			bnx2x_cl45_write(bp, phy,
+					MDIO_PMA_DEVAD,
+					MDIO_PMA_REG_8481_LED1_MASK,
+					0x0);
+
+			bnx2x_cl45_write(bp, phy,
+					MDIO_PMA_DEVAD,
+					MDIO_PMA_REG_8481_LED2_MASK,
+					0x0);
+
+			bnx2x_cl45_write(bp, phy,
+					MDIO_PMA_DEVAD,
+					MDIO_PMA_REG_8481_LED3_MASK,
+					0x0);
+
+			bnx2x_cl45_write(bp, phy,
+					MDIO_PMA_DEVAD,
+					MDIO_PMA_REG_8481_LED5_MASK,
+					0x0);
+
+		} else {
+			bnx2x_cl45_write(bp, phy,
+					 MDIO_PMA_DEVAD,
+					 MDIO_PMA_REG_8481_LED1_MASK,
+					 0x0);
+		}
+		break;
+	case LED_MODE_FRONT_PANEL_OFF:
+
+		DP(NETIF_MSG_LINK, "Port 0x%x: LED MODE FRONT PANEL OFF\n",
+		   params->port);
+
+		if ((params->hw_led_mode << SHARED_HW_CFG_LED_MODE_SHIFT) ==
+		    SHARED_HW_CFG_LED_EXTPHY1) {
+
+			/* Set LED masks */
+			bnx2x_cl45_write(bp, phy,
+					MDIO_PMA_DEVAD,
+					MDIO_PMA_REG_8481_LED1_MASK,
+					0x0);
+
+			bnx2x_cl45_write(bp, phy,
+					MDIO_PMA_DEVAD,
+					MDIO_PMA_REG_8481_LED2_MASK,
+					0x0);
+
+			bnx2x_cl45_write(bp, phy,
+					MDIO_PMA_DEVAD,
+					MDIO_PMA_REG_8481_LED3_MASK,
+					0x0);
+
+			bnx2x_cl45_write(bp, phy,
+					MDIO_PMA_DEVAD,
+					MDIO_PMA_REG_8481_LED5_MASK,
+					0x20);
+
+		} else {
+			bnx2x_cl45_write(bp, phy,
+					 MDIO_PMA_DEVAD,
+					 MDIO_PMA_REG_8481_LED1_MASK,
+					 0x0);
+		}
+		break;
+	case LED_MODE_ON:
+
+		DP(NETIF_MSG_LINK, "Port 0x%x: LED MODE ON\n", params->port);
+
+		if ((params->hw_led_mode << SHARED_HW_CFG_LED_MODE_SHIFT) ==
+		    SHARED_HW_CFG_LED_EXTPHY1) {
+			/* Set control reg */
+			bnx2x_cl45_read(bp, phy,
+					MDIO_PMA_DEVAD,
+					MDIO_PMA_REG_8481_LINK_SIGNAL,
+					&val);
+			val &= 0x8000;
+			val |= 0x2492;
+
+			bnx2x_cl45_write(bp, phy,
+					MDIO_PMA_DEVAD,
+					MDIO_PMA_REG_8481_LINK_SIGNAL,
+					val);
+
+			/* Set LED masks */
+			bnx2x_cl45_write(bp, phy,
+					MDIO_PMA_DEVAD,
+					MDIO_PMA_REG_8481_LED1_MASK,
+					0x0);
+
+			bnx2x_cl45_write(bp, phy,
+					MDIO_PMA_DEVAD,
+					MDIO_PMA_REG_8481_LED2_MASK,
+					0x20);
+
+			bnx2x_cl45_write(bp, phy,
+					MDIO_PMA_DEVAD,
+					MDIO_PMA_REG_8481_LED3_MASK,
+					0x20);
+
+			bnx2x_cl45_write(bp, phy,
+					MDIO_PMA_DEVAD,
+					MDIO_PMA_REG_8481_LED5_MASK,
+					0x0);
+		} else {
+			bnx2x_cl45_write(bp, phy,
+					MDIO_PMA_DEVAD,
+					MDIO_PMA_REG_8481_LED1_MASK,
+					0x20);
+		}
+		break;
+
+	case LED_MODE_OPER:
+
+		DP(NETIF_MSG_LINK, "Port 0x%x: LED MODE OPER\n", params->port);
+
+		if ((params->hw_led_mode << SHARED_HW_CFG_LED_MODE_SHIFT) ==
+		    SHARED_HW_CFG_LED_EXTPHY1) {
+
+			/* Set control reg */
+			bnx2x_cl45_read(bp, phy,
+					MDIO_PMA_DEVAD,
+					MDIO_PMA_REG_8481_LINK_SIGNAL,
+					&val);
+
+			if (!((val &
+			      MDIO_PMA_REG_8481_LINK_SIGNAL_LED4_ENABLE_MASK)
+			   >> MDIO_PMA_REG_8481_LINK_SIGNAL_LED4_ENABLE_SHIFT)){
+				DP(NETIF_MSG_LINK, "Seting LINK_SIGNAL\n");
+				bnx2x_cl45_write(bp, phy,
+						 MDIO_PMA_DEVAD,
+						 MDIO_PMA_REG_8481_LINK_SIGNAL,
+						 0xa492);
+			}
+
+			/* Set LED masks */
+			bnx2x_cl45_write(bp, phy,
+					MDIO_PMA_DEVAD,
+					MDIO_PMA_REG_8481_LED1_MASK,
+					0x10);
+
+			bnx2x_cl45_write(bp, phy,
+					MDIO_PMA_DEVAD,
+					MDIO_PMA_REG_8481_LED2_MASK,
+					0x80);
+
+			bnx2x_cl45_write(bp, phy,
+					MDIO_PMA_DEVAD,
+					MDIO_PMA_REG_8481_LED3_MASK,
+					0x98);
+
+			bnx2x_cl45_write(bp, phy,
+					MDIO_PMA_DEVAD,
+					MDIO_PMA_REG_8481_LED5_MASK,
+					0x40);
+
+		} else {
+			bnx2x_cl45_write(bp, phy,
+					 MDIO_PMA_DEVAD,
+					 MDIO_PMA_REG_8481_LED1_MASK,
+					 0x80);
+		}
+		break;
+	}
+}
 /******************************************************************/
 /*			SFX7101 PHY SECTION			  */
 /******************************************************************/
@@ -5632,6 +5887,29 @@ static void bnx2x_7101_hw_reset(struct bnx2x_phy *phy,
 			    MISC_REGISTERS_GPIO_OUTPUT_LOW, params->port);
 }
 
+static void bnx2x_7101_set_link_led(struct bnx2x_phy *phy,
+				    struct link_params *params, u8 mode)
+{
+	u16 val = 0;
+	struct bnx2x *bp = params->bp;
+	switch (mode) {
+	case LED_MODE_FRONT_PANEL_OFF:
+	case LED_MODE_OFF:
+		val = 2;
+		break;
+	case LED_MODE_ON:
+		val = 1;
+		break;
+	case LED_MODE_OPER:
+		val = 0;
+		break;
+	}
+	bnx2x_cl45_write(bp, phy,
+			 MDIO_PMA_DEVAD,
+			 MDIO_PMA_REG_7107_LINK_LED_CNTL,
+			 val);
+}
+
 /******************************************************************/
 /*			STATIC PHY DECLARATION			  */
 /******************************************************************/
@@ -5763,7 +6041,7 @@ static struct bnx2x_phy phy_7101 = {
 	.config_loopback = (config_loopback_t)bnx2x_7101_config_loopback,
 	.format_fw_ver	= (format_fw_ver_t)bnx2x_7101_format_ver,
 	.hw_reset	= (hw_reset_t)bnx2x_7101_hw_reset,
-	.set_link_led	= (set_link_led_t)NULL,
+	.set_link_led	= (set_link_led_t)bnx2x_7101_set_link_led,
 	.phy_specific_func = (phy_specific_func_t)NULL
 };
 static struct bnx2x_phy phy_8073 = {
@@ -5918,7 +6196,7 @@ static struct bnx2x_phy phy_8727 = {
 	.config_loopback = (config_loopback_t)NULL,
 	.format_fw_ver	= (format_fw_ver_t)bnx2x_format_ver,
 	.hw_reset	= (hw_reset_t)bnx2x_8727_hw_reset,
-	.set_link_led	= (set_link_led_t)NULL,
+	.set_link_led	= (set_link_led_t)bnx2x_8727_set_link_led,
 	.phy_specific_func = (phy_specific_func_t)bnx2x_8727_specific_func
 };
 static struct bnx2x_phy phy_8481 = {
@@ -5954,7 +6232,7 @@ static struct bnx2x_phy phy_8481 = {
 	.config_loopback = (config_loopback_t)NULL,
 	.format_fw_ver	= (format_fw_ver_t)bnx2x_848xx_format_ver,
 	.hw_reset	= (hw_reset_t)bnx2x_8481_hw_reset,
-	.set_link_led	= (set_link_led_t)NULL,
+	.set_link_led	= (set_link_led_t)bnx2x_848xx_set_link_led,
 	.phy_specific_func = (phy_specific_func_t)NULL
 };
 
@@ -5991,7 +6269,7 @@ static struct bnx2x_phy phy_84823 = {
 	.config_loopback = (config_loopback_t)NULL,
 	.format_fw_ver	= (format_fw_ver_t)bnx2x_848xx_format_ver,
 	.hw_reset	= (hw_reset_t)NULL,
-	.set_link_led	= (set_link_led_t)NULL,
+	.set_link_led	= (set_link_led_t)bnx2x_848xx_set_link_led,
 	.phy_specific_func = (phy_specific_func_t)NULL
 };
 
@@ -6573,7 +6851,8 @@ u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 		REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE +
 			    params->port*4, 0);
 
-		bnx2x_set_led(params, LED_MODE_OPER, vars->line_speed);
+		bnx2x_set_led(params, vars,
+			      LED_MODE_OPER, vars->line_speed);
 	} else
 	/* No loopback */
 	{
@@ -6581,6 +6860,7 @@ u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 			bnx2x_xgxs_deassert(params);
 		else
 			bnx2x_serdes_deassert(bp, params->port);
+
 		bnx2x_link_initialize(params, vars);
 		msleep(30);
 		bnx2x_link_int_enable(params);
@@ -6620,7 +6900,8 @@ u8 bnx2x_link_reset(struct link_params *params, struct link_vars *vars,
 	 * Hold it as vars low
 	 */
 	 /* clear link led */
-	bnx2x_set_led(params, LED_MODE_OFF, 0);
+	bnx2x_set_led(params, vars, LED_MODE_OFF, 0);
+
 	if (reset_ext_phy) {
 		for (phy_index = EXT_PHY1; phy_index < params->num_phys;
 		      phy_index++) {
diff --git a/drivers/net/bnx2x/bnx2x_link.h b/drivers/net/bnx2x/bnx2x_link.h
index 9115c12..e98ea3d 100644
--- a/drivers/net/bnx2x/bnx2x_link.h
+++ b/drivers/net/bnx2x/bnx2x_link.h
@@ -296,9 +296,12 @@ u8 bnx2x_get_ext_phy_fw_version(struct link_params *params, u8 driver_loaded,
    Basically, the CLC takes care of the led for the link, but in case one needs
    to set/unset the led unnaturally, set the "mode" to LED_MODE_OPER to
    blink the led, and LED_MODE_OFF to set the led off.*/
-u8 bnx2x_set_led(struct link_params *params, u8 mode, u32 speed);
-#define LED_MODE_OFF	0
-#define LED_MODE_OPER 	2
+u8 bnx2x_set_led(struct link_params *params, struct link_vars *vars,
+		 u8 mode, u32 speed);
+#define LED_MODE_OFF			0
+#define LED_MODE_ON			1
+#define LED_MODE_OPER			2
+#define LED_MODE_FRONT_PANEL_OFF	3
 
 u8 bnx2x_override_led_value(struct bnx2x *bp, u8 port, u32 led_idx, u32 value);
 
diff --git a/drivers/net/bnx2x/bnx2x_reg.h b/drivers/net/bnx2x/bnx2x_reg.h
index f0a6956..6be0d09 100644
--- a/drivers/net/bnx2x/bnx2x_reg.h
+++ b/drivers/net/bnx2x/bnx2x_reg.h
@@ -5156,13 +5156,16 @@ Theotherbitsarereservedandshouldbezero*/
 #define MDIO_PMA_REG_7101_VER1		0xc026
 #define MDIO_PMA_REG_7101_VER2		0xc027
 
-#define MDIO_PMA_REG_8481_PMD_SIGNAL	0xa811
-#define MDIO_PMA_REG_8481_LED1_MASK	0xa82c
-#define MDIO_PMA_REG_8481_LED2_MASK	0xa82f
-#define MDIO_PMA_REG_8481_LED3_MASK	0xa832
-#define MDIO_PMA_REG_8481_LED3_BLINK	0xa834
-#define MDIO_PMA_REG_8481_SIGNAL_MASK	0xa835
-#define MDIO_PMA_REG_8481_LINK_SIGNAL	0xa83b
+#define MDIO_PMA_REG_8481_PMD_SIGNAL			0xa811
+#define MDIO_PMA_REG_8481_LED1_MASK			0xa82c
+#define MDIO_PMA_REG_8481_LED2_MASK			0xa82f
+#define MDIO_PMA_REG_8481_LED3_MASK			0xa832
+#define MDIO_PMA_REG_8481_LED3_BLINK			0xa834
+#define MDIO_PMA_REG_8481_LED5_MASK			0xa838
+#define MDIO_PMA_REG_8481_SIGNAL_MASK			0xa835
+#define MDIO_PMA_REG_8481_LINK_SIGNAL			0xa83b
+#define MDIO_PMA_REG_8481_LINK_SIGNAL_LED4_ENABLE_MASK	0x800
+#define MDIO_PMA_REG_8481_LINK_SIGNAL_LED4_ENABLE_SHIFT 11
 

 #define MDIO_WIS_DEVAD			0x2
-- 
1.7.1




