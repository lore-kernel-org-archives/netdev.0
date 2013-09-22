From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net 3/5] bnx2x: 57840 non-external loopback test fail on
 1G
Date: Sun, 22 Sep 2013 14:59:24 +0300
Message-ID: <1379851166-11959-4-git-send-email-yanivr@broadcom.com>
References: <1379851166-11959-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Yaniv Rosner" <yanivr@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4018 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753135Ab3IVL75 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Sep 2013 07:59:57 -0400
In-Reply-To: <1379851166-11959-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

when 1G-optic module was plugged in, internal loopback test failed because the
driver used to check the optic module (with no need), and for 1G optic module,
the link speed was forced down to 1G, while the XMAC (10G MAC) was enabled.
This patch avoid accessing optic module in case internal loopback was selected,
and update the link speed in case 1G optic module was detected during init
stage.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |   17 +++++++++++++----
 1 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 84798bb..5c6d46c 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -4523,10 +4523,14 @@ static void bnx2x_warpcore_config_init(struct bnx2x_phy *phy,
 			 * enabled transmitter to avoid current leakage in case
 			 * no module is connected
 			 */
-			if (bnx2x_is_sfp_module_plugged(phy, params))
-				bnx2x_sfp_module_detection(phy, params);
-			else
-				bnx2x_sfp_e3_set_transmitter(params, phy, 1);
+			if ((params->loopback_mode == LOOPBACK_NONE) ||
+			    (params->loopback_mode == LOOPBACK_EXT)) {
+				if (bnx2x_is_sfp_module_plugged(phy, params))
+					bnx2x_sfp_module_detection(phy, params);
+				else
+					bnx2x_sfp_e3_set_transmitter(params,
+								     phy, 1);
+			}
 
 			bnx2x_warpcore_config_sfi(phy, params);
 			break;
@@ -6528,6 +6532,11 @@ static int bnx2x_link_initialize(struct link_params *params,
 			params->phy[INT_PHY].config_init(phy, params, vars);
 	}
 
+	/* Re-read this value in case it was changed inside config_init due to
+	 * limitations of optic module
+	 */
+	vars->line_speed = params->phy[INT_PHY].req_line_speed;
+
 	/* Init external phy*/
 	if (non_ext_phy) {
 		if (params->phy[INT_PHY].supported &
-- 
1.7.1
