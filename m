From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCH net-next-2.6 2/3] qlcnic: Fix driver load issue in FW hang
Date: Thu, 26 Aug 2010 17:02:52 -0700
Message-ID: <alpine.OSX.2.00.1008261643310.9385@macintosh-2.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>
To: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexcashub1.qlogic.com ([198.70.193.61]:23118 "EHLO
	avexcashub1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754878Ab0H0ACx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Aug 2010 20:02:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


If there is a FW hang when the driver loads, it can not determine the FW operational
mode. Fix it by checking the FW state first before issuing any FW commands to 
determine its capabilities and thereby detecting driver operational mode.

Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h      |    1 +
 drivers/net/qlcnic/qlcnic_hdr.h  |    2 +-
 drivers/net/qlcnic/qlcnic_init.c |   16 ++++--
 drivers/net/qlcnic/qlcnic_main.c |  116 ++++++++++++++++++++------------------
 4 files changed, 75 insertions(+), 60 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index d15de63..0a53704 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -902,6 +902,7 @@ struct qlcnic_mac_req {
 #define QLCNIC_BRIDGE_ENABLED       	0X10
 #define QLCNIC_DIAG_ENABLED		0x20
 #define QLCNIC_ESWITCH_ENABLED		0x40
+#define QLCNIC_ADAPTER_INITIALIZED	0x80
 #define QLCNIC_TAGGING_ENABLED		0x100
 #define QLCNIC_MACSPOOF			0x200
 #define QLCNIC_IS_MSI_FAMILY(adapter) \
diff --git a/drivers/net/qlcnic/qlcnic_hdr.h b/drivers/net/qlcnic/qlcnic_hdr.h
index 219de9f..bce1b1d 100644
--- a/drivers/net/qlcnic/qlcnic_hdr.h
+++ b/drivers/net/qlcnic/qlcnic_hdr.h
@@ -748,7 +748,7 @@ enum {
 #define QLCNIC_RESET_TIMEOUT_SECS	10
 #define QLCNIC_INIT_TIMEOUT_SECS	30
 #define QLCNIC_HEARTBEAT_PERIOD_MSECS	200
-#define QLCNIC_HEARTBEAT_RETRY_COUNT	30
+#define QLCNIC_HEARTBEAT_RETRY_COUNT	45
 
 #define	ISR_MSI_INT_TRIGGER(FUNC) (QLCNIC_PCIX_PS_REG(PCIX_MSI_F(FUNC)))
 #define ISR_LEGACY_INT_TRIGGERED(VAL)	(((VAL) & 0x300) == 0x200)
diff --git a/drivers/net/qlcnic/qlcnic_init.c b/drivers/net/qlcnic/qlcnic_init.c
index df91b75..eb8256b 100644
--- a/drivers/net/qlcnic/qlcnic_init.c
+++ b/drivers/net/qlcnic/qlcnic_init.c
@@ -547,7 +547,7 @@ int qlcnic_pinit_from_rom(struct qlcnic_adapter *adapter)
 int
 qlcnic_check_fw_status(struct qlcnic_adapter *adapter)
 {
-	u32 heartbit, ret = -EIO;
+	u32 heartbit, cmdpeg_state, ret = -EIO;
 	int retries = QLCNIC_HEARTBEAT_RETRY_COUNT;
 
 	adapter->heartbit = QLCRD32(adapter, QLCNIC_PEG_ALIVE_COUNTER);
@@ -555,10 +555,16 @@ qlcnic_check_fw_status(struct qlcnic_adapter *adapter)
 		msleep(QLCNIC_HEARTBEAT_PERIOD_MSECS);
 		heartbit = QLCRD32(adapter, QLCNIC_PEG_ALIVE_COUNTER);
 		if (heartbit != adapter->heartbit) {
-			/* Complete firmware handshake */
-			QLCWR32(adapter, CRB_CMDPEG_STATE, PHAN_INITIALIZE_ACK);
-			ret = QLCNIC_RCODE_SUCCESS;
-			break;
+			cmdpeg_state = QLCRD32(adapter, CRB_CMDPEG_STATE);
+			/* Ensure peg states are initialized */
+			if (cmdpeg_state == PHAN_INITIALIZE_COMPLETE ||
+				cmdpeg_state == PHAN_INITIALIZE_ACK) {
+				/* Complete firmware handshake */
+				QLCWR32(adapter, CRB_CMDPEG_STATE,
+					PHAN_INITIALIZE_ACK);
+				ret = QLCNIC_RCODE_SUCCESS;
+				break;
+			}
 		}
 	} while (--retries);
 
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 1b8f67d..6999d5a 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -566,12 +566,11 @@ err_lock:
 	return ret;
 }
 
-static u32
-qlcnic_get_driver_mode(struct qlcnic_adapter *adapter)
+static void
+qlcnic_check_vf(struct qlcnic_adapter *adapter)
 {
 	void __iomem *msix_base_addr;
 	void __iomem *priv_op;
-	struct qlcnic_info nic_info;
 	u32 func;
 	u32 msix_base;
 	u32 op_mode, priv_level;
@@ -586,20 +585,6 @@ qlcnic_get_driver_mode(struct qlcnic_adapter *adapter)
 	func = (func - msix_base)/QLCNIC_MSIX_TBL_PGSIZE;
 	adapter->ahw.pci_func = func;
 
-	if (!qlcnic_get_nic_info(adapter, &nic_info, adapter->ahw.pci_func)) {
-		adapter->capabilities = nic_info.capabilities;
-
-		if (adapter->capabilities & BIT_6)
-			adapter->flags |= QLCNIC_ESWITCH_ENABLED;
-		else
-			adapter->flags &= ~QLCNIC_ESWITCH_ENABLED;
-	}
-
-	if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED))	{
-		adapter->nic_ops = &qlcnic_ops;
-		return adapter->fw_hal_version;
-	}
-
 	/* Determine function privilege level */
 	priv_op = adapter->ahw.pci_base0 + QLCNIC_DRV_OP_MODE;
 	op_mode = readl(priv_op);
@@ -608,37 +593,14 @@ qlcnic_get_driver_mode(struct qlcnic_adapter *adapter)
 	else
 		priv_level = QLC_DEV_GET_DRV(op_mode, adapter->ahw.pci_func);
 
-	switch (priv_level) {
-	case QLCNIC_MGMT_FUNC:
-		adapter->op_mode = QLCNIC_MGMT_FUNC;
-		adapter->nic_ops = &qlcnic_ops;
-		qlcnic_init_pci_info(adapter);
-		/* Set privilege level for other functions */
-		qlcnic_set_function_modes(adapter);
-		dev_info(&adapter->pdev->dev,
-			"HAL Version: %d, Management function\n",
-			adapter->fw_hal_version);
-		break;
-	case QLCNIC_PRIV_FUNC:
-		adapter->op_mode = QLCNIC_PRIV_FUNC;
-		dev_info(&adapter->pdev->dev,
-			"HAL Version: %d, Privileged function\n",
-			adapter->fw_hal_version);
-		adapter->nic_ops = &qlcnic_ops;
-		break;
-	case QLCNIC_NON_PRIV_FUNC:
+	if (priv_level == QLCNIC_NON_PRIV_FUNC) {
 		adapter->op_mode = QLCNIC_NON_PRIV_FUNC;
 		dev_info(&adapter->pdev->dev,
 			"HAL Version: %d Non Privileged function\n",
 			adapter->fw_hal_version);
 		adapter->nic_ops = &qlcnic_vf_ops;
-		break;
-	default:
-		dev_info(&adapter->pdev->dev, "Unknown function mode: %d\n",
-			priv_level);
-		return 0;
-	}
-	return adapter->fw_hal_version;
+	} else
+		adapter->nic_ops = &qlcnic_ops;
 }
 
 static int
@@ -671,10 +633,7 @@ qlcnic_setup_pci_map(struct qlcnic_adapter *adapter)
 	adapter->ahw.pci_base0 = mem_ptr0;
 	adapter->ahw.pci_len0 = pci_len0;
 
-	if (!qlcnic_get_driver_mode(adapter)) {
-		iounmap(adapter->ahw.pci_base0);
-		return -EIO;
-	}
+	qlcnic_check_vf(adapter);
 
 	adapter->ahw.ocm_win_crb = qlcnic_get_ioaddr(adapter,
 		QLCNIC_PCIX_PS_REG(PCIX_OCM_WINDOW_REG(adapter->ahw.pci_func)));
@@ -719,6 +678,9 @@ qlcnic_check_options(struct qlcnic_adapter *adapter)
 
 	adapter->fw_version = QLCNIC_VERSION_CODE(fw_major, fw_minor, fw_build);
 
+	if (!(adapter->flags & QLCNIC_ADAPTER_INITIALIZED))
+		if (qlcnic_read_mac_addr(adapter))
+			dev_warn(&pdev->dev, "failed to read mac addr\n");
 	if (adapter->portnum == 0) {
 		get_brd_name(adapter, brd_name);
 
@@ -837,6 +799,51 @@ qlcnic_set_netdev_features(struct qlcnic_adapter *adapter,
 }
 
 static int
+qlcnic_check_eswitch_mode(struct qlcnic_adapter *adapter)
+{
+	void __iomem *priv_op;
+	u32 op_mode, priv_level;
+	int err = 0;
+
+	if (adapter->flags & QLCNIC_ADAPTER_INITIALIZED)
+		return 0;
+
+	priv_op = adapter->ahw.pci_base0 + QLCNIC_DRV_OP_MODE;
+	op_mode = readl(priv_op);
+	priv_level = QLC_DEV_GET_DRV(op_mode, adapter->ahw.pci_func);
+
+	if (op_mode == QLC_DEV_DRV_DEFAULT)
+		priv_level = QLCNIC_MGMT_FUNC;
+	else
+		priv_level = QLC_DEV_GET_DRV(op_mode, adapter->ahw.pci_func);
+
+	if (adapter->capabilities & BIT_6) {
+		adapter->flags |= QLCNIC_ESWITCH_ENABLED;
+		if (priv_level == QLCNIC_MGMT_FUNC) {
+			adapter->op_mode = QLCNIC_MGMT_FUNC;
+			err = qlcnic_init_pci_info(adapter);
+			if (err)
+				return err;
+			/* Set privilege level for other functions */
+			qlcnic_set_function_modes(adapter);
+			dev_info(&adapter->pdev->dev,
+				"HAL Version: %d, Management function\n",
+				adapter->fw_hal_version);
+		} else if (priv_level == QLCNIC_PRIV_FUNC) {
+			adapter->op_mode = QLCNIC_PRIV_FUNC;
+			dev_info(&adapter->pdev->dev,
+				"HAL Version: %d, Privileged function\n",
+				adapter->fw_hal_version);
+		}
+	} else
+		adapter->flags &= ~QLCNIC_ESWITCH_ENABLED;
+
+	adapter->flags |= QLCNIC_ADAPTER_INITIALIZED;
+
+	return err;
+}
+
+static int
 qlcnic_set_default_offload_settings(struct qlcnic_adapter *adapter)
 {
 	struct qlcnic_esw_func_cfg esw_cfg;
@@ -1005,8 +1012,14 @@ set_dev_ready:
 	err = qlcnic_reset_npar_config(adapter);
 	if (err)
 		goto err_out;
-	qlcnic_dev_set_npar_ready(adapter);
 	qlcnic_check_options(adapter);
+	err = qlcnic_check_eswitch_mode(adapter);
+	if (err) {
+		dev_err(&adapter->pdev->dev,
+			"Memory allocation failed for eswitch\n");
+		goto err_out;
+	}
+	qlcnic_dev_set_npar_ready(adapter);
 	adapter->need_fw_reset = 0;
 
 	qlcnic_release_firmware(adapter);
@@ -1015,6 +1028,7 @@ set_dev_ready:
 err_out:
 	QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_FAILED);
 	dev_err(&adapter->pdev->dev, "Device state set to failed\n");
+
 	qlcnic_release_firmware(adapter);
 	return err;
 }
@@ -1419,9 +1433,6 @@ qlcnic_setup_netdev(struct qlcnic_adapter *adapter,
 		netdev->features |= NETIF_F_LRO;
 	netdev->irq = adapter->msix_entries[0].vector;
 
-	if (qlcnic_read_mac_addr(adapter))
-		dev_warn(&pdev->dev, "failed to read mac addr\n");
-
 	netif_carrier_off(netdev);
 	netif_stop_queue(netdev);
 
@@ -1515,9 +1526,6 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_out_iounmap;
 	}
 
-	if (qlcnic_read_mac_addr(adapter))
-		dev_warn(&pdev->dev, "failed to read mac addr\n");
-
 	err = qlcnic_setup_idc_param(adapter);
 	if (err)
 		goto err_out_iounmap;
-- 
1.7.1

