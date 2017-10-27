From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] drivers/net: 8390: Convert timers to use timer_setup()
Date: Thu, 26 Oct 2017 22:54:25 -0700
Message-ID: <20171027055425.GA80645@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:48791 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750790AbdJ0Fy3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 01:54:29 -0400
Received: by mail-pf0-f194.google.com with SMTP id b79so4215535pfk.5
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 22:54:29 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/ethernet/8390/axnet_cs.c | 10 +++++-----
 drivers/net/ethernet/8390/pcnet_cs.c | 10 +++++-----
 2 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/8390/axnet_cs.c b/drivers/net/ethernet/8390/axnet_cs.c
index 3da1fc539ef9..7bddb8efb6d5 100644
--- a/drivers/net/ethernet/8390/axnet_cs.c
+++ b/drivers/net/ethernet/8390/axnet_cs.c
@@ -85,7 +85,7 @@ static struct net_device_stats *get_stats(struct net_device *dev);
 static void set_multicast_list(struct net_device *dev);
 static void axnet_tx_timeout(struct net_device *dev);
 static irqreturn_t ei_irq_wrapper(int irq, void *dev_id);
-static void ei_watchdog(u_long arg);
+static void ei_watchdog(struct timer_list *t);
 static void axnet_reset_8390(struct net_device *dev);
 
 static int mdio_read(unsigned int addr, int phy_id, int loc);
@@ -483,7 +483,7 @@ static int axnet_open(struct net_device *dev)
     link->open++;
 
     info->link_status = 0x00;
-    setup_timer(&info->watchdog, ei_watchdog, (u_long)dev);
+    timer_setup(&info->watchdog, ei_watchdog, 0);
     mod_timer(&info->watchdog, jiffies + HZ);
 
     return ax_open(dev);
@@ -547,10 +547,10 @@ static irqreturn_t ei_irq_wrapper(int irq, void *dev_id)
     return ax_interrupt(irq, dev_id);
 }
 
-static void ei_watchdog(u_long arg)
+static void ei_watchdog(struct timer_list *t)
 {
-    struct net_device *dev = (struct net_device *)(arg);
-    struct axnet_dev *info = PRIV(dev);
+    struct axnet_dev *info = from_timer(info, t, watchdog);
+    struct net_device *dev = info->p_dev->priv;
     unsigned int nic_base = dev->base_addr;
     unsigned int mii_addr = nic_base + AXNET_MII_EEP;
     u_short link;
diff --git a/drivers/net/ethernet/8390/pcnet_cs.c b/drivers/net/ethernet/8390/pcnet_cs.c
index bd0a2a14b649..eae9827035dc 100644
--- a/drivers/net/ethernet/8390/pcnet_cs.c
+++ b/drivers/net/ethernet/8390/pcnet_cs.c
@@ -99,7 +99,7 @@ static int pcnet_open(struct net_device *dev);
 static int pcnet_close(struct net_device *dev);
 static int ei_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 static irqreturn_t ei_irq_wrapper(int irq, void *dev_id);
-static void ei_watchdog(u_long arg);
+static void ei_watchdog(struct timer_list *t);
 static void pcnet_reset_8390(struct net_device *dev);
 static int set_config(struct net_device *dev, struct ifmap *map);
 static int setup_shmem_window(struct pcmcia_device *link, int start_pg,
@@ -917,7 +917,7 @@ static int pcnet_open(struct net_device *dev)
 
     info->phy_id = info->eth_phy;
     info->link_status = 0x00;
-    setup_timer(&info->watchdog, ei_watchdog, (u_long)dev);
+    timer_setup(&info->watchdog, ei_watchdog, 0);
     mod_timer(&info->watchdog, jiffies + HZ);
 
     return ei_open(dev);
@@ -1006,10 +1006,10 @@ static irqreturn_t ei_irq_wrapper(int irq, void *dev_id)
     return ret;
 }
 
-static void ei_watchdog(u_long arg)
+static void ei_watchdog(struct timer_list *t)
 {
-    struct net_device *dev = (struct net_device *)arg;
-    struct pcnet_dev *info = PRIV(dev);
+    struct pcnet_dev *info = from_timer(info, t, watchdog);
+    struct net_device *dev = info->p_dev->priv;
     unsigned int nic_base = dev->base_addr;
     unsigned int mii_addr = nic_base + DLINK_GPIO;
     u_short link;
-- 
2.7.4


-- 
Kees Cook
Pixel Security
