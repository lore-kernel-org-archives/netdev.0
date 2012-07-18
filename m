From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/6] ixgbe: Move configuration of set_real_num_rx/tx_queues into open
Date: Tue, 17 Jul 2012 19:20:42 -0700
Message-ID: <1342578045-17778-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1342578045-17778-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:6702 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752088Ab2GRCUu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jul 2012 22:20:50 -0400
In-Reply-To: <1342578045-17778-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

It makes much more sense for us to configure the real number of Tx and Rx
queues in the ixgbe_open call than it does in ixgbe_set_num_queues.  By
setting the number in ixgbe_open we can avoid a number of unecessary
updates and only have to make the calls once.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c  |   58 ++++++-------------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   36 ++++++++++-----
 2 files changed, 38 insertions(+), 56 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
index d308e71..c03d771 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
@@ -349,7 +349,7 @@ static bool ixgbe_set_rss_queues(struct ixgbe_adapter *adapter)
  * fallthrough conditions.
  *
  **/
-static int ixgbe_set_num_queues(struct ixgbe_adapter *adapter)
+static void ixgbe_set_num_queues(struct ixgbe_adapter *adapter)
 {
 	/* Start with base case */
 	adapter->num_rx_queues = 1;
@@ -358,29 +358,14 @@ static int ixgbe_set_num_queues(struct ixgbe_adapter *adapter)
 	adapter->num_rx_queues_per_pool = 1;
 
 	if (ixgbe_set_sriov_queues(adapter))
-		goto done;
+		return;
 
 #ifdef CONFIG_IXGBE_DCB
 	if (ixgbe_set_dcb_queues(adapter))
-		goto done;
+		return;
 
 #endif
-	if (ixgbe_set_rss_queues(adapter))
-		goto done;
-
-	/* fallback to base case */
-	adapter->num_rx_queues = 1;
-	adapter->num_tx_queues = 1;
-
-done:
-	if ((adapter->netdev->reg_state == NETREG_UNREGISTERED) ||
-	    (adapter->netdev->reg_state == NETREG_UNREGISTERING))
-		return 0;
-
-	/* Notify the stack of the (possibly) reduced queue counts. */
-	netif_set_real_num_tx_queues(adapter->netdev, adapter->num_tx_queues);
-	return netif_set_real_num_rx_queues(adapter->netdev,
-					    adapter->num_rx_queues);
+	ixgbe_set_rss_queues(adapter);
 }
 
 static void ixgbe_acquire_msix_vectors(struct ixgbe_adapter *adapter,
@@ -710,11 +695,10 @@ static void ixgbe_reset_interrupt_capability(struct ixgbe_adapter *adapter)
  * Attempt to configure the interrupts using the best available
  * capabilities of the hardware and the kernel.
  **/
-static int ixgbe_set_interrupt_capability(struct ixgbe_adapter *adapter)
+static void ixgbe_set_interrupt_capability(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
-	int err = 0;
-	int vector, v_budget;
+	int vector, v_budget, err;
 
 	/*
 	 * It's easy to be greedy for MSI-X vectors, but it really
@@ -747,7 +731,7 @@ static int ixgbe_set_interrupt_capability(struct ixgbe_adapter *adapter)
 		ixgbe_acquire_msix_vectors(adapter, v_budget);
 
 		if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED)
-			goto out;
+			return;
 	}
 
 	adapter->flags &= ~IXGBE_FLAG_DCB_ENABLED;
@@ -762,25 +746,17 @@ static int ixgbe_set_interrupt_capability(struct ixgbe_adapter *adapter)
 	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED)
 		ixgbe_disable_sriov(adapter);
 
-	err = ixgbe_set_num_queues(adapter);
-	if (err)
-		return err;
-
+	ixgbe_set_num_queues(adapter);
 	adapter->num_q_vectors = 1;
 
 	err = pci_enable_msi(adapter->pdev);
-	if (!err) {
-		adapter->flags |= IXGBE_FLAG_MSI_ENABLED;
-	} else {
+	if (err) {
 		netif_printk(adapter, hw, KERN_DEBUG, adapter->netdev,
 			     "Unable to allocate MSI interrupt, "
 			     "falling back to legacy.  Error: %d\n", err);
-		/* reset err */
-		err = 0;
+		return;
 	}
-
-out:
-	return err;
+	adapter->flags |= IXGBE_FLAG_MSI_ENABLED;
 }
 
 /**
@@ -798,15 +774,10 @@ int ixgbe_init_interrupt_scheme(struct ixgbe_adapter *adapter)
 	int err;
 
 	/* Number of supported queues */
-	err = ixgbe_set_num_queues(adapter);
-	if (err)
-		return err;
+	ixgbe_set_num_queues(adapter);
 
-	err = ixgbe_set_interrupt_capability(adapter);
-	if (err) {
-		e_dev_err("Unable to setup interrupt capabilities\n");
-		goto err_set_interrupt;
-	}
+	/* Set interrupt mode */
+	ixgbe_set_interrupt_capability(adapter);
 
 	err = ixgbe_alloc_q_vectors(adapter);
 	if (err) {
@@ -826,7 +797,6 @@ int ixgbe_init_interrupt_scheme(struct ixgbe_adapter *adapter)
 
 err_alloc_q_vectors:
 	ixgbe_reset_interrupt_capability(adapter);
-err_set_interrupt:
 	return err;
 }
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 373342f..7f2aa22 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4798,10 +4798,26 @@ static int ixgbe_open(struct net_device *netdev)
 	if (err)
 		goto err_req_irq;
 
+	/* Notify the stack of the actual queue counts. */
+	err = netif_set_real_num_tx_queues(netdev,
+					   adapter->num_rx_pools > 1 ? 1 :
+					   adapter->num_tx_queues);
+	if (err)
+		goto err_set_queues;
+
+
+	err = netif_set_real_num_rx_queues(netdev,
+					   adapter->num_rx_pools > 1 ? 1 :
+					   adapter->num_rx_queues);
+	if (err)
+		goto err_set_queues;
+
 	ixgbe_up_complete(adapter);
 
 	return 0;
 
+err_set_queues:
+	ixgbe_free_irq(adapter);
 err_req_irq:
 	ixgbe_free_all_rx_resources(adapter);
 err_setup_rx:
@@ -4864,23 +4880,19 @@ static int ixgbe_resume(struct pci_dev *pdev)
 
 	pci_wake_from_d3(pdev, false);
 
-	rtnl_lock();
-	err = ixgbe_init_interrupt_scheme(adapter);
-	rtnl_unlock();
-	if (err) {
-		e_dev_err("Cannot initialize interrupts for device\n");
-		return err;
-	}
-
 	ixgbe_reset(adapter);
 
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_WUS, ~0);
 
-	if (netif_running(netdev)) {
+	rtnl_lock();
+	err = ixgbe_init_interrupt_scheme(adapter);
+	if (!err && netif_running(netdev))
 		err = ixgbe_open(netdev);
-		if (err)
-			return err;
-	}
+
+	rtnl_unlock();
+
+	if (err)
+		return err;
 
 	netif_device_attach(netdev);
 
-- 
1.7.10.4
