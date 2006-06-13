From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH 4/4] bcm43xx: Port PIO fixes to d80211
Date: Tue, 13 Jun 2006 21:18:53 +0200
Message-ID: <200606132118.53392.mb@bu3sch.de>
References: <20060613191206.122150000@ppc1>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:44741
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1751149AbWFMTUY
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jun 2006 15:20:24 -0400
To: linville@tuxdriver.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Port the PIO fixes from bcm43xx-softmac to bcm43xx-d80211.

Signed-off-by: Michael Buesch <mb@bu3sch.de>
Index: wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.h
===================================================================
--- wireless-dev-dscapeports.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.h	2006-06-13 21:11:05.000000000 +0200
+++ wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.h	2006-06-13 21:11:48.000000000 +0200
@@ -223,6 +223,14 @@
 void bcm43xx_dma_rx(struct bcm43xx_dmaring *ring)
 {
 }
+static inline
+void bcm43xx_dma_tx_suspend(struct bcm43xx_dmaring *ring)
+{
+}
+static inline
+void bcm43xx_dma_tx_resume(struct bcm43xx_dmaring *ring)
+{
+}
 
 #endif /* CONFIG_BCM43XX_D80211_DMA */
 #endif /* BCM43xx_DMA_H_ */
Index: wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.c
===================================================================
--- wireless-dev-dscapeports.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.c	2006-06-13 21:11:24.000000000 +0200
+++ wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.c	2006-06-13 21:11:48.000000000 +0200
@@ -27,6 +27,7 @@
 #include "bcm43xx_pio.h"
 #include "bcm43xx_main.h"
 #include "bcm43xx_xmit.h"
+#include "bcm43xx_power.h"
 
 #include <linux/delay.h>
 
@@ -44,10 +45,10 @@
 		bcm43xx_pio_write(queue, BCM43xx_PIO_TXDATA,
 				  octet);
 		bcm43xx_pio_write(queue, BCM43xx_PIO_TXCTL,
-				  BCM43xx_PIO_TXCTL_WRITEHI);
+				  BCM43xx_PIO_TXCTL_WRITELO);
 	} else {
 		bcm43xx_pio_write(queue, BCM43xx_PIO_TXCTL,
-				  BCM43xx_PIO_TXCTL_WRITEHI);
+				  BCM43xx_PIO_TXCTL_WRITELO);
 		bcm43xx_pio_write(queue, BCM43xx_PIO_TXDATA,
 				  octet);
 	}
@@ -103,7 +104,7 @@
 		bcm43xx_pio_write(queue, BCM43xx_PIO_TXDATA,
 				  skb->data[skb->len - 1]);
 		bcm43xx_pio_write(queue, BCM43xx_PIO_TXCTL,
-				  BCM43xx_PIO_TXCTL_WRITEHI |
+				  BCM43xx_PIO_TXCTL_WRITELO |
 				  BCM43xx_PIO_TXCTL_COMPLETE);
 	} else {
 		bcm43xx_pio_write(queue, BCM43xx_PIO_TXCTL,
@@ -112,9 +113,10 @@
 }
 
 static u16 generate_cookie(struct bcm43xx_pioqueue *queue,
-			   int packetindex)
+			   struct bcm43xx_pio_txpacket *packet)
 {
 	u16 cookie = 0x0000;
+	int packetindex;
 
 	/* We use the upper 4 bits for the PIO
 	 * controller ID and the lower 12 bits
@@ -135,6 +137,7 @@
 	default:
 		assert(0);
 	}
+	packetindex = pio_txpacket_getindex(packet);
 	assert(((u16)packetindex & 0xF000) == 0x0000);
 	cookie |= (u16)packetindex;
 
@@ -184,8 +187,8 @@
 	bcm43xx_generate_txhdr(queue->bcm,
 			       &txhdr, skb->data, skb->len,
 			       1,//FIXME
-			       generate_cookie(queue, pio_txpacket_getindex(packet)),
-			       packet->ctl);
+			       generate_cookie(queue, packet),
+			       &packet->txstat.control);
 
 	tx_start(queue);
 	octets = skb->len + sizeof(txhdr);
@@ -200,10 +203,12 @@
 {
 	struct bcm43xx_pioqueue *queue = packet->queue;
 
-	if (irq_context)
-		dev_kfree_skb_irq(packet->skb);
-	else
-		dev_kfree_skb(packet->skb);
+	if (packet->skb) {
+		if (irq_context)
+			dev_kfree_skb_irq(packet->skb);
+		else
+			dev_kfree_skb(packet->skb);
+	}
 	list_move(&packet->list, &queue->txfree);
 	queue->nr_txfree++;
 }
@@ -216,8 +221,8 @@
 
 	octets = (u16)skb->len + sizeof(struct bcm43xx_txhdr);
 	if (queue->tx_devq_size < octets) {
-		dprintkl(KERN_WARNING PFX "PIO queue too small. "
-					  "Dropping packet.\n");
+		printkl(KERN_WARNING PFX "PIO queue too small. "
+					 "Dropping packet.\n");
 		/* Drop it silently (return success) */
 		free_txpacket(packet, 1);
 		return 0;
@@ -256,10 +261,14 @@
 	unsigned long flags;
 	struct bcm43xx_pio_txpacket *packet, *tmp_packet;
 	int err;
+	u16 txctl;
 
 	bcm43xx_lock_irqonly(bcm, flags);
 	if (queue->tx_frozen)
 		goto out_unlock;
+	txctl = bcm43xx_pio_read(queue, BCM43xx_PIO_TXCTL);
+	if (txctl & BCM43xx_PIO_TXCTL_SUSPEND)
+		goto out_unlock;
 
 	list_for_each_entry_safe(packet, tmp_packet, &queue->txqueue, list) {
 		/* Try to transmit the packet. This can fail, if
@@ -316,12 +325,19 @@
 		     (unsigned long)queue);
 
 	value = bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS_BITFIELD);
-	value |= BCM43xx_SBF_XFER_REG_BYTESWAP;
+	value &= ~BCM43xx_SBF_XFER_REG_BYTESWAP;
 	bcm43xx_write32(bcm, BCM43xx_MMIO_STATUS_BITFIELD, value);
 
 	qsize = bcm43xx_read16(bcm, queue->mmio_base + BCM43xx_PIO_TXQBUFSIZE);
+	if (qsize == 0) {
+		printk(KERN_ERR PFX "ERROR: This card does not support PIO "
+				    "operation mode. Please use DMA mode "
+				    "(module parameter pio=0).\n");
+		goto err_freequeue;
+	}
 	if (qsize <= BCM43xx_PIO_TXQADJUST) {
-		printk(KERN_ERR PFX "PIO tx device-queue too small (%u)\n", qsize);
+		printk(KERN_ERR PFX "PIO tx device-queue too small (%u)\n",
+		       qsize);
 		goto err_freequeue;
 	}
 	qsize -= BCM43xx_PIO_TXQADJUST;
@@ -430,20 +446,19 @@
 {
 	struct bcm43xx_pioqueue *queue = bcm43xx_current_pio(bcm)->queue1;
 	struct bcm43xx_pio_txpacket *packet;
-	u16 tmp;
 
 	assert(!queue->tx_suspended);
 	assert(!list_empty(&queue->txfree));
 
-	tmp = bcm43xx_pio_read(queue, BCM43xx_PIO_TXCTL);
-	if (tmp & BCM43xx_PIO_TXCTL_SUSPEND)
-		return -EBUSY;
-
 	packet = list_entry(queue->txfree.next, struct bcm43xx_pio_txpacket, list);
 	packet->skb = skb;
-	packet->ctl = ctl;
+
+	memset(&packet->txstat, 0, sizeof(packet->txstat));
+	memcpy(&packet->txstat.control, ctl, sizeof(*ctl));
+
 	list_move_tail(&packet->list, &queue->txqueue);
 	queue->nr_txfree--;
+	queue->nr_tx_packets++;
 	assert(queue->nr_txfree < BCM43xx_PIO_MAXTXPACKETS);
 
 	tasklet_schedule(&queue->txtask);
@@ -459,11 +474,20 @@
 
 	queue = parse_cookie(bcm, status->cookie, &packet);
 	assert(queue);
-//TODO
-if (!queue)
-return;
+
+	queue->tx_devq_packets--;
+	queue->tx_devq_used -= (packet->skb->len + sizeof(struct bcm43xx_txhdr));
+
+	packet->txstat.ack = !!(status->flags & BCM43xx_TXSTAT_FLAG_ACK);
+	packet->txstat.retry_count = status->cnt2 - 1;
+	ieee80211_tx_status_irqsafe(bcm->net_dev, packet->skb,
+				    &(packet->txstat));
+	packet->skb = NULL;
+
 	free_txpacket(packet, 1);
-	/* If there are packets on the txqueue, poke the tasklet. */
+	/* If there are packets on the txqueue, poke the tasklet
+	 * to transmit them.
+	 */
 	if (!list_empty(&queue->txqueue))
 		tasklet_schedule(&queue->txtask);
 }
@@ -508,12 +532,9 @@
 	int i, preamble_readwords;
 	struct sk_buff *skb;
 
-return;
 	tmp = bcm43xx_pio_read(queue, BCM43xx_PIO_RXCTL);
-	if (!(tmp & BCM43xx_PIO_RXCTL_DATAAVAILABLE)) {
-		dprintkl(KERN_ERR PFX "PIO RX: No data available\n");//TODO: remove this printk.
+	if (!(tmp & BCM43xx_PIO_RXCTL_DATAAVAILABLE))
 		return;
-	}
 	bcm43xx_pio_write(queue, BCM43xx_PIO_RXCTL,
 			  BCM43xx_PIO_RXCTL_DATAAVAILABLE);
 
@@ -527,8 +548,7 @@
 	return;
 data_ready:
 
-//FIXME: endianess in this function.
-	len = le16_to_cpu(bcm43xx_pio_read(queue, BCM43xx_PIO_RXDATA));
+	len = bcm43xx_pio_read(queue, BCM43xx_PIO_RXDATA);
 	if (unlikely(len > 0x700)) {
 		pio_rx_error(queue, 0, "len > 0x700");
 		return;
@@ -544,7 +564,7 @@
 		preamble_readwords = 18 / sizeof(u16);
 	for (i = 0; i < preamble_readwords; i++) {
 		tmp = bcm43xx_pio_read(queue, BCM43xx_PIO_RXDATA);
-		preamble[i + 1] = cpu_to_be16(tmp);//FIXME?
+		preamble[i + 1] = cpu_to_le16(tmp);
 	}
 	rxhdr = (struct bcm43xx_rxhdr *)preamble;
 	rxflags2 = le16_to_cpu(rxhdr->flags2);
@@ -580,20 +600,43 @@
 	}
 	skb_put(skb, len);
 	for (i = 0; i < len - 1; i += 2) {
-		tmp = cpu_to_be16(bcm43xx_pio_read(queue, BCM43xx_PIO_RXDATA));
-		*((u16 *)(skb->data + i)) = tmp;
+		tmp = bcm43xx_pio_read(queue, BCM43xx_PIO_RXDATA);
+		*((u16 *)(skb->data + i)) = cpu_to_le16(tmp);
 	}
 	if (len % 2) {
 		tmp = bcm43xx_pio_read(queue, BCM43xx_PIO_RXDATA);
 		skb->data[len - 1] = (tmp & 0x00FF);
+/* The specs say the following is required, but
+ * it is wrong and corrupts the PLCP. If we don't do
+ * this, the PLCP seems to be correct. So ifdef it out for now.
+ */
+#if 0
 		if (rxflags2 & BCM43xx_RXHDR_FLAGS2_TYPE2FRAME)
-			skb->data[0x20] = (tmp & 0xFF00) >> 8;
+			skb->data[2] = (tmp & 0xFF00) >> 8;
 		else
-			skb->data[0x1E] = (tmp & 0xFF00) >> 8;
+			skb->data[0] = (tmp & 0xFF00) >> 8;
+#endif
 	}
 	bcm43xx_rx(queue->bcm, skb, rxhdr);
 }
 
+void bcm43xx_pio_tx_suspend(struct bcm43xx_pioqueue *queue)
+{
+	bcm43xx_power_saving_ctl_bits(queue->bcm, -1, 1);
+	bcm43xx_pio_write(queue, BCM43xx_PIO_TXCTL,
+			  bcm43xx_pio_read(queue, BCM43xx_PIO_TXCTL)
+			  | BCM43xx_PIO_TXCTL_SUSPEND);
+}
+
+void bcm43xx_pio_tx_resume(struct bcm43xx_pioqueue *queue)
+{
+	bcm43xx_pio_write(queue, BCM43xx_PIO_TXCTL,
+			  bcm43xx_pio_read(queue, BCM43xx_PIO_TXCTL)
+			  & ~BCM43xx_PIO_TXCTL_SUSPEND);
+	bcm43xx_power_saving_ctl_bits(queue->bcm, -1, -1);
+	tasklet_schedule(&queue->txtask);
+}
+
 void bcm43xx_pio_freeze_txqueues(struct bcm43xx_private *bcm)
 {
 	struct bcm43xx_pio *pio;
Index: wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.h
===================================================================
--- wireless-dev-dscapeports.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.h	2006-06-13 21:11:24.000000000 +0200
+++ wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.h	2006-06-13 21:11:48.000000000 +0200
@@ -14,8 +14,8 @@
 #define BCM43xx_PIO_RXCTL		0x08
 #define BCM43xx_PIO_RXDATA		0x0A
 
-#define BCM43xx_PIO_TXCTL_WRITEHI	(1 << 0)
-#define BCM43xx_PIO_TXCTL_WRITELO	(1 << 1)
+#define BCM43xx_PIO_TXCTL_WRITELO	(1 << 0)
+#define BCM43xx_PIO_TXCTL_WRITEHI	(1 << 1)
 #define BCM43xx_PIO_TXCTL_COMPLETE	(1 << 2)
 #define BCM43xx_PIO_TXCTL_INIT		(1 << 3)
 #define BCM43xx_PIO_TXCTL_SUSPEND	(1 << 7)
@@ -41,7 +41,7 @@
 struct bcm43xx_pio_txpacket {
 	struct bcm43xx_pioqueue *queue;
 	struct sk_buff *skb;
-	struct ieee80211_tx_control *ctl;
+	struct ieee80211_tx_status txstat;
 	struct list_head list;
 };
 
@@ -94,6 +94,7 @@
 		       u16 offset, u16 value)
 {
 	bcm43xx_write16(queue->bcm, queue->mmio_base + offset, value);
+	mmiowb();
 }
 
 
@@ -108,6 +109,10 @@
 void bcm43xx_pio_get_tx_stats(struct bcm43xx_private *bcm,
 			      struct ieee80211_tx_queue_stats *stats);
 void bcm43xx_pio_rx(struct bcm43xx_pioqueue *queue);
+
+/* Suspend TX queue in hardware. */
+void bcm43xx_pio_tx_suspend(struct bcm43xx_pioqueue *queue);
+void bcm43xx_pio_tx_resume(struct bcm43xx_pioqueue *queue);
 /* Suspend (freeze) the TX tasklet (software level). */
 void bcm43xx_pio_freeze_txqueues(struct bcm43xx_private *bcm);
 void bcm43xx_pio_thaw_txqueues(struct bcm43xx_private *bcm);
@@ -145,6 +150,14 @@
 {
 }
 static inline
+void bcm43xx_pio_tx_suspend(struct bcm43xx_pioqueue *queue)
+{
+}
+static inline
+void bcm43xx_pio_tx_resume(struct bcm43xx_pioqueue *queue)
+{
+}
+static inline
 void bcm43xx_pio_freeze_txqueues(struct bcm43xx_private *bcm)
 {
 }

--

