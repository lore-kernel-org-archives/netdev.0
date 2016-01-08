From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/8] ixgbe: do not call check_link for ethtool in ixgbe_get_settings()
Date: Fri,  8 Jan 2016 05:00:26 -0800
Message-ID: <1452258030-63996-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1452258030-63996-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:55493 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754698AbcAHNAd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jan 2016 08:00:33 -0500
In-Reply-To: <1452258030-63996-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

In ixgbe_get_settings() the link status and speed of the interface
are determined based on a read from the LINKS register via the call
to mac.ops.check.link(). This can cause issues where external drivers
may end up with unknown speed when calling ethtool_get_settings().

Instead of calling the mac.ops.check_link() we can report the speed
from the adapter structure which is populated by the driver.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 2448eba..bea96b3 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -185,9 +185,7 @@ static int ixgbe_get_settings(struct net_device *netdev,
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
 	ixgbe_link_speed supported_link;
-	u32 link_speed = 0;
 	bool autoneg = false;
-	bool link_up;
 
 	hw->mac.ops.get_link_capabilities(hw, &supported_link, &autoneg);
 
@@ -313,9 +311,8 @@ static int ixgbe_get_settings(struct net_device *netdev,
 		break;
 	}
 
-	hw->mac.ops.check_link(hw, &link_speed, &link_up, false);
-	if (link_up) {
-		switch (link_speed) {
+	if (netif_carrier_ok(netdev)) {
+		switch (adapter->link_speed) {
 		case IXGBE_LINK_SPEED_10GB_FULL:
 			ethtool_cmd_speed_set(ecmd, SPEED_10000);
 			break;
-- 
2.5.0
