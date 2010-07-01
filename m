From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH net-next-2.6] be2net: changes to properly provide phy
 details
Date: Thu, 1 Jul 2010 19:21:00 +0530
Message-ID: <20100701135049.GA4518@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:10317 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752548Ab0GANvF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jul 2010 09:51:05 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

be2net driver is currently not showing correct phy details in certain cases.
This patch fixes it.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be.h         |    1 +
 drivers/net/benet/be_cmds.c    |   35 +++++++++++++++++++++++++
 drivers/net/benet/be_cmds.h    |   27 +++++++++++++++++++
 drivers/net/benet/be_ethtool.c |   55 +++++++++++++++++++++++++++++----------
 4 files changed, 104 insertions(+), 14 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index b46be49..1a0d2d0 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -282,6 +282,7 @@ struct be_adapter {
 	int link_speed;
 	u8 port_type;
 	u8 transceiver;
+	u8 autoneg;
 	u8 generation;		/* BladeEngine ASIC generation */
 	u32 flash_status;
 	struct completion flash_compl;
diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 65e3260..344e062 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -1695,3 +1695,38 @@ int be_cmd_get_seeprom_data(struct be_adapter *adapter,
 	spin_unlock_bh(&adapter->mcc_lock);
 	return status;
 }
+
+int be_cmd_get_phy_info(struct be_adapter *adapter, struct be_dma_mem *cmd)
+{
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_req_get_phy_info *req;
+	struct be_sge *sge;
+	int status;
+
+	spin_lock_bh(&adapter->mcc_lock);
+
+	wrb = wrb_from_mccq(adapter);
+	if (!wrb) {
+		status = -EBUSY;
+		goto err;
+	}
+
+	req = cmd->va;
+	sge = nonembedded_sgl(wrb);
+
+	be_wrb_hdr_prepare(wrb, sizeof(*req), false, 1,
+				OPCODE_COMMON_GET_PHY_DETAILS);
+
+	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+			OPCODE_COMMON_GET_PHY_DETAILS,
+			sizeof(*req));
+
+	sge->pa_hi = cpu_to_le32(upper_32_bits(cmd->dma));
+	sge->pa_lo = cpu_to_le32(cmd->dma & 0xFFFFFFFF);
+	sge->len = cpu_to_le32(cmd->size);
+
+	status = be_mcc_notify_wait(adapter);
+err:
+	spin_unlock_bh(&adapter->mcc_lock);
+	return status;
+}
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index 763dc19..912a058 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -144,6 +144,7 @@ struct be_mcc_mailbox {
 #define OPCODE_COMMON_ENABLE_DISABLE_BEACON		69
 #define OPCODE_COMMON_GET_BEACON_STATE			70
 #define OPCODE_COMMON_READ_TRANSRECV_DATA		73
+#define OPCODE_COMMON_GET_PHY_DETAILS			102
 
 #define OPCODE_ETH_ACPI_CONFIG				2
 #define OPCODE_ETH_PROMISCUOUS				3
@@ -869,6 +870,30 @@ struct be_cmd_resp_seeprom_read {
 	u8 seeprom_data[BE_READ_SEEPROM_LEN];
 };
 
+enum {
+	PHY_TYPE_CX4_10GB = 0,
+	PHY_TYPE_XFP_10GB,
+	PHY_TYPE_SFP_1GB,
+	PHY_TYPE_SFP_PLUS_10GB,
+	PHY_TYPE_KR_10GB,
+	PHY_TYPE_KX4_10GB,
+	PHY_TYPE_BASET_10GB,
+	PHY_TYPE_BASET_1GB,
+	PHY_TYPE_DISABLED = 255
+};
+
+struct be_cmd_req_get_phy_info {
+	struct be_cmd_req_hdr hdr;
+	u8 rsvd0[24];
+};
+struct be_cmd_resp_get_phy_info {
+	struct be_cmd_req_hdr hdr;
+	u16 phy_type;
+	u16 interface_type;
+	u32 misc_params;
+	u32 future_use[4];
+};
+
 extern int be_pci_fnum_get(struct be_adapter *adapter);
 extern int be_cmd_POST(struct be_adapter *adapter);
 extern int be_cmd_mac_addr_query(struct be_adapter *adapter, u8 *mac_addr,
@@ -947,4 +972,6 @@ extern int be_cmd_get_seeprom_data(struct be_adapter *adapter,
 				struct be_dma_mem *nonemb_cmd);
 extern int be_cmd_set_loopback(struct be_adapter *adapter, u8 port_num,
 				u8 loopback_type, u8 enable);
+extern int be_cmd_get_phy_info(struct be_adapter *adapter,
+		struct be_dma_mem *cmd);
 
diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index 200e985..c0ade24 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -314,10 +314,13 @@ static int be_get_sset_count(struct net_device *netdev, int stringset)
 static int be_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
-	u8 mac_speed = 0, connector = 0;
+	struct be_dma_mem phy_cmd;
+	struct be_cmd_resp_get_phy_info *resp;
+	u8 mac_speed = 0;
 	u16 link_speed = 0;
 	bool link_up = false;
 	int status;
+	u16 intf_type;
 
 	if (adapter->link_speed < 0) {
 		status = be_cmd_link_status_query(adapter, &link_up,
@@ -337,40 +340,57 @@ static int be_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 			}
 		}
 
-		status = be_cmd_read_port_type(adapter, adapter->port_num,
-						&connector);
+		phy_cmd.size = sizeof(struct be_cmd_req_get_phy_info);
+		phy_cmd.va = pci_alloc_consistent(adapter->pdev, phy_cmd.size,
+					&phy_cmd.dma);
+		if (!phy_cmd.va) {
+			dev_err(&adapter->pdev->dev, "Memory alloc failure\n");
+			return -ENOMEM;
+		}
+		status = be_cmd_get_phy_info(adapter, &phy_cmd);
 		if (!status) {
-			switch (connector) {
-			case 7:
+			resp = (struct be_cmd_resp_get_phy_info *) phy_cmd.va;
+			intf_type = le16_to_cpu(resp->interface_type);
+
+			switch (intf_type) {
+			case PHY_TYPE_XFP_10GB:
+			case PHY_TYPE_SFP_1GB:
+			case PHY_TYPE_SFP_PLUS_10GB:
 				ecmd->port = PORT_FIBRE;
-				ecmd->transceiver = XCVR_EXTERNAL;
-				break;
-			case 0:
-				ecmd->port = PORT_TP;
-				ecmd->transceiver = XCVR_EXTERNAL;
 				break;
 			default:
 				ecmd->port = PORT_TP;
-				ecmd->transceiver = XCVR_INTERNAL;
 				break;
 			}
-		} else {
-			ecmd->port = PORT_AUI;
+
+			switch (intf_type) {
+			case PHY_TYPE_KR_10GB:
+			case PHY_TYPE_KX4_10GB:
+				ecmd->autoneg = AUTONEG_ENABLE;
 			ecmd->transceiver = XCVR_INTERNAL;
+				break;
+			default:
+				ecmd->autoneg = AUTONEG_DISABLE;
+				ecmd->transceiver = XCVR_EXTERNAL;
+				break;
+			}
 		}
 
 		/* Save for future use */
 		adapter->link_speed = ecmd->speed;
 		adapter->port_type = ecmd->port;
 		adapter->transceiver = ecmd->transceiver;
+		adapter->autoneg = ecmd->autoneg;
+		pci_free_consistent(adapter->pdev, phy_cmd.size,
+					phy_cmd.va, phy_cmd.dma);
 	} else {
 		ecmd->speed = adapter->link_speed;
 		ecmd->port = adapter->port_type;
 		ecmd->transceiver = adapter->transceiver;
+		ecmd->autoneg = adapter->autoneg;
 	}
 
 	ecmd->duplex = DUPLEX_FULL;
-	ecmd->autoneg = AUTONEG_DISABLE;
 	ecmd->phy_address = adapter->port_num;
 	switch (ecmd->port) {
 	case PORT_FIBRE:
@@ -384,6 +404,13 @@ static int be_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 		break;
 	}
 
+	if (ecmd->autoneg) {
+		ecmd->supported |= SUPPORTED_1000baseT_Full;
+		ecmd->supported |= SUPPORTED_Autoneg;
+		ecmd->advertising |= (ADVERTISED_10000baseT_Full |
+				ADVERTISED_1000baseT_Full);
+	}
+
 	return 0;
 }
 
-- 
1.7.0.4

