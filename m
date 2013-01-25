From: Alex Bligh <alex@alex.org.uk>
Subject: [RFC] [PATCH 6/7] net: add skb_frag_k(un)map convenience functions.
Date: Fri, 25 Jan 2013 14:27:06 +0000
Message-ID: <1359124027-1170-7-git-send-email-alex@alex.org.uk>
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
Received: from mail.avalus.com ([89.16.176.221]:59185 "EHLO mail.avalus.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751138Ab3AYOhz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jan 2013 09:37:55 -0500
In-Reply-To: <1359124027-1170-1-git-send-email-alex@alex.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ian Campbell <ian.campbell at>

Signed-off-by: Ian Campbell <ian.campbell <at> citrix.com>
Cc: "David S. Miller" <davem <at> davemloft.net>
Cc: Eric Dumazet <eric.dumazet <at> gmail.com>
Cc: "Micha=C5=82 Miros=C5=82aw" <mirq-linux <at> rere.qmqm.pl>
Cc: Tom Herbert <therbert <at> google.com>
Cc: Neil Horman <nhorman <at> tuxdriver.com>
Cc: Koki Sanagi <sanagi.koki <at> jp.fujitsu.com>
Cc: linux-kernel <at> vger.kernel.org
Cc: netdev <at> vger.kernel.org
Signed-off-by: Alex Bligh <alex@alex.org.uk>
---
 include/linux/skbuff.h |   22 ++++++++++++++++++++++
 net/core/datagram.c    |   20 ++++++++------------
 2 files changed, 30 insertions(+), 12 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 84a54d6..698e4c1 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1868,6 +1868,28 @@ static inline void skb_frag_kunmap_atomic(void *=
vaddr)
 }
=20
 /**
+ * skb_frag_kmap - kmaps a paged fragment
+ * @frag: the paged fragment
+ *
+ * kmap()s the paged fragment @frag and returns the virtual address.
+ */
+static inline void *skb_frag_kmap(const skb_frag_t *frag)
+{
+	return kmap(skb_frag_page(frag));
+}
+
+/**
+ * skb_frag_kunmap - kunmaps a paged fragment
+ * @frag: the paged fragment
+ *
+ * kunmap()s the paged fragment @frag.
+ */
+static inline void skb_frag_kunmap(const skb_frag_t *frag)
+{
+	kunmap(skb_frag_page(frag));
+}
+
+/**
  * skb_frag_dma_map - maps a paged fragment via the DMA API
  * @dev: the device to map the fragment to
  * @frag: the paged fragment to map
diff --git a/net/core/datagram.c b/net/core/datagram.c
index 68bbf9f..ac763d1 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -332,14 +332,13 @@ int skb_copy_datagram_iovec(const struct sk_buff =
*skb, int offset,
 		if ((copy =3D end - offset) > 0) {
 			int err;
 			u8  *vaddr;
-			struct page *page =3D skb_frag_page(frag);
=20
 			if (copy > len)
 				copy =3D len;
-			vaddr =3D kmap(page);
+			vaddr =3D skb_frag_kmap(frag);
 			err =3D memcpy_toiovec(to, vaddr + frag->page_offset +
 					     offset - start, copy);
-			kunmap(page);
+			skb_frag_kunmap(frag);
 			if (err)
 				goto fault;
 			if (!(len -=3D copy))
@@ -418,14 +417,13 @@ int skb_copy_datagram_const_iovec(const struct sk=
_buff *skb, int offset,
 		if ((copy =3D end - offset) > 0) {
 			int err;
 			u8  *vaddr;
-			struct page *page =3D skb_frag_page(frag);
=20
 			if (copy > len)
 				copy =3D len;
-			vaddr =3D kmap(page);
+			vaddr =3D skb_frag_kmap(frag);
 			err =3D memcpy_toiovecend(to, vaddr + frag->page_offset +
 						offset - start, to_offset, copy);
-			kunmap(page);
+			skb_frag_kunmap(frag);
 			if (err)
 				goto fault;
 			if (!(len -=3D copy))
@@ -508,15 +506,14 @@ int skb_copy_datagram_from_iovec(struct sk_buff *=
skb, int offset,
 		if ((copy =3D end - offset) > 0) {
 			int err;
 			u8  *vaddr;
-			struct page *page =3D skb_frag_page(frag);
=20
 			if (copy > len)
 				copy =3D len;
-			vaddr =3D kmap(page);
+			vaddr =3D skb_frag_kmap(frag);
 			err =3D memcpy_fromiovecend(vaddr + frag->page_offset +
 						  offset - start,
 						  from, from_offset, copy);
-			kunmap(page);
+			skb_frag_kunmap(frag);
 			if (err)
 				goto fault;
=20
@@ -594,16 +591,15 @@ static int skb_copy_and_csum_datagram(const struc=
t sk_buff *skb, int offset,
 			__wsum csum2;
 			int err =3D 0;
 			u8  *vaddr;
-			struct page *page =3D skb_frag_page(frag);
=20
 			if (copy > len)
 				copy =3D len;
-			vaddr =3D kmap(page);
+			vaddr =3D skb_frag_kmap(frag);
 			csum2 =3D csum_and_copy_to_user(vaddr +
 							frag->page_offset +
 							offset - start,
 						      to, copy, 0, &err);
-			kunmap(page);
+			skb_frag_kunmap(frag);
 			if (err)
 				goto fault;
 			*csump =3D csum_block_add(*csump, csum2, pos);
--=20
1.7.9.5
