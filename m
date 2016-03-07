From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH v2 net-next 2/8] bnxt_en: Add reporting of link partner advertisement.
Date: Mon,  7 Mar 2016 15:38:42 -0500
Message-ID: <1457383128-28645-3-git-send-email-michael.chan@broadcom.com>
References: <1457383128-28645-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5520-maca-inet1-outside.broadcom.com ([216.31.211.11]:6527 "EHLO
	mail-irv-18.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753613AbcCGUit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 15:38:49 -0500
In-Reply-To: <1457383128-28645-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

And report actual pause settings to ETHTOOL_GPAUSEPARAM to let ethtool
resolve the actual pause settings.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         |  3 +++
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         |  2 ++
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 20 ++++++++++++++++++--
 3 files changed, 23 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index aa6a318..072a12f 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4467,6 +4467,7 @@ static int bnxt_update_link(struct bnxt *bp, bool chng_link_state)
 	link_info->pause = resp->pause;
 	link_info->auto_mode = resp->auto_mode;
 	link_info->auto_pause_setting = resp->auto_pause;
+	link_info->lp_pause = resp->link_partner_adv_pause;
 	link_info->force_pause_setting = resp->force_pause;
 	link_info->duplex_setting = resp->duplex;
 	if (link_info->phy_link_status == BNXT_LINK_LINK)
@@ -4477,6 +4478,8 @@ static int bnxt_update_link(struct bnxt *bp, bool chng_link_state)
 	link_info->auto_link_speed = le16_to_cpu(resp->auto_link_speed);
 	link_info->support_speeds = le16_to_cpu(resp->support_speeds);
 	link_info->auto_link_speeds = le16_to_cpu(resp->auto_link_speed_mask);
+	link_info->lp_auto_link_speeds =
+		le16_to_cpu(resp->link_partner_adv_speeds);
 	link_info->preemphasis = le32_to_cpu(resp->preemphasis);
 	link_info->phy_ver[0] = resp->phy_maj;
 	link_info->phy_ver[1] = resp->phy_min;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 9aa38f5..2f24e4e 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -780,6 +780,7 @@ struct bnxt_link_info {
 #define BNXT_LINK_PAUSE_RX	PORT_PHY_QCFG_RESP_PAUSE_RX
 #define BNXT_LINK_PAUSE_BOTH	(PORT_PHY_QCFG_RESP_PAUSE_RX | \
 				 PORT_PHY_QCFG_RESP_PAUSE_TX)
+	u8			lp_pause;
 	u8			auto_pause_setting;
 	u8			force_pause_setting;
 	u8			duplex_setting;
@@ -814,6 +815,7 @@ struct bnxt_link_info {
 #define BNXT_LINK_SPEED_MSK_25GB PORT_PHY_QCFG_RESP_SUPPORT_SPEEDS_25GB
 #define BNXT_LINK_SPEED_MSK_40GB PORT_PHY_QCFG_RESP_SUPPORT_SPEEDS_40GB
 #define BNXT_LINK_SPEED_MSK_50GB PORT_PHY_QCFG_RESP_SUPPORT_SPEEDS_50GB
+	u16			lp_auto_link_speeds;
 	u16			auto_link_speed;
 	u16			force_link_speed;
 	u32			preemphasis;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index a6ee26a..591c290 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -553,6 +553,17 @@ static u32 bnxt_fw_to_ethtool_advertised_spds(struct bnxt_link_info *link_info)
 	return _bnxt_fw_to_ethtool_adv_spds(fw_speeds, fw_pause);
 }
 
+static u32 bnxt_fw_to_ethtool_lp_adv(struct bnxt_link_info *link_info)
+{
+	u16 fw_speeds = link_info->lp_auto_link_speeds;
+	u8 fw_pause = 0;
+
+	if (link_info->autoneg & BNXT_AUTONEG_FLOW_CTRL)
+		fw_pause = link_info->lp_pause;
+
+	return _bnxt_fw_to_ethtool_adv_spds(fw_speeds, fw_pause);
+}
+
 u32 bnxt_fw_to_ethtool_speed(u16 fw_link_speed)
 {
 	switch (fw_link_speed) {
@@ -594,6 +605,9 @@ static int bnxt_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 			bnxt_fw_to_ethtool_advertised_spds(link_info);
 		cmd->advertising |= ADVERTISED_Autoneg;
 		cmd->autoneg = AUTONEG_ENABLE;
+		if (link_info->phy_link_status == BNXT_LINK_LINK)
+			cmd->lp_advertising =
+				bnxt_fw_to_ethtool_lp_adv(link_info);
 	} else {
 		cmd->autoneg = AUTONEG_DISABLE;
 		cmd->advertising = 0;
@@ -757,8 +771,10 @@ static void bnxt_get_pauseparam(struct net_device *dev,
 	if (BNXT_VF(bp))
 		return;
 	epause->autoneg = !!(link_info->autoneg & BNXT_AUTONEG_FLOW_CTRL);
-	epause->rx_pause = ((link_info->pause & BNXT_LINK_PAUSE_RX) != 0);
-	epause->tx_pause = ((link_info->pause & BNXT_LINK_PAUSE_TX) != 0);
+	epause->rx_pause =
+		((link_info->auto_pause_setting & BNXT_LINK_PAUSE_RX) != 0);
+	epause->tx_pause =
+		((link_info->auto_pause_setting & BNXT_LINK_PAUSE_TX) != 0);
 }
 
 static int bnxt_set_pauseparam(struct net_device *dev,
-- 
1.8.3.1
