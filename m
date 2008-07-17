From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [UPDATE][NET-TX PATCH] igb: update tx multiqueue
Date: Wed, 16 Jul 2008 20:22:00 -0700
Message-ID: <20080717032115.13459.84845.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:13598 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752960AbYGQDWC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2008 23:22:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These changes are to update igb's tx multiqueue to work with Dave's new TX
multiqueue changes.
Removed references to CONFIG_NETDEVICES_MULTIQUEUE.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |   18 +++++++++++-------
 1 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index afd4ce3..720aea2 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -414,6 +414,9 @@ msi_only:
 	adapter->num_rx_queues = 1;
 	if (!pci_enable_msi(adapter->pdev))
 		adapter->msi_enabled = 1;
+
+	/* Notify the stack of the (possibly) reduced Tx Queue count. */
+	adapter->netdev->real_num_tx_queues = adapter->num_tx_queues;
 	return;
 }
 
@@ -692,7 +695,7 @@ void igb_down(struct igb_adapter *adapter)
 	wr32(E1000_RCTL, rctl & ~E1000_RCTL_EN);
 	/* flush and sleep below */
 
-	netif_stop_queue(netdev);
+	netif_tx_stop_all_queues(netdev);
 
 	/* disable transmits in the hardware */
 	tctl = rd32(E1000_TCTL);
@@ -1096,7 +1099,7 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 
 	/* tell the stack to leave us alone until igb_open() is called */
 	netif_carrier_off(netdev);
-	netif_stop_queue(netdev);
+	netif_tx_stop_all_queues(netdev);
 
 	strcpy(netdev->name, "eth%d");
 	err = register_netdev(netdev);
@@ -2151,7 +2154,7 @@ static void igb_watchdog_task(struct work_struct *work)
 			}
 
 			netif_carrier_on(netdev);
-			netif_wake_queue(netdev);
+			netif_tx_wake_all_queues(netdev);
 
 			if (!test_bit(__IGB_DOWN, &adapter->state))
 				mod_timer(&adapter->phy_info_timer,
@@ -2163,7 +2166,7 @@ static void igb_watchdog_task(struct work_struct *work)
 			adapter->link_duplex = 0;
 			dev_info(&adapter->pdev->dev, "NIC Link is Down\n");
 			netif_carrier_off(netdev);
-			netif_stop_queue(netdev);
+			netif_tx_stop_all_queues(netdev);
 			if (!test_bit(__IGB_DOWN, &adapter->state))
 				mod_timer(&adapter->phy_info_timer,
 					  round_jiffies(jiffies + 2 * HZ));
@@ -2663,7 +2666,8 @@ static int __igb_maybe_stop_tx(struct net_device *netdev,
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
 
-	netif_stop_queue(netdev);
+	netif_tx_stop_all_queues(netdev);
+
 	/* Herbert's original patch had:
 	 *  smp_mb__after_netif_stop_queue();
 	 * but since that doesn't exist yet, just open code it. */
@@ -2675,7 +2679,7 @@ static int __igb_maybe_stop_tx(struct net_device *netdev,
 		return -EBUSY;
 
 	/* A reprieve! */
-	netif_start_queue(netdev);
+	netif_tx_wake_all_queues(netdev);
 	++adapter->restart_queue;
 	return 0;
 }
@@ -3368,7 +3372,7 @@ done_cleaning:
 				tx_ring->buffer_info[i].time_stamp,
 				jiffies,
 				tx_desc->upper.fields.status);
-			netif_stop_queue(netdev);
+			netif_tx_stop_all_queues(netdev);
 		}
 	}
 	tx_ring->total_bytes += total_bytes;

