From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] ethernet/broadcom: Convert timers to use timer_setup()
Date: Wed, 4 Oct 2017 17:50:43 -0700
Message-ID: <20171005005043.GA23290@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        bcm-kernel-feedback-list@broadcom.com,
        "David S. Miller" <davem@davemloft.net>,
        Arnd Bergmann <arnd@arndb.de>, Jarod Wilson <jarod@redhat.com>,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        Thomas Gleixner <tglx@linutronix.de>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
helper to pass the timer pointer explicitly.

Cc: Florian Fainelli <f.fainelli@gmail.com>
Cc: bcm-kernel-feedback-list@broadcom.com
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Jarod Wilson <jarod@redhat.com>
Cc: netdev@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
This requires commit 686fef928bba ("timer: Prepare to change timer
callback argument type") in v4.14-rc3, but should be otherwise
stand-alone.
---
 drivers/net/ethernet/broadcom/bcm63xx_enet.c | 27 +++++++++------------------
 1 file changed, 9 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index 4f3845a58126..99c2270d4677 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -295,16 +295,13 @@ static int bcm_enet_refill_rx(struct net_device *dev)
 /*
  * timer callback to defer refill rx queue in case we're OOM
  */
-static void bcm_enet_refill_rx_timer(unsigned long data)
+static void bcm_enet_refill_rx_timer(struct timer_list *t)
 {
-	struct net_device *dev;
-	struct bcm_enet_priv *priv;
-
-	dev = (struct net_device *)data;
-	priv = netdev_priv(dev);
+	struct bcm_enet_priv *priv = from_timer(priv, t, rx_timeout);
+	struct net_device *dev = priv->net_dev;
 
 	spin_lock(&priv->rx_lock);
-	bcm_enet_refill_rx((struct net_device *)data);
+	bcm_enet_refill_rx(dev);
 	spin_unlock(&priv->rx_lock);
 }
 
@@ -1857,9 +1854,7 @@ static int bcm_enet_probe(struct platform_device *pdev)
 	spin_lock_init(&priv->rx_lock);
 
 	/* init rx timeout (used for oom) */
-	init_timer(&priv->rx_timeout);
-	priv->rx_timeout.function = bcm_enet_refill_rx_timer;
-	priv->rx_timeout.data = (unsigned long)dev;
+	timer_setup(&priv->rx_timeout, bcm_enet_refill_rx_timer, 0);
 
 	/* init the mib update lock&work */
 	mutex_init(&priv->mib_update_lock);
@@ -2021,9 +2016,9 @@ static inline int bcm_enet_port_is_rgmii(int portid)
 /*
  * enet sw PHY polling
  */
-static void swphy_poll_timer(unsigned long data)
+static void swphy_poll_timer(struct timer_list *t)
 {
-	struct bcm_enet_priv *priv = (struct bcm_enet_priv *)data;
+	struct bcm_enet_priv *priv = from_timer(priv, t, swphy_poll);
 	unsigned int i;
 
 	for (i = 0; i < priv->num_ports; i++) {
@@ -2332,9 +2327,7 @@ static int bcm_enetsw_open(struct net_device *dev)
 	}
 
 	/* start phy polling timer */
-	init_timer(&priv->swphy_poll);
-	priv->swphy_poll.function = swphy_poll_timer;
-	priv->swphy_poll.data = (unsigned long)priv;
+	timer_setup(&priv->swphy_poll, swphy_poll_timer, 0);
 	priv->swphy_poll.expires = jiffies;
 	add_timer(&priv->swphy_poll);
 	return 0;
@@ -2759,9 +2752,7 @@ static int bcm_enetsw_probe(struct platform_device *pdev)
 	spin_lock_init(&priv->rx_lock);
 
 	/* init rx timeout (used for oom) */
-	init_timer(&priv->rx_timeout);
-	priv->rx_timeout.function = bcm_enet_refill_rx_timer;
-	priv->rx_timeout.data = (unsigned long)dev;
+	timer_setup(&priv->rx_timeout, bcm_enet_refill_rx_timer, 0);
 
 	/* register netdevice */
 	dev->netdev_ops = &bcm_enetsw_ops;
-- 
2.7.4


-- 
Kees Cook
Pixel Security
