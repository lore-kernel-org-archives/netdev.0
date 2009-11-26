From: Simon Horman <horms@verge.net.au>
Subject: [rfc 2/3 v3] [E1000-devel] [rfc 3/4] igb: Common error path in igb_init_vfs()
Date: Thu, 26 Nov 2009 11:05:40 +1100
Message-ID: <20091126000758.491056195@vergenet.net>
References: <20091126000538.716725330@vergenet.net>
Cc: Arnd Bergmann <arndbergmann@googlemail.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:41678 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759585AbZKZAMN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 19:12:13 -0500
Content-Disposition: inline; filename=igb-common-error-path-in-igb_init_vfs.2.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drop out into an error path on error.

This is a bit superfluous as things stand, though arguably
it already makes the code cleaner. But it should help things a lot
if igb_init_vfs() has a several things to unwind on error.

This patch eliminates resetting adapter->vfs_allocated_count to 0
in the case where CONFIG_PCI_IOV is not set, because in that
case adapter->vfs_allocated_count can never be non-zero.

Cc: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Simon Horman <horms@verge.net.au>

--- 
Thu, 05 Nov 2009 11:58:50 +1100
* Initial post

Wed, 25 Nov 2009 16:44:15 +1100
* Merged with " Initialise adapter->vfs_allocated_count in igb_init_vf()",
  however the initialisation of adapter->vfs_allocated_count is no
  longer moved into igb_init_vf() as doing so results in a panic.

Thu, 26 Nov 2009 10:29:02 +1100
As per suggestions from Alexander Duyck
* Don't try and allocate vf_data if there are no vfs
* Zero out vfs_allocated_count and vf_data in the
  non CONFIG_PCI_IOV case, just to be sure.

Index: net-next-2.6/drivers/net/igb/igb_main.c
===================================================================
--- net-next-2.6.orig/drivers/net/igb/igb_main.c	2009-11-26 10:21:58.000000000 +1100
+++ net-next-2.6/drivers/net/igb/igb_main.c	2009-11-26 10:23:50.000000000 +1100
@@ -1753,39 +1753,41 @@ static void __devinit igb_init_vf(struct
 {
 #ifdef CONFIG_PCI_IOV
 	struct pci_dev *pdev = adapter->pdev;
+	unsigned char mac_addr[ETH_ALEN];
+	int i;
+
+	if (!adapter->vfs_allocated_count)
+		goto err_zero;
 
 	if (adapter->vfs_allocated_count > 7)
 		adapter->vfs_allocated_count = 7;
 
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
+	adapter->vf_data = kcalloc(adapter->vfs_allocated_count,
+				   sizeof(struct vf_data_storage), GFP_KERNEL);
+	/* if allocation failed then we do not support SR-IOV */
+	if (!adapter->vf_data) {
+		dev_err(&pdev->dev, "Unable to allocate memory for VF "
+		        "Data Storage\n");
+		goto err_zero;
 	}
 
-	if (pci_enable_sriov(pdev, adapter->vfs_allocated_count)) {
-		kfree(adapter->vf_data);
-		adapter->vf_data = NULL;
-#endif /* CONFIG_PCI_IOV */
-		adapter->vfs_allocated_count = 0;
-#ifdef CONFIG_PCI_IOV
-	} else {
-		unsigned char mac_addr[ETH_ALEN];
-		int i;
-		dev_info(&pdev->dev, "%d vfs allocated\n",
-		         adapter->vfs_allocated_count);
-		for (i = 0; i < adapter->vfs_allocated_count; i++) {
-			random_ether_addr(mac_addr);
-			igb_set_vf_mac(adapter, i, mac_addr);
-		}
+	if (pci_enable_sriov(pdev, adapter->vfs_allocated_count))
+		goto err_free;
+
+	dev_info(&pdev->dev, "%d vfs allocated\n",
+		 adapter->vfs_allocated_count);
+	for (i = 0; i < adapter->vfs_allocated_count; i++) {
+		random_ether_addr(mac_addr);
+		igb_set_vf_mac(adapter, i, mac_addr);
 	}
+
+	return;
+err_free:
+	kfree(adapter->vf_data);
+err_zero:
 #endif /* CONFIG_PCI_IOV */
+	adapter->vf_data = NULL;
+	adapter->vfs_allocated_count = 0;
 }
 
 

