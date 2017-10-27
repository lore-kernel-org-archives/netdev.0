From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] drivers/net: fealnx: Convert timers to use timer_setup()
Date: Thu, 26 Oct 2017 22:55:07 -0700
Message-ID: <20171027055507.GA110104@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "yuval.shaia@oracle.com" <yuval.shaia@oracle.com>,
        Allen Pais <allen.lkml@gmail.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Philippe Reynes <tremyfr@gmail.com>,
        Johannes Berg <johannes.berg@intel.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: "yuval.shaia@oracle.com" <yuval.shaia@oracle.com>
Cc: Allen Pais <allen.lkml@gmail.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: Philippe Reynes <tremyfr@gmail.com>
Cc: Johannes Berg <johannes.berg@intel.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/ethernet/fealnx.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/fealnx.c b/drivers/net/ethernet/fealnx.c
index c8982313d850..23053919ebf5 100644
--- a/drivers/net/ethernet/fealnx.c
+++ b/drivers/net/ethernet/fealnx.c
@@ -426,8 +426,8 @@ static void mdio_write(struct net_device *dev, int phy_id, int location, int val
 static int netdev_open(struct net_device *dev);
 static void getlinktype(struct net_device *dev);
 static void getlinkstatus(struct net_device *dev);
-static void netdev_timer(unsigned long data);
-static void reset_timer(unsigned long data);
+static void netdev_timer(struct timer_list *t);
+static void reset_timer(struct timer_list *t);
 static void fealnx_tx_timeout(struct net_device *dev);
 static void init_ring(struct net_device *dev);
 static netdev_tx_t start_tx(struct sk_buff *skb, struct net_device *dev);
@@ -909,13 +909,13 @@ static int netdev_open(struct net_device *dev)
 		printk(KERN_DEBUG "%s: Done netdev_open().\n", dev->name);
 
 	/* Set the timer to check for link beat. */
-	setup_timer(&np->timer, netdev_timer, (unsigned long)dev);
+	timer_setup(&np->timer, netdev_timer, 0);
 	np->timer.expires = RUN_AT(3 * HZ);
 
 	/* timer handler */
 	add_timer(&np->timer);
 
-	setup_timer(&np->reset_timer, reset_timer, (unsigned long)dev);
+	timer_setup(&np->reset_timer, reset_timer, 0);
 	np->reset_timer_armed = 0;
 	return rc;
 }
@@ -1078,10 +1078,10 @@ static void allocate_rx_buffers(struct net_device *dev)
 }
 
 
-static void netdev_timer(unsigned long data)
+static void netdev_timer(struct timer_list *t)
 {
-	struct net_device *dev = (struct net_device *) data;
-	struct netdev_private *np = netdev_priv(dev);
+	struct netdev_private *np = from_timer(np, t, timer);
+	struct net_device *dev = np->mii.dev;
 	void __iomem *ioaddr = np->mem;
 	int old_crvalue = np->crvalue;
 	unsigned int old_linkok = np->linkok;
@@ -1167,10 +1167,10 @@ static void enable_rxtx(struct net_device *dev)
 }
 
 
-static void reset_timer(unsigned long data)
+static void reset_timer(struct timer_list *t)
 {
-	struct net_device *dev = (struct net_device *) data;
-	struct netdev_private *np = netdev_priv(dev);
+	struct netdev_private *np = from_timer(np, t, reset_timer);
+	struct net_device *dev = np->mii.dev;
 	unsigned long flags;
 
 	printk(KERN_WARNING "%s: resetting tx and rx machinery\n", dev->name);
-- 
2.7.4


-- 
Kees Cook
Pixel Security
