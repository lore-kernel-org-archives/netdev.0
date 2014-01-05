From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/15] i40e: fix error handling when alloc of vsi array fails
Date: Sun,  5 Jan 2014 02:47:01 -0800
Message-ID: <1388918827-13430-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1388918827-13430-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:5196 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751207AbaAEKrP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Jan 2014 05:47:15 -0500
In-Reply-To: <1388918827-13430-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Swap a couple lines around in the error handling if the kzalloc() for
the pf->vsi array fails.  This was causing a kernel BUG because the
call to i40e_clear_interrupt_scheme() was assuming the pf->vsi[] array
existed.  In this fix it is possible that i40e_reset_interrupt_capability()
will get called twice, but this is a safe action.

Change-Id: I939163ccaa89baac7511556d36bc873864c35ae1
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 7194277..2785d7e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7775,9 +7775,10 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	/* Unwind what we've done if something failed in the setup */
 err_vsis:
 	set_bit(__I40E_DOWN, &pf->state);
-err_switch_setup:
 	i40e_clear_interrupt_scheme(pf);
 	kfree(pf->vsi);
+err_switch_setup:
+	i40e_reset_interrupt_capability(pf);
 	del_timer_sync(&pf->service_timer);
 err_mac_addr:
 err_configure_lan_hmc:
-- 
1.8.3.1
