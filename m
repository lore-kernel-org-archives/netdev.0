From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 10/10] bnxt_en: Improve ethtool .get_settings().
Date: Tue,  5 Apr 2016 04:22:42 -0400
Message-ID: <1459844562-24576-11-git-send-email-michael.chan@broadcom.com>
References: <1459844562-24576-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:48796 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752863AbcDEIWr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 04:22:47 -0400
In-Reply-To: <1459844562-24576-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If autoneg is off, we should always report the speed and duplex settings
even if it is link down so the user knows the current settings.  The
unknown speed and duplex should only be used for autoneg when link is
down.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 21 +++++++++++++--------
 1 file changed, 13 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index 289895f..3795af2 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -698,10 +698,23 @@ static int bnxt_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		if (link_info->phy_link_status == BNXT_LINK_LINK)
 			cmd->lp_advertising =
 				bnxt_fw_to_ethtool_lp_adv(link_info);
+		ethtool_speed = bnxt_fw_to_ethtool_speed(link_info->link_speed);
+		if (!netif_carrier_ok(dev))
+			cmd->duplex = DUPLEX_UNKNOWN;
+		else if (link_info->duplex & BNXT_LINK_DUPLEX_FULL)
+			cmd->duplex = DUPLEX_FULL;
+		else
+			cmd->duplex = DUPLEX_HALF;
 	} else {
 		cmd->autoneg = AUTONEG_DISABLE;
 		cmd->advertising = 0;
+		ethtool_speed =
+			bnxt_fw_to_ethtool_speed(link_info->req_link_speed);
+		cmd->duplex = DUPLEX_HALF;
+		if (link_info->req_duplex == BNXT_LINK_DUPLEX_FULL)
+			cmd->duplex = DUPLEX_FULL;
 	}
+	ethtool_cmd_speed_set(cmd, ethtool_speed);
 
 	cmd->port = PORT_NONE;
 	if (link_info->media_type == PORT_PHY_QCFG_RESP_MEDIA_TYPE_TP) {
@@ -719,14 +732,6 @@ static int bnxt_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 			cmd->port = PORT_FIBRE;
 	}
 
-	if (link_info->phy_link_status == BNXT_LINK_LINK) {
-		if (link_info->duplex & BNXT_LINK_DUPLEX_FULL)
-			cmd->duplex = DUPLEX_FULL;
-	} else {
-		cmd->duplex = DUPLEX_UNKNOWN;
-	}
-	ethtool_speed = bnxt_fw_to_ethtool_speed(link_info->link_speed);
-	ethtool_cmd_speed_set(cmd, ethtool_speed);
 	if (link_info->transceiver ==
 	    PORT_PHY_QCFG_RESP_XCVR_PKG_TYPE_XCVR_INTERNAL)
 		cmd->transceiver = XCVR_INTERNAL;
-- 
1.8.3.1
