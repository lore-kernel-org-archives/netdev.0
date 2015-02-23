From: Sathya Perla <sathya.perla@emulex.com>
Subject: [net-next PATCH 4/9] be2net: use a wrapper to schedule and cancel error detection task
Date: Mon, 23 Feb 2015 04:20:11 -0500
Message-ID: <1424683216-29611-5-git-send-email-sathya.perla@emulex.com>
References: <1424683216-29611-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.emulex.com ([138.239.224.99]:32982 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752593AbbBWJRQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 04:17:16 -0500
In-Reply-To: <1424683216-29611-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also rename func_recovery_work/task to err_detection_work/task as error
detection is the primary goal of this task while recovery is not guaranteed.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |  3 +-
 drivers/net/ethernet/emulex/benet/be_main.c | 45 +++++++++++++++++++----------
 2 files changed, 32 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index ad33bf1..fac806a 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -376,6 +376,7 @@ enum vf_state {
 #define BE_FLAGS_VXLAN_OFFLOADS			BIT(8)
 #define BE_FLAGS_SETUP_DONE			BIT(9)
 #define BE_FLAGS_EVT_INCOMPATIBLE_SFP		BIT(10)
+#define BE_FLAGS_ERR_DETECTION_SCHEDULED	BIT(11)
 
 #define BE_UC_PMAC_COUNT			30
 #define BE_VF_UC_PMAC_COUNT			2
@@ -501,7 +502,7 @@ struct be_adapter {
 	struct delayed_work work;
 	u16 work_counter;
 
-	struct delayed_work func_recovery_work;
+	struct delayed_work be_err_detection_work;
 	u32 flags;
 	u32 cmd_privileges;
 	/* Ethtool knobs and info */
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index fda2e5d..74ba995 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3363,6 +3363,14 @@ static void be_cancel_worker(struct be_adapter *adapter)
 	}
 }
 
+static void be_cancel_err_detection(struct be_adapter *adapter)
+{
+	if (adapter->flags & BE_FLAGS_ERR_DETECTION_SCHEDULED) {
+		cancel_delayed_work_sync(&adapter->be_err_detection_work);
+		adapter->flags &= ~BE_FLAGS_ERR_DETECTION_SCHEDULED;
+	}
+}
+
 static void be_mac_clear(struct be_adapter *adapter)
 {
 	if (adapter->pmac_id) {
@@ -3847,6 +3855,13 @@ static void be_schedule_worker(struct be_adapter *adapter)
 	adapter->flags |= BE_FLAGS_WORKER_SCHEDULED;
 }
 
+static void be_schedule_err_detection(struct be_adapter *adapter)
+{
+	schedule_delayed_work(&adapter->be_err_detection_work,
+			      msecs_to_jiffies(1000));
+	adapter->flags |= BE_FLAGS_ERR_DETECTION_SCHEDULED;
+}
+
 static int be_setup_queues(struct be_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
@@ -4925,10 +4940,11 @@ err:
 	return status;
 }
 
-static void be_func_recovery_task(struct work_struct *work)
+static void be_err_detection_task(struct work_struct *work)
 {
 	struct be_adapter *adapter =
-		container_of(work, struct be_adapter, func_recovery_work.work);
+				container_of(work, struct be_adapter,
+					     be_err_detection_work.work);
 	int status = 0;
 
 	be_detect_error(adapter);
@@ -4947,8 +4963,7 @@ static void be_func_recovery_task(struct work_struct *work)
 	 * no need to attempt further recovery.
 	 */
 	if (!status || status == -EAGAIN)
-		schedule_delayed_work(&adapter->func_recovery_work,
-				      msecs_to_jiffies(1000));
+		be_schedule_err_detection(adapter);
 }
 
 static void be_log_sfp_info(struct be_adapter *adapter)
@@ -5140,7 +5155,8 @@ static int be_drv_init(struct be_adapter *adapter)
 	pci_save_state(adapter->pdev);
 
 	INIT_DELAYED_WORK(&adapter->work, be_worker);
-	INIT_DELAYED_WORK(&adapter->func_recovery_work, be_func_recovery_task);
+	INIT_DELAYED_WORK(&adapter->be_err_detection_work,
+			  be_err_detection_task);
 
 	adapter->rx_fc = true;
 	adapter->tx_fc = true;
@@ -5169,7 +5185,7 @@ static void be_remove(struct pci_dev *pdev)
 	be_roce_dev_remove(adapter);
 	be_intr_set(adapter, false);
 
-	cancel_delayed_work_sync(&adapter->func_recovery_work);
+	be_cancel_err_detection(adapter);
 
 	unregister_netdev(adapter->netdev);
 
@@ -5345,8 +5361,7 @@ static int be_probe(struct pci_dev *pdev, const struct pci_device_id *pdev_id)
 
 	be_roce_dev_add(adapter);
 
-	schedule_delayed_work(&adapter->func_recovery_work,
-			      msecs_to_jiffies(1000));
+	be_schedule_err_detection(adapter);
 
 	dev_info(&pdev->dev, "%s: %s %s port %c\n", nic_name(pdev),
 		 func_name(adapter), mc_name(adapter), adapter->port_name);
@@ -5379,7 +5394,7 @@ static int be_suspend(struct pci_dev *pdev, pm_message_t state)
 		be_setup_wol(adapter, true);
 
 	be_intr_set(adapter, false);
-	cancel_delayed_work_sync(&adapter->func_recovery_work);
+	be_cancel_err_detection(adapter);
 
 	netif_device_detach(netdev);
 	if (netif_running(netdev)) {
@@ -5421,10 +5436,10 @@ static int be_resume(struct pci_dev *pdev)
 		rtnl_unlock();
 	}
 
-	schedule_delayed_work(&adapter->func_recovery_work,
-			      msecs_to_jiffies(1000));
 	netif_device_attach(netdev);
 
+	be_schedule_err_detection(adapter);
+
 	if (adapter->wol_en)
 		be_setup_wol(adapter, false);
 
@@ -5443,7 +5458,7 @@ static void be_shutdown(struct pci_dev *pdev)
 
 	be_roce_dev_shutdown(adapter);
 	cancel_delayed_work_sync(&adapter->work);
-	cancel_delayed_work_sync(&adapter->func_recovery_work);
+	be_cancel_err_detection(adapter);
 
 	netif_device_detach(adapter->netdev);
 
@@ -5463,7 +5478,7 @@ static pci_ers_result_t be_eeh_err_detected(struct pci_dev *pdev,
 	if (!adapter->eeh_error) {
 		adapter->eeh_error = true;
 
-		cancel_delayed_work_sync(&adapter->func_recovery_work);
+		be_cancel_err_detection(adapter);
 
 		rtnl_lock();
 		netif_device_detach(netdev);
@@ -5542,9 +5557,9 @@ static void be_eeh_resume(struct pci_dev *pdev)
 			goto err;
 	}
 
-	schedule_delayed_work(&adapter->func_recovery_work,
-			      msecs_to_jiffies(1000));
 	netif_device_attach(netdev);
+
+	be_schedule_err_detection(adapter);
 	return;
 err:
 	dev_err(&adapter->pdev->dev, "EEH resume failed\n");
-- 
2.2.0
