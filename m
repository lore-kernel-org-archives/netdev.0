From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [net-next 05/10] bnx2x: Modify BCM8706 link init seq
Date: Thu, 5 Nov 2009 19:18:21 +0200
Message-ID: <1257441501.3390.52.camel@lb-tlvb-yanivr.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2445 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755714AbZKEPSY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Nov 2009 10:18:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Modify BCM8706 link initialization sequence so that first it link up between
Serdes and BCM8706, and only then between BCM8706 to network

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_link.c |   31 ++++++++++++++++++-------------
 1 files changed, 18 insertions(+), 13 deletions(-)

diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index 4c16a46..b08ff77 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -1930,6 +1930,8 @@ static u8 bnx2x_link_settings_status(struct link_params *params,
 		    (XGXS_EXT_PHY_TYPE(params->ext_phy_config) ==
 		     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705) ||
 		    (XGXS_EXT_PHY_TYPE(params->ext_phy_config) ==
+		     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706) ||
+		    (XGXS_EXT_PHY_TYPE(params->ext_phy_config) ==
 		     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726))) {
 			vars->autoneg = AUTO_NEG_ENABLED;
 
@@ -3772,19 +3774,6 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 				}
 			}
 			/* Force speed */
-			/* First enable LASI */
-			bnx2x_cl45_write(bp, params->port,
-				       ext_phy_type,
-				       ext_phy_addr,
-				       MDIO_PMA_DEVAD,
-				       MDIO_PMA_REG_RX_ALARM_CTRL,
-				       0x0400);
-			bnx2x_cl45_write(bp, params->port,
-				       ext_phy_type,
-				       ext_phy_addr,
-				       MDIO_PMA_DEVAD,
-				       MDIO_PMA_REG_LASI_CTRL, 0x0004);
-
 			if (params->req_line_speed == SPEED_10000) {
 				DP(NETIF_MSG_LINK, "XGXS 8706 force 10Gbps\n");
 
@@ -3794,6 +3783,9 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 					       MDIO_PMA_DEVAD,
 					       MDIO_PMA_REG_DIGITAL_CTRL,
 					       0x400);
+				bnx2x_cl45_write(bp, params->port, ext_phy_type,
+					       ext_phy_addr, MDIO_PMA_DEVAD,
+					       MDIO_PMA_REG_LASI_CTRL, 1);
 			} else {
 				/* Force 1Gbps using autoneg with 1G
 				advertisment */
@@ -3835,6 +3827,17 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 					       MDIO_AN_DEVAD,
 					       MDIO_AN_REG_CTRL,
 					       0x1200);
+				bnx2x_cl45_write(bp, params->port,
+					       ext_phy_type,
+					       ext_phy_addr,
+					       MDIO_PMA_DEVAD,
+					       MDIO_PMA_REG_RX_ALARM_CTRL,
+					       0x0400);
+				bnx2x_cl45_write(bp, params->port,
+					       ext_phy_type,
+					       ext_phy_addr,
+					       MDIO_PMA_DEVAD,
+					       MDIO_PMA_REG_LASI_CTRL, 0x0004);
 
 			}
 			bnx2x_save_bcm_spirom_ver(bp, params->port,
@@ -5952,6 +5955,7 @@ static u8 bnx2x_link_initialize(struct link_params *params,
 
 	if (non_ext_phy ||
 	    (ext_phy_type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705) ||
+	    (ext_phy_type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706) ||
 	    (ext_phy_type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726) ||
 	    (params->loopback_mode == LOOPBACK_EXT_PHY)) {
 		if (params->req_line_speed == SPEED_AUTO_NEG)
@@ -6421,6 +6425,7 @@ u8 bnx2x_link_update(struct link_params *params, struct link_vars *vars)
 
 	if ((ext_phy_type != PORT_HW_CFG_SERDES_EXT_PHY_TYPE_DIRECT) &&
 	    (ext_phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705) &&
+	    (ext_phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706) &&
 	    (ext_phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726) &&
 	    (ext_phy_link_up && !vars->phy_link_up))
 		bnx2x_init_internal_phy(params, vars, 0);
-- 
1.6.5.2




