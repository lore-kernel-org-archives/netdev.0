From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: via_rhine kernel crashes in 2.6.32
Date: Tue, 22 Dec 2009 12:32:11 +0000
Message-ID: <20091222123211.GA8546@ff.dom.local>
References: <alpine.DEB.2.01.0912211040100.3483@bogon.housecafe.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrey Rahmatullin <wrar@altlinux.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Roger Luethi <rl@hellgate.ch>, netdev@vger.kernel.org
To: Christian Kujau <lists@nerdbynature.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f213.google.com ([209.85.220.213]:36685 "EHLO
	mail-fx0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750801AbZLVMcT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2009 07:32:19 -0500
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.01.0912211040100.3483@bogon.housecafe.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21-12-2009 20:32, Christian Kujau wrote:
> On Mon, 21 Dec 2009 at 23:18, Andrey Rahmatullin wrote:
>> I've installed 2.6.27, the earliest kernel supported by udev 149. I
> [...]
>> one of downloads, waited for some time, nothing happened. I resumed the
>> second download, the kernel crashed into an endless stream of backtraces
>> (did 2.6.27 support pause_on_oops?), containing "whatever from the idle
>> thread", or smth like that, which was also in other crash logs.
> 
> So, 2.6.27 crashed as well. Was the backtrace similar to those on 2.6.30? 
> I know it's a long shot, but since you seem to be able to reproduce this 
> pretty reliably, can you try 2.6.23? Or at least something before 
> bea3348eef27e6044b6161fd04c3152215f96411 [0]?
> 
> Christian.
> 
> [0] I'm *really* guessing here, if some netdev guru has some better
>     understanding of the backtraces Andrey sent, please step forward.

It looks like napi_disable() should be illegal in ndo_tx_timeout().
Here is a patch which moves most of the timeout work to a workqueue,
similarly to tg3 etc. It should prevent at least one of reported
bugs. Alas I can't even check-compile it at the moment, so let me
know on any problems.

Jarek P.

---

 drivers/net/via-rhine.c |   41 ++++++++++++++++++++++++++++-------------
 1 files changed, 28 insertions(+), 13 deletions(-)

diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index 593e01f..125406b 100644
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
@@ -1179,22 +1184,18 @@ static int rhine_open(struct net_device *dev)
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
 
 	napi_disable(&rp->napi);
 
-	spin_lock(&rp->lock);
+	spin_lock_irq(&rp->lock);
 
 	/* clear all descriptors */
 	free_tbufs(dev);
@@ -1206,7 +1207,7 @@ static void rhine_tx_timeout(struct net_device *dev)
 	rhine_chip_reset(dev);
 	init_registers(dev);
 
-	spin_unlock(&rp->lock);
+	spin_unlock_irq(&rp->lock);
 	enable_irq(rp->pdev->irq);
 
 	dev->trans_start = jiffies;
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
