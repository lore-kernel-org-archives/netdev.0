From: Florian Fainelli <florian.fainelli@telecomint.eu>
Subject: [PATCH 07/10] r6040: use definitions for magic values in descriptor status
Date: Sun, 13 Jul 2008 14:34:15 +0200
Message-ID: <200807131434.16082.florian.fainelli@telecomint.eu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.int-evry.fr ([157.159.10.71]:42242 "EHLO
	smtp4.int-evry.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752955AbYGMMfB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jul 2008 08:35:01 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Define all the descriptor status the MAC can set.

Signed-off-by: Florian Fainelli <florian.fainelli@telecomint.eu>
---
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 9061ec1..973f1e8 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -138,6 +138,21 @@
 #define MBCR_DEFAULT	0x012A	/* MAC Bus Control Register */
 #define MCAST_MAX	4	/* Max number multicast addresses to filter */
 
+/* Descriptor status */
+#define DSC_OWNER_MAC	0x8000	/* MAC is the owner of this descriptor */
+#define DSC_RX_OK	0x4000	/* RX was successful */
+#define DSC_RX_ERR	0x0800	/* RX PHY error */
+#define DSC_RX_ERR_DRI	0x0400	/* RX dribble packet */
+#define DSC_RX_ERR_BUF	0x0200	/* RX length exceeds buffer size */
+#define DSC_RX_ERR_LONG	0x0100	/* RX length > maximum packet length */
+#define DSC_RX_ERR_RUNT	0x0080	/* RX packet length < 64 byte */
+#define DSC_RX_ERR_CRC	0x0040	/* RX CRC error */
+#define DSC_RX_BCAST	0x0020	/* RX broadcast (no error) */
+#define DSC_RX_MCAST	0x0010	/* RX multicast (no error) */
+#define DSC_RX_MCH_HIT	0x0008	/* RX multicast hit in hash table (no error) */
+#define DSC_RX_MIDH_HIT	0x0004	/* RX MID table hit (no error) */
+#define DSC_RX_IDX_MID_MASK 3	/* RX mask for the index of matched MIDx */
+
 /* PHY settings */
 #define ICPLUS_PHY_ID	0x0243
 
@@ -324,7 +339,7 @@ static int r6040_alloc_rxbufs(struct net_device *dev)
 		desc->buf = cpu_to_le32(pci_map_single(lp->pdev,
 						desc->skb_ptr->data,
 						MAX_BUF_SIZE, PCI_DMA_FROMDEVICE));
-		desc->status = 0x8000;
+		desc->status = DSC_OWNER_MAC;
 		desc = desc->vndescp;
 	} while (desc != lp->rx_ring);
 
@@ -541,25 +556,25 @@ static int r6040_rx(struct net_device *dev, int limit)
 	u16 err;
 
 	/* Limit not reached and the descriptor belongs to the CPU */
-	while (count < limit && !(descptr->status & 0x8000)) {
+	while (count < limit && !(descptr->status & DSC_OWNER_MAC)) {
 		/* Read the descriptor status */
 		err = descptr->status;
 		/* Global error status set */
-		if (err & 0x0800) {
+		if (err & DSC_RX_ERR) {
 			/* RX dribble */
-			if (err & 0x0400)
+			if (err & DSC_RX_ERR_DRI)
 				dev->stats.rx_frame_errors++;
 			/* Buffer lenght exceeded */
-			if (err & 0x0200)
+			if (err & DSC_RX_ERR_BUF)
 				dev->stats.rx_length_errors++;
 			/* Packet too long */
-			if (err & 0x0100)
+			if (err & DSC_RX_ERR_LONG)
 				dev->stats.rx_length_errors++;
 			/* Packet < 64 bytes */
-			if (err & 0x0080)
+			if (err & DSC_RX_ERR_RUNT)
 				dev->stats.rx_length_errors++;
 			/* CRC error */
-			if (err & 0x0040) {
+			if (err & DSC_RX_ERR_CRC) {
 				spin_lock(&priv->lock);
 				dev->stats.rx_crc_errors++;
 				spin_unlock(&priv->lock);
@@ -596,7 +611,7 @@ static int r6040_rx(struct net_device *dev, int limit)
 
 next_descr:
 		/* put the descriptor back to the MAC */
-		descptr->status = 0x8000;
+		descptr->status = DSC_OWNER_MAC;
 		descptr = descptr->vndescp;
 		count++;
 	}
@@ -624,7 +639,7 @@ static void r6040_tx(struct net_device *dev)
 		if (err & (0x2000 | 0x4000))
 			dev->stats.tx_carrier_errors++;
 
-		if (descptr->status & 0x8000)
+		if (descptr->status & DSC_OWNER_MAC)
 			break; /* Not complete */
 		skb_ptr = descptr->skb_ptr;
 		pci_unmap_single(priv->pdev, le32_to_cpu(descptr->buf),
@@ -874,7 +889,7 @@ static int r6040_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	descptr->skb_ptr = skb;
 	descptr->buf = cpu_to_le32(pci_map_single(lp->pdev,
 		skb->data, skb->len, PCI_DMA_TODEVICE));
-	descptr->status = 0x8000;
+	descptr->status = DSC_OWNER_MAC;
 	/* Trigger the MAC to check the TX descriptor */
 	iowrite16(0x01, ioaddr + MTPR);
 	lp->tx_insert_ptr = descptr->vndescp;
