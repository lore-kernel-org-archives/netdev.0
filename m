From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/13] i40e: amortize wait time when disabling lots of VFs
Date: Sun, 30 Apr 2017 06:24:43 -0700
Message-ID: <20170430132451.68494-6-jeffrey.t.kirsher@intel.com>
References: <20170430132451.68494-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:57823 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1163518AbdD3NY6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 30 Apr 2017 09:24:58 -0400
In-Reply-To: <20170430132451.68494-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Just as we do in i40e_reset_all_vfs, save some time when freeing VFs by
amortizing the wait time for stopping queues. We can use
i40e_vsi_stop_rings_no_wait() to begin the process of stopping all the
VF rings at once. Then, once we've started the process on each VF we can
begin waiting for the VFs to stop. This helps reduce the total wait time
by a large factor.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 16 ++++++++++++++--
 1 file changed, 14 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 74977a295987..2a47a6474366 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1194,9 +1194,21 @@ void i40e_free_vfs(struct i40e_pf *pf)
 		usleep_range(1000, 2000);
 
 	i40e_notify_client_of_vf_enable(pf, 0);
-	for (i = 0; i < pf->num_alloc_vfs; i++)
+
+	/* Amortize wait time by stopping all VFs at the same time */
+	for (i = 0; i < pf->num_alloc_vfs; i++) {
+		if (test_bit(I40E_VF_STATE_INIT, &pf->vf[i].vf_states))
+			continue;
+
+		i40e_vsi_stop_rings_no_wait(pf->vsi[pf->vf[i].lan_vsi_idx]);
+	}
+
+	for (i = 0; i < pf->num_alloc_vfs; i++) {
 		if (test_bit(I40E_VF_STATE_INIT, &pf->vf[i].vf_states))
-			i40e_vsi_stop_rings(pf->vsi[pf->vf[i].lan_vsi_idx]);
+			continue;
+
+		i40e_vsi_wait_queues_disabled(pf->vsi[pf->vf[i].lan_vsi_idx]);
+	}
 
 	/* Disable IOV before freeing resources. This lets any VF drivers
 	 * running in the host get themselves cleaned up before we yank
-- 
2.12.2
