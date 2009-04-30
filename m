From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: oopses since "net: Optimize memory usage when splicing from
	sockets"
Date: Thu, 30 Apr 2009 10:43:21 +0200
Message-ID: <20090430084321.GA2753@ami.dom.local>
References: <20090430031626.GM14729@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f163.google.com ([209.85.218.163]:65166 "EHLO
	mail-bw0-f163.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751405AbZD3IoW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2009 04:44:22 -0400
Received: by bwz7 with SMTP id 7so1659369bwz.37
        for <netdev@vger.kernel.org>; Thu, 30 Apr 2009 01:44:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090430031626.GM14729@mail.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 30, 2009 at 05:16:26AM +0200, Lennert Buytenhek wrote:
> Since 4fb669948116d928ae44262ab7743732c574630d ("net: Optimize memory
> usage when splicing from sockets.") I'm seeing this oops (e.g. in
> 2.6.30-rc3) when splicing from a TCP socket to /dev/null on a driver
> (mv643xx_eth) that uses LRO in the skb mode (lro_receive_skb) rather
> than the frag mode:
...
> addr2line suggests skb->sk is NULL in linear_to_page():
> 
> 
> 	static inline struct page *linear_to_page(struct page *page, unsigned int *len,
> 						  unsigned int *offset,
> 						  struct sk_buff *skb)
> 	{
> 		struct sock *sk = skb->sk;
> 		struct page *p = sk->sk_sndmsg_page;		<========
> 		unsigned int off;
> 
> 		if (!p) {
> 
> 
> When we get here, skb->sk has apparently already been dropped, leading
> to a NULL pointer deref.  Backing out the offending commit makes the
> oops go away (as does converting the driver to lro frag rx, but that
> destroys routing performance).
> 
> Thoughts?  Should we just fall back to plain alloc_pages() if skb->sk
> is NULL, or should have still have the socket reference when we get here?

Hmm... I definitely need more time for this, but the first and maybe
wrong impression is this is an skb from the frag_list. There are
probably better ways of fixing it properly, but here is a quick hack
for the beginning (alas not even compile-tested at the moment).

Thanks for debugging this,
Jarek P.
---

 net/core/skbuff.c |   27 ++++++++++++++-------------
 1 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index ce6356c..f091a5a 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1365,9 +1365,8 @@ static void sock_spd_release(struct splice_pipe_desc *spd, unsigned int i)
 
 static inline struct page *linear_to_page(struct page *page, unsigned int *len,
 					  unsigned int *offset,
-					  struct sk_buff *skb)
+					  struct sk_buff *skb, struct sock *sk)
 {
-	struct sock *sk = skb->sk;
 	struct page *p = sk->sk_sndmsg_page;
 	unsigned int off;
 
@@ -1405,13 +1404,14 @@ new_page:
  */
 static inline int spd_fill_page(struct splice_pipe_desc *spd, struct page *page,
 				unsigned int *len, unsigned int offset,
-				struct sk_buff *skb, int linear)
+				struct sk_buff *skb, int linear,
+				struct sock *sk)
 {
 	if (unlikely(spd->nr_pages == PIPE_BUFFERS))
 		return 1;
 
 	if (linear) {
-		page = linear_to_page(page, len, &offset, skb);
+		page = linear_to_page(page, len, &offset, skb, sk);
 		if (!page)
 			return 1;
 	} else
@@ -1442,7 +1442,8 @@ static inline void __segment_seek(struct page **page, unsigned int *poff,
 static inline int __splice_segment(struct page *page, unsigned int poff,
 				   unsigned int plen, unsigned int *off,
 				   unsigned int *len, struct sk_buff *skb,
-				   struct splice_pipe_desc *spd, int linear)
+				   struct splice_pipe_desc *spd, int linear,
+				   struct sock *sk)
 {
 	if (!*len)
 		return 1;
@@ -1465,7 +1466,7 @@ static inline int __splice_segment(struct page *page, unsigned int poff,
 		/* the linear region may spread across several pages  */
 		flen = min_t(unsigned int, flen, PAGE_SIZE - poff);
 
-		if (spd_fill_page(spd, page, &flen, poff, skb, linear))
+		if (spd_fill_page(spd, page, &flen, poff, skb, linear, sk))
 			return 1;
 
 		__segment_seek(&page, &poff, &plen, flen);
@@ -1481,8 +1482,8 @@ static inline int __splice_segment(struct page *page, unsigned int poff,
  * pipe is full or if we already spliced the requested length.
  */
 static int __skb_splice_bits(struct sk_buff *skb, unsigned int *offset,
-		      unsigned int *len,
-		      struct splice_pipe_desc *spd)
+			     unsigned int *len, struct splice_pipe_desc *spd,
+			     struct sock *sk)
 {
 	int seg;
 
@@ -1492,7 +1493,7 @@ static int __skb_splice_bits(struct sk_buff *skb, unsigned int *offset,
 	if (__splice_segment(virt_to_page(skb->data),
 			     (unsigned long) skb->data & (PAGE_SIZE - 1),
 			     skb_headlen(skb),
-			     offset, len, skb, spd, 1))
+			     offset, len, skb, spd, 1, sk))
 		return 1;
 
 	/*
@@ -1502,7 +1503,7 @@ static int __skb_splice_bits(struct sk_buff *skb, unsigned int *offset,
 		const skb_frag_t *f = &skb_shinfo(skb)->frags[seg];
 
 		if (__splice_segment(f->page, f->page_offset, f->size,
-				     offset, len, skb, spd, 0))
+				     offset, len, skb, spd, 0, sk))
 			return 1;
 	}
 
@@ -1528,12 +1529,13 @@ int skb_splice_bits(struct sk_buff *skb, unsigned int offset,
 		.ops = &sock_pipe_buf_ops,
 		.spd_release = sock_spd_release,
 	};
+	struct sock *sk = skb->sk;
 
 	/*
 	 * __skb_splice_bits() only fails if the output has no room left,
 	 * so no point in going over the frag_list for the error case.
 	 */
-	if (__skb_splice_bits(skb, &offset, &tlen, &spd))
+	if (__skb_splice_bits(skb, &offset, &tlen, &spd, sk))
 		goto done;
 	else if (!tlen)
 		goto done;
@@ -1545,14 +1547,13 @@ int skb_splice_bits(struct sk_buff *skb, unsigned int offset,
 		struct sk_buff *list = skb_shinfo(skb)->frag_list;
 
 		for (; list && tlen; list = list->next) {
-			if (__skb_splice_bits(list, &offset, &tlen, &spd))
+			if (__skb_splice_bits(list, &offset, &tlen, &spd, sk))
 				break;
 		}
 	}
 
 done:
 	if (spd.nr_pages) {
-		struct sock *sk = skb->sk;
 		int ret;
 
 		/*
