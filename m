From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCH 07/11] can: at91_can: convert derived mailbox constants into
	functions
Date: Mon,  6 Jun 2011 15:42:56 +0200
Message-ID: <1307367780-30715-8-git-send-email-mkl@pengutronix.de>
References: <1307367780-30715-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1307367780-30715-1-git-send-email-mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
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

This is the first of two patches converting the at91_can driver from a
compile time mailbox setup to a dynamic one.

This patch converts all derived mailbox constants to functions.

Signed-off-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
---
 drivers/net/can/at91_can.c |  125 +++++++++++++++++++++++++++++---------------
 1 files changed, 83 insertions(+), 42 deletions(-)

diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
index 8699484..900ff67 100644
--- a/drivers/net/can/at91_can.c
+++ b/drivers/net/can/at91_can.c
@@ -54,18 +54,7 @@
 
 #define AT91_MB_MASK(i)		((1 << (i)) - 1)
 #define AT91_MB_RX_SPLIT	8
-#define AT91_MB_RX_LOW_LAST	(AT91_MB_RX_SPLIT - 1)
-#define AT91_MB_RX_LOW_MASK	(AT91_MB_MASK(AT91_MB_RX_SPLIT) & \
-				 ~AT91_MB_MASK(AT91_MB_RX_FIRST))
 
-#define AT91_MB_TX_NUM		(1 << AT91_MB_TX_SHIFT)
-#define AT91_MB_TX_FIRST	(AT91_MB_RX_LAST + 1)
-#define AT91_MB_TX_LAST		(AT91_MB_TX_FIRST + AT91_MB_TX_NUM - 1)
-
-#define AT91_NEXT_PRIO_SHIFT	(AT91_MB_TX_SHIFT)
-#define AT91_NEXT_PRIO_MASK	(0xf << AT91_MB_TX_SHIFT)
-#define AT91_NEXT_MB_MASK	(AT91_MB_MASK(AT91_MB_TX_SHIFT))
-#define AT91_NEXT_MASK		((AT91_MB_TX_NUM - 1) | AT91_NEXT_PRIO_MASK)
 
 /* Common registers */
 enum at91_reg {
@@ -127,12 +116,6 @@ enum at91_mb_mode {
 };
 
 /* Interrupt mask bits */
-#define AT91_IRQ_MB_RX		(AT91_MB_MASK(AT91_MB_RX_LAST + 1) & \
-				 ~AT91_MB_MASK(AT91_MB_RX_FIRST))
-#define AT91_IRQ_MB_TX		(AT91_MB_MASK(AT91_MB_TX_LAST + 1) & \
-				 ~AT91_MB_MASK(AT91_MB_TX_FIRST))
-#define AT91_IRQ_MB_ALL		(AT91_IRQ_MB_RX | AT91_IRQ_MB_TX)
-
 #define AT91_IRQ_ERRA		(1 << 16)
 #define AT91_IRQ_WARN		(1 << 17)
 #define AT91_IRQ_ERRP		(1 << 18)
@@ -185,19 +168,77 @@ static struct can_bittiming_const at91_bittiming_const = {
 	.brp_inc	= 1,
 };
 
+static inline unsigned int get_mb_rx_low_last(const struct at91_priv *priv)
+{
+	return AT91_MB_RX_SPLIT - 1;
+}
+
+static inline unsigned int get_mb_rx_low_mask(const struct at91_priv *priv)
+{
+	return AT91_MB_MASK(AT91_MB_RX_SPLIT) &
+		~AT91_MB_MASK(AT91_MB_RX_FIRST);
+}
+
+static inline unsigned int get_mb_tx_num(const struct at91_priv *priv)
+{
+	return 1 << AT91_MB_TX_SHIFT;
+}
+
+static inline unsigned int get_mb_tx_first(const struct at91_priv *priv)
+{
+	return AT91_MB_RX_LAST + 1;
+}
+
+static inline unsigned int get_mb_tx_last(const struct at91_priv *priv)
+{
+	return get_mb_tx_first(priv) + get_mb_tx_num(priv) - 1;
+}
+
+static inline unsigned int get_next_prio_shift(const struct at91_priv *priv)
+{
+	return AT91_MB_TX_SHIFT;
+}
+
+static inline unsigned int get_next_prio_mask(const struct at91_priv *priv)
+{
+	return 0xf << AT91_MB_TX_SHIFT;
+}
+
+static inline unsigned int get_next_mb_mask(const struct at91_priv *priv)
+{
+	return AT91_MB_MASK(AT91_MB_TX_SHIFT);
+}
+
+static inline unsigned int get_next_mask(const struct at91_priv *priv)
+{
+	return get_next_mb_mask(priv) | get_next_prio_mask(priv);
+}
+
+static inline unsigned int get_irq_mb_rx(const struct at91_priv *priv)
+{
+	return AT91_MB_MASK(AT91_MB_RX_LAST + 1) &
+		~AT91_MB_MASK(AT91_MB_RX_FIRST);
+}
+
+static inline unsigned int get_irq_mb_tx(const struct at91_priv *priv)
+{
+	return AT91_MB_MASK(get_mb_tx_last(priv) + 1) &
+		~AT91_MB_MASK(get_mb_tx_first(priv));
+}
+
 static inline unsigned int get_tx_next_mb(const struct at91_priv *priv)
 {
-	return (priv->tx_next & AT91_NEXT_MB_MASK) + AT91_MB_TX_FIRST;
+	return (priv->tx_next & get_next_mb_mask(priv)) + get_mb_tx_first(priv);
 }
 
 static inline unsigned int get_tx_next_prio(const struct at91_priv *priv)
 {
-	return (priv->tx_next >> AT91_NEXT_PRIO_SHIFT) & 0xf;
+	return (priv->tx_next >> get_next_prio_shift(priv)) & 0xf;
 }
 
 static inline unsigned int get_tx_echo_mb(const struct at91_priv *priv)
 {
-	return (priv->tx_echo & AT91_NEXT_MB_MASK) + AT91_MB_TX_FIRST;
+	return (priv->tx_echo & get_next_mb_mask(priv)) + get_mb_tx_first(priv);
 }
 
 static inline u32 at91_read(const struct at91_priv *priv, enum at91_reg reg)
@@ -275,7 +316,7 @@ static void at91_setup_mailboxes(struct net_device *dev)
 	}
 
 	/* The last 4 mailboxes are used for transmitting. */
-	for (i = AT91_MB_TX_FIRST; i <= AT91_MB_TX_LAST; i++)
+	for (i = get_mb_tx_first(priv); i <= get_mb_tx_last(priv); i++)
 		set_mb_mode_prio(priv, i, AT91_MB_MODE_TX, 0);
 
 	/* Reset tx and rx helper pointers */
@@ -335,7 +376,7 @@ static void at91_chip_start(struct net_device *dev)
 	priv->can.state = CAN_STATE_ERROR_ACTIVE;
 
 	/* Enable interrupts */
-	reg_ier = AT91_IRQ_MB_RX | AT91_IRQ_ERRP | AT91_IRQ_ERR_FRAME;
+	reg_ier = get_irq_mb_rx(priv) | AT91_IRQ_ERRP | AT91_IRQ_ERR_FRAME;
 	at91_write(priv, AT91_IDR, AT91_IRQ_ALL);
 	at91_write(priv, AT91_IER, reg_ier);
 }
@@ -416,7 +457,7 @@ static netdev_tx_t at91_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	stats->tx_bytes += cf->can_dlc;
 
 	/* _NOTE_: subtract AT91_MB_TX_FIRST offset from mb! */
-	can_put_echo_skb(skb, dev, mb - AT91_MB_TX_FIRST);
+	can_put_echo_skb(skb, dev, mb - get_mb_tx_first(priv));
 
 	/*
 	 * we have to stop the queue and deliver all messages in case
@@ -429,7 +470,7 @@ static netdev_tx_t at91_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	priv->tx_next++;
 	if (!(at91_read(priv, AT91_MSR(get_tx_next_mb(priv))) &
 	      AT91_MSR_MRDY) ||
-	    (priv->tx_next & AT91_NEXT_MASK) == 0)
+	    (priv->tx_next & get_next_mask(priv)) == 0)
 		netif_stop_queue(dev);
 
 	/* Enable interrupt for this mailbox */
@@ -446,7 +487,7 @@ static netdev_tx_t at91_start_xmit(struct sk_buff *skb, struct net_device *dev)
  */
 static inline void at91_activate_rx_low(const struct at91_priv *priv)
 {
-	u32 mask = AT91_MB_RX_LOW_MASK;
+	u32 mask = get_mb_rx_low_mask(priv);
 	at91_write(priv, AT91_TCR, mask);
 }
 
@@ -611,23 +652,23 @@ static int at91_poll_rx(struct net_device *dev, int quota)
 	unsigned int mb;
 	int received = 0;
 
-	if (priv->rx_next > AT91_MB_RX_LOW_LAST &&
-	    reg_sr & AT91_MB_RX_LOW_MASK)
+	if (priv->rx_next > get_mb_rx_low_last(priv) &&
+	    reg_sr & get_mb_rx_low_mask(priv))
 		netdev_info(dev,
 			"order of incoming frames cannot be guaranteed\n");
 
  again:
-	for (mb = find_next_bit(addr, AT91_MB_RX_LAST + 1, priv->rx_next);
-	     mb < AT91_MB_RX_LAST + 1 && quota > 0;
+	for (mb = find_next_bit(addr, get_mb_tx_first(priv), priv->rx_next);
+	     mb < get_mb_tx_first(priv) && quota > 0;
 	     reg_sr = at91_read(priv, AT91_SR),
-	     mb = find_next_bit(addr, AT91_MB_RX_LAST + 1, ++priv->rx_next)) {
+	     mb = find_next_bit(addr, get_mb_tx_first(priv), ++priv->rx_next)) {
 		at91_read_msg(dev, mb);
 
 		/* reactivate mailboxes */
-		if (mb == AT91_MB_RX_LOW_LAST)
+		if (mb == get_mb_rx_low_last(priv))
 			/* all lower mailboxed, if just finished it */
 			at91_activate_rx_low(priv);
-		else if (mb > AT91_MB_RX_LOW_LAST)
+		else if (mb > get_mb_rx_low_last(priv))
 			/* only the mailbox we read */
 			at91_activate_rx_mb(priv, mb);
 
@@ -636,7 +677,7 @@ static int at91_poll_rx(struct net_device *dev, int quota)
 	}
 
 	/* upper group completed, look again in lower */
-	if (priv->rx_next > AT91_MB_RX_LOW_LAST &&
+	if (priv->rx_next > get_mb_rx_low_last(priv) &&
 	    quota > 0 && mb > AT91_MB_RX_LAST) {
 		priv->rx_next = AT91_MB_RX_FIRST;
 		goto again;
@@ -721,7 +762,7 @@ static int at91_poll(struct napi_struct *napi, int quota)
 	u32 reg_sr = at91_read(priv, AT91_SR);
 	int work_done = 0;
 
-	if (reg_sr & AT91_IRQ_MB_RX)
+	if (reg_sr & get_irq_mb_rx(priv))
 		work_done += at91_poll_rx(dev, quota - work_done);
 
 	/*
@@ -735,7 +776,7 @@ static int at91_poll(struct napi_struct *napi, int quota)
 	if (work_done < quota) {
 		/* enable IRQs for frame errors and all mailboxes >= rx_next */
 		u32 reg_ier = AT91_IRQ_ERR_FRAME;
-		reg_ier |= AT91_IRQ_MB_RX & ~AT91_MB_MASK(priv->rx_next);
+		reg_ier |= get_irq_mb_rx(priv) & ~AT91_MB_MASK(priv->rx_next);
 
 		napi_complete(napi);
 		at91_write(priv, AT91_IER, reg_ier);
@@ -784,7 +825,7 @@ static void at91_irq_tx(struct net_device *dev, u32 reg_sr)
 		if (likely(reg_msr & AT91_MSR_MRDY &&
 			   ~reg_msr & AT91_MSR_MABT)) {
 			/* _NOTE_: subtract AT91_MB_TX_FIRST offset from mb! */
-			can_get_echo_skb(dev, mb - AT91_MB_TX_FIRST);
+			can_get_echo_skb(dev, mb - get_mb_tx_first(priv));
 			dev->stats.tx_packets++;
 		}
 	}
@@ -794,8 +835,8 @@ static void at91_irq_tx(struct net_device *dev, u32 reg_sr)
 	 * we get a TX int for the last can frame directly before a
 	 * wrap around.
 	 */
-	if ((priv->tx_next & AT91_NEXT_MASK) != 0 ||
-	    (priv->tx_echo & AT91_NEXT_MASK) == 0)
+	if ((priv->tx_next & get_next_mask(priv)) != 0 ||
+	    (priv->tx_echo & get_next_mask(priv)) == 0)
 		netif_wake_queue(dev);
 }
 
@@ -969,19 +1010,19 @@ static irqreturn_t at91_irq(int irq, void *dev_id)
 	handled = IRQ_HANDLED;
 
 	/* Receive or error interrupt? -> napi */
-	if (reg_sr & (AT91_IRQ_MB_RX | AT91_IRQ_ERR_FRAME)) {
+	if (reg_sr & (get_irq_mb_rx(priv) | AT91_IRQ_ERR_FRAME)) {
 		/*
 		 * The error bits are clear on read,
 		 * save for later use.
 		 */
 		priv->reg_sr = reg_sr;
 		at91_write(priv, AT91_IDR,
-			   AT91_IRQ_MB_RX | AT91_IRQ_ERR_FRAME);
+			   get_irq_mb_rx(priv) | AT91_IRQ_ERR_FRAME);
 		napi_schedule(&priv->napi);
 	}
 
 	/* Transmission complete interrupt */
-	if (reg_sr & AT91_IRQ_MB_TX)
+	if (reg_sr & get_irq_mb_tx(priv))
 		at91_irq_tx(dev, reg_sr);
 
 	at91_irq_err(dev);
@@ -1158,7 +1199,7 @@ static int __devinit at91_can_probe(struct platform_device *pdev)
 		goto exit_release;
 	}
 
-	dev = alloc_candev(sizeof(struct at91_priv), AT91_MB_TX_NUM);
+	dev = alloc_candev(sizeof(struct at91_priv), 1 << AT91_MB_TX_SHIFT);
 	if (!dev) {
 		err = -ENOMEM;
 		goto exit_iounmap;
-- 
1.7.4.1
