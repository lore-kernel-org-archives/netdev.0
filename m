From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] drivers/net: packetengines: Convert timers to use
 timer_setup()
Date: Thu, 26 Oct 2017 22:55:34 -0700
Message-ID: <20171027055534.GA125544@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Allen Pais <allen.lkml@gmail.com>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>,
        Philippe Reynes <tremyfr@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:54392 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752209AbdJ0Fzh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 01:55:37 -0400
Received: by mail-pf0-f196.google.com with SMTP id n89so4206391pfk.11
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 22:55:36 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Allen Pais <allen.lkml@gmail.com>
Cc: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
Cc: Philippe Reynes <tremyfr@gmail.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/ethernet/packetengines/hamachi.c   | 14 +++++++-------
 drivers/net/ethernet/packetengines/yellowfin.c | 10 +++++-----
 2 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/packetengines/hamachi.c b/drivers/net/ethernet/packetengines/hamachi.c
index 77bc7cca8980..c9529c29a0a7 100644
--- a/drivers/net/ethernet/packetengines/hamachi.c
+++ b/drivers/net/ethernet/packetengines/hamachi.c
@@ -413,13 +413,13 @@ that case.
 
 /* The rest of these values should never change. */
 
-static void hamachi_timer(unsigned long data);
+static void hamachi_timer(struct timer_list *t);
 
 enum capability_flags {CanHaveMII=1, };
 static const struct chip_info {
 	u16	vendor_id, device_id, device_id_mask, pad;
 	const char *name;
-	void (*media_timer)(unsigned long data);
+	void (*media_timer)(struct timer_list *t);
 	int flags;
 } chip_tbl[] = {
 	{0x1318, 0x0911, 0xffff, 0, "Hamachi GNIC-II", hamachi_timer, 0},
@@ -547,7 +547,7 @@ static int mdio_read(struct net_device *dev, int phy_id, int location);
 static void mdio_write(struct net_device *dev, int phy_id, int location, int value);
 static int hamachi_open(struct net_device *dev);
 static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
-static void hamachi_timer(unsigned long data);
+static void hamachi_timer(struct timer_list *t);
 static void hamachi_tx_timeout(struct net_device *dev);
 static void hamachi_init_ring(struct net_device *dev);
 static netdev_tx_t hamachi_start_xmit(struct sk_buff *skb,
@@ -979,7 +979,7 @@ static int hamachi_open(struct net_device *dev)
 			   dev->name, readw(ioaddr + RxStatus), readw(ioaddr + TxStatus));
 	}
 	/* Set the timer to check for link beat. */
-	setup_timer(&hmp->timer, hamachi_timer, (unsigned long)dev);
+	timer_setup(&hmp->timer, hamachi_timer, 0);
 	hmp->timer.expires = RUN_AT((24*HZ)/10);			/* 2.4 sec. */
 	add_timer(&hmp->timer);
 
@@ -1017,10 +1017,10 @@ static inline int hamachi_tx(struct net_device *dev)
 	return 0;
 }
 
-static void hamachi_timer(unsigned long data)
+static void hamachi_timer(struct timer_list *t)
 {
-	struct net_device *dev = (struct net_device *)data;
-	struct hamachi_private *hmp = netdev_priv(dev);
+	struct hamachi_private *hmp = from_timer(hmp, t, timer);
+	struct net_device *dev = hmp->mii_if.dev;
 	void __iomem *ioaddr = hmp->base;
 	int next_tick = 10*HZ;
 
diff --git a/drivers/net/ethernet/packetengines/yellowfin.c b/drivers/net/ethernet/packetengines/yellowfin.c
index 33c241f52a71..54224d1822e3 100644
--- a/drivers/net/ethernet/packetengines/yellowfin.c
+++ b/drivers/net/ethernet/packetengines/yellowfin.c
@@ -343,7 +343,7 @@ static int mdio_read(void __iomem *ioaddr, int phy_id, int location);
 static void mdio_write(void __iomem *ioaddr, int phy_id, int location, int value);
 static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 static int yellowfin_open(struct net_device *dev);
-static void yellowfin_timer(unsigned long data);
+static void yellowfin_timer(struct timer_list *t);
 static void yellowfin_tx_timeout(struct net_device *dev);
 static int yellowfin_init_ring(struct net_device *dev);
 static netdev_tx_t yellowfin_start_xmit(struct sk_buff *skb,
@@ -632,7 +632,7 @@ static int yellowfin_open(struct net_device *dev)
 	}
 
 	/* Set the timer to check for link beat. */
-	setup_timer(&yp->timer, yellowfin_timer, (unsigned long)dev);
+	timer_setup(&yp->timer, yellowfin_timer, 0);
 	yp->timer.expires = jiffies + 3*HZ;
 	add_timer(&yp->timer);
 out:
@@ -643,10 +643,10 @@ static int yellowfin_open(struct net_device *dev)
 	goto out;
 }
 
-static void yellowfin_timer(unsigned long data)
+static void yellowfin_timer(struct timer_list *t)
 {
-	struct net_device *dev = (struct net_device *)data;
-	struct yellowfin_private *yp = netdev_priv(dev);
+	struct yellowfin_private *yp = from_timer(yp, t, timer);
+	struct net_device *dev = pci_get_drvdata(yp->pci_dev);
 	void __iomem *ioaddr = yp->base;
 	int next_tick = 60*HZ;
 
-- 
2.7.4


-- 
Kees Cook
Pixel Security
