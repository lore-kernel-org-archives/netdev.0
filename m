From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/5] igb: remove duplicate code for fallback interrupt initialization
Date: Thu,  6 Dec 2012 22:11:33 -0800
Message-ID: <1354860695-27039-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1354860695-27039-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Stefan Assmann <sassmann@kpanic.de>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:4860 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752719Ab2LGGLu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Dec 2012 01:11:50 -0500
In-Reply-To: <1354860695-27039-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Assmann <sassmann@kpanic.de>

Given a small change to igb_init_interrupt_scheme() the function fits
igb_request_irq() for MSI/legacy interrupts initialization as well, instead of
duplicating most of its code there.

Also adding a missing igb_configure() to igb_request_irq() for MSI fallback
to work properly.

Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 29 ++++++++++++++---------------
 1 file changed, 14 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index de4ebb3..615b68c 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -122,6 +122,7 @@ static void igb_remove(struct pci_dev *pdev);
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
@@ -2444,7 +2443,7 @@ static int igb_sw_init(struct igb_adapter *adapter)
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
