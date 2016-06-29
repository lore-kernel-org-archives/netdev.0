From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/16] i40e: Save PCI state before suspend
Date: Tue, 28 Jun 2016 21:40:53 -0700
Message-ID: <1467175262-54719-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1467175262-54719-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:22102 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751171AbcF2EnS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jun 2016 00:43:18 -0400
In-Reply-To: <1467175262-54719-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

The i40e_suspend() function was failing to save PCI state
and this would result in a kernel stack trace from a WARN_ONCE in the
pci_legacy_suspend() function.

Add a call to pci_save_state() to fix that problem.

Change-ID: I4736e62bb660966bd208cc8af617a14cb07fc4bd
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index e071c22..52d9d28 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -11441,6 +11441,7 @@ static int i40e_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct i40e_pf *pf = pci_get_drvdata(pdev);
 	struct i40e_hw *hw = &pf->hw;
+	int retval = 0;
 
 	set_bit(__I40E_SUSPENDED, &pf->state);
 	set_bit(__I40E_DOWN, &pf->state);
@@ -11454,10 +11455,14 @@ static int i40e_suspend(struct pci_dev *pdev, pm_message_t state)
 
 	i40e_stop_misc_vector(pf);
 
+	retval = pci_save_state(pdev);
+	if (retval)
+		return retval;
+
 	pci_wake_from_d3(pdev, pf->wol_en);
 	pci_set_power_state(pdev, PCI_D3hot);
 
-	return 0;
+	return retval;
 }
 
 /**
-- 
2.5.5
