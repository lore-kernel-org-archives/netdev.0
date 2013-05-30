From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net 2/2] be2net: Fix crash on 2nd invocation of PCI AER/EEH error_detected hook
Date: Thu, 30 May 2013 14:26:17 +0530
Message-ID: <43df230c-ad73-414a-8de0-2c4f9a5f3d71@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Somnath Kotur <somnath.kotur@emulex.com>,
	Kalesh AP <kalesh.purayil@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:38639 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967933Ab3E3I5S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 04:57:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During a PCI EEH/AER error recovery flow, if the device did not successfully
restart, the error_detected() hook may be called a second time with a
"perm_failure" state. This patch skips over driver cleanup for the second
invocation of the callback.

Also, Lancer error recovery code is fixed-up to handle these changes.

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Somnath kotur <somnath.kotur@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |    6 ++--
 drivers/net/ethernet/emulex/benet/be_main.c |   48 +++++++++++++--------------
 2 files changed, 26 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index a236ecd..1db2df6 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -562,7 +562,7 @@ int lancer_test_and_set_rdy_state(struct be_adapter *adapter)
 
 	resource_error = lancer_provisioning_error(adapter);
 	if (resource_error)
-		return -1;
+		return -EAGAIN;
 
 	status = lancer_wait_ready(adapter);
 	if (!status) {
@@ -590,8 +590,8 @@ int lancer_test_and_set_rdy_state(struct be_adapter *adapter)
 	 * when PF provisions resources.
 	 */
 	resource_error = lancer_provisioning_error(adapter);
-	if (status == -1 && !resource_error)
-		adapter->eeh_error = true;
+	if (resource_error)
+		status = -EAGAIN;
 
 	return status;
 }
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 32a6927..8bc1b21 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -4098,6 +4098,7 @@ static int be_get_initial_config(struct be_adapter *adapter)
 
 static int lancer_recover_func(struct be_adapter *adapter)
 {
+	struct device *dev = &adapter->pdev->dev;
 	int status;
 
 	status = lancer_test_and_set_rdy_state(adapter);
@@ -4109,8 +4110,7 @@ static int lancer_recover_func(struct be_adapter *adapter)
 
 	be_clear(adapter);
 
-	adapter->hw_error = false;
-	adapter->fw_timeout = false;
+	be_clear_all_error(adapter);
 
 	status = be_setup(adapter);
 	if (status)
@@ -4122,13 +4122,13 @@ static int lancer_recover_func(struct be_adapter *adapter)
 			goto err;
 	}
 
-	dev_err(&adapter->pdev->dev,
-		"Adapter SLIPORT recovery succeeded\n");
+	dev_err(dev, "Error recovery successful\n");
 	return 0;
 err:
-	if (adapter->eeh_error)
-		dev_err(&adapter->pdev->dev,
-			"Adapter SLIPORT recovery failed\n");
+	if (status == -EAGAIN)
+		dev_err(dev, "Waiting for resource provisioning\n");
+	else
+		dev_err(dev, "Error recovery failed\n");
 
 	return status;
 }
@@ -4137,28 +4137,27 @@ static void be_func_recovery_task(struct work_struct *work)
 {
 	struct be_adapter *adapter =
 		container_of(work, struct be_adapter,  func_recovery_work.work);
-	int status;
+	int status = 0;
 
 	be_detect_error(adapter);
 
 	if (adapter->hw_error && lancer_chip(adapter)) {
 
-		if (adapter->eeh_error)
-			goto out;
-
 		rtnl_lock();
 		netif_device_detach(adapter->netdev);
 		rtnl_unlock();
 
 		status = lancer_recover_func(adapter);
-
 		if (!status)
 			netif_device_attach(adapter->netdev);
 	}
 
-out:
-	schedule_delayed_work(&adapter->func_recovery_work,
-			      msecs_to_jiffies(1000));
+	/* In Lancer, for all errors other than provisioning error (-EAGAIN),
+	 * no need to attempt further recovery.
+	 */
+	if (!status || status == -EAGAIN)
+		schedule_delayed_work(&adapter->func_recovery_work,
+				      msecs_to_jiffies(1000));
 }
 
 static void be_worker(struct work_struct *work)
@@ -4441,20 +4440,19 @@ static pci_ers_result_t be_eeh_err_detected(struct pci_dev *pdev,
 
 	dev_err(&adapter->pdev->dev, "EEH error detected\n");
 
-	adapter->eeh_error = true;
-
-	cancel_delayed_work_sync(&adapter->func_recovery_work);
+	if (!adapter->eeh_error) {
+		adapter->eeh_error = true;
 
-	rtnl_lock();
-	netif_device_detach(netdev);
-	rtnl_unlock();
+		cancel_delayed_work_sync(&adapter->func_recovery_work);
 
-	if (netif_running(netdev)) {
 		rtnl_lock();
-		be_close(netdev);
+		netif_device_detach(netdev);
+		if (netif_running(netdev))
+			be_close(netdev);
 		rtnl_unlock();
+
+		be_clear(adapter);
 	}
-	be_clear(adapter);
 
 	if (state == pci_channel_io_perm_failure)
 		return PCI_ERS_RESULT_DISCONNECT;
@@ -4479,7 +4477,6 @@ static pci_ers_result_t be_eeh_reset(struct pci_dev *pdev)
 	int status;
 
 	dev_info(&adapter->pdev->dev, "EEH reset\n");
-	be_clear_all_error(adapter);
 
 	status = pci_enable_device(pdev);
 	if (status)
@@ -4497,6 +4494,7 @@ static pci_ers_result_t be_eeh_reset(struct pci_dev *pdev)
 		return PCI_ERS_RESULT_DISCONNECT;
 
 	pci_cleanup_aer_uncorrect_error_status(pdev);
+	be_clear_all_error(adapter);
 	return PCI_ERS_RESULT_RECOVERED;
 }
 
-- 
1.6.0.2
