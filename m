From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next] cxgb4: Fix for SR-IOV VF initialization
Date: Tue, 22 Jul 2014 16:26:20 +0530
Message-ID: <1406026580-27256-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	kumaras@chelsio.com, anish@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:35051
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753743AbaGVKue (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 06:50:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 35b1de5 ("rdma/cxgb4: Fixes cxgb4 probe failure in VM when PF is exposed
through PCI Passthrough") introduced a regression, where VF failed to
initialize. This commit fixes it.

Signed-off-by: Casey Leedom <leedom@chelsio.com>
Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |   51 +++++++++++++++++++++--
 1 files changed, 47 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 8b46534..c78e6b2 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -6695,11 +6695,33 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		attach_ulds(adapter);
 
 #ifdef CONFIG_PCI_IOV
-	if (func < ARRAY_SIZE(num_vf) && num_vf[func] > 0)
-		if (pci_enable_sriov(pdev, num_vf[func]) == 0)
-			dev_info(&pdev->dev,
+	for (func = 0; func < ARRAY_SIZE(num_vf); func++) {
+		struct pci_dev *pf;
+
+		if (num_vf[func] <= 0)
+			continue;
+
+		pf = pci_get_slot(pdev->bus,
+				  PCI_DEVFN(PCI_SLOT(pdev->devfn),
+					    func));
+		if (pf == NULL) {
+			dev_warn(&pdev->dev, "failed to find PF%d; not"
+				 " enabling %d virtual functions\n",
+				 func, num_vf[func]);
+			continue;
+		}
+		err = pci_enable_sriov(pf, num_vf[func]);
+		if (err < 0)
+			dev_warn(&pf->dev, "failed to instantiate %d"
+				 " virtual functions; err=%d\n",
+				 num_vf[func], err);
+		else
+			dev_info(&pf->dev,
 				 "instantiated %u virtual functions\n",
 				 num_vf[func]);
+
+		pci_dev_put(pf);
+	}
 #endif
 	return 0;
 
@@ -6725,8 +6747,29 @@ static void remove_one(struct pci_dev *pdev)
 	struct adapter *adapter = pci_get_drvdata(pdev);
 
 #ifdef CONFIG_PCI_IOV
-	pci_disable_sriov(pdev);
+	/* Loop accross SR-IOV PFs to see if any VFs need to be
+	 * uninstantiated.
+	 */
+	int func;
+
+	for (func = 0; func < ARRAY_SIZE(num_vf); func++) {
+		struct pci_dev *pf;
+
+		if (num_vf[func] <= 0)
+			continue;
 
+		pf = pci_get_slot(pdev->bus,
+				  PCI_DEVFN(PCI_SLOT(pdev->devfn),
+					    func));
+		if (pf == NULL) {
+			dev_warn(&pdev->dev, "failed to find PF%d; not"
+				 " disabling %d virtual functions\n",
+				 func, num_vf[func]);
+			continue;
+		}
+		pci_disable_sriov(pf);
+		pci_dev_put(pf);
+	}
 #endif
 
 	if (adapter) {
-- 
1.7.1
