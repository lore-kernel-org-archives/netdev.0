From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] e1000: do not modify tx_queue_len on link speed change
Date: Fri, 26 Mar 2010 14:25:58 -0700
Message-ID: <20100326212557.18793.62063.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Franco Fichtner <franco@lastsummer.de>,
	Emil Tantilov <emil.s.tantilov@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta13.emeryville.ca.mail.comcast.net ([76.96.27.243]:59353
	"EHLO qmta13.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751426Ab0CZV0V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Mar 2010 17:26:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Previously the driver tweaked txqueuelen to avoid false Tx hang reports
seen at half duplex.  This had the effect of overriding user set values
on link change/reset. Testing shows that adjusting only the timeout
factor is sufficient to prevent Tx hang reports at half duplex.

This patch removes all instances of tx_queue_len in the driver.

Based on e1000e patch by Franco Fichtner <franco@lastsummer.de>

CC: Franco Fichtner <franco@lastsummer.de>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000.h      |    1 -
 drivers/net/e1000/e1000_main.c |    9 +--------
 2 files changed, 1 insertions(+), 9 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index 9902b33..2f29c21 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -261,7 +261,6 @@ struct e1000_adapter {
 	/* TX */
 	struct e1000_tx_ring *tx_ring;      /* One per active queue */
 	unsigned int restart_queue;
-	unsigned long tx_queue_len;
 	u32 txd_cmd;
 	u32 tx_int_delay;
 	u32 tx_abs_int_delay;
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 8be6fae..b15ece2 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -383,8 +383,6 @@ static void e1000_configure(struct e1000_adapter *adapter)
 		adapter->alloc_rx_buf(adapter, ring,
 		                      E1000_DESC_UNUSED(ring));
 	}
-
-	adapter->tx_queue_len = netdev->tx_queue_len;
 }
 
 int e1000_up(struct e1000_adapter *adapter)
@@ -503,7 +501,6 @@ void e1000_down(struct e1000_adapter *adapter)
 	del_timer_sync(&adapter->watchdog_timer);
 	del_timer_sync(&adapter->phy_info_timer);
 
-	netdev->tx_queue_len = adapter->tx_queue_len;
 	adapter->link_speed = 0;
 	adapter->link_duplex = 0;
 	netif_carrier_off(netdev);
@@ -2316,19 +2313,15 @@ static void e1000_watchdog(unsigned long data)
 			        E1000_CTRL_RFCE) ? "RX" : ((ctrl &
 			        E1000_CTRL_TFCE) ? "TX" : "None" )));
 
-			/* tweak tx_queue_len according to speed/duplex
-			 * and adjust the timeout factor */
-			netdev->tx_queue_len = adapter->tx_queue_len;
+			/* adjust timeout factor according to speed/duplex */
 			adapter->tx_timeout_factor = 1;
 			switch (adapter->link_speed) {
 			case SPEED_10:
 				txb2b = false;
-				netdev->tx_queue_len = 10;
 				adapter->tx_timeout_factor = 16;
 				break;
 			case SPEED_100:
 				txb2b = false;
-				netdev->tx_queue_len = 100;
 				/* maybe add some timeout factor ? */
 				break;
 			}

