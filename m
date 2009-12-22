From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] net/via-rhine: Fix scheduling while atomic bugs
Date: Tue, 22 Dec 2009 18:36:42 +0100
Message-ID: <20091222173641.GA3093@del.dom.local>
References: <alpine.DEB.2.01.0912211040100.3483@bogon.housecafe.de>
 <20091222123211.GA8546@ff.dom.local>
 <20091222132107.GA9060@ff.dom.local>
 <20091222133817.GA9208@ff.dom.local>
 <20091222150045.GA5355@wrars-comp.wrarsdomain>
 <20091222152658.GA16043@core.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roger Luethi <rl@hellgate.ch>,
	Andrey Rahmatullin <wrar@altlinux.org>,
	Christian Kujau <lists@nerdbynature.de>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754529AbZLVRgz@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091222152658.GA16043@core.hellgate.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 22, 2009 at 04:26:59PM +0100, Roger Luethi wrote:
> On Tue, 22 Dec 2009 20:00:45 +0500, Andrey Rahmatullin wrote:
> > On Tue, Dec 22, 2009 at 01:38:17PM +0000, Jarek Poplawski wrote:
> > > > > It looks like napi_disable() should be illegal in ndo_tx_timeout().
> > > > > Here is a patch which moves most of the timeout work to a workqueue,
> > > > > similarly to tg3 etc. It should prevent at least one of reported
> > > > > bugs. Alas I can't even check-compile it at the moment, so let me
> > > > > know on any problems.
> > > > It seems I needlessly changed locking btw, so here it is again.
> > > Hmm... On the other hand, it definitely needs at least _bh now...
> > I've tried this patch. There are lots of "Transmit timed out", but no
> > crashes.
> 
> ACK. Looks like you guys tracked down the crashing and fixed it (thanks!).
> I suspect we shouldn't have to reset due to timeouts that often, but that's
> another story.
> 
> Roger

Thanks everybody,
Jarek P.
------------------->

There are BUGs "scheduling while atomic" triggered by the timer
rhine_tx_timeout(). They are caused by calling napi_disable() (with
msleep()). This patch fixes it by moving most of the timer content to
the workqueue function (similarly to other drivers, like tg3), with
spin_lock() changed to BH version.

Additionally, there is spin_lock_irq() moved in rhine_close() to
exclude napi_disable() etc., also tg3's way.

Reported-by: Andrey Rahmatullin <wrar@altlinux.org>
Tested-by: Andrey Rahmatullin <wrar@altlinux.org>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
Cc: Christian Kujau <lists@nerdbynature.de>
Cc: Roger Luethi <rl@hellgate.ch>
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
+						reset_task);
+	struct net_device *dev = rp->dev;
 
 	/* protect against concurrent rx interrupts */
 	disable_irq(rp->pdev->irq);
 
 	napi_disable(&rp->napi);
 
-	spin_lock(&rp->lock);
+	spin_lock_bh(&rp->lock);
 
 	/* clear all descriptors */
 	free_tbufs(dev);
@@ -1206,7 +1207,7 @@ static void rhine_tx_timeout(struct net_device *dev)
 	rhine_chip_reset(dev);
 	init_registers(dev);
 
-	spin_unlock(&rp->lock);
+	spin_unlock_bh(&rp->lock);
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
