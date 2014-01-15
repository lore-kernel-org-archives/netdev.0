From: Yuval Mintz <yuvalmin@broadcom.com>
Subject: [PATCH net] bnx2x: Don't release PCI bars on shutdown
Date: Wed, 15 Jan 2014 12:05:30 +0200
Message-ID: <1389780330-6927-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <yuvalmin@broadcom.com>,
	Ariel Elior <ariele@broadcom.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:30438 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751535AbaAOKFd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 05:05:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bnx2x driver in its pci shutdown() callback releases its pci bars (in the
same manner it does during its pci remove() callback).
During a system reboot while VFs are enabled, its possible for the VF's remove
to be called (as a result of pci_disable_sriov()) after its shutdown callback
has already finished running; This will cause a paging request fault as the VF
tries to access the pci bar which it has previously released, crashing the
system.

This patch further differentiates the shutdown and remove callbacks, preventing the
pci release procedures from being called during shutdown.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
---
Hi Dave,

Please accept this patch to `net'.

Thanks,
Yuval
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 29 ++++++++++++------------
 1 file changed, 15 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 8b3107b..7b3b5cc 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -12942,25 +12942,26 @@ static void __bnx2x_remove(struct pci_dev *pdev,
 		pci_set_power_state(pdev, PCI_D3hot);
 	}
 
-	if (bp->regview)
-		iounmap(bp->regview);
+	if (remove_netdev) {
+		if (bp->regview)
+			iounmap(bp->regview);
 
-	/* for vf doorbells are part of the regview and were unmapped along with
-	 * it. FW is only loaded by PF.
-	 */
-	if (IS_PF(bp)) {
-		if (bp->doorbells)
-			iounmap(bp->doorbells);
+		/* For vfs, doorbells are part of the regview and were unmapped
+		 * along with it. FW is only loaded by PF.
+		 */
+		if (IS_PF(bp)) {
+			if (bp->doorbells)
+				iounmap(bp->doorbells);
 
-		bnx2x_release_firmware(bp);
-	}
-	bnx2x_free_mem_bp(bp);
+			bnx2x_release_firmware(bp);
+		}
+		bnx2x_free_mem_bp(bp);
 
-	if (remove_netdev)
 		free_netdev(dev);
 
-	if (atomic_read(&pdev->enable_cnt) == 1)
-		pci_release_regions(pdev);
+		if (atomic_read(&pdev->enable_cnt) == 1)
+			pci_release_regions(pdev);
+	}
 
 	pci_disable_device(pdev);
 }
-- 
1.8.1.227.g44fe835
