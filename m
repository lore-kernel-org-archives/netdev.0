From: Yaniv Rosner <yanivr@broadcom.com>
Subject: [PATCH net 2/5] bnx2x: Fix passive DAC cable detection
Date: Wed, 1 Jan 2014 11:06:42 +0200
Message-ID: <1388567205-20210-3-git-send-email-yanivr@broadcom.com>
References: <1388567205-20210-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
	Yaniv Rosner <yanivr@broadcom.com>,
	Ariel Elior <ariele@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:21489 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752519AbaAAJIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jan 2014 04:08:07 -0500
In-Reply-To: <1388567205-20210-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix Passive DAC detection for specific cables, such that even in case
SFP_CABLE_TECHNOLOGY option is not set in the EEPROM (offset 8), treat it as a
passive DAC cable, since some cables don't have this indication.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |   21 ++++++++++++---------
 1 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index efbf729..000b6ee 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -8133,17 +8133,20 @@ static int bnx2x_get_edc_mode(struct bnx2x_phy *phy,
 				*edc_mode = EDC_MODE_ACTIVE_DAC;
 			else
 				check_limiting_mode = 1;
-		} else if (copper_module_type &
-			SFP_EEPROM_FC_TX_TECH_BITMASK_COPPER_PASSIVE) {
+		} else {
+			*edc_mode = EDC_MODE_PASSIVE_DAC;
+			/* Even in case PASSIVE_DAC indication is not set,
+			 * treat it as a passive DAC cable, since some cables
+			 * don't have this indication.
+			 */
+			if (copper_module_type &
+			    SFP_EEPROM_FC_TX_TECH_BITMASK_COPPER_PASSIVE) {
 				DP(NETIF_MSG_LINK,
 				   "Passive Copper cable detected\n");
-				*edc_mode =
-				      EDC_MODE_PASSIVE_DAC;
-		} else {
-			DP(NETIF_MSG_LINK,
-			   "Unknown copper-cable-type 0x%x !!!\n",
-			   copper_module_type);
-			return -EINVAL;
+			} else {
+				DP(NETIF_MSG_LINK,
+				   "Unknown copper-cable-type\n");
+			}
 		}
 		break;
 	}
-- 
1.7.1
