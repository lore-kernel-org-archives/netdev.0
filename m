From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Data corruption issue with splice() on 2.6.27.10
Date: Wed, 7 Jan 2009 12:31:53 +0000
Message-ID: <20090107123153.GA9597@ff.dom.local>
References: <20081224152841.GB13113@1wt.eu> <20090106085442.GA9513@ff.dom.local> <20090106094138.GE25644@1wt.eu> <20090106100112.GB9513@ff.dom.local> <20090106155715.GA28783@1wt.eu> <20090107093915.GA6899@ff.dom.local> <20090107122205.GA6051@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jens Axboe <jens.axboe@oracle.com>,
	Changli Gao <xiaosuo@gmail.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f17.google.com ([209.85.219.17]:55355 "EHLO
	mail-ew0-f17.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751649AbZAGMcF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 07:32:05 -0500
Content-Disposition: inline
In-Reply-To: <20090107122205.GA6051@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 07, 2009 at 01:22:05PM +0100, Willy Tarreau wrote:
> [ CCing Evgeniy and Herbert who also participate to the thread ]
...
> Well, I've just tested it. It did not fix the problem but made it worse.
...

Terrible mistake! Here is take 2.

Sorry!
Jarek P.

---

 net/core/skbuff.c |   41 +++++++++++++++++++++++++++--------------
 1 files changed, 27 insertions(+), 14 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 5110b35..a598034 100644
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
+	memcpy((void *)p + offset, (void *)page + offset, len);
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
+	}
+
 	spd->pages[spd->nr_pages] = page;
 	spd->partial[spd->nr_pages].len = len;
 	spd->partial[spd->nr_pages].offset = offset;
-	spd->partial[spd->nr_pages].private = (unsigned long) skb_get(skb);
 	spd->nr_pages++;
+	get_page(page);
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
 
