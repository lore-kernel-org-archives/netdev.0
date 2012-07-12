From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next 3/7] be2net: Fix initialization sequence for Lancer
Date: Thu, 12 Jul 2012 19:26:58 +0530
Message-ID: <67544f6d-a1ac-4433-96b1-53beceefe3e5@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:49161 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932522Ab2GLOBC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 10:01:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Invoke only required initialization routines for Lancer.
Remove invocation of unnecessary routines.

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |   76 ++++++++++++++++++++++++++-
 drivers/net/ethernet/emulex/benet/be_cmds.h |    4 +-
 drivers/net/ethernet/emulex/benet/be_main.c |   75 +++-----------------------
 3 files changed, 87 insertions(+), 68 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index d75c9fb..431f774 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -426,12 +426,65 @@ static int be_POST_stage_get(struct be_adapter *adapter, u16 *stage)
 		return 0;
 }
 
-int be_cmd_POST(struct be_adapter *adapter)
+int lancer_wait_ready(struct be_adapter *adapter)
+{
+#define SLIPORT_READY_TIMEOUT 30
+	u32 sliport_status;
+	int status = 0, i;
+
+	for (i = 0; i < SLIPORT_READY_TIMEOUT; i++) {
+		sliport_status = ioread32(adapter->db + SLIPORT_STATUS_OFFSET);
+		if (sliport_status & SLIPORT_STATUS_RDY_MASK)
+			break;
+
+		msleep(1000);
+	}
+
+	if (i == SLIPORT_READY_TIMEOUT)
+		status = -1;
+
+	return status;
+}
+
+int lancer_test_and_set_rdy_state(struct be_adapter *adapter)
+{
+	int status;
+	u32 sliport_status, err, reset_needed;
+	status = lancer_wait_ready(adapter);
+	if (!status) {
+		sliport_status = ioread32(adapter->db + SLIPORT_STATUS_OFFSET);
+		err = sliport_status & SLIPORT_STATUS_ERR_MASK;
+		reset_needed = sliport_status & SLIPORT_STATUS_RN_MASK;
+		if (err && reset_needed) {
+			iowrite32(SLI_PORT_CONTROL_IP_MASK,
+				  adapter->db + SLIPORT_CONTROL_OFFSET);
+
+			/* check adapter has corrected the error */
+			status = lancer_wait_ready(adapter);
+			sliport_status = ioread32(adapter->db +
+						  SLIPORT_STATUS_OFFSET);
+			sliport_status &= (SLIPORT_STATUS_ERR_MASK |
+						SLIPORT_STATUS_RN_MASK);
+			if (status || sliport_status)
+				status = -1;
+		} else if (err || reset_needed) {
+			status = -1;
+		}
+	}
+	return status;
+}
+
+int be_fw_wait_ready(struct be_adapter *adapter)
 {
 	u16 stage;
 	int status, timeout = 0;
 	struct device *dev = &adapter->pdev->dev;
 
+	if (lancer_chip(adapter)) {
+		status = lancer_wait_ready(adapter);
+		return status;
+	}
+
 	do {
 		status = be_POST_stage_get(adapter, &stage);
 		if (status) {
@@ -562,6 +615,9 @@ int be_cmd_fw_init(struct be_adapter *adapter)
 	u8 *wrb;
 	int status;
 
+	if (lancer_chip(adapter))
+		return 0;
+
 	if (mutex_lock_interruptible(&adapter->mbox_lock))
 		return -1;
 
@@ -589,6 +645,9 @@ int be_cmd_fw_clean(struct be_adapter *adapter)
 	u8 *wrb;
 	int status;
 
+	if (lancer_chip(adapter))
+		return 0;
+
 	if (mutex_lock_interruptible(&adapter->mbox_lock))
 		return -1;
 
@@ -607,6 +666,7 @@ int be_cmd_fw_clean(struct be_adapter *adapter)
 	mutex_unlock(&adapter->mbox_lock);
 	return status;
 }
+
 int be_cmd_eq_create(struct be_adapter *adapter,
 		struct be_queue_info *eq, int eq_delay)
 {
@@ -1682,6 +1742,20 @@ int be_cmd_reset_function(struct be_adapter *adapter)
 	struct be_cmd_req_hdr *req;
 	int status;
 
+	if (lancer_chip(adapter)) {
+		status = lancer_wait_ready(adapter);
+		if (!status) {
+			iowrite32(SLI_PORT_CONTROL_IP_MASK,
+				  adapter->db + SLIPORT_CONTROL_OFFSET);
+			status = lancer_test_and_set_rdy_state(adapter);
+		}
+		if (status) {
+			dev_err(&adapter->pdev->dev,
+				"Adapter in non recoverable error\n");
+		}
+		return status;
+	}
+
 	if (mutex_lock_interruptible(&adapter->mbox_lock))
 		return -1;
 
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index 3c938f5..cfc0620 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -1656,7 +1656,7 @@ struct be_cmd_req_set_ext_fat_caps {
 };
 
 extern int be_pci_fnum_get(struct be_adapter *adapter);
-extern int be_cmd_POST(struct be_adapter *adapter);
+extern int be_fw_wait_ready(struct be_adapter *adapter);
 extern int be_cmd_mac_addr_query(struct be_adapter *adapter, u8 *mac_addr,
 			u8 type, bool permanent, u32 if_handle, u32 pmac_id);
 extern int be_cmd_pmac_add(struct be_adapter *adapter, u8 *mac_addr,
@@ -1765,4 +1765,6 @@ extern int be_cmd_get_ext_fat_capabilites(struct be_adapter *adapter,
 extern int be_cmd_set_ext_fat_capabilites(struct be_adapter *adapter,
 					  struct be_dma_mem *cmd,
 					  struct be_fat_conf_params *cfgs);
+extern int lancer_wait_ready(struct be_adapter *adapter);
+extern int lancer_test_and_set_rdy_state(struct be_adapter *adapter);
 
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 2436c3a..a3641ba 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2573,9 +2573,6 @@ static int be_clear(struct be_adapter *adapter)
 	be_tx_queues_destroy(adapter);
 	be_evt_queues_destroy(adapter);
 
-	/* tell fw we're done with firing cmds */
-	be_cmd_fw_clean(adapter);
-
 	be_msix_disable(adapter);
 	return 0;
 }
@@ -3476,6 +3473,9 @@ static void __devexit be_remove(struct pci_dev *pdev)
 
 	be_clear(adapter);
 
+	/* tell fw we're done with firing cmds */
+	be_cmd_fw_clean(adapter);
+
 	be_stats_cleanup(adapter);
 
 	be_ctrl_cleanup(adapter);
@@ -3625,54 +3625,6 @@ static int be_dev_type_check(struct be_adapter *adapter)
 	return 0;
 }
 
-static int lancer_wait_ready(struct be_adapter *adapter)
-{
-#define SLIPORT_READY_TIMEOUT 30
-	u32 sliport_status;
-	int status = 0, i;
-
-	for (i = 0; i < SLIPORT_READY_TIMEOUT; i++) {
-		sliport_status = ioread32(adapter->db + SLIPORT_STATUS_OFFSET);
-		if (sliport_status & SLIPORT_STATUS_RDY_MASK)
-			break;
-
-		msleep(1000);
-	}
-
-	if (i == SLIPORT_READY_TIMEOUT)
-		status = -1;
-
-	return status;
-}
-
-static int lancer_test_and_set_rdy_state(struct be_adapter *adapter)
-{
-	int status;
-	u32 sliport_status, err, reset_needed;
-	status = lancer_wait_ready(adapter);
-	if (!status) {
-		sliport_status = ioread32(adapter->db + SLIPORT_STATUS_OFFSET);
-		err = sliport_status & SLIPORT_STATUS_ERR_MASK;
-		reset_needed = sliport_status & SLIPORT_STATUS_RN_MASK;
-		if (err && reset_needed) {
-			iowrite32(SLI_PORT_CONTROL_IP_MASK,
-					adapter->db + SLIPORT_CONTROL_OFFSET);
-
-			/* check adapter has corrected the error */
-			status = lancer_wait_ready(adapter);
-			sliport_status = ioread32(adapter->db +
-							SLIPORT_STATUS_OFFSET);
-			sliport_status &= (SLIPORT_STATUS_ERR_MASK |
-						SLIPORT_STATUS_RN_MASK);
-			if (status || sliport_status)
-				status = -1;
-		} else if (err || reset_needed) {
-			status = -1;
-		}
-	}
-	return status;
-}
-
 static void lancer_test_and_recover_fn_err(struct be_adapter *adapter)
 {
 	int status;
@@ -3820,22 +3772,9 @@ static int __devinit be_probe(struct pci_dev *pdev,
 	if (status)
 		goto free_netdev;
 
-	if (lancer_chip(adapter)) {
-		status = lancer_wait_ready(adapter);
-		if (!status) {
-			iowrite32(SLI_PORT_CONTROL_IP_MASK,
-					adapter->db + SLIPORT_CONTROL_OFFSET);
-			status = lancer_test_and_set_rdy_state(adapter);
-		}
-		if (status) {
-			dev_err(&pdev->dev, "Adapter in non recoverable error\n");
-			goto ctrl_clean;
-		}
-	}
-
 	/* sync up with fw's ready state */
 	if (be_physfn(adapter)) {
-		status = be_cmd_POST(adapter);
+		status = be_fw_wait_ready(adapter);
 		if (status)
 			goto ctrl_clean;
 	}
@@ -4033,7 +3972,7 @@ static pci_ers_result_t be_eeh_reset(struct pci_dev *pdev)
 	pci_restore_state(pdev);
 
 	/* Check if card is ok and fw is ready */
-	status = be_cmd_POST(adapter);
+	status = be_fw_wait_ready(adapter);
 	if (status)
 		return PCI_ERS_RESULT_DISCONNECT;
 
@@ -4055,6 +3994,10 @@ static void be_eeh_resume(struct pci_dev *pdev)
 	if (status)
 		goto err;
 
+	status = be_cmd_reset_function(adapter);
+	if (status)
+		goto err;
+
 	status = be_setup(adapter);
 	if (status)
 		goto err;
-- 
1.6.0.2
