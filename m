From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net 07/10] bnx2x: Fix BCM84833 link
Date: Wed, 3 Aug 2011 11:59:53 +0300
Message-ID: <1312361993.21665.97.camel@lb-tlvb-dmitry.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2501 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753305Ab1HCJAJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Aug 2011 05:00:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BCM84833 fail to link due to incorrect auto-negotiation setting.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_link.c |   21 ++++++++++++---------
 1 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index 6a3fdf8..cf8b8d1 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -9268,7 +9268,13 @@ static int bnx2x_848xx_cmn_config_init(struct bnx2x_phy *phy,
 	if (phy->req_duplex == DUPLEX_FULL)
 		autoneg_val |= (1<<8);
 
-	bnx2x_cl45_write(bp, phy,
+	/*
+	 * Always write this if this is not 84833.
+	 * For 84833, write it only when it's a forced speed.
+	 */
+	if ((phy->type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833) ||
+		((autoneg_val & (1<<12)) == 0))
+		bnx2x_cl45_write(bp, phy,
 			 MDIO_AN_DEVAD,
 			 MDIO_AN_REG_8481_LEGACY_MII_CTRL, autoneg_val);
 
@@ -9282,13 +9288,12 @@ static int bnx2x_848xx_cmn_config_init(struct bnx2x_phy *phy,
 			bnx2x_cl45_write(bp, phy,
 				 MDIO_AN_DEVAD, MDIO_AN_REG_CTRL,
 				 0x3200);
-	} else if (phy->req_line_speed != SPEED_10 &&
-		   phy->req_line_speed != SPEED_100) {
+	} else
 		bnx2x_cl45_write(bp, phy,
 				 MDIO_AN_DEVAD,
 				 MDIO_AN_REG_8481_10GBASE_T_AN_CTRL,
 				 1);
-	}
+
 	/* Save spirom version */
 	bnx2x_save_848xx_spirom_version(phy, params);
 
@@ -9781,11 +9786,9 @@ static void bnx2x_848x3_link_reset(struct bnx2x_phy *phy,
 		bnx2x_cl45_read(bp, phy,
 				MDIO_CTL_DEVAD,
 				0x400f, &val16);
-		/* Put to low power mode on newer FW */
-		if ((val16 & 0x303f) > 0x1009)
-			bnx2x_cl45_write(bp, phy,
-					MDIO_PMA_DEVAD,
-					MDIO_PMA_REG_CTRL, 0x800);
+		bnx2x_cl45_write(bp, phy,
+				MDIO_PMA_DEVAD,
+				MDIO_PMA_REG_CTRL, 0x800);
 	}
 }
 
-- 
1.7.1








