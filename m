From: Alex Bligh <alex@alex.org.uk>
Subject: [RFC] [PATCH 7/7] net: return a *const* struct page from skb_frag_page.
Date: Fri, 25 Jan 2013 14:27:07 +0000
Message-ID: <1359124027-1170-8-git-send-email-alex@alex.org.uk>
References: <1359124027-1170-1-git-send-email-alex@alex.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stefano Stabellini <stefano.stabellini@eu.citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Alex Bligh <alex@alex.org.uk>,
	"Trond Myklebust" <Trond.Myklebust@netapp.com>,
	Mel Gorman <mgorman@suse.de>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.avalus.com ([89.16.176.221]:54422 "EHLO mail.avalus.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751837Ab3AYOhz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jan 2013 09:37:55 -0500
In-Reply-To: <1359124027-1170-1-git-send-email-alex@alex.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Mel Gorman <mgorman@suse.de>

This attempts to catch bare uses of get/put_page (which take a non-cons=
t struct
page) on skb paged fragments.

Add __skb_frag_page for those callers which really need a non-const ref=
erence
to the page.

Signed-off-by: Ian Campbell <ian.campbell <at> citrix.com>
Cc: "David S. Miller" <davem <at> davemloft.net>
Cc: Eric Dumazet <eric.dumazet <at> gmail.com>
Cc: "Micha=C5=82 Miros=C5=82aw" <mirq-linux <at> rere.qmqm.pl>
Cc: netdev <at> vger.kernel.org
Signed-off-by: Alex Bligh <alex@alex.org.uk>
---
 drivers/infiniband/ulp/ipoib/ipoib_cm.c       |    4 ++--
 drivers/infiniband/ulp/ipoib/ipoib_ib.c       |    2 +-
 drivers/net/ethernet/broadcom/bnx2.c          |    2 +-
 drivers/net/ethernet/intel/e1000/e1000_main.c |    2 +-
 drivers/net/ethernet/jme.c                    |    2 +-
 drivers/net/ethernet/sun/cassini.c            |    2 +-
 drivers/net/ethernet/sun/niu.c                |    2 +-
 drivers/net/xen-netback/netback.c             |    2 +-
 drivers/net/xen-netfront.c                    |    4 ++--
 drivers/scsi/bnx2fc/bnx2fc_fcoe.c             |    2 +-
 drivers/scsi/cxgbi/libcxgbi.c                 |    2 +-
 drivers/scsi/fcoe/fcoe_transport.c            |    2 +-
 include/linux/skbuff.h                        |   30 +++++++++++++++++=
--------
 net/core/skbuff.c                             |    6 +++--
 net/core/user_dma.c                           |    2 +-
 net/ipv4/tcp.c                                |    2 +-
 16 files changed, 41 insertions(+), 27 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_cm.c b/drivers/infiniba=
nd/ulp/ipoib/ipoib_cm.c
index 014504d..2373cb89 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_cm.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_cm.c
@@ -538,8 +538,8 @@ static void skb_put_frags(struct sk_buff *skb, unsi=
gned int hdr_space,
=20
 		if (length =3D=3D 0) {
 			/* don't need this page */
-			skb_fill_page_desc(toskb, i, skb_frag_page(frag),
-					   0, PAGE_SIZE);
+			skb_fill_page_desc(toskb, i, __skb_frag_page(frag),
+					   0, PAGE_SIZE);/* XXX */
 			--skb_shinfo(skb)->nr_frags;
 		} else {
 			size =3D min(length, (unsigned) PAGE_SIZE);
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_ib.c b/drivers/infiniba=
nd/ulp/ipoib/ipoib_ib.c
index 4115be5..26e4bd7 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_ib.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
@@ -328,7 +328,7 @@ static int ipoib_dma_map_tx(struct ib_device *ca,
 	for (i =3D 0; i < skb_shinfo(skb)->nr_frags; ++i) {
 		const skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
 		mapping[i + off] =3D ib_dma_map_page(ca,
-						 skb_frag_page(frag),
+						 __skb_frag_page(frag),
 						 frag->page_offset, skb_frag_size(frag),
 						 DMA_TO_DEVICE);
 		if (unlikely(ib_dma_mapping_error(ca, mapping[i + off])))
diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/etherne=
t/broadcom/bnx2.c
index 965c723..2927700 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -2930,7 +2930,7 @@ bnx2_reuse_rx_skb_pages(struct bnx2 *bp, struct b=
nx2_rx_ring_info *rxr,
=20
 		shinfo =3D skb_shinfo(skb);
 		shinfo->nr_frags--;
-		page =3D skb_frag_page(&shinfo->frags[shinfo->nr_frags]);
+		page =3D __skb_frag_page(&shinfo->frags[shinfo->nr_frags]);
 		__skb_frag_set_page(&shinfo->frags[shinfo->nr_frags], NULL);
=20
 		cons_rx_pg->page =3D page;
diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/ne=
t/ethernet/intel/e1000/e1000_main.c
index cf480b5..c1d6f18 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -2916,7 +2916,7 @@ static int e1000_tx_map(struct e1000_adapter *ada=
pter,
 			 * Avoid terminating buffers within evenly-aligned
 			 * dwords. */
 			bufend =3D (unsigned long)
-				page_to_phys(skb_frag_page(frag));
+				page_to_phys(__skb_frag_page(frag));
 			bufend +=3D offset + size - 1;
 			if (unlikely(adapter->pcix_82544 &&
 				     !(bufend & 4) &&
diff --git a/drivers/net/ethernet/jme.c b/drivers/net/ethernet/jme.c
index 76b8457..833b322 100644
--- a/drivers/net/ethernet/jme.c
+++ b/drivers/net/ethernet/jme.c
@@ -2036,7 +2036,7 @@ jme_map_tx_skb(struct jme_adapter *jme, struct sk=
_buff *skb, int idx)
 		ctxbi =3D txbi + ((idx + i + 2) & (mask));
=20
 		jme_fill_tx_map(jme->pdev, ctxdesc, ctxbi,
-				skb_frag_page(frag),
+				__skb_frag_page(frag),
 				frag->page_offset, skb_frag_size(frag), hidma);
 	}
=20
diff --git a/drivers/net/ethernet/sun/cassini.c b/drivers/net/ethernet/=
sun/cassini.c
index fd40988..61f6e93 100644
--- a/drivers/net/ethernet/sun/cassini.c
+++ b/drivers/net/ethernet/sun/cassini.c
@@ -2841,7 +2841,7 @@ static inline int cas_xmit_tx_ringN(struct cas *c=
p, int ring,
 				      ctrl, 0);
 			entry =3D TX_DESC_NEXT(ring, entry);
=20
-			addr =3D cas_page_map(skb_frag_page(fragp));
+			addr =3D cas_page_map(__skb_frag_page(fragp));
 			memcpy(tx_tiny_buf(cp, ring, entry),
 			       addr + fragp->page_offset + len - tabort,
 			       tabort);
diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/=
niu.c
index 73c7081..85fe5c2 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -6730,7 +6730,7 @@ static netdev_tx_t niu_start_xmit(struct sk_buff =
*skb,
 		const skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
=20
 		len =3D skb_frag_size(frag);
-		mapping =3D np->ops->map_page(np->device, skb_frag_page(frag),
+		mapping =3D np->ops->map_page(np->device, __skb_frag_page(frag),
 					    frag->page_offset, len,
 					    DMA_TO_DEVICE);
=20
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netbac=
k/netback.c
index 15e332d..43ff39b 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -525,7 +525,7 @@ static int netbk_gop_skb(struct sk_buff *skb,
=20
 	for (i =3D 0; i < nr_frags; i++) {
 		netbk_gop_frag_copy(vif, skb, npo,
-				    skb_frag_page(&skb_shinfo(skb)->frags[i]),
+				    __skb_frag_page(&skb_shinfo(skb)->frags[i]),
 				    skb_frag_size(&skb_shinfo(skb)->frags[i]),
 				    skb_shinfo(skb)->frags[i].page_offset,
 				    &head);
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 226faab..6d3d36b 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -770,7 +770,7 @@ static RING_IDX xennet_fill_frags(struct netfront_i=
nfo *np,
 		skb_frag_t *nfrag =3D &skb_shinfo(nskb)->frags[0];
=20
 		__skb_fill_page_desc(skb, nr_frags,
-				     skb_frag_page(nfrag),
+				     __skb_frag_page(nfrag),
 				     rx->offset, rx->status);
=20
 		skb->data_len +=3D rx->status;
@@ -954,7 +954,7 @@ err:
 		}
=20
 		NETFRONT_SKB_CB(skb)->page =3D
-			skb_frag_page(&skb_shinfo(skb)->frags[0]);
+			__skb_frag_page(&skb_shinfo(skb)->frags[0]);
 		NETFRONT_SKB_CB(skb)->offset =3D rx->offset;
=20
 		len =3D rx->status;
diff --git a/drivers/scsi/bnx2fc/bnx2fc_fcoe.c b/drivers/scsi/bnx2fc/bn=
x2fc_fcoe.c
index 8c6156a..cd45c0f 100644
--- a/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
+++ b/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
@@ -322,7 +322,7 @@ static int bnx2fc_xmit(struct fc_lport *lport, stru=
ct fc_frame *fp)
 			return -ENOMEM;
 		}
 		frag =3D &skb_shinfo(skb)->frags[skb_shinfo(skb)->nr_frags - 1];
-		cp =3D kmap_atomic(skb_frag_page(frag), KM_SKB_DATA_SOFTIRQ)
+		cp =3D kmap_atomic(__skb_frag_page(frag), KM_SKB_DATA_SOFTIRQ)
 				+ frag->page_offset;
 	} else {
 		cp =3D (struct fcoe_crc_eof *)skb_put(skb, tlen);
diff --git a/drivers/scsi/cxgbi/libcxgbi.c b/drivers/scsi/cxgbi/libcxgb=
i.c
index c10f74a..eba623a 100644
--- a/drivers/scsi/cxgbi/libcxgbi.c
+++ b/drivers/scsi/cxgbi/libcxgbi.c
@@ -1949,7 +1949,7 @@ int cxgbi_conn_init_pdu(struct iscsi_task *task, =
unsigned int offset,
=20
 			/* data fits in the skb's headroom */
 			for (i =3D 0; i < tdata->nr_frags; i++, frag++) {
-				char *src =3D kmap_atomic(frag->page,
+				char *src =3D kmap_atomic(__skb_frag_page(frag),
 							KM_SOFTIRQ0);
=20
 				memcpy(dst, src+frag->offset, frag->size);
diff --git a/drivers/scsi/fcoe/fcoe_transport.c b/drivers/scsi/fcoe/fco=
e_transport.c
index bd97b22..3cc35f3 100644
--- a/drivers/scsi/fcoe/fcoe_transport.c
+++ b/drivers/scsi/fcoe/fcoe_transport.c
@@ -210,7 +210,7 @@ u32 fcoe_fc_crc(struct fc_frame *fp)
 		while (len > 0) {
 			clen =3D min(len, PAGE_SIZE - (off & ~PAGE_MASK));
 			data =3D kmap_atomic(
-				skb_frag_page(frag) + (off >> PAGE_SHIFT),
+				__skb_frag_page(frag) + (off >> PAGE_SHIFT),
 				KM_SKB_DATA_SOFTIRQ);
 			crc =3D crc32(crc, data + (off & ~PAGE_MASK), clen);
 			kunmap_atomic(data, KM_SKB_DATA_SOFTIRQ);
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 698e4c1..4adf576 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1728,12 +1728,24 @@ static inline void netdev_free_page(struct net_=
device *dev, struct page *page)
 }
=20
 /**
- * skb_frag_page - retrieve the page refered to by a paged fragment
+ * __skb_frag_page - retrieve the page refered to by a paged fragment
  * @frag: the paged fragment
  *
- * Returns the &struct page associated with @frag.
+ * Returns the &struct page associated with @frag. Where possible you
+ * should use skb_frag_page() which returns a const &struct page.
  */
-static inline struct page *skb_frag_page(const skb_frag_t *frag)
+static inline struct page *__skb_frag_page(const skb_frag_t *frag)
+{
+	return frag->page.p;
+}
+
+/**
+ * __skb_frag_page - retrieve the page refered to by a paged fragment
+ * @frag: the paged fragment
+ *
+ * Returns the &struct page associated with @frag as a const.
+ */
+static inline const struct page *skb_frag_page(const skb_frag_t *frag)
 {
 	return frag->page.p;
 }
@@ -1753,7 +1765,7 @@ static inline void __skb_frag_ref(skb_frag_t *fra=
g)
 		skb_frag_destructor_ref(frag->page.destructor);
 		return;
 	}
-	get_page(skb_frag_page(frag));
+	get_page(__skb_frag_page(frag));
 }
=20
 /**
@@ -1780,7 +1792,7 @@ static inline void __skb_frag_unref(skb_frag_t *f=
rag)
 		skb_frag_destructor_unref(frag->page.destructor);
 		return;
 	}
-	put_page(skb_frag_page(frag));
+	put_page(__skb_frag_page(frag));
 }
=20
 /**
@@ -1856,7 +1868,7 @@ static inline void *skb_frag_kmap_atomic(const sk=
b_frag_t *frag)
=20
 	local_bh_disable();
 #endif
-	return kmap_atomic(skb_frag_page(frag), KM_SKB_DATA_SOFTIRQ);
+	return kmap_atomic(__skb_frag_page(frag), KM_SKB_DATA_SOFTIRQ);
 }
=20
 static inline void skb_frag_kunmap_atomic(void *vaddr)
@@ -1875,7 +1887,7 @@ static inline void skb_frag_kunmap_atomic(void *v=
addr)
  */
 static inline void *skb_frag_kmap(const skb_frag_t *frag)
 {
-	return kmap(skb_frag_page(frag));
+	return kmap(__skb_frag_page(frag));
 }
=20
 /**
@@ -1886,7 +1898,7 @@ static inline void *skb_frag_kmap(const skb_frag_=
t *frag)
  */
 static inline void skb_frag_kunmap(const skb_frag_t *frag)
 {
-	kunmap(skb_frag_page(frag));
+	kunmap(__skb_frag_page(frag));
 }
=20
 /**
@@ -1905,7 +1917,7 @@ static inline dma_addr_t skb_frag_dma_map(struct =
device *dev,
 					  size_t offset, size_t size,
 					  enum dma_data_direction dir)
 {
-	return dma_map_page(dev, skb_frag_page(frag),
+	return dma_map_page(dev, __skb_frag_page(frag),
 			    frag->page_offset + offset, size, dir);
 }
=20
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 047f38f..5f20a48 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1653,7 +1653,8 @@ static int __skb_splice_bits(struct sk_buff *skb,=
 struct pipe_inode_info *pipe,
 	for (seg =3D 0; seg < skb_shinfo(skb)->nr_frags; seg++) {
 		const skb_frag_t *f =3D &skb_shinfo(skb)->frags[seg];
=20
-		if (__splice_segment(skb_frag_page(f),
+		/* XXX */
+		if (__splice_segment(__skb_frag_page(f),
 				     f->page_offset, skb_frag_size(f),
 				     offset, len, skb, spd, 0, sk, pipe))
 			return 1;
@@ -2965,7 +2966,8 @@ __skb_to_sgvec(struct sk_buff *skb, struct scatte=
rlist *sg, int offset, int len)
=20
 			if (copy > len)
 				copy =3D len;
-			sg_set_page(&sg[elt], skb_frag_page(frag), copy,
+			/* XXX */
+			sg_set_page(&sg[elt], __skb_frag_page(frag), copy,
 					frag->page_offset+offset-start);
 			elt++;
 			if (!(len -=3D copy))
diff --git a/net/core/user_dma.c b/net/core/user_dma.c
index 1b5fefd..1c51151 100644
--- a/net/core/user_dma.c
+++ b/net/core/user_dma.c
@@ -79,7 +79,7 @@ int dma_skb_copy_datagram_iovec(struct dma_chan *chan=
,
 		end =3D start + skb_frag_size(frag);
 		copy =3D end - offset;
 		if (copy > 0) {
-			struct page *page =3D skb_frag_page(frag);
+			struct page *page =3D __skb_frag_page(frag); /* XXX */
=20
 			if (copy > len)
 				copy =3D len;
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 56ef323..28afcf7 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3037,7 +3037,7 @@ int tcp_md5_hash_skb_data(struct tcp_md5sig_pool =
*hp,
=20
 	for (i =3D 0; i < shi->nr_frags; ++i) {
 		const struct skb_frag_struct *f =3D &shi->frags[i];
-		struct page *page =3D skb_frag_page(f);
+		struct page *page =3D __skb_frag_page(f); /* XXX */
 		sg_set_page(&sg, page, skb_frag_size(f), f->page_offset);
 		if (crypto_hash_update(desc, &sg, skb_frag_size(f)))
 			return 1;
--=20
1.7.9.5
