From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/11] ixgbe: cleanup reset paths
Date: Thu, 15 Sep 2011 21:42:51 -0700
Message-ID: <1316148173-11209-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1316148173-11209-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:15976 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752046Ab1IPEnA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Sep 2011 00:43:00 -0400
In-Reply-To: <1316148173-11209-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The reset paths are overly complicated and are either missing steps or
contain extra unnecessary steps such as reading MAC address twice.  This
change is meant to help clean up the reset paths an get things functioning
correctly.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c |   13 ++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c |   40 ++++++++------
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h  |    1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c  |   72 +++++-------------------
 4 files changed, 43 insertions(+), 83 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
index 0d4e382..22504f2 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
@@ -820,8 +820,8 @@ mac_reset_top:
 	 * Issue global reset to the MAC.  This needs to be a SW reset.
 	 * If link reset is used, it might reset the MAC when mng is using it
 	 */
-	ctrl = IXGBE_READ_REG(hw, IXGBE_CTRL);
-	IXGBE_WRITE_REG(hw, IXGBE_CTRL, (ctrl | IXGBE_CTRL_RST));
+	ctrl = IXGBE_READ_REG(hw, IXGBE_CTRL) | IXGBE_CTRL_RST;
+	IXGBE_WRITE_REG(hw, IXGBE_CTRL, ctrl);
 	IXGBE_WRITE_FLUSH(hw);
 
 	/* Poll for reset bit to self-clear indicating reset is complete */
@@ -836,21 +836,18 @@ mac_reset_top:
 		hw_dbg(hw, "Reset polling failed to complete.\n");
 	}
 
+	msleep(50);
+
 	/*
 	 * Double resets are required for recovery from certain error
 	 * conditions.  Between resets, it is necessary to stall to allow time
-	 * for any pending HW events to complete.  We use 1usec since that is
-	 * what is needed for ixgbe_disable_pcie_master().  The second reset
-	 * then clears out any effects of those events.
+	 * for any pending HW events to complete.
 	 */
 	if (hw->mac.flags & IXGBE_FLAGS_DOUBLE_RESET_REQUIRED) {
 		hw->mac.flags &= ~IXGBE_FLAGS_DOUBLE_RESET_REQUIRED;
-		udelay(1);
 		goto mac_reset_top;
 	}
 
-	msleep(50);
-
 	gheccr = IXGBE_READ_REG(hw, IXGBE_GHECCR);
 	gheccr &= ~((1 << 21) | (1 << 18) | (1 << 9) | (1 << 6));
 	IXGBE_WRITE_REG(hw, IXGBE_GHECCR, gheccr);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
index f193fc2..a5ff435 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
@@ -904,11 +904,10 @@ static s32 ixgbe_setup_copper_link_82599(struct ixgbe_hw *hw,
  **/
 static s32 ixgbe_reset_hw_82599(struct ixgbe_hw *hw)
 {
-	s32 status = 0;
-	u32 ctrl;
-	u32 i;
-	u32 autoc;
-	u32 autoc2;
+	ixgbe_link_speed link_speed;
+	s32 status;
+	u32 ctrl, i, autoc, autoc2;
+	bool link_up = false;
 
 	/* Call adapter stop to disable tx/rx and clear interrupts */
 	hw->mac.ops.stop_adapter(hw);
@@ -942,40 +941,47 @@ static s32 ixgbe_reset_hw_82599(struct ixgbe_hw *hw)
 
 mac_reset_top:
 	/*
-	 * Issue global reset to the MAC.  This needs to be a SW reset.
-	 * If link reset is used, it might reset the MAC when mng is using it
+	 * Issue global reset to the MAC. Needs to be SW reset if link is up.
+	 * If link reset is used when link is up, it might reset the PHY when
+	 * mng is using it.  If link is down or the flag to force full link
+	 * reset is set, then perform link reset.
 	 */
-	ctrl = IXGBE_READ_REG(hw, IXGBE_CTRL);
-	IXGBE_WRITE_REG(hw, IXGBE_CTRL, (ctrl | IXGBE_CTRL_RST));
+	ctrl = IXGBE_CTRL_LNK_RST;
+	if (!hw->force_full_reset) {
+		hw->mac.ops.check_link(hw, &link_speed, &link_up, false);
+		if (link_up)
+			ctrl = IXGBE_CTRL_RST;
+	}
+
+	ctrl |= IXGBE_READ_REG(hw, IXGBE_CTRL);
+	IXGBE_WRITE_REG(hw, IXGBE_CTRL, ctrl);
 	IXGBE_WRITE_FLUSH(hw);
 
 	/* Poll for reset bit to self-clear indicating reset is complete */
 	for (i = 0; i < 10; i++) {
 		udelay(1);
 		ctrl = IXGBE_READ_REG(hw, IXGBE_CTRL);
-		if (!(ctrl & IXGBE_CTRL_RST))
+		if (!(ctrl & IXGBE_CTRL_RST_MASK))
 			break;
 	}
-	if (ctrl & IXGBE_CTRL_RST) {
+
+	if (ctrl & IXGBE_CTRL_RST_MASK) {
 		status = IXGBE_ERR_RESET_FAILED;
 		hw_dbg(hw, "Reset polling failed to complete.\n");
 	}
 
+	msleep(50);
+
 	/*
 	 * Double resets are required for recovery from certain error
 	 * conditions.  Between resets, it is necessary to stall to allow time
-	 * for any pending HW events to complete.  We use 1usec since that is
-	 * what is needed for ixgbe_disable_pcie_master().  The second reset
-	 * then clears out any effects of those events.
+	 * for any pending HW events to complete.
 	 */
 	if (hw->mac.flags & IXGBE_FLAGS_DOUBLE_RESET_REQUIRED) {
 		hw->mac.flags &= ~IXGBE_FLAGS_DOUBLE_RESET_REQUIRED;
-		udelay(1);
 		goto mac_reset_top;
 	}
 
-	msleep(50);
-
 	/*
 	 * Store the original AUTOC/AUTOC2 values if they have not been
 	 * stored off yet.  Otherwise restore the stored original
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index 9f618ee..a9f8839 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -982,6 +982,7 @@
 #define IXGBE_CTRL_GIO_DIS      0x00000004 /* Global IO Master Disable bit */
 #define IXGBE_CTRL_LNK_RST      0x00000008 /* Link Reset. Resets everything. */
 #define IXGBE_CTRL_RST          0x04000000 /* Reset (SW) */
+#define IXGBE_CTRL_RST_MASK     (IXGBE_CTRL_LNK_RST | IXGBE_CTRL_RST)
 
 /* FACTPS */
 #define IXGBE_FACTPS_LFS        0x40000000 /* LAN Function Select */
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
index 2696c78..bbfe8c4 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
@@ -94,13 +94,8 @@ static s32 ixgbe_setup_mac_link_X540(struct ixgbe_hw *hw,
 static s32 ixgbe_reset_hw_X540(struct ixgbe_hw *hw)
 {
 	ixgbe_link_speed link_speed;
-	s32 status = 0;
-	u32 ctrl;
-	u32 ctrl_ext;
-	u32 reset_bit;
-	u32 i;
-	u32 autoc;
-	u32 autoc2;
+	s32 status;
+	u32 ctrl, i;
 	bool link_up = false;
 
 	/* Call adapter stop to disable tx/rx and clear interrupts */
@@ -119,53 +114,42 @@ mac_reset_top:
 	 * mng is using it.  If link is down or the flag to force full link
 	 * reset is set, then perform link reset.
 	 */
-	if (hw->force_full_reset) {
-		reset_bit = IXGBE_CTRL_LNK_RST;
-	} else {
+	ctrl = IXGBE_CTRL_LNK_RST;
+	if (!hw->force_full_reset) {
 		hw->mac.ops.check_link(hw, &link_speed, &link_up, false);
-		if (!link_up)
-			reset_bit = IXGBE_CTRL_LNK_RST;
-		else
-			reset_bit = IXGBE_CTRL_RST;
+		if (link_up)
+			ctrl = IXGBE_CTRL_RST;
 	}
 
-	ctrl = IXGBE_READ_REG(hw, IXGBE_CTRL);
-	IXGBE_WRITE_REG(hw, IXGBE_CTRL, (ctrl | reset_bit));
+	ctrl |= IXGBE_READ_REG(hw, IXGBE_CTRL);
+	IXGBE_WRITE_REG(hw, IXGBE_CTRL, ctrl);
 	IXGBE_WRITE_FLUSH(hw);
 
 	/* Poll for reset bit to self-clear indicating reset is complete */
 	for (i = 0; i < 10; i++) {
 		udelay(1);
 		ctrl = IXGBE_READ_REG(hw, IXGBE_CTRL);
-		if (!(ctrl & reset_bit))
+		if (!(ctrl & IXGBE_CTRL_RST_MASK))
 			break;
 	}
-	if (ctrl & reset_bit) {
+
+	if (ctrl & IXGBE_CTRL_RST_MASK) {
 		status = IXGBE_ERR_RESET_FAILED;
 		hw_dbg(hw, "Reset polling failed to complete.\n");
 	}
 
+	msleep(50);
+
 	/*
 	 * Double resets are required for recovery from certain error
 	 * conditions.  Between resets, it is necessary to stall to allow time
-	 * for any pending HW events to complete.  We use 1usec since that is
-	 * what is needed for ixgbe_disable_pcie_master().  The second reset
-	 * then clears out any effects of those events.
+	 * for any pending HW events to complete.
 	 */
 	if (hw->mac.flags & IXGBE_FLAGS_DOUBLE_RESET_REQUIRED) {
 		hw->mac.flags &= ~IXGBE_FLAGS_DOUBLE_RESET_REQUIRED;
-		udelay(1);
 		goto mac_reset_top;
 	}
 
-	/* Clear PF Reset Done bit so PF/VF Mail Ops can work */
-	ctrl_ext = IXGBE_READ_REG(hw, IXGBE_CTRL_EXT);
-	ctrl_ext |= IXGBE_CTRL_EXT_PFRSTD;
-	IXGBE_WRITE_REG(hw, IXGBE_CTRL_EXT, ctrl_ext);
-	IXGBE_WRITE_FLUSH(hw);
-
-	msleep(50);
-
 	/* Set the Rx packet buffer size. */
 	IXGBE_WRITE_REG(hw, IXGBE_RXPBSIZE(0), 384 << IXGBE_RXPBSIZE_SHIFT);
 
@@ -173,31 +157,6 @@ mac_reset_top:
 	hw->mac.ops.get_mac_addr(hw, hw->mac.perm_addr);
 
 	/*
-	 * Store the original AUTOC/AUTOC2 values if they have not been
-	 * stored off yet.  Otherwise restore the stored original
-	 * values since the reset operation sets back to defaults.
-	 */
-	autoc = IXGBE_READ_REG(hw, IXGBE_AUTOC);
-	autoc2 = IXGBE_READ_REG(hw, IXGBE_AUTOC2);
-	if (hw->mac.orig_link_settings_stored == false) {
-		hw->mac.orig_autoc = autoc;
-		hw->mac.orig_autoc2 = autoc2;
-		hw->mac.orig_link_settings_stored = true;
-	} else {
-		if (autoc != hw->mac.orig_autoc)
-			IXGBE_WRITE_REG(hw, IXGBE_AUTOC, (hw->mac.orig_autoc |
-			                IXGBE_AUTOC_AN_RESTART));
-
-		if ((autoc2 & IXGBE_AUTOC2_UPPER_MASK) !=
-		    (hw->mac.orig_autoc2 & IXGBE_AUTOC2_UPPER_MASK)) {
-			autoc2 &= ~IXGBE_AUTOC2_UPPER_MASK;
-			autoc2 |= (hw->mac.orig_autoc2 &
-			           IXGBE_AUTOC2_UPPER_MASK);
-			IXGBE_WRITE_REG(hw, IXGBE_AUTOC2, autoc2);
-		}
-	}
-
-	/*
 	 * Store MAC address from RAR0, clear receive address registers, and
 	 * clear the multicast table.  Also reset num_rar_entries to 128,
 	 * since we modify this value when programming the SAN MAC address.
@@ -205,9 +164,6 @@ mac_reset_top:
 	hw->mac.num_rar_entries = IXGBE_X540_MAX_TX_QUEUES;
 	hw->mac.ops.init_rx_addrs(hw);
 
-	/* Store the permanent mac address */
-	hw->mac.ops.get_mac_addr(hw, hw->mac.perm_addr);
-
 	/* Store the permanent SAN mac address */
 	hw->mac.ops.get_san_mac_addr(hw, hw->mac.san_addr);
 
-- 
1.7.6
