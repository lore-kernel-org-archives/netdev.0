From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 10/11] bnxt_en: Don't allow autoneg on cards that don't support it.
Date: Mon, 13 Jun 2016 02:25:37 -0400
Message-ID: <1465799138-27529-11-git-send-email-michael.chan@broadcom.com>
References: <1465799138-27529-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:36541 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030184AbcFMG0A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 02:26:00 -0400
Received: by mail-pf0-f180.google.com with SMTP id t190so42943793pfb.3
        for <netdev@vger.kernel.org>; Sun, 12 Jun 2016 23:26:00 -0700 (PDT)
In-Reply-To: <1465799138-27529-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some cards do not support autoneg.  The current code does not prevent the
user from enabling autoneg with ethtool on such cards, causing confusion.
Firmware provides the autoneg capability information and we just need to
store it in the support_auto_speeds field in bnxt_link_info struct.
The ethtool set_settings() call will check this field before proceeding
with autoneg.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         |  9 +++++++
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         |  1 +
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 29 ++++++++++++++++-------
 3 files changed, 30 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index c275329..9aaa6a6 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4823,6 +4823,7 @@ static int bnxt_hwrm_phy_qcaps(struct bnxt *bp)
 	int rc = 0;
 	struct hwrm_port_phy_qcaps_input req = {0};
 	struct hwrm_port_phy_qcaps_output *resp = bp->hwrm_cmd_resp_addr;
+	struct bnxt_link_info *link_info = &bp->link_info;
 
 	if (bp->hwrm_spec_code < 0x10201)
 		return 0;
@@ -4845,6 +4846,8 @@ static int bnxt_hwrm_phy_qcaps(struct bnxt *bp)
 		bp->lpi_tmr_hi = le32_to_cpu(resp->valid_tx_lpi_timer_high) &
 				 PORT_PHY_QCAPS_RESP_TX_LPI_TIMER_HIGH_MASK;
 	}
+	link_info->support_auto_speeds =
+		le16_to_cpu(resp->supported_speeds_auto_mode);
 
 hwrm_phy_qcaps_exit:
 	mutex_unlock(&bp->hwrm_cmd_lock);
@@ -6368,6 +6371,12 @@ static int bnxt_probe_phy(struct bnxt *bp)
 		return rc;
 	}
 
+	/* Older firmware does not have supported_auto_speeds, so assume
+	 * that all supported speeds can be autonegotiated.
+	 */
+	if (link_info->auto_link_speeds && !link_info->support_auto_speeds)
+		link_info->support_auto_speeds = link_info->support_speeds;
+
 	/*initialize the ethool setting copy with NVM settings */
 	if (BNXT_AUTO_MODE(link_info->auto_mode)) {
 		link_info->autoneg = BNXT_AUTONEG_SPEED;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index c1b41fb..04cc69b 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -849,6 +849,7 @@ struct bnxt_link_info {
 #define BNXT_LINK_SPEED_MSK_25GB PORT_PHY_QCFG_RESP_SUPPORT_SPEEDS_25GB
 #define BNXT_LINK_SPEED_MSK_40GB PORT_PHY_QCFG_RESP_SUPPORT_SPEEDS_40GB
 #define BNXT_LINK_SPEED_MSK_50GB PORT_PHY_QCFG_RESP_SUPPORT_SPEEDS_50GB
+	u16			support_auto_speeds;
 	u16			lp_auto_link_speeds;
 	u16			force_link_speed;
 	u32			preemphasis;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index 89050ed..3362e90 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -659,6 +659,17 @@ static u32 bnxt_fw_to_ethtool_support_spds(struct bnxt_link_info *link_info)
 	return supported | SUPPORTED_Pause | SUPPORTED_Asym_Pause;
 }
 
+static u32 bnxt_fw_to_ethtool_support_adv_spds(struct bnxt_link_info *link_info)
+{
+	u16 fw_speeds = link_info->support_auto_speeds;
+	u32 supported;
+
+	supported = _bnxt_fw_to_ethtool_adv_spds(fw_speeds, 0);
+	if (supported)
+		supported |= SUPPORTED_Pause | SUPPORTED_Asym_Pause;
+	return supported;
+}
+
 u32 bnxt_fw_to_ethtool_speed(u16 fw_link_speed)
 {
 	switch (fw_link_speed) {
@@ -691,7 +702,7 @@ static int bnxt_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 	cmd->supported = bnxt_fw_to_ethtool_support_spds(link_info);
 
-	if (link_info->auto_link_speeds)
+	if (link_info->support_auto_speeds)
 		cmd->supported |= SUPPORTED_Autoneg;
 
 	if (link_info->autoneg) {
@@ -827,8 +838,14 @@ static int bnxt_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		return rc;
 
 	if (cmd->autoneg == AUTONEG_ENABLE) {
-		u32 supported_spds = bnxt_fw_to_ethtool_support_spds(link_info);
+		u32 supported_spds =
+			bnxt_fw_to_ethtool_support_adv_spds(link_info);
 
+		if (!supported_spds) {
+			netdev_err(dev, "Autoneg not supported\n");
+			rc = -EINVAL;
+			goto set_setting_exit;
+		}
 		if (cmd->advertising & ~(supported_spds | ADVERTISED_Autoneg |
 					 ADVERTISED_TP | ADVERTISED_FIBRE)) {
 			netdev_err(dev, "Unsupported advertising mask (adv: 0x%x)\n",
@@ -837,15 +854,9 @@ static int bnxt_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 			goto set_setting_exit;
 		}
 		fw_advertising = bnxt_get_fw_auto_link_speeds(cmd->advertising);
-		if (fw_advertising & ~link_info->support_speeds) {
-			netdev_err(dev, "Advertising parameters are not supported! (adv: 0x%x)\n",
-				   cmd->advertising);
-			rc = -EINVAL;
-			goto set_setting_exit;
-		}
 		link_info->autoneg |= BNXT_AUTONEG_SPEED;
 		if (!fw_advertising)
-			link_info->advertising = link_info->support_speeds;
+			link_info->advertising = link_info->support_auto_speeds;
 		else
 			link_info->advertising = fw_advertising;
 		/* any change to autoneg will cause link change, therefore the
-- 
1.8.3.1
