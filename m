From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] drivers/net: sis: Convert timers to use timer_setup()
Date: Tue, 24 Oct 2017 01:46:52 -0700
Message-ID: <20171024084652.GA23986@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>,
        Daniele Venzano <venza@brownhat.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:48677 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751980AbdJXIqz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 04:46:55 -0400
Received: by mail-pf0-f193.google.com with SMTP id b79so19197655pfk.5
        for <netdev@vger.kernel.org>; Tue, 24 Oct 2017 01:46:55 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: Francois Romieu <romieu@fr.zoreil.com>
Cc: Daniele Venzano <venza@brownhat.org>
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/ethernet/sis/sis190.c | 10 ++++------
 drivers/net/ethernet/sis/sis900.c | 10 +++++-----
 2 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/sis/sis190.c b/drivers/net/ethernet/sis/sis190.c
index 445109bd6910..c2c50522b96d 100644
--- a/drivers/net/ethernet/sis/sis190.c
+++ b/drivers/net/ethernet/sis/sis190.c
@@ -1018,10 +1018,10 @@ static void sis190_phy_task(struct work_struct *work)
 	rtnl_unlock();
 }
 
-static void sis190_phy_timer(unsigned long __opaque)
+static void sis190_phy_timer(struct timer_list *t)
 {
-	struct net_device *dev = (struct net_device *)__opaque;
-	struct sis190_private *tp = netdev_priv(dev);
+	struct sis190_private *tp = from_timer(tp, t, timer);
+	struct net_device *dev = tp->dev;
 
 	if (likely(netif_running(dev)))
 		schedule_work(&tp->phy_task);
@@ -1039,10 +1039,8 @@ static inline void sis190_request_timer(struct net_device *dev)
 	struct sis190_private *tp = netdev_priv(dev);
 	struct timer_list *timer = &tp->timer;
 
-	init_timer(timer);
+	timer_setup(timer, sis190_phy_timer, 0);
 	timer->expires = jiffies + SIS190_PHY_TIMEOUT;
-	timer->data = (unsigned long)dev;
-	timer->function = sis190_phy_timer;
 	add_timer(timer);
 }
 
diff --git a/drivers/net/ethernet/sis/sis900.c b/drivers/net/ethernet/sis/sis900.c
index cb61247b0526..4bb89f74742c 100644
--- a/drivers/net/ethernet/sis/sis900.c
+++ b/drivers/net/ethernet/sis/sis900.c
@@ -218,7 +218,7 @@ static void sis900_init_rxfilter (struct net_device * net_dev);
 static u16 read_eeprom(void __iomem *ioaddr, int location);
 static int mdio_read(struct net_device *net_dev, int phy_id, int location);
 static void mdio_write(struct net_device *net_dev, int phy_id, int location, int val);
-static void sis900_timer(unsigned long data);
+static void sis900_timer(struct timer_list *t);
 static void sis900_check_mode (struct net_device *net_dev, struct mii_phy *mii_phy);
 static void sis900_tx_timeout(struct net_device *net_dev);
 static void sis900_init_tx_ring(struct net_device *net_dev);
@@ -1065,7 +1065,7 @@ sis900_open(struct net_device *net_dev)
 
 	/* Set the timer to switch to check for link beat and perhaps switch
 	   to an alternate media type. */
-	setup_timer(&sis_priv->timer, sis900_timer, (unsigned long)net_dev);
+	timer_setup(&sis_priv->timer, sis900_timer, 0);
 	sis_priv->timer.expires = jiffies + HZ;
 	add_timer(&sis_priv->timer);
 
@@ -1300,10 +1300,10 @@ static void sis630_set_eq(struct net_device *net_dev, u8 revision)
  *	link status (ON/OFF) and link mode (10/100/Full/Half)
  */
 
-static void sis900_timer(unsigned long data)
+static void sis900_timer(struct timer_list *t)
 {
-	struct net_device *net_dev = (struct net_device *)data;
-	struct sis900_private *sis_priv = netdev_priv(net_dev);
+	struct sis900_private *sis_priv = from_timer(sis_priv, t, timer);
+	struct net_device *net_dev = sis_priv->mii_info.dev;
 	struct mii_phy *mii_phy = sis_priv->mii;
 	static const int next_tick = 5*HZ;
 	int speed = 0, duplex = 0;
-- 
2.7.4


-- 
Kees Cook
Pixel Security
