From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 33502] New: Caught 64-bit read from
 uninitialized memory in __alloc_skb
Date: Thu, 05 May 2011 08:18:16 +0200
Message-ID: <1304576296.32152.713.camel@edumazet-laptop>
References: <bug-33502-10286@https.bugzilla.kernel.org/>
	 <20110418153852.153d3ed3.akpm@linux-foundation.org>
	 <1303181466.4152.39.camel@edumazet-laptop>
	 <1303182557.4152.48.camel@edumazet-laptop>
	 <1303183217.4152.49.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1104191210011.17888@router.home>
	 <1303244270.2756.3.camel@edumazet-laptop> <4DAE7579.3020400@cs.helsinki.fi>
	 <1303279470.2756.17.camel@edumazet-laptop>
	 <1303285519.4dae8f0fdf9b1@imp.free.fr>  <4DAE901C.2090809@cs.helsinki.fi>
	 <1303286998.3186.18.camel@edumazet-laptop>
	 <1303290464.3186.32.camel@edumazet-laptop>
	 <1303293765.3186.74.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1104200904440.8634@router.home>
	 <1303309591.3186.84.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1104200942020.9266@router.home>
	 <1303311687.3186.100.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, casteyde.christian@free.fr,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Vegard Nossum <vegardno@ifi.uio.no>
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:44262 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751700Ab1EEGSZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2011 02:18:25 -0400
Received: by wya21 with SMTP id 21so1352988wya.19
        for <netdev@vger.kernel.org>; Wed, 04 May 2011 23:18:24 -0700 (PDT)
In-Reply-To: <1303311687.3186.100.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 20 avril 2011 =C3=A0 17:01 +0200, Eric Dumazet a =C3=A9crit=
 :
> Le mercredi 20 avril 2011 =C3=A0 09:42 -0500, Christoph Lameter a =C3=
=A9crit :
>=20
> > Avoiding the irq handling yields the savings that improve the fastp=
ath. if
> > you do both then there is only a regression left. So lets go with
> > disabling the CMPXCHG_LOCAL.
>=20
> OK, let's do that then.
>=20
> Thanks
>=20
> [PATCH v4] slub: dont use cmpxchg_double if KMEMCHECK or DEBUG_PAGEAL=
LOC
>=20
> Christian Casteyde reported a KMEMCHECK splat in slub code.
>=20
> Problem is now we are lockless and allow IRQ in slab_alloc(), the obj=
ect
> we manipulate from freelist can be allocated and freed right before w=
e
> try to read object->next.
>=20
> Same problem can happen with DEBUG_PAGEALLOC
>=20
> Just dont use cmpxchg_double() if either CONFIG_KMEMCHECK or
> CONFIG_DEBUG_PAGEALLOC is defined.
>=20
> Reported-by: Christian Casteyde <casteyde.christian@free.fr>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Pekka Enberg <penberg@cs.helsinki.fi>
> Cc: Vegard Nossum <vegardno@ifi.uio.no>
> Cc: Christoph Lameter <cl@linux.com>
> ---
>  mm/slub.c |   45 +++++++++++++++++++++++++--------------------
>  1 files changed, 25 insertions(+), 20 deletions(-)
>=20
> diff --git a/mm/slub.c b/mm/slub.c
> index 94d2a33..f31ab2c 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1540,7 +1540,12 @@ static void unfreeze_slab(struct kmem_cache *s=
, struct page *page, int tail)
>  	}
>  }
> =20
> -#ifdef CONFIG_CMPXCHG_LOCAL
> +#if defined(CONFIG_CMPXCHG_LOCAL) && !defined(CONFIG_KMEMCHECK) && \
> +				     !defined(CONFIG_DEBUG_PAGEALLOC)
> +#define SLUB_USE_CMPXCHG_DOUBLE
> +#endif
> +
> +#ifdef SLUB_USE_CMPXCHG_DOUBLE
>  #ifdef CONFIG_PREEMPT
>  /*
>   * Calculate the next globally unique transaction for disambiguiatio=
n
> @@ -1604,7 +1609,7 @@ static inline void note_cmpxchg_failure(const c=
har *n,
> =20
>  void init_kmem_cache_cpus(struct kmem_cache *s)
>  {
> -#ifdef CONFIG_CMPXCHG_LOCAL
> +#ifdef SLUB_USE_CMPXCHG_DOUBLE
>  	int cpu;
> =20
>  	for_each_possible_cpu(cpu)
> @@ -1643,7 +1648,7 @@ static void deactivate_slab(struct kmem_cache *=
s, struct kmem_cache_cpu *c)
>  		page->inuse--;
>  	}
>  	c->page =3D NULL;
> -#ifdef CONFIG_CMPXCHG_LOCAL
> +#ifdef SLUB_USE_CMPXCHG_DOUBLE
>  	c->tid =3D next_tid(c->tid);
>  #endif
>  	unfreeze_slab(s, page, tail);
> @@ -1780,7 +1785,7 @@ static void *__slab_alloc(struct kmem_cache *s,=
 gfp_t gfpflags, int node,
>  {
>  	void **object;
>  	struct page *new;
> -#ifdef CONFIG_CMPXCHG_LOCAL
> +#ifdef SLUB_USE_CMPXCHG_DOUBLE
>  	unsigned long flags;
> =20
>  	local_irq_save(flags);
> @@ -1819,7 +1824,7 @@ load_freelist:
>  	c->node =3D page_to_nid(c->page);
>  unlock_out:
>  	slab_unlock(c->page);
> -#ifdef CONFIG_CMPXCHG_LOCAL
> +#ifdef SLUB_USE_CMPXCHG_DOUBLE
>  	c->tid =3D next_tid(c->tid);
>  	local_irq_restore(flags);
>  #endif
> @@ -1858,7 +1863,7 @@ new_slab:
>  	}
>  	if (!(gfpflags & __GFP_NOWARN) && printk_ratelimit())
>  		slab_out_of_memory(s, gfpflags, node);
> -#ifdef CONFIG_CMPXCHG_LOCAL
> +#ifdef SLUB_USE_CMPXCHG_DOUBLE
>  	local_irq_restore(flags);
>  #endif
>  	return NULL;
> @@ -1887,7 +1892,7 @@ static __always_inline void *slab_alloc(struct =
kmem_cache *s,
>  {
>  	void **object;
>  	struct kmem_cache_cpu *c;
> -#ifdef CONFIG_CMPXCHG_LOCAL
> +#ifdef SLUB_USE_CMPXCHG_DOUBLE
>  	unsigned long tid;
>  #else
>  	unsigned long flags;
> @@ -1896,7 +1901,7 @@ static __always_inline void *slab_alloc(struct =
kmem_cache *s,
>  	if (slab_pre_alloc_hook(s, gfpflags))
>  		return NULL;
> =20
> -#ifndef CONFIG_CMPXCHG_LOCAL
> +#ifndef SLUB_USE_CMPXCHG_DOUBLE
>  	local_irq_save(flags);
>  #else
>  redo:
> @@ -1910,7 +1915,7 @@ redo:
>  	 */
>  	c =3D __this_cpu_ptr(s->cpu_slab);
> =20
> -#ifdef CONFIG_CMPXCHG_LOCAL
> +#ifdef SLUB_USE_CMPXCHG_DOUBLE
>  	/*
>  	 * The transaction ids are globally unique per cpu and per operatio=
n on
>  	 * a per cpu queue. Thus they can be guarantee that the cmpxchg_dou=
ble
> @@ -1927,7 +1932,7 @@ redo:
>  		object =3D __slab_alloc(s, gfpflags, node, addr, c);
> =20
>  	else {
> -#ifdef CONFIG_CMPXCHG_LOCAL
> +#ifdef SLUB_USE_CMPXCHG_DOUBLE
>  		/*
>  		 * The cmpxchg will only match if there was no additional
>  		 * operation and if we are on the right processor.
> @@ -1954,7 +1959,7 @@ redo:
>  		stat(s, ALLOC_FASTPATH);
>  	}
> =20
> -#ifndef CONFIG_CMPXCHG_LOCAL
> +#ifndef SLUB_USE_CMPXCHG_DOUBLE
>  	local_irq_restore(flags);
>  #endif
> =20
> @@ -2034,7 +2039,7 @@ static void __slab_free(struct kmem_cache *s, s=
truct page *page,
>  {
>  	void *prior;
>  	void **object =3D (void *)x;
> -#ifdef CONFIG_CMPXCHG_LOCAL
> +#ifdef SLUB_USE_CMPXCHG_DOUBLE
>  	unsigned long flags;
> =20
>  	local_irq_save(flags);
> @@ -2070,7 +2075,7 @@ checks_ok:
> =20
>  out_unlock:
>  	slab_unlock(page);
> -#ifdef CONFIG_CMPXCHG_LOCAL
> +#ifdef SLUB_USE_CMPXCHG_DOUBLE
>  	local_irq_restore(flags);
>  #endif
>  	return;
> @@ -2084,7 +2089,7 @@ slab_empty:
>  		stat(s, FREE_REMOVE_PARTIAL);
>  	}
>  	slab_unlock(page);
> -#ifdef CONFIG_CMPXCHG_LOCAL
> +#ifdef SLUB_USE_CMPXCHG_DOUBLE
>  	local_irq_restore(flags);
>  #endif
>  	stat(s, FREE_SLAB);
> @@ -2113,7 +2118,7 @@ static __always_inline void slab_free(struct km=
em_cache *s,
>  {
>  	void **object =3D (void *)x;
>  	struct kmem_cache_cpu *c;
> -#ifdef CONFIG_CMPXCHG_LOCAL
> +#ifdef SLUB_USE_CMPXCHG_DOUBLE
>  	unsigned long tid;
>  #else
>  	unsigned long flags;
> @@ -2121,7 +2126,7 @@ static __always_inline void slab_free(struct km=
em_cache *s,
> =20
>  	slab_free_hook(s, x);
> =20
> -#ifndef CONFIG_CMPXCHG_LOCAL
> +#ifndef SLUB_USE_CMPXCHG_DOUBLE
>  	local_irq_save(flags);
> =20
>  #else
> @@ -2136,7 +2141,7 @@ redo:
>  	 */
>  	c =3D __this_cpu_ptr(s->cpu_slab);
> =20
> -#ifdef CONFIG_CMPXCHG_LOCAL
> +#ifdef SLUB_USE_CMPXCHG_DOUBLE
>  	tid =3D c->tid;
>  	barrier();
>  #endif
> @@ -2144,7 +2149,7 @@ redo:
>  	if (likely(page =3D=3D c->page && c->node !=3D NUMA_NO_NODE)) {
>  		set_freepointer(s, object, c->freelist);
> =20
> -#ifdef CONFIG_CMPXCHG_LOCAL
> +#ifdef SLUB_USE_CMPXCHG_DOUBLE
>  		if (unlikely(!this_cpu_cmpxchg_double(
>  				s->cpu_slab->freelist, s->cpu_slab->tid,
>  				c->freelist, tid,
> @@ -2160,7 +2165,7 @@ redo:
>  	} else
>  		__slab_free(s, page, x, addr);
> =20
> -#ifndef CONFIG_CMPXCHG_LOCAL
> +#ifndef SLUB_USE_CMPXCHG_DOUBLE
>  	local_irq_restore(flags);
>  #endif
>  }
> @@ -2354,7 +2359,7 @@ static inline int alloc_kmem_cache_cpus(struct =
kmem_cache *s)
>  	BUILD_BUG_ON(PERCPU_DYNAMIC_EARLY_SIZE <
>  			SLUB_PAGE_SHIFT * sizeof(struct kmem_cache_cpu));
> =20
> -#ifdef CONFIG_CMPXCHG_LOCAL
> +#ifdef SLUB_USE_CMPXCHG_DOUBLE
>  	/*
>  	 * Must align to double word boundary for the double cmpxchg instru=
ctions
>  	 * to work.
>=20


Is anybody taking the patch and sending it upstream ?

Thanks


