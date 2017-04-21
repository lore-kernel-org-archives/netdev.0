From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/11] ixgbe: Acquire PHY semaphore before device reset
Date: Thu, 20 Apr 2017 18:50:19 -0700
Message-ID: <20170421015029.18994-2-jeffrey.t.kirsher@intel.com>
References: <20170421015029.18994-1-jeffrey.t.kirsher@intel.com>
Cc: Paul Greenwalt <paul.greenwalt@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:48798 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1034398AbdDUBus (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 21:50:48 -0400
In-Reply-To: <20170421015029.18994-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Greenwalt <paul.greenwalt@intel.com>

A recent firmware change fixed an issue to acquire the PHY semaphore before
accessing PHY registers. This led to a case where  SW can issue a device
reset clearing the MDIO registers. This patch makes SW acquire the PHY
semaphore before issuing a device reset.

Signed-off-by: Paul Greenwalt <paul.greenwalt@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c | 8 ++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 8 ++++++++
 2 files changed, 16 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
index 84a467a8ed3d..6ea0d6a5fb90 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
@@ -95,6 +95,7 @@ s32 ixgbe_reset_hw_X540(struct ixgbe_hw *hw)
 {
 	s32 status;
 	u32 ctrl, i;
+	u32 swfw_mask = hw->phy.phy_semaphore_mask;
 
 	/* Call adapter stop to disable tx/rx and clear interrupts */
 	status = hw->mac.ops.stop_adapter(hw);
@@ -105,10 +106,17 @@ s32 ixgbe_reset_hw_X540(struct ixgbe_hw *hw)
 	ixgbe_clear_tx_pending(hw);
 
 mac_reset_top:
+	status = hw->mac.ops.acquire_swfw_sync(hw, swfw_mask);
+	if (status) {
+		hw_dbg(hw, "semaphore failed with %d", status);
+		return IXGBE_ERR_SWFW_SYNC;
+	}
+
 	ctrl = IXGBE_CTRL_RST;
 	ctrl |= IXGBE_READ_REG(hw, IXGBE_CTRL);
 	IXGBE_WRITE_REG(hw, IXGBE_CTRL, ctrl);
 	IXGBE_WRITE_FLUSH(hw);
+	hw->mac.ops.release_swfw_sync(hw, swfw_mask);
 	usleep_range(1000, 1200);
 
 	/* Poll for reset bit to self-clear indicating reset is complete */
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index 2658394599e4..58d3bcaca2b9 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -3318,6 +3318,7 @@ static s32 ixgbe_reset_hw_X550em(struct ixgbe_hw *hw)
 	u32 ctrl = 0;
 	u32 i;
 	bool link_up = false;
+	u32 swfw_mask = hw->phy.phy_semaphore_mask;
 
 	/* Call adapter stop to disable Tx/Rx and clear interrupts */
 	status = hw->mac.ops.stop_adapter(hw);
@@ -3363,9 +3364,16 @@ static s32 ixgbe_reset_hw_X550em(struct ixgbe_hw *hw)
 			ctrl = IXGBE_CTRL_RST;
 	}
 
+	status = hw->mac.ops.acquire_swfw_sync(hw, swfw_mask);
+	if (status) {
+		hw_dbg(hw, "semaphore failed with %d", status);
+		return IXGBE_ERR_SWFW_SYNC;
+	}
+
 	ctrl |= IXGBE_READ_REG(hw, IXGBE_CTRL);
 	IXGBE_WRITE_REG(hw, IXGBE_CTRL, ctrl);
 	IXGBE_WRITE_FLUSH(hw);
+	hw->mac.ops.release_swfw_sync(hw, swfw_mask);
 	usleep_range(1000, 1200);
 
 	/* Poll for reset bit to self-clear meaning reset is complete */
-- 
2.12.2
