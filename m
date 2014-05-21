From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/15] i40e: Don't disable SR-IOV when VFs are assigned
Date: Wed, 21 May 2014 05:01:09 -0700
Message-ID: <1400673673-31626-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1400673673-31626-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:3720 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752455AbaEUMBn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 May 2014 08:01:43 -0400
In-Reply-To: <1400673673-31626-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

When VFs are assigned to active VMs and we disable SR-IOV out from under them,
bad things happen. Currently, the VM does not crash, but the VFs lose all
resources and have no way to get them back.

Add an additional check for when the user is disabling through sysfs, and add a
comment to clarify why we check twice.

Change-ID: Icad78eef516e4e1e4a87874d59132bc3baa058d4
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 82e7abf..4d21956 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -842,6 +842,10 @@ void i40e_free_vfs(struct i40e_pf *pf)
 	kfree(pf->vf);
 	pf->vf = NULL;
 
+	/* This check is for when the driver is unloaded while VFs are
+	 * assigned. Setting the number of VFs to 0 through sysfs is caught
+	 * before this function ever gets called.
+	 */
 	if (!i40e_vfs_are_assigned(pf)) {
 		pci_disable_sriov(pf->pdev);
 		/* Acknowledge VFLR for all VFS. Without this, VFs will fail to
@@ -978,7 +982,12 @@ int i40e_pci_sriov_configure(struct pci_dev *pdev, int num_vfs)
 	if (num_vfs)
 		return i40e_pci_sriov_enable(pdev, num_vfs);
 
-	i40e_free_vfs(pf);
+	if (!i40e_vfs_are_assigned(pf)) {
+		i40e_free_vfs(pf);
+	} else {
+		dev_warn(&pdev->dev, "Unable to free VFs because some are assigned to VMs.\n");
+		return -EINVAL;
+	}
 	return 0;
 }
 
-- 
1.9.0
