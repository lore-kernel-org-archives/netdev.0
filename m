From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 1/6 net-next] bnx2: Handle error condition in
 ->slot_reset()
Date: Tue, 6 Aug 2013 15:50:07 -0700
Message-ID: <1375829412-26425-2-git-send-email-mchan@broadcom.com>
References: <1375829412-26425-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4005 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756625Ab3HFW2J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Aug 2013 18:28:09 -0400
In-Reply-To: <1375829412-26425-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

by closing the device if necessary.  Otherwise, since NAPI state is
already disabled, a subsequent close will hang the system.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2.c |   15 ++++++++++-----
 1 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 6a2de1d..3baf8b5 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -8694,14 +8694,13 @@ static pci_ers_result_t bnx2_io_slot_reset(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct bnx2 *bp = netdev_priv(dev);
-	pci_ers_result_t result;
-	int err;
+	pci_ers_result_t result = PCI_ERS_RESULT_DISCONNECT;
+	int err = 0;
 
 	rtnl_lock();
 	if (pci_enable_device(pdev)) {
 		dev_err(&pdev->dev,
 			"Cannot re-enable PCI device after reset\n");
-		result = PCI_ERS_RESULT_DISCONNECT;
 	} else {
 		pci_set_master(pdev);
 		pci_restore_state(pdev);
@@ -8709,9 +8708,15 @@ static pci_ers_result_t bnx2_io_slot_reset(struct pci_dev *pdev)
 
 		if (netif_running(dev)) {
 			bnx2_set_power_state(bp, PCI_D0);
-			bnx2_init_nic(bp, 1);
+			err = bnx2_init_nic(bp, 1);
 		}
-		result = PCI_ERS_RESULT_RECOVERED;
+		if (!err)
+			result = PCI_ERS_RESULT_RECOVERED;
+	}
+
+	if (result != PCI_ERS_RESULT_RECOVERED && netif_running(dev)) {
+		bnx2_napi_enable(bp);
+		dev_close(dev);
 	}
 	rtnl_unlock();
 
-- 
1.7.1
