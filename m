From: Christoph Lameter <cl@linux.com>
Subject: Re: [Bugme-new] [Bug 33502] New: Caught 64-bit read from uninitialized
 memory in __alloc_skb
Date: Thu, 5 May 2011 14:05:18 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1105051405000.6821@router.home>
References: <bug-33502-10286@https.bugzilla.kernel.org/>  <20110418153852.153d3ed3.akpm@linux-foundation.org>  <1303181466.4152.39.camel@edumazet-laptop>  <1303182557.4152.48.camel@edumazet-laptop>  <1303183217.4152.49.camel@edumazet-laptop>
 <alpine.DEB.2.00.1104191210011.17888@router.home>  <1303244270.2756.3.camel@edumazet-laptop> <4DAE7579.3020400@cs.helsinki.fi>  <1303279470.2756.17.camel@edumazet-laptop>  <1303285519.4dae8f0fdf9b1@imp.free.fr>  <4DAE901C.2090809@cs.helsinki.fi>
 <1303286998.3186.18.camel@edumazet-laptop>  <1303290464.3186.32.camel@edumazet-laptop>  <1303293765.3186.74.camel@edumazet-laptop>  <alpine.DEB.2.00.1104200904440.8634@router.home>  <1303309591.3186.84.camel@edumazet-laptop>  <alpine.DEB.2.00.1104200942020.9266@router.home>
  <1303311687.3186.100.camel@edumazet-laptop>  <1304576296.32152.713.camel@edumazet-laptop>  <4DC24239.7050806@cs.helsinki.fi>  <alpine.DEB.2.00.1105051339310.6821@router.home> <1304621296.3032.98.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, casteyde.christian@free.fr,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Vegard Nossum <vegardno@ifi.uio.no>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp110.prem.mail.ac4.yahoo.com ([76.13.13.93]:38212 "HELO
	smtp110.prem.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751970Ab1EETFW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2011 15:05:22 -0400
In-Reply-To: <1304621296.3032.98.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 5 May 2011, Eric Dumazet wrote:

> > Combining this one with the patch I sent to remove the #ifdeffery would
> > make this much simpler.
>
> I must missed it, could you please resend it ?


Subject: slub: Remove CONFIG_CMPXCHG_LOCAL ifdeffery

Remove the #ifdefs. This means that the irqsafe_cpu_cmpxchg_double() is used
everywhere.

There may be performance implications since:

A. We now have to manage a transaction ID for all arches

B. The interrupt holdoff for arches not supporting CONFIG_CMPXCHG_LOCAL is reduced
to a very short irqoff section.

There are no multiple irqoff/irqon sequences as a result of this change. Even in the fallback
case we only have to do one disable and enable like before.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 include/linux/slub_def.h |    2 -
 mm/slub.c                |   56 -----------------------------------------------
 2 files changed, 58 deletions(-)

Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2011-05-04 09:33:08.000000000 -0500
+++ linux-2.6/include/linux/slub_def.h	2011-05-04 09:42:05.000000000 -0500
@@ -37,9 +37,7 @@ enum stat_item {

 struct kmem_cache_cpu {
 	void **freelist;	/* Pointer to next available object */
-#ifdef CONFIG_CMPXCHG_LOCAL
 	unsigned long tid;	/* Globally unique transaction id */
-#endif
 	struct page *page;	/* The slab from which we are allocating */
 	int node;		/* The node of the page (or -1 for debug) */
 #ifdef CONFIG_SLUB_STATS
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-05-04 09:41:59.000000000 -0500
+++ linux-2.6/mm/slub.c	2011-05-04 09:48:11.000000000 -0500
@@ -1540,7 +1540,6 @@ static void unfreeze_slab(struct kmem_ca
 	}
 }

-#ifdef CONFIG_CMPXCHG_LOCAL
 #ifdef CONFIG_PREEMPT
 /*
  * Calculate the next globally unique transaction for disambiguiation
@@ -1600,17 +1599,12 @@ static inline void note_cmpxchg_failure(
 	stat(s, CMPXCHG_DOUBLE_CPU_FAIL);
 }

-#endif
-
 void init_kmem_cache_cpus(struct kmem_cache *s)
 {
-#ifdef CONFIG_CMPXCHG_LOCAL
 	int cpu;

 	for_each_possible_cpu(cpu)
 		per_cpu_ptr(s->cpu_slab, cpu)->tid = init_tid(cpu);
-#endif
-
 }
 /*
  * Remove the cpu slab
@@ -1643,9 +1637,7 @@ static void deactivate_slab(struct kmem_
 		page->inuse--;
 	}
 	c->page = NULL;
-#ifdef CONFIG_CMPXCHG_LOCAL
 	c->tid = next_tid(c->tid);
-#endif
 	unfreeze_slab(s, page, tail);
 }

@@ -1780,7 +1772,6 @@ static void *__slab_alloc(struct kmem_ca
 {
 	void **object;
 	struct page *new;
-#ifdef CONFIG_CMPXCHG_LOCAL
 	unsigned long flags;

 	local_irq_save(flags);
@@ -1792,7 +1783,6 @@ static void *__slab_alloc(struct kmem_ca
 	 */
 	c = this_cpu_ptr(s->cpu_slab);
 #endif
-#endif

 	/* We handle __GFP_ZERO in the caller */
 	gfpflags &= ~__GFP_ZERO;
@@ -1819,10 +1809,8 @@ load_freelist:
 	c->node = page_to_nid(c->page);
 unlock_out:
 	slab_unlock(c->page);
-#ifdef CONFIG_CMPXCHG_LOCAL
 	c->tid = next_tid(c->tid);
 	local_irq_restore(flags);
-#endif
 	stat(s, ALLOC_SLOWPATH);
 	return object;

@@ -1858,9 +1846,7 @@ new_slab:
 	}
 	if (!(gfpflags & __GFP_NOWARN) && printk_ratelimit())
 		slab_out_of_memory(s, gfpflags, node);
-#ifdef CONFIG_CMPXCHG_LOCAL
 	local_irq_restore(flags);
-#endif
 	return NULL;
 debug:
 	if (!alloc_debug_processing(s, c->page, object, addr))
@@ -1887,20 +1873,12 @@ static __always_inline void *slab_alloc(
 {
 	void **object;
 	struct kmem_cache_cpu *c;
-#ifdef CONFIG_CMPXCHG_LOCAL
 	unsigned long tid;
-#else
-	unsigned long flags;
-#endif

 	if (slab_pre_alloc_hook(s, gfpflags))
 		return NULL;

-#ifndef CONFIG_CMPXCHG_LOCAL
-	local_irq_save(flags);
-#else
 redo:
-#endif

 	/*
 	 * Must read kmem_cache cpu data via this cpu ptr. Preemption is
@@ -1910,7 +1888,6 @@ redo:
 	 */
 	c = __this_cpu_ptr(s->cpu_slab);

-#ifdef CONFIG_CMPXCHG_LOCAL
 	/*
 	 * The transaction ids are globally unique per cpu and per operation on
 	 * a per cpu queue. Thus they can be guarantee that the cmpxchg_double
@@ -1919,7 +1896,6 @@ redo:
 	 */
 	tid = c->tid;
 	barrier();
-#endif

 	object = c->freelist;
 	if (unlikely(!object || !node_match(c, node)))
@@ -1927,7 +1903,6 @@ redo:
 		object = __slab_alloc(s, gfpflags, node, addr, c);

 	else {
-#ifdef CONFIG_CMPXCHG_LOCAL
 		/*
 		 * The cmpxchg will only match if there was no additional
 		 * operation and if we are on the right processor.
@@ -1948,16 +1923,9 @@ redo:
 			note_cmpxchg_failure("slab_alloc", s, tid);
 			goto redo;
 		}
-#else
-		c->freelist = get_freepointer(s, object);
-#endif
 		stat(s, ALLOC_FASTPATH);
 	}

-#ifndef CONFIG_CMPXCHG_LOCAL
-	local_irq_restore(flags);
-#endif
-
 	if (unlikely(gfpflags & __GFP_ZERO) && object)
 		memset(object, 0, s->objsize);

@@ -2034,11 +2002,9 @@ static void __slab_free(struct kmem_cach
 {
 	void *prior;
 	void **object = (void *)x;
-#ifdef CONFIG_CMPXCHG_LOCAL
 	unsigned long flags;

 	local_irq_save(flags);
-#endif
 	slab_lock(page);
 	stat(s, FREE_SLOWPATH);

@@ -2070,9 +2036,7 @@ checks_ok:

 out_unlock:
 	slab_unlock(page);
-#ifdef CONFIG_CMPXCHG_LOCAL
 	local_irq_restore(flags);
-#endif
 	return;

 slab_empty:
@@ -2084,9 +2048,7 @@ slab_empty:
 		stat(s, FREE_REMOVE_PARTIAL);
 	}
 	slab_unlock(page);
-#ifdef CONFIG_CMPXCHG_LOCAL
 	local_irq_restore(flags);
-#endif
 	stat(s, FREE_SLAB);
 	discard_slab(s, page);
 	return;
@@ -2113,20 +2075,11 @@ static __always_inline void slab_free(st
 {
 	void **object = (void *)x;
 	struct kmem_cache_cpu *c;
-#ifdef CONFIG_CMPXCHG_LOCAL
 	unsigned long tid;
-#else
-	unsigned long flags;
-#endif

 	slab_free_hook(s, x);

-#ifndef CONFIG_CMPXCHG_LOCAL
-	local_irq_save(flags);
-
-#else
 redo:
-#endif

 	/*
 	 * Determine the currently cpus per cpu slab.
@@ -2136,15 +2089,12 @@ redo:
 	 */
 	c = __this_cpu_ptr(s->cpu_slab);

-#ifdef CONFIG_CMPXCHG_LOCAL
 	tid = c->tid;
 	barrier();
-#endif

 	if (likely(page == c->page && c->node != NUMA_NO_NODE)) {
 		set_freepointer(s, object, c->freelist);

-#ifdef CONFIG_CMPXCHG_LOCAL
 		if (unlikely(!irqsafe_cpu_cmpxchg_double(
 				s->cpu_slab->freelist, s->cpu_slab->tid,
 				c->freelist, tid,
@@ -2153,16 +2103,10 @@ redo:
 			note_cmpxchg_failure("slab_free", s, tid);
 			goto redo;
 		}
-#else
-		c->freelist = object;
-#endif
 		stat(s, FREE_FASTPATH);
 	} else
 		__slab_free(s, page, x, addr);

-#ifndef CONFIG_CMPXCHG_LOCAL
-	local_irq_restore(flags);
-#endif
 }

 void kmem_cache_free(struct kmem_cache *s, void *x)
