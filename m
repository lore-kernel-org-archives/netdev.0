From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 3/5] igb: convert to ethtool set_phys_id
Date: Sat,  7 May 2011 03:25:21 -0700
Message-ID: <1304763923-6839-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1304763923-6839-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Stephen Hemminger <shemminger@vyatta.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:43819 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754415Ab1EGKZ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 May 2011 06:25:29 -0400
In-Reply-To: <1304763923-6839-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on patch from Stephen Hemminger.
Convert igb driver to use new set_phys_id ethtool interface.

CC: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/igb/igb_ethtool.c |   37 +++++++++++++++++++------------------
 1 files changed, 19 insertions(+), 18 deletions(-)

diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index 6e29634..fdc895e 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -1964,27 +1964,28 @@ static int igb_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
 /* bit defines for adapter->led_status */
 #define IGB_LED_ON		0
 
-static int igb_phys_id(struct net_device *netdev, u32 data)
+static int igb_set_phys_id(struct net_device *netdev,
+			   enum ethtool_phys_id_state state)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
-	unsigned long timeout;
 
-	timeout = data * 1000;
-
-	/*
-	 *  msleep_interruptable only accepts unsigned int so we are limited
-	 * in how long a duration we can wait
-	 */
-	if (!timeout || timeout > UINT_MAX)
-		timeout = UINT_MAX;
-
-	igb_blink_led(hw);
-	msleep_interruptible(timeout);
-
-	igb_led_off(hw);
-	clear_bit(IGB_LED_ON, &adapter->led_status);
-	igb_cleanup_led(hw);
+	switch (state) {
+	case ETHTOOL_ID_ACTIVE:
+		igb_blink_led(hw);
+		return 2;
+	case ETHTOOL_ID_ON:
+		igb_blink_led(hw);
+		break;
+	case ETHTOOL_ID_OFF:
+		igb_led_off(hw);
+		break;
+	case ETHTOOL_ID_INACTIVE:
+		igb_led_off(hw);
+		clear_bit(IGB_LED_ON, &adapter->led_status);
+		igb_cleanup_led(hw);
+		break;
+	}
 
 	return 0;
 }
@@ -2216,7 +2217,7 @@ static const struct ethtool_ops igb_ethtool_ops = {
 	.set_tso                = igb_set_tso,
 	.self_test              = igb_diag_test,
 	.get_strings            = igb_get_strings,
-	.phys_id                = igb_phys_id,
+	.set_phys_id            = igb_set_phys_id,
 	.get_sset_count         = igb_get_sset_count,
 	.get_ethtool_stats      = igb_get_ethtool_stats,
 	.get_coalesce           = igb_get_coalesce,
-- 
1.7.4.4

