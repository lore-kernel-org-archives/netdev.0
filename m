From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 03/14] i40e: Move function calls to i40e_shutdown instead of i40e_suspend
Date: Wed, 26 Aug 2015 15:49:22 -0700
Message-ID: <1440629373-21287-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1440629373-21287-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:12760 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754778AbbHZWth (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Aug 2015 18:49:37 -0400
In-Reply-To: <1440629373-21287-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

We should be stopping the service task and flow director on
shutdown not on suspension.

Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index ded62eb..07bfe61 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -10450,6 +10450,19 @@ static void i40e_shutdown(struct pci_dev *pdev)
 	wr32(hw, I40E_PFPM_APM, (pf->wol_en ? I40E_PFPM_APM_APME_MASK : 0));
 	wr32(hw, I40E_PFPM_WUFC, (pf->wol_en ? I40E_PFPM_WUFC_MAG_MASK : 0));
 
+	del_timer_sync(&pf->service_timer);
+	cancel_work_sync(&pf->service_task);
+	i40e_fdir_teardown(pf);
+
+	rtnl_lock();
+	i40e_prep_for_reset(pf);
+	rtnl_unlock();
+
+	wr32(hw, I40E_PFPM_APM,
+	     (pf->wol_en ? I40E_PFPM_APM_APME_MASK : 0));
+	wr32(hw, I40E_PFPM_WUFC,
+	     (pf->wol_en ? I40E_PFPM_WUFC_MAG_MASK : 0));
+
 	i40e_clear_interrupt_scheme(pf);
 
 	if (system_state == SYSTEM_POWER_OFF) {
@@ -10470,9 +10483,6 @@ static int i40e_suspend(struct pci_dev *pdev, pm_message_t state)
 
 	set_bit(__I40E_SUSPENDED, &pf->state);
 	set_bit(__I40E_DOWN, &pf->state);
-	del_timer_sync(&pf->service_timer);
-	cancel_work_sync(&pf->service_task);
-	i40e_fdir_teardown(pf);
 
 	rtnl_lock();
 	i40e_prep_for_reset(pf);
-- 
2.4.3
