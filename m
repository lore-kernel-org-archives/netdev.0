From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/17] i40e: don't panic on VSI allocation failure
Date: Mon, 12 Oct 2015 22:53:09 -0700
Message-ID: <1444715598-20970-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444715598-20970-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:24922 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752111AbbJMFx2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Oct 2015 01:53:28 -0400
In-Reply-To: <1444715598-20970-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

In some circumstances, the firmware may fail to allocate a VSI for a VF.
When this happens, the driver does not react well to the bad news and
has a panic attack.

To fix this problem, check the return value from i40e_alloc_vf_res and
don't try to configure the device further if it failed. Additionally,
explicitly clear the INIT bit when we free VF resources, so that this
bit will be in the proper state in the failure case, and won't blow up
elsewhere.

Change-ID: I6a20ce2b59c3458fd832032e88fa28cd42500189
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 2102280..ae7548a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -703,6 +703,7 @@ static void i40e_free_vf_res(struct i40e_vf *vf)
 	 */
 	vf->num_queue_pairs = 0;
 	vf->vf_states = 0;
+	clear_bit(I40E_VF_STAT_INIT, &vf->vf_states);
 }
 
 /**
@@ -841,11 +842,11 @@ void i40e_reset_vf(struct i40e_vf *vf, bool flr)
 complete_reset:
 	/* reallocate VF resources to reset the VSI state */
 	i40e_free_vf_res(vf);
-	i40e_alloc_vf_res(vf);
-	i40e_enable_vf_mappings(vf);
-	set_bit(I40E_VF_STAT_ACTIVE, &vf->vf_states);
-	clear_bit(I40E_VF_STAT_DISABLED, &vf->vf_states);
-
+	if (!i40e_alloc_vf_res(vf)) {
+		i40e_enable_vf_mappings(vf);
+		set_bit(I40E_VF_STAT_ACTIVE, &vf->vf_states);
+		clear_bit(I40E_VF_STAT_DISABLED, &vf->vf_states);
+	}
 	/* tell the VF the reset is done */
 	wr32(hw, I40E_VFGEN_RSTAT1(vf->vf_id), I40E_VFR_VFACTIVE);
 	i40e_flush(hw);
-- 
2.4.3
