From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 04/13] netxen: fix link speed reporting for some boards
Date: Mon, 12 Jan 2009 11:23:02 -0800
Message-ID: <1231788191-23794-5-git-send-email-dhananjay@netxen.com>
References: <1231788191-23794-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:36353 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754799AbZALT3w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jan 2009 14:29:52 -0500
In-Reply-To: <1231788191-23794-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o Read negotiated link speed when link state changes.
o Fix link speed reporting for hybrid nic boards, which have both 1Gbps and
  10Gbps ports.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h         |    3 ++-
 drivers/net/netxen/netxen_nic_ethtool.c |   31 +++++++++++++++++++++++--------
 drivers/net/netxen/netxen_nic_hw.c      |   28 ++++++++++++++++++++--------
 drivers/net/netxen/netxen_nic_main.c    |   14 +++++++++++++-
 4 files changed, 58 insertions(+), 18 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 8da6fa2..5110348 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -499,7 +499,8 @@ typedef enum {
 	NETXEN_BRDTYPE_P3_10G_SFP_CT = 0x002a,
 	NETXEN_BRDTYPE_P3_10G_SFP_QT = 0x002b,
 	NETXEN_BRDTYPE_P3_10G_CX4 = 0x0031,
-	NETXEN_BRDTYPE_P3_10G_XFP = 0x0032
+	NETXEN_BRDTYPE_P3_10G_XFP = 0x0032,
+	NETXEN_BRDTYPE_P3_10G_TROOPER = 0x0080
 
 } netxen_brdtype_t;
 
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index e45ce29..48b20f6 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -136,11 +136,9 @@ netxen_nic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 
 		ecmd->port = PORT_TP;
 
-		if (netif_running(dev)) {
-			ecmd->speed = adapter->link_speed;
-			ecmd->duplex = adapter->link_duplex;
-			ecmd->autoneg = adapter->link_autoneg;
-		}
+		ecmd->speed = adapter->link_speed;
+		ecmd->duplex = adapter->link_duplex;
+		ecmd->autoneg = adapter->link_autoneg;
 
 	} else if (adapter->ahw.board_type == NETXEN_NIC_XGBE) {
 		u32 val;
@@ -171,7 +169,7 @@ netxen_nic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 	} else
 		return -EIO;
 
-	ecmd->phy_address = adapter->portnum;
+	ecmd->phy_address = adapter->physical_port;
 	ecmd->transceiver = XCVR_EXTERNAL;
 
 	switch ((netxen_brdtype_t) boardinfo->board_type) {
@@ -180,13 +178,13 @@ netxen_nic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 	case NETXEN_BRDTYPE_P3_REF_QG:
 	case NETXEN_BRDTYPE_P3_4_GB:
 	case NETXEN_BRDTYPE_P3_4_GB_MM:
-	case NETXEN_BRDTYPE_P3_10000_BASE_T:
 
 		ecmd->supported |= SUPPORTED_Autoneg;
 		ecmd->advertising |= ADVERTISED_Autoneg;
 	case NETXEN_BRDTYPE_P2_SB31_10G_CX4:
 	case NETXEN_BRDTYPE_P3_10G_CX4:
 	case NETXEN_BRDTYPE_P3_10G_CX4_LP:
+	case NETXEN_BRDTYPE_P3_10000_BASE_T:
 		ecmd->supported |= SUPPORTED_TP;
 		ecmd->advertising |= ADVERTISED_TP;
 		ecmd->port = PORT_TP;
@@ -204,16 +202,33 @@ netxen_nic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 		ecmd->port = PORT_FIBRE;
 		ecmd->autoneg = AUTONEG_DISABLE;
 		break;
-	case NETXEN_BRDTYPE_P2_SB31_10G:
 	case NETXEN_BRDTYPE_P3_10G_SFP_PLUS:
 	case NETXEN_BRDTYPE_P3_10G_SFP_CT:
 	case NETXEN_BRDTYPE_P3_10G_SFP_QT:
+		ecmd->advertising |= ADVERTISED_TP;
+		ecmd->supported |= SUPPORTED_TP;
+	case NETXEN_BRDTYPE_P2_SB31_10G:
 	case NETXEN_BRDTYPE_P3_10G_XFP:
 		ecmd->supported |= SUPPORTED_FIBRE;
 		ecmd->advertising |= ADVERTISED_FIBRE;
 		ecmd->port = PORT_FIBRE;
 		ecmd->autoneg = AUTONEG_DISABLE;
 		break;
+	case NETXEN_BRDTYPE_P3_10G_TROOPER:
+		if (adapter->ahw.board_type == NETXEN_NIC_XGBE) {
+			ecmd->autoneg = AUTONEG_DISABLE;
+			ecmd->supported |= (SUPPORTED_FIBRE | SUPPORTED_TP);
+			ecmd->advertising |=
+				(ADVERTISED_FIBRE | ADVERTISED_TP);
+			ecmd->port = PORT_FIBRE;
+		} else {
+			ecmd->autoneg = AUTONEG_ENABLE;
+			ecmd->supported |= (SUPPORTED_TP |SUPPORTED_Autoneg);
+			ecmd->advertising |=
+				(ADVERTISED_TP | ADVERTISED_Autoneg);
+			ecmd->port = PORT_TP;
+		}
+		break;
 	default:
 		printk(KERN_ERR "netxen-nic: Unsupported board model %d\n",
 		       (netxen_brdtype_t) boardinfo->board_type);
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 2eec8aa..e2bb5cf 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -1960,7 +1960,13 @@ int netxen_nic_get_board_info(struct netxen_adapter *adapter)
 		rv = -1;
 	}
 
-	DPRINTK(INFO, "Discovered board type:0x%x  ", boardinfo->board_type);
+	if (boardinfo->board_type == NETXEN_BRDTYPE_P3_4_GB_MM) {
+		u32 gpio = netxen_nic_reg_read(adapter,
+				NETXEN_ROMUSB_GLB_PAD_GPIO_I);
+		if ((gpio & 0x8000) == 0)
+			boardinfo->board_type = NETXEN_BRDTYPE_P3_10G_TROOPER;
+	}
+
 	switch ((netxen_brdtype_t) boardinfo->board_type) {
 	case NETXEN_BRDTYPE_P2_SB35_4G:
 		adapter->ahw.board_type = NETXEN_NIC_GBE;
@@ -1979,7 +1985,6 @@ int netxen_nic_get_board_info(struct netxen_adapter *adapter)
 	case NETXEN_BRDTYPE_P3_10G_SFP_QT:
 	case NETXEN_BRDTYPE_P3_10G_XFP:
 	case NETXEN_BRDTYPE_P3_10000_BASE_T:
-
 		adapter->ahw.board_type = NETXEN_NIC_XGBE;
 		break;
 	case NETXEN_BRDTYPE_P1_BD:
@@ -1989,9 +1994,12 @@ int netxen_nic_get_board_info(struct netxen_adapter *adapter)
 	case NETXEN_BRDTYPE_P3_REF_QG:
 	case NETXEN_BRDTYPE_P3_4_GB:
 	case NETXEN_BRDTYPE_P3_4_GB_MM:
-
 		adapter->ahw.board_type = NETXEN_NIC_GBE;
 		break;
+	case NETXEN_BRDTYPE_P3_10G_TROOPER:
+		adapter->ahw.board_type = (adapter->portnum < 2) ?
+			NETXEN_NIC_XGBE : NETXEN_NIC_GBE;
+		break;
 	default:
 		printk("%s: Unknown(%x)\n", netxen_nic_driver_name,
 		       boardinfo->board_type);
@@ -2036,12 +2044,16 @@ void netxen_nic_set_link_parameters(struct netxen_adapter *adapter)
 {
 	__u32 status;
 	__u32 autoneg;
-	__u32 mode;
 	__u32 port_mode;
 
-	netxen_nic_read_w0(adapter, NETXEN_NIU_MODE, &mode);
-	if (netxen_get_niu_enable_ge(mode)) {	/* Gb 10/100/1000 Mbps mode */
+	if (!netif_carrier_ok(adapter->netdev)) {
+		adapter->link_speed   = 0;
+		adapter->link_duplex  = -1;
+		adapter->link_autoneg = AUTONEG_ENABLE;
+		return;
+	}
 
+	if (adapter->ahw.board_type == NETXEN_NIC_GBE) {
 		adapter->hw_read_wx(adapter,
 				NETXEN_PORT_MODE_ADDR, &port_mode, 4);
 		if (port_mode == NETXEN_PORT_MODE_802_3_AP) {
@@ -2067,7 +2079,7 @@ void netxen_nic_set_link_parameters(struct netxen_adapter *adapter)
 					adapter->link_speed = SPEED_1000;
 					break;
 				default:
-					adapter->link_speed = -1;
+					adapter->link_speed = 0;
 					break;
 				}
 				switch (netxen_get_phy_duplex(status)) {
@@ -2090,7 +2102,7 @@ void netxen_nic_set_link_parameters(struct netxen_adapter *adapter)
 				goto link_down;
 		} else {
 		      link_down:
-			adapter->link_speed = -1;
+			adapter->link_speed = 0;
 			adapter->link_duplex = -1;
 		}
 	}
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index eaef94b..7da2b08 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -243,7 +243,7 @@ static void netxen_check_options(struct netxen_adapter *adapter)
 	case NETXEN_BRDTYPE_P3_4_GB:
 	case NETXEN_BRDTYPE_P3_4_GB_MM:
 		adapter->msix_supported = !!use_msi_x;
-		adapter->max_rx_desc_count = MAX_RCV_DESCRIPTORS_10G;
+		adapter->max_rx_desc_count = MAX_RCV_DESCRIPTORS_1G;
 		break;
 
 	case NETXEN_BRDTYPE_P2_SB35_4G:
@@ -252,6 +252,14 @@ static void netxen_check_options(struct netxen_adapter *adapter)
 		adapter->max_rx_desc_count = MAX_RCV_DESCRIPTORS_1G;
 		break;
 
+	case NETXEN_BRDTYPE_P3_10G_TROOPER:
+		adapter->msix_supported = !!use_msi_x;
+		if (adapter->ahw.board_type == NETXEN_NIC_XGBE)
+			adapter->max_rx_desc_count = MAX_RCV_DESCRIPTORS_10G;
+		else
+			adapter->max_rx_desc_count = MAX_RCV_DESCRIPTORS_1G;
+		break;
+
 	default:
 		adapter->msix_supported = 0;
 		adapter->max_rx_desc_count = MAX_RCV_DESCRIPTORS_1G;
@@ -1396,6 +1404,8 @@ static void netxen_nic_handle_phy_intr(struct netxen_adapter *adapter)
 			netif_carrier_off(netdev);
 			netif_stop_queue(netdev);
 		}
+
+		netxen_nic_set_link_parameters(adapter);
 	} else if (!adapter->ahw.linkup && linkup) {
 		printk(KERN_INFO "%s: %s NIC Link is up\n",
 		       netxen_nic_driver_name, netdev->name);
@@ -1404,6 +1414,8 @@ static void netxen_nic_handle_phy_intr(struct netxen_adapter *adapter)
 			netif_carrier_on(netdev);
 			netif_wake_queue(netdev);
 		}
+
+		netxen_nic_set_link_parameters(adapter);
 	}
 }
 
-- 
1.6.0.2

