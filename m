From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/14] ixgbevf: Correct parameter sent to LED function
Date: Fri, 22 Jul 2016 23:49:39 -0700
Message-ID: <1469256591-109822-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1469256591-109822-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	guru.anbalagane@oracle.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:62671 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751003AbcGWGuJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jul 2016 02:50:09 -0400
In-Reply-To: <1469256591-109822-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

The second parameter of these functions is the index to the led we
are interested in affecting.  However we were mistakenly passing
the offset in the register.  This patch corrects that and adds some
bonds checking which would hopefully make bugs like this more noticeable
in the future.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c  | 12 ++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |  4 ++--
 2 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index 902d206..0ffba44 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -763,6 +763,9 @@ s32 ixgbe_led_on_generic(struct ixgbe_hw *hw, u32 index)
 {
 	u32 led_reg = IXGBE_READ_REG(hw, IXGBE_LEDCTL);
 
+	if (index > 3)
+		return IXGBE_ERR_PARAM;
+
 	/* To turn on the LED, set mode to ON. */
 	led_reg &= ~IXGBE_LED_MODE_MASK(index);
 	led_reg |= IXGBE_LED_ON << IXGBE_LED_MODE_SHIFT(index);
@@ -781,6 +784,9 @@ s32 ixgbe_led_off_generic(struct ixgbe_hw *hw, u32 index)
 {
 	u32 led_reg = IXGBE_READ_REG(hw, IXGBE_LEDCTL);
 
+	if (index > 3)
+		return IXGBE_ERR_PARAM;
+
 	/* To turn off the LED, set mode to OFF. */
 	led_reg &= ~IXGBE_LED_MODE_MASK(index);
 	led_reg |= IXGBE_LED_OFF << IXGBE_LED_MODE_SHIFT(index);
@@ -2698,6 +2704,9 @@ s32 ixgbe_blink_led_start_generic(struct ixgbe_hw *hw, u32 index)
 	bool locked = false;
 	s32 ret_val;
 
+	if (index > 3)
+		return IXGBE_ERR_PARAM;
+
 	/*
 	 * Link must be up to auto-blink the LEDs;
 	 * Force it if link is down.
@@ -2741,6 +2750,9 @@ s32 ixgbe_blink_led_stop_generic(struct ixgbe_hw *hw, u32 index)
 	bool locked = false;
 	s32 ret_val;
 
+	if (index > 3)
+		return IXGBE_ERR_PARAM;
+
 	ret_val = hw->mac.ops.prot_autoc_read(hw, &locked, &autoc_reg);
 	if (ret_val)
 		return ret_val;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 8a84507..0d7209e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -2204,11 +2204,11 @@ static int ixgbe_set_phys_id(struct net_device *netdev,
 		return 2;
 
 	case ETHTOOL_ID_ON:
-		hw->mac.ops.led_on(hw, IXGBE_LED_ON);
+		hw->mac.ops.led_on(hw, hw->bus.func);
 		break;
 
 	case ETHTOOL_ID_OFF:
-		hw->mac.ops.led_off(hw, IXGBE_LED_ON);
+		hw->mac.ops.led_off(hw, hw->bus.func);
 		break;
 
 	case ETHTOOL_ID_INACTIVE:
-- 
2.5.5
