From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/17] i40e: Fix for long link down notification time
Date: Sat, 29 Oct 2016 00:30:54 -0700
Message-ID: <1477726258-111563-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1477726258-111563-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:50625 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751609AbcJ2HbH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 29 Oct 2016 03:31:07 -0400
In-Reply-To: <1477726258-111563-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch fixes a problem where it could take a very
long time (>100 msec) to print the link down notification.
This problem is fixed by changing how often we update link
info from fw, when link is down. Without this patch, it can
take over 100msec to notify user link is down.

Change-ID: Ib876eb30834c7080792becd13ee093b9cbb35d78
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index fe8100b..a475946 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -2494,7 +2494,10 @@ i40e_status i40e_update_link_info(struct i40e_hw *hw)
 	if (status)
 		return status;
 
-	if (hw->phy.link_info.link_info & I40E_AQ_MEDIA_AVAILABLE) {
+	/* extra checking needed to ensure link info to user is timely */
+	if ((hw->phy.link_info.link_info & I40E_AQ_MEDIA_AVAILABLE) &&
+	    ((hw->phy.link_info.link_info & I40E_AQ_LINK_UP) ||
+	     !(hw->phy.link_info_old.link_info & I40E_AQ_LINK_UP))) {
 		status = i40e_aq_get_phy_capabilities(hw, false, false,
 						      &abilities, NULL);
 		if (status)
-- 
2.7.4
