From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCH 08/11] can: at91_can: add id_table and convert prime mailbox
	constats to functions
Date: Mon,  6 Jun 2011 15:42:57 +0200
Message-ID: <1307367780-30715-9-git-send-email-mkl@pengutronix.de>
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

This is the second of two patches converting the at91_can driver from a
compile time mailbox setup to a dynamic one.

This patch first adds a id_table to the platform driver. Depending on the
driver_data the constants for the mailbox setup is selected. Then all
remaining prime mailbox constants are converted to functions, using the
run time selected mailbox constants.

Signed-off-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
---
 drivers/net/can/at91_can.c |  137 +++++++++++++++++++++++++++++++------------
 1 files changed, 99 insertions(+), 38 deletions(-)

diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
index 900ff67..248e03f 100644
--- a/drivers/net/can/at91_can.c
+++ b/drivers/net/can/at91_can.c
@@ -41,20 +41,7 @@
 
 #include <mach/board.h>
 
-#define AT91_NAPI_WEIGHT	11
-
-/*
- * RX/TX Mailbox split
- * don't dare to touch
- */
-#define AT91_MB_TX_SHIFT	2
-
-#define AT91_MB_RX_FIRST	1
-#define AT91_MB_RX_LAST		11
-
 #define AT91_MB_MASK(i)		((1 << (i)) - 1)
-#define AT91_MB_RX_SPLIT	8
-
 
 /* Common registers */
 enum at91_reg {
@@ -138,6 +125,18 @@ enum at91_mb_mode {
 
 #define AT91_IRQ_ALL		(0x1fffffff)
 
+enum at91_devtype {
+	AT91_DEVTYPE_SAM9263,
+};
+
+struct at91_devtype_data {
+	unsigned int rx_first;
+	unsigned int rx_split;
+	unsigned int rx_last;
+	unsigned int tx_shift;
+	enum at91_devtype type;
+};
+
 struct at91_priv {
 	struct can_priv can;		/* must be the first member! */
 	struct net_device *dev;
@@ -149,6 +148,7 @@ struct at91_priv {
 	unsigned int tx_next;
 	unsigned int tx_echo;
 	unsigned int rx_next;
+	struct at91_devtype_data devtype_data;
 
 	struct clk *clk;
 	struct at91_can_data *pdata;
@@ -156,6 +156,15 @@ struct at91_priv {
 	canid_t mb0_id;
 };
 
+static const struct at91_devtype_data at91_devtype_data[] __devinitconst = {
+	[AT91_DEVTYPE_SAM9263] = {
+		.rx_first = 1,
+		.rx_split = 8,
+		.rx_last = 11,
+		.tx_shift = 2,
+	},
+};
+
 static struct can_bittiming_const at91_bittiming_const = {
 	.name		= KBUILD_MODNAME,
 	.tseg1_min	= 4,
@@ -168,25 +177,58 @@ static struct can_bittiming_const at91_bittiming_const = {
 	.brp_inc	= 1,
 };
 
+#define AT91_IS(_model) \
+static inline int at91_is_sam##_model(const struct at91_priv *priv) \
+{ \
+	return priv->devtype_data.type == AT91_DEVTYPE_SAM##_model; \
+}
+
+AT91_IS(9263);
+
+static inline unsigned int get_mb_rx_first(const struct at91_priv *priv)
+{
+	return priv->devtype_data.rx_first;
+}
+
+static inline unsigned int get_mb_rx_last(const struct at91_priv *priv)
+{
+	return priv->devtype_data.rx_last;
+}
+
+static inline unsigned int get_mb_rx_split(const struct at91_priv *priv)
+{
+	return priv->devtype_data.rx_split;
+}
+
+static inline unsigned int get_mb_rx_num(const struct at91_priv *priv)
+{
+	return get_mb_rx_last(priv) - get_mb_rx_first(priv) + 1;
+}
+
 static inline unsigned int get_mb_rx_low_last(const struct at91_priv *priv)
 {
-	return AT91_MB_RX_SPLIT - 1;
+	return get_mb_rx_split(priv) - 1;
 }
 
 static inline unsigned int get_mb_rx_low_mask(const struct at91_priv *priv)
 {
-	return AT91_MB_MASK(AT91_MB_RX_SPLIT) &
-		~AT91_MB_MASK(AT91_MB_RX_FIRST);
+	return AT91_MB_MASK(get_mb_rx_split(priv)) &
+		~AT91_MB_MASK(get_mb_rx_first(priv));
+}
+
+static inline unsigned int get_mb_tx_shift(const struct at91_priv *priv)
+{
+	return priv->devtype_data.tx_shift;
 }
 
 static inline unsigned int get_mb_tx_num(const struct at91_priv *priv)
 {
-	return 1 << AT91_MB_TX_SHIFT;
+	return 1 << get_mb_tx_shift(priv);
 }
 
 static inline unsigned int get_mb_tx_first(const struct at91_priv *priv)
 {
-	return AT91_MB_RX_LAST + 1;
+	return get_mb_rx_last(priv) + 1;
 }
 
 static inline unsigned int get_mb_tx_last(const struct at91_priv *priv)
@@ -196,17 +238,17 @@ static inline unsigned int get_mb_tx_last(const struct at91_priv *priv)
 
 static inline unsigned int get_next_prio_shift(const struct at91_priv *priv)
 {
-	return AT91_MB_TX_SHIFT;
+	return get_mb_tx_shift(priv);
 }
 
 static inline unsigned int get_next_prio_mask(const struct at91_priv *priv)
 {
-	return 0xf << AT91_MB_TX_SHIFT;
+	return 0xf << get_mb_tx_shift(priv);
 }
 
 static inline unsigned int get_next_mb_mask(const struct at91_priv *priv)
 {
-	return AT91_MB_MASK(AT91_MB_TX_SHIFT);
+	return AT91_MB_MASK(get_mb_tx_shift(priv));
 }
 
 static inline unsigned int get_next_mask(const struct at91_priv *priv)
@@ -216,8 +258,8 @@ static inline unsigned int get_next_mask(const struct at91_priv *priv)
 
 static inline unsigned int get_irq_mb_rx(const struct at91_priv *priv)
 {
-	return AT91_MB_MASK(AT91_MB_RX_LAST + 1) &
-		~AT91_MB_MASK(AT91_MB_RX_FIRST);
+	return AT91_MB_MASK(get_mb_rx_last(priv) + 1) &
+		~AT91_MB_MASK(get_mb_rx_first(priv));
 }
 
 static inline unsigned int get_irq_mb_tx(const struct at91_priv *priv)
@@ -299,18 +341,18 @@ static void at91_setup_mailboxes(struct net_device *dev)
 	 * overflow.
 	 */
 	reg_mid = at91_can_id_to_reg_mid(priv->mb0_id);
-	for (i = 0; i < AT91_MB_RX_FIRST; i++) {
+	for (i = 0; i < get_mb_rx_first(priv); i++) {
 		set_mb_mode(priv, i, AT91_MB_MODE_DISABLED);
 		at91_write(priv, AT91_MID(i), reg_mid);
 		at91_write(priv, AT91_MCR(i), 0x0);	/* clear dlc */
 	}
 
-	for (i = AT91_MB_RX_FIRST; i < AT91_MB_RX_LAST; i++)
+	for (i = get_mb_rx_first(priv); i < get_mb_rx_last(priv); i++)
 		set_mb_mode(priv, i, AT91_MB_MODE_RX);
-	set_mb_mode(priv, AT91_MB_RX_LAST, AT91_MB_MODE_RX_OVRWR);
+	set_mb_mode(priv, get_mb_rx_last(priv), AT91_MB_MODE_RX_OVRWR);
 
 	/* reset acceptance mask and id register */
-	for (i = AT91_MB_RX_FIRST; i <= AT91_MB_RX_LAST; i++) {
+	for (i = get_mb_rx_first(priv); i <= get_mb_rx_last(priv); i++) {
 		at91_write(priv, AT91_MAM(i), 0x0);
 		at91_write(priv, AT91_MID(i), AT91_MID_MIDE);
 	}
@@ -321,7 +363,7 @@ static void at91_setup_mailboxes(struct net_device *dev)
 
 	/* Reset tx and rx helper pointers */
 	priv->tx_next = priv->tx_echo = 0;
-	priv->rx_next = AT91_MB_RX_FIRST;
+	priv->rx_next = get_mb_rx_first(priv);
 }
 
 static int at91_set_bittiming(struct net_device *dev)
@@ -415,8 +457,8 @@ static void at91_chip_stop(struct net_device *dev, enum can_state state)
  * mailbox, but without the offset AT91_MB_TX_FIRST. The lower bits
  * encode the mailbox number, the upper 4 bits the mailbox priority:
  *
- * priv->tx_next = (prio << AT91_NEXT_PRIO_SHIFT) |
- *                 (mb - AT91_MB_TX_FIRST);
+ * priv->tx_next = (prio << get_next_prio_shift(priv)) |
+ *                 (mb - get_mb_tx_first(priv));
  *
  */
 static netdev_tx_t at91_start_xmit(struct sk_buff *skb, struct net_device *dev)
@@ -565,7 +607,7 @@ static void at91_read_mb(struct net_device *dev, unsigned int mb,
 	/* allow RX of extended frames */
 	at91_write(priv, AT91_MID(mb), AT91_MID_MIDE);
 
-	if (unlikely(mb == AT91_MB_RX_LAST && reg_msr & AT91_MSR_MMI))
+	if (unlikely(mb == get_mb_rx_last(priv) && reg_msr & AT91_MSR_MMI))
 		at91_rx_overflow_err(dev);
 }
 
@@ -603,8 +645,9 @@ static void at91_read_msg(struct net_device *dev, unsigned int mb)
  *
  * Theory of Operation:
  *
- * 11 of the 16 mailboxes on the chip are reserved for RX. we split
- * them into 2 groups. The lower group holds 7 and upper 4 mailboxes.
+ * About 3/4 of the mailboxes (get_mb_rx_first()...get_mb_rx_last())
+ * on the chip are reserved for RX. We split them into 2 groups. The
+ * lower group ranges from get_mb_rx_first() to get_mb_rx_low_last().
  *
  * Like it or not, but the chip always saves a received CAN message
  * into the first free mailbox it finds (starting with the
@@ -678,8 +721,8 @@ static int at91_poll_rx(struct net_device *dev, int quota)
 
 	/* upper group completed, look again in lower */
 	if (priv->rx_next > get_mb_rx_low_last(priv) &&
-	    quota > 0 && mb > AT91_MB_RX_LAST) {
-		priv->rx_next = AT91_MB_RX_FIRST;
+	    quota > 0 && mb > get_mb_rx_last(priv)) {
+		priv->rx_next = get_mb_rx_first(priv);
 		goto again;
 	}
 
@@ -1165,6 +1208,8 @@ static struct attribute_group at91_sysfs_attr_group = {
 
 static int __devinit at91_can_probe(struct platform_device *pdev)
 {
+	const struct at91_devtype_data *devtype_data;
+	enum at91_devtype devtype;
 	struct net_device *dev;
 	struct at91_priv *priv;
 	struct resource *res;
@@ -1172,6 +1217,9 @@ static int __devinit at91_can_probe(struct platform_device *pdev)
 	void __iomem *addr;
 	int err, irq;
 
+	devtype = pdev->id_entry->driver_data;
+	devtype_data = &at91_devtype_data[devtype];
+
 	clk = clk_get(&pdev->dev, "can_clk");
 	if (IS_ERR(clk)) {
 		dev_err(&pdev->dev, "no clock defined\n");
@@ -1199,7 +1247,8 @@ static int __devinit at91_can_probe(struct platform_device *pdev)
 		goto exit_release;
 	}
 
-	dev = alloc_candev(sizeof(struct at91_priv), 1 << AT91_MB_TX_SHIFT);
+	dev = alloc_candev(sizeof(struct at91_priv),
+			   1 << devtype_data->tx_shift);
 	if (!dev) {
 		err = -ENOMEM;
 		goto exit_iounmap;
@@ -1216,13 +1265,15 @@ static int __devinit at91_can_probe(struct platform_device *pdev)
 	priv->can.do_set_mode = at91_set_mode;
 	priv->can.do_get_berr_counter = at91_get_berr_counter;
 	priv->can.ctrlmode_supported = CAN_CTRLMODE_3_SAMPLES;
-	priv->reg_base = addr;
 	priv->dev = dev;
+	priv->reg_base = addr;
+	priv->devtype_data = *devtype_data;
+	priv->devtype_data.type = devtype;
 	priv->clk = clk;
 	priv->pdata = pdev->dev.platform_data;
 	priv->mb0_id = 0x7ff;
 
-	netif_napi_add(dev, &priv->napi, at91_poll, AT91_NAPI_WEIGHT);
+	netif_napi_add(dev, &priv->napi, at91_poll, get_mb_rx_num(priv));
 
 	dev_set_drvdata(&pdev->dev, dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
@@ -1272,6 +1323,15 @@ static int __devexit at91_can_remove(struct platform_device *pdev)
 	return 0;
 }
 
+static const struct platform_device_id at91_can_id_table[] = {
+	{
+		.name = "at91_can",
+		.driver_data = AT91_DEVTYPE_SAM9263,
+	}, {
+		/* sentinel */
+	}
+};
+
 static struct platform_driver at91_can_driver = {
 	.probe = at91_can_probe,
 	.remove = __devexit_p(at91_can_remove),
@@ -1279,6 +1339,7 @@ static struct platform_driver at91_can_driver = {
 		.name = KBUILD_MODNAME,
 		.owner = THIS_MODULE,
 	},
+	.id_table = at91_can_id_table,
 };
 
 static int __init at91_can_module_init(void)
-- 
1.7.4.1
