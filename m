From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net 5/7] bnx2x: Fix unrecognized SFP+ module after
 driver is loaded
Date: Wed, 31 Oct 2012 17:46:56 +0200
Message-ID: <1351698418-10005-6-git-send-email-dmitry@broadcom.com>
References: <1351698418-10005-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Yaniv Rosner" <yanivr@broadcom.com>,
	"Barak Witkowski" <barak@broadcom.com>,
	"Dmitry Kravkov" <dmitry@broadcom.com>
To: ariele@broadcom.com, eilong@broadcom.com, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2910 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965146Ab2JaPrT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2012 11:47:19 -0400
In-Reply-To: <1351698418-10005-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yaniv Rosner <yanivr@broadcom.com>

When SFP+ module is plugged in after driver is already loaded, it may not be
recognized, so set SFP module recognition time up to 300ms, without resetting
the module power in the middle.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Barak Witkowski <barak@broadcom.com>
Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |   22 +++++++++++++++-------
 1 files changed, 15 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 308ba42..679d45e 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -7634,7 +7634,7 @@ static void bnx2x_warpcore_power_module(struct link_params *params,
 static int bnx2x_warpcore_read_sfp_module_eeprom(struct bnx2x_phy *phy,
 						 struct link_params *params,
 						 u16 addr, u8 byte_cnt,
-						 u8 *o_buf)
+						 u8 *o_buf, u8 is_init)
 {
 	int rc = 0;
 	u8 i, j = 0, cnt = 0;
@@ -7651,10 +7651,10 @@ static int bnx2x_warpcore_read_sfp_module_eeprom(struct bnx2x_phy *phy,
 	/* 4 byte aligned address */
 	addr32 = addr & (~0x3);
 	do {
-		if (cnt == I2C_WA_PWR_ITER) {
+		if ((!is_init) && (cnt == I2C_WA_PWR_ITER)) {
 			bnx2x_warpcore_power_module(params, phy, 0);
 			/* Note that 100us are not enough here */
-			usleep_range(1000,1000);
+			usleep_range(1000, 2000);
 			bnx2x_warpcore_power_module(params, phy, 1);
 		}
 		rc = bnx2x_bsc_read(params, phy, 0xa0, addr32, 0, byte_cnt,
@@ -7774,7 +7774,7 @@ int bnx2x_read_sfp_module_eeprom(struct bnx2x_phy *phy,
 	break;
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT:
 		rc = bnx2x_warpcore_read_sfp_module_eeprom(phy, params, addr,
-							   byte_cnt, o_buf);
+							   byte_cnt, o_buf, 0);
 	break;
 	}
 	return rc;
@@ -7978,6 +7978,7 @@ static int bnx2x_wait_for_sfp_module_initialized(struct bnx2x_phy *phy,
 
 {
 	u8 val;
+	int rc;
 	struct bnx2x *bp = params->bp;
 	u16 timeout;
 	/* Initialization time after hot-plug may take up to 300ms for
@@ -7985,8 +7986,14 @@ static int bnx2x_wait_for_sfp_module_initialized(struct bnx2x_phy *phy,
 	 */
 
 	for (timeout = 0; timeout < 60; timeout++) {
-		if (bnx2x_read_sfp_module_eeprom(phy, params, 1, 1, &val)
-		    == 0) {
+		if (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT)
+			rc = bnx2x_warpcore_read_sfp_module_eeprom(phy,
+								   params, 1,
+								   1, &val, 1);
+		else
+			rc = bnx2x_read_sfp_module_eeprom(phy, params, 1, 1,
+							  &val);
+		if (rc == 0) {
 			DP(NETIF_MSG_LINK,
 			   "SFP+ module initialization took %d ms\n",
 			   timeout * 5);
@@ -7994,7 +8001,8 @@ static int bnx2x_wait_for_sfp_module_initialized(struct bnx2x_phy *phy,
 		}
 		usleep_range(5000, 10000);
 	}
-	return -EINVAL;
+	rc = bnx2x_read_sfp_module_eeprom(phy, params, 1, 1, &val);
+	return rc;
 }
 
 static void bnx2x_8727_power_module(struct bnx2x *bp,
-- 
1.7.7.2
