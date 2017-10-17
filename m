From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 23/58] drivers/net/3com: Convert timers to use timer_setup()
Date: Mon, 16 Oct 2017 17:29:07 -0700
Message-ID: <1508200182-104605-24-git-send-email-keescook@chromium.org>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>,
        Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
        Jarod Wilson <jarod@redhat.com>, netdev@vger.kernel.org,
        Thomas Gleixner <tglx@linutronix.de>,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Jarod Wilson <jarod@redhat.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/ethernet/3com/3c574_cs.c | 12 +++++-------
 drivers/net/ethernet/3com/3c589_cs.c | 10 +++++-----
 drivers/net/ethernet/3com/3c59x.c    | 20 ++++++++++----------
 3 files changed, 20 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/3com/3c574_cs.c b/drivers/net/ethernet/3com/3c574_cs.c
index 47c844cc9d27..48bc7fa0258c 100644
--- a/drivers/net/ethernet/3com/3c574_cs.c
+++ b/drivers/net/ethernet/3com/3c574_cs.c
@@ -225,7 +225,7 @@ static unsigned short read_eeprom(unsigned int ioaddr, int index);
 static void tc574_wait_for_completion(struct net_device *dev, int cmd);
 
 static void tc574_reset(struct net_device *dev);
-static void media_check(unsigned long arg);
+static void media_check(struct timer_list *t);
 static int el3_open(struct net_device *dev);
 static netdev_tx_t el3_start_xmit(struct sk_buff *skb,
 					struct net_device *dev);
@@ -377,7 +377,7 @@ static int tc574_config(struct pcmcia_device *link)
 		lp->autoselect = config & Autoselect ? 1 : 0;
 	}
 
-	init_timer(&lp->media);
+	timer_setup(&lp->media, media_check, 0);
 
 	{
 		int phy;
@@ -681,8 +681,6 @@ static int el3_open(struct net_device *dev)
 	netif_start_queue(dev);
 	
 	tc574_reset(dev);
-	lp->media.function = media_check;
-	lp->media.data = (unsigned long) dev;
 	lp->media.expires = jiffies + HZ;
 	add_timer(&lp->media);
 	
@@ -859,10 +857,10 @@ static irqreturn_t el3_interrupt(int irq, void *dev_id)
 	(and as a last resort, poll the NIC for events), and to monitor
 	the MII, reporting changes in cable status.
 */
-static void media_check(unsigned long arg)
+static void media_check(struct timer_list *t)
 {
-	struct net_device *dev = (struct net_device *) arg;
-	struct el3_private *lp = netdev_priv(dev);
+	struct el3_private *lp = from_timer(lp, t, media);
+	struct net_device *dev = lp->p_dev->priv;
 	unsigned int ioaddr = dev->base_addr;
 	unsigned long flags;
 	unsigned short /* cable, */ media, partner;
diff --git a/drivers/net/ethernet/3com/3c589_cs.c b/drivers/net/ethernet/3com/3c589_cs.c
index e28254a00599..2b2695311bda 100644
--- a/drivers/net/ethernet/3com/3c589_cs.c
+++ b/drivers/net/ethernet/3com/3c589_cs.c
@@ -163,7 +163,7 @@ static void tc589_release(struct pcmcia_device *link);
 
 static u16 read_eeprom(unsigned int ioaddr, int index);
 static void tc589_reset(struct net_device *dev);
-static void media_check(unsigned long arg);
+static void media_check(struct timer_list *t);
 static int el3_config(struct net_device *dev, struct ifmap *map);
 static int el3_open(struct net_device *dev);
 static netdev_tx_t el3_start_xmit(struct sk_buff *skb,
@@ -517,7 +517,7 @@ static int el3_open(struct net_device *dev)
 	netif_start_queue(dev);
 
 	tc589_reset(dev);
-	setup_timer(&lp->media, media_check, (unsigned long)dev);
+	timer_setup(&lp->media, media_check, 0);
 	mod_timer(&lp->media, jiffies + HZ);
 
 	dev_dbg(&link->dev, "%s: opened, status %4.4x.\n",
@@ -676,10 +676,10 @@ static irqreturn_t el3_interrupt(int irq, void *dev_id)
 	return IRQ_RETVAL(handled);
 }
 
-static void media_check(unsigned long arg)
+static void media_check(struct timer_list *t)
 {
-	struct net_device *dev = (struct net_device *)(arg);
-	struct el3_private *lp = netdev_priv(dev);
+	struct el3_private *lp = from_timer(lp, t, media);
+	struct net_device *dev = lp->p_dev->priv;
 	unsigned int ioaddr = dev->base_addr;
 	u16 media, errs;
 	unsigned long flags;
diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet/3com/3c59x.c
index 402d9090ad29..f4e13a7014bd 100644
--- a/drivers/net/ethernet/3com/3c59x.c
+++ b/drivers/net/ethernet/3com/3c59x.c
@@ -759,8 +759,8 @@ static int vortex_open(struct net_device *dev);
 static void mdio_sync(struct vortex_private *vp, int bits);
 static int mdio_read(struct net_device *dev, int phy_id, int location);
 static void mdio_write(struct net_device *vp, int phy_id, int location, int value);
-static void vortex_timer(unsigned long arg);
-static void rx_oom_timer(unsigned long arg);
+static void vortex_timer(struct timer_list *t);
+static void rx_oom_timer(struct timer_list *t);
 static netdev_tx_t vortex_start_xmit(struct sk_buff *skb,
 				     struct net_device *dev);
 static netdev_tx_t boomerang_start_xmit(struct sk_buff *skb,
@@ -1599,9 +1599,9 @@ vortex_up(struct net_device *dev)
 				dev->name, media_tbl[dev->if_port].name);
 	}
 
-	setup_timer(&vp->timer, vortex_timer, (unsigned long)dev);
+	timer_setup(&vp->timer, vortex_timer, 0);
 	mod_timer(&vp->timer, RUN_AT(media_tbl[dev->if_port].wait));
-	setup_timer(&vp->rx_oom_timer, rx_oom_timer, (unsigned long)dev);
+	timer_setup(&vp->rx_oom_timer, rx_oom_timer, 0);
 
 	if (vortex_debug > 1)
 		pr_debug("%s: Initial media type %s.\n",
@@ -1784,10 +1784,10 @@ vortex_open(struct net_device *dev)
 }
 
 static void
-vortex_timer(unsigned long data)
+vortex_timer(struct timer_list *t)
 {
-	struct net_device *dev = (struct net_device *)data;
-	struct vortex_private *vp = netdev_priv(dev);
+	struct vortex_private *vp = from_timer(vp, t, timer);
+	struct net_device *dev = vp->mii.dev;
 	void __iomem *ioaddr = vp->ioaddr;
 	int next_tick = 60*HZ;
 	int ok = 0;
@@ -2687,10 +2687,10 @@ boomerang_rx(struct net_device *dev)
  * for some memory.  Otherwise there is no way to restart the rx process.
  */
 static void
-rx_oom_timer(unsigned long arg)
+rx_oom_timer(struct timer_list *t)
 {
-	struct net_device *dev = (struct net_device *)arg;
-	struct vortex_private *vp = netdev_priv(dev);
+	struct vortex_private *vp = from_timer(vp, t, rx_oom_timer);
+	struct net_device *dev = vp->mii.dev;
 
 	spin_lock_irq(&vp->lock);
 	if ((vp->cur_rx - vp->dirty_rx) == RX_RING_SIZE)	/* This test is redundant, but makes me feel good */
-- 
2.7.4
