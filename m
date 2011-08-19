From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 02/75] net: convert core to skb paged frag APIs
Date: Fri, 19 Aug 2011 14:26:34 +0100
Message-ID: <1313760467-8598-2-git-send-email-ian.campbell@citrix.com>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Ian Campbell <ian.campbell@citrix.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: "Micha=C5=82 Miros=C5=82aw" <mirq-linux@rere.qmqm.pl>
Cc: netdev@vger.kernel.org
---
 include/linux/skbuff.h |    4 ++--
 net/core/datagram.c    |    8 ++++----
 net/core/dev.c         |   16 +++++++++-------
 net/core/kmap_skb.h    |    2 +-
 net/core/pktgen.c      |    3 +--
 net/core/skbuff.c      |   29 +++++++++++++++--------------
 net/core/sock.c        |   12 +++++-------
 net/core/user_dma.c    |    2 +-
 8 files changed, 38 insertions(+), 38 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 2562764..c015e61 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1895,12 +1895,12 @@ static inline int skb_add_data(struct sk_buff *=
skb,
 }
=20
 static inline int skb_can_coalesce(struct sk_buff *skb, int i,
-				   struct page *page, int off)
+				   const struct page *page, int off)
 {
 	if (i) {
 		struct skb_frag_struct *frag =3D &skb_shinfo(skb)->frags[i - 1];
=20
-		return page =3D=3D frag->page &&
+		return page =3D=3D skb_frag_page(frag) &&
 		       off =3D=3D frag->page_offset + frag->size;
 	}
 	return 0;
diff --git a/net/core/datagram.c b/net/core/datagram.c
index 18ac112..6449bed 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -332,7 +332,7 @@ int skb_copy_datagram_iovec(const struct sk_buff *s=
kb, int offset,
 			int err;
 			u8  *vaddr;
 			skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
-			struct page *page =3D frag->page;
+			struct page *page =3D skb_frag_page(frag);
=20
 			if (copy > len)
 				copy =3D len;
@@ -418,7 +418,7 @@ int skb_copy_datagram_const_iovec(const struct sk_b=
uff *skb, int offset,
 			int err;
 			u8  *vaddr;
 			skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
-			struct page *page =3D frag->page;
+			struct page *page =3D skb_frag_page(frag);
=20
 			if (copy > len)
 				copy =3D len;
@@ -508,7 +508,7 @@ int skb_copy_datagram_from_iovec(struct sk_buff *sk=
b, int offset,
 			int err;
 			u8  *vaddr;
 			skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
-			struct page *page =3D frag->page;
+			struct page *page =3D skb_frag_page(frag);
=20
 			if (copy > len)
 				copy =3D len;
@@ -594,7 +594,7 @@ static int skb_copy_and_csum_datagram(const struct =
sk_buff *skb, int offset,
 			int err =3D 0;
 			u8  *vaddr;
 			skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
-			struct page *page =3D frag->page;
+			struct page *page =3D skb_frag_page(frag);
=20
 			if (copy > len)
 				copy =3D len;
diff --git a/net/core/dev.c b/net/core/dev.c
index 17d67b5..1380325 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1947,9 +1947,11 @@ static int illegal_highdma(struct net_device *de=
v, struct sk_buff *skb)
 #ifdef CONFIG_HIGHMEM
 	int i;
 	if (!(dev->features & NETIF_F_HIGHDMA)) {
-		for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++)
-			if (PageHighMem(skb_shinfo(skb)->frags[i].page))
+		for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
+			skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
+			if (PageHighMem(skb_frag_page(frag)))
 				return 1;
+		}
 	}
=20
 	if (PCI_DMA_BUS_IS_PHYS) {
@@ -1958,7 +1960,8 @@ static int illegal_highdma(struct net_device *dev=
, struct sk_buff *skb)
 		if (!pdev)
 			return 0;
 		for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
-			dma_addr_t addr =3D page_to_phys(skb_shinfo(skb)->frags[i].page);
+			skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
+			dma_addr_t addr =3D page_to_phys(skb_frag_page(frag));
 			if (!pdev->dma_mask || addr + PAGE_SIZE - 1 > *pdev->dma_mask)
 				return 1;
 		}
@@ -3424,7 +3427,7 @@ pull:
 		skb_shinfo(skb)->frags[0].size -=3D grow;
=20
 		if (unlikely(!skb_shinfo(skb)->frags[0].size)) {
-			put_page(skb_shinfo(skb)->frags[0].page);
+			skb_frag_unref(skb, 0);
 			memmove(skb_shinfo(skb)->frags,
 				skb_shinfo(skb)->frags + 1,
 				--skb_shinfo(skb)->nr_frags * sizeof(skb_frag_t));
@@ -3488,10 +3491,9 @@ void skb_gro_reset_offset(struct sk_buff *skb)
 	NAPI_GRO_CB(skb)->frag0_len =3D 0;
=20
 	if (skb->mac_header =3D=3D skb->tail &&
-	    !PageHighMem(skb_shinfo(skb)->frags[0].page)) {
+	    !PageHighMem(skb_frag_page(&skb_shinfo(skb)->frags[0]))) {
 		NAPI_GRO_CB(skb)->frag0 =3D
-			page_address(skb_shinfo(skb)->frags[0].page) +
-			skb_shinfo(skb)->frags[0].page_offset;
+			skb_frag_address(&skb_shinfo(skb)->frags[0]);
 		NAPI_GRO_CB(skb)->frag0_len =3D skb_shinfo(skb)->frags[0].size;
 	}
 }
diff --git a/net/core/kmap_skb.h b/net/core/kmap_skb.h
index 283c2b9..81e1ed7 100644
--- a/net/core/kmap_skb.h
+++ b/net/core/kmap_skb.h
@@ -7,7 +7,7 @@ static inline void *kmap_skb_frag(const skb_frag_t *fra=
g)
=20
 	local_bh_disable();
 #endif
-	return kmap_atomic(frag->page, KM_SKB_DATA_SOFTIRQ);
+	return kmap_atomic(skb_frag_page(frag), KM_SKB_DATA_SOFTIRQ);
 }
=20
 static inline void kunmap_skb_frag(void *vaddr)
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index e35a6fb..796044a 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2602,8 +2602,7 @@ static void pktgen_finalize_skb(struct pktgen_dev=
 *pkt_dev, struct sk_buff *skb,
 				if (!pkt_dev->page)
 					break;
 			}
-			skb_shinfo(skb)->frags[i].page =3D pkt_dev->page;
-			get_page(pkt_dev->page);
+			skb_frag_set_page(skb, i, pkt_dev->page);
 			skb_shinfo(skb)->frags[i].page_offset =3D 0;
 			/*last fragment, fill rest of data*/
 			if (i =3D=3D (frags - 1))
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 27002df..418f3435 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -326,7 +326,7 @@ static void skb_release_data(struct sk_buff *skb)
 		if (skb_shinfo(skb)->nr_frags) {
 			int i;
 			for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++)
-				put_page(skb_shinfo(skb)->frags[i].page);
+				skb_frag_unref(skb, i);
 		}
=20
 		/*
@@ -807,7 +807,7 @@ struct sk_buff *pskb_copy(struct sk_buff *skb, gfp_=
t gfp_mask)
 		}
 		for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
 			skb_shinfo(n)->frags[i] =3D skb_shinfo(skb)->frags[i];
-			get_page(skb_shinfo(n)->frags[i].page);
+			skb_frag_ref(skb, i);
 		}
 		skb_shinfo(n)->nr_frags =3D i;
 	}
@@ -899,7 +899,7 @@ int pskb_expand_head(struct sk_buff *skb, int nhead=
, int ntail,
 			skb_shinfo(skb)->tx_flags &=3D ~SKBTX_DEV_ZEROCOPY;
 		}
 		for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++)
-			get_page(skb_shinfo(skb)->frags[i].page);
+			skb_frag_ref(skb, i);
=20
 		if (skb_has_frag_list(skb))
 			skb_clone_fraglist(skb);
@@ -1179,7 +1179,7 @@ drop_pages:
 		skb_shinfo(skb)->nr_frags =3D i;
=20
 		for (; i < nfrags; i++)
-			put_page(skb_shinfo(skb)->frags[i].page);
+			skb_frag_unref(skb, i);
=20
 		if (skb_has_frag_list(skb))
 			skb_drop_fraglist(skb);
@@ -1348,7 +1348,7 @@ pull_pages:
 	k =3D 0;
 	for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		if (skb_shinfo(skb)->frags[i].size <=3D eat) {
-			put_page(skb_shinfo(skb)->frags[i].page);
+			skb_frag_unref(skb, i);
 			eat -=3D skb_shinfo(skb)->frags[i].size;
 		} else {
 			skb_shinfo(skb)->frags[k] =3D skb_shinfo(skb)->frags[i];
@@ -1607,7 +1607,8 @@ static int __skb_splice_bits(struct sk_buff *skb,=
 struct pipe_inode_info *pipe,
 	for (seg =3D 0; seg < skb_shinfo(skb)->nr_frags; seg++) {
 		const skb_frag_t *f =3D &skb_shinfo(skb)->frags[seg];
=20
-		if (__splice_segment(f->page, f->page_offset, f->size,
+		if (__splice_segment(skb_frag_page(f),
+				     f->page_offset, f->size,
 				     offset, len, skb, spd, 0, sk, pipe))
 			return 1;
 	}
@@ -2152,7 +2153,7 @@ static inline void skb_split_no_header(struct sk_=
buff *skb,
 				 *    where splitting is expensive.
 				 * 2. Split is accurately. We make this.
 				 */
-				get_page(skb_shinfo(skb)->frags[i].page);
+				skb_frag_ref(skb, i);
 				skb_shinfo(skb1)->frags[0].page_offset +=3D len - pos;
 				skb_shinfo(skb1)->frags[0].size -=3D len - pos;
 				skb_shinfo(skb)->frags[i].size	=3D len - pos;
@@ -2227,7 +2228,8 @@ int skb_shift(struct sk_buff *tgt, struct sk_buff=
 *skb, int shiftlen)
 	 * commit all, so that we don't have to undo partial changes
 	 */
 	if (!to ||
-	    !skb_can_coalesce(tgt, to, fragfrom->page, fragfrom->page_offset)=
) {
+	    !skb_can_coalesce(tgt, to, skb_frag_page(fragfrom),
+			      fragfrom->page_offset)) {
 		merge =3D -1;
 	} else {
 		merge =3D to - 1;
@@ -2274,7 +2276,7 @@ int skb_shift(struct sk_buff *tgt, struct sk_buff=
 *skb, int shiftlen)
 			to++;
=20
 		} else {
-			get_page(fragfrom->page);
+			__skb_frag_ref(fragfrom);
 			fragto->page =3D fragfrom->page;
 			fragto->page_offset =3D fragfrom->page_offset;
 			fragto->size =3D todo;
@@ -2296,7 +2298,7 @@ int skb_shift(struct sk_buff *tgt, struct sk_buff=
 *skb, int shiftlen)
 		fragto =3D &skb_shinfo(tgt)->frags[merge];
=20
 		fragto->size +=3D fragfrom->size;
-		put_page(fragfrom->page);
+		__skb_frag_unref(fragfrom);
 	}
=20
 	/* Reposition in the original skb */
@@ -2541,8 +2543,7 @@ int skb_append_datato_frags(struct sock *sk, stru=
ct sk_buff *skb,
 		left =3D PAGE_SIZE - frag->page_offset;
 		copy =3D (length > left)? left : length;
=20
-		ret =3D getfrag(from, (page_address(frag->page) +
-			    frag->page_offset + frag->size),
+		ret =3D getfrag(from, skb_frag_address(frag) + frag->size,
 			    offset, copy, 0, skb);
 		if (ret < 0)
 			return -EFAULT;
@@ -2694,7 +2695,7 @@ struct sk_buff *skb_segment(struct sk_buff *skb, =
u32 features)
=20
 		while (pos < offset + len && i < nfrags) {
 			*frag =3D skb_shinfo(skb)->frags[i];
-			get_page(frag->page);
+			__skb_frag_ref(frag);
 			size =3D frag->size;
=20
 			if (pos < offset) {
@@ -2917,7 +2918,7 @@ __skb_to_sgvec(struct sk_buff *skb, struct scatte=
rlist *sg, int offset, int len)
=20
 			if (copy > len)
 				copy =3D len;
-			sg_set_page(&sg[elt], frag->page, copy,
+			sg_set_page(&sg[elt], skb_frag_page(frag), copy,
 					frag->page_offset+offset-start);
 			elt++;
 			if (!(len -=3D copy))
diff --git a/net/core/sock.c b/net/core/sock.c
index bc745d0..72b8f06 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1533,7 +1533,6 @@ struct sk_buff *sock_alloc_send_pskb(struct sock =
*sk, unsigned long header_len,
 				skb_shinfo(skb)->nr_frags =3D npages;
 				for (i =3D 0; i < npages; i++) {
 					struct page *page;
-					skb_frag_t *frag;
=20
 					page =3D alloc_pages(sk->sk_allocation, 0);
 					if (!page) {
@@ -1543,12 +1542,11 @@ struct sk_buff *sock_alloc_send_pskb(struct soc=
k *sk, unsigned long header_len,
 						goto failure;
 					}
=20
-					frag =3D &skb_shinfo(skb)->frags[i];
-					frag->page =3D page;
-					frag->page_offset =3D 0;
-					frag->size =3D (data_len >=3D PAGE_SIZE ?
-						      PAGE_SIZE :
-						      data_len);
+					__skb_fill_page_desc(skb, i,
+							page, 0,
+							(data_len >=3D PAGE_SIZE ?
+							 PAGE_SIZE :
+							 data_len));
 					data_len -=3D PAGE_SIZE;
 				}
=20
diff --git a/net/core/user_dma.c b/net/core/user_dma.c
index 25d717e..34e9664 100644
--- a/net/core/user_dma.c
+++ b/net/core/user_dma.c
@@ -78,7 +78,7 @@ int dma_skb_copy_datagram_iovec(struct dma_chan *chan=
,
 		copy =3D end - offset;
 		if (copy > 0) {
 			skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
-			struct page *page =3D frag->page;
+			struct page *page =3D skb_frag_page(frag);
=20
 			if (copy > len)
 				copy =3D len;
--=20
1.7.2.5
