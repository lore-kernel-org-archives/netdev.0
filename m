From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 27212] New: Warning kmemcheck: Caught 64-bit
 read from uninitialized memory in netlink_broadcast_filtered
Date: Mon, 14 Feb 2011 18:35:22 +0100
Message-ID: <1297704922.2996.60.camel@edumazet-laptop>
References: <bug-27212-10286@https.bugzilla.kernel.org/>
	 <20110120122549.85863a84.akpm@linux-foundation.org>
	 <1295556085.2613.22.camel@edumazet-laptop>  <4D393A99.9060104@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, casteyde.christian@free.fr,
	Changli Gao <xiaosuo@gmail.com>,
	Vegard Nossum <vegardno@ifi.uio.no>,
	David Miller <davem@davemloft.net>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Pekka Enberg <penberg@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:54653 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755313Ab1BNRf3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Feb 2011 12:35:29 -0500
In-Reply-To: <4D393A99.9060104@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 21 janvier 2011 =C3=A0 09:49 +0200, Pekka Enberg a =C3=A9cr=
it :

> It actually looks like a bug in SLUB+kmemcheck. The=20
> kmemcheck_slab_alloc() call in slab_post_alloc_hook() should use ksiz=
e()=20
> instead of s->objsize. SLAB seems to do the right thing already. Anyo=
ne=20
> care to send a patch my way?
>=20

Hmm, what do you think of following patch ?

Thanks, and sorry for the delay.

[PATCH] slub: fix kmemcheck calls to match ksize() hints

Recent use of ksize() in network stack (commit ca44ac38 : net: don't
reallocate skb->head unless the current one hasn't the needed extra siz=
e
or is shared) triggers kmemcheck warnings, because ksize() can return
more space than kmemcheck is aware of.

Pekka Enberg noticed SLAB+kmemcheck is doing the right thing, while SLU=
B
+kmemcheck doesnt.

Bugzilla reference #27212

Reported-by: Christian Casteyde <casteyde.christian@free.fr>
Suggested-by: Pekka Enberg <penberg@kernel.org>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: David Miller <davem@davemloft.net>
CC: Changli Gao <xiaosuo@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>
---
 mm/slub.c |   49 ++++++++++++++++++++++++++-----------------------
 1 file changed, 26 insertions(+), 23 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index e15aa7f..ee0aeb8 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -797,10 +797,34 @@ static inline int slab_pre_alloc_hook(struct kmem=
_cache *s, gfp_t flags)
 	return should_failslab(s->objsize, flags, s->flags);
 }
=20
+static inline size_t slab_ksize(const struct kmem_cache *s)
+{
+#ifdef CONFIG_SLUB_DEBUG
+	/*
+	 * Debugging requires use of the padding between object
+	 * and whatever may come after it.
+	 */
+	if (s->flags & (SLAB_RED_ZONE | SLAB_POISON))
+		return s->objsize;
+
+#endif
+	/*
+	 * If we have the need to store the freelist pointer
+	 * back there or track user information then we can
+	 * only use the space before that information.
+	 */
+	if (s->flags & (SLAB_DESTROY_BY_RCU | SLAB_STORE_USER))
+		return s->inuse;
+	/*
+	 * Else we can use all the padding etc for the allocation
+	 */
+	return s->size;
+}
+
 static inline void slab_post_alloc_hook(struct kmem_cache *s, gfp_t fl=
ags, void *object)
 {
 	flags &=3D gfp_allowed_mask;
-	kmemcheck_slab_alloc(s, flags, object, s->objsize);
+	kmemcheck_slab_alloc(s, flags, object, slab_ksize(s));
 	kmemleak_alloc_recursive(object, s->objsize, 1, s->flags, flags);
 }
=20
@@ -2696,7 +2720,6 @@ EXPORT_SYMBOL(__kmalloc_node);
 size_t ksize(const void *object)
 {
 	struct page *page;
-	struct kmem_cache *s;
=20
 	if (unlikely(object =3D=3D ZERO_SIZE_PTR))
 		return 0;
@@ -2707,28 +2730,8 @@ size_t ksize(const void *object)
 		WARN_ON(!PageCompound(page));
 		return PAGE_SIZE << compound_order(page);
 	}
-	s =3D page->slab;
=20
-#ifdef CONFIG_SLUB_DEBUG
-	/*
-	 * Debugging requires use of the padding between object
-	 * and whatever may come after it.
-	 */
-	if (s->flags & (SLAB_RED_ZONE | SLAB_POISON))
-		return s->objsize;
-
-#endif
-	/*
-	 * If we have the need to store the freelist pointer
-	 * back there or track user information then we can
-	 * only use the space before that information.
-	 */
-	if (s->flags & (SLAB_DESTROY_BY_RCU | SLAB_STORE_USER))
-		return s->inuse;
-	/*
-	 * Else we can use all the padding etc for the allocation
-	 */
-	return s->size;
+	return slab_ksize(page->slab);
 }
 EXPORT_SYMBOL(ksize);
=20


