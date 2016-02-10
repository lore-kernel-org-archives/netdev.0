From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net 1/5] bnxt_en: Fix ethtool autoneg logic.
Date: Wed, 10 Feb 2016 17:33:46 -0500
Message-ID: <1455143630-30140-2-git-send-email-mchan@broadcom.com>
References: <1455143630-30140-1-git-send-email-mchan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5520-maca-inet1-outside.broadcom.com ([216.31.211.11]:58777
	"EHLO mail-irv-18.broadcom.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750788AbcBJWdv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2016 17:33:51 -0500
In-Reply-To: <1455143630-30140-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1. Determine autoneg on|off setting from link_info->autoneg.  Using the
firmware returned setting can be misleading if autoneg is changed and
there hasn't been a phy update from the firmware.

2. If autoneg is disabled, link_info->autoneg should be set to 0 to
indicate both speed and flow control autoneg are disabled.

3. To enable autoneg flow control, speed autoneg must be enabled.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index 922b898..7240307 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -561,7 +561,7 @@ static int bnxt_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	if (link_info->auto_link_speeds)
 		cmd->supported |= SUPPORTED_Autoneg;
 
-	if (BNXT_AUTO_MODE(link_info->auto_mode)) {
+	if (link_info->autoneg) {
 		cmd->advertising =
 			bnxt_fw_to_ethtool_advertised_spds(link_info);
 		cmd->advertising |= ADVERTISED_Autoneg;
@@ -729,7 +729,7 @@ static int bnxt_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		speed = ethtool_cmd_speed(cmd);
 		link_info->req_link_speed = bnxt_get_fw_speed(dev, speed);
 		link_info->req_duplex = BNXT_LINK_DUPLEX_FULL;
-		link_info->autoneg &= ~BNXT_AUTONEG_SPEED;
+		link_info->autoneg = 0;
 		link_info->advertising = 0;
 	}
 
@@ -748,8 +748,7 @@ static void bnxt_get_pauseparam(struct net_device *dev,
 
 	if (BNXT_VF(bp))
 		return;
-	epause->autoneg = !!(link_info->auto_pause_setting &
-			     BNXT_LINK_PAUSE_BOTH);
+	epause->autoneg = !!(link_info->autoneg & BNXT_AUTONEG_FLOW_CTRL);
 	epause->rx_pause = ((link_info->pause & BNXT_LINK_PAUSE_RX) != 0);
 	epause->tx_pause = ((link_info->pause & BNXT_LINK_PAUSE_TX) != 0);
 }
@@ -765,6 +764,9 @@ static int bnxt_set_pauseparam(struct net_device *dev,
 		return rc;
 
 	if (epause->autoneg) {
+		if (!(link_info->autoneg & BNXT_AUTONEG_SPEED))
+			return -EINVAL;
+
 		link_info->autoneg |= BNXT_AUTONEG_FLOW_CTRL;
 		link_info->req_flow_ctrl |= BNXT_LINK_PAUSE_BOTH;
 	} else {
-- 
1.8.3.1
