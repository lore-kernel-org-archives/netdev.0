From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 19/26] atl1: modernize down/up functions
Date: Mon, 31 Dec 2007 20:22:46 -0600
Message-ID: <1199154173-4058-20-git-send-email-jacliburn@bellsouth.net>
References: <1199154173-4058-1-git-send-email-jacliburn@bellsouth.net>
Cc: Jay Cliburn <jacliburn@bellsouth.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost03.isp.att.net ([207.115.11.53]:64476 "EHLO
	fmailhost03.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751800AbYAAC2M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 21:28:12 -0500
In-Reply-To: <1199154173-4058-1-git-send-email-jacliburn@bellsouth.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update atl1_down() and atl1_up() to conform with the current vendor driver
version 1.2.40.2.

Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---
 drivers/net/atlx/atl1.c |   21 ++++++++-------------
 drivers/net/atlx/atl1.h |    1 -
 drivers/net/atlx/atlx.c |    2 +-
 3 files changed, 9 insertions(+), 15 deletions(-)

diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index 7697e80..972de34 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -2388,7 +2388,6 @@ static s32 atl1_up(struct atl1_adapter *adapter)
 	}
 
 	clear_bit(__ATL1_DOWN, &adapter->flags);
-	mod_timer(&adapter->watchdog_timer, jiffies + (4 * HZ));
 	retval = ioread32(&adapter->hw + REG_MASTER_CTRL);
 	retval |= MASTER_CTRL_MANUAL_INT;
 	iowrite32(retval, &adapter->hw + REG_MASTER_CTRL);
@@ -2401,21 +2400,18 @@ void atl1_down(struct atl1_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 
-	del_timer_sync(&adapter->watchdog_timer);
-	del_timer_sync(&adapter->phy_config_timer);
-	adapter->phy_timer_pending = false;
-
-	atlx_irq_disable(adapter);
-	free_irq(adapter->pdev->irq, netdev);
-	pci_disable_msi(adapter->pdev);
+	set_bit(__ATL1_DOWN, &adapter->flags);
+	netif_stop_queue(netdev);
 	atl1_reset_hw(&adapter->hw);
 	adapter->cmb.cmb->int_stats = 0;
-
+	msleep(1);
+	atlx_irq_disable(adapter);
+	del_timer_sync(&adapter->watchdog_timer);
+	del_timer_sync(&adapter->phy_config_timer);
+	clear_bit(0, &adapter->cfg_phy);
+	netif_carrier_off(netdev);
 	adapter->link_speed = SPEED_0;
 	adapter->link_duplex = -1;
-	netif_carrier_off(netdev);
-	netif_stop_queue(netdev);
-
 	atl1_clean_tx_ring(adapter);
 	atl1_clean_rx_ring(adapter);
 }
@@ -2821,7 +2817,6 @@ static int __devinit atl1_probe(struct pci_dev *pdev,
 	init_timer(&adapter->phy_config_timer);
 	adapter->phy_config_timer.function = &atl1_phy_config;
 	adapter->phy_config_timer.data = (unsigned long)adapter;
-	adapter->phy_timer_pending = false;
 
 	INIT_WORK(&adapter->reset_task, atl1_reset_task);
 	INIT_WORK(&adapter->link_chg_task, atlx_link_chg_task);
diff --git a/drivers/net/atlx/atl1.h b/drivers/net/atlx/atl1.h
index 1f245e0..5187f74 100644
--- a/drivers/net/atlx/atl1.h
+++ b/drivers/net/atlx/atl1.h
@@ -790,7 +790,6 @@ struct atl1_adapter {
 	struct work_struct link_chg_task;
 	struct timer_list watchdog_timer;
 	struct timer_list phy_config_timer;
-	bool phy_timer_pending;
 	unsigned long cfg_phy;
 
 	/* all descriptor rings' memory */
diff --git a/drivers/net/atlx/atlx.c b/drivers/net/atlx/atlx.c
index 18c2d7e..9cc9441 100644
--- a/drivers/net/atlx/atlx.c
+++ b/drivers/net/atlx/atlx.c
@@ -91,7 +91,6 @@ static void atlx_check_for_link(struct atlx_adapter *adapter)
 	u16 phy_data = 0;
 
 	spin_lock(&adapter->lock);
-	adapter->phy_timer_pending = false;
 	atlx_read_phy_reg(&adapter->hw, MII_BMSR, &phy_data);
 	atlx_read_phy_reg(&adapter->hw, MII_BMSR, &phy_data);
 	spin_unlock(&adapter->lock);
@@ -104,6 +103,7 @@ static void atlx_check_for_link(struct atlx_adapter *adapter)
 			dev_info(&adapter->pdev->dev, "%s link is down\n",
 				netdev->name);
 			adapter->link_speed = SPEED_0;
+			clear_bit(0, &adapter->hw.force_ps);
 			netif_carrier_off(netdev);
 			netif_stop_queue(netdev);
 		}
-- 
1.5.3.3

