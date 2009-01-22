From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH v3] tcp: splice as many packets as possible at once
Date: Thu, 22 Jan 2009 09:04:42 +0000
Message-ID: <20090122090442.GB11139@ff.dom.local>
References: <20090120102053.GA17004@ff.dom.local> <20090120103122.GC9167@ioremap.net> <20090120110144.GB17004@ff.dom.local> <20090120.091616.224452074.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: zbr@ioremap.net, herbert@gondor.apana.org.au, w@1wt.eu,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:5264 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753650AbZAVJEw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 04:04:52 -0500
Content-Disposition: inline
In-Reply-To: <20090120.091616.224452074.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 20, 2009 at 09:16:16AM -0800, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Tue, 20 Jan 2009 11:01:44 +0000
> 
> > On Tue, Jan 20, 2009 at 01:31:22PM +0300, Evgeniy Polyakov wrote:
> > > On Tue, Jan 20, 2009 at 10:20:53AM +0000, Jarek Poplawski (jarkao2@gmail.com) wrote:
> > > > Good question! Alas I can't check this soon, but if it's really like
> > > > this, of course this needs some better idea and rework. (BTW, I'd like
> > > > to prevent here as much as possible some strange activities like 1
> > > > byte (payload) packets getting full pages without any accounting.)
> > > 
> > > I believe approach to meet all our goals is to have own network memory
> > > allocator, so that each skb could have its payload in the fragments, we
> > > would not suffer from the heavy fragmentation and power-of-two overhead
> > > for the larger MTUs, have a reserve for the OOM condition and generally
> > > do not depend on the main system behaviour.
> > 
> > 100% right! But I guess we need this current fix for -stable, and I'm
> > a bit worried about safety.
> 
> Jarek, we already have a page and offset you can use.
> 
> It's called sk_sndmsg_page but that is just the (current) name.
> Nothing prevents you from reusing it for your purposes here.

It seems this sk_sndmsg_page usage (refcounting) isn't consistent.
I used here tcp_sndmsg() way, but I think I'll go back to this question
soon.

Thanks,
Jarek P.

------------> take 3

net: Optimize memory usage when splicing from sockets.

The recent fix of data corruption when splicing from sockets uses
memory very inefficiently allocating a new page to copy each chunk of
linear part of skb. This patch uses the same page until it's full
(almost) by caching the page in sk_sndmsg_page field.

With changes from David S. Miller <davem@davemloft.net>

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Tested-by: needed...
---

 net/core/skbuff.c |   45 +++++++++++++++++++++++++++++++++++----------
 1 files changed, 35 insertions(+), 10 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 2e5f2ca..2e64c1b 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1333,14 +1333,39 @@ static void sock_spd_release(struct splice_pipe_desc *spd, unsigned int i)
 	put_page(spd->pages[i]);
 }
 
-static inline struct page *linear_to_page(struct page *page, unsigned int len,
-					  unsigned int offset)
-{
-	struct page *p = alloc_pages(GFP_KERNEL, 0);
+static inline struct page *linear_to_page(struct page *page, unsigned int *len,
+					  unsigned int *offset,
+					  struct sk_buff *skb)
+{
+	struct sock *sk = skb->sk;
+	struct page *p = sk->sk_sndmsg_page;
+	unsigned int off;
+
+	if (!p) {
+new_page:
+		p = sk->sk_sndmsg_page = alloc_pages(sk->sk_allocation, 0);
+		if (!p)
+			return NULL;
 
-	if (!p)
-		return NULL;
-	memcpy(page_address(p) + offset, page_address(page) + offset, len);
+		off = sk->sk_sndmsg_off = 0;
+		/* hold one ref to this page until it's full */
+	} else {
+		unsigned int mlen;
+
+		off = sk->sk_sndmsg_off;
+		mlen = PAGE_SIZE - off;
+		if (mlen < 64 && mlen < *len) {
+			put_page(p);
+			goto new_page;
+		}
+
+		*len = min_t(unsigned int, *len, mlen);
+	}
+
+	memcpy(page_address(p) + off, page_address(page) + *offset, *len);
+	sk->sk_sndmsg_off += *len;
+	*offset = off;
+	get_page(p);
 
 	return p;
 }
@@ -1349,21 +1374,21 @@ static inline struct page *linear_to_page(struct page *page, unsigned int len,
  * Fill page/offset/length into spd, if it can hold more pages.
  */
 static inline int spd_fill_page(struct splice_pipe_desc *spd, struct page *page,
-				unsigned int len, unsigned int offset,
+				unsigned int *len, unsigned int offset,
 				struct sk_buff *skb, int linear)
 {
 	if (unlikely(spd->nr_pages == PIPE_BUFFERS))
 		return 1;
 
 	if (linear) {
-		page = linear_to_page(page, len, offset);
+		page = linear_to_page(page, len, &offset, skb);
 		if (!page)
 			return 1;
 	} else
 		get_page(page);
 
 	spd->pages[spd->nr_pages] = page;
-	spd->partial[spd->nr_pages].len = len;
+	spd->partial[spd->nr_pages].len = *len;
 	spd->partial[spd->nr_pages].offset = offset;
 	spd->nr_pages++;
 
@@ -1405,7 +1430,7 @@ static inline int __splice_segment(struct page *page, unsigned int poff,
 		/* the linear region may spread across several pages  */
 		flen = min_t(unsigned int, flen, PAGE_SIZE - poff);
 
-		if (spd_fill_page(spd, page, flen, poff, skb, linear))
+		if (spd_fill_page(spd, page, &flen, poff, skb, linear))
 			return 1;
 
 		__segment_seek(&page, &poff, &plen, flen);
