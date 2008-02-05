From: David Brownell <david-b@pacbell.net>
Subject: [patch 2.6.24-git] net/enc28j60: oops fix, low power mode
Date: Tue, 05 Feb 2008 11:01:24 -0800
Message-ID: <20080205190124.E72F48E45F@adsl-69-226-248-13.dsl.pltn13.pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: lanconelli.claudio@eptar.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp118.sbc.mail.sp1.yahoo.com ([69.147.64.91]:48164 "HELO
	smtp118.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757460AbYBETB3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 14:01:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Brownell <dbrownell@users.sourceforge.net>

Prevent unaligned packet oops on enc28j60 packet RX.

Keep enc28j60 chips in low-power mode when they're not in use.
At typically 120 mA, these chips run hot even when idle.  Low
power mode cuts that power usage by a factor of around 100.

Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>
---
 drivers/net/enc28j60.c |   54 +++++++++++++++++++++++++++++++++++++++++++++----
 1 files changed, 50 insertions(+), 4 deletions(-)

--- avr.orig/drivers/net/enc28j60.c	2008-02-05 10:04:22.000000000 -0800
+++ avr/drivers/net/enc28j60.c	2008-02-05 10:50:50.000000000 -0800
@@ -594,6 +594,43 @@ static void nolock_txfifo_init(struct en
 	nolock_regw_write(priv, ETXNDL, end);
 }
 
+/*
+ * Low power mode shrinks power consumption about 100x, so we'd like
+ * the chip to be in that mode whenever it's inactive.
+ */
+static void enc28j60_lowpower(struct enc28j60_net *priv, bool is_low)
+{
+	int	tmp;
+
+	dev_dbg(&priv->spi->dev, "%s power...\n", is_low ? "low" : "high");
+
+	mutex_lock(&priv->lock);
+	if (is_low) {
+		nolock_reg_bfclr(priv, ECON1, ECON1_RXEN);
+		for (;;) {
+			tmp = nolock_regb_read(priv, ESTAT);
+			if (!(tmp & ESTAT_RXBUSY))
+				break;
+		}
+		for (;;) {
+			tmp = nolock_regb_read(priv, ECON1);
+			if (!(tmp & ECON1_TXRTS))
+				break;
+		}
+		/* ECON2_VRPS was set during initialization */
+		nolock_reg_bfset(priv, ECON2, ECON2_PWRSV);
+	} else {
+		nolock_reg_bfclr(priv, ECON2, ECON2_PWRSV);
+		for (;;) {
+			tmp = nolock_regb_read(priv, ESTAT);
+			if (tmp & ESTAT_CLKRDY)
+				break;
+		}
+		/* caller sets ECON1_RXEN */
+	}
+	mutex_unlock(&priv->lock);
+}
+
 static int enc28j60_hw_init(struct enc28j60_net *priv)
 {
 	u8 reg;
@@ -612,8 +649,8 @@ static int enc28j60_hw_init(struct enc28
 	priv->tx_retry_count = 0;
 	priv->max_pk_counter = 0;
 	priv->rxfilter = RXFILTER_NORMAL;
-	/* enable address auto increment */
-	nolock_regb_write(priv, ECON2, ECON2_AUTOINC);
+	/* enable address auto increment and voltage regulator powersave */
+	nolock_regb_write(priv, ECON2, ECON2_AUTOINC | ECON2_VRPS);
 
 	nolock_rxfifo_init(priv, RXSTART_INIT, RXEND_INIT);
 	nolock_txfifo_init(priv, TXSTART_INIT, TXEND_INIT);
@@ -690,7 +727,9 @@ static int enc28j60_hw_init(struct enc28
 
 static void enc28j60_hw_enable(struct enc28j60_net *priv)
 {
-	/* enable interrutps */
+	enc28j60_lowpower(priv, false);
+
+	/* enable interrupts */
 	if (netif_msg_hw(priv))
 		printk(KERN_DEBUG DRV_NAME ": %s() enabling interrupts.\n",
 			__FUNCTION__);
@@ -717,6 +756,8 @@ static void enc28j60_hw_disable(struct e
 	nolock_reg_bfclr(priv, ECON1, ECON1_RXEN);
 	priv->hw_enable = false;
 	mutex_unlock(&priv->lock);
+
+	enc28j60_lowpower(priv, true);
 }
 
 static int
@@ -734,6 +775,8 @@ enc28j60_setlink(struct net_device *ndev
 						"hw_reset() failed\n");
 				ret = -EINVAL;
 			}
+			enc28j60_lowpower(priv, true);
+
 		} else {
 			if (netif_msg_link(priv))
 				dev_warn(&ndev->dev,
@@ -900,7 +943,7 @@ static void enc28j60_hw_rx(struct net_de
 		if (RSV_GETBIT(rxstat, RSV_LENCHECKERR))
 			ndev->stats.rx_frame_errors++;
 	} else {
-		skb = dev_alloc_skb(len);
+		skb = dev_alloc_skb(len + NET_IP_ALIGN);
 		if (!skb) {
 			if (netif_msg_rx_err(priv))
 				dev_err(&ndev->dev,
@@ -908,6 +951,7 @@ static void enc28j60_hw_rx(struct net_de
 			ndev->stats.rx_dropped++;
 		} else {
 			skb->dev = ndev;
+			skb_reserve(skb, NET_IP_ALIGN);
 			/* copy the packet from the receive buffer */
 			enc28j60_mem_read(priv, priv->next_pk_ptr + sizeof(rsv),
 					len, skb_put(skb, len));
@@ -1536,6 +1580,8 @@ static int __devinit enc28j60_probe(stru
 	dev->watchdog_timeo = TX_TIMEOUT;
 	SET_ETHTOOL_OPS(dev, &enc28j60_ethtool_ops);
 
+	enc28j60_lowpower(priv, true);
+
 	ret = register_netdev(dev);
 	if (ret) {
 		if (netif_msg_probe(priv))
