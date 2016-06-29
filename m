From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/16] i40e: set default VSI without a reset
Date: Tue, 28 Jun 2016 21:40:58 -0700
Message-ID: <1467175262-54719-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1467175262-54719-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:22102 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751352AbcF2EnT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jun 2016 00:43:19 -0400
In-Reply-To: <1467175262-54719-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Remove the need for a reset when the device enters limited promiscuous
mode. This was causing heartburn for people who were using VFs and
bridging, since this would require all of the VFs to undergo a reset
each time the PF changed its promiscuity.

Change-ID: I0a83495c5e4d68112bbc7a7a076d20fa8dd3b61c
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 26 ++++++++++++++++++++++----
 1 file changed, 22 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index a32be7c..d6a5106 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -2110,7 +2110,25 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 			 */
 			if (pf->cur_promisc != cur_promisc) {
 				pf->cur_promisc = cur_promisc;
-				set_bit(__I40E_PF_RESET_REQUESTED, &pf->state);
+				if (cur_promisc)
+					aq_ret =
+					      i40e_aq_set_default_vsi(hw,
+								      vsi->seid,
+								      NULL);
+				else
+					aq_ret =
+					    i40e_aq_clear_default_vsi(hw,
+								      vsi->seid,
+								      NULL);
+				if (aq_ret) {
+					retval = i40e_aq_rc_to_posix(aq_ret,
+							hw->aq.asq_last_status);
+					dev_info(&pf->pdev->dev,
+						 "Set default VSI failed, err %s, aq_err %s\n",
+						 i40e_stat_str(hw, aq_ret),
+						 i40e_aq_str(hw,
+						     hw->aq.asq_last_status));
+				}
 			}
 		} else {
 			aq_ret = i40e_aq_set_vsi_unicast_promiscuous(
@@ -10047,14 +10065,14 @@ void i40e_veb_release(struct i40e_veb *veb)
 static int i40e_add_veb(struct i40e_veb *veb, struct i40e_vsi *vsi)
 {
 	struct i40e_pf *pf = veb->pf;
-	bool is_default = veb->pf->cur_promisc;
 	bool enable_stats = !!(pf->flags & I40E_FLAG_VEB_STATS_ENABLED);
 	int ret;
 
-	/* get a VEB from the hardware */
 	ret = i40e_aq_add_veb(&pf->hw, veb->uplink_seid, vsi->seid,
-			      veb->enabled_tc, is_default,
+			      veb->enabled_tc, false,
 			      &veb->seid, enable_stats, NULL);
+
+	/* get a VEB from the hardware */
 	if (ret) {
 		dev_info(&pf->pdev->dev,
 			 "couldn't add VEB, err %s aq_err %s\n",
-- 
2.5.5
