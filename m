From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/15] i40e: don't hold RTNL lock for the entire reset
Date: Tue, 20 Jun 2017 18:18:02 -0700
Message-ID: <20170621011802.81768-16-jeffrey.t.kirsher@intel.com>
References: <20170621011802.81768-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:40195 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753118AbdFUBSX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Jun 2017 21:18:23 -0400
In-Reply-To: <20170621011802.81768-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

We recently refactored i40e_do_reset() and its friends to be able to
hold the RTNL lock only for the portions that actually need to be
protected. However, a separate refactoring added several new callers of
these functions during the PCIe error recovery and suspend/resume
cycles.

When merging the changes together, it was not noticed that we could
reduce the RTNL scope by letting the reset function handle the lock
itself, as previously it was not possible.

Fix this by replacing these call sites to indicate that the reset
function should handle its own lock. This enables multiple PFs to reset
or resume simultaneously without serializing the resets via the RTNL
lock. The end result is that on systems with lots of PFs and VFs the
resets don't stall waiting for each other to finish.

It is probable that we can also do the same for i40e_do_reset_safe, but
this author did not research that change carefully enough to be
confident.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 27 +++++++--------------------
 1 file changed, 7 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index c4328b4bec95..2db93d3f6d23 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6566,9 +6566,7 @@ static void i40e_reset_subtask(struct i40e_pf *pf)
 	if (reset_flags &&
 	    !test_bit(__I40E_DOWN, pf->state) &&
 	    !test_bit(__I40E_CONFIG_BUSY, pf->state)) {
-		rtnl_lock();
-		i40e_do_reset(pf, reset_flags, true);
-		rtnl_unlock();
+		i40e_do_reset(pf, reset_flags, false);
 	}
 }
 
@@ -11906,11 +11904,8 @@ static pci_ers_result_t i40e_pci_error_detected(struct pci_dev *pdev,
 	}
 
 	/* shutdown all operations */
-	if (!test_bit(__I40E_SUSPENDED, pf->state)) {
-		rtnl_lock();
-		i40e_prep_for_reset(pf, true);
-		rtnl_unlock();
-	}
+	if (!test_bit(__I40E_SUSPENDED, pf->state))
+		i40e_prep_for_reset(pf, false);
 
 	/* Request a slot reset */
 	return PCI_ERS_RESULT_NEED_RESET;
@@ -11976,9 +11971,7 @@ static void i40e_pci_error_resume(struct pci_dev *pdev)
 	if (test_bit(__I40E_SUSPENDED, pf->state))
 		return;
 
-	rtnl_lock();
-	i40e_handle_reset_warning(pf, true);
-	rtnl_unlock();
+	i40e_handle_reset_warning(pf, false);
 }
 
 /**
@@ -12058,9 +12051,7 @@ static void i40e_shutdown(struct pci_dev *pdev)
 	if (pf->wol_en && (pf->flags & I40E_FLAG_WOL_MC_MAGIC_PKT_WAKE))
 		i40e_enable_mc_magic_wake(pf);
 
-	rtnl_lock();
-	i40e_prep_for_reset(pf, true);
-	rtnl_unlock();
+	i40e_prep_for_reset(pf, false);
 
 	wr32(hw, I40E_PFPM_APM,
 	     (pf->wol_en ? I40E_PFPM_APM_APME_MASK : 0));
@@ -12092,9 +12083,7 @@ static int i40e_suspend(struct pci_dev *pdev, pm_message_t state)
 	if (pf->wol_en && (pf->flags & I40E_FLAG_WOL_MC_MAGIC_PKT_WAKE))
 		i40e_enable_mc_magic_wake(pf);
 
-	rtnl_lock();
-	i40e_prep_for_reset(pf, true);
-	rtnl_unlock();
+	i40e_prep_for_reset(pf, false);
 
 	wr32(hw, I40E_PFPM_APM, (pf->wol_en ? I40E_PFPM_APM_APME_MASK : 0));
 	wr32(hw, I40E_PFPM_WUFC, (pf->wol_en ? I40E_PFPM_WUFC_MAG_MASK : 0));
@@ -12140,9 +12129,7 @@ static int i40e_resume(struct pci_dev *pdev)
 	/* handling the reset will rebuild the device state */
 	if (test_and_clear_bit(__I40E_SUSPENDED, pf->state)) {
 		clear_bit(__I40E_DOWN, pf->state);
-		rtnl_lock();
-		i40e_reset_and_rebuild(pf, false, true);
-		rtnl_unlock();
+		i40e_reset_and_rebuild(pf, false, false);
 	}
 
 	return 0;
-- 
2.12.2
