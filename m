From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net 2/7] bnx2x: Fix link down in 57712 following LFA
Date: Wed, 31 Oct 2012 17:46:53 +0200
Message-ID: <1351698418-10005-3-git-send-email-dmitry@broadcom.com>
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
Received: from mms3.broadcom.com ([216.31.210.19]:2865 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757618Ab2JaPrP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2012 11:47:15 -0400
In-Reply-To: <1351698418-10005-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yaniv Rosner <yanivr@broadcom.com>

In case of link flap avoidance between PXE boot and bnx2x, set the appropriate
PHY DEVAD even if LFA kicks in.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Barak Witkowski <barak@broadcom.com>
Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |   23 +++++++++++++++++----
 1 files changed, 18 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 290e12a..f2436ea 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -3295,6 +3295,21 @@ static void bnx2x_serdes_deassert(struct bnx2x *bp, u8 port)
 	       DEFAULT_PHY_DEV_ADDR);
 }
 
+static void bnx2x_xgxs_specific_func(struct bnx2x_phy *phy,
+				     struct link_params *params,
+				     u32 action)
+{
+	struct bnx2x *bp = params->bp;
+	switch (action) {
+	case PHY_INIT:
+		/* Set correct devad */
+		REG_WR(bp, NIG_REG_XGXS0_CTRL_MD_ST + params->port*0x18, 0);
+		REG_WR(bp, NIG_REG_XGXS0_CTRL_MD_DEVAD + params->port*0x18,
+		       phy->def_md_devad);
+		break;
+	}
+}
+
 static void bnx2x_xgxs_deassert(struct link_params *params)
 {
 	struct bnx2x *bp = params->bp;
@@ -3309,10 +3324,8 @@ static void bnx2x_xgxs_deassert(struct link_params *params)
 	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_3_CLEAR, val);
 	udelay(500);
 	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_3_SET, val);
-
-	REG_WR(bp, NIG_REG_XGXS0_CTRL_MD_ST + port*0x18, 0);
-	REG_WR(bp, NIG_REG_XGXS0_CTRL_MD_DEVAD + port*0x18,
-	       params->phy[INT_PHY].def_md_devad);
+	bnx2x_xgxs_specific_func(&params->phy[INT_PHY], params,
+				 PHY_INIT);
 }
 
 static void bnx2x_calc_ieee_aneg_adv(struct bnx2x_phy *phy,
@@ -10999,7 +11012,7 @@ static struct bnx2x_phy phy_xgxs = {
 	.format_fw_ver	= (format_fw_ver_t)NULL,
 	.hw_reset	= (hw_reset_t)NULL,
 	.set_link_led	= (set_link_led_t)NULL,
-	.phy_specific_func = (phy_specific_func_t)NULL
+	.phy_specific_func = (phy_specific_func_t)bnx2x_xgxs_specific_func
 };
 static struct bnx2x_phy phy_warpcore = {
 	.type		= PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT,
-- 
1.7.7.2
