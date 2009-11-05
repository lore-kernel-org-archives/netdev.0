From: Simon Horman <horms@verge.net.au>
Subject: [rfc 3/4] igb: Common error path in igb_init_vfs()
Date: Thu, 05 Nov 2009 11:58:50 +1100
Message-ID: <20091105010627.806283906@vergenet.net>
References: <20091105005847.941190065@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arndbergmann@googlemail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: e1000-devel@lists.sourceforge.net,
 netdev@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline; filename=igb_init_vf-err.patch
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Drop out into an error path on error.

This is a bit superfluous as things stand, though arguably
it already makes the code cleaner. But it should help things a lot
if igb_init_vfs() has a several things to unwind on error.

Signed-off-by: Simon Horman <horms@verge.net.au>

Index: net-next-2.6/drivers/net/igb/igb_main.c
===================================================================
--- net-next-2.6.orig/drivers/net/igb/igb_main.c	2009-11-05 04:52:16.000000000 +0900
+++ net-next-2.6/drivers/net/igb/igb_main.c	2009-11-05 16:36:01.000000000 +0900
@@ -1735,6 +1735,8 @@ static void __devinit igb_init_vf(struct
 #ifdef CONFIG_PCI_IOV
 	struct pci_dev *pdev = adapter->pdev;
 	struct e1000_hw *hw = &adapter->hw;
+	unsigned char mac_addr[ETH_ALEN];
+	int i;
 
 	if (hw->mac.type != e1000_82576 || !vfn)
 		return;
@@ -1751,20 +1753,21 @@ static void __devinit igb_init_vf(struct
 		return;
 	}
 
-	if (pci_enable_sriov(pdev, vfn)) {
-		kfree(adapter->vf_data);
-		adapter->vf_data = NULL;
-	} else {
-		unsigned char mac_addr[ETH_ALEN];
-		int i;
-		dev_info(&pdev->dev, "%d vfs allocated\n", vfn);
-		for (i = 0; i < vfn; i++) {
-			random_ether_addr(mac_addr);
-			igb_set_vf_mac(adapter, i, mac_addr);
-		}
+	if (pci_enable_sriov(pdev, vfn))
+		goto err;
+
+	dev_info(&pdev->dev, "%d vfs allocated\n", vfn);
+	for (i = 0; i < vfn; i++) {
+		random_ether_addr(mac_addr);
+		igb_set_vf_mac(adapter, i, mac_addr);
 	}
 
 	adapter->vfs_allocated_count = vfn;
+
+	return;
+err:
+	kfree(adapter->vf_data);
+	adapter->vf_data = NULL;
 #endif /* CONFIG_PCI_IOV */
 }
 


------------------------------------------------------------------------------
Let Crystal Reports handle the reporting - Free Crystal Reports 2008 30-Day 
trial. Simplify your report design, integration and deployment - and focus on 
what you do best, core application coding. Discover what's new with
Crystal Reports now.  http://p.sf.net/sfu/bobj-july
