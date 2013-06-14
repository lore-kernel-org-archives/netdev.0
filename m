From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net-next] tg3: Prevent system hang during repeated EEH
 errors.
Date: Fri, 14 Jun 2013 14:15:06 -0700
Message-ID: <1371244506-18969-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	"Nithin Nayak Sujir" <nsujir@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4203 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751294Ab3FNVPS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jun 2013 17:15:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <mchan@broadcom.com>

The current tg3 code assumes the pci_error_handlers to be always called
in sequence.  In particular, during ->error_detected(), NAPI is disabled
and the device is shutdown.  The device is later reset and NAPI
re-enabled in ->slot_reset() and ->resume().

In EEH, if more than 6 errors are detected in a hour, only
->error_detected() will be called.  This will leave the driver in an
inconsistent state as NAPI is disabled but netif_running state is still
true.  When the device is later closed, we'll try to disable NAPI again
and it will loop forever.

We fix this by closing the device if we encounter any error conditions
during the normal sequence of the pci_error_handlers.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 28a645f..bfe1831 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -17747,10 +17747,13 @@ static pci_ers_result_t tg3_io_error_detected(struct pci_dev *pdev,
 	tg3_full_unlock(tp);
 
 done:
-	if (state == pci_channel_io_perm_failure)
+	if (state == pci_channel_io_perm_failure) {
+		tg3_napi_enable(tp);
+		dev_close(netdev);
 		err = PCI_ERS_RESULT_DISCONNECT;
-	else
+	} else {
 		pci_disable_device(pdev);
+	}
 
 	rtnl_unlock();
 
@@ -17796,6 +17799,10 @@ static pci_ers_result_t tg3_io_slot_reset(struct pci_dev *pdev)
 	rc = PCI_ERS_RESULT_RECOVERED;
 
 done:
+	if (rc != PCI_ERS_RESULT_RECOVERED && netif_running(netdev)) {
+		tg3_napi_enable(tp);
+		dev_close(netdev);
+	}
 	rtnl_unlock();
 
 	return rc;
@@ -17826,6 +17833,8 @@ static void tg3_io_resume(struct pci_dev *pdev)
 	if (err) {
 		tg3_full_unlock(tp);
 		netdev_err(netdev, "Cannot restart hardware after reset.\n");
+		tg3_napi_enable(tp);
+		dev_close(netdev);
 		goto done;
 	}
 
-- 
1.8.1.4
