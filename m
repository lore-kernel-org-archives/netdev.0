From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/12] ixgbe: cleanup logic in ixgbe_change_mtu
Date: Sat, 17 Mar 2012 01:50:54 -0700
Message-ID: <1331974260-6383-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1331974260-6383-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:51651 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753595Ab2CQIve (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Mar 2012 04:51:34 -0400
In-Reply-To: <1331974260-6383-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change is meant to just cleanup the logic in ixgbe_change_mtu since we
are making it unnecessarily complex due to a workaround required for 82599
when SR-IOV is enabled.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   20 ++++++++++++--------
 1 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index e97ef45..db1f17c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -5544,20 +5544,24 @@ static void ixgbe_free_all_rx_resources(struct ixgbe_adapter *adapter)
 static int ixgbe_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	struct ixgbe_hw *hw = &adapter->hw;
 	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN;
 
 	/* MTU < 68 is an error and causes problems on some kernels */
-	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED &&
-	    hw->mac.type != ixgbe_mac_X540) {
-		if ((new_mtu < 68) || (max_frame > MAXIMUM_ETHERNET_VLAN_SIZE))
-			return -EINVAL;
-	} else {
-		if ((new_mtu < 68) || (max_frame > IXGBE_MAX_JUMBO_FRAME_SIZE))
+	if ((new_mtu < 68) || (max_frame > IXGBE_MAX_JUMBO_FRAME_SIZE))
+		return -EINVAL;
+
+	/*
+	 * For 82599EB we cannot allow PF to change MTU greater than 1500
+	 * in SR-IOV mode as it may cause buffer overruns in guest VFs that
+	 * don't allocate and chain buffers correctly.
+	 */
+	if ((adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) &&
+	    (adapter->hw.mac.type == ixgbe_mac_82599EB) &&
+	    (max_frame > MAXIMUM_ETHERNET_VLAN_SIZE))
 			return -EINVAL;
-	}
 
 	e_info(probe, "changing MTU from %d to %d\n", netdev->mtu, new_mtu);
+
 	/* must set new MTU before calling down or up */
 	netdev->mtu = new_mtu;
 
-- 
1.7.7.6
