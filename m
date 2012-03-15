From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 20/34] sis190: stop using net_device.{base_addr, irq}
Date: Thu, 15 Mar 2012 14:57:17 +0100
Message-ID: <1febab2c8e194b96da9d418d00aee5c32c6414fa.1331814082.git.romieu@fr.zoreil.com>
References: <cover.1331814082.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:51858 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1761118Ab2CON7q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2012 09:59:46 -0400
In-Reply-To: <cover.1331814082.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/sis/sis190.c |   26 +++++++++++---------------
 1 files changed, 11 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/sis/sis190.c b/drivers/net/ethernet/sis/sis190.c
index a9deda8..4613591 100644
--- a/drivers/net/ethernet/sis/sis190.c
+++ b/drivers/net/ethernet/sis/sis190.c
@@ -729,7 +729,7 @@ static void sis190_tx_interrupt(struct net_device *dev,
  * The interrupt handler does all of the Rx thread work and cleans up after
  * the Tx thread.
  */
-static irqreturn_t sis190_interrupt(int irq, void *__dev)
+static irqreturn_t sis190_irq(int irq, void *__dev)
 {
 	struct net_device *dev = __dev;
 	struct sis190_private *tp = netdev_priv(dev);
@@ -772,11 +772,11 @@ out:
 static void sis190_netpoll(struct net_device *dev)
 {
 	struct sis190_private *tp = netdev_priv(dev);
-	struct pci_dev *pdev = tp->pci_dev;
+	const int irq = tp->pci_dev->irq;
 
-	disable_irq(pdev->irq);
-	sis190_interrupt(pdev->irq, dev);
-	enable_irq(pdev->irq);
+	disable_irq(irq);
+	sis190_irq(irq, dev);
+	enable_irq(irq);
 }
 #endif
 
@@ -1085,7 +1085,7 @@ static int sis190_open(struct net_device *dev)
 
 	sis190_request_timer(dev);
 
-	rc = request_irq(dev->irq, sis190_interrupt, IRQF_SHARED, dev->name, dev);
+	rc = request_irq(pdev->irq, sis190_irq, IRQF_SHARED, dev->name, dev);
 	if (rc < 0)
 		goto err_release_timer_2;
 
@@ -1097,11 +1097,9 @@ err_release_timer_2:
 	sis190_delete_timer(dev);
 	sis190_rx_clear(tp);
 err_free_rx_1:
-	pci_free_consistent(tp->pci_dev, RX_RING_BYTES, tp->RxDescRing,
-		tp->rx_dma);
+	pci_free_consistent(pdev, RX_RING_BYTES, tp->RxDescRing, tp->rx_dma);
 err_free_tx_0:
-	pci_free_consistent(tp->pci_dev, TX_RING_BYTES, tp->TxDescRing,
-		tp->tx_dma);
+	pci_free_consistent(pdev, TX_RING_BYTES, tp->TxDescRing, tp->tx_dma);
 	goto out;
 }
 
@@ -1141,7 +1139,7 @@ static void sis190_down(struct net_device *dev)
 
 		spin_unlock_irq(&tp->lock);
 
-		synchronize_irq(dev->irq);
+		synchronize_irq(tp->pci_dev->irq);
 
 		if (!poll_locked)
 			poll_locked++;
@@ -1161,7 +1159,7 @@ static int sis190_close(struct net_device *dev)
 
 	sis190_down(dev);
 
-	free_irq(dev->irq, dev);
+	free_irq(pdev->irq, dev);
 
 	pci_free_consistent(pdev, TX_RING_BYTES, tp->TxDescRing, tp->tx_dma);
 	pci_free_consistent(pdev, RX_RING_BYTES, tp->RxDescRing, tp->rx_dma);
@@ -1884,8 +1882,6 @@ static int __devinit sis190_init_one(struct pci_dev *pdev,
 	dev->netdev_ops = &sis190_netdev_ops;
 
 	SET_ETHTOOL_OPS(dev, &sis190_ethtool_ops);
-	dev->irq = pdev->irq;
-	dev->base_addr = (unsigned long) 0xdead;
 	dev->watchdog_timeo = SIS190_TX_TIMEOUT;
 
 	spin_lock_init(&tp->lock);
@@ -1902,7 +1898,7 @@ static int __devinit sis190_init_one(struct pci_dev *pdev,
 		netdev_info(dev, "%s: %s at %p (IRQ: %d), %pM\n",
 			    pci_name(pdev),
 			    sis_chip_info[ent->driver_data].name,
-			    ioaddr, dev->irq, dev->dev_addr);
+			    ioaddr, pdev->irq, dev->dev_addr);
 		netdev_info(dev, "%s mode.\n",
 			    (tp->features & F_HAS_RGMII) ? "RGMII" : "GMII");
 	}
-- 
1.7.7.6
