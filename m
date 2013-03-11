From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 08/13] bnx2x: Add RJ45 SFP module detection
Date: Mon, 11 Mar 2013 17:17:48 +0200
Message-ID: <1363015073-25743-9-git-send-email-yuvalmin@broadcom.com>
References: <1363015073-25743-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1468 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754104Ab3CKQZU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Mar 2013 12:25:20 -0400
In-Reply-To: <1363015073-25743-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yaniv Rosner <yanivr@broadcom.com>

Add RJ45 SFP module detection. In case the user set 10G link speed, and the
module doesn't support it, then force the speed to 1G and notify the user.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |   21 +++++++++++++--------
 1 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 31c5787..600f850 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -152,6 +152,7 @@
 #define SFP_EEPROM_CON_TYPE_ADDR		0x2
 	#define SFP_EEPROM_CON_TYPE_VAL_LC	0x7
 	#define SFP_EEPROM_CON_TYPE_VAL_COPPER	0x21
+	#define SFP_EEPROM_CON_TYPE_VAL_RJ45	0x22
 
 
 #define SFP_EEPROM_COMP_CODE_ADDR		0x3
@@ -8049,20 +8050,24 @@ static int bnx2x_get_edc_mode(struct bnx2x_phy *phy,
 		break;
 	}
 	case SFP_EEPROM_CON_TYPE_VAL_LC:
+	case SFP_EEPROM_CON_TYPE_VAL_RJ45:
 		check_limiting_mode = 1;
 		if ((val[1] & (SFP_EEPROM_COMP_CODE_SR_MASK |
 			       SFP_EEPROM_COMP_CODE_LR_MASK |
 			       SFP_EEPROM_COMP_CODE_LRM_MASK)) == 0) {
-			DP(NETIF_MSG_LINK, "1G Optic module detected\n");
+			DP(NETIF_MSG_LINK, "1G SFP module detected\n");
 			gport = params->port;
 			phy->media_type = ETH_PHY_SFP_1G_FIBER;
-			phy->req_line_speed = SPEED_1000;
-			if (!CHIP_IS_E1x(bp))
-				gport = BP_PATH(bp) + (params->port << 1);
-			netdev_err(bp->dev, "Warning: Link speed was forced to 1000Mbps."
-			      " Current SFP module in port %d is not"
-			      " compliant with 10G Ethernet\n",
-			 gport);
+			if (phy->req_line_speed != SPEED_1000) {
+				phy->req_line_speed = SPEED_1000;
+				if (!CHIP_IS_E1x(bp)) {
+					gport = BP_PATH(bp) +
+					(params->port << 1);
+				}
+				netdev_err(bp->dev,
+					   "Warning: Link speed was forced to 1000Mbps. Current SFP module in port %d is not compliant with 10G Ethernet\n",
+					   gport);
+			}
 		} else {
 			int idx, cfg_idx = 0;
 			DP(NETIF_MSG_LINK, "10G Optic module detected\n");
-- 
1.7.7.2
