From: Padmanabh Ratnakar <padmanabh.ratnakar@broadcom.com>
Subject: [PATCH net-next] be2net: Fix pcie error recovery in case of NIC+RoCE adapters
Date: Thu, 18 Feb 2016 03:09:34 +0530
Message-ID: <1455745174-25211-1-git-send-email-padmanabh.ratnakar@broadcom.com>
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:53523 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1422925AbcBQNj4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 08:39:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Interrupts registered by RoCE driver are not unregistered when
msix interrupts are disabled during error recovery causing a
crash. Detach the adapter instance from RoCE driver when error
is detected to complete the cleanup. Attach the driver again after
the adapter is recovered from error.

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@broadcom.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 88f427c..4624846 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -5456,6 +5456,8 @@ static pci_ers_result_t be_eeh_err_detected(struct pci_dev *pdev,
 
 	dev_err(&adapter->pdev->dev, "EEH error detected\n");
 
+	be_roce_dev_remove(adapter);
+
 	if (!be_check_error(adapter, BE_ERROR_EEH)) {
 		be_set_error(adapter, BE_ERROR_EEH);
 
@@ -5520,6 +5522,8 @@ static void be_eeh_resume(struct pci_dev *pdev)
 	if (status)
 		goto err;
 
+	be_roce_dev_add(adapter);
+
 	be_schedule_err_detection(adapter, ERR_DETECTION_DELAY);
 	return;
 err:
-- 
2.7.1.287.g4943984
