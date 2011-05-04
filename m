From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 2/9] ixgb: convert to set_phys_id
Date: Wed,  4 May 2011 12:30:34 -0700
Message-ID: <1304537441-2056-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1304537441-2056-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Stephen Hemminger <shemminger@vyatta.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:65291 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755413Ab1EDTaq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2011 15:30:46 -0400
In-Reply-To: <1304537441-2056-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on the original patch sent by Stephen Hemminger.

This version incorporates the ethtool changes that Bruce Allan
submitted.

CC: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Tested-by: Evan Swanson <evan.swanson@intel.com>
---
 drivers/net/ixgb/ixgb.h         |    3 --
 drivers/net/ixgb/ixgb_ethtool.c |   46 ++++++++++----------------------------
 2 files changed, 12 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ixgb/ixgb.h b/drivers/net/ixgb/ixgb.h
index 8f3df04..49e8408 100644
--- a/drivers/net/ixgb/ixgb.h
+++ b/drivers/net/ixgb/ixgb.h
@@ -157,9 +157,6 @@ struct ixgb_adapter {
 	u16 link_duplex;
 	struct work_struct tx_timeout_task;
 
-	struct timer_list blink_timer;
-	unsigned long led_status;
-
 	/* TX */
 	struct ixgb_desc_ring tx_ring ____cacheline_aligned_in_smp;
 	unsigned int restart_queue;
diff --git a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ixgb/ixgb_ethtool.c
index 5f224c3..6da890b 100644
--- a/drivers/net/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ixgb/ixgb_ethtool.c
@@ -611,45 +611,23 @@ err_setup_rx:
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
+		return 2;
 
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
@@ -767,7 +745,7 @@ static const struct ethtool_ops ixgb_ethtool_ops = {
 	.set_msglevel = ixgb_set_msglevel,
 	.set_tso = ixgb_set_tso,
 	.get_strings = ixgb_get_strings,
-	.phys_id = ixgb_phys_id,
+	.set_phys_id = ixgb_set_phys_id,
 	.get_sset_count = ixgb_get_sset_count,
 	.get_ethtool_stats = ixgb_get_ethtool_stats,
 	.get_flags = ethtool_op_get_flags,
-- 
1.7.4.4

