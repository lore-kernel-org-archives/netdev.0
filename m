From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] drivers/net: can: Convert timers to use timer_setup()
Date: Wed, 25 Oct 2017 03:51:14 -0700
Message-ID: <20171025105114.GA146515@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wolfgang Grandegger <wg@grandegger.com>,
        Marc Kleine-Budde <mkl@pengutronix.de>,
        Allen Pais <allen.lkml@gmail.com>, linux-can@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: Wolfgang Grandegger <wg@grandegger.com>
Cc: Marc Kleine-Budde <mkl@pengutronix.de>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Allen Pais <allen.lkml@gmail.com>
Cc: linux-can@vger.kernel.org
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/can/grcan.c                 | 19 ++++++++-----------
 drivers/net/can/sja1000/peak_pcmcia.c   |  6 +++---
 drivers/net/can/usb/peak_usb/pcan_usb.c | 10 ++++++----
 3 files changed, 17 insertions(+), 18 deletions(-)

diff --git a/drivers/net/can/grcan.c b/drivers/net/can/grcan.c
index 8570cfdaea75..897c6b113d3f 100644
--- a/drivers/net/can/grcan.c
+++ b/drivers/net/can/grcan.c
@@ -807,10 +807,10 @@ static irqreturn_t grcan_interrupt(int irq, void *dev_id)
  * is not ONGOING (TX might be stuck in ONGOING due to a harwrware bug
  * for single shot)
  */
-static void grcan_running_reset(unsigned long data)
+static void grcan_running_reset(struct timer_list *t)
 {
-	struct net_device *dev = (struct net_device *)data;
-	struct grcan_priv *priv = netdev_priv(dev);
+	struct grcan_priv *priv = from_timer(priv, t, rr_timer);
+	struct net_device *dev = priv->dev;
 	struct grcan_registers __iomem *regs = priv->regs;
 	unsigned long flags;
 
@@ -898,10 +898,10 @@ static inline void grcan_reset_timer(struct timer_list *timer, __u32 bitrate)
 }
 
 /* Disable channels and schedule a running reset */
-static void grcan_initiate_running_reset(unsigned long data)
+static void grcan_initiate_running_reset(struct timer_list *t)
 {
-	struct net_device *dev = (struct net_device *)data;
-	struct grcan_priv *priv = netdev_priv(dev);
+	struct grcan_priv *priv = from_timer(priv, t, hang_timer);
+	struct net_device *dev = priv->dev;
 	struct grcan_registers __iomem *regs = priv->regs;
 	unsigned long flags;
 
@@ -1626,11 +1626,8 @@ static int grcan_setup_netdev(struct platform_device *ofdev,
 	spin_lock_init(&priv->lock);
 
 	if (priv->need_txbug_workaround) {
-		setup_timer(&priv->rr_timer, grcan_running_reset,
-			    (unsigned long)dev);
-
-		setup_timer(&priv->hang_timer, grcan_initiate_running_reset,
-			    (unsigned long)dev);
+		timer_setup(&priv->rr_timer, grcan_running_reset, 0);
+		timer_setup(&priv->hang_timer, grcan_initiate_running_reset, 0);
 	}
 
 	netif_napi_add(dev, &priv->napi, grcan_poll, GRCAN_NAPI_WEIGHT);
diff --git a/drivers/net/can/sja1000/peak_pcmcia.c b/drivers/net/can/sja1000/peak_pcmcia.c
index 4b8758e10bd4..485b19c9ae47 100644
--- a/drivers/net/can/sja1000/peak_pcmcia.c
+++ b/drivers/net/can/sja1000/peak_pcmcia.c
@@ -381,9 +381,9 @@ static inline void pcan_set_can_power(struct pcan_pccard *card, int onoff)
 /*
  * set leds state according to channel activity
  */
-static void pcan_led_timer(unsigned long arg)
+static void pcan_led_timer(struct timer_list *t)
 {
-	struct pcan_pccard *card = (struct pcan_pccard *)arg;
+	struct pcan_pccard *card = from_timer(card, t, led_timer);
 	struct net_device *netdev;
 	int i, up_count = 0;
 	u8 ccr;
@@ -692,7 +692,7 @@ static int pcan_probe(struct pcmcia_device *pdev)
 	}
 
 	/* init the timer which controls the leds */
-	setup_timer(&card->led_timer, pcan_led_timer, (unsigned long)card);
+	timer_setup(&card->led_timer, pcan_led_timer, 0);
 
 	/* request the given irq */
 	err = request_irq(pdev->irq, &pcan_isr, IRQF_SHARED, PCC_NAME, card);
diff --git a/drivers/net/can/usb/peak_usb/pcan_usb.c b/drivers/net/can/usb/peak_usb/pcan_usb.c
index 7e10dbdded28..25a9b79cc42d 100644
--- a/drivers/net/can/usb/peak_usb/pcan_usb.c
+++ b/drivers/net/can/usb/peak_usb/pcan_usb.c
@@ -259,10 +259,13 @@ static int pcan_usb_write_mode(struct peak_usb_device *dev, u8 onoff)
 /*
  * handle end of waiting for the device to reset
  */
-static void pcan_usb_restart(unsigned long arg)
+static void pcan_usb_restart(struct timer_list *t)
 {
+	struct pcan_usb *pdev = from_timer(pdev, t, restart_timer);
+	struct peak_usb_device *dev = &pdev->dev;
+
 	/* notify candev and netdev */
-	peak_usb_restart_complete((struct peak_usb_device *)arg);
+	peak_usb_restart_complete(dev);
 }
 
 /*
@@ -798,8 +801,7 @@ static int pcan_usb_init(struct peak_usb_device *dev)
 	int err;
 
 	/* initialize a timer needed to wait for hardware restart */
-	setup_timer(&pdev->restart_timer, pcan_usb_restart,
-		    (unsigned long)dev);
+	timer_setup(&pdev->restart_timer, pcan_usb_restart, 0);
 
 	/*
 	 * explicit use of dev_xxx() instead of netdev_xxx() here:
-- 
2.7.4


-- 
Kees Cook
Pixel Security
