From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/14] ixgbe: Place SWFW semaphore in known valid state at probe
Date: Mon,  4 Apr 2016 15:14:55 -0700
Message-ID: <1459808097-26409-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459808097-26409-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:64563 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756309AbcDDWPH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2016 18:15:07 -0400
In-Reply-To: <1459808097-26409-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

It is possible on some HW that a system reset could occur when we are
holding the SWFW semaphore lock.  So next time the driver was loaded we
would see it incorrectly as locked. This patch will recover from that state
by: Attempting to acquire the semaphore and then regardless of whether or
not it was acquire we immediately release it. This will force us into
a known good state.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  |  4 ++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h  |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c  | 20 ++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.h  |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c  |  2 ++
 7 files changed, 30 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
index f47eb12..6ecd598 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
@@ -1196,6 +1196,7 @@ static const struct ixgbe_mac_operations mac_ops_82598 = {
 	.set_fw_drv_ver         = NULL,
 	.acquire_swfw_sync      = &ixgbe_acquire_swfw_sync,
 	.release_swfw_sync      = &ixgbe_release_swfw_sync,
+	.init_swfw_sync		= NULL,
 	.get_thermal_sensor_data = NULL,
 	.init_thermal_sensor_thresh = NULL,
 	.prot_autoc_read	= &prot_autoc_read_generic,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
index c3ae5a7..4bb6b68 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
@@ -2228,6 +2228,7 @@ static const struct ixgbe_mac_operations mac_ops_82599 = {
 	.set_vlan_anti_spoofing = &ixgbe_set_vlan_anti_spoofing,
 	.acquire_swfw_sync      = &ixgbe_acquire_swfw_sync,
 	.release_swfw_sync      = &ixgbe_release_swfw_sync,
+	.init_swfw_sync		= NULL,
 	.get_thermal_sensor_data = &ixgbe_get_thermal_sensor_data_generic,
 	.init_thermal_sensor_thresh = &ixgbe_init_thermal_sensor_thresh_generic,
 	.prot_autoc_read	= &prot_autoc_read_82599,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index e972ab5..d8b67d2 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -9126,6 +9126,10 @@ static int ixgbe_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (err)
 		goto err_sw_init;
 
+	/* Make sure the SWFW semaphore is in a valid state */
+	if (hw->mac.ops.init_swfw_sync)
+		hw->mac.ops.init_swfw_sync(hw);
+
 	/* Make it possible the adapter to be woken up via WOL */
 	switch (adapter->hw.mac.type) {
 	case ixgbe_mac_82599EB:
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index 787d2b2..bc012ab 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -3266,6 +3266,7 @@ struct ixgbe_mac_operations {
 	s32 (*enable_rx_dma)(struct ixgbe_hw *, u32);
 	s32 (*acquire_swfw_sync)(struct ixgbe_hw *, u32);
 	void (*release_swfw_sync)(struct ixgbe_hw *, u32);
+	void (*init_swfw_sync)(struct ixgbe_hw *);
 	s32 (*prot_autoc_read)(struct ixgbe_hw *, bool *, u32 *);
 	s32 (*prot_autoc_write)(struct ixgbe_hw *, u32, bool);
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
index c00b67b..40824d8 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
@@ -747,6 +747,25 @@ static void ixgbe_release_swfw_sync_semaphore(struct ixgbe_hw *hw)
 }
 
 /**
+ *  ixgbe_init_swfw_sync_X540 - Release hardware semaphore
+ *  @hw: pointer to hardware structure
+ *
+ *  This function reset hardware semaphore bits for a semaphore that may
+ *  have be left locked due to a catastrophic failure.
+ **/
+void ixgbe_init_swfw_sync_X540(struct ixgbe_hw *hw)
+{
+	/* First try to grab the semaphore but we don't need to bother
+	 * looking to see whether we got the lock or not since we do
+	 * the same thing regardless of whether we got the lock or not.
+	 * We got the lock - we release it.
+	 * We timeout trying to get the lock - we force its release.
+	 */
+	ixgbe_get_swfw_sync_semaphore(hw);
+	ixgbe_release_swfw_sync_semaphore(hw);
+}
+
+/**
  * ixgbe_blink_led_start_X540 - Blink LED based on index.
  * @hw: pointer to hardware structure
  * @index: led number to blink
@@ -854,6 +873,7 @@ static const struct ixgbe_mac_operations mac_ops_X540 = {
 	.set_vlan_anti_spoofing = &ixgbe_set_vlan_anti_spoofing,
 	.acquire_swfw_sync      = &ixgbe_acquire_swfw_sync_X540,
 	.release_swfw_sync      = &ixgbe_release_swfw_sync_X540,
+	.init_swfw_sync		= &ixgbe_init_swfw_sync_X540,
 	.disable_rx_buff	= &ixgbe_disable_rx_buff_generic,
 	.enable_rx_buff		= &ixgbe_enable_rx_buff_generic,
 	.get_thermal_sensor_data = NULL,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.h
index a1468b1..e21cd48 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.h
@@ -36,4 +36,5 @@ s32 ixgbe_blink_led_start_X540(struct ixgbe_hw *hw, u32 index);
 s32 ixgbe_blink_led_stop_X540(struct ixgbe_hw *hw, u32 index);
 s32 ixgbe_acquire_swfw_sync_X540(struct ixgbe_hw *hw, u32 mask);
 void ixgbe_release_swfw_sync_X540(struct ixgbe_hw *hw, u32 mask);
+void ixgbe_init_swfw_sync_X540(struct ixgbe_hw *hw);
 s32 ixgbe_init_eeprom_params_X540(struct ixgbe_hw *hw);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index 972c9aa..9d3f765 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -2432,6 +2432,7 @@ static const struct ixgbe_mac_operations mac_ops_X550 = {
 	.setup_sfp		= NULL,
 	.acquire_swfw_sync	= &ixgbe_acquire_swfw_sync_X540,
 	.release_swfw_sync	= &ixgbe_release_swfw_sync_X540,
+	.init_swfw_sync		= &ixgbe_init_swfw_sync_X540,
 	.prot_autoc_read	= prot_autoc_read_generic,
 	.prot_autoc_write	= prot_autoc_write_generic,
 	.setup_fc		= ixgbe_setup_fc_generic,
@@ -2449,6 +2450,7 @@ static const struct ixgbe_mac_operations mac_ops_X550EM_x = {
 	.setup_sfp		= ixgbe_setup_sfp_modules_X550em,
 	.acquire_swfw_sync	= &ixgbe_acquire_swfw_sync_X550em,
 	.release_swfw_sync	= &ixgbe_release_swfw_sync_X550em,
+	.init_swfw_sync		= &ixgbe_init_swfw_sync_X540,
 	.setup_fc		= NULL, /* defined later */
 };
 
-- 
2.5.5
