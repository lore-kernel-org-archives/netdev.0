From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH V6 09/22] qlcnic: update NIC partition interface routines
Date: Mon,  5 Nov 2012 17:12:03 -0500
Message-ID: <1352153535-5006-10-git-send-email-sony.chacko@qlogic.com>
References: <1352153535-5006-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:60709 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S933348Ab2KEWbn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Nov 2012 17:31:43 -0500
In-Reply-To: <1352153535-5006-1-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Refactor 82xx driver to support new adapter - Qlogic 83XX CNA
Update routines to support variable number of NIC partitions

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Sritej Velaga <sritej.velaga@qlogic.com>
Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h      |    3 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c  |   38 +++++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |  144 +++++++++++++++-------
 3 files changed, 136 insertions(+), 49 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index f5ddd03..056a2c6 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -482,6 +482,7 @@ struct qlcnic_hardware_context {
 	u16 max_rx_ques;
 	u16 max_mtu;
 	u16 msg_enable;
+	u16 act_pci_func;
 
 	u32 capabilities;
 	u32 temp;
@@ -1120,6 +1121,7 @@ struct qlcnic_npar_info {
 	u8	mac_anti_spoof;
 	u8	promisc_mode;
 	u8	offload_flags;
+	u8      pci_func;
 };
 
 struct qlcnic_eswitch {
@@ -1547,6 +1549,7 @@ int qlcnic_get_port_stats(struct qlcnic_adapter *, const u8, const u8,
 					struct __qlcnic_esw_statistics *);
 int qlcnic_get_eswitch_stats(struct qlcnic_adapter *, const u8, u8,
 					struct __qlcnic_esw_statistics *);
+int qlcnic_is_valid_nic_func(struct qlcnic_adapter *, u8);
 int qlcnic_clear_esw_stats(struct qlcnic_adapter *adapter, u8, u8, u8);
 int qlcnic_get_mac_stats(struct qlcnic_adapter *, struct qlcnic_mac_statistics *);
 void qlcnic_free_mbx_args(struct qlcnic_cmd_args *cmd);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
index f9aeefe..2f873cb 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
@@ -688,6 +688,17 @@ int qlcnic_82xx_get_nic_info(struct qlcnic_adapter *adapter,
 		dev_err(&adapter->pdev->dev,
 			"Failed to get nic info%d\n", err);
 		err = -EIO;
+	} else {
+		npar_info->pci_func = le16_to_cpu(nic_info->pci_func);
+		npar_info->op_mode = le16_to_cpu(nic_info->op_mode);
+		npar_info->min_tx_bw = le16_to_cpu(nic_info->min_tx_bw);
+		npar_info->max_tx_bw = le16_to_cpu(nic_info->max_tx_bw);
+		npar_info->phys_port = le16_to_cpu(nic_info->phys_port);
+		npar_info->switch_mode = le16_to_cpu(nic_info->switch_mode);
+		npar_info->max_tx_ques = le16_to_cpu(nic_info->max_tx_ques);
+		npar_info->max_rx_ques = le16_to_cpu(nic_info->max_rx_ques);
+		npar_info->capabilities = le32_to_cpu(nic_info->capabilities);
+		npar_info->max_mtu = le16_to_cpu(nic_info->max_mtu);
 	}
 
 	dma_free_coherent(&adapter->pdev->dev, nic_size, nic_info_addr,
@@ -774,11 +785,14 @@ int qlcnic_82xx_get_pci_info(struct qlcnic_adapter *adapter,
 	cmd.req.arg[3] = pci_size;
 	err = qlcnic_issue_cmd(adapter, &cmd);
 
+	adapter->ahw->act_pci_func = 0;
 	if (err == QLCNIC_RCODE_SUCCESS) {
 		for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++, npar++, pci_info++) {
 			pci_info->id = le16_to_cpu(npar->id);
 			pci_info->active = le16_to_cpu(npar->active);
 			pci_info->type = le16_to_cpu(npar->type);
+			if (pci_info->type == QLCNIC_TYPE_NIC)
+				adapter->ahw->act_pci_func++;
 			pci_info->default_port =
 				le16_to_cpu(npar->default_port);
 			pci_info->tx_min_bw =
@@ -978,12 +992,13 @@ int qlcnic_get_eswitch_stats(struct qlcnic_adapter *adapter, const u8 eswitch,
 	esw_stats->numbytes = QLCNIC_STATS_NOT_AVAIL;
 	esw_stats->context_id = eswitch;
 
-	for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++) {
+	for (i = 0; i < adapter->ahw->act_pci_func; i++) {
 		if (adapter->npars[i].phy_port != eswitch)
 			continue;
 
 		memset(&port_stats, 0, sizeof(struct __qlcnic_esw_statistics));
-		if (qlcnic_get_port_stats(adapter, i, rx_tx, &port_stats))
+		if (qlcnic_get_port_stats(adapter, adapter->npars[i].pci_func,
+					  rx_tx, &port_stats))
 			continue;
 
 		esw_stats->size = port_stats.size;
@@ -1082,7 +1097,7 @@ op_type = 1 for port vlan_id
 int qlcnic_config_switch_port(struct qlcnic_adapter *adapter,
 		struct qlcnic_esw_func_cfg *esw_cfg)
 {
-	int err = -EIO;
+	int err = -EIO, index;
 	u32 arg1, arg2 = 0;
 	struct qlcnic_cmd_args cmd;
 	u8 pci_func;
@@ -1090,7 +1105,10 @@ int qlcnic_config_switch_port(struct qlcnic_adapter *adapter,
 	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC)
 		return err;
 	pci_func = esw_cfg->pci_func;
-	arg1 = (adapter->npars[pci_func].phy_port & BIT_0);
+	index = qlcnic_is_valid_nic_func(adapter, pci_func);
+	if (index < 0)
+		return err;
+	arg1 = (adapter->npars[index].phy_port & BIT_0);
 	arg1 |= (pci_func << 8);
 
 	if (__qlcnic_get_eswitch_port_config(adapter, &arg1, &arg2))
@@ -1152,11 +1170,17 @@ qlcnic_get_eswitch_port_config(struct qlcnic_adapter *adapter,
 			struct qlcnic_esw_func_cfg *esw_cfg)
 {
 	u32 arg1, arg2;
+	int index;
 	u8 phy_port;
-	if (adapter->ahw->op_mode == QLCNIC_MGMT_FUNC)
-		phy_port = adapter->npars[esw_cfg->pci_func].phy_port;
-	else
+
+	if (adapter->ahw->op_mode == QLCNIC_MGMT_FUNC) {
+		index = qlcnic_is_valid_nic_func(adapter, esw_cfg->pci_func);
+		if (index < 0)
+			return -EIO;
+		phy_port = adapter->npars[index].phy_port;
+	} else {
 		phy_port = adapter->ahw->physical_port;
+	}
 	arg1 = phy_port;
 	arg1 |= (esw_cfg->pci_func << 8);
 	if (__qlcnic_get_eswitch_port_config(adapter, &arg1, &arg2))
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 9cc7fca..af592cf 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -101,6 +101,9 @@ static void qlcnic_set_netdev_features(struct qlcnic_adapter *,
 static int qlcnic_vlan_rx_add(struct net_device *, u16);
 static int qlcnic_vlan_rx_del(struct net_device *, u16);
 
+#define QLCNIC_IS_TSO_CAPABLE(adapter)	\
+	((adapter)->ahw->capabilities & QLCNIC_FW_CAPABILITY_TSO)
+
 /*  PCI Device ID Table  */
 #define ENTRY(device) \
 	{PCI_DEVICE(PCI_VENDOR_ID_QLOGIC, (device)), \
@@ -450,19 +453,54 @@ static void qlcnic_cleanup_pci_map(struct qlcnic_hardware_context *ahw)
 		iounmap(ahw->pci_base0);
 }
 
-static int
-qlcnic_init_pci_info(struct qlcnic_adapter *adapter)
+static int qlcnic_get_act_pci_func(struct qlcnic_adapter *adapter)
+{
+	struct qlcnic_pci_info *pci_info;
+	int ret;
+
+	if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED)) {
+		switch (adapter->ahw->port_type) {
+		case QLCNIC_GBE:
+			adapter->ahw->act_pci_func = QLCNIC_NIU_MAX_GBE_PORTS;
+			break;
+		case QLCNIC_XGBE:
+			adapter->ahw->act_pci_func = QLCNIC_NIU_MAX_XG_PORTS;
+			break;
+		}
+		return 0;
+	}
+
+	if (adapter->ahw->op_mode == QLCNIC_MGMT_FUNC)
+		return 0;
+
+	pci_info = kcalloc(QLCNIC_MAX_PCI_FUNC, sizeof(*pci_info), GFP_KERNEL);
+	if (!pci_info)
+		return -ENOMEM;
+
+	ret = qlcnic_get_pci_info(adapter, pci_info);
+	kfree(pci_info);
+	return ret;
+}
+
+int qlcnic_init_pci_info(struct qlcnic_adapter *adapter)
 {
 	struct qlcnic_pci_info *pci_info;
-	int i, ret = 0;
+	int i, ret = 0, j = 0;
+	u16 act_pci_func;
 	u8 pfn;
 
 	pci_info = kcalloc(QLCNIC_MAX_PCI_FUNC, sizeof(*pci_info), GFP_KERNEL);
 	if (!pci_info)
 		return -ENOMEM;
 
+	ret = qlcnic_get_pci_info(adapter, pci_info);
+	if (ret)
+		goto err_pci_info;
+
+	act_pci_func = adapter->ahw->act_pci_func;
+
 	adapter->npars = kzalloc(sizeof(struct qlcnic_npar_info) *
-				QLCNIC_MAX_PCI_FUNC, GFP_KERNEL);
+				 act_pci_func, GFP_KERNEL);
 	if (!adapter->npars) {
 		ret = -ENOMEM;
 		goto err_pci_info;
@@ -475,21 +513,25 @@ qlcnic_init_pci_info(struct qlcnic_adapter *adapter)
 		goto err_npars;
 	}
 
-	ret = qlcnic_get_pci_info(adapter, pci_info);
-	if (ret)
-		goto err_eswitch;
-
 	for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++) {
 		pfn = pci_info[i].id;
+
 		if (pfn >= QLCNIC_MAX_PCI_FUNC) {
 			ret = QL_STATUS_INVALID_PARAM;
 			goto err_eswitch;
 		}
-		adapter->npars[pfn].active = (u8)pci_info[i].active;
-		adapter->npars[pfn].type = (u8)pci_info[i].type;
-		adapter->npars[pfn].phy_port = (u8)pci_info[i].default_port;
-		adapter->npars[pfn].min_bw = pci_info[i].tx_min_bw;
-		adapter->npars[pfn].max_bw = pci_info[i].tx_max_bw;
+
+		if (!pci_info[i].active ||
+		    (pci_info[i].type != QLCNIC_TYPE_NIC))
+			continue;
+
+		adapter->npars[j].pci_func = pfn;
+		adapter->npars[j].active = (u8)pci_info[i].active;
+		adapter->npars[j].type = (u8)pci_info[i].type;
+		adapter->npars[j].phy_port = (u8)pci_info[i].default_port;
+		adapter->npars[j].min_bw = pci_info[i].tx_min_bw;
+		adapter->npars[j].max_bw = pci_info[i].tx_max_bw;
+		j++;
 	}
 
 	for (i = 0; i < QLCNIC_NIU_MAX_XG_PORTS; i++)
@@ -517,30 +559,29 @@ qlcnic_set_function_modes(struct qlcnic_adapter *adapter)
 	u32 ref_count;
 	int i, ret = 1;
 	u32 data = QLCNIC_MGMT_FUNC;
-	void __iomem *priv_op = adapter->ahw->pci_base0 + QLCNIC_DRV_OP_MODE;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
 	/* If other drivers are not in use set their privilege level */
-	ref_count = QLCRD32(adapter, QLCNIC_CRB_DRV_ACTIVE);
+	ref_count = QLCRD(adapter, QLCNIC_CRB_DRV_ACTIVE);
 	ret = qlcnic_api_lock(adapter);
 	if (ret)
 		goto err_lock;
 
 	if (qlcnic_config_npars) {
-		for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++) {
-			id = i;
-			if (adapter->npars[i].type != QLCNIC_TYPE_NIC ||
-				id == adapter->ahw->pci_func)
+		for (i = 0; i < ahw->act_pci_func; i++) {
+			id = adapter->npars[i].pci_func;
+			if (id == ahw->pci_func)
 				continue;
 			data |= (qlcnic_config_npars &
 					QLC_DEV_SET_DRV(0xf, id));
 		}
 	} else {
-		data = readl(priv_op);
-		data = (data & ~QLC_DEV_SET_DRV(0xf, adapter->ahw->pci_func)) |
+		data = QLCRD(adapter, QLCNIC_DRV_OP_MODE);
+		data = (data & ~QLC_DEV_SET_DRV(0xf, ahw->pci_func)) |
 			(QLC_DEV_SET_DRV(QLCNIC_MGMT_FUNC,
-			adapter->ahw->pci_func));
+					 ahw->pci_func));
 	}
-	writel(data, priv_op);
+	QLCWR(adapter, QLCNIC_DRV_OP_MODE, data);
 	qlcnic_api_unlock(adapter);
 err_lock:
 	return ret;
@@ -710,6 +751,7 @@ qlcnic_initialize_nic(struct qlcnic_adapter *adapter)
 	int err;
 	struct qlcnic_info nic_info;
 
+	memset(&nic_info, 0, sizeof(struct qlcnic_info));
 	err = qlcnic_get_nic_info(adapter, &nic_info, adapter->ahw->pci_func);
 	if (err)
 		return err;
@@ -879,8 +921,7 @@ qlcnic_check_eswitch_mode(struct qlcnic_adapter *adapter)
 	return err;
 }
 
-static int
-qlcnic_set_default_offload_settings(struct qlcnic_adapter *adapter)
+int qlcnic_set_default_offload_settings(struct qlcnic_adapter *adapter)
 {
 	struct qlcnic_esw_func_cfg esw_cfg;
 	struct qlcnic_npar_info *npar;
@@ -889,16 +930,16 @@ qlcnic_set_default_offload_settings(struct qlcnic_adapter *adapter)
 	if (adapter->need_fw_reset)
 		return 0;
 
-	for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++) {
-		if (adapter->npars[i].type != QLCNIC_TYPE_NIC)
-			continue;
+	for (i = 0; i < adapter->ahw->act_pci_func; i++) {
 		memset(&esw_cfg, 0, sizeof(struct qlcnic_esw_func_cfg));
-		esw_cfg.pci_func = i;
-		esw_cfg.offload_flags = BIT_0;
+		esw_cfg.pci_func = adapter->npars[i].pci_func;
 		esw_cfg.mac_override = BIT_0;
 		esw_cfg.promisc_mode = BIT_0;
-		if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_TSO)
-			esw_cfg.offload_flags |= (BIT_1 | BIT_2);
+		if (qlcnic_82xx_check(adapter)) {
+			esw_cfg.offload_flags = BIT_0;
+			if (QLCNIC_IS_TSO_CAPABLE(adapter))
+				esw_cfg.offload_flags |= (BIT_1 | BIT_2);
+		}
 		if (qlcnic_config_switch_port(adapter, &esw_cfg))
 			return -EIO;
 		npar = &adapter->npars[i];
@@ -936,22 +977,24 @@ qlcnic_reset_eswitch_config(struct qlcnic_adapter *adapter,
 	return 0;
 }
 
-static int
-qlcnic_reset_npar_config(struct qlcnic_adapter *adapter)
+int qlcnic_reset_npar_config(struct qlcnic_adapter *adapter)
 {
 	int i, err;
 	struct qlcnic_npar_info *npar;
 	struct qlcnic_info nic_info;
+	u8 pci_func;
 
-	if (!adapter->need_fw_reset)
-		return 0;
+	if (qlcnic_82xx_check(adapter))
+		if (!adapter->need_fw_reset)
+			return 0;
 
 	/* Set the NPAR config data after FW reset */
-	for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++) {
+	for (i = 0; i < adapter->ahw->act_pci_func; i++) {
 		npar = &adapter->npars[i];
-		if (npar->type != QLCNIC_TYPE_NIC)
-			continue;
-		err = qlcnic_get_nic_info(adapter, &nic_info, i);
+		pci_func = npar->pci_func;
+		memset(&nic_info, 0, sizeof(struct qlcnic_info));
+		err = qlcnic_get_nic_info(adapter,
+					  &nic_info, pci_func);
 		if (err)
 			return err;
 		nic_info.min_tx_bw = npar->min_bw;
@@ -962,11 +1005,12 @@ qlcnic_reset_npar_config(struct qlcnic_adapter *adapter)
 
 		if (npar->enable_pm) {
 			err = qlcnic_config_port_mirroring(adapter,
-							npar->dest_npar, 1, i);
+							   npar->dest_npar, 1,
+							   pci_func);
 			if (err)
 				return err;
 		}
-		err = qlcnic_reset_eswitch_config(adapter, npar, i);
+		err = qlcnic_reset_eswitch_config(adapter, npar, pci_func);
 		if (err)
 			return err;
 	}
@@ -1586,6 +1630,19 @@ int qlcnic_alloc_tx_rings(struct qlcnic_adapter *adapter,
 
 	return 0;
 }
+
+int qlcnic_is_valid_nic_func(struct qlcnic_adapter *adapter, u8 pci_func)
+{
+	int i;
+
+	for (i = 0; i < adapter->ahw->act_pci_func; i++) {
+		if (adapter->npars[i].pci_func == pci_func)
+			return i;
+	}
+
+	return -1;
+}
+
 static int __devinit
 qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
@@ -1708,6 +1765,9 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		break;
 	}
 
+	if (qlcnic_get_act_pci_func(adapter))
+		goto err_out_disable_mbx_intr;
+
 	if (adapter->mac_learn)
 		qlcnic_alloc_lb_filters_mem(adapter);
 
-- 
1.7.1
