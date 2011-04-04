From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next-2.6 09/12] ixgb: convert to set_phys_id
Date: Mon, 04 Apr 2011 11:43:49 -0700
Message-ID: <20110404184502.102613916@linuxplumber.net>
References: <20110404184340.604594357@linuxplumber.net>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce A
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:52822 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755198Ab1DDSvK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2011 14:51:10 -0400
Content-Disposition: inline; filename=ixgb-set-phys.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/ixgb/ixgb.h	2011-04-04 11:38:54.837945742 -0700
+++ b/drivers/net/ixgb/ixgb.h	2011-04-04 11:38:59.441992978 -0700
@@ -157,9 +157,6 @@ struct ixgb_adapter {
 	u16 link_duplex;
 	struct work_struct tx_timeout_task;
 
-	struct timer_list blink_timer;
-	unsigned long led_status;
-
 	/* TX */
 	struct ixgb_desc_ring tx_ring ____cacheline_aligned_in_smp;
 	unsigned int restart_queue;
--- a/drivers/net/ixgb/ixgb_ethtool.c	2011-04-04 11:38:04.089428786 -0700
+++ b/drivers/net/ixgb/ixgb_ethtool.c	2011-04-04 11:40:39.458950195 -0700
@@ -610,45 +610,23 @@ err_setup_rx:
 	return err;
 }
 
-/* toggle LED 4 times per second = 2 "blinks" per second */
-#define IXGB_ID_INTERVAL	(HZ/4)
-
-/* bit defines for adapter->led_status */
-#define IXGB_LED_ON		0
-
-static void
-ixgb_led_blink_callback(unsigned long data)
-{
-	struct ixgb_adapter *adapter = (struct ixgb_adapter *)data;
-
-	if (test_and_change_bit(IXGB_LED_ON, &adapter->led_status))
-		ixgb_led_off(&adapter->hw);
-	else
-		ixgb_led_on(&adapter->hw);
-
-	mod_timer(&adapter->blink_timer, jiffies + IXGB_ID_INTERVAL);
-}
-
 static int
-ixgb_phys_id(struct net_device *netdev, u32 data)
+ixgb_set_phys_id(struct net_device *netdev, enum ethtool_phys_id_state state)
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 
-	if (!data)
-		data = INT_MAX;
-
-	if (!adapter->blink_timer.function) {
-		init_timer(&adapter->blink_timer);
-		adapter->blink_timer.function = ixgb_led_blink_callback;
-		adapter->blink_timer.data = (unsigned long)adapter;
-	}
+	switch (state) {
+	case ETHTOOL_ID_ACTIVE:
+		return -EINVAL;
 
-	mod_timer(&adapter->blink_timer, jiffies);
+	case ETHTOOL_ID_ON:
+		ixgb_led_on(&adapter->hw);
+		break;
 
-	msleep_interruptible(data * 1000);
-	del_timer_sync(&adapter->blink_timer);
-	ixgb_led_off(&adapter->hw);
-	clear_bit(IXGB_LED_ON, &adapter->led_status);
+	case ETHTOOL_ID_OFF:
+	case ETHTOOL_ID_INACTIVE:
+		ixgb_led_off(&adapter->hw);
+	}
 
 	return 0;
 }
@@ -766,7 +744,7 @@ static const struct ethtool_ops ixgb_eth
 	.set_msglevel = ixgb_set_msglevel,
 	.set_tso = ixgb_set_tso,
 	.get_strings = ixgb_get_strings,
-	.phys_id = ixgb_phys_id,
+	.set_phys_id = ixgb_set_phys_id,
 	.get_sset_count = ixgb_get_sset_count,
 	.get_ethtool_stats = ixgb_get_ethtool_stats,
 	.get_flags = ethtool_op_get_flags,


