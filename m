From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: via_rhine kernel crashes in 2.6.32
Date: Tue, 22 Dec 2009 13:21:07 +0000
Message-ID: <20091222132107.GA9060@ff.dom.local>
References: <alpine.DEB.2.01.0912211040100.3483@bogon.housecafe.de> <20091222123211.GA8546@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrey Rahmatullin <wrar@altlinux.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Roger Luethi <rl@hellgate.ch>, netdev@vger.kernel.org
To: Christian Kujau <lists@nerdbynature.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:34426 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750895AbZLVNVP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2009 08:21:15 -0500
Content-Disposition: inline
In-Reply-To: <20091222123211.GA8546@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 22, 2009 at 12:32:11PM +0000, Jarek Poplawski wrote:
> It looks like napi_disable() should be illegal in ndo_tx_timeout().
> Here is a patch which moves most of the timeout work to a workqueue,
> similarly to tg3 etc. It should prevent at least one of reported
> bugs. Alas I can't even check-compile it at the moment, so let me
> know on any problems.

It seems I needlessly changed locking btw, so here it is again.

Jarek P.

--- (take 2)

 drivers/net/via-rhine.c |   37 ++++++++++++++++++++++++++-----------
 1 files changed, 26 insertions(+), 11 deletions(-)

diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index 593e01f..15a4063 100644
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -102,6 +102,7 @@ static const int multicast_filter_limit = 32;
 #include <linux/ethtool.h>
 #include <linux/crc32.h>
 #include <linux/bitops.h>
+#include <linux/workqueue.h>
 #include <asm/processor.h>	/* Processor type for cache alignment. */
 #include <asm/io.h>
 #include <asm/irq.h>
@@ -389,6 +390,7 @@ struct rhine_private {
 	struct net_device *dev;
 	struct napi_struct napi;
 	spinlock_t lock;
+	struct work_struct reset_task;
 
 	/* Frequently used values: keep some adjacent for cache effect. */
 	u32 quirks;
@@ -407,6 +409,7 @@ struct rhine_private {
 static int  mdio_read(struct net_device *dev, int phy_id, int location);
 static void mdio_write(struct net_device *dev, int phy_id, int location, int value);
 static int  rhine_open(struct net_device *dev);
+static void rhine_reset_task(struct work_struct *work);
 static void rhine_tx_timeout(struct net_device *dev);
 static netdev_tx_t rhine_start_tx(struct sk_buff *skb,
 				  struct net_device *dev);
@@ -775,6 +778,8 @@ static int __devinit rhine_init_one(struct pci_dev *pdev,
 	dev->irq = pdev->irq;
 
 	spin_lock_init(&rp->lock);
+	INIT_WORK(&rp->reset_task, rhine_reset_task);
+
 	rp->mii_if.dev = dev;
 	rp->mii_if.mdio_read = mdio_read;
 	rp->mii_if.mdio_write = mdio_write;
@@ -1179,15 +1184,11 @@ static int rhine_open(struct net_device *dev)
 	return 0;
 }
 
-static void rhine_tx_timeout(struct net_device *dev)
+static void rhine_reset_task(struct work_struct *work)
 {
-	struct rhine_private *rp = netdev_priv(dev);
-	void __iomem *ioaddr = rp->base;
-
-	printk(KERN_WARNING "%s: Transmit timed out, status %4.4x, PHY status "
-	       "%4.4x, resetting...\n",
-	       dev->name, ioread16(ioaddr + IntrStatus),
-	       mdio_read(dev, rp->mii_if.phy_id, MII_BMSR));
+	struct rhine_private *rp = container_of(work, struct rhine_private,
+					        reset_task);
+	struct net_device *dev = rp->dev;
 
 	/* protect against concurrent rx interrupts */
 	disable_irq(rp->pdev->irq);
@@ -1214,6 +1215,19 @@ static void rhine_tx_timeout(struct net_device *dev)
 	netif_wake_queue(dev);
 }
 
+static void rhine_tx_timeout(struct net_device *dev)
+{
+	struct rhine_private *rp = netdev_priv(dev);
+	void __iomem *ioaddr = rp->base;
+
+	printk(KERN_WARNING "%s: Transmit timed out, status %4.4x, PHY status "
+	       "%4.4x, resetting...\n",
+	       dev->name, ioread16(ioaddr + IntrStatus),
+	       mdio_read(dev, rp->mii_if.phy_id, MII_BMSR));
+
+	schedule_work(&rp->reset_task);
+}
+
 static netdev_tx_t rhine_start_tx(struct sk_buff *skb,
 				  struct net_device *dev)
 {
@@ -1830,10 +1844,11 @@ static int rhine_close(struct net_device *dev)
 	struct rhine_private *rp = netdev_priv(dev);
 	void __iomem *ioaddr = rp->base;
 
-	spin_lock_irq(&rp->lock);
-
-	netif_stop_queue(dev);
 	napi_disable(&rp->napi);
+	cancel_work_sync(&rp->reset_task);
+	netif_stop_queue(dev);
+
+	spin_lock_irq(&rp->lock);
 
 	if (debug > 1)
 		printk(KERN_DEBUG "%s: Shutting down ethercard, "
