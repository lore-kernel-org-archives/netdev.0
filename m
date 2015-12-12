From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/12] ixgbe: Clear stale pool mappings
Date: Sat, 12 Dec 2015 03:14:48 -0800
Message-ID: <1449918890-145243-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449918890-145243-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:39614 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752408AbbLLLPD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Dec 2015 06:15:03 -0500
In-Reply-To: <1449918890-145243-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

This patch makes certain that we clear the pool mappings added when we
configure default MAC addresses for the interface.  Without this we run the
risk of leaking an address into pool 0 which really belongs to VF 0 when
SR-IOV is enabled.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c  | 10 +++++++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c |  7 ++++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c   | 10 +++++++---
 3 files changed, 18 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
index b8bd725..fa8d4f4 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
@@ -1083,12 +1083,16 @@ mac_reset_top:
 
 	/* Add the SAN MAC address to the RAR only if it's a valid address */
 	if (is_valid_ether_addr(hw->mac.san_addr)) {
-		hw->mac.ops.set_rar(hw, hw->mac.num_rar_entries - 1,
-				    hw->mac.san_addr, 0, IXGBE_RAH_AV);
-
 		/* Save the SAN MAC RAR index */
 		hw->mac.san_mac_rar_index = hw->mac.num_rar_entries - 1;
 
+		hw->mac.ops.set_rar(hw, hw->mac.san_mac_rar_index,
+				    hw->mac.san_addr, 0, IXGBE_RAH_AV);
+
+		/* clear VMDq pool/queue selection for this RAR */
+		hw->mac.ops.clear_vmdq(hw, hw->mac.san_mac_rar_index,
+				       IXGBE_CLEAR_VMDQ_ALL);
+
 		/* Reserve the last RAR for the SAN MAC address */
 		hw->mac.num_rar_entries--;
 	}
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index 73dcc0a..6404505 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -1884,10 +1884,11 @@ s32 ixgbe_init_rx_addrs_generic(struct ixgbe_hw *hw)
 		hw_dbg(hw, " New MAC Addr =%pM\n", hw->mac.addr);
 
 		hw->mac.ops.set_rar(hw, 0, hw->mac.addr, 0, IXGBE_RAH_AV);
-
-		/*  clear VMDq pool/queue selection for RAR 0 */
-		hw->mac.ops.clear_vmdq(hw, 0, IXGBE_CLEAR_VMDQ_ALL);
 	}
+
+	/*  clear VMDq pool/queue selection for RAR 0 */
+	hw->mac.ops.clear_vmdq(hw, 0, IXGBE_CLEAR_VMDQ_ALL);
+
 	hw->addr_ctrl.overflow_promisc = 0;
 
 	hw->addr_ctrl.rar_used_count = 1;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
index bf8225c..2358c1b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
@@ -154,12 +154,16 @@ mac_reset_top:
 
 	/* Add the SAN MAC address to the RAR only if it's a valid address */
 	if (is_valid_ether_addr(hw->mac.san_addr)) {
-		hw->mac.ops.set_rar(hw, hw->mac.num_rar_entries - 1,
-				    hw->mac.san_addr, 0, IXGBE_RAH_AV);
-
 		/* Save the SAN MAC RAR index */
 		hw->mac.san_mac_rar_index = hw->mac.num_rar_entries - 1;
 
+		hw->mac.ops.set_rar(hw, hw->mac.san_mac_rar_index,
+				    hw->mac.san_addr, 0, IXGBE_RAH_AV);
+
+		/* clear VMDq pool/queue selection for this RAR */
+		hw->mac.ops.clear_vmdq(hw, hw->mac.san_mac_rar_index,
+				       IXGBE_CLEAR_VMDQ_ALL);
+
 		/* Reserve the last RAR for the SAN MAC address */
 		hw->mac.num_rar_entries--;
 	}
-- 
2.5.0
