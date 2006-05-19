From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch w/o fuzz] via-rhine: revert "change mdelay to msleep and remove from ISR path"
Date: Fri, 19 May 2006 10:51:21 -0400
Message-ID: <20060519145116.GB30177@tuxdriver.com>
References: <BAY103-F401F96F0B06D75E70AF0BFB2DF0@phx.gbl> <20060327203946.GA11824@k3.hellgate.ch> <20060413182638.GC25854@tuxdriver.com> <20060413203147.GA2874@k3.hellgate.ch> <20060519144124.GA30177@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marco Berizzi <pupilla@hotmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([24.172.12.4]:7175 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1751092AbWESOvs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 May 2006 10:51:48 -0400
To: Roger Luethi <rl@hellgate.ch>, jeff@garzik.org
Content-Disposition: inline
In-Reply-To: <20060519144124.GA30177@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Revert previous patch with subject "change mdelay to msleep and remove
from ISR path".  This patch seems to have caused bigger problems than
it solved, and it didn't solve much of a problem to begin with...

Signed-off-by: John W. Linville <linville@tuxdriver.com
---
Use this one, it applies w/o fuzz...

Discussion about backing-out this patch can be found here:

	http://marc.theaimsgroup.com/?l=linux-netdev&m=114321570402396&w=2

The git commit associated w/ the original patch is:

	6ba98d311d0a4ff7dc36d8f435ce60174f4c30ec

 drivers/net/via-rhine.c |   34 +++-------------------------------
 1 files changed, 3 insertions(+), 31 deletions(-)

diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index a6dc53b..fdc2103 100644
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -491,8 +491,6 @@ struct rhine_private {
 	u8 tx_thresh, rx_thresh;
 
 	struct mii_if_info mii_if;
-	struct work_struct tx_timeout_task;
-	struct work_struct check_media_task;
 	void __iomem *base;
 };
 
@@ -500,8 +498,6 @@ static int  mdio_read(struct net_device 
 static void mdio_write(struct net_device *dev, int phy_id, int location, int value);
 static int  rhine_open(struct net_device *dev);
 static void rhine_tx_timeout(struct net_device *dev);
-static void rhine_tx_timeout_task(struct net_device *dev);
-static void rhine_check_media_task(struct net_device *dev);
 static int  rhine_start_tx(struct sk_buff *skb, struct net_device *dev);
 static irqreturn_t rhine_interrupt(int irq, void *dev_instance, struct pt_regs *regs);
 static void rhine_tx(struct net_device *dev);
@@ -856,12 +852,6 @@ #endif
 	if (rp->quirks & rqRhineI)
 		dev->features |= NETIF_F_SG|NETIF_F_HW_CSUM;
 
-	INIT_WORK(&rp->tx_timeout_task,
-		  (void (*)(void *))rhine_tx_timeout_task, dev);
-
-	INIT_WORK(&rp->check_media_task,
-		  (void (*)(void *))rhine_check_media_task, dev);
-
 	/* dev->name not defined before register_netdev()! */
 	rc = register_netdev(dev);
 	if (rc)
@@ -1108,11 +1098,6 @@ static void rhine_set_carrier(struct mii
 		       netif_carrier_ok(mii->dev));
 }
 
-static void rhine_check_media_task(struct net_device *dev)
-{
-	rhine_check_media(dev, 0);
-}
-
 static void init_registers(struct net_device *dev)
 {
 	struct rhine_private *rp = netdev_priv(dev);
@@ -1166,8 +1151,8 @@ static void rhine_disable_linkmon(void _
 	if (quirks & rqRhineI) {
 		iowrite8(0x01, ioaddr + MIIRegAddr);	// MII_BMSR
 
-		/* Do not call from ISR! */
-		msleep(1);
+		/* Can be called from ISR. Evil. */
+		mdelay(1);
 
 		/* 0x80 must be set immediately before turning it off */
 		iowrite8(0x80, ioaddr + MIICmd);
@@ -1257,16 +1242,6 @@ static int rhine_open(struct net_device 
 static void rhine_tx_timeout(struct net_device *dev)
 {
 	struct rhine_private *rp = netdev_priv(dev);
-
-	/*
-	 * Move bulk of work outside of interrupt context
-	 */
-	schedule_work(&rp->tx_timeout_task);
-}
-
-static void rhine_tx_timeout_task(struct net_device *dev)
-{
-	struct rhine_private *rp = netdev_priv(dev);
 	void __iomem *ioaddr = rp->base;
 
 	printk(KERN_WARNING "%s: Transmit timed out, status %4.4x, PHY status "
@@ -1677,7 +1652,7 @@ static void rhine_error(struct net_devic
 	spin_lock(&rp->lock);
 
 	if (intr_status & IntrLinkChange)
-		schedule_work(&rp->check_media_task);
+		rhine_check_media(dev, 0);
 	if (intr_status & IntrStatsMax) {
 		rp->stats.rx_crc_errors += ioread16(ioaddr + RxCRCErrs);
 		rp->stats.rx_missed_errors += ioread16(ioaddr + RxMissed);
@@ -1927,9 +1902,6 @@ static int rhine_close(struct net_device
 	spin_unlock_irq(&rp->lock);
 
 	free_irq(rp->pdev->irq, dev);
-
-	flush_scheduled_work();
-
 	free_rbufs(dev);
 	free_tbufs(dev);
 	free_ring(dev);
-- 
John W. Linville
linville@tuxdriver.com
