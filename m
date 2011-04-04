From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next-2.6 03/12] e100: implemenet set_phys_id
Date: Mon, 04 Apr 2011 11:43:43 -0700
Message-ID: <20110404184501.541503577@linuxplumber.net>
References: <20110404184340.604594357@linuxplumber.net>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce A
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:52797 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755146Ab1DDSvG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2011 14:51:06 -0400
Content-Disposition: inline; filename=e100-set-phys-id.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement set_phys_id to control LED. 
Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/e100.c	2011-04-04 10:51:19.340063286 -0700
+++ b/drivers/net/e100.c	2011-04-04 11:04:55.117587486 -0700
@@ -593,7 +593,6 @@ struct nic {
 	enum phy phy;
 	struct params params;
 	struct timer_list watchdog;
-	struct timer_list blink_timer;
 	struct mii_if_info mii;
 	struct work_struct tx_timeout_task;
 	enum loopback loopback;
@@ -618,7 +617,6 @@ struct nic {
 	u32 rx_tco_frames;
 	u32 rx_over_length_errors;
 
-	u16 leds;
 	u16 eeprom_wc;
 	__le16 eeprom[256];
 	spinlock_t mdio_lock;
@@ -2351,30 +2349,6 @@ err_clean_rx:
 #define E100_82552_LED_OVERRIDE 0x19
 #define E100_82552_LED_ON       0x000F /* LEDTX and LED_RX both on */
 #define E100_82552_LED_OFF      0x000A /* LEDTX and LED_RX both off */
-static void e100_blink_led(unsigned long data)
-{
-	struct nic *nic = (struct nic *)data;
-	enum led_state {
-		led_on     = 0x01,
-		led_off    = 0x04,
-		led_on_559 = 0x05,
-		led_on_557 = 0x07,
-	};
-	u16 led_reg = MII_LED_CONTROL;
-
-	if (nic->phy == phy_82552_v) {
-		led_reg = E100_82552_LED_OVERRIDE;
-
-		nic->leds = (nic->leds == E100_82552_LED_ON) ?
-		            E100_82552_LED_OFF : E100_82552_LED_ON;
-	} else {
-		nic->leds = (nic->leds & led_on) ? led_off :
-		            (nic->mac < mac_82559_D101M) ? led_on_557 :
-		            led_on_559;
-	}
-	mdio_write(nic->netdev, nic->mii.phy_id, led_reg, nic->leds);
-	mod_timer(&nic->blink_timer, jiffies + HZ / 4);
-}
 
 static int e100_get_settings(struct net_device *netdev, struct ethtool_cmd *cmd)
 {
@@ -2598,19 +2572,38 @@ static void e100_diag_test(struct net_de
 	msleep_interruptible(4 * 1000);
 }
 
-static int e100_phys_id(struct net_device *netdev, u32 data)
+static int e100_set_phys_id(struct net_device *netdev,
+			    enum ethtool_phys_id_state state)
 {
 	struct nic *nic = netdev_priv(netdev);
+	enum led_state {
+		led_on     = 0x01,
+		led_off    = 0x04,
+		led_on_559 = 0x05,
+		led_on_557 = 0x07,
+	};
 	u16 led_reg = (nic->phy == phy_82552_v) ? E100_82552_LED_OVERRIDE :
-	              MII_LED_CONTROL;
+		MII_LED_CONTROL;
+	u16 leds = 0;
+
+	switch (state) {
+	case ETHTOOL_ID_ACTIVE:
+		return -EINVAL;
+
+	case ETHTOOL_ID_ON:
+		leds = (nic->phy == phy_82552_v) ? E100_82552_LED_ON :
+		       (nic->mac < mac_82559_D101M) ? led_on_557 : led_on_559;
+		break;
 
-	if (!data || data > (u32)(MAX_SCHEDULE_TIMEOUT / HZ))
-		data = (u32)(MAX_SCHEDULE_TIMEOUT / HZ);
-	mod_timer(&nic->blink_timer, jiffies);
-	msleep_interruptible(data * 1000);
-	del_timer_sync(&nic->blink_timer);
-	mdio_write(netdev, nic->mii.phy_id, led_reg, 0);
+	case ETHTOOL_ID_OFF:
+		leds = (nic->phy == phy_82552_v) ? E100_82552_LED_OFF : led_off;
+		break;
+
+	case ETHTOOL_ID_INACTIVE:
+		break;
+	}
 
+	mdio_write(netdev, nic->mii.phy_id, led_reg, leds);
 	return 0;
 }
 
@@ -2691,7 +2684,7 @@ static const struct ethtool_ops e100_eth
 	.set_ringparam		= e100_set_ringparam,
 	.self_test		= e100_diag_test,
 	.get_strings		= e100_get_strings,
-	.phys_id		= e100_phys_id,
+	.set_phys_id		= e100_set_phys_id,
 	.get_ethtool_stats	= e100_get_ethtool_stats,
 	.get_sset_count		= e100_get_sset_count,
 };
@@ -2832,9 +2825,6 @@ static int __devinit e100_probe(struct p
 	init_timer(&nic->watchdog);
 	nic->watchdog.function = e100_watchdog;
 	nic->watchdog.data = (unsigned long)nic;
-	init_timer(&nic->blink_timer);
-	nic->blink_timer.function = e100_blink_led;
-	nic->blink_timer.data = (unsigned long)nic;
 
 	INIT_WORK(&nic->tx_timeout_task, e100_tx_timeout_task);
 


