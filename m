From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 5/6] qed: Prevent probe on previous error
Date: Wed, 24 Feb 2016 16:52:49 +0200
Message-ID: <1456325570-1514-6-git-send-email-Yuval.Mintz@qlogic.com>
References: <1456325570-1514-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:35922 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753906AbcBXOxN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 09:53:13 -0500
In-Reply-To: <1456325570-1514-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't allow driver to probe on an adapter at a failed state;
Gracefully block the probe instead.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_main.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index 08cd92d..e4e6ca5 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -99,12 +99,15 @@ static void qed_free_pci(struct qed_dev *cdev)
 	pci_disable_device(pdev);
 }
 
+#define PCI_REVISION_ID_ERROR_VAL	0xff
+
 /* Performs PCI initializations as well as initializing PCI-related parameters
  * in the device structrue. Returns 0 in case of success.
  */
 static int qed_init_pci(struct qed_dev *cdev,
 			struct pci_dev *pdev)
 {
+	u8 rev_id;
 	int rc;
 
 	cdev->pdev = pdev;
@@ -138,6 +141,14 @@ static int qed_init_pci(struct qed_dev *cdev,
 		pci_save_state(pdev);
 	}
 
+	pci_read_config_byte(pdev, PCI_REVISION_ID, &rev_id);
+	if (rev_id == PCI_REVISION_ID_ERROR_VAL) {
+		DP_NOTICE(cdev,
+			  "Detected PCI device error [rev_id 0x%x]. Probably due to prior indication. Aborting.\n",
+			  rev_id);
+		rc = -ENODEV;
+		goto err2;
+	}
 	if (!pci_is_pcie(pdev)) {
 		DP_NOTICE(cdev, "The bus is not PCI Express\n");
 		rc = -EIO;
-- 
1.9.3
