From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: [PATCH net-2.6] can: Fix data length code handling in rx path
Date: Sat, 12 Dec 2009 15:13:21 +0100
Message-ID: <4B23A501.9000208@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060505090307030601080103"
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	SocketCAN Core Mailing List <socketcan-core@lists.berlios.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-fb.rzone.de ([81.169.146.163]:14591 "HELO
	mo-p00-fb.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1756118AbZLMDNo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Dec 2009 22:13:44 -0500
Received: from mo-p00-ob.rzone.de (fruni-mo-p00-ob.mail [192.168.63.71])
	by snori-fb-01.store (RZmta 22.5) with ESMTP id W03c0blBCBOUJg
	for <netdev@vger.kernel.org>; Sat, 12 Dec 2009 16:26:52 +0100 (MET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060505090307030601080103
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

A valid CAN dataframe can have a data length code (DLC) of 0 .. 8 data bytes.

When reading the CAN controllers register the 4-bit value may contain values
from 0 .. 15 which may exceed the reserved space in the socket buffer!

The ISO 11898-1 Chapter 8.4.2.3 (DLC field) says that register values > 8
should be reduced to 8 without any error reporting or frame drop.

This patch introduces a new helper macro to cast a given 4-bit data length
code (dlc) to __u8 and ensure the DLC value to be max. 8 bytes.

The different handlings in the rx path of the CAN netdevice drivers are fixed.

Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>

---


--------------060505090307030601080103
Content-Type: text/x-patch;
 name="can_dlc_rx_path_fixup.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="can_dlc_rx_path_fixup.patch"

diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
index cbe3fce..d0ec178 100644
--- a/drivers/net/can/at91_can.c
+++ b/drivers/net/can/at91_can.c
@@ -474,7 +474,7 @@ static void at91_read_mb(struct net_device *dev, unsigned int mb,
 	reg_msr = at91_read(priv, AT91_MSR(mb));
 	if (reg_msr & AT91_MSR_MRTR)
 		cf->can_id |= CAN_RTR_FLAG;
-	cf->can_dlc = min_t(__u8, (reg_msr >> 16) & 0xf, 8);
+	cf->can_dlc = get_can_dlc((reg_msr >> 16) & 0xf);
 
 	*(u32 *)(cf->data + 0) = at91_read(priv, AT91_MDL(mb));
 	*(u32 *)(cf->data + 4) = at91_read(priv, AT91_MDH(mb));
diff --git a/drivers/net/can/bfin_can.c b/drivers/net/can/bfin_can.c
index c7fc1de..0ec1524 100644
--- a/drivers/net/can/bfin_can.c
+++ b/drivers/net/can/bfin_can.c
@@ -392,7 +392,7 @@ static void bfin_can_rx(struct net_device *dev, u16 isrc)
 		cf->can_id |= CAN_RTR_FLAG;
 
 	/* get data length code */
-	cf->can_dlc = bfin_read16(&reg->chl[obj].dlc);
+	cf->can_dlc = get_can_dlc(bfin_read16(&reg->chl[obj].dlc) & 0xF);
 
 	/* get payload */
 	for (i = 0; i < 8; i += 2) {
diff --git a/drivers/net/can/mcp251x.c b/drivers/net/can/mcp251x.c
index 78b1b69..9c5a153 100644
--- a/drivers/net/can/mcp251x.c
+++ b/drivers/net/can/mcp251x.c
@@ -403,9 +403,8 @@ static void mcp251x_hw_rx_frame(struct spi_device *spi, u8 *buf,
 
 		for (i = 1; i < RXBDAT_OFF; i++)
 			buf[i] = mcp251x_read_reg(spi, RXBCTRL(buf_idx) + i);
-		len = buf[RXBDLC_OFF] & RXBDLC_LEN_MASK;
-		if (len > 8)
-			len = 8;
+
+		len = get_can_dlc(buf[RXBDLC_OFF] & RXBDLC_LEN_MASK);
 		for (; i < (RXBDAT_OFF + len); i++)
 			buf[i] = mcp251x_read_reg(spi, RXBCTRL(buf_idx) + i);
 	} else {
@@ -455,13 +454,7 @@ static void mcp251x_hw_rx(struct spi_device *spi, int buf_idx)
 			(buf[RXBSIDL_OFF] >> RXBSIDL_SHIFT);
 	}
 	/* Data length */
-	frame->can_dlc = buf[RXBDLC_OFF] & RXBDLC_LEN_MASK;
-	if (frame->can_dlc > 8) {
-		dev_warn(&spi->dev, "invalid frame recevied\n");
-		priv->net->stats.rx_errors++;
-		dev_kfree_skb(skb);
-		return;
-	}
+	frame->can_dlc = get_can_dlc(buf[RXBDLC_OFF] & RXBDLC_LEN_MASK);
 	memcpy(frame->data, buf + RXBDAT_OFF, frame->can_dlc);
 
 	priv->net->stats.rx_packets++;
diff --git a/drivers/net/can/mscan/mscan.c b/drivers/net/can/mscan/mscan.c
index bb06dfb..07346f8 100644
--- a/drivers/net/can/mscan/mscan.c
+++ b/drivers/net/can/mscan/mscan.c
@@ -297,7 +297,8 @@ static void mscan_get_rx_frame(struct net_device *dev, struct can_frame *frame)
 	frame->can_id |= can_id >> 1;
 	if (can_id & 1)
 		frame->can_id |= CAN_RTR_FLAG;
-	frame->can_dlc = in_8(&regs->rx.dlr) & 0xf;
+
+	frame->can_dlc = get_can_dlc(in_8(&regs->rx.dlr) & 0xf);
 
 	if (!(frame->can_id & CAN_RTR_FLAG)) {
 		void __iomem *data = &regs->rx.dsr1_0;
diff --git a/drivers/net/can/sja1000/sja1000.c b/drivers/net/can/sja1000/sja1000.c
index b4ba88a..542a4f7 100644
--- a/drivers/net/can/sja1000/sja1000.c
+++ b/drivers/net/can/sja1000/sja1000.c
@@ -293,15 +293,14 @@ static void sja1000_rx(struct net_device *dev)
 	uint8_t fi;
 	uint8_t dreg;
 	canid_t id;
-	uint8_t dlc;
 	int i;
 
+	/* create zero'ed CAN frame buffer */
 	skb = alloc_can_skb(dev, &cf);
 	if (skb == NULL)
 		return;
 
 	fi = priv->read_reg(priv, REG_FI);
-	dlc = fi & 0x0F;
 
 	if (fi & FI_FF) {
 		/* extended frame format (EFF) */
@@ -318,16 +317,15 @@ static void sja1000_rx(struct net_device *dev)
 		    | (priv->read_reg(priv, REG_ID2) >> 5);
 	}
 
-	if (fi & FI_RTR)
+	if (fi & FI_RTR) {
 		id |= CAN_RTR_FLAG;
+	} else {
+		cf->can_dlc = get_can_dlc(fi & 0x0F);
+		for (i = 0; i < cf->can_dlc; i++)
+			cf->data[i] = priv->read_reg(priv, dreg++);
+	}
 
 	cf->can_id = id;
-	cf->can_dlc = dlc;
-	for (i = 0; i < dlc; i++)
-		cf->data[i] = priv->read_reg(priv, dreg++);
-
-	while (i < 8)
-		cf->data[i++] = 0;
 
 	/* release receive buffer */
 	priv->write_reg(priv, REG_CMR, CMD_RRB);
@@ -335,7 +333,7 @@ static void sja1000_rx(struct net_device *dev)
 	netif_rx(skb);
 
 	stats->rx_packets++;
-	stats->rx_bytes += dlc;
+	stats->rx_bytes += cf->can_dlc;
 }
 
 static int sja1000_err(struct net_device *dev, uint8_t isrc, uint8_t status)
diff --git a/drivers/net/can/ti_hecc.c b/drivers/net/can/ti_hecc.c
index 07e8016..5c993c2 100644
--- a/drivers/net/can/ti_hecc.c
+++ b/drivers/net/can/ti_hecc.c
@@ -552,7 +552,7 @@ static int ti_hecc_rx_pkt(struct ti_hecc_priv *priv, int mbxno)
 	data = hecc_read_mbx(priv, mbxno, HECC_CANMCF);
 	if (data & HECC_CANMCF_RTR)
 		cf->can_id |= CAN_RTR_FLAG;
-	cf->can_dlc = data & 0xF;
+	cf->can_dlc = get_can_dlc(data & 0xF);
 	data = hecc_read_mbx(priv, mbxno, HECC_CANMDL);
 	*(u32 *)(cf->data) = cpu_to_be32(data);
 	if (cf->can_dlc > 4) {
diff --git a/drivers/net/can/usb/ems_usb.c b/drivers/net/can/usb/ems_usb.c
index 591eb0e..efbb05c 100644
--- a/drivers/net/can/usb/ems_usb.c
+++ b/drivers/net/can/usb/ems_usb.c
@@ -316,7 +316,7 @@ static void ems_usb_rx_can_msg(struct ems_usb *dev, struct ems_cpc_msg *msg)
 		return;
 
 	cf->can_id = le32_to_cpu(msg->msg.can_msg.id);
-	cf->can_dlc = min_t(u8, msg->msg.can_msg.length, 8);
+	cf->can_dlc = get_can_dlc(msg->msg.can_msg.length & 0xF);
 
 	if (msg->type == CPC_MSG_TYPE_EXT_CAN_FRAME ||
 	    msg->type == CPC_MSG_TYPE_EXT_RTR_FRAME)
diff --git a/include/linux/can/dev.h b/include/linux/can/dev.h
index 1ed2a5c..3db7767 100644
--- a/include/linux/can/dev.h
+++ b/include/linux/can/dev.h
@@ -51,6 +51,15 @@ struct can_priv {
 	struct sk_buff **echo_skb;
 };
 
+/*
+ * get_can_dlc(value) - helper macro to cast a given data length code (dlc)
+ * to __u8 and ensure the dlc value to be max. 8 bytes.
+ *
+ * To be used in the CAN netdriver receive path to ensure conformance with
+ * ISO 11898-1 Chapter 8.4.2.3 (DLC field)
+ */
+#define get_can_dlc(i)	(min_t(__u8, (i), 8))
+
 struct net_device *alloc_candev(int sizeof_priv, unsigned int echo_skb_max);
 void free_candev(struct net_device *dev);
 

--------------060505090307030601080103--
