From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/15] i40e: acknowledge VFLR when disabling SR-IOV
Date: Mon,  6 Jan 2014 04:30:29 -0800
Message-ID: <1389011436-18424-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1389011436-18424-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:44283 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750932AbaAFMam (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jan 2014 07:30:42 -0500
In-Reply-To: <1389011436-18424-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

When SR-IOV is disabled, the (now nonexistent) virtual function
devices undergo a VFLR event. We don't need to handle this event
because the VFs are gone, but we do need to tell the HW that they are
complete. This fixes an issue with a phantom VFLR and broken VFs when
SR-IOV is re-enabled.

Change-Id: I7580b49ded0158172a85b14661ec212af77000c8
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index f92404c..e91f9d7 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -726,7 +726,9 @@ static bool i40e_vfs_are_assigned(struct i40e_pf *pf)
  **/
 void i40e_free_vfs(struct i40e_pf *pf)
 {
-	int i, tmp;
+	struct i40e_hw *hw = &pf->hw;
+	u32 reg_idx, bit_idx;
+	int i, tmp, vf_id;
 
 	if (!pf->vf)
 		return;
@@ -748,8 +750,17 @@ void i40e_free_vfs(struct i40e_pf *pf)
 	kfree(pf->vf);
 	pf->vf = NULL;
 
-	if (!i40e_vfs_are_assigned(pf))
+	if (!i40e_vfs_are_assigned(pf)) {
 		pci_disable_sriov(pf->pdev);
+		/* Acknowledge VFLR for all VFS. Without this, VFs will fail to
+		 * work correctly when SR-IOV gets re-enabled.
+		 */
+		for (vf_id = 0; vf_id < tmp; vf_id++) {
+			reg_idx = (hw->func_caps.vf_base_id + vf_id) / 32;
+			bit_idx = (hw->func_caps.vf_base_id + vf_id) % 32;
+			wr32(hw, I40E_GLGEN_VFLRSTAT(reg_idx), (1 << bit_idx));
+		}
+	}
 	else
 		dev_warn(&pf->pdev->dev,
 			 "unable to disable SR-IOV because VFs are assigned.\n");
-- 
1.8.3.1
