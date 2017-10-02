From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/15] i40e: fix handling of vf_states variable
Date: Mon,  2 Oct 2017 12:48:50 -0700
Message-ID: <20171002194852.71970-14-jeffrey.t.kirsher@intel.com>
References: <20171002194852.71970-1-jeffrey.t.kirsher@intel.com>
Cc: Alan Brady <alan.brady@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:36724 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751268AbdJBTtU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 2 Oct 2017 15:49:20 -0400
In-Reply-To: <20171002194852.71970-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Brady <alan.brady@intel.com>

Currently we inappropriately clear the vf_states variable with a null
assignment.  This is problematic because we should be using atomic
bitops on this variable and we don't actually want to clear all the
flags.  We should just clear the ones we know we want to clear.
Additionally remove the I40E_VF_STATE_FCOEENA bit because it is no
longer being used.

Signed-off-by: Alan Brady <alan.brady@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 5 ++++-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h | 1 -
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 7742cf3d38d9..989a65d60ac9 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -879,7 +879,8 @@ static void i40e_free_vf_res(struct i40e_vf *vf)
 	}
 	/* reset some of the state variables keeping track of the resources */
 	vf->num_queue_pairs = 0;
-	vf->vf_states = 0;
+	clear_bit(I40E_VF_STATE_MC_PROMISC, &vf->vf_states);
+	clear_bit(I40E_VF_STATE_UC_PROMISC, &vf->vf_states);
 }
 
 /**
@@ -1586,6 +1587,8 @@ static int i40e_vc_get_vf_resources_msg(struct i40e_vf *vf, u8 *msg)
 	    (vf->driver_caps & VIRTCHNL_VF_OFFLOAD_IWARP)) {
 		vfres->vf_cap_flags |= VIRTCHNL_VF_OFFLOAD_IWARP;
 		set_bit(I40E_VF_STATE_IWARPENA, &vf->vf_states);
+	} else {
+		clear_bit(I40E_VF_STATE_IWARPENA, &vf->vf_states);
 	}
 
 	if (vf->driver_caps & VIRTCHNL_VF_OFFLOAD_RSS_PF) {
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
index 5ea42ad094bc..5efc4f92bb37 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
@@ -56,7 +56,6 @@ enum i40e_vf_states {
 	I40E_VF_STATE_INIT = 0,
 	I40E_VF_STATE_ACTIVE,
 	I40E_VF_STATE_IWARPENA,
-	I40E_VF_STATE_FCOEENA,
 	I40E_VF_STATE_DISABLED,
 	I40E_VF_STATE_MC_PROMISC,
 	I40E_VF_STATE_UC_PROMISC,
-- 
2.14.2
