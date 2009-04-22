From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] e1000/e1000e/igb/ixgb: do not use
	netif_wake_queue un-necessarily
Date: Tue, 21 Apr 2009 21:42:05 -0700
Message-ID: <20090422044153.22980.31231.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.emeryville.ca.mail.comcast.net ([76.96.30.40]:52980 "EHLO
	QMTA04.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751543AbZDVEmX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 00:42:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

It was pointed out that the Intel wired ethernet drivers do not need to
wake the tx queue since netif_carrier_on/off will take care of the qdisc
management in order to guarantee the correct handling of the transmit
routine enable state.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000_main.c |    4 ++--
 drivers/net/e1000e/netdev.c    |    8 ++++----
 drivers/net/igb/igb_main.c     |    4 ++--
 drivers/net/ixgb/ixgb_main.c   |    5 ++---
 4 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 112e6b0..71d4fe1 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -498,6 +498,8 @@ int e1000_up(struct e1000_adapter *adapter)
 
 	e1000_irq_enable(adapter);
 
+	netif_wake_queue(adapter->netdev);
+
 	/* fire a link change interrupt to start the watchdog */
 	ew32(ICS, E1000_ICS_LSC);
 	return 0;
@@ -2591,7 +2593,6 @@ static void e1000_watchdog(unsigned long data)
 			ew32(TCTL, tctl);
 
 			netif_carrier_on(netdev);
-			netif_wake_queue(netdev);
 			mod_timer(&adapter->phy_info_timer, round_jiffies(jiffies + 2 * HZ));
 			adapter->smartspeed = 0;
 		} else {
@@ -2608,7 +2609,6 @@ static void e1000_watchdog(unsigned long data)
 			printk(KERN_INFO "e1000: %s NIC Link is Down\n",
 			       netdev->name);
 			netif_carrier_off(netdev);
-			netif_stop_queue(netdev);
 			mod_timer(&adapter->phy_info_timer, round_jiffies(jiffies + 2 * HZ));
 
 			/* 80003ES2LAN workaround--
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 9048f8e..da6b37e 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -2826,6 +2826,8 @@ int e1000e_up(struct e1000_adapter *adapter)
 		e1000_configure_msix(adapter);
 	e1000_irq_enable(adapter);
 
+	netif_wake_queue(adapter->netdev);
+
 	/* fire a link change interrupt to start the watchdog */
 	ew32(ICS, E1000_ICS_LSC);
 	return 0;
@@ -2848,7 +2850,7 @@ void e1000e_down(struct e1000_adapter *adapter)
 	ew32(RCTL, rctl & ~E1000_RCTL_EN);
 	/* flush and sleep below */
 
-	netif_tx_stop_all_queues(netdev);
+	netif_stop_queue(netdev);
 
 	/* disable transmits in the hardware */
 	tctl = er32(TCTL);
@@ -3130,7 +3132,7 @@ static int e1000_open(struct net_device *netdev)
 
 	e1000_irq_enable(adapter);
 
-	netif_tx_start_all_queues(netdev);
+	netif_start_queue(netdev);
 
 	/* fire a link status change interrupt to start the watchdog */
 	ew32(ICS, E1000_ICS_LSC);
@@ -3600,7 +3602,6 @@ static void e1000_watchdog_task(struct work_struct *work)
 				phy->ops.cfg_on_link_up(hw);
 
 			netif_carrier_on(netdev);
-			netif_tx_wake_all_queues(netdev);
 
 			if (!test_bit(__E1000_DOWN, &adapter->state))
 				mod_timer(&adapter->phy_info_timer,
@@ -3614,7 +3615,6 @@ static void e1000_watchdog_task(struct work_struct *work)
 			printk(KERN_INFO "e1000e: %s NIC Link is Down\n",
 			       adapter->netdev->name);
 			netif_carrier_off(netdev);
-			netif_tx_stop_all_queues(netdev);
 			if (!test_bit(__E1000_DOWN, &adapter->state))
 				mod_timer(&adapter->phy_info_timer,
 					  round_jiffies(jiffies + 2 * HZ));
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index ceaa585..183235d 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -942,6 +942,8 @@ int igb_up(struct igb_adapter *adapter)
 	rd32(E1000_ICR);
 	igb_irq_enable(adapter);
 
+	netif_tx_start_all_queues(adapter->netdev);
+
 	/* Fire a link change interrupt to start the watchdog. */
 	wr32(E1000_ICS, E1000_ICS_LSC);
 	return 0;
@@ -2664,7 +2666,6 @@ static void igb_watchdog_task(struct work_struct *work)
 			}
 
 			netif_carrier_on(netdev);
-			netif_tx_wake_all_queues(netdev);
 
 			igb_ping_all_vfs(adapter);
 
@@ -2681,7 +2682,6 @@ static void igb_watchdog_task(struct work_struct *work)
 			printk(KERN_INFO "igb: %s NIC Link is Down\n",
 			       netdev->name);
 			netif_carrier_off(netdev);
-			netif_tx_stop_all_queues(netdev);
 
 			igb_ping_all_vfs(adapter);
 
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index ff741ca..cb9ecc4 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -266,6 +266,8 @@ ixgb_up(struct ixgb_adapter *adapter)
 	napi_enable(&adapter->napi);
 	ixgb_irq_enable(adapter);
 
+	netif_wake_queue(netdev);
+
 	mod_timer(&adapter->watchdog_timer, jiffies);
 
 	return 0;
@@ -1118,7 +1120,6 @@ ixgb_watchdog(unsigned long data)
 			adapter->link_speed = 10000;
 			adapter->link_duplex = FULL_DUPLEX;
 			netif_carrier_on(netdev);
-			netif_wake_queue(netdev);
 		}
 	} else {
 		if (netif_carrier_ok(netdev)) {
@@ -1127,8 +1128,6 @@ ixgb_watchdog(unsigned long data)
 			printk(KERN_INFO "ixgb: %s NIC Link is Down\n",
 			       netdev->name);
 			netif_carrier_off(netdev);
-			netif_stop_queue(netdev);
-
 		}
 	}
 

