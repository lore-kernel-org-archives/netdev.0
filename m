From: amit.salecha@qlogic.com
Subject: [PATCHv2 NEXT 5/5] qlcnic: restore NPAR config data after recovery
Date: Tue, 13 Jul 2010 22:54:53 -0700
Message-ID: <1279086893-22523-6-git-send-email-amit.salecha@qlogic.com>
References: <1279086893-22523-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	Amit Kumar Salecha <amit.salecha@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:36098 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751507Ab0GNFyy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jul 2010 01:54:54 -0400
In-Reply-To: <1279086893-22523-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>

o NPAR configuration which is programmed in fw, need to
  restore after fw recovery.
o Update version to 5.0.7

Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h      |    7 ++-
 drivers/net/qlcnic/qlcnic_ctx.c  |    2 +
 drivers/net/qlcnic/qlcnic_main.c |   86 +++++++++++++++++++++++++++++---------
 3 files changed, 72 insertions(+), 23 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 0644642..e189477 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -51,8 +51,8 @@
 
 #define _QLCNIC_LINUX_MAJOR 5
 #define _QLCNIC_LINUX_MINOR 0
-#define _QLCNIC_LINUX_SUBVERSION 6
-#define QLCNIC_LINUX_VERSIONID  "5.0.6"
+#define _QLCNIC_LINUX_SUBVERSION 7
+#define QLCNIC_LINUX_VERSIONID  "5.0.7"
 #define QLCNIC_DRV_IDC_VER  0x01
 
 #define QLCNIC_VERSION_CODE(a, b, c)	(((a) << 24) + ((b) << 16) + (c))
@@ -949,7 +949,6 @@ struct qlcnic_adapter {
 	u8 has_link_events;
 	u8 fw_type;
 	u16 tx_context_id;
-	u16 mtu;
 	u16 is_up;
 
 	u16 link_speed;
@@ -1044,6 +1043,8 @@ struct qlcnic_pci_info {
 
 struct qlcnic_npar_info {
 	u16	vlan_id;
+	u16	min_bw;
+	u16	max_bw;
 	u8	phy_port;
 	u8	type;
 	u8	active;
diff --git a/drivers/net/qlcnic/qlcnic_ctx.c b/drivers/net/qlcnic/qlcnic_ctx.c
index cdd44b4..cc5d861 100644
--- a/drivers/net/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/qlcnic/qlcnic_ctx.c
@@ -636,6 +636,8 @@ int qlcnic_get_nic_info(struct qlcnic_adapter *adapter,
 			QLCNIC_CDRP_CMD_GET_NIC_INFO);
 
 	if (err == QLCNIC_RCODE_SUCCESS) {
+		npar_info->pci_func = le16_to_cpu(nic_info->pci_func);
+		npar_info->op_mode = le16_to_cpu(nic_info->op_mode);
 		npar_info->phys_port = le16_to_cpu(nic_info->phys_port);
 		npar_info->switch_mode = le16_to_cpu(nic_info->switch_mode);
 		npar_info->max_tx_ques = le16_to_cpu(nic_info->max_tx_ques);
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 462cb6b..dc0b22b 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -507,6 +507,8 @@ qlcnic_init_pci_info(struct qlcnic_adapter *adapter)
 			adapter->npars[pfn].type = pci_info[i].type;
 			adapter->npars[pfn].phy_port = pci_info[i].default_port;
 			adapter->npars[pfn].mac_learning = DEFAULT_MAC_LEARN;
+			adapter->npars[pfn].min_bw = pci_info[i].tx_min_bw;
+			adapter->npars[pfn].max_bw = pci_info[i].tx_max_bw;
 		}
 
 		for (i = 0; i < QLCNIC_NIU_MAX_XG_PORTS; i++)
@@ -771,6 +773,50 @@ qlcnic_check_options(struct qlcnic_adapter *adapter)
 }
 
 static int
+qlcnic_reset_npar_config(struct qlcnic_adapter *adapter)
+{
+	int i, err = 0;
+	struct qlcnic_npar_info *npar;
+	struct qlcnic_info nic_info;
+
+	if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED)
+				|| !adapter->need_fw_reset)
+		return 0;
+
+	if (adapter->op_mode == QLCNIC_MGMT_FUNC) {
+		/* Set the NPAR config data after FW reset */
+		for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++) {
+			npar = &adapter->npars[i];
+			if (npar->type != QLCNIC_TYPE_NIC)
+				continue;
+			err = qlcnic_get_nic_info(adapter, &nic_info, i);
+			if (err)
+				goto err_out;
+			nic_info.min_tx_bw = npar->min_bw;
+			nic_info.max_tx_bw = npar->max_bw;
+			err = qlcnic_set_nic_info(adapter, &nic_info);
+			if (err)
+				goto err_out;
+
+			if (npar->enable_pm) {
+				err = qlcnic_config_port_mirroring(adapter,
+						npar->dest_npar, 1, i);
+				if (err)
+					goto err_out;
+
+			}
+			npar->mac_learning = DEFAULT_MAC_LEARN;
+			npar->host_vlan_tag = 0;
+			npar->promisc_mode = 0;
+			npar->discard_tagged = 0;
+			npar->vlan_id = 0;
+		}
+	}
+err_out:
+	return err;
+}
+
+static int
 qlcnic_start_firmware(struct qlcnic_adapter *adapter)
 {
 	int val, err, first_boot;
@@ -834,10 +880,9 @@ wait_init:
 	qlcnic_idc_debug_info(adapter, 1);
 
 	qlcnic_check_options(adapter);
-
-	if (adapter->flags & QLCNIC_ESWITCH_ENABLED &&
-		adapter->op_mode != QLCNIC_NON_PRIV_FUNC)
-		qlcnic_dev_set_npar_ready(adapter);
+	if (qlcnic_reset_npar_config(adapter))
+		goto err_out;
+	qlcnic_dev_set_npar_ready(adapter);
 
 	adapter->need_fw_reset = 0;
 
@@ -2486,6 +2531,7 @@ qlcnic_dev_request_reset(struct qlcnic_adapter *adapter)
 {
 	u32 state;
 
+	adapter->need_fw_reset = 1;
 	if (qlcnic_api_lock(adapter))
 		return;
 
@@ -2506,6 +2552,9 @@ qlcnic_dev_set_npar_ready(struct qlcnic_adapter *adapter)
 {
 	u32 state;
 
+	if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED) ||
+		adapter->op_mode == QLCNIC_NON_PRIV_FUNC)
+		return;
 	if (qlcnic_api_lock(adapter))
 		return;
 
@@ -3019,7 +3068,7 @@ static struct bin_attribute bin_attr_mem = {
 	.write = qlcnic_sysfs_write_mem,
 };
 
-int
+static int
 validate_pm_config(struct qlcnic_adapter *adapter,
 			struct qlcnic_pm_func_cfg *pm_cfg, int count)
 {
@@ -3118,7 +3167,7 @@ qlcnic_sysfs_read_pm_config(struct file *filp, struct kobject *kobj,
 	return size;
 }
 
-int
+static int
 validate_esw_config(struct qlcnic_adapter *adapter,
 			struct qlcnic_esw_func_cfg *esw_cfg, int count)
 {
@@ -3154,9 +3203,8 @@ qlcnic_sysfs_write_esw_config(struct file *file, struct kobject *kobj,
 	struct device *dev = container_of(kobj, struct device, kobj);
 	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
 	struct qlcnic_esw_func_cfg *esw_cfg;
-	u8 id, discard_tagged, promsc_mode, mac_learn;
-	u8 vlan_tagging, pci_func, vlan_id;
 	int count, rem, i, ret;
+	u8 id, pci_func;
 
 	count	= size / sizeof(struct qlcnic_esw_func_cfg);
 	rem	= size % sizeof(struct qlcnic_esw_func_cfg);
@@ -3171,17 +3219,13 @@ qlcnic_sysfs_write_esw_config(struct file *file, struct kobject *kobj,
 	for (i = 0; i < count; i++) {
 		pci_func = esw_cfg[i].pci_func;
 		id = adapter->npars[pci_func].phy_port;
-		vlan_tagging = esw_cfg[i].host_vlan_tag;
-		promsc_mode = esw_cfg[i].promisc_mode;
-		mac_learn = esw_cfg[i].mac_learning;
-		vlan_id	= esw_cfg[i].vlan_id;
-		discard_tagged = esw_cfg[i].discard_tagged;
-		ret = qlcnic_config_switch_port(adapter, id, vlan_tagging,
-						discard_tagged,
-						promsc_mode,
-						mac_learn,
-						pci_func,
-						vlan_id);
+		ret = qlcnic_config_switch_port(adapter, id,
+						esw_cfg[i].host_vlan_tag,
+						esw_cfg[i].discard_tagged,
+						esw_cfg[i].promisc_mode,
+						esw_cfg[i].mac_learning,
+						esw_cfg[i].pci_func,
+						esw_cfg[i].vlan_id);
 		if (ret)
 			return ret;
 	}
@@ -3227,7 +3271,7 @@ qlcnic_sysfs_read_esw_config(struct file *file, struct kobject *kobj,
 	return size;
 }
 
-int
+static int
 validate_npar_config(struct qlcnic_adapter *adapter,
 				struct qlcnic_npar_func_cfg *np_cfg, int count)
 {
@@ -3282,6 +3326,8 @@ qlcnic_sysfs_write_npar_config(struct file *file, struct kobject *kobj,
 		ret = qlcnic_set_nic_info(adapter, &nic_info);
 		if (ret)
 			return ret;
+		adapter->npars[i].min_bw = nic_info.min_tx_bw;
+		adapter->npars[i].max_bw = nic_info.max_tx_bw;
 	}
 
 	return size;
-- 
1.6.0.2

