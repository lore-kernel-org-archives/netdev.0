From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/10] ixgbe: Use pci_vfs_assigned instead of ixgbe_vfs_are_assigned
Date: Wed, 26 Jun 2013 03:55:14 -0700
Message-ID: <1372244122-17664-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1372244122-17664-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:61757 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751711Ab3FZKz0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jun 2013 06:55:26 -0400
In-Reply-To: <1372244122-17664-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change makes it so that the ixgbe driver uses the generic helper
pci_vfs_assigned instead of the ixgbe specific function
ixgbe_vfs_are_assigned.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 35 +-------------------------
 1 file changed, 1 insertion(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index a85d5f4..6369fb9 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -173,39 +173,6 @@ void ixgbe_enable_sriov(struct ixgbe_adapter *adapter)
 	ixgbe_disable_sriov(adapter);
 }
 
-static bool ixgbe_vfs_are_assigned(struct ixgbe_adapter *adapter)
-{
-	struct pci_dev *pdev = adapter->pdev;
-	struct pci_dev *vfdev;
-	int dev_id;
-
-	switch (adapter->hw.mac.type) {
-	case ixgbe_mac_82599EB:
-		dev_id = IXGBE_DEV_ID_82599_VF;
-		break;
-	case ixgbe_mac_X540:
-		dev_id = IXGBE_DEV_ID_X540_VF;
-		break;
-	default:
-		return false;
-	}
-
-	/* loop through all the VFs to see if we own any that are assigned */
-	vfdev = pci_get_device(PCI_VENDOR_ID_INTEL, dev_id, NULL);
-	while (vfdev) {
-		/* if we don't own it we don't care */
-		if (vfdev->is_virtfn && vfdev->physfn == pdev) {
-			/* if it is assigned we cannot release it */
-			if (vfdev->dev_flags & PCI_DEV_FLAGS_ASSIGNED)
-				return true;
-		}
-
-		vfdev = pci_get_device(PCI_VENDOR_ID_INTEL, dev_id, vfdev);
-	}
-
-	return false;
-}
-
 #endif /* #ifdef CONFIG_PCI_IOV */
 int ixgbe_disable_sriov(struct ixgbe_adapter *adapter)
 {
@@ -235,7 +202,7 @@ int ixgbe_disable_sriov(struct ixgbe_adapter *adapter)
 	 * without causing issues, so just leave the hardware
 	 * available but disabled
 	 */
-	if (ixgbe_vfs_are_assigned(adapter)) {
+	if (pci_vfs_assigned(adapter->pdev)) {
 		e_dev_warn("Unloading driver while VFs are assigned - VFs will not be deallocated\n");
 		return -EPERM;
 	}
-- 
1.7.11.7
