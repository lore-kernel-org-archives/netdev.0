From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [net v2 3/7] bnx2x: Fix RX/TX problem caused by the MAC layer
Date: Thu, 27 Oct 2011 17:09:47 +0200
Message-ID: <1319728191-24938-4-git-send-email-yanivr@broadcom.com>
References: <1319728191-24938-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1462 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752954Ab1J0NKI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Oct 2011 09:10:08 -0400
In-Reply-To: <1319728191-24938-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a problem in which the host stops receiving data after
restarting the interface. This issue is caused by combination of incorrect
data path tap closure, along with missing MAC reset.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |   45 ++++++++++++++++------
 1 files changed, 33 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index a47db9d..23333e0 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -1494,6 +1494,18 @@ static void bnx2x_set_xumac_nig(struct link_params *params,
 	       NIG_REG_P0_MAC_PAUSE_OUT_EN, tx_pause_en);
 }
 
+static void bnx2x_umac_disable(struct link_params *params)
+{
+	u32 umac_base = params->port ? GRCBASE_UMAC1 : GRCBASE_UMAC0;
+	struct bnx2x *bp = params->bp;
+	if (!(REG_RD(bp, MISC_REG_RESET_REG_2) &
+		   (MISC_REGISTERS_RESET_REG_2_UMAC0 << params->port)))
+		return;
+
+	/* Disable RX and TX */
+	REG_WR(bp, umac_base + UMAC_REG_COMMAND_CONFIG, 0);
+}
+
 static void bnx2x_umac_enable(struct link_params *params,
 			    struct link_vars *vars, u8 lb)
 {
@@ -1603,8 +1615,9 @@ static u8 bnx2x_is_4_port_mode(struct bnx2x *bp)
 }
 
 /* Define the XMAC mode */
-static void bnx2x_xmac_init(struct bnx2x *bp, u32 max_speed)
+static void bnx2x_xmac_init(struct link_params *params, u32 max_speed)
 {
+	struct bnx2x *bp = params->bp;
 	u32 is_port4mode = bnx2x_is_4_port_mode(bp);
 
 	/**
@@ -1614,7 +1627,8 @@ static void bnx2x_xmac_init(struct bnx2x *bp, u32 max_speed)
 	* ports of the path
 	**/
 
-	if (is_port4mode && (REG_RD(bp, MISC_REG_RESET_REG_2) &
+	if ((CHIP_NUM(bp) == CHIP_NUM_57840) &&
+	    (REG_RD(bp, MISC_REG_RESET_REG_2) &
 	     MISC_REGISTERS_RESET_REG_2_XMAC)) {
 		DP(NETIF_MSG_LINK,
 		   "XMAC already out of reset in 4-port mode\n");
@@ -1681,10 +1695,6 @@ static void bnx2x_xmac_disable(struct link_params *params)
 		       (pfc_ctrl | (1<<1)));
 		DP(NETIF_MSG_LINK, "Disable XMAC on port %x\n", port);
 		REG_WR(bp, xmac_base + XMAC_REG_CTRL, 0);
-		usleep_range(1000, 1000);
-		bnx2x_set_xumac_nig(params, 0, 0);
-		REG_WR(bp, xmac_base + XMAC_REG_CTRL,
-		       XMAC_CTRL_REG_SOFT_RESET);
 	}
 }
 
@@ -1697,7 +1707,7 @@ static int bnx2x_xmac_enable(struct link_params *params,
 
 	xmac_base = (params->port) ? GRCBASE_XMAC1 : GRCBASE_XMAC0;
 
-	bnx2x_xmac_init(bp, vars->line_speed);
+	bnx2x_xmac_init(params, vars->line_speed);
 
 	/*
 	 * This register determines on which events the MAC will assert
@@ -6310,8 +6320,10 @@ static int bnx2x_update_link_down(struct link_params *params,
 		       MISC_REGISTERS_RESET_REG_2_CLEAR,
 	       (MISC_REGISTERS_RESET_REG_2_RST_BMAC0 << port));
 	}
-	if (CHIP_IS_E3(bp))
+	if (CHIP_IS_E3(bp)) {
 		bnx2x_xmac_disable(params);
+		bnx2x_umac_disable(params);
+	}
 
 	return 0;
 }
@@ -11810,8 +11822,10 @@ int bnx2x_link_reset(struct link_params *params, struct link_vars *vars,
 	/* Stop BigMac rx */
 	if (!CHIP_IS_E3(bp))
 		bnx2x_bmac_rx_disable(bp, port);
-	else
+	else {
 		bnx2x_xmac_disable(params);
+		bnx2x_umac_disable(params);
+	}
 	/* disable emac */
 	if (!CHIP_IS_E3(bp))
 		REG_WR(bp, NIG_REG_NIG_EMAC0_EN + port*4, 0);
@@ -11849,14 +11863,21 @@ int bnx2x_link_reset(struct link_params *params, struct link_vars *vars,
 	if (params->phy[INT_PHY].link_reset)
 		params->phy[INT_PHY].link_reset(
 			&params->phy[INT_PHY], params);
-	/* reset BigMac */
-	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_CLEAR,
-	       (MISC_REGISTERS_RESET_REG_2_RST_BMAC0 << port));
 
 	/* disable nig ingress interface */
 	if (!CHIP_IS_E3(bp)) {
+		/* reset BigMac */
+		REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_CLEAR,
+		       (MISC_REGISTERS_RESET_REG_2_RST_BMAC0 << port));
 		REG_WR(bp, NIG_REG_BMAC0_IN_EN + port*4, 0);
 		REG_WR(bp, NIG_REG_EMAC0_IN_EN + port*4, 0);
+	} else {
+		u32 xmac_base = (params->port) ? GRCBASE_XMAC1 : GRCBASE_XMAC0;
+		bnx2x_set_xumac_nig(params, 0, 0);
+		if (REG_RD(bp, MISC_REG_RESET_REG_2) &
+		    MISC_REGISTERS_RESET_REG_2_XMAC)
+			REG_WR(bp, xmac_base + XMAC_REG_CTRL,
+			       XMAC_CTRL_REG_SOFT_RESET);
 	}
 	vars->link_up = 0;
 	vars->phy_flags = 0;
-- 
1.7.2.2
