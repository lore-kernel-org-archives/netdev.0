From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net-next v5] be2net: Fix to allow get/set of debug levels in the firmware.
Date: Fri, 18 May 2012 14:29:03 +0530
Message-ID: <66e444e7-aef9-4ce5-a695-10a70fe3b31e@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Somnath Kotur <somnath.kotur@emulex.com>,
	Suresh Reddy <suresh.reddy@emulex.com>
To: <netdev@vger.kernel.org>, <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:54234 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S966339Ab2ERJAZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2012 05:00:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch re-spin.
Incorporated review comments by Ben Hutchings.

Signed-off-by: Suresh Reddy <suresh.reddy@emulex.com>
Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h         |    3 +
 drivers/net/ethernet/emulex/benet/be_cmds.c    |   56 +++++++++++++++++
 drivers/net/ethernet/emulex/benet/be_cmds.h    |   57 +++++++++++++++++
 drivers/net/ethernet/emulex/benet/be_ethtool.c |   77 ++++++++++++++++++++++++
 drivers/net/ethernet/emulex/benet/be_main.c    |   37 +++++++++++
 5 files changed, 230 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index ecf1a81..ff4eb8f 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -421,6 +421,7 @@ struct be_adapter {
 	bool wol;
 	u32 max_pmac_cnt;	/* Max secondary UC MACs programmable */
 	u32 uc_macs;		/* Count of secondary UC MAC programmed */
+	u32 msg_enable;
 };
 
 #define be_physfn(adapter)		(!adapter->virtfn)
@@ -603,4 +604,6 @@ extern void be_parse_stats(struct be_adapter *adapter);
 extern int be_load_fw(struct be_adapter *adapter, u8 *func);
 extern bool be_is_wol_supported(struct be_adapter *adapter);
 extern bool be_pause_supported(struct be_adapter *adapter);
+extern u32 be_get_fw_log_level(struct be_adapter *adapter);
+
 #endif				/* BE_H */
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 43167e8..b24623c 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -2589,4 +2589,60 @@ err:
 	mutex_unlock(&adapter->mbox_lock);
 	pci_free_consistent(adapter->pdev, cmd.size, cmd.va, cmd.dma);
 	return status;
+
+}
+int be_cmd_get_ext_fat_capabilites(struct be_adapter *adapter,
+				   struct be_dma_mem *cmd)
+{
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_req_get_ext_fat_caps *req;
+	int status;
+
+	if (mutex_lock_interruptible(&adapter->mbox_lock))
+		return -1;
+
+	wrb = wrb_from_mbox(adapter);
+	if (!wrb) {
+		status = -EBUSY;
+		goto err;
+	}
+
+	req = cmd->va;
+	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+			       OPCODE_COMMON_GET_EXT_FAT_CAPABILITES,
+			       cmd->size, wrb, cmd);
+	req->parameter_type = cpu_to_le32(1);
+
+	status = be_mbox_notify_wait(adapter);
+err:
+	mutex_unlock(&adapter->mbox_lock);
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
 }
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index 944f031..0b1029b 100644
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
@@ -1602,6 +1604,56 @@ static inline void *be_erx_stats_from_cmd(struct be_adapter *adapter)
 	}
 }
 
+
+/************** get fat capabilites *******************/
+#define MAX_MODULES 27
+#define MAX_MODES 4
+#define MODE_UART 0
+#define FW_LOG_LEVEL_DEFAULT 48
+#define FW_LOG_LEVEL_FATAL 64
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
@@ -1707,4 +1759,9 @@ extern int be_cmd_set_hsw_config(struct be_adapter *adapter, u16 pvid,
 extern int be_cmd_get_hsw_config(struct be_adapter *adapter, u16 *pvid,
 			u32 domain, u16 intf_id);
 extern int be_cmd_get_acpi_wol_cap(struct be_adapter *adapter);
+extern int be_cmd_get_ext_fat_capabilites(struct be_adapter *adapter,
+					  struct be_dma_mem *cmd);
+extern int be_cmd_set_ext_fat_capabilites(struct be_adapter *adapter,
+					  struct be_dma_mem *cmd,
+					  struct be_fat_conf_params *cfgs);
 
diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index 747f68f..63e51d4 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -878,6 +878,81 @@ be_read_eeprom(struct net_device *netdev, struct ethtool_eeprom *eeprom,
 	return status;
 }
 
+static u32 be_get_msg_level(struct net_device *netdev)
+{
+	struct be_adapter *adapter = netdev_priv(netdev);
+
+	if (lancer_chip(adapter)) {
+		dev_err(&adapter->pdev->dev, "Operation not supported\n");
+		return -EOPNOTSUPP;
+	}
+
+	return adapter->msg_enable;
+}
+
+static void be_set_fw_log_level(struct be_adapter *adapter, u32 level)
+{
+	struct be_dma_mem extfat_cmd;
+	struct be_fat_conf_params *cfgs;
+	int status;
+	int i, j;
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
+							cpu_to_le32(level);
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
+
+static void be_set_msg_level(struct net_device *netdev, u32 level)
+{
+	struct be_adapter *adapter = netdev_priv(netdev);
+
+	if (lancer_chip(adapter)) {
+		dev_err(&adapter->pdev->dev, "Operation not supported\n");
+		return;
+	}
+
+	if (adapter->msg_enable == level)
+		return;
+
+	if ((level & NETIF_MSG_HW) != (adapter->msg_enable & NETIF_MSG_HW))
+		be_set_fw_log_level(adapter, level & NETIF_MSG_HW ?
+				    FW_LOG_LEVEL_DEFAULT : FW_LOG_LEVEL_FATAL);
+	adapter->msg_enable = level;
+
+	return;
+}
+
 const struct ethtool_ops be_ethtool_ops = {
 	.get_settings = be_get_settings,
 	.get_drvinfo = be_get_drvinfo,
@@ -893,6 +968,8 @@ const struct ethtool_ops be_ethtool_ops = {
 	.set_pauseparam = be_set_pauseparam,
 	.get_strings = be_get_stat_strings,
 	.set_phys_id = be_set_phys_id,
+	.get_msglevel = be_get_msg_level,
+	.set_msglevel = be_set_msg_level,
 	.get_sset_count = be_get_sset_count,
 	.get_ethtool_stats = be_get_ethtool_stats,
 	.get_regs_len = be_get_reg_len,
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index a01f734..081c777 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3403,9 +3403,43 @@ bool be_is_wol_supported(struct be_adapter *adapter)
 		!be_is_wol_excluded(adapter)) ? true : false;
 }
 
+u32 be_get_fw_log_level(struct be_adapter *adapter)
+{
+	struct be_dma_mem extfat_cmd;
+	struct be_fat_conf_params *cfgs;
+	int status;
+	u32 level = 0;
+	int j;
+
+	memset(&extfat_cmd, 0, sizeof(struct be_dma_mem));
+	extfat_cmd.size = sizeof(struct be_cmd_resp_get_ext_fat_caps);
+	extfat_cmd.va = pci_alloc_consistent(adapter->pdev, extfat_cmd.size,
+					     &extfat_cmd.dma);
+
+	if (!extfat_cmd.va) {
+		dev_err(&adapter->pdev->dev, "%s: Memory allocation failure\n",
+			__func__);
+		goto err;
+	}
+
+	status = be_cmd_get_ext_fat_capabilites(adapter, &extfat_cmd);
+	if (!status) {
+		cfgs = (struct be_fat_conf_params *)(extfat_cmd.va +
+						sizeof(struct be_cmd_resp_hdr));
+		for (j = 0; j < cfgs->module[0].num_modes; j++) {
+			if (cfgs->module[0].trace_lvl[j].mode == MODE_UART)
+				level = cfgs->module[0].trace_lvl[j].dbg_lvl;
+		}
+	}
+	pci_free_consistent(adapter->pdev, extfat_cmd.size, extfat_cmd.va,
+			    extfat_cmd.dma);
+err:
+	return level;
+}
 static int be_get_initial_config(struct be_adapter *adapter)
 {
 	int status;
+	u32 level;
 
 	status = be_cmd_query_fw_cfg(adapter, &adapter->port_num,
 			&adapter->function_mode, &adapter->function_caps);
@@ -3443,6 +3477,9 @@ static int be_get_initial_config(struct be_adapter *adapter)
 	if (be_is_wol_supported(adapter))
 		adapter->wol = true;
 
+	level = be_get_fw_log_level(adapter);
+	adapter->msg_enable = level <= FW_LOG_LEVEL_DEFAULT ? NETIF_MSG_HW : 0;
+
 	return 0;
 }
 
-- 
1.5.6.1
