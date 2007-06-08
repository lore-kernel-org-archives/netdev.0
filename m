From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [PATCH][RFC] network splice receive
Date: Fri, 8 Jun 2007 16:14:52 +0200
Message-ID: <20070608141452.GR7341@kernel.dk>
References: <20070607105159.GV4735@kernel.dk> <20070607145818.GA26491@2ka.mipt.ru> <20070608074823.GG7341@kernel.dk> <20070608.010629.52902577.davem@davemloft.net> <20070608083853.GH7341@kernel.dk> <20070608085620.GC11488@2ka.mipt.ru> <20070608090439.GK7341@kernel.dk> <20070608135819.GA14302@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from brick.kernel.dk ([80.160.20.94]:2316 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S968919AbXFHOQb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jun 2007 10:16:31 -0400
Content-Disposition: inline
In-Reply-To: <20070608135819.GA14302@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 08 2007, Evgeniy Polyakov wrote:
> On Fri, Jun 08, 2007 at 11:04:40AM +0200, Jens Axboe (jens.axboe@oracle.com) wrote:
> > OK, so a delayed empty of the pipe could end up causing packet drops
> > elsewhere due to allocation exhaustion?
> 
> Yes.
> 
> > > > We can grow the pipe, should we have to. So instead of blocking waiting
> > > > on reader consumption, we can extend the size of the pipe and keep
> > > > going.
> > > 
> > > I have a code, which roughly works (but I will test it some more), which
> > > just introduces reference counters for slab pages, so that the would not
> > > be actually freed via page reclaim, but only after reference counters
> > > are dropped. That forced changes in mm/slab.c so likely it is
> > > unacceptible solution, but it is interesting as is.
> > 
> > Hmm, still seems like it's working around the problem. We essentially
> > just need to ensure that the data doesn't get _reused_, not just freed.
> > It doesn't help holding a reference to the page, if someone else just
> > reuses it and fills it with other data before it has been consumed and
> > released by the pipe buffer operations.
> > 
> > That's why I thought the skb referencing was the better idea, then we
> > don't have to care about the backing of the skb either. Provided that
> > preventing the free of the skb before the pipe buffer has been consumed
> > guarantees that the contents aren't reused.
> 
> It is not only better idea, it is the only correct one.
> Attached patch for interested reader, which does slab pages accounting,
> but it is broken. It does not fires up with kernel bug, but it fills
> output file with random garbage from reused and dirtied pages. And I do
> not know why, but received file is always smaller than file being sent
> (when file has resonable size like 10mb, with 4-40kb filesize things
> seems to be ok).
> 
> I've started skb referencing work, let's see where this will end up.

Here's a start, for the splice side at least of storing a buf-private
entity with the ops.

diff --git a/fs/splice.c b/fs/splice.c
index 90588a8..f24e367 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -191,6 +191,7 @@ ssize_t splice_to_pipe(struct pipe_inode_info *pipe,
 			buf->page = spd->pages[page_nr];
 			buf->offset = spd->partial[page_nr].offset;
 			buf->len = spd->partial[page_nr].len;
+			buf->private = spd->partial[page_nr].private;
 			buf->ops = spd->ops;
 			if (spd->flags & SPLICE_F_GIFT)
 				buf->flags |= PIPE_BUF_FLAG_GIFT;
diff --git a/include/linux/pipe_fs_i.h b/include/linux/pipe_fs_i.h
index 7ba228d..4409167 100644
--- a/include/linux/pipe_fs_i.h
+++ b/include/linux/pipe_fs_i.h
@@ -14,6 +14,7 @@ struct pipe_buffer {
 	unsigned int offset, len;
 	const struct pipe_buf_operations *ops;
 	unsigned int flags;
+	unsigned long private;
 };
 
 struct pipe_inode_info {
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 619dcf5..64e3eed 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1504,7 +1504,7 @@ extern int	       skb_store_bits(struct sk_buff *skb, int offset,
 extern __wsum	       skb_copy_and_csum_bits(const struct sk_buff *skb,
 					      int offset, u8 *to, int len,
 					      __wsum csum);
-extern int             skb_splice_bits(const struct sk_buff *skb,
+extern int             skb_splice_bits(struct sk_buff *skb,
 						unsigned int offset,
 						struct pipe_inode_info *pipe,
 						unsigned int len,
diff --git a/include/linux/splice.h b/include/linux/splice.h
index b3f1528..1a1182b 100644
--- a/include/linux/splice.h
+++ b/include/linux/splice.h
@@ -41,6 +41,7 @@ struct splice_desc {
 struct partial_page {
 	unsigned int offset;
 	unsigned int len;
+	unsigned long private;
 };
 
 /*
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index d2b2547..7d9ec9e 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -78,7 +78,10 @@ static void sock_pipe_buf_release(struct pipe_inode_info *pipe,
 #ifdef NET_COPY_SPLICE
 	__free_page(buf->page);
 #else
-	put_page(buf->page);
+	struct sk_buff *skb = (struct sk_buff *) buf->private;
+
+	kfree_skb(skb);
+	//put_page(buf->page);
 #endif
 }
 
@@ -1148,7 +1151,8 @@ fault:
  * Fill page/offset/length into spd, if it can hold more pages.
  */
 static inline int spd_fill_page(struct splice_pipe_desc *spd, struct page *page,
-				unsigned int len, unsigned int offset)
+				unsigned int len, unsigned int offset,
+				struct sk_buff *skb)
 {
 	struct page *p;
 
@@ -1163,12 +1167,14 @@ static inline int spd_fill_page(struct splice_pipe_desc *spd, struct page *page,
 	memcpy(page_address(p) + offset, page_address(page) + offset, len);
 #else
 	p = page;
-	get_page(p);
+	skb_get(skb);
+	//get_page(p);
 #endif
 
 	spd->pages[spd->nr_pages] = p;
 	spd->partial[spd->nr_pages].len = len;
 	spd->partial[spd->nr_pages].offset = offset;
+	spd->partial[spd->nr_pages].private = (unsigned long) skb;
 	spd->nr_pages++;
 	return 0;
 }
@@ -1177,7 +1183,7 @@ static inline int spd_fill_page(struct splice_pipe_desc *spd, struct page *page,
  * Map linear and fragment data from the skb to spd. Returns number of
  * pages mapped.
  */
-static int __skb_splice_bits(const struct sk_buff *skb, unsigned int *offset,
+static int __skb_splice_bits(struct sk_buff *skb, unsigned int *offset,
 			     unsigned int *total_len,
 			     struct splice_pipe_desc *spd)
 {
@@ -1210,7 +1216,7 @@ static int __skb_splice_bits(const struct sk_buff *skb, unsigned int *offset,
 		if (plen > *total_len)
 			plen = *total_len;
 
-		if (spd_fill_page(spd, virt_to_page(p), plen, poff))
+		if (spd_fill_page(spd, virt_to_page(p), plen, poff, skb))
 			break;
 
 		*total_len -= plen;
@@ -1238,7 +1244,7 @@ static int __skb_splice_bits(const struct sk_buff *skb, unsigned int *offset,
 		if (plen > *total_len)
 			plen = *total_len;
 
-		if (spd_fill_page(spd, f->page, plen, poff))
+		if (spd_fill_page(spd, f->page, plen, poff, skb))
 			break;
 
 		*total_len -= plen;
@@ -1253,7 +1259,7 @@ static int __skb_splice_bits(const struct sk_buff *skb, unsigned int *offset,
  * the frag list, if such a thing exists. We'd probably need to recurse to
  * handle that cleanly.
  */
-int skb_splice_bits(const struct sk_buff *skb, unsigned int offset,
+int skb_splice_bits(struct sk_buff *skb, unsigned int offset,
 		    struct pipe_inode_info *pipe, unsigned int tlen,
 		    unsigned int flags)
 {

-- 
Jens Axboe

