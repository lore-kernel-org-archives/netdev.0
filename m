From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH v1 08/19] qlcnic: update NIC partition interface routines
Date: Wed, 19 Sep 2012 15:29:46 -0400
Message-ID: <1348082997-12333-9-git-send-email-sony.chacko@qlogic.com>
References: <1348082997-12333-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:19087 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753007Ab2ITBMm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2012 21:12:42 -0400
In-Reply-To: <1348082997-12333-1-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Refactor 82xx driver to support new adapter - Qlogic 83XX CNA

Update routines to support variable number of NIC partitions

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Sritej Velaga <sritej.velaga@qlogic.com>
Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h      |    2 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c  |    3 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |  104 +++++++++++++--------
 3 files changed, 69 insertions(+), 40 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index b68ea92..2bb91b4 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -482,6 +482,7 @@ struct qlcnic_hardware_context {
 	u16 max_rx_ques;
 	u16 max_mtu;
 	u16 msg_enable;
+	u16 act_pci_func;
 
 	u32 capabilities;
 	u32 temp;
@@ -1117,6 +1118,7 @@ struct qlcnic_npar_info {
 	u8	mac_anti_spoof;
 	u8	promisc_mode;
 	u8	offload_flags;
+	u8      pci_func;
 };
 
 struct qlcnic_eswitch {
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
index 0ca8fe5..ed7ce0e 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
@@ -775,11 +775,14 @@ int qlcnic_82xx_get_pci_info(struct qlcnic_adapter *adapter,
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
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 9076f49..b6b0e35 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -524,19 +524,26 @@ qlcnic_cleanup_pci_map(struct qlcnic_hardware_context *ahw)
 		iounmap(ahw->pci_base0);
 }
 
-static int
+int
 qlcnic_init_pci_info(struct qlcnic_adapter *adapter)
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
@@ -549,21 +556,25 @@ qlcnic_init_pci_info(struct qlcnic_adapter *adapter)
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
+				(pci_info[i].type != QLCNIC_TYPE_NIC))
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
@@ -589,32 +600,31 @@ qlcnic_set_function_modes(struct qlcnic_adapter *adapter)
 {
 	u8 id;
 	u32 ref_count;
-	int i, err, ret = 1;
+	int i, ret = 1;
 	u32 data = QLCNIC_MGMT_FUNC;
-	void __iomem *priv_op = adapter->ahw->pci_base0 + QLCNIC_DRV_OP_MODE;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
 	/* If other drivers are not in use set their privilege level */
-	ref_count = QLCRD32(adapter, QLCNIC_CRB_DRV_ACTIVE, &err);
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
+			ahw->pci_func));
 	}
-	writel(data, priv_op);
+	QLCWR(adapter, QLCNIC_DRV_OP_MODE, data);
 	qlcnic_api_unlock(adapter);
 err_lock:
 	return ret;
@@ -957,7 +967,7 @@ qlcnic_check_eswitch_mode(struct qlcnic_adapter *adapter)
 	return err;
 }
 
-static int
+int
 qlcnic_set_default_offload_settings(struct qlcnic_adapter *adapter)
 {
 	struct qlcnic_esw_func_cfg esw_cfg;
@@ -967,16 +977,16 @@ qlcnic_set_default_offload_settings(struct qlcnic_adapter *adapter)
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
-		if (adapter->ahw->capabilities  & QLCNIC_FW_CAPABILITY_TSO)
-			esw_cfg.offload_flags |= (BIT_1 | BIT_2);
+		if (QLCNIC_IS_82XX(adapter)) {
+			esw_cfg.offload_flags = BIT_0;
+			if (QLCNIC_IS_TSO_CAPABLE(adapter))
+				esw_cfg.offload_flags |= (BIT_1 | BIT_2);
+		}
 		if (qlcnic_config_switch_port(adapter, &esw_cfg))
 			return -EIO;
 		npar = &adapter->npars[i];
@@ -1014,22 +1024,24 @@ qlcnic_reset_eswitch_config(struct qlcnic_adapter *adapter,
 	return 0;
 }
 
-static int
+int
 qlcnic_reset_npar_config(struct qlcnic_adapter *adapter)
 {
 	int i, err;
 	struct qlcnic_npar_info *npar;
 	struct qlcnic_info nic_info;
+	u8 pci_func;
 
-	if (!adapter->need_fw_reset)
-		return 0;
+	if (QLCNIC_IS_82XX(adapter))
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
+		err = qlcnic_get_nic_info(adapter,
+					  &nic_info, pci_func);
 		if (err)
 			return err;
 		nic_info.min_tx_bw = npar->min_bw;
@@ -1040,11 +1052,12 @@ qlcnic_reset_npar_config(struct qlcnic_adapter *adapter)
 
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
@@ -1618,6 +1631,17 @@ static int qlcnic_set_dma_mask(struct pci_dev *pdev, u8 *pci_using_dac)
 	return 0;
 }
 
+int qlcnic_is_valid_nic_func(struct qlcnic_adapter *adapter, u8 pci_func)
+{
+	int i;
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
-- 
1.7.1
