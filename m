From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 26/29] ixgbe: correctly add and remove napi queues
Date: Thu, 11 Sep 2008 20:04:56 -0700
Message-ID: <20080912030450.6234.71019.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080912025404.6234.83037.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.227]:22815 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756799AbYILDE7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 23:04:59 -0400
Received: by rv-out-0506.google.com with SMTP id k40so615228rvb.1
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 20:04:58 -0700 (PDT)
In-Reply-To: <20080912025404.6234.83037.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch corrects support for NAPI so that queues are correctly added and
removed during suspend/resume in the event that the number of MSI-X vectors
changes.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |  230 +++++++++++++++++++++++-----------------
 1 files changed, 130 insertions(+), 100 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 2980a37..a8edbad 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2023,43 +2023,6 @@ void ixgbe_reset(struct ixgbe_adapter *adapter)
 
 }
 
-#ifdef CONFIG_PM
-static int ixgbe_resume(struct pci_dev *pdev)
-{
-	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	u32 err;
-
-	pci_set_power_state(pdev, PCI_D0);
-	pci_restore_state(pdev);
-	err = pci_enable_device(pdev);
-	if (err) {
-		printk(KERN_ERR "ixgbe: Cannot enable PCI device from " \
-		       "suspend\n");
-		return err;
-	}
-	pci_set_master(pdev);
-
-	pci_enable_wake(pdev, PCI_D3hot, 0);
-	pci_enable_wake(pdev, PCI_D3cold, 0);
-
-	if (netif_running(netdev)) {
-		err = ixgbe_request_irq(adapter);
-		if (err)
-			return err;
-	}
-
-	ixgbe_reset(adapter);
-
-	if (netif_running(netdev))
-		ixgbe_up(adapter);
-
-	netif_device_attach(netdev);
-
-	return 0;
-}
-#endif
-
 /**
  * ixgbe_clean_rx_ring - Free Rx Buffers per Queue
  * @adapter: board private structure
@@ -2230,44 +2193,6 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 #endif
 }
 
-static int ixgbe_suspend(struct pci_dev *pdev, pm_message_t state)
-{
-	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-#ifdef CONFIG_PM
-	int retval = 0;
-#endif
-
-	netif_device_detach(netdev);
-
-	if (netif_running(netdev)) {
-		ixgbe_down(adapter);
-		ixgbe_free_irq(adapter);
-	}
-
-#ifdef CONFIG_PM
-	retval = pci_save_state(pdev);
-	if (retval)
-		return retval;
-#endif
-
-	pci_enable_wake(pdev, PCI_D3hot, 0);
-	pci_enable_wake(pdev, PCI_D3cold, 0);
-
-	ixgbe_release_hw_control(adapter);
-
-	pci_disable_device(pdev);
-
-	pci_set_power_state(pdev, pci_choose_state(pdev, state));
-
-	return 0;
-}
-
-static void ixgbe_shutdown(struct pci_dev *pdev)
-{
-	ixgbe_suspend(pdev, PMSG_SUSPEND);
-}
-
 /**
  * ixgbe_poll - NAPI Rx polling callback
  * @napi: structure for representing this polling device
@@ -3023,6 +2948,135 @@ static int ixgbe_close(struct net_device *netdev)
 }
 
 /**
+ * ixgbe_napi_add_all - prep napi structs for use
+ * @adapter: private struct
+ * helper function to napi_add each possible q_vector->napi
+ */
+static void ixgbe_napi_add_all(struct ixgbe_adapter *adapter)
+{
+	int q_idx, q_vectors;
+	int (*poll)(struct napi_struct *, int);
+
+	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
+		poll = &ixgbe_clean_rxonly;
+		/* Only enable as many vectors as we have rx queues. */
+		q_vectors = adapter->num_rx_queues;
+	} else {
+		poll = &ixgbe_poll;
+		/* only one q_vector for legacy modes */
+		q_vectors = 1;
+	}
+
+	for (q_idx = 0; q_idx < q_vectors; q_idx++) {
+		struct ixgbe_q_vector *q_vector = &adapter->q_vector[q_idx];
+		netif_napi_add(adapter->netdev, &q_vector->napi, (*poll), 64);
+	}
+}
+
+static void ixgbe_napi_del_all(struct ixgbe_adapter *adapter)
+{
+	int q_idx;
+	int q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
+
+	/* legacy and MSI only use one vector */
+	if (!(adapter->flags & IXGBE_FLAG_MSIX_ENABLED))
+		q_vectors = 1;
+
+	for (q_idx = 0; q_idx < q_vectors; q_idx++) {
+		struct ixgbe_q_vector *q_vector = &adapter->q_vector[q_idx];
+		if (!q_vector->rxr_count)
+			continue;
+		netif_napi_del(&q_vector->napi);
+	}
+}
+
+#ifdef CONFIG_PM
+static int ixgbe_resume(struct pci_dev *pdev)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	u32 err;
+
+	pci_set_power_state(pdev, PCI_D0);
+	pci_restore_state(pdev);
+	err = pci_enable_device(pdev);
+	if (err) {
+		printk(KERN_ERR "ixgbe: Cannot enable PCI device from " \
+				"suspend\n");
+		return err;
+	}
+	pci_set_master(pdev);
+
+	pci_enable_wake(pdev, PCI_D3hot, 0);
+	pci_enable_wake(pdev, PCI_D3cold, 0);
+
+	err = ixgbe_init_interrupt_scheme(adapter);
+	if (err) {
+		printk(KERN_ERR "ixgbe: Cannot initialize interrupts for "
+		                "device\n");
+		return err;
+	}
+
+	ixgbe_napi_add_all(adapter);
+	ixgbe_reset(adapter);
+
+	if (netif_running(netdev)) {
+		err = ixgbe_open(adapter->netdev);
+		if (err)
+			return err;
+	}
+
+	netif_device_attach(netdev);
+
+	return 0;
+}
+
+#endif /* CONFIG_PM */
+static int ixgbe_suspend(struct pci_dev *pdev, pm_message_t state)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+#ifdef CONFIG_PM
+	int retval = 0;
+#endif
+
+	netif_device_detach(netdev);
+
+	if (netif_running(netdev)) {
+		ixgbe_down(adapter);
+		ixgbe_free_irq(adapter);
+		ixgbe_free_all_tx_resources(adapter);
+		ixgbe_free_all_rx_resources(adapter);
+	}
+	ixgbe_reset_interrupt_capability(adapter);
+	ixgbe_napi_del_all(adapter);
+	kfree(adapter->tx_ring);
+	kfree(adapter->rx_ring);
+
+#ifdef CONFIG_PM
+	retval = pci_save_state(pdev);
+	if (retval)
+		return retval;
+#endif
+
+	pci_enable_wake(pdev, PCI_D3hot, 0);
+	pci_enable_wake(pdev, PCI_D3cold, 0);
+
+	ixgbe_release_hw_control(adapter);
+
+	pci_disable_device(pdev);
+
+	pci_set_power_state(pdev, pci_choose_state(pdev, state));
+
+	return 0;
+}
+
+static void ixgbe_shutdown(struct pci_dev *pdev)
+{
+	ixgbe_suspend(pdev, PMSG_SUSPEND);
+}
+
+/**
  * ixgbe_update_stats - Update the board statistics counters.
  * @adapter: board private structure
  **/
@@ -3657,31 +3711,6 @@ static int ixgbe_link_config(struct ixgbe_hw *hw)
 }
 
 /**
- * ixgbe_napi_add_all - prep napi structs for use
- * @adapter: private struct
- * helper function to napi_add each possible q_vector->napi
- */
-static void ixgbe_napi_add_all(struct ixgbe_adapter *adapter)
-{
-	int i, q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
-	int (*poll)(struct napi_struct *, int);
-
-	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
-		poll = &ixgbe_clean_rxonly;
-	} else {
-		poll = &ixgbe_poll;
-		/* only one q_vector for legacy modes */
-		q_vectors = 1;
-	}
-
-	for (i = 0; i < q_vectors; i++) {
-		struct ixgbe_q_vector *q_vector = &adapter->q_vector[i];
-		netif_napi_add(adapter->netdev, &q_vector->napi,
-		               (*poll), 64);
-	}
-}
-
-/**
  * ixgbe_probe - Device Initialization Routine
  * @pdev: PCI device information struct
  * @ent: entry in ixgbe_pci_tbl
@@ -3977,6 +4006,7 @@ static void __devexit ixgbe_remove(struct pci_dev *pdev)
 	pci_release_regions(pdev);
 
 	DPRINTK(PROBE, INFO, "complete\n");
+	ixgbe_napi_del_all(adapter);
 	kfree(adapter->tx_ring);
 	kfree(adapter->rx_ring);
 

