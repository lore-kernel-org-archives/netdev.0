From: Alexander Duyck <aduyck@mirantis.com>
Subject: [next PATCH 10/11] ixgbe: Clear stale pool mappings
Date: Mon, 02 Nov 2015 17:10:26 -0800
Message-ID: <20151103011026.28233.59751.stgit@localhost.localdomain>
References: <20151103005850.28233.63113.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35440 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754311AbbKCBK1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 20:10:27 -0500
Received: by pasz6 with SMTP id z6so2047812pas.2
        for <netdev@vger.kernel.org>; Mon, 02 Nov 2015 17:10:27 -0800 (PST)
In-Reply-To: <20151103005850.28233.63113.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>

This patch makes certain that we clear the pool mappings added when we
configure default MAC addresses for the interface.  Without this we run the
risk of leaking an address into pool 0 which really belongs to VF 0 when
SR-IOV is enabled.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c  |   10 +++++++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c |    7 ++++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c   |   10 +++++++---
 3 files changed, 18 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
index b8bd72589f72..fa8d4f40ac2a 100644
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
index 73dcc0aec6dc..64045053e874 100644
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
index b9e9b0c17398..e44952eeab00 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
@@ -155,12 +155,16 @@ mac_reset_top:
 
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
