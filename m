From: Alex Bligh <alex@alex.org.uk>
Subject: [RFC] [PATCH 5/7] net: move skb frag kmap functions to skbuff.h
Date: Fri, 25 Jan 2013 14:27:05 +0000
Message-ID: <1359124027-1170-6-git-send-email-alex@alex.org.uk>
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
Received: from mail.avalus.com ([89.16.176.221]:50398 "EHLO mail.avalus.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751536Ab3AYOhz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jan 2013 09:37:55 -0500
In-Reply-To: <1359124027-1170-1-git-send-email-alex@alex.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ian Campbell <ian.campbell@>

The usage is open-coded in drivers/scsi/fcoe/fcoe.c and net/appletalk/d=
dp.c
uses an out-of-directory local include of "../core/kmap_skb.h".

Rename functions k(un)map_skb_frag to skb_frag_k(un)map_atomic to avoid
confusion with shortly to be introduced skb_frag_k(un)map.

Signed-off-by: Ian Campbell <ian.campbell <at> citrix.com>
Cc: Robert Love <robert.w.love <at> intel.com>
Cc: "James E.J. Bottomley" <JBottomley <at> parallels.com>
Cc: Arnaldo Carvalho de Melo <acme <at> ghostprotocols.net>
Cc: "David S. Miller" <davem <at> davemloft.net>
Cc: Eric Dumazet <eric.dumazet <at> gmail.com>
Cc: "Micha=C5=82 Miros=C5=82aw" <mirq-linux <at> rere.qmqm.pl>
Cc: Tom Herbert <therbert <at> google.com>
Cc: devel <at> open-fcoe.org
Cc: linux-scsi <at> vger.kernel.org
Cc: linux-kernel <at> vger.kernel.org
Cc: netdev <at> vger.kernel.org
Signed-off-by: Alex Bligh <alex@alex.org.uk>
---
 drivers/scsi/fcoe/fcoe.c |    7 +++----
 include/linux/skbuff.h   |   19 +++++++++++++++++++
 net/appletalk/ddp.c      |    5 ++---
 net/core/kmap_skb.h      |   19 -------------------
 net/core/skbuff.c        |   35 +++++++++++++++++------------------
 5 files changed, 41 insertions(+), 44 deletions(-)

diff --git a/drivers/scsi/fcoe/fcoe.c b/drivers/scsi/fcoe/fcoe.c
index 8d67467..70ab372 100644
--- a/drivers/scsi/fcoe/fcoe.c
+++ b/drivers/scsi/fcoe/fcoe.c
@@ -1458,6 +1458,7 @@ int fcoe_xmit(struct fc_lport *lport, struct fc_f=
rame *fp)
 	struct ethhdr *eh;
 	struct fcoe_crc_eof *cp;
 	struct sk_buff *skb;
+	skb_frag_t *frag;
 	struct fcoe_dev_stats *stats;
 	struct fc_frame_header *fh;
 	unsigned int hlen;		/* header length implies the version */
@@ -1504,14 +1505,12 @@ int fcoe_xmit(struct fc_lport *lport, struct fc=
_frame *fp)
=20
 	/* copy port crc and eof to the skb buff */
 	if (skb_is_nonlinear(skb)) {
-		skb_frag_t *frag;
 		if (fcoe_alloc_paged_crc_eof(skb, tlen)) {
 			kfree_skb(skb);
 			return -ENOMEM;
 		}
 		frag =3D &skb_shinfo(skb)->frags[skb_shinfo(skb)->nr_frags - 1];
-		cp =3D kmap_atomic(skb_frag_page(frag), KM_SKB_DATA_SOFTIRQ)
-			+ frag->page_offset;
+		cp =3D skb_frag_kmap_atomic(frag) + frag->page_offset;
 	} else {
 		cp =3D (struct fcoe_crc_eof *)skb_put(skb, tlen);
 	}
@@ -1521,7 +1520,7 @@ int fcoe_xmit(struct fc_lport *lport, struct fc_f=
rame *fp)
 	cp->fcoe_crc32 =3D cpu_to_le32(~crc);
=20
 	if (skb_is_nonlinear(skb)) {
-		kunmap_atomic(cp, KM_SKB_DATA_SOFTIRQ);
+		skb_frag_kunmap_atomic(frag);
 		cp =3D NULL;
 	}
=20
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 8a8eecd..84a54d6 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -29,6 +29,7 @@
 #include <linux/rcupdate.h>
 #include <linux/dmaengine.h>
 #include <linux/hrtimer.h>
+#include <linux/highmem.h>
 #include <linux/dma-mapping.h>
=20
 /* Don't change this without changing skb_csum_unnecessary! */
@@ -1848,6 +1849,24 @@ static inline void skb_frag_set_page(struct sk_b=
uff *skb, int f,
 	__skb_frag_set_page(&skb_shinfo(skb)->frags[f], page);
 }
=20
+static inline void *skb_frag_kmap_atomic(const skb_frag_t *frag)
+{
+#ifdef CONFIG_HIGHMEM
+	BUG_ON(in_irq());
+
+	local_bh_disable();
+#endif
+	return kmap_atomic(skb_frag_page(frag), KM_SKB_DATA_SOFTIRQ);
+}
+
+static inline void skb_frag_kunmap_atomic(void *vaddr)
+{
+	kunmap_atomic(vaddr, KM_SKB_DATA_SOFTIRQ);
+#ifdef CONFIG_HIGHMEM
+	local_bh_enable();
+#endif
+}
+
 /**
  * skb_frag_dma_map - maps a paged fragment via the DMA API
  * @dev: the device to map the fragment to
diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index bfa9ab9..ecc6f63 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -63,7 +63,6 @@
 #include <net/tcp_states.h>
 #include <net/route.h>
 #include <linux/atalk.h>
-#include "../core/kmap_skb.h"
=20
 struct datalink_proto *ddp_dl, *aarp_dl;
 static const struct proto_ops atalk_dgram_ops;
@@ -960,10 +959,10 @@ static unsigned long atalk_sum_skb(const struct s=
k_buff *skb, int offset,
=20
 			if (copy > len)
 				copy =3D len;
-			vaddr =3D kmap_skb_frag(frag);
+			vaddr =3D skb_frag_kmap_atomic(frag);
 			sum =3D atalk_sum_partial(vaddr + frag->page_offset +
 						  offset - start, copy, sum);
-			kunmap_skb_frag(vaddr);
+			skb_frag_kunmap_atomic(vaddr);
=20
 			if (!(len -=3D copy))
 				return sum;
diff --git a/net/core/kmap_skb.h b/net/core/kmap_skb.h
deleted file mode 100644
index 81e1ed7..0000000
--- a/net/core/kmap_skb.h
+++ /dev/null
@@ -1,19 +0,0 @@
-#include <linux/highmem.h>
-
-static inline void *kmap_skb_frag(const skb_frag_t *frag)
-{
-#ifdef CONFIG_HIGHMEM
-	BUG_ON(in_irq());
-
-	local_bh_disable();
-#endif
-	return kmap_atomic(skb_frag_page(frag), KM_SKB_DATA_SOFTIRQ);
-}
-
-static inline void kunmap_skb_frag(void *vaddr)
-{
-	kunmap_atomic(vaddr, KM_SKB_DATA_SOFTIRQ);
-#ifdef CONFIG_HIGHMEM
-	local_bh_enable();
-#endif
-}
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 425cd5a..047f38f 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -69,8 +69,6 @@
 #include <asm/system.h>
 #include <trace/events/skb.h>
=20
-#include "kmap_skb.h"
-
 static struct kmem_cache *skbuff_head_cache __read_mostly;
 static struct kmem_cache *skbuff_fclone_cache __read_mostly;
=20
@@ -676,10 +674,10 @@ int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp=
_mask)
 			}
 			return -ENOMEM;
 		}
-		vaddr =3D kmap_skb_frag(&skb_shinfo(skb)->frags[i]);
+		vaddr =3D skb_frag_kmap_atomic(&skb_shinfo(skb)->frags[i]);
 		memcpy(page_address(page),
 		       vaddr + f->page_offset, skb_frag_size(f));
-		kunmap_skb_frag(vaddr);
+		skb_frag_kunmap_atomic(vaddr);
 		page->private =3D (unsigned long)head;
 		head =3D page;
 	}
@@ -1459,15 +1457,16 @@ int skb_copy_bits(const struct sk_buff *skb, in=
t offset, void *to, int len)
 		end =3D start + skb_frag_size(&skb_shinfo(skb)->frags[i]);
 		if ((copy =3D end - offset) > 0) {
 			u8 *vaddr;
+			skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
=20
 			if (copy > len)
 				copy =3D len;
=20
-			vaddr =3D kmap_skb_frag(&skb_shinfo(skb)->frags[i]);
+			vaddr =3D skb_frag_kmap_atomic(frag);
 			memcpy(to,
-			       vaddr + skb_shinfo(skb)->frags[i].page_offset+
-			       offset - start, copy);
-			kunmap_skb_frag(vaddr);
+			       vaddr + frag->page_offset + offset - start,
+			       copy);
+			skb_frag_kunmap_atomic(vaddr);
=20
 			if ((len -=3D copy) =3D=3D 0)
 				return 0;
@@ -1772,10 +1771,10 @@ int skb_store_bits(struct sk_buff *skb, int off=
set, const void *from, int len)
 			if (copy > len)
 				copy =3D len;
=20
-			vaddr =3D kmap_skb_frag(frag);
+			vaddr =3D skb_frag_kmap_atomic(frag);
 			memcpy(vaddr + frag->page_offset + offset - start,
 			       from, copy);
-			kunmap_skb_frag(vaddr);
+			skb_frag_kunmap_atomic(vaddr);
=20
 			if ((len -=3D copy) =3D=3D 0)
 				return 0;
@@ -1846,10 +1845,10 @@ __wsum skb_checksum(const struct sk_buff *skb, =
int offset,
=20
 			if (copy > len)
 				copy =3D len;
-			vaddr =3D kmap_skb_frag(frag);
+			vaddr =3D skb_frag_kmap_atomic(frag);
 			csum2 =3D csum_partial(vaddr + frag->page_offset +
 					     offset - start, copy, 0);
-			kunmap_skb_frag(vaddr);
+			skb_frag_kunmap_atomic(vaddr);
 			csum =3D csum_block_add(csum, csum2, pos);
 			if (!(len -=3D copy))
 				return csum;
@@ -1921,12 +1920,12 @@ __wsum skb_copy_and_csum_bits(const struct sk_b=
uff *skb, int offset,
=20
 			if (copy > len)
 				copy =3D len;
-			vaddr =3D kmap_skb_frag(frag);
+			vaddr =3D skb_frag_kmap_atomic(frag);
 			csum2 =3D csum_partial_copy_nocheck(vaddr +
 							  frag->page_offset +
 							  offset - start, to,
 							  copy, 0);
-			kunmap_skb_frag(vaddr);
+			skb_frag_kunmap_atomic(vaddr);
 			csum =3D csum_block_add(csum, csum2, pos);
 			if (!(len -=3D copy))
 				return csum;
@@ -2447,7 +2446,7 @@ next_skb:
=20
 		if (abs_offset < block_limit) {
 			if (!st->frag_data)
-				st->frag_data =3D kmap_skb_frag(frag);
+				st->frag_data =3D skb_frag_kmap_atomic(frag);
=20
 			*data =3D (u8 *) st->frag_data + frag->page_offset +
 				(abs_offset - st->stepped_offset);
@@ -2456,7 +2455,7 @@ next_skb:
 		}
=20
 		if (st->frag_data) {
-			kunmap_skb_frag(st->frag_data);
+			skb_frag_kunmap_atomic(st->frag_data);
 			st->frag_data =3D NULL;
 		}
=20
@@ -2465,7 +2464,7 @@ next_skb:
 	}
=20
 	if (st->frag_data) {
-		kunmap_skb_frag(st->frag_data);
+		skb_frag_kunmap_atomic(st->frag_data);
 		st->frag_data =3D NULL;
 	}
=20
@@ -2493,7 +2492,7 @@ EXPORT_SYMBOL(skb_seq_read);
 void skb_abort_seq_read(struct skb_seq_state *st)
 {
 	if (st->frag_data)
-		kunmap_skb_frag(st->frag_data);
+		skb_frag_kunmap_atomic(st->frag_data);
 }
 EXPORT_SYMBOL(skb_abort_seq_read);
=20
--=20
1.7.9.5
