From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 1/2] ixgbe: Move the LED blink code to common,
	since 82599 also uses it
Date: Wed, 08 Apr 2009 16:20:31 -0700
Message-ID: <20090408232031.8781.83459.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.westchester.pa.mail.comcast.net ([76.96.62.56]:44508
	"EHLO QMTA06.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755371AbZDIHs5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2009 03:48:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>

The LED blink code is common for 82599 as well.  It should be moved to
ixgbe_common.c so both devices can use it, and not have it duplicated.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82598.c  |   59 +-------------------------------------
 drivers/net/ixgbe/ixgbe_82599.c  |   40 +-------------------------
 drivers/net/ixgbe/ixgbe_common.c |   55 +++++++++++++++++++++++++++++++++++
 drivers/net/ixgbe/ixgbe_common.h |    3 ++
 4 files changed, 62 insertions(+), 95 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index de4db0d..4791238 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -885,61 +885,6 @@ static s32 ixgbe_clear_vfta_82598(struct ixgbe_hw *hw)
 }
 
 /**
- *  ixgbe_blink_led_start_82598 - Blink LED based on index.
- *  @hw: pointer to hardware structure
- *  @index: led number to blink
- **/
-static s32 ixgbe_blink_led_start_82598(struct ixgbe_hw *hw, u32 index)
-{
-	ixgbe_link_speed speed = 0;
-	bool link_up = 0;
-	u32 autoc_reg = IXGBE_READ_REG(hw, IXGBE_AUTOC);
-	u32 led_reg = IXGBE_READ_REG(hw, IXGBE_LEDCTL);
-
-	/*
-	 * Link must be up to auto-blink the LEDs on the 82598EB MAC;
-	 * force it if link is down.
-	 */
-	hw->mac.ops.check_link(hw, &speed, &link_up, false);
-
-	if (!link_up) {
-		autoc_reg |= IXGBE_AUTOC_FLU;
-		IXGBE_WRITE_REG(hw, IXGBE_AUTOC, autoc_reg);
-		msleep(10);
-	}
-
-	led_reg &= ~IXGBE_LED_MODE_MASK(index);
-	led_reg |= IXGBE_LED_BLINK(index);
-	IXGBE_WRITE_REG(hw, IXGBE_LEDCTL, led_reg);
-	IXGBE_WRITE_FLUSH(hw);
-
-	return 0;
-}
-
-/**
- *  ixgbe_blink_led_stop_82598 - Stop blinking LED based on index.
- *  @hw: pointer to hardware structure
- *  @index: led number to stop blinking
- **/
-static s32 ixgbe_blink_led_stop_82598(struct ixgbe_hw *hw, u32 index)
-{
-	u32 autoc_reg = IXGBE_READ_REG(hw, IXGBE_AUTOC);
-	u32 led_reg = IXGBE_READ_REG(hw, IXGBE_LEDCTL);
-
-	autoc_reg &= ~IXGBE_AUTOC_FLU;
-	autoc_reg |= IXGBE_AUTOC_AN_RESTART;
-	IXGBE_WRITE_REG(hw, IXGBE_AUTOC, autoc_reg);
-
-	led_reg &= ~IXGBE_LED_MODE_MASK(index);
-	led_reg &= ~IXGBE_LED_BLINK(index);
-	led_reg |= IXGBE_LED_LINK_ACTIVE << IXGBE_LED_MODE_SHIFT(index);
-	IXGBE_WRITE_REG(hw, IXGBE_LEDCTL, led_reg);
-	IXGBE_WRITE_FLUSH(hw);
-
-	return 0;
-}
-
-/**
  *  ixgbe_read_analog_reg8_82598 - Reads 8 bit Atlas analog register
  *  @hw: pointer to hardware structure
  *  @reg: analog register to read
@@ -1128,8 +1073,8 @@ static struct ixgbe_mac_operations mac_ops_82598 = {
 	.get_link_capabilities	= &ixgbe_get_link_capabilities_82598,
 	.led_on			= &ixgbe_led_on_generic,
 	.led_off		= &ixgbe_led_off_generic,
-	.blink_led_start	= &ixgbe_blink_led_start_82598,
-	.blink_led_stop		= &ixgbe_blink_led_stop_82598,
+	.blink_led_start	= &ixgbe_blink_led_start_generic,
+	.blink_led_stop		= &ixgbe_blink_led_stop_generic,
 	.set_rar		= &ixgbe_set_rar_generic,
 	.clear_rar		= &ixgbe_clear_rar_generic,
 	.set_vmdq		= &ixgbe_set_vmdq_82598,
diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index beae7e0..29771fb 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -68,8 +68,6 @@ s32 ixgbe_clear_vmdq_82599(struct ixgbe_hw *hw, u32 rar, u32 vmdq);
 s32 ixgbe_set_vfta_82599(struct ixgbe_hw *hw, u32 vlan,
                          u32 vind, bool vlan_on);
 s32 ixgbe_clear_vfta_82599(struct ixgbe_hw *hw);
-s32 ixgbe_blink_led_stop_82599(struct ixgbe_hw *hw, u32 index);
-s32 ixgbe_blink_led_start_82599(struct ixgbe_hw *hw, u32 index);
 s32 ixgbe_init_uta_tables_82599(struct ixgbe_hw *hw);
 s32 ixgbe_read_analog_reg8_82599(struct ixgbe_hw *hw, u32 reg, u8 *val);
 s32 ixgbe_write_analog_reg8_82599(struct ixgbe_hw *hw, u32 reg, u8 val);
@@ -991,40 +989,6 @@ s32 ixgbe_clear_vfta_82599(struct ixgbe_hw *hw)
 }
 
 /**
- *  ixgbe_blink_led_start_82599 - Blink LED based on index.
- *  @hw: pointer to hardware structure
- *  @index: led number to blink
- **/
-s32 ixgbe_blink_led_start_82599(struct ixgbe_hw *hw, u32 index)
-{
-	u32 led_reg = IXGBE_READ_REG(hw, IXGBE_LEDCTL);
-
-	led_reg &= ~IXGBE_LED_MODE_MASK(index);
-	led_reg |= IXGBE_LED_BLINK(index);
-	IXGBE_WRITE_REG(hw, IXGBE_LEDCTL, led_reg);
-	IXGBE_WRITE_FLUSH(hw);
-
-	return 0;
-}
-
-/**
- *  ixgbe_blink_led_stop_82599 - Stop blinking LED based on index.
- *  @hw: pointer to hardware structure
- *  @index: led number to stop blinking
- **/
-s32 ixgbe_blink_led_stop_82599(struct ixgbe_hw *hw, u32 index)
-{
-	u32 led_reg = IXGBE_READ_REG(hw, IXGBE_LEDCTL);
-
-	led_reg &= ~IXGBE_LED_MODE_MASK(index);
-	led_reg &= ~IXGBE_LED_BLINK(index);
-	IXGBE_WRITE_REG(hw, IXGBE_LEDCTL, led_reg);
-	IXGBE_WRITE_FLUSH(hw);
-
-	return 0;
-}
-
-/**
  *  ixgbe_init_uta_tables_82599 - Initialize the Unicast Table Array
  *  @hw: pointer to hardware structure
  **/
@@ -1243,8 +1207,8 @@ static struct ixgbe_mac_operations mac_ops_82599 = {
 	.get_link_capabilities  = &ixgbe_get_link_capabilities_82599,
 	.led_on                 = &ixgbe_led_on_generic,
 	.led_off                = &ixgbe_led_off_generic,
-	.blink_led_start        = &ixgbe_blink_led_start_82599,
-	.blink_led_stop         = &ixgbe_blink_led_stop_82599,
+	.blink_led_start        = &ixgbe_blink_led_start_generic,
+	.blink_led_stop         = &ixgbe_blink_led_stop_generic,
 	.set_rar                = &ixgbe_set_rar_generic,
 	.clear_rar              = &ixgbe_clear_rar_generic,
 	.set_vmdq               = &ixgbe_set_vmdq_82599,
diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index 63ab667..5567519 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -2071,3 +2071,58 @@ s32 ixgbe_enable_rx_dma_generic(struct ixgbe_hw *hw, u32 regval)
 
 	return 0;
 }
+
+/**
+ *  ixgbe_blink_led_start_generic - Blink LED based on index.
+ *  @hw: pointer to hardware structure
+ *  @index: led number to blink
+ **/
+s32 ixgbe_blink_led_start_generic(struct ixgbe_hw *hw, u32 index)
+{
+	ixgbe_link_speed speed = 0;
+	bool link_up = 0;
+	u32 autoc_reg = IXGBE_READ_REG(hw, IXGBE_AUTOC);
+	u32 led_reg = IXGBE_READ_REG(hw, IXGBE_LEDCTL);
+
+	/*
+	 * Link must be up to auto-blink the LEDs;
+	 * Force it if link is down.
+	 */
+	hw->mac.ops.check_link(hw, &speed, &link_up, false);
+
+	if (!link_up) {
+		autoc_reg |= IXGBE_AUTOC_FLU;
+		IXGBE_WRITE_REG(hw, IXGBE_AUTOC, autoc_reg);
+		msleep(10);
+	}
+
+	led_reg &= ~IXGBE_LED_MODE_MASK(index);
+	led_reg |= IXGBE_LED_BLINK(index);
+	IXGBE_WRITE_REG(hw, IXGBE_LEDCTL, led_reg);
+	IXGBE_WRITE_FLUSH(hw);
+
+	return 0;
+}
+
+/**
+ *  ixgbe_blink_led_stop_generic - Stop blinking LED based on index.
+ *  @hw: pointer to hardware structure
+ *  @index: led number to stop blinking
+ **/
+s32 ixgbe_blink_led_stop_generic(struct ixgbe_hw *hw, u32 index)
+{
+	u32 autoc_reg = IXGBE_READ_REG(hw, IXGBE_AUTOC);
+	u32 led_reg = IXGBE_READ_REG(hw, IXGBE_LEDCTL);
+
+	autoc_reg &= ~IXGBE_AUTOC_FLU;
+	autoc_reg |= IXGBE_AUTOC_AN_RESTART;
+	IXGBE_WRITE_REG(hw, IXGBE_AUTOC, autoc_reg);
+
+	led_reg &= ~IXGBE_LED_MODE_MASK(index);
+	led_reg &= ~IXGBE_LED_BLINK(index);
+	led_reg |= IXGBE_LED_LINK_ACTIVE << IXGBE_LED_MODE_SHIFT(index);
+	IXGBE_WRITE_REG(hw, IXGBE_LEDCTL, led_reg);
+	IXGBE_WRITE_FLUSH(hw);
+
+	return 0;
+}
diff --git a/drivers/net/ixgbe/ixgbe_common.h b/drivers/net/ixgbe/ixgbe_common.h
index 24f73e7..dd26089 100644
--- a/drivers/net/ixgbe/ixgbe_common.h
+++ b/drivers/net/ixgbe/ixgbe_common.h
@@ -76,6 +76,9 @@ s32 ixgbe_disable_pcie_master(struct ixgbe_hw *hw);
 s32 ixgbe_read_analog_reg8_generic(struct ixgbe_hw *hw, u32 reg, u8 *val);
 s32 ixgbe_write_analog_reg8_generic(struct ixgbe_hw *hw, u32 reg, u8 val);
 
+s32 ixgbe_blink_led_start_generic(struct ixgbe_hw *hw, u32 index);
+s32 ixgbe_blink_led_stop_generic(struct ixgbe_hw *hw, u32 index);
+
 #define IXGBE_WRITE_REG(a, reg, value) writel((value), ((a)->hw_addr + (reg)))
 
 #ifndef writeq

