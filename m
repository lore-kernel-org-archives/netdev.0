From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Thu, 15 Jan 2009 15:26:08 -0800 (PST)
Message-ID: <20090115.152608.89323697.davem@davemloft.net>
References: <20090114.012919.117682429.davem@davemloft.net>
	<20090115230331.GB1123@1wt.eu>
	<20090115231934.GA8328@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: w@1wt.eu, jarkao2@gmail.com, zbr@ioremap.net, dada1@cosmosbay.com,
	ben@zeus.com, mingo@elte.hu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53883
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759356AbZAOX0H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 18:26:07 -0500
In-Reply-To: <20090115231934.GA8328@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 16 Jan 2009 10:19:35 +1100

> On Fri, Jan 16, 2009 at 12:03:31AM +0100, Willy Tarreau wrote:
> > > +	if (linear) {
> > > +		page = linear_to_page(page, len, offset);
> > > +		if (!page)
> > > +			return 1;
> > > +	}
> > > +
> > >  	spd->pages[spd->nr_pages] = page;
> > >  	spd->partial[spd->nr_pages].len = len;
> > >  	spd->partial[spd->nr_pages].offset = offset;
> > > -	spd->partial[spd->nr_pages].private = (unsigned long) skb_get(skb);
> > >  	spd->nr_pages++;
> > > +	get_page(page);
> 
> This get_page needs to be moved into an else clause of the previous
> if block.

Yep, good catch Herbert.

New patch, this has the SKB clone removal as well:

net: Fix data corruption when splicing from sockets.

From: Jarek Poplawski <jarkao2@gmail.com>

The trick in socket splicing where we try to convert the skb->data
into a page based reference using virt_to_page() does not work so
well.

The idea is to pass the virt_to_page() reference via the pipe
buffer, and refcount the buffer using a SKB reference.

But if we are splicing from a socket to a socket (via sendpage)
this doesn't work.

The from side processing will grab the page (and SKB) references.
The sendpage() calls will grab page references only, return, and
then the from side processing completes and drops the SKB ref.

The page based reference to skb->data is not enough to keep the
kmalloc() buffer backing it from being reused.  Yet, that is
all that the socket send side has at this point.

This leads to data corruption if the skb->data buffer is reused
by SLAB before the send side socket actually gets the TX packet
out to the device.

The fix employed here is to simply allocate a page and copy the
skb->data bytes into that page.

This will hurt performance, but there is no clear way to fix this
properly without a copy at the present time, and it is important
to get rid of the data corruption.

With fixes from Herbert Xu.

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 65eac77..56272ac 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -73,17 +73,13 @@ static struct kmem_cache *skbuff_fclone_cache __read_mostly;
 static void sock_pipe_buf_release(struct pipe_inode_info *pipe,
 				  struct pipe_buffer *buf)
 {
-	struct sk_buff *skb = (struct sk_buff *) buf->private;
-
-	kfree_skb(skb);
+	put_page(buf->page);
 }
 
 static void sock_pipe_buf_get(struct pipe_inode_info *pipe,
 				struct pipe_buffer *buf)
 {
-	struct sk_buff *skb = (struct sk_buff *) buf->private;
-
-	skb_get(skb);
+	get_page(buf->page);
 }
 
 static int sock_pipe_buf_steal(struct pipe_inode_info *pipe,
@@ -1334,9 +1330,19 @@ fault:
  */
 static void sock_spd_release(struct splice_pipe_desc *spd, unsigned int i)
 {
-	struct sk_buff *skb = (struct sk_buff *) spd->partial[i].private;
+	put_page(spd->pages[i]);
+}
 
-	kfree_skb(skb);
+static inline struct page *linear_to_page(struct page *page, unsigned int len,
+					  unsigned int offset)
+{
+	struct page *p = alloc_pages(GFP_KERNEL, 0);
+
+	if (!p)
+		return NULL;
+	memcpy(page_address(p) + offset, page_address(page) + offset, len);
+
+	return p;
 }
 
 /*
@@ -1344,16 +1350,23 @@ static void sock_spd_release(struct splice_pipe_desc *spd, unsigned int i)
  */
 static inline int spd_fill_page(struct splice_pipe_desc *spd, struct page *page,
 				unsigned int len, unsigned int offset,
-				struct sk_buff *skb)
+				struct sk_buff *skb, int linear)
 {
 	if (unlikely(spd->nr_pages == PIPE_BUFFERS))
 		return 1;
 
+	if (linear) {
+		page = linear_to_page(page, len, offset);
+		if (!page)
+			return 1;
+	} else
+		get_page(page);
+
 	spd->pages[spd->nr_pages] = page;
 	spd->partial[spd->nr_pages].len = len;
 	spd->partial[spd->nr_pages].offset = offset;
-	spd->partial[spd->nr_pages].private = (unsigned long) skb_get(skb);
 	spd->nr_pages++;
+
 	return 0;
 }
 
@@ -1369,7 +1382,7 @@ static inline void __segment_seek(struct page **page, unsigned int *poff,
 static inline int __splice_segment(struct page *page, unsigned int poff,
 				   unsigned int plen, unsigned int *off,
 				   unsigned int *len, struct sk_buff *skb,
-				   struct splice_pipe_desc *spd)
+				   struct splice_pipe_desc *spd, int linear)
 {
 	if (!*len)
 		return 1;
@@ -1392,7 +1405,7 @@ static inline int __splice_segment(struct page *page, unsigned int poff,
 		/* the linear region may spread across several pages  */
 		flen = min_t(unsigned int, flen, PAGE_SIZE - poff);
 
-		if (spd_fill_page(spd, page, flen, poff, skb))
+		if (spd_fill_page(spd, page, flen, poff, skb, linear))
 			return 1;
 
 		__segment_seek(&page, &poff, &plen, flen);
@@ -1419,7 +1432,7 @@ static int __skb_splice_bits(struct sk_buff *skb, unsigned int *offset,
 	if (__splice_segment(virt_to_page(skb->data),
 			     (unsigned long) skb->data & (PAGE_SIZE - 1),
 			     skb_headlen(skb),
-			     offset, len, skb, spd))
+			     offset, len, skb, spd, 1))
 		return 1;
 
 	/*
@@ -1429,7 +1442,7 @@ static int __skb_splice_bits(struct sk_buff *skb, unsigned int *offset,
 		const skb_frag_t *f = &skb_shinfo(skb)->frags[seg];
 
 		if (__splice_segment(f->page, f->page_offset, f->size,
-				     offset, len, skb, spd))
+				     offset, len, skb, spd, 0))
 			return 1;
 	}
 
@@ -1442,7 +1455,7 @@ static int __skb_splice_bits(struct sk_buff *skb, unsigned int *offset,
  * the frag list, if such a thing exists. We'd probably need to recurse to
  * handle that cleanly.
  */
-int skb_splice_bits(struct sk_buff *__skb, unsigned int offset,
+int skb_splice_bits(struct sk_buff *skb, unsigned int offset,
 		    struct pipe_inode_info *pipe, unsigned int tlen,
 		    unsigned int flags)
 {
@@ -1455,16 +1468,6 @@ int skb_splice_bits(struct sk_buff *__skb, unsigned int offset,
 		.ops = &sock_pipe_buf_ops,
 		.spd_release = sock_spd_release,
 	};
-	struct sk_buff *skb;
-
-	/*
-	 * I'd love to avoid the clone here, but tcp_read_sock()
-	 * ignores reference counts and unconditonally kills the sk_buff
-	 * on return from the actor.
-	 */
-	skb = skb_clone(__skb, GFP_KERNEL);
-	if (unlikely(!skb))
-		return -ENOMEM;
 
 	/*
 	 * __skb_splice_bits() only fails if the output has no room left,
@@ -1488,15 +1491,9 @@ int skb_splice_bits(struct sk_buff *__skb, unsigned int offset,
 	}
 
 done:
-	/*
-	 * drop our reference to the clone, the pipe consumption will
-	 * drop the rest.
-	 */
-	kfree_skb(skb);
-
 	if (spd.nr_pages) {
+		struct sock *sk = skb->sk;
 		int ret;
-		struct sock *sk = __skb->sk;
 
 		/*
 		 * Drop the socket lock, otherwise we have reverse
