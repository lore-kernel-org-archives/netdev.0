From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next v2 8/9] bnxt_en: Check for valid forced speed during ethtool -s.
Date: Tue,  5 Apr 2016 14:09:02 -0400
Message-ID: <1459879743-16960-9-git-send-email-michael.chan@broadcom.com>
References: <1459879743-16960-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:31443 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933578AbcDESJR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 14:09:17 -0400
In-Reply-To: <1459879743-16960-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check that the forced speed is a valid speed supported by firmware.
If not supported, return -EINVAL.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 48 ++++++++++++++++++-----
 1 file changed, 38 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index 47e08a8..952b5ba 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -739,28 +739,49 @@ static int bnxt_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 static u32 bnxt_get_fw_speed(struct net_device *dev, u16 ethtool_speed)
 {
+	struct bnxt *bp = netdev_priv(dev);
+	struct bnxt_link_info *link_info = &bp->link_info;
+	u16 support_spds = link_info->support_speeds;
+	u32 fw_speed = 0;
+
 	switch (ethtool_speed) {
 	case SPEED_100:
-		return PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_100MB;
+		if (support_spds & BNXT_LINK_SPEED_MSK_100MB)
+			fw_speed = PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_100MB;
+		break;
 	case SPEED_1000:
-		return PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_1GB;
+		if (support_spds & BNXT_LINK_SPEED_MSK_1GB)
+			fw_speed = PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_1GB;
+		break;
 	case SPEED_2500:
-		return PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_2_5GB;
+		if (support_spds & BNXT_LINK_SPEED_MSK_2_5GB)
+			fw_speed = PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_2_5GB;
+		break;
 	case SPEED_10000:
-		return PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_10GB;
+		if (support_spds & BNXT_LINK_SPEED_MSK_10GB)
+			fw_speed = PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_10GB;
+		break;
 	case SPEED_20000:
-		return PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_20GB;
+		if (support_spds & BNXT_LINK_SPEED_MSK_20GB)
+			fw_speed = PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_20GB;
+		break;
 	case SPEED_25000:
-		return PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_25GB;
+		if (support_spds & BNXT_LINK_SPEED_MSK_25GB)
+			fw_speed = PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_25GB;
+		break;
 	case SPEED_40000:
-		return PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_40GB;
+		if (support_spds & BNXT_LINK_SPEED_MSK_40GB)
+			fw_speed = PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_40GB;
+		break;
 	case SPEED_50000:
-		return PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_50GB;
+		if (support_spds & BNXT_LINK_SPEED_MSK_50GB)
+			fw_speed = PORT_PHY_CFG_REQ_AUTO_LINK_SPEED_50GB;
+		break;
 	default:
 		netdev_err(dev, "unsupported speed!\n");
 		break;
 	}
-	return 0;
+	return fw_speed;
 }
 
 u16 bnxt_get_fw_auto_link_speeds(u32 advertising)
@@ -823,6 +844,8 @@ static int bnxt_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		 */
 		set_pause = true;
 	} else {
+		u16 fw_speed;
+
 		/* TODO: currently don't support half duplex */
 		if (cmd->duplex == DUPLEX_HALF) {
 			netdev_err(dev, "HALF DUPLEX is not supported!\n");
@@ -833,7 +856,12 @@ static int bnxt_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		if (cmd->duplex == DUPLEX_UNKNOWN)
 			cmd->duplex = DUPLEX_FULL;
 		speed = ethtool_cmd_speed(cmd);
-		link_info->req_link_speed = bnxt_get_fw_speed(dev, speed);
+		fw_speed = bnxt_get_fw_speed(dev, speed);
+		if (!fw_speed) {
+			rc = -EINVAL;
+			goto set_setting_exit;
+		}
+		link_info->req_link_speed = fw_speed;
 		link_info->req_duplex = BNXT_LINK_DUPLEX_FULL;
 		link_info->autoneg = 0;
 		link_info->advertising = 0;
-- 
1.8.3.1
