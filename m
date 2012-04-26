From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] allow skb->head to point/alias to first skb frag
Date: Thu, 26 Apr 2012 15:50:52 +0200
Message-ID: <1335448252.2775.41.camel@edumazet-glaptop>
References: <1335427854.2775.15.camel@edumazet-glaptop>
	 <20120426.043623.1317043382565428400.davem@davemloft.net>
	 <1335431402.2775.24.camel@edumazet-glaptop>
	 <20120426.051800.637617874638567499.davem@davemloft.net>
	 <1335432147.2775.27.camel@edumazet-glaptop>
	 <CANP3RGdnZk5b-gMkF8BPScrp9xos4X1u3n58ocuBQhTT7taE8A@mail.gmail.com>
	 <1335443554.2775.33.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, ilpo.jarvinen@helsinki.fi,
	rick.jones2@hp.com, netdev@vger.kernel.org, therbert@google.com,
	ncardwell@google.com, ycheng@google.com
To: Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:40622 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752380Ab2DZNu7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 09:50:59 -0400
Received: by bkuw12 with SMTP id w12so1002093bku.19
        for <netdev@vger.kernel.org>; Thu, 26 Apr 2012 06:50:58 -0700 (PDT)
In-Reply-To: <1335443554.2775.33.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-04-26 at 14:32 +0200, Eric Dumazet wrote:
> On Thu, 2012-04-26 at 03:09 -0700, Maciej =C5=BBenczykowski wrote:
> > it would be very useful if there was an api for freeing skb->head m=
emory...
> >=20
> > I've fooled around with a single memory buffer for both the head an=
d
> > the data and seen huge performance wins under heavy packet load (ha=
lf
> > the amount of malloc/free), but could never quite get it to be 100%
> > stable.
>=20
> My patch is almost ready, and seems very good.
>=20
> I added a param to skb_build() to tell the memory comes from a (sub)p=
age
>=20
> tg3 uses the new thing.
>=20
> GRO does the correct merging.
>=20
> (by the way, I noticed GRO lies about skb truesize... since it
> accumulates frag lengths instead of allocated space... with a 1448/20=
48
> mismatch for MTU=3D1500)
>=20
> And this apparently solves my slub performance issue I had on my dual
> quad core machine, since I no longer hit slub slow path.
>=20
>=20

Here is the raw patch. (tg3 part is dirty and needs some helpers)

I am working on the TCP coalesce part, the splice() helpers (to avoid a
copy), and split in five different patches for further
discussion/inclusion.


 drivers/net/ethernet/broadcom/bnx2.c            |    2=20
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |    4=20
 drivers/net/ethernet/broadcom/tg3.c             |   61 +++++++++++---
 drivers/net/ethernet/broadcom/tg3.h             |    2=20
 include/linux/skbuff.h                          |    7 +
 net/core/dev.c                                  |    5 -
 net/core/skbuff.c                               |   46 ++++++++--
 net/ipv4/tcp_input.c                            |    1=20
 8 files changed, 103 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/etherne=
t/broadcom/bnx2.c
index ab55979..ac7b744 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -3006,7 +3006,7 @@ error:
=20
 	dma_unmap_single(&bp->pdev->dev, dma_addr, bp->rx_buf_use_size,
 			 PCI_DMA_FROMDEVICE);
-	skb =3D build_skb(data);
+	skb =3D build_skb(data, 0);
 	if (!skb) {
 		kfree(data);
 		goto error;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/=
net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 60d5b54..9c5bc5d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -513,7 +513,7 @@ static inline void bnx2x_tpa_stop(struct bnx2x *bp,=
 struct bnx2x_fastpath *fp,
 	dma_unmap_single(&bp->pdev->dev, dma_unmap_addr(rx_buf, mapping),
 			 fp->rx_buf_size, DMA_FROM_DEVICE);
 	if (likely(new_data))
-		skb =3D build_skb(data);
+		skb =3D build_skb(data, 0);
=20
 	if (likely(skb)) {
 #ifdef BNX2X_STOP_ON_ERROR
@@ -721,7 +721,7 @@ int bnx2x_rx_int(struct bnx2x_fastpath *fp, int bud=
get)
 						 dma_unmap_addr(rx_buf, mapping),
 						 fp->rx_buf_size,
 						 DMA_FROM_DEVICE);
-				skb =3D build_skb(data);
+				skb =3D build_skb(data, 0);
 				if (unlikely(!skb)) {
 					kfree(data);
 					fp->eth_q_stats.rx_skb_alloc_failed++;
diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet=
/broadcom/tg3.c
index 0c3e7c7..d216076 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -5619,12 +5619,18 @@ static void tg3_tx(struct tg3_napi *tnapi)
=20
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
+	if (skb_size <=3D 2048)
+		put_page(virt_to_head_page(ri->data));
+	else
+		kfree(ri->data);
 	ri->data =3D NULL;
 }
=20
@@ -5640,7 +5646,8 @@ static void tg3_rx_data_free(struct tg3 *tp, stru=
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
@@ -5675,16 +5682,36 @@ static int tg3_alloc_rx_data(struct tg3 *tp, st=
ruct tg3_rx_prodring_set *tpr,
 	 */
 	skb_size =3D SKB_DATA_ALIGN(data_size + TG3_RX_OFFSET(tp)) +
 		   SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
-	data =3D kmalloc(skb_size, GFP_ATOMIC);
-	if (!data)
-		return -ENOMEM;
-
+	if (skb_size <=3D 2048) {
+		if (tpr->rx_page_size < 2048) {
+			struct page *page =3D alloc_page(GFP_ATOMIC);
+			if (!page)
+				return -ENOMEM;
+			atomic_add((PAGE_SIZE / 2048) - 1, &page->_count);=20
+			tpr->rx_page_addr =3D page_address(page);
+			tpr->rx_page_size =3D PAGE_SIZE;
+		}
+		data =3D tpr->rx_page_addr;
+		tpr->rx_page_addr +=3D 2048;
+		tpr->rx_page_size -=3D 2048;
+		*frag_size =3D 2048;
+	} else {
+		data =3D kmalloc(skb_size, GFP_ATOMIC);
+		if (!data)
+			return -ENOMEM;
+		*frag_size =3D 0;
+	}
 	mapping =3D pci_map_single(tp->pdev,
 				 data + TG3_RX_OFFSET(tp),
 				 data_size,
 				 PCI_DMA_FROMDEVICE);
 	if (pci_dma_mapping_error(tp->pdev, mapping)) {
-		kfree(data);
+		if (skb_size <=3D 2048) {
+			tpr->rx_page_addr -=3D 2048;
+			tpr->rx_page_size +=3D 2048;
+		} else {
+			kfree(data);
+		}
 		return -EIO;
 	}
=20
@@ -5835,18 +5862,22 @@ static int tg3_rx(struct tg3_napi *tnapi, int b=
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
-			skb =3D build_skb(data);
+			skb =3D build_skb(data, frag_size);
 			if (!skb) {
-				kfree(data);
+				if (frag_size)
+					put_page(virt_to_head_page(data));
+				else
+					kfree(data);
 				goto drop_it_no_recycle;
 			}
 			skb_reserve(skb, TG3_RX_OFFSET(tp));
@@ -7279,7 +7310,10 @@ static int tg3_rx_prodring_alloc(struct tg3 *tp,
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
@@ -7311,7 +7345,10 @@ static int tg3_rx_prodring_alloc(struct tg3 *tp,
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
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 4a656b5..1161111 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -470,7 +470,8 @@ struct sk_buff {
 	__u8			wifi_acked_valid:1;
 	__u8			wifi_acked:1;
 	__u8			no_fcs:1;
-	/* 9/11 bit hole (depending on ndisc_nodetype presence) */
+	__u8			head_frag:1;
+	/* 8/10 bit hole (depending on ndisc_nodetype presence) */
 	kmemcheck_bitfield_end(flags2);
=20
 #ifdef CONFIG_NET_DMA
@@ -558,11 +559,13 @@ static inline struct rtable *skb_rtable(const str=
uct sk_buff *skb)
 }
=20
 extern void kfree_skb(struct sk_buff *skb);
+extern struct kmem_cache *skbuff_head_cache;
+
 extern void consume_skb(struct sk_buff *skb);
 extern void	       __kfree_skb(struct sk_buff *skb);
 extern struct sk_buff *__alloc_skb(unsigned int size,
 				   gfp_t priority, int fclone, int node);
-extern struct sk_buff *build_skb(void *data);
+extern struct sk_buff *build_skb(void *data, unsigned int frag_size);
 static inline struct sk_buff *alloc_skb(unsigned int size,
 					gfp_t priority)
 {
diff --git a/net/core/dev.c b/net/core/dev.c
index 501f3cc..9537321 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3546,7 +3546,10 @@ gro_result_t napi_skb_finish(gro_result_t ret, s=
truct sk_buff *skb)
 		break;
=20
 	case GRO_MERGED_FREE:
-		consume_skb(skb);
+		if (skb->head_frag)
+			kmem_cache_free(skbuff_head_cache, skb);
+		else
+			consume_skb(skb);
 		break;
=20
 	case GRO_HELD:
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 2342a72..d8fb4b2 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -69,7 +69,7 @@
 #include <trace/events/skb.h>
 #include <linux/highmem.h>
=20
-static struct kmem_cache *skbuff_head_cache __read_mostly;
+struct kmem_cache *skbuff_head_cache __read_mostly;
 static struct kmem_cache *skbuff_fclone_cache __read_mostly;
=20
 static void sock_pipe_buf_release(struct pipe_inode_info *pipe,
@@ -245,6 +245,7 @@ EXPORT_SYMBOL(__alloc_skb);
 /**
  * build_skb - build a network buffer
  * @data: data buffer provided by caller
+ * @frag_size: size of fragment, or 0 if head was kmalloced
  *
  * Allocate a new &sk_buff. Caller provides space holding head and
  * skb_shared_info. @data must have been allocated by kmalloc()
@@ -258,20 +259,21 @@ EXPORT_SYMBOL(__alloc_skb);
  *  before giving packet to stack.
  *  RX rings only contains data buffers, not full skbs.
  */
-struct sk_buff *build_skb(void *data)
+struct sk_buff *build_skb(void *data, unsigned int frag_size)
 {
 	struct skb_shared_info *shinfo;
 	struct sk_buff *skb;
-	unsigned int size;
+	unsigned int size =3D frag_size ? : ksize(data);
=20
 	skb =3D kmem_cache_alloc(skbuff_head_cache, GFP_ATOMIC);
 	if (!skb)
 		return NULL;
=20
-	size =3D ksize(data) - SKB_DATA_ALIGN(sizeof(struct skb_shared_info))=
;
+	size -=3D SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
=20
 	memset(skb, 0, offsetof(struct sk_buff, tail));
 	skb->truesize =3D SKB_TRUESIZE(size);
+	skb->head_frag =3D frag_size !=3D 0;
 	atomic_set(&skb->users, 1);
 	skb->head =3D data;
 	skb->data =3D data;
@@ -376,6 +378,14 @@ static void skb_clone_fraglist(struct sk_buff *skb=
)
 		skb_get(list);
 }
=20
+static void skb_free_head(struct sk_buff *skb)
+{
+	if (skb->head_frag)
+		put_page(virt_to_head_page(skb->head));
+	else
+		kfree(skb->head);
+}
+
 static void skb_release_data(struct sk_buff *skb)
 {
 	if (!skb->cloned ||
@@ -402,7 +412,7 @@ static void skb_release_data(struct sk_buff *skb)
 		if (skb_has_frag_list(skb))
 			skb_drop_fraglist(skb);
=20
-		kfree(skb->head);
+		skb_free_head(skb);
 	}
 }
=20
@@ -644,6 +654,7 @@ static struct sk_buff *__skb_clone(struct sk_buff *=
n, struct sk_buff *skb)
 	C(tail);
 	C(end);
 	C(head);
+	C(head_frag);
 	C(data);
 	C(truesize);
 	atomic_set(&n->users, 1);
@@ -940,7 +951,7 @@ int pskb_expand_head(struct sk_buff *skb, int nhead=
, int ntail,
 		fastpath =3D atomic_read(&skb_shinfo(skb)->dataref) =3D=3D delta;
 	}
=20
-	if (fastpath &&
+	if (fastpath && !skb->head_frag &&
 	    size + sizeof(struct skb_shared_info) <=3D ksize(skb->head)) {
 		memmove(skb->head + size, skb_shinfo(skb),
 			offsetof(struct skb_shared_info,
@@ -967,7 +978,7 @@ int pskb_expand_head(struct sk_buff *skb, int nhead=
, int ntail,
 	       offsetof(struct skb_shared_info, frags[skb_shinfo(skb)->nr_fra=
gs]));
=20
 	if (fastpath) {
-		kfree(skb->head);
+		skb_free_head(skb);
 	} else {
 		/* copy this zero copy skb frags */
 		if (skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY) {
@@ -985,6 +996,7 @@ int pskb_expand_head(struct sk_buff *skb, int nhead=
, int ntail,
 	off =3D (data + nhead) - skb->head;
=20
 	skb->head     =3D data;
+	skb->head_frag =3D 0;
 adjust_others:
 	skb->data    +=3D off;
 #ifdef NET_SKBUFF_DATA_USES_OFFSET
@@ -2889,6 +2901,26 @@ int skb_gro_receive(struct sk_buff **head, struc=
t sk_buff *skb)
=20
 		NAPI_GRO_CB(skb)->free =3D 1;
 		goto done;
+	} else if (skb->head_frag) {
+		int nr_frags =3D pinfo->nr_frags;
+		skb_frag_t *frag =3D pinfo->frags + nr_frags;
+		struct page *page =3D virt_to_head_page(skb->head);
+
+
+		if (nr_frags >=3D MAX_SKB_FRAGS)
+			return -E2BIG;
+		offset -=3D headlen;
+		offset +=3D skb->head - (unsigned char *)page_address(page);
+
+		pinfo->nr_frags =3D nr_frags + 1;
+
+		frag->page.p	  =3D page;
+		frag->page_offset =3D offset;
+		skb_frag_size_set(frag, len);
+
+		/* note : napi_skb_finish() will free skb, not skb->head */
+		NAPI_GRO_CB(skb)->free =3D 1;
+		goto done;
 	} else if (skb_gro_len(p) !=3D pinfo->gso_size)
 		return -E2BIG;
=20
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index c93b0cb..69d379a 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4478,6 +4478,7 @@ merge:
 		TCP_SKB_CB(to)->ack_seq =3D TCP_SKB_CB(from)->ack_seq;
 		return true;
 	}
+	/* TODO : handle special case where from->frag_head is true */
 	if (skb_headlen(from) =3D=3D 0 &&
 	    !skb_has_frag_list(to) &&
 	    !skb_has_frag_list(from) &&
