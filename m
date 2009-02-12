From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 16/41]bnx2x: Supporting BCM8481 PHY
Date: Thu, 12 Feb 2009 20:37:00 +0200
Message-ID: <1234463820.1863.148.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1665 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759041AbZBLSpL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 13:45:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 16/41]bnx2x: Supporting BCM8481 PHY

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_link.c |   95 +++++++++++++++++++++++++++++++++++++++++++++-
 drivers/net/bnx2x_main.c |   17 ++++++++
 2 files changed, 110 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index 55f50c7..bed11b9 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -1755,7 +1755,9 @@ static u8 bnx2x_link_settings_status(struct link_params *params,
 		    (XGXS_EXT_PHY_TYPE(params->ext_phy_config) ==
 		     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705) ||
 		    (XGXS_EXT_PHY_TYPE(params->ext_phy_config) ==
-		     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726))) {
+		     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726) ||
+		     (XGXS_EXT_PHY_TYPE(params->ext_phy_config) ==
+		     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481))) {
 			vars->autoneg = AUTO_NEG_ENABLED;
 
 			if (gp_status & MDIO_AN_CL73_OR_37_COMPLETE) {
@@ -1997,6 +1999,23 @@ static void bnx2x_ext_phy_reset(struct link_params *params,
 
 			break;
 
+		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481:
+
+			/* Restore normal power mode*/
+			bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
+				      MISC_REGISTERS_GPIO_OUTPUT_HIGH,
+					  params->port);
+
+			/* HW reset */
+			bnx2x_hw_reset(bp, params->port);
+
+			bnx2x_cl45_write(bp, params->port,
+				       ext_phy_type,
+				       ext_phy_addr,
+				       MDIO_PMA_DEVAD,
+				       MDIO_PMA_REG_CTRL,
+				       1<<15);
+			break;
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_FAILURE:
 			DP(NETIF_MSG_LINK, "XGXS PHY Failure detected\n");
 			break;
@@ -3414,6 +3433,31 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 				       ext_phy_addr,
 				       MDIO_AN_DEVAD,
 				       MDIO_AN_REG_CTRL, val);
+
+			break;
+		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481:
+			DP(NETIF_MSG_LINK,
+				"Setting the BCM8481 LASI control\n");
+
+			bnx2x_cl45_write(bp, params->port,
+				       ext_phy_type,
+				       ext_phy_addr,
+				       MDIO_PMA_DEVAD,
+				       MDIO_PMA_REG_LASI_CTRL, 0x1);
+
+			/* Restart autoneg */
+			bnx2x_cl45_read(bp, params->port,
+				      ext_phy_type,
+				      ext_phy_addr,
+				      MDIO_AN_DEVAD,
+				      MDIO_AN_REG_CTRL, &val);
+			val |= 0x200;
+			bnx2x_cl45_write(bp, params->port,
+				       ext_phy_type,
+				       ext_phy_addr,
+				       MDIO_AN_DEVAD,
+				       MDIO_AN_REG_CTRL, val);
+
 			break;
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_FAILURE:
 			DP(NETIF_MSG_LINK,
@@ -3830,7 +3874,53 @@ static u8 bnx2x_ext_phy_is_link_up(struct link_params *params,
 					 (val2 & (1<<14)));
 			}
 			break;
+		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481:
+			/* Clear LASI interrupt */
+			bnx2x_cl45_read(bp, params->port,
+				      ext_phy_type,
+				      ext_phy_addr,
+				      MDIO_PMA_DEVAD,
+				      MDIO_PMA_REG_LASI_STATUS, &val1);
+			DP(NETIF_MSG_LINK, "8481 LASI status reg = 0x%x\n",
+				 val1);
+
+			/* Check 10G-BaseT link status */
+			/* Check Global PMD signal ok */
+			bnx2x_cl45_read(bp, params->port, ext_phy_type,
+				      ext_phy_addr,
+				      MDIO_PMA_DEVAD, MDIO_PMA_REG_RX_SD,
+				      &rx_sd);
+			/* Check PCS block lock */
+			bnx2x_cl45_read(bp, params->port, ext_phy_type,
+				      ext_phy_addr,
+				      MDIO_PCS_DEVAD, MDIO_PCS_REG_STATUS,
+				      &pcs_status);
+			DP(NETIF_MSG_LINK, "8481 1.a = 0x%x, 1.20 = 0x%x\n",
+				 rx_sd, pcs_status);
+			if (rx_sd & pcs_status & 0x1) {
+				vars->line_speed = SPEED_10000;
+				ext_phy_link_up = 1;
+			} else {
+
+				/* Check 1000-BaseT link status */
+				bnx2x_cl45_read(bp, params->port, ext_phy_type,
+					      ext_phy_addr,
+					      MDIO_AN_DEVAD, 0xFFE1,
+					      &val1);
 
+				bnx2x_cl45_read(bp, params->port, ext_phy_type,
+					      ext_phy_addr,
+					      MDIO_AN_DEVAD, 0xFFE1,
+					      &val2);
+				DP(NETIF_MSG_LINK, "8481 7.FFE1 ="
+					     "0x%x-->0x%x\n", val1, val2);
+				if (val2 & (1<<2)) {
+					vars->line_speed = SPEED_1000;
+					ext_phy_link_up = 1;
+				}
+			}
+
+			break;
 		default:
 			DP(NETIF_MSG_LINK, "BAD XGXS ext_phy_config 0x%x\n",
 			   params->ext_phy_config);
@@ -4523,7 +4613,8 @@ static u8 bnx2x_link_initialize(struct link_params *params,
 
 	if (non_ext_phy ||
 	    (ext_phy_type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705) ||
-	    (ext_phy_type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726)) {
+	    (ext_phy_type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726) ||
+	    (ext_phy_type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481)) {
 		if (params->req_line_speed == SPEED_AUTO_NEG)
 			bnx2x_set_parallel_detection(params, vars->phy_flags);
 		bnx2x_init_internal_phy(params, vars);
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 2ee480b..0d2d556 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -7730,6 +7730,22 @@ static void __devinit bnx2x_link_settings_supported(struct bnx2x *bp,
 					       SUPPORTED_Asym_Pause);
 			break;
 
+		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481:
+			BNX2X_DEV_INFO("ext_phy_type 0x%x (BCM8481)\n",
+				       ext_phy_type);
+
+			bp->port.supported |= (SUPPORTED_10baseT_Half |
+					       SUPPORTED_10baseT_Full |
+					       SUPPORTED_100baseT_Half |
+					       SUPPORTED_100baseT_Full |
+					       SUPPORTED_1000baseT_Full |
+					       SUPPORTED_10000baseT_Full |
+					       SUPPORTED_TP |
+					       SUPPORTED_Autoneg |
+					       SUPPORTED_Pause |
+					       SUPPORTED_Asym_Pause);
+			break;
+
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_FAILURE:
 			BNX2X_ERR("XGXS PHY Failure detected 0x%x\n",
 				  bp->link_params.ext_phy_config);
@@ -8189,6 +8205,7 @@ static int bnx2x_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 			break;
 
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101:
+		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481:
 			cmd->port = PORT_TP;
 			break;
 
-- 
1.5.4.3




