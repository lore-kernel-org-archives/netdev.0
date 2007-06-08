From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH][RFC] network splice receive
Date: Fri, 8 Jun 2007 19:30:11 +0400
Message-ID: <20070608153011.GA2375@2ka.mipt.ru>
References: <20070607105159.GV4735@kernel.dk> <20070607145818.GA26491@2ka.mipt.ru> <20070608074823.GG7341@kernel.dk> <20070608.010629.52902577.davem@davemloft.net> <20070608083853.GH7341@kernel.dk> <20070608085620.GC11488@2ka.mipt.ru> <20070608090439.GK7341@kernel.dk> <20070608135819.GA14302@2ka.mipt.ru> <20070608141452.GR7341@kernel.dk> <20070608145724.GA14561@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:40059 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763697AbXFHPbE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jun 2007 11:31:04 -0400
Content-Disposition: inline
In-Reply-To: <20070608145724.GA14561@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 08, 2007 at 06:57:25PM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> I will try some things for the nearest 30-60 minutes, and then will move to
> canoe trip until thuesday, so will not be able to work on this idea.

Ok, replacing in fs/splice.c every page_cache_release() with
static void splice_page_release(struct page *p)
{
	if (!PageSlab(p))
		page_cache_release(p);
}

and putting cloned skb into private field instead of 
original on in spd_fill_page() ends up without kernel hung.

I'm not sure it is correct, that page can be released in fs/splice.c
without calling any callback from network code, when network data is
being processed.

Size of the received file is bigger than file sent, file contains repeated
blocks of data sometimes. Cloned skb usage is likely too big overhead,
although for receiving fast clone is unused in most cases, so there
might be some gain.

Attached your patch with above changes.

diff --git a/fs/splice.c b/fs/splice.c
index 928bea0..a75dc56 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -29,6 +29,12 @@
 #include <linux/syscalls.h>
 #include <linux/uio.h>
 
+static void splice_page_release(struct page *p)
+{
+	if (!PageSlab(p))
+		page_cache_release(p);
+}
+
 /*
  * Attempt to steal a page from a pipe buffer. This should perhaps go into
  * a vm helper function, it's already simplified quite a bit by the
@@ -81,7 +87,7 @@ static int page_cache_pipe_buf_steal(struct pipe_inode_info *pipe,
 static void page_cache_pipe_buf_release(struct pipe_inode_info *pipe,
 					struct pipe_buffer *buf)
 {
-	page_cache_release(buf->page);
+	splice_page_release(buf->page);
 	buf->flags &= ~PIPE_BUF_FLAG_LRU;
 }
 
@@ -191,6 +197,7 @@ ssize_t splice_to_pipe(struct pipe_inode_info *pipe,
 			buf->page = spd->pages[page_nr];
 			buf->offset = spd->partial[page_nr].offset;
 			buf->len = spd->partial[page_nr].len;
+			buf->private = spd->partial[page_nr].private;
 			buf->ops = spd->ops;
 			if (spd->flags & SPLICE_F_GIFT)
 				buf->flags |= PIPE_BUF_FLAG_GIFT;
@@ -246,7 +253,7 @@ ssize_t splice_to_pipe(struct pipe_inode_info *pipe,
 	}
 
 	while (page_nr < spd->nr_pages)
-		page_cache_release(spd->pages[page_nr++]);
+		splice_page_release(spd->pages[page_nr++]);
 
 	return ret;
 }
@@ -322,7 +329,7 @@ __generic_file_splice_read(struct file *in, loff_t *ppos,
 			error = add_to_page_cache_lru(page, mapping, index,
 					      GFP_KERNEL);
 			if (unlikely(error)) {
-				page_cache_release(page);
+				splice_page_release(page);
 				if (error == -EEXIST)
 					continue;
 				break;
@@ -448,7 +455,7 @@ fill_it:
 	 * we got, 'nr_pages' is how many pages are in the map.
 	 */
 	while (page_nr < nr_pages)
-		page_cache_release(pages[page_nr++]);
+		splice_page_release(pages[page_nr++]);
 
 	if (spd.nr_pages)
 		return splice_to_pipe(pipe, &spd);
@@ -604,7 +611,7 @@ find_page:
 
 		if (ret != AOP_TRUNCATED_PAGE)
 			unlock_page(page);
-		page_cache_release(page);
+		splice_page_release(page);
 		if (ret == AOP_TRUNCATED_PAGE)
 			goto find_page;
 
@@ -634,7 +641,7 @@ find_page:
 	ret = mapping->a_ops->commit_write(file, page, offset, offset+this_len);
 	if (ret) {
 		if (ret == AOP_TRUNCATED_PAGE) {
-			page_cache_release(page);
+			splice_page_release(page);
 			goto find_page;
 		}
 		if (ret < 0)
@@ -651,7 +658,7 @@ find_page:
 	 */
 	mark_page_accessed(page);
 out:
-	page_cache_release(page);
+	splice_page_release(page);
 	unlock_page(page);
 out_ret:
 	return ret;
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
index 0312bd3..3306d90 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -78,7 +78,9 @@ static void sock_pipe_buf_release(struct pipe_inode_info *pipe,
 #ifdef NET_COPY_SPLICE
 	__free_page(buf->page);
 #else
-	put_page(buf->page);
+	struct sk_buff *skb = (struct sk_buff *) buf->private;
+
+	kfree_skb(skb);
 #endif
 }
 
@@ -1148,9 +1150,15 @@ fault:
  * Fill page/offset/length into spd, if it can hold more pages.
  */
 static inline int spd_fill_page(struct splice_pipe_desc *spd, struct page *page,
-				unsigned int len, unsigned int offset)
+				unsigned int len, unsigned int offset,
+				struct sk_buff *__skb)
 {
 	struct page *p;
+	struct sk_buff *skb = skb_clone(__skb, GFP_KERNEL);
+
+	if (!skb)
+		return 1;
+
 
 	if (unlikely(spd->nr_pages == PIPE_BUFFERS))
 		return 1;
@@ -1163,12 +1171,12 @@ static inline int spd_fill_page(struct splice_pipe_desc *spd, struct page *page,
 	memcpy(page_address(p) + offset, page_address(page) + offset, len);
 #else
 	p = page;
-	get_page(p);
 #endif
 
 	spd->pages[spd->nr_pages] = p;
 	spd->partial[spd->nr_pages].len = len;
 	spd->partial[spd->nr_pages].offset = offset;
+	spd->partial[spd->nr_pages].private = (unsigned long) skb;
 	spd->nr_pages++;
 	return 0;
 }
@@ -1177,7 +1185,7 @@ static inline int spd_fill_page(struct splice_pipe_desc *spd, struct page *page,
  * Map linear and fragment data from the skb to spd. Returns number of
  * pages mapped.
  */
-static int __skb_splice_bits(const struct sk_buff *skb, unsigned int *offset,
+static int __skb_splice_bits(struct sk_buff *skb, unsigned int *offset,
 			     unsigned int *total_len,
 			     struct splice_pipe_desc *spd)
 {
@@ -1210,7 +1218,7 @@ static int __skb_splice_bits(const struct sk_buff *skb, unsigned int *offset,
 		if (plen > *total_len)
 			plen = *total_len;
 
-		if (spd_fill_page(spd, virt_to_page(p), plen, poff))
+		if (spd_fill_page(spd, virt_to_page(p), plen, poff, skb))
 			break;
 
 		*total_len -= plen;
@@ -1238,7 +1246,7 @@ static int __skb_splice_bits(const struct sk_buff *skb, unsigned int *offset,
 		if (plen > *total_len)
 			plen = *total_len;
 
-		if (spd_fill_page(spd, f->page, plen, poff))
+		if (spd_fill_page(spd, f->page, plen, poff, skb))
 			break;
 
 		*total_len -= plen;
@@ -1253,7 +1261,7 @@ static int __skb_splice_bits(const struct sk_buff *skb, unsigned int *offset,
  * the frag list, if such a thing exists. We'd probably need to recurse to
  * handle that cleanly.
  */
-int skb_splice_bits(const struct sk_buff *skb, unsigned int offset,
+int skb_splice_bits(struct sk_buff *skb, unsigned int offset,
 		    struct pipe_inode_info *pipe, unsigned int tlen,
 		    unsigned int flags)
 {

-- 
	Evgeniy Polyakov
