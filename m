From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [net-next 04/10] bnx2x: Enable FC when parallel-detect is used
Date: Thu, 5 Nov 2009 19:18:12 +0200
Message-ID: <1257441492.3390.51.camel@lb-tlvb-yanivr.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2445 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755455AbZKEPSO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Nov 2009 10:18:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When parallel detect is used, flow-control is set to the req_fc_auto_adv
instead of none.
Motive: when 577xx is FC configuration is set to AUTO, while LP speed is set to
FORCE mode and FC to force RX/TX, link would come up using parallel detect, and
the FC will be set to NONE since FC capabilities were not negotiated, although
the LP is setting FC to force RX/TX.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_link.c |   37 +++++++++++++++++++++++++++++++++++++
 drivers/net/bnx2x_reg.h  |    4 ++++
 2 files changed, 41 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index bf1021e..4c16a46 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -1621,6 +1621,39 @@ static u8 bnx2x_ext_phy_resolve_fc(struct link_params *params,
 	return ret;
 }
 
+static u8 bnx2x_direct_parallel_detect_used(struct link_params *params)
+{
+	struct bnx2x *bp = params->bp;
+	u16 pd_10g, status2_1000x;
+	CL45_RD_OVER_CL22(bp, params->port,
+			      params->phy_addr,
+			      MDIO_REG_BANK_SERDES_DIGITAL,
+			      MDIO_SERDES_DIGITAL_A_1000X_STATUS2,
+			      &status2_1000x);
+	CL45_RD_OVER_CL22(bp, params->port,
+			      params->phy_addr,
+			      MDIO_REG_BANK_SERDES_DIGITAL,
+			      MDIO_SERDES_DIGITAL_A_1000X_STATUS2,
+			      &status2_1000x);
+	if (status2_1000x & MDIO_SERDES_DIGITAL_A_1000X_STATUS2_AN_DISABLED) {
+		DP(NETIF_MSG_LINK, "1G parallel detect link on port %d\n",
+			 params->port);
+		return 1;
+	}
+
+	CL45_RD_OVER_CL22(bp, params->port,
+			      params->phy_addr,
+			      MDIO_REG_BANK_10G_PARALLEL_DETECT,
+			      MDIO_10G_PARALLEL_DETECT_PAR_DET_10G_STATUS,
+			      &pd_10g);
+
+	if (pd_10g & MDIO_10G_PARALLEL_DETECT_PAR_DET_10G_STATUS_PD_LINK) {
+		DP(NETIF_MSG_LINK, "10G parallel detect link on port %d\n",
+			 params->port);
+		return 1;
+	}
+	return 0;
+}
 
 static void bnx2x_flow_ctrl_resolve(struct link_params *params,
 				  struct link_vars *vars,
@@ -1639,6 +1672,10 @@ static void bnx2x_flow_ctrl_resolve(struct link_params *params,
 	    (!(vars->phy_flags & PHY_SGMII_FLAG)) &&
 	    (XGXS_EXT_PHY_TYPE(params->ext_phy_config) ==
 	     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT)) {
+		if (bnx2x_direct_parallel_detect_used(params)) {
+			vars->flow_ctrl = params->req_fc_auto_adv;
+			return;
+		}
 		if ((gp_status &
 		    (MDIO_GP_STATUS_TOP_AN_STATUS1_CL73_AUTONEG_COMPLETE |
 		     MDIO_GP_STATUS_TOP_AN_STATUS1_CL73_MR_LP_NP_AN_ABLE)) ==
diff --git a/drivers/net/bnx2x_reg.h b/drivers/net/bnx2x_reg.h
index b80fde4..4be9bab 100644
--- a/drivers/net/bnx2x_reg.h
+++ b/drivers/net/bnx2x_reg.h
@@ -4920,6 +4920,8 @@
 
 
 #define MDIO_REG_BANK_10G_PARALLEL_DETECT		0x8130
+#define MDIO_10G_PARALLEL_DETECT_PAR_DET_10G_STATUS		0x10
+#define MDIO_10G_PARALLEL_DETECT_PAR_DET_10G_STATUS_PD_LINK		0x8000
 #define MDIO_10G_PARALLEL_DETECT_PAR_DET_10G_CONTROL		0x11
 #define MDIO_10G_PARALLEL_DETECT_PAR_DET_10G_CONTROL_PARDET10G_EN	0x1
 #define MDIO_10G_PARALLEL_DETECT_PAR_DET_10G_LINK		0x13
@@ -4944,6 +4946,8 @@
 #define MDIO_SERDES_DIGITAL_A_1000X_STATUS1_SPEED_1G			0x0010
 #define MDIO_SERDES_DIGITAL_A_1000X_STATUS1_SPEED_100M			0x0008
 #define MDIO_SERDES_DIGITAL_A_1000X_STATUS1_SPEED_10M			0x0000
+#define MDIO_SERDES_DIGITAL_A_1000X_STATUS2			0x15
+#define MDIO_SERDES_DIGITAL_A_1000X_STATUS2_AN_DISABLED 		0x0002
 #define MDIO_SERDES_DIGITAL_MISC1				0x18
 #define MDIO_SERDES_DIGITAL_MISC1_REFCLK_SEL_MASK			0xE000
 #define MDIO_SERDES_DIGITAL_MISC1_REFCLK_SEL_25M			0x0000
-- 
1.6.5.2




