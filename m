From: David Brownell <david-b@pacbell.net>
Subject: [RESEND/patch 2.6.25-rc2-git] net/enc28j60: low power mode
Date: Tue, 19 Feb 2008 12:54:00 -0800
Message-ID: <200802191254.00410.david-b@pacbell.net>
References: <20080205190124.E72F48E45F@adsl-69-226-248-13.dsl.pltn13.pacbell.net> <200802062208.48838.david-b@pacbell.net> <47AAE7CD.9050801@eptar.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Claudio Lanconelli <lanconelli.claudio@eptar.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp120.sbc.mail.sp1.yahoo.com ([69.147.64.93]:30595 "HELO
	smtp120.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752849AbYBSU5T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2008 15:57:19 -0500
In-Reply-To: <47AAE7CD.9050801@eptar.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Keep enc28j60 chips in low-power mode when they're not in use.
At typically 120 mA, these chips run hot even when idle; this
low power mode cuts that power usage by a factor of around 100.

This version provides a generic routine to poll a register until
its masked value equals some value ... e.g. bit set or cleared.
It's basically what the previous wait_phy_ready() did, but this
version is generalized to support the handshaking needed to
enter and exit low power mode.

Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>
Signed-off-by: Claudio Lanconelli <lanconelli.claudio@eptar.com>
---
 drivers/net/enc28j60.c |   82 ++++++++++++++++++++++++++++++++++---------------
 1 files changed, 58 insertions(+), 24 deletions(-)

--- a/drivers/net/enc28j60.c
+++ b/drivers/net/enc28j60.c
@@ -400,26 +400,31 @@ enc28j60_packet_write(struct enc28j60_ne
 	mutex_unlock(&priv->lock);
 }
 
-/*
- * Wait until the PHY operation is complete.
- */
-static int wait_phy_ready(struct enc28j60_net *priv)
+static unsigned long msec20_to_jiffies;
+
+static int poll_ready(struct enc28j60_net *priv, u8 reg, u8 mask, u8 val)
 {
-	unsigned long timeout = jiffies + 20 * HZ / 1000;
-	int ret = 1;
+	unsigned long timeout = jiffies + msec20_to_jiffies;
 
 	/* 20 msec timeout read */
-	while (nolock_regb_read(priv, MISTAT) & MISTAT_BUSY) {
+	while ((nolock_regb_read(priv, reg) & mask) != val) {
 		if (time_after(jiffies, timeout)) {
 			if (netif_msg_drv(priv))
-				printk(KERN_DEBUG DRV_NAME
-					": PHY ready timeout!\n");
-			ret = 0;
-			break;
+				dev_dbg(&priv->spi->dev,
+					"reg %02x ready timeout!\n", reg);
+			return -ETIMEDOUT;
 		}
 		cpu_relax();
 	}
-	return ret;
+	return 0;
+}
+
+/*
+ * Wait until the PHY operation is complete.
+ */
+static int wait_phy_ready(struct enc28j60_net *priv)
+{
+	return poll_ready(priv, MISTAT, MISTAT_BUSY, 0) ? 0 : 1;
 }
 
 /*
@@ -594,6 +599,32 @@ static void nolock_txfifo_init(struct en
 	nolock_regw_write(priv, ETXNDL, end);
 }
 
+/*
+ * Low power mode shrinks power consumption about 100x, so we'd like
+ * the chip to be in that mode whenever it's inactive.  (However, we
+ * can't stay in lowpower mode during suspend with WOL active.)
+ */
+static void enc28j60_lowpower(struct enc28j60_net *priv, bool is_low)
+{
+	if (netif_msg_drv(priv))
+		dev_dbg(&priv->spi->dev, "%s power...\n",
+				is_low ? "low" : "high");
+
+	mutex_lock(&priv->lock);
+	if (is_low) {
+		nolock_reg_bfclr(priv, ECON1, ECON1_RXEN);
+		poll_ready(priv, ESTAT, ESTAT_RXBUSY, 0);
+		poll_ready(priv, ECON1, ECON1_TXRTS, 0);
+		/* ECON2_VRPS was set during initialization */
+		nolock_reg_bfset(priv, ECON2, ECON2_PWRSV);
+	} else {
+		nolock_reg_bfclr(priv, ECON2, ECON2_PWRSV);
+		poll_ready(priv, ESTAT, ESTAT_CLKRDY, ESTAT_CLKRDY);
+		/* caller sets ECON1_RXEN */
+	}
+	mutex_unlock(&priv->lock);
+}
+
 static int enc28j60_hw_init(struct enc28j60_net *priv)
 {
 	u8 reg;
@@ -612,8 +643,8 @@ static int enc28j60_hw_init(struct enc28
 	priv->tx_retry_count = 0;
 	priv->max_pk_counter = 0;
 	priv->rxfilter = RXFILTER_NORMAL;
-	/* enable address auto increment */
-	nolock_regb_write(priv, ECON2, ECON2_AUTOINC);
+	/* enable address auto increment and voltage regulator powersave */
+	nolock_regb_write(priv, ECON2, ECON2_AUTOINC | ECON2_VRPS);
 
 	nolock_rxfifo_init(priv, RXSTART_INIT, RXEND_INIT);
 	nolock_txfifo_init(priv, TXSTART_INIT, TXEND_INIT);
@@ -690,7 +721,7 @@ static int enc28j60_hw_init(struct enc28
 
 static void enc28j60_hw_enable(struct enc28j60_net *priv)
 {
-	/* enable interrutps */
+	/* enable interrupts */
 	if (netif_msg_hw(priv))
 		printk(KERN_DEBUG DRV_NAME ": %s() enabling interrupts.\n",
 			__FUNCTION__);
@@ -726,15 +757,12 @@ enc28j60_setlink(struct net_device *ndev
 	int ret = 0;
 
 	if (!priv->hw_enable) {
-		if (autoneg == AUTONEG_DISABLE && speed == SPEED_10) {
+		/* link is in low power mode now; duplex setting
+		 * will take effect on next enc28j60_hw_init().
+		 */
+		if (autoneg == AUTONEG_DISABLE && speed == SPEED_10)
 			priv->full_duplex = (duplex == DUPLEX_FULL);
-			if (!enc28j60_hw_init(priv)) {
-				if (netif_msg_drv(priv))
-					dev_err(&ndev->dev,
-						"hw_reset() failed\n");
-				ret = -EINVAL;
-			}
-		} else {
+		else {
 			if (netif_msg_link(priv))
 				dev_warn(&ndev->dev,
 					"unsupported link setting\n");
@@ -1307,7 +1335,8 @@ static int enc28j60_net_open(struct net_
 		}
 		return -EADDRNOTAVAIL;
 	}
-	/* Reset the hardware here */
+	/* Reset the hardware here (and take it out of low power mode) */
+	enc28j60_lowpower(priv, false);
 	enc28j60_hw_disable(priv);
 	if (!enc28j60_hw_init(priv)) {
 		if (netif_msg_ifup(priv))
@@ -1337,6 +1366,7 @@ static int enc28j60_net_close(struct net
 		printk(KERN_DEBUG DRV_NAME ": %s() enter\n", __FUNCTION__);
 
 	enc28j60_hw_disable(priv);
+	enc28j60_lowpower(priv, true);
 	netif_stop_queue(dev);
 
 	return 0;
@@ -1537,6 +1567,8 @@ static int __devinit enc28j60_probe(stru
 	dev->watchdog_timeo = TX_TIMEOUT;
 	SET_ETHTOOL_OPS(dev, &enc28j60_ethtool_ops);
 
+	enc28j60_lowpower(priv, true);
+
 	ret = register_netdev(dev);
 	if (ret) {
 		if (netif_msg_probe(priv))
@@ -1582,6 +1614,8 @@ static struct spi_driver enc28j60_driver
 
 static int __init enc28j60_init(void)
 {
+	msec20_to_jiffies = msecs_to_jiffies(20);
+
 	return spi_register_driver(&enc28j60_driver);
 }
 
