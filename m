From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 06/58] net/ti/tlan: Convert timers to use timer_setup()
Date: Mon, 16 Oct 2017 17:28:50 -0700
Message-ID: <1508200182-104605-7-git-send-email-keescook@chromium.org>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>,
        Samuel Chessman <chessman@tux.org>, netdev@vger.kernel.org,
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

Cc: Samuel Chessman <chessman@tux.org>
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/ethernet/ti/tlan.c | 32 +++++++++++++-------------------
 1 file changed, 13 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/ti/tlan.c b/drivers/net/ethernet/ti/tlan.c
index c8d53d8c83ee..8f53d762fbc4 100644
--- a/drivers/net/ethernet/ti/tlan.c
+++ b/drivers/net/ethernet/ti/tlan.c
@@ -172,7 +172,8 @@ static u32	tlan_handle_tx_eoc(struct net_device *, u16);
 static u32	tlan_handle_status_check(struct net_device *, u16);
 static u32	tlan_handle_rx_eoc(struct net_device *, u16);
 
-static void	tlan_timer(unsigned long);
+static void	tlan_timer(struct timer_list *t);
+static void	tlan_phy_monitor(struct timer_list *t);
 
 static void	tlan_reset_lists(struct net_device *);
 static void	tlan_free_lists(struct net_device *);
@@ -190,7 +191,6 @@ static void	tlan_phy_power_up(struct net_device *);
 static void	tlan_phy_reset(struct net_device *);
 static void	tlan_phy_start_link(struct net_device *);
 static void	tlan_phy_finish_auto_neg(struct net_device *);
-static void     tlan_phy_monitor(unsigned long);
 
 /*
   static int	tlan_phy_nop(struct net_device *);
@@ -254,11 +254,10 @@ tlan_set_timer(struct net_device *dev, u32 ticks, u32 type)
 			spin_unlock_irqrestore(&priv->lock, flags);
 		return;
 	}
-	priv->timer.function = tlan_timer;
+	priv->timer.function = (TIMER_FUNC_TYPE)tlan_timer;
 	if (!in_irq())
 		spin_unlock_irqrestore(&priv->lock, flags);
 
-	priv->timer.data = (unsigned long) dev;
 	priv->timer_set_at = jiffies;
 	priv->timer_type = type;
 	mod_timer(&priv->timer, jiffies + ticks);
@@ -926,8 +925,8 @@ static int tlan_open(struct net_device *dev)
 		return err;
 	}
 
-	init_timer(&priv->timer);
-	init_timer(&priv->media_timer);
+	timer_setup(&priv->timer, NULL, 0);
+	timer_setup(&priv->media_timer, tlan_phy_monitor, 0);
 
 	tlan_start(dev);
 
@@ -1426,8 +1425,7 @@ static u32 tlan_handle_tx_eof(struct net_device *dev, u16 host_int)
 		tlan_dio_write8(dev->base_addr,
 				TLAN_LED_REG, TLAN_LED_LINK | TLAN_LED_ACT);
 		if (priv->timer.function == NULL) {
-			priv->timer.function = tlan_timer;
-			priv->timer.data = (unsigned long) dev;
+			priv->timer.function = (TIMER_FUNC_TYPE)tlan_timer;
 			priv->timer.expires = jiffies + TLAN_TIMER_ACT_DELAY;
 			priv->timer_set_at = jiffies;
 			priv->timer_type = TLAN_TIMER_ACTIVITY;
@@ -1578,8 +1576,7 @@ static u32 tlan_handle_rx_eof(struct net_device *dev, u16 host_int)
 		tlan_dio_write8(dev->base_addr,
 				TLAN_LED_REG, TLAN_LED_LINK | TLAN_LED_ACT);
 		if (priv->timer.function == NULL)  {
-			priv->timer.function = tlan_timer;
-			priv->timer.data = (unsigned long) dev;
+			priv->timer.function = (TIMER_FUNC_TYPE)tlan_timer;
 			priv->timer.expires = jiffies + TLAN_TIMER_ACT_DELAY;
 			priv->timer_set_at = jiffies;
 			priv->timer_type = TLAN_TIMER_ACTIVITY;
@@ -1836,10 +1833,10 @@ ThunderLAN driver timer function
  *
  **************************************************************/
 
-static void tlan_timer(unsigned long data)
+static void tlan_timer(struct timer_list *t)
 {
-	struct net_device	*dev = (struct net_device *) data;
-	struct tlan_priv	*priv = netdev_priv(dev);
+	struct tlan_priv	*priv = from_timer(priv, t, timer);
+	struct net_device	*dev = priv->dev;
 	u32		elapsed;
 	unsigned long	flags = 0;
 
@@ -1872,7 +1869,6 @@ static void tlan_timer(unsigned long data)
 				tlan_dio_write8(dev->base_addr,
 						TLAN_LED_REG, TLAN_LED_LINK);
 			} else  {
-				priv->timer.function = tlan_timer;
 				priv->timer.expires = priv->timer_set_at
 					+ TLAN_TIMER_ACT_DELAY;
 				spin_unlock_irqrestore(&priv->lock, flags);
@@ -2317,8 +2313,6 @@ tlan_finish_reset(struct net_device *dev)
 			} else
 				netdev_info(dev, "Link active\n");
 			/* Enabling link beat monitoring */
-			priv->media_timer.function = tlan_phy_monitor;
-			priv->media_timer.data = (unsigned long) dev;
 			priv->media_timer.expires = jiffies + HZ;
 			add_timer(&priv->media_timer);
 		}
@@ -2763,10 +2757,10 @@ static void tlan_phy_finish_auto_neg(struct net_device *dev)
  *
  *******************************************************************/
 
-static void tlan_phy_monitor(unsigned long data)
+static void tlan_phy_monitor(struct timer_list *t)
 {
-	struct net_device *dev = (struct net_device *) data;
-	struct tlan_priv *priv = netdev_priv(dev);
+	struct tlan_priv *priv = from_timer(priv, t, media_timer);
+	struct net_device *dev = priv->dev;
 	u16     phy;
 	u16     phy_status;
 
-- 
2.7.4
