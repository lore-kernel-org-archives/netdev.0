From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/18] i40e: Assure that adminq is alive in debug mode
Date: Tue,  5 Apr 2016 13:17:28 -0700
Message-ID: <1459887455-146634-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459887455-146634-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:28348 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759979AbcDEURl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 16:17:41 -0400
In-Reply-To: <1459887455-146634-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

When dropping into debug mode in a failed probe, make sure that
the AdminQ is left alive for possible hand debug of driver and
firmware states.

Move the mutex_init calls earlier in probe so that if init fails,
the admin queue interface is still available for debugging purposes.

Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 2464dca..56d4416 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -10822,6 +10822,12 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	hw->bus.func = PCI_FUNC(pdev->devfn);
 	pf->instance = pfs_found;
 
+	/* set up the locks for the AQ, do this only once in probe
+	 * and destroy them only once in remove
+	 */
+	mutex_init(&hw->aq.asq_mutex);
+	mutex_init(&hw->aq.arq_mutex);
+
 	if (debug != -1) {
 		pf->msg_enable = pf->hw.debug_mask;
 		pf->msg_enable = debug;
@@ -10867,12 +10873,6 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	/* set up a default setting for link flow control */
 	pf->hw.fc.requested_mode = I40E_FC_NONE;
 
-	/* set up the locks for the AQ, do this only once in probe
-	 * and destroy them only once in remove
-	 */
-	mutex_init(&hw->aq.asq_mutex);
-	mutex_init(&hw->aq.arq_mutex);
-
 	err = i40e_init_adminq(hw);
 	if (err) {
 		if (err == I40E_ERR_FIRMWARE_API_VERSION)
@@ -11265,7 +11265,6 @@ err_init_lan_hmc:
 	kfree(pf->qp_pile);
 err_sw_init:
 err_adminq_setup:
-	(void)i40e_shutdown_adminq(hw);
 err_pf_reset:
 	iounmap(hw->hw_addr);
 err_ioremap:
-- 
2.5.5
