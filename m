From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 net-next] cxgb4: Fix for SR-IOV VF initialization
Date: Wed,  6 Aug 2014 17:10:59 +0530
Message-ID: <1407325259-1637-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	kumaras@chelsio.com, anish@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:33709
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755486AbaHFLfR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 07:35:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 35b1de5 ("rdma/cxgb4: Fixes cxgb4 probe failure in VM when PF is exposed
through PCI Passthrough") introduced a regression, where VF failed to
initialize for Physical function 0 to Physical Function 3. In the above
commit, we removed the code which used to enable sriov for PF0 to PF3. Now
adding it back to get sriov working.

V2:
 Removed SRIOV loop for PF[0..3] to instantiate the VF's as per David Miller's
 comment

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 4247356..1a162d2 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -6527,11 +6527,9 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	/* We control everything through one PF */
 	func = SOURCEPF_GET(readl(adapter->regs + PL_WHOAMI));
-	if ((pdev->device == 0xa000 && func != 0) ||
-	    func != ent->driver_data) {
+	if (func != ent->driver_data) {
 		pci_save_state(pdev);        /* to restore SR-IOV later */
-		err = 0;
-		goto out_unmap_bar0;
+		goto sriov;
 	}
 
 	adapter->pdev = pdev;
@@ -6697,6 +6695,7 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (is_offload(adapter))
 		attach_ulds(adapter);
 
+sriov:
 #ifdef CONFIG_PCI_IOV
 	if (func < ARRAY_SIZE(num_vf) && num_vf[func] > 0)
 		if (pci_enable_sriov(pdev, num_vf[func]) == 0)
-- 
1.7.1
