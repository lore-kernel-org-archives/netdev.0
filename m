From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next #2 15/39] starfire: stop using net_device.{base_addr, irq}.
Date: Fri,  6 Apr 2012 12:06:29 +0200
Message-ID: <923387c00c92b368ae7906952817cbd1d014fe4c.1333704409.git.romieu@fr.zoreil.com>
References: <1333704408.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>,
	Ion Badulescu <ionut@badula.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:43446 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755923Ab2DFKKh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Apr 2012 06:10:37 -0400
In-Reply-To: <1333704408.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's useless to check mem_start on a newly allocated device as well.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Ion Badulescu <ionut@badula.org>
---
 drivers/net/ethernet/adaptec/starfire.c |   14 +++++---------
 1 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/adaptec/starfire.c b/drivers/net/ethernet/adaptec/starfire.c
index d896816..4f27bff 100644
--- a/drivers/net/ethernet/adaptec/starfire.c
+++ b/drivers/net/ethernet/adaptec/starfire.c
@@ -753,9 +753,6 @@ static int __devinit starfire_init_one(struct pci_dev *pdev,
 	/* wait a little longer */
 	udelay(1000);
 
-	dev->base_addr = (unsigned long)base;
-	dev->irq = irq;
-
 	np = netdev_priv(dev);
 	np->dev = dev;
 	np->base = base;
@@ -773,8 +770,6 @@ static int __devinit starfire_init_one(struct pci_dev *pdev,
 	drv_flags = netdrv_tbl[chip_idx].drv_flags;
 
 	option = card_idx < MAX_UNITS ? options[card_idx] : 0;
-	if (dev->mem_start)
-		option = dev->mem_start;
 
 	/* The lower four bits are the media type. */
 	if (option & 0x200)
@@ -909,13 +904,14 @@ static int netdev_open(struct net_device *dev)
 	const __be32 *fw_rx_data, *fw_tx_data;
 	struct netdev_private *np = netdev_priv(dev);
 	void __iomem *ioaddr = np->base;
+	const int irq = np->pci_dev->irq;
 	int i, retval;
 	size_t tx_size, rx_size;
 	size_t tx_done_q_size, rx_done_q_size, tx_ring_size, rx_ring_size;
 
 	/* Do we ever need to reset the chip??? */
 
-	retval = request_irq(dev->irq, intr_handler, IRQF_SHARED, dev->name, dev);
+	retval = request_irq(irq, intr_handler, IRQF_SHARED, dev->name, dev);
 	if (retval)
 		return retval;
 
@@ -924,7 +920,7 @@ static int netdev_open(struct net_device *dev)
 	writel(1, ioaddr + PCIDeviceConfig);
 	if (debug > 1)
 		printk(KERN_DEBUG "%s: netdev_open() irq %d.\n",
-		       dev->name, dev->irq);
+		       dev->name, irq);
 
 	/* Allocate the various queues. */
 	if (!np->queue_mem) {
@@ -935,7 +931,7 @@ static int netdev_open(struct net_device *dev)
 		np->queue_mem_size = tx_done_q_size + rx_done_q_size + tx_ring_size + rx_ring_size;
 		np->queue_mem = pci_alloc_consistent(np->pci_dev, np->queue_mem_size, &np->queue_mem_dma);
 		if (np->queue_mem == NULL) {
-			free_irq(dev->irq, dev);
+			free_irq(irq, dev);
 			return -ENOMEM;
 		}
 
@@ -1962,7 +1958,7 @@ static int netdev_close(struct net_device *dev)
 		}
 	}
 
-	free_irq(dev->irq, dev);
+	free_irq(np->pci_dev->irq, dev);
 
 	/* Free all the skbuffs in the Rx queue. */
 	for (i = 0; i < RX_RING_SIZE; i++) {
-- 
1.7.7.6
