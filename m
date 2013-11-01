From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 6/6] ixgbe: fix inconsistent clearing of the multicast table
Date: Fri,  1 Nov 2013 06:56:50 -0700
Message-ID: <1383314210-24289-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1383314210-24289-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:33105 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753899Ab3KAN45 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Nov 2013 09:56:57 -0400
In-Reply-To: <1383314210-24289-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch resolves an issue where the MTA table can be cleared when the
interface is reset while in promisc mode. As result IPv6 traffic between
VFs will be interrupted.

This patch makes the update of the MTA table unconditional to avoid the
inconsistent clearing on reset.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index a7d1a1c..5191b3c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3823,14 +3823,6 @@ void ixgbe_set_rx_mode(struct net_device *netdev)
 		if (netdev->flags & IFF_ALLMULTI) {
 			fctrl |= IXGBE_FCTRL_MPE;
 			vmolr |= IXGBE_VMOLR_MPE;
-		} else {
-			/*
-			 * Write addresses to the MTA, if the attempt fails
-			 * then we should just turn on promiscuous mode so
-			 * that we can at least receive multicast traffic
-			 */
-			hw->mac.ops.update_mc_addr_list(hw, netdev);
-			vmolr |= IXGBE_VMOLR_ROMPE;
 		}
 		ixgbe_vlan_filter_enable(adapter);
 		hw->addr_ctrl.user_set_promisc = false;
@@ -3847,6 +3839,13 @@ void ixgbe_set_rx_mode(struct net_device *netdev)
 		vmolr |= IXGBE_VMOLR_ROPE;
 	}
 
+	/* Write addresses to the MTA, if the attempt fails
+	 * then we should just turn on promiscuous mode so
+	 * that we can at least receive multicast traffic
+	 */
+	hw->mac.ops.update_mc_addr_list(hw, netdev);
+	vmolr |= IXGBE_VMOLR_ROMPE;
+
 	if (adapter->num_vfs)
 		ixgbe_restore_vf_multicasts(adapter);
 
-- 
1.8.3.1
