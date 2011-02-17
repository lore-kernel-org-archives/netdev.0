From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 3/4] ixgbe: fix panic due to uninitialised pointer
Date: Thu, 17 Feb 2011 01:35:09 -0800
Message-ID: <1297935310-23510-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1297935310-23510-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:59899 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754310Ab1BQJfR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Feb 2011 04:35:17 -0500
In-Reply-To: <1297935310-23510-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <andy@greyhouse.net>

Systems containing an 82599EB and running a backported driver from
upstream were panicing on boot.  It turns out hw->mac.ops.setup_sfp is
only set for 82599, so one should check to be sure that pointer is set
before continuing in ixgbe_sfp_config_module_task.  I verified by
inspection that the upstream driver has the same issue and also added a
check before the call in ixgbe_sfp_link_config.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_main.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index fbae703..30f9ccf 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3728,7 +3728,8 @@ static void ixgbe_sfp_link_config(struct ixgbe_adapter *adapter)
 			 * We need to try and force an autonegotiation
 			 * session, then bring up link.
 			 */
-			hw->mac.ops.setup_sfp(hw);
+			if (hw->mac.ops.setup_sfp)
+				hw->mac.ops.setup_sfp(hw);
 			if (!(adapter->flags & IXGBE_FLAG_IN_SFP_LINK_TASK))
 				schedule_work(&adapter->multispeed_fiber_task);
 		} else {
@@ -5968,7 +5969,8 @@ static void ixgbe_sfp_config_module_task(struct work_struct *work)
 		unregister_netdev(adapter->netdev);
 		return;
 	}
-	hw->mac.ops.setup_sfp(hw);
+	if (hw->mac.ops.setup_sfp)
+		hw->mac.ops.setup_sfp(hw);
 
 	if (!(adapter->flags & IXGBE_FLAG_IN_SFP_LINK_TASK))
 		/* This will also work for DA Twinax connections */
-- 
1.7.4

