From: Wolfgang Grandegger <wg@grandegger.com>
Subject: [PATCH v2] can: provide library functions for skb allocation
Date: Sun, 18 Oct 2009 20:45:23 +0200
Message-ID: <4ADB6243.2040109@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: SocketCAN Core Mailing List <socketcan-core@lists.berlios.de>,
	Sebastian Haas <haas@ems-wuensche.com>,
	"Gole, Anant" <anantgole@ti.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	David Miller <davem@davemloft.net>
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:50360 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754951AbZJRSpy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2009 14:45:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes the private functions alloc_can_skb() and
alloc_can_err_skb() of the at91_can driver public and adapts all
drivers to use these. While making the patch I realized, that
the skb's are *not* setup consistently. It's now done as shown
below:

  skb->protocol = htons(ETH_P_CAN);
  skb->pkt_type = PACKET_BROADCAST;
  skb->ip_summed = CHECKSUM_UNNECESSARY;
  *cf = (struct can_frame *)skb_put(skb, sizeof(struct can_frame));
  memset(*cf, 0, sizeof(struct can_frame));

The frame is zeroed out to avoid uninitialized data to be passed to
user space. Some drivers or library code did not set "pkt_type" or 
"ip_summed". Also,  "__constant_htons()" should not be used for
runtime invocations, as pointed out by David Miller.

Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>
---
 drivers/net/can/at91_can.c        |   32 ----------------------------
 drivers/net/can/dev.c             |   42 +++++++++++++++++++++++++++++++-------
 drivers/net/can/sja1000/sja1000.c |   12 +---------
 drivers/net/can/ti_hecc.c         |   17 +++------------
 drivers/net/can/usb/ems_usb.c     |   16 +-------------
 5 files changed, 43 insertions(+), 76 deletions(-)

Index: net-next-2.6/drivers/net/can/dev.c
===================================================================
--- net-next-2.6.orig/drivers/net/can/dev.c
+++ net-next-2.6/drivers/net/can/dev.c
@@ -366,17 +366,12 @@ void can_restart(unsigned long data)
 	can_flush_echo_skb(dev);
 
 	/* send restart message upstream */
-	skb = dev_alloc_skb(sizeof(struct can_frame));
+	skb = alloc_can_err_skb(dev, &cf);
 	if (skb == NULL) {
 		err = -ENOMEM;
 		goto restart;
 	}
-	skb->dev = dev;
-	skb->protocol = htons(ETH_P_CAN);
-	cf = (struct can_frame *)skb_put(skb, sizeof(struct can_frame));
-	memset(cf, 0, sizeof(struct can_frame));
-	cf->can_id = CAN_ERR_FLAG | CAN_ERR_RESTARTED;
-	cf->can_dlc = CAN_ERR_DLC;
+	cf->can_id |= CAN_ERR_RESTARTED;
 
 	netif_rx(skb);
 
@@ -449,6 +444,39 @@ static void can_setup(struct net_device 
 	dev->features = NETIF_F_NO_CSUM;
 }
 
+struct sk_buff *alloc_can_skb(struct net_device *dev, struct can_frame **cf)
+{
+	struct sk_buff *skb;
+
+	skb = netdev_alloc_skb(dev, sizeof(struct can_frame));
+	if (unlikely(!skb))
+		return NULL;
+
+	skb->protocol = htons(ETH_P_CAN);
+	skb->pkt_type = PACKET_BROADCAST;
+	skb->ip_summed = CHECKSUM_UNNECESSARY;
+	*cf = (struct can_frame *)skb_put(skb, sizeof(struct can_frame));
+	memset(*cf, 0, sizeof(struct can_frame));
+
+	return skb;
+}
+EXPORT_SYMBOL_GPL(alloc_can_skb);
+
+struct sk_buff *alloc_can_err_skb(struct net_device *dev, struct can_frame **cf)
+{
+	struct sk_buff *skb;
+
+	skb = alloc_can_skb(dev, cf);
+	if (unlikely(!skb))
+		return NULL;
+
+	(*cf)->can_id = CAN_ERR_FLAG;
+	(*cf)->can_dlc = CAN_ERR_DLC;
+
+	return skb;
+}
+EXPORT_SYMBOL_GPL(alloc_can_err_skb);
+
 /*
  * Allocate and setup space for the CAN network device
  */
Index: net-next-2.6/drivers/net/can/at91_can.c
===================================================================
--- net-next-2.6.orig/drivers/net/can/at91_can.c
+++ net-next-2.6/drivers/net/can/at91_can.c
@@ -221,38 +221,6 @@ static inline void set_mb_mode(const str
 	set_mb_mode_prio(priv, mb, mode, 0);
 }
 
-static struct sk_buff *alloc_can_skb(struct net_device *dev,
-		struct can_frame **cf)
-{
-	struct sk_buff *skb;
-
-	skb = netdev_alloc_skb(dev, sizeof(struct can_frame));
-	if (unlikely(!skb))
-		return NULL;
-
-	skb->protocol = htons(ETH_P_CAN);
-	skb->ip_summed = CHECKSUM_UNNECESSARY;
-	*cf = (struct can_frame *)skb_put(skb, sizeof(struct can_frame));
-
-	return skb;
-}
-
-static struct sk_buff *alloc_can_err_skb(struct net_device *dev,
-		struct can_frame **cf)
-{
-	struct sk_buff *skb;
-
-	skb = alloc_can_skb(dev, cf);
-	if (unlikely(!skb))
-		return NULL;
-
-	memset(*cf, 0, sizeof(struct can_frame));
-	(*cf)->can_id = CAN_ERR_FLAG;
-	(*cf)->can_dlc = CAN_ERR_DLC;
-
-	return skb;
-}
-
 /*
  * Swtich transceiver on or off
  */
Index: net-next-2.6/drivers/net/can/sja1000/sja1000.c
===================================================================
--- net-next-2.6.orig/drivers/net/can/sja1000/sja1000.c
+++ net-next-2.6/drivers/net/can/sja1000/sja1000.c
@@ -296,11 +296,9 @@ static void sja1000_rx(struct net_device
 	uint8_t dlc;
 	int i;
 
-	skb = dev_alloc_skb(sizeof(struct can_frame));
+	skb = alloc_can_skb(dev, &cf);
 	if (skb == NULL)
 		return;
-	skb->dev = dev;
-	skb->protocol = htons(ETH_P_CAN);
 
 	fi = priv->read_reg(priv, REG_FI);
 	dlc = fi & 0x0F;
@@ -351,15 +349,9 @@ static int sja1000_err(struct net_device
 	enum can_state state = priv->can.state;
 	uint8_t ecc, alc;
 
-	skb = dev_alloc_skb(sizeof(struct can_frame));
+	skb = alloc_can_err_skb(dev, &cf);
 	if (skb == NULL)
 		return -ENOMEM;
-	skb->dev = dev;
-	skb->protocol = htons(ETH_P_CAN);
-	cf = (struct can_frame *)skb_put(skb, sizeof(struct can_frame));
-	memset(cf, 0, sizeof(struct can_frame));
-	cf->can_id = CAN_ERR_FLAG;
-	cf->can_dlc = CAN_ERR_DLC;
 
 	if (isrc & IRQ_DOI) {
 		/* data overrun interrupt */
Index: net-next-2.6/drivers/net/can/usb/ems_usb.c
===================================================================
--- net-next-2.6.orig/drivers/net/can/usb/ems_usb.c
+++ net-next-2.6/drivers/net/can/usb/ems_usb.c
@@ -311,14 +311,10 @@ static void ems_usb_rx_can_msg(struct em
 	int i;
 	struct net_device_stats *stats = &dev->netdev->stats;
 
-	skb = netdev_alloc_skb(dev->netdev, sizeof(struct can_frame));
+	skb = alloc_can_skb(dev->netdev, &cf);
 	if (skb == NULL)
 		return;
 
-	skb->protocol = htons(ETH_P_CAN);
-
-	cf = (struct can_frame *)skb_put(skb, sizeof(struct can_frame));
-
 	cf->can_id = msg->msg.can_msg.id;
 	cf->can_dlc = min_t(u8, msg->msg.can_msg.length, 8);
 
@@ -346,18 +342,10 @@ static void ems_usb_rx_err(struct ems_us
 	struct sk_buff *skb;
 	struct net_device_stats *stats = &dev->netdev->stats;
 
-	skb = netdev_alloc_skb(dev->netdev, sizeof(struct can_frame));
+	skb = alloc_can_err_skb(dev->netdev, &cf);
 	if (skb == NULL)
 		return;
 
-	skb->protocol = htons(ETH_P_CAN);
-
-	cf = (struct can_frame *)skb_put(skb, sizeof(struct can_frame));
-	memset(cf, 0, sizeof(struct can_frame));
-
-	cf->can_id = CAN_ERR_FLAG;
-	cf->can_dlc = CAN_ERR_DLC;
-
 	if (msg->type == CPC_MSG_TYPE_CAN_STATE) {
 		u8 state = msg->msg.can_state;
 
Index: net-next-2.6/drivers/net/can/ti_hecc.c
===================================================================
--- net-next-2.6.orig/drivers/net/can/ti_hecc.c
+++ net-next-2.6/drivers/net/can/ti_hecc.c
@@ -535,18 +535,15 @@ static int ti_hecc_rx_pkt(struct ti_hecc
 	u32 data, mbx_mask;
 	unsigned long flags;
 
-	skb = netdev_alloc_skb(priv->ndev, sizeof(struct can_frame));
+	skb = alloc_can_skb(priv->ndev, &cf);
 	if (!skb) {
 		if (printk_ratelimit())
 			dev_err(priv->ndev->dev.parent,
-				"ti_hecc_rx_pkt: netdev_alloc_skb() failed\n");
+				"ti_hecc_rx_pkt: alloc_can_skb() failed\n");
 		return -ENOMEM;
 	}
-	skb->protocol = __constant_htons(ETH_P_CAN);
-	skb->ip_summed = CHECKSUM_UNNECESSARY;
 
 	mbx_mask = BIT(mbxno);
-	cf = (struct can_frame *)skb_put(skb, sizeof(struct can_frame));
 	data = hecc_read_mbx(priv, mbxno, HECC_CANMID);
 	if (data & HECC_CANMID_IDE)
 		cf->can_id = (data & CAN_EFF_MASK) | CAN_EFF_FLAG;
@@ -656,19 +653,13 @@ static int ti_hecc_error(struct net_devi
 	struct sk_buff *skb;
 
 	/* propogate the error condition to the can stack */
-	skb = netdev_alloc_skb(ndev, sizeof(struct can_frame));
+	skb = alloc_can_err_skb(ndev, &cf);
 	if (!skb) {
 		if (printk_ratelimit())
 			dev_err(priv->ndev->dev.parent,
-				"ti_hecc_error: netdev_alloc_skb() failed\n");
+				"ti_hecc_error: alloc_can_err_skb() failed\n");
 		return -ENOMEM;
 	}
-	skb->protocol = __constant_htons(ETH_P_CAN);
-	skb->ip_summed = CHECKSUM_UNNECESSARY;
-	cf = (struct can_frame *)skb_put(skb, sizeof(struct can_frame));
-	memset(cf, 0, sizeof(struct can_frame));
-	cf->can_id = CAN_ERR_FLAG;
-	cf->can_dlc = CAN_ERR_DLC;
 
 	if (int_status & HECC_CANGIF_WLIF) { /* warning level int */
 		if ((int_status & HECC_CANGIF_BOIF) == 0) {
