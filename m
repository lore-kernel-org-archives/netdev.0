From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH net-next]netdevice: 82596: Convert netdev->priv to netdev_priv
Date: Mon, 17 Nov 2008 14:04:13 +0800
Message-ID: <4921095D.9010109@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: Jeff Garzik <jgarzik@pobox.com>,
	"David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:58782 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751615AbYKQGEz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 01:04:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev->priv points to the memory which is allocated by alloc_etherdev().
It should not change to netdev->mem_start later.
After fixing it, mem_start allocation is useless.
I removed mem_start allocation.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 drivers/net/82596.c |   59 ++++++++++++--------------------------------------
 1 files changed, 14 insertions(+), 45 deletions(-)

diff --git a/drivers/net/82596.c b/drivers/net/82596.c
index 717fe2f..25e5d5f 100644
--- a/drivers/net/82596.c
+++ b/drivers/net/82596.c
@@ -457,7 +457,7 @@ static inline int wait_cfg(struct net_device *dev, struct i596_cmd *cmd, int del
 
 static void i596_display_data(struct net_device *dev)
 {
-	struct i596_private *lp = dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	struct i596_cmd *cmd;
 	struct i596_rfd *rfd;
 	struct i596_rbd *rbd;
@@ -527,7 +527,7 @@ static irqreturn_t i596_error(int irq, void *dev_id)
 
 static inline void init_rx_bufs(struct net_device *dev)
 {
-	struct i596_private *lp = dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	int i;
 	struct i596_rfd *rfd;
 	struct i596_rbd *rbd;
@@ -578,7 +578,7 @@ static inline void init_rx_bufs(struct net_device *dev)
 
 static inline void remove_rx_bufs(struct net_device *dev)
 {
-	struct i596_private *lp = dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	struct i596_rbd *rbd;
 	int i;
 
@@ -592,7 +592,7 @@ static inline void remove_rx_bufs(struct net_device *dev)
 
 static void rebuild_rx_bufs(struct net_device *dev)
 {
-	struct i596_private *lp = dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	int i;
 
 	/* Ensure rx frame/buffer descriptors are tidy */
@@ -611,7 +611,7 @@ static void rebuild_rx_bufs(struct net_device *dev)
 
 static int init_i596_mem(struct net_device *dev)
 {
-	struct i596_private *lp = dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 #if !defined(ENABLE_MVME16x_NET) && !defined(ENABLE_BVME6000_NET) || defined(ENABLE_APRICOT)
 	short ioaddr = dev->base_addr;
 #endif
@@ -764,7 +764,7 @@ failed:
 
 static inline int i596_rx(struct net_device *dev)
 {
-	struct i596_private *lp = dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	struct i596_rfd *rfd;
 	struct i596_rbd *rbd;
 	int frames = 0;
@@ -958,7 +958,7 @@ static void i596_reset(struct net_device *dev, struct i596_private *lp,
 
 static void i596_add_cmd(struct net_device *dev, struct i596_cmd *cmd)
 {
-	struct i596_private *lp = dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 	unsigned long flags;
 
@@ -1028,7 +1028,7 @@ static int i596_open(struct net_device *dev)
 
 static void i596_tx_timeout (struct net_device *dev)
 {
-	struct i596_private *lp = dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 
 	/* Transmitter timeout, serious problems. */
@@ -1057,7 +1057,7 @@ static void i596_tx_timeout (struct net_device *dev)
 
 static int i596_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct i596_private *lp = dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	struct tx_cmd *tx_cmd;
 	struct i596_tbd *tbd;
 	short length = skb->len;
@@ -1216,12 +1216,6 @@ struct net_device * __init i82596_probe(int unit)
 	goto out;
 
 found:
-	dev->mem_start = (int)__get_free_pages(GFP_ATOMIC, 0);
-	if (!dev->mem_start) {
-		err = -ENOMEM;
-		goto out1;
-	}
-
 	DEB(DEB_PROBE,printk(KERN_INFO "%s: 82596 at %#3lx,", dev->name, dev->base_addr));
 
 	for (i = 0; i < 6; i++)
@@ -1239,20 +1233,13 @@ found:
 	dev->tx_timeout = i596_tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
 
-	dev->priv = (void *)(dev->mem_start);
-
-	lp = dev->priv;
+	lp = netdev_priv(dev);
 	DEB(DEB_INIT,printk(KERN_DEBUG "%s: lp at 0x%08lx (%zd bytes), "
 			"lp->scb at 0x%08lx\n",
 			dev->name, (unsigned long)lp,
 			sizeof(struct i596_private), (unsigned long)&lp->scb));
 	memset((void *) lp, 0, sizeof(struct i596_private));
 
-#ifdef __mc68000__
-	cache_push(virt_to_phys((void *)(dev->mem_start)), 4096);
-	cache_clear(virt_to_phys((void *)(dev->mem_start)), 4096);
-	kernel_set_cachemode((void *)(dev->mem_start), 4096, IOMAP_NOCACHE_SER);
-#endif
 	lp->scb.command = 0;
 	lp->scb.cmd = I596_NULL;
 	lp->scb.rfd = I596_NULL;
@@ -1260,17 +1247,8 @@ found:
 
 	err = register_netdev(dev);
 	if (err)
-		goto out2;
+		goto out1;
 	return dev;
-out2:
-#ifdef __mc68000__
-	/* XXX This assumes default cache mode to be IOMAP_FULL_CACHING,
-	 * XXX which may be invalid (CONFIG_060_WRITETHROUGH)
-	 */
-	kernel_set_cachemode((void *)(dev->mem_start), 4096,
-			IOMAP_FULL_CACHING);
-#endif
-	free_page ((u32)(dev->mem_start));
 out1:
 #ifdef ENABLE_APRICOT
 	release_region(dev->base_addr, I596_TOTAL_SIZE);
@@ -1302,7 +1280,7 @@ static irqreturn_t i596_interrupt(int irq, void *dev_id)
 	}
 
 	ioaddr = dev->base_addr;
-	lp = dev->priv;
+	lp = netdev_priv(dev);
 
 	spin_lock (&lp->lock);
 
@@ -1445,7 +1423,7 @@ static irqreturn_t i596_interrupt(int irq, void *dev_id)
 
 static int i596_close(struct net_device *dev)
 {
-	struct i596_private *lp = dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	unsigned long flags;
 
 	netif_stop_queue(dev);
@@ -1495,7 +1473,7 @@ static int i596_close(struct net_device *dev)
 
 static void set_multicast_list(struct net_device *dev)
 {
-	struct i596_private *lp = dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	int config = 0, cnt;
 
 	DEB(DEB_MULTI,printk(KERN_DEBUG "%s: set multicast list, %d entries, promisc %s, allmulti %s\n",
@@ -1581,15 +1559,6 @@ int __init init_module(void)
 void __exit cleanup_module(void)
 {
 	unregister_netdev(dev_82596);
-#ifdef __mc68000__
-	/* XXX This assumes default cache mode to be IOMAP_FULL_CACHING,
-	 * XXX which may be invalid (CONFIG_060_WRITETHROUGH)
-	 */
-
-	kernel_set_cachemode((void *)(dev_82596->mem_start), 4096,
-			IOMAP_FULL_CACHING);
-#endif
-	free_page ((u32)(dev_82596->mem_start));
 #ifdef ENABLE_APRICOT
 	/* If we don't do this, we can't re-insmod it later. */
 	release_region(dev_82596->base_addr, I596_TOTAL_SIZE);
-- 
1.5.3.4

