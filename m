From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 10/15] i40e: don't handle VF reset on unload
Date: Thu, 13 Feb 2014 03:48:48 -0800
Message-ID: <1392292133-32120-11-git-send-email-aaron.f.brown@intel.com>
References: <1392292133-32120-1-git-send-email-aaron.f.brown@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:29634 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754362AbaBMLvN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Feb 2014 06:51:13 -0500
In-Reply-To: <1392292133-32120-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Set the DOWN flag before attempting to disable VFs when unloading the
driver. Also, don't attempt to reset the VFs when the driver is
unloading, because the switch configuration will fail. This fixes a
panic on unload when VFs are enabled.

Change-ID: I25a6567e89c9687145f510ff4f630932412c5c5d
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 10 +++++-----
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  3 ++-
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 897452d..628e917 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8181,16 +8181,16 @@ static void i40e_remove(struct pci_dev *pdev)
 
 	i40e_ptp_stop(pf);
 
-	if (pf->flags & I40E_FLAG_SRIOV_ENABLED) {
-		i40e_free_vfs(pf);
-		pf->flags &= ~I40E_FLAG_SRIOV_ENABLED;
-	}
-
 	/* no more scheduling of any task */
 	set_bit(__I40E_DOWN, &pf->state);
 	del_timer_sync(&pf->service_timer);
 	cancel_work_sync(&pf->service_task);
 
+	if (pf->flags & I40E_FLAG_SRIOV_ENABLED) {
+		i40e_free_vfs(pf);
+		pf->flags &= ~I40E_FLAG_SRIOV_ENABLED;
+	}
+
 	i40e_fdir_teardown(pf);
 
 	/* If there is a switch structure or any orphans, remove them.
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 9074f63..7d133fa 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1868,7 +1868,8 @@ int i40e_vc_process_vflr_event(struct i40e_pf *pf)
 			/* clear the bit in GLGEN_VFLRSTAT */
 			wr32(hw, I40E_GLGEN_VFLRSTAT(reg_idx), (1 << bit_idx));
 
-			i40e_reset_vf(vf, true);
+			if (!test_bit(__I40E_DOWN, &pf->state))
+				i40e_reset_vf(vf, true);
 		}
 	}
 
-- 
1.8.5.GIT
