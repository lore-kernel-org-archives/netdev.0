From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] drivers/net: wan/lmc: Convert timers to use timer_setup()
Date: Wed, 25 Oct 2017 03:53:53 -0700
Message-ID: <20171025105353.GA146631@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Allen Pais <allen.lkml@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: Allen Pais <allen.lkml@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/wan/lmc/lmc_main.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/lmc_main.c
index ae69d65158e6..37b1e0d03e31 100644
--- a/drivers/net/wan/lmc/lmc_main.c
+++ b/drivers/net/wan/lmc/lmc_main.c
@@ -99,7 +99,7 @@ static void lmc_initcsrs(lmc_softc_t * const sc, lmc_csrptr_t csr_base, size_t c
 static void lmc_softreset(lmc_softc_t * const);
 static void lmc_running_reset(struct net_device *dev);
 static int lmc_ifdown(struct net_device * const);
-static void lmc_watchdog(unsigned long data);
+static void lmc_watchdog(struct timer_list *t);
 static void lmc_reset(lmc_softc_t * const sc);
 static void lmc_dec_reset(lmc_softc_t * const sc);
 static void lmc_driver_timeout(struct net_device *dev);
@@ -636,10 +636,10 @@ int lmc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
 
 
 /* the watchdog process that cruises around */
-static void lmc_watchdog (unsigned long data) /*fold00*/
+static void lmc_watchdog(struct timer_list *t) /*fold00*/
 {
-    struct net_device *dev = (struct net_device *)data;
-    lmc_softc_t *sc = dev_to_sc(dev);
+    lmc_softc_t *sc = from_timer(sc, t, timer);
+    struct net_device *dev = sc->lmc_device;
     int link_status;
     u32 ticks;
     unsigned long flags;
@@ -1084,7 +1084,7 @@ static int lmc_open(struct net_device *dev)
      * Setup a timer for the watchdog on probe, and start it running.
      * Since lmc_ok == 0, it will be a NOP for now.
      */
-    setup_timer(&sc->timer, lmc_watchdog, (unsigned long)dev);
+    timer_setup(&sc->timer, lmc_watchdog, 0);
     sc->timer.expires = jiffies + HZ;
     add_timer (&sc->timer);
 
-- 
2.7.4


-- 
Kees Cook
Pixel Security
