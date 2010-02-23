From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: [PATCH net-next-2.6] can: netlink support for bus-error reporting
	and counters
Date: Tue, 23 Feb 2010 09:21:17 +0100
Message-ID: <4B838FFD.5070302@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: SocketCAN Core Mailing List <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch makes the bus-error reporting configurable and allows to
retrieve the CAN TX and RX bus error counters via netlink interface.
I have added support for the SJA1000. The TX and RX bus error counters
are also copied to the data fields 6..7 of error messages when state
changes are reported.

Signed-off-by: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>

---
diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
index f08f120..904aa36 100644
--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -574,6 +574,7 @@ static const struct nla_policy can_policy[IFLA_CAN_MAX + 1] = {
 	[IFLA_CAN_BITTIMING_CONST]
 				= { .len = sizeof(struct can_bittiming_const) },
 	[IFLA_CAN_CLOCK]	= { .len = sizeof(struct can_clock) },
+	[IFLA_CAN_BERR_COUNTER]	= { .len = sizeof(struct can_berr_counter) },
 };
 
 static int can_changelink(struct net_device *dev,
@@ -649,6 +650,8 @@ static size_t can_get_size(const struct net_device *dev)
 	size += nla_total_size(sizeof(u32));  /* IFLA_CAN_RESTART_MS */
 	size += sizeof(struct can_bittiming); /* IFLA_CAN_BITTIMING */
 	size += sizeof(struct can_clock);     /* IFLA_CAN_CLOCK */
+	if (priv->do_get_berr_counter)        /* IFLA_CAN_BERR_COUNTER */
+		size += sizeof(struct can_berr_counter);
 	if (priv->bittiming_const)	      /* IFLA_CAN_BITTIMING_CONST */
 		size += sizeof(struct can_bittiming_const);
 
@@ -659,6 +662,7 @@ static int can_fill_info(struct sk_buff *skb, const struct net_device *dev)
 {
 	struct can_priv *priv = netdev_priv(dev);
 	struct can_ctrlmode cm = {.flags = priv->ctrlmode};
+	struct can_berr_counter bec;
 	enum can_state state = priv->state;
 
 	if (priv->do_get_state)
@@ -669,6 +673,8 @@ static int can_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	NLA_PUT(skb, IFLA_CAN_BITTIMING,
 		sizeof(priv->bittiming), &priv->bittiming);
 	NLA_PUT(skb, IFLA_CAN_CLOCK, sizeof(cm), &priv->clock);
+	if (priv->do_get_berr_counter && !priv->do_get_berr_counter(dev, &bec))
+		NLA_PUT(skb, IFLA_CAN_BERR_COUNTER, sizeof(bec), &bec);
 	if (priv->bittiming_const)
 		NLA_PUT(skb, IFLA_CAN_BITTIMING_CONST,
 			sizeof(*priv->bittiming_const), priv->bittiming_const);
diff --git a/drivers/net/can/sja1000/sja1000.c b/drivers/net/can/sja1000/sja1000.c
index ace103a..145b1a7 100644
--- a/drivers/net/can/sja1000/sja1000.c
+++ b/drivers/net/can/sja1000/sja1000.c
@@ -130,8 +130,12 @@ static void set_normal_mode(struct net_device *dev)
 		/* check reset bit */
 		if ((status & MOD_RM) == 0) {
 			priv->can.state = CAN_STATE_ERROR_ACTIVE;
-			/* enable all interrupts */
-			priv->write_reg(priv, REG_IER, IRQ_ALL);
+			/* enable interrupts */
+			if (priv->can.ctrlmode & CAN_CTRLMODE_BERR_REPORTING)
+				priv->write_reg(priv, REG_IER, IRQ_ALL);
+			else
+				priv->write_reg(priv, REG_IER,
+						IRQ_ALL & ~IRQ_BEI);
 			return;
 		}
 
@@ -203,6 +207,17 @@ static int sja1000_set_bittiming(struct net_device *dev)
 	return 0;
 }
 
+static int sja1000_get_berr_counter(const struct net_device *dev,
+				    struct can_berr_counter *bec)
+{
+	struct sja1000_priv *priv = netdev_priv(dev);
+
+	bec->txerr = priv->read_reg(priv, REG_TXERR);
+	bec->rxerr = priv->read_reg(priv, REG_RXERR);
+
+	return 0;
+}
+
 /*
  * initialize SJA1000 chip:
  *   - reset chip
@@ -437,6 +452,8 @@ static int sja1000_err(struct net_device *dev, uint8_t isrc, uint8_t status)
 				CAN_ERR_CRTL_TX_PASSIVE :
 				CAN_ERR_CRTL_RX_PASSIVE;
 		}
+		cf->data[6] = txerr;
+		cf->data[7] = rxerr;
 	}
 
 	priv->can.state = state;
@@ -567,7 +584,9 @@ struct net_device *alloc_sja1000dev(int sizeof_priv)
 	priv->can.bittiming_const = &sja1000_bittiming_const;
 	priv->can.do_set_bittiming = sja1000_set_bittiming;
 	priv->can.do_set_mode = sja1000_set_mode;
-	priv->can.ctrlmode_supported = CAN_CTRLMODE_3_SAMPLES;
+	priv->can.do_get_berr_counter = sja1000_get_berr_counter;
+	priv->can.ctrlmode_supported = CAN_CTRLMODE_3_SAMPLES |
+		CAN_CTRLMODE_BERR_REPORTING;
 
 	if (sizeof_priv)
 		priv->priv = (void *)priv + sizeof(struct sja1000_priv);
diff --git a/include/linux/can/dev.h b/include/linux/can/dev.h
index c8c660a..6e5a7f0 100644
--- a/include/linux/can/dev.h
+++ b/include/linux/can/dev.h
@@ -47,6 +47,8 @@ struct can_priv {
 	int (*do_set_mode)(struct net_device *dev, enum can_mode mode);
 	int (*do_get_state)(const struct net_device *dev,
 			    enum can_state *state);
+	int (*do_get_berr_counter)(const struct net_device *dev,
+				   struct can_berr_counter *bec);
 
 	unsigned int echo_skb_max;
 	struct sk_buff **echo_skb;
diff --git a/include/linux/can/netlink.h b/include/linux/can/netlink.h
index c818335..3250de9 100644
--- a/include/linux/can/netlink.h
+++ b/include/linux/can/netlink.h
@@ -70,6 +70,14 @@ enum can_state {
 };
 
 /*
+ * CAN bus error counters
+ */
+struct can_berr_counter {
+	__u16 txerr;
+	__u16 rxerr;
+};
+
+/*
  * CAN controller mode
  */
 struct can_ctrlmode {
@@ -77,10 +85,11 @@ struct can_ctrlmode {
 	__u32 flags;
 };
 
-#define CAN_CTRLMODE_LOOPBACK	0x1	/* Loopback mode */
-#define CAN_CTRLMODE_LISTENONLY	0x2 	/* Listen-only mode */
-#define CAN_CTRLMODE_3_SAMPLES	0x4	/* Triple sampling mode */
-#define CAN_CTRLMODE_ONE_SHOT	0x8	/* One-Shot mode */
+#define CAN_CTRLMODE_LOOPBACK		0x01	/* Loopback mode */
+#define CAN_CTRLMODE_LISTENONLY		0x02 	/* Listen-only mode */
+#define CAN_CTRLMODE_3_SAMPLES		0x04	/* Triple sampling mode */
+#define CAN_CTRLMODE_ONE_SHOT		0x08	/* One-Shot mode */
+#define CAN_CTRLMODE_BERR_REPORTING	0x10	/* Bus-error reporting */
 
 /*
  * CAN device statistics
@@ -106,6 +115,7 @@ enum {
 	IFLA_CAN_CTRLMODE,
 	IFLA_CAN_RESTART_MS,
 	IFLA_CAN_RESTART,
+	IFLA_CAN_BERR_COUNTER,
 	__IFLA_CAN_MAX
 };
