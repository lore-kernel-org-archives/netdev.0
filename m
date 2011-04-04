From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next-2.6 06/12] igb: convert to ethtool set_phys_id
Date: Mon, 04 Apr 2011 11:43:46 -0700
Message-ID: <20110404184501.824549872@linuxplumber.net>
References: <20110404184340.604594357@linuxplumber.net>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce A
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:52815 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753796Ab1DDSvI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2011 14:51:08 -0400
Content-Disposition: inline; filename=igb-set-phys-id.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert igb driver to use new set_phys_id ethtool interface.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/igb/igb_ethtool.c	2011-04-04 10:48:11.725482218 -0700
+++ b/drivers/net/igb/igb_ethtool.c	2011-04-04 10:50:38.243512749 -0700
@@ -1963,29 +1963,26 @@ static int igb_set_wol(struct net_device
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
+	switch (state) {
+	case ETHTOOL_ID_ACTIVE:
+		igb_blink_led(hw);
+		return 0;
+
+	case ETHTOOL_ID_INACTIVE:
+		igb_led_off(hw);
+		clear_bit(IGB_LED_ON, &adapter->led_status);
+		igb_cleanup_led(hw);
+		return 0;
 
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
-
-	return 0;
+	default:
+		return -EINVAL;
+	}
 }
 
 static int igb_set_coalesce(struct net_device *netdev,
@@ -2215,7 +2212,7 @@ static const struct ethtool_ops igb_etht
 	.set_tso                = igb_set_tso,
 	.self_test              = igb_diag_test,
 	.get_strings            = igb_get_strings,
-	.phys_id                = igb_phys_id,
+	.set_phys_id            = igb_set_phys_id,
 	.get_sset_count         = igb_get_sset_count,
 	.get_ethtool_stats      = igb_get_ethtool_stats,
 	.get_coalesce           = igb_get_coalesce,


