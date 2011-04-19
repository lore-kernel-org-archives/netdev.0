From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 33502] New: Caught 64-bit read from
 uninitialized memory in __alloc_skb
Date: Tue, 19 Apr 2011 22:17:50 +0200
Message-ID: <1303244270.2756.3.camel@edumazet-laptop>
References: <bug-33502-10286@https.bugzilla.kernel.org/>
	 <20110418153852.153d3ed3.akpm@linux-foundation.org>
	 <1303181466.4152.39.camel@edumazet-laptop>
	 <1303182557.4152.48.camel@edumazet-laptop>
	 <1303183217.4152.49.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1104191210011.17888@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, casteyde.christian@free.fr,
	Vegard Nossum <vegardno@ifi.uio.no>,
	Pekka Enberg <penberg@kernel.org>
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:51327 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755155Ab1DSUR6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 16:17:58 -0400
Received: by wya21 with SMTP id 21so58928wya.19
        for <netdev@vger.kernel.org>; Tue, 19 Apr 2011 13:17:57 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1104191210011.17888@router.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 19 avril 2011 =C3=A0 12:10 -0500, Christoph Lameter a =C3=A9cr=
it :
> On Tue, 19 Apr 2011, Eric Dumazet wrote:
>=20
> >  	}
> >  }
> >
> > -#ifdef CONFIG_CMPXCHG_LOCAL
> > +#if defined(CONFIG_CMPXCHG_LOCAL) && \
> > +	!defined(CONFIG_KMEMCHECK) && !defined(DEBUG_PAGEALLOC)
> > +#define SLUB_USE_CMPXCHG_DOUBLE
> > +#endif
> > +
> > +#ifdef SLUB_USE_CMPXCHG_DOUBLE
> >  #ifdef CONFIG_PREEMPT
> >  /*
>=20
> Ugg.. Isnt there some way to indicate to kmemcheck that a speculative
> access is occurring?

Yes, here is a totally untested patch (only compiled here), to keep
kmemcheck & cmpxchg_double together.



diff --git a/mm/slub.c b/mm/slub.c
index 94d2a33..43c08c7 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -261,6 +261,14 @@ static inline void *get_freepointer(struct kmem_ca=
che *s, void *object)
 	return *(void **)(object + s->offset);
 }
=20
+static inline void *get_freepointer_mark(struct kmem_cache *s, void *o=
bject)
+{
+	void *ptr =3D object + s->offset;
+
+	kmemcheck_mark_initialized(ptr, sizeof(void *));
+	return *(void **)ptr;
+}
+
 static inline void set_freepointer(struct kmem_cache *s, void *object,=
 void *fp)
 {
 	*(void **)(object + s->offset) =3D fp;
@@ -1540,7 +1548,11 @@ static void unfreeze_slab(struct kmem_cache *s, =
struct page *page, int tail)
 	}
 }
=20
-#ifdef CONFIG_CMPXCHG_LOCAL
+#if defined(CONFIG_CMPXCHG_LOCAL) && !defined(DEBUG_PAGEALLOC)
+#define SLUB_USE_CMPXCHG_DOUBLE
+#endif
+
+#ifdef SLUB_USE_CMPXCHG_DOUBLE
 #ifdef CONFIG_PREEMPT
 /*
  * Calculate the next globally unique transaction for disambiguiation
@@ -1604,7 +1616,7 @@ static inline void note_cmpxchg_failure(const cha=
r *n,
=20
 void init_kmem_cache_cpus(struct kmem_cache *s)
 {
-#ifdef CONFIG_CMPXCHG_LOCAL
+#ifdef SLUB_USE_CMPXCHG_DOUBLE
 	int cpu;
=20
 	for_each_possible_cpu(cpu)
@@ -1643,7 +1655,7 @@ static void deactivate_slab(struct kmem_cache *s,=
 struct kmem_cache_cpu *c)
 		page->inuse--;
 	}
 	c->page =3D NULL;
-#ifdef CONFIG_CMPXCHG_LOCAL
+#ifdef SLUB_USE_CMPXCHG_DOUBLE
 	c->tid =3D next_tid(c->tid);
 #endif
 	unfreeze_slab(s, page, tail);
@@ -1780,7 +1792,7 @@ static void *__slab_alloc(struct kmem_cache *s, g=
fp_t gfpflags, int node,
 {
 	void **object;
 	struct page *new;
-#ifdef CONFIG_CMPXCHG_LOCAL
+#ifdef SLUB_USE_CMPXCHG_DOUBLE
 	unsigned long flags;
=20
 	local_irq_save(flags);
@@ -1819,7 +1831,7 @@ load_freelist:
 	c->node =3D page_to_nid(c->page);
 unlock_out:
 	slab_unlock(c->page);
-#ifdef CONFIG_CMPXCHG_LOCAL
+#ifdef SLUB_USE_CMPXCHG_DOUBLE
 	c->tid =3D next_tid(c->tid);
 	local_irq_restore(flags);
 #endif
@@ -1858,7 +1870,7 @@ new_slab:
 	}
 	if (!(gfpflags & __GFP_NOWARN) && printk_ratelimit())
 		slab_out_of_memory(s, gfpflags, node);
-#ifdef CONFIG_CMPXCHG_LOCAL
+#ifdef SLUB_USE_CMPXCHG_DOUBLE
 	local_irq_restore(flags);
 #endif
 	return NULL;
@@ -1887,7 +1899,7 @@ static __always_inline void *slab_alloc(struct km=
em_cache *s,
 {
 	void **object;
 	struct kmem_cache_cpu *c;
-#ifdef CONFIG_CMPXCHG_LOCAL
+#ifdef SLUB_USE_CMPXCHG_DOUBLE
 	unsigned long tid;
 #else
 	unsigned long flags;
@@ -1896,7 +1908,7 @@ static __always_inline void *slab_alloc(struct km=
em_cache *s,
 	if (slab_pre_alloc_hook(s, gfpflags))
 		return NULL;
=20
-#ifndef CONFIG_CMPXCHG_LOCAL
+#ifndef SLUB_USE_CMPXCHG_DOUBLE
 	local_irq_save(flags);
 #else
 redo:
@@ -1910,7 +1922,7 @@ redo:
 	 */
 	c =3D __this_cpu_ptr(s->cpu_slab);
=20
-#ifdef CONFIG_CMPXCHG_LOCAL
+#ifdef SLUB_USE_CMPXCHG_DOUBLE
 	/*
 	 * The transaction ids are globally unique per cpu and per operation =
on
 	 * a per cpu queue. Thus they can be guarantee that the cmpxchg_doubl=
e
@@ -1927,7 +1939,7 @@ redo:
 		object =3D __slab_alloc(s, gfpflags, node, addr, c);
=20
 	else {
-#ifdef CONFIG_CMPXCHG_LOCAL
+#ifdef SLUB_USE_CMPXCHG_DOUBLE
 		/*
 		 * The cmpxchg will only match if there was no additional
 		 * operation and if we are on the right processor.
@@ -1943,7 +1955,8 @@ redo:
 		if (unlikely(!this_cpu_cmpxchg_double(
 				s->cpu_slab->freelist, s->cpu_slab->tid,
 				object, tid,
-				get_freepointer(s, object), next_tid(tid)))) {
+				get_freepointer_mark(s, object),
+				next_tid(tid)))) {
=20
 			note_cmpxchg_failure("slab_alloc", s, tid);
 			goto redo;
@@ -1954,7 +1967,7 @@ redo:
 		stat(s, ALLOC_FASTPATH);
 	}
=20
-#ifndef CONFIG_CMPXCHG_LOCAL
+#ifndef SLUB_USE_CMPXCHG_DOUBLE
 	local_irq_restore(flags);
 #endif
=20
@@ -2034,7 +2047,7 @@ static void __slab_free(struct kmem_cache *s, str=
uct page *page,
 {
 	void *prior;
 	void **object =3D (void *)x;
-#ifdef CONFIG_CMPXCHG_LOCAL
+#ifdef SLUB_USE_CMPXCHG_DOUBLE
 	unsigned long flags;
=20
 	local_irq_save(flags);
@@ -2070,7 +2083,7 @@ checks_ok:
=20
 out_unlock:
 	slab_unlock(page);
-#ifdef CONFIG_CMPXCHG_LOCAL
+#ifdef SLUB_USE_CMPXCHG_DOUBLE
 	local_irq_restore(flags);
 #endif
 	return;
@@ -2084,7 +2097,7 @@ slab_empty:
 		stat(s, FREE_REMOVE_PARTIAL);
 	}
 	slab_unlock(page);
-#ifdef CONFIG_CMPXCHG_LOCAL
+#ifdef SLUB_USE_CMPXCHG_DOUBLE
 	local_irq_restore(flags);
 #endif
 	stat(s, FREE_SLAB);
@@ -2113,7 +2126,7 @@ static __always_inline void slab_free(struct kmem=
_cache *s,
 {
 	void **object =3D (void *)x;
 	struct kmem_cache_cpu *c;
-#ifdef CONFIG_CMPXCHG_LOCAL
+#ifdef SLUB_USE_CMPXCHG_DOUBLE
 	unsigned long tid;
 #else
 	unsigned long flags;
@@ -2121,7 +2134,7 @@ static __always_inline void slab_free(struct kmem=
_cache *s,
=20
 	slab_free_hook(s, x);
=20
-#ifndef CONFIG_CMPXCHG_LOCAL
+#ifndef SLUB_USE_CMPXCHG_DOUBLE
 	local_irq_save(flags);
=20
 #else
@@ -2136,7 +2149,7 @@ redo:
 	 */
 	c =3D __this_cpu_ptr(s->cpu_slab);
=20
-#ifdef CONFIG_CMPXCHG_LOCAL
+#ifdef SLUB_USE_CMPXCHG_DOUBLE
 	tid =3D c->tid;
 	barrier();
 #endif
@@ -2144,7 +2157,7 @@ redo:
 	if (likely(page =3D=3D c->page && c->node !=3D NUMA_NO_NODE)) {
 		set_freepointer(s, object, c->freelist);
=20
-#ifdef CONFIG_CMPXCHG_LOCAL
+#ifdef SLUB_USE_CMPXCHG_DOUBLE
 		if (unlikely(!this_cpu_cmpxchg_double(
 				s->cpu_slab->freelist, s->cpu_slab->tid,
 				c->freelist, tid,
@@ -2160,7 +2173,7 @@ redo:
 	} else
 		__slab_free(s, page, x, addr);
=20
-#ifndef CONFIG_CMPXCHG_LOCAL
+#ifndef SLUB_USE_CMPXCHG_DOUBLE
 	local_irq_restore(flags);
 #endif
 }
@@ -2354,7 +2367,7 @@ static inline int alloc_kmem_cache_cpus(struct km=
em_cache *s)
 	BUILD_BUG_ON(PERCPU_DYNAMIC_EARLY_SIZE <
 			SLUB_PAGE_SHIFT * sizeof(struct kmem_cache_cpu));
=20
-#ifdef CONFIG_CMPXCHG_LOCAL
+#ifdef SLUB_USE_CMPXCHG_DOUBLE
 	/*
 	 * Must align to double word boundary for the double cmpxchg instruct=
ions
 	 * to work.


