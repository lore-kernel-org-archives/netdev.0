From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] forcedeth: Convert timers to use timer_setup()
Date: Wed, 4 Oct 2017 17:52:03 -0700
Message-ID: <20171005005203.GA23528@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Zhu Yanjun <yanjun.zhu@oracle.com>,
        Philippe Reynes <tremyfr@gmail.com>, netdev@vger.kernel.org,
        Thomas Gleixner <tglx@linutronix.de>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:49835 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752705AbdJEAwG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 20:52:06 -0400
Received: by mail-pg0-f45.google.com with SMTP id v13so7417068pgq.6
        for <netdev@vger.kernel.org>; Wed, 04 Oct 2017 17:52:05 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Zhu Yanjun <yanjun.zhu@oracle.com>
Cc: Philippe Reynes <tremyfr@gmail.com>
Cc: netdev@vger.kernel.org
Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
This requires commit 686fef928bba ("timer: Prepare to change timer
callback argument type") in v4.14-rc3, but should be otherwise
stand-alone.
---
 drivers/net/ethernet/nvidia/forcedeth.c | 28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 994a83a1f0a5..277b233c781f 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -1884,10 +1884,9 @@ static int nv_alloc_rx_optimized(struct net_device *dev)
 }
 
 /* If rx bufs are exhausted called after 50ms to attempt to refresh */
-static void nv_do_rx_refill(unsigned long data)
+static void nv_do_rx_refill(struct timer_list *t)
 {
-	struct net_device *dev = (struct net_device *) data;
-	struct fe_priv *np = netdev_priv(dev);
+	struct fe_priv *np = from_timer(np, t, oom_kick);
 
 	/* Just reschedule NAPI rx processing */
 	napi_schedule(&np->napi);
@@ -4061,10 +4060,10 @@ static void nv_free_irq(struct net_device *dev)
 	}
 }
 
-static void nv_do_nic_poll(unsigned long data)
+static void nv_do_nic_poll(struct timer_list *t)
 {
-	struct net_device *dev = (struct net_device *) data;
-	struct fe_priv *np = netdev_priv(dev);
+	struct fe_priv *np = from_timer(np, t, nic_poll);
+	struct net_device *dev = np->dev;
 	u8 __iomem *base = get_hwbase(dev);
 	u32 mask = 0;
 	unsigned long flags;
@@ -4172,16 +4171,18 @@ static void nv_do_nic_poll(unsigned long data)
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void nv_poll_controller(struct net_device *dev)
 {
-	nv_do_nic_poll((unsigned long) dev);
+	struct fe_priv *np = netdev_priv(dev);
+
+	nv_do_nic_poll(&np->nic_poll);
 }
 #endif
 
-static void nv_do_stats_poll(unsigned long data)
+static void nv_do_stats_poll(struct timer_list *t)
 	__acquires(&netdev_priv(dev)->hwstats_lock)
 	__releases(&netdev_priv(dev)->hwstats_lock)
 {
-	struct net_device *dev = (struct net_device *) data;
-	struct fe_priv *np = netdev_priv(dev);
+	struct fe_priv *np = from_timer(np, t, stats_poll);
+	struct net_device *dev = np->dev;
 
 	/* If lock is currently taken, the stats are being refreshed
 	 * and hence fresh enough */
@@ -5627,10 +5628,9 @@ static int nv_probe(struct pci_dev *pci_dev, const struct pci_device_id *id)
 	u64_stats_init(&np->swstats_rx_syncp);
 	u64_stats_init(&np->swstats_tx_syncp);
 
-	setup_timer(&np->oom_kick, nv_do_rx_refill, (unsigned long)dev);
-	setup_timer(&np->nic_poll, nv_do_nic_poll, (unsigned long)dev);
-	setup_deferrable_timer(&np->stats_poll, nv_do_stats_poll,
-			       (unsigned long)dev);
+	timer_setup(&np->oom_kick, nv_do_rx_refill, 0);
+	timer_setup(&np->nic_poll, nv_do_nic_poll, 0);
+	timer_setup(&np->stats_poll, nv_do_stats_poll, TIMER_DEFERRABLE);
 
 	err = pci_enable_device(pci_dev);
 	if (err)
-- 
2.7.4


-- 
Kees Cook
Pixel Security
