From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 74/75] net: add skb_frag_k(un)map convenience functions.
Date: Fri, 19 Aug 2011 14:27:46 +0100
Message-ID: <1313760467-8598-74-git-send-email-ian.campbell@citrix.com>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Ian Campbell <ian.campbell@citrix.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	Tom Herbert <therbert@google.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Koki Sanagi <sanagi.koki@jp.fujitsu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:24015 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755571Ab1HSNaW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Aug 2011 09:30:22 -0400
In-Reply-To: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: "Micha=C5=82 Miros=C5=82aw" <mirq-linux@rere.qmqm.pl>
Cc: Tom Herbert <therbert@google.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org
Cc: netdev@vger.kernel.org
---
 include/linux/skbuff.h |   22 ++++++++++++++++++++++
 net/core/datagram.c    |   20 ++++++++------------
 2 files changed, 30 insertions(+), 12 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 73d8f7a..0328428 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1839,6 +1839,28 @@ static inline void skb_frag_kunmap_atomic(void *=
vaddr)
 }
=20
 /**
+ * skb_frag_kmap - kmaps a paged fragment
+ * @frag: the paged fragment
+ *
+ * kmap()s the paged fragment @frag and returns the virtual address.
+ */
+static inline void *skb_frag_kmap(skb_frag_t *frag)
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
+static inline void skb_frag_kunmap(skb_frag_t *frag)
+{
+	kunmap(skb_frag_page(frag));
+}
+
+/**
  * skb_frag_dma_map - maps a paged fragment via the DMA API
  * @device: the device to map the fragment to
  * @frag: the paged fragment to map
diff --git a/net/core/datagram.c b/net/core/datagram.c
index 6449bed..f0dcaa2 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -332,14 +332,13 @@ int skb_copy_datagram_iovec(const struct sk_buff =
*skb, int offset,
 			int err;
 			u8  *vaddr;
 			skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
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
 			int err;
 			u8  *vaddr;
 			skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
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
 			int err;
 			u8  *vaddr;
 			skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
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
 			int err =3D 0;
 			u8  *vaddr;
 			skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
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
1.7.2.5

