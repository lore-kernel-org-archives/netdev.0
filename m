From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/11] i40e: Fixed race conditions in VF reset
Date: Sat, 25 Mar 2017 01:12:58 -0700
Message-ID: <20170325081305.31835-5-jeffrey.t.kirsher@intel.com>
References: <20170325081305.31835-1-jeffrey.t.kirsher@intel.com>
Cc: Robert Konklewski <robertx.konklewski@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:23525 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751054AbdCYINK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 25 Mar 2017 04:13:10 -0400
In-Reply-To: <20170325081305.31835-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Konklewski <robertx.konklewski@intel.com>

First, this patch eliminates IOMMU DMAR Faults caused by VF hardware.
This is done by enabling VF hardware only after VSI resources are
freed. Otherwise, hardware could DMA into memory that is (or just has
been) being freed.

Then, the VF driver is activated only after VSI resources have been
reallocated. That's because the VF driver can request resources
immediately after it's activated. So they need to be ready at that
point.

The second race condition happens when the OS initiates a VF reset,
and then before it's finished modifies VF's settings by changing its
MAC, VLAN ID, bandwidth allocation, anti-spoof checking, etc. These
functions needed to be blocked while VF is undergoing reset. Otherwise,
they could operate on data structures that had just been freed or not
yet fully initialized.

Change-ID: I43ba5a7ae2c9a1cce3911611ffc4598ae33ae3ff
Signed-off-by: Robert Konklewski <robertx.konklewski@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 43 ++++++++++++++++++----
 1 file changed, 35 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index cfe8b78dac0e..d526940ff951 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -809,6 +809,11 @@ static void i40e_free_vf_res(struct i40e_vf *vf)
 	u32 reg_idx, reg;
 	int i, msix_vf;
 
+	/* Start by disabling VF's configuration API to prevent the OS from
+	 * accessing the VF's VSI after it's freed / invalidated.
+	 */
+	clear_bit(I40E_VF_STAT_INIT, &vf->vf_states);
+
 	/* free vsi & disconnect it from the parent uplink */
 	if (vf->lan_vsi_idx) {
 		i40e_vsi_release(pf->vsi[vf->lan_vsi_idx]);
@@ -848,7 +853,6 @@ static void i40e_free_vf_res(struct i40e_vf *vf)
 	/* reset some of the state variables keeping track of the resources */
 	vf->num_queue_pairs = 0;
 	vf->vf_states = 0;
-	clear_bit(I40E_VF_STAT_INIT, &vf->vf_states);
 }
 
 /**
@@ -939,6 +943,14 @@ void i40e_reset_vf(struct i40e_vf *vf, bool flr)
 	/* warn the VF */
 	clear_bit(I40E_VF_STAT_ACTIVE, &vf->vf_states);
 
+	/* Disable VF's configuration API during reset. The flag is re-enabled
+	 * in i40e_alloc_vf_res(), when it's safe again to access VF's VSI.
+	 * It's normally disabled in i40e_free_vf_res(), but it's safer
+	 * to do it earlier to give some time to finish to any VF config
+	 * functions that may still be running at this point.
+	 */
+	clear_bit(I40E_VF_STAT_INIT, &vf->vf_states);
+
 	/* In the case of a VFLR, the HW has already reset the VF and we
 	 * just need to clean up, so don't hit the VFRTRIG register.
 	 */
@@ -982,11 +994,6 @@ void i40e_reset_vf(struct i40e_vf *vf, bool flr)
 	if (!rsd)
 		dev_err(&pf->pdev->dev, "VF reset check timeout on VF %d\n",
 			vf->vf_id);
-	wr32(hw, I40E_VFGEN_RSTAT1(vf->vf_id), I40E_VFR_COMPLETED);
-	/* clear the reset bit in the VPGEN_VFRTRIG reg */
-	reg = rd32(hw, I40E_VPGEN_VFRTRIG(vf->vf_id));
-	reg &= ~I40E_VPGEN_VFRTRIG_VFSWR_MASK;
-	wr32(hw, I40E_VPGEN_VFRTRIG(vf->vf_id), reg);
 
 	/* On initial reset, we won't have any queues */
 	if (vf->lan_vsi_idx == 0)
@@ -994,8 +1001,24 @@ void i40e_reset_vf(struct i40e_vf *vf, bool flr)
 
 	i40e_vsi_stop_rings(pf->vsi[vf->lan_vsi_idx]);
 complete_reset:
-	/* reallocate VF resources to reset the VSI state */
+	/* free VF resources to begin resetting the VSI state */
 	i40e_free_vf_res(vf);
+
+	/* Enable hardware by clearing the reset bit in the VPGEN_VFRTRIG reg.
+	 * By doing this we allow HW to access VF memory at any point. If we
+	 * did it any sooner, HW could access memory while it was being freed
+	 * in i40e_free_vf_res(), causing an IOMMU fault.
+	 *
+	 * On the other hand, this needs to be done ASAP, because the VF driver
+	 * is waiting for this to happen and may report a timeout. It's
+	 * harmless, but it gets logged into Guest OS kernel log, so best avoid
+	 * it.
+	 */
+	reg = rd32(hw, I40E_VPGEN_VFRTRIG(vf->vf_id));
+	reg &= ~I40E_VPGEN_VFRTRIG_VFSWR_MASK;
+	wr32(hw, I40E_VPGEN_VFRTRIG(vf->vf_id), reg);
+
+	/* reallocate VF resources to finish resetting the VSI state */
 	if (!i40e_alloc_vf_res(vf)) {
 		int abs_vf_id = vf->vf_id + hw->func_caps.vf_base_id;
 		i40e_enable_vf_mappings(vf);
@@ -1006,7 +1029,11 @@ void i40e_reset_vf(struct i40e_vf *vf, bool flr)
 			i40e_notify_client_of_vf_reset(pf, abs_vf_id);
 		vf->num_vlan = 0;
 	}
-	/* tell the VF the reset is done */
+
+	/* Tell the VF driver the reset is done. This needs to be done only
+	 * after VF has been fully initialized, because the VF driver may
+	 * request resources immediately after setting this flag.
+	 */
 	wr32(hw, I40E_VFGEN_RSTAT1(vf->vf_id), I40E_VFR_VFACTIVE);
 
 	i40e_flush(hw);
-- 
2.12.0
