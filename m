From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 11/11] bnxt_en: Support new ETHTOOL_{G|S}LINKSETTINGS API.
Date: Mon, 13 Jun 2016 02:25:38 -0400
Message-ID: <1465799138-27529-12-git-send-email-michael.chan@broadcom.com>
References: <1465799138-27529-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35638 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161096AbcFMG0B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 02:26:01 -0400
Received: by mail-pa0-f43.google.com with SMTP id hl6so42689562pac.2
        for <netdev@vger.kernel.org>; Sun, 12 Jun 2016 23:26:01 -0700 (PDT)
In-Reply-To: <1465799138-27529-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To fully support 25G and 50G link settings.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 198 +++++++++++++---------
 1 file changed, 118 insertions(+), 80 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index 3362e90..d7ab2d79 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -628,7 +628,66 @@ u32 _bnxt_fw_to_ethtool_adv_spds(u16 fw_speeds, u8 fw_pause)
 	return speed_mask;
 }
 
-static u32 bnxt_fw_to_ethtool_advertised_spds(struct bnxt_link_info *link_info)
+#define BNXT_FW_TO_ETHTOOL_SPDS(fw_speeds, fw_pause, lk_ksettings, name)\
+{									\
+	if ((fw_speeds) & BNXT_LINK_SPEED_MSK_100MB)			\
+		ethtool_link_ksettings_add_link_mode(lk_ksettings, name,\
+						     100baseT_Full);	\
+	if ((fw_speeds) & BNXT_LINK_SPEED_MSK_1GB)			\
+		ethtool_link_ksettings_add_link_mode(lk_ksettings, name,\
+						     1000baseT_Full);	\
+	if ((fw_speeds) & BNXT_LINK_SPEED_MSK_10GB)			\
+		ethtool_link_ksettings_add_link_mode(lk_ksettings, name,\
+						     10000baseT_Full);	\
+	if ((fw_speeds) & BNXT_LINK_SPEED_MSK_25GB)			\
+		ethtool_link_ksettings_add_link_mode(lk_ksettings, name,\
+						     25000baseCR_Full);	\
+	if ((fw_speeds) & BNXT_LINK_SPEED_MSK_40GB)			\
+		ethtool_link_ksettings_add_link_mode(lk_ksettings, name,\
+						     40000baseCR4_Full);\
+	if ((fw_speeds) & BNXT_LINK_SPEED_MSK_50GB)			\
+		ethtool_link_ksettings_add_link_mode(lk_ksettings, name,\
+						     50000baseCR2_Full);\
+	if ((fw_pause) & BNXT_LINK_PAUSE_RX) {				\
+		ethtool_link_ksettings_add_link_mode(lk_ksettings, name,\
+						     Pause);		\
+		if (!((fw_pause) & BNXT_LINK_PAUSE_TX))			\
+			ethtool_link_ksettings_add_link_mode(		\
+					lk_ksettings, name, Asym_Pause);\
+	} else if ((fw_pause) & BNXT_LINK_PAUSE_TX) {			\
+		ethtool_link_ksettings_add_link_mode(lk_ksettings, name,\
+						     Asym_Pause);	\
+	}								\
+}
+
+#define BNXT_ETHTOOL_TO_FW_SPDS(fw_speeds, lk_ksettings, name)		\
+{									\
+	if (ethtool_link_ksettings_test_link_mode(lk_ksettings, name,	\
+						  100baseT_Full) ||	\
+	    ethtool_link_ksettings_test_link_mode(lk_ksettings, name,	\
+						  100baseT_Half))	\
+		(fw_speeds) |= BNXT_LINK_SPEED_MSK_100MB;		\
+	if (ethtool_link_ksettings_test_link_mode(lk_ksettings, name,	\
+						  1000baseT_Full) ||	\
+	    ethtool_link_ksettings_test_link_mode(lk_ksettings, name,	\
+						  1000baseT_Half))	\
+		(fw_speeds) |= BNXT_LINK_SPEED_MSK_1GB;			\
+	if (ethtool_link_ksettings_test_link_mode(lk_ksettings, name,	\
+						  10000baseT_Full))	\
+		(fw_speeds) |= BNXT_LINK_SPEED_MSK_10GB;		\
+	if (ethtool_link_ksettings_test_link_mode(lk_ksettings, name,	\
+						  25000baseCR_Full))	\
+		(fw_speeds) |= BNXT_LINK_SPEED_MSK_25GB;		\
+	if (ethtool_link_ksettings_test_link_mode(lk_ksettings, name,	\
+						  40000baseCR4_Full))	\
+		(fw_speeds) |= BNXT_LINK_SPEED_MSK_40GB;		\
+	if (ethtool_link_ksettings_test_link_mode(lk_ksettings, name,	\
+						  50000baseCR2_Full))	\
+		(fw_speeds) |= BNXT_LINK_SPEED_MSK_50GB;		\
+}
+
+static void bnxt_fw_to_ethtool_advertised_spds(struct bnxt_link_info *link_info,
+				struct ethtool_link_ksettings *lk_ksettings)
 {
 	u16 fw_speeds = link_info->auto_link_speeds;
 	u8 fw_pause = 0;
@@ -636,10 +695,11 @@ static u32 bnxt_fw_to_ethtool_advertised_spds(struct bnxt_link_info *link_info)
 	if (link_info->autoneg & BNXT_AUTONEG_FLOW_CTRL)
 		fw_pause = link_info->auto_pause_setting;
 
-	return _bnxt_fw_to_ethtool_adv_spds(fw_speeds, fw_pause);
+	BNXT_FW_TO_ETHTOOL_SPDS(fw_speeds, fw_pause, lk_ksettings, advertising);
 }
 
-static u32 bnxt_fw_to_ethtool_lp_adv(struct bnxt_link_info *link_info)
+static void bnxt_fw_to_ethtool_lp_adv(struct bnxt_link_info *link_info,
+				struct ethtool_link_ksettings *lk_ksettings)
 {
 	u16 fw_speeds = link_info->lp_auto_link_speeds;
 	u8 fw_pause = 0;
@@ -647,27 +707,24 @@ static u32 bnxt_fw_to_ethtool_lp_adv(struct bnxt_link_info *link_info)
 	if (link_info->autoneg & BNXT_AUTONEG_FLOW_CTRL)
 		fw_pause = link_info->lp_pause;
 
-	return _bnxt_fw_to_ethtool_adv_spds(fw_speeds, fw_pause);
+	BNXT_FW_TO_ETHTOOL_SPDS(fw_speeds, fw_pause, lk_ksettings,
+				lp_advertising);
 }
 
-static u32 bnxt_fw_to_ethtool_support_spds(struct bnxt_link_info *link_info)
+static void bnxt_fw_to_ethtool_support_spds(struct bnxt_link_info *link_info,
+				struct ethtool_link_ksettings *lk_ksettings)
 {
 	u16 fw_speeds = link_info->support_speeds;
-	u32 supported;
 
-	supported = _bnxt_fw_to_ethtool_adv_spds(fw_speeds, 0);
-	return supported | SUPPORTED_Pause | SUPPORTED_Asym_Pause;
-}
+	BNXT_FW_TO_ETHTOOL_SPDS(fw_speeds, 0, lk_ksettings, supported);
 
-static u32 bnxt_fw_to_ethtool_support_adv_spds(struct bnxt_link_info *link_info)
-{
-	u16 fw_speeds = link_info->support_auto_speeds;
-	u32 supported;
+	ethtool_link_ksettings_add_link_mode(lk_ksettings, supported, Pause);
+	ethtool_link_ksettings_add_link_mode(lk_ksettings, supported,
+					     Asym_Pause);
 
-	supported = _bnxt_fw_to_ethtool_adv_spds(fw_speeds, 0);
-	if (supported)
-		supported |= SUPPORTED_Pause | SUPPORTED_Asym_Pause;
-	return supported;
+	if (link_info->support_auto_speeds)
+		ethtool_link_ksettings_add_link_mode(lk_ksettings, supported,
+						     Autoneg);
 }
 
 u32 bnxt_fw_to_ethtool_speed(u16 fw_link_speed)
@@ -694,65 +751,62 @@ u32 bnxt_fw_to_ethtool_speed(u16 fw_link_speed)
 	}
 }
 
-static int bnxt_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int bnxt_get_link_ksettings(struct net_device *dev,
+				   struct ethtool_link_ksettings *lk_ksettings)
 {
 	struct bnxt *bp = netdev_priv(dev);
 	struct bnxt_link_info *link_info = &bp->link_info;
-	u16 ethtool_speed;
-
-	cmd->supported = bnxt_fw_to_ethtool_support_spds(link_info);
+	struct ethtool_link_settings *base = &lk_ksettings->base;
+	u32 ethtool_speed;
 
-	if (link_info->support_auto_speeds)
-		cmd->supported |= SUPPORTED_Autoneg;
+	ethtool_link_ksettings_zero_link_mode(lk_ksettings, supported);
+	bnxt_fw_to_ethtool_support_spds(link_info, lk_ksettings);
 
+	ethtool_link_ksettings_zero_link_mode(lk_ksettings, advertising);
 	if (link_info->autoneg) {
-		cmd->advertising =
-			bnxt_fw_to_ethtool_advertised_spds(link_info);
-		cmd->advertising |= ADVERTISED_Autoneg;
-		cmd->autoneg = AUTONEG_ENABLE;
+		bnxt_fw_to_ethtool_advertised_spds(link_info, lk_ksettings);
+		ethtool_link_ksettings_add_link_mode(lk_ksettings,
+						     advertising, Autoneg);
+		base->autoneg = AUTONEG_ENABLE;
 		if (link_info->phy_link_status == BNXT_LINK_LINK)
-			cmd->lp_advertising =
-				bnxt_fw_to_ethtool_lp_adv(link_info);
+			bnxt_fw_to_ethtool_lp_adv(link_info, lk_ksettings);
 		ethtool_speed = bnxt_fw_to_ethtool_speed(link_info->link_speed);
 		if (!netif_carrier_ok(dev))
-			cmd->duplex = DUPLEX_UNKNOWN;
+			base->duplex = DUPLEX_UNKNOWN;
 		else if (link_info->duplex & BNXT_LINK_DUPLEX_FULL)
-			cmd->duplex = DUPLEX_FULL;
+			base->duplex = DUPLEX_FULL;
 		else
-			cmd->duplex = DUPLEX_HALF;
+			base->duplex = DUPLEX_HALF;
 	} else {
-		cmd->autoneg = AUTONEG_DISABLE;
-		cmd->advertising = 0;
+		base->autoneg = AUTONEG_DISABLE;
 		ethtool_speed =
 			bnxt_fw_to_ethtool_speed(link_info->req_link_speed);
-		cmd->duplex = DUPLEX_HALF;
+		base->duplex = DUPLEX_HALF;
 		if (link_info->req_duplex == BNXT_LINK_DUPLEX_FULL)
-			cmd->duplex = DUPLEX_FULL;
+			base->duplex = DUPLEX_FULL;
 	}
-	ethtool_cmd_speed_set(cmd, ethtool_speed);
+	base->speed = ethtool_speed;
 
-	cmd->port = PORT_NONE;
+	base->port = PORT_NONE;
 	if (link_info->media_type == PORT_PHY_QCFG_RESP_MEDIA_TYPE_TP) {
-		cmd->port = PORT_TP;
-		cmd->supported |= SUPPORTED_TP;
-		cmd->advertising |= ADVERTISED_TP;
+		base->port = PORT_TP;
+		ethtool_link_ksettings_add_link_mode(lk_ksettings, supported,
+						     TP);
+		ethtool_link_ksettings_add_link_mode(lk_ksettings, advertising,
+						     TP);
 	} else {
-		cmd->supported |= SUPPORTED_FIBRE;
-		cmd->advertising |= ADVERTISED_FIBRE;
+		ethtool_link_ksettings_add_link_mode(lk_ksettings, supported,
+						     FIBRE);
+		ethtool_link_ksettings_add_link_mode(lk_ksettings, advertising,
+						     FIBRE);
 
 		if (link_info->media_type == PORT_PHY_QCFG_RESP_MEDIA_TYPE_DAC)
-			cmd->port = PORT_DA;
+			base->port = PORT_DA;
 		else if (link_info->media_type ==
 			 PORT_PHY_QCFG_RESP_MEDIA_TYPE_FIBRE)
-			cmd->port = PORT_FIBRE;
+			base->port = PORT_FIBRE;
 	}
-
-	if (link_info->transceiver ==
-	    PORT_PHY_QCFG_RESP_XCVR_PKG_TYPE_XCVR_INTERNAL)
-		cmd->transceiver = XCVR_INTERNAL;
-	else
-		cmd->transceiver = XCVR_EXTERNAL;
-	cmd->phy_address = link_info->phy_addr;
+	base->phy_address = link_info->phy_addr;
 
 	return 0;
 }
@@ -826,34 +880,22 @@ u16 bnxt_get_fw_auto_link_speeds(u32 advertising)
 	return fw_speed_mask;
 }
 
-static int bnxt_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int bnxt_set_link_ksettings(struct net_device *dev,
+			   const struct ethtool_link_ksettings *lk_ksettings)
 {
-	int rc = 0;
 	struct bnxt *bp = netdev_priv(dev);
 	struct bnxt_link_info *link_info = &bp->link_info;
+	const struct ethtool_link_settings *base = &lk_ksettings->base;
 	u32 speed, fw_advertising = 0;
 	bool set_pause = false;
+	int rc = 0;
 
 	if (!BNXT_SINGLE_PF(bp))
-		return rc;
-
-	if (cmd->autoneg == AUTONEG_ENABLE) {
-		u32 supported_spds =
-			bnxt_fw_to_ethtool_support_adv_spds(link_info);
+		return -EOPNOTSUPP;
 
-		if (!supported_spds) {
-			netdev_err(dev, "Autoneg not supported\n");
-			rc = -EINVAL;
-			goto set_setting_exit;
-		}
-		if (cmd->advertising & ~(supported_spds | ADVERTISED_Autoneg |
-					 ADVERTISED_TP | ADVERTISED_FIBRE)) {
-			netdev_err(dev, "Unsupported advertising mask (adv: 0x%x)\n",
-				   cmd->advertising);
-			rc = -EINVAL;
-			goto set_setting_exit;
-		}
-		fw_advertising = bnxt_get_fw_auto_link_speeds(cmd->advertising);
+	if (base->autoneg == AUTONEG_ENABLE) {
+		BNXT_ETHTOOL_TO_FW_SPDS(fw_advertising, lk_ksettings,
+					advertising);
 		link_info->autoneg |= BNXT_AUTONEG_SPEED;
 		if (!fw_advertising)
 			link_info->advertising = link_info->support_auto_speeds;
@@ -874,16 +916,12 @@ static int bnxt_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 			rc = -EINVAL;
 			goto set_setting_exit;
 		}
-		/* TODO: currently don't support half duplex */
-		if (cmd->duplex == DUPLEX_HALF) {
+		if (base->duplex == DUPLEX_HALF) {
 			netdev_err(dev, "HALF DUPLEX is not supported!\n");
 			rc = -EINVAL;
 			goto set_setting_exit;
 		}
-		/* If received a request for an unknown duplex, assume full*/
-		if (cmd->duplex == DUPLEX_UNKNOWN)
-			cmd->duplex = DUPLEX_FULL;
-		speed = ethtool_cmd_speed(cmd);
+		speed = base->speed;
 		fw_speed = bnxt_get_fw_speed(dev, speed);
 		if (!fw_speed) {
 			rc = -EINVAL;
@@ -1629,8 +1667,8 @@ static int bnxt_get_module_eeprom(struct net_device *dev,
 }
 
 const struct ethtool_ops bnxt_ethtool_ops = {
-	.get_settings		= bnxt_get_settings,
-	.set_settings		= bnxt_set_settings,
+	.get_link_ksettings	= bnxt_get_link_ksettings,
+	.set_link_ksettings	= bnxt_set_link_ksettings,
 	.get_pauseparam		= bnxt_get_pauseparam,
 	.set_pauseparam		= bnxt_set_pauseparam,
 	.get_drvinfo		= bnxt_get_drvinfo,
-- 
1.8.3.1
