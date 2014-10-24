From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/9] i40e: enable LSE poke and simplify link state
Date: Thu, 23 Oct 2014 21:09:59 -0700
Message-ID: <1414123806-20049-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1414123806-20049-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:39968 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751488AbaJXEKQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Oct 2014 00:10:16 -0400
In-Reply-To: <1414123806-20049-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The driver can do a simpler job of managing link state by simply
using the admin queue receive event for link events as a doorbell
that tells the driver to update link state.

Additionally, add a workaround will help make sure the link state in the
hardware is consistent with the link state the driver is reporting
by refreshing the link state every service task interval.

Change-ID: Ib95b5b7b8cc016e97d8009f6363c9f9eed301444
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 39 ++++++++++++-----------------
 1 file changed, 16 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 8cb6469..d40fc3b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5354,10 +5354,14 @@ static void i40e_link_event(struct i40e_pf *pf)
 {
 	bool new_link, old_link;
 
-	new_link = (pf->hw.phy.link_info.link_info & I40E_AQ_LINK_UP);
+	/* set this to force the get_link_status call to refresh state */
+	pf->hw.phy.get_link_info = true;
+
 	old_link = (pf->hw.phy.link_info_old.link_info & I40E_AQ_LINK_UP);
+	new_link = i40e_get_link_status(&pf->hw);
 
-	if (new_link == old_link)
+	if (new_link == old_link &&
+	    new_link == netif_carrier_ok(pf->vsi[pf->lan_vsi]->netdev))
 		return;
 	if (!test_bit(__I40E_DOWN, &pf->vsi[pf->lan_vsi]->state))
 		i40e_print_link_message(pf->vsi[pf->lan_vsi], new_link);
@@ -5525,33 +5529,20 @@ static void i40e_handle_link_event(struct i40e_pf *pf,
 	memcpy(&pf->hw.phy.link_info_old, hw_link_info,
 	       sizeof(pf->hw.phy.link_info_old));
 
+	/* Do a new status request to re-enable LSE reporting
+	 * and load new status information into the hw struct
+	 * This completely ignores any state information
+	 * in the ARQ event info, instead choosing to always
+	 * issue the AQ update link status command.
+	 */
+	i40e_link_event(pf);
+
 	/* check for unqualified module, if link is down */
 	if ((status->link_info & I40E_AQ_MEDIA_AVAILABLE) &&
 	    (!(status->an_info & I40E_AQ_QUALIFIED_MODULE)) &&
 	    (!(status->link_info & I40E_AQ_LINK_UP)))
 		dev_err(&pf->pdev->dev,
 			"The driver failed to link because an unqualified module was detected.\n");
-
-	/* update link status */
-	hw_link_info->phy_type = (enum i40e_aq_phy_type)status->phy_type;
-	hw_link_info->link_speed = (enum i40e_aq_link_speed)status->link_speed;
-	hw_link_info->link_info = status->link_info;
-	hw_link_info->an_info = status->an_info;
-	hw_link_info->ext_info = status->ext_info;
-	hw_link_info->lse_enable =
-		le16_to_cpu(status->command_flags) &
-			    I40E_AQ_LSE_ENABLE;
-
-	/* process the event */
-	i40e_link_event(pf);
-
-	/* Do a new status request to re-enable LSE reporting
-	 * and load new status information into the hw struct,
-	 * then see if the status changed while processing the
-	 * initial event.
-	 */
-	i40e_update_link_info(&pf->hw, true);
-	i40e_link_event(pf);
 }
 
 /**
@@ -6314,6 +6305,8 @@ static void i40e_service_task(struct work_struct *work)
 #endif
 	i40e_clean_adminq_subtask(pf);
 
+	i40e_link_event(pf);
+
 	i40e_service_event_complete(pf);
 
 	/* If the tasks have taken longer than one timer cycle or there
-- 
1.9.3
