From: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Subject: [PATCH net-next 7/8] benet: Add retry in case of error recovery failure
Date: Tue,  2 Feb 2016 15:50:34 +0530
Message-ID: <1454408435-11575-8-git-send-email-sriharsha.basavapatna@broadcom.com>
References: <1454408435-11575-1-git-send-email-sriharsha.basavapatna@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:63466 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754572AbcBBKjb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 05:39:31 -0500
In-Reply-To: <1454408435-11575-1-git-send-email-sriharsha.basavapatna@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Padmanabh Ratnakar <padmanabh.ratnakar@broadcom.com>

Retry error recovery MAX_ERR_RECOVERY_RETRY_COUNT times in case of
failure during error recovery.

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@broadcom.com>
Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |  5 +++++
 drivers/net/ethernet/emulex/benet/be_main.c | 23 +++++++++++++++++------
 2 files changed, 22 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index f33d73c..5277974 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -397,6 +397,10 @@ enum vf_state {
 #define BE_UC_PMAC_COUNT			30
 #define BE_VF_UC_PMAC_COUNT			2
 
+#define MAX_ERR_RECOVERY_RETRY_COUNT		3
+#define ERR_DETECTION_DELAY			1000
+#define ERR_RECOVERY_RETRY_DELAY		30000
+
 /* Ethtool set_dump flags */
 #define LANCER_INITIATE_FW_DUMP			0x1
 #define LANCER_DELETE_FW_DUMP			0x2
@@ -534,6 +538,7 @@ struct be_adapter {
 	u16 work_counter;
 
 	struct delayed_work be_err_detection_work;
+	u8 recovery_retries;
 	u8 err_flags;
 	u32 flags;
 	u32 cmd_privileges;
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 6eb3aba..d5286d3 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -4265,10 +4265,10 @@ static void be_schedule_worker(struct be_adapter *adapter)
 	adapter->flags |= BE_FLAGS_WORKER_SCHEDULED;
 }
 
-static void be_schedule_err_detection(struct be_adapter *adapter)
+static void be_schedule_err_detection(struct be_adapter *adapter, u32 delay)
 {
 	schedule_delayed_work(&adapter->be_err_detection_work,
-			      msecs_to_jiffies(1000));
+			      msecs_to_jiffies(delay));
 	adapter->flags |= BE_FLAGS_ERR_DETECTION_SCHEDULED;
 }
 
@@ -4890,6 +4890,7 @@ static void be_err_detection_task(struct work_struct *work)
 					     be_err_detection_work.work);
 	struct device *dev = &adapter->pdev->dev;
 	int recovery_status;
+	int delay = ERR_DETECTION_DELAY;
 
 	be_detect_error(adapter);
 
@@ -4899,6 +4900,7 @@ static void be_err_detection_task(struct work_struct *work)
 		goto reschedule_task;
 
 	if (!recovery_status) {
+		adapter->recovery_retries = 0;
 		dev_info(dev, "Adapter recovery successful\n");
 		goto reschedule_task;
 	} else if (be_virtfn(adapter)) {
@@ -4907,13 +4909,22 @@ static void be_err_detection_task(struct work_struct *work)
 		 */
 		dev_err(dev, "Re-trying adapter recovery\n");
 		goto reschedule_task;
+	} else if (adapter->recovery_retries++ <
+		   MAX_ERR_RECOVERY_RETRY_COUNT) {
+		/* In case of another error during recovery, it takes 30 sec
+		 * for adapter to come out of error. Retry error recovery after
+		 * this time interval.
+		 */
+		dev_err(&adapter->pdev->dev, "Re-trying adapter recovery\n");
+		delay = ERR_RECOVERY_RETRY_DELAY;
+		goto reschedule_task;
 	} else {
 		dev_err(dev, "Adapter recovery failed\n");
 	}
 
 	return;
 reschedule_task:
-	be_schedule_err_detection(adapter);
+	be_schedule_err_detection(adapter, delay);
 }
 
 static void be_log_sfp_info(struct be_adapter *adapter)
@@ -5309,7 +5320,7 @@ static int be_probe(struct pci_dev *pdev, const struct pci_device_id *pdev_id)
 
 	be_roce_dev_add(adapter);
 
-	be_schedule_err_detection(adapter);
+	be_schedule_err_detection(adapter, ERR_DETECTION_DELAY);
 
 	/* On Die temperature not supported for VF. */
 	if (be_physfn(adapter) && IS_ENABLED(CONFIG_BE2NET_HWMON)) {
@@ -5376,7 +5387,7 @@ static int be_pci_resume(struct pci_dev *pdev)
 	if (status)
 		return status;
 
-	be_schedule_err_detection(adapter);
+	be_schedule_err_detection(adapter, ERR_DETECTION_DELAY);
 
 	if (adapter->wol_en)
 		be_setup_wol(adapter, false);
@@ -5476,7 +5487,7 @@ static void be_eeh_resume(struct pci_dev *pdev)
 	if (status)
 		goto err;
 
-	be_schedule_err_detection(adapter);
+	be_schedule_err_detection(adapter, ERR_DETECTION_DELAY);
 	return;
 err:
 	dev_err(&adapter->pdev->dev, "EEH resume failed\n");
-- 
2.3.0.rc2
