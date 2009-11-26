From: Simon Horman <horms@verge.net.au>
Subject: [rfc 1/3 v3] [E1000-devel] [rfc 1/4] igb: Add igb_cleanup_vf()
Date: Thu, 26 Nov 2009 11:05:39 +1100
Message-ID: <20091126000758.275292536@vergenet.net>
References: <20091126000538.716725330@vergenet.net>
Cc: Arnd Bergmann <arndbergmann@googlemail.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:41667 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754550AbZKZALN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 19:11:13 -0500
Content-Disposition: inline; filename=igb-add-igb_cleanup-vf.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move virtual function cleanup code into igb_cleanup_vf() and for the sake
of symmetry rename igb_probe_vfs() as igb_init_vf().

Although these functions aren't entirely symmetrical it should aid
maintenance by making the relationship between initialisation and cleanup
more obvious.

Cc: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Simon Horman <horms@verge.net.au>

--- 
Thu, 05 Nov 2009 11:58:48 +1100
* Initial post

Wed, 25 Nov 2009 15:43:45 +1100
* Actually remove adapter->vfs_allocated_count = 0 from outside of
  igb_cleanup_vf()
* Up-port to current net-next

Thu, 26 Nov 2009 10:29:02 +1100
As per suggestion from Alexander Duyck
* Use igb_cleanup_vf() in igb_remove()

Index: net-next-2.6/drivers/net/igb/igb_main.c
===================================================================
--- net-next-2.6.orig/drivers/net/igb/igb_main.c	2009-11-26 10:31:13.000000000 +1100
+++ net-next-2.6/drivers/net/igb/igb_main.c	2009-11-26 10:32:02.000000000 +1100
@@ -92,6 +92,7 @@ void igb_update_stats(struct igb_adapter
 static int igb_probe(struct pci_dev *, const struct pci_device_id *);
 static void __devexit igb_remove(struct pci_dev *pdev);
 static int igb_sw_init(struct igb_adapter *);
+static void igb_cleanup_vf(struct igb_adapter * adapter);
 static int igb_open(struct net_device *);
 static int igb_close(struct net_device *);
 static void igb_configure_tx(struct igb_adapter *);
@@ -701,22 +702,7 @@ static void igb_set_interrupt_capability
 
 	/* If we can't do MSI-X, try MSI */
 msi_only:
-#ifdef CONFIG_PCI_IOV
-	/* disable SR-IOV for non MSI-X configurations */
-	if (adapter->vf_data) {
-		struct e1000_hw *hw = &adapter->hw;
-		/* disable iov and allow time for transactions to clear */
-		pci_disable_sriov(adapter->pdev);
-		msleep(500);
-
-		kfree(adapter->vf_data);
-		adapter->vf_data = NULL;
-		wr32(E1000_IOVCTL, E1000_IOVCTL_REUSE_VFQ);
-		msleep(100);
-		dev_info(&adapter->pdev->dev, "IOV Disabled\n");
-	}
-#endif
-	adapter->vfs_allocated_count = 0;
+	igb_cleanup_vf(adapter);
 	adapter->rss_queues = 1;
 	adapter->flags |= IGB_FLAG_QUEUE_PAIRS;
 	adapter->num_rx_queues = 1;
@@ -1725,21 +1711,7 @@ static void __devexit igb_remove(struct 
 		igb_reset_phy(hw);
 
 	igb_clear_interrupt_scheme(adapter);
-
-#ifdef CONFIG_PCI_IOV
-	/* reclaim resources allocated to VFs */
-	if (adapter->vf_data) {
-		/* disable iov and allow time for transactions to clear */
-		pci_disable_sriov(pdev);
-		msleep(500);
-
-		kfree(adapter->vf_data);
-		adapter->vf_data = NULL;
-		wr32(E1000_IOVCTL, E1000_IOVCTL_REUSE_VFQ);
-		msleep(100);
-		dev_info(&pdev->dev, "IOV Disabled\n");
-	}
-#endif
+	igb_cleanup_vf(adapter);
 
 	iounmap(hw->hw_addr);
 	if (hw->flash_address)
@@ -1755,7 +1727,7 @@ static void __devexit igb_remove(struct 
 }
 
 /**
- * igb_probe_vfs - Initialize vf data storage and add VFs to pci config space
+ * igb_init_vf - Initialize vf data storage and add VFs to pci config space
  * @adapter: board private structure to initialize
  *
  * This function initializes the vf specific data storage and then attempts to
@@ -1763,7 +1735,7 @@ static void __devexit igb_remove(struct 
  * mor expensive time wise to disable SR-IOV than it is to allocate and free
  * the memory for the VFs.
  **/
-static void __devinit igb_probe_vfs(struct igb_adapter * adapter)
+static void __devinit igb_init_vf(struct igb_adapter * adapter)
 {
 #ifdef CONFIG_PCI_IOV
 	struct pci_dev *pdev = adapter->pdev;
@@ -1909,6 +1881,35 @@ static void igb_init_hw_timer(struct igb
 }
 
 /**
+ * igb_cleanup_vf - Clean up vf data and remove vfs from pci config space
+ * @adapter: board private structure to initialize
+ *
+ * This function cleans-up the vf specific data storage and then attempts to
+ * deallocate the VFs.
+ **/
+static void igb_cleanup_vf(struct igb_adapter * adapter)
+{
+#ifdef CONFIG_PCI_IOV
+	struct e1000_hw *hw = &adapter->hw;
+
+	if (!adapter->vf_data)
+		return;
+
+	/* disable iov and allow time for transactions to clear */
+	pci_disable_sriov(adapter->pdev);
+	msleep(500);
+
+	kfree(adapter->vf_data);
+	adapter->vf_data = NULL;
+	adapter->vfs_allocated_count = 0;
+
+	wr32(E1000_IOVCTL, E1000_IOVCTL_REUSE_VFQ);
+	msleep(100);
+	dev_info(&adapter->pdev->dev, "IOV Disabled\n");
+#endif
+}
+
+/**
  * igb_sw_init - Initialize general software structures (struct igb_adapter)
  * @adapter: board private structure to initialize
  *
@@ -1955,7 +1956,7 @@ static int __devinit igb_sw_init(struct 
 	}
 
 	igb_init_hw_timer(adapter);
-	igb_probe_vfs(adapter);
+	igb_init_vf(adapter);
 
 	/* Explicitly disable IRQ since the NIC can be in any state. */
 	igb_irq_disable(adapter);

