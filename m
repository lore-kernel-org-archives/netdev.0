From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 6/9] net: add support for per-paged-fragment destructors
Date: Thu, 3 May 2012 15:56:08 +0100
Message-ID: <1336056971-7839-6-git-send-email-ian.campbell@citrix.com>
References: <1336056915.20716.96.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	=?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:43303 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757075Ab2ECO7W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 10:59:22 -0400
In-Reply-To: <1336056915.20716.96.camel@zakaz.uk.xensource.com>
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

Previous changes have ensured that, even with the increase in frag size=
, the
hot fields (nr_frags through to at least frags[0]) fit with and are ali=
gned to
a 64 byte cache line.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: "Micha=C5=82 Miros=C5=82aw" <mirq-linux@rere.qmqm.pl>
Cc: netdev@vger.kernel.org
---
 include/linux/skbuff.h |   50 ++++++++++++++++++++++++++++++++++++++++=
++++++-
 net/core/skbuff.c      |   18 +++++++++++++++++
 net/ipv4/ip_output.c   |    2 +-
 net/ipv4/tcp.c         |    4 +-
 4 files changed, 69 insertions(+), 5 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 3698625..ccc7d93 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -168,9 +168,15 @@ struct sk_buff;
=20
 typedef struct skb_frag_struct skb_frag_t;
=20
+struct skb_frag_destructor {
+	atomic_t ref;
+	int (*destroy)(struct skb_frag_destructor *destructor);
+};
+
 struct skb_frag_struct {
 	struct {
 		struct page *p;
+		struct skb_frag_destructor *destructor;
 	} page;
 #if (BITS_PER_LONG > 32) || (PAGE_SIZE >=3D 65536)
 	__u32 page_offset;
@@ -1232,6 +1238,31 @@ static inline int skb_pagelen(const struct sk_bu=
ff *skb)
 }
=20
 /**
+ * skb_frag_set_destructor - set destructor for a paged fragment
+ * @skb: buffer containing fragment to be initialised
+ * @i: paged fragment index to initialise
+ * @destroy: the destructor to use for this fragment
+ *
+ * Sets @destroy as the destructor to be called when all references to
+ * the frag @i in @skb (tracked over skb_clone, retransmit, pull-ups,
+ * etc) are released.
+ *
+ * When a destructor is set then reference counting is performed on
+ * @destroy->ref. When the ref reaches zero then @destroy->destroy
+ * will be called. The caller is responsible for holding and managing
+ * any other references (such a the struct page reference count).
+ *
+ * This function must be called before any use of skb_frag_ref() or
+ * skb_frag_unref().
+ */
+static inline void skb_frag_set_destructor(struct sk_buff *skb, int i,
+					   struct skb_frag_destructor *destroy)
+{
+	skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
+	frag->page.destructor =3D destroy;
+}
+
+/**
  * __skb_fill_page_desc - initialise a paged fragment in an skb
  * @skb: buffer containing fragment to be initialised
  * @i: paged fragment index to initialise
@@ -1250,6 +1281,7 @@ static inline void __skb_fill_page_desc(struct sk=
_buff *skb, int i,
 	skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
=20
 	frag->page.p		  =3D page;
+	frag->page.destructor     =3D NULL;
 	frag->page_offset	  =3D off;
 	skb_frag_size_set(frag, size);
 }
@@ -1766,6 +1798,9 @@ static inline struct page *skb_frag_page(const sk=
b_frag_t *frag)
 	return frag->page.p;
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
@@ -1774,6 +1809,10 @@ static inline struct page *skb_frag_page(const s=
kb_frag_t *frag)
  */
 static inline void __skb_frag_ref(skb_frag_t *frag)
 {
+	if (unlikely(frag->page.destructor)) {
+		skb_frag_destructor_ref(frag->page.destructor);
+		return;
+	}
 	get_page(skb_frag_page(frag));
 }
=20
@@ -1797,6 +1836,10 @@ static inline void skb_frag_ref(struct sk_buff *=
skb, int f)
  */
 static inline void __skb_frag_unref(skb_frag_t *frag)
 {
+	if (unlikely(frag->page.destructor)) {
+		skb_frag_destructor_unref(frag->page.destructor);
+		return;
+	}
 	put_page(skb_frag_page(frag));
 }
=20
@@ -1994,13 +2037,16 @@ static inline int skb_add_data(struct sk_buff *=
skb,
 }
=20
 static inline bool skb_can_coalesce(struct sk_buff *skb, int i,
-				    const struct page *page, int off)
+				    const struct page *page,
+				    const struct skb_frag_destructor *destroy,
+				    int off)
 {
 	if (i) {
 		const struct skb_frag_struct *frag =3D &skb_shinfo(skb)->frags[i - 1=
];
=20
 		return page =3D=3D skb_frag_page(frag) &&
-		       off =3D=3D frag->page_offset + skb_frag_size(frag);
+		       off =3D=3D frag->page_offset + skb_frag_size(frag) &&
+		       frag->page.destructor =3D=3D destroy;
 	}
 	return false;
 }
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index fab6de0..945b807 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -353,6 +353,23 @@ struct sk_buff *dev_alloc_skb(unsigned int length)
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
+		destroy->destroy(destroy);
+}
+EXPORT_SYMBOL(skb_frag_destructor_unref);
+
 static void skb_drop_list(struct sk_buff **listp)
 {
 	struct sk_buff *list =3D *listp;
@@ -2334,6 +2351,7 @@ int skb_shift(struct sk_buff *tgt, struct sk_buff=
 *skb, int shiftlen)
 	 */
 	if (!to ||
 	    !skb_can_coalesce(tgt, to, skb_frag_page(fragfrom),
+			      fragfrom->page.destructor,
 			      fragfrom->page_offset)) {
 		merge =3D -1;
 	} else {
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 4910176..7652751 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1242,7 +1242,7 @@ ssize_t	ip_append_page(struct sock *sk, struct fl=
owi4 *fl4, struct page *page,
 		i =3D skb_shinfo(skb)->nr_frags;
 		if (len > size)
 			len =3D size;
-		if (skb_can_coalesce(skb, i, page, offset)) {
+		if (skb_can_coalesce(skb, i, page, NULL, offset)) {
 			skb_frag_size_add(&skb_shinfo(skb)->frags[i-1], len);
 		} else if (i < MAX_SKB_FRAGS) {
 			get_page(page);
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 9670af3..2d590ca 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -870,7 +870,7 @@ new_segment:
 			copy =3D size;
=20
 		i =3D skb_shinfo(skb)->nr_frags;
-		can_coalesce =3D skb_can_coalesce(skb, i, page, offset);
+		can_coalesce =3D skb_can_coalesce(skb, i, page, NULL, offset);
 		if (!can_coalesce && i >=3D MAX_SKB_FRAGS) {
 			tcp_mark_push(tp, skb);
 			goto new_segment;
@@ -1124,7 +1124,7 @@ new_segment:
=20
 				off =3D sk->sk_sndmsg_off;
=20
-				if (skb_can_coalesce(skb, i, page, off) &&
+				if (skb_can_coalesce(skb, i, page, NULL, off) &&
 				    off !=3D PAGE_SIZE) {
 					/* We can extend the last page
 					 * fragment. */
--=20
1.7.2.5
