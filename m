From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/2] e1000e: keep Rx/Tx HW_VLAN_CTAG in sync
Date: Wed, 29 Jun 2016 09:30:03 -0700
Message-ID: <1467217804-137463-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1467217804-137463-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jarod Wilson <jarod@redhat.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:14828 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751141AbcF2Qbm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jun 2016 12:31:42 -0400
In-Reply-To: <1467217804-137463-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarod Wilson <jarod@redhat.com>

The bit in the e1000 driver that mentions explicitly that the hardware
has no support for separate RX/TX VLAN accel toggling rings true for
e1000e as well, and thus both NETIF_F_HW_VLAN_CTAG_RX and
NETIF_F_HW_VLAN_CTAG_TX need to be kept in sync.

Revert a portion of commit 889ad456660461 ("e1000e: keep VLAN interfaces
functional after rxvlan off") since keeping the bits in sync resolves
the original issue.

Signed-off-by: Jarod Wilson <jarod@redhat.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 21 +++++++++------------
 1 file changed, 9 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 73f7452..2b2e2f8 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -154,16 +154,6 @@ void __ew32(struct e1000_hw *hw, unsigned long reg, u32 val)
 	writel(val, hw->hw_addr + reg);
 }
 
-static bool e1000e_vlan_used(struct e1000_adapter *adapter)
-{
-	u16 vid;
-
-	for_each_set_bit(vid, adapter->active_vlans, VLAN_N_VID)
-		return true;
-
-	return false;
-}
-
 /**
  * e1000_regdump - register printout routine
  * @hw: pointer to the HW structure
@@ -3453,8 +3443,7 @@ static void e1000e_set_rx_mode(struct net_device *netdev)
 
 	ew32(RCTL, rctl);
 
-	if (netdev->features & NETIF_F_HW_VLAN_CTAG_RX ||
-	    e1000e_vlan_used(adapter))
+	if (netdev->features & NETIF_F_HW_VLAN_CTAG_RX)
 		e1000e_vlan_strip_enable(adapter);
 	else
 		e1000e_vlan_strip_disable(adapter);
@@ -6926,6 +6915,14 @@ static netdev_features_t e1000_fix_features(struct net_device *netdev,
 	if ((hw->mac.type >= e1000_pch2lan) && (netdev->mtu > ETH_DATA_LEN))
 		features &= ~NETIF_F_RXFCS;
 
+	/* Since there is no support for separate Rx/Tx vlan accel
+	 * enable/disable make sure Tx flag is always in same state as Rx.
+	 */
+	if (features & NETIF_F_HW_VLAN_CTAG_RX)
+		features |= NETIF_F_HW_VLAN_CTAG_TX;
+	else
+		features &= ~NETIF_F_HW_VLAN_CTAG_TX;
+
 	return features;
 }
 
-- 
2.5.5
