From: "Yaniv Rosner" <yaniv.rosner@broadcom.com>
Subject: [PATCH net-next 2/8] bnx2x: Fix potential link issue In BCM8727
 based boards
Date: Wed, 1 Sep 2010 22:51:20 +0300
Message-ID: <1283370680.4403.133.camel@lb-tlvb-yanivr.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1286 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755177Ab0IAQdM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Sep 2010 12:33:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In BCM8727 based boards, setting default 10G link speed after link was
set to 1G may lead to link down issue. The problem was setting the right
value, but to the wrong registers 

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_link.c |   23 +++++++++++++----------
 drivers/net/bnx2x/bnx2x_reg.h  |    2 ++
 2 files changed, 15 insertions(+), 10 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index 9b4e7b3..cbacf8a 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -4239,8 +4239,10 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 			} else if ((params->req_line_speed ==
 				    SPEED_AUTO_NEG) &&
 				   ((params->speed_cap_mask &
-				     PORT_HW_CFG_SPEED_CAPABILITY_D0_1G))) {
-
+				     PORT_HW_CFG_SPEED_CAPABILITY_D0_1G)) &&
+				   ((params->speed_cap_mask &
+				     PORT_HW_CFG_SPEED_CAPABILITY_D0_10G) !=
+				    PORT_HW_CFG_SPEED_CAPABILITY_D0_10G)) {
 				DP(NETIF_MSG_LINK, "Setting 1G clause37\n");
 				bnx2x_cl45_write(bp, params->port, ext_phy_type,
 					       ext_phy_addr, MDIO_AN_DEVAD,
@@ -4253,17 +4255,18 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 				need to set the 10G registers although it is
 				default */
 				bnx2x_cl45_write(bp, params->port, ext_phy_type,
-					       ext_phy_addr, MDIO_AN_DEVAD,
-					       MDIO_AN_REG_CTRL, 0x0020);
+					      ext_phy_addr, MDIO_AN_DEVAD,
+					      MDIO_AN_REG_8727_MISC_CTRL,
+					      0x0020);
 				bnx2x_cl45_write(bp, params->port, ext_phy_type,
-					       ext_phy_addr, MDIO_AN_DEVAD,
-					       0x7, 0x0100);
+					      ext_phy_addr, MDIO_AN_DEVAD,
+					      MDIO_AN_REG_CL37_AN, 0x0100);
 				bnx2x_cl45_write(bp, params->port, ext_phy_type,
-					       ext_phy_addr, MDIO_PMA_DEVAD,
-					       MDIO_PMA_REG_CTRL, 0x2040);
+					      ext_phy_addr, MDIO_PMA_DEVAD,
+					      MDIO_PMA_REG_CTRL, 0x2040);
 				bnx2x_cl45_write(bp, params->port, ext_phy_type,
-					       ext_phy_addr, MDIO_PMA_DEVAD,
-					       MDIO_PMA_REG_10G_CTRL2, 0x0008);
+					      ext_phy_addr, MDIO_PMA_DEVAD,
+					      MDIO_PMA_REG_10G_CTRL2, 0x0008);
 			}
 
 			/* Set 2-wire transfer rate of SFP+ module EEPROM
diff --git a/drivers/net/bnx2x/bnx2x_reg.h b/drivers/net/bnx2x/bnx2x_reg.h
index a1f3bf0..c82e261 100644
--- a/drivers/net/bnx2x/bnx2x_reg.h
+++ b/drivers/net/bnx2x/bnx2x_reg.h
@@ -5211,6 +5211,8 @@ Theotherbitsarereservedandshouldbezero*/
 
 #define MDIO_AN_REG_8073_2_5G		0x8329
 
+#define MDIO_AN_REG_8727_MISC_CTRL	0x8309
+
 #define MDIO_AN_REG_8481_LEGACY_MII_CTRL	0xffe0
 #define MDIO_AN_REG_8481_LEGACY_AN_ADV		0xffe4
 #define MDIO_AN_REG_8481_1000T_CTRL		0xffe9
-- 
1.7.1




