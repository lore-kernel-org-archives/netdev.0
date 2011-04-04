From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next-2.6 04/12] e1000: convert to set_phys_id
Date: Mon, 04 Apr 2011 11:43:44 -0700
Message-ID: <20110404184501.640779086@linuxplumber.net>
References: <20110404184340.604594357@linuxplumber.net>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce A
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:52805 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753752Ab1DDSvH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2011 14:51:07 -0400
Content-Disposition: inline; filename=e1000-set-phys-id.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert to new LED control infrastucture and remove no longer
necessary bits.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 drivers/net/e1000/e1000.h         |    3 --
 drivers/net/e1000/e1000_ethtool.c |   50 ++++++++++++--------------------------
 2 files changed, 16 insertions(+), 37 deletions(-)

--- a/drivers/net/e1000/e1000.h	2011-04-04 11:22:23.951992540 -0700
+++ b/drivers/net/e1000/e1000.h	2011-04-04 11:22:32.832071659 -0700
@@ -238,9 +238,6 @@ struct e1000_adapter {
 	struct work_struct reset_task;
 	u8 fc_autoneg;
 
-	struct timer_list blink_timer;
-	unsigned long led_status;
-
 	/* TX */
 	struct e1000_tx_ring *tx_ring;      /* One per active queue */
 	unsigned int restart_queue;
--- a/drivers/net/e1000/e1000_ethtool.c	2011-04-04 11:21:31.663536366 -0700
+++ b/drivers/net/e1000/e1000_ethtool.c	2011-04-04 11:26:51.978552805 -0700
@@ -1753,46 +1753,28 @@ static int e1000_set_wol(struct net_devi
 	return 0;
 }
 
-/* toggle LED 4 times per second = 2 "blinks" per second */
-#define E1000_ID_INTERVAL	(HZ/4)
-
-/* bit defines for adapter->led_status */
-#define E1000_LED_ON		0
-
-static void e1000_led_blink_callback(unsigned long data)
+static int e1000_set_phys_id(struct net_device *netdev,
+			     enum ethtool_phys_id_state state)
 {
-	struct e1000_adapter *adapter = (struct e1000_adapter *) data;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 
-	if (test_and_change_bit(E1000_LED_ON, &adapter->led_status))
-		e1000_led_off(hw);
-	else
-		e1000_led_on(hw);
-
-	mod_timer(&adapter->blink_timer, jiffies + E1000_ID_INTERVAL);
-}
+	switch (state) {
+	case ETHTOOL_ID_ACTIVE:
+		e1000_setup_led(hw);
+		return -EINVAL;
 
-static int e1000_phys_id(struct net_device *netdev, u32 data)
-{
-	struct e1000_adapter *adapter = netdev_priv(netdev);
-	struct e1000_hw *hw = &adapter->hw;
+	case ETHTOOL_ID_ON:
+		e1000_led_on(hw);
+		break;
 
-	if (!data)
-		data = INT_MAX;
+	case ETHTOOL_ID_OFF:
+		e1000_led_off(hw);
+		break;
 
-	if (!adapter->blink_timer.function) {
-		init_timer(&adapter->blink_timer);
-		adapter->blink_timer.function = e1000_led_blink_callback;
-		adapter->blink_timer.data = (unsigned long)adapter;
+	case ETHTOOL_ID_INACTIVE:
+		e1000_cleanup_led(hw);
 	}
-	e1000_setup_led(hw);
-	mod_timer(&adapter->blink_timer, jiffies);
-	msleep_interruptible(data * 1000);
-	del_timer_sync(&adapter->blink_timer);
-
-	e1000_led_off(hw);
-	clear_bit(E1000_LED_ON, &adapter->led_status);
-	e1000_cleanup_led(hw);
 
 	return 0;
 }
@@ -1929,7 +1911,7 @@ static const struct ethtool_ops e1000_et
 	.set_tso                = e1000_set_tso,
 	.self_test              = e1000_diag_test,
 	.get_strings            = e1000_get_strings,
-	.phys_id                = e1000_phys_id,
+	.set_phys_id            = e1000_set_phys_id,
 	.get_ethtool_stats      = e1000_get_ethtool_stats,
 	.get_sset_count         = e1000_get_sset_count,
 	.get_coalesce           = e1000_get_coalesce,


