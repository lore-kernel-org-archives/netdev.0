From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/11] i40e: fix link checking logic
Date: Mon,  3 Nov 2014 06:56:31 -0800
Message-ID: <1415026599-16232-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1415026599-16232-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Patrick Lu <patrick.lu@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:44881 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752662AbaKCO4y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2014 09:56:54 -0500
In-Reply-To: <1415026599-16232-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

If the interface is closed, but VFs exist, current code will spam all
the VFs with link messages every second. This is because the link event
code was looking at netif_carrier_ok() without checking to see if the
interface was actually open.

Refactor the logic to only check the carrier state if the interface is
actually open. This allows link changes to be reported correctly without
spamming the VFs.

Change-ID: If136e79bb3820d21ea4e39e332e8a9604efc2b2a
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Patrick Lu <patrick.lu@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 0eccd82..f95c04a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5358,6 +5358,7 @@ static void i40e_veb_link_event(struct i40e_veb *veb, bool link_up)
 static void i40e_link_event(struct i40e_pf *pf)
 {
 	bool new_link, old_link;
+	struct i40e_vsi *vsi = pf->vsi[pf->lan_vsi];
 
 	/* set this to force the get_link_status call to refresh state */
 	pf->hw.phy.get_link_info = true;
@@ -5366,10 +5367,12 @@ static void i40e_link_event(struct i40e_pf *pf)
 	new_link = i40e_get_link_status(&pf->hw);
 
 	if (new_link == old_link &&
-	    new_link == netif_carrier_ok(pf->vsi[pf->lan_vsi]->netdev))
+	    (test_bit(__I40E_DOWN, &vsi->state) ||
+	     new_link == netif_carrier_ok(vsi->netdev)))
 		return;
-	if (!test_bit(__I40E_DOWN, &pf->vsi[pf->lan_vsi]->state))
-		i40e_print_link_message(pf->vsi[pf->lan_vsi], new_link);
+
+	if (!test_bit(__I40E_DOWN, &vsi->state))
+		i40e_print_link_message(vsi, new_link);
 
 	/* Notify the base of the switch tree connected to
 	 * the link.  Floating VEBs are not notified.
@@ -5377,7 +5380,7 @@ static void i40e_link_event(struct i40e_pf *pf)
 	if (pf->lan_veb != I40E_NO_VEB && pf->veb[pf->lan_veb])
 		i40e_veb_link_event(pf->veb[pf->lan_veb], new_link);
 	else
-		i40e_vsi_link_event(pf->vsi[pf->lan_vsi], new_link);
+		i40e_vsi_link_event(vsi, new_link);
 
 	if (pf->vf)
 		i40e_vc_notify_link_state(pf);
-- 
1.9.3
