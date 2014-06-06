From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/13] i40e: don't remove HMC that doesn't exist
Date: Fri,  6 Jun 2014 02:04:20 -0700
Message-ID: <1402045462-10304-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1402045462-10304-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:5078 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751870AbaFFJFa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jun 2014 05:05:30 -0400
In-Reply-To: <1402045462-10304-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

If a reset recovery failed (e.g. firmware is broken), the HMC space won't
get set up.  We don't need to try to delete it if it didn't get set up.
This stops some needless error messages when we already know we need to
just tear things down.

Change-ID: Iac600481765e20b136052b43a544e55d7870268b
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 24 +++++++++++++++---------
 1 file changed, 15 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 484ada97..52bd69d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5429,7 +5429,7 @@ static void i40e_fdir_teardown(struct i40e_pf *pf)
 static int i40e_prep_for_reset(struct i40e_pf *pf)
 {
 	struct i40e_hw *hw = &pf->hw;
-	i40e_status ret;
+	i40e_status ret = 0;
 	u32 v;
 
 	clear_bit(__I40E_RESET_INTR_RECEIVED, &pf->state);
@@ -5449,10 +5449,13 @@ static int i40e_prep_for_reset(struct i40e_pf *pf)
 	i40e_shutdown_adminq(&pf->hw);
 
 	/* call shutdown HMC */
-	ret = i40e_shutdown_lan_hmc(hw);
-	if (ret) {
-		dev_info(&pf->pdev->dev, "shutdown_lan_hmc failed: %d\n", ret);
-		clear_bit(__I40E_RESET_RECOVERY_PENDING, &pf->state);
+	if (hw->hmc.hmc_obj) {
+		ret = i40e_shutdown_lan_hmc(hw);
+		if (ret) {
+			dev_warn(&pf->pdev->dev,
+				 "shutdown_lan_hmc failed: %d\n", ret);
+			clear_bit(__I40E_RESET_RECOVERY_PENDING, &pf->state);
+		}
 	}
 	return ret;
 }
@@ -8637,10 +8640,13 @@ static void i40e_remove(struct pci_dev *pdev)
 	}
 
 	/* shutdown and destroy the HMC */
-	ret_code = i40e_shutdown_lan_hmc(&pf->hw);
-	if (ret_code)
-		dev_warn(&pdev->dev,
-			 "Failed to destroy the HMC resources: %d\n", ret_code);
+	if (pf->hw.hmc.hmc_obj) {
+		ret_code = i40e_shutdown_lan_hmc(&pf->hw);
+		if (ret_code)
+			dev_warn(&pdev->dev,
+				 "Failed to destroy the HMC resources: %d\n",
+				 ret_code);
+	}
 
 	/* shutdown the adminq */
 	ret_code = i40e_shutdown_adminq(&pf->hw);
-- 
1.9.3
