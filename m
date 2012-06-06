From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/3] ixgbe: fix_features rxvlan is independent of DCB and needs to be set
Date: Tue,  5 Jun 2012 21:08:54 -0700
Message-ID: <1338955735-8967-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1338955735-8967-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:49278 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753218Ab2FFEJA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jun 2012 00:09:00 -0400
In-Reply-To: <1338955735-8967-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

DCB can be used independent of if RX VLAN stripping is enabled
or disabled so remove erroneous check.

Also enable or disable VLAN stripping when features are applied so
hardware and feature flags are in sync.

CC: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Marcus Dennis <marcusx.e.dennis@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   15 +++++----------
 1 file changed, 5 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index bf20457..b8b2087 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3607,10 +3607,6 @@ static void ixgbe_configure_dcb(struct ixgbe_adapter *adapter)
 	if (hw->mac.type == ixgbe_mac_82598EB)
 		netif_set_gso_max_size(adapter->netdev, 32768);
 
-
-	/* Enable VLAN tag insert/strip */
-	adapter->netdev->features |= NETIF_F_HW_VLAN_RX;
-
 	hw->mac.ops.set_vfta(&adapter->hw, 0, 0, true);
 
 #ifdef IXGBE_FCOE
@@ -6701,11 +6697,6 @@ static netdev_features_t ixgbe_fix_features(struct net_device *netdev,
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
-#ifdef CONFIG_DCB
-	if (adapter->flags & IXGBE_FLAG_DCB_ENABLED)
-		features &= ~NETIF_F_HW_VLAN_RX;
-#endif
-
 	/* return error if RXHASH is being enabled when RSS is not supported */
 	if (!(adapter->flags & IXGBE_FLAG_RSS_ENABLED))
 		features &= ~NETIF_F_RXHASH;
@@ -6718,7 +6709,6 @@ static netdev_features_t ixgbe_fix_features(struct net_device *netdev,
 	if (!(adapter->flags2 & IXGBE_FLAG2_RSC_CAPABLE))
 		features &= ~NETIF_F_LRO;
 
-
 	return features;
 }
 
@@ -6766,6 +6756,11 @@ static int ixgbe_set_features(struct net_device *netdev,
 		need_reset = true;
 	}
 
+	if (features & NETIF_F_HW_VLAN_RX)
+		ixgbe_vlan_strip_enable(adapter);
+	else
+		ixgbe_vlan_strip_disable(adapter);
+
 	if (changed & NETIF_F_RXALL)
 		need_reset = true;
 
-- 
1.7.10.2
