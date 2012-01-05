From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 3/6] net: add support for per-paged-fragment destructors
Date: Thu, 5 Jan 2012 17:13:41 +0000
Message-ID: <1325783624-14601-3-git-send-email-ian.campbell@citrix.com>
References: <1325783399.25206.413.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	=?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:4867 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756832Ab2AERNv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jan 2012 12:13:51 -0500
In-Reply-To: <1325783399.25206.413.camel@zakaz.uk.xensource.com>
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

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: "Micha=C5=82 Miros=C5=82aw" <mirq-linux@rere.qmqm.pl>
Cc: netdev@vger.kernel.org
---
 include/linux/skbuff.h |   44 ++++++++++++++++++++++++++++++++++++++++=
++++
 net/core/skbuff.c      |   17 +++++++++++++++++
 2 files changed, 61 insertions(+), 0 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index f04333b..89fa908 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -143,9 +143,16 @@ struct sk_buff;
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
 	struct {
 		struct page *p;
+		struct skb_frag_destructor *destructor;
 	} page;
 #if (BITS_PER_LONG > 32) || (PAGE_SIZE >=3D 65536)
 	__u32 page_offset;
@@ -1172,6 +1179,31 @@ static inline int skb_pagelen(const struct sk_bu=
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
@@ -1190,6 +1222,7 @@ static inline void __skb_fill_page_desc(struct sk=
_buff *skb, int i,
 	skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
=20
 	frag->page.p		  =3D page;
+	frag->page.destructor     =3D NULL;
 	frag->page_offset	  =3D off;
 	skb_frag_size_set(frag, size);
 }
@@ -1684,6 +1717,9 @@ static inline struct page *skb_frag_page(const sk=
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
@@ -1692,6 +1728,10 @@ static inline struct page *skb_frag_page(const s=
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
@@ -1715,6 +1755,10 @@ static inline void skb_frag_ref(struct sk_buff *=
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
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index b6de604..12f3c8c 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -351,6 +351,23 @@ struct sk_buff *dev_alloc_skb(unsigned int length)
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
