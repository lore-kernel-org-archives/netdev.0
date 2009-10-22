From: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Subject: [net-next-2.6 PATCH] be2net:Changes to update ethtool get_settings
	function to return appropriate values.
Date: Thu, 22 Oct 2009 19:00:00 +0530
Message-ID: <20091022132949.GA23701@serverengines.com>
Reply-To: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:54162 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754908AbZJVN3z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2009 09:29:55 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update ethtool get_settings function to:
- get current link speed settings from controller
- get port transceiver type from controller
- fill appropriate values for supported, phy_address

Signed-off-by: Sarveshwar Bandi <sarveshwarb@serverengines.com>
---
 drivers/net/benet/be_cmds.c    |   37 +++++++++++++++++++++++++++++++--
 drivers/net/benet/be_cmds.h    |   45 ++++++++++++++++++++++++++++++++++++++--
 drivers/net/benet/be_ethtool.c |   36 +++++++++++++++++++++++++++++++-
 drivers/net/benet/be_main.c    |    5 ++++
 4 files changed, 117 insertions(+), 6 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 25b6602..a034265 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -823,7 +823,7 @@ int be_cmd_get_stats(struct be_adapter *
 
 /* Uses synchronous mcc */
 int be_cmd_link_status_query(struct be_adapter *adapter,
-			bool *link_up)
+			bool *link_up, u8 *mac_speed, u16 *link_speed)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_link_status *req;
@@ -844,8 +844,11 @@ int be_cmd_link_status_query(struct be_a
 	status = be_mcc_notify_wait(adapter);
 	if (!status) {
 		struct be_cmd_resp_link_status *resp = embedded_payload(wrb);
-		if (resp->mac_speed != PHY_LINK_SPEED_ZERO)
+		if (resp->mac_speed != PHY_LINK_SPEED_ZERO) {
 			*link_up = true;
+			*link_speed = le16_to_cpu(resp->link_speed);
+			*mac_speed = resp->mac_speed;
+		}
 	}
 
 	spin_unlock_bh(&adapter->mcc_lock);
@@ -1177,6 +1180,36 @@ int be_cmd_get_beacon_state(struct be_ad
 	return status;
 }
 
+/* Uses sync mcc */
+int be_cmd_read_port_type(struct be_adapter *adapter, u32 port,
+				u8 *connector)
+{
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_req_port_type *req;
+	int status;
+
+	spin_lock_bh(&adapter->mcc_lock);
+
+	wrb = wrb_from_mccq(adapter);
+	req = embedded_payload(wrb);
+
+	be_wrb_hdr_prepare(wrb, sizeof(struct be_cmd_resp_port_type), true, 0);
+
+	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+		OPCODE_COMMON_READ_TRANSRECV_DATA, sizeof(*req));
+
+	req->port = cpu_to_le32(port);
+	req->page_num = cpu_to_le32(TR_PAGE_A0);
+	status = be_mcc_notify_wait(adapter);
+	if (!status) {
+		struct be_cmd_resp_port_type *resp = embedded_payload(wrb);
+			*connector = resp->data.connector;
+	}
+
+	spin_unlock_bh(&adapter->mcc_lock);
+	return status;
+}
+
 int be_cmd_write_flashrom(struct be_adapter *adapter, struct be_dma_mem *cmd,
 			u32 flash_type, u32 flash_opcode, u32 buf_size)
 {
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index a1e78cc..65e14dd 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -140,6 +140,7 @@ #define OPCODE_COMMON_NTWK_PMAC_DEL			60
 #define OPCODE_COMMON_FUNCTION_RESET			61
 #define OPCODE_COMMON_ENABLE_DISABLE_BEACON		69
 #define OPCODE_COMMON_GET_BEACON_STATE			70
+#define OPCODE_COMMON_READ_TRANSRECV_DATA		73
 
 #define OPCODE_ETH_ACPI_CONFIG				2
 #define OPCODE_ETH_PROMISCUOUS				3
@@ -635,9 +636,47 @@ struct be_cmd_resp_link_status {
 	u8 mac_fault;
 	u8 mgmt_mac_duplex;
 	u8 mgmt_mac_speed;
-	u16 rsvd0;
+	u16 link_speed;
+	u32 rsvd0;
 } __packed;
 
+/******************** Port Identification ***************************/
+/*    Identifies the type of port attached to NIC     */
+struct be_cmd_req_port_type {
+	struct be_cmd_req_hdr hdr;
+	u32 page_num;
+	u32 port;
+};
+
+enum {
+	TR_PAGE_A0 = 0xa0,
+	TR_PAGE_A2 = 0xa2
+};
+
+struct be_cmd_resp_port_type {
+	struct be_cmd_resp_hdr hdr;
+	u32 page_num;
+	u32 port;
+	struct data {
+		u8 identifier;
+		u8 identifier_ext;
+		u8 connector;
+		u8 transceiver[8];
+		u8 rsvd0[3];
+		u8 length_km;
+		u8 length_hm;
+		u8 length_om1;
+		u8 length_om2;
+		u8 length_cu;
+		u8 length_cu_m;
+		u8 vendor_name[16];
+		u8 rsvd;
+		u8 vendor_oui[3];
+		u8 vendor_pn[16];
+		u8 vendor_rev[4];
+	} data;
+};
+
 /******************** Get FW Version *******************/
 struct be_cmd_req_get_fw_version {
 	struct be_cmd_req_hdr hdr;
@@ -775,7 +814,7 @@ extern int be_cmd_rxq_create(struct be_a
 extern int be_cmd_q_destroy(struct be_adapter *adapter, struct be_queue_info *q,
 			int type);
 extern int be_cmd_link_status_query(struct be_adapter *adapter,
-			bool *link_up);
+			bool *link_up, u8 *mac_speed, u16 *link_speed);
 extern int be_cmd_reset(struct be_adapter *adapter);
 extern int be_cmd_get_stats(struct be_adapter *adapter,
 			struct be_dma_mem *nonemb_cmd);
@@ -801,6 +840,8 @@ extern int be_cmd_set_beacon_state(struc
 			u8 port_num, u8 beacon, u8 status, u8 state);
 extern int be_cmd_get_beacon_state(struct be_adapter *adapter,
 			u8 port_num, u32 *state);
+extern int be_cmd_read_port_type(struct be_adapter *adapter, u32 port,
+					u8 *connector);
 extern int be_cmd_write_flashrom(struct be_adapter *adapter,
 			struct be_dma_mem *cmd, u32 flash_oper,
 			u32 flash_opcode, u32 buf_size);
diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index 280471e..edebce9 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -293,9 +293,43 @@ static int be_get_sset_count(struct net_
 
 static int be_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 {
-	ecmd->speed = SPEED_10000;
+	struct be_adapter *adapter = netdev_priv(netdev);
+	u8 mac_speed = 0, connector = 0;
+	u16 link_speed = 0;
+	bool link_up = false;
+
+	be_cmd_link_status_query(adapter, &link_up, &mac_speed, &link_speed);
+
+	/* link_speed is in units of 10 Mbps */
+	if (link_speed) {
+		ecmd->speed = link_speed*10;
+	} else {
+		switch (mac_speed) {
+		case PHY_LINK_SPEED_1GBPS:
+			ecmd->speed = SPEED_1000;
+			break;
+		case PHY_LINK_SPEED_10GBPS:
+			ecmd->speed = SPEED_10000;
+			break;
+		}
+	}
 	ecmd->duplex = DUPLEX_FULL;
 	ecmd->autoneg = AUTONEG_DISABLE;
+	ecmd->supported = (SUPPORTED_10000baseT_Full | SUPPORTED_TP);
+
+	be_cmd_read_port_type(adapter, adapter->port_num, &connector);
+	switch (connector) {
+	case 7:
+		ecmd->port = PORT_FIBRE;
+		break;
+	default:
+		ecmd->port = PORT_TP;
+		break;
+	}
+
+	ecmd->phy_address = adapter->port_num;
+	ecmd->transceiver = XCVR_INTERNAL;
+
 	return 0;
 }
 
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index e0f9d64..a48e822 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1586,6 +1586,8 @@ static int be_open(struct net_device *ne
 	struct be_eq_obj *tx_eq = &adapter->tx_eq;
 	bool link_up;
 	int status;
+	u8 mac_speed;
+	u16 link_speed;
 
 	/* First time posting */
 	be_post_rx_frags(adapter);
@@ -1604,7 +1606,8 @@ static int be_open(struct net_device *ne
 	/* Rx compl queue may be in unarmed state; rearm it */
 	be_cq_notify(adapter, adapter->rx_obj.cq.id, true, 0);
 
-	status = be_cmd_link_status_query(adapter, &link_up);
+	status = be_cmd_link_status_query(adapter, &link_up, &mac_speed,
+			&link_speed);
 	if (status)
 		return status;
 	be_link_status_update(adapter, link_up);
-- 
1.4.0

