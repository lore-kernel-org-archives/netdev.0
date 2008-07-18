From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH] igb/ixgbe/e1000e: resolve tx multiqueue bug
Date: Fri, 18 Jul 2008 04:02:25 -0700
Message-ID: <20080718110225.20696.14881.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:63573 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751995AbYGRLC1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jul 2008 07:02:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the recent changes to tx mutiqueue, igb/ixgbe/e1000e was not calling
netif_tx_start_all_queues() before calling netif_tx_wake_all_queues().
This causes an issue during loading of the driver.

In addition, updated e1000e to use the updated tx mutliqueue api.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/netdev.c    |   10 ++++++----
 drivers/net/igb/igb_main.c     |    2 ++
 drivers/net/ixgbe/ixgbe_main.c |    2 ++
 3 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index be59533..869544b 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -2513,7 +2513,7 @@ void e1000e_down(struct e1000_adapter *adapter)
 	ew32(RCTL, rctl & ~E1000_RCTL_EN);
 	/* flush and sleep below */
 
-	netif_stop_queue(netdev);
+	netif_tx_stop_all_queues(netdev);
 
 	/* disable transmits in the hardware */
 	tctl = er32(TCTL);
@@ -2663,6 +2663,8 @@ static int e1000_open(struct net_device *netdev)
 
 	e1000_irq_enable(adapter);
 
+	netif_tx_start_all_queues(netdev);
+
 	/* fire a link status change interrupt to start the watchdog */
 	ew32(ICS, E1000_ICS_LSC);
 
@@ -3118,7 +3120,7 @@ static void e1000_watchdog_task(struct work_struct *work)
 			ew32(TCTL, tctl);
 
 			netif_carrier_on(netdev);
-			netif_wake_queue(netdev);
+			netif_tx_wake_all_queues(netdev);
 
 			if (!test_bit(__E1000_DOWN, &adapter->state))
 				mod_timer(&adapter->phy_info_timer,
@@ -3130,7 +3132,7 @@ static void e1000_watchdog_task(struct work_struct *work)
 			adapter->link_duplex = 0;
 			ndev_info(netdev, "Link is Down\n");
 			netif_carrier_off(netdev);
-			netif_stop_queue(netdev);
+			netif_tx_stop_all_queues(netdev);
 			if (!test_bit(__E1000_DOWN, &adapter->state))
 				mod_timer(&adapter->phy_info_timer,
 					  round_jiffies(jiffies + 2 * HZ));
@@ -4504,7 +4506,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 
 	/* tell the stack to leave us alone until e1000_open() is called */
 	netif_carrier_off(netdev);
-	netif_stop_queue(netdev);
+	netif_tx_stop_all_queues(netdev);
 
 	strcpy(netdev->name, "eth%d");
 	err = register_netdev(netdev);
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 81bba69..1b7cb29 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1493,6 +1493,8 @@ static int igb_open(struct net_device *netdev)
 
 	igb_irq_enable(adapter);
 
+	netif_tx_start_all_queues(netdev);
+
 	/* Fire a link status change interrupt to start the watchdog. */
 	wr32(E1000_ICS, E1000_ICS_LSC);
 
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index efebd11..e5f3da8 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2763,6 +2763,8 @@ static int ixgbe_open(struct net_device *netdev)
 	if (err)
 		goto err_up;
 
+	netif_tx_start_all_queues(netdev);
+
 	return 0;
 
 err_up:

