From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net 1/7] bnx2x: Fix 57810 1G-KR link against certain
 switches.
Date: Wed, 31 Oct 2012 17:46:52 +0200
Message-ID: <1351698418-10005-2-git-send-email-dmitry@broadcom.com>
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
Received: from mms1.broadcom.com ([216.31.210.17]:3321 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757618Ab2JaPrK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2012 11:47:10 -0400
In-Reply-To: <1351698418-10005-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yaniv Rosner <yanivr@broadcom.com>

Fix 1G KR link by restoring CL72 misc control register to default value rather
than 0.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Barak Witkowski <barak@broadcom.com>
Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index e2e45ee..290e12a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -3545,12 +3545,11 @@ static void bnx2x_warpcore_set_lpi_passthrough(struct bnx2x_phy *phy,
 static void bnx2x_warpcore_enable_AN_KR(struct bnx2x_phy *phy,
 					struct link_params *params,
 					struct link_vars *vars) {
-	u16 val16 = 0, lane, i;
+	u16 val16 = 0, lane, i, cl72_ctrl;
 	struct bnx2x *bp = params->bp;
 	static struct bnx2x_reg_set reg_set[] = {
 		{MDIO_WC_DEVAD, MDIO_WC_REG_SERDESDIGITAL_CONTROL1000X2, 0x7},
 		{MDIO_AN_DEVAD, MDIO_WC_REG_PAR_DET_10G_CTRL, 0},
-		{MDIO_WC_DEVAD, MDIO_WC_REG_CL72_USERB0_CL72_MISC1_CONTROL, 0},
 		{MDIO_WC_DEVAD, MDIO_WC_REG_XGXSBLK1_LANECTRL0, 0xff},
 		{MDIO_WC_DEVAD, MDIO_WC_REG_XGXSBLK1_LANECTRL1, 0x5555},
 		{MDIO_PMA_DEVAD, MDIO_WC_REG_IEEE0BLK_AUTONEGNP, 0x0},
@@ -3565,6 +3564,13 @@ static void bnx2x_warpcore_enable_AN_KR(struct bnx2x_phy *phy,
 		bnx2x_cl45_write(bp, phy, reg_set[i].devad, reg_set[i].reg,
 				 reg_set[i].val);
 
+	bnx2x_cl45_read(bp, phy, MDIO_WC_DEVAD,
+		MDIO_WC_REG_CL72_USERB0_CL72_MISC1_CONTROL, &cl72_ctrl);
+	cl72_ctrl &= 0xf8ff;
+	cl72_ctrl |= 0x3800;
+	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
+		MDIO_WC_REG_CL72_USERB0_CL72_MISC1_CONTROL, cl72_ctrl);
+
 	/* Check adding advertisement for 1G KX */
 	if (((vars->line_speed == SPEED_AUTO_NEG) &&
 	     (phy->speed_cap_mask & PORT_HW_CFG_SPEED_CAPABILITY_D0_1G)) ||
-- 
1.7.7.2
