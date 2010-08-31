From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 04/10] qlcnic: fix for setting default eswitch config
Date: Tue, 31 Aug 2010 07:29:34 -0700
Message-ID: <1283264980-25881-5-git-send-email-amit.salecha@qlogic.com>
References: <1283264980-25881-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:43921 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1757471Ab0HaO3m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Aug 2010 10:29:42 -0400
In-Reply-To: <1283264980-25881-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh Borundia <rajesh.borundia@qlogic.com>

o Default eswitch config was set, even before eswitch capabilty get detected.
As a result setting default config was getting fail.

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_main.c |   96 +++++++++++++++++++++++++------------
 1 files changed, 65 insertions(+), 31 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 3f2f93b..e0c6811 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -667,7 +667,6 @@ qlcnic_check_options(struct qlcnic_adapter *adapter)
 {
 	u32 fw_major, fw_minor, fw_build;
 	struct pci_dev *pdev = adapter->pdev;
-	struct qlcnic_info nic_info;
 
 	fw_major = QLCRD32(adapter, QLCNIC_FW_VERSION_MAJOR);
 	fw_minor = QLCRD32(adapter, QLCNIC_FW_VERSION_MINOR);
@@ -688,16 +687,6 @@ qlcnic_check_options(struct qlcnic_adapter *adapter)
 		adapter->num_jumbo_rxd = MAX_JUMBO_RCV_DESCRIPTORS_1G;
 	}
 
-	if (!qlcnic_get_nic_info(adapter, &nic_info, adapter->ahw.pci_func)) {
-		adapter->physical_port = nic_info.phys_port;
-		adapter->switch_mode = nic_info.switch_mode;
-		adapter->max_tx_ques = nic_info.max_tx_ques;
-		adapter->max_rx_ques = nic_info.max_rx_ques;
-		adapter->capabilities = nic_info.capabilities;
-		adapter->max_mac_filters = nic_info.max_mac_filters;
-		adapter->max_mtu = nic_info.max_mtu;
-	}
-
 	adapter->msix_supported = !!use_msi_x;
 	adapter->rss_supported = !!use_msi_x;
 
@@ -706,6 +695,32 @@ qlcnic_check_options(struct qlcnic_adapter *adapter)
 	adapter->max_rds_rings = MAX_RDS_RINGS;
 }
 
+static int
+qlcnic_initialize_nic(struct qlcnic_adapter *adapter)
+{
+	int err;
+	struct qlcnic_info nic_info;
+
+	err = qlcnic_get_nic_info(adapter, &nic_info, adapter->ahw.pci_func);
+	if (err)
+		return err;
+
+	adapter->physical_port = nic_info.phys_port;
+	adapter->switch_mode = nic_info.switch_mode;
+	adapter->max_tx_ques = nic_info.max_tx_ques;
+	adapter->max_rx_ques = nic_info.max_rx_ques;
+	adapter->capabilities = nic_info.capabilities;
+	adapter->max_mac_filters = nic_info.max_mac_filters;
+	adapter->max_mtu = nic_info.max_mtu;
+
+	if (adapter->capabilities & BIT_6)
+		adapter->flags |= QLCNIC_ESWITCH_ENABLED;
+	else
+		adapter->flags &= ~QLCNIC_ESWITCH_ENABLED;
+
+	return err;
+}
+
 static void
 qlcnic_set_vlan_config(struct qlcnic_adapter *adapter,
 		struct qlcnic_esw_func_cfg *esw_cfg)
@@ -791,6 +806,10 @@ qlcnic_check_eswitch_mode(struct qlcnic_adapter *adapter)
 	u32 op_mode, priv_level;
 	int err = 0;
 
+	err = qlcnic_initialize_nic(adapter);
+	if (err)
+		return err;
+
 	if (adapter->flags & QLCNIC_ADAPTER_INITIALIZED)
 		return 0;
 
@@ -803,8 +822,7 @@ qlcnic_check_eswitch_mode(struct qlcnic_adapter *adapter)
 	else
 		priv_level = QLC_DEV_GET_DRV(op_mode, adapter->ahw.pci_func);
 
-	if (adapter->capabilities & BIT_6) {
-		adapter->flags |= QLCNIC_ESWITCH_ENABLED;
+	if (adapter->flags & QLCNIC_ESWITCH_ENABLED) {
 		if (priv_level == QLCNIC_MGMT_FUNC) {
 			adapter->op_mode = QLCNIC_MGMT_FUNC;
 			err = qlcnic_init_pci_info(adapter);
@@ -821,8 +839,7 @@ qlcnic_check_eswitch_mode(struct qlcnic_adapter *adapter)
 				"HAL Version: %d, Privileged function\n",
 				adapter->fw_hal_version);
 		}
-	} else
-		adapter->flags &= ~QLCNIC_ESWITCH_ENABLED;
+	}
 
 	adapter->flags |= QLCNIC_ADAPTER_INITIALIZED;
 
@@ -836,9 +853,7 @@ qlcnic_set_default_offload_settings(struct qlcnic_adapter *adapter)
 	struct qlcnic_npar_info *npar;
 	u8 i;
 
-	if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED) ||
-	    adapter->need_fw_reset ||
-	    adapter->op_mode != QLCNIC_MGMT_FUNC)
+	if (adapter->need_fw_reset)
 		return 0;
 
 	for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++) {
@@ -894,8 +909,7 @@ qlcnic_reset_npar_config(struct qlcnic_adapter *adapter)
 	struct qlcnic_npar_info *npar;
 	struct qlcnic_info nic_info;
 
-	if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED) ||
-	    !adapter->need_fw_reset || adapter->op_mode != QLCNIC_MGMT_FUNC)
+	if (!adapter->need_fw_reset)
 		return 0;
 
 	/* Set the NPAR config data after FW reset */
@@ -947,6 +961,28 @@ static int qlcnic_check_npar_opertional(struct qlcnic_adapter *adapter)
 }
 
 static int
+qlcnic_set_mgmt_operations(struct qlcnic_adapter *adapter)
+{
+	int err;
+
+	if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED) ||
+		    adapter->op_mode != QLCNIC_MGMT_FUNC)
+		return 0;
+
+	err = qlcnic_set_default_offload_settings(adapter);
+	if (err)
+		return err;
+
+	err = qlcnic_reset_npar_config(adapter);
+	if (err)
+		return err;
+
+	qlcnic_dev_set_npar_ready(adapter);
+
+	return err;
+}
+
+static int
 qlcnic_start_firmware(struct qlcnic_adapter *adapter)
 {
 	int err;
@@ -991,20 +1027,17 @@ check_fw_status:
 	QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_READY);
 	qlcnic_idc_debug_info(adapter, 1);
 
-	err = qlcnic_set_default_offload_settings(adapter);
-	if (err)
-		goto err_out;
-	err = qlcnic_reset_npar_config(adapter);
-	if (err)
-		goto err_out;
-	qlcnic_check_options(adapter);
 	err = qlcnic_check_eswitch_mode(adapter);
 	if (err) {
 		dev_err(&adapter->pdev->dev,
 			"Memory allocation failed for eswitch\n");
 		goto err_out;
 	}
-	qlcnic_dev_set_npar_ready(adapter);
+	err = qlcnic_set_mgmt_operations(adapter);
+	if (err)
+		goto err_out;
+
+	qlcnic_check_options(adapter);
 	adapter->need_fw_reset = 0;
 
 	qlcnic_release_firmware(adapter);
@@ -2719,9 +2752,6 @@ qlcnic_dev_request_reset(struct qlcnic_adapter *adapter)
 static void
 qlcnic_dev_set_npar_ready(struct qlcnic_adapter *adapter)
 {
-	if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED) ||
-	    adapter->op_mode != QLCNIC_MGMT_FUNC)
-		return;
 	if (qlcnic_api_lock(adapter))
 		return;
 
@@ -3004,6 +3034,10 @@ qlcnicvf_start_firmware(struct qlcnic_adapter *adapter)
 	if (err)
 		return err;
 
+	err = qlcnic_initialize_nic(adapter);
+	if (err)
+		return err;
+
 	qlcnic_check_options(adapter);
 
 	adapter->need_fw_reset = 0;
-- 
1.6.0.2

