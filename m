From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCHv2 NEXT 1/1] netxen: support for GbE port settings
Date: Mon, 14 Mar 2011 23:52:47 -0700
Message-ID: <1300171967-16576-2-git-send-email-amit.salecha@qlogic.com>
References: <1300171967-16576-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:46200 "EHLO unm84.unminc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753944Ab1COG6D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Mar 2011 02:58:03 -0400
In-Reply-To: <1300171967-16576-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

o Enable setting speed and auto negotiation parameters for GbE ports.
o Hardware do not support half duplex setting currently.

David Miller:
	Amit please update your patch to silently reject link setting
	attempts that are unsupported by the device.

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/netxen/netxen_nic.h         |    6 ++-
 drivers/net/netxen/netxen_nic_ctx.c     |   15 +++++++
 drivers/net/netxen/netxen_nic_ethtool.c |   62 ++++++++-----------------------
 3 files changed, 36 insertions(+), 47 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index a113805..d7299f1 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -739,7 +739,8 @@ struct netxen_recv_context {
 #define NX_CDRP_CMD_READ_PEXQ_PARAMETERS	0x0000001c
 #define NX_CDRP_CMD_GET_LIC_CAPABILITIES	0x0000001d
 #define NX_CDRP_CMD_READ_MAX_LRO_PER_BOARD	0x0000001e
-#define NX_CDRP_CMD_MAX				0x0000001f
+#define NX_CDRP_CMD_CONFIG_GBE_PORT		0x0000001f
+#define NX_CDRP_CMD_MAX				0x00000020
 
 #define NX_RCODE_SUCCESS		0
 #define NX_RCODE_NO_HOST_MEM		1
@@ -1054,6 +1055,7 @@ typedef struct {
 #define NX_FW_CAPABILITY_BDG			(1 << 8)
 #define NX_FW_CAPABILITY_FVLANTX		(1 << 9)
 #define NX_FW_CAPABILITY_HW_LRO			(1 << 10)
+#define NX_FW_CAPABILITY_GBE_LINK_CFG		(1 << 11)
 
 /* module types */
 #define LINKEVENT_MODULE_NOT_PRESENT			1
@@ -1349,6 +1351,8 @@ void netxen_advert_link_change(struct netxen_adapter *adapter, int linkup);
 void netxen_pci_camqm_read_2M(struct netxen_adapter *, u64, u64 *);
 void netxen_pci_camqm_write_2M(struct netxen_adapter *, u64, u64);
 
+int nx_fw_cmd_set_gbe_port(struct netxen_adapter *adapter,
+				u32 speed, u32 duplex, u32 autoneg);
 int nx_fw_cmd_set_mtu(struct netxen_adapter *adapter, int mtu);
 int netxen_nic_change_mtu(struct net_device *netdev, int new_mtu);
 int netxen_config_hw_lro(struct netxen_adapter *adapter, int enable);
diff --git a/drivers/net/netxen/netxen_nic_ctx.c b/drivers/net/netxen/netxen_nic_ctx.c
index f7d06cb..f16966a 100644
--- a/drivers/net/netxen/netxen_nic_ctx.c
+++ b/drivers/net/netxen/netxen_nic_ctx.c
@@ -112,6 +112,21 @@ nx_fw_cmd_set_mtu(struct netxen_adapter *adapter, int mtu)
 	return 0;
 }
 
+int
+nx_fw_cmd_set_gbe_port(struct netxen_adapter *adapter,
+			u32 speed, u32 duplex, u32 autoneg)
+{
+
+	return netxen_issue_cmd(adapter,
+				adapter->ahw.pci_func,
+				NXHAL_VERSION,
+				speed,
+				duplex,
+				autoneg,
+				NX_CDRP_CMD_CONFIG_GBE_PORT);
+
+}
+
 static int
 nx_fw_cmd_create_rx_ctx(struct netxen_adapter *adapter)
 {
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index 587498e..653d308 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -214,7 +214,6 @@ skip:
 			check_sfp_module = netif_running(dev) &&
 				adapter->has_link_events;
 		} else {
-			ecmd->autoneg = AUTONEG_ENABLE;
 			ecmd->supported |= (SUPPORTED_TP |SUPPORTED_Autoneg);
 			ecmd->advertising |=
 				(ADVERTISED_TP | ADVERTISED_Autoneg);
@@ -252,53 +251,24 @@ static int
 netxen_nic_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 {
 	struct netxen_adapter *adapter = netdev_priv(dev);
-	__u32 status;
+	int ret;
 
-	/* read which mode */
-	if (adapter->ahw.port_type == NETXEN_NIC_GBE) {
-		/* autonegotiation */
-		if (adapter->phy_write &&
-		    adapter->phy_write(adapter,
-				       NETXEN_NIU_GB_MII_MGMT_ADDR_AUTONEG,
-				       ecmd->autoneg) != 0)
-			return -EIO;
-		else
-			adapter->link_autoneg = ecmd->autoneg;
+	if (adapter->ahw.port_type != NETXEN_NIC_GBE)
+		return -EOPNOTSUPP;
 
-		if (adapter->phy_read &&
-		    adapter->phy_read(adapter,
-				      NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
-				      &status) != 0)
-			return -EIO;
+	if (!(adapter->capabilities & NX_FW_CAPABILITY_GBE_LINK_CFG))
+		return -EOPNOTSUPP;
 
-		/* speed */
-		switch (ecmd->speed) {
-		case SPEED_10:
-			netxen_set_phy_speed(status, 0);
-			break;
-		case SPEED_100:
-			netxen_set_phy_speed(status, 1);
-			break;
-		case SPEED_1000:
-			netxen_set_phy_speed(status, 2);
-			break;
-		}
-		/* set duplex mode */
-		if (ecmd->duplex == DUPLEX_HALF)
-			netxen_clear_phy_duplex(status);
-		if (ecmd->duplex == DUPLEX_FULL)
-			netxen_set_phy_duplex(status);
-		if (adapter->phy_write &&
-		    adapter->phy_write(adapter,
-				       NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
-				       *((int *)&status)) != 0)
-			return -EIO;
-		else {
-			adapter->link_speed = ecmd->speed;
-			adapter->link_duplex = ecmd->duplex;
-		}
-	} else
+	ret = nx_fw_cmd_set_gbe_port(adapter, ecmd->speed, ecmd->duplex,
+				     ecmd->autoneg);
+	if (ret == NX_RCODE_NOT_SUPPORTED)
 		return -EOPNOTSUPP;
+	else if (ret)
+		return -EIO;
+
+	adapter->link_speed = ecmd->speed;
+	adapter->link_duplex = ecmd->duplex;
+	adapter->link_autoneg = ecmd->autoneg;
 
 	if (!netif_running(dev))
 		return 0;
-- 
1.7.3.2

