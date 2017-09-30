From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/15] i40e: don't clear suspended state until we finish resuming
Date: Fri, 29 Sep 2017 17:45:02 -0700
Message-ID: <20170930004507.20072-11-jeffrey.t.kirsher@intel.com>
References: <20170930004507.20072-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:57175 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752652AbdI3Apu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 29 Sep 2017 20:45:50 -0400
In-Reply-To: <20170930004507.20072-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

When handling suspend and resume callbacks we want to make sure that (a)
we don't suspend again if we're already suspended and (b) we don't
resume again if we're already resuming. Lets make sure we test_and_set
the __I40E_SUSPENDED bit in i40e_suspend which ensures that a suspend
call when already suspended will exit early. Additionally, if
__I40E_SUSPENDED is not set when we begin resuming, exit early as well.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 19 +++++++++++++------
 1 file changed, 13 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index c82360437024..494cafde6b26 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -12059,7 +12059,10 @@ static int i40e_suspend(struct device *dev)
 	struct i40e_pf *pf = pci_get_drvdata(pdev);
 	struct i40e_hw *hw = &pf->hw;
 
-	set_bit(__I40E_SUSPENDED, pf->state);
+	/* If we're already suspended, then there is nothing to do */
+	if (test_and_set_bit(__I40E_SUSPENDED, pf->state))
+		return 0;
+
 	set_bit(__I40E_DOWN, pf->state);
 
 	if (pf->wol_en && (pf->hw_features & I40E_HW_WOL_MC_MAGIC_PKT_WAKE))
@@ -12084,11 +12087,15 @@ static int i40e_resume(struct device *dev)
 	struct pci_dev *pdev = to_pci_dev(dev);
 	struct i40e_pf *pf = pci_get_drvdata(pdev);
 
-	/* handling the reset will rebuild the device state */
-	if (test_and_clear_bit(__I40E_SUSPENDED, pf->state)) {
-		clear_bit(__I40E_DOWN, pf->state);
-		i40e_reset_and_rebuild(pf, false, false);
-	}
+	/* If we're not suspended, then there is nothing to do */
+	if (!test_bit(__I40E_SUSPENDED, pf->state))
+		return 0;
+
+	clear_bit(__I40E_DOWN, pf->state);
+	i40e_reset_and_rebuild(pf, false, false);
+
+	/* Clear suspended state last after everything is recovered */
+	clear_bit(__I40E_SUSPENDED, pf->state);
 
 	return 0;
 }
-- 
2.14.1
