From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: qlogic: netxen: use new api ethtool_{get|set}_link_ksettings
Date: Thu, 16 Feb 2017 23:28:01 +0100
Message-ID: <1487284081-27626-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: manish.chopra@cavium.com, rahul.verma@cavium.com,
        Dept-GELinuxNICDev@cavium.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:34852 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933547AbdBPW2K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 17:28:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 .../ethernet/qlogic/netxen/netxen_nic_ethtool.c    |  123 ++++++++++---------
 1 files changed, 65 insertions(+), 58 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
index f903446..3157f97 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
@@ -96,69 +96,70 @@ static int netxen_nic_get_eeprom_len(struct net_device *dev)
 }
 
 static int
-netxen_nic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
+netxen_nic_get_link_ksettings(struct net_device *dev,
+			      struct ethtool_link_ksettings *cmd)
 {
 	struct netxen_adapter *adapter = netdev_priv(dev);
 	int check_sfp_module = 0;
+	u32 supported, advertising;
 
 	/* read which mode */
 	if (adapter->ahw.port_type == NETXEN_NIC_GBE) {
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
 
-		ecmd->port = PORT_TP;
+		cmd->base.port = PORT_TP;
 
-		ethtool_cmd_speed_set(ecmd, adapter->link_speed);
-		ecmd->duplex = adapter->link_duplex;
-		ecmd->autoneg = adapter->link_autoneg;
+		cmd->base.speed = adapter->link_speed;
+		cmd->base.duplex = adapter->link_duplex;
+		cmd->base.autoneg = adapter->link_autoneg;
 
 	} else if (adapter->ahw.port_type == NETXEN_NIC_XGBE) {
 		u32 val;
 
 		val = NXRD32(adapter, NETXEN_PORT_MODE_ADDR);
 		if (val == NETXEN_PORT_MODE_802_3_AP) {
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
 
 		if (netif_running(dev) && adapter->has_link_events) {
-			ethtool_cmd_speed_set(ecmd, adapter->link_speed);
-			ecmd->autoneg = adapter->link_autoneg;
-			ecmd->duplex = adapter->link_duplex;
+			cmd->base.speed = adapter->link_speed;
+			cmd->base.autoneg = adapter->link_autoneg;
+			cmd->base.duplex = adapter->link_duplex;
 			goto skip;
 		}
 
-		ecmd->port = PORT_TP;
+		cmd->base.port = PORT_TP;
 
 		if (NX_IS_REVISION_P3(adapter->ahw.revision_id)) {
 			u16 pcifn = adapter->ahw.pci_func;
 
 			val = NXRD32(adapter, P3_LINK_SPEED_REG(pcifn));
-			ethtool_cmd_speed_set(ecmd, P3_LINK_SPEED_MHZ *
-					      P3_LINK_SPEED_VAL(pcifn, val));
+			cmd->base.speed = P3_LINK_SPEED_MHZ *
+				P3_LINK_SPEED_VAL(pcifn, val);
 		} else
-			ethtool_cmd_speed_set(ecmd, SPEED_10000);
+			cmd->base.speed = SPEED_10000;
 
-		ecmd->duplex = DUPLEX_FULL;
-		ecmd->autoneg = AUTONEG_DISABLE;
+		cmd->base.duplex = DUPLEX_FULL;
+		cmd->base.autoneg = AUTONEG_DISABLE;
 	} else
 		return -EIO;
 
 skip:
-	ecmd->phy_address = adapter->physical_port;
-	ecmd->transceiver = XCVR_EXTERNAL;
+	cmd->base.phy_address = adapter->physical_port;
 
 	switch (adapter->ahw.board_type) {
 	case NETXEN_BRDTYPE_P2_SB35_4G:
@@ -167,16 +168,16 @@ static int netxen_nic_get_eeprom_len(struct net_device *dev)
 	case NETXEN_BRDTYPE_P3_4_GB:
 	case NETXEN_BRDTYPE_P3_4_GB_MM:
 
-		ecmd->supported |= SUPPORTED_Autoneg;
-		ecmd->advertising |= ADVERTISED_Autoneg;
+		supported |= SUPPORTED_Autoneg;
+		advertising |= ADVERTISED_Autoneg;
 	case NETXEN_BRDTYPE_P2_SB31_10G_CX4:
 	case NETXEN_BRDTYPE_P3_10G_CX4:
 	case NETXEN_BRDTYPE_P3_10G_CX4_LP:
 	case NETXEN_BRDTYPE_P3_10000_BASE_T:
-		ecmd->supported |= SUPPORTED_TP;
-		ecmd->advertising |= ADVERTISED_TP;
-		ecmd->port = PORT_TP;
-		ecmd->autoneg = (adapter->ahw.board_type ==
+		supported |= SUPPORTED_TP;
+		advertising |= ADVERTISED_TP;
+		cmd->base.port = PORT_TP;
+		cmd->base.autoneg = (adapter->ahw.board_type ==
 				 NETXEN_BRDTYPE_P2_SB31_10G_CX4) ?
 		    (AUTONEG_DISABLE) : (adapter->link_autoneg);
 		break;
@@ -185,39 +186,39 @@ static int netxen_nic_get_eeprom_len(struct net_device *dev)
 	case NETXEN_BRDTYPE_P3_IMEZ:
 	case NETXEN_BRDTYPE_P3_XG_LOM:
 	case NETXEN_BRDTYPE_P3_HMEZ:
-		ecmd->supported |= SUPPORTED_MII;
-		ecmd->advertising |= ADVERTISED_MII;
-		ecmd->port = PORT_MII;
-		ecmd->autoneg = AUTONEG_DISABLE;
+		supported |= SUPPORTED_MII;
+		advertising |= ADVERTISED_MII;
+		cmd->base.port = PORT_MII;
+		cmd->base.autoneg = AUTONEG_DISABLE;
 		break;
 	case NETXEN_BRDTYPE_P3_10G_SFP_PLUS:
 	case NETXEN_BRDTYPE_P3_10G_SFP_CT:
 	case NETXEN_BRDTYPE_P3_10G_SFP_QT:
-		ecmd->advertising |= ADVERTISED_TP;
-		ecmd->supported |= SUPPORTED_TP;
+		advertising |= ADVERTISED_TP;
+		supported |= SUPPORTED_TP;
 		check_sfp_module = netif_running(dev) &&
 			adapter->has_link_events;
 	case NETXEN_BRDTYPE_P2_SB31_10G:
 	case NETXEN_BRDTYPE_P3_10G_XFP:
-		ecmd->supported |= SUPPORTED_FIBRE;
-		ecmd->advertising |= ADVERTISED_FIBRE;
-		ecmd->port = PORT_FIBRE;
-		ecmd->autoneg = AUTONEG_DISABLE;
+		supported |= SUPPORTED_FIBRE;
+		advertising |= ADVERTISED_FIBRE;
+		cmd->base.port = PORT_FIBRE;
+		cmd->base.autoneg = AUTONEG_DISABLE;
 		break;
 	case NETXEN_BRDTYPE_P3_10G_TP:
 		if (adapter->ahw.port_type == NETXEN_NIC_XGBE) {
-			ecmd->autoneg = AUTONEG_DISABLE;
-			ecmd->supported |= (SUPPORTED_FIBRE | SUPPORTED_TP);
-			ecmd->advertising |=
+			cmd->base.autoneg = AUTONEG_DISABLE;
+			supported |= (SUPPORTED_FIBRE | SUPPORTED_TP);
+			advertising |=
 				(ADVERTISED_FIBRE | ADVERTISED_TP);
-			ecmd->port = PORT_FIBRE;
+			cmd->base.port = PORT_FIBRE;
 			check_sfp_module = netif_running(dev) &&
 				adapter->has_link_events;
 		} else {
-			ecmd->supported |= (SUPPORTED_TP | SUPPORTED_Autoneg);
-			ecmd->advertising |=
+			supported |= (SUPPORTED_TP | SUPPORTED_Autoneg);
+			advertising |=
 				(ADVERTISED_TP | ADVERTISED_Autoneg);
-			ecmd->port = PORT_TP;
+			cmd->base.port = PORT_TP;
 		}
 		break;
 	default:
@@ -232,31 +233,37 @@ static int netxen_nic_get_eeprom_len(struct net_device *dev)
 		case LINKEVENT_MODULE_OPTICAL_SRLR:
 		case LINKEVENT_MODULE_OPTICAL_LRM:
 		case LINKEVENT_MODULE_OPTICAL_SFP_1G:
-			ecmd->port = PORT_FIBRE;
+			cmd->base.port = PORT_FIBRE;
 			break;
 		case LINKEVENT_MODULE_TWINAX_UNSUPPORTED_CABLE:
 		case LINKEVENT_MODULE_TWINAX_UNSUPPORTED_CABLELEN:
 		case LINKEVENT_MODULE_TWINAX:
-			ecmd->port = PORT_TP;
+			cmd->base.port = PORT_TP;
 			break;
 		default:
-			ecmd->port = -1;
+			cmd->base.port = -1;
 		}
 	}
 
 	if (!netif_running(dev) || !adapter->ahw.linkup) {
-		ecmd->duplex = DUPLEX_UNKNOWN;
-		ethtool_cmd_speed_set(ecmd, SPEED_UNKNOWN);
+		cmd->base.duplex = DUPLEX_UNKNOWN;
+		cmd->base.speed = SPEED_UNKNOWN;
 	}
 
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
+						supported);
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.advertising,
+						advertising);
+
 	return 0;
 }
 
 static int
-netxen_nic_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
+netxen_nic_set_link_ksettings(struct net_device *dev,
+			      const struct ethtool_link_ksettings *cmd)
 {
 	struct netxen_adapter *adapter = netdev_priv(dev);
-	u32 speed = ethtool_cmd_speed(ecmd);
+	u32 speed = cmd->base.speed;
 	int ret;
 
 	if (adapter->ahw.port_type != NETXEN_NIC_GBE)
@@ -265,16 +272,16 @@ static int netxen_nic_get_eeprom_len(struct net_device *dev)
 	if (!(adapter->capabilities & NX_FW_CAPABILITY_GBE_LINK_CFG))
 		return -EOPNOTSUPP;
 
-	ret = nx_fw_cmd_set_gbe_port(adapter, speed, ecmd->duplex,
-				     ecmd->autoneg);
+	ret = nx_fw_cmd_set_gbe_port(adapter, speed, cmd->base.duplex,
+				     cmd->base.autoneg);
 	if (ret == NX_RCODE_NOT_SUPPORTED)
 		return -EOPNOTSUPP;
 	else if (ret)
 		return -EIO;
 
 	adapter->link_speed = speed;
-	adapter->link_duplex = ecmd->duplex;
-	adapter->link_autoneg = ecmd->autoneg;
+	adapter->link_duplex = cmd->base.duplex;
+	adapter->link_autoneg = cmd->base.autoneg;
 
 	if (!netif_running(dev))
 		return 0;
@@ -931,8 +938,6 @@ static int netxen_get_intr_coalesce(struct net_device *netdev,
 }
 
 const struct ethtool_ops netxen_nic_ethtool_ops = {
-	.get_settings = netxen_nic_get_settings,
-	.set_settings = netxen_nic_set_settings,
 	.get_drvinfo = netxen_nic_get_drvinfo,
 	.get_regs_len = netxen_nic_get_regs_len,
 	.get_regs = netxen_nic_get_regs,
@@ -954,4 +959,6 @@ static int netxen_get_intr_coalesce(struct net_device *netdev,
 	.get_dump_flag = netxen_get_dump_flag,
 	.get_dump_data = netxen_get_dump_data,
 	.set_dump = netxen_set_dump,
+	.get_link_ksettings = netxen_nic_get_link_ksettings,
+	.set_link_ksettings = netxen_nic_set_link_ksettings,
 };
-- 
1.7.4.4
