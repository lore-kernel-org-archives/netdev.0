From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] drivers/net: natsemi: Convert timers to use timer_setup()
Date: Thu, 26 Oct 2017 22:55:27 -0700
Message-ID: <20171027055527.GA122213@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Allen Pais <allen.lkml@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        Philippe Reynes <tremyfr@gmail.com>,
        Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Allen Pais <allen.lkml@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Philippe Reynes <tremyfr@gmail.com>
Cc: Wei Yongjun <weiyongjun1@huawei.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/ethernet/natsemi/natsemi.c | 10 +++++-----
 drivers/net/ethernet/natsemi/ns83820.c |  8 ++++----
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/natsemi/natsemi.c b/drivers/net/ethernet/natsemi/natsemi.c
index dedeacd0bbca..b9a1a9f999ea 100644
--- a/drivers/net/ethernet/natsemi/natsemi.c
+++ b/drivers/net/ethernet/natsemi/natsemi.c
@@ -610,7 +610,7 @@ static int netdev_open(struct net_device *dev);
 static void do_cable_magic(struct net_device *dev);
 static void undo_cable_magic(struct net_device *dev);
 static void check_link(struct net_device *dev);
-static void netdev_timer(unsigned long data);
+static void netdev_timer(struct timer_list *t);
 static void dump_ring(struct net_device *dev);
 static void ns_tx_timeout(struct net_device *dev);
 static int alloc_ring(struct net_device *dev);
@@ -1571,7 +1571,7 @@ static int netdev_open(struct net_device *dev)
 			dev->name, (int)readl(ioaddr + ChipCmd));
 
 	/* Set the timer to check for link beat. */
-	setup_timer(&np->timer, netdev_timer, (unsigned long)dev);
+	timer_setup(&np->timer, netdev_timer, 0);
 	np->timer.expires = round_jiffies(jiffies + NATSEMI_TIMER_FREQ);
 	add_timer(&np->timer);
 
@@ -1787,10 +1787,10 @@ static void init_registers(struct net_device *dev)
  *    this check via dspcfg_workaround sysfs option.
  * 3) check of death of the RX path due to OOM
  */
-static void netdev_timer(unsigned long data)
+static void netdev_timer(struct timer_list *t)
 {
-	struct net_device *dev = (struct net_device *)data;
-	struct netdev_private *np = netdev_priv(dev);
+	struct netdev_private *np = from_timer(np, t, timer);
+	struct net_device *dev = np->dev;
 	void __iomem * ioaddr = ns_ioaddr(dev);
 	int next_tick = NATSEMI_TIMER_FREQ;
 	const int irq = np->pci_dev->irq;
diff --git a/drivers/net/ethernet/natsemi/ns83820.c b/drivers/net/ethernet/natsemi/ns83820.c
index 99d3c7884a4a..958fced4dacf 100644
--- a/drivers/net/ethernet/natsemi/ns83820.c
+++ b/drivers/net/ethernet/natsemi/ns83820.c
@@ -1600,10 +1600,10 @@ static void ns83820_tx_timeout(struct net_device *ndev)
 	spin_unlock_irqrestore(&dev->tx_lock, flags);
 }
 
-static void ns83820_tx_watch(unsigned long data)
+static void ns83820_tx_watch(struct timer_list *t)
 {
-	struct net_device *ndev = (void *)data;
-	struct ns83820 *dev = PRIV(ndev);
+	struct ns83820 *dev = from_timer(dev, t, tx_watchdog);
+	struct net_device *ndev = dev->ndev;
 
 #if defined(DEBUG)
 	printk("ns83820_tx_watch: %u %u %d\n",
@@ -1652,7 +1652,7 @@ static int ns83820_open(struct net_device *ndev)
 	writel(0, dev->base + TXDP_HI);
 	writel(desc, dev->base + TXDP);
 
-	setup_timer(&dev->tx_watchdog, ns83820_tx_watch, (unsigned long)ndev);
+	timer_setup(&dev->tx_watchdog, ns83820_tx_watch, 0);
 	mod_timer(&dev->tx_watchdog, jiffies + 2*HZ);
 
 	netif_start_queue(ndev);	/* FIXME: wait for phy to come up */
-- 
2.7.4


-- 
Kees Cook
Pixel Security
