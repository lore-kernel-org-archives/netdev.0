From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net] net: tg3: fix NULL pointer dereference in
 tg3_io_error_detected and tg3_io_slot_reset
Date: Tue, 13 Aug 2013 11:45:13 -0700
Message-ID: <1376419513-31924-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Daniel Borkmann" <dborkman@redhat.com>,
	"Gavin Shan" <shangw@linux.vnet.ibm.com>,
	"Michael Chan" <mchan@broadcom.com>,
	"Nithin Nayak Sujir" <nsujir@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4238 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756803Ab3HMSpd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Aug 2013 14:45:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>

Commit d8af4dfd8 ("net/tg3: Fix kernel crash") introduced a possible
NULL pointer dereference in tg3 driver when !netdev || !netif_running(netdev)
condition is met and netdev is NULL. Then, the jump to the 'done' label
calls dev_close() with a netdevice that is NULL. Therefore, only call
dev_close() when we have a netdevice, but one that is not running.

[ Add the same checks in tg3_io_slot_reset() per Gavin Shan - by Nithin
Nayak Sujir ]

Reported-by: Dave Jones <davej@redhat.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: Gavin Shan <shangw@linux.vnet.ibm.com>
Cc: Michael Chan <mchan@broadcom.com>
Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index ddebc7a..0da2214 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -17796,8 +17796,10 @@ static pci_ers_result_t tg3_io_error_detected(struct pci_dev *pdev,
 
 done:
 	if (state == pci_channel_io_perm_failure) {
-		tg3_napi_enable(tp);
-		dev_close(netdev);
+		if (netdev) {
+			tg3_napi_enable(tp);
+			dev_close(netdev);
+		}
 		err = PCI_ERS_RESULT_DISCONNECT;
 	} else {
 		pci_disable_device(pdev);
@@ -17827,7 +17829,8 @@ static pci_ers_result_t tg3_io_slot_reset(struct pci_dev *pdev)
 	rtnl_lock();
 
 	if (pci_enable_device(pdev)) {
-		netdev_err(netdev, "Cannot re-enable PCI device after reset.\n");
+		dev_err(&pdev->dev,
+			"Cannot re-enable PCI device after reset.\n");
 		goto done;
 	}
 
@@ -17835,7 +17838,7 @@ static pci_ers_result_t tg3_io_slot_reset(struct pci_dev *pdev)
 	pci_restore_state(pdev);
 	pci_save_state(pdev);
 
-	if (!netif_running(netdev)) {
+	if (!netdev || !netif_running(netdev)) {
 		rc = PCI_ERS_RESULT_RECOVERED;
 		goto done;
 	}
@@ -17847,7 +17850,7 @@ static pci_ers_result_t tg3_io_slot_reset(struct pci_dev *pdev)
 	rc = PCI_ERS_RESULT_RECOVERED;
 
 done:
-	if (rc != PCI_ERS_RESULT_RECOVERED && netif_running(netdev)) {
+	if (rc != PCI_ERS_RESULT_RECOVERED && netdev && netif_running(netdev)) {
 		tg3_napi_enable(tp);
 		dev_close(netdev);
 	}
-- 
1.8.1.4
