From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/10] ixgbe: get pauseparam autoneg
Date: Wed,  5 Oct 2011 03:20:23 -0700
Message-ID: <1317810024-20846-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1317810024-20846-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mika Lansirinne <mika.lansirinne@stonesoft.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:36493 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934298Ab1JEKUe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Oct 2011 06:20:34 -0400
In-Reply-To: <1317810024-20846-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mika Lansirinne <mika.lansirinne@stonesoft.com>

There is a problem in the ixgbe driver with the reporting of the flow
control parameters. The autoneg parameter is shown to be of if
*either* it really is off, or current modes for both tx and rx are off.

The problem is seen when the parameters are read or set when the link
is down. In this case, the driver sees that tx and rx are currently off
and therefore autoneg parameter is incorrectly reported to be off too.
Also, the ethtool binary can not set the autoneg off since it sees that
it already is. When a link later comes up, the autonegotiation is
carried out normally and the driver later on reports the autoneg
parameter to be on (as it is) and then it can also be changed with
ethtool.

The patch is made against v3.0 kernel, but the problem seems to be there
since v2.6.30-rc1.

Reviewer comments: What we are trying to do is to disable flow control
while the cable is disconnected. Since ixgbe defaults to full flow
control, we call ethtool -A autoneg off rx off tx off while the cable
is disconnected. This doesn't work, because the driver sets
hw->fc.current_mode = ixgbe_fc_none if the cable is unplugged.
ixgbe_get_pauseparam() then reports to ethtool that nothing needs to be
done. The code fixes this, but it might have some unknown consequences.

Signed-off-by: Mika Lansirinne <mika.lansirinne@stonesoft.com>
Reviewed-by: Esa-Pekka Pyokkimies <esa-pekka.pyokkimies@stonesoft.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |    8 +-------
 1 files changed, 1 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index db255fc..10ea29f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -372,13 +372,7 @@ static void ixgbe_get_pauseparam(struct net_device *netdev,
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
 
-	/*
-	 * Flow Control Autoneg isn't on if
-	 *  - we didn't ask for it OR
-	 *  - it failed, we know this by tx & rx being off
-	 */
-	if (hw->fc.disable_fc_autoneg ||
-	    (hw->fc.current_mode == ixgbe_fc_none))
+	if (hw->fc.disable_fc_autoneg)
 		pause->autoneg = 0;
 	else
 		pause->autoneg = 1;
-- 
1.7.6.4
