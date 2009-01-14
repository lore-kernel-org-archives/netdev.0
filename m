From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 29/34]bnx2x: 1G-10G toggling race
Date: Wed, 14 Jan 2009 18:44:13 +0200
Message-ID: <1231951453.11301.150.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Yaniv Rosner" <yanivr@broadcom.com>
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2905 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763733AbZANQp2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 11:45:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The HW should be configured so fast toggling between 1G and 10G will not be
missed. Make sure that the HW is re-configured in full

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_link.c |   43 ++++++++++++++++++++++++++++++++-----------
 1 files changed, 32 insertions(+), 11 deletions(-)

diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index fefa6ab..d9e1cfc 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -317,6 +317,9 @@ static u8 bnx2x_emac_enable(struct link_params *params,
 		val &= ~0x810;
 	EMAC_WR(bp, EMAC_REG_EMAC_MODE, val);
 
+	/* enable emac */
+	REG_WR(bp, NIG_REG_NIG_EMAC0_EN + port*4, 1);
+
 	/* enable emac for jumbo packets */
 	EMAC_WR(bp, EMAC_REG_EMAC_RX_MTU_SIZE,
 		(EMAC_RX_MTU_SIZE_JUMBO_ENA |
@@ -1609,7 +1612,7 @@ static u8 bnx2x_link_settings_status(struct link_params *params,
 				      u32 gp_status)
 {
 	struct bnx2x *bp = params->bp;
-
+	u16 new_line_speed;
 	u8 rc = 0;
 	vars->link_status = 0;
 
@@ -1629,7 +1632,7 @@ static u8 bnx2x_link_settings_status(struct link_params *params,
 
 		switch (gp_status & GP_STATUS_SPEED_MASK) {
 		case GP_STATUS_10M:
-			vars->line_speed = SPEED_10;
+			new_line_speed = SPEED_10;
 			if (vars->duplex == DUPLEX_FULL)
 				vars->link_status |= LINK_10TFD;
 			else
@@ -1637,7 +1640,7 @@ static u8 bnx2x_link_settings_status(struct link_params *params,
 			break;
 
 		case GP_STATUS_100M:
-			vars->line_speed = SPEED_100;
+			new_line_speed = SPEED_100;
 			if (vars->duplex == DUPLEX_FULL)
 				vars->link_status |= LINK_100TXFD;
 			else
@@ -1646,7 +1649,7 @@ static u8 bnx2x_link_settings_status(struct link_params *params,
 
 		case GP_STATUS_1G:
 		case GP_STATUS_1G_KX:
-			vars->line_speed = SPEED_1000;
+			new_line_speed = SPEED_1000;
 			if (vars->duplex == DUPLEX_FULL)
 				vars->link_status |= LINK_1000TFD;
 			else
@@ -1654,7 +1657,7 @@ static u8 bnx2x_link_settings_status(struct link_params *params,
 			break;
 
 		case GP_STATUS_2_5G:
-			vars->line_speed = SPEED_2500;
+			new_line_speed = SPEED_2500;
 			if (vars->duplex == DUPLEX_FULL)
 				vars->link_status |= LINK_2500TFD;
 			else
@@ -1671,32 +1674,32 @@ static u8 bnx2x_link_settings_status(struct link_params *params,
 		case GP_STATUS_10G_KX4:
 		case GP_STATUS_10G_HIG:
 		case GP_STATUS_10G_CX4:
-			vars->line_speed = SPEED_10000;
+			new_line_speed = SPEED_10000;
 			vars->link_status |= LINK_10GTFD;
 			break;
 
 		case GP_STATUS_12G_HIG:
-			vars->line_speed = SPEED_12000;
+			new_line_speed = SPEED_12000;
 			vars->link_status |= LINK_12GTFD;
 			break;
 
 		case GP_STATUS_12_5G:
-			vars->line_speed = SPEED_12500;
+			new_line_speed = SPEED_12500;
 			vars->link_status |= LINK_12_5GTFD;
 			break;
 
 		case GP_STATUS_13G:
-			vars->line_speed = SPEED_13000;
+			new_line_speed = SPEED_13000;
 			vars->link_status |= LINK_13GTFD;
 			break;
 
 		case GP_STATUS_15G:
-			vars->line_speed = SPEED_15000;
+			new_line_speed = SPEED_15000;
 			vars->link_status |= LINK_15GTFD;
 			break;
 
 		case GP_STATUS_16G:
-			vars->line_speed = SPEED_16000;
+			new_line_speed = SPEED_16000;
 			vars->link_status |= LINK_16GTFD;
 			break;
 
@@ -1708,6 +1711,15 @@ static u8 bnx2x_link_settings_status(struct link_params *params,
 			break;
 		}
 
+		/* Upon link speed change set the NIG into drain mode.
+		Comes to deals with possible FIFO glitch due to clk change
+		when speed is decreased without link down indicator */
+		if (new_line_speed != vars->line_speed) {
+			REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE
+				    + params->port*4, 0);
+			msleep(1);
+		}
+		vars->line_speed = new_line_speed;
 		vars->link_status |= LINK_STATUS_SERDES_LINK;
 
 		if ((params->req_line_speed == SPEED_AUTO_NEG) &&
@@ -4194,6 +4206,11 @@ static u8 bnx2x_update_link_down(struct link_params *params,
 	/* activate nig drain */
 	REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE + port*4, 1);
 
+	/* disable emac */
+	REG_WR(bp, NIG_REG_NIG_EMAC0_EN + port*4, 0);
+
+	msleep(10);
+
 	/* reset BigMac */
 	bnx2x_bmac_rx_disable(bp, params->port);
 	REG_WR(bp, GRCBASE_MISC +
@@ -4238,6 +4255,7 @@ static u8 bnx2x_update_link_up(struct link_params *params,
 
 	/* update shared memory */
 	bnx2x_update_mng(params, vars->link_status);
+	msleep(20);
 	return rc;
 }
 /* This function should called upon link interrupt */
@@ -4276,6 +4294,9 @@ u8 bnx2x_link_update(struct link_params *params, struct link_vars *vars)
 	  REG_RD(bp, NIG_REG_XGXS0_STATUS_LINK10G + port*0x68),
 	  REG_RD(bp, NIG_REG_XGXS0_STATUS_LINK_STATUS + port*0x68));
 
+	/* disable emac */
+	REG_WR(bp, NIG_REG_NIG_EMAC0_EN + port*4, 0);
+
 	ext_phy_type = XGXS_EXT_PHY_TYPE(params->ext_phy_config);
 
 	/* Check external link change only for non-direct */
-- 
1.5.4.3




