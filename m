From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/14] i40e: make prep_for_reset void
Date: Mon, 23 Jun 2014 17:47:26 -0700
Message-ID: <1403570858-13548-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1403570858-13548-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:58389 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754085AbaFXArm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jun 2014 20:47:42 -0400
In-Reply-To: <1403570858-13548-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

The return from i40e_prep_for_reset() was being ignored by almost all
its callers.  The one place it wasn't ignored could have caused a silent
and confusing failure of the driver to finish a reset.  Since we really
are doing a rebuild anyway, ignore this last case as well and simply
make the function a void type.

Change-ID: Ia4fed7f903d39a6c47c5722625a53e59c3f7ed53
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 17 ++++++-----------
 1 file changed, 6 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index b167fc2..0a68065 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5611,7 +5611,7 @@ static void i40e_fdir_teardown(struct i40e_pf *pf)
  *
  * Close up the VFs and other things in prep for pf Reset.
   **/
-static int i40e_prep_for_reset(struct i40e_pf *pf)
+static void i40e_prep_for_reset(struct i40e_pf *pf)
 {
 	struct i40e_hw *hw = &pf->hw;
 	i40e_status ret = 0;
@@ -5619,7 +5619,7 @@ static int i40e_prep_for_reset(struct i40e_pf *pf)
 
 	clear_bit(__I40E_RESET_INTR_RECEIVED, &pf->state);
 	if (test_and_set_bit(__I40E_RESET_RECOVERY_PENDING, &pf->state))
-		return 0;
+		return;
 
 	dev_dbg(&pf->pdev->dev, "Tearing down internal switch for reset\n");
 
@@ -5636,13 +5636,11 @@ static int i40e_prep_for_reset(struct i40e_pf *pf)
 	/* call shutdown HMC */
 	if (hw->hmc.hmc_obj) {
 		ret = i40e_shutdown_lan_hmc(hw);
-		if (ret) {
+		if (ret)
 			dev_warn(&pf->pdev->dev,
 				 "shutdown_lan_hmc failed: %d\n", ret);
-			clear_bit(__I40E_RESET_RECOVERY_PENDING, &pf->state);
-		}
 	}
-	return ret;
+	return;
 }
 
 /**
@@ -5816,11 +5814,8 @@ end_core_reset:
  **/
 static void i40e_handle_reset_warning(struct i40e_pf *pf)
 {
-	i40e_status ret;
-
-	ret = i40e_prep_for_reset(pf);
-	if (!ret)
-		i40e_reset_and_rebuild(pf, false);
+	i40e_prep_for_reset(pf);
+	i40e_reset_and_rebuild(pf, false);
 }
 
 /**
-- 
1.9.3
