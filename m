From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/13] i40e: make use of i40e_reset_all_vfs when initializing new VFs
Date: Sun, 30 Apr 2017 06:24:40 -0700
Message-ID: <20170430132451.68494-3-jeffrey.t.kirsher@intel.com>
References: <20170430132451.68494-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:4938 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1163495AbdD3NY5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 30 Apr 2017 09:24:57 -0400
In-Reply-To: <20170430132451.68494-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

When allocating a large number of VFs, the driver previously used
i40e_reset_vf in a sequence. Just as when performing a normal reset,
this accumulates a large amount of delay for handling all of the VFs in
sequence. This delay is mainly due to a hardware requirement to wait
after initiating a reset on the VF.

We recently added a new function, i40e_reset_all_vfs() which can be used
to amortize the delay time, by first triggering all VF resets, then
waiting once, and finally cleaning up and allocating the VFs. This is
almost as good as truly running the resets in parallel.

In order to avoid sending a spurious reset message to a client
interface, we have a check to see whether we've assigned
pf->num_alloc_vfs yet. This was originally intended as a way to
distinguish the "initialization" case from the regular reset case.

Unfortunately, this means that we can't directly use i40e_reset_all_vfs
yet. Lets avoid this check of pf->num_alloc_vfs by replacing it with
a proper VSI state bit which we can use instead. This makes the
intention much clearer and allows us to re-use the i40e_reset_all_vfs
function directly.

Change-ID: I694279b37eb6b5a91b6670182d0c15d10244fd6e
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Reviewed-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 10 +++++++---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |  1 +
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index a46c07799384..74977a295987 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1007,7 +1007,8 @@ static void i40e_cleanup_reset_vf(struct i40e_vf *vf)
 		set_bit(I40E_VF_STATE_ACTIVE, &vf->vf_states);
 		clear_bit(I40E_VF_STATE_DISABLED, &vf->vf_states);
 		/* Do not notify the client during VF init */
-		if (vf->pf->num_alloc_vfs)
+		if (test_and_clear_bit(I40E_VF_STATE_PRE_ENABLE,
+				       &vf->vf_states))
 			i40e_notify_client_of_vf_reset(pf, abs_vf_id);
 		vf->num_vlan = 0;
 	}
@@ -1280,12 +1281,15 @@ int i40e_alloc_vfs(struct i40e_pf *pf, u16 num_alloc_vfs)
 		/* assign default capabilities */
 		set_bit(I40E_VIRTCHNL_VF_CAP_L2, &vfs[i].vf_caps);
 		vfs[i].spoofchk = true;
-		/* VF resources get allocated during reset */
-		i40e_reset_vf(&vfs[i], false);
+
+		set_bit(I40E_VF_STATE_PRE_ENABLE, &vfs[i].vf_states);
 
 	}
 	pf->num_alloc_vfs = num_alloc_vfs;
 
+	/* VF resources get allocated during reset */
+	i40e_reset_all_vfs(pf, false);
+
 	i40e_notify_client_of_vf_enable(pf, num_alloc_vfs);
 
 err_alloc:
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
index 8c7c08489612..20d7c8160e9e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
@@ -63,6 +63,7 @@ enum i40e_vf_states {
 	I40E_VF_STATE_DISABLED,
 	I40E_VF_STATE_MC_PROMISC,
 	I40E_VF_STATE_UC_PROMISC,
+	I40E_VF_STATE_PRE_ENABLE,
 };
 
 /* VF capabilities */
-- 
2.12.2
