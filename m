From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next #2 10/39] fealnx: stop using net_device.{base_addr, irq}.
Date: Fri,  6 Apr 2012 12:06:24 +0200
Message-ID: <7db239c57d31d1d3fdc73e22b27ed9c46fc1da65.1333704409.git.romieu@fr.zoreil.com>
References: <1333704408.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:43442 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755877Ab2DFKKh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Apr 2012 06:10:37 -0400
In-Reply-To: <1333704408.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/fealnx.c |   17 ++++++++---------
 1 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/fealnx.c b/drivers/net/ethernet/fealnx.c
index 1637b98..328c631 100644
--- a/drivers/net/ethernet/fealnx.c
+++ b/drivers/net/ethernet/fealnx.c
@@ -545,9 +545,6 @@ static int __devinit fealnx_init_one(struct pci_dev *pdev,
 	/* Reset the chip to erase previous misconfiguration. */
 	iowrite32(0x00000001, ioaddr + BCR);
 
-	dev->base_addr = (unsigned long)ioaddr;
-	dev->irq = irq;
-
 	/* Make certain the descriptor lists are aligned. */
 	np = netdev_priv(dev);
 	np->mem = ioaddr;
@@ -832,12 +829,14 @@ static int netdev_open(struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
 	void __iomem *ioaddr = np->mem;
-	int i;
+	const int irq = np->pci_dev->irq;
+	int rc, i;
 
 	iowrite32(0x00000001, ioaddr + BCR);	/* Reset */
 
-	if (request_irq(dev->irq, intr_handler, IRQF_SHARED, dev->name, dev))
-		return -EAGAIN;
+	rc = request_irq(irq, intr_handler, IRQF_SHARED, dev->name, dev);
+	if (rc < 0)
+		goto out;
 
 	for (i = 0; i < 3; i++)
 		iowrite16(((unsigned short*)dev->dev_addr)[i],
@@ -924,8 +923,8 @@ static int netdev_open(struct net_device *dev)
 	np->reset_timer.data = (unsigned long) dev;
 	np->reset_timer.function = reset_timer;
 	np->reset_timer_armed = 0;
-
-	return 0;
+out:
+	return rc;
 }
 
 
@@ -1910,7 +1909,7 @@ static int netdev_close(struct net_device *dev)
 	del_timer_sync(&np->timer);
 	del_timer_sync(&np->reset_timer);
 
-	free_irq(dev->irq, dev);
+	free_irq(np->pci_dev->irq, dev);
 
 	/* Free all the skbuffs in the Rx queue. */
 	for (i = 0; i < RX_RING_SIZE; i++) {
-- 
1.7.7.6
