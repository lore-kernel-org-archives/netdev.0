From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/14] i40e: stop VF rings
Date: Tue, 14 Apr 2015 21:51:38 -0700
Message-ID: <1429073511-27664-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1429073511-27664-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:56288 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932230AbbDOEvz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Apr 2015 00:51:55 -0400
In-Reply-To: <1429073511-27664-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Explicitly stop the rings belonging to each VF when disabling SR-IOV.
Even though the VFs were gone, and the associated VSIs were removed,
the rings were not stopped, and in some circumstances the hardware would
continue to access the memory formerly used by the rings, causing
memory corruption or DMAR errors, both of which would lead to general
malaise of the kernel.

To relieve this condition, explicitly stop all the rings associated with
each VF before releasing its resources.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 4d69e1f..9b3fc83 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -733,6 +733,11 @@ void i40e_free_vfs(struct i40e_pf *pf)
 	while (test_and_set_bit(__I40E_VF_DISABLE, &pf->state))
 		usleep_range(1000, 2000);
 
+	for (i = 0; i < pf->num_alloc_vfs; i++)
+		if (test_bit(I40E_VF_STAT_INIT, &pf->vf[i].vf_states))
+			i40e_vsi_control_rings(pf->vsi[pf->vf[i].lan_vsi_idx],
+					       false);
+
 	/* Disable IOV before freeing resources. This lets any VF drivers
 	 * running in the host get themselves cleaned up before we yank
 	 * the carpet out from underneath their feet.
-- 
1.9.3
