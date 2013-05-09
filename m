From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net v2 4/8] qlcnic: Fix ethtool supported port status for 83xx
Date: Thu, 9 May 2013 15:25:12 -0400
Message-ID: <1368127516-9943-5-git-send-email-shahed.shaikh@qlogic.com>
References: <1368127516-9943-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe001.messaging.microsoft.com ([216.32.180.184]:50982
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751761Ab3EITuA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 May 2013 15:50:00 -0400
In-Reply-To: <1368127516-9943-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>

o Fix display for interface while using 'ethtool <device>' for 83xx adapter

Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |    2 +
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |   68 +++++++++++++++++++-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |    2 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |   49 +++++++-------
 4 files changed, 94 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 90c253b..019c5f7 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -429,6 +429,7 @@ struct qlcnic_hardware_context {
 
 	u16 port_type;
 	u16 board_type;
+	u16 supported_type;
 
 	u16 link_speed;
 	u16 link_duplex;
@@ -1514,6 +1515,7 @@ void qlcnic_create_diag_entries(struct qlcnic_adapter *adapter);
 void qlcnic_remove_diag_entries(struct qlcnic_adapter *adapter);
 void qlcnic_82xx_add_sysfs(struct qlcnic_adapter *adapter);
 void qlcnic_82xx_remove_sysfs(struct qlcnic_adapter *adapter);
+int qlcnic_82xx_get_settings(struct qlcnic_adapter *, struct ethtool_cmd *);
 
 int qlcnicvf_config_bridged_mode(struct qlcnic_adapter *, u32);
 int qlcnicvf_config_led(struct qlcnic_adapter *, u32, u32);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index ea790a9..642fca0 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -2830,6 +2830,23 @@ int qlcnic_83xx_test_link(struct qlcnic_adapter *adapter)
 			break;
 		}
 		config = cmd.rsp.arg[3];
+		if (QLC_83XX_SFP_PRESENT(config)) {
+			switch (ahw->module_type) {
+			case LINKEVENT_MODULE_OPTICAL_UNKNOWN:
+			case LINKEVENT_MODULE_OPTICAL_SRLR:
+			case LINKEVENT_MODULE_OPTICAL_LRM:
+			case LINKEVENT_MODULE_OPTICAL_SFP_1G:
+				ahw->supported_type = PORT_FIBRE;
+				break;
+			case LINKEVENT_MODULE_TWINAX_UNSUPPORTED_CABLE:
+			case LINKEVENT_MODULE_TWINAX_UNSUPPORTED_CABLELEN:
+			case LINKEVENT_MODULE_TWINAX:
+				ahw->supported_type = PORT_TP;
+				break;
+			default:
+				ahw->supported_type = PORT_OTHER;
+			}
+		}
 		if (config & 1)
 			err = 1;
 	}
@@ -2838,7 +2855,8 @@ out:
 	return config;
 }
 
-int qlcnic_83xx_get_settings(struct qlcnic_adapter *adapter)
+int qlcnic_83xx_get_settings(struct qlcnic_adapter *adapter,
+			     struct ethtool_cmd *ecmd)
 {
 	u32 config = 0;
 	int status = 0;
@@ -2851,6 +2869,54 @@ int qlcnic_83xx_get_settings(struct qlcnic_adapter *adapter)
 	ahw->module_type = QLC_83XX_SFP_MODULE_TYPE(config);
 	/* hard code until there is a way to get it from flash */
 	ahw->board_type = QLCNIC_BRDTYPE_83XX_10G;
+
+	if (netif_running(adapter->netdev) && ahw->has_link_events) {
+		ethtool_cmd_speed_set(ecmd, ahw->link_speed);
+		ecmd->duplex = ahw->link_duplex;
+		ecmd->autoneg = ahw->link_autoneg;
+	} else {
+		ethtool_cmd_speed_set(ecmd, SPEED_UNKNOWN);
+		ecmd->duplex = DUPLEX_UNKNOWN;
+		ecmd->autoneg = AUTONEG_DISABLE;
+	}
+
+	if (ahw->port_type == QLCNIC_XGBE) {
+		ecmd->supported = SUPPORTED_1000baseT_Full;
+		ecmd->advertising = ADVERTISED_1000baseT_Full;
+	} else {
+		ecmd->supported = (SUPPORTED_10baseT_Half |
+				   SUPPORTED_10baseT_Full |
+				   SUPPORTED_100baseT_Half |
+				   SUPPORTED_100baseT_Full |
+				   SUPPORTED_1000baseT_Half |
+				   SUPPORTED_1000baseT_Full);
+		ecmd->advertising = (ADVERTISED_100baseT_Half |
+				     ADVERTISED_100baseT_Full |
+				     ADVERTISED_1000baseT_Half |
+				     ADVERTISED_1000baseT_Full);
+	}
+
+	switch (ahw->supported_type) {
+	case PORT_FIBRE:
+		ecmd->supported |= SUPPORTED_FIBRE;
+		ecmd->advertising |= ADVERTISED_FIBRE;
+		ecmd->port = PORT_FIBRE;
+		ecmd->transceiver = XCVR_EXTERNAL;
+		break;
+	case PORT_TP:
+		ecmd->supported |= SUPPORTED_TP;
+		ecmd->advertising |= ADVERTISED_TP;
+		ecmd->port = PORT_TP;
+		ecmd->transceiver = XCVR_INTERNAL;
+		break;
+	default:
+		ecmd->supported |= SUPPORTED_FIBRE;
+		ecmd->advertising |= ADVERTISED_FIBRE;
+		ecmd->port = PORT_OTHER;
+		ecmd->transceiver = XCVR_EXTERNAL;
+		break;
+	}
+	ecmd->phy_address = ahw->physical_port;
 	return status;
 }
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
index 1f1d85e..faf5553 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
@@ -603,7 +603,7 @@ int qlcnic_83xx_get_vnic_pf_info(struct qlcnic_adapter *, struct qlcnic_info *);
 
 void qlcnic_83xx_get_minidump_template(struct qlcnic_adapter *);
 void qlcnic_83xx_get_stats(struct qlcnic_adapter *adapter, u64 *data);
-int qlcnic_83xx_get_settings(struct qlcnic_adapter *);
+int qlcnic_83xx_get_settings(struct qlcnic_adapter *, struct ethtool_cmd *);
 int qlcnic_83xx_set_settings(struct qlcnic_adapter *, struct ethtool_cmd *);
 void qlcnic_83xx_get_pauseparam(struct qlcnic_adapter *,
 				struct ethtool_pauseparam *);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index 6005b06..f67652d 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -252,6 +252,18 @@ static int
 qlcnic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
+
+	if (qlcnic_82xx_check(adapter))
+		return qlcnic_82xx_get_settings(adapter, ecmd);
+	else if (qlcnic_83xx_check(adapter))
+		return qlcnic_83xx_get_settings(adapter, ecmd);
+
+	return -EIO;
+}
+
+int qlcnic_82xx_get_settings(struct qlcnic_adapter *adapter,
+			     struct ethtool_cmd *ecmd)
+{
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	u32 speed, reg;
 	int check_sfp_module = 0;
@@ -277,10 +289,7 @@ qlcnic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 
 	} else if (adapter->ahw->port_type == QLCNIC_XGBE) {
 		u32 val = 0;
-		if (qlcnic_83xx_check(adapter))
-			qlcnic_83xx_get_settings(adapter);
-		else
-			val = QLCRD32(adapter, QLCNIC_PORT_MODE_ADDR);
+		val = QLCRD32(adapter, QLCNIC_PORT_MODE_ADDR);
 
 		if (val == QLCNIC_PORT_MODE_802_3_AP) {
 			ecmd->supported = SUPPORTED_1000baseT_Full;
@@ -290,16 +299,13 @@ qlcnic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 			ecmd->advertising = ADVERTISED_10000baseT_Full;
 		}
 
-		if (netif_running(dev) && adapter->ahw->has_link_events) {
-			if (qlcnic_82xx_check(adapter)) {
-				reg = QLCRD32(adapter,
-					      P3P_LINK_SPEED_REG(pcifn));
-				speed = P3P_LINK_SPEED_VAL(pcifn, reg);
-				ahw->link_speed = speed * P3P_LINK_SPEED_MHZ;
-			}
-			ethtool_cmd_speed_set(ecmd, adapter->ahw->link_speed);
-			ecmd->autoneg = adapter->ahw->link_autoneg;
-			ecmd->duplex = adapter->ahw->link_duplex;
+		if (netif_running(adapter->netdev) && ahw->has_link_events) {
+			reg = QLCRD32(adapter, P3P_LINK_SPEED_REG(pcifn));
+			speed = P3P_LINK_SPEED_VAL(pcifn, reg);
+			ahw->link_speed = speed * P3P_LINK_SPEED_MHZ;
+			ethtool_cmd_speed_set(ecmd, ahw->link_speed);
+			ecmd->autoneg = ahw->link_autoneg;
+			ecmd->duplex = ahw->link_duplex;
 			goto skip;
 		}
 
@@ -341,8 +347,8 @@ skip:
 	case QLCNIC_BRDTYPE_P3P_10G_SFP_QT:
 		ecmd->advertising |= ADVERTISED_TP;
 		ecmd->supported |= SUPPORTED_TP;
-		check_sfp_module = netif_running(dev) &&
-				   adapter->ahw->has_link_events;
+		check_sfp_module = netif_running(adapter->netdev) &&
+				   ahw->has_link_events;
 	case QLCNIC_BRDTYPE_P3P_10G_XFP:
 		ecmd->supported |= SUPPORTED_FIBRE;
 		ecmd->advertising |= ADVERTISED_FIBRE;
@@ -356,8 +362,8 @@ skip:
 			ecmd->advertising |=
 				(ADVERTISED_FIBRE | ADVERTISED_TP);
 			ecmd->port = PORT_FIBRE;
-			check_sfp_module = netif_running(dev) &&
-					   adapter->ahw->has_link_events;
+			check_sfp_module = netif_running(adapter->netdev) &&
+					   ahw->has_link_events;
 		} else {
 			ecmd->autoneg = AUTONEG_ENABLE;
 			ecmd->supported |= (SUPPORTED_TP | SUPPORTED_Autoneg);
@@ -366,13 +372,6 @@ skip:
 			ecmd->port = PORT_TP;
 		}
 		break;
-	case QLCNIC_BRDTYPE_83XX_10G:
-		ecmd->autoneg = AUTONEG_DISABLE;
-		ecmd->supported |= (SUPPORTED_FIBRE | SUPPORTED_TP);
-		ecmd->advertising |= (ADVERTISED_FIBRE | ADVERTISED_TP);
-		ecmd->port = PORT_FIBRE;
-		check_sfp_module = netif_running(dev) && ahw->has_link_events;
-		break;
 	default:
 		dev_err(&adapter->pdev->dev, "Unsupported board model %d\n",
 			adapter->ahw->board_type);
-- 
1.5.6
