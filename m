From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH net-2.6] ixgbe: fix panic due to uninitialied pointer
Date: Fri, 11 Feb 2011 16:45:47 -0500
Message-ID: <1297460747-31896-1-git-send-email-andy@greyhouse.net>
Cc: Don Skidmore <donald.c.skidmore@intel.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60694 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758085Ab1BKVqF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Feb 2011 16:46:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Systems containing an 82599EB and running a backported driver from
upstream were panicing on boot.  It turns out hw->mac.ops.setup_sfp is
only set for 82599, so one should check to be sure that pointer is set
before continuing in ixgbe_sfp_config_module_task.  I verified by
inspection that the upstream driver has the same issue and also added a
check before the call in ixgbe_sfp_link_config.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
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

