From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 03/24] igb: introduce igb_thermal_sensor_event for sensor checking
Date: Wed, 13 Apr 2011 18:01:59 -0700
Message-ID: <1302742940-22141-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1302742940-22141-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Stefan Assmann <sassmann@kpanic.de>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:52716 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750892Ab1DNBC2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 21:02:28 -0400
In-Reply-To: <1302742940-22141-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Assmann <sassmann@kpanic.de>

The code for thermal sensor checking should be wrapped into a function.

Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/igb/igb_main.c |   67 ++++++++++++++++++++++---------------------
 1 files changed, 34 insertions(+), 33 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 0dfd1b9..cdfd572 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3532,6 +3532,25 @@ bool igb_has_link(struct igb_adapter *adapter)
 	return link_active;
 }
 
+static bool igb_thermal_sensor_event(struct e1000_hw *hw, u32 event)
+{
+	bool ret = false;
+	u32 ctrl_ext, thstat;
+
+	/* check for thermal sensor event on i350, copper only */
+	if (hw->mac.type == e1000_i350) {
+		thstat = rd32(E1000_THSTAT);
+		ctrl_ext = rd32(E1000_CTRL_EXT);
+
+		if ((hw->phy.media_type == e1000_media_type_copper) &&
+		    !(ctrl_ext & E1000_CTRL_EXT_LINK_MODE_SGMII)) {
+			ret = !!(thstat & event);
+		}
+	}
+
+	return ret;
+}
+
 /**
  * igb_watchdog - Timer Call-back
  * @data: pointer to adapter cast into an unsigned long
@@ -3550,7 +3569,7 @@ static void igb_watchdog_task(struct work_struct *work)
                                                    watchdog_task);
 	struct e1000_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
-	u32 link, ctrl_ext, thstat;
+	u32 link;
 	int i;
 
 	link = igb_has_link(adapter);
@@ -3574,25 +3593,14 @@ static void igb_watchdog_task(struct work_struct *work)
 			       ((ctrl & E1000_CTRL_RFCE) ?  "RX" :
 			       ((ctrl & E1000_CTRL_TFCE) ?  "TX" : "None")));
 
-			/* check for thermal sensor event on i350,
-			 * copper only */
-			if (hw->mac.type == e1000_i350) {
-				thstat = rd32(E1000_THSTAT);
-				ctrl_ext = rd32(E1000_CTRL_EXT);
-				if ((hw->phy.media_type ==
-				     e1000_media_type_copper) && !(ctrl_ext &
-				     E1000_CTRL_EXT_LINK_MODE_SGMII)) {
-					if (thstat &
-					    E1000_THSTAT_LINK_THROTTLE) {
-						printk(KERN_INFO "igb: %s The "
-						       "network adapter link "
-						       "speed was downshifted "
-						       "because it "
-						       "overheated.\n",
-						       netdev->name);
-					}
-				}
+			/* check for thermal sensor event */
+			if (igb_thermal_sensor_event(hw, E1000_THSTAT_LINK_THROTTLE)) {
+				printk(KERN_INFO "igb: %s The network adapter "
+						 "link speed was downshifted "
+						 "because it overheated.\n",
+						 netdev->name);
 			}
+
 			/* adjust timeout factor according to speed/duplex */
 			adapter->tx_timeout_factor = 1;
 			switch (adapter->link_speed) {
@@ -3618,22 +3626,15 @@ static void igb_watchdog_task(struct work_struct *work)
 		if (netif_carrier_ok(netdev)) {
 			adapter->link_speed = 0;
 			adapter->link_duplex = 0;
-			/* check for thermal sensor event on i350
-			 * copper only*/
-			if (hw->mac.type == e1000_i350) {
-				thstat = rd32(E1000_THSTAT);
-				ctrl_ext = rd32(E1000_CTRL_EXT);
-				if ((hw->phy.media_type ==
-				     e1000_media_type_copper) && !(ctrl_ext &
-				     E1000_CTRL_EXT_LINK_MODE_SGMII)) {
-					if (thstat & E1000_THSTAT_PWR_DOWN) {
-						printk(KERN_ERR "igb: %s The "
-						"network adapter was stopped "
-						"because it overheated.\n",
+
+			/* check for thermal sensor event */
+			if (igb_thermal_sensor_event(hw, E1000_THSTAT_PWR_DOWN)) {
+				printk(KERN_ERR "igb: %s The network adapter "
+						"was stopped because it "
+						"overheated.\n",
 						netdev->name);
-					}
-				}
 			}
+
 			/* Links status message must follow this format */
 			printk(KERN_INFO "igb: %s NIC Link is Down\n",
 			       netdev->name);
-- 
1.7.4.2

