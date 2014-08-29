From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/15] i40e: use global pci_vfs_assigned() to replace local i40e_vfs_are_assigned()
Date: Fri, 29 Aug 2014 02:30:15 -0700
Message-ID: <1409304620-23251-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1409304620-23251-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Ethan Zhao <ethan.zhao@oracle.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com,
	Ethan Zhao <ethan.kernel@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:53242 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752509AbaH2Ja3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Aug 2014 05:30:29 -0400
In-Reply-To: <1409304620-23251-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ethan Zhao <ethan.zhao@oracle.com>

There is global funcion pci_vfs_assigned(), so use it instead of composing
local one.

Signed-off-by: Ethan Zhao <ethan.kernel@gmail.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 33 ++--------------------
 1 file changed, 2 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index aeae5f2..4eeed26 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -707,35 +707,6 @@ complete_reset:
 	wr32(hw, I40E_VFGEN_RSTAT1(vf->vf_id), I40E_VFR_VFACTIVE);
 	i40e_flush(hw);
 }
-
-/**
- * i40e_vfs_are_assigned
- * @pf: pointer to the pf structure
- *
- * Determine if any VFs are assigned to VMs
- **/
-static bool i40e_vfs_are_assigned(struct i40e_pf *pf)
-{
-	struct pci_dev *pdev = pf->pdev;
-	struct pci_dev *vfdev;
-
-	/* loop through all the VFs to see if we own any that are assigned */
-	vfdev = pci_get_device(PCI_VENDOR_ID_INTEL, I40E_DEV_ID_VF , NULL);
-	while (vfdev) {
-		/* if we don't own it we don't care */
-		if (vfdev->is_virtfn && pci_physfn(vfdev) == pdev) {
-			/* if it is assigned we cannot release it */
-			if (vfdev->dev_flags & PCI_DEV_FLAGS_ASSIGNED)
-				return true;
-		}
-
-		vfdev = pci_get_device(PCI_VENDOR_ID_INTEL,
-				       I40E_DEV_ID_VF,
-				       vfdev);
-	}
-
-	return false;
-}
 #ifdef CONFIG_PCI_IOV
 
 /**
@@ -843,7 +814,7 @@ void i40e_free_vfs(struct i40e_pf *pf)
 	 * assigned. Setting the number of VFs to 0 through sysfs is caught
 	 * before this function ever gets called.
 	 */
-	if (!i40e_vfs_are_assigned(pf)) {
+	if (!pci_vfs_assigned(pf->pdev)) {
 		pci_disable_sriov(pf->pdev);
 		/* Acknowledge VFLR for all VFS. Without this, VFs will fail to
 		 * work correctly when SR-IOV gets re-enabled.
@@ -980,7 +951,7 @@ int i40e_pci_sriov_configure(struct pci_dev *pdev, int num_vfs)
 	if (num_vfs)
 		return i40e_pci_sriov_enable(pdev, num_vfs);
 
-	if (!i40e_vfs_are_assigned(pf)) {
+	if (!pci_vfs_assigned(pf->pdev)) {
 		i40e_free_vfs(pf);
 	} else {
 		dev_warn(&pdev->dev, "Unable to free VFs because some are assigned to VMs.\n");
-- 
1.9.3
