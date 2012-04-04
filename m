From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [net 02/10] bnx2x: Fix BCM57810-KR FC
Date: Wed, 4 Apr 2012 14:28:55 +0300
Message-ID: <1333538942-9904-3-git-send-email-yanivr@broadcom.com>
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
	id S1755930Ab2DDJ3c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Apr 2012 05:29:32 -0400
In-Reply-To: <1333538942-9904-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix 57810-KR flow-control handling link is achieved via CL37 AN.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |   27 ++++++++++++++++++++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h  |    4 +++
 2 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 7e2ebba..8c00bbc 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -3655,6 +3655,33 @@ static void bnx2x_ext_phy_update_adv_fc(struct bnx2x_phy *phy,
 	if (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM54618SE) {
 		bnx2x_cl22_read(bp, phy, 0x4, &ld_pause);
 		bnx2x_cl22_read(bp, phy, 0x5, &lp_pause);
+	} else if (CHIP_IS_E3(bp) &&
+		SINGLE_MEDIA_DIRECT(params)) {
+		u8 lane = bnx2x_get_warpcore_lane(phy, params);
+		u16 gp_status, gp_mask;
+		bnx2x_cl45_read(bp, phy,
+				MDIO_AN_DEVAD, MDIO_WC_REG_GP2_STATUS_GP_2_4,
+				&gp_status);
+		gp_mask = (MDIO_WC_REG_GP2_STATUS_GP_2_4_CL73_AN_CMPL |
+			   MDIO_WC_REG_GP2_STATUS_GP_2_4_CL37_LP_AN_CAP) <<
+			lane;
+		if ((gp_status & gp_mask) == gp_mask) {
+			bnx2x_cl45_read(bp, phy, MDIO_AN_DEVAD,
+					MDIO_AN_REG_ADV_PAUSE, &ld_pause);
+			bnx2x_cl45_read(bp, phy, MDIO_AN_DEVAD,
+					MDIO_AN_REG_LP_AUTO_NEG, &lp_pause);
+		} else {
+			bnx2x_cl45_read(bp, phy, MDIO_AN_DEVAD,
+					MDIO_AN_REG_CL37_FC_LD, &ld_pause);
+			bnx2x_cl45_read(bp, phy, MDIO_AN_DEVAD,
+					MDIO_AN_REG_CL37_FC_LP, &lp_pause);
+			ld_pause = ((ld_pause &
+				     MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH)
+				    << 3);
+			lp_pause = ((lp_pause &
+				     MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH)
+				    << 3);
+		}
 	} else {
 		bnx2x_cl45_read(bp, phy,
 				MDIO_AN_DEVAD,
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
index ecc7fa6..1ea2b95 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
@@ -6944,6 +6944,10 @@ Theotherbitsarereservedandshouldbezero*/
 #define MDIO_WC_REG_GP2_STATUS_GP_2_2			0x81d2
 #define MDIO_WC_REG_GP2_STATUS_GP_2_3			0x81d3
 #define MDIO_WC_REG_GP2_STATUS_GP_2_4			0x81d4
+#define MDIO_WC_REG_GP2_STATUS_GP_2_4_CL73_AN_CMPL 0x1000
+#define MDIO_WC_REG_GP2_STATUS_GP_2_4_CL37_AN_CMPL 0x0100
+#define MDIO_WC_REG_GP2_STATUS_GP_2_4_CL37_LP_AN_CAP 0x0010
+#define MDIO_WC_REG_GP2_STATUS_GP_2_4_CL37_AN_CAP 0x1
 #define MDIO_WC_REG_UC_INFO_B0_DEAD_TRAP		0x81EE
 #define MDIO_WC_REG_UC_INFO_B1_VERSION			0x81F0
 #define MDIO_WC_REG_UC_INFO_B1_FIRMWARE_MODE		0x81F2
-- 
1.7.7.1
