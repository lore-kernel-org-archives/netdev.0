From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 1/8] bnxt_en: Refactor bnxt_fw_to_ethtool_advertised_spds().
Date: Sun,  6 Mar 2016 02:01:17 -0500
Message-ID: <1457247684-2403-2-git-send-email-michael.chan@broadcom.com>
References: <1457247684-2403-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5520-maca-inet1-outside.broadcom.com ([216.31.211.11]:38980
	"EHLO mail-irv-18.broadcom.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751136AbcCFHBZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Mar 2016 02:01:25 -0500
In-Reply-To: <1457247684-2403-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Include the conversion of pause bits and add one extra call layer so
that the same refactored function can be reused to get the link partner
advertisement bits.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 33 ++++++++++++++---------
 1 file changed, 20 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index 84ea26d..a6ee26a 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -515,9 +515,8 @@ static u32 bnxt_fw_to_ethtool_support_spds(struct bnxt_link_info *link_info)
 	return speed_mask;
 }
 
-static u32 bnxt_fw_to_ethtool_advertised_spds(struct bnxt_link_info *link_info)
+static u32 _bnxt_fw_to_ethtool_adv_spds(u16 fw_speeds, u8 fw_pause)
 {
-	u16 fw_speeds = link_info->auto_link_speeds;
 	u32 speed_mask = 0;
 
 	/* TODO: support 25GB, 40GB, 50GB with different cable type */
@@ -532,9 +531,28 @@ static u32 bnxt_fw_to_ethtool_advertised_spds(struct bnxt_link_info *link_info)
 		speed_mask |= ADVERTISED_10000baseT_Full;
 	if (fw_speeds & BNXT_LINK_SPEED_MSK_40GB)
 		speed_mask |= ADVERTISED_40000baseCR4_Full;
+
+	if ((fw_pause & BNXT_LINK_PAUSE_BOTH) == BNXT_LINK_PAUSE_BOTH)
+		speed_mask |= ADVERTISED_Pause;
+	else if (fw_pause & BNXT_LINK_PAUSE_TX)
+		speed_mask |= ADVERTISED_Asym_Pause;
+	else if (fw_pause & BNXT_LINK_PAUSE_RX)
+		speed_mask |= ADVERTISED_Pause | ADVERTISED_Asym_Pause;
+
 	return speed_mask;
 }
 
+static u32 bnxt_fw_to_ethtool_advertised_spds(struct bnxt_link_info *link_info)
+{
+	u16 fw_speeds = link_info->auto_link_speeds;
+	u8 fw_pause = 0;
+
+	if (link_info->autoneg & BNXT_AUTONEG_FLOW_CTRL)
+		fw_pause = link_info->auto_pause_setting;
+
+	return _bnxt_fw_to_ethtool_adv_spds(fw_speeds, fw_pause);
+}
+
 u32 bnxt_fw_to_ethtool_speed(u16 fw_link_speed)
 {
 	switch (fw_link_speed) {
@@ -580,17 +598,6 @@ static int bnxt_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		cmd->autoneg = AUTONEG_DISABLE;
 		cmd->advertising = 0;
 	}
-	if (link_info->autoneg & BNXT_AUTONEG_FLOW_CTRL) {
-		if ((link_info->auto_pause_setting & BNXT_LINK_PAUSE_BOTH) ==
-		    BNXT_LINK_PAUSE_BOTH) {
-			cmd->advertising |= ADVERTISED_Pause;
-		} else {
-			cmd->advertising |= ADVERTISED_Asym_Pause;
-			if (link_info->auto_pause_setting &
-			    BNXT_LINK_PAUSE_RX)
-				cmd->advertising |= ADVERTISED_Pause;
-		}
-	}
 
 	cmd->port = PORT_NONE;
 	if (link_info->media_type == PORT_PHY_QCFG_RESP_MEDIA_TYPE_TP) {
-- 
1.8.3.1
