From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net] igbvf: fix divide by zero
Date: Sat, 30 Jun 2012 03:23:19 -0700
Message-ID: <1341051799-8824-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch A Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	stable@vger.kernel.org, daahern@cisco.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:7259 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752847Ab2F3KXV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Jun 2012 06:23:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch A Williams <mitch.a.williams@intel.com>

Using ethtool -C ethX rx-usecs 0 crashes with a divide by zero.
Refactor this function to fix this issue and make it more clear
what the intent of each conditional is. Add comment regarding
using a setting of zero.

CC: stable <stable@vger.kernel.org> [3.3+]
CC: David Ahern <daahern@cisco.com>
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igbvf/ethtool.c |   29 +++++++++++++++++-----------
 1 file changed, 18 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/igbvf/ethtool.c b/drivers/net/ethernet/intel/igbvf/ethtool.c
index 8ce6706..90eef07 100644
--- a/drivers/net/ethernet/intel/igbvf/ethtool.c
+++ b/drivers/net/ethernet/intel/igbvf/ethtool.c
@@ -357,21 +357,28 @@ static int igbvf_set_coalesce(struct net_device *netdev,
 	struct igbvf_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 
-	if ((ec->rx_coalesce_usecs > IGBVF_MAX_ITR_USECS) ||
-	    ((ec->rx_coalesce_usecs > 3) &&
-	     (ec->rx_coalesce_usecs < IGBVF_MIN_ITR_USECS)) ||
-	    (ec->rx_coalesce_usecs == 2))
-		return -EINVAL;
-
-	/* convert to rate of irq's per second */
-	if (ec->rx_coalesce_usecs && ec->rx_coalesce_usecs <= 3) {
+	if ((ec->rx_coalesce_usecs >= IGBVF_MIN_ITR_USECS) &&
+	     (ec->rx_coalesce_usecs <= IGBVF_MAX_ITR_USECS)) {
+		adapter->current_itr = ec->rx_coalesce_usecs << 2;
+		adapter->requested_itr = 1000000000 /
+					(adapter->current_itr * 256);
+	} else if ((ec->rx_coalesce_usecs == 3) ||
+		   (ec->rx_coalesce_usecs == 2)) {
 		adapter->current_itr = IGBVF_START_ITR;
 		adapter->requested_itr = ec->rx_coalesce_usecs;
-	} else {
-		adapter->current_itr = ec->rx_coalesce_usecs << 2;
+	} else if (ec->rx_coalesce_usecs == 0) {
+		/*
+		 * The user's desire is to turn off interrupt throttling
+		 * altogether, but due to HW limitations, we can't do that.
+		 * Instead we set a very small value in EITR, which would
+		 * allow ~967k interrupts per second, but allow the adapter's
+		 * internal clocking to still function properly.
+		 */
+		adapter->current_itr = 4;
 		adapter->requested_itr = 1000000000 /
 					(adapter->current_itr * 256);
-	}
+	} else
+		return -EINVAL;
 
 	writel(adapter->current_itr,
 	       hw->hw_addr + adapter->rx_ring->itr_register);
-- 
1.7.10.4
