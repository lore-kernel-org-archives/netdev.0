From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 3/8] bnxt_en: Use common function to get ethtool supported flags.
Date: Sun,  6 Mar 2016 02:01:19 -0500
Message-ID: <1457247684-2403-4-git-send-email-michael.chan@broadcom.com>
References: <1457247684-2403-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5520-maca-inet1-outside.broadcom.com ([216.31.211.11]:2452 "EHLO
	mail-irv-18.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751252AbcCFHBZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Mar 2016 02:01:25 -0500
In-Reply-To: <1457247684-2403-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The supported bits and advertising bits in ethtool have the same
definitions.  The same is true for the firmware bits.  So use the
common function to handle the conversion for both supported and
advertising bits.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 29 +++++++----------------
 1 file changed, 9 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index 591c290..e2fe967 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -496,25 +496,6 @@ static void bnxt_get_drvinfo(struct net_device *dev,
 	kfree(pkglog);
 }
 
-static u32 bnxt_fw_to_ethtool_support_spds(struct bnxt_link_info *link_info)
-{
-	u16 fw_speeds = link_info->support_speeds;
-	u32 speed_mask = 0;
-
-	if (fw_speeds & BNXT_LINK_SPEED_MSK_100MB)
-		speed_mask |= SUPPORTED_100baseT_Full;
-	if (fw_speeds & BNXT_LINK_SPEED_MSK_1GB)
-		speed_mask |= SUPPORTED_1000baseT_Full;
-	if (fw_speeds & BNXT_LINK_SPEED_MSK_2_5GB)
-		speed_mask |= SUPPORTED_2500baseX_Full;
-	if (fw_speeds & BNXT_LINK_SPEED_MSK_10GB)
-		speed_mask |= SUPPORTED_10000baseT_Full;
-	if (fw_speeds & BNXT_LINK_SPEED_MSK_40GB)
-		speed_mask |= SUPPORTED_40000baseCR4_Full;
-
-	return speed_mask;
-}
-
 static u32 _bnxt_fw_to_ethtool_adv_spds(u16 fw_speeds, u8 fw_pause)
 {
 	u32 speed_mask = 0;
@@ -564,6 +545,15 @@ static u32 bnxt_fw_to_ethtool_lp_adv(struct bnxt_link_info *link_info)
 	return _bnxt_fw_to_ethtool_adv_spds(fw_speeds, fw_pause);
 }
 
+static u32 bnxt_fw_to_ethtool_support_spds(struct bnxt_link_info *link_info)
+{
+	u16 fw_speeds = link_info->support_speeds;
+	u32 supported;
+
+	supported = _bnxt_fw_to_ethtool_adv_spds(fw_speeds, 0);
+	return (supported | SUPPORTED_Pause | SUPPORTED_Asym_Pause);
+}
+
 u32 bnxt_fw_to_ethtool_speed(u16 fw_link_speed)
 {
 	switch (fw_link_speed) {
@@ -595,7 +585,6 @@ static int bnxt_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	u16 ethtool_speed;
 
 	cmd->supported = bnxt_fw_to_ethtool_support_spds(link_info);
-	cmd->supported |= SUPPORTED_Pause | SUPPORTED_Asym_Pause;
 
 	if (link_info->auto_link_speeds)
 		cmd->supported |= SUPPORTED_Autoneg;
-- 
1.8.3.1
