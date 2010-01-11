From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH net-next-2.6 v2] can: Unify droping of invalid tx skbs and
	netdev stats
Date: Mon, 11 Jan 2010 15:59:21 +0100
Message-ID: <4B4B3CC9.7040801@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: SocketCAN Core Mailing List <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
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

To prevent the CAN drivers to operate on invalid socketbuffers the skbs are
now checked and silently dropped at the xmit-function consistently.

Also the netdev stats are consistently using the CAN data length code (dlc)
for [rx|tx]_bytes now.

Signed-off-by: Oliver Hartkopp <oliver-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>

---

diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
index 166cc7e..70bff87 100644
--- a/drivers/net/can/at91_can.c
+++ b/drivers/net/can/at91_can.c
@@ -342,6 +342,12 @@ static netdev_tx_t at91_start_xmit(struct sk_buff *skb,
struct net_device *dev)
 	unsigned int mb, prio;
 	u32 reg_mid, reg_mcr;

+	if (invalid_can_skb(skb)) {
+		kfree_skb(skb);
+		dev->stats.tx_dropped++;
+		return NETDEV_TX_OK;
+	}
+
 	mb = get_tx_next_mb(priv);
 	prio = get_tx_next_prio(priv);

diff --git a/drivers/net/can/bfin_can.c b/drivers/net/can/bfin_can.c
index 0ec1524..b0bf359 100644
--- a/drivers/net/can/bfin_can.c
+++ b/drivers/net/can/bfin_can.c
@@ -318,6 +318,12 @@ static int bfin_can_start_xmit(struct sk_buff *skb,
struct net_device *dev)
 	u16 val;
 	int i;

+	if (invalid_can_skb(skb)) {
+		kfree_skb(skb);
+		dev->stats.tx_dropped++;
+		return NETDEV_TX_OK;
+	}
+
 	netif_stop_queue(dev);

 	/* fill id */
diff --git a/drivers/net/can/mcp251x.c b/drivers/net/can/mcp251x.c
index 9c5a153..4df3b40 100644
--- a/drivers/net/can/mcp251x.c
+++ b/drivers/net/can/mcp251x.c
@@ -494,9 +494,8 @@ static netdev_tx_t mcp251x_hard_start_xmit(struct sk_buff
*skb,
 		return NETDEV_TX_BUSY;
 	}

-	if (skb->len != sizeof(struct can_frame)) {
-		dev_err(&spi->dev, "dropping packet - bad length\n");
-		dev_kfree_skb(skb);
+	if (invalid_can_skb(skb)) {
+		kfree_skb(skb);
 		net->stats.tx_dropped++;
 		return NETDEV_TX_OK;
 	}
diff --git a/drivers/net/can/sja1000/sja1000.c b/drivers/net/can/sja1000/sja1000.c
index 542a4f7..3abad97 100644
--- a/drivers/net/can/sja1000/sja1000.c
+++ b/drivers/net/can/sja1000/sja1000.c
@@ -249,6 +249,12 @@ static netdev_tx_t sja1000_start_xmit(struct sk_buff *skb,
 	uint8_t dreg;
 	int i;

+	if (invalid_can_skb(skb)) {
+		kfree_skb(skb);
+		dev->stats.tx_dropped++;
+		return NETDEV_TX_OK;
+	}
+
 	netif_stop_queue(dev);

 	fi = dlc = cf->can_dlc;
diff --git a/drivers/net/can/ti_hecc.c b/drivers/net/can/ti_hecc.c
index 5c993c2..0ec9859 100644
--- a/drivers/net/can/ti_hecc.c
+++ b/drivers/net/can/ti_hecc.c
@@ -477,6 +477,12 @@ static netdev_tx_t ti_hecc_xmit(struct sk_buff *skb,
struct net_device *ndev)
 	u32 mbxno, mbx_mask, data;
 	unsigned long flags;

+	if (invalid_can_skb(skb)) {
+		kfree_skb(skb);
+		ndev->stats.tx_dropped++;
+		return NETDEV_TX_OK;
+	}
+
 	mbxno = get_tx_head_mb(priv);
 	mbx_mask = BIT(mbxno);
 	spin_lock_irqsave(&priv->mbx_lock, flags);
@@ -491,7 +497,6 @@ static netdev_tx_t ti_hecc_xmit(struct sk_buff *skb,
struct net_device *ndev)
 	spin_unlock_irqrestore(&priv->mbx_lock, flags);

 	/* Prepare mailbox for transmission */
-	data = min_t(u8, cf->can_dlc, 8);
 	if (cf->can_id & CAN_RTR_FLAG) /* Remote transmission request */
 		data |= HECC_CANMCF_RTR;
 	data |= get_tx_head_prio(priv) << 8;
diff --git a/drivers/net/can/usb/ems_usb.c b/drivers/net/can/usb/ems_usb.c
index efbb05c..a375781 100644
--- a/drivers/net/can/usb/ems_usb.c
+++ b/drivers/net/can/usb/ems_usb.c
@@ -767,6 +767,12 @@ static netdev_tx_t ems_usb_start_xmit(struct sk_buff
*skb, struct net_device *ne
 	size_t size = CPC_HEADER_SIZE + CPC_MSG_HEADER_LEN
 			+ sizeof(struct cpc_can_msg);

+	if (invalid_can_skb(skb)) {
+		kfree_skb(skb);
+		stats->tx_dropped++;
+		return NETDEV_TX_OK;
+	}
+
 	/* create a URB, and a buffer for it, and copy the data to the URB */
 	urb = usb_alloc_urb(0, GFP_ATOMIC);
 	if (!urb) {
diff --git a/drivers/net/can/vcan.c b/drivers/net/can/vcan.c
index 80ac563..66411d5 100644
--- a/drivers/net/can/vcan.c
+++ b/drivers/net/can/vcan.c
@@ -70,10 +70,11 @@ MODULE_PARM_DESC(echo, "Echo sent frames (for testing).
Default: 0 (Off)");

 static void vcan_rx(struct sk_buff *skb, struct net_device *dev)
 {
+	struct can_frame *cf = (struct can_frame *)skb->data;
 	struct net_device_stats *stats = &dev->stats;

 	stats->rx_packets++;
-	stats->rx_bytes += skb->len;
+	stats->rx_bytes += cf->can_dlc;

 	skb->protocol  = htons(ETH_P_CAN);
 	skb->pkt_type  = PACKET_BROADCAST;
@@ -85,11 +86,18 @@ static void vcan_rx(struct sk_buff *skb, struct net_device
*dev)

 static netdev_tx_t vcan_tx(struct sk_buff *skb, struct net_device *dev)
 {
+	struct can_frame *cf = (struct can_frame *)skb->data;
 	struct net_device_stats *stats = &dev->stats;
 	int loop;

+	if (unlikely(skb->len != sizeof(*cf) || cf->can_dlc > 8)) {
+		kfree_skb(skb);
+		stats->tx_dropped++;
+		return NETDEV_TX_OK;
+	}
+
 	stats->tx_packets++;
-	stats->tx_bytes += skb->len;
+	stats->tx_bytes += cf->can_dlc;

 	/* set flag whether this packet has to be looped back */
 	loop = skb->pkt_type == PACKET_LOOPBACK;
@@ -103,7 +111,7 @@ static netdev_tx_t vcan_tx(struct sk_buff *skb, struct
net_device *dev)
 			 * CAN core already did the echo for us
 			 */
 			stats->rx_packets++;
-			stats->rx_bytes += skb->len;
+			stats->rx_bytes += cf->can_dlc;
 		}
 		kfree_skb(skb);
 		return NETDEV_TX_OK;
diff --git a/include/linux/can/dev.h b/include/linux/can/dev.h
index 3db7767..e0703c3 100644
--- a/include/linux/can/dev.h
+++ b/include/linux/can/dev.h
@@ -60,6 +60,14 @@ struct can_priv {
  */
 #define get_can_dlc(i)	(min_t(__u8, (i), 8))

+/* check if a given socketbuffer does not contain a valid CAN frame */
+static inline int invalid_can_skb(struct sk_buff *skb)
+{
+	const struct can_frame *cf = (struct can_frame *)skb->data;
+
+	return unlikely(skb->len != sizeof(*cf) || cf->can_dlc > 8);
+}
+
 struct net_device *alloc_candev(int sizeof_priv, unsigned int echo_skb_max);
 void free_candev(struct net_device *dev);
