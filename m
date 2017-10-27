From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] drivers/net: smsc: Convert timers to use timer_setup()
Date: Thu, 26 Oct 2017 22:55:42 -0700
Message-ID: <20171027055542.GA128951@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "yuval.shaia@oracle.com" <yuval.shaia@oracle.com>,
        Eric Dumazet <edumazet@google.com>,
        Philippe Reynes <tremyfr@gmail.com>,
        Allen Pais <allen.lkml@gmail.com>,
        Tobias Klauser <tklauser@distanz.ch>, netdev@vger.kernel.org,
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
Cc: "yuval.shaia@oracle.com" <yuval.shaia@oracle.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Philippe Reynes <tremyfr@gmail.com>
Cc: Allen Pais <allen.lkml@gmail.com>
Cc: Tobias Klauser <tklauser@distanz.ch>
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/ethernet/smsc/epic100.c     | 10 +++++-----
 drivers/net/ethernet/smsc/smc91c92_cs.c | 10 +++++-----
 2 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/smsc/epic100.c b/drivers/net/ethernet/smsc/epic100.c
index 2a9724898fcf..949aaef390b6 100644
--- a/drivers/net/ethernet/smsc/epic100.c
+++ b/drivers/net/ethernet/smsc/epic100.c
@@ -290,7 +290,7 @@ static int read_eeprom(struct epic_private *, int);
 static int mdio_read(struct net_device *dev, int phy_id, int location);
 static void mdio_write(struct net_device *dev, int phy_id, int loc, int val);
 static void epic_restart(struct net_device *dev);
-static void epic_timer(unsigned long data);
+static void epic_timer(struct timer_list *t);
 static void epic_tx_timeout(struct net_device *dev);
 static void epic_init_ring(struct net_device *dev);
 static netdev_tx_t epic_start_xmit(struct sk_buff *skb,
@@ -739,7 +739,7 @@ static int epic_open(struct net_device *dev)
 
 	/* Set the timer to switch to check for link beat and perhaps switch
 	   to an alternate media type. */
-	setup_timer(&ep->timer, epic_timer, (unsigned long)dev);
+	timer_setup(&ep->timer, epic_timer, 0);
 	ep->timer.expires = jiffies + 3*HZ;
 	add_timer(&ep->timer);
 
@@ -843,10 +843,10 @@ static void check_media(struct net_device *dev)
 	}
 }
 
-static void epic_timer(unsigned long data)
+static void epic_timer(struct timer_list *t)
 {
-	struct net_device *dev = (struct net_device *)data;
-	struct epic_private *ep = netdev_priv(dev);
+	struct epic_private *ep = from_timer(ep, t, timer);
+	struct net_device *dev = ep->mii.dev;
 	void __iomem *ioaddr = ep->ioaddr;
 	int next_tick = 5*HZ;
 
diff --git a/drivers/net/ethernet/smsc/smc91c92_cs.c b/drivers/net/ethernet/smsc/smc91c92_cs.c
index 92c927aec66d..a55f430f6a7b 100644
--- a/drivers/net/ethernet/smsc/smc91c92_cs.c
+++ b/drivers/net/ethernet/smsc/smc91c92_cs.c
@@ -280,7 +280,7 @@ static void set_rx_mode(struct net_device *dev);
 static int s9k_config(struct net_device *dev, struct ifmap *map);
 static void smc_set_xcvr(struct net_device *dev, int if_port);
 static void smc_reset(struct net_device *dev);
-static void media_check(u_long arg);
+static void media_check(struct timer_list *t);
 static void mdio_sync(unsigned int addr);
 static int mdio_read(struct net_device *dev, int phy_id, int loc);
 static void mdio_write(struct net_device *dev, int phy_id, int loc, int value);
@@ -1070,7 +1070,7 @@ static int smc_open(struct net_device *dev)
     smc->packets_waiting = 0;
 
     smc_reset(dev);
-    setup_timer(&smc->media, media_check, (u_long)dev);
+    timer_setup(&smc->media, media_check, 0);
     mod_timer(&smc->media, jiffies + HZ);
 
     return 0;
@@ -1708,10 +1708,10 @@ static void smc_reset(struct net_device *dev)
 
 ======================================================================*/
 
-static void media_check(u_long arg)
+static void media_check(struct timer_list *t)
 {
-    struct net_device *dev = (struct net_device *) arg;
-    struct smc_private *smc = netdev_priv(dev);
+    struct smc_private *smc = from_timer(smc, t, media);
+    struct net_device *dev = smc->mii_if.dev;
     unsigned int ioaddr = dev->base_addr;
     u_short i, media, saved_bank;
     u_short link;
-- 
2.7.4


-- 
Kees Cook
Pixel Security
