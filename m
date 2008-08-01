From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 1/7] netxen: fix link status, link speed
Date: Fri,  1 Aug 2008 03:14:55 -0700
Message-ID: <1217585701-13958-2-git-send-email-dhananjay@netxen.com>
Cc: jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.209.101.202] ([64.209.101.202]:42826 "EHLO unm84.unminc.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753156AbYHAKPG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Aug 2008 06:15:06 -0400
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For NX3031, the phy is managed by firmware, so driver should avoid
setting any phy registers.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_ethtool.c  |   33 +++++++++++++++++++++--------
 drivers/net/netxen/netxen_nic_hdr.h      |    7 ++++++
 drivers/net/netxen/netxen_nic_hw.c       |   17 +++++++++++---
 drivers/net/netxen/netxen_nic_main.c     |   19 +++++++----------
 drivers/net/netxen/netxen_nic_niu.c      |   12 ++++++++++
 drivers/net/netxen/netxen_nic_phan_reg.h |    4 +-
 6 files changed, 66 insertions(+), 26 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index 48ee06b..f9b933e 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -140,18 +140,33 @@ netxen_nic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 		if (netif_running(dev)) {
 			ecmd->speed = adapter->link_speed;
 			ecmd->duplex = adapter->link_duplex;
-		} else
-			return -EIO;	/* link absent */
+			ecmd->autoneg = adapter->link_autoneg;
+		}
+
 	} else if (adapter->ahw.board_type == NETXEN_NIC_XGBE) {
-		ecmd->supported = (SUPPORTED_TP |
-				   SUPPORTED_1000baseT_Full |
-				   SUPPORTED_10000baseT_Full);
-		ecmd->advertising = (ADVERTISED_TP |
-				     ADVERTISED_1000baseT_Full |
-				     ADVERTISED_10000baseT_Full);
+		u32 val;
+
+		adapter->hw_read_wx(adapter, NETXEN_PORT_MODE_ADDR, &val, 4);
+		if (val == NETXEN_PORT_MODE_802_3_AP) {
+			ecmd->supported = SUPPORTED_1000baseT_Full;
+			ecmd->advertising = ADVERTISED_1000baseT_Full;
+		} else {
+			ecmd->supported = SUPPORTED_10000baseT_Full;
+			ecmd->advertising = ADVERTISED_10000baseT_Full;
+		}
+
 		ecmd->port = PORT_TP;
 
-		ecmd->speed = SPEED_10000;
+		if (NX_IS_REVISION_P3(adapter->ahw.revision_id)) {
+			u16 pcifn = adapter->ahw.pci_func;
+
+			adapter->hw_read_wx(adapter,
+				P3_LINK_SPEED_REG(pcifn), &val, 4);
+			ecmd->speed = P3_LINK_SPEED_MHZ *
+					P3_LINK_SPEED_VAL(pcifn, val);
+		} else
+			ecmd->speed = SPEED_10000;
+
 		ecmd->duplex = DUPLEX_FULL;
 		ecmd->autoneg = AUTONEG_DISABLE;
 	} else
diff --git a/drivers/net/netxen/netxen_nic_hdr.h b/drivers/net/netxen/netxen_nic_hdr.h
index 3ce13e4..ccf6d70 100644
--- a/drivers/net/netxen/netxen_nic_hdr.h
+++ b/drivers/net/netxen/netxen_nic_hdr.h
@@ -724,6 +724,13 @@ enum {
 #define XG_LINK_STATE_P3(pcifn,val) \
 	(((val) >> ((pcifn) * 4)) & XG_LINK_STATE_P3_MASK)
 
+#define P3_LINK_SPEED_MHZ	100
+#define P3_LINK_SPEED_MASK	0xff
+#define P3_LINK_SPEED_REG(pcifn)	\
+	(CRB_PF_LINK_SPEED_1 + (((pcifn) / 4) * 4))
+#define P3_LINK_SPEED_VAL(pcifn, reg)	\
+	(((reg) >> (8 * ((pcifn) & 0x3))) & P3_LINK_SPEED_MASK)
+
 #define NETXEN_CAM_RAM_BASE	(NETXEN_CRB_CAM + 0x02000)
 #define NETXEN_CAM_RAM(reg)	(NETXEN_CAM_RAM_BASE + (reg))
 #define NETXEN_FW_VERSION_MAJOR (NETXEN_CAM_RAM(0x150))
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 96a3bc6..008a6e7 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -2074,12 +2074,22 @@ void netxen_nic_set_link_parameters(struct netxen_adapter *adapter)
 	__u32 status;
 	__u32 autoneg;
 	__u32 mode;
+	__u32 port_mode;
 
 	netxen_nic_read_w0(adapter, NETXEN_NIU_MODE, &mode);
 	if (netxen_get_niu_enable_ge(mode)) {	/* Gb 10/100/1000 Mbps mode */
+
+		adapter->hw_read_wx(adapter,
+				NETXEN_PORT_MODE_ADDR, &port_mode, 4);
+		if (port_mode == NETXEN_PORT_MODE_802_3_AP) {
+			adapter->link_speed   = SPEED_1000;
+			adapter->link_duplex  = DUPLEX_FULL;
+			adapter->link_autoneg = AUTONEG_DISABLE;
+			return;
+		}
+
 		if (adapter->phy_read
-		    && adapter->
-		    phy_read(adapter,
+		    && adapter->phy_read(adapter,
 			     NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
 			     &status) == 0) {
 			if (netxen_get_phy_link(status)) {
@@ -2109,8 +2119,7 @@ void netxen_nic_set_link_parameters(struct netxen_adapter *adapter)
 					break;
 				}
 				if (adapter->phy_read
-				    && adapter->
-				    phy_read(adapter,
+				    && adapter->phy_read(adapter,
 					     NETXEN_NIU_GB_MII_MGMT_ADDR_AUTONEG,
 					     &autoneg) != 0)
 					adapter->link_autoneg = autoneg;
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 91d209a..7b8688e 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -1410,20 +1410,17 @@ static void netxen_nic_handle_phy_intr(struct netxen_adapter *adapter)
 
 	port = adapter->physical_port;
 
-	if (adapter->ahw.board_type == NETXEN_NIC_GBE) {
-		val = adapter->pci_read_normalize(adapter, CRB_XG_STATE);
-		linkup = (val >> port) & 1;
+	if (NX_IS_REVISION_P3(adapter->ahw.revision_id)) {
+		val = adapter->pci_read_normalize(adapter, CRB_XG_STATE_P3);
+		val = XG_LINK_STATE_P3(adapter->ahw.pci_func, val);
+		linkup = (val == XG_LINK_UP_P3);
 	} else {
-		if (adapter->fw_major < 4) {
-			val = adapter->pci_read_normalize(adapter,
-					CRB_XG_STATE);
+		val = adapter->pci_read_normalize(adapter, CRB_XG_STATE);
+		if (adapter->ahw.board_type == NETXEN_NIC_GBE)
+			linkup = (val >> port) & 1;
+		else {
 			val = (val >> port*8) & 0xff;
 			linkup = (val == XG_LINK_UP);
-		} else {
-			val = adapter->pci_read_normalize(adapter,
-				CRB_XG_STATE_P3);
-			val = XG_LINK_STATE_P3(adapter->ahw.pci_func, val);
-			linkup = (val == XG_LINK_UP_P3);
 		}
 	}
 
diff --git a/drivers/net/netxen/netxen_nic_niu.c b/drivers/net/netxen/netxen_nic_niu.c
index 4cb8f4a..c9493e2 100644
--- a/drivers/net/netxen/netxen_nic_niu.c
+++ b/drivers/net/netxen/netxen_nic_niu.c
@@ -610,6 +610,9 @@ int netxen_niu_macaddr_set(struct netxen_adapter *adapter,
 	int i;
 	DECLARE_MAC_BUF(mac);
 
+	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
+		return 0;
+
 	for (i = 0; i < 10; i++) {
 		temp[0] = temp[1] = 0;
 		memcpy(temp + 2, addr, 2);
@@ -727,6 +730,9 @@ int netxen_niu_disable_gbe_port(struct netxen_adapter *adapter)
 	__u32 mac_cfg0;
 	u32 port = adapter->physical_port;
 
+	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
+		return 0;
+
 	if (port > NETXEN_NIU_MAX_GBE_PORTS)
 		return -EINVAL;
 	mac_cfg0 = 0;
@@ -743,6 +749,9 @@ int netxen_niu_disable_xg_port(struct netxen_adapter *adapter)
 	__u32 mac_cfg;
 	u32 port = adapter->physical_port;
 
+	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
+		return 0;
+
 	if (port > NETXEN_NIU_MAX_XG_PORTS)
 		return -EINVAL;
 
@@ -819,6 +828,9 @@ int netxen_niu_xg_macaddr_set(struct netxen_adapter *adapter,
 	u8 temp[4];
 	u32 val;
 
+	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
+		return 0;
+
 	if ((phy < 0) || (phy > NETXEN_NIU_MAX_XG_PORTS))
 		return -EIO;
 
diff --git a/drivers/net/netxen/netxen_nic_phan_reg.h b/drivers/net/netxen/netxen_nic_phan_reg.h
index 3bfa51b..83e5ee5 100644
--- a/drivers/net/netxen/netxen_nic_phan_reg.h
+++ b/drivers/net/netxen/netxen_nic_phan_reg.h
@@ -95,8 +95,8 @@
 #define CRB_HOST_STS_PROD           NETXEN_NIC_REG(0xdc)
 #define CRB_HOST_STS_CONS           NETXEN_NIC_REG(0xe0)
 #define CRB_PEG_CMD_PROD            NETXEN_NIC_REG(0xe4)
-#define CRB_PEG_CMD_CONS            NETXEN_NIC_REG(0xe8)
-#define CRB_HOST_BUFFER_PROD        NETXEN_NIC_REG(0xec)
+#define CRB_PF_LINK_SPEED_1         NETXEN_NIC_REG(0xe8)
+#define CRB_PF_LINK_SPEED_2         NETXEN_NIC_REG(0xec)
 #define CRB_HOST_BUFFER_CONS        NETXEN_NIC_REG(0xf0)
 #define CRB_JUMBO_BUFFER_PROD       NETXEN_NIC_REG(0xf4)
 #define CRB_JUMBO_BUFFER_CONS       NETXEN_NIC_REG(0xf8)
-- 
1.5.4.3

