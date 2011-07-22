From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 09/13] net: add support for per-paged-fragment destructors
Date: Fri, 22 Jul 2011 14:17:29 +0100
Message-ID: <1311340653-19336-9-git-send-email-ian.campbell@citrix.com>
References: <1311340095.12772.57.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ian Campbell <ian.campbell@citrix.com>,
	"David S. Miller" <davem@davemloft.net>,
	"James E.J. Bottomley" <JBottomley@parallels.com>,
	Dimitris Michailidis <dm@chelsio.com>,
	Casey Leedom <leedom@chelsio.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	linux-scsi@vger.kernel.org
To: netdev@vger.kernel.org, linux-nfs@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:23859 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754382Ab1GVNSA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jul 2011 09:18:00 -0400
In-Reply-To: <1311340095.12772.57.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Entities which care about the complete lifecycle of pages which they in=
ject
into the network stack via an skb paged fragment can choose to set this
destructor in order to receive a callback when the stack is really fini=
shed
with a page (including all clones, retransmits, pull-ups etc etc).

This destructor will always be propagated alongside the struct page whe=
n
copying skb_frag_t->page. This is the reason I chose to embed the destr=
uctor in
a "struct { } page" within the skb_frag_t, rather than as a separate fi=
eld,
since it allows existing code which propagates ->frags[N].page to Just
Work(tm).

When the destructor is present the page reference counting is done slig=
htly
differently. No references are held by the network stack on the struct =
page (it
is up to the caller to manage this as necessary) instead the network st=
ack will
track references via the count embedded in the destructor structure. Wh=
en this
reference count reaches zero then the destructor will be called and the=
 caller
can take the necesary steps to release the page (i.e. release the struc=
t page
reference itself).

The intention is that callers can use this callback to delay completion=
 to
_their_ callers until the network stack has completely released the pag=
e, in
order to prevent use-after-free or modification of data pages which are=
 still
in use by the stack.

It is allowable (indeed expected) for a caller to share a single destru=
ctor
instance between multiple pages injected into the stack e.g. a group of=
 pages
included in a single higher level operation might share a destructor wh=
ich is
used to complete that higher level operation.

NB: a small number of drivers use skb_frag_t independently of struct sk=
_buff so
this patch is slightly larger than necessary. I did consider leaving sk=
b_frag_t
alone and defining a new (but similar) structure to be used in the stru=
ct
sk_buff itself. This would also have the advantage of more clearly sepa=
rating
the two uses, which is useful since there are now special reference cou=
nting
accessors for skb_frag_t within a struct sk_buff but not (necessarily) =
for
those used outside of an skb.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: "James E.J. Bottomley" <JBottomley@parallels.com>
Cc: Dimitris Michailidis <dm@chelsio.com>
Cc: Casey Leedom <leedom@chelsio.com>
Cc: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: "Micha=C5=82 Miros=C5=82aw" <mirq-linux@rere.qmqm.pl>
Cc: netdev@vger.kernel.org
Cc: linux-scsi@vger.kernel.org
---
 drivers/net/cxgb4/sge.c       |   14 +++++++-------
 drivers/net/cxgb4vf/sge.c     |   18 +++++++++---------
 drivers/net/mlx4/en_rx.c      |    2 +-
 drivers/scsi/cxgbi/libcxgbi.c |    2 +-
 include/linux/skbuff.h        |   31 ++++++++++++++++++++++++++-----
 net/core/skbuff.c             |   17 +++++++++++++++++
 6 files changed, 61 insertions(+), 23 deletions(-)

diff --git a/drivers/net/cxgb4/sge.c b/drivers/net/cxgb4/sge.c
index f1813b5..3e7c4b3 100644
--- a/drivers/net/cxgb4/sge.c
+++ b/drivers/net/cxgb4/sge.c
@@ -1416,7 +1416,7 @@ static inline void copy_frags(struct sk_buff *skb=
,
 	unsigned int n;
=20
 	/* usually there's just one frag */
-	skb_frag_set_page(skb, 0, gl->frags[0].page);
+	skb_frag_set_page(skb, 0, gl->frags[0].page.p);	/* XXX */
 	ssi->frags[0].page_offset =3D gl->frags[0].page_offset + offset;
 	ssi->frags[0].size =3D gl->frags[0].size - offset;
 	ssi->nr_frags =3D gl->nfrags;
@@ -1425,7 +1425,7 @@ static inline void copy_frags(struct sk_buff *skb=
,
 		memcpy(&ssi->frags[1], &gl->frags[1], n * sizeof(skb_frag_t));
=20
 	/* get a reference to the last page, we don't own it */
-	get_page(gl->frags[n].page);
+	get_page(gl->frags[n].page.p);	/* XXX */
 }
=20
 /**
@@ -1482,7 +1482,7 @@ static void t4_pktgl_free(const struct pkt_gl *gl=
)
 	const skb_frag_t *p;
=20
 	for (p =3D gl->frags, n =3D gl->nfrags - 1; n--; p++)
-		put_page(p->page);
+		put_page(p->page.p); /* XXX */
 }
=20
 /*
@@ -1635,7 +1635,7 @@ static void restore_rx_bufs(const struct pkt_gl *=
si, struct sge_fl *q,
 		else
 			q->cidx--;
 		d =3D &q->sdesc[q->cidx];
-		d->page =3D si->frags[frags].page;
+		d->page =3D si->frags[frags].page.p; /* XXX */
 		d->dma_addr |=3D RX_UNMAPPED_BUF;
 		q->avail++;
 	}
@@ -1717,7 +1717,7 @@ static int process_responses(struct sge_rspq *q, =
int budget)
 			for (frags =3D 0, fp =3D si.frags; ; frags++, fp++) {
 				rsd =3D &rxq->fl.sdesc[rxq->fl.cidx];
 				bufsz =3D get_buf_size(rsd);
-				fp->page =3D rsd->page;
+				fp->page.p =3D rsd->page; /* XXX */
 				fp->page_offset =3D q->offset;
 				fp->size =3D min(bufsz, len);
 				len -=3D fp->size;
@@ -1734,8 +1734,8 @@ static int process_responses(struct sge_rspq *q, =
int budget)
 						get_buf_addr(rsd),
 						fp->size, DMA_FROM_DEVICE);
=20
-			si.va =3D page_address(si.frags[0].page) +
-				si.frags[0].page_offset;
+			si.va =3D page_address(si.frags[0].page.p) +
+				si.frags[0].page_offset; /* XXX */
=20
 			prefetch(si.va);
=20
diff --git a/drivers/net/cxgb4vf/sge.c b/drivers/net/cxgb4vf/sge.c
index f4c4480..0a0dda1 100644
--- a/drivers/net/cxgb4vf/sge.c
+++ b/drivers/net/cxgb4vf/sge.c
@@ -1397,7 +1397,7 @@ struct sk_buff *t4vf_pktgl_to_skb(const struct pk=
t_gl *gl,
 		skb_copy_to_linear_data(skb, gl->va, pull_len);
=20
 		ssi =3D skb_shinfo(skb);
-		skb_frag_set_page(skb, 0, gl->frags[0].page);
+		skb_frag_set_page(skb, 0, gl->frags[0].page.p); /* XXX */
 		ssi->frags[0].page_offset =3D gl->frags[0].page_offset + pull_len;
 		ssi->frags[0].size =3D gl->frags[0].size - pull_len;
 		if (gl->nfrags > 1)
@@ -1410,7 +1410,7 @@ struct sk_buff *t4vf_pktgl_to_skb(const struct pk=
t_gl *gl,
 		skb->truesize +=3D skb->data_len;
=20
 		/* Get a reference for the last page, we don't own it */
-		get_page(gl->frags[gl->nfrags - 1].page);
+		get_page(gl->frags[gl->nfrags - 1].page.p); /* XXX */
 	}
=20
 out:
@@ -1430,7 +1430,7 @@ void t4vf_pktgl_free(const struct pkt_gl *gl)
=20
 	frag =3D gl->nfrags - 1;
 	while (frag--)
-		put_page(gl->frags[frag].page);
+		put_page(gl->frags[frag].page.p); /* XXX */
 }
=20
 /**
@@ -1450,7 +1450,7 @@ static inline void copy_frags(struct sk_buff *skb=
,
 	unsigned int n;
=20
 	/* usually there's just one frag */
-	skb_frag_set_page(skb, 0, gl->frags[0].page);
+	skb_frag_set_page(skb, 0, gl->frags[0].page.p);	/* XXX */
 	si->frags[0].page_offset =3D gl->frags[0].page_offset + offset;
 	si->frags[0].size =3D gl->frags[0].size - offset;
 	si->nr_frags =3D gl->nfrags;
@@ -1460,7 +1460,7 @@ static inline void copy_frags(struct sk_buff *skb=
,
 		memcpy(&si->frags[1], &gl->frags[1], n * sizeof(skb_frag_t));
=20
 	/* get a reference to the last page, we don't own it */
-	get_page(gl->frags[n].page);
+	get_page(gl->frags[n].page.p); /* XXX */
 }
=20
 /**
@@ -1633,7 +1633,7 @@ static void restore_rx_bufs(const struct pkt_gl *=
gl, struct sge_fl *fl,
 		else
 			fl->cidx--;
 		sdesc =3D &fl->sdesc[fl->cidx];
-		sdesc->page =3D gl->frags[frags].page;
+		sdesc->page =3D gl->frags[frags].page.p; /* XXX */
 		sdesc->dma_addr |=3D RX_UNMAPPED_BUF;
 		fl->avail++;
 	}
@@ -1721,7 +1721,7 @@ int process_responses(struct sge_rspq *rspq, int =
budget)
 				BUG_ON(rxq->fl.avail =3D=3D 0);
 				sdesc =3D &rxq->fl.sdesc[rxq->fl.cidx];
 				bufsz =3D get_buf_size(sdesc);
-				fp->page =3D sdesc->page;
+				fp->page.p =3D sdesc->page; /* XXX */
 				fp->page_offset =3D rspq->offset;
 				fp->size =3D min(bufsz, len);
 				len -=3D fp->size;
@@ -1739,8 +1739,8 @@ int process_responses(struct sge_rspq *rspq, int =
budget)
 			dma_sync_single_for_cpu(rspq->adapter->pdev_dev,
 						get_buf_addr(sdesc),
 						fp->size, DMA_FROM_DEVICE);
-			gl.va =3D (page_address(gl.frags[0].page) +
-				 gl.frags[0].page_offset);
+			gl.va =3D (page_address(gl.frags[0].page.p) +
+				 gl.frags[0].page_offset); /* XXX */
 			prefetch(gl.va);
=20
 			/*
diff --git a/drivers/net/mlx4/en_rx.c b/drivers/net/mlx4/en_rx.c
index 21a89e0..c5d01ce 100644
--- a/drivers/net/mlx4/en_rx.c
+++ b/drivers/net/mlx4/en_rx.c
@@ -418,7 +418,7 @@ static int mlx4_en_complete_rx_desc(struct mlx4_en_=
priv *priv,
 			break;
=20
 		/* Save page reference in skb */
-		__skb_frag_set_page(&skb_frags_rx[nr], skb_frags[nr].page);
+		__skb_frag_set_page(&skb_frags_rx[nr], skb_frags[nr].page.p); /* XXX=
 */
 		skb_frags_rx[nr].size =3D skb_frags[nr].size;
 		skb_frags_rx[nr].page_offset =3D skb_frags[nr].page_offset;
 		dma =3D be64_to_cpu(rx_desc->data[nr].addr);
diff --git a/drivers/scsi/cxgbi/libcxgbi.c b/drivers/scsi/cxgbi/libcxgb=
i.c
index 949ee48..8d16a74 100644
--- a/drivers/scsi/cxgbi/libcxgbi.c
+++ b/drivers/scsi/cxgbi/libcxgbi.c
@@ -1823,7 +1823,7 @@ static int sgl_read_to_frags(struct scatterlist *=
sg, unsigned int sgoffset,
 				return -EINVAL;
 			}
=20
-			frags[i].page =3D page;
+			frags[i].page.p =3D page;
 			frags[i].page_offset =3D sg->offset + sgoffset;
 			frags[i].size =3D copy;
 			i++;
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index bc6bd24..9818fe2 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -135,8 +135,17 @@ struct sk_buff;
=20
 typedef struct skb_frag_struct skb_frag_t;
=20
+struct skb_frag_destructor {
+	atomic_t ref;
+	int (*destroy)(void *data);
+	void *data;
+};
+
 struct skb_frag_struct {
-	struct page *page;
+	struct {
+		struct page *p;
+		struct skb_frag_destructor *destructor;
+	} page;
 #if (BITS_PER_LONG > 32) || (PAGE_SIZE >=3D 65536)
 	__u32 page_offset;
 	__u32 size;
@@ -1129,7 +1138,8 @@ static inline void __skb_fill_page_desc(struct sk=
_buff *skb, int i,
 {
 	skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
=20
-	frag->page		  =3D page;
+	frag->page.p		  =3D page;
+	frag->page.destructor     =3D NULL;
 	frag->page_offset	  =3D off;
 	frag->size		  =3D size;
 }
@@ -1648,7 +1658,7 @@ static inline void netdev_free_page(struct net_de=
vice *dev, struct page *page)
  */
 static inline struct page *__skb_frag_page(const skb_frag_t *frag)
 {
-	return frag->page;
+	return frag->page.p;
 }
=20
 /**
@@ -1659,9 +1669,12 @@ static inline struct page *__skb_frag_page(const=
 skb_frag_t *frag)
  */
 static inline const struct page *skb_frag_page(const skb_frag_t *frag)
 {
-	return frag->page;
+	return frag->page.p;
 }
=20
+extern void skb_frag_destructor_ref(struct skb_frag_destructor *destro=
y);
+extern void skb_frag_destructor_unref(struct skb_frag_destructor *dest=
roy);
+
 /**
  * __skb_frag_ref - take an addition reference on a paged fragment.
  * @frag: the paged fragment
@@ -1670,6 +1683,10 @@ static inline const struct page *skb_frag_page(c=
onst skb_frag_t *frag)
  */
 static inline void __skb_frag_ref(skb_frag_t *frag)
 {
+	if (unlikely(frag->page.destructor)) {
+		skb_frag_destructor_ref(frag->page.destructor);
+		return;
+	}
 	get_page(__skb_frag_page(frag));
 }
=20
@@ -1693,6 +1710,10 @@ static inline void skb_frag_ref(struct sk_buff *=
skb, int f)
  */
 static inline void __skb_frag_unref(skb_frag_t *frag)
 {
+	if (unlikely(frag->page.destructor)) {
+		skb_frag_destructor_unref(frag->page.destructor);
+		return;
+	}
 	put_page(__skb_frag_page(frag));
 }
=20
@@ -1745,7 +1766,7 @@ static inline void *skb_frag_address_safe(const s=
kb_frag_t *frag)
  */
 static inline void __skb_frag_set_page(skb_frag_t *frag, struct page *=
page)
 {
-	frag->page =3D page;
+	frag->page.p =3D page;
 	__skb_frag_ref(frag);
 }
=20
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 2133600..bdc6f6e 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -292,6 +292,23 @@ struct sk_buff *dev_alloc_skb(unsigned int length)
 }
 EXPORT_SYMBOL(dev_alloc_skb);
=20
+void skb_frag_destructor_ref(struct skb_frag_destructor *destroy)
+{
+	BUG_ON(destroy =3D=3D NULL);
+	atomic_inc(&destroy->ref);
+}
+EXPORT_SYMBOL(skb_frag_destructor_ref);
+
+void skb_frag_destructor_unref(struct skb_frag_destructor *destroy)
+{
+	if (destroy =3D=3D NULL)
+		return;
+
+	if (atomic_dec_and_test(&destroy->ref))
+		destroy->destroy(destroy->data);
+}
+EXPORT_SYMBOL(skb_frag_destructor_unref);
+
 static void skb_drop_list(struct sk_buff **listp)
 {
 	struct sk_buff *list =3D *listp;
--=20
1.7.2.5

