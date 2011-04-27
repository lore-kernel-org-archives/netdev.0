From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 05/12] ixgbe: add LED blink code for x540
Date: Wed, 27 Apr 2011 02:34:44 -0700
Message-ID: <1303896891-16006-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1303896891-16006-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:63274 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756000Ab1D0Je7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Apr 2011 05:34:59 -0400
In-Reply-To: <1303896891-16006-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Implement blink_led_start and blink_led_stop functions for x540
using the MACC register.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Evan Swanson <evan.swanson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_x540.c |   64 ++++++++++++++++++++++++++++++++++++++-
 1 files changed, 62 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_x540.c b/drivers/net/ixgbe/ixgbe_x540.c
index 932394f..75c6465 100644
--- a/drivers/net/ixgbe/ixgbe_x540.c
+++ b/drivers/net/ixgbe/ixgbe_x540.c
@@ -744,6 +744,66 @@ static void ixgbe_release_swfw_sync_semaphore(struct ixgbe_hw *hw)
 	IXGBE_WRITE_FLUSH(hw);
 }
 
+/**
+ * ixgbe_blink_led_start_X540 - Blink LED based on index.
+ * @hw: pointer to hardware structure
+ * @index: led number to blink
+ *
+ * Devices that implement the version 2 interface:
+ *   X540
+ **/
+static s32 ixgbe_blink_led_start_X540(struct ixgbe_hw *hw, u32 index)
+{
+	u32 macc_reg;
+	u32 ledctl_reg;
+
+	/*
+	 * In order for the blink bit in the LED control register
+	 * to work, link and speed must be forced in the MAC. We
+	 * will reverse this when we stop the blinking.
+	 */
+	macc_reg = IXGBE_READ_REG(hw, IXGBE_MACC);
+	macc_reg |= IXGBE_MACC_FLU | IXGBE_MACC_FSV_10G | IXGBE_MACC_FS;
+	IXGBE_WRITE_REG(hw, IXGBE_MACC, macc_reg);
+
+	/* Set the LED to LINK_UP + BLINK. */
+	ledctl_reg = IXGBE_READ_REG(hw, IXGBE_LEDCTL);
+	ledctl_reg &= ~IXGBE_LED_MODE_MASK(index);
+	ledctl_reg |= IXGBE_LED_BLINK(index);
+	IXGBE_WRITE_REG(hw, IXGBE_LEDCTL, ledctl_reg);
+	IXGBE_WRITE_FLUSH(hw);
+
+	return 0;
+}
+
+/**
+ * ixgbe_blink_led_stop_X540 - Stop blinking LED based on index.
+ * @hw: pointer to hardware structure
+ * @index: led number to stop blinking
+ *
+ * Devices that implement the version 2 interface:
+ *   X540
+ **/
+static s32 ixgbe_blink_led_stop_X540(struct ixgbe_hw *hw, u32 index)
+{
+	u32 macc_reg;
+	u32 ledctl_reg;
+
+	/* Restore the LED to its default value. */
+	ledctl_reg = IXGBE_READ_REG(hw, IXGBE_LEDCTL);
+	ledctl_reg &= ~IXGBE_LED_MODE_MASK(index);
+	ledctl_reg |= IXGBE_LED_LINK_ACTIVE << IXGBE_LED_MODE_SHIFT(index);
+	ledctl_reg &= ~IXGBE_LED_BLINK(index);
+	IXGBE_WRITE_REG(hw, IXGBE_LEDCTL, ledctl_reg);
+
+	/* Unforce link and speed in the MAC. */
+	macc_reg = IXGBE_READ_REG(hw, IXGBE_MACC);
+	macc_reg &= ~(IXGBE_MACC_FLU | IXGBE_MACC_FSV_10G | IXGBE_MACC_FS);
+	IXGBE_WRITE_REG(hw, IXGBE_MACC, macc_reg);
+	IXGBE_WRITE_FLUSH(hw);
+
+	return 0;
+}
 static struct ixgbe_mac_operations mac_ops_X540 = {
 	.init_hw                = &ixgbe_init_hw_generic,
 	.reset_hw               = &ixgbe_reset_hw_X540,
@@ -767,8 +827,8 @@ static struct ixgbe_mac_operations mac_ops_X540 = {
 	.get_link_capabilities  = &ixgbe_get_copper_link_capabilities_generic,
 	.led_on                 = &ixgbe_led_on_generic,
 	.led_off                = &ixgbe_led_off_generic,
-	.blink_led_start        = &ixgbe_blink_led_start_generic,
-	.blink_led_stop         = &ixgbe_blink_led_stop_generic,
+	.blink_led_start        = &ixgbe_blink_led_start_X540,
+	.blink_led_stop         = &ixgbe_blink_led_stop_X540,
 	.set_rar                = &ixgbe_set_rar_generic,
 	.clear_rar              = &ixgbe_clear_rar_generic,
 	.set_vmdq               = &ixgbe_set_vmdq_generic,
-- 
1.7.4.4

