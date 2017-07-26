From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/14] i40e: Fix for trace found with S4 state
Date: Wed, 26 Jul 2017 03:31:11 -0700
Message-ID: <20170726103123.76743-3-jeffrey.t.kirsher@intel.com>
References: <20170726103123.76743-1-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:19638 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751723AbdGZKc2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Jul 2017 06:32:28 -0400
In-Reply-To: <20170726103123.76743-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch fixes a problem found in systems when entering
S4 state.  This patch fixes the problem by ensuring that
the misc vector's IRQ is disabled as well.  Without this
patch a stack trace can be seen upon entering S4 state.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 2db93d3f6d23..933b8e357ee4 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -12089,7 +12089,10 @@ static int i40e_suspend(struct pci_dev *pdev, pm_message_t state)
 	wr32(hw, I40E_PFPM_WUFC, (pf->wol_en ? I40E_PFPM_WUFC_MAG_MASK : 0));
 
 	i40e_stop_misc_vector(pf);
-
+	if (pf->msix_entries) {
+		synchronize_irq(pf->msix_entries[0].vector);
+		free_irq(pf->msix_entries[0].vector, pf);
+	}
 	retval = pci_save_state(pdev);
 	if (retval)
 		return retval;
@@ -12129,6 +12132,15 @@ static int i40e_resume(struct pci_dev *pdev)
 	/* handling the reset will rebuild the device state */
 	if (test_and_clear_bit(__I40E_SUSPENDED, pf->state)) {
 		clear_bit(__I40E_DOWN, pf->state);
+		if (pf->msix_entries) {
+			err = request_irq(pf->msix_entries[0].vector,
+					  i40e_intr, 0, pf->int_name, pf);
+			if (err) {
+				dev_err(&pf->pdev->dev,
+					"request_irq for %s failed: %d\n",
+					pf->int_name, err);
+			}
+		}
 		i40e_reset_and_rebuild(pf, false, false);
 	}
 
-- 
2.13.3
