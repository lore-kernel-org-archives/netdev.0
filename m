From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net-next 09/10] bnx2x: Remove support for emulation/FPGA
Date: Mon, 31 Jan 2011 16:22:53 +0200
Message-ID: <1296483773.17181.119.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3424 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753853Ab1AaOZw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jan 2011 09:25:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove unneeded support for emulation/FPGA from the code

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_link.c |   88 +---------------------------------------
 1 files changed, 1 insertions(+), 87 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index 9ef15ce..ad72f82 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -521,22 +521,6 @@ static u8 bnx2x_emac_enable(struct link_params *params,
 	/* enable emac and not bmac */
 	REG_WR(bp, NIG_REG_EGRESS_EMAC0_PORT + port*4, 1);
 
-	/* for paladium */
-	if (CHIP_REV_IS_EMUL(bp)) {
-		/* Use lane 1 (of lanes 0-3) */
-		REG_WR(bp, NIG_REG_XGXS_LANE_SEL_P0 + port*4, 1);
-		REG_WR(bp, NIG_REG_XGXS_SERDES0_MODE_SEL + port*4, 1);
-	}
-	/* for fpga */
-	else
-
-	if (CHIP_REV_IS_FPGA(bp)) {
-		/* Use lane 1 (of lanes 0-3) */
-		DP(NETIF_MSG_LINK, "bnx2x_emac_enable: Setting FPGA\n");
-
-		REG_WR(bp, NIG_REG_XGXS_LANE_SEL_P0 + port*4, 1);
-		REG_WR(bp, NIG_REG_XGXS_SERDES0_MODE_SEL + port*4, 0);
-	} else
 	/* ASIC */
 	if (vars->phy_flags & PHY_XGXS_FLAG) {
 		u32 ser_lane = ((params->lane_config &
@@ -654,15 +638,7 @@ static u8 bnx2x_emac_enable(struct link_params *params,
 	REG_WR(bp, NIG_REG_EMAC0_PAUSE_OUT_EN + port*4, val);
 	REG_WR(bp, NIG_REG_EGRESS_EMAC0_OUT_EN + port*4, 0x1);
 
-	if (CHIP_REV_IS_EMUL(bp)) {
-		/* take the BigMac out of reset */
-		REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_SET,
-		       (MISC_REGISTERS_RESET_REG_2_RST_BMAC0 << port));
-
-		/* enable access for bmac registers */
-		REG_WR(bp, NIG_REG_BMAC0_REGS_OUT_EN + port*4, 0x1);
-	} else
-		REG_WR(bp, NIG_REG_BMAC0_REGS_OUT_EN + port*4, 0x0);
+	REG_WR(bp, NIG_REG_BMAC0_REGS_OUT_EN + port*4, 0x0);
 
 	vars->mac_type = MAC_TYPE_EMAC;
 	return 0;
@@ -1086,14 +1062,6 @@ static u8 bnx2x_bmac1_enable(struct link_params *params,
 	wb_data[1] = 0;
 	REG_WR_DMAE(bp, bmac_addr + BIGMAC_REGISTER_RX_LLFC_MSG_FLDS,
 		    wb_data, 2);
-	/* fix for emulation */
-	if (CHIP_REV_IS_EMUL(bp)) {
-		wb_data[0] = 0xf000;
-		wb_data[1] = 0;
-		REG_WR_DMAE(bp,	bmac_addr + BIGMAC_REGISTER_TX_PAUSE_THRESHOLD,
-			    wb_data, 2);
-	}
-
 
 	return 0;
 }
@@ -7710,57 +7678,6 @@ u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 	set_phy_vars(params);
 
 	DP(NETIF_MSG_LINK, "Num of phys on board: %d\n", params->num_phys);
-	if (CHIP_REV_IS_FPGA(bp)) {
-
-		vars->link_up = 1;
-		vars->line_speed = SPEED_10000;
-		vars->duplex = DUPLEX_FULL;
-		vars->flow_ctrl = BNX2X_FLOW_CTRL_NONE;
-		vars->link_status = (LINK_STATUS_LINK_UP | LINK_10GTFD);
-		/* enable on E1.5 FPGA */
-		if (CHIP_IS_E1H(bp)) {
-			vars->flow_ctrl |=
-					(BNX2X_FLOW_CTRL_TX |
-					 BNX2X_FLOW_CTRL_RX);
-			vars->link_status |=
-					(LINK_STATUS_TX_FLOW_CONTROL_ENABLED |
-					 LINK_STATUS_RX_FLOW_CONTROL_ENABLED);
-		}
-
-		bnx2x_emac_enable(params, vars, 0);
-		if (!(CHIP_IS_E2(bp)))
-			bnx2x_pbf_update(params, vars->flow_ctrl,
-					 vars->line_speed);
-		/* disable drain */
-		REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE + params->port*4, 0);
-
-		/* update shared memory */
-		bnx2x_update_mng(params, vars->link_status);
-
-		return 0;
-
-	} else
-	if (CHIP_REV_IS_EMUL(bp)) {
-
-		vars->link_up = 1;
-		vars->line_speed = SPEED_10000;
-		vars->duplex = DUPLEX_FULL;
-		vars->flow_ctrl = BNX2X_FLOW_CTRL_NONE;
-		vars->link_status = (LINK_STATUS_LINK_UP | LINK_10GTFD);
-
-		bnx2x_bmac_enable(params, vars, 0);
-
-		bnx2x_pbf_update(params, vars->flow_ctrl, vars->line_speed);
-		/* Disable drain */
-		REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE
-				    + params->port*4, 0);
-
-		/* update shared memory */
-		bnx2x_update_mng(params, vars->link_status);
-
-		return 0;
-
-	} else
 	if (params->loopback_mode == LOOPBACK_BMAC) {
 
 		vars->link_up = 1;
@@ -8292,9 +8209,6 @@ u8 bnx2x_common_init_phy(struct bnx2x *bp, u32 shmem_base_path[],
 	u32 ext_phy_type, ext_phy_config;
 	DP(NETIF_MSG_LINK, "Begin common phy init\n");
 
-	if (CHIP_REV_IS_EMUL(bp))
-		return 0;
-
 	/* Check if common init was already done */
 	phy_ver = REG_RD(bp, shmem_base_path[0] +
 			 offsetof(struct shmem_region,
-- 
1.7.1





