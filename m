From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [net 05/10] bnx2x: Restore 1G LED on BCM57712+BCM8727 designs.
Date: Wed, 4 Apr 2012 14:28:58 +0300
Message-ID: <1333538942-9904-6-git-send-email-yanivr@broadcom.com>
References: <1333538942-9904-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2740 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756109Ab2DDJ3h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Apr 2012 05:29:37 -0400
In-Reply-To: <1333538942-9904-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix no-LED problem when link speed is 1G on BCM57712 + BCM8727 designs, by
removing a logic error checking for a different PHY.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |   33 ++++++++++++----------
 1 files changed, 18 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 1e2fea3..1438da8 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -6216,12 +6216,14 @@ int bnx2x_set_led(struct link_params *params,
 
 		tmp = EMAC_RD(bp, EMAC_REG_EMAC_LED);
 		if (params->phy[EXT_PHY1].type ==
-			  PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM54618SE)
-			EMAC_WR(bp, EMAC_REG_EMAC_LED, tmp & 0xfff1);
-		else {
-			EMAC_WR(bp, EMAC_REG_EMAC_LED,
-				(tmp | EMAC_LED_OVERRIDE));
-		}
+			PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM54618SE)
+			tmp &= ~(EMAC_LED_1000MB_OVERRIDE |
+				EMAC_LED_100MB_OVERRIDE |
+				EMAC_LED_10MB_OVERRIDE);
+		else
+			tmp |= EMAC_LED_OVERRIDE;
+
+		EMAC_WR(bp, EMAC_REG_EMAC_LED, tmp);
 		break;
 
 	case LED_MODE_OPER:
@@ -6276,10 +6278,15 @@ int bnx2x_set_led(struct link_params *params,
 				       hw_led_mode);
 		} else if ((params->phy[EXT_PHY1].type ==
 			    PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM54618SE) &&
-			   (mode != LED_MODE_OPER)) {
+			   (mode == LED_MODE_ON)) {
 			REG_WR(bp, NIG_REG_LED_MODE_P0 + port*4, 0);
 			tmp = EMAC_RD(bp, EMAC_REG_EMAC_LED);
-			EMAC_WR(bp, EMAC_REG_EMAC_LED, tmp | 0x3);
+			EMAC_WR(bp, EMAC_REG_EMAC_LED, tmp |
+				EMAC_LED_OVERRIDE | EMAC_LED_1000MB_OVERRIDE);
+			/* Break here; otherwise, it'll disable the
+			 * intended override.
+			 */
+			break;
 		} else
 			REG_WR(bp, NIG_REG_LED_MODE_P0 + port*4,
 			       hw_led_mode);
@@ -6294,13 +6301,9 @@ int bnx2x_set_led(struct link_params *params,
 			       LED_BLINK_RATE_VAL_E1X_E2);
 		REG_WR(bp, NIG_REG_LED_CONTROL_BLINK_RATE_ENA_P0 +
 		       port*4, 1);
-		if ((params->phy[EXT_PHY1].type !=
-		     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM54618SE) &&
-		    (mode != LED_MODE_OPER)) {
-			tmp = EMAC_RD(bp, EMAC_REG_EMAC_LED);
-			EMAC_WR(bp, EMAC_REG_EMAC_LED,
-				(tmp & (~EMAC_LED_OVERRIDE)));
-		}
+		tmp = EMAC_RD(bp, EMAC_REG_EMAC_LED);
+		EMAC_WR(bp, EMAC_REG_EMAC_LED,
+			(tmp & (~EMAC_LED_OVERRIDE)));
 
 		if (CHIP_IS_E1(bp) &&
 		    ((speed == SPEED_2500) ||
-- 
1.7.7.1
