From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/18] i40e: stop VF rings
Date: Wed,  7 Oct 2015 15:46:57 -0700
Message-ID: <1444258032-41476-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444258032-41476-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:33566 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753714AbbJGWrZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Oct 2015 18:47:25 -0400
In-Reply-To: <1444258032-41476-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Explicitly stop the rings belonging to each VF when disabling SR-IOV.
Even though the VFs were gone, and the associated VSIs were removed, the
rings were not stopped, and in some circumstances the hardware would
continue to access the memory formerly used by the rings, causing memory
corruption or DMAR errors, both of which would lead to general malaise
of the kernel.

To relieve this condition, explicitly stop all the rings associated with
each VF before releasing its resources.

Change-ID: I78c05d562c66e7b594b7e48d67860f49b3e5b6ec
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index b148694..0545e3f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -872,6 +872,11 @@ void i40e_free_vfs(struct i40e_pf *pf)
 			i40e_vsi_control_rings(pf->vsi[pf->vf[i].lan_vsi_idx],
 					       false);
 
+	for (i = 0; i < pf->num_alloc_vfs; i++)
+		if (test_bit(I40E_VF_STAT_INIT, &pf->vf[i].vf_states))
+			i40e_vsi_control_rings(pf->vsi[pf->vf[i].lan_vsi_idx],
+					       false);
+
 	/* Disable IOV before freeing resources. This lets any VF drivers
 	 * running in the host get themselves cleaned up before we yank
 	 * the carpet out from underneath their feet.
-- 
2.4.3
