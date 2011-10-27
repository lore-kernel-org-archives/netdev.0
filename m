From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [net v2 4/7] bnx2x: Fix 54618se LED behavior
Date: Thu, 27 Oct 2011 17:09:48 +0200
Message-ID: <1319728191-24938-5-git-send-email-yanivr@broadcom.com>
References: <1319728191-24938-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3816 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753008Ab1J0NKK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Oct 2011 09:10:10 -0400
In-Reply-To: <1319728191-24938-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |   44 +++++++++++----------
 1 files changed, 23 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 23333e0..bce203f 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -5994,7 +5994,13 @@ int bnx2x_set_led(struct link_params *params,
 		       SHARED_HW_CFG_LED_MAC1);
 
 		tmp = EMAC_RD(bp, EMAC_REG_EMAC_LED);
-		EMAC_WR(bp, EMAC_REG_EMAC_LED, (tmp | EMAC_LED_OVERRIDE));
+		if (params->phy[EXT_PHY1].type ==
+			  PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM54618SE)
+			EMAC_WR(bp, EMAC_REG_EMAC_LED, tmp & 0xfff1);
+		else {
+			EMAC_WR(bp, EMAC_REG_EMAC_LED,
+				(tmp | EMAC_LED_OVERRIDE));
+		}
 		break;
 
 	case LED_MODE_OPER:
@@ -6047,8 +6053,15 @@ int bnx2x_set_led(struct link_params *params,
 			else
 				REG_WR(bp, NIG_REG_LED_MODE_P0 + port*4,
 				       hw_led_mode);
+		} else if ((params->phy[EXT_PHY1].type ==
+			    PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM54618SE) &&
+			   (mode != LED_MODE_OPER)) {
+			REG_WR(bp, NIG_REG_LED_MODE_P0 + port*4, 0);
+			tmp = EMAC_RD(bp, EMAC_REG_EMAC_LED);
+			EMAC_WR(bp, EMAC_REG_EMAC_LED, tmp | 0x3);
 		} else
-			REG_WR(bp, NIG_REG_LED_MODE_P0 + port*4, hw_led_mode);
+			REG_WR(bp, NIG_REG_LED_MODE_P0 + port*4,
+			       hw_led_mode);
 
 		REG_WR(bp, NIG_REG_LED_CONTROL_OVERRIDE_TRAFFIC_P0 + port*4, 0);
 		/* Set blinking rate to ~15.9Hz */
@@ -6060,8 +6073,13 @@ int bnx2x_set_led(struct link_params *params,
 			       LED_BLINK_RATE_VAL_E1X_E2);
 		REG_WR(bp, NIG_REG_LED_CONTROL_BLINK_RATE_ENA_P0 +
 		       port*4, 1);
-		tmp = EMAC_RD(bp, EMAC_REG_EMAC_LED);
-		EMAC_WR(bp, EMAC_REG_EMAC_LED, (tmp & (~EMAC_LED_OVERRIDE)));
+		if ((params->phy[EXT_PHY1].type !=
+		     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM54618SE) &&
+		    (mode != LED_MODE_OPER)) {
+			tmp = EMAC_RD(bp, EMAC_REG_EMAC_LED);
+			EMAC_WR(bp, EMAC_REG_EMAC_LED,
+				(tmp & (~EMAC_LED_OVERRIDE)));
+		}
 
 		if (CHIP_IS_E1(bp) &&
 		    ((speed == SPEED_2500) ||
@@ -10309,22 +10327,6 @@ static int bnx2x_54618se_config_init(struct bnx2x_phy *phy,
 	return 0;
 }
 
-static void bnx2x_54618se_set_link_led(struct bnx2x_phy *phy,
-				       struct link_params *params, u8 mode)
-{
-	struct bnx2x *bp = params->bp;
-	DP(NETIF_MSG_LINK, "54618SE set link led (mode=%x)\n", mode);
-	switch (mode) {
-	case LED_MODE_FRONT_PANEL_OFF:
-	case LED_MODE_OFF:
-	case LED_MODE_OPER:
-	case LED_MODE_ON:
-	default:
-		break;
-	}
-	return;
-}
-
 static void bnx2x_54618se_link_reset(struct bnx2x_phy *phy,
 				     struct link_params *params)
 {
@@ -11101,7 +11103,7 @@ static struct bnx2x_phy phy_54618se = {
 	.config_loopback = (config_loopback_t)bnx2x_54618se_config_loopback,
 	.format_fw_ver	= (format_fw_ver_t)NULL,
 	.hw_reset	= (hw_reset_t)NULL,
-	.set_link_led	= (set_link_led_t)bnx2x_54618se_set_link_led,
+	.set_link_led	= (set_link_led_t)NULL,
 	.phy_specific_func = (phy_specific_func_t)NULL
 };
 /*****************************************************************/
-- 
1.7.2.2
