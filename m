From: <jie.yang@atheros.com>
Subject: [PATCH net-next]atl1c:use common_task instead of reset_task and link_chg_task
Date: Mon, 7 Dec 2009 17:16:58 +0800
Message-ID: <1260177418354-git-send-email-jie.yang@atheros.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <cmatei@profis.ro>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, Jie Yang <jie.yang@atheros.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.atheros.com ([12.36.123.2]:40591 "EHLO mail.atheros.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757674AbZLGJQz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Dec 2009 04:16:55 -0500
Received: from mail.atheros.com ([10.10.20.108])
	by sidewinder.atheros.com
	for <netdev@vger.kernel.org>; Mon, 07 Dec 2009 01:17:02 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jie Yang <jie.yang@atheros.com>

use common_task instead of reset_task and link_chg_task, so it fix "call cancel_work_sync
from the work itself".

Signed-off-by: Jie Yang <jie.yang@atheros.com>
---

 drivers/net/atl1c/atl1c.h      |    6 ++-
 drivers/net/atl1c/atl1c_main.c |   72 ++++++++++++++++++---------------------
 2 files changed, 37 insertions(+), 41 deletions(-)

diff --git a/drivers/net/atl1c/atl1c.h b/drivers/net/atl1c/atl1c.h
index a348a22..b020723 100644
--- a/drivers/net/atl1c/atl1c.h
+++ b/drivers/net/atl1c/atl1c.h
@@ -550,6 +550,9 @@ struct atl1c_adapter {
 #define __AT_TESTING        0x0001
 #define __AT_RESETTING      0x0002
 #define __AT_DOWN           0x0003
+	u8 work_event;
+#define ATL1C_WORK_EVENT_RESET 		0x01
+#define ATL1C_WORK_EVENT_LINK_CHANGE	0x02
 	u32 msg_enable;
 
 	bool have_msi;
@@ -561,8 +564,7 @@ struct atl1c_adapter {
 	spinlock_t tx_lock;
 	atomic_t irq_sem;
 
-	struct work_struct reset_task;
-	struct work_struct link_chg_task;
+	struct work_struct common_task;
 	struct timer_list watchdog_timer;
 	struct timer_list phy_config_timer;
 
diff --git a/drivers/net/atl1c/atl1c_main.c b/drivers/net/atl1c/atl1c_main.c
index 1e2f57d..c6c8fe8 100644
--- a/drivers/net/atl1c/atl1c_main.c
+++ b/drivers/net/atl1c/atl1c_main.c
@@ -198,27 +198,12 @@ static void atl1c_phy_config(unsigned long data)
 
 void atl1c_reinit_locked(struct atl1c_adapter *adapter)
 {
-
 	WARN_ON(in_interrupt());
 	atl1c_down(adapter);
 	atl1c_up(adapter);
 	clear_bit(__AT_RESETTING, &adapter->flags);
 }
 
-static void atl1c_reset_task(struct work_struct *work)
-{
-	struct atl1c_adapter *adapter;
-	struct net_device *netdev;
-
-	adapter = container_of(work, struct atl1c_adapter, reset_task);
-	netdev = adapter->netdev;
-
-	netif_device_detach(netdev);
-	atl1c_down(adapter);
-	atl1c_up(adapter);
-	netif_device_attach(netdev);
-}
-
 static void atl1c_check_link_status(struct atl1c_adapter *adapter)
 {
 	struct atl1c_hw *hw = &adapter->hw;
@@ -275,18 +260,6 @@ static void atl1c_check_link_status(struct atl1c_adapter *adapter)
 	}
 }
 
-/*
- * atl1c_link_chg_task - deal with link change event Out of interrupt context
- * @netdev: network interface device structure
- */
-static void atl1c_link_chg_task(struct work_struct *work)
-{
-	struct atl1c_adapter *adapter;
-
-	adapter = container_of(work, struct atl1c_adapter, link_chg_task);
-	atl1c_check_link_status(adapter);
-}
-
 static void atl1c_link_chg_event(struct atl1c_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
@@ -311,20 +284,40 @@ static void atl1c_link_chg_event(struct atl1c_adapter *adapter)
 			adapter->link_speed = SPEED_0;
 		}
 	}
-	schedule_work(&adapter->link_chg_task);
+
+	adapter->work_event |= ATL1C_WORK_EVENT_LINK_CHANGE;
+	schedule_work(&adapter->common_task);
 }
 
-static void atl1c_del_timer(struct atl1c_adapter *adapter)
+static void atl1c_common_task(struct work_struct *work)
 {
-	del_timer_sync(&adapter->phy_config_timer);
+	struct atl1c_adapter *adapter;
+	struct net_device *netdev;
+
+	adapter = container_of(work, struct atl1c_adapter, common_task);
+	netdev = adapter->netdev;
+
+	if (adapter->work_event & ATL1C_WORK_EVENT_RESET) {
+		netif_device_detach(netdev);
+		atl1c_down(adapter);
+		atl1c_up(adapter);
+		netif_device_attach(netdev);
+		return;
+	}
+
+	if (adapter->work_event & ATL1C_WORK_EVENT_LINK_CHANGE)
+		atl1c_check_link_status(adapter);
+
+	return;
 }
 
-static void atl1c_cancel_work(struct atl1c_adapter *adapter)
+
+static void atl1c_del_timer(struct atl1c_adapter *adapter)
 {
-	cancel_work_sync(&adapter->reset_task);
-	cancel_work_sync(&adapter->link_chg_task);
+	del_timer_sync(&adapter->phy_config_timer);
 }
 
+
 /*
  * atl1c_tx_timeout - Respond to a Tx Hang
  * @netdev: network interface device structure
@@ -334,7 +327,8 @@ static void atl1c_tx_timeout(struct net_device *netdev)
 	struct atl1c_adapter *adapter = netdev_priv(netdev);
 
 	/* Do the reset outside of interrupt context */
-	schedule_work(&adapter->reset_task);
+	adapter->work_event |= ATL1C_WORK_EVENT_RESET;
+	schedule_work(&adapter->common_task);
 }
 
 /*
@@ -1533,7 +1527,8 @@ static irqreturn_t atl1c_intr(int irq, void *data)
 			/* reset MAC */
 			hw->intr_mask &= ~ISR_ERROR;
 			AT_WRITE_REG(hw, REG_IMR, hw->intr_mask);
-			schedule_work(&adapter->reset_task);
+			adapter->work_event |= ATL1C_WORK_EVENT_RESET;
+			schedule_work(&adapter->common_task);
 			break;
 		}
 
@@ -2198,8 +2193,7 @@ void atl1c_down(struct atl1c_adapter *adapter)
 	struct net_device *netdev = adapter->netdev;
 
 	atl1c_del_timer(adapter);
-	atl1c_cancel_work(adapter);
-
+	adapter->work_event = 0; /* clear all event */
 	/* signal that we're down so the interrupt handler does not
 	 * reschedule our watchdog timer */
 	set_bit(__AT_DOWN, &adapter->flags);
@@ -2599,8 +2593,8 @@ static int __devinit atl1c_probe(struct pci_dev *pdev,
 			adapter->hw.mac_addr[4], adapter->hw.mac_addr[5]);
 
 	atl1c_hw_set_mac_addr(&adapter->hw);
-	INIT_WORK(&adapter->reset_task, atl1c_reset_task);
-	INIT_WORK(&adapter->link_chg_task, atl1c_link_chg_task);
+	INIT_WORK(&adapter->common_task, atl1c_common_task);
+	adapter->work_event = 0;
 	err = register_netdev(netdev);
 	if (err) {
 		dev_err(&pdev->dev, "register netdevice failed\n");
