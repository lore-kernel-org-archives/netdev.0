From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 2/4 net-next] tg3: provide frags as skb head
Date: Fri, 27 Apr 2012 12:34:49 +0200
Message-ID: <1335522889.2775.231.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Tom Herbert <therbert@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Michael Chan <mchan@broadcom.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:62698 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759804Ab2D0Kez (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2012 06:34:55 -0400
Received: by bkuw12 with SMTP id w12so387094bku.19
        for <netdev@vger.kernel.org>; Fri, 27 Apr 2012 03:34:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

This patch converts tg3 driver, one of our reference drivers, to use ne=
w
build_skb() api in frag mode.

Instead of using kmalloc() to allocate the memory block that will be
used by build_skb() as skb->head, we use a page fragment.

This is a followup of patch "net: allow skb->head to be a page fragment=
"

This allows GRO, TCP coalescing, and splice() to be more efficient.

Incidentally, this also removes SLUB slow path contention in kfree()

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Maciej =C5=BBenczykowski <maze@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Tom Herbert <therbert@google.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>
Cc: Matt Carlson <mcarlson@broadcom.com>
Cc: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   74 ++++++++++++++++++++++----
 drivers/net/ethernet/broadcom/tg3.h |    2=20
 2 files changed, 66 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet=
/broadcom/tg3.c
index d481b0a..c1a580e 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -195,6 +195,15 @@ static inline void _tg3_flag_clear(enum TG3_FLAGS =
flag, unsigned long *bits)
 #define TG3_RX_OFFSET(tp)	(NET_SKB_PAD)
 #endif
=20
+/* This driver uses the new build_skb() API providing a frag as skb->h=
ead
+ * This strategy permits better GRO aggregation, better TCP coalescing=
, and
+ * better splice() implementation (avoids a copy from head to a page),=
 at
+ * minimal memory cost.
+ * In this 2048 bytes block, we have enough room to store the MTU=3D15=
00 frame
+ * and the struct skb_shared_info.
+ */
+#define TG3_FRAGSIZE 2048
+
 /* minimum number of free TX descriptors required to wake up TX proces=
s */
 #define TG3_TX_WAKEUP_THRESH(tnapi)		((tnapi)->tx_pending / 4)
 #define TG3_TX_BD_DMA_MAX_2K		2048
@@ -5617,17 +5626,48 @@ static void tg3_tx(struct tg3_napi *tnapi)
 	}
 }
=20
+static void *tg3_frag_alloc(struct tg3_rx_prodring_set *tpr)
+{
+	void *data;
+
+	if (tpr->rx_page_size < TG3_FRAGSIZE) {
+		struct page *page =3D alloc_page(GFP_ATOMIC);
+
+		if (!page)
+			return NULL;
+		atomic_add((PAGE_SIZE / TG3_FRAGSIZE) - 1, &page->_count);=20
+		tpr->rx_page_addr =3D page_address(page);
+		tpr->rx_page_size =3D PAGE_SIZE;
+	}
+	data =3D tpr->rx_page_addr;
+	tpr->rx_page_addr +=3D TG3_FRAGSIZE;
+	tpr->rx_page_size -=3D TG3_FRAGSIZE;
+	return data;
+}
+
+static void tg3_frag_free(bool is_frag, void *data)
+{
+	if (is_frag)
+		put_page(virt_to_head_page(data));
+	else
+		kfree(data);
+}
+
 static void tg3_rx_data_free(struct tg3 *tp, struct ring_info *ri, u32=
 map_sz)
 {
+	unsigned int skb_size =3D SKB_DATA_ALIGN(map_sz + TG3_RX_OFFSET(tp)) =
+
+		   SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
+
 	if (!ri->data)
 		return;
=20
 	pci_unmap_single(tp->pdev, dma_unmap_addr(ri, mapping),
 			 map_sz, PCI_DMA_FROMDEVICE);
-	kfree(ri->data);
+	tg3_frag_free(skb_size <=3D TG3_FRAGSIZE, ri->data);
 	ri->data =3D NULL;
 }
=20
+
 /* Returns size of skb allocated or < 0 on error.
  *
  * We only need to fill in the address because the other members
@@ -5640,7 +5680,8 @@ static void tg3_rx_data_free(struct tg3 *tp, stru=
ct ring_info *ri, u32 map_sz)
  * (to fetch the error flags, vlan tag, checksum, and opaque cookie).
  */
 static int tg3_alloc_rx_data(struct tg3 *tp, struct tg3_rx_prodring_se=
t *tpr,
-			    u32 opaque_key, u32 dest_idx_unmasked)
+			     u32 opaque_key, u32 dest_idx_unmasked,
+			     unsigned int *frag_size)
 {
 	struct tg3_rx_buffer_desc *desc;
 	struct ring_info *map;
@@ -5675,7 +5716,13 @@ static int tg3_alloc_rx_data(struct tg3 *tp, str=
uct tg3_rx_prodring_set *tpr,
 	 */
 	skb_size =3D SKB_DATA_ALIGN(data_size + TG3_RX_OFFSET(tp)) +
 		   SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
-	data =3D kmalloc(skb_size, GFP_ATOMIC);
+	if (skb_size <=3D TG3_FRAGSIZE) {
+		data =3D tg3_frag_alloc(tpr);
+		*frag_size =3D TG3_FRAGSIZE;
+	} else {
+		data =3D kmalloc(skb_size, GFP_ATOMIC);
+		*frag_size =3D 0;
+	}
 	if (!data)
 		return -ENOMEM;
=20
@@ -5683,8 +5730,8 @@ static int tg3_alloc_rx_data(struct tg3 *tp, stru=
ct tg3_rx_prodring_set *tpr,
 				 data + TG3_RX_OFFSET(tp),
 				 data_size,
 				 PCI_DMA_FROMDEVICE);
-	if (pci_dma_mapping_error(tp->pdev, mapping)) {
-		kfree(data);
+	if (unlikely(pci_dma_mapping_error(tp->pdev, mapping))) {
+		tg3_frag_free(skb_size <=3D TG3_FRAGSIZE, data);
 		return -EIO;
 	}
=20
@@ -5835,18 +5882,19 @@ static int tg3_rx(struct tg3_napi *tnapi, int b=
udget)
=20
 		if (len > TG3_RX_COPY_THRESH(tp)) {
 			int skb_size;
+			unsigned int frag_size;
=20
 			skb_size =3D tg3_alloc_rx_data(tp, tpr, opaque_key,
-						    *post_ptr);
+						    *post_ptr, &frag_size);
 			if (skb_size < 0)
 				goto drop_it;
=20
 			pci_unmap_single(tp->pdev, dma_addr, skb_size,
 					 PCI_DMA_FROMDEVICE);
=20
-			skb =3D build_skb(data, 0);
+			skb =3D build_skb(data, frag_size);
 			if (!skb) {
-				kfree(data);
+				tg3_frag_free(frag_size !=3D 0, data);
 				goto drop_it_no_recycle;
 			}
 			skb_reserve(skb, TG3_RX_OFFSET(tp));
@@ -7279,7 +7327,10 @@ static int tg3_rx_prodring_alloc(struct tg3 *tp,
=20
 	/* Now allocate fresh SKBs for each rx ring. */
 	for (i =3D 0; i < tp->rx_pending; i++) {
-		if (tg3_alloc_rx_data(tp, tpr, RXD_OPAQUE_RING_STD, i) < 0) {
+		unsigned int frag_size;
+
+		if (tg3_alloc_rx_data(tp, tpr, RXD_OPAQUE_RING_STD, i,
+				      &frag_size) < 0) {
 			netdev_warn(tp->dev,
 				    "Using a smaller RX standard ring. Only "
 				    "%d out of %d buffers were allocated "
@@ -7311,7 +7362,10 @@ static int tg3_rx_prodring_alloc(struct tg3 *tp,
 	}
=20
 	for (i =3D 0; i < tp->rx_jumbo_pending; i++) {
-		if (tg3_alloc_rx_data(tp, tpr, RXD_OPAQUE_RING_JUMBO, i) < 0) {
+		unsigned int frag_size;
+
+		if (tg3_alloc_rx_data(tp, tpr, RXD_OPAQUE_RING_JUMBO, i,
+				      &frag_size) < 0) {
 			netdev_warn(tp->dev,
 				    "Using a smaller RX jumbo ring. Only %d "
 				    "out of %d buffers were allocated "
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet=
/broadcom/tg3.h
index 93865f8..7c85545 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -2815,6 +2815,8 @@ struct tg3_rx_prodring_set {
 	struct ring_info		*rx_jmb_buffers;
 	dma_addr_t			rx_std_mapping;
 	dma_addr_t			rx_jmb_mapping;
+	void				*rx_page_addr;
+	unsigned int			rx_page_size;
 };
=20
 #define TG3_IRQ_MAX_VECS_RSS		5
