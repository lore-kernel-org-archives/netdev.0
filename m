From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] drivers/net: dlink: Convert timers to use timer_setup()
Date: Thu, 26 Oct 2017 22:54:59 -0700
Message-ID: <20171027055459.GA105727@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denis Kirjanov <kda@linux-powerpc.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:55385 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752099AbdJ0FzC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 01:55:02 -0400
Received: by mail-pg0-f65.google.com with SMTP id 15so4496935pgc.12
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 22:55:02 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: Denis Kirjanov <kda@linux-powerpc.org>
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/ethernet/dlink/sundance.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/dlink/sundance.c b/drivers/net/ethernet/dlink/sundance.c
index 6ca9e981ad57..1a27176381fb 100644
--- a/drivers/net/ethernet/dlink/sundance.c
+++ b/drivers/net/ethernet/dlink/sundance.c
@@ -431,7 +431,7 @@ static void mdio_write(struct net_device *dev, int phy_id, int location, int val
 static int  mdio_wait_link(struct net_device *dev, int wait);
 static int  netdev_open(struct net_device *dev);
 static void check_duplex(struct net_device *dev);
-static void netdev_timer(unsigned long data);
+static void netdev_timer(struct timer_list *t);
 static void tx_timeout(struct net_device *dev);
 static void init_ring(struct net_device *dev);
 static netdev_tx_t start_tx(struct sk_buff *skb, struct net_device *dev);
@@ -913,7 +913,7 @@ static int netdev_open(struct net_device *dev)
 			   ioread16(ioaddr + MACCtrl1), ioread16(ioaddr + MACCtrl0));
 
 	/* Set the timer to check for link beat. */
-	setup_timer(&np->timer, netdev_timer, (unsigned long)dev);
+	timer_setup(&np->timer, netdev_timer, 0);
 	np->timer.expires = jiffies + 3*HZ;
 	add_timer(&np->timer);
 
@@ -951,10 +951,10 @@ static void check_duplex(struct net_device *dev)
 	}
 }
 
-static void netdev_timer(unsigned long data)
+static void netdev_timer(struct timer_list *t)
 {
-	struct net_device *dev = (struct net_device *)data;
-	struct netdev_private *np = netdev_priv(dev);
+	struct netdev_private *np = from_timer(np, t, timer);
+	struct net_device *dev = np->mii_if.dev;
 	void __iomem *ioaddr = np->base;
 	int next_tick = 10*HZ;
 
-- 
2.7.4


-- 
Kees Cook
Pixel Security
