From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next-2.6 05/12] e1000e: implement ethtool set_phys_id
Date: Mon, 04 Apr 2011 11:43:45 -0700
Message-ID: <20110404184501.732239902@linuxplumber.net>
References: <20110404184340.604594357@linuxplumber.net>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce A
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:52817 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755186Ab1DDSvJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2011 14:51:09 -0400
Content-Disposition: inline; filename=e1000e-phys-id.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The new ethtool set_phys_id takes over controlling the LED for identifying
boards. This fixes the lockout during that period.
For this device lots of extra infrastructure can also be removed by using
set_phys_id.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/e1000e/e1000.h	2011-04-04 10:48:18.801583226 -0700
+++ b/drivers/net/e1000e/e1000.h	2011-04-04 10:49:31.254596880 -0700
@@ -389,13 +389,10 @@ struct e1000_adapter {
 
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
@@ -484,7 +481,6 @@ extern const char e1000e_driver_version[
 
 extern void e1000e_check_options(struct e1000_adapter *adapter);
 extern void e1000e_set_ethtool_ops(struct net_device *netdev);
-extern void e1000e_led_blink_task(struct work_struct *work);
 
 extern int e1000e_up(struct e1000_adapter *adapter);
 extern void e1000e_down(struct e1000_adapter *adapter);
--- a/drivers/net/e1000e/ethtool.c	2011-04-04 10:48:18.789583047 -0700
+++ b/drivers/net/e1000e/ethtool.c	2011-04-04 10:49:48.798839237 -0700
@@ -1851,64 +1851,39 @@ static int e1000_set_wol(struct net_devi
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
+		if ((hw->phy.type == e1000_phy_ife) ||
+		    (hw->mac.type == e1000_pchlan) ||
+		    (hw->mac.type == e1000_pch2lan) ||
+		    (hw->mac.type == e1000_82583) ||
+		    (hw->mac.type == e1000_82574))
+			return -EINVAL;	/* blink in software */
 
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
+		e1000e_blink_led(hw);
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
 
@@ -2049,7 +2024,7 @@ static const struct ethtool_ops e1000_et
 	.set_tso		= e1000_set_tso,
 	.self_test		= e1000_diag_test,
 	.get_strings		= e1000_get_strings,
-	.phys_id		= e1000_phys_id,
+	.set_phys_id		= e1000_set_phys_id,
 	.get_ethtool_stats	= e1000_get_ethtool_stats,
 	.get_sset_count		= e1000e_get_sset_count,
 	.get_coalesce		= e1000_get_coalesce,
--- a/drivers/net/e1000e/netdev.c	2011-04-04 10:48:18.821583507 -0700
+++ b/drivers/net/e1000e/netdev.c	2011-04-04 10:49:31.258596933 -0700
@@ -5991,7 +5991,6 @@ static int __devinit e1000_probe(struct
 	INIT_WORK(&adapter->downshift_task, e1000e_downshift_workaround);
 	INIT_WORK(&adapter->update_phy_task, e1000e_update_phy_task);
 	INIT_WORK(&adapter->print_hang_task, e1000_print_hw_hang);
-	INIT_WORK(&adapter->led_blink_task, e1000e_led_blink_task);
 
 	/* Initialize link parameters. User can change them with ethtool */
 	adapter->hw.mac.autoneg = 1;
@@ -6124,7 +6123,6 @@ static void __devexit e1000_remove(struc
 	cancel_work_sync(&adapter->watchdog_task);
 	cancel_work_sync(&adapter->downshift_task);
 	cancel_work_sync(&adapter->update_phy_task);
-	cancel_work_sync(&adapter->led_blink_task);
 	cancel_work_sync(&adapter->print_hang_task);
 
 	if (!(netdev->flags & IFF_UP))


