From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net-next 09/11] bnx2x: Fix link status sync
Date: Wed, 1 Jun 2011 10:29:05 +0300
Message-ID: <1306913345.20872.116.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1641 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755400Ab1FAH3G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jun 2011 03:29:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix link status synchronization between the primary function, and rest functions.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_link.c |   29 ++++++++++++++++++++++++-----
 1 files changed, 24 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index e44c19d..1816b2d 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -1786,12 +1786,15 @@ void bnx2x_link_status_update(struct link_params *params,
 	u8 link_10g;
 	u8 port = params->port;
 	u32 sync_offset, media_types;
+	/* Update PHY configuration */
+	set_phy_vars(params, vars);
+
 	vars->link_status = REG_RD(bp, params->shmem_base +
 				   offsetof(struct shmem_region,
 					    port_mb[port].link_status));
 
 	vars->link_up = (vars->link_status & LINK_STATUS_LINK_UP);
-
+	vars->phy_flags = PHY_XGXS_FLAG;
 	if (vars->link_up) {
 		DP(NETIF_MSG_LINK, "phy link up\n");
 
@@ -3436,7 +3439,11 @@ static int bnx2x_link_initialize(struct link_params *params,
 	}
 
 	/* Init external phy*/
-	if (!non_ext_phy)
+	if (non_ext_phy) {
+		if (params->phy[INT_PHY].supported &
+		    SUPPORTED_FIBRE)
+			vars->link_status |= LINK_STATUS_SERDES_LINK;
+	} else {
 		for (phy_index = EXT_PHY1; phy_index < params->num_phys;
 		      phy_index++) {
 			/*
@@ -3445,6 +3452,10 @@ static int bnx2x_link_initialize(struct link_params *params,
 			 * need to initialize the first phy, since they are
 			 * connected.
 			 */
+			if (params->phy[phy_index].supported &
+			    SUPPORTED_FIBRE)
+				vars->link_status |= LINK_STATUS_SERDES_LINK;
+
 			if (phy_index == EXT_PHY2 &&
 			    (bnx2x_phy_selection(params) ==
 			     PORT_HW_CFG_PHY_SELECTION_FIRST_PHY)) {
@@ -3456,7 +3467,7 @@ static int bnx2x_link_initialize(struct link_params *params,
 				&params->phy[phy_index],
 				params, vars);
 		}
-
+	}
 	/* Reset the interrupt indication after phy was initialized */
 	bnx2x_bits_dis(bp, NIG_REG_STATUS_INTERRUPT_PORT0 +
 		       params->port*4,
@@ -3464,6 +3475,7 @@ static int bnx2x_link_initialize(struct link_params *params,
 			NIG_STATUS_XGXS0_LINK_STATUS |
 			NIG_STATUS_SERDES0_LINK_STATUS |
 			NIG_MASK_MI_INT));
+	bnx2x_update_mng(params, vars->link_status);
 	return rc;
 }
 
@@ -3507,7 +3519,12 @@ static int bnx2x_update_link_down(struct link_params *params,
 	vars->mac_type = MAC_TYPE_NONE;
 
 	/* update shared memory */
-	vars->link_status = 0;
+	vars->link_status &= ~(LINK_STATUS_SPEED_AND_DUPLEX_MASK |
+			       LINK_STATUS_LINK_UP |
+			       LINK_STATUS_AUTO_NEGOTIATE_COMPLETE |
+			       LINK_STATUS_RX_FLOW_CONTROL_FLAG_MASK |
+			       LINK_STATUS_TX_FLOW_CONTROL_FLAG_MASK |
+			       LINK_STATUS_PARALLEL_DETECTION_FLAG_MASK);
 	vars->line_speed = 0;
 	bnx2x_update_mng(params, vars->link_status);
 
@@ -3597,7 +3614,7 @@ int bnx2x_link_update(struct link_params *params, struct link_vars *vars)
 	u8 is_mi_int = 0;
 	u16 ext_phy_line_speed = 0, prev_line_speed = vars->line_speed;
 	u8 active_external_phy = INT_PHY;
-	vars->link_status = 0;
+
 	for (phy_index = INT_PHY; phy_index < params->num_phys;
 	      phy_index++) {
 		phy_vars[phy_index].flow_ctrl = 0;
@@ -3738,6 +3755,8 @@ int bnx2x_link_update(struct link_params *params, struct link_vars *vars)
 		if (params->phy[active_external_phy].supported &
 		    SUPPORTED_FIBRE)
 			vars->link_status |= LINK_STATUS_SERDES_LINK;
+		else
+			vars->link_status &= ~LINK_STATUS_SERDES_LINK;
 		DP(NETIF_MSG_LINK, "Active external phy selected: %x\n",
 			   active_external_phy);
 	}
-- 
1.7.1






