From: Brice Goglin <brice@myri.com>
Subject: [PATCH 1/5] myri10ge: match number of save_state and restore
Date: Mon, 18 Dec 2006 11:50:00 +0100
Message-ID: <45867258.3050304@myri.com>
References: <45867228.1090406@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:41357 "EHLO
	myri.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753839AbWLRLVj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Dec 2006 06:21:39 -0500
To: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
In-Reply-To: <45867228.1090406@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since pci_save_state() pushes MSI and PCIe states on a kind of stack,
myri10ge saving the state in advance for parity recovery will push the
state again on the stack on suspend. This leads to some memory leak.
We add a couple additional calls to save_state and restore_state so
that we don't leak anymore.

For the future, we are thinking of a better way to recover from parity
error without using pci_save_state().

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |   12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

Index: linux-rc/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-rc.orig/drivers/net/myri10ge/myri10ge.c	2006-12-17 22:12:20.000000000 +0100
+++ linux-rc/drivers/net/myri10ge/myri10ge.c	2006-12-17 22:13:50.000000000 +0100
@@ -2641,6 +2641,10 @@
 		 * nic was resumed from power saving mode.
 		 */
 		myri10ge_restore_state(mgp);
+
+		/* save state again for accounting reasons */
+		myri10ge_save_state(mgp);
+
 	} else {
 		/* if we get back -1's from our slot, perhaps somebody
 		 * powered off our card.  Don't try to reset it in
@@ -2907,7 +2911,7 @@
 	status = register_netdev(netdev);
 	if (status != 0) {
 		dev_err(&pdev->dev, "register_netdev failed: %d\n", status);
-		goto abort_with_irq;
+		goto abort_with_state;
 	}
 	dev_info(dev, "%s IRQ %d, tx bndry %d, fw %s, WC %s\n",
 		 (mgp->msi_enabled ? "MSI" : "xPIC"),
@@ -2916,7 +2920,8 @@
 
 	return 0;
 
-abort_with_irq:
+abort_with_state:
+	myri10ge_restore_state(mgp);
 	free_irq(pdev->irq, mgp);
 	if (mgp->msi_enabled)
 		pci_disable_msi(pdev);
@@ -2976,6 +2981,9 @@
 
 	myri10ge_dummy_rdma(mgp, 0);
 
+	/* avoid a memory leak */
+	myri10ge_restore_state(mgp);
+
 	bytes = myri10ge_max_intr_slots * sizeof(*mgp->rx_done.entry);
 	dma_free_coherent(&pdev->dev, bytes,
 			  mgp->rx_done.entry, mgp->rx_done.bus);


