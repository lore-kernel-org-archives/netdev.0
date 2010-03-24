From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH] e1000e: do not modify tx_queue_len on link speed change
Date: Wed, 24 Mar 2010 15:55:02 -0700
Message-ID: <20100324225501.7104.28849.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Franco Fichtner <franco@lastsummer.de>,
	Emil Tantilov <emil.s.tantilov@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.emeryville.ca.mail.comcast.net ([76.96.30.32]:56874 "EHLO
	qmta03.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751981Ab0CXWz3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 18:55:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Previously the driver tweaked txqueuelen to avoid false Tx hang reports seen at half duplex.
This had the effect of overriding user set values on link change/reset. Testing shows that
adjusting only the timeout factor is sufficient to prevent Tx hang reports at half duplex.

This patch removes all instances of tx_queue_len in the driver.

Originally reported and patched by Franco Fichtner
CC: Franco Fichtner <franco@lastsummer.de>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/e1000.h  |    1 -
 drivers/net/e1000e/netdev.c |   11 +----------
 2 files changed, 1 insertions(+), 11 deletions(-)

diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index c2ec095..118bdf4 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -279,7 +279,6 @@ struct e1000_adapter {
 
 	struct napi_struct napi;
 
-	unsigned long tx_queue_len;
 	unsigned int restart_queue;
 	u32 txd_cmd;
 
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 88d54d3..e1cceb6 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -2289,8 +2289,6 @@ static void e1000_configure_tx(struct e1000_adapter *adapter)
 	ew32(TCTL, tctl);
 
 	e1000e_config_collision_dist(hw);
-
-	adapter->tx_queue_len = adapter->netdev->tx_queue_len;
 }
 
 /**
@@ -2877,7 +2875,6 @@ void e1000e_down(struct e1000_adapter *adapter)
 	del_timer_sync(&adapter->watchdog_timer);
 	del_timer_sync(&adapter->phy_info_timer);
 
-	netdev->tx_queue_len = adapter->tx_queue_len;
 	netif_carrier_off(netdev);
 	adapter->link_speed = 0;
 	adapter->link_duplex = 0;
@@ -3588,21 +3585,15 @@ static void e1000_watchdog_task(struct work_struct *work)
 					       "link gets many collisions.\n");
 			}
 
-			/*
-			 * tweak tx_queue_len according to speed/duplex
-			 * and adjust the timeout factor
-			 */
-			netdev->tx_queue_len = adapter->tx_queue_len;
+			/* adjust timeout factor according to speed/duplex */
 			adapter->tx_timeout_factor = 1;
 			switch (adapter->link_speed) {
 			case SPEED_10:
 				txb2b = 0;
-				netdev->tx_queue_len = 10;
 				adapter->tx_timeout_factor = 16;
 				break;
 			case SPEED_100:
 				txb2b = 0;
-				netdev->tx_queue_len = 100;
 				adapter->tx_timeout_factor = 10;
 				break;
 			}

