From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] bcm43xx: make PIO mode usable
Date: Sun, 23 Apr 2006 13:23:10 +0200
Message-ID: <200604231323.11302.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart5074239.LKoZHD9tKc";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:49847
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1751370AbWDWLU2
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Apr 2006 07:20:28 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart5074239.LKoZHD9tKc
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Please apply this to 2.6.17, because it can be used
as a tempoary workaround for people with the >1G problem.

=2D-

This patch fixes PIO mode on the softmac bcm43xx
driver. (A dscape patch will follow).
It mainly fixes endianess issues.
This patch is tested on PowerPC32 and i386.

Signed-off-by: Michael Buesch <mb@bu3sch.de>

Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_dma.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=2D-- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_dma.h	2006-04-=
11 06:26:46.000000000 +0200
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_dma.h	2006-04-22 16:4=
7:51.000000000 +0200
@@ -213,6 +213,14 @@
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
=20
 #endif /* CONFIG_BCM43XX_DMA */
 #endif /* BCM43xx_DMA_H_ */
Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_pio.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=2D-- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_pio.c	2006-04-=
11 06:26:46.000000000 +0200
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_pio.c	2006-04-23 13:1=
0:02.000000000 +0200
@@ -27,6 +27,7 @@
 #include "bcm43xx_pio.h"
 #include "bcm43xx_main.h"
 #include "bcm43xx_xmit.h"
+#include "bcm43xx_power.h"
=20
 #include <linux/delay.h>
=20
@@ -44,10 +45,10 @@
 		bcm43xx_pio_write(queue, BCM43xx_PIO_TXDATA,
 				  octet);
 		bcm43xx_pio_write(queue, BCM43xx_PIO_TXCTL,
=2D				  BCM43xx_PIO_TXCTL_WRITEHI);
+				  BCM43xx_PIO_TXCTL_WRITELO);
 	} else {
 		bcm43xx_pio_write(queue, BCM43xx_PIO_TXCTL,
=2D				  BCM43xx_PIO_TXCTL_WRITEHI);
+				  BCM43xx_PIO_TXCTL_WRITELO);
 		bcm43xx_pio_write(queue, BCM43xx_PIO_TXDATA,
 				  octet);
 	}
@@ -103,7 +104,7 @@
 		bcm43xx_pio_write(queue, BCM43xx_PIO_TXDATA,
 				  skb->data[skb->len - 1]);
 		bcm43xx_pio_write(queue, BCM43xx_PIO_TXCTL,
=2D				  BCM43xx_PIO_TXCTL_WRITEHI |
+				  BCM43xx_PIO_TXCTL_WRITELO |
 				  BCM43xx_PIO_TXCTL_COMPLETE);
 	} else {
 		bcm43xx_pio_write(queue, BCM43xx_PIO_TXCTL,
@@ -112,9 +113,10 @@
 }
=20
 static u16 generate_cookie(struct bcm43xx_pioqueue *queue,
=2D			   int packetindex)
+			   struct bcm43xx_pio_txpacket *packet)
 {
 	u16 cookie =3D 0x0000;
+	int packetindex;
=20
 	/* We use the upper 4 bits for the PIO
 	 * controller ID and the lower 12 bits
@@ -135,6 +137,7 @@
 	default:
 		assert(0);
 	}
+	packetindex =3D pio_txpacket_getindex(packet);
 	assert(((u16)packetindex & 0xF000) =3D=3D 0x0000);
 	cookie |=3D (u16)packetindex;
=20
@@ -184,7 +187,7 @@
 	bcm43xx_generate_txhdr(queue->bcm,
 			       &txhdr, skb->data, skb->len,
 			       (packet->xmitted_frags =3D=3D 0),
=2D			       generate_cookie(queue, pio_txpacket_getindex(packet)));
+			       generate_cookie(queue, packet));
=20
 	tx_start(queue);
 	octets =3D skb->len + sizeof(txhdr);
@@ -241,7 +244,7 @@
 		queue->tx_devq_packets++;
 		queue->tx_devq_used +=3D octets;
=20
=2D		assert(packet->xmitted_frags <=3D packet->txb->nr_frags);
+		assert(packet->xmitted_frags < packet->txb->nr_frags);
 		packet->xmitted_frags++;
 		packet->xmitted_octets +=3D octets;
 	}
@@ -257,8 +260,14 @@
 	unsigned long flags;
 	struct bcm43xx_pio_txpacket *packet, *tmp_packet;
 	int err;
+	u16 txctl;
=20
 	bcm43xx_lock_mmio(bcm, flags);
+
+	txctl =3D bcm43xx_pio_read(queue, BCM43xx_PIO_TXCTL);
+	if (txctl & BCM43xx_PIO_TXCTL_SUSPEND)
+		goto out_unlock;
+
 	list_for_each_entry_safe(packet, tmp_packet, &queue->txqueue, list) {
 		assert(packet->xmitted_frags < packet->txb->nr_frags);
 		if (packet->xmitted_frags =3D=3D 0) {
@@ -288,6 +297,7 @@
 	next_packet:
 		continue;
 	}
+out_unlock:
 	bcm43xx_unlock_mmio(bcm, flags);
 }
=20
@@ -330,12 +340,19 @@
 		     (unsigned long)queue);
=20
 	value =3D bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS_BITFIELD);
=2D	value |=3D BCM43xx_SBF_XFER_REG_BYTESWAP;
+	value &=3D ~BCM43xx_SBF_XFER_REG_BYTESWAP;
 	bcm43xx_write32(bcm, BCM43xx_MMIO_STATUS_BITFIELD, value);
=20
 	qsize =3D bcm43xx_read16(bcm, queue->mmio_base + BCM43xx_PIO_TXQBUFSIZE);
+	if (qsize =3D=3D 0) {
+		printk(KERN_ERR PFX "ERROR: This card does not support PIO "
+				    "operation mode. Please use DMA mode "
+				    "(module parameter pio=3D0).\n");
+		goto err_freequeue;
+	}
 	if (qsize <=3D BCM43xx_PIO_TXQADJUST) {
=2D		printk(KERN_ERR PFX "PIO tx device-queue too small (%u)\n", qsize);
+		printk(KERN_ERR PFX "PIO tx device-queue too small (%u)\n",
+		       qsize);
 		goto err_freequeue;
 	}
 	qsize -=3D BCM43xx_PIO_TXQADJUST;
@@ -444,15 +461,10 @@
 {
 	struct bcm43xx_pioqueue *queue =3D bcm43xx_current_pio(bcm)->queue1;
 	struct bcm43xx_pio_txpacket *packet;
=2D	u16 tmp;
=20
 	assert(!queue->tx_suspended);
 	assert(!list_empty(&queue->txfree));
=20
=2D	tmp =3D bcm43xx_pio_read(queue, BCM43xx_PIO_TXCTL);
=2D	if (tmp & BCM43xx_PIO_TXCTL_SUSPEND)
=2D		return -EBUSY;
=2D
 	packet =3D list_entry(queue->txfree.next, struct bcm43xx_pio_txpacket, li=
st);
 	packet->txb =3D txb;
 	packet->xmitted_frags =3D 0;
@@ -462,7 +474,7 @@
 	assert(queue->nr_txfree < BCM43xx_PIO_MAXTXPACKETS);
=20
 	/* Suspend TX, if we are out of packets in the "free" queue. */
=2D	if (unlikely(list_empty(&queue->txfree))) {
+	if (list_empty(&queue->txfree)) {
 		netif_stop_queue(queue->bcm->net_dev);
 		queue->tx_suspended =3D 1;
 	}
@@ -480,15 +492,15 @@
=20
 	queue =3D parse_cookie(bcm, status->cookie, &packet);
 	assert(queue);
=2D//TODO
=2Dif (!queue)
=2Dreturn;
+
 	free_txpacket(packet, 1);
=2D	if (unlikely(queue->tx_suspended)) {
+	if (queue->tx_suspended) {
 		queue->tx_suspended =3D 0;
 		netif_wake_queue(queue->bcm->net_dev);
 	}
=2D	/* If there are packets on the txqueue, poke the tasklet. */
+	/* If there are packets on the txqueue, poke the tasklet
+	 * to transmit them.
+	 */
 	if (!list_empty(&queue->txqueue))
 		tasklet_schedule(&queue->txtask);
 }
@@ -519,12 +531,9 @@
 	int i, preamble_readwords;
 	struct sk_buff *skb;
=20
=2Dreturn;
 	tmp =3D bcm43xx_pio_read(queue, BCM43xx_PIO_RXCTL);
=2D	if (!(tmp & BCM43xx_PIO_RXCTL_DATAAVAILABLE)) {
=2D		dprintkl(KERN_ERR PFX "PIO RX: No data available\n");//TODO: remove th=
is printk.
+	if (!(tmp & BCM43xx_PIO_RXCTL_DATAAVAILABLE))
 		return;
=2D	}
 	bcm43xx_pio_write(queue, BCM43xx_PIO_RXCTL,
 			  BCM43xx_PIO_RXCTL_DATAAVAILABLE);
=20
@@ -538,8 +547,7 @@
 	return;
 data_ready:
=20
=2D//FIXME: endianess in this function.
=2D	len =3D le16_to_cpu(bcm43xx_pio_read(queue, BCM43xx_PIO_RXDATA));
+	len =3D bcm43xx_pio_read(queue, BCM43xx_PIO_RXDATA);
 	if (unlikely(len > 0x700)) {
 		pio_rx_error(queue, 0, "len > 0x700");
 		return;
@@ -555,7 +563,7 @@
 		preamble_readwords =3D 18 / sizeof(u16);
 	for (i =3D 0; i < preamble_readwords; i++) {
 		tmp =3D bcm43xx_pio_read(queue, BCM43xx_PIO_RXDATA);
=2D		preamble[i + 1] =3D cpu_to_be16(tmp);//FIXME?
+		preamble[i + 1] =3D cpu_to_le16(tmp);
 	}
 	rxhdr =3D (struct bcm43xx_rxhdr *)preamble;
 	rxflags2 =3D le16_to_cpu(rxhdr->flags2);
@@ -591,16 +599,40 @@
 	}
 	skb_put(skb, len);
 	for (i =3D 0; i < len - 1; i +=3D 2) {
=2D		tmp =3D cpu_to_be16(bcm43xx_pio_read(queue, BCM43xx_PIO_RXDATA));
=2D		*((u16 *)(skb->data + i)) =3D tmp;
+		tmp =3D bcm43xx_pio_read(queue, BCM43xx_PIO_RXDATA);
+		*((u16 *)(skb->data + i)) =3D cpu_to_le16(tmp);
 	}
 	if (len % 2) {
 		tmp =3D bcm43xx_pio_read(queue, BCM43xx_PIO_RXDATA);
 		skb->data[len - 1] =3D (tmp & 0x00FF);
+/* The specs say the following is required, but
+ * it is wrong and corrupts the PLCP. If we don't do
+ * this, the PLCP seems to be correct. So ifdef it out for now.
+ */
+#if 0
 		if (rxflags2 & BCM43xx_RXHDR_FLAGS2_TYPE2FRAME)
=2D			skb->data[0x20] =3D (tmp & 0xFF00) >> 8;
+			skb->data[2] =3D (tmp & 0xFF00) >> 8;
 		else
=2D			skb->data[0x1E] =3D (tmp & 0xFF00) >> 8;
+			skb->data[0] =3D (tmp & 0xFF00) >> 8;
+#endif
 	}
+	skb_trim(skb, len - IEEE80211_FCS_LEN);
 	bcm43xx_rx(queue->bcm, skb, rxhdr);
 }
+
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
Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_pio.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=2D-- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_pio.h	2006-04-=
11 06:26:46.000000000 +0200
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_pio.h	2006-04-22 16:4=
7:17.000000000 +0200
@@ -14,8 +14,8 @@
 #define BCM43xx_PIO_RXCTL		0x08
 #define BCM43xx_PIO_RXDATA		0x0A
=20
=2D#define BCM43xx_PIO_TXCTL_WRITEHI	(1 << 0)
=2D#define BCM43xx_PIO_TXCTL_WRITELO	(1 << 1)
+#define BCM43xx_PIO_TXCTL_WRITELO	(1 << 0)
+#define BCM43xx_PIO_TXCTL_WRITEHI	(1 << 1)
 #define BCM43xx_PIO_TXCTL_COMPLETE	(1 << 2)
 #define BCM43xx_PIO_TXCTL_INIT		(1 << 3)
 #define BCM43xx_PIO_TXCTL_SUSPEND	(1 << 7)
@@ -95,6 +95,7 @@
 		       u16 offset, u16 value)
 {
 	bcm43xx_write16(queue->bcm, queue->mmio_base + offset, value);
+	mmiowb();
 }
=20
=20
@@ -107,6 +108,9 @@
 				   struct bcm43xx_xmitstatus *status);
 void bcm43xx_pio_rx(struct bcm43xx_pioqueue *queue);
=20
+void bcm43xx_pio_tx_suspend(struct bcm43xx_pioqueue *queue);
+void bcm43xx_pio_tx_resume(struct bcm43xx_pioqueue *queue);
+
 #else /* CONFIG_BCM43XX_PIO */
=20
 static inline
@@ -133,6 +137,14 @@
 void bcm43xx_pio_rx(struct bcm43xx_pioqueue *queue)
 {
 }
+static inline
+void bcm43xx_pio_tx_suspend(struct bcm43xx_pioqueue *queue)
+{
+}
+static inline
+void bcm43xx_pio_tx_resume(struct bcm43xx_pioqueue *queue)
+{
+}
=20
 #endif /* CONFIG_BCM43XX_PIO */
 #endif /* BCM43xx_PIO_H_ */

=2D-=20
Greetings Michael.

--nextPart5074239.LKoZHD9tKc
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)

iD8DBQBES2Oflb09HEdWDKgRAkPpAJ0fWYQL9KYefmfT2Gor9q7sZDAcNwCffl2x
v9fcBhUeamQb7AnT8nXIKP0=
=oJn8
-----END PGP SIGNATURE-----

--nextPart5074239.LKoZHD9tKc--
