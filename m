From: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Subject: [PATCH net-next 6/8] benet: Fix Lancer error recovery
Date: Tue,  2 Feb 2016 15:50:33 +0530
Message-ID: <1454408435-11575-7-git-send-email-sriharsha.basavapatna@broadcom.com>
References: <1454408435-11575-1-git-send-email-sriharsha.basavapatna@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:63466 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754529AbcBBKja (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 05:39:30 -0500
In-Reply-To: <1454408435-11575-1-git-send-email-sriharsha.basavapatna@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Padmanabh Ratnakar <padmanabh.ratnakar@broadcom.com>

After error is detected, wait for adapter to move to ready state
before destroying queues and cleanup of other resources. Also
skip performing any cleanup for non-Lancer chips and move debug
messages to correct routine.

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@broadcom.com>
Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 51 +++++++++++++++++++----------
 1 file changed, 34 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 62f6fbb..6eb3aba 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -4859,21 +4859,27 @@ static int be_resume(struct be_adapter *adapter)
 
 static int be_err_recover(struct be_adapter *adapter)
 {
-	struct device *dev = &adapter->pdev->dev;
 	int status;
 
+	/* Error recovery is supported only Lancer as of now */
+	if (!lancer_chip(adapter))
+		return -EIO;
+
+	/* Wait for adapter to reach quiescent state before
+	 * destroying queues
+	 */
+	status = be_fw_wait_ready(adapter);
+	if (status)
+		goto err;
+
+	be_cleanup(adapter);
+
 	status = be_resume(adapter);
 	if (status)
 		goto err;
 
-	dev_info(dev, "Adapter recovery successful\n");
 	return 0;
 err:
-	if (be_physfn(adapter))
-		dev_err(dev, "Adapter recovery failed\n");
-	else
-		dev_err(dev, "Re-trying adapter recovery\n");
-
 	return status;
 }
 
@@ -4882,21 +4888,32 @@ static void be_err_detection_task(struct work_struct *work)
 	struct be_adapter *adapter =
 				container_of(work, struct be_adapter,
 					     be_err_detection_work.work);
-	int status = 0;
+	struct device *dev = &adapter->pdev->dev;
+	int recovery_status;
 
 	be_detect_error(adapter);
 
-	if (be_check_error(adapter, BE_ERROR_HW)) {
-		be_cleanup(adapter);
-
-		/* As of now error recovery support is in Lancer only */
-		if (lancer_chip(adapter))
-			status = be_err_recover(adapter);
+	if (be_check_error(adapter, BE_ERROR_HW))
+		recovery_status = be_err_recover(adapter);
+	else
+		goto reschedule_task;
+
+	if (!recovery_status) {
+		dev_info(dev, "Adapter recovery successful\n");
+		goto reschedule_task;
+	} else if (be_virtfn(adapter)) {
+		/* For VFs, check if PF have allocated resources
+		 * every second.
+		 */
+		dev_err(dev, "Re-trying adapter recovery\n");
+		goto reschedule_task;
+	} else {
+		dev_err(dev, "Adapter recovery failed\n");
 	}
 
-	/* Always attempt recovery on VFs */
-	if (!status || be_virtfn(adapter))
-		be_schedule_err_detection(adapter);
+	return;
+reschedule_task:
+	be_schedule_err_detection(adapter);
 }
 
 static void be_log_sfp_info(struct be_adapter *adapter)
-- 
2.3.0.rc2
