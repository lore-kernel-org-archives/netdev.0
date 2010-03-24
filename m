From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH] igb: do not modify tx_queue_len on link speed change
Date: Tue, 23 Mar 2010 21:34:57 -0700
Message-ID: <20100324043456.32036.21219.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Emil Tantilov <emil.s.tantilov@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta14.emeryville.ca.mail.comcast.net ([76.96.27.212]:46650
	"EHLO qmta14.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751208Ab0CXEfS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 00:35:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Previously the driver tweaked txqueuelen to avoid false Tx hang reports seen at half duplex.
This had the effect of overriding user set values on link change/reset. Testing shows that
adjusting only the timeout factor is sufficient to prevent Tx hang reports at half duplex.

Based on e1000e patch by Franco Fichtner <franco@lastsummer.de>

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb.h      |    1 -
 drivers/net/igb/igb_main.c |   10 +---------
 2 files changed, 1 insertions(+), 10 deletions(-)

diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index a177570..3b772b8 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -267,7 +267,6 @@ struct igb_adapter {
 
 	/* TX */
 	struct igb_ring *tx_ring[16];
-	unsigned long tx_queue_len;
 	u32 tx_timeout_count;
 
 	/* RX */
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 70dc03b..e72760c 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1105,9 +1105,6 @@ static void igb_configure(struct igb_adapter *adapter)
 		struct igb_ring *ring = adapter->rx_ring[i];
 		igb_alloc_rx_buffers_adv(ring, igb_desc_unused(ring));
 	}
-
-
-	adapter->tx_queue_len = netdev->tx_queue_len;
 }
 
 /**
@@ -1213,7 +1210,6 @@ void igb_down(struct igb_adapter *adapter)
 	del_timer_sync(&adapter->watchdog_timer);
 	del_timer_sync(&adapter->phy_info_timer);
 
-	netdev->tx_queue_len = adapter->tx_queue_len;
 	netif_carrier_off(netdev);
 
 	/* record the stats before reset*/
@@ -3106,17 +3102,13 @@ static void igb_watchdog_task(struct work_struct *work)
 			       ((ctrl & E1000_CTRL_RFCE) ?  "RX" :
 			       ((ctrl & E1000_CTRL_TFCE) ?  "TX" : "None")));
 
-			/* tweak tx_queue_len according to speed/duplex and
-			 * adjust the timeout factor */
-			netdev->tx_queue_len = adapter->tx_queue_len;
+			/* adjust timeout factor according to speed/duplex */
 			adapter->tx_timeout_factor = 1;
 			switch (adapter->link_speed) {
 			case SPEED_10:
-				netdev->tx_queue_len = 10;
 				adapter->tx_timeout_factor = 14;
 				break;
 			case SPEED_100:
-				netdev->tx_queue_len = 100;
 				/* maybe add some timeout factor ? */
 				break;
 			}

