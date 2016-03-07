From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH v2 net-next 4/8] bnxt_en: Extend autoneg to all speeds.
Date: Mon,  7 Mar 2016 15:38:44 -0500
Message-ID: <1457383128-28645-5-git-send-email-michael.chan@broadcom.com>
References: <1457383128-28645-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5520-maca-inet1-outside.broadcom.com ([216.31.211.11]:45644
	"EHLO mail-irv-18.broadcom.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753618AbcCGUit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 15:38:49 -0500
In-Reply-To: <1457383128-28645-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow all autoneg speeds aupported by firmware to be advertised.  If
the advertising parameter is 0, then all supported speeds will be
advertised.

Remove BNXT_ALL_COPPER_ETHTOOL_SPEED which is no longer used as all
supported speeds can be advertised.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         |  4 ----
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 14 ++++----------
 2 files changed, 4 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 2f24e4e..c4424b6 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -757,10 +757,6 @@ struct bnxt_ntuple_filter {
 #define BNXT_FLTR_UPDATE	1
 };
 
-#define BNXT_ALL_COPPER_ETHTOOL_SPEED				\
-	(ADVERTISED_100baseT_Full | ADVERTISED_1000baseT_Full |	\
-	 ADVERTISED_10000baseT_Full)
-
 struct bnxt_link_info {
 	u8			media_type;
 	u8			transceiver;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index e2fe967..87dcc62 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -696,16 +696,10 @@ static int bnxt_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		return rc;
 
 	if (cmd->autoneg == AUTONEG_ENABLE) {
-		if (link_info->media_type != PORT_PHY_QCFG_RESP_MEDIA_TYPE_TP) {
-			netdev_err(dev, "Media type doesn't support autoneg\n");
-			rc = -EINVAL;
-			goto set_setting_exit;
-		}
-		if (cmd->advertising & ~(BNXT_ALL_COPPER_ETHTOOL_SPEED |
-					 ADVERTISED_Autoneg |
-					 ADVERTISED_TP |
-					 ADVERTISED_Pause |
-					 ADVERTISED_Asym_Pause)) {
+		u32 supported_spds = bnxt_fw_to_ethtool_support_spds(link_info);
+
+		if (cmd->advertising & ~(supported_spds | ADVERTISED_Autoneg |
+					 ADVERTISED_TP | ADVERTISED_FIBRE)) {
 			netdev_err(dev, "Unsupported advertising mask (adv: 0x%x)\n",
 				   cmd->advertising);
 			rc = -EINVAL;
-- 
1.8.3.1
