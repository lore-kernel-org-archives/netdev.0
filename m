From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 10/13] i40e: disconnect irqs on shutdown
Date: Thu, 26 Feb 2015 07:03:46 -0800
Message-ID: <1424963029-4612-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1424963029-4612-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:48322 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753955AbbBZPD6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2015 10:03:58 -0500
In-Reply-To: <1424963029-4612-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Combine the ICR0 shutdown with the standard interrupt shutdown, and
add the interrupt clearing to the PCI shutdown path.

This prevents the driver from allowing stray interrupts or causing
system logs from un-handled interrupts.

Change-ID: I48f6ab95cad7f8ca77c1f26c92a51cc1034ced43
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 9751465..8bfd254 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -3842,6 +3842,12 @@ static void i40e_clear_interrupt_scheme(struct i40e_pf *pf)
 {
 	int i;
 
+	i40e_stop_misc_vector(pf);
+	if (pf->flags & I40E_FLAG_MSIX_ENABLED) {
+		synchronize_irq(pf->msix_entries[0].vector);
+		free_irq(pf->msix_entries[0].vector, pf);
+	}
+
 	i40e_put_lump(pf->irq_pile, 0, I40E_PILE_VALID_BIT-1);
 	for (i = 0; i < pf->num_alloc_vsi; i++)
 		if (pf->vsi[i])
@@ -9578,12 +9584,6 @@ static void i40e_remove(struct pci_dev *pdev)
 	if (pf->vsi[pf->lan_vsi])
 		i40e_vsi_release(pf->vsi[pf->lan_vsi]);
 
-	i40e_stop_misc_vector(pf);
-	if (pf->flags & I40E_FLAG_MSIX_ENABLED) {
-		synchronize_irq(pf->msix_entries[0].vector);
-		free_irq(pf->msix_entries[0].vector, pf);
-	}
-
 	/* shutdown and destroy the HMC */
 	if (pf->hw.hmc.hmc_obj) {
 		ret_code = i40e_shutdown_lan_hmc(&pf->hw);
@@ -9737,6 +9737,8 @@ static void i40e_shutdown(struct pci_dev *pdev)
 	wr32(hw, I40E_PFPM_APM, (pf->wol_en ? I40E_PFPM_APM_APME_MASK : 0));
 	wr32(hw, I40E_PFPM_WUFC, (pf->wol_en ? I40E_PFPM_WUFC_MAG_MASK : 0));
 
+	i40e_clear_interrupt_scheme(pf);
+
 	if (system_state == SYSTEM_POWER_OFF) {
 		pci_wake_from_d3(pdev, pf->wol_en);
 		pci_set_power_state(pdev, PCI_D3hot);
-- 
1.9.3
