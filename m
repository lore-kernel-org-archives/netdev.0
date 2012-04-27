From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 1/4 net-next] net: allow skb->head to be a page fragment
Date: Fri, 27 Apr 2012 12:33:38 +0200
Message-ID: <1335522818.2775.227.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <therbert@google.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:55871 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759804Ab2D0Kdp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2012 06:33:45 -0400
Received: by bkuw12 with SMTP id w12so386317bku.19
        for <netdev@vger.kernel.org>; Fri, 27 Apr 2012 03:33:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

skb->head is currently allocated from kmalloc(). This is convenient but
has the drawback the data cannot be converted to a page fragment if
needed.

We have three spots were it hurts :

1) GRO aggregation

 When a linear skb must be appended to another skb, GRO uses the
frag_list fallback, very inefficient since we keep all struct sk_buff
around. So drivers enabling GRO but delivering linear skbs to network
stack aren't enabling full GRO power.

2) splice(socket -> pipe).

 We must copy the linear part to a page fragment.
 This kind of defeats splice() purpose (zero copy claim)

3) TCP coalescing.

 Recently introduced, this permits to group several contiguous segments
into a single skb. This shortens queue lengths and save kernel memory,
and greatly reduce probabilities of TCP collapses. This coalescing
doesnt work on linear skbs (or we would need to copy data, this would b=
e
too slow)

Given all these issues, the following patch introduces the possibility
of having skb->head be a fragment in itself. We use a new skb flag,
skb->head_frag to carry this information.

build_skb() is changed to accept a frag_size argument. Drivers willing
to provide a page fragment instead of kmalloc() data will set a non zer=
o
value, set to the fragment size.

Then, on situations we need to convert the skb head to a frag in itself=
,
we can check if skb->head_frag is set and avoid the copies or various
fallbacks we have.

This means drivers currently using frags could be updated to avoid the
current skb->head allocation and reduce their memory footprint (aka skb
truesize). (thats 512 or 1024 bytes saved per skb). This also makes
bpf/netfilter faster since the 'first frag' will be part of skb linear
part, no need to copy data.

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
 drivers/net/ethernet/broadcom/bnx2.c            |    2 -
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |    4 +-
 drivers/net/ethernet/broadcom/tg3.c             |    2 -
 include/linux/skbuff.h                          |    5 +-
 net/core/skbuff.c                               |   24 ++++++++++----
 5 files changed, 25 insertions(+), 12 deletions(-)

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
index 0c3e7c7..d481b0a 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -5844,7 +5844,7 @@ static int tg3_rx(struct tg3_napi *tnapi, int bud=
get)
 			pci_unmap_single(tp->pdev, dma_addr, skb_size,
 					 PCI_DMA_FROMDEVICE);
=20
-			skb =3D build_skb(data);
+			skb =3D build_skb(data, 0);
 			if (!skb) {
 				kfree(data);
 				goto drop_it_no_recycle;
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 4a656b5..9d28a22 100644
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
@@ -562,7 +563,7 @@ extern void consume_skb(struct sk_buff *skb);
 extern void	       __kfree_skb(struct sk_buff *skb);
 extern struct sk_buff *__alloc_skb(unsigned int size,
 				   gfp_t priority, int fclone, int node);
-extern struct sk_buff *build_skb(void *data);
+extern struct sk_buff *build_skb(void *data, unsigned int frag_size);
 static inline struct sk_buff *alloc_skb(unsigned int size,
 					gfp_t priority)
 {
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 2342a72..effa75d 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
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
