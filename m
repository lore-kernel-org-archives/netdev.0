From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 1/5] e100: implemenet set_phys_id
Date: Sat,  7 May 2011 03:25:19 -0700
Message-ID: <1304763923-6839-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1304763923-6839-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Stephen Hemminger <shemminger@vyatta.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:43819 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754527Ab1EGKZ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 May 2011 06:25:28 -0400
In-Reply-To: <1304763923-6839-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on the original patch from Stephen Hemminger.
Implement set_phys_id to control LED.

CC: Stephen Hemminger <shemminger@vyatta.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e100.c |   66 ++++++++++++++++++++++------------------------------
 1 files changed, 28 insertions(+), 38 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 29f812d..e336c79 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
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
@@ -2353,30 +2351,6 @@ err_clean_rx:
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
@@ -2600,19 +2574,38 @@ static void e100_diag_test(struct net_device *netdev,
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
+		return 2;
 
-	if (!data || data > (u32)(MAX_SCHEDULE_TIMEOUT / HZ))
-		data = (u32)(MAX_SCHEDULE_TIMEOUT / HZ);
-	mod_timer(&nic->blink_timer, jiffies);
-	msleep_interruptible(data * 1000);
-	del_timer_sync(&nic->blink_timer);
-	mdio_write(netdev, nic->mii.phy_id, led_reg, 0);
+	case ETHTOOL_ID_ON:
+		leds = (nic->phy == phy_82552_v) ? E100_82552_LED_ON :
+		       (nic->mac < mac_82559_D101M) ? led_on_557 : led_on_559;
+		break;
+
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
 
@@ -2693,7 +2686,7 @@ static const struct ethtool_ops e100_ethtool_ops = {
 	.set_ringparam		= e100_set_ringparam,
 	.self_test		= e100_diag_test,
 	.get_strings		= e100_get_strings,
-	.phys_id		= e100_phys_id,
+	.set_phys_id		= e100_set_phys_id,
 	.get_ethtool_stats	= e100_get_ethtool_stats,
 	.get_sset_count		= e100_get_sset_count,
 };
@@ -2834,9 +2827,6 @@ static int __devinit e100_probe(struct pci_dev *pdev,
 	init_timer(&nic->watchdog);
 	nic->watchdog.function = e100_watchdog;
 	nic->watchdog.data = (unsigned long)nic;
-	init_timer(&nic->blink_timer);
-	nic->blink_timer.function = e100_blink_led;
-	nic->blink_timer.data = (unsigned long)nic;
 
 	INIT_WORK(&nic->tx_timeout_task, e100_tx_timeout_task);
 
-- 
1.7.4.4

