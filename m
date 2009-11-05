From: Simon Horman <horms@verge.net.au>
Subject: [rfc 2/4] igb: Initialise
	adapter->vfs_allocated_count in igb_init_vf()
Date: Thu, 05 Nov 2009 11:58:49 +1100
Message-ID: <20091105010627.464560295@vergenet.net>
References: <20091105005847.941190065@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arndbergmann@googlemail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: e1000-devel@lists.sourceforge.net,
 netdev@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline; filename=igb_init_vf-vfs_allocated_count.patch
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Initialise adapter->vfs_allocated_count in igb_init_vf()
and only do so if the VFs are successfully created.

This seems a lot tidier to me, for starters igb_init_vf() is no longer
spliced in two by an #ifdef just to allow vfs_allocated_count to be reset to
0 if CONFIG_PCI_IOV is unset.

This change will break things if igb_init_interrupt_scheme() relies on
adapter->vfs_allocated_count, but on inspection it appears not to.

Signed-off-by: Simon Horman <horms@verge.net.au>

Index: net-next-2.6/drivers/net/igb/igb_main.c
===================================================================
--- net-next-2.6.orig/drivers/net/igb/igb_main.c	2009-11-05 04:46:06.000000000 +0900
+++ net-next-2.6/drivers/net/igb/igb_main.c	2009-11-05 04:51:10.000000000 +0900
@@ -1723,48 +1723,48 @@ static void __devexit igb_remove(struct 
 /**
  * igb_init_vf - Initialize vf data storage and add VFs to pci config space
  * @adapter: board private structure to initialize
+ * @vfn: requested number of virtual functions
  *
  * This function initializes the vf specific data storage and then attempts to
  * allocate the VFs.  The reason for ordering it this way is because it is much
  * mor expensive time wise to disable SR-IOV than it is to allocate and free
  * the memory for the VFs.
  **/
-static void __devinit igb_init_vf(struct igb_adapter * adapter)
+static void __devinit igb_init_vf(struct igb_adapter * adapter, int vfn)
 {
 #ifdef CONFIG_PCI_IOV
 	struct pci_dev *pdev = adapter->pdev;
+	struct e1000_hw *hw = &adapter->hw;
 
-	if (adapter->vfs_allocated_count > 7)
-		adapter->vfs_allocated_count = 7;
+	if (hw->mac.type != e1000_82576 || !vfn)
+		return;
 
-	if (adapter->vfs_allocated_count) {
-		adapter->vf_data = kcalloc(adapter->vfs_allocated_count,
-		                           sizeof(struct vf_data_storage),
-		                           GFP_KERNEL);
-		/* if allocation failed then we do not support SR-IOV */
-		if (!adapter->vf_data) {
-			adapter->vfs_allocated_count = 0;
-			dev_err(&pdev->dev, "Unable to allocate memory for VF "
-			        "Data Storage\n");
-		}
+	if (vfn > 7)
+		vfn = 7;
+
+	adapter->vf_data = kcalloc(vfn, sizeof(struct vf_data_storage),
+				   GFP_KERNEL);
+	/* if allocation failed then we do not support SR-IOV */
+	if (!adapter->vf_data) {
+		dev_err(&pdev->dev, "Unable to allocate memory for VF "
+		        "Data Storage\n");
+		return;
 	}
 
-	if (pci_enable_sriov(pdev, adapter->vfs_allocated_count)) {
+	if (pci_enable_sriov(pdev, vfn)) {
 		kfree(adapter->vf_data);
 		adapter->vf_data = NULL;
-#endif /* CONFIG_PCI_IOV */
-		adapter->vfs_allocated_count = 0;
-#ifdef CONFIG_PCI_IOV
 	} else {
 		unsigned char mac_addr[ETH_ALEN];
 		int i;
-		dev_info(&pdev->dev, "%d vfs allocated\n",
-		         adapter->vfs_allocated_count);
-		for (i = 0; i < adapter->vfs_allocated_count; i++) {
+		dev_info(&pdev->dev, "%d vfs allocated\n", vfn);
+		for (i = 0; i < vfn; i++) {
 			random_ether_addr(mac_addr);
 			igb_set_vf_mac(adapter, i, mac_addr);
 		}
 	}
+
+	adapter->vfs_allocated_count = vfn;
 #endif /* CONFIG_PCI_IOV */
 }
 
@@ -1821,18 +1821,13 @@ static int __devinit igb_sw_init(struct 
 	adapter->max_frame_size = netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
 	adapter->min_frame_size = ETH_ZLEN + ETH_FCS_LEN;
 
-#ifdef CONFIG_PCI_IOV
-	if (hw->mac.type == e1000_82576)
-		adapter->vfs_allocated_count = max_vfs;
-
-#endif /* CONFIG_PCI_IOV */
 	/* This call may decrease the number of queues */
 	if (igb_init_interrupt_scheme(adapter)) {
 		dev_err(&pdev->dev, "Unable to allocate memory for queues\n");
 		return -ENOMEM;
 	}
 
-	igb_init_vf(adapter);
+	igb_init_vf(adapter, max_vfs);
 
 	/* Explicitly disable IRQ since the NIC can be in any state. */
 	igb_irq_disable(adapter);


------------------------------------------------------------------------------
Let Crystal Reports handle the reporting - Free Crystal Reports 2008 30-Day 
trial. Simplify your report design, integration and deployment - and focus on 
what you do best, core application coding. Discover what's new with
Crystal Reports now.  http://p.sf.net/sfu/bobj-july
