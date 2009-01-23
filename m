From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: Mainline kernel OLTP performance update
Date: Fri, 23 Jan 2009 11:46:29 +0200
Message-ID: <1232703989.6094.29.camel@penberg-laptop>
References: <BC02C49EEB98354DBA7F5DD76F2A9E800317003CB0@azsmsx501.amr.corp.intel.com>
	 <200901161503.13730.nickpiggin@yahoo.com.au>
	 <20090115201210.ca1a9542.akpm@linux-foundation.org>
	 <200901161746.25205.nickpiggin@yahoo.com.au>
	 <20090116065546.GJ31013@parisc-linux.org>
	 <1232092430.11429.52.camel@ymzhang>  <87sknjeemn.fsf@basil.nowhere.org>
	 <1232428583.11429.83.camel@ymzhang>
	 <alpine.DEB.1.10.0901211852060.18367@qirst.com>
	 <1232613395.11429.122.camel@ymzhang>
	 <1232615707.14549.6.camel@penberg-laptop>
	 <1232616517.11429.129.camel@ymzhang>
	 <1232617672.14549.25.camel@penberg-laptop>
	 <1232679773.11429.155.camel@ymzhang>  <4979692B.3050703@cs.helsinki.fi>
	 <1232697998.6094.17.camel@penberg-laptop>
	 <1232699401.11429.163.camel@ymzhang>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <cl@linux-foundation.org>,
	Andi Kleen <andi@firstfloor.org>,
	Matthew Wilcox <matthew@wil.cx>,
	Nick Piggin <nickpiggin@yahoo.com.au>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, sfr@canb.auug.org.au,
	matthew.r.wilcox@intel.com, chinang.ma@intel.com,
	linux-kernel@vger.kernel.org, sharad.c.tripathi@intel.com,
	arjan@linux.intel.com, suresh.b.siddha@intel.com,
	harita.chilukuri@intel.com, douglas.w.styner@intel.com,
	peter.xihong.wang@intel.com, hubert.nueckel@intel.com,
	chris.mason@oracle.com, srostedt@redhat.com,
	linux-scsi@vger.kernel.org, andrew.vasquez@qlogic.com,
	anirban.chakraborty@qlogic.com, mingo@elte.hu
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761745AbZAWJqw@vger.kernel.org>
In-Reply-To: <1232699401.11429.163.camel@ymzhang>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2009-01-23 at 16:30 +0800, Zhang, Yanmin wrote:
> On Fri, 2009-01-23 at 10:06 +0200, Pekka Enberg wrote:
> > On Fri, 2009-01-23 at 08:52 +0200, Pekka Enberg wrote:
> > > > 1) If I start CPU_NUM clients and servers, SLUB's result is about 2% better than SLQB's;
> > > > 2) If I start 1 clinet and 1 server, and bind them to different physical cpu, SLQB's result
> > > > is about 10% better than SLUB's.
> > > > 
> > > > I don't know why there is still 10% difference with item 2). Maybe cachemiss causes it?
> > > 
> > > Maybe we can use the perfstat and/or kerneltop utilities of the new perf 
> > > counters patch to diagnose this:
> > > 
> > > http://lkml.org/lkml/2009/1/21/273
> > > 
> > > And do oprofile, of course. Thanks!
> > 
> > I assume binding the client and the server to different physical CPUs
> > also  means that the SKB is always allocated on CPU 1 and freed on CPU
> > 2? If so, we will be taking the __slab_free() slow path all the time on
> > kfree() which will cause cache effects, no doubt.
> > 
> > But there's another potential performance hit we're taking because the
> > object size of the cache is so big. As allocations from CPU 1 keep
> > coming in, we need to allocate new pages and unfreeze the per-cpu page.
> > That in turn causes __slab_free() to be more eager to discard the slab
> > (see the PageSlubFrozen check there).
> > 
> > So before going for cache profiling, I'd really like to see an oprofile
> > report. I suspect we're still going to see much more page allocator
> > activity
> Theoretically, it should, but oprofile doesn't show that.

That's bit surprising, actually. FWIW, I've included a patch for empty
slab lists. But it's probably not going to help here.

> >  there than with SLAB or SLQB which is why we're still behaving
> > so badly here.
> 
> oprofile output with 2.6.29-rc2-slubrevertlarge:
> CPU: Core 2, speed 2666.71 MHz (estimated)
> Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with a unit mask of 0x00 (Unhalted core cycles) count 100000
> samples  %        app name                 symbol name
> 132779   32.9951  vmlinux                  copy_user_generic_string
> 25334     6.2954  vmlinux                  schedule
> 21032     5.2264  vmlinux                  tg_shares_up
> 17175     4.2679  vmlinux                  __skb_recv_datagram
> 9091      2.2591  vmlinux                  sock_def_readable
> 8934      2.2201  vmlinux                  mwait_idle
> 8796      2.1858  vmlinux                  try_to_wake_up
> 6940      1.7246  vmlinux                  __slab_free
> 
> #slaninfo -AD
> Name                   Objects    Alloc     Free   %Fast
> :0000256                  1643  5215544  5214027  94   0 
> kmalloc-8192                28  5189576  5189560   0   0 
> :0000168                  2631   141466   138976  92  28 
> :0004096                  1452    88697    87269  99  96 
> :0000192                  3402    63050    59732  89  11 
> :0000064                  6265    46611    40721  98  82 
> :0000128                  1895    30429    28654  93  32 

Looking at __slab_free(), unless page->inuse is constantly zero and we
discard the slab, it really is just cache effects (10% sounds like a
lot, though!). AFAICT, the only way to optimize that is with Christoph's
unfinished pointer freelists patches or with a remote free list like in
SLQB.

		Pekka

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 3bd3662..41a4c1a 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -48,6 +48,9 @@ struct kmem_cache_node {
 	unsigned long nr_partial;
 	unsigned long min_partial;
 	struct list_head partial;
+	unsigned long nr_empty;
+	unsigned long max_empty;
+	struct list_head empty;
 #ifdef CONFIG_SLUB_DEBUG
 	atomic_long_t nr_slabs;
 	atomic_long_t total_objects;
diff --git a/mm/slub.c b/mm/slub.c
index 8fad23f..5a12597 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -134,6 +134,11 @@
  */
 #define MAX_PARTIAL 10
 
+/*
+ * Maximum number of empty slabs.
+ */
+#define MAX_EMPTY 1
+
 #define DEBUG_DEFAULT_FLAGS (SLAB_DEBUG_FREE | SLAB_RED_ZONE | \
 				SLAB_POISON | SLAB_STORE_USER)
 
@@ -1205,6 +1210,24 @@ static void discard_slab(struct kmem_cache *s, struct page *page)
 	free_slab(s, page);
 }
 
+static void discard_or_cache_slab(struct kmem_cache *s, struct page *page)
+{
+	struct kmem_cache_node *n;
+	int node;
+
+	node = page_to_nid(page);
+	n = get_node(s, node);
+
+	dec_slabs_node(s, node, page->objects);
+
+	if (likely(n->nr_empty >= n->max_empty)) {
+		free_slab(s, page);
+	} else {
+		n->nr_empty++;
+		list_add(&page->lru, &n->partial);
+	}
+}
+
 /*
  * Per slab locking using the pagelock
  */
@@ -1252,7 +1275,7 @@ static void remove_partial(struct kmem_cache *s, struct page *page)
 }
 
 /*
- * Lock slab and remove from the partial list.
+ * Lock slab and remove from the partial or empty list.
  *
  * Must hold list_lock.
  */
@@ -1261,7 +1284,6 @@ static inline int lock_and_freeze_slab(struct kmem_cache_node *n,
 {
 	if (slab_trylock(page)) {
 		list_del(&page->lru);
-		n->nr_partial--;
 		__SetPageSlubFrozen(page);
 		return 1;
 	}
@@ -1271,7 +1293,7 @@ static inline int lock_and_freeze_slab(struct kmem_cache_node *n,
 /*
  * Try to allocate a partial slab from a specific node.
  */
-static struct page *get_partial_node(struct kmem_cache_node *n)
+static struct page *get_partial_or_empty_node(struct kmem_cache_node *n)
 {
 	struct page *page;
 
@@ -1281,13 +1303,22 @@ static struct page *get_partial_node(struct kmem_cache_node *n)
 	 * partial slab and there is none available then get_partials()
 	 * will return NULL.
 	 */
-	if (!n || !n->nr_partial)
+	if (!n || (!n->nr_partial && !n->nr_empty))
 		return NULL;
 
 	spin_lock(&n->list_lock);
+
 	list_for_each_entry(page, &n->partial, lru)
-		if (lock_and_freeze_slab(n, page))
+		if (lock_and_freeze_slab(n, page)) {
+			n->nr_partial--;
+			goto out;
+		}
+
+	list_for_each_entry(page, &n->empty, lru)
+		if (lock_and_freeze_slab(n, page)) {
+			n->nr_empty--;
 			goto out;
+		}
 	page = NULL;
 out:
 	spin_unlock(&n->list_lock);
@@ -1297,7 +1328,7 @@ out:
 /*
  * Get a page from somewhere. Search in increasing NUMA distances.
  */
-static struct page *get_any_partial(struct kmem_cache *s, gfp_t flags)
+static struct page *get_any_partial_or_empty(struct kmem_cache *s, gfp_t flags)
 {
 #ifdef CONFIG_NUMA
 	struct zonelist *zonelist;
@@ -1336,7 +1367,7 @@ static struct page *get_any_partial(struct kmem_cache *s, gfp_t flags)
 
 		if (n && cpuset_zone_allowed_hardwall(zone, flags) &&
 				n->nr_partial > n->min_partial) {
-			page = get_partial_node(n);
+			page = get_partial_or_empty_node(n);
 			if (page)
 				return page;
 		}
@@ -1346,18 +1377,19 @@ static struct page *get_any_partial(struct kmem_cache *s, gfp_t flags)
 }
 
 /*
- * Get a partial page, lock it and return it.
+ * Get a partial or empty page, lock it and return it.
  */
-static struct page *get_partial(struct kmem_cache *s, gfp_t flags, int node)
+static struct page *
+get_partial_or_empty(struct kmem_cache *s, gfp_t flags, int node)
 {
 	struct page *page;
 	int searchnode = (node == -1) ? numa_node_id() : node;
 
-	page = get_partial_node(get_node(s, searchnode));
+	page = get_partial_or_empty_node(get_node(s, searchnode));
 	if (page || (flags & __GFP_THISNODE))
 		return page;
 
-	return get_any_partial(s, flags);
+	return get_any_partial_or_empty(s, flags);
 }
 
 /*
@@ -1403,7 +1435,7 @@ static void unfreeze_slab(struct kmem_cache *s, struct page *page, int tail)
 		} else {
 			slab_unlock(page);
 			stat(get_cpu_slab(s, raw_smp_processor_id()), FREE_SLAB);
-			discard_slab(s, page);
+			discard_or_cache_slab(s, page);
 		}
 	}
 }
@@ -1542,7 +1574,7 @@ another_slab:
 	deactivate_slab(s, c);
 
 new_slab:
-	new = get_partial(s, gfpflags, node);
+	new = get_partial_or_empty(s, gfpflags, node);
 	if (new) {
 		c->page = new;
 		stat(c, ALLOC_FROM_PARTIAL);
@@ -1693,7 +1725,7 @@ slab_empty:
 	}
 	slab_unlock(page);
 	stat(c, FREE_SLAB);
-	discard_slab(s, page);
+	discard_or_cache_slab(s, page);
 	return;
 
 debug:
@@ -1927,6 +1959,8 @@ static void init_kmem_cache_cpu(struct kmem_cache *s,
 static void
 init_kmem_cache_node(struct kmem_cache_node *n, struct kmem_cache *s)
 {
+	spin_lock_init(&n->list_lock);
+
 	n->nr_partial = 0;
 
 	/*
@@ -1939,8 +1973,18 @@ init_kmem_cache_node(struct kmem_cache_node *n, struct kmem_cache *s)
 	else if (n->min_partial > MAX_PARTIAL)
 		n->min_partial = MAX_PARTIAL;
 
-	spin_lock_init(&n->list_lock);
 	INIT_LIST_HEAD(&n->partial);
+
+	n->nr_empty = 0;
+	/*
+	 * XXX: This needs to take object size into account. We don't need
+	 * empty slabs for caches which will have plenty of partial slabs
+	 * available. Only caches that have either full or empty slabs need
+	 * this kind of optimization.
+	 */
+	n->max_empty = MAX_EMPTY;
+	INIT_LIST_HEAD(&n->empty);
+
 #ifdef CONFIG_SLUB_DEBUG
 	atomic_long_set(&n->nr_slabs, 0);
 	atomic_long_set(&n->total_objects, 0);
@@ -2427,6 +2471,32 @@ static void free_partial(struct kmem_cache *s, struct kmem_cache_node *n)
 	spin_unlock_irqrestore(&n->list_lock, flags);
 }
 
+static void free_empty_slabs(struct kmem_cache *s)
+{
+	int node;
+
+	for_each_node_state(node, N_NORMAL_MEMORY) {
+		struct kmem_cache_node *n;
+		struct page *page, *t;
+		unsigned long flags;
+
+		n = get_node(s, node);
+
+		if (!n->nr_empty)
+			continue;
+
+		spin_lock_irqsave(&n->list_lock, flags);
+
+		list_for_each_entry_safe(page, t, &n->empty, lru) {
+			list_del(&page->lru);
+			n->nr_empty--;
+
+			free_slab(s, page);
+		}
+		spin_unlock_irqrestore(&n->list_lock, flags);
+	}
+}
+
 /*
  * Release all resources used by a slab cache.
  */
@@ -2436,6 +2506,8 @@ static inline int kmem_cache_close(struct kmem_cache *s)
 
 	flush_all(s);
 
+	free_empty_slabs(s);
+
 	/* Attempt to free all objects */
 	free_kmem_cache_cpus(s);
 	for_each_node_state(node, N_NORMAL_MEMORY) {
@@ -2765,6 +2837,7 @@ int kmem_cache_shrink(struct kmem_cache *s)
 		return -ENOMEM;
 
 	flush_all(s);
+	free_empty_slabs(s);
 	for_each_node_state(node, N_NORMAL_MEMORY) {
 		n = get_node(s, node);
 
