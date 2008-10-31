From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/2] atlx: timer cleanup
Date: Fri, 31 Oct 2008 16:52:04 -0700
Message-ID: <20081031235325.781544260@vyatta.com>
References: <20081031235202.019379082@vyatta.com>
Cc: netdev@vger.kernel.org
To: Jay Cliburn <jacliburn@bellsouth.net>,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:52173 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752218AbYJaXy3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Oct 2008 19:54:29 -0400
Content-Disposition: inline; filename=alt-timer.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do some cleanup on timer usage in this driver:
  * Use round_jiffies to align wakeups and reduce power.
  * Remove atl1_watchdog which does nothing but rearm itself
  * Use setup_timer() function

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/atlx/atl1.c	2008-10-31 16:47:20.000000000 -0700
+++ b/drivers/net/atlx/atl1.c	2008-10-31 16:48:04.000000000 -0700
@@ -1390,7 +1390,8 @@ static u32 atl1_check_link(struct atl1_a
 	/* auto-neg, insert timer to re-config phy */
 	if (!adapter->phy_timer_pending) {
 		adapter->phy_timer_pending = true;
-		mod_timer(&adapter->phy_config_timer, jiffies + 3 * HZ);
+		mod_timer(&adapter->phy_config_timer,
+			  round_jiffies(jiffies + 3 * HZ));
 	}
 
 	return 0;
@@ -2524,17 +2525,6 @@ static irqreturn_t atl1_intr(int irq, vo
 	return IRQ_HANDLED;
 }
 
-/*
- * atl1_watchdog - Timer Call-back
- * @data: pointer to netdev cast into an unsigned long
- */
-static void atl1_watchdog(unsigned long data)
-{
-	struct atl1_adapter *adapter = (struct atl1_adapter *)data;
-
-	/* Reset the timer */
-	mod_timer(&adapter->watchdog_timer, jiffies + 2 * HZ);
-}
 
 /*
  * atl1_phy_config - Timer Call-back
@@ -2607,7 +2597,6 @@ static s32 atl1_up(struct atl1_adapter *
 	if (unlikely(err))
 		goto err_up;
 
-	mod_timer(&adapter->watchdog_timer, jiffies);
 	atlx_irq_enable(adapter);
 	atl1_check_link(adapter);
 	netif_start_queue(netdev);
@@ -2625,7 +2614,6 @@ static void atl1_down(struct atl1_adapte
 	struct net_device *netdev = adapter->netdev;
 
 	netif_stop_queue(netdev);
-	del_timer_sync(&adapter->watchdog_timer);
 	del_timer_sync(&adapter->phy_config_timer);
 	adapter->phy_timer_pending = false;
 
@@ -3049,13 +3037,8 @@ static int __devinit atl1_probe(struct p
 	netif_carrier_off(netdev);
 	netif_stop_queue(netdev);
 
-	init_timer(&adapter->watchdog_timer);
-	adapter->watchdog_timer.function = &atl1_watchdog;
-	adapter->watchdog_timer.data = (unsigned long)adapter;
-
-	init_timer(&adapter->phy_config_timer);
-	adapter->phy_config_timer.function = &atl1_phy_config;
-	adapter->phy_config_timer.data = (unsigned long)adapter;
+	setup_timer(&adapter->phy_config_timer, &atl1_phy_config,
+		    (unsigned long)adapter);
 	adapter->phy_timer_pending = false;
 
 	INIT_WORK(&adapter->tx_timeout_task, atl1_tx_timeout_task);
--- a/drivers/net/atlx/atl1.h	2008-10-31 16:47:20.000000000 -0700
+++ b/drivers/net/atlx/atl1.h	2008-10-31 16:48:24.000000000 -0700
@@ -765,7 +765,7 @@ struct atl1_adapter {
 	struct work_struct tx_timeout_task;
 	struct work_struct link_chg_task;
 	struct work_struct pcie_dma_to_rst_task;
-	struct timer_list watchdog_timer;
+
 	struct timer_list phy_config_timer;
 	bool phy_timer_pending;
 
--- a/drivers/net/atlx/atl2.c	2008-10-31 16:47:20.000000000 -0700
+++ b/drivers/net/atlx/atl2.c	2008-10-31 16:47:47.000000000 -0700
@@ -724,7 +724,7 @@ static int atl2_open(struct net_device *
 
 	clear_bit(__ATL2_DOWN, &adapter->flags);
 
-	mod_timer(&adapter->watchdog_timer, jiffies + 4*HZ);
+	mod_timer(&adapter->watchdog_timer, round_jiffies(jiffies + 4*HZ));
 
 	val = ATL2_READ_REG(&adapter->hw, REG_MASTER_CTRL);
 	ATL2_WRITE_REG(&adapter->hw, REG_MASTER_CTRL,
@@ -1051,7 +1051,8 @@ static void atl2_watchdog(unsigned long 
 		adapter->netdev->stats.rx_over_errors += drop_rxd + drop_rxs;
 
 		/* Reset the timer */
-		mod_timer(&adapter->watchdog_timer, jiffies + 4 * HZ);
+		mod_timer(&adapter->watchdog_timer,
+			  round_jiffies(jiffies + 4 * HZ));
 	}
 }
 
@@ -1255,7 +1256,8 @@ static int atl2_check_link(struct atl2_a
 	 * (if interval smaller than 5 seconds, something strange) */
 	if (!test_bit(__ATL2_DOWN, &adapter->flags)) {
 		if (!test_and_set_bit(0, &adapter->cfg_phy))
-			mod_timer(&adapter->phy_config_timer, jiffies + 5 * HZ);
+			mod_timer(&adapter->phy_config_timer,
+				  round_jiffies(jiffies + 5 * HZ));
 	}
 
 	return 0;

-- 

