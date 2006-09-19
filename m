From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 17/23] e1000: driver state fixes (race fix)
Date: Tue, 19 Sep 2006 10:29:11 -0700
Message-ID: <20060919172911.4605.26281.stgit@gitlost.site>
References: <20060919172623.4605.56860.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:27917 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1030351AbWISRUQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 13:20:16 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060919172623.4605.56860.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


We were plagued by our interrupt handler posting a watchdog event which
could occur when our adapter was going down in case a late packet arrived
just before e1000_down() finished. This caused the watchdog timer to start
after the NIC was down and keep rescheduling it every N seconds. Once
the driver unloaded it would panic.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000.h         |    3 ++-
 drivers/net/e1000/e1000_ethtool.c |    6 +++---
 drivers/net/e1000/e1000_main.c    |   28 ++++++++++++++++++----------
 3 files changed, 23 insertions(+), 14 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index a9501e7..7ecce43 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -345,8 +345,9 @@ struct e1000_adapter {
 };
 
 enum e1000_state_t {
-	__E1000_DRIVER_TESTING,
+	__E1000_TESTING,
 	__E1000_RESETTING,
+	__E1000_DOWN
 };
 
 #endif /* _E1000_H_ */
diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index d8b9c3f..ea8dfe4 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -1624,7 +1624,7 @@ e1000_diag_test(struct net_device *netde
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	boolean_t if_running = netif_running(netdev);
 
-	set_bit(__E1000_DRIVER_TESTING, &adapter->flags);
+	set_bit(__E1000_TESTING, &adapter->flags);
 	if (eth_test->flags == ETH_TEST_FL_OFFLINE) {
 		/* Offline tests */
 
@@ -1669,7 +1669,7 @@ e1000_diag_test(struct net_device *netde
 		adapter->hw.autoneg = autoneg;
 
 		e1000_reset(adapter);
-		clear_bit(__E1000_DRIVER_TESTING, &adapter->flags);
+		clear_bit(__E1000_TESTING, &adapter->flags);
 		if (if_running)
 			dev_open(netdev);
 	} else {
@@ -1684,7 +1684,7 @@ e1000_diag_test(struct net_device *netde
 		data[2] = 0;
 		data[3] = 0;
 
-		clear_bit(__E1000_DRIVER_TESTING, &adapter->flags);
+		clear_bit(__E1000_TESTING, &adapter->flags);
 	}
 	msleep_interruptible(4 * 1000);
 }
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 07082e7..7a991a4 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -476,13 +476,14 @@ e1000_up(struct e1000_adapter *adapter)
 
 	adapter->tx_queue_len = netdev->tx_queue_len;
 
-	mod_timer(&adapter->watchdog_timer, jiffies);
-
 #ifdef CONFIG_E1000_NAPI
 	netif_poll_enable(netdev);
 #endif
 	e1000_irq_enable(adapter);
 
+	clear_bit(__E1000_DOWN, &adapter->flags);
+
+	mod_timer(&adapter->watchdog_timer, jiffies + 2 * HZ);
 	return 0;
 }
 
@@ -561,6 +562,10 @@ e1000_down(struct e1000_adapter *adapter
 {
 	struct net_device *netdev = adapter->netdev;
 
+	/* signal that we're down so the interrupt handler does not
+	 * reschedule our watchdog timer */
+	set_bit(__E1000_DOWN, &adapter->flags);
+
 	e1000_irq_disable(adapter);
 
 	del_timer_sync(&adapter->tx_fifo_stall_timer);
@@ -903,11 +908,6 @@ e1000_probe(struct pci_dev *pdev,
 	INIT_WORK(&adapter->reset_task,
 		(void (*)(void *))e1000_reset_task, netdev);
 
-	/* we're going to reset, so assume we have no link for now */
-
-	netif_carrier_off(netdev);
-	netif_stop_queue(netdev);
-
 	e1000_check_options(adapter);
 
 	/* Initial Wake on LAN setting
@@ -1014,6 +1014,10 @@ e1000_probe(struct pci_dev *pdev,
 	if ((err = register_netdev(netdev)))
 		goto err_register;
 
+	/* tell the stack to leave us alone until e1000_open() is called */
+	netif_carrier_off(netdev);
+	netif_stop_queue(netdev);
+
 	DPRINTK(PROBE, INFO, "Intel(R) PRO/1000 Network Connection\n");
 
 	cards_found++;
@@ -1200,6 +1204,8 @@ e1000_sw_init(struct e1000_adapter *adap
 	atomic_set(&adapter->irq_sem, 1);
 	spin_lock_init(&adapter->stats_lock);
 
+	set_bit(__E1000_DOWN, &adapter->flags);
+
 	return 0;
 }
 
@@ -1265,7 +1271,7 @@ e1000_open(struct net_device *netdev)
 	int err;
 
 	/* disallow open during test */
-	if (test_bit(__E1000_DRIVER_TESTING, &adapter->flags))
+	if (test_bit(__E1000_TESTING, &adapter->flags))
 		return -EBUSY;
 
 	/* allocate transmit descriptors */
@@ -3072,7 +3078,7 @@ e1000_xmit_frame(struct sk_buff *skb, st
 	if (unlikely(adapter->hw.mac_type == e1000_82547)) {
 		if (unlikely(e1000_82547_fifo_workaround(adapter, skb))) {
 			netif_stop_queue(netdev);
-			mod_timer(&adapter->tx_fifo_stall_timer, jiffies);
+			mod_timer(&adapter->tx_fifo_stall_timer, jiffies + 1);
 			spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
 			return NETDEV_TX_BUSY;
 		}
@@ -3469,7 +3475,9 @@ e1000_intr(int irq, void *data, struct p
 			rctl = E1000_READ_REG(hw, RCTL);
 			E1000_WRITE_REG(hw, RCTL, rctl & ~E1000_RCTL_EN);
 		}
-		mod_timer(&adapter->watchdog_timer, jiffies);
+		/* guard against interrupt when we're going down */
+		if (!test_bit(__E1000_DOWN, &adapter->flags))
+			mod_timer(&adapter->watchdog_timer, jiffies + 1);
 	}
 
 #ifdef CONFIG_E1000_NAPI



---
Auke Kok <auke-jan.h.kok@intel.com>
