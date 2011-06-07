From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 38/40] ixgbe: Update feature flags so that LRO and Ntuple are restricted
Date: Tue,  7 Jun 2011 05:33:13 -0700
Message-ID: <1307449995-9458-39-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1307449995-9458-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:46645 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753382Ab1FGMde (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jun 2011 08:33:34 -0400
In-Reply-To: <1307449995-9458-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change makes it so that LRO and Ntuple flags are correctly restricted
to only devices that support those features.  Currently we weren't
enforcing any of those restrictions and as such it was possible to do
things such as enable LRO without it actually being supported on the
hardware.

This change also makes a slight modification to the code that assumes the
ETH_FLAG_RXVLAN is the same as the netdev flag. I corrected it by just adding
a !! to cast the result of the flag & to a bool in order to guarantee the two
checks are compared as boolean values.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Evan Swanson <evan.swanson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_ethtool.c |   25 ++++++++++++++++---------
 1 files changed, 16 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 74a53ca..e4ff46d 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -2289,7 +2289,8 @@ static int ixgbe_set_coalesce(struct net_device *netdev,
 static int ixgbe_set_flags(struct net_device *netdev, u32 data)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	bool need_reset = false;
+	bool need_reset;
+	u32 supported_flags = ETH_FLAG_RXVLAN | ETH_FLAG_TXVLAN;
 	int rc;
 
 #ifdef CONFIG_IXGBE_DCB
@@ -2298,16 +2299,22 @@ static int ixgbe_set_flags(struct net_device *netdev, u32 data)
 		return -EINVAL;
 #endif
 
-	need_reset = (data & ETH_FLAG_RXVLAN) !=
-		     (netdev->features & NETIF_F_HW_VLAN_RX);
+	need_reset = !!(data & ETH_FLAG_RXVLAN) !=
+		     !!(netdev->features & NETIF_F_HW_VLAN_RX);
 
-	if ((data & ETH_FLAG_RXHASH) &&
-	    !(adapter->flags & IXGBE_FLAG_RSS_ENABLED))
-		return -EOPNOTSUPP;
+	switch (adapter->hw.mac.type) {
+	case ixgbe_mac_X540:
+	case ixgbe_mac_82599EB:
+		supported_flags |= ETH_FLAG_NTUPLE | ETH_FLAG_LRO;
+		break;
+	default:
+		break;
+	}
+
+	if (adapter->flags & IXGBE_FLAG_RSS_ENABLED)
+		supported_flags |= ETH_FLAG_RXHASH;
 
-	rc = ethtool_op_set_flags(netdev, data, ETH_FLAG_LRO | ETH_FLAG_NTUPLE |
-				  ETH_FLAG_RXVLAN | ETH_FLAG_TXVLAN |
-				  ETH_FLAG_RXHASH);
+	rc = ethtool_op_set_flags(netdev, data, supported_flags);
 	if (rc)
 		return rc;
 
-- 
1.7.5.2

