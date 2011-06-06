From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCH 10/11] can: at91_can: add support for the AT91SAM9X5 SOCs
Date: Mon,  6 Jun 2011 15:42:59 +0200
Message-ID: <1307367780-30715-11-git-send-email-mkl@pengutronix.de>
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

The AT91SAM9X5 SOCs have a similar CAN core, but they only have 8 compared
to 16 mailboxes on the AT91SAM9263 SOC. Another difference is that the bits
defining the state of the CAN core are cleared on read, thus the driver
has to derive the state by looking at the error counters.

Signed-off-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
---
 drivers/net/can/at91_can.c |   69 +++++++++++++++++++++++++++++++++++---------
 1 files changed, 55 insertions(+), 14 deletions(-)

diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
index 2b97281..121ede6 100644
--- a/drivers/net/can/at91_can.c
+++ b/drivers/net/can/at91_can.c
@@ -127,6 +127,7 @@ enum at91_mb_mode {
 
 enum at91_devtype {
 	AT91_DEVTYPE_SAM9263,
+	AT91_DEVTYPE_SAM9X5,
 };
 
 struct at91_devtype_data {
@@ -163,6 +164,12 @@ static const struct at91_devtype_data at91_devtype_data[] __devinitconst = {
 		.rx_last = 11,
 		.tx_shift = 2,
 	},
+	[AT91_DEVTYPE_SAM9X5] = {
+		.rx_first = 0,
+		.rx_split = 4,
+		.rx_last = 5,
+		.tx_shift = 1,
+	},
 };
 
 static struct can_bittiming_const at91_bittiming_const = {
@@ -184,6 +191,7 @@ static inline int at91_is_sam##_model(const struct at91_priv *priv) \
 }
 
 AT91_IS(9263);
+AT91_IS(9X5);
 
 static inline unsigned int get_mb_rx_first(const struct at91_priv *priv)
 {
@@ -991,6 +999,29 @@ static void at91_irq_err_state(struct net_device *dev,
 	at91_write(priv, AT91_IER, reg_ier);
 }
 
+static int at91_get_state_by_bec(const struct net_device *dev,
+		enum can_state *state)
+{
+	struct can_berr_counter bec;
+	int err;
+
+	err = at91_get_berr_counter(dev, &bec);
+	if (err)
+		return err;
+
+	if (bec.txerr < 96 && bec.rxerr < 96)
+		*state = CAN_STATE_ERROR_ACTIVE;
+	else if (bec.txerr < 128 && bec.rxerr < 128)
+		*state = CAN_STATE_ERROR_WARNING;
+	else if (bec.txerr < 256 && bec.rxerr < 256)
+		*state = CAN_STATE_ERROR_PASSIVE;
+	else
+		*state = CAN_STATE_BUS_OFF;
+
+	return 0;
+}
+
+
 static void at91_irq_err(struct net_device *dev)
 {
 	struct at91_priv *priv = netdev_priv(dev);
@@ -998,21 +1029,28 @@ static void at91_irq_err(struct net_device *dev)
 	struct can_frame *cf;
 	enum can_state new_state;
 	u32 reg_sr;
+	int err;
 
-	reg_sr = at91_read(priv, AT91_SR);
-
-	/* we need to look at the unmasked reg_sr */
-	if (unlikely(reg_sr & AT91_IRQ_BOFF))
-		new_state = CAN_STATE_BUS_OFF;
-	else if (unlikely(reg_sr & AT91_IRQ_ERRP))
-		new_state = CAN_STATE_ERROR_PASSIVE;
-	else if (unlikely(reg_sr & AT91_IRQ_WARN))
-		new_state = CAN_STATE_ERROR_WARNING;
-	else if (likely(reg_sr & AT91_IRQ_ERRA))
-		new_state = CAN_STATE_ERROR_ACTIVE;
-	else {
-		netdev_err(dev, "BUG! hardware in undefined state\n");
-		return;
+	if (at91_is_sam9263(priv)) {
+		reg_sr = at91_read(priv, AT91_SR);
+
+		/* we need to look at the unmasked reg_sr */
+		if (unlikely(reg_sr & AT91_IRQ_BOFF))
+			new_state = CAN_STATE_BUS_OFF;
+		else if (unlikely(reg_sr & AT91_IRQ_ERRP))
+			new_state = CAN_STATE_ERROR_PASSIVE;
+		else if (unlikely(reg_sr & AT91_IRQ_WARN))
+			new_state = CAN_STATE_ERROR_WARNING;
+		else if (likely(reg_sr & AT91_IRQ_ERRA))
+			new_state = CAN_STATE_ERROR_ACTIVE;
+		else {
+			netdev_err(dev, "BUG! hardware in undefined state\n");
+			return;
+		}
+	} else {
+		err = at91_get_state_by_bec(dev, &new_state);
+		if (err)
+			return;
 	}
 
 	/* state hasn't changed */
@@ -1330,6 +1368,9 @@ static const struct platform_device_id at91_can_id_table[] = {
 		.name = "at91_can",
 		.driver_data = AT91_DEVTYPE_SAM9263,
 	}, {
+		.name = "at91sam9x5_can",
+		.driver_data = AT91_DEVTYPE_SAM9X5,
+	}, {
 		/* sentinel */
 	}
 };
-- 
1.7.4.1
