From: Simon Horman <horms@verge.net.au>
Subject: [rfc 1/4] igb: Add igb_cleanup_vf()
Date: Thu, 05 Nov 2009 11:58:48 +1100
Message-ID: <20091105010627.123781635@vergenet.net>
References: <20091105005847.941190065@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arndbergmann@googlemail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: e1000-devel@lists.sourceforge.net,
 netdev@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline; filename=igb_cleanup_vf.patch
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Move virtual finction cleanup code into igb_cleanup_vf() and for the sake
of symmetry rename igb_probe_vfs() as igb_init_vf().

Although these functions aren't entirely symmetrical it should aid
maintenance by making the relationship between initialisation and cleanup
more obvious.

Note that there appears to be no way for adapter->vfs_allocated_count to be
non-zero for the case where CONFIG_PCI_IOV is not set, so reseting this
value was moved to inside the relvant #ifdef.

Signed-off-by: Simon Horman <horms@verge.net.au>

Index: net-next-2.6/drivers/net/igb/igb_main.c
===================================================================
--- net-next-2.6.orig/drivers/net/igb/igb_main.c	2009-11-05 04:38:58.000000000 +0900
+++ net-next-2.6/drivers/net/igb/igb_main.c	2009-11-05 16:36:07.000000000 +0900
@@ -87,6 +87,7 @@ void igb_update_stats(struct igb_adapter
 static int igb_probe(struct pci_dev *, const struct pci_device_id *);
 static void __devexit igb_remove(struct pci_dev *pdev);
 static int igb_sw_init(struct igb_adapter *);
+static void igb_cleanup_vf(struct igb_adapter * adapter);
 static int igb_open(struct net_device *);
 static int igb_close(struct net_device *);
 static void igb_configure_tx(struct igb_adapter *);
@@ -650,21 +651,7 @@ static void igb_set_interrupt_capability
 
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
+	igb_cleanup_vf(adapter);
 	adapter->vfs_allocated_count = 0;
 	adapter->flags |= IGB_FLAG_QUEUE_PAIRS;
 	adapter->num_rx_queues = 1;
@@ -1734,7 +1721,7 @@ static void __devexit igb_remove(struct 
 }
 
 /**
- * igb_probe_vfs - Initialize vf data storage and add VFs to pci config space
+ * igb_init_vf - Initialize vf data storage and add VFs to pci config space
  * @adapter: board private structure to initialize
  *
  * This function initializes the vf specific data storage and then attempts to
@@ -1742,7 +1729,7 @@ static void __devexit igb_remove(struct 
  * mor expensive time wise to disable SR-IOV than it is to allocate and free
  * the memory for the VFs.
  **/
-static void __devinit igb_probe_vfs(struct igb_adapter * adapter)
+static void __devinit igb_init_vf(struct igb_adapter * adapter)
 {
 #ifdef CONFIG_PCI_IOV
 	struct pci_dev *pdev = adapter->pdev;
@@ -1782,6 +1769,35 @@ static void __devinit igb_probe_vfs(stru
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
@@ -1816,7 +1832,7 @@ static int __devinit igb_sw_init(struct 
 		return -ENOMEM;
 	}
 
-	igb_probe_vfs(adapter);
+	igb_init_vf(adapter);
 
 	/* Explicitly disable IRQ since the NIC can be in any state. */
 	igb_irq_disable(adapter);


------------------------------------------------------------------------------
Let Crystal Reports handle the reporting - Free Crystal Reports 2008 30-Day 
trial. Simplify your report design, integration and deployment - and focus on 
what you do best, core application coding. Discover what's new with
Crystal Reports now.  http://p.sf.net/sfu/bobj-july
