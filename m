From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 06/36] bnx2x: BCM8481 LED4 instead of LASI
Date: Wed, 12 Aug 2009 21:22:16 +0300
Message-ID: <1250101336.27379.157.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Yaniv Rosner" <yanivr@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4884 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751685AbZHLSXV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2009 14:23:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The BCM8481 does not generate LASI interrupt for 10M, 100M and 1G link, so we
are using LED4 output as the interrupt input to the 57711. This requires some
adaptation in the link interrupt routines

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_link.c |  498 ++++++++++++++++++++++++++++++++++++++++------
 drivers/net/bnx2x_reg.h  |   32 +++
 2 files changed, 468 insertions(+), 62 deletions(-)

diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index 1f17334..9e1f19a 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -37,6 +37,10 @@
 /*			Shortcut definitions		   */
 /***********************************************************/
 
+#define NIG_LATCH_BC_ENABLE_MI_INT 0
+
+#define NIG_STATUS_EMAC0_MI_INT \
+		NIG_STATUS_INTERRUPT_PORT0_REG_STATUS_EMAC0_MISC_MI_INT
 #define NIG_STATUS_XGXS0_LINK10G \
 		NIG_STATUS_INTERRUPT_PORT0_REG_STATUS_XGXS0_LINK10G
 #define NIG_STATUS_XGXS0_LINK_STATUS \
@@ -1589,8 +1593,9 @@ static void bnx2x_flow_ctrl_resolve(struct link_params *params,
 
 
 static u8 bnx2x_link_settings_status(struct link_params *params,
-				      struct link_vars *vars,
-				      u32 gp_status)
+				   struct link_vars *vars,
+				   u32 gp_status,
+				   u8 ext_phy_link_up)
 {
 	struct bnx2x *bp = params->bp;
 	u16 new_line_speed;
@@ -1696,6 +1701,16 @@ static u8 bnx2x_link_settings_status(struct link_params *params,
 		Comes to deals with possible FIFO glitch due to clk change
 		when speed is decreased without link down indicator */
 		if (new_line_speed != vars->line_speed) {
+			if (XGXS_EXT_PHY_TYPE(params->ext_phy_config) !=
+			     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT &&
+			    ext_phy_link_up) {
+				DP(NETIF_MSG_LINK, "Internal link speed %d is"
+					    " different than the external"
+					    " link speed %d\n", new_line_speed,
+					  vars->line_speed);
+				vars->phy_link_up = 0;
+				return 0;
+			}
 			REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE
 				    + params->port*4, 0);
 			msleep(1);
@@ -1709,9 +1724,7 @@ static u8 bnx2x_link_settings_status(struct link_params *params,
 		    (XGXS_EXT_PHY_TYPE(params->ext_phy_config) ==
 		     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705) ||
 		    (XGXS_EXT_PHY_TYPE(params->ext_phy_config) ==
-		     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726) ||
-		     (XGXS_EXT_PHY_TYPE(params->ext_phy_config) ==
-		     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481))) {
+		     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726))) {
 			vars->autoneg = AUTO_NEG_ENABLED;
 
 			if (gp_status & MDIO_AN_CL73_OR_37_COMPLETE) {
@@ -3182,6 +3195,130 @@ static void bnx2x_set_preemphasis(struct link_params *params)
 	}
 }
 
+
+static void bnx2x_8481_set_led4(struct link_params *params,
+			      u32 ext_phy_type, u8 ext_phy_addr)
+{
+	struct bnx2x *bp = params->bp;
+
+	/* PHYC_CTL_LED_CTL */
+	bnx2x_cl45_write(bp, params->port,
+		       ext_phy_type,
+		       ext_phy_addr,
+		       MDIO_PMA_DEVAD,
+		       MDIO_PMA_REG_8481_LINK_SIGNAL, 0xa482);
+
+	/* Unmask LED4 for 10G link */
+	bnx2x_cl45_write(bp, params->port,
+		       ext_phy_type,
+		       ext_phy_addr,
+		       MDIO_PMA_DEVAD,
+		       MDIO_PMA_REG_8481_SIGNAL_MASK, (1<<6));
+	/* 'Interrupt Mask' */
+	bnx2x_cl45_write(bp, params->port,
+		       ext_phy_type,
+		       ext_phy_addr,
+		       MDIO_AN_DEVAD,
+		       0xFFFB, 0xFFFD);
+}
+static void bnx2x_8481_set_legacy_led_mode(struct link_params *params,
+					 u32 ext_phy_type, u8 ext_phy_addr)
+{
+	struct bnx2x *bp = params->bp;
+
+	/* LED1 (10G Link): Disable LED1 when 10/100/1000 link */
+	/* LED2 (1G/100/10 Link): Enable LED2 when 10/100/1000 link) */
+	bnx2x_cl45_write(bp, params->port,
+		       ext_phy_type,
+		       ext_phy_addr,
+		       MDIO_AN_DEVAD,
+		       MDIO_AN_REG_8481_LEGACY_SHADOW,
+		       (1<<15) | (0xd << 10) | (0xc<<4) | 0xe);
+}
+
+static void bnx2x_8481_set_10G_led_mode(struct link_params *params,
+				      u32 ext_phy_type, u8 ext_phy_addr)
+{
+	struct bnx2x *bp = params->bp;
+	u16 val1;
+
+	/* LED1 (10G Link) */
+	/* Enable continuse based on source 7(10G-link) */
+	bnx2x_cl45_read(bp, params->port,
+		       ext_phy_type,
+		       ext_phy_addr,
+		       MDIO_PMA_DEVAD,
+		       MDIO_PMA_REG_8481_LINK_SIGNAL,
+		       &val1);
+	/* Set bit 2 to 0, and bits [1:0] to 10 */
+	val1 &= ~((1<<0) | (1<<2)); /* Clear bits 0,2*/
+	val1 |= (1<<1); /* Set bit 1 */
+
+	bnx2x_cl45_write(bp, params->port,
+		       ext_phy_type,
+		       ext_phy_addr,
+		       MDIO_PMA_DEVAD,
+		       MDIO_PMA_REG_8481_LINK_SIGNAL,
+		       val1);
+
+	/* Unmask LED1 for 10G link */
+	bnx2x_cl45_read(bp, params->port,
+		      ext_phy_type,
+		      ext_phy_addr,
+		      MDIO_PMA_DEVAD,
+		      MDIO_PMA_REG_8481_LED1_MASK,
+		      &val1);
+	/* Set bit 2 to 0, and bits [1:0] to 10 */
+	val1 |= (1<<7);
+	bnx2x_cl45_write(bp, params->port,
+		       ext_phy_type,
+		       ext_phy_addr,
+		       MDIO_PMA_DEVAD,
+		       MDIO_PMA_REG_8481_LED1_MASK,
+		       val1);
+
+	/* LED2 (1G/100/10G Link) */
+	/* Mask LED2 for 10G link */
+	bnx2x_cl45_write(bp, params->port,
+		       ext_phy_type,
+		       ext_phy_addr,
+		       MDIO_PMA_DEVAD,
+		       MDIO_PMA_REG_8481_LED2_MASK,
+		       0);
+
+	/* LED3 (10G/1G/100/10G Activity) */
+	bnx2x_cl45_read(bp, params->port,
+		      ext_phy_type,
+		      ext_phy_addr,
+		      MDIO_PMA_DEVAD,
+		      MDIO_PMA_REG_8481_LINK_SIGNAL,
+		      &val1);
+	/* Enable blink based on source 4(Activity) */
+	val1 &= ~((1<<7) | (1<<8)); /* Clear bits 7,8 */
+	val1 |= (1<<6); /* Set only bit 6 */
+	bnx2x_cl45_write(bp, params->port,
+		       ext_phy_type,
+		       ext_phy_addr,
+		       MDIO_PMA_DEVAD,
+		       MDIO_PMA_REG_8481_LINK_SIGNAL,
+		       val1);
+
+	bnx2x_cl45_read(bp, params->port,
+		      ext_phy_type,
+		      ext_phy_addr,
+		      MDIO_PMA_DEVAD,
+		      MDIO_PMA_REG_8481_LED3_MASK,
+		      &val1);
+	val1 |= (1<<4); /* Unmask LED3 for 10G link */
+	bnx2x_cl45_write(bp, params->port,
+		       ext_phy_type,
+		       ext_phy_addr,
+		       MDIO_PMA_DEVAD,
+		       MDIO_PMA_REG_8481_LED3_MASK,
+		       val1);
+}
+
+
 static void bnx2x_init_internal_phy(struct link_params *params,
 				struct link_vars *vars)
 {
@@ -3947,16 +4084,109 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 			break;
 		}
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481:
-			DP(NETIF_MSG_LINK,
-				"Setting the BCM8481 LASI control\n");
+			/* This phy uses the NIG latch mechanism since link
+				indication arrives through its LED4 and not via
+				its LASI signal, so we get steady signal
+				instead of clear on read */
+			bnx2x_bits_en(bp, NIG_REG_LATCH_BC_0 + params->port*4,
+				    1 << NIG_LATCH_BC_ENABLE_MI_INT);
+
+			bnx2x_8481_set_led4(params, ext_phy_type, ext_phy_addr);
+			if (params->req_line_speed == SPEED_AUTO_NEG) {
+
+				u16 autoneg_val, an_1000_val, an_10_100_val;
+				/* set 1000 speed advertisement */
+				bnx2x_cl45_read(bp, params->port,
+					      ext_phy_type,
+					      ext_phy_addr,
+					      MDIO_AN_DEVAD,
+					      MDIO_AN_REG_8481_1000T_CTRL,
+					      &an_1000_val);
 
-			bnx2x_cl45_write(bp, params->port,
-				       ext_phy_type,
-				       ext_phy_addr,
-				       MDIO_PMA_DEVAD,
-				       MDIO_PMA_REG_LASI_CTRL, 0x1);
+				if (params->speed_cap_mask &
+				    PORT_HW_CFG_SPEED_CAPABILITY_D0_1G) {
+					an_1000_val |= (1<<8);
+					if (params->req_duplex == DUPLEX_FULL)
+						an_1000_val |= (1<<9);
+					DP(NETIF_MSG_LINK, "Advertising 1G\n");
+				} else
+					an_1000_val &= ~((1<<8) | (1<<9));
 
-			/* Restart autoneg */
+				bnx2x_cl45_write(bp, params->port,
+					       ext_phy_type,
+					       ext_phy_addr,
+					       MDIO_AN_DEVAD,
+					       MDIO_AN_REG_8481_1000T_CTRL,
+					       an_1000_val);
+
+				/* set 100 speed advertisement */
+				bnx2x_cl45_read(bp, params->port,
+					      ext_phy_type,
+					      ext_phy_addr,
+					      MDIO_AN_DEVAD,
+					      MDIO_AN_REG_8481_LEGACY_AN_ADV,
+					      &an_10_100_val);
+
+				if (params->speed_cap_mask &
+				 (PORT_HW_CFG_SPEED_CAPABILITY_D0_100M_FULL |
+				  PORT_HW_CFG_SPEED_CAPABILITY_D0_100M_HALF)) {
+					an_10_100_val |= (1<<7);
+					if (params->req_duplex == DUPLEX_FULL)
+						an_10_100_val |= (1<<8);
+					DP(NETIF_MSG_LINK,
+						"Advertising 100M\n");
+				} else
+					an_10_100_val &= ~((1<<7) | (1<<8));
+
+				/* set 10 speed advertisement */
+				if (params->speed_cap_mask &
+				  (PORT_HW_CFG_SPEED_CAPABILITY_D0_10M_FULL |
+				   PORT_HW_CFG_SPEED_CAPABILITY_D0_10M_HALF)) {
+					an_10_100_val |= (1<<5);
+					if (params->req_duplex == DUPLEX_FULL)
+						an_10_100_val |= (1<<6);
+					DP(NETIF_MSG_LINK, "Advertising 10M\n");
+				     }
+				else
+					an_10_100_val &= ~((1<<5) | (1<<6));
+
+				bnx2x_cl45_write(bp, params->port,
+					       ext_phy_type,
+					       ext_phy_addr,
+					       MDIO_AN_DEVAD,
+					       MDIO_AN_REG_8481_LEGACY_AN_ADV,
+					       an_10_100_val);
+
+				bnx2x_cl45_read(bp, params->port,
+					      ext_phy_type,
+					      ext_phy_addr,
+					      MDIO_AN_DEVAD,
+					      MDIO_AN_REG_8481_LEGACY_MII_CTRL,
+					      &autoneg_val);
+
+				/* Disable forced speed */
+				autoneg_val &= ~(1<<6|1<<13);
+
+				/* Enable autoneg and restart autoneg
+				for legacy speeds */
+				autoneg_val |= (1<<9|1<<12);
+
+				if (params->req_duplex == DUPLEX_FULL)
+					autoneg_val |= (1<<8);
+				else
+					autoneg_val &= ~(1<<8);
+
+				bnx2x_cl45_write(bp, params->port,
+					       ext_phy_type,
+					       ext_phy_addr,
+					       MDIO_AN_DEVAD,
+					       MDIO_AN_REG_8481_LEGACY_MII_CTRL,
+					       autoneg_val);
+
+				if (params->speed_cap_mask &
+				    PORT_HW_CFG_SPEED_CAPABILITY_D0_10G) {
+					DP(NETIF_MSG_LINK, "Advertising 10G\n");
+					/* Restart autoneg for 10G*/
 			bnx2x_cl45_read(bp, params->port,
 				      ext_phy_type,
 				      ext_phy_addr,
@@ -3968,6 +4198,76 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 				       ext_phy_addr,
 				       MDIO_AN_DEVAD,
 				       MDIO_AN_REG_CTRL, val);
+				}
+			} else {
+				/* Force speed */
+				u16 autoneg_ctrl, pma_ctrl;
+				bnx2x_cl45_read(bp, params->port,
+					      ext_phy_type,
+					      ext_phy_addr,
+					      MDIO_AN_DEVAD,
+					      MDIO_AN_REG_8481_LEGACY_MII_CTRL,
+					      &autoneg_ctrl);
+
+				/* Disable autoneg */
+				autoneg_ctrl &= ~(1<<12);
+
+				/* Set 1000 force */
+				switch (params->req_line_speed) {
+				case SPEED_10000:
+					DP(NETIF_MSG_LINK,
+						"Unable to set 10G force !\n");
+					break;
+				case SPEED_1000:
+					bnx2x_cl45_read(bp, params->port,
+						      ext_phy_type,
+						      ext_phy_addr,
+						      MDIO_PMA_DEVAD,
+						      MDIO_PMA_REG_CTRL,
+						      &pma_ctrl);
+					autoneg_ctrl &= ~(1<<13);
+					autoneg_ctrl |= (1<<6);
+					pma_ctrl &= ~(1<<13);
+					pma_ctrl |= (1<<6);
+					DP(NETIF_MSG_LINK,
+						"Setting 1000M force\n");
+					bnx2x_cl45_write(bp, params->port,
+						       ext_phy_type,
+						       ext_phy_addr,
+						       MDIO_PMA_DEVAD,
+						       MDIO_PMA_REG_CTRL,
+						       pma_ctrl);
+					break;
+				case SPEED_100:
+					autoneg_ctrl |= (1<<13);
+					autoneg_ctrl &= ~(1<<6);
+					DP(NETIF_MSG_LINK,
+						"Setting 100M force\n");
+					break;
+				case SPEED_10:
+					autoneg_ctrl &= ~(1<<13);
+					autoneg_ctrl &= ~(1<<6);
+					DP(NETIF_MSG_LINK,
+						"Setting 10M force\n");
+					break;
+				}
+
+				/* Duplex mode */
+				if (params->req_duplex == DUPLEX_FULL) {
+					autoneg_ctrl |= (1<<8);
+					DP(NETIF_MSG_LINK,
+						"Setting full duplex\n");
+				} else
+					autoneg_ctrl &= ~(1<<8);
+
+				/* Update autoneg ctrl and pma ctrl */
+				bnx2x_cl45_write(bp, params->port,
+					       ext_phy_type,
+					       ext_phy_addr,
+					       MDIO_AN_DEVAD,
+					       MDIO_AN_REG_8481_LEGACY_MII_CTRL,
+					       autoneg_ctrl);
+			}
 
 			bnx2x_save_bcm_spirom_ver(bp, params->port,
 						ext_phy_type,
@@ -4104,7 +4404,8 @@ static void bnx2x_8727_handle_mod_abs(struct link_params *params)
 
 
 static u8 bnx2x_ext_phy_is_link_up(struct link_params *params,
-				 struct link_vars *vars)
+				 struct link_vars *vars,
+				 u8 is_mi_int)
 {
 	struct bnx2x *bp = params->bp;
 	u32 ext_phy_type;
@@ -4647,48 +4948,77 @@ static u8 bnx2x_ext_phy_is_link_up(struct link_params *params,
 			}
 			break;
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481:
-			/* Clear LASI interrupt */
-			bnx2x_cl45_read(bp, params->port,
-				      ext_phy_type,
-				      ext_phy_addr,
-				      MDIO_PMA_DEVAD,
-				      MDIO_PMA_REG_LASI_STATUS, &val1);
-			DP(NETIF_MSG_LINK, "8481 LASI status reg = 0x%x\n",
-				 val1);
-
 			/* Check 10G-BaseT link status */
-			/* Check Global PMD signal ok */
+			/* Check PMD signal ok */
 			bnx2x_cl45_read(bp, params->port, ext_phy_type,
-				      ext_phy_addr,
-				      MDIO_PMA_DEVAD, MDIO_PMA_REG_RX_SD,
-				      &rx_sd);
-			/* Check PCS block lock */
+						      ext_phy_addr,
+						      MDIO_AN_DEVAD,
+						      0xFFFA,
+						      &val1);
 			bnx2x_cl45_read(bp, params->port, ext_phy_type,
 				      ext_phy_addr,
-				      MDIO_PCS_DEVAD, MDIO_PCS_REG_STATUS,
-				      &pcs_status);
-			DP(NETIF_MSG_LINK, "8481 1.a = 0x%x, 1.20 = 0x%x\n",
-				 rx_sd, pcs_status);
-			if (rx_sd & pcs_status & 0x1) {
+				      MDIO_PMA_DEVAD,
+				      MDIO_PMA_REG_8481_PMD_SIGNAL,
+				      &val2);
+			DP(NETIF_MSG_LINK, "PMD_SIGNAL 1.a811 = 0x%x\n", val2);
+
+			/* Check link 10G */
+			if (val2 & (1<<11)) {
 				vars->line_speed = SPEED_10000;
 				ext_phy_link_up = 1;
-			} else {
-
-				/* Check 1000-BaseT link status */
-				bnx2x_cl45_read(bp, params->port, ext_phy_type,
-					      ext_phy_addr,
-					      MDIO_AN_DEVAD, 0xFFE1,
-					      &val1);
+				bnx2x_8481_set_10G_led_mode(params,
+							  ext_phy_type,
+							  ext_phy_addr);
+			} else { /* Check Legacy speed link */
+				u16 legacy_status, legacy_speed;
+
+				/* Enable expansion register 0x42
+				(Operation mode status) */
+				bnx2x_cl45_write(bp, params->port,
+					 ext_phy_type,
+					 ext_phy_addr,
+					 MDIO_AN_DEVAD,
+					 MDIO_AN_REG_8481_EXPANSION_REG_ACCESS,
+					 0xf42);
 
-				bnx2x_cl45_read(bp, params->port, ext_phy_type,
-					      ext_phy_addr,
-					      MDIO_AN_DEVAD, 0xFFE1,
-					      &val2);
-				DP(NETIF_MSG_LINK, "8481 7.FFE1 ="
-					     "0x%x-->0x%x\n", val1, val2);
-				if (val2 & (1<<2)) {
-					vars->line_speed = SPEED_1000;
-					ext_phy_link_up = 1;
+				/* Get legacy speed operation status */
+				bnx2x_cl45_read(bp, params->port,
+					  ext_phy_type,
+					  ext_phy_addr,
+					  MDIO_AN_DEVAD,
+					  MDIO_AN_REG_8481_EXPANSION_REG_RD_RW,
+					  &legacy_status);
+
+				DP(NETIF_MSG_LINK, "Legacy speed status"
+					     " = 0x%x\n", legacy_status);
+				ext_phy_link_up = ((legacy_status & (1<<11))
+						   == (1<<11));
+				if (ext_phy_link_up) {
+					legacy_speed = (legacy_status & (3<<9));
+					if (legacy_speed == (0<<9))
+						vars->line_speed = SPEED_10;
+					else if (legacy_speed == (1<<9))
+						vars->line_speed =
+							SPEED_100;
+					else if (legacy_speed == (2<<9))
+						vars->line_speed =
+							SPEED_1000;
+					else /* Should not happen */
+						vars->line_speed = 0;
+
+					if (legacy_status & (1<<8))
+						vars->duplex = DUPLEX_FULL;
+					else
+						vars->duplex = DUPLEX_HALF;
+
+					DP(NETIF_MSG_LINK, "Link is up "
+						     "in %dMbps, is_duplex_full"
+						     "= %d\n",
+						vars->line_speed,
+						(vars->duplex == DUPLEX_FULL));
+					bnx2x_8481_set_legacy_led_mode(params,
+								 ext_phy_type,
+								 ext_phy_addr);
 				}
 			}
 
@@ -4775,12 +5105,47 @@ static void bnx2x_link_int_enable(struct link_params *params)
 	   REG_RD(bp, NIG_REG_XGXS0_STATUS_LINK_STATUS + port*0x68));
 }
 
-
+static void bnx2x_8481_rearm_latch_signal(struct bnx2x *bp, u8 port,
+					u8 is_mi_int)
+{
+	u32 latch_status = 0, is_mi_int_status;
+	/* Disable the MI INT ( external phy int )
+	 * by writing 1 to the status register. Link down indication
+	 * is high-active-signal, so in this case we need to write the
+	 * status to clear the XOR
+	 */
+	/* Read Latched signals */
+	latch_status = REG_RD(bp,
+				  NIG_REG_LATCH_STATUS_0 + port*8);
+	is_mi_int_status = REG_RD(bp,
+				  NIG_REG_STATUS_INTERRUPT_PORT0 + port*4);
+	DP(NETIF_MSG_LINK, "original_signal = 0x%x, nig_status = 0x%x,"
+		     "latch_status = 0x%x\n",
+		 is_mi_int, is_mi_int_status, latch_status);
+	/* Handle only those with latched-signal=up.*/
+	if (latch_status & 1) {
+		/* For all latched-signal=up,Write original_signal to status */
+		if (is_mi_int)
+			bnx2x_bits_en(bp,
+				    NIG_REG_STATUS_INTERRUPT_PORT0
+				    + port*4,
+				    NIG_STATUS_EMAC0_MI_INT);
+		else
+			bnx2x_bits_dis(bp,
+				     NIG_REG_STATUS_INTERRUPT_PORT0
+				     + port*4,
+				     NIG_STATUS_EMAC0_MI_INT);
+		/* For all latched-signal=up : Re-Arm Latch signals */
+		REG_WR(bp, NIG_REG_LATCH_STATUS_0 + port*8,
+			   (latch_status & 0xfffe) | (latch_status & 1));
+	}
+}
 /*
  * link management
  */
 static void bnx2x_link_int_ack(struct link_params *params,
-			     struct link_vars *vars, u8 is_10g)
+			     struct link_vars *vars, u8 is_10g,
+			     u8 is_mi_int)
 {
 	struct bnx2x *bp = params->bp;
 	u8 port = params->port;
@@ -4791,6 +5156,10 @@ static void bnx2x_link_int_ack(struct link_params *params,
 		     (NIG_STATUS_XGXS0_LINK10G |
 		      NIG_STATUS_XGXS0_LINK_STATUS |
 		      NIG_STATUS_SERDES0_LINK_STATUS));
+	if (XGXS_EXT_PHY_TYPE(params->ext_phy_config)
+	    == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481) {
+		bnx2x_8481_rearm_latch_signal(bp, port, is_mi_int);
+	}
 	if (vars->phy_link_up) {
 		if (is_10g) {
 			/* Disable the 10G link interrupt
@@ -4810,7 +5179,8 @@ static void bnx2x_link_int_ack(struct link_params *params,
 				    PORT_HW_CFG_LANE_SWAP_CFG_MASTER_MASK) >>
 				    PORT_HW_CFG_LANE_SWAP_CFG_MASTER_SHIFT);
 
-			DP(NETIF_MSG_LINK, "1G XGXS phy link up\n");
+			DP(NETIF_MSG_LINK, "%d speed XGXS phy link up\n",
+				 vars->line_speed);
 			bnx2x_bits_en(bp,
 				      NIG_REG_STATUS_INTERRUPT_PORT0 + port*4,
 				      ((1 << ser_lane) <<
@@ -5270,7 +5640,7 @@ u8 bnx2x_test_link(struct link_params *params, struct link_vars *vars)
 			      &gp_status);
 	/* link is up only if both local phy and external phy are up */
 	if ((gp_status & MDIO_GP_STATUS_TOP_AN_STATUS1_LINK_STATUS) &&
-	    bnx2x_ext_phy_is_link_up(params, vars))
+	    bnx2x_ext_phy_is_link_up(params, vars, 1))
 		return 0;
 
 	return -ESRCH;
@@ -5758,16 +6128,19 @@ u8 bnx2x_link_update(struct link_params *params, struct link_vars *vars)
 	u8 link_10g;
 	u8 ext_phy_link_up, rc = 0;
 	u32 ext_phy_type;
+	u8 is_mi_int = 0;
 
 	DP(NETIF_MSG_LINK, "port %x, XGXS?%x, int_status 0x%x\n",
-	 port,
-	(vars->phy_flags & PHY_XGXS_FLAG),
-	 REG_RD(bp, NIG_REG_STATUS_INTERRUPT_PORT0 + port*4));
+		 port, (vars->phy_flags & PHY_XGXS_FLAG),
+		 REG_RD(bp, NIG_REG_STATUS_INTERRUPT_PORT0 + port*4));
 
+	is_mi_int = (u8)(REG_RD(bp, NIG_REG_EMAC0_STATUS_MISC_MI_INT +
+				    port*0x18) > 0);
 	DP(NETIF_MSG_LINK, "int_mask 0x%x MI_INT %x, SERDES_LINK %x\n",
-	REG_RD(bp, NIG_REG_MASK_INTERRUPT_PORT0 + port*4),
-	REG_RD(bp, NIG_REG_EMAC0_STATUS_MISC_MI_INT + port*0x18),
-	REG_RD(bp, NIG_REG_SERDES0_STATUS_LINK_STATUS + port*0x3c));
+		 REG_RD(bp, NIG_REG_MASK_INTERRUPT_PORT0 + port*4),
+		 is_mi_int,
+		 REG_RD(bp,
+			    NIG_REG_SERDES0_STATUS_LINK_STATUS + port*0x3c));
 
 	DP(NETIF_MSG_LINK, " 10G %x, XGXS_LINK %x\n",
 	  REG_RD(bp, NIG_REG_XGXS0_STATUS_LINK10G + port*0x68),
@@ -5779,7 +6152,7 @@ u8 bnx2x_link_update(struct link_params *params, struct link_vars *vars)
 	ext_phy_type = XGXS_EXT_PHY_TYPE(params->ext_phy_config);
 
 	/* Check external link change only for non-direct */
-	ext_phy_link_up = bnx2x_ext_phy_is_link_up(params, vars);
+	ext_phy_link_up = bnx2x_ext_phy_is_link_up(params, vars, is_mi_int);
 
 	/* Read gp_status */
 	CL45_RD_OVER_CL22(bp, port, params->phy_addr,
@@ -5787,7 +6160,8 @@ u8 bnx2x_link_update(struct link_params *params, struct link_vars *vars)
 			      MDIO_GP_STATUS_TOP_AN_STATUS1,
 			      &gp_status);
 
-	rc = bnx2x_link_settings_status(params, vars, gp_status);
+	rc = bnx2x_link_settings_status(params, vars, gp_status,
+				      ext_phy_link_up);
 	if (rc != 0)
 		return rc;
 
@@ -5799,7 +6173,7 @@ u8 bnx2x_link_update(struct link_params *params, struct link_vars *vars)
 		    (vars->line_speed == SPEED_15000) ||
 		    (vars->line_speed == SPEED_16000));
 
-	bnx2x_link_int_ack(params, vars, link_10g);
+	bnx2x_link_int_ack(params, vars, link_10g, is_mi_int);
 
 	/* In case external phy link is up, and internal link is down
 	( not initialized yet probably after link initialization, it needs
diff --git a/drivers/net/bnx2x_reg.h b/drivers/net/bnx2x_reg.h
index 25639e2..9a20da5 100644
--- a/drivers/net/bnx2x_reg.h
+++ b/drivers/net/bnx2x_reg.h
@@ -1681,6 +1681,24 @@
 /* [RW 17] Debug only. RX_EOP_DSCR_lb_FIFO in NIG_RX_EOP. Data
    packet_length[13:0]; mac_error[14]; trunc_error[15]; parity[16] */
 #define NIG_REG_INGRESS_EOP_LB_FIFO				 0x104e4
+/* [RW 27] 0 - must be active for Everest A0; 1- for Everest B0 when latch
+   logic for interrupts must be used. Enable per bit of interrupt of
+   ~latch_status.latch_status */
+#define NIG_REG_LATCH_BC_0					 0x16210
+/* [RW 27] Latch for each interrupt from Unicore.b[0]
+   status_emac0_misc_mi_int; b[1] status_emac0_misc_mi_complete;
+   b[2]status_emac0_misc_cfg_change; b[3]status_emac0_misc_link_status;
+   b[4]status_emac0_misc_link_change; b[5]status_emac0_misc_attn;
+   b[6]status_serdes0_mac_crs; b[7]status_serdes0_autoneg_complete;
+   b[8]status_serdes0_fiber_rxact; b[9]status_serdes0_link_status;
+   b[10]status_serdes0_mr_page_rx; b[11]status_serdes0_cl73_an_complete;
+   b[12]status_serdes0_cl73_mr_page_rx; b[13]status_serdes0_rx_sigdet;
+   b[14]status_xgxs0_remotemdioreq; b[15]status_xgxs0_link10g;
+   b[16]status_xgxs0_autoneg_complete; b[17]status_xgxs0_fiber_rxact;
+   b[21:18]status_xgxs0_link_status; b[22]status_xgxs0_mr_page_rx;
+   b[23]status_xgxs0_cl73_an_complete; b[24]status_xgxs0_cl73_mr_page_rx;
+   b[25]status_xgxs0_rx_sigdet; b[26]status_xgxs0_mac_crs */
+#define NIG_REG_LATCH_STATUS_0					 0x18000
 /* [RW 1] led 10g for port 0 */
 #define NIG_REG_LED_10G_P0					 0x10320
 /* [RW 1] led 10g for port 1 */
@@ -1871,6 +1889,7 @@
 #define NIG_REG_XGXS_LANE_SEL_P0				 0x102e8
 /* [RW 1] selection for port0 for NIG_MUX block : 0 = SerDes; 1 = XGXS */
 #define NIG_REG_XGXS_SERDES0_MODE_SEL				 0x102e0
+#define NIG_STATUS_INTERRUPT_PORT0_REG_STATUS_EMAC0_MISC_MI_INT  (0x1<<0)
 #define NIG_STATUS_INTERRUPT_PORT0_REG_STATUS_SERDES0_LINK_STATUS (0x1<<9)
 #define NIG_STATUS_INTERRUPT_PORT0_REG_STATUS_XGXS0_LINK10G	 (0x1<<15)
 #define NIG_STATUS_INTERRUPT_PORT0_REG_STATUS_XGXS0_LINK_STATUS  (0xf<<18)
@@ -5889,6 +5908,13 @@ Theotherbitsarereservedandshouldbezero*/
 #define MDIO_PMA_REG_7101_VER1		0xc026
 #define MDIO_PMA_REG_7101_VER2		0xc027
 
+#define MDIO_PMA_REG_8481_PMD_SIGNAL	0xa811
+#define MDIO_PMA_REG_8481_LED1_MASK	0xa82c
+#define MDIO_PMA_REG_8481_LED2_MASK	0xa82f
+#define MDIO_PMA_REG_8481_LED3_MASK	0xa832
+#define MDIO_PMA_REG_8481_SIGNAL_MASK	0xa835
+#define MDIO_PMA_REG_8481_LINK_SIGNAL	0xa83b
+
 
 #define MDIO_WIS_DEVAD			0x2
 /*bcm*/
@@ -5942,6 +5968,12 @@ Theotherbitsarereservedandshouldbezero*/
 
 #define MDIO_AN_REG_8073_2_5G		0x8329
 
+#define MDIO_AN_REG_8481_LEGACY_MII_CTRL	0xffe0
+#define MDIO_AN_REG_8481_LEGACY_AN_ADV		0xffe4
+#define MDIO_AN_REG_8481_1000T_CTRL		0xffe9
+#define MDIO_AN_REG_8481_EXPANSION_REG_RD_RW	0xfff5
+#define MDIO_AN_REG_8481_EXPANSION_REG_ACCESS	0xfff7
+#define MDIO_AN_REG_8481_LEGACY_SHADOW		0xfffc
 
 #define IGU_FUNC_BASE			0x0400
 
-- 
1.5.4.3




