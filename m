From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 3/3] be2net: support deleting FW dump via ethtool (only for Lancer)
Date: Fri, 1 Aug 2014 17:47:32 +0530
Message-ID: <1406895452-29514-4-git-send-email-sathya.perla@emulex.com>
References: <1406895452-29514-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:6599 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755260AbaHAMPp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2014 08:15:45 -0400
In-Reply-To: <1406895452-29514-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@emulex.com>

This patch adds support to delete an existing FW-dump in Lancer via ethtool.
Initiating a new dump is not allowed if a FW dump is already present in the
adapter. The existing dump has to be first explicitly deleted.

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h         |    2 +
 drivers/net/ethernet/emulex/benet/be_cmds.c    |   48 ++++++++++++++++++++++-
 drivers/net/ethernet/emulex/benet/be_cmds.h    |   10 +++++
 drivers/net/ethernet/emulex/benet/be_ethtool.c |   17 ++++----
 4 files changed, 65 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 0048ef8..811f135 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -383,8 +383,10 @@ enum vf_state {
 
 #define BE_UC_PMAC_COUNT			30
 #define BE_VF_UC_PMAC_COUNT			2
+
 /* Ethtool set_dump flags */
 #define LANCER_INITIATE_FW_DUMP			0x1
+#define LANCER_DELETE_FW_DUMP			0x2
 
 struct phy_info {
 	u8 transceiver;
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 791094c..4370ec1 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -2240,6 +2240,34 @@ err_unlock:
 	return status;
 }
 
+int lancer_cmd_delete_object(struct be_adapter *adapter, const char *obj_name)
+{
+	struct lancer_cmd_req_delete_object *req;
+	struct be_mcc_wrb *wrb;
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
+	req = embedded_payload(wrb);
+
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+			       OPCODE_COMMON_DELETE_OBJECT,
+			       sizeof(*req), wrb, NULL);
+
+	strcpy(req->object_name, obj_name);
+
+	status = be_mcc_notify_wait(adapter);
+err:
+	spin_unlock_bh(&adapter->mcc_lock);
+	return status;
+}
+
 int lancer_cmd_read_object(struct be_adapter *adapter, struct be_dma_mem *cmd,
 			   u32 data_size, u32 data_offset, const char *obj_name,
 			   u32 *data_read, u32 *eof, u8 *addn_status)
@@ -3805,13 +3833,19 @@ bool dump_present(struct be_adapter *adapter)
 
 int lancer_initiate_dump(struct be_adapter *adapter)
 {
+	struct device *dev = &adapter->pdev->dev;
 	int status;
 
+	if (dump_present(adapter)) {
+		dev_info(dev, "Previous dump not cleared, not forcing dump\n");
+		return -EEXIST;
+	}
+
 	/* give firmware reset and diagnostic dump */
 	status = lancer_physdev_ctrl(adapter, PHYSDEV_CONTROL_FW_RESET_MASK |
 				     PHYSDEV_CONTROL_DD_MASK);
 	if (status < 0) {
-		dev_err(&adapter->pdev->dev, "Firmware reset failed\n");
+		dev_err(dev, "FW reset failed\n");
 		return status;
 	}
 
@@ -3820,13 +3854,21 @@ int lancer_initiate_dump(struct be_adapter *adapter)
 		return status;
 
 	if (!dump_present(adapter)) {
-		dev_err(&adapter->pdev->dev, "Dump image not present\n");
-		return -1;
+		dev_err(dev, "FW dump not generated\n");
+		return -EIO;
 	}
 
 	return 0;
 }
 
+int lancer_delete_dump(struct be_adapter *adapter)
+{
+	int status;
+
+	status = lancer_cmd_delete_object(adapter, LANCER_FW_DUMP_FILE);
+	return be_cmd_status(status);
+}
+
 /* Uses sync mcc */
 int be_cmd_enable_vf(struct be_adapter *adapter, u8 domain)
 {
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index 03e8a15..5284b82 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -231,6 +231,7 @@ struct be_mcc_mailbox {
 #define OPCODE_COMMON_GET_FN_PRIVILEGES			170
 #define OPCODE_COMMON_READ_OBJECT			171
 #define OPCODE_COMMON_WRITE_OBJECT			172
+#define OPCODE_COMMON_DELETE_OBJECT			174
 #define OPCODE_COMMON_MANAGE_IFACE_FILTERS		193
 #define OPCODE_COMMON_GET_IFACE_LIST			194
 #define OPCODE_COMMON_ENABLE_DISABLE_VF			196
@@ -1253,6 +1254,13 @@ struct lancer_cmd_resp_read_object {
 	u32 eof;
 };
 
+struct lancer_cmd_req_delete_object {
+	struct be_cmd_req_hdr hdr;
+	u32 rsvd1;
+	u32 rsvd2;
+	u8 object_name[104];
+};
+
 /************************ WOL *******************************/
 struct be_cmd_req_acpi_wol_magic_config{
 	struct be_cmd_req_hdr hdr;
@@ -2067,6 +2075,7 @@ int lancer_cmd_write_object(struct be_adapter *adapter, struct be_dma_mem *cmd,
 int lancer_cmd_read_object(struct be_adapter *adapter, struct be_dma_mem *cmd,
 			   u32 data_size, u32 data_offset, const char *obj_name,
 			   u32 *data_read, u32 *eof, u8 *addn_status);
+int lancer_cmd_delete_object(struct be_adapter *adapter, const char *obj_name);
 int be_cmd_get_flash_crc(struct be_adapter *adapter, u8 *flashed_crc,
 			  u16 optype, int offset);
 int be_cmd_enable_magic_wol(struct be_adapter *adapter, u8 *mac,
@@ -2120,6 +2129,7 @@ int be_cmd_set_ext_fat_capabilites(struct be_adapter *adapter,
 				   struct be_fat_conf_params *cfgs);
 int lancer_physdev_ctrl(struct be_adapter *adapter, u32 mask);
 int lancer_initiate_dump(struct be_adapter *adapter);
+int lancer_delete_dump(struct be_adapter *adapter);
 bool dump_present(struct be_adapter *adapter);
 int lancer_test_and_set_rdy_state(struct be_adapter *adapter);
 int be_cmd_query_port_name(struct be_adapter *adapter, u8 *port_name);
diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index 25f516d..0cd3311 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -681,22 +681,21 @@ static int be_set_dump(struct net_device *netdev, struct ethtool_dump *dump)
 	struct device *dev = &adapter->pdev->dev;
 	int status;
 
-	if (!lancer_chip(adapter)) {
-		dev_err(dev, "FW dump not supported\n");
+	if (!lancer_chip(adapter) ||
+	    !check_privilege(adapter, MAX_PRIVILEGES))
 		return -EOPNOTSUPP;
-	}
-
-	if (dump_present(adapter)) {
-		dev_err(dev, "Previous dump not cleared, not forcing dump\n");
-		return 0;
-	}
 
 	switch (dump->flag) {
 	case LANCER_INITIATE_FW_DUMP:
 		status = lancer_initiate_dump(adapter);
 		if (!status)
-			dev_info(dev, "F/w dump initiated successfully\n");
+			dev_info(dev, "FW dump initiated successfully\n");
 		break;
+	case LANCER_DELETE_FW_DUMP:
+		status = lancer_delete_dump(adapter);
+		if (!status)
+			dev_info(dev, "FW dump deleted successfully\n");
+	break;
 	default:
 		dev_err(dev, "Invalid dump level: 0x%x\n", dump->flag);
 		return -EINVAL;
-- 
1.7.1
