From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 09/24] ixgbe: Add ability to double reset on failure to clear master enable
Date: Thu,  3 Mar 2011 05:03:34 -0800
Message-ID: <1299157429-15878-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299157429-15878-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:24647 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758196Ab1CCNEV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2011 08:04:21 -0500
In-Reply-To: <1299157429-15878-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Double resets are required for recovery from certain error conditions.
Between resets, it is necessary to stall to allow time for any pending HW
events to complete. We use 1usec since that is what is needed for
ixgbe_disable_pcie_master(). The second reset then clears out any effects
of those events.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_82598.c  |   21 ++++++++++++-----
 drivers/net/ixgbe/ixgbe_82599.c  |   20 ++++++++++++----
 drivers/net/ixgbe/ixgbe_common.c |   47 +++++++++++++++++++++++++++++++++-----
 drivers/net/ixgbe/ixgbe_type.h   |    4 +++
 drivers/net/ixgbe/ixgbe_x540.c   |   20 ++++++++++++----
 5 files changed, 90 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index d0f1d9d..291b1e6 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -770,7 +770,6 @@ static s32 ixgbe_reset_hw_82598(struct ixgbe_hw *hw)
 		else if (phy_status == IXGBE_ERR_SFP_NOT_PRESENT)
 			goto no_phy_reset;
 
-
 		hw->phy.ops.reset(hw);
 	}
 
@@ -779,12 +778,9 @@ no_phy_reset:
 	 * Prevent the PCI-E bus from from hanging by disabling PCI-E master
 	 * access and verify no pending requests before reset
 	 */
-	status = ixgbe_disable_pcie_master(hw);
-	if (status != 0) {
-		status = IXGBE_ERR_MASTER_REQUESTS_PENDING;
-		hw_dbg(hw, "PCI-E Master disable polling has failed.\n");
-	}
+	ixgbe_disable_pcie_master(hw);
 
+mac_reset_top:
 	/*
 	 * Issue global reset to the MAC.  This needs to be a SW reset.
 	 * If link reset is used, it might reset the MAC when mng is using it
@@ -805,6 +801,19 @@ no_phy_reset:
 		hw_dbg(hw, "Reset polling failed to complete.\n");
 	}
 
+	/*
+	 * Double resets are required for recovery from certain error
+	 * conditions.  Between resets, it is necessary to stall to allow time
+	 * for any pending HW events to complete.  We use 1usec since that is
+	 * what is needed for ixgbe_disable_pcie_master().  The second reset
+	 * then clears out any effects of those events.
+	 */
+	if (hw->mac.flags & IXGBE_FLAGS_DOUBLE_RESET_REQUIRED) {
+		hw->mac.flags &= ~IXGBE_FLAGS_DOUBLE_RESET_REQUIRED;
+		udelay(1);
+		goto mac_reset_top;
+	}
+
 	msleep(50);
 
 	gheccr = IXGBE_READ_REG(hw, IXGBE_GHECCR);
diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index b45a491..126a06f 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -904,12 +904,9 @@ static s32 ixgbe_reset_hw_82599(struct ixgbe_hw *hw)
 	 * Prevent the PCI-E bus from from hanging by disabling PCI-E master
 	 * access and verify no pending requests before reset
 	 */
-	status = ixgbe_disable_pcie_master(hw);
-	if (status != 0) {
-		status = IXGBE_ERR_MASTER_REQUESTS_PENDING;
-		hw_dbg(hw, "PCI-E Master disable polling has failed.\n");
-	}
+	ixgbe_disable_pcie_master(hw);
 
+mac_reset_top:
 	/*
 	 * Issue global reset to the MAC.  This needs to be a SW reset.
 	 * If link reset is used, it might reset the MAC when mng is using it
@@ -930,6 +927,19 @@ static s32 ixgbe_reset_hw_82599(struct ixgbe_hw *hw)
 		hw_dbg(hw, "Reset polling failed to complete.\n");
 	}
 
+	/*
+	 * Double resets are required for recovery from certain error
+	 * conditions.  Between resets, it is necessary to stall to allow time
+	 * for any pending HW events to complete.  We use 1usec since that is
+	 * what is needed for ixgbe_disable_pcie_master().  The second reset
+	 * then clears out any effects of those events.
+	 */
+	if (hw->mac.flags & IXGBE_FLAGS_DOUBLE_RESET_REQUIRED) {
+		hw->mac.flags &= ~IXGBE_FLAGS_DOUBLE_RESET_REQUIRED;
+		udelay(1);
+		goto mac_reset_top;
+	}
+
 	msleep(50);
 
 	/*
diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index 345c32e..6d87c74 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -454,8 +454,7 @@ s32 ixgbe_stop_adapter_generic(struct ixgbe_hw *hw)
 	 * Prevent the PCI-E bus from from hanging by disabling PCI-E master
 	 * access and verify no pending requests
 	 */
-	if (ixgbe_disable_pcie_master(hw) != 0)
-		hw_dbg(hw, "PCI-E Master disable polling has failed.\n");
+	ixgbe_disable_pcie_master(hw);
 
 	return 0;
 }
@@ -2161,10 +2160,16 @@ out:
  **/
 s32 ixgbe_disable_pcie_master(struct ixgbe_hw *hw)
 {
+	struct ixgbe_adapter *adapter = hw->back;
 	u32 i;
 	u32 reg_val;
 	u32 number_of_queues;
-	s32 status = IXGBE_ERR_MASTER_REQUESTS_PENDING;
+	s32 status = 0;
+	u16 dev_status = 0;
+
+	/* Just jump out if bus mastering is already disabled */
+	if (!(IXGBE_READ_REG(hw, IXGBE_STATUS) & IXGBE_STATUS_GIO))
+		goto out;
 
 	/* Disable the receive unit by stopping each queue */
 	number_of_queues = hw->mac.max_rx_queues;
@@ -2181,13 +2186,43 @@ s32 ixgbe_disable_pcie_master(struct ixgbe_hw *hw)
 	IXGBE_WRITE_REG(hw, IXGBE_CTRL, reg_val);
 
 	for (i = 0; i < IXGBE_PCI_MASTER_DISABLE_TIMEOUT; i++) {
-		if (!(IXGBE_READ_REG(hw, IXGBE_STATUS) & IXGBE_STATUS_GIO)) {
-			status = 0;
+		if (!(IXGBE_READ_REG(hw, IXGBE_STATUS) & IXGBE_STATUS_GIO))
+			goto check_device_status;
+		udelay(100);
+	}
+
+	hw_dbg(hw, "GIO Master Disable bit didn't clear - requesting resets\n");
+	status = IXGBE_ERR_MASTER_REQUESTS_PENDING;
+
+	/*
+	 * Before proceeding, make sure that the PCIe block does not have
+	 * transactions pending.
+	 */
+check_device_status:
+	for (i = 0; i < IXGBE_PCI_MASTER_DISABLE_TIMEOUT; i++) {
+		pci_read_config_word(adapter->pdev, IXGBE_PCI_DEVICE_STATUS,
+							 &dev_status);
+		if (!(dev_status & IXGBE_PCI_DEVICE_STATUS_TRANSACTION_PENDING))
 			break;
-		}
 		udelay(100);
 	}
 
+	if (i == IXGBE_PCI_MASTER_DISABLE_TIMEOUT)
+		hw_dbg(hw, "PCIe transaction pending bit also did not clear.\n");
+	else
+		goto out;
+
+	/*
+	 * Two consecutive resets are required via CTRL.RST per datasheet
+	 * 5.2.5.3.2 Master Disable.  We set a flag to inform the reset routine
+	 * of this need.  The first reset prevents new master requests from
+	 * being issued by our device.  We then must wait 1usec for any
+	 * remaining completions from the PCIe bus to trickle in, and then reset
+	 * again to clear out any effects they may have had on our device.
+	 */
+	 hw->mac.flags |= IXGBE_FLAGS_DOUBLE_RESET_REQUIRED;
+
+out:
 	return status;
 }
 
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index af5ad40..5ede03c 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -1614,6 +1614,8 @@
 #define IXGBE_ALT_SAN_MAC_ADDR_CAPS_ALTWWN  0x1 /* Alt. WWN base exists */
 
 /* PCI Bus Info */
+#define IXGBE_PCI_DEVICE_STATUS   0xAA
+#define IXGBE_PCI_DEVICE_STATUS_TRANSACTION_PENDING   0x0020
 #define IXGBE_PCI_LINK_STATUS     0xB2
 #define IXGBE_PCI_DEVICE_CONTROL2 0xC8
 #define IXGBE_PCI_LINK_WIDTH      0x3F0
@@ -2557,6 +2559,7 @@ struct ixgbe_eeprom_info {
 	u16                             address_bits;
 };
 
+#define IXGBE_FLAGS_DOUBLE_RESET_REQUIRED	0x01
 struct ixgbe_mac_info {
 	struct ixgbe_mac_operations     ops;
 	enum ixgbe_mac_type             type;
@@ -2579,6 +2582,7 @@ struct ixgbe_mac_info {
 	u32                             orig_autoc2;
 	bool                            orig_link_settings_stored;
 	bool                            autotry_restart;
+	u8                              flags;
 };
 
 struct ixgbe_phy_info {
diff --git a/drivers/net/ixgbe/ixgbe_x540.c b/drivers/net/ixgbe/ixgbe_x540.c
index f2518b0..a6f06d5 100644
--- a/drivers/net/ixgbe/ixgbe_x540.c
+++ b/drivers/net/ixgbe/ixgbe_x540.c
@@ -110,12 +110,9 @@ static s32 ixgbe_reset_hw_X540(struct ixgbe_hw *hw)
 	 * Prevent the PCI-E bus from from hanging by disabling PCI-E master
 	 * access and verify no pending requests before reset
 	 */
-	status = ixgbe_disable_pcie_master(hw);
-	if (status != 0) {
-		status = IXGBE_ERR_MASTER_REQUESTS_PENDING;
-		hw_dbg(hw, "PCI-E Master disable polling has failed.\n");
-	}
+	ixgbe_disable_pcie_master(hw);
 
+mac_reset_top:
 	/*
 	 * Issue global reset to the MAC.  Needs to be SW reset if link is up.
 	 * If link reset is used when link is up, it might reset the PHY when
@@ -148,6 +145,19 @@ static s32 ixgbe_reset_hw_X540(struct ixgbe_hw *hw)
 		hw_dbg(hw, "Reset polling failed to complete.\n");
 	}
 
+	/*
+	 * Double resets are required for recovery from certain error
+	 * conditions.  Between resets, it is necessary to stall to allow time
+	 * for any pending HW events to complete.  We use 1usec since that is
+	 * what is needed for ixgbe_disable_pcie_master().  The second reset
+	 * then clears out any effects of those events.
+	 */
+	if (hw->mac.flags & IXGBE_FLAGS_DOUBLE_RESET_REQUIRED) {
+		hw->mac.flags &= ~IXGBE_FLAGS_DOUBLE_RESET_REQUIRED;
+		udelay(1);
+		goto mac_reset_top;
+	}
+
 	/* Clear PF Reset Done bit so PF/VF Mail Ops can work */
 	ctrl_ext = IXGBE_READ_REG(hw, IXGBE_CTRL_EXT);
 	ctrl_ext |= IXGBE_CTRL_EXT_PFRSTD;
-- 
1.7.4

