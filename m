From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] igbvf: do not modify tx_queue_len on link speed change
Date: Thu, 25 Mar 2010 15:11:48 -0700
Message-ID: <20100325221120.8756.51559.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Franco Fichtner <franco@lastsummer.de>,
	Emil Tantilov <emil.s.tantilov@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.westchester.pa.mail.comcast.net ([76.96.62.96]:41515
	"EHLO qmta09.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752378Ab0CYWMJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Mar 2010 18:12:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Previously the driver tweaked txqueuelen to avoid false Tx hang reports seen at half duplex.
This had the effect of overriding user set values on link change/reset. Testing shows that
adjusting only the timeout factor is sufficient to prevent Tx hang reports at half duplex.

Based on e1000e patch by Franco Fichtner <franco@lastsummer.de>

CC: Franco Fichtner <franco@lastsummer.de>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igbvf/igbvf.h  |    1 -
 drivers/net/igbvf/netdev.c |   11 +----------
 2 files changed, 1 insertions(+), 11 deletions(-)

diff --git a/drivers/net/igbvf/igbvf.h b/drivers/net/igbvf/igbvf.h
index a1774b2..debeee2 100644
--- a/drivers/net/igbvf/igbvf.h
+++ b/drivers/net/igbvf/igbvf.h
@@ -198,7 +198,6 @@ struct igbvf_adapter {
 	struct igbvf_ring *tx_ring /* One per active queue */
 	____cacheline_aligned_in_smp;
 
-	unsigned long tx_queue_len;
 	unsigned int restart_queue;
 	u32 txd_cmd;
 
diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
index a77afd8..b41037e 100644
--- a/drivers/net/igbvf/netdev.c
+++ b/drivers/net/igbvf/netdev.c
@@ -1304,8 +1304,6 @@ static void igbvf_configure_tx(struct igbvf_adapter *adapter)
 
 	/* enable Report Status bit */
 	adapter->txd_cmd |= E1000_ADVTXD_DCMD_RS;
-
-	adapter->tx_queue_len = adapter->netdev->tx_queue_len;
 }
 
 /**
@@ -1524,7 +1522,6 @@ void igbvf_down(struct igbvf_adapter *adapter)
 
 	del_timer_sync(&adapter->watchdog_timer);
 
-	netdev->tx_queue_len = adapter->tx_queue_len;
 	netif_carrier_off(netdev);
 
 	/* record the stats before reset*/
@@ -1857,21 +1854,15 @@ static void igbvf_watchdog_task(struct work_struct *work)
 			                          &adapter->link_duplex);
 			igbvf_print_link_info(adapter);
 
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
 				/* maybe add some timeout factor ? */
 				break;
 			}

