From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 13/58] ethernet/broadcom: Convert timers to use timer_setup()
Date: Mon, 16 Oct 2017 17:28:57 -0700
Message-ID: <1508200182-104605-14-git-send-email-keescook@chromium.org>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, Kees Cook <keescook@chromium.org>,
 Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, Jarod Wilson <jarod@redhat.com>,
 bcm-kernel-feedback-list@broadcom.com, Thomas Gleixner <tglx@linutronix.de>,
 linux-arm-kernel@lists.infradead.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1508200182-104605-1-git-send-email-keescook@chromium.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
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
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/ethernet/broadcom/bcm63xx_enet.c | 24 +++++++++---------------
 1 file changed, 9 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index f6bc13fe8a99..d9346e2ac720 100644
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
 
@@ -1860,8 +1857,7 @@ static int bcm_enet_probe(struct platform_device *pdev)
 	spin_lock_init(&priv->rx_lock);
 
 	/* init rx timeout (used for oom) */
-	setup_timer(&priv->rx_timeout, bcm_enet_refill_rx_timer,
-		    (unsigned long)dev);
+	timer_setup(&priv->rx_timeout, bcm_enet_refill_rx_timer, 0);
 
 	/* init the mib update lock&work */
 	mutex_init(&priv->mib_update_lock);
@@ -2015,9 +2011,9 @@ static inline int bcm_enet_port_is_rgmii(int portid)
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
@@ -2326,7 +2322,7 @@ static int bcm_enetsw_open(struct net_device *dev)
 	}
 
 	/* start phy polling timer */
-	setup_timer(&priv->swphy_poll, swphy_poll_timer, (unsigned long)priv);
+	timer_setup(&priv->swphy_poll, swphy_poll_timer, 0);
 	mod_timer(&priv->swphy_poll, jiffies);
 	return 0;
 
@@ -2743,9 +2739,7 @@ static int bcm_enetsw_probe(struct platform_device *pdev)
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
