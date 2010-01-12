From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: [PATCH net-next-2.6 v5] can: Unify droping of invalid tx skbs and
 netdev stats
Date: Tue, 12 Jan 2010 10:34:04 +0100
Message-ID: <4B4C420C.1040308@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	SocketCAN Core Mailing List <socketcan-core@lists.berlios.de>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: David Miller <davem@davemloft.net>,
	Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:32859 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751346Ab0ALJeN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2010 04:34:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To prevent the CAN drivers to operate on invalid socketbuffers the skbs are
now checked and silently dropped at the xmit-function consistently.

Also the netdev stats are consistently using the CAN data length code (dlc)
for [rx|tx]_bytes now.

Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>

---

diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
index 166cc7e..f728749 100644
--- a/drivers/net/can/at91_can.c
+++ b/drivers/net/can/at91_can.c
@@ -342,6 +342,9 @@ static netdev_tx_t at91_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	unsigned int mb, prio;
 	u32 reg_mid, reg_mcr;
 
+	if (can_dropped_invalid_skb(dev, skb))
+		return NETDEV_TX_OK;
+
 	mb = get_tx_next_mb(priv);
 	prio = get_tx_next_prio(priv);
 
diff --git a/drivers/net/can/bfin_can.c b/drivers/net/can/bfin_can.c
index 0ec1524..7e1926e 100644
--- a/drivers/net/can/bfin_can.c
+++ b/drivers/net/can/bfin_can.c
@@ -318,6 +318,9 @@ static int bfin_can_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	u16 val;
 	int i;
 
+	if (can_dropped_invalid_skb(dev, skb))
+		return NETDEV_TX_OK;
+
 	netif_stop_queue(dev);
 
 	/* fill id */
diff --git a/drivers/net/can/mcp251x.c b/drivers/net/can/mcp251x.c
index 1a72ca0..afa2fa4 100644
--- a/drivers/net/can/mcp251x.c
+++ b/drivers/net/can/mcp251x.c
@@ -494,12 +494,8 @@ static netdev_tx_t mcp251x_hard_start_xmit(struct sk_buff *skb,
 		return NETDEV_TX_BUSY;
 	}
 
-	if (skb->len != sizeof(struct can_frame)) {
-		dev_err(&spi->dev, "dropping packet - bad length\n");
-		dev_kfree_skb(skb);
-		net->stats.tx_dropped++;
+	if (can_dropped_invalid_skb(net, skb))
 		return NETDEV_TX_OK;
-	}
 
 	netif_stop_queue(net);
 	priv->tx_skb = skb;
diff --git a/drivers/net/can/mscan/mscan.c b/drivers/net/can/mscan/mscan.c
index 500d189..40827c1 100644
--- a/drivers/net/can/mscan/mscan.c
+++ b/drivers/net/can/mscan/mscan.c
@@ -204,11 +204,8 @@ static netdev_tx_t mscan_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	int i, rtr, buf_id;
 	u32 can_id;
 
-	if (skb->len != sizeof(*frame) || frame->can_dlc > 8) {
-		kfree_skb(skb);
-		dev->stats.tx_dropped++;
+	if (can_dropped_invalid_skb(dev, skb))
 		return NETDEV_TX_OK;
-	}
 
 	out_8(&regs->cantier, 0);
 
diff --git a/drivers/net/can/sja1000/sja1000.c b/drivers/net/can/sja1000/sja1000.c
index 542a4f7..345304d 100644
--- a/drivers/net/can/sja1000/sja1000.c
+++ b/drivers/net/can/sja1000/sja1000.c
@@ -249,6 +249,9 @@ static netdev_tx_t sja1000_start_xmit(struct sk_buff *skb,
 	uint8_t dreg;
 	int i;
 
+	if (can_dropped_invalid_skb(dev, skb))
+		return NETDEV_TX_OK;
+
 	netif_stop_queue(dev);
 
 	fi = dlc = cf->can_dlc;
diff --git a/drivers/net/can/ti_hecc.c b/drivers/net/can/ti_hecc.c
index 5c993c2..7d370e3 100644
--- a/drivers/net/can/ti_hecc.c
+++ b/drivers/net/can/ti_hecc.c
@@ -477,6 +477,9 @@ static netdev_tx_t ti_hecc_xmit(struct sk_buff *skb, struct net_device *ndev)
 	u32 mbxno, mbx_mask, data;
 	unsigned long flags;
 
+	if (can_dropped_invalid_skb(ndev, skb))
+		return NETDEV_TX_OK;
+
 	mbxno = get_tx_head_mb(priv);
 	mbx_mask = BIT(mbxno);
 	spin_lock_irqsave(&priv->mbx_lock, flags);
@@ -491,7 +494,6 @@ static netdev_tx_t ti_hecc_xmit(struct sk_buff *skb, struct net_device *ndev)
 	spin_unlock_irqrestore(&priv->mbx_lock, flags);
 
 	/* Prepare mailbox for transmission */
-	data = min_t(u8, cf->can_dlc, 8);
 	if (cf->can_id & CAN_RTR_FLAG) /* Remote transmission request */
 		data |= HECC_CANMCF_RTR;
 	data |= get_tx_head_prio(priv) << 8;
diff --git a/drivers/net/can/usb/ems_usb.c b/drivers/net/can/usb/ems_usb.c
index efbb05c..ddb17e2 100644
--- a/drivers/net/can/usb/ems_usb.c
+++ b/drivers/net/can/usb/ems_usb.c
@@ -767,6 +767,9 @@ static netdev_tx_t ems_usb_start_xmit(struct sk_buff *skb, struct net_device *ne
 	size_t size = CPC_HEADER_SIZE + CPC_MSG_HEADER_LEN
 			+ sizeof(struct cpc_can_msg);
 
+	if (can_dropped_invalid_skb(netdev, skb))
+		return NETDEV_TX_OK;
+
 	/* create a URB, and a buffer for it, and copy the data to the URB */
 	urb = usb_alloc_urb(0, GFP_ATOMIC);
 	if (!urb) {
diff --git a/drivers/net/can/vcan.c b/drivers/net/can/vcan.c
index 80ac563..d124d83 100644
--- a/drivers/net/can/vcan.c
+++ b/drivers/net/can/vcan.c
@@ -47,6 +47,7 @@
 #include <linux/if_arp.h>
 #include <linux/if_ether.h>
 #include <linux/can.h>
+#include <linux/can/dev.h>
 #include <net/rtnetlink.h>
 
 static __initdata const char banner[] =
@@ -70,10 +71,11 @@ MODULE_PARM_DESC(echo, "Echo sent frames (for testing). Default: 0 (Off)");
 
 static void vcan_rx(struct sk_buff *skb, struct net_device *dev)
 {
+	struct can_frame *cf = (struct can_frame *)skb->data;
 	struct net_device_stats *stats = &dev->stats;
 
 	stats->rx_packets++;
-	stats->rx_bytes += skb->len;
+	stats->rx_bytes += cf->can_dlc;
 
 	skb->protocol  = htons(ETH_P_CAN);
 	skb->pkt_type  = PACKET_BROADCAST;
@@ -85,11 +87,15 @@ static void vcan_rx(struct sk_buff *skb, struct net_device *dev)
 
 static netdev_tx_t vcan_tx(struct sk_buff *skb, struct net_device *dev)
 {
+	struct can_frame *cf = (struct can_frame *)skb->data;
 	struct net_device_stats *stats = &dev->stats;
 	int loop;
 
+	if (can_dropped_invalid_skb(dev, skb))
+		return NETDEV_TX_OK;
+
 	stats->tx_packets++;
-	stats->tx_bytes += skb->len;
+	stats->tx_bytes += cf->can_dlc;
 
 	/* set flag whether this packet has to be looped back */
 	loop = skb->pkt_type == PACKET_LOOPBACK;
@@ -103,7 +109,7 @@ static netdev_tx_t vcan_tx(struct sk_buff *skb, struct net_device *dev)
 			 * CAN core already did the echo for us
 			 */
 			stats->rx_packets++;
-			stats->rx_bytes += skb->len;
+			stats->rx_bytes += cf->can_dlc;
 		}
 		kfree_skb(skb);
 		return NETDEV_TX_OK;
diff --git a/include/linux/can/dev.h b/include/linux/can/dev.h
index 3db7767..7e7c98a 100644
--- a/include/linux/can/dev.h
+++ b/include/linux/can/dev.h
@@ -60,6 +60,21 @@ struct can_priv {
  */
 #define get_can_dlc(i)	(min_t(__u8, (i), 8))
 
+/* Drop a given socketbuffer if it does not contain a valid CAN frame. */
+static inline int can_dropped_invalid_skb(struct net_device *dev,
+					  struct sk_buff *skb)
+{
+	const struct can_frame *cf = (struct can_frame *)skb->data;
+
+	if (unlikely(skb->len != sizeof(*cf) || cf->can_dlc > 8)) {
+		kfree_skb(skb);
+		dev->stats.tx_dropped++;
+		return 1;
+	}
+
+	return 0;
+}
+
 struct net_device *alloc_candev(int sizeof_priv, unsigned int echo_skb_max);
 void free_candev(struct net_device *dev);
 

