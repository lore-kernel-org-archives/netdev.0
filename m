From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next 4/7] be2net: Activate new FW after FW download for Lancer
Date: Thu, 12 Jul 2012 19:27:09 +0530
Message-ID: <e78e8a6c-b8fd-40a3-b321-bf873474e40f@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:9045 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161096Ab2GLOBR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 10:01:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After FW download, activate new FW by invoking FW reset.
Recreate rings once new FW is operational.

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |   20 +++-
 drivers/net/ethernet/emulex/benet/be_cmds.c |   13 +-
 drivers/net/ethernet/emulex/benet/be_cmds.h |   15 ++-
 drivers/net/ethernet/emulex/benet/be_hw.h   |    7 +-
 drivers/net/ethernet/emulex/benet/be_main.c |  203 +++++++++++++++++++--------
 5 files changed, 180 insertions(+), 78 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 748e870..e2dfe31 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -389,6 +389,7 @@ struct be_adapter {
 	struct delayed_work work;
 	u16 work_counter;
 
+	struct delayed_work func_recovery_work;
 	u32 flags;
 	/* Ethtool knobs and info */
 	char fw_ver[FW_VER_LEN];
@@ -396,9 +397,10 @@ struct be_adapter {
 	u32 *pmac_id;		/* MAC addr handle used by BE card */
 	u32 beacon_state;	/* for set_phys_id */
 
-	bool eeh_err;
-	bool ue_detected;
+	bool eeh_error;
 	bool fw_timeout;
+	bool hw_error;
+
 	u32 port_num;
 	bool promiscuous;
 	u32 function_mode;
@@ -599,7 +601,19 @@ static inline bool be_multi_rxq(const struct be_adapter *adapter)
 
 static inline bool be_error(struct be_adapter *adapter)
 {
-	return adapter->eeh_err || adapter->ue_detected || adapter->fw_timeout;
+	return adapter->eeh_error || adapter->hw_error || adapter->fw_timeout;
+}
+
+static inline bool be_crit_error(struct be_adapter *adapter)
+{
+	return adapter->eeh_error || adapter->hw_error;
+}
+
+static inline void  be_clear_all_error(struct be_adapter *adapter)
+{
+	adapter->eeh_error = false;
+	adapter->hw_error = false;
+	adapter->fw_timeout = false;
 }
 
 static inline bool be_is_wol_excluded(struct be_adapter *adapter)
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 431f774..34dfc0c 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -349,7 +349,7 @@ static int be_mbox_db_ready_wait(struct be_adapter *adapter, void __iomem *db)
 		if (msecs > 4000) {
 			dev_err(&adapter->pdev->dev, "FW not responding\n");
 			adapter->fw_timeout = true;
-			be_detect_dump_ue(adapter);
+			be_detect_error(adapter);
 			return -1;
 		}
 
@@ -1869,8 +1869,9 @@ err:
 }
 
 int lancer_cmd_write_object(struct be_adapter *adapter, struct be_dma_mem *cmd,
-			u32 data_size, u32 data_offset, const char *obj_name,
-			u32 *data_written, u8 *addn_status)
+			    u32 data_size, u32 data_offset,
+			    const char *obj_name, u32 *data_written,
+			    u8 *change_status, u8 *addn_status)
 {
 	struct be_mcc_wrb *wrb;
 	struct lancer_cmd_req_write_object *req;
@@ -1926,10 +1927,12 @@ int lancer_cmd_write_object(struct be_adapter *adapter, struct be_dma_mem *cmd,
 		status = adapter->flash_status;
 
 	resp = embedded_payload(wrb);
-	if (!status)
+	if (!status) {
 		*data_written = le32_to_cpu(resp->actual_write_len);
-	else
+		*change_status = resp->change_status;
+	} else {
 		*addn_status = resp->additional_status;
+	}
 
 	return status;
 
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index cfc0620..c1324e7 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -1163,6 +1163,8 @@ struct lancer_cmd_req_write_object {
 	u32 addr_high;
 };
 
+#define LANCER_NO_RESET_NEEDED		0x00
+#define LANCER_FW_RESET_NEEDED		0x02
 struct lancer_cmd_resp_write_object {
 	u8 opcode;
 	u8 subsystem;
@@ -1173,6 +1175,8 @@ struct lancer_cmd_resp_write_object {
 	u32 resp_len;
 	u32 actual_resp_len;
 	u32 actual_write_len;
+	u8 change_status;
+	u8 rsvd3[3];
 };
 
 /************************ Lancer Read FW info **************/
@@ -1718,10 +1722,11 @@ extern int be_cmd_write_flashrom(struct be_adapter *adapter,
 			struct be_dma_mem *cmd, u32 flash_oper,
 			u32 flash_opcode, u32 buf_size);
 extern int lancer_cmd_write_object(struct be_adapter *adapter,
-				struct be_dma_mem *cmd,
-				u32 data_size, u32 data_offset,
-				const char *obj_name,
-				u32 *data_written, u8 *addn_status);
+				   struct be_dma_mem *cmd,
+				   u32 data_size, u32 data_offset,
+				   const char *obj_name,
+				   u32 *data_written, u8 *change_status,
+				   u8 *addn_status);
 int lancer_cmd_read_object(struct be_adapter *adapter, struct be_dma_mem *cmd,
 		u32 data_size, u32 data_offset, const char *obj_name,
 		u32 *data_read, u32 *eof, u8 *addn_status);
@@ -1744,7 +1749,7 @@ extern int be_cmd_set_loopback(struct be_adapter *adapter, u8 port_num,
 				u8 loopback_type, u8 enable);
 extern int be_cmd_get_phy_info(struct be_adapter *adapter);
 extern int be_cmd_set_qos(struct be_adapter *adapter, u32 bps, u32 domain);
-extern void be_detect_dump_ue(struct be_adapter *adapter);
+extern void be_detect_error(struct be_adapter *adapter);
 extern int be_cmd_get_die_temperature(struct be_adapter *adapter);
 extern int be_cmd_get_cntl_attributes(struct be_adapter *adapter);
 extern int be_cmd_req_native_mode(struct be_adapter *adapter);
diff --git a/drivers/net/ethernet/emulex/benet/be_hw.h b/drivers/net/ethernet/emulex/benet/be_hw.h
index 7c8a710..b755f70 100644
--- a/drivers/net/ethernet/emulex/benet/be_hw.h
+++ b/drivers/net/ethernet/emulex/benet/be_hw.h
@@ -45,18 +45,19 @@
 #define POST_STAGE_ARMFW_RDY		0xc000	/* FW is done with POST */
 
 
-/* Lancer SLIPORT_CONTROL SLIPORT_STATUS registers */
+/* Lancer SLIPORT registers */
 #define SLIPORT_STATUS_OFFSET		0x404
 #define SLIPORT_CONTROL_OFFSET		0x408
 #define SLIPORT_ERROR1_OFFSET		0x40C
 #define SLIPORT_ERROR2_OFFSET		0x410
+#define PHYSDEV_CONTROL_OFFSET		0x414
 
 #define SLIPORT_STATUS_ERR_MASK		0x80000000
 #define SLIPORT_STATUS_RN_MASK		0x01000000
 #define SLIPORT_STATUS_RDY_MASK		0x00800000
-
-
 #define SLI_PORT_CONTROL_IP_MASK	0x08000000
+#define PHYSDEV_CONTROL_FW_RESET_MASK	0x00000002
+#define PHYSDEV_CONTROL_INP_MASK	0x40000000
 
 /********* Memory BAR register ************/
 #define PCICFG_MEMBAR_CTRL_INT_CTRL_OFFSET 	0xfc
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index a3641ba..9e7dbd5 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -155,7 +155,7 @@ static void be_intr_set(struct be_adapter *adapter, bool enable)
 {
 	u32 reg, enabled;
 
-	if (adapter->eeh_err)
+	if (adapter->eeh_error)
 		return;
 
 	pci_read_config_dword(adapter->pdev, PCICFG_MEMBAR_CTRL_INT_CTRL_OFFSET,
@@ -201,7 +201,7 @@ static void be_eq_notify(struct be_adapter *adapter, u16 qid,
 	val |= ((qid & DB_EQ_RING_ID_EXT_MASK) <<
 			DB_EQ_RING_ID_EXT_MASK_SHIFT);
 
-	if (adapter->eeh_err)
+	if (adapter->eeh_error)
 		return;
 
 	if (arm)
@@ -220,7 +220,7 @@ void be_cq_notify(struct be_adapter *adapter, u16 qid, bool arm, u16 num_popped)
 	val |= ((qid & DB_CQ_RING_ID_EXT_MASK) <<
 			DB_CQ_RING_ID_EXT_MASK_SHIFT);
 
-	if (adapter->eeh_err)
+	if (adapter->eeh_error)
 		return;
 
 	if (arm)
@@ -2098,13 +2098,13 @@ int be_poll(struct napi_struct *napi, int budget)
 	return max_work;
 }
 
-void be_detect_dump_ue(struct be_adapter *adapter)
+void be_detect_error(struct be_adapter *adapter)
 {
 	u32 ue_lo = 0, ue_hi = 0, ue_lo_mask = 0, ue_hi_mask = 0;
 	u32 sliport_status = 0, sliport_err1 = 0, sliport_err2 = 0;
 	u32 i;
 
-	if (adapter->eeh_err || adapter->ue_detected)
+	if (be_crit_error(adapter))
 		return;
 
 	if (lancer_chip(adapter)) {
@@ -2125,16 +2125,24 @@ void be_detect_dump_ue(struct be_adapter *adapter)
 		pci_read_config_dword(adapter->pdev,
 				PCICFG_UE_STATUS_HI_MASK, &ue_hi_mask);
 
-		ue_lo = (ue_lo & (~ue_lo_mask));
-		ue_hi = (ue_hi & (~ue_hi_mask));
+		ue_lo = (ue_lo & ~ue_lo_mask);
+		ue_hi = (ue_hi & ~ue_hi_mask);
 	}
 
 	if (ue_lo || ue_hi ||
 		sliport_status & SLIPORT_STATUS_ERR_MASK) {
-		adapter->ue_detected = true;
-		adapter->eeh_err = true;
+		adapter->hw_error = true;
 		dev_err(&adapter->pdev->dev,
-			"Unrecoverable error in the card\n");
+			"Error detected in the card\n");
+	}
+
+	if (sliport_status & SLIPORT_STATUS_ERR_MASK) {
+		dev_err(&adapter->pdev->dev,
+			"ERR: sliport status 0x%x\n", sliport_status);
+		dev_err(&adapter->pdev->dev,
+			"ERR: sliport error1 0x%x\n", sliport_err1);
+		dev_err(&adapter->pdev->dev,
+			"ERR: sliport error2 0x%x\n", sliport_err2);
 	}
 
 	if (ue_lo) {
@@ -2144,6 +2152,7 @@ void be_detect_dump_ue(struct be_adapter *adapter)
 				"UE: %s bit set\n", ue_status_low_desc[i]);
 		}
 	}
+
 	if (ue_hi) {
 		for (i = 0; ue_hi; ue_hi >>= 1, i++) {
 			if (ue_hi & 1)
@@ -2152,14 +2161,6 @@ void be_detect_dump_ue(struct be_adapter *adapter)
 		}
 	}
 
-	if (sliport_status & SLIPORT_STATUS_ERR_MASK) {
-		dev_err(&adapter->pdev->dev,
-			"sliport status 0x%x\n", sliport_status);
-		dev_err(&adapter->pdev->dev,
-			"sliport error1 0x%x\n", sliport_err1);
-		dev_err(&adapter->pdev->dev,
-			"sliport error2 0x%x\n", sliport_err2);
-	}
 }
 
 static void be_msix_disable(struct be_adapter *adapter)
@@ -3067,6 +3068,40 @@ static int get_ufigen_type(struct flash_file_hdr_g2 *fhdr)
 		return 0;
 }
 
+static int lancer_wait_idle(struct be_adapter *adapter)
+{
+#define SLIPORT_IDLE_TIMEOUT 30
+	u32 reg_val;
+	int status = 0, i;
+
+	for (i = 0; i < SLIPORT_IDLE_TIMEOUT; i++) {
+		reg_val = ioread32(adapter->db + PHYSDEV_CONTROL_OFFSET);
+		if ((reg_val & PHYSDEV_CONTROL_INP_MASK) == 0)
+			break;
+
+		ssleep(1);
+	}
+
+	if (i == SLIPORT_IDLE_TIMEOUT)
+		status = -1;
+
+	return status;
+}
+
+static int lancer_fw_reset(struct be_adapter *adapter)
+{
+	int status = 0;
+
+	status = lancer_wait_idle(adapter);
+	if (status)
+		return status;
+
+	iowrite32(PHYSDEV_CONTROL_FW_RESET_MASK, adapter->db +
+		  PHYSDEV_CONTROL_OFFSET);
+
+	return status;
+}
+
 static int lancer_fw_download(struct be_adapter *adapter,
 				const struct firmware *fw)
 {
@@ -3081,6 +3116,7 @@ static int lancer_fw_download(struct be_adapter *adapter,
 	u32 offset = 0;
 	int status = 0;
 	u8 add_status = 0;
+	u8 change_status;
 
 	if (!IS_ALIGNED(fw->size, sizeof(u32))) {
 		dev_err(&adapter->pdev->dev,
@@ -3113,9 +3149,10 @@ static int lancer_fw_download(struct be_adapter *adapter,
 		memcpy(dest_image_ptr, data_ptr, chunk_size);
 
 		status = lancer_cmd_write_object(adapter, &flash_cmd,
-				chunk_size, offset, LANCER_FW_DOWNLOAD_LOCATION,
-				&data_written, &add_status);
-
+						 chunk_size, offset,
+						 LANCER_FW_DOWNLOAD_LOCATION,
+						 &data_written, &change_status,
+						 &add_status);
 		if (status)
 			break;
 
@@ -3127,8 +3164,10 @@ static int lancer_fw_download(struct be_adapter *adapter,
 	if (!status) {
 		/* Commit the FW written */
 		status = lancer_cmd_write_object(adapter, &flash_cmd,
-					0, offset, LANCER_FW_DOWNLOAD_LOCATION,
-					&data_written, &add_status);
+						 0, offset,
+						 LANCER_FW_DOWNLOAD_LOCATION,
+						 &data_written, &change_status,
+						 &add_status);
 	}
 
 	dma_free_coherent(&adapter->pdev->dev, flash_cmd.size, flash_cmd.va,
@@ -3141,6 +3180,20 @@ static int lancer_fw_download(struct be_adapter *adapter,
 		goto lancer_fw_exit;
 	}
 
+	if (change_status == LANCER_FW_RESET_NEEDED) {
+		status = lancer_fw_reset(adapter);
+		if (status) {
+			dev_err(&adapter->pdev->dev,
+				"Adapter busy for FW reset.\n"
+				"New FW will not be active.\n");
+			goto lancer_fw_exit;
+		}
+	} else if (change_status != LANCER_NO_RESET_NEEDED) {
+			dev_err(&adapter->pdev->dev,
+				"System reboot required for new FW"
+				" to be active\n");
+	}
+
 	dev_info(&adapter->pdev->dev, "Firmware flashed successfully\n");
 lancer_fw_exit:
 	return status;
@@ -3469,6 +3522,8 @@ static void __devexit be_remove(struct pci_dev *pdev)
 
 	be_roce_dev_remove(adapter);
 
+	cancel_delayed_work_sync(&adapter->func_recovery_work);
+
 	unregister_netdev(adapter->netdev);
 
 	be_clear(adapter);
@@ -3625,53 +3680,68 @@ static int be_dev_type_check(struct be_adapter *adapter)
 	return 0;
 }
 
-static void lancer_test_and_recover_fn_err(struct be_adapter *adapter)
+static int lancer_recover_func(struct be_adapter *adapter)
 {
 	int status;
-	u32 sliport_status;
 
-	if (adapter->eeh_err || adapter->ue_detected)
-		return;
+	status = lancer_test_and_set_rdy_state(adapter);
+	if (status)
+		goto err;
 
-	sliport_status = ioread32(adapter->db + SLIPORT_STATUS_OFFSET);
+	if (netif_running(adapter->netdev))
+		be_close(adapter->netdev);
 
-	if (sliport_status & SLIPORT_STATUS_ERR_MASK) {
-		dev_err(&adapter->pdev->dev,
-				"Adapter in error state."
-				"Trying to recover.\n");
+	be_clear(adapter);
+
+	adapter->hw_error = false;
+	adapter->fw_timeout = false;
+
+	status = be_setup(adapter);
+	if (status)
+		goto err;
 
-		status = lancer_test_and_set_rdy_state(adapter);
+	if (netif_running(adapter->netdev)) {
+		status = be_open(adapter->netdev);
 		if (status)
 			goto err;
+	}
 
-		netif_device_detach(adapter->netdev);
+	dev_err(&adapter->pdev->dev,
+		"Adapter SLIPORT recovery succeeded\n");
+	return 0;
+err:
+	dev_err(&adapter->pdev->dev,
+		"Adapter SLIPORT recovery failed\n");
 
-		if (netif_running(adapter->netdev))
-			be_close(adapter->netdev);
+	return status;
+}
+
+static void be_func_recovery_task(struct work_struct *work)
+{
+	struct be_adapter *adapter =
+		container_of(work, struct be_adapter,  func_recovery_work.work);
+	int status;
 
-		be_clear(adapter);
+	be_detect_error(adapter);
 
-		adapter->fw_timeout = false;
+	if (adapter->hw_error && lancer_chip(adapter)) {
 
-		status = be_setup(adapter);
-		if (status)
-			goto err;
+		if (adapter->eeh_error)
+			goto out;
 
-		if (netif_running(adapter->netdev)) {
-			status = be_open(adapter->netdev);
-			if (status)
-				goto err;
-		}
+		rtnl_lock();
+		netif_device_detach(adapter->netdev);
+		rtnl_unlock();
 
-		netif_device_attach(adapter->netdev);
+		status = lancer_recover_func(adapter);
 
-		dev_err(&adapter->pdev->dev,
-				"Adapter error recovery succeeded\n");
+		if (!status)
+			netif_device_attach(adapter->netdev);
 	}
-	return;
-err:
-	dev_err(&adapter->pdev->dev,
-			"Adapter error recovery failed\n");
+
+out:
+	schedule_delayed_work(&adapter->func_recovery_work,
+			      msecs_to_jiffies(1000));
 }
 
 static void be_worker(struct work_struct *work)
@@ -3682,11 +3752,6 @@ static void be_worker(struct work_struct *work)
 	struct be_eq_obj *eqo;
 	int i;
 
-	if (lancer_chip(adapter))
-		lancer_test_and_recover_fn_err(adapter);
-
-	be_detect_dump_ue(adapter);
-
 	/* when interrupts are not yet enabled, just reap any pending
 	* mcc completions */
 	if (!netif_running(adapter->netdev)) {
@@ -3805,6 +3870,7 @@ static int __devinit be_probe(struct pci_dev *pdev,
 		goto stats_clean;
 
 	INIT_DELAYED_WORK(&adapter->work, be_worker);
+	INIT_DELAYED_WORK(&adapter->func_recovery_work, be_func_recovery_task);
 	adapter->rx_fc = adapter->tx_fc = true;
 
 	status = be_setup(adapter);
@@ -3818,6 +3884,8 @@ static int __devinit be_probe(struct pci_dev *pdev,
 
 	be_roce_dev_add(adapter);
 
+	schedule_delayed_work(&adapter->func_recovery_work,
+			      msecs_to_jiffies(1000));
 	dev_info(&pdev->dev, "%s: %s port %d\n", netdev->name, nic_name(pdev),
 		adapter->port_num);
 
@@ -3851,6 +3919,8 @@ static int be_suspend(struct pci_dev *pdev, pm_message_t state)
 	if (adapter->wol)
 		be_setup_wol(adapter, true);
 
+	cancel_delayed_work_sync(&adapter->func_recovery_work);
+
 	netif_device_detach(netdev);
 	if (netif_running(netdev)) {
 		rtnl_lock();
@@ -3891,6 +3961,9 @@ static int be_resume(struct pci_dev *pdev)
 		be_open(netdev);
 		rtnl_unlock();
 	}
+
+	schedule_delayed_work(&adapter->func_recovery_work,
+			      msecs_to_jiffies(1000));
 	netif_device_attach(netdev);
 
 	if (adapter->wol)
@@ -3910,6 +3983,7 @@ static void be_shutdown(struct pci_dev *pdev)
 		return;
 
 	cancel_delayed_work_sync(&adapter->work);
+	cancel_delayed_work_sync(&adapter->func_recovery_work);
 
 	netif_device_detach(adapter->netdev);
 
@@ -3929,9 +4003,13 @@ static pci_ers_result_t be_eeh_err_detected(struct pci_dev *pdev,
 
 	dev_err(&adapter->pdev->dev, "EEH error detected\n");
 
-	adapter->eeh_err = true;
+	adapter->eeh_error = true;
+
+	cancel_delayed_work_sync(&adapter->func_recovery_work);
 
+	rtnl_lock();
 	netif_device_detach(netdev);
+	rtnl_unlock();
 
 	if (netif_running(netdev)) {
 		rtnl_lock();
@@ -3959,9 +4037,7 @@ static pci_ers_result_t be_eeh_reset(struct pci_dev *pdev)
 	int status;
 
 	dev_info(&adapter->pdev->dev, "EEH reset\n");
-	adapter->eeh_err = false;
-	adapter->ue_detected = false;
-	adapter->fw_timeout = false;
+	be_clear_all_error(adapter);
 
 	status = pci_enable_device(pdev);
 	if (status)
@@ -4007,6 +4083,9 @@ static void be_eeh_resume(struct pci_dev *pdev)
 		if (status)
 			goto err;
 	}
+
+	schedule_delayed_work(&adapter->func_recovery_work,
+			      msecs_to_jiffies(1000));
 	netif_device_attach(netdev);
 	return;
 err:
-- 
1.6.0.2
