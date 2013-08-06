From: Vipul Pandya <vipul@chelsio.com>
Subject: [PATCH V2 4/4] pci: Use pci_wait_for_pending_transaction instead of for loop
Date: Tue,  6 Aug 2013 15:48:39 +0530
Message-ID: <1375784319-25760-5-git-send-email-vipul@chelsio.com>
References: <1375784319-25760-1-git-send-email-vipul@chelsio.com>
Cc: bhelgaas@google.com, leedom@chelsio.com, tomreu@chelsio.com,
	vipul@chelsio.com, divy@chelsio.com, dm@chelsio.com,
	nirranjan@chelsio.com, eilong@broadcom.com, netdev@vger.kernel.org
To: linux-pci@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:20657 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755922Ab3HFKZy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 06:25:54 -0400
In-Reply-To: <1375784319-25760-1-git-send-email-vipul@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Casey Leedom <leedom@chelsio.com>

New routine has been added to avoid duplication of waiting for pending pci
transaction code. This patch makes use of that function.

Signed-off-by: Casey Leedom <leedom@chelsio.com>
Signed-off-by: Vipul Pandya <vipul@chelsio.com>
---
V2: Added pci_wait_for_pending_transaction routine and replaced it at respective
places. Made the patch series for the same.
V2: Used dev->msix_cap directly for capability offset
V2: Removed use of 'rc' variable.

 drivers/pci/quirks.c | 18 ++----------------
 1 file changed, 2 insertions(+), 16 deletions(-)

diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
index 4a64fc4..ea9108d 100644
--- a/drivers/pci/quirks.c
+++ b/drivers/pci/quirks.c
@@ -3126,9 +3126,6 @@ static int reset_intel_generic_dev(struct pci_dev *dev, int probe)
 
 static int reset_intel_82599_sfp_virtfn(struct pci_dev *dev, int probe)
 {
-	int i;
-	u16 status;
-
 	/*
 	 * http://www.intel.com/content/dam/doc/datasheet/82599-10-gbe-controller-datasheet.pdf
 	 *
@@ -3140,20 +3137,9 @@ static int reset_intel_82599_sfp_virtfn(struct pci_dev *dev, int probe)
 	if (probe)
 		return 0;
 
-	/* Wait for Transaction Pending bit clean */
-	for (i = 0; i < 4; i++) {
-		if (i)
-			msleep((1 << (i - 1)) * 100);
-
-		pcie_capability_read_word(dev, PCI_EXP_DEVSTA, &status);
-		if (!(status & PCI_EXP_DEVSTA_TRPND))
-			goto clear;
-	}
-
-	dev_err(&dev->dev, "transaction is not cleared; "
-			"proceeding with reset anyway\n");
+	if (!pci_wait_for_pending_transaction(dev))
+		dev_err(&dev->dev, "transaction is not cleared; proceeding with reset anyway\n");
 
-clear:
 	pcie_capability_set_word(dev, PCI_EXP_DEVCTL, PCI_EXP_DEVCTL_BCR_FLR);
 
 	msleep(100);
-- 
1.8.0
