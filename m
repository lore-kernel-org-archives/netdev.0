From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/14] i40e: don't hold RTNL lock while waiting for VF reset to finish
Date: Wed, 19 Apr 2017 18:57:43 -0700
Message-ID: <20170420015750.6828-8-jeffrey.t.kirsher@intel.com>
References: <20170420015750.6828-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:47224 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S939048AbdDTB56 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Apr 2017 21:57:58 -0400
In-Reply-To: <20170420015750.6828-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

We made some effort to reduce the RTNL lock scope when resetting and
rebuilding the PF. Unfortunately we still held the RTNL lock during the
VF reset operation, which meant that multiple PFs could not reset in
parallel due to the global lock. For now, further reduce the scope by
not holding the RTNL lock while resetting VFs. This allows multiple PFs
to reset in a timely manner.

Change-ID: I2fbf823a0063f24dff67676cad09f0bbf83ee4ce
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 5e625e0c73ac..5c2ceb247959 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7108,6 +7108,10 @@ static void i40e_rebuild(struct i40e_pf *pf, bool reinit, bool lock_acquired)
 	/* restart the VSIs that were rebuilt and running before the reset */
 	i40e_pf_unquiesce_all_vsi(pf);
 
+	/* Release the RTNL lock before we start resetting VFs */
+	if (!lock_acquired)
+		rtnl_unlock();
+
 	if (pf->num_alloc_vfs) {
 		for (v = 0; v < pf->num_alloc_vfs; v++)
 			i40e_reset_vf(&pf->vf[v], true);
@@ -7116,9 +7120,12 @@ static void i40e_rebuild(struct i40e_pf *pf, bool reinit, bool lock_acquired)
 	/* tell the firmware that we're starting */
 	i40e_send_version(pf);
 
+	/* We've already released the lock, so don't do it again */
+	goto end_core_reset;
+
 end_unlock:
-if (!lock_acquired)
-	rtnl_unlock();
+	if (!lock_acquired)
+		rtnl_unlock();
 end_core_reset:
 	clear_bit(__I40E_RESET_FAILED, &pf->state);
 clear_recovery:
-- 
2.12.2
