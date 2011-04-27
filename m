From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 01/12] e1000e: implement ethtool set_phys_id
Date: Wed, 27 Apr 2011 02:34:40 -0700
Message-ID: <1303896891-16006-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1303896891-16006-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:14485 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755983Ab1D0Je6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Apr 2011 05:34:58 -0400
In-Reply-To: <1303896891-16006-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Based on a patch from Stephen Hemminger <shemminger@vyatta.com>.

The new ethtool set_phys_id takes over controlling the LED for
identifying boards.  This fixes the lockout during that period.
For this device lots of extra infrastructure can also be removed by
using set_phys_id.

v2: - return blink frequency for parts that do not support blink in h/w
    - add blink_led function pointers for devices that do support blink
      in h/w to cleanup the test for this functionality

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/82571.c   |    2 +
 drivers/net/e1000e/e1000.h   |    6 +---
 drivers/net/e1000e/es2lan.c  |    1 +
 drivers/net/e1000e/ethtool.c |   71 ++++++++++++-----------------------------
 drivers/net/e1000e/hw.h      |    1 +
 drivers/net/e1000e/ich8lan.c |    4 ++
 drivers/net/e1000e/lib.c     |    4 +-
 drivers/net/e1000e/netdev.c  |    2 -
 8 files changed, 32 insertions(+), 59 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index ae07d37..8295f21 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -300,6 +300,7 @@ static s32 e1000_init_mac_params_82571(struct e1000_adapter *adapter)
 		func->set_lan_id = e1000_set_lan_id_single_port;
 		func->check_mng_mode = e1000e_check_mng_mode_generic;
 		func->led_on = e1000e_led_on_generic;
+		func->blink_led = e1000e_blink_led_generic;
 
 		/* FWSM register */
 		mac->has_fwsm = true;
@@ -320,6 +321,7 @@ static s32 e1000_init_mac_params_82571(struct e1000_adapter *adapter)
 	default:
 		func->check_mng_mode = e1000e_check_mng_mode_generic;
 		func->led_on = e1000e_led_on_generic;
+		func->blink_led = e1000e_blink_led_generic;
 
 		/* FWSM register */
 		mac->has_fwsm = true;
diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index 3be5478..9549879 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -391,13 +391,10 @@ struct e1000_adapter {
 
 	bool fc_autoneg;
 
-	unsigned long led_status;
-
 	unsigned int flags;
 	unsigned int flags2;
 	struct work_struct downshift_task;
 	struct work_struct update_phy_task;
-	struct work_struct led_blink_task;
 	struct work_struct print_hang_task;
 
 	bool idle_check;
@@ -487,7 +484,6 @@ extern const char e1000e_driver_version[];
 
 extern void e1000e_check_options(struct e1000_adapter *adapter);
 extern void e1000e_set_ethtool_ops(struct net_device *netdev);
-extern void e1000e_led_blink_task(struct work_struct *work);
 
 extern int e1000e_up(struct e1000_adapter *adapter);
 extern void e1000e_down(struct e1000_adapter *adapter);
@@ -575,7 +571,7 @@ extern s32 e1000e_valid_led_default(struct e1000_hw *hw, u16 *data);
 extern void e1000e_config_collision_dist(struct e1000_hw *hw);
 extern s32 e1000e_config_fc_after_link_up(struct e1000_hw *hw);
 extern s32 e1000e_force_mac_fc(struct e1000_hw *hw);
-extern s32 e1000e_blink_led(struct e1000_hw *hw);
+extern s32 e1000e_blink_led_generic(struct e1000_hw *hw);
 extern void e1000_write_vfta_generic(struct e1000_hw *hw, u32 offset, u32 value);
 extern s32 e1000_check_alt_mac_addr_generic(struct e1000_hw *hw);
 extern void e1000e_reset_adaptive(struct e1000_hw *hw);
diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/e1000e/es2lan.c
index 0279695..f4bbeb2 100644
--- a/drivers/net/e1000e/es2lan.c
+++ b/drivers/net/e1000e/es2lan.c
@@ -1434,6 +1434,7 @@ static void e1000_clear_hw_cntrs_80003es2lan(struct e1000_hw *hw)
 static struct e1000_mac_operations es2_mac_ops = {
 	.read_mac_addr		= e1000_read_mac_addr_80003es2lan,
 	.id_led_init		= e1000e_id_led_init,
+	.blink_led		= e1000e_blink_led_generic,
 	.check_mng_mode		= e1000e_check_mng_mode_generic,
 	/* check_for_link dependent on media type */
 	.cleanup_led		= e1000e_cleanup_led_generic,
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index a31d280..1d7bf40 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -1851,64 +1851,35 @@ static int e1000_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
 	return 0;
 }
 
-/* toggle LED 4 times per second = 2 "blinks" per second */
-#define E1000_ID_INTERVAL	(HZ/4)
-
-/* bit defines for adapter->led_status */
-#define E1000_LED_ON		0
-
-void e1000e_led_blink_task(struct work_struct *work)
-{
-	struct e1000_adapter *adapter = container_of(work,
-	                                struct e1000_adapter, led_blink_task);
-
-	if (test_and_change_bit(E1000_LED_ON, &adapter->led_status))
-		adapter->hw.mac.ops.led_off(&adapter->hw);
-	else
-		adapter->hw.mac.ops.led_on(&adapter->hw);
-}
-
-static void e1000_led_blink_callback(unsigned long data)
-{
-	struct e1000_adapter *adapter = (struct e1000_adapter *) data;
-
-	schedule_work(&adapter->led_blink_task);
-	mod_timer(&adapter->blink_timer, jiffies + E1000_ID_INTERVAL);
-}
-
-static int e1000_phys_id(struct net_device *netdev, u32 data)
+static int e1000_set_phys_id(struct net_device *netdev,
+			     enum ethtool_phys_id_state state)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 
-	if (!data)
-		data = INT_MAX;
+	switch (state) {
+	case ETHTOOL_ID_ACTIVE:
+		if (!hw->mac.ops.blink_led)
+			return 2;	/* cycle on/off twice per second */
 
-	if ((hw->phy.type == e1000_phy_ife) ||
-	    (hw->mac.type == e1000_pchlan) ||
-	    (hw->mac.type == e1000_pch2lan) ||
-	    (hw->mac.type == e1000_82583) ||
-	    (hw->mac.type == e1000_82574)) {
-		if (!adapter->blink_timer.function) {
-			init_timer(&adapter->blink_timer);
-			adapter->blink_timer.function =
-				e1000_led_blink_callback;
-			adapter->blink_timer.data = (unsigned long) adapter;
-		}
-		mod_timer(&adapter->blink_timer, jiffies);
-		msleep_interruptible(data * 1000);
-		del_timer_sync(&adapter->blink_timer);
+		hw->mac.ops.blink_led(hw);
+		break;
+
+	case ETHTOOL_ID_INACTIVE:
 		if (hw->phy.type == e1000_phy_ife)
 			e1e_wphy(hw, IFE_PHY_SPECIAL_CONTROL_LED, 0);
-	} else {
-		e1000e_blink_led(hw);
-		msleep_interruptible(data * 1000);
-	}
+		hw->mac.ops.led_off(hw);
+		hw->mac.ops.cleanup_led(hw);
+		break;
 
-	hw->mac.ops.led_off(hw);
-	clear_bit(E1000_LED_ON, &adapter->led_status);
-	hw->mac.ops.cleanup_led(hw);
+	case ETHTOOL_ID_ON:
+		adapter->hw.mac.ops.led_on(&adapter->hw);
+		break;
 
+	case ETHTOOL_ID_OFF:
+		adapter->hw.mac.ops.led_off(&adapter->hw);
+		break;
+	}
 	return 0;
 }
 
@@ -2074,7 +2045,7 @@ static const struct ethtool_ops e1000_ethtool_ops = {
 	.set_tso		= e1000_set_tso,
 	.self_test		= e1000_diag_test,
 	.get_strings		= e1000_get_strings,
-	.phys_id		= e1000_phys_id,
+	.set_phys_id		= e1000_set_phys_id,
 	.get_ethtool_stats	= e1000_get_ethtool_stats,
 	.get_sset_count		= e1000e_get_sset_count,
 	.get_coalesce		= e1000_get_coalesce,
diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index 307e1ec..6c2fa83 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -756,6 +756,7 @@ struct e1000_host_mng_command_info {
 /* Function pointers and static data for the MAC. */
 struct e1000_mac_operations {
 	s32  (*id_led_init)(struct e1000_hw *);
+	s32  (*blink_led)(struct e1000_hw *);
 	bool (*check_mng_mode)(struct e1000_hw *);
 	s32  (*check_for_link)(struct e1000_hw *);
 	s32  (*cleanup_led)(struct e1000_hw *);
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 06ff884..3369d1f 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -564,6 +564,8 @@ static s32 e1000_init_mac_params_ich8lan(struct e1000_adapter *adapter)
 		mac->ops.check_mng_mode = e1000_check_mng_mode_ich8lan;
 		/* ID LED init */
 		mac->ops.id_led_init = e1000e_id_led_init;
+		/* blink LED */
+		mac->ops.blink_led = e1000e_blink_led_generic;
 		/* setup LED */
 		mac->ops.setup_led = e1000e_setup_led_generic;
 		/* cleanup LED */
@@ -767,6 +769,8 @@ static s32 e1000_get_variants_ich8lan(struct e1000_adapter *adapter)
 	     (!(er32(CTRL_EXT) & E1000_CTRL_EXT_LSECCK)))) {
 		adapter->flags &= ~FLAG_HAS_JUMBO_FRAMES;
 		adapter->max_hw_frame_size = ETH_FRAME_LEN + ETH_FCS_LEN;
+
+		hw->mac.ops.blink_led = NULL;
 	}
 
 	if ((adapter->hw.mac.type == e1000_ich8lan) &&
diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index 30ef8fa..6432dda 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -1530,12 +1530,12 @@ s32 e1000e_cleanup_led_generic(struct e1000_hw *hw)
 }
 
 /**
- *  e1000e_blink_led - Blink LED
+ *  e1000e_blink_led_generic - Blink LED
  *  @hw: pointer to the HW structure
  *
  *  Blink the LEDs which are set to be on.
  **/
-s32 e1000e_blink_led(struct e1000_hw *hw)
+s32 e1000e_blink_led_generic(struct e1000_hw *hw)
 {
 	u32 ledctl_blink = 0;
 	u32 i;
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 4deb67d..0939040 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -6020,7 +6020,6 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	INIT_WORK(&adapter->downshift_task, e1000e_downshift_workaround);
 	INIT_WORK(&adapter->update_phy_task, e1000e_update_phy_task);
 	INIT_WORK(&adapter->print_hang_task, e1000_print_hw_hang);
-	INIT_WORK(&adapter->led_blink_task, e1000e_led_blink_task);
 
 	/* Initialize link parameters. User can change them with ethtool */
 	adapter->hw.mac.autoneg = 1;
@@ -6153,7 +6152,6 @@ static void __devexit e1000_remove(struct pci_dev *pdev)
 	cancel_work_sync(&adapter->watchdog_task);
 	cancel_work_sync(&adapter->downshift_task);
 	cancel_work_sync(&adapter->update_phy_task);
-	cancel_work_sync(&adapter->led_blink_task);
 	cancel_work_sync(&adapter->print_hang_task);
 
 	if (!(netdev->flags & IFF_UP))
-- 
1.7.4.4

