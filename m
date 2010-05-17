From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH v2] Fix SJA1000 command register writes on SMP systems
Date: Mon, 17 May 2010 22:17:40 +0200
Message-ID: <4BF1A464.6070207@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: SocketCAN Core Mailing List <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

The SJA1000 command register is concurrently written in the rx-path to free
the receive buffer _and_ in the tx-path to start the transmission.

The SJA1000 data sheet, 6.4.4 COMMAND REGISTER (CMR) states:
"Between two commands at least one internal clock cycle is needed in
order to proceed. The internal clock is half of the external oscillator
frequency."

On SMP systems this leads to a write stall in the tx-path, which can be
solved by adding some locking for the command register in the SMP case.
In this special case we also read the status register to settle the command
register write.

Thanks to Klaus Hitschler for the original fix and detailed problem
description.

This patch applies on net-2.6 and (with some offsets) on net-next-2.6 .

Signed-off-by: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Acked-by: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>

---

diff --git a/drivers/net/can/sja1000/sja1000.c b/drivers/net/can/sja1000/sja1000.c
index 145b1a7..2760085 100644
--- a/drivers/net/can/sja1000/sja1000.c
+++ b/drivers/net/can/sja1000/sja1000.c
@@ -84,6 +84,27 @@ static struct can_bittiming_const sja1000_bittiming_const = {
 	.brp_inc = 1,
 };
 +static void sja1000_write_cmdreg(struct sja1000_priv *priv, u8 val)
+{
+	/* the command register needs some locking on SMP systems */
+
+#ifdef CONFIG_SMP
+
+	unsigned long flags;
+
+	spin_lock_irqsave(&priv->cmdreg_lock, flags);
+	priv->write_reg(priv, REG_CMR, val);
+	priv->read_reg(priv, REG_SR);
+	spin_unlock_irqrestore(&priv->cmdreg_lock, flags);
+
+#else
+
+	/* write to the command register without locking */
+	priv->write_reg(priv, REG_CMR, val);
+
+#endif
+}
+
 static int sja1000_probe_chip(struct net_device *dev)
 {
 	struct sja1000_priv *priv = netdev_priv(dev);
@@ -297,7 +318,7 @@ static netdev_tx_t sja1000_start_xmit(struct sk_buff *skb,
  	can_put_echo_skb(skb, dev, 0);
 -	priv->write_reg(priv, REG_CMR, CMD_TR);
+	sja1000_write_cmdreg(priv, CMD_TR);
  	return NETDEV_TX_OK;
 }
@@ -346,7 +367,7 @@ static void sja1000_rx(struct net_device *dev)
 	cf->can_id = id;
  	/* release receive buffer */
-	priv->write_reg(priv, REG_CMR, CMD_RRB);
+	sja1000_write_cmdreg(priv, CMD_RRB);
  	netif_rx(skb);
 @@ -374,7 +395,7 @@ static int sja1000_err(struct net_device *dev, uint8_t isrc, uint8_t status)
 		cf->data[1] = CAN_ERR_CRTL_RX_OVERFLOW;
 		stats->rx_over_errors++;
 		stats->rx_errors++;
-		priv->write_reg(priv, REG_CMR, CMD_CDO);	/* clear bit */
+		sja1000_write_cmdreg(priv, CMD_CDO);	/* clear bit */
 	}
  	if (isrc & IRQ_EI) {
diff --git a/drivers/net/can/sja1000/sja1000.h b/drivers/net/can/sja1000/sja1000.h
index 97a622b..4527d95 100644
--- a/drivers/net/can/sja1000/sja1000.h
+++ b/drivers/net/can/sja1000/sja1000.h
@@ -168,6 +168,10 @@ struct sja1000_priv {
 	void __iomem *reg_base;	 /* ioremap'ed address to registers */
 	unsigned long irq_flags; /* for request_irq() */
 +#ifdef CONFIG_SMP
+	spinlock_t cmdreg_lock; /* lock for concurrent cmd register writes */
+#endif
+
 	u16 flags;		/* custom mode flags */
 	u8 ocr;			/* output control register */
 	u8 cdr;			/* clock divider register */
