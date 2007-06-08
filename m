From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH][RFC] network splice receive
Date: Fri, 8 Jun 2007 17:58:19 +0400
Message-ID: <20070608135819.GA14302@2ka.mipt.ru>
References: <20070607105159.GV4735@kernel.dk> <20070607145818.GA26491@2ka.mipt.ru> <20070608074823.GG7341@kernel.dk> <20070608.010629.52902577.davem@davemloft.net> <20070608083853.GH7341@kernel.dk> <20070608085620.GC11488@2ka.mipt.ru> <20070608090439.GK7341@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:33716 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S968607AbXFHOEg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jun 2007 10:04:36 -0400
Content-Disposition: inline
In-Reply-To: <20070608090439.GK7341@kernel.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 08, 2007 at 11:04:40AM +0200, Jens Axboe (jens.axboe@oracle.com) wrote:
> OK, so a delayed empty of the pipe could end up causing packet drops
> elsewhere due to allocation exhaustion?

Yes.

> > > We can grow the pipe, should we have to. So instead of blocking waiting
> > > on reader consumption, we can extend the size of the pipe and keep
> > > going.
> > 
> > I have a code, which roughly works (but I will test it some more), which
> > just introduces reference counters for slab pages, so that the would not
> > be actually freed via page reclaim, but only after reference counters
> > are dropped. That forced changes in mm/slab.c so likely it is
> > unacceptible solution, but it is interesting as is.
> 
> Hmm, still seems like it's working around the problem. We essentially
> just need to ensure that the data doesn't get _reused_, not just freed.
> It doesn't help holding a reference to the page, if someone else just
> reuses it and fills it with other data before it has been consumed and
> released by the pipe buffer operations.
> 
> That's why I thought the skb referencing was the better idea, then we
> don't have to care about the backing of the skb either. Provided that
> preventing the free of the skb before the pipe buffer has been consumed
> guarantees that the contents aren't reused.

It is not only better idea, it is the only correct one.
Attached patch for interested reader, which does slab pages accounting,
but it is broken. It does not fires up with kernel bug, but it fills
output file with random garbage from reused and dirtied pages. And I do
not know why, but received file is always smaller than file being sent
(when file has resonable size like 10mb, with 4-40kb filesize things
seems to be ok).

I've started skb referencing work, let's see where this will end up.

diff --git a/fs/splice.c b/fs/splice.c
index 928bea0..742e1ee 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -29,6 +29,18 @@
 #include <linux/syscalls.h>
 #include <linux/uio.h>
 
+extern void slab_change_usage(struct page *p);
+
+static inline void splice_page_release(struct page *p)
+{
+	struct page *head = p->first_page;
+	if (!PageSlab(head))
+		page_cache_release(p);
+	else {
+		slab_change_usage(head);
+	}
+}
+
 /*
  * Attempt to steal a page from a pipe buffer. This should perhaps go into
  * a vm helper function, it's already simplified quite a bit by the
@@ -81,7 +93,7 @@ static int page_cache_pipe_buf_steal(struct pipe_inode_info *pipe,
 static void page_cache_pipe_buf_release(struct pipe_inode_info *pipe,
 					struct pipe_buffer *buf)
 {
-	page_cache_release(buf->page);
+	splice_page_release(buf->page);
 	buf->flags &= ~PIPE_BUF_FLAG_LRU;
 }
 
@@ -246,7 +258,7 @@ ssize_t splice_to_pipe(struct pipe_inode_info *pipe,
 	}
 
 	while (page_nr < spd->nr_pages)
-		page_cache_release(spd->pages[page_nr++]);
+		splice_page_release(spd->pages[page_nr++]);
 
 	return ret;
 }
@@ -322,7 +334,7 @@ __generic_file_splice_read(struct file *in, loff_t *ppos,
 			error = add_to_page_cache_lru(page, mapping, index,
 					      GFP_KERNEL);
 			if (unlikely(error)) {
-				page_cache_release(page);
+				splice_page_release(page);
 				if (error == -EEXIST)
 					continue;
 				break;
@@ -448,7 +460,7 @@ fill_it:
 	 * we got, 'nr_pages' is how many pages are in the map.
 	 */
 	while (page_nr < nr_pages)
-		page_cache_release(pages[page_nr++]);
+		splice_page_release(pages[page_nr++]);
 
 	if (spd.nr_pages)
 		return splice_to_pipe(pipe, &spd);
@@ -604,7 +616,7 @@ find_page:
 
 		if (ret != AOP_TRUNCATED_PAGE)
 			unlock_page(page);
-		page_cache_release(page);
+		splice_page_release(page);
 		if (ret == AOP_TRUNCATED_PAGE)
 			goto find_page;
 
@@ -634,7 +646,7 @@ find_page:
 	ret = mapping->a_ops->commit_write(file, page, offset, offset+this_len);
 	if (ret) {
 		if (ret == AOP_TRUNCATED_PAGE) {
-			page_cache_release(page);
+			splice_page_release(page);
 			goto find_page;
 		}
 		if (ret < 0)
@@ -651,7 +663,7 @@ find_page:
 	 */
 	mark_page_accessed(page);
 out:
-	page_cache_release(page);
+	splice_page_release(page);
 	unlock_page(page);
 out_ret:
 	return ret;
diff --git a/mm/slab.c b/mm/slab.c
index 2e71a32..673383d 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1649,8 +1649,12 @@ static void *kmem_getpages(struct kmem_cache *cachep, gfp_t flags, int nodeid)
 	else
 		add_zone_page_state(page_zone(page),
 			NR_SLAB_UNRECLAIMABLE, nr_pages);
-	for (i = 0; i < nr_pages; i++)
-		__SetPageSlab(page + i);
+	for (i = 0; i < nr_pages; i++) {
+		struct page *p = page + i;
+		__SetPageSlab(p);
+		p->first_page = page;
+	}
+	atomic_inc(&page->_count);
 	return page_address(page);
 }
 
@@ -1662,6 +1666,12 @@ static void kmem_freepages(struct kmem_cache *cachep, void *addr)
 	unsigned long i = (1 << cachep->gfporder);
 	struct page *page = virt_to_page(addr);
 	const unsigned long nr_freed = i;
+	struct page *mp = page->first_page;
+
+	if (atomic_dec_return(&mp->_count) != 1) {
+		printk("%s: page: %p, head: %p, order: %d, count: %d.\n", __func__, page, mp, cachep->gfporder, atomic_read(&mp->_count));
+		return;
+	}
 
 	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
 		sub_zone_page_state(page_zone(page),
@@ -1679,6 +1689,36 @@ static void kmem_freepages(struct kmem_cache *cachep, void *addr)
 	free_pages((unsigned long)addr, cachep->gfporder);
 }
 
+void slab_change_usage(struct page *page)
+{
+	struct kmem_cache *cachep = page_get_cache(page);
+	unsigned long i = (1 << cachep->gfporder);
+	const unsigned long nr_freed = i;
+	struct page *p = page = page->first_page;
+
+	//printk("%s: page: %p, count: %d, order: %u.\n", __func__, page, atomic_read(&page->_count), cachep->gfporder);
+
+	if (atomic_dec_return(&page->_count) != 1)
+		return;
+	
+	//printk("%s: page: %p, count: %d, freeing.\n", __func__, page, atomic_read(&page->_count));
+
+	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
+		sub_zone_page_state(page_zone(page),
+				NR_SLAB_RECLAIMABLE, nr_freed);
+	else
+		sub_zone_page_state(page_zone(page),
+				NR_SLAB_UNRECLAIMABLE, nr_freed);
+	while (i--) {
+		BUG_ON(!PageSlab(p));
+		__ClearPageSlab(p);
+		p++;
+	}
+	if (current->reclaim_state)
+		current->reclaim_state->reclaimed_slab += nr_freed;
+	__free_pages(page, cachep->gfporder);
+}
+
 static void kmem_rcu_free(struct rcu_head *head)
 {
 	struct slab_rcu *slab_rcu = (struct slab_rcu *)head;
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 0312bd3..7c027cb 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -72,13 +72,20 @@
 static struct kmem_cache *skbuff_head_cache __read_mostly;
 static struct kmem_cache *skbuff_fclone_cache __read_mostly;
 
+extern void slab_change_usage(struct page *p);
+
 static void sock_pipe_buf_release(struct pipe_inode_info *pipe,
 				  struct pipe_buffer *buf)
 {
+	struct page *p = buf->page->first_page;
 #ifdef NET_COPY_SPLICE
 	__free_page(buf->page);
 #else
-	put_page(buf->page);
+	if (!PageSlab(p))
+		put_page(buf->page);
+	else {
+		slab_change_usage(p);
+	}
 #endif
 }
 
@@ -1162,8 +1169,12 @@ static inline int spd_fill_page(struct splice_pipe_desc *spd, struct page *page,
 
 	memcpy(page_address(p) + offset, page_address(page) + offset, len);
 #else
-	p = page;
-	get_page(p);
+	p = page->first_page;
+	atomic_inc(&p->_count);
+#if 0
+	printk("%s: p: %p, page: %p, slab: %d, head_count: %d, page_count: %d.\n", 
+			__func__, p, page, PageSlab(p), atomic_read(&p->_count), atomic_read(&page->_count));
+#endif
 #endif
 
 	spd->pages[spd->nr_pages] = p;
@@ -1194,7 +1205,7 @@ static int __skb_splice_bits(const struct sk_buff *skb, unsigned int *offset,
 	for (seg = 0; len < headlen && *total_len; len += PAGE_SIZE - poff) {
 		void *p = skb->data + len;
 
-		poff = (unsigned long) p & (PAGE_SIZE - 1);
+		poff = offset_in_page(p);
 		plen = min_t(unsigned, headlen - len, PAGE_SIZE - poff);
 
 		if (*offset) {
@@ -1209,7 +1220,10 @@ static int __skb_splice_bits(const struct sk_buff *skb, unsigned int *offset,
 
 		if (plen > *total_len)
 			plen = *total_len;
-
+#if 0
+		printk("%s: skb_data: %p, ptr: %p, len: %u, headlen: %u, page: %p, plen: %u, poff: %u.\n",
+				__func__, skb->data, p, len, headlen, virt_to_page(p), plen, poff);
+#endif
 		if (spd_fill_page(spd, virt_to_page(p), plen, poff))
 			break;
 


> -- 
> Jens Axboe

-- 
	Evgeniy Polyakov
