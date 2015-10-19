From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 11/17] i40e: fix for PHY NVM interaction problem
Date: Mon, 19 Oct 2015 15:49:25 -0700
Message-ID: <1445294971-44714-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1445294971-44714-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:9921 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751273AbbJSWth (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Oct 2015 18:49:37 -0400
In-Reply-To: <1445294971-44714-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch fixes a problem where the NVMUpdate Tool, when using the PHY
NVM feature, gets bad data from the PHY because of contention on the
MDIO interface from get PHY capability calls from the driver during
regular operations.  The problem is fixed by adding a check if media
is available before calling get PHY capability function because that
bit is not set when device is in PHY interaction mode.

Change-ID: Ib89991b0f841808dd92410f5e8683d6ee3301cd0
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 7f456e9..c51f2fb 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -2278,13 +2278,15 @@ i40e_status i40e_update_link_info(struct i40e_hw *hw)
 	if (status)
 		return status;
 
-	status = i40e_aq_get_phy_capabilities(hw, false, false, &abilities,
-					      NULL);
-	if (status)
-		return status;
+	if (hw->phy.link_info.link_info & I40E_AQ_MEDIA_AVAILABLE) {
+		status = i40e_aq_get_phy_capabilities(hw, false, false,
+						      &abilities, NULL);
+		if (status)
+			return status;
 
-	memcpy(hw->phy.link_info.module_type, &abilities.module_type,
-	       sizeof(hw->phy.link_info.module_type));
+		memcpy(hw->phy.link_info.module_type, &abilities.module_type,
+		       sizeof(hw->phy.link_info.module_type));
+	}
 
 	return status;
 }
-- 
2.4.3
