From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 29/58] forcedeth: Convert timers to use timer_setup()
Date: Mon, 16 Oct 2017 17:29:13 -0700
Message-ID: <1508200182-104605-30-git-send-email-keescook@chromium.org>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>,
        Zhu Yanjun <yanjun.zhu@oracle.com>,
        Philippe Reynes <tremyfr@gmail.com>, netdev@vger.kernel.org,
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

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Zhu Yanjun <yanjun.zhu@oracle.com>
Cc: Philippe Reynes <tremyfr@gmail.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/ethernet/nvidia/forcedeth.c | 28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index a235e8881af9..88128ce61471 100644
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
@@ -4065,10 +4064,10 @@ static void nv_free_irq(struct net_device *dev)
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
@@ -4176,16 +4175,18 @@ static void nv_do_nic_poll(unsigned long data)
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
@@ -5631,10 +5632,9 @@ static int nv_probe(struct pci_dev *pci_dev, const struct pci_device_id *id)
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
