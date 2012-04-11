From: Tony Zelenoff <antonz@parallels.com>
Subject: [PATCH] atl1: fix kernel panic in case of DMA errors
Date: Wed, 11 Apr 2012 20:15:03 +0400
Message-ID: <1334160903-988902-1-git-send-email-antonz@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <antonz@parallels.com>, <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:57146 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932364Ab2DKQUm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Apr 2012 12:20:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Problem:
There was two separate work_struct structures which share one
handler. Unfortunately getting atl1_adapter structure from
work_struct in case of DMA error was done from incorrect
offset which cause kernel panics.

Solution:
The useless work_struct for DMA error removed and
handler name changed to more generic one.

Signed-off-by: Tony Zelenoff <antonz@parallels.com>
---
 drivers/net/ethernet/atheros/atlx/atl1.c |   12 +++++-------
 drivers/net/ethernet/atheros/atlx/atl1.h |    3 +--
 drivers/net/ethernet/atheros/atlx/atlx.c |    2 +-
 3 files changed, 7 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
index 40ac414..c926857 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.c
+++ b/drivers/net/ethernet/atheros/atlx/atl1.c
@@ -2476,7 +2476,7 @@ static irqreturn_t atl1_intr(int irq, void *data)
 					"pcie phy link down %x\n", status);
 			if (netif_running(adapter->netdev)) {	/* reset MAC */
 				iowrite32(0, adapter->hw.hw_addr + REG_IMR);
-				schedule_work(&adapter->pcie_dma_to_rst_task);
+				schedule_work(&adapter->reset_dev_task);
 				return IRQ_HANDLED;
 			}
 		}
@@ -2488,7 +2488,7 @@ static irqreturn_t atl1_intr(int irq, void *data)
 					"pcie DMA r/w error (status = 0x%x)\n",
 					status);
 			iowrite32(0, adapter->hw.hw_addr + REG_IMR);
-			schedule_work(&adapter->pcie_dma_to_rst_task);
+			schedule_work(&adapter->reset_dev_task);
 			return IRQ_HANDLED;
 		}
 
@@ -2633,10 +2633,10 @@ static void atl1_down(struct atl1_adapter *adapter)
 	atl1_clean_rx_ring(adapter);
 }
 
-static void atl1_tx_timeout_task(struct work_struct *work)
+static void atl1_reset_dev_task(struct work_struct *work)
 {
 	struct atl1_adapter *adapter =
-		container_of(work, struct atl1_adapter, tx_timeout_task);
+		container_of(work, struct atl1_adapter, reset_dev_task);
 	struct net_device *netdev = adapter->netdev;
 
 	netif_device_detach(netdev);
@@ -3038,12 +3038,10 @@ static int __devinit atl1_probe(struct pci_dev *pdev,
 		    (unsigned long)adapter);
 	adapter->phy_timer_pending = false;
 
-	INIT_WORK(&adapter->tx_timeout_task, atl1_tx_timeout_task);
+	INIT_WORK(&adapter->reset_dev_task, atl1_reset_dev_task);
 
 	INIT_WORK(&adapter->link_chg_task, atlx_link_chg_task);
 
-	INIT_WORK(&adapter->pcie_dma_to_rst_task, atl1_tx_timeout_task);
-
 	err = register_netdev(netdev);
 	if (err)
 		goto err_common;
diff --git a/drivers/net/ethernet/atheros/atlx/atl1.h b/drivers/net/ethernet/atheros/atlx/atl1.h
index 109d6da..e04bf4d 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.h
+++ b/drivers/net/ethernet/atheros/atlx/atl1.h
@@ -758,9 +758,8 @@ struct atl1_adapter {
 	u16 link_speed;
 	u16 link_duplex;
 	spinlock_t lock;
-	struct work_struct tx_timeout_task;
+	struct work_struct reset_dev_task;
 	struct work_struct link_chg_task;
-	struct work_struct pcie_dma_to_rst_task;
 
 	struct timer_list phy_config_timer;
 	bool phy_timer_pending;
diff --git a/drivers/net/ethernet/atheros/atlx/atlx.c b/drivers/net/ethernet/atheros/atlx/atlx.c
index 3cd8837..c9e9dc5 100644
--- a/drivers/net/ethernet/atheros/atlx/atlx.c
+++ b/drivers/net/ethernet/atheros/atlx/atlx.c
@@ -194,7 +194,7 @@ static void atlx_tx_timeout(struct net_device *netdev)
 {
 	struct atlx_adapter *adapter = netdev_priv(netdev);
 	/* Do the reset outside of interrupt context */
-	schedule_work(&adapter->tx_timeout_task);
+	schedule_work(&adapter->reset_dev_task);
 }
 
 /*
-- 
1.7.1
