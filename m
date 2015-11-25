From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 08/15] i40e: Move the saving of old link info from handle_link_event to link_event
Date: Wed, 25 Nov 2015 10:21:12 -0800
Message-ID: <1448475679-57194-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1448475679-57194-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:23563 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751917AbbKYSV0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Nov 2015 13:21:26 -0500
In-Reply-To: <1448475679-57194-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

The watchdog only calls link_event not handle_link_event which means
that we need to save the old information in link_event.

Previously when polling we were comparing current data to the old data
saved the last time we actually received a link event. This means that
the polling would only fix link status changes in one direction
depending on what the last old data saved off was.

Change-ID: Ie590f30fdbcb133d0ddad4e07e3eb1aad58255b3
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 0e6abc2..9c0a381 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6016,6 +6016,9 @@ static void i40e_link_event(struct i40e_pf *pf)
 	i40e_status status;
 	bool new_link, old_link;
 
+	/* save off old link status information */
+	pf->hw.phy.link_info_old = pf->hw.phy.link_info;
+
 	/* set this to force the get_link_status call to refresh state */
 	pf->hw.phy.get_link_info = true;
 
@@ -6150,13 +6153,9 @@ unlock:
 static void i40e_handle_link_event(struct i40e_pf *pf,
 				   struct i40e_arq_event_info *e)
 {
-	struct i40e_hw *hw = &pf->hw;
 	struct i40e_aqc_get_link_status *status =
 		(struct i40e_aqc_get_link_status *)&e->desc.params.raw;
 
-	/* save off old link status information */
-	hw->phy.link_info_old = hw->phy.link_info;
-
 	/* Do a new status request to re-enable LSE reporting
 	 * and load new status information into the hw struct
 	 * This completely ignores any state information
-- 
2.5.0
