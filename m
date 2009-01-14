From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Tue, 13 Jan 2009 16:37:05 -0800 (PST)
Message-ID: <20090113.163705.130074998.davem@davemloft.net>
References: <20090114001345.GB512@ioremap.net>
	<20090113.161625.111759506.davem@davemloft.net>
	<20090114002252.GE512@ioremap.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, w@1wt.eu, ben@zeus.com, jarkao2@gmail.com,
	mingo@elte.hu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com
To: zbr@ioremap.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34283
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753240AbZANAhF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 19:37:05 -0500
In-Reply-To: <20090114002252.GE512@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Evgeniy Polyakov <zbr@ioremap.net>
Date: Wed, 14 Jan 2009 03:22:52 +0300

> On Tue, Jan 13, 2009 at 04:16:25PM -0800, David Miller (davem@davemloft.net) wrote:
> > I wish there were some way we could make this code grab and release a
> > reference to the SKB data area (I mean skb_shinfo(skb)->dataref) to
> > accomplish it's goals.
> 
> Ugh... Clone without cloninig, but by increasing the dataref. Getting
> that splice only needs that skb to track the head of the original, this
> may really work.

Here is something I scrambled together, it is largely based upon
Jarek's patch:

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 5110b35..05126da 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -70,12 +70,17 @@
 static struct kmem_cache *skbuff_head_cache __read_mostly;
 static struct kmem_cache *skbuff_fclone_cache __read_mostly;
 
+static void skb_release_data(struct sk_buff *skb);
+
 static void sock_pipe_buf_release(struct pipe_inode_info *pipe,
 				  struct pipe_buffer *buf)
 {
 	struct sk_buff *skb = (struct sk_buff *) buf->private;
 
-	kfree_skb(skb);
+	if (skb)
+		skb_release_data(skb);
+	else
+		put_page(buf->page);
 }
 
 static void sock_pipe_buf_get(struct pipe_inode_info *pipe,
@@ -83,7 +88,10 @@ static void sock_pipe_buf_get(struct pipe_inode_info *pipe,
 {
 	struct sk_buff *skb = (struct sk_buff *) buf->private;
 
-	skb_get(skb);
+	if (skb)
+		atomic_inc(&skb_shinfo(skb)->dataref);
+	else
+		get_page(buf->page);
 }
 
 static int sock_pipe_buf_steal(struct pipe_inode_info *pipe,
@@ -1336,7 +1344,10 @@ static void sock_spd_release(struct splice_pipe_desc *spd, unsigned int i)
 {
 	struct sk_buff *skb = (struct sk_buff *) spd->partial[i].private;
 
-	kfree_skb(skb);
+	if (skb)
+		skb_release_data(skb);
+	else
+		put_page(spd->pages[i]);
 }
 
 /*
@@ -1344,7 +1355,7 @@ static void sock_spd_release(struct splice_pipe_desc *spd, unsigned int i)
  */
 static inline int spd_fill_page(struct splice_pipe_desc *spd, struct page *page,
 				unsigned int len, unsigned int offset,
-				struct sk_buff *skb)
+				struct sk_buff *skb, int linear)
 {
 	if (unlikely(spd->nr_pages == PIPE_BUFFERS))
 		return 1;
@@ -1352,8 +1363,15 @@ static inline int spd_fill_page(struct splice_pipe_desc *spd, struct page *page,
 	spd->pages[spd->nr_pages] = page;
 	spd->partial[spd->nr_pages].len = len;
 	spd->partial[spd->nr_pages].offset = offset;
-	spd->partial[spd->nr_pages].private = (unsigned long) skb_get(skb);
+	spd->partial[spd->nr_pages].private =
+		(unsigned long) (linear ? skb : NULL);
 	spd->nr_pages++;
+
+	if (linear)
+		atomic_inc(&skb_shinfo(skb)->dataref);
+	else
+		get_page(page);
+
 	return 0;
 }
 
@@ -1369,7 +1387,7 @@ static inline void __segment_seek(struct page **page, unsigned int *poff,
 static inline int __splice_segment(struct page *page, unsigned int poff,
 				   unsigned int plen, unsigned int *off,
 				   unsigned int *len, struct sk_buff *skb,
-				   struct splice_pipe_desc *spd)
+				   struct splice_pipe_desc *spd, int linear)
 {
 	if (!*len)
 		return 1;
@@ -1392,7 +1410,7 @@ static inline int __splice_segment(struct page *page, unsigned int poff,
 		/* the linear region may spread across several pages  */
 		flen = min_t(unsigned int, flen, PAGE_SIZE - poff);
 
-		if (spd_fill_page(spd, page, flen, poff, skb))
+		if (spd_fill_page(spd, page, flen, poff, skb, linear))
 			return 1;
 
 		__segment_seek(&page, &poff, &plen, flen);
@@ -1419,7 +1437,7 @@ static int __skb_splice_bits(struct sk_buff *skb, unsigned int *offset,
 	if (__splice_segment(virt_to_page(skb->data),
 			     (unsigned long) skb->data & (PAGE_SIZE - 1),
 			     skb_headlen(skb),
-			     offset, len, skb, spd))
+			     offset, len, skb, spd, 1))
 		return 1;
 
 	/*
@@ -1429,7 +1447,7 @@ static int __skb_splice_bits(struct sk_buff *skb, unsigned int *offset,
 		const skb_frag_t *f = &skb_shinfo(skb)->frags[seg];
 
 		if (__splice_segment(f->page, f->page_offset, f->size,
-				     offset, len, skb, spd))
+				     offset, len, skb, spd, 0))
 			return 1;
 	}
 
