From: Stefan Assmann <sassmann@kpanic.de>
Subject: [PATCH net-next 1/2] igb: remove duplicate code for fallback interrupt initialization
Date: Mon,  3 Dec 2012 14:15:00 +0100
Message-ID: <1354540501-18407-2-git-send-email-sassmann@kpanic.de>
References: <1354540501-18407-1-git-send-email-sassmann@kpanic.de>
Cc: e1000-devel@lists.sourceforge.net, alexander.h.duyck@intel.com,
	carolyn.wyborny@intel.com, jeffrey.t.kirsher@intel.com,
	sassmann@kpanic.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61125 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754360Ab2LCNQ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Dec 2012 08:16:27 -0500
In-Reply-To: <1354540501-18407-1-git-send-email-sassmann@kpanic.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Given a small change to igb_init_interrupt_scheme() the function fits
igb_request_irq() for MSI/legacy interrupts initialization as well, instead of
duplicating most of its code there.

Also adding a missing igb_configure() to igb_request_irq() for MSI fallback
to work properly.

Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 29 ++++++++++++++---------------
 1 file changed, 14 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index b85b15a..b0dd5ef 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -122,6 +122,7 @@ static void __devexit igb_remove(struct pci_dev *pdev);
 static int igb_sw_init(struct igb_adapter *);
 static int igb_open(struct net_device *);
 static int igb_close(struct net_device *);
+static void igb_configure(struct igb_adapter *);
 static void igb_configure_tx(struct igb_adapter *);
 static void igb_configure_rx(struct igb_adapter *);
 static void igb_clean_all_tx_rings(struct igb_adapter *);
@@ -948,11 +949,14 @@ static void igb_clear_interrupt_scheme(struct igb_adapter *adapter)
  * Attempt to configure interrupts using the best available
  * capabilities of the hardware and kernel.
  **/
-static void igb_set_interrupt_capability(struct igb_adapter *adapter)
+static void igb_set_interrupt_capability(struct igb_adapter *adapter, bool msix)
 {
 	int err;
 	int numvecs, i;
 
+	if (!msix)
+		goto msi_only;
+
 	/* Number of supported queues. */
 	adapter->num_rx_queues = adapter->rss_queues;
 	if (adapter->vfs_allocated_count)
@@ -1199,12 +1203,12 @@ err_out:
  *
  * This function initializes the interrupts and allocates all of the queues.
  **/
-static int igb_init_interrupt_scheme(struct igb_adapter *adapter)
+static int igb_init_interrupt_scheme(struct igb_adapter *adapter, bool msix)
 {
 	struct pci_dev *pdev = adapter->pdev;
 	int err;
 
-	igb_set_interrupt_capability(adapter);
+	igb_set_interrupt_capability(adapter, msix);
 
 	err = igb_alloc_q_vectors(adapter);
 	if (err) {
@@ -1240,20 +1244,15 @@ static int igb_request_irq(struct igb_adapter *adapter)
 		/* fall back to MSI */
 		igb_free_all_tx_resources(adapter);
 		igb_free_all_rx_resources(adapter);
+
 		igb_clear_interrupt_scheme(adapter);
-		if (!pci_enable_msi(pdev))
-			adapter->flags |= IGB_FLAG_HAS_MSI;
-		adapter->num_tx_queues = 1;
-		adapter->num_rx_queues = 1;
-		adapter->num_q_vectors = 1;
-		err = igb_alloc_q_vectors(adapter);
-		if (err) {
-			dev_err(&pdev->dev,
-			        "Unable to allocate memory for vectors\n");
+		err = igb_init_interrupt_scheme(adapter, false);
+		if (err)
 			goto request_done;
-		}
+
 		igb_setup_all_tx_resources(adapter);
 		igb_setup_all_rx_resources(adapter);
+		igb_configure(adapter);
 	}
 
 	igb_assign_vector(adapter->q_vector[0], 0);
@@ -2444,7 +2443,7 @@ static int __devinit igb_sw_init(struct igb_adapter *adapter)
 				GFP_ATOMIC);
 
 	/* This call may decrease the number of queues */
-	if (igb_init_interrupt_scheme(adapter)) {
+	if (igb_init_interrupt_scheme(adapter, true)) {
 		dev_err(&pdev->dev, "Unable to allocate memory for queues\n");
 		return -ENOMEM;
 	}
@@ -6818,7 +6817,7 @@ static int igb_resume(struct device *dev)
 	pci_enable_wake(pdev, PCI_D3hot, 0);
 	pci_enable_wake(pdev, PCI_D3cold, 0);
 
-	if (igb_init_interrupt_scheme(adapter)) {
+	if (igb_init_interrupt_scheme(adapter, true)) {
 		dev_err(&pdev->dev, "Unable to allocate memory for queues\n");
 		return -ENOMEM;
 	}
-- 
1.7.11.7
