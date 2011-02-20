From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next 6/6] be2net: use hba_port_num instead of port_num
Date: Sun, 20 Feb 2011 15:42:22 -0600
Message-ID: <20110220214222.GA13707@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:11629 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755110Ab1BTVmk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Feb 2011 16:42:40 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use hba_port_num for phy loopback and ethtool phy identification.

From: Suresh R <suresh.reddy@emulex.com>
Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/benet/be.h         |    1 +
 drivers/net/benet/be_cmds.c    |   54 ++++++++++++++++++++++++++++++++++++++++
 drivers/net/benet/be_cmds.h    |   12 +++++++++
 drivers/net/benet/be_ethtool.c |   12 ++++----
 drivers/net/benet/be_hw.h      |   47 ++++++++++++++++++++++++++++++++++
 drivers/net/benet/be_main.c    |    4 +++
 6 files changed, 124 insertions(+), 6 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index 46b951f..ed709a5 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -318,6 +318,7 @@ struct be_adapter {
 	struct be_vf_cfg vf_cfg[BE_MAX_VF];
 	u8 is_virtfn;
 	u32 sli_family;
+	u8 hba_port_num;
 	u16 pvid;
 };
 
diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index ff62aae..1822ecd 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -1954,3 +1954,57 @@ err:
 	spin_unlock_bh(&adapter->mcc_lock);
 	return status;
 }
+
+int be_cmd_get_cntl_attributes(struct be_adapter *adapter)
+{
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_req_cntl_attribs *req;
+	struct be_cmd_resp_cntl_attribs *resp;
+	struct be_sge *sge;
+	int status;
+	int payload_len = max(sizeof(*req), sizeof(*resp));
+	struct mgmt_controller_attrib *attribs;
+	struct be_dma_mem attribs_cmd;
+
+	memset(&attribs_cmd, 0, sizeof(struct be_dma_mem));
+	attribs_cmd.size = sizeof(struct be_cmd_resp_cntl_attribs);
+	attribs_cmd.va = pci_alloc_consistent(adapter->pdev, attribs_cmd.size,
+						&attribs_cmd.dma);
+	if (!attribs_cmd.va) {
+		dev_err(&adapter->pdev->dev,
+				"Memory allocation failure\n");
+		return -ENOMEM;
+	}
+
+	if (mutex_lock_interruptible(&adapter->mbox_lock))
+		return -1;
+
+	wrb = wrb_from_mbox(adapter);
+	if (!wrb) {
+		status = -EBUSY;
+		goto err;
+	}
+	req = attribs_cmd.va;
+	sge = nonembedded_sgl(wrb);
+
+	be_wrb_hdr_prepare(wrb, payload_len, false, 1,
+			OPCODE_COMMON_GET_CNTL_ATTRIBUTES);
+	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+			 OPCODE_COMMON_GET_CNTL_ATTRIBUTES, payload_len);
+	sge->pa_hi = cpu_to_le32(upper_32_bits(attribs_cmd.dma));
+	sge->pa_lo = cpu_to_le32(attribs_cmd.dma & 0xFFFFFFFF);
+	sge->len = cpu_to_le32(attribs_cmd.size);
+
+	status = be_mbox_notify_wait(adapter);
+	if (!status) {
+		attribs = (struct mgmt_controller_attrib *)( attribs_cmd.va +
+					sizeof(struct be_cmd_resp_hdr));
+		adapter->hba_port_num = attribs->hba_attribs.phy_port;
+	}
+
+err:
+	mutex_unlock(&adapter->mbox_lock);
+	pci_free_consistent(adapter->pdev, attribs_cmd.size, attribs_cmd.va,
+					attribs_cmd.dma);
+	return status;
+}
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index 6e89de8..93e5768 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -169,6 +169,7 @@ struct be_mcc_mailbox {
 #define OPCODE_COMMON_SET_QOS				28
 #define OPCODE_COMMON_MCC_CREATE_EXT			90
 #define OPCODE_COMMON_SEEPROM_READ			30
+#define OPCODE_COMMON_GET_CNTL_ATTRIBUTES               32
 #define OPCODE_COMMON_NTWK_RX_FILTER    		34
 #define OPCODE_COMMON_GET_FW_VERSION			35
 #define OPCODE_COMMON_SET_FLOW_CONTROL			36
@@ -1030,6 +1031,16 @@ struct be_cmd_resp_set_qos {
 	u32 rsvd;
 };
 
+/*********************** Controller Attributes ***********************/
+struct be_cmd_req_cntl_attribs {
+	struct be_cmd_req_hdr hdr;
+};
+
+struct be_cmd_resp_cntl_attribs {
+	struct be_cmd_resp_hdr hdr;
+	struct mgmt_controller_attrib attribs;
+};
+
 extern int be_pci_fnum_get(struct be_adapter *adapter);
 extern int be_cmd_POST(struct be_adapter *adapter);
 extern int be_cmd_mac_addr_query(struct be_adapter *adapter, u8 *mac_addr,
@@ -1115,4 +1126,5 @@ extern int be_cmd_get_phy_info(struct be_adapter *adapter,
 extern int be_cmd_set_qos(struct be_adapter *adapter, u32 bps, u32 domain);
 extern void be_detect_dump_ue(struct be_adapter *adapter);
 extern int be_cmd_get_die_temperature(struct be_adapter *adapter);
+extern int be_cmd_get_cntl_attributes(struct be_adapter *adapter);
 
diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index 4766693..6e5e433 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -513,7 +513,7 @@ be_phys_id(struct net_device *netdev, u32 data)
 	int status;
 	u32 cur;
 
-	be_cmd_get_beacon_state(adapter, adapter->port_num, &cur);
+	be_cmd_get_beacon_state(adapter, adapter->hba_port_num, &cur);
 
 	if (cur == BEACON_STATE_ENABLED)
 		return 0;
@@ -521,12 +521,12 @@ be_phys_id(struct net_device *netdev, u32 data)
 	if (data < 2)
 		data = 2;
 
-	status = be_cmd_set_beacon_state(adapter, adapter->port_num, 0, 0,
+	status = be_cmd_set_beacon_state(adapter, adapter->hba_port_num, 0, 0,
 			BEACON_STATE_ENABLED);
 	set_current_state(TASK_INTERRUPTIBLE);
 	schedule_timeout(data*HZ);
 
-	status = be_cmd_set_beacon_state(adapter, adapter->port_num, 0, 0,
+	status = be_cmd_set_beacon_state(adapter, adapter->hba_port_num, 0, 0,
 			BEACON_STATE_DISABLED);
 
 	return status;
@@ -605,12 +605,12 @@ err:
 static u64 be_loopback_test(struct be_adapter *adapter, u8 loopback_type,
 				u64 *status)
 {
-	be_cmd_set_loopback(adapter, adapter->port_num,
+	be_cmd_set_loopback(adapter, adapter->hba_port_num,
 				loopback_type, 1);
-	*status = be_cmd_loopback_test(adapter, adapter->port_num,
+	*status = be_cmd_loopback_test(adapter, adapter->hba_port_num,
 				loopback_type, 1500,
 				2, 0xabc);
-	be_cmd_set_loopback(adapter, adapter->port_num,
+	be_cmd_set_loopback(adapter, adapter->hba_port_num,
 				BE_NO_LOOPBACK, 1);
 	return *status;
 }
diff --git a/drivers/net/benet/be_hw.h b/drivers/net/benet/be_hw.h
index 4096d97..3f459f7 100644
--- a/drivers/net/benet/be_hw.h
+++ b/drivers/net/benet/be_hw.h
@@ -327,6 +327,53 @@ struct be_eth_rx_compl {
 	u32 dw[4];
 };
 
+struct mgmt_hba_attribs {
+	u8 flashrom_version_string[32];
+	u8 manufacturer_name[32];
+	u32 supported_modes;
+	u32 rsvd0[3];
+	u8 ncsi_ver_string[12];
+	u32 default_extended_timeout;
+	u8 controller_model_number[32];
+	u8 controller_description[64];
+	u8 controller_serial_number[32];
+	u8 ip_version_string[32];
+	u8 firmware_version_string[32];
+	u8 bios_version_string[32];
+	u8 redboot_version_string[32];
+	u8 driver_version_string[32];
+	u8 fw_on_flash_version_string[32];
+	u32 functionalities_supported;
+	u16 max_cdblength;
+	u8 asic_revision;
+	u8 generational_guid[16];
+	u8 hba_port_count;
+	u16 default_link_down_timeout;
+	u8 iscsi_ver_min_max;
+	u8 multifunction_device;
+	u8 cache_valid;
+	u8 hba_status;
+	u8 max_domains_supported;
+	u8 phy_port;
+	u32 firmware_post_status;
+	u32 hba_mtu[8];
+	u32 rsvd1[4];
+};
+
+struct mgmt_controller_attrib {
+	struct mgmt_hba_attribs hba_attribs;
+	u16 pci_vendor_id;
+	u16 pci_device_id;
+	u16 pci_sub_vendor_id;
+	u16 pci_sub_system_id;
+	u8 pci_bus_number;
+	u8 pci_device_number;
+	u8 pci_function_number;
+	u8 interface_type;
+	u64 unique_identifier;
+	u32 rsvd0[5];
+};
+
 struct controller_id {
 	u32 vendor;
 	u32 device;
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index cd6fda7..0bdccb1 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -2868,6 +2868,10 @@ static int be_get_config(struct be_adapter *adapter)
 	else
 		adapter->max_vlans = BE_NUM_VLANS_SUPPORTED;
 
+	status = be_cmd_get_cntl_attributes(adapter);
+	if (status)
+		return status;
+
 	return 0;
 }
 
-- 
1.7.1

