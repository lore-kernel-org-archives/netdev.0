From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/14] igb: Use pci_vfs_assigned instead of igb_vfs_are_assigned
Date: Wed, 24 Apr 2013 21:08:42 -0700
Message-ID: <1366862927-1855-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1366862927-1855-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:33226 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751332Ab3DYEJG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Apr 2013 00:09:06 -0400
In-Reply-To: <1366862927-1855-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change makes it so that the igb driver uses the generic helper
pci_vfs_assigned instead of the igb specific function igb_vfs_are_assigned.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 36 +------------------------------
 1 file changed, 1 insertion(+), 35 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index dcaa354..b94a3c5 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -180,7 +180,6 @@ static void igb_check_vf_rate_limit(struct igb_adapter *);
 
 #ifdef CONFIG_PCI_IOV
 static int igb_vf_configure(struct igb_adapter *adapter, int vf);
-static bool igb_vfs_are_assigned(struct igb_adapter *adapter);
 #endif
 
 #ifdef CONFIG_PM
@@ -2402,7 +2401,7 @@ static int  igb_disable_sriov(struct pci_dev *pdev)
 	/* reclaim resources allocated to VFs */
 	if (adapter->vf_data) {
 		/* disable iov and allow time for transactions to clear */
-		if (igb_vfs_are_assigned(adapter)) {
+		if (pci_vfs_assigned(pdev)) {
 			dev_warn(&pdev->dev,
 				 "Cannot deallocate SR-IOV virtual functions while they are assigned - VFs will not be deallocated\n");
 			return -EPERM;
@@ -5242,39 +5241,6 @@ static int igb_vf_configure(struct igb_adapter *adapter, int vf)
 	return 0;
 }
 
-static bool igb_vfs_are_assigned(struct igb_adapter *adapter)
-{
-	struct pci_dev *pdev = adapter->pdev;
-	struct pci_dev *vfdev;
-	int dev_id;
-
-	switch (adapter->hw.mac.type) {
-	case e1000_82576:
-		dev_id = IGB_82576_VF_DEV_ID;
-		break;
-	case e1000_i350:
-		dev_id = IGB_I350_VF_DEV_ID;
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
 #endif
 static void igb_ping_all_vfs(struct igb_adapter *adapter)
 {
-- 
1.7.11.7
