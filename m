From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 04/12] qlcnic: configure port on eswitch
Date: Thu, 19 Aug 2010 08:08:25 -0700
Message-ID: <1282230513-25286-5-git-send-email-amit.salecha@qlogic.com>
References: <1282230513-25286-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:26143 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752311Ab0HSPIe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Aug 2010 11:08:34 -0400
In-Reply-To: <1282230513-25286-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh Borundia <rajesh.borundia@qlogic.com>

o Nic partition capable devices has embedded switch, this needs to support
various features like external switch.

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h      |   22 +++--
 drivers/net/qlcnic/qlcnic_ctx.c  |  174 ++++++++++++++++++++++++++---------
 drivers/net/qlcnic/qlcnic_hdr.h  |    7 ++
 drivers/net/qlcnic/qlcnic_main.c |  185 +++++++++++++++++++++-----------------
 4 files changed, 254 insertions(+), 134 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index d198367..9433a05 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -556,6 +556,7 @@ struct qlcnic_recv_context {
 #define QLCNIC_CDRP_CMD_GET_ESWITCH_STATUS	0x00000026
 #define QLCNIC_CDRP_CMD_SET_PORTMIRRORING	0x00000027
 #define QLCNIC_CDRP_CMD_CONFIGURE_ESWITCH	0x00000028
+#define QLCNIC_CDRP_CMD_GET_ESWITCH_PORT_CONFIG	0x00000029
 #define QLCNIC_CDRP_CMD_GET_ESWITCH_STATS	0x0000002a
 
 #define QLCNIC_RCODE_SUCCESS		0
@@ -1044,7 +1045,7 @@ struct qlcnic_pci_info {
 };
 
 struct qlcnic_npar_info {
-	u16	vlan_id;
+	u16	pvid;
 	u16	min_bw;
 	u16	max_bw;
 	u8	phy_port;
@@ -1052,11 +1053,13 @@ struct qlcnic_npar_info {
 	u8	active;
 	u8	enable_pm;
 	u8	dest_npar;
-	u8	host_vlan_tag;
-	u8	promisc_mode;
 	u8	discard_tagged;
 	u8	mac_learning;
+	u8	mac_anti_spoof;
+	u8	promisc_mode;
+	u8	offload_flags;
 };
+
 struct qlcnic_eswitch {
 	u8	port;
 	u8	active_vports;
@@ -1088,7 +1091,6 @@ struct qlcnic_eswitch {
 #define IS_VALID_BW(bw)		(bw >= MIN_BW && bw <= MAX_BW)
 #define IS_VALID_TX_QUEUES(que)	(que > 0 && que <= MAX_TX_QUEUES)
 #define IS_VALID_RX_QUEUES(que)	(que > 0 && que <= MAX_RX_QUEUES)
-#define IS_VALID_MODE(mode)	(mode == 0 || mode == 1)
 
 struct qlcnic_pci_func_cfg {
 	u16	func_type;
@@ -1120,12 +1122,16 @@ struct qlcnic_pm_func_cfg {
 
 struct qlcnic_esw_func_cfg {
 	u16	vlan_id;
+	u8	op_mode;
+	u8	op_type;
 	u8	pci_func;
 	u8	host_vlan_tag;
 	u8	promisc_mode;
 	u8	discard_tagged;
 	u8	mac_learning;
-	u8	reserved;
+	u8	mac_anti_spoof;
+	u8	offload_flags;
+	u8	reserved[5];
 };
 
 #define QLCNIC_STATS_VERSION		1
@@ -1276,8 +1282,10 @@ int qlcnic_get_eswitch_capabilities(struct qlcnic_adapter *, u8,
 int qlcnic_get_eswitch_status(struct qlcnic_adapter *, u8,
 				struct qlcnic_eswitch *);
 int qlcnic_toggle_eswitch(struct qlcnic_adapter *, u8, u8);
-int qlcnic_config_switch_port(struct qlcnic_adapter *, u8, int, u8, u8,
-			u8, u8, u16);
+int qlcnic_config_switch_port(struct qlcnic_adapter *,
+				struct qlcnic_esw_func_cfg *);
+int qlcnic_get_eswitch_port_config(struct qlcnic_adapter *,
+				struct qlcnic_esw_func_cfg *);
 int qlcnic_config_port_mirroring(struct qlcnic_adapter *, u8, u8, u8);
 int qlcnic_get_port_stats(struct qlcnic_adapter *, const u8, const u8,
 					struct __qlcnic_esw_statistics *);
diff --git a/drivers/net/qlcnic/qlcnic_ctx.c b/drivers/net/qlcnic/qlcnic_ctx.c
index 57c9b09..74ae3b0 100644
--- a/drivers/net/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/qlcnic/qlcnic_ctx.c
@@ -813,9 +813,8 @@ int qlcnic_get_eswitch_capabilities(struct qlcnic_adapter *adapter, u8 port,
 		arg2 = QLCRD32(adapter, QLCNIC_ARG2_CRB_OFFSET);
 
 		eswitch->port = arg1 & 0xf;
-		eswitch->active_vports = LSB(arg2);
-		eswitch->max_ucast_filters = MSB(arg2);
-		eswitch->max_active_vlans = LSB(MSW(arg2));
+		eswitch->max_ucast_filters = LSW(arg2);
+		eswitch->max_active_vlans = MSW(arg2) & 0xfff;
 		if (arg1 & BIT_6)
 			eswitch->flags |= QLCNIC_SWITCH_VLAN_FILTERING;
 		if (arg1 & BIT_7)
@@ -943,47 +942,6 @@ int qlcnic_config_port_mirroring(struct qlcnic_adapter *adapter, u8 id,
 	return err;
 }
 
-/* Configure eSwitch port */
-int qlcnic_config_switch_port(struct qlcnic_adapter *adapter, u8 id,
-		int vlan_tagging, u8 discard_tagged, u8 promsc_mode,
-		u8 mac_learn, u8 pci_func, u16 vlan_id)
-{
-	int err = -EIO;
-	u32 arg1;
-	struct qlcnic_eswitch *eswitch;
-
-	if (adapter->op_mode != QLCNIC_MGMT_FUNC)
-		return err;
-
-	eswitch = &adapter->eswitch[id];
-	if (!(eswitch->flags & QLCNIC_SWITCH_ENABLE))
-		return err;
-
-	arg1 = eswitch->port | (discard_tagged ? BIT_4 : 0);
-	arg1 |= (promsc_mode ? BIT_6 : 0) | (mac_learn ? BIT_7 : 0);
-	arg1 |= pci_func << 8;
-	if (vlan_tagging)
-		arg1 |= BIT_5 | (vlan_id << 16);
-
-	err = qlcnic_issue_cmd(adapter,
-			adapter->ahw.pci_func,
-			adapter->fw_hal_version,
-			arg1,
-			0,
-			0,
-			QLCNIC_CDRP_CMD_CONFIGURE_ESWITCH);
-
-	if (err != QLCNIC_RCODE_SUCCESS) {
-		dev_err(&adapter->pdev->dev,
-			"Failed to configure eswitch port%d\n", eswitch->port);
-	} else {
-		dev_info(&adapter->pdev->dev,
-			"Configured eSwitch for port %d\n", eswitch->port);
-	}
-
-	return err;
-}
-
 int qlcnic_get_port_stats(struct qlcnic_adapter *adapter, const u8 func,
 		const u8 rx_tx, struct __qlcnic_esw_statistics *esw_stats) {
 
@@ -1108,3 +1066,131 @@ err_ret:
 		"rx_ctx=%d\n", func_esw, port, rx_tx);
 	return -EIO;
 }
+
+static int
+__qlcnic_get_eswitch_port_config(struct qlcnic_adapter *adapter,
+					u32 *arg1, u32 *arg2)
+{
+	int err = -EIO;
+	u8 pci_func;
+	pci_func = (*arg1 >> 8);
+	err = qlcnic_issue_cmd(adapter,
+			adapter->ahw.pci_func,
+			adapter->fw_hal_version,
+			*arg1,
+			0,
+			0,
+			QLCNIC_CDRP_CMD_GET_ESWITCH_PORT_CONFIG);
+
+	if (err == QLCNIC_RCODE_SUCCESS) {
+		*arg1 = QLCRD32(adapter, QLCNIC_ARG1_CRB_OFFSET);
+		*arg2 = QLCRD32(adapter, QLCNIC_ARG2_CRB_OFFSET);
+		dev_info(&adapter->pdev->dev,
+			"eSwitch port config for pci func%d\n",	pci_func);
+	} else {
+		dev_err(&adapter->pdev->dev,
+			"Failed to get eswitch port config%d\n", pci_func);
+	}
+	return err;
+}
+/* Configure eSwitch port
+op_mode = 0 for setting default port behavior
+op_mode = 1 for setting  vlan id
+op_mode = 2 for deleting vlan id
+op_type = 0 for vlan_id
+op_type = 1 for port vlan_id
+*/
+int qlcnic_config_switch_port(struct qlcnic_adapter *adapter,
+		struct qlcnic_esw_func_cfg *esw_cfg)
+{
+	int err = -EIO;
+	u32 arg1, arg2 = 0;
+	u8 pci_func;
+
+	if (adapter->op_mode != QLCNIC_MGMT_FUNC)
+		return err;
+	pci_func = esw_cfg->pci_func;
+	arg1 = (adapter->npars[pci_func].phy_port & BIT_0);
+	arg1 |= (pci_func << 8);
+
+	if (__qlcnic_get_eswitch_port_config(adapter, &arg1, &arg2))
+		return err;
+	arg1 &= ~(0x0ff << 8);
+	arg1 |= (pci_func << 8);
+	arg1 &= ~(BIT_2 | BIT_3);
+	switch (esw_cfg->op_mode) {
+	case QLCNIC_PORT_DEFAULTS:
+		arg1 |= (BIT_4 | BIT_6 | BIT_7);
+		arg2 |= (BIT_0 | BIT_1);
+		if (adapter->capabilities & QLCNIC_FW_CAPABILITY_TSO)
+			arg2 |= (BIT_2 | BIT_3);
+		if (!(esw_cfg->discard_tagged))
+			arg1 &= ~BIT_4;
+		if (!(esw_cfg->promisc_mode))
+			arg1 &= ~BIT_6;
+		if (!(esw_cfg->mac_learning))
+			arg1 &= ~BIT_7;
+		if (!(esw_cfg->mac_anti_spoof))
+			arg2 &= ~BIT_0;
+		if (!(esw_cfg->offload_flags & BIT_0))
+			arg2 &= ~(BIT_1 | BIT_2 | BIT_3);
+		if (!(esw_cfg->offload_flags & BIT_1))
+			arg2 &= ~BIT_2;
+		if (!(esw_cfg->offload_flags & BIT_2))
+			arg2 &= ~BIT_3;
+		break;
+	case QLCNIC_ADD_VLAN:
+			arg1 |= (BIT_2 | BIT_5);
+			arg1 |= (esw_cfg->vlan_id << 16);
+			break;
+	case QLCNIC_DEL_VLAN:
+			arg1 |= (BIT_3 | BIT_5);
+			arg1 &= ~(0x0ffff << 16);
+	default:
+		return err;
+	}
+
+	err = qlcnic_issue_cmd(adapter,
+			adapter->ahw.pci_func,
+			adapter->fw_hal_version,
+			arg1,
+			arg2,
+			0,
+			QLCNIC_CDRP_CMD_CONFIGURE_ESWITCH);
+
+	if (err != QLCNIC_RCODE_SUCCESS) {
+		dev_err(&adapter->pdev->dev,
+			"Failed to configure eswitch port%d\n", pci_func);
+	} else {
+		dev_info(&adapter->pdev->dev,
+			"Configured eSwitch for port %d\n", pci_func);
+	}
+
+	return err;
+}
+
+int
+qlcnic_get_eswitch_port_config(struct qlcnic_adapter *adapter,
+			struct qlcnic_esw_func_cfg *esw_cfg)
+{
+	u32 arg1, arg2;
+	u8 phy_port;
+	if (adapter->op_mode == QLCNIC_MGMT_FUNC)
+		phy_port = adapter->npars[esw_cfg->pci_func].phy_port;
+	else
+		phy_port = adapter->physical_port;
+	arg1 = phy_port;
+	arg1 |= (esw_cfg->pci_func << 8);
+	if (__qlcnic_get_eswitch_port_config(adapter, &arg1, &arg2))
+		return -EIO;
+
+	esw_cfg->discard_tagged = !!(arg1 & BIT_4);
+	esw_cfg->host_vlan_tag = !!(arg1 & BIT_5);
+	esw_cfg->promisc_mode = !!(arg1 & BIT_6);
+	esw_cfg->mac_learning = !!(arg1 & BIT_7);
+	esw_cfg->vlan_id = LSW(arg1 >> 16);
+	esw_cfg->mac_anti_spoof = (arg2 & 0x1);
+	esw_cfg->offload_flags = ((arg2 >> 1) & 0x7);
+
+	return 0;
+}
diff --git a/drivers/net/qlcnic/qlcnic_hdr.h b/drivers/net/qlcnic/qlcnic_hdr.h
index 39db4df..eae03b5 100644
--- a/drivers/net/qlcnic/qlcnic_hdr.h
+++ b/drivers/net/qlcnic/qlcnic_hdr.h
@@ -775,6 +775,7 @@ struct qlcnic_legacy_intr_set {
 #define QLCNIC_DRV_OP_MODE	0x1b2170
 #define QLCNIC_MSIX_BASE	0x132110
 #define QLCNIC_MAX_PCI_FUNC	8
+#define QLCNIC_MAX_VLAN_FILTERS	64
 
 /* PCI function operational mode */
 enum {
@@ -783,6 +784,12 @@ enum {
 	QLCNIC_NON_PRIV_FUNC	= 2
 };
 
+enum {
+	QLCNIC_PORT_DEFAULTS	= 0,
+	QLCNIC_ADD_VLAN	= 1,
+	QLCNIC_DEL_VLAN	= 2
+};
+
 #define QLC_DEV_DRV_DEFAULT 0x11111111
 
 #define LSB(x)	((uint8_t)(x))
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index c6f19c9..7bb3285 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -506,7 +506,6 @@ qlcnic_init_pci_info(struct qlcnic_adapter *adapter)
 		adapter->npars[pfn].active = pci_info[i].active;
 		adapter->npars[pfn].type = pci_info[i].type;
 		adapter->npars[pfn].phy_port = pci_info[i].default_port;
-		adapter->npars[pfn].mac_learning = DEFAULT_MAC_LEARN;
 		adapter->npars[pfn].min_bw = pci_info[i].tx_min_bw;
 		adapter->npars[pfn].max_bw = pci_info[i].tx_max_bw;
 	}
@@ -758,47 +757,64 @@ qlcnic_check_options(struct qlcnic_adapter *adapter)
 }
 
 static int
+qlcnic_reset_eswitch_config(struct qlcnic_adapter *adapter,
+			struct qlcnic_npar_info *npar, int pci_func)
+{
+	struct qlcnic_esw_func_cfg esw_cfg;
+	esw_cfg.op_mode = QLCNIC_PORT_DEFAULTS;
+	esw_cfg.pci_func = pci_func;
+	esw_cfg.vlan_id = npar->pvid;
+	esw_cfg.mac_learning = npar->mac_learning;
+	esw_cfg.discard_tagged = npar->discard_tagged;
+	esw_cfg.mac_anti_spoof = npar->mac_anti_spoof;
+	esw_cfg.offload_flags = npar->offload_flags;
+	esw_cfg.promisc_mode = npar->promisc_mode;
+	if (qlcnic_config_switch_port(adapter, &esw_cfg))
+		return -EIO;
+
+	esw_cfg.op_mode = QLCNIC_ADD_VLAN;
+	if (qlcnic_config_switch_port(adapter, &esw_cfg))
+		return -EIO;
+
+	return 0;
+}
+
+static int
 qlcnic_reset_npar_config(struct qlcnic_adapter *adapter)
 {
-	int i, err = 0;
+	int i, err;
 	struct qlcnic_npar_info *npar;
 	struct qlcnic_info nic_info;
 
 	if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED) ||
-	    !adapter->need_fw_reset)
+	    !adapter->need_fw_reset || adapter->op_mode != QLCNIC_MGMT_FUNC)
 		return 0;
 
-	if (adapter->op_mode == QLCNIC_MGMT_FUNC) {
-		/* Set the NPAR config data after FW reset */
-		for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++) {
-			npar = &adapter->npars[i];
-			if (npar->type != QLCNIC_TYPE_NIC)
-				continue;
-			err = qlcnic_get_nic_info(adapter, &nic_info, i);
-			if (err)
-				goto err_out;
-			nic_info.min_tx_bw = npar->min_bw;
-			nic_info.max_tx_bw = npar->max_bw;
-			err = qlcnic_set_nic_info(adapter, &nic_info);
-			if (err)
-				goto err_out;
-
-			if (npar->enable_pm) {
-				err = qlcnic_config_port_mirroring(adapter,
-						npar->dest_npar, 1, i);
-				if (err)
-					goto err_out;
+	/* Set the NPAR config data after FW reset */
+	for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++) {
+		npar = &adapter->npars[i];
+		if (npar->type != QLCNIC_TYPE_NIC)
+			continue;
+		err = qlcnic_get_nic_info(adapter, &nic_info, i);
+		if (err)
+			return err;
+		nic_info.min_tx_bw = npar->min_bw;
+		nic_info.max_tx_bw = npar->max_bw;
+		err = qlcnic_set_nic_info(adapter, &nic_info);
+		if (err)
+			return err;
 
-			}
-			npar->mac_learning = DEFAULT_MAC_LEARN;
-			npar->host_vlan_tag = 0;
-			npar->promisc_mode = 0;
-			npar->discard_tagged = 0;
-			npar->vlan_id = 0;
+		if (npar->enable_pm) {
+			err = qlcnic_config_port_mirroring(adapter,
+							npar->dest_npar, 1, i);
+			if (err)
+				return err;
 		}
+		err = qlcnic_reset_eswitch_config(adapter, npar, i);
+		if (err)
+			return err;
 	}
-err_out:
-	return err;
+	return 0;
 }
 
 static int
@@ -863,12 +879,10 @@ wait_init:
 
 	QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_READY);
 	qlcnic_idc_debug_info(adapter, 1);
-
-	qlcnic_check_options(adapter);
 	if (qlcnic_reset_npar_config(adapter))
 		goto err_out;
 	qlcnic_dev_set_npar_ready(adapter);
-
+	qlcnic_check_options(adapter);
 	adapter->need_fw_reset = 0;
 
 	qlcnic_release_firmware(adapter);
@@ -3082,9 +3096,6 @@ validate_pm_config(struct qlcnic_adapter *adapter,
 		if (adapter->npars[dest_pci_func].type != QLCNIC_TYPE_NIC)
 			return QL_STATUS_INVALID_PARAM;
 
-		if (!IS_VALID_MODE(pm_cfg[i].action))
-			return QL_STATUS_INVALID_PARAM;
-
 		s_esw_id = adapter->npars[src_pci_func].phy_port;
 		d_esw_id = adapter->npars[dest_pci_func].phy_port;
 
@@ -3118,7 +3129,7 @@ qlcnic_sysfs_write_pm_config(struct file *filp, struct kobject *kobj,
 		return ret;
 	for (i = 0; i < count; i++) {
 		pci_func = pm_cfg[i].pci_func;
-		action = pm_cfg[i].action;
+		action = !!pm_cfg[i].action;
 		id = adapter->npars[pci_func].phy_port;
 		ret = qlcnic_config_port_mirroring(adapter, id,
 						action, pci_func);
@@ -3129,7 +3140,7 @@ qlcnic_sysfs_write_pm_config(struct file *filp, struct kobject *kobj,
 	for (i = 0; i < count; i++) {
 		pci_func = pm_cfg[i].pci_func;
 		id = adapter->npars[pci_func].phy_port;
-		adapter->npars[pci_func].enable_pm = pm_cfg[i].action;
+		adapter->npars[pci_func].enable_pm = !!pm_cfg[i].action;
 		adapter->npars[pci_func].dest_npar = id;
 	}
 	return size;
@@ -3161,30 +3172,38 @@ qlcnic_sysfs_read_pm_config(struct file *filp, struct kobject *kobj,
 
 static int
 validate_esw_config(struct qlcnic_adapter *adapter,
-			struct qlcnic_esw_func_cfg *esw_cfg, int count)
+	struct qlcnic_esw_func_cfg *esw_cfg, int count)
 {
 	u8 pci_func;
 	int i;
-
 	for (i = 0; i < count; i++) {
 		pci_func = esw_cfg[i].pci_func;
 		if (pci_func >= QLCNIC_MAX_PCI_FUNC)
 			return QL_STATUS_INVALID_PARAM;
 
-		if (adapter->npars[i].type != QLCNIC_TYPE_NIC)
-			return QL_STATUS_INVALID_PARAM;
+		if (adapter->op_mode == QLCNIC_MGMT_FUNC)
+			if (adapter->npars[pci_func].type != QLCNIC_TYPE_NIC)
+				return QL_STATUS_INVALID_PARAM;
 
-		if (esw_cfg->host_vlan_tag == 1)
+		switch (esw_cfg[i].op_mode) {
+		case QLCNIC_PORT_DEFAULTS:
+			break;
+		case QLCNIC_ADD_VLAN:
 			if (!IS_VALID_VLAN(esw_cfg[i].vlan_id))
 				return QL_STATUS_INVALID_PARAM;
-
-		if (!IS_VALID_MODE(esw_cfg[i].promisc_mode)
-				|| !IS_VALID_MODE(esw_cfg[i].host_vlan_tag)
-				|| !IS_VALID_MODE(esw_cfg[i].mac_learning)
-				|| !IS_VALID_MODE(esw_cfg[i].discard_tagged))
+			if (!esw_cfg[i].op_type)
+				return QL_STATUS_INVALID_PARAM;
+			break;
+		case QLCNIC_DEL_VLAN:
+			if (!IS_VALID_VLAN(esw_cfg[i].vlan_id))
+				return QL_STATUS_INVALID_PARAM;
+			if (!esw_cfg[i].op_type)
+				return QL_STATUS_INVALID_PARAM;
+			break;
+		default:
 			return QL_STATUS_INVALID_PARAM;
+		}
 	}
-
 	return 0;
 }
 
@@ -3195,8 +3214,9 @@ qlcnic_sysfs_write_esw_config(struct file *file, struct kobject *kobj,
 	struct device *dev = container_of(kobj, struct device, kobj);
 	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
 	struct qlcnic_esw_func_cfg *esw_cfg;
+	struct qlcnic_npar_info *npar;
 	int count, rem, i, ret;
-	u8 id, pci_func;
+	u8 pci_func;
 
 	count	= size / sizeof(struct qlcnic_esw_func_cfg);
 	rem	= size % sizeof(struct qlcnic_esw_func_cfg);
@@ -3209,28 +3229,28 @@ qlcnic_sysfs_write_esw_config(struct file *file, struct kobject *kobj,
 		return ret;
 
 	for (i = 0; i < count; i++) {
-		pci_func = esw_cfg[i].pci_func;
-		id = adapter->npars[pci_func].phy_port;
-		ret = qlcnic_config_switch_port(adapter, id,
-						esw_cfg[i].host_vlan_tag,
-						esw_cfg[i].discard_tagged,
-						esw_cfg[i].promisc_mode,
-						esw_cfg[i].mac_learning,
-						esw_cfg[i].pci_func,
-						esw_cfg[i].vlan_id);
-		if (ret)
-			return ret;
+		if (qlcnic_config_switch_port(adapter, &esw_cfg[i]))
+			return QL_STATUS_INVALID_PARAM;
 	}
 
 	for (i = 0; i < count; i++) {
 		pci_func = esw_cfg[i].pci_func;
-		adapter->npars[pci_func].promisc_mode = esw_cfg[i].promisc_mode;
-		adapter->npars[pci_func].mac_learning =	esw_cfg[i].mac_learning;
-		adapter->npars[pci_func].vlan_id = esw_cfg[i].vlan_id;
-		adapter->npars[pci_func].discard_tagged	=
-						esw_cfg[i].discard_tagged;
-		adapter->npars[pci_func].host_vlan_tag =
-						esw_cfg[i].host_vlan_tag;
+		npar = &adapter->npars[pci_func];
+		switch (esw_cfg[i].op_mode) {
+		case QLCNIC_PORT_DEFAULTS:
+			npar->promisc_mode = esw_cfg[i].promisc_mode;
+			npar->mac_learning = esw_cfg[i].mac_learning;
+			npar->offload_flags = esw_cfg[i].offload_flags;
+			npar->mac_anti_spoof = esw_cfg[i].mac_anti_spoof;
+			npar->discard_tagged = esw_cfg[i].discard_tagged;
+			break;
+		case QLCNIC_ADD_VLAN:
+			npar->pvid = esw_cfg[i].vlan_id;
+			break;
+		case QLCNIC_DEL_VLAN:
+			npar->pvid = 0;
+			break;
+		}
 	}
 
 	return size;
@@ -3243,7 +3263,7 @@ qlcnic_sysfs_read_esw_config(struct file *file, struct kobject *kobj,
 	struct device *dev = container_of(kobj, struct device, kobj);
 	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
 	struct qlcnic_esw_func_cfg esw_cfg[QLCNIC_MAX_PCI_FUNC];
-	int i;
+	u8 i;
 
 	if (size != sizeof(esw_cfg))
 		return QL_STATUS_INVALID_PARAM;
@@ -3251,12 +3271,9 @@ qlcnic_sysfs_read_esw_config(struct file *file, struct kobject *kobj,
 	for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++) {
 		if (adapter->npars[i].type != QLCNIC_TYPE_NIC)
 			continue;
-
-		esw_cfg[i].host_vlan_tag = adapter->npars[i].host_vlan_tag;
-		esw_cfg[i].promisc_mode = adapter->npars[i].promisc_mode;
-		esw_cfg[i].discard_tagged = adapter->npars[i].discard_tagged;
-		esw_cfg[i].vlan_id = adapter->npars[i].vlan_id;
-		esw_cfg[i].mac_learning = adapter->npars[i].mac_learning;
+		esw_cfg[i].pci_func = i;
+		if (qlcnic_get_eswitch_port_config(adapter, &esw_cfg[i]))
+			return QL_STATUS_INVALID_PARAM;
 	}
 	memcpy(buf, &esw_cfg, size);
 
@@ -3580,15 +3597,16 @@ qlcnic_create_diag_entries(struct qlcnic_adapter *adapter)
 		dev_info(dev, "failed to create crb sysfs entry\n");
 	if (device_create_bin_file(dev, &bin_attr_mem))
 		dev_info(dev, "failed to create mem sysfs entry\n");
-	if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED) ||
-			adapter->op_mode != QLCNIC_MGMT_FUNC)
+	if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED))
+		return;
+	if (device_create_bin_file(dev, &bin_attr_esw_config))
+		dev_info(dev, "failed to create esw config sysfs entry");
+	if (adapter->op_mode != QLCNIC_MGMT_FUNC)
 		return;
 	if (device_create_bin_file(dev, &bin_attr_pci_config))
 		dev_info(dev, "failed to create pci config sysfs entry");
 	if (device_create_bin_file(dev, &bin_attr_npar_config))
 		dev_info(dev, "failed to create npar config sysfs entry");
-	if (device_create_bin_file(dev, &bin_attr_esw_config))
-		dev_info(dev, "failed to create esw config sysfs entry");
 	if (device_create_bin_file(dev, &bin_attr_pm_config))
 		dev_info(dev, "failed to create pm config sysfs entry");
 	if (device_create_bin_file(dev, &bin_attr_esw_stats))
@@ -3607,12 +3625,13 @@ qlcnic_remove_diag_entries(struct qlcnic_adapter *adapter)
 	device_remove_file(dev, &dev_attr_diag_mode);
 	device_remove_bin_file(dev, &bin_attr_crb);
 	device_remove_bin_file(dev, &bin_attr_mem);
-	if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED) ||
-			adapter->op_mode != QLCNIC_MGMT_FUNC)
+	if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED))
+		return;
+	device_remove_bin_file(dev, &bin_attr_esw_config);
+	if (adapter->op_mode != QLCNIC_MGMT_FUNC)
 		return;
 	device_remove_bin_file(dev, &bin_attr_pci_config);
 	device_remove_bin_file(dev, &bin_attr_npar_config);
-	device_remove_bin_file(dev, &bin_attr_esw_config);
 	device_remove_bin_file(dev, &bin_attr_pm_config);
 	device_remove_bin_file(dev, &bin_attr_esw_stats);
 }
-- 
1.6.0.2

