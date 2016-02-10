From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net 2/5] bnxt_en: Cleanup and Fix flow control setup logic
Date: Wed, 10 Feb 2016 17:33:47 -0500
Message-ID: <1455143630-30140-3-git-send-email-mchan@broadcom.com>
References: <1455143630-30140-1-git-send-email-mchan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5520-maca-inet1-outside.broadcom.com ([216.31.211.11]:27631
	"EHLO mail-irv-18.broadcom.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750905AbcBJWdv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2016 17:33:51 -0500
In-Reply-To: <1455143630-30140-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cleanup bnxt_probe_phy() to cleanly separate 2 code blocks for autoneg
on and off.  Autoneg flow control is possible only if autoneg is enabled.

In bnxt_get_settings(), Pause and Asym_Pause are always supported.
Only the advertisement bits change depending on the ethtool -A setting
in auto mode.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         | 20 +++++++-------------
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 15 ++-------------
 2 files changed, 9 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 5dc89e5..ddcf7ef 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -5670,22 +5670,16 @@ static int bnxt_probe_phy(struct bnxt *bp)
 	}
 
 	/*initialize the ethool setting copy with NVM settings */
-	if (BNXT_AUTO_MODE(link_info->auto_mode))
-		link_info->autoneg |= BNXT_AUTONEG_SPEED;
-
-	if (link_info->auto_pause_setting & BNXT_LINK_PAUSE_BOTH) {
-		if (link_info->auto_pause_setting == BNXT_LINK_PAUSE_BOTH)
-			link_info->autoneg |= BNXT_AUTONEG_FLOW_CTRL;
+	if (BNXT_AUTO_MODE(link_info->auto_mode)) {
+		link_info->autoneg = BNXT_AUTONEG_SPEED |
+				     BNXT_AUTONEG_FLOW_CTRL;
+		link_info->advertising = link_info->auto_link_speeds;
 		link_info->req_flow_ctrl = link_info->auto_pause_setting;
-	} else if (link_info->force_pause_setting & BNXT_LINK_PAUSE_BOTH) {
+	} else {
+		link_info->req_link_speed = link_info->force_link_speed;
+		link_info->req_duplex = link_info->duplex_setting;
 		link_info->req_flow_ctrl = link_info->force_pause_setting;
 	}
-	link_info->req_duplex = link_info->duplex_setting;
-	if (link_info->autoneg & BNXT_AUTONEG_SPEED)
-		link_info->req_link_speed = link_info->auto_link_speed;
-	else
-		link_info->req_link_speed = link_info->force_link_speed;
-	link_info->advertising = link_info->auto_link_speeds;
 	snprintf(phy_ver, PHY_VER_STR_LEN, " ph %d.%d.%d",
 		 link_info->phy_ver[0],
 		 link_info->phy_ver[1],
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index 7240307..afc9655 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -557,6 +557,7 @@ static int bnxt_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	u16 ethtool_speed;
 
 	cmd->supported = bnxt_fw_to_ethtool_support_spds(link_info);
+	cmd->supported |= SUPPORTED_Pause | SUPPORTED_Asym_Pause;
 
 	if (link_info->auto_link_speeds)
 		cmd->supported |= SUPPORTED_Autoneg;
@@ -570,28 +571,16 @@ static int bnxt_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		cmd->autoneg = AUTONEG_DISABLE;
 		cmd->advertising = 0;
 	}
-	if (link_info->auto_pause_setting & BNXT_LINK_PAUSE_BOTH) {
+	if (link_info->autoneg & BNXT_AUTONEG_FLOW_CTRL) {
 		if ((link_info->auto_pause_setting & BNXT_LINK_PAUSE_BOTH) ==
 		    BNXT_LINK_PAUSE_BOTH) {
 			cmd->advertising |= ADVERTISED_Pause;
-			cmd->supported |= SUPPORTED_Pause;
 		} else {
 			cmd->advertising |= ADVERTISED_Asym_Pause;
-			cmd->supported |= SUPPORTED_Asym_Pause;
 			if (link_info->auto_pause_setting &
 			    BNXT_LINK_PAUSE_RX)
 				cmd->advertising |= ADVERTISED_Pause;
 		}
-	} else if (link_info->force_pause_setting & BNXT_LINK_PAUSE_BOTH) {
-		if ((link_info->force_pause_setting & BNXT_LINK_PAUSE_BOTH) ==
-		    BNXT_LINK_PAUSE_BOTH) {
-			cmd->supported |= SUPPORTED_Pause;
-		} else {
-			cmd->supported |= SUPPORTED_Asym_Pause;
-			if (link_info->force_pause_setting &
-			    BNXT_LINK_PAUSE_RX)
-				cmd->supported |= SUPPORTED_Pause;
-		}
 	}
 
 	cmd->port = PORT_NONE;
-- 
1.8.3.1
