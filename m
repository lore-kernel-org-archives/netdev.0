From: Matthew Wilcox <matthew@wil.cx>
Subject: [PATCH] Rewrite e100_phys_id
Date: Thu, 26 Oct 2006 13:11:55 -0600
Message-ID: <20061026191154.GG5591@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palinux.external.hp.com ([192.25.206.14]:46276 "EHLO
	mail.parisc-linux.org") by vger.kernel.org with ESMTP
	id S1423716AbWJZTLz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Oct 2006 15:11:55 -0400
To: john.ronciak@intel.com, jesse.brandeburg@intel.com,
	jeffrey.t.kirsher@intel.com, auke-jan.h.kok@intel.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The motivator for this was to fix the sparse warning:

drivers/net/e100.c:2418:48: warning: cast truncates bits from constant
value (83126e978d4fdf becomes 978d4fdf)
drivers/net/e100.c:2419:37: warning: cast truncates bits from constant
value (83126e978d4fdf becomes 978d4fdf)

Initially, I tried a quick fix, but when it ran into difficulties, I
looked at tg3.c to see how it does it.  I liked their way better, so I
rewrote e100.c to be similar.  It shaves ~700 bytes off the size of the
driver, and a few bytes off the size of struct nic, so I think it's a
win all round.  Tested on the internal interface of an HP Integrity rx2600.

Signed-off-by: Matthew Wilcox <matthew@wil.cx>

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index a3a08a5..aade1e9 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -556,7 +556,6 @@ struct nic {
 	struct params params;
 	struct net_device_stats net_stats;
 	struct timer_list watchdog;
-	struct timer_list blink_timer;
 	struct mii_if_info mii;
 	struct work_struct tx_timeout_task;
 	enum loopback loopback;
@@ -581,7 +580,6 @@ struct nic {
 	u32 rx_over_length_errors;
 
 	u8 rev_id;
-	u16 leds;
 	u16 eeprom_wc;
 	u16 eeprom[256];
 	spinlock_t mdio_lock;
@@ -2168,23 +2166,6 @@ err_clean_rx:
 	return err;
 }
 
-#define MII_LED_CONTROL	0x1B
-static void e100_blink_led(unsigned long data)
-{
-	struct nic *nic = (struct nic *)data;
-	enum led_state {
-		led_on     = 0x01,
-		led_off    = 0x04,
-		led_on_559 = 0x05,
-		led_on_557 = 0x07,
-	};
-
-	nic->leds = (nic->leds & led_on) ? led_off :
-		(nic->mac < mac_82559_D101M) ? led_on_557 : led_on_559;
-	mdio_write(nic->netdev, nic->mii.phy_id, MII_LED_CONTROL, nic->leds);
-	mod_timer(&nic->blink_timer, jiffies + HZ / 4);
-}
-
 static int e100_get_settings(struct net_device *netdev, struct ethtool_cmd *cmd)
 {
 	struct nic *nic = netdev_priv(netdev);
@@ -2411,16 +2392,32 @@ static void e100_diag_test(struct net_de
 	msleep_interruptible(4 * 1000);
 }
 
+#define MII_LED_CONTROL	0x1B
 static int e100_phys_id(struct net_device *netdev, u32 data)
 {
 	struct nic *nic = netdev_priv(netdev);
+	int i;
+
+	enum led_state {
+		led_off    = 0x04,
+		led_on_559 = 0x05,
+		led_on_557 = 0x07,
+	};
+	u16 leds = led_off;
+
+	if (data == 0)
+		data = 2;
+
+	for (i = 0; i < (data * 2); i++) {
+		leds = (leds == led_off) ?
+			(nic->mac < mac_82559_D101M) ? led_on_557 : led_on_559 :
+			led_off;
+		mdio_write(nic->netdev, nic->mii.phy_id, MII_LED_CONTROL, leds);
+		if (msleep_interruptible(500))
+			break;
+	}
 
-	if(!data || data > (u32)(MAX_SCHEDULE_TIMEOUT / HZ))
-		data = (u32)(MAX_SCHEDULE_TIMEOUT / HZ);
-	mod_timer(&nic->blink_timer, jiffies);
-	msleep_interruptible(data * 1000);
-	del_timer_sync(&nic->blink_timer);
-	mdio_write(netdev, nic->mii.phy_id, MII_LED_CONTROL, 0);
+	mdio_write(netdev, nic->mii.phy_id, MII_LED_CONTROL, led_off);
 
 	return 0;
 }
@@ -2633,9 +2630,6 @@ #endif
 	init_timer(&nic->watchdog);
 	nic->watchdog.function = e100_watchdog;
 	nic->watchdog.data = (unsigned long)nic;
-	init_timer(&nic->blink_timer);
-	nic->blink_timer.function = e100_blink_led;
-	nic->blink_timer.data = (unsigned long)nic;
 
 	INIT_WORK(&nic->tx_timeout_task,
 		(void (*)(void *))e100_tx_timeout_task, netdev);
