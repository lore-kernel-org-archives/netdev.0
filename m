From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH net-next v2]netdevice: 82596: Convert netdev->priv to netdev_priv
Date: Mon, 17 Nov 2008 17:24:38 +0800
Message-ID: <49213856.6040802@cn.fujitsu.com>
References: <4921095D.9010109@cn.fujitsu.com> <20081116.223637.108010315.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52816 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752048AbYKQJZB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 04:25:01 -0500
In-Reply-To: <20081116.223637.108010315.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The memory, which pointed by netdev->priv, can be allocated by alloc_etherdev().
We don't need to use __get_free_pages() to get memory.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 drivers/net/82596.c |   53 +++++++++++++++++++++++---------------------------
 1 files changed, 24 insertions(+), 29 deletions(-)

diff --git a/drivers/net/82596.c b/drivers/net/82596.c
index 717fe2f..74d5bca 100644
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
@@ -1135,7 +1135,7 @@ struct net_device * __init i82596_probe(int unit)
 		return ERR_PTR(-ENODEV);
 	probed++;
 
-	dev = alloc_etherdev(0);
+	dev = alloc_etherdev(sizeof(struct i596_private));
 	if (!dev)
 		return ERR_PTR(-ENOMEM);
 
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
@@ -1239,9 +1233,7 @@ found:
 	dev->tx_timeout = i596_tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
 
-	dev->priv = (void *)(dev->mem_start);
-
-	lp = dev->priv;
+	lp = netdev_priv(dev);
 	DEB(DEB_INIT,printk(KERN_DEBUG "%s: lp at 0x%08lx (%zd bytes), "
 			"lp->scb at 0x%08lx\n",
 			dev->name, (unsigned long)lp,
@@ -1249,9 +1241,12 @@ found:
 	memset((void *) lp, 0, sizeof(struct i596_private));
 
 #ifdef __mc68000__
-	cache_push(virt_to_phys((void *)(dev->mem_start)), 4096);
-	cache_clear(virt_to_phys((void *)(dev->mem_start)), 4096);
-	kernel_set_cachemode((void *)(dev->mem_start), 4096, IOMAP_NOCACHE_SER);
+	cache_push(virt_to_phys((void *)netdev_priv(dev)),
+			sizeof(struct i596_private));
+	cache_clear(virt_to_phys((void *)netdev_priv(dev)),
+			sizeof(struct i596_private));
+	kernel_set_cachemode((void *)netdev_priv(dev),
+			sizeof(struct i596_private), IOMAP_NOCACHE_SER);
 #endif
 	lp->scb.command = 0;
 	lp->scb.cmd = I596_NULL;
@@ -1267,10 +1262,10 @@ out2:
 	/* XXX This assumes default cache mode to be IOMAP_FULL_CACHING,
 	 * XXX which may be invalid (CONFIG_060_WRITETHROUGH)
 	 */
-	kernel_set_cachemode((void *)(dev->mem_start), 4096,
+	kernel_set_cachemode((void *)netdev_priv(dev),
+			sizeof(struct i596_private),
 			IOMAP_FULL_CACHING);
 #endif
-	free_page ((u32)(dev->mem_start));
 out1:
 #ifdef ENABLE_APRICOT
 	release_region(dev->base_addr, I596_TOTAL_SIZE);
@@ -1302,7 +1297,7 @@ static irqreturn_t i596_interrupt(int irq, void *dev_id)
 	}
 
 	ioaddr = dev->base_addr;
-	lp = dev->priv;
+	lp = netdev_priv(dev);
 
 	spin_lock (&lp->lock);
 
@@ -1445,7 +1440,7 @@ static irqreturn_t i596_interrupt(int irq, void *dev_id)
 
 static int i596_close(struct net_device *dev)
 {
-	struct i596_private *lp = dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	unsigned long flags;
 
 	netif_stop_queue(dev);
@@ -1495,7 +1490,7 @@ static int i596_close(struct net_device *dev)
 
 static void set_multicast_list(struct net_device *dev)
 {
-	struct i596_private *lp = dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	int config = 0, cnt;
 
 	DEB(DEB_MULTI,printk(KERN_DEBUG "%s: set multicast list, %d entries, promisc %s, allmulti %s\n",
@@ -1586,10 +1581,10 @@ void __exit cleanup_module(void)
 	 * XXX which may be invalid (CONFIG_060_WRITETHROUGH)
 	 */
 
-	kernel_set_cachemode((void *)(dev_82596->mem_start), 4096,
+	kernel_set_cachemode((void *)netdev_priv(dev_82596),
+			sizeof(struct i596_private),
 			IOMAP_FULL_CACHING);
 #endif
-	free_page ((u32)(dev_82596->mem_start));
 #ifdef ENABLE_APRICOT
 	/* If we don't do this, we can't re-insmod it later. */
 	release_region(dev_82596->base_addr, I596_TOTAL_SIZE);
-- 
1.5.3.4



