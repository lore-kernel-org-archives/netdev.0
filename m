From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 04/13] e1000: stop timers at appropriate times
Date: Fri, 25 Sep 2009 15:17:23 -0700
Message-ID: <20090925221723.26715.90597.stgit@localhost.localdomain>
References: <20090925221613.26715.66796.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.westchester.pa.mail.comcast.net ([76.96.62.16]:36676
	"EHLO QMTA01.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752732AbZIYWRk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2009 18:17:40 -0400
In-Reply-To: <20090925221613.26715.66796.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

there were some hotplug cases that made timers still run after the driver
had been removed, make sure to stop all the timers and not allow racy
reschedules.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000_main.c |   26 +++++++++++++++++++-------
 1 files changed, 19 insertions(+), 7 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 4d6677e..7af3255 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -1098,6 +1098,11 @@ static void __devexit e1000_remove(struct pci_dev *pdev)
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 
+	set_bit(__E1000_DOWN, &adapter->flags);
+	del_timer_sync(&adapter->tx_fifo_stall_timer);
+	del_timer_sync(&adapter->watchdog_timer);
+	del_timer_sync(&adapter->phy_info_timer);
+
 	cancel_work_sync(&adapter->reset_task);
 
 	e1000_release_manageability(adapter);
@@ -2240,7 +2245,7 @@ static void e1000_82547_tx_fifo_stall(unsigned long data)
 			adapter->tx_fifo_head = 0;
 			atomic_set(&adapter->tx_fifo_stall, 0);
 			netif_wake_queue(netdev);
-		} else {
+		} else if (!test_bit(__E1000_DOWN, &adapter->flags)) {
 			mod_timer(&adapter->tx_fifo_stall_timer, jiffies + 1);
 		}
 	}
@@ -2309,8 +2314,9 @@ static void e1000_watchdog(unsigned long data)
 			ew32(TCTL, tctl);
 
 			netif_carrier_on(netdev);
-			mod_timer(&adapter->phy_info_timer,
-			          round_jiffies(jiffies + 2 * HZ));
+			if (!test_bit(__E1000_DOWN, &adapter->flags))
+				mod_timer(&adapter->phy_info_timer,
+				          round_jiffies(jiffies + 2 * HZ));
 			adapter->smartspeed = 0;
 		}
 	} else {
@@ -2320,8 +2326,10 @@ static void e1000_watchdog(unsigned long data)
 			printk(KERN_INFO "e1000: %s NIC Link is Down\n",
 			       netdev->name);
 			netif_carrier_off(netdev);
-			mod_timer(&adapter->phy_info_timer,
-			          round_jiffies(jiffies + 2 * HZ));
+
+			if (!test_bit(__E1000_DOWN, &adapter->flags))
+				mod_timer(&adapter->phy_info_timer,
+				          round_jiffies(jiffies + 2 * HZ));
 		}
 
 		e1000_smartspeed(adapter);
@@ -2361,7 +2369,9 @@ static void e1000_watchdog(unsigned long data)
 	adapter->detect_tx_hung = true;
 
 	/* Reset the timer */
-	mod_timer(&adapter->watchdog_timer, round_jiffies(jiffies + 2 * HZ));
+	if (!test_bit(__E1000_DOWN, &adapter->flags))
+		mod_timer(&adapter->watchdog_timer,
+		          round_jiffies(jiffies + 2 * HZ));
 }
 
 enum latency_range {
@@ -2977,7 +2987,9 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 	if (unlikely(hw->mac_type == e1000_82547)) {
 		if (unlikely(e1000_82547_fifo_workaround(adapter, skb))) {
 			netif_stop_queue(netdev);
-			mod_timer(&adapter->tx_fifo_stall_timer, jiffies + 1);
+			if (!test_bit(__E1000_DOWN, &adapter->flags))
+				mod_timer(&adapter->tx_fifo_stall_timer,
+				          jiffies + 1);
 			return NETDEV_TX_BUSY;
 		}
 	}

