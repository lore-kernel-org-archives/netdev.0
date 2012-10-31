From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net 4/7] bnx2x: Fix potential incorrect link speed
 provision
Date: Wed, 31 Oct 2012 17:46:55 +0200
Message-ID: <1351698418-10005-5-git-send-email-dmitry@broadcom.com>
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
	id S1757618Ab2JaPrN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2012 11:47:13 -0400
In-Reply-To: <1351698418-10005-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yaniv Rosner <yanivr@broadcom.com>

Fix possible incorrect link speed provision following rapid link speed change.
Clear link speed mask after each link change, and not only after link down.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Barak Witkowski <barak@broadcom.com>
Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |   22 ++++++++++++----------
 1 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 5e8f7b7..308ba42 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -137,7 +137,16 @@
 #define LINK_20GTFD		LINK_STATUS_SPEED_AND_DUPLEX_20GTFD
 #define LINK_20GXFD		LINK_STATUS_SPEED_AND_DUPLEX_20GXFD
 
-
+#define LINK_UPDATE_MASK \
+			(LINK_STATUS_SPEED_AND_DUPLEX_MASK | \
+			 LINK_STATUS_LINK_UP | \
+			 LINK_STATUS_PHYSICAL_LINK_FLAG | \
+			 LINK_STATUS_AUTO_NEGOTIATE_COMPLETE | \
+			 LINK_STATUS_RX_FLOW_CONTROL_FLAG_MASK | \
+			 LINK_STATUS_TX_FLOW_CONTROL_FLAG_MASK | \
+			 LINK_STATUS_PARALLEL_DETECTION_FLAG_MASK | \
+			 LINK_STATUS_LINK_PARTNER_SYMMETRIC_PAUSE | \
+			 LINK_STATUS_LINK_PARTNER_ASYMMETRIC_PAUSE)
 
 #define SFP_EEPROM_CON_TYPE_ADDR		0x2
 	#define SFP_EEPROM_CON_TYPE_VAL_LC	0x7
@@ -6349,15 +6358,7 @@ static int bnx2x_update_link_down(struct link_params *params,
 	vars->mac_type = MAC_TYPE_NONE;
 
 	/* Update shared memory */
-	vars->link_status &= ~(LINK_STATUS_SPEED_AND_DUPLEX_MASK |
-			       LINK_STATUS_LINK_UP |
-			       LINK_STATUS_PHYSICAL_LINK_FLAG |
-			       LINK_STATUS_AUTO_NEGOTIATE_COMPLETE |
-			       LINK_STATUS_RX_FLOW_CONTROL_FLAG_MASK |
-			       LINK_STATUS_TX_FLOW_CONTROL_FLAG_MASK |
-			       LINK_STATUS_PARALLEL_DETECTION_FLAG_MASK |
-			       LINK_STATUS_LINK_PARTNER_SYMMETRIC_PAUSE |
-			       LINK_STATUS_LINK_PARTNER_ASYMMETRIC_PAUSE);
+	vars->link_status &= ~LINK_UPDATE_MASK;
 	vars->line_speed = 0;
 	bnx2x_update_mng(params, vars->link_status);
 
@@ -6505,6 +6506,7 @@ int bnx2x_link_update(struct link_params *params, struct link_vars *vars)
 	u16 ext_phy_line_speed = 0, prev_line_speed = vars->line_speed;
 	u8 active_external_phy = INT_PHY;
 	vars->phy_flags &= ~PHY_HALF_OPEN_CONN_FLAG;
+	vars->link_status &= ~LINK_UPDATE_MASK;
 	for (phy_index = INT_PHY; phy_index < params->num_phys;
 	      phy_index++) {
 		phy_vars[phy_index].flow_ctrl = 0;
-- 
1.7.7.2
