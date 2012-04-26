From: Somnath Kotur <Somnath.Kotur@emulex.com>
Subject: [PATCH net-next 2/5] be2net: Fix to allow setting of debug levels in the firmware.
Date: Thu, 26 Apr 2012 19:57:45 +0530
Message-ID: <464dcb28-2450-4e0b-a30f-d8c9104bac86@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Somnath Kotur <somnath.kotur@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:47281 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757114Ab2DZOhY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 10:37:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Somnath Kotur <somnath.kotur@emulex.com>


Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c    |   59 ++++++++++++++++++++
 drivers/net/ethernet/emulex/benet/be_cmds.h    |   69 ++++++++++++++++++++++++
 drivers/net/ethernet/emulex/benet/be_ethtool.c |   67 +++++++++++++++++++++++
 3 files changed, 195 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 43167e8..9971e4b 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -2590,3 +2590,62 @@ err:
 	pci_free_consistent(adapter->pdev, cmd.size, cmd.va, cmd.dma);
 	return status;
 }
+
+int be_cmd_get_ext_fat_capabilites(struct be_adapter *adapter,
+				   struct be_dma_mem *cmd)
+{
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_req_get_ext_fat_caps *req;
+	int status;
+
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
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+			       OPCODE_COMMON_GET_EXT_FAT_CAPABILITES,
+			       cmd->size, wrb, cmd);
+	/*
+	* Retrieve currently set parameters
+	*/
+	req->parameter_type = cpu_to_le32(1);
+
+	status = be_mcc_notify_wait(adapter);
+err:
+	spin_unlock_bh(&adapter->mcc_lock);
+	return status;
+}
+
+int be_cmd_set_ext_fat_capabilites(struct be_adapter *adapter,
+				   struct be_dma_mem *cmd,
+				   struct be_fat_conf_params *configs)
+{
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_req_set_ext_fat_caps *req;
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
+	memcpy(&req->set_params, configs, sizeof(struct be_fat_conf_params));
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+			       OPCODE_COMMON_SET_EXT_FAT_CAPABILITES,
+			       cmd->size, wrb, cmd);
+
+	status = be_mcc_notify_wait(adapter);
+err:
+	spin_unlock_bh(&adapter->mcc_lock);
+	return status;
+}
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index 944f031..02df9f8 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -189,6 +189,8 @@ struct be_mcc_mailbox {
 #define OPCODE_COMMON_GET_PHY_DETAILS			102
 #define OPCODE_COMMON_SET_DRIVER_FUNCTION_CAP		103
 #define OPCODE_COMMON_GET_CNTL_ADDITIONAL_ATTRIBUTES	121
+#define OPCODE_COMMON_GET_EXT_FAT_CAPABILITES		125
+#define OPCODE_COMMON_SET_EXT_FAT_CAPABILITES		126
 #define OPCODE_COMMON_GET_MAC_LIST			147
 #define OPCODE_COMMON_SET_MAC_LIST			148
 #define OPCODE_COMMON_GET_HSW_CONFIG			152
@@ -1602,6 +1604,68 @@ static inline void *be_erx_stats_from_cmd(struct be_adapter *adapter)
 	}
 }
 
+/************** get fat capabilites *******************/
+#define MAX_MODULES 27
+#define MAX_MODES 4
+#define MODE_UART 0
+
+/* Trace level Valid values */
+enum {
+	TRACE_LEVEL_ALL = 0x0,
+	TRACE_LEVEL_ENTER_FUNCTION = 0x1,
+	TRACE_LEVEL_VERBOSE = 0x4,
+	TRACE_LEVEL_INFO = 0x5,
+	TRACE_LEVEL_TEST = 0x8,
+	TRACE_LEVEL_SHOW = 0x10,
+	TRACE_LEVEL_WARNING = 0x20,
+	TRACE_LEVEL_ERROR = 0x30,
+	TRACE_LEVEL_FATAL = 0x40,
+	TRACE_LEVEL_ALWAYS = 0x80,
+	TRACE_LEVEL_DISABLED = 0xff
+};
+
+struct ext_fat_mode {
+	u8 mode;
+	u8 rsvd0;
+	u16 port_mask;
+	u32 dbg_lvl;
+	u64 fun_mask;
+} __packed;
+
+struct ext_fat_modules {
+	u8 modules_str[32];
+	u32 modules_id;
+	u32 num_modes;
+	struct ext_fat_mode trace_lvl[MAX_MODES];
+} __packed;
+
+struct be_fat_conf_params {
+	u32 max_log_entries;
+	u32 log_entry_size;
+	u8 log_type;
+	u8 max_log_funs;
+	u8 max_log_ports;
+	u8 rsvd0;
+	u32 supp_modes;
+	u32 num_modules;
+	struct ext_fat_modules module[MAX_MODULES];
+} __packed;
+
+struct be_cmd_req_get_ext_fat_caps {
+	struct be_cmd_req_hdr hdr;
+	u32 parameter_type;
+};
+
+struct be_cmd_resp_get_ext_fat_caps {
+	struct be_cmd_resp_hdr hdr;
+	struct be_fat_conf_params get_params;
+};
+
+struct be_cmd_req_set_ext_fat_caps {
+	struct be_cmd_req_hdr hdr;
+	struct be_fat_conf_params set_params;
+};
+
 extern int be_pci_fnum_get(struct be_adapter *adapter);
 extern int be_cmd_POST(struct be_adapter *adapter);
 extern int be_cmd_mac_addr_query(struct be_adapter *adapter, u8 *mac_addr,
@@ -1707,4 +1771,9 @@ extern int be_cmd_set_hsw_config(struct be_adapter *adapter, u16 pvid,
 extern int be_cmd_get_hsw_config(struct be_adapter *adapter, u16 *pvid,
 			u32 domain, u16 intf_id);
 extern int be_cmd_get_acpi_wol_cap(struct be_adapter *adapter);
+extern int be_cmd_get_ext_fat_capabilites(struct be_adapter *adapter,
+					  struct be_dma_mem *cmd);
+extern int be_cmd_set_ext_fat_capabilites(struct be_adapter *adapter,
+					  struct be_dma_mem *cmd,
+					  struct be_fat_conf_params *cfgs);
 
diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index a00983e..5296df5 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -878,6 +878,72 @@ be_read_eeprom(struct net_device *netdev, struct ethtool_eeprom *eeprom,
 	return status;
 }
 
+static void be_set_msglevel(struct net_device *netdev, u32 data)
+{
+	struct be_adapter *adapter = netdev_priv(netdev);
+	struct be_dma_mem extfat_cmd;
+	struct be_fat_conf_params *cfgs;
+	int status;
+	int i, j;
+
+	if (lancer_chip(adapter)) {
+		dev_err(&adapter->pdev->dev, "Operation not supported\n");
+		return;
+	}
+
+	switch (data) {
+	case TRACE_LEVEL_ALL:
+	case TRACE_LEVEL_ENTER_FUNCTION:
+	case TRACE_LEVEL_VERBOSE:
+	case TRACE_LEVEL_INFO:
+	case TRACE_LEVEL_TEST:
+	case TRACE_LEVEL_SHOW:
+	case TRACE_LEVEL_WARNING:
+	case TRACE_LEVEL_ERROR:
+	case TRACE_LEVEL_FATAL:
+	case TRACE_LEVEL_ALWAYS:
+	case TRACE_LEVEL_DISABLED:
+		break;
+	default:
+		dev_err(&adapter->pdev->dev, "Invalid message level value\n");
+		return;
+	}
+
+	memset(&extfat_cmd, 0, sizeof(struct be_dma_mem));
+	extfat_cmd.size = sizeof(struct be_cmd_resp_get_ext_fat_caps);
+	extfat_cmd.va = pci_alloc_consistent(adapter->pdev, extfat_cmd.size,
+					     &extfat_cmd.dma);
+	if (!extfat_cmd.va) {
+		dev_err(&adapter->pdev->dev, "%s: Memory allocation failure\n",
+			__func__);
+		goto err;
+	}
+	status = be_cmd_get_ext_fat_capabilites(adapter, &extfat_cmd);
+	if (!status) {
+		cfgs = (struct be_fat_conf_params *)(extfat_cmd.va +
+					sizeof(struct be_cmd_resp_hdr));
+		for (i = 0; i < cfgs->num_modules; i++) {
+			for (j = 0; j < cfgs->module[i].num_modes; j++) {
+				if (cfgs->module[i].trace_lvl[j].mode ==
+								MODE_UART)
+					cfgs->module[i].trace_lvl[j].dbg_lvl =
+							cpu_to_le32(data);
+			}
+		}
+		status = be_cmd_set_ext_fat_capabilites(adapter, &extfat_cmd,
+							cfgs);
+		if (status)
+			dev_err(&adapter->pdev->dev,
+				"Message level set failed\n");
+	} else {
+		dev_err(&adapter->pdev->dev, "Message level get failed\n");
+	}
+
+	pci_free_consistent(adapter->pdev, extfat_cmd.size, extfat_cmd.va,
+			    extfat_cmd.dma);
+err:
+	return;
+}
 const struct ethtool_ops be_ethtool_ops = {
 	.get_settings = be_get_settings,
 	.get_drvinfo = be_get_drvinfo,
@@ -893,6 +959,7 @@ const struct ethtool_ops be_ethtool_ops = {
 	.set_pauseparam = be_set_pauseparam,
 	.get_strings = be_get_stat_strings,
 	.set_phys_id = be_set_phys_id,
+	.set_msglevel = be_set_msglevel,
 	.get_sset_count = be_get_sset_count,
 	.get_ethtool_stats = be_get_ethtool_stats,
 	.get_regs_len = be_get_reg_len,
-- 
1.5.6.1
