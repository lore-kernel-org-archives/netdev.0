From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/11] ixgbe: fix MNG FW support when adapter not up
Date: Fri, 12 Apr 2013 04:24:24 -0700
Message-ID: <1365765866-15741-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1365765866-15741-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:40891 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754921Ab3DLLZH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Apr 2013 07:25:07 -0400
In-Reply-To: <1365765866-15741-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

We were only turning the laser on when the adapter was up.  This
causes issues for those who wanted to access the MNG FW while the
port was in a down state.  This patch makes sure the laser is turned
on in probe and remain up even after the port is brought down.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c | 48 +++++++++++++++++++++++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  | 10 ++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h  | 10 ++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c  |  1 +
 5 files changed, 65 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
index d0113fc..4a5bfb6 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
@@ -1305,6 +1305,7 @@ static struct ixgbe_mac_operations mac_ops_82598 = {
 	.release_swfw_sync      = &ixgbe_release_swfw_sync,
 	.get_thermal_sensor_data = NULL,
 	.init_thermal_sensor_thresh = NULL,
+	.mng_fw_enabled		= NULL,
 };
 
 static struct ixgbe_eeprom_operations eeprom_ops_82598 = {
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
index 203a00c..b6289f1 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
@@ -59,12 +59,34 @@ static s32 ixgbe_setup_copper_link_82599(struct ixgbe_hw *hw,
                                          bool autoneg_wait_to_complete);
 static s32 ixgbe_verify_fw_version_82599(struct ixgbe_hw *hw);
 
+static bool ixgbe_mng_enabled(struct ixgbe_hw *hw)
+{
+	u32 fwsm, manc, factps;
+
+	fwsm = IXGBE_READ_REG(hw, IXGBE_FWSM);
+	if ((fwsm & IXGBE_FWSM_MODE_MASK) != IXGBE_FWSM_FW_MODE_PT)
+		return false;
+
+	manc = IXGBE_READ_REG(hw, IXGBE_MANC);
+	if (!(manc & IXGBE_MANC_RCV_TCO_EN))
+		return false;
+
+	factps = IXGBE_READ_REG(hw, IXGBE_FACTPS);
+	if (factps & IXGBE_FACTPS_MNGCG)
+		return false;
+
+	return true;
+}
+
 static void ixgbe_init_mac_link_ops_82599(struct ixgbe_hw *hw)
 {
 	struct ixgbe_mac_info *mac = &hw->mac;
 
-	/* enable the laser control functions for SFP+ fiber */
-	if (mac->ops.get_media_type(hw) == ixgbe_media_type_fiber) {
+	/* enable the laser control functions for SFP+ fiber
+	 * and MNG not enabled
+	 */
+	if ((mac->ops.get_media_type(hw) == ixgbe_media_type_fiber) &&
+	    !hw->mng_fw_enabled) {
 		mac->ops.disable_tx_laser =
 		                       &ixgbe_disable_tx_laser_multispeed_fiber;
 		mac->ops.enable_tx_laser =
@@ -563,7 +585,8 @@ static s32 ixgbe_setup_mac_link_multispeed_fiber(struct ixgbe_hw *hw,
 			return status;
 
 		/* Flap the tx laser if it has not already been done */
-		hw->mac.ops.flap_tx_laser(hw);
+		if (hw->mac.ops.flap_tx_laser)
+			hw->mac.ops.flap_tx_laser(hw);
 
 		/*
 		 * Wait for the controller to acquire link.  Per IEEE 802.3ap,
@@ -615,7 +638,8 @@ static s32 ixgbe_setup_mac_link_multispeed_fiber(struct ixgbe_hw *hw,
 			return status;
 
 		/* Flap the tx laser if it has not already been done */
-		hw->mac.ops.flap_tx_laser(hw);
+		if (hw->mac.ops.flap_tx_laser)
+			hw->mac.ops.flap_tx_laser(hw);
 
 		/* Wait for the link partner to also set speed */
 		msleep(100);
@@ -933,6 +957,7 @@ static s32 ixgbe_reset_hw_82599(struct ixgbe_hw *hw)
 	ixgbe_link_speed link_speed;
 	s32 status;
 	u32 ctrl, i, autoc, autoc2;
+	u32 curr_lms;
 	bool link_up = false;
 
 	/* Call adapter stop to disable tx/rx and clear interrupts */
@@ -964,6 +989,9 @@ static s32 ixgbe_reset_hw_82599(struct ixgbe_hw *hw)
 	if (hw->phy.reset_disable == false && hw->phy.ops.reset != NULL)
 		hw->phy.ops.reset(hw);
 
+	/* remember AUTOC LMS from before we reset */
+	curr_lms = IXGBE_READ_REG(hw, IXGBE_AUTOC) & IXGBE_AUTOC_LMS_MASK;
+
 mac_reset_top:
 	/*
 	 * Issue global reset to the MAC. Needs to be SW reset if link is up.
@@ -1019,6 +1047,16 @@ mac_reset_top:
 		hw->mac.orig_autoc2 = autoc2;
 		hw->mac.orig_link_settings_stored = true;
 	} else {
+
+		/* If MNG FW is running on a multi-speed device that
+		 * doesn't autoneg with out driver support we need to
+		 * leave LMS in the state it was before we MAC reset.
+		 */
+		if (hw->phy.multispeed_fiber && hw->mng_fw_enabled)
+			hw->mac.orig_autoc =
+				(hw->mac.orig_autoc & ~IXGBE_AUTOC_LMS_MASK) |
+				curr_lms;
+
 		if (autoc != hw->mac.orig_autoc) {
 			/* Need SW/FW semaphore around AUTOC writes if LESM is
 			 * on, likewise reset_pipeline requires us to hold
@@ -2216,7 +2254,7 @@ static struct ixgbe_mac_operations mac_ops_82599 = {
 	.release_swfw_sync      = &ixgbe_release_swfw_sync,
 	.get_thermal_sensor_data = &ixgbe_get_thermal_sensor_data_generic,
 	.init_thermal_sensor_thresh = &ixgbe_init_thermal_sensor_thresh_generic,
-
+	.mng_fw_enabled		= &ixgbe_mng_enabled,
 };
 
 static struct ixgbe_eeprom_operations eeprom_ops_82599 = {
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 8793aae..ed0a6b6 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7510,6 +7510,10 @@ static int ixgbe_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (err)
 		goto err_sw_init;
 
+	/* Cache if MNG FW is up so we don't have to read the REG later */
+	if (hw->mac.ops.mng_fw_enabled)
+		hw->mng_fw_enabled = hw->mac.ops.mng_fw_enabled(hw);
+
 	/* Make it possible the adapter to be woken up via WOL */
 	switch (adapter->hw.mac.type) {
 	case ixgbe_mac_82599EB:
@@ -7758,6 +7762,12 @@ skip_sriov:
 	ixgbe_dbg_adapter_init(adapter);
 #endif /* CONFIG_DEBUG_FS */
 
+	/* Need link setup for MNG FW, else wait for IXGBE_UP */
+	if (hw->mng_fw_enabled && hw->mac.ops.setup_link)
+		hw->mac.ops.setup_link(hw,
+			IXGBE_LINK_SPEED_10GB_FULL | IXGBE_LINK_SPEED_1GB_FULL,
+			true);
+
 	return 0;
 
 err_register:
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index 05df36e..200b1a8 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -729,6 +729,13 @@ struct ixgbe_thermal_sensor_data {
 #define IXGBE_MDEF_EXT(_i) (0x05160 + ((_i) * 4)) /* 8 of these (0-7) */
 #define IXGBE_LSWFW     0x15014
 
+/* Management Bit Fields and Masks */
+#define IXGBE_MANC_RCV_TCO_EN	0x00020000 /* Rcv TCO packet enable */
+
+/* Firmware Semaphore Register */
+#define IXGBE_FWSM_MODE_MASK	0xE
+#define IXGBE_FWSM_FW_MODE_PT	0x4
+
 /* ARC Subsystem registers */
 #define IXGBE_HICR      0x15F00
 #define IXGBE_FWSTS     0x15F0C
@@ -1019,6 +1026,7 @@ struct ixgbe_thermal_sensor_data {
 #define IXGBE_CTRL_RST_MASK     (IXGBE_CTRL_LNK_RST | IXGBE_CTRL_RST)
 
 /* FACTPS */
+#define IXGBE_FACTPS_MNGCG      0x20000000 /* Manageblility Clock Gated */
 #define IXGBE_FACTPS_LFS        0x40000000 /* LAN Function Select */
 
 /* MHADD Bit Masks */
@@ -2861,6 +2869,7 @@ struct ixgbe_mac_operations {
 	s32 (*set_fw_drv_ver)(struct ixgbe_hw *, u8, u8, u8, u8);
 	s32 (*get_thermal_sensor_data)(struct ixgbe_hw *);
 	s32 (*init_thermal_sensor_thresh)(struct ixgbe_hw *hw);
+	bool (*mng_fw_enabled)(struct ixgbe_hw *hw);
 };
 
 struct ixgbe_phy_operations {
@@ -2988,6 +2997,7 @@ struct ixgbe_hw {
 	bool				adapter_stopped;
 	bool				force_full_reset;
 	bool				allow_unsupported_sfp;
+	bool				mng_fw_enabled;
 };
 
 struct ixgbe_info {
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
index 66c5e94..389324f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
@@ -854,6 +854,7 @@ static struct ixgbe_mac_operations mac_ops_X540 = {
 	.enable_rx_buff		= &ixgbe_enable_rx_buff_generic,
 	.get_thermal_sensor_data = NULL,
 	.init_thermal_sensor_thresh = NULL,
+	.mng_fw_enabled		= NULL,
 };
 
 static struct ixgbe_eeprom_operations eeprom_ops_X540 = {
-- 
1.7.11.7
