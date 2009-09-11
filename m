From: Simon Horman <horms@verge.net.au>
Subject: [patch] igb: Tidy vf initialisation
Date: Fri, 11 Sep 2009 12:18:42 +1000
Message-ID: <20090911021842.GC3221@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: John Ronciak <john.ronciak@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

This is purely cosmetic, but to my mind it makes the code a lot easier
to follow.

Signed-off-by: Simon Horman <horms@verge.net.au>

Index: net-next-2.6/drivers/net/igb/igb_main.c
===================================================================
--- net-next-2.6.orig/drivers/net/igb/igb_main.c	2009-09-09 15:04:34.000000000 +1000
+++ net-next-2.6/drivers/net/igb/igb_main.c	2009-09-09 16:06:59.000000000 +1000
@@ -1194,6 +1194,44 @@ static const struct net_device_ops igb_n
 #endif
 };
 
+/* Since IOV functionality isn't critical to base device function we can
+ * accept failure.  If it fails we don't allow IOV to be enabled */
+static void __devinit igb_probe_vf(struct pci_dev *pdev,
+				   struct igb_adapter *adapter)
+{
+#ifdef CONFIG_PCI_IOV
+	/* 82576 supports a maximum of 7 VFs in addition to the PF */
+	unsigned int num_vfs = (max_vfs > 7) ? 7 : max_vfs;
+	int i;
+	unsigned char mac_addr[ETH_ALEN];
+
+	if (adapter->hw.mac.type != e1000_82576 || !num_vfs)
+		return;
+
+	adapter->vf_data = kcalloc(num_vfs, sizeof(struct vf_data_storage),
+				   GFP_KERNEL);
+	if (!adapter->vf_data) {
+		dev_err(&pdev->dev, "Could not allocate VF private data - "
+				    "IOV enable failed\n");
+		return;
+	}
+
+	if (pci_enable_sriov(pdev, num_vfs)) {
+		kfree(adapter->vf_data);
+		adapter->vf_data = NULL;
+		return;
+	}
+
+	adapter->vfs_allocated_count = num_vfs;
+	dev_info(&pdev->dev, "%d vfs allocated\n", num_vfs);
+	for (i = 0; i < adapter->vfs_allocated_count; i++) {
+		random_ether_addr(mac_addr);
+		igb_set_vf_mac(adapter, i, mac_addr);
+	}
+#endif
+	return;
+}
+
 /**
  * igb_probe - Device Initialization Routine
  * @pdev: PCI device information struct
@@ -1307,46 +1345,8 @@ static int __devinit igb_probe(struct pc
 	if (err)
 		goto err_sw_init;
 
-#ifdef CONFIG_PCI_IOV
-	/* since iov functionality isn't critical to base device function we
-	 * can accept failure.  If it fails we don't allow iov to be enabled */
-	if (hw->mac.type == e1000_82576) {
-		/* 82576 supports a maximum of 7 VFs in addition to the PF */
-		unsigned int num_vfs = (max_vfs > 7) ? 7 : max_vfs;
-		int i;
-		unsigned char mac_addr[ETH_ALEN];
-
-		if (num_vfs) {
-			adapter->vf_data = kcalloc(num_vfs,
-						sizeof(struct vf_data_storage),
-						GFP_KERNEL);
-			if (!adapter->vf_data) {
-				dev_err(&pdev->dev,
-				        "Could not allocate VF private data - "
-					"IOV enable failed\n");
-			} else {
-				err = pci_enable_sriov(pdev, num_vfs);
-				if (!err) {
-					adapter->vfs_allocated_count = num_vfs;
-					dev_info(&pdev->dev,
-					         "%d vfs allocated\n",
-					         num_vfs);
-					for (i = 0;
-					     i < adapter->vfs_allocated_count;
-					     i++) {
-						random_ether_addr(mac_addr);
-						igb_set_vf_mac(adapter, i,
-						               mac_addr);
-					}
-				} else {
-					kfree(adapter->vf_data);
-					adapter->vf_data = NULL;
-				}
-			}
-		}
-	}
+	igb_probe_vf(pdev, adapter);
 
-#endif
 	/* setup the private structure */
 	err = igb_sw_init(adapter);
 	if (err)

------------------------------------------------------------------------------
Let Crystal Reports handle the reporting - Free Crystal Reports 2008 30-Day 
trial. Simplify your report design, integration and deployment - and focus on 
what you do best, core application coding. Discover what's new with 
Crystal Reports now.  http://p.sf.net/sfu/bobj-july
