From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: qlogic: qlcnic: use new api ethtool_{get|set}_link_ksettings
Date: Sun, 19 Feb 2017 23:06:01 +0100
Message-ID: <1487541961-28691-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: harish.patil@cavium.com, manish.chopra@cavium.com,
        Dept-GELinuxNICDev@cavium.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33985 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751517AbdBSWHh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Feb 2017 17:07:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |   94 ++++++++-------
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |    6 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |  132 ++++++++++---------
 3 files changed, 123 insertions(+), 109 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index bdbcd2b..99b187b 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -3252,12 +3252,13 @@ int qlcnic_83xx_test_link(struct qlcnic_adapter *adapter)
 	return config;
 }
 
-int qlcnic_83xx_get_settings(struct qlcnic_adapter *adapter,
-			     struct ethtool_cmd *ecmd)
+int qlcnic_83xx_get_link_ksettings(struct qlcnic_adapter *adapter,
+				   struct ethtool_link_ksettings *ecmd)
 {
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	u32 config = 0;
 	int status = 0;
+	u32 supported, advertising;
 
 	if (!test_bit(__QLCNIC_MAINTENANCE_MODE, &adapter->state)) {
 		/* Get port configuration info */
@@ -3271,45 +3272,48 @@ int qlcnic_83xx_get_settings(struct qlcnic_adapter *adapter,
 	ahw->board_type = QLCNIC_BRDTYPE_83XX_10G;
 
 	if (netif_running(adapter->netdev) && ahw->has_link_events) {
-		ethtool_cmd_speed_set(ecmd, ahw->link_speed);
-		ecmd->duplex = ahw->link_duplex;
-		ecmd->autoneg = ahw->link_autoneg;
+		ecmd->base.speed = ahw->link_speed;
+		ecmd->base.duplex = ahw->link_duplex;
+		ecmd->base.autoneg = ahw->link_autoneg;
 	} else {
-		ethtool_cmd_speed_set(ecmd, SPEED_UNKNOWN);
-		ecmd->duplex = DUPLEX_UNKNOWN;
-		ecmd->autoneg = AUTONEG_DISABLE;
+		ecmd->base.speed = SPEED_UNKNOWN;
+		ecmd->base.duplex = DUPLEX_UNKNOWN;
+		ecmd->base.autoneg = AUTONEG_DISABLE;
 	}
 
-	ecmd->supported = (SUPPORTED_10baseT_Full |
+	supported = (SUPPORTED_10baseT_Full |
 			   SUPPORTED_100baseT_Full |
 			   SUPPORTED_1000baseT_Full |
 			   SUPPORTED_10000baseT_Full |
 			   SUPPORTED_Autoneg);
 
-	if (ecmd->autoneg == AUTONEG_ENABLE) {
+	ethtool_convert_link_mode_to_legacy_u32(&advertising,
+						ecmd->link_modes.advertising);
+
+	if (ecmd->base.autoneg == AUTONEG_ENABLE) {
 		if (ahw->port_config & QLC_83XX_10_CAPABLE)
-			ecmd->advertising |= SUPPORTED_10baseT_Full;
+			advertising |= SUPPORTED_10baseT_Full;
 		if (ahw->port_config & QLC_83XX_100_CAPABLE)
-			ecmd->advertising |= SUPPORTED_100baseT_Full;
+			advertising |= SUPPORTED_100baseT_Full;
 		if (ahw->port_config & QLC_83XX_1G_CAPABLE)
-			ecmd->advertising |= SUPPORTED_1000baseT_Full;
+			advertising |= SUPPORTED_1000baseT_Full;
 		if (ahw->port_config & QLC_83XX_10G_CAPABLE)
-			ecmd->advertising |= SUPPORTED_10000baseT_Full;
+			advertising |= SUPPORTED_10000baseT_Full;
 		if (ahw->port_config & QLC_83XX_AUTONEG_ENABLE)
-			ecmd->advertising |= ADVERTISED_Autoneg;
+			advertising |= ADVERTISED_Autoneg;
 	} else {
 		switch (ahw->link_speed) {
 		case SPEED_10:
-			ecmd->advertising = SUPPORTED_10baseT_Full;
+			advertising = SUPPORTED_10baseT_Full;
 			break;
 		case SPEED_100:
-			ecmd->advertising = SUPPORTED_100baseT_Full;
+			advertising = SUPPORTED_100baseT_Full;
 			break;
 		case SPEED_1000:
-			ecmd->advertising = SUPPORTED_1000baseT_Full;
+			advertising = SUPPORTED_1000baseT_Full;
 			break;
 		case SPEED_10000:
-			ecmd->advertising = SUPPORTED_10000baseT_Full;
+			advertising = SUPPORTED_10000baseT_Full;
 			break;
 		default:
 			break;
@@ -3319,56 +3323,58 @@ int qlcnic_83xx_get_settings(struct qlcnic_adapter *adapter,
 
 	switch (ahw->supported_type) {
 	case PORT_FIBRE:
-		ecmd->supported |= SUPPORTED_FIBRE;
-		ecmd->advertising |= ADVERTISED_FIBRE;
-		ecmd->port = PORT_FIBRE;
-		ecmd->transceiver = XCVR_EXTERNAL;
+		supported |= SUPPORTED_FIBRE;
+		advertising |= ADVERTISED_FIBRE;
+		ecmd->base.port = PORT_FIBRE;
 		break;
 	case PORT_TP:
-		ecmd->supported |= SUPPORTED_TP;
-		ecmd->advertising |= ADVERTISED_TP;
-		ecmd->port = PORT_TP;
-		ecmd->transceiver = XCVR_INTERNAL;
+		supported |= SUPPORTED_TP;
+		advertising |= ADVERTISED_TP;
+		ecmd->base.port = PORT_TP;
 		break;
 	case PORT_DA:
-		ecmd->supported |= SUPPORTED_FIBRE;
-		ecmd->advertising |= ADVERTISED_FIBRE;
-		ecmd->port = PORT_DA;
-		ecmd->transceiver = XCVR_EXTERNAL;
+		supported |= SUPPORTED_FIBRE;
+		advertising |= ADVERTISED_FIBRE;
+		ecmd->base.port = PORT_DA;
 		break;
 	default:
-		ecmd->supported |= SUPPORTED_FIBRE;
-		ecmd->advertising |= ADVERTISED_FIBRE;
-		ecmd->port = PORT_OTHER;
-		ecmd->transceiver = XCVR_EXTERNAL;
+		supported |= SUPPORTED_FIBRE;
+		advertising |= ADVERTISED_FIBRE;
+		ecmd->base.port = PORT_OTHER;
 		break;
 	}
-	ecmd->phy_address = ahw->physical_port;
+	ecmd->base.phy_address = ahw->physical_port;
+
+	ethtool_convert_legacy_u32_to_link_mode(ecmd->link_modes.supported,
+						supported);
+	ethtool_convert_legacy_u32_to_link_mode(ecmd->link_modes.advertising,
+						advertising);
+
 	return status;
 }
 
-int qlcnic_83xx_set_settings(struct qlcnic_adapter *adapter,
-			     struct ethtool_cmd *ecmd)
+int qlcnic_83xx_set_link_ksettings(struct qlcnic_adapter *adapter,
+				   const struct ethtool_link_ksettings *ecmd)
 {
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	u32 config = adapter->ahw->port_config;
 	int status = 0;
 
 	/* 83xx devices do not support Half duplex */
-	if (ecmd->duplex == DUPLEX_HALF) {
-			netdev_info(adapter->netdev,
-				    "Half duplex mode not supported\n");
-			return -EINVAL;
+	if (ecmd->base.duplex == DUPLEX_HALF) {
+		netdev_info(adapter->netdev,
+			    "Half duplex mode not supported\n");
+		return -EINVAL;
 	}
 
-	if (ecmd->autoneg) {
+	if (ecmd->base.autoneg) {
 		ahw->port_config |= QLC_83XX_AUTONEG_ENABLE;
 		ahw->port_config |= (QLC_83XX_100_CAPABLE |
 				     QLC_83XX_1G_CAPABLE |
 				     QLC_83XX_10G_CAPABLE);
 	} else { /* force speed */
 		ahw->port_config &= ~QLC_83XX_AUTONEG_ENABLE;
-		switch (ethtool_cmd_speed(ecmd)) {
+		switch (ecmd->base.speed) {
 		case SPEED_10:
 			ahw->port_config &= ~(QLC_83XX_100_CAPABLE |
 					      QLC_83XX_1G_CAPABLE |
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
index 331ae2c..3dfe8e2 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
@@ -628,8 +628,10 @@ int qlcnic_83xx_get_vnic_vport_info(struct qlcnic_adapter *,
 void qlcnic_83xx_get_minidump_template(struct qlcnic_adapter *);
 void qlcnic_83xx_get_stats(struct qlcnic_adapter *adapter, u64 *data);
 int qlcnic_83xx_extend_md_capab(struct qlcnic_adapter *);
-int qlcnic_83xx_get_settings(struct qlcnic_adapter *, struct ethtool_cmd *);
-int qlcnic_83xx_set_settings(struct qlcnic_adapter *, struct ethtool_cmd *);
+int qlcnic_83xx_get_link_ksettings(struct qlcnic_adapter *adapter,
+				   struct ethtool_link_ksettings *ecmd);
+int qlcnic_83xx_set_link_ksettings(struct qlcnic_adapter *adapter,
+				   const struct ethtool_link_ksettings *ecmd);
 void qlcnic_83xx_get_pauseparam(struct qlcnic_adapter *,
 				struct ethtool_pauseparam *);
 int qlcnic_83xx_set_pauseparam(struct qlcnic_adapter *,
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index 0a2318c..9a869c1 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -285,42 +285,43 @@ static int qlcnic_get_eeprom_len(struct net_device *dev)
 		sizeof(drvinfo->version));
 }
 
-static int qlcnic_82xx_get_settings(struct qlcnic_adapter *adapter,
-				    struct ethtool_cmd *ecmd)
+static int qlcnic_82xx_get_link_ksettings(struct qlcnic_adapter *adapter,
+					  struct ethtool_link_ksettings *ecmd)
 {
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	u32 speed, reg;
 	int check_sfp_module = 0, err = 0;
 	u16 pcifn = ahw->pci_func;
+	u32 supported, advertising;
 
 	/* read which mode */
 	if (adapter->ahw->port_type == QLCNIC_GBE) {
-		ecmd->supported = (SUPPORTED_10baseT_Half |
+		supported = (SUPPORTED_10baseT_Half |
 				   SUPPORTED_10baseT_Full |
 				   SUPPORTED_100baseT_Half |
 				   SUPPORTED_100baseT_Full |
 				   SUPPORTED_1000baseT_Half |
 				   SUPPORTED_1000baseT_Full);
 
-		ecmd->advertising = (ADVERTISED_100baseT_Half |
+		advertising = (ADVERTISED_100baseT_Half |
 				     ADVERTISED_100baseT_Full |
 				     ADVERTISED_1000baseT_Half |
 				     ADVERTISED_1000baseT_Full);
 
-		ethtool_cmd_speed_set(ecmd, adapter->ahw->link_speed);
-		ecmd->duplex = adapter->ahw->link_duplex;
-		ecmd->autoneg = adapter->ahw->link_autoneg;
+		ecmd->base.speed = adapter->ahw->link_speed;
+		ecmd->base.duplex = adapter->ahw->link_duplex;
+		ecmd->base.autoneg = adapter->ahw->link_autoneg;
 
 	} else if (adapter->ahw->port_type == QLCNIC_XGBE) {
 		u32 val = 0;
 		val = QLCRD32(adapter, QLCNIC_PORT_MODE_ADDR, &err);
 
 		if (val == QLCNIC_PORT_MODE_802_3_AP) {
-			ecmd->supported = SUPPORTED_1000baseT_Full;
-			ecmd->advertising = ADVERTISED_1000baseT_Full;
+			supported = SUPPORTED_1000baseT_Full;
+			advertising = ADVERTISED_1000baseT_Full;
 		} else {
-			ecmd->supported = SUPPORTED_10000baseT_Full;
-			ecmd->advertising = ADVERTISED_10000baseT_Full;
+			supported = SUPPORTED_10000baseT_Full;
+			advertising = ADVERTISED_10000baseT_Full;
 		}
 
 		if (netif_running(adapter->netdev) && ahw->has_link_events) {
@@ -331,73 +332,72 @@ static int qlcnic_82xx_get_settings(struct qlcnic_adapter *adapter,
 				ahw->link_speed = speed * P3P_LINK_SPEED_MHZ;
 			}
 
-			ethtool_cmd_speed_set(ecmd, ahw->link_speed);
-			ecmd->autoneg = ahw->link_autoneg;
-			ecmd->duplex = ahw->link_duplex;
+			ecmd->base.speed = ahw->link_speed;
+			ecmd->base.autoneg = ahw->link_autoneg;
+			ecmd->base.duplex = ahw->link_duplex;
 			goto skip;
 		}
 
-		ethtool_cmd_speed_set(ecmd, SPEED_UNKNOWN);
-		ecmd->duplex = DUPLEX_UNKNOWN;
-		ecmd->autoneg = AUTONEG_DISABLE;
+		ecmd->base.speed = SPEED_UNKNOWN;
+		ecmd->base.duplex = DUPLEX_UNKNOWN;
+		ecmd->base.autoneg = AUTONEG_DISABLE;
 	} else
 		return -EIO;
 
 skip:
-	ecmd->phy_address = adapter->ahw->physical_port;
-	ecmd->transceiver = XCVR_EXTERNAL;
+	ecmd->base.phy_address = adapter->ahw->physical_port;
 
 	switch (adapter->ahw->board_type) {
 	case QLCNIC_BRDTYPE_P3P_REF_QG:
 	case QLCNIC_BRDTYPE_P3P_4_GB:
 	case QLCNIC_BRDTYPE_P3P_4_GB_MM:
 
-		ecmd->supported |= SUPPORTED_Autoneg;
-		ecmd->advertising |= ADVERTISED_Autoneg;
+		supported |= SUPPORTED_Autoneg;
+		advertising |= ADVERTISED_Autoneg;
 	case QLCNIC_BRDTYPE_P3P_10G_CX4:
 	case QLCNIC_BRDTYPE_P3P_10G_CX4_LP:
 	case QLCNIC_BRDTYPE_P3P_10000_BASE_T:
-		ecmd->supported |= SUPPORTED_TP;
-		ecmd->advertising |= ADVERTISED_TP;
-		ecmd->port = PORT_TP;
-		ecmd->autoneg =  adapter->ahw->link_autoneg;
+		supported |= SUPPORTED_TP;
+		advertising |= ADVERTISED_TP;
+		ecmd->base.port = PORT_TP;
+		ecmd->base.autoneg =  adapter->ahw->link_autoneg;
 		break;
 	case QLCNIC_BRDTYPE_P3P_IMEZ:
 	case QLCNIC_BRDTYPE_P3P_XG_LOM:
 	case QLCNIC_BRDTYPE_P3P_HMEZ:
-		ecmd->supported |= SUPPORTED_MII;
-		ecmd->advertising |= ADVERTISED_MII;
-		ecmd->port = PORT_MII;
-		ecmd->autoneg = AUTONEG_DISABLE;
+		supported |= SUPPORTED_MII;
+		advertising |= ADVERTISED_MII;
+		ecmd->base.port = PORT_MII;
+		ecmd->base.autoneg = AUTONEG_DISABLE;
 		break;
 	case QLCNIC_BRDTYPE_P3P_10G_SFP_PLUS:
 	case QLCNIC_BRDTYPE_P3P_10G_SFP_CT:
 	case QLCNIC_BRDTYPE_P3P_10G_SFP_QT:
-		ecmd->advertising |= ADVERTISED_TP;
-		ecmd->supported |= SUPPORTED_TP;
+		advertising |= ADVERTISED_TP;
+		supported |= SUPPORTED_TP;
 		check_sfp_module = netif_running(adapter->netdev) &&
 				   ahw->has_link_events;
 	case QLCNIC_BRDTYPE_P3P_10G_XFP:
-		ecmd->supported |= SUPPORTED_FIBRE;
-		ecmd->advertising |= ADVERTISED_FIBRE;
-		ecmd->port = PORT_FIBRE;
-		ecmd->autoneg = AUTONEG_DISABLE;
+		supported |= SUPPORTED_FIBRE;
+		advertising |= ADVERTISED_FIBRE;
+		ecmd->base.port = PORT_FIBRE;
+		ecmd->base.autoneg = AUTONEG_DISABLE;
 		break;
 	case QLCNIC_BRDTYPE_P3P_10G_TP:
 		if (adapter->ahw->port_type == QLCNIC_XGBE) {
-			ecmd->autoneg = AUTONEG_DISABLE;
-			ecmd->supported |= (SUPPORTED_FIBRE | SUPPORTED_TP);
-			ecmd->advertising |=
+			ecmd->base.autoneg = AUTONEG_DISABLE;
+			supported |= (SUPPORTED_FIBRE | SUPPORTED_TP);
+			advertising |=
 				(ADVERTISED_FIBRE | ADVERTISED_TP);
-			ecmd->port = PORT_FIBRE;
+			ecmd->base.port = PORT_FIBRE;
 			check_sfp_module = netif_running(adapter->netdev) &&
 					   ahw->has_link_events;
 		} else {
-			ecmd->autoneg = AUTONEG_ENABLE;
-			ecmd->supported |= (SUPPORTED_TP | SUPPORTED_Autoneg);
-			ecmd->advertising |=
+			ecmd->base.autoneg = AUTONEG_ENABLE;
+			supported |= (SUPPORTED_TP | SUPPORTED_Autoneg);
+			advertising |=
 				(ADVERTISED_TP | ADVERTISED_Autoneg);
-			ecmd->port = PORT_TP;
+			ecmd->base.port = PORT_TP;
 		}
 		break;
 	default:
@@ -412,47 +412,52 @@ static int qlcnic_82xx_get_settings(struct qlcnic_adapter *adapter,
 		case LINKEVENT_MODULE_OPTICAL_SRLR:
 		case LINKEVENT_MODULE_OPTICAL_LRM:
 		case LINKEVENT_MODULE_OPTICAL_SFP_1G:
-			ecmd->port = PORT_FIBRE;
+			ecmd->base.port = PORT_FIBRE;
 			break;
 		case LINKEVENT_MODULE_TWINAX_UNSUPPORTED_CABLE:
 		case LINKEVENT_MODULE_TWINAX_UNSUPPORTED_CABLELEN:
 		case LINKEVENT_MODULE_TWINAX:
-			ecmd->port = PORT_TP;
+			ecmd->base.port = PORT_TP;
 			break;
 		default:
-			ecmd->port = PORT_OTHER;
+			ecmd->base.port = PORT_OTHER;
 		}
 	}
 
+	ethtool_convert_legacy_u32_to_link_mode(ecmd->link_modes.supported,
+						supported);
+	ethtool_convert_legacy_u32_to_link_mode(ecmd->link_modes.advertising,
+						advertising);
+
 	return 0;
 }
 
-static int qlcnic_get_settings(struct net_device *dev,
-			       struct ethtool_cmd *ecmd)
+static int qlcnic_get_link_ksettings(struct net_device *dev,
+				     struct ethtool_link_ksettings *ecmd)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
 
 	if (qlcnic_82xx_check(adapter))
-		return qlcnic_82xx_get_settings(adapter, ecmd);
+		return qlcnic_82xx_get_link_ksettings(adapter, ecmd);
 	else if (qlcnic_83xx_check(adapter))
-		return qlcnic_83xx_get_settings(adapter, ecmd);
+		return qlcnic_83xx_get_link_ksettings(adapter, ecmd);
 
 	return -EIO;
 }
 
 
 static int qlcnic_set_port_config(struct qlcnic_adapter *adapter,
-				  struct ethtool_cmd *ecmd)
+				  const struct ethtool_link_ksettings *ecmd)
 {
 	u32 ret = 0, config = 0;
 	/* read which mode */
-	if (ecmd->duplex)
+	if (ecmd->base.duplex)
 		config |= 0x1;
 
-	if (ecmd->autoneg)
+	if (ecmd->base.autoneg)
 		config |= 0x2;
 
-	switch (ethtool_cmd_speed(ecmd)) {
+	switch (ecmd->base.speed) {
 	case SPEED_10:
 		config |= (0 << 8);
 		break;
@@ -475,7 +480,8 @@ static int qlcnic_set_port_config(struct qlcnic_adapter *adapter,
 	return ret;
 }
 
-static int qlcnic_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
+static int qlcnic_set_link_ksettings(struct net_device *dev,
+				     const struct ethtool_link_ksettings *ecmd)
 {
 	u32 ret = 0;
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
@@ -484,16 +490,16 @@ static int qlcnic_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 		return -EOPNOTSUPP;
 
 	if (qlcnic_83xx_check(adapter))
-		ret = qlcnic_83xx_set_settings(adapter, ecmd);
+		ret = qlcnic_83xx_set_link_ksettings(adapter, ecmd);
 	else
 		ret = qlcnic_set_port_config(adapter, ecmd);
 
 	if (!ret)
 		return ret;
 
-	adapter->ahw->link_speed = ethtool_cmd_speed(ecmd);
-	adapter->ahw->link_duplex = ecmd->duplex;
-	adapter->ahw->link_autoneg = ecmd->autoneg;
+	adapter->ahw->link_speed = ecmd->base.speed;
+	adapter->ahw->link_duplex = ecmd->base.duplex;
+	adapter->ahw->link_autoneg = ecmd->base.autoneg;
 
 	if (!netif_running(dev))
 		return 0;
@@ -1822,8 +1828,6 @@ static int qlcnic_set_dump_mask(struct qlcnic_adapter *adapter, u32 mask)
 }
 
 const struct ethtool_ops qlcnic_ethtool_ops = {
-	.get_settings = qlcnic_get_settings,
-	.set_settings = qlcnic_set_settings,
 	.get_drvinfo = qlcnic_get_drvinfo,
 	.get_regs_len = qlcnic_get_regs_len,
 	.get_regs = qlcnic_get_regs,
@@ -1850,10 +1854,11 @@ static int qlcnic_set_dump_mask(struct qlcnic_adapter *adapter, u32 mask)
 	.get_dump_flag = qlcnic_get_dump_flag,
 	.get_dump_data = qlcnic_get_dump_data,
 	.set_dump = qlcnic_set_dump,
+	.get_link_ksettings = qlcnic_get_link_ksettings,
+	.set_link_ksettings = qlcnic_set_link_ksettings,
 };
 
 const struct ethtool_ops qlcnic_sriov_vf_ethtool_ops = {
-	.get_settings		= qlcnic_get_settings,
 	.get_drvinfo		= qlcnic_get_drvinfo,
 	.get_regs_len		= qlcnic_get_regs_len,
 	.get_regs		= qlcnic_get_regs,
@@ -1872,12 +1877,13 @@ static int qlcnic_set_dump_mask(struct qlcnic_adapter *adapter, u32 mask)
 	.set_coalesce		= qlcnic_set_intr_coalesce,
 	.set_msglevel		= qlcnic_set_msglevel,
 	.get_msglevel		= qlcnic_get_msglevel,
+	.get_link_ksettings	= qlcnic_get_link_ksettings,
 };
 
 const struct ethtool_ops qlcnic_ethtool_failed_ops = {
-	.get_settings		= qlcnic_get_settings,
 	.get_drvinfo		= qlcnic_get_drvinfo,
 	.set_msglevel		= qlcnic_set_msglevel,
 	.get_msglevel		= qlcnic_get_msglevel,
 	.set_dump		= qlcnic_set_dump,
+	.get_link_ksettings	= qlcnic_get_link_ksettings,
 };
-- 
1.7.4.4
