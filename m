From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 02/10] bnxt_en: Improve flow control autoneg with Firmware 1.2.1 interface.
Date: Tue,  5 Apr 2016 04:22:34 -0400
Message-ID: <1459844562-24576-3-git-send-email-michael.chan@broadcom.com>
References: <1459844562-24576-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:8221 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757160AbcDEIWo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 04:22:44 -0400
In-Reply-To: <1459844562-24576-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make use of the new AUTONEG_PAUSE bit in the new interface to better
control autoneg flow control settings, independent of RX and TX
advertisement settings.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         | 28 +++++++++++++++++++----
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 10 ++++----
 2 files changed, 27 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index bfe98cb..2b5a541 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4557,6 +4557,9 @@ static void
 bnxt_hwrm_set_pause_common(struct bnxt *bp, struct hwrm_port_phy_cfg_input *req)
 {
 	if (bp->link_info.autoneg & BNXT_AUTONEG_FLOW_CTRL) {
+		if (bp->hwrm_spec_code >= 0x10201)
+			req->auto_pause =
+				PORT_PHY_CFG_REQ_AUTO_PAUSE_AUTONEG_PAUSE;
 		if (bp->link_info.req_flow_ctrl & BNXT_LINK_PAUSE_RX)
 			req->auto_pause |= PORT_PHY_CFG_REQ_AUTO_PAUSE_RX;
 		if (bp->link_info.req_flow_ctrl & BNXT_LINK_PAUSE_TX)
@@ -4570,6 +4573,11 @@ bnxt_hwrm_set_pause_common(struct bnxt *bp, struct hwrm_port_phy_cfg_input *req)
 			req->force_pause |= PORT_PHY_CFG_REQ_FORCE_PAUSE_TX;
 		req->enables |=
 			cpu_to_le32(PORT_PHY_CFG_REQ_ENABLES_FORCE_PAUSE);
+		if (bp->hwrm_spec_code >= 0x10201) {
+			req->auto_pause = req->force_pause;
+			req->enables |= cpu_to_le32(
+				PORT_PHY_CFG_REQ_ENABLES_AUTO_PAUSE);
+		}
 	}
 }
 
@@ -4656,7 +4664,8 @@ static int bnxt_update_phy_setting(struct bnxt *bp)
 		return rc;
 	}
 	if ((link_info->autoneg & BNXT_AUTONEG_FLOW_CTRL) &&
-	    link_info->auto_pause_setting != link_info->req_flow_ctrl)
+	    (link_info->auto_pause_setting & BNXT_LINK_PAUSE_BOTH) !=
+	    link_info->req_flow_ctrl)
 		update_pause = true;
 	if (!(link_info->autoneg & BNXT_AUTONEG_FLOW_CTRL) &&
 	    link_info->force_pause_setting != link_info->req_flow_ctrl)
@@ -5825,15 +5834,24 @@ static int bnxt_probe_phy(struct bnxt *bp)
 
 	/*initialize the ethool setting copy with NVM settings */
 	if (BNXT_AUTO_MODE(link_info->auto_mode)) {
-		link_info->autoneg = BNXT_AUTONEG_SPEED |
-				     BNXT_AUTONEG_FLOW_CTRL;
+		link_info->autoneg = BNXT_AUTONEG_SPEED;
+		if (bp->hwrm_spec_code >= 0x10201) {
+			if (link_info->auto_pause_setting &
+			    PORT_PHY_CFG_REQ_AUTO_PAUSE_AUTONEG_PAUSE)
+				link_info->autoneg |= BNXT_AUTONEG_FLOW_CTRL;
+		} else {
+			link_info->autoneg |= BNXT_AUTONEG_FLOW_CTRL;
+		}
 		link_info->advertising = link_info->auto_link_speeds;
-		link_info->req_flow_ctrl = link_info->auto_pause_setting;
 	} else {
 		link_info->req_link_speed = link_info->force_link_speed;
 		link_info->req_duplex = link_info->duplex_setting;
-		link_info->req_flow_ctrl = link_info->force_pause_setting;
 	}
+	if (link_info->autoneg & BNXT_AUTONEG_FLOW_CTRL)
+		link_info->req_flow_ctrl =
+			link_info->auto_pause_setting & BNXT_LINK_PAUSE_BOTH;
+	else
+		link_info->req_flow_ctrl = link_info->force_pause_setting;
 	return rc;
 }
 
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index f103f9b..99b1740 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -874,7 +874,9 @@ static int bnxt_set_pauseparam(struct net_device *dev,
 			return -EINVAL;
 
 		link_info->autoneg |= BNXT_AUTONEG_FLOW_CTRL;
-		link_info->req_flow_ctrl |= BNXT_LINK_PAUSE_BOTH;
+		if (bp->hwrm_spec_code >= 0x10201)
+			link_info->req_flow_ctrl =
+				PORT_PHY_CFG_REQ_AUTO_PAUSE_AUTONEG_PAUSE;
 	} else {
 		/* when transition from auto pause to force pause,
 		 * force a link change
@@ -882,17 +884,13 @@ static int bnxt_set_pauseparam(struct net_device *dev,
 		if (link_info->autoneg & BNXT_AUTONEG_FLOW_CTRL)
 			link_info->force_link_chng = true;
 		link_info->autoneg &= ~BNXT_AUTONEG_FLOW_CTRL;
-		link_info->req_flow_ctrl &= ~BNXT_LINK_PAUSE_BOTH;
+		link_info->req_flow_ctrl = 0;
 	}
 	if (epause->rx_pause)
 		link_info->req_flow_ctrl |= BNXT_LINK_PAUSE_RX;
-	else
-		link_info->req_flow_ctrl &= ~BNXT_LINK_PAUSE_RX;
 
 	if (epause->tx_pause)
 		link_info->req_flow_ctrl |= BNXT_LINK_PAUSE_TX;
-	else
-		link_info->req_flow_ctrl &= ~BNXT_LINK_PAUSE_TX;
 
 	if (netif_running(dev))
 		rc = bnxt_hwrm_set_pause(bp);
-- 
1.8.3.1
