From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCH net-next-2.6 1/2] qlcnic: Fix a bug in setting up NIC
 partitioning mode
Date: Wed, 16 Jun 2010 12:07:27 -0700
Message-ID: <alpine.OSX.2.00.1006161159040.15485@macintosh-2.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>
To: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexcashub1.qlogic.com ([198.70.193.61]:34089 "EHLO
	avexcashub1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758923Ab0FPTHf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 15:07:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver was not detecting the presence of NIC partitioning capability of the 
firmware properly. Now, it checks the eswitch set bit in the FW capabilities 
register and accordingly sets the driver mode as NPAR capable or not.

Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h      |    2 +-
 drivers/net/qlcnic/qlcnic_ctx.c  |    5 ++
 drivers/net/qlcnic/qlcnic_main.c |   82 ++++++++++++++-----------------------
 3 files changed, 37 insertions(+), 52 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 02db363..eb1bdb2 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -891,7 +891,7 @@ struct qlcnic_mac_req {
 #define QLCNIC_LRO_ENABLED		0x08
 #define QLCNIC_BRIDGE_ENABLED       	0X10
 #define QLCNIC_DIAG_ENABLED		0x20
-#define QLCNIC_NPAR_ENABLED		0x40
+#define QLCNIC_ESWITCH_ENABLED		0x40
 #define QLCNIC_IS_MSI_FAMILY(adapter) \
 	((adapter)->flags & (QLCNIC_MSI_ENABLED | QLCNIC_MSIX_ENABLED))
 
diff --git a/drivers/net/qlcnic/qlcnic_ctx.c b/drivers/net/qlcnic/qlcnic_ctx.c
index 1e1dc58..42feb23 100644
--- a/drivers/net/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/qlcnic/qlcnic_ctx.c
@@ -637,6 +637,11 @@ int qlcnic_get_nic_info(struct qlcnic_adapter *adapter, u8 func_id)
 		adapter->capabilities = le32_to_cpu(nic_info->capabilities);
 		adapter->max_mac_filters = nic_info->max_mac_filters;
 
+		if (adapter->capabilities & BIT_6)
+			adapter->flags |= QLCNIC_ESWITCH_ENABLED;
+		else
+			adapter->flags &= ~QLCNIC_ESWITCH_ENABLED;
+
 		dev_info(&adapter->pdev->dev,
 			"phy port: %d switch_mode: %d,\n"
 			"\tmax_tx_q: %d max_rx_q: %d min_tx_bw: 0x%x,\n"
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 99371bc..128a0a7 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -502,39 +502,28 @@ qlcnic_set_function_modes(struct qlcnic_adapter *adapter)
 	if (QLC_DEV_CLR_REF_CNT(ref_count, adapter->ahw.pci_func))
 		goto err_npar;
 
-	for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++) {
-		id = adapter->npars[i].id;
-		if (adapter->npars[i].type != QLCNIC_TYPE_NIC ||
-			id == adapter->ahw.pci_func)
-			continue;
-		data |= (qlcnic_config_npars & QLC_DEV_SET_DRV(0xf, id));
+	if (qlcnic_config_npars) {
+		for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++) {
+			id = adapter->npars[i].id;
+			if (adapter->npars[i].type != QLCNIC_TYPE_NIC ||
+				id == adapter->ahw.pci_func)
+				continue;
+			data |= (qlcnic_config_npars &
+					QLC_DEV_SET_DRV(0xf, id));
+		}
+	} else {
+		data = readl(priv_op);
+		data = (data & ~QLC_DEV_SET_DRV(0xf, adapter->ahw.pci_func)) |
+			(QLC_DEV_SET_DRV(QLCNIC_MGMT_FUNC,
+			adapter->ahw.pci_func));
 	}
 	writel(data, priv_op);
-
 err_npar:
 	qlcnic_api_unlock(adapter);
 err_lock:
 	return ret;
 }
 
-static u8
-qlcnic_set_mgmt_driver(struct qlcnic_adapter *adapter)
-{
-	u8 i, ret = 0;
-
-	if (qlcnic_get_pci_info(adapter))
-		return ret;
-	/* Set the eswitch */
-	for (i = 0; i < QLCNIC_NIU_MAX_XG_PORTS; i++) {
-		if (!qlcnic_get_eswitch_capabilities(adapter, i,
-			&adapter->eswitch[i])) {
-			ret++;
-			qlcnic_toggle_eswitch(adapter, i, ret);
-		}
-	}
-	return ret;
-}
-
 static u32
 qlcnic_get_driver_mode(struct qlcnic_adapter *adapter)
 {
@@ -550,6 +539,7 @@ qlcnic_get_driver_mode(struct qlcnic_adapter *adapter)
 		adapter->nic_ops = &qlcnic_ops;
 		adapter->fw_hal_version = QLCNIC_FW_BASE;
 		adapter->ahw.pci_func = PCI_FUNC(adapter->pdev->devfn);
+		adapter->capabilities = QLCRD32(adapter, CRB_FW_CAPABILITIES_1);
 		dev_info(&adapter->pdev->dev,
 			"FW does not support nic partion\n");
 		return adapter->fw_hal_version;
@@ -562,29 +552,28 @@ qlcnic_get_driver_mode(struct qlcnic_adapter *adapter)
 	func = (func - msix_base)/QLCNIC_MSIX_TBL_PGSIZE;
 	adapter->ahw.pci_func = func;
 
+	qlcnic_get_nic_info(adapter, adapter->ahw.pci_func);
+
+	if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED))	{
+		adapter->nic_ops = &qlcnic_ops;
+		return adapter->fw_hal_version;
+	}
+
 	/* Determine function privilege level */
 	priv_op = adapter->ahw.pci_base0 + QLCNIC_DRV_OP_MODE;
 	op_mode = readl(priv_op);
-	if (op_mode == QLC_DEV_DRV_DEFAULT) {
+	if (op_mode == QLC_DEV_DRV_DEFAULT)
 		priv_level = QLCNIC_MGMT_FUNC;
-		if (qlcnic_api_lock(adapter))
-			return 0;
-		op_mode = (op_mode & ~QLC_DEV_SET_DRV(0xf, func)) |
-				(QLC_DEV_SET_DRV(QLCNIC_MGMT_FUNC, func));
-		writel(op_mode, priv_op);
-		qlcnic_api_unlock(adapter);
-
-	} else
+	else
 		priv_level = QLC_DEV_GET_DRV(op_mode, adapter->ahw.pci_func);
 
 	switch (priv_level) {
 	case QLCNIC_MGMT_FUNC:
 		adapter->op_mode = QLCNIC_MGMT_FUNC;
 		adapter->nic_ops = &qlcnic_pf_ops;
+		qlcnic_get_pci_info(adapter);
 		/* Set privilege level for other functions */
-		if (qlcnic_config_npars)
-			qlcnic_set_function_modes(adapter);
-		qlcnic_dev_set_npar_ready(adapter);
+		qlcnic_set_function_modes(adapter);
 		dev_info(&adapter->pdev->dev,
 			"HAL Version: %d, Management function\n",
 			adapter->fw_hal_version);
@@ -716,11 +705,6 @@ qlcnic_check_options(struct qlcnic_adapter *adapter)
 	dev_info(&pdev->dev, "firmware v%d.%d.%d\n",
 			fw_major, fw_minor, fw_build);
 
-	if (adapter->fw_hal_version == QLCNIC_FW_NPAR)
-		qlcnic_get_nic_info(adapter, adapter->ahw.pci_func);
-	else
-		adapter->capabilities = QLCRD32(adapter, CRB_FW_CAPABILITIES_1);
-
 	adapter->flags &= ~QLCNIC_LRO_ENABLED;
 
 	if (adapter->ahw.port_type == QLCNIC_XGBE) {
@@ -731,6 +715,8 @@ qlcnic_check_options(struct qlcnic_adapter *adapter)
 		adapter->num_jumbo_rxd = MAX_JUMBO_RCV_DESCRIPTORS_1G;
 	}
 
+	qlcnic_get_nic_info(adapter, adapter->ahw.pci_func);
+
 	adapter->msix_supported = !!use_msi_x;
 	adapter->rss_supported = !!use_msi_x;
 
@@ -797,13 +783,11 @@ wait_init:
 	QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_READY);
 	qlcnic_idc_debug_info(adapter, 1);
 
-	qlcnic_dev_set_npar_ready(adapter);
-
 	qlcnic_check_options(adapter);
 
-	if (adapter->fw_hal_version != QLCNIC_FW_BASE &&
-			adapter->op_mode == QLCNIC_MGMT_FUNC)
-		qlcnic_set_mgmt_driver(adapter);
+	if (adapter->flags & QLCNIC_ESWITCH_ENABLED &&
+		adapter->op_mode != QLCNIC_NON_PRIV_FUNC)
+		qlcnic_dev_set_npar_ready(adapter);
 
 	adapter->need_fw_reset = 0;
 
@@ -2449,10 +2433,6 @@ qlcnic_dev_set_npar_ready(struct qlcnic_adapter *adapter)
 {
 	u32 state;
 
-	if (adapter->op_mode == QLCNIC_NON_PRIV_FUNC ||
-		adapter->fw_hal_version == QLCNIC_FW_BASE)
-		return;
-
 	if (qlcnic_api_lock(adapter))
 		return;
 
-- 
1.6.0.2

