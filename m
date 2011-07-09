From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 01/21] net: wrap common patterns of rx handler code
Date: Sat,  9 Jul 2011 19:17:51 +0200 (CEST)
Message-ID: <83c802518ea92ecdaaf7ffc89c875e226e09a441.1310229312.git.mirq-linux@rere.qmqm.pl>
References: <cover.1310229312.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
	Santiago Leon <santil@linux.vnet.ibm.com>,
	Tim Hockin <thockin@hockin.org>,
	Don Fry <pcnet32@frontier.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Ion Badulescu <ionut@badula.org>,
	Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	Grant Grundler <grundler@parisc-linux.org>,
	David Dillow <dave@thedillows.org>,
	Roger Luethi <rl@hellgate.ch>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:37400 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753715Ab1GIRRx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jul 2011 13:17:53 -0400
In-Reply-To: <cover.1310229312.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce dev_skb_finish_rx_dma() and dev_skb_finish_rx_dma_refill() --=
-
two common patterns for rx handling as seen in various network drivers
that implement rx_copybreak idea (copying smaller packets, passing larg=
er
ones in original skb).

The common pattern (as implemented in dev_skb_finish_rx_dma()) is:

if (packet len <=3D threshold)
	allocate new, smaller skb
	sync DMA buffer to cpu
	copy packet's data
	give DMA buffer back to device
	pass new skb
	reuse buffer in rx ring
else (or if skb alloc for copy failed)
	unmap DMA buffer
	pass skb
	remove buffer from rx ring
	[refill rx ring later]

This scheme is modified by some drivers to immediately refill rx slot b=
efore
passing original rx skb up the stack. Those drivers have also a problem=
 that
they drop packets from the head of the queue when that allocation fails=
=2E This
forces unnecessary retransmits and can deadlock if the device is used f=
or
swapping over network.  To mark this case, dev_skb_finish_rx_dma_refill=
()
implementing it, is marked as deprecated to encourage driver maintainer=
s to
look into the matter.

Those functions are called from rx handler hot path and have a lot of a=
rguments,
and so are inlined. This should allow compiler to better optimize the c=
ode with
calling code.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 include/linux/skbuff.h |  129 ++++++++++++++++++++++++++++++++++++++++=
++++++++
 1 files changed, 129 insertions(+), 0 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 08d4507..8f81972 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -29,6 +29,7 @@
 #include <linux/rcupdate.h>
 #include <linux/dmaengine.h>
 #include <linux/hrtimer.h>
+#include <linux/dma-mapping.h>
=20
 /* Don't change this without changing skb_csum_unnecessary! */
 #define CHECKSUM_NONE 0
@@ -2281,5 +2282,133 @@ static inline void skb_checksum_none_assert(str=
uct sk_buff *skb)
=20
 bool skb_partial_csum_set(struct sk_buff *skb, u16 start, u16 off);
=20
+/**
+ * __dev_skb_finish_rx_dma - finish skb after DMA'd RX
+ * @skb: skb to finish
+ * @len: packet data length
+ * @copybreak: maximum packet size to copy
+ * @dma_dev: device used for DMA
+ * @dma_buf: DMA mapping address
+ * @dma_len: DMA mapping length
+ *
+ * This function finishes DMA mapping (sync for copied, unmap otherwis=
e) for
+ * a packet and copies it to new skb if its size is at or below @copyb=
reak
+ * threshold.
+ *
+ * Returns new skb or NULL if the copy wasn't made.
+ */
+static inline struct sk_buff *__dev_skb_finish_rx_dma(
+	struct sk_buff *skb, unsigned int len, unsigned int copybreak,
+	struct device *dma_dev, dma_addr_t dma_buf, size_t dma_len)
+{
+	if (len <=3D copybreak) {
+		struct sk_buff *skb2 =3D netdev_alloc_skb_ip_align(skb->dev, len);
+		if (likely(skb2)) {
+			dma_sync_single_for_cpu(dma_dev, dma_buf, dma_len,
+				DMA_FROM_DEVICE);
+			skb_copy_to_linear_data(skb2, skb->data, len);
+			dma_sync_single_for_device(dma_dev, dma_buf, dma_len,
+				DMA_FROM_DEVICE);
+			return skb2;
+		}
+	}
+
+	/* else or copy failed */
+
+	dma_unmap_single(dma_dev, dma_buf, dma_len, DMA_FROM_DEVICE);
+	return NULL;
+}
+
+/**
+ * dev_skb_finish_rx_dma - finish skb after DMA'd RX
+ * @pskb: pointer to variable holding skb to finish
+ * @len: packet data length
+ * @copybreak: maximum packet size to copy
+ * @dma_dev: device used for DMA
+ * @dma_buf: DMA mapping address
+ * @dma_len: DMA mapping length
+ *
+ * This function finishes DMA mapping (sync for copied, unmap otherwis=
e) for
+ * a packet and copies it to new skb if its size is at or below @copyb=
reak
+ * threshold.  Like __dev_skb_finish_rx_dma().
+ *
+ * Returns the skb - old or copied. *pskb is cleared if the skb wasn't=
 copied.
+ */
+static inline struct sk_buff *dev_skb_finish_rx_dma(
+	struct sk_buff **pskb, unsigned int len, unsigned int copybreak,
+	struct device *dma_dev, dma_addr_t dma_buf, size_t dma_len)
+{
+	struct sk_buff *skb2;
+
+	skb2 =3D __dev_skb_finish_rx_dma(*pskb, len, copybreak,
+		dma_dev, dma_buf, dma_len);
+
+	if (!skb2) {
+		/* not copied */
+		skb2 =3D *pskb;
+		*pskb =3D NULL;
+	}
+
+	skb_put(skb2, len);
+	return skb2;
+}
+
+/**
+ * dev_skb_finish_rx_dma_refill - finish skb after DMA'd RX and refill=
 the slot
+ * @pskb: pointer to variable holding skb to finish
+ * @len: packet data length
+ * @copybreak: maximum packet size to copy
+ * @ip_align: new skb's alignment offset
+ * @rx_offset: count of bytes prepended by HW before packet's data
+ * @dma_dev: device used for DMA
+ * @dma_buf: DMA mapping address
+ * @dma_len: DMA mapping length
+ *
+ * This function finishes DMA mapping (sync for copied, unmap otherwis=
e) for
+ * a packet and copies it to new skb if its size is at or below @copyb=
reak
+ * threshold.  Like __dev_skb_finish_rx_dma().
+ *
+ * *pskb is filled with new mapped skb if the skb wasn't copied.
+ * Returns the skb - old or copied, or NULL if refill failed.
+ *
+ * NOTE:
+ * This will effectively drop the packet in case of memory pressure. T=
his
+ * might not be wanted when swapping over network. It's better to thro=
ttle
+ * the receiver queue (refill later) as the packet might be needed to
+ * reclaim some memory.
+ */
+static inline __deprecated struct sk_buff *dev_skb_finish_rx_dma_refil=
l(
+	struct sk_buff **pskb, unsigned int len, unsigned int copybreak,
+	unsigned int ip_align, unsigned int rx_offset,
+	struct device *dma_dev, dma_addr_t *dma_buf, size_t dma_len)
+{
+	struct sk_buff *skb;
+
+	skb =3D __dev_skb_finish_rx_dma(*pskb, len, copybreak,
+		dma_dev, *dma_buf, dma_len);
+
+	if (!skb) {
+		/* not copied */
+		skb =3D *pskb;
+		/* netdev_alloc_skb_ip_align() */
+		*pskb =3D netdev_alloc_skb(skb->dev, dma_len + ip_align);
+		if (likely(*pskb))
+			skb_reserve(*pskb, ip_align + rx_offset);
+		else {
+			/* no memory - drop packet */
+			*pskb =3D skb;
+			skb =3D NULL;
+		}
+
+		*dma_buf =3D dma_map_single(dma_dev, (*pskb)->data - rx_offset,
+			dma_len, DMA_FROM_DEVICE);
+	}
+
+	if (likely(skb))
+		skb_put(skb, len);
+
+	return skb;
+}
+
 #endif	/* __KERNEL__ */
 #endif	/* _LINUX_SKBUFF_H */
--=20
1.7.5.4

