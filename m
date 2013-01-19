From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/10] ixgbevf: Fix statistics corruption
Date: Sat, 19 Jan 2013 05:14:57 -0800
Message-ID: <1358601299-10404-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1358601299-10404-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:40832 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751499Ab3ASNPJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Jan 2013 08:15:09 -0500
In-Reply-To: <1358601299-10404-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

When the physical function (PF) is reset for any reason the statistics
collection in ixgbevf_update_stats needs to wait to update until after
the reset synchronization ensures that the PF driver is up and running
and is finished with its own reset.  Go ahead and clear the link flag to
indicate this when the control message from the PF is received.  The
reset synchronization and recovery in the watchdog task will eventually
set the link flag up when the PF has resumed.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 3fbf0d2..551e31d 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -762,9 +762,11 @@ static irqreturn_t ixgbevf_msix_other(int irq, void *data)
 	if (!hw->mbx.ops.check_for_msg(hw)) {
 		hw->mbx.ops.read(hw, &msg, 1);
 
-		if ((msg & IXGBE_MBVFICR_VFREQ_MASK) == IXGBE_PF_CONTROL_MSG)
+		if ((msg & IXGBE_MBVFICR_VFREQ_MASK) == IXGBE_PF_CONTROL_MSG) {
 			mod_timer(&adapter->watchdog_timer,
 				  round_jiffies(jiffies + 1));
+			adapter->link_up = false;
+		}
 
 		if (msg & IXGBE_VT_MSGTYPE_NACK)
 			dev_info(&pdev->dev,
@@ -2118,6 +2120,9 @@ void ixgbevf_update_stats(struct ixgbevf_adapter *adapter)
 	struct ixgbe_hw *hw = &adapter->hw;
 	int i;
 
+	if (!adapter->link_up)
+		return;
+
 	UPDATE_VF_COUNTER_32bit(IXGBE_VFGPRC, adapter->stats.last_vfgprc,
 				adapter->stats.vfgprc);
 	UPDATE_VF_COUNTER_32bit(IXGBE_VFGPTC, adapter->stats.last_vfgptc,
-- 
1.7.11.7
