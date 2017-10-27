From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] drivers/net: amd: Convert timers to use timer_setup()
Date: Thu, 26 Oct 2017 22:54:38 -0700
Message-ID: <20171027055438.GA88997@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Lendacky <thomas.lendacky@amd.com>,
        Allen Pais <allen.lkml@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: Tom Lendacky <thomas.lendacky@amd.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Allen Pais <allen.lkml@gmail.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/ethernet/amd/a2065.c         | 13 ++++++++++---
 drivers/net/ethernet/amd/am79c961a.c     |  9 +++++----
 drivers/net/ethernet/amd/am79c961a.h     |  1 +
 drivers/net/ethernet/amd/declance.c      | 10 ++++++----
 drivers/net/ethernet/amd/pcnet32.c       | 10 +++++-----
 drivers/net/ethernet/amd/sunlance.c      |  8 ++++----
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c | 14 ++++++--------
 7 files changed, 37 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/amd/a2065.c b/drivers/net/ethernet/amd/a2065.c
index 998d30e050a6..212fe72a190b 100644
--- a/drivers/net/ethernet/amd/a2065.c
+++ b/drivers/net/ethernet/amd/a2065.c
@@ -123,6 +123,7 @@ struct lance_private {
 	int burst_sizes;	      /* ledma SBus burst sizes */
 #endif
 	struct timer_list         multicast_timer;
+	struct net_device	  *dev;
 };
 
 #define LANCE_ADDR(x) ((int)(x) & ~0xff000000)
@@ -638,6 +639,13 @@ static void lance_set_multicast(struct net_device *dev)
 	netif_wake_queue(dev);
 }
 
+static void lance_set_multicast_retry(struct timer_list *t)
+{
+	struct lance_private *lp = from_timer(lp, t, multicast_timer);
+
+	lance_set_multicast(lp->dev);
+}
+
 static int a2065_init_one(struct zorro_dev *z,
 			  const struct zorro_device_id *ent);
 static void a2065_remove_one(struct zorro_dev *z);
@@ -728,14 +736,13 @@ static int a2065_init_one(struct zorro_dev *z,
 	priv->lance_log_tx_bufs = LANCE_LOG_TX_BUFFERS;
 	priv->rx_ring_mod_mask = RX_RING_MOD_MASK;
 	priv->tx_ring_mod_mask = TX_RING_MOD_MASK;
+	priv->dev = dev;
 
 	dev->netdev_ops = &lance_netdev_ops;
 	dev->watchdog_timeo = 5*HZ;
 	dev->dma = 0;
 
-	setup_timer(&priv->multicast_timer,
-		    (void(*)(unsigned long))lance_set_multicast,
-		    (unsigned long)dev);
+	timer_setup(&priv->multicast_timer, lance_set_multicast_retry, 0);
 
 	err = register_netdev(dev);
 	if (err) {
diff --git a/drivers/net/ethernet/amd/am79c961a.c b/drivers/net/ethernet/amd/am79c961a.c
index 0612dbee00d2..01d132c02ff9 100644
--- a/drivers/net/ethernet/amd/am79c961a.c
+++ b/drivers/net/ethernet/amd/am79c961a.c
@@ -302,10 +302,10 @@ am79c961_init_for_open(struct net_device *dev)
 	write_rreg (dev->base_addr, CSR0, CSR0_IENA|CSR0_STRT);
 }
 
-static void am79c961_timer(unsigned long data)
+static void am79c961_timer(struct timer_list *t)
 {
-	struct net_device *dev = (struct net_device *)data;
-	struct dev_priv *priv = netdev_priv(dev);
+	struct dev_priv *priv = from_timer(priv, t, timer);
+	struct net_device *dev = priv->dev;
 	unsigned int lnkstat, carrier;
 	unsigned long flags;
 
@@ -728,7 +728,8 @@ static int am79c961_probe(struct platform_device *pdev)
 	am79c961_banner();
 
 	spin_lock_init(&priv->chip_lock);
-	setup_timer(&priv->timer, am79c961_timer, (unsigned long)dev);
+	priv->dev = dev;
+	timer_setup(&priv->timer, am79c961_timer, 0);
 
 	if (am79c961_hw_init(dev))
 		goto release;
diff --git a/drivers/net/ethernet/amd/am79c961a.h b/drivers/net/ethernet/amd/am79c961a.h
index 9f384b79507b..fc5088c70731 100644
--- a/drivers/net/ethernet/amd/am79c961a.h
+++ b/drivers/net/ethernet/amd/am79c961a.h
@@ -140,6 +140,7 @@ struct dev_priv {
     unsigned long	txhdr;
     spinlock_t		chip_lock;
     struct timer_list	timer;
+    struct net_device   *dev;
 };
 
 #endif
diff --git a/drivers/net/ethernet/amd/declance.c b/drivers/net/ethernet/amd/declance.c
index 9bdf81c2cd00..116997a8b593 100644
--- a/drivers/net/ethernet/amd/declance.c
+++ b/drivers/net/ethernet/amd/declance.c
@@ -260,6 +260,7 @@ struct lance_private {
 	unsigned short busmaster_regval;
 
 	struct timer_list       multicast_timer;
+	struct net_device	*dev;
 
 	/* Pointers to the ring buffers as seen from the CPU */
 	char *rx_buf_ptr_cpu[RX_RING_SIZE];
@@ -1000,9 +1001,10 @@ static void lance_set_multicast(struct net_device *dev)
 	netif_wake_queue(dev);
 }
 
-static void lance_set_multicast_retry(unsigned long _opaque)
+static void lance_set_multicast_retry(struct timer_list *t)
 {
-	struct net_device *dev = (struct net_device *) _opaque;
+	struct lance_private *lp = from_timer(lp, t, multicast_timer);
+	struct net_device *dev = lp->dev;
 
 	lance_set_multicast(dev);
 }
@@ -1246,8 +1248,8 @@ static int dec_lance_probe(struct device *bdev, const int type)
 	 * can occur from interrupts (ex. IPv6).  So we
 	 * use a timer to try again later when necessary. -DaveM
 	 */
-	setup_timer(&lp->multicast_timer, lance_set_multicast_retry,
-		    (unsigned long)dev);
+	lp->dev = dev;
+	timer_setup(&lp->multicast_timer, lance_set_multicast_retry, 0);
 
 
 	ret = register_netdev(dev);
diff --git a/drivers/net/ethernet/amd/pcnet32.c b/drivers/net/ethernet/amd/pcnet32.c
index e46153654016..a561705f232c 100644
--- a/drivers/net/ethernet/amd/pcnet32.c
+++ b/drivers/net/ethernet/amd/pcnet32.c
@@ -321,7 +321,7 @@ static struct net_device_stats *pcnet32_get_stats(struct net_device *);
 static void pcnet32_load_multicast(struct net_device *dev);
 static void pcnet32_set_multicast_list(struct net_device *);
 static int pcnet32_ioctl(struct net_device *, struct ifreq *, int);
-static void pcnet32_watchdog(struct net_device *);
+static void pcnet32_watchdog(struct timer_list *);
 static int mdio_read(struct net_device *dev, int phy_id, int reg_num);
 static void mdio_write(struct net_device *dev, int phy_id, int reg_num,
 		       int val);
@@ -1970,8 +1970,7 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 			lp->options |= PCNET32_PORT_MII;
 	}
 
-	setup_timer(&lp->watchdog_timer, (void *)&pcnet32_watchdog,
-		    (unsigned long)dev);
+	timer_setup(&lp->watchdog_timer, pcnet32_watchdog, 0);
 
 	/* The PCNET32-specific entries in the device structure. */
 	dev->netdev_ops = &pcnet32_netdev_ops;
@@ -2901,9 +2900,10 @@ static void pcnet32_check_media(struct net_device *dev, int verbose)
  * Could possibly be changed to use mii_check_media instead.
  */
 
-static void pcnet32_watchdog(struct net_device *dev)
+static void pcnet32_watchdog(struct timer_list *t)
 {
-	struct pcnet32_private *lp = netdev_priv(dev);
+	struct pcnet32_private *lp = from_timer(lp, t, watchdog_timer);
+	struct net_device *dev = lp->dev;
 	unsigned long flags;
 
 	/* Print the link status if it has changed */
diff --git a/drivers/net/ethernet/amd/sunlance.c b/drivers/net/ethernet/amd/sunlance.c
index 0183ffb9d3ba..cdd7a611479b 100644
--- a/drivers/net/ethernet/amd/sunlance.c
+++ b/drivers/net/ethernet/amd/sunlance.c
@@ -1248,9 +1248,10 @@ static void lance_set_multicast(struct net_device *dev)
 	netif_wake_queue(dev);
 }
 
-static void lance_set_multicast_retry(unsigned long _opaque)
+static void lance_set_multicast_retry(struct timer_list *t)
 {
-	struct net_device *dev = (struct net_device *) _opaque;
+	struct lance_private *lp = from_timer(lp, t, multicast_timer);
+	struct net_device *dev = lp->dev;
 
 	lance_set_multicast(dev);
 }
@@ -1459,8 +1460,7 @@ static int sparc_lance_probe_one(struct platform_device *op,
 	 * can occur from interrupts (ex. IPv6).  So we
 	 * use a timer to try again later when necessary. -DaveM
 	 */
-	setup_timer(&lp->multicast_timer, lance_set_multicast_retry,
-		    (unsigned long)dev);
+	timer_setup(&lp->multicast_timer, lance_set_multicast_retry, 0);
 
 	if (register_netdev(dev)) {
 		printk(KERN_ERR "SunLance: Cannot register device.\n");
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index 608693d11bd7..3d53153ce751 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -642,9 +642,9 @@ static irqreturn_t xgbe_dma_isr(int irq, void *data)
 	return IRQ_HANDLED;
 }
 
-static void xgbe_tx_timer(unsigned long data)
+static void xgbe_tx_timer(struct timer_list *t)
 {
-	struct xgbe_channel *channel = (struct xgbe_channel *)data;
+	struct xgbe_channel *channel = from_timer(channel, t, tx_timer);
 	struct xgbe_prv_data *pdata = channel->pdata;
 	struct napi_struct *napi;
 
@@ -680,9 +680,9 @@ static void xgbe_service(struct work_struct *work)
 	pdata->phy_if.phy_status(pdata);
 }
 
-static void xgbe_service_timer(unsigned long data)
+static void xgbe_service_timer(struct timer_list *t)
 {
-	struct xgbe_prv_data *pdata = (struct xgbe_prv_data *)data;
+	struct xgbe_prv_data *pdata = from_timer(pdata, t, service_timer);
 
 	queue_work(pdata->dev_workqueue, &pdata->service_work);
 
@@ -694,16 +694,14 @@ static void xgbe_init_timers(struct xgbe_prv_data *pdata)
 	struct xgbe_channel *channel;
 	unsigned int i;
 
-	setup_timer(&pdata->service_timer, xgbe_service_timer,
-		    (unsigned long)pdata);
+	timer_setup(&pdata->service_timer, xgbe_service_timer, 0);
 
 	for (i = 0; i < pdata->channel_count; i++) {
 		channel = pdata->channel[i];
 		if (!channel->tx_ring)
 			break;
 
-		setup_timer(&channel->tx_timer, xgbe_tx_timer,
-			    (unsigned long)channel);
+		timer_setup(&channel->tx_timer, xgbe_tx_timer, 0);
 	}
 }
 
-- 
2.7.4


-- 
Kees Cook
Pixel Security
