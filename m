From: Yuval Mintz <yuval.mintz@qlogic.com>
Subject: [PATCH net 1/4] bnx2x: Fix link for KR with swapped polarity lane
Date: Wed, 11 Jun 2014 16:27:25 +0300
Message-ID: <1402493248-5427-2-git-send-email-yuval.mintz@qlogic.com>
References: <1402493248-5427-1-git-send-email-yuval.mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ariel.elior@qlogic.com>, Yaniv Rosner <yaniv.rosner@qlogic.com>,
	Yuval Mintz <yuval.mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:34465 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751510AbaFKN1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 09:27:38 -0400
In-Reply-To: <1402493248-5427-1-git-send-email-yuval.mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yaniv Rosner <yaniv.rosner@qlogic.com>

This avoids clearing the RX polarity setting in KR mode when polarity lane
is swapped, as otherwise this will result in failed link.

Signed-off-by: Yaniv Rosner <yaniv.rosner@qlogic.com>
Signed-off-by: Yuval Mintz <yuval.mintz@qlogic.com>
Signed-off-by: Ariel Elior <ariel.elior@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c | 25 ++++++++++++++++++------
 1 file changed, 19 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 9b6b3d7..b052f56 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -3703,7 +3703,8 @@ static void bnx2x_warpcore_restart_AN_KR(struct bnx2x_phy *phy,
 static void bnx2x_warpcore_enable_AN_KR(struct bnx2x_phy *phy,
 					struct link_params *params,
 					struct link_vars *vars) {
-	u16 lane, i, cl72_ctrl, an_adv = 0;
+	u16 lane, i, cl72_ctrl, an_adv = 0, val;
+	u32 wc_lane_config;
 	struct bnx2x *bp = params->bp;
 	static struct bnx2x_reg_set reg_set[] = {
 		{MDIO_WC_DEVAD, MDIO_WC_REG_SERDESDIGITAL_CONTROL1000X2, 0x7},
@@ -3822,15 +3823,27 @@ static void bnx2x_warpcore_enable_AN_KR(struct bnx2x_phy *phy,
 		/* Enable Auto-Detect to support 1G over CL37 as well */
 		bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
 				 MDIO_WC_REG_SERDESDIGITAL_CONTROL1000X1, 0x10);
-
+		wc_lane_config = REG_RD(bp, params->shmem_base +
+					offsetof(struct shmem_region, dev_info.
+					shared_hw_config.wc_lane_config));
+		bnx2x_cl45_read(bp, phy, MDIO_WC_DEVAD,
+				MDIO_WC_REG_RX0_PCI_CTRL + (0x10 * lane), &val);
 		/* Force cl48 sync_status LOW to avoid getting stuck in CL73
 		 * parallel-detect loop when CL73 and CL37 are enabled.
 		 */
-		CL22_WR_OVER_CL45(bp, phy, MDIO_REG_BANK_AER_BLOCK,
-				  MDIO_AER_BLOCK_AER_REG, 0);
+		val |= (1<<11);
+
+		/* Restore Polarity settings in case it was run over by
+		 * previous link owner
+		 */
+		if (wc_lane_config &
+		    (SHARED_HW_CFG_RX_LANE0_POL_FLIP_ENABLED << lane))
+			val |= (3<<2);
+		else
+			val &= ~(3<<2);
 		bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
-				 MDIO_WC_REG_RXB_ANA_RX_CONTROL_PCI, 0x0800);
-		bnx2x_set_aer_mmd(params, phy);
+				 MDIO_WC_REG_RX0_PCI_CTRL + (0x10 * lane),
+				 val);
 
 		bnx2x_disable_kr2(params, vars, phy);
 	}
-- 
1.8.1.4
