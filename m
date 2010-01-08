From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH net-next-2.6] can: Unify droping of invalid tx skbs and netdev
	stats
Date: Fri, 08 Jan 2010 19:38:47 +0100
Message-ID: <4B477BB7.2030108@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: SocketCAN Core Mailing List <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
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
index 166cc7e..95567be 100644
--- a/drivers/net/can/at91_can.c
+++ b/drivers/net/can/at91_can.c
@@ -336,18 +336,24 @@ static void at91_chip_stop(struct net_device *dev, enum can_state state)
  */
 static netdev_tx_t at91_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct at91_priv *priv = netdev_priv(dev);
 	struct net_device_stats *stats = &dev->stats;
 	struct can_frame *cf = (struct can_frame *)skb->data;
 	unsigned int mb, prio;
 	u32 reg_mid, reg_mcr;
 
+	if (skb->len != sizeof(*cf) || cf->can_dlc > 8) {
+		kfree_skb(skb);
+		dev->stats.tx_dropped++;
+		return NETDEV_TX_OK;
+	}
+
 	mb = get_tx_next_mb(priv);
 	prio = get_tx_next_prio(priv);
 
 	if (unlikely(!(at91_read(priv, AT91_MSR(mb)) & AT91_MSR_MRDY))) {
 		netif_stop_queue(dev);
 
 		dev_err(dev->dev.parent,
 			"BUG! TX buffer full when queue awake!\n");
 		return NETDEV_TX_BUSY;
diff --git a/drivers/net/can/bfin_can.c b/drivers/net/can/bfin_can.c
index 0ec1524..f8f8b47 100644
--- a/drivers/net/can/bfin_can.c
+++ b/drivers/net/can/bfin_can.c
@@ -312,18 +312,24 @@ static int bfin_can_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct bfin_can_priv *priv = netdev_priv(dev);
 	struct bfin_can_regs __iomem *reg = priv->membase;
 	struct can_frame *cf = (struct can_frame *)skb->data;
 	u8 dlc = cf->can_dlc;
 	canid_t id = cf->can_id;
 	u8 *data = cf->data;
 	u16 val;
 	int i;
 
+	if (skb->len != sizeof(*cf) || cf->can_dlc > 8) {
+		kfree_skb(skb);
+		dev->stats.tx_dropped++;
+		return NETDEV_TX_OK;
+	}
+
 	netif_stop_queue(dev);
 
 	/* fill id */
 	if (id & CAN_EFF_FLAG) {
 		bfin_write16(&reg->chl[TRANSMIT_CHL].id0, id);
 		if (id & CAN_RTR_FLAG)
 			writew(((id & 0x1FFF0000) >> 16) | IDE | AME | RTR,
 					&reg->chl[TRANSMIT_CHL].id1);
 		else
diff --git a/drivers/net/can/mcp251x.c b/drivers/net/can/mcp251x.c
index 9c5a153..9b8f782 100644
--- a/drivers/net/can/mcp251x.c
+++ b/drivers/net/can/mcp251x.c
@@ -481,28 +481,28 @@ static void mcp251x_hw_wakeup(struct spi_device *spi)
 	if (!wait_for_completion_timeout(&priv->awake, HZ))
 		dev_err(&spi->dev, "MCP251x didn't wake-up\n");
 }
 
 static netdev_tx_t mcp251x_hard_start_xmit(struct sk_buff *skb,
 					   struct net_device *net)
 {
 	struct mcp251x_priv *priv = netdev_priv(net);
 	struct spi_device *spi = priv->spi;
+	struct can_frame *cf = (struct can_frame *)skb->data;
 
 	if (priv->tx_skb || priv->tx_len) {
 		dev_warn(&spi->dev, "hard_xmit called while tx busy\n");
 		netif_stop_queue(net);
 		return NETDEV_TX_BUSY;
 	}
 
-	if (skb->len != sizeof(struct can_frame)) {
-		dev_err(&spi->dev, "dropping packet - bad length\n");
-		dev_kfree_skb(skb);
+	if (skb->len != sizeof(*cf) || cf->can_dlc > 8) {
+		kfree_skb(skb);
 		net->stats.tx_dropped++;
 		return NETDEV_TX_OK;
 	}
 
 	netif_stop_queue(net);
 	priv->tx_skb = skb;
 	net->trans_start = jiffies;
 	queue_work(priv->wq, &priv->tx_work);
 
diff --git a/drivers/net/can/sja1000/sja1000.c b/drivers/net/can/sja1000/sja1000.c
index 542a4f7..7979d48 100644
--- a/drivers/net/can/sja1000/sja1000.c
+++ b/drivers/net/can/sja1000/sja1000.c
@@ -243,18 +243,24 @@ static netdev_tx_t sja1000_start_xmit(struct sk_buff *skb,
 {
 	struct sja1000_priv *priv = netdev_priv(dev);
 	struct can_frame *cf = (struct can_frame *)skb->data;
 	uint8_t fi;
 	uint8_t dlc;
 	canid_t id;
 	uint8_t dreg;
 	int i;
 
+	if (skb->len != sizeof(*cf) || cf->can_dlc > 8) {
+		kfree_skb(skb);
+		dev->stats.tx_dropped++;
+		return NETDEV_TX_OK;
+	}
+
 	netif_stop_queue(dev);
 
 	fi = dlc = cf->can_dlc;
 	id = cf->can_id;
 
 	if (id & CAN_RTR_FLAG)
 		fi |= FI_RTR;
 
 	if (id & CAN_EFF_FLAG) {
diff --git a/drivers/net/can/ti_hecc.c b/drivers/net/can/ti_hecc.c
index 5c993c2..e80be1d 100644
--- a/drivers/net/can/ti_hecc.c
+++ b/drivers/net/can/ti_hecc.c
@@ -471,33 +471,38 @@ static int ti_hecc_do_set_mode(struct net_device *ndev, enum can_mode mode)
  * value roll-over happens.
  */
 static netdev_tx_t ti_hecc_xmit(struct sk_buff *skb, struct net_device *ndev)
 {
 	struct ti_hecc_priv *priv = netdev_priv(ndev);
 	struct can_frame *cf = (struct can_frame *)skb->data;
 	u32 mbxno, mbx_mask, data;
 	unsigned long flags;
 
+	if (skb->len != sizeof(*cf) || cf->can_dlc > 8) {
+		kfree_skb(skb);
+		ndev->stats.tx_dropped++;
+		return NETDEV_TX_OK;
+	}
+
 	mbxno = get_tx_head_mb(priv);
 	mbx_mask = BIT(mbxno);
 	spin_lock_irqsave(&priv->mbx_lock, flags);
 	if (unlikely(hecc_read(priv, HECC_CANME) & mbx_mask)) {
 		spin_unlock_irqrestore(&priv->mbx_lock, flags);
 		netif_stop_queue(ndev);
 		dev_err(priv->ndev->dev.parent,
 			"BUG: TX mbx not ready tx_head=%08X, tx_tail=%08X\n",
 			priv->tx_head, priv->tx_tail);
 		return NETDEV_TX_BUSY;
 	}
 	spin_unlock_irqrestore(&priv->mbx_lock, flags);
 
 	/* Prepare mailbox for transmission */
-	data = min_t(u8, cf->can_dlc, 8);
 	if (cf->can_id & CAN_RTR_FLAG) /* Remote transmission request */
 		data |= HECC_CANMCF_RTR;
 	data |= get_tx_head_prio(priv) << 8;
 	hecc_write_mbx(priv, mbxno, HECC_CANMCF, data);
 
 	if (cf->can_id & CAN_EFF_FLAG) /* Extended frame format */
 		data = (cf->can_id & CAN_EFF_MASK) | HECC_CANMID_IDE;
 	else /* Standard frame format */
 		data = (cf->can_id & CAN_SFF_MASK) << 18;
diff --git a/drivers/net/can/usb/ems_usb.c b/drivers/net/can/usb/ems_usb.c
index efbb05c..f1c8fd7 100644
--- a/drivers/net/can/usb/ems_usb.c
+++ b/drivers/net/can/usb/ems_usb.c
@@ -761,18 +761,24 @@ static netdev_tx_t ems_usb_start_xmit(struct sk_buff *skb, struct net_device *ne
 	struct net_device_stats *stats = &netdev->stats;
 	struct can_frame *cf = (struct can_frame *)skb->data;
 	struct ems_cpc_msg *msg;
 	struct urb *urb;
 	u8 *buf;
 	int i, err;
 	size_t size = CPC_HEADER_SIZE + CPC_MSG_HEADER_LEN
 			+ sizeof(struct cpc_can_msg);
 
+	if (skb->len != sizeof(*cf) || cf->can_dlc > 8) {
+		kfree_skb(skb);
+		stats->tx_dropped++;
+		return NETDEV_TX_OK;
+	}
+
 	/* create a URB, and a buffer for it, and copy the data to the URB */
 	urb = usb_alloc_urb(0, GFP_ATOMIC);
 	if (!urb) {
 		dev_err(netdev->dev.parent, "No memory left for URBs\n");
 		goto nomem;
 	}
 
 	buf = usb_buffer_alloc(dev->udev, size, GFP_ATOMIC, &urb->transfer_dma);
 	if (!buf) {
diff --git a/drivers/net/can/vcan.c b/drivers/net/can/vcan.c
index 80ac563..d6af5fa 100644
--- a/drivers/net/can/vcan.c
+++ b/drivers/net/can/vcan.c
@@ -64,52 +64,60 @@ MODULE_AUTHOR("Urs Thuermann <urs.thuermann-l29pVbxQd1IUtdQbppsyvg@public.gmane.org>");
  */
 
 static int echo; /* echo testing. Default: 0 (Off) */
 module_param(echo, bool, S_IRUGO);
 MODULE_PARM_DESC(echo, "Echo sent frames (for testing). Default: 0 (Off)");
 
 
 static void vcan_rx(struct sk_buff *skb, struct net_device *dev)
 {
+	struct can_frame *cf = (struct can_frame *)skb->data;
 	struct net_device_stats *stats = &dev->stats;
 
 	stats->rx_packets++;
-	stats->rx_bytes += skb->len;
+	stats->rx_bytes += cf->can_dlc;
 
 	skb->protocol  = htons(ETH_P_CAN);
 	skb->pkt_type  = PACKET_BROADCAST;
 	skb->dev       = dev;
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 
 	netif_rx_ni(skb);
 }
 
 static netdev_tx_t vcan_tx(struct sk_buff *skb, struct net_device *dev)
 {
+	struct can_frame *cf = (struct can_frame *)skb->data;
 	struct net_device_stats *stats = &dev->stats;
 	int loop;
 
+	if (skb->len != sizeof(*cf) || cf->can_dlc > 8) {
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
 
 	if (!echo) {
 		/* no echo handling available inside this driver */
 
 		if (loop) {
 			/*
 			 * only count the packets here, because the
 			 * CAN core already did the echo for us
 			 */
 			stats->rx_packets++;
-			stats->rx_bytes += skb->len;
+			stats->rx_bytes += cf->can_dlc;
 		}
 		kfree_skb(skb);
 		return NETDEV_TX_OK;
 	}
 
 	/* perform standard echo handling for CAN network interfaces */
 
 	if (loop) {
 		struct sock *srcsk = skb->sk;
