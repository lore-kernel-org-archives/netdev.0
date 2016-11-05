From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/15] ixgbe: Add support to retrieve and store LED link active
Date: Sat,  5 Nov 2016 00:54:08 -0700
Message-ID: <1478332461-43147-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1478332461-43147-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:56205 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752877AbcKEHyY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 5 Nov 2016 03:54:24 -0400
In-Reply-To: <1478332461-43147-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

This patch adds support to get the LED link active via the LEDCTL
register.  If the LEDCTL register does not have LED link active
(LED mode field = 0x0100) set then default LED link active returned.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c   |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c   |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c  | 46 ++++++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h  |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |  4 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h    |  2 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c    |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c    |  3 ++
 8 files changed, 57 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
index fb51be7..506e346 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
@@ -1179,6 +1179,7 @@ static const struct ixgbe_mac_operations mac_ops_82598 = {
 	.get_link_capabilities	= &ixgbe_get_link_capabilities_82598,
 	.led_on			= &ixgbe_led_on_generic,
 	.led_off		= &ixgbe_led_off_generic,
+	.init_led_link_act	= ixgbe_init_led_link_act_generic,
 	.blink_led_start	= &ixgbe_blink_led_start_generic,
 	.blink_led_stop		= &ixgbe_blink_led_stop_generic,
 	.set_rar		= &ixgbe_set_rar_generic,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
index 63b2500..1c1076b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
@@ -2204,6 +2204,7 @@ static const struct ixgbe_mac_operations mac_ops_82599 = {
 	.get_link_capabilities  = &ixgbe_get_link_capabilities_82599,
 	.led_on                 = &ixgbe_led_on_generic,
 	.led_off                = &ixgbe_led_off_generic,
+	.init_led_link_act	= ixgbe_init_led_link_act_generic,
 	.blink_led_start        = &ixgbe_blink_led_start_generic,
 	.blink_led_stop         = &ixgbe_blink_led_stop_generic,
 	.set_rar                = &ixgbe_set_rar_generic,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index 77d3039..f7600dd 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -390,6 +390,9 @@ s32 ixgbe_init_hw_generic(struct ixgbe_hw *hw)
 		status = hw->mac.ops.start_hw(hw);
 	}
 
+	/* Initialize the LED link active for LED blink support */
+	hw->mac.ops.init_led_link_act(hw);
+
 	return status;
 }
 
@@ -773,6 +776,49 @@ s32 ixgbe_stop_adapter_generic(struct ixgbe_hw *hw)
 }
 
 /**
+ *  ixgbe_init_led_link_act_generic - Store the LED index link/activity.
+ *  @hw: pointer to hardware structure
+ *
+ *  Store the index for the link active LED. This will be used to support
+ *  blinking the LED.
+ **/
+s32 ixgbe_init_led_link_act_generic(struct ixgbe_hw *hw)
+{
+	struct ixgbe_mac_info *mac = &hw->mac;
+	u32 led_reg, led_mode;
+	u16 i;
+
+	led_reg = IXGBE_READ_REG(hw, IXGBE_LEDCTL);
+
+	/* Get LED link active from the LEDCTL register */
+	for (i = 0; i < 4; i++) {
+		led_mode = led_reg >> IXGBE_LED_MODE_SHIFT(i);
+
+		if ((led_mode & IXGBE_LED_MODE_MASK_BASE) ==
+		    IXGBE_LED_LINK_ACTIVE) {
+			mac->led_link_act = i;
+			return 0;
+		}
+	}
+
+	/* If LEDCTL register does not have the LED link active set, then use
+	 * known MAC defaults.
+	 */
+	switch (hw->mac.type) {
+	case ixgbe_mac_x550em_a:
+		mac->led_link_act = 0;
+		break;
+	case ixgbe_mac_X550EM_x:
+		mac->led_link_act = 1;
+		break;
+	default:
+		mac->led_link_act = 2;
+	}
+
+	return 0;
+}
+
+/**
  *  ixgbe_led_on_generic - Turns on the software controllable LEDs.
  *  @hw: pointer to hardware structure
  *  @index: led number to turn on
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
index 6d4c260..5b3e3c6 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
@@ -49,6 +49,7 @@ s32 ixgbe_stop_adapter_generic(struct ixgbe_hw *hw);
 
 s32 ixgbe_led_on_generic(struct ixgbe_hw *hw, u32 index);
 s32 ixgbe_led_off_generic(struct ixgbe_hw *hw, u32 index);
+s32 ixgbe_init_led_link_act_generic(struct ixgbe_hw *hw);
 
 s32 ixgbe_init_eeprom_params_generic(struct ixgbe_hw *hw);
 s32 ixgbe_write_eeprom_generic(struct ixgbe_hw *hw, u16 offset, u16 data);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index f49f803..fd192bf 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -2225,11 +2225,11 @@ static int ixgbe_set_phys_id(struct net_device *netdev,
 		return 2;
 
 	case ETHTOOL_ID_ON:
-		hw->mac.ops.led_on(hw, hw->bus.func);
+		hw->mac.ops.led_on(hw, hw->mac.led_link_act);
 		break;
 
 	case ETHTOOL_ID_OFF:
-		hw->mac.ops.led_off(hw, hw->bus.func);
+		hw->mac.ops.led_off(hw, hw->mac.led_link_act);
 		break;
 
 	case ETHTOOL_ID_INACTIVE:
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index 31d82e3..82813f9 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -3352,6 +3352,7 @@ struct ixgbe_mac_operations {
 	s32 (*led_off)(struct ixgbe_hw *, u32);
 	s32 (*blink_led_start)(struct ixgbe_hw *, u32);
 	s32 (*blink_led_stop)(struct ixgbe_hw *, u32);
+	s32 (*init_led_link_act)(struct ixgbe_hw *);
 
 	/* RAR, Multicast, VLAN */
 	s32 (*set_rar)(struct ixgbe_hw *, u32, u8 *, u32, u32);
@@ -3462,6 +3463,7 @@ struct ixgbe_mac_info {
 	u8				san_mac_rar_index;
 	struct ixgbe_thermal_sensor_data  thermal_sensor_data;
 	bool				set_lben;
+	u8				led_link_act;
 };
 
 struct ixgbe_phy_info {
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
index f2b1d48..5bf1d49 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
@@ -851,6 +851,7 @@ static const struct ixgbe_mac_operations mac_ops_X540 = {
 	.get_link_capabilities  = &ixgbe_get_copper_link_capabilities_generic,
 	.led_on                 = &ixgbe_led_on_generic,
 	.led_off                = &ixgbe_led_off_generic,
+	.init_led_link_act	= ixgbe_init_led_link_act_generic,
 	.blink_led_start        = &ixgbe_blink_led_start_X540,
 	.blink_led_stop         = &ixgbe_blink_led_stop_X540,
 	.set_rar                = &ixgbe_set_rar_generic,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index 3e3458e..f4385fc 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -2952,6 +2952,7 @@ static const struct ixgbe_mac_operations mac_ops_X550 = {
 	X550_COMMON_MAC
 	.led_on			= ixgbe_led_on_generic,
 	.led_off		= ixgbe_led_off_generic,
+	.init_led_link_act	= ixgbe_init_led_link_act_generic,
 	.reset_hw		= &ixgbe_reset_hw_X540,
 	.get_media_type		= &ixgbe_get_media_type_X540,
 	.get_san_mac_addr	= &ixgbe_get_san_mac_addr_generic,
@@ -2972,6 +2973,7 @@ static const struct ixgbe_mac_operations mac_ops_X550EM_x = {
 	X550_COMMON_MAC
 	.led_on			= ixgbe_led_on_t_x550em,
 	.led_off		= ixgbe_led_off_t_x550em,
+	.init_led_link_act	= ixgbe_init_led_link_act_generic,
 	.reset_hw		= &ixgbe_reset_hw_X550em,
 	.get_media_type		= &ixgbe_get_media_type_X550em,
 	.get_san_mac_addr	= NULL,
@@ -2992,6 +2994,7 @@ static struct ixgbe_mac_operations mac_ops_x550em_a = {
 	X550_COMMON_MAC
 	.led_on			= ixgbe_led_on_t_x550em,
 	.led_off		= ixgbe_led_off_t_x550em,
+	.init_led_link_act	= ixgbe_init_led_link_act_generic,
 	.reset_hw		= ixgbe_reset_hw_X550em,
 	.get_media_type		= ixgbe_get_media_type_X550em,
 	.get_san_mac_addr	= NULL,
-- 
2.7.4
