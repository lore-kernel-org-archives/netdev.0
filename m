From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/16] i40e: Clean up MSIX IRQs before suspend
Date: Tue, 28 Jun 2016 21:40:52 -0700
Message-ID: <1467175262-54719-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1467175262-54719-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:16687 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751137AbcF2EnR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jun 2016 00:43:17 -0400
In-Reply-To: <1467175262-54719-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

The i40e_suspend() function calls another function that preps the device
for the power save and resume by freeing all the Tx/Rx resources and
interrupts but that function does not free the "other" causes interrupt
vector and IRQ. It also fails to call synchronize_irq() before freeing
the IRQ vectors.  This sometimes may result in some AER errors on those
systems with that PCIe error reporting feature enabled.

Call synchronize_irq() before freeing IRQ vectors and explicitly free
the other causes interrupt resources and shut down that MSIX interrupt.

Change-ID: Ib88e4536756518a352446da0232189716618ad81
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index a2b4012..e071c22 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -3950,6 +3950,7 @@ static void i40e_vsi_free_irq(struct i40e_vsi *vsi)
 			/* clear the affinity_mask in the IRQ descriptor */
 			irq_set_affinity_hint(pf->msix_entries[vector].vector,
 					      NULL);
+			synchronize_irq(pf->msix_entries[vector].vector);
 			free_irq(pf->msix_entries[vector].vector,
 				 vsi->q_vectors[i]);
 
@@ -11451,6 +11452,8 @@ static int i40e_suspend(struct pci_dev *pdev, pm_message_t state)
 	wr32(hw, I40E_PFPM_APM, (pf->wol_en ? I40E_PFPM_APM_APME_MASK : 0));
 	wr32(hw, I40E_PFPM_WUFC, (pf->wol_en ? I40E_PFPM_WUFC_MAG_MASK : 0));
 
+	i40e_stop_misc_vector(pf);
+
 	pci_wake_from_d3(pdev, pf->wol_en);
 	pci_set_power_state(pdev, PCI_D3hot);
 
-- 
2.5.5
