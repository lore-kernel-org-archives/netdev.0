From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [RESEND] [PATCH] tcp: fix for splice receive when used with software LRO
Date: Fri, 20 Jun 2008 23:44:12 +0300
Message-ID: <200806202344.12771.opurdila@ixiacom.com>
References: <485B4ADE.8070102@domat.com.pl> <200806201539.24421.opurdila@ixiacom.com> <20080620130129.GA4417@ff.dom.local>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_caBXI3tjCoHqavK"
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:3795 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S933169AbYFTUpr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2008 16:45:47 -0400
In-Reply-To: <20080620130129.GA4417@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_caBXI3tjCoHqavK
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Friday 20 June 2008, Jarek Poplawski wrote:
> >
> > Let me try to wrap my brain around this again :) and see if we don't miss
> > anything. In the process, maybe I can even find a way to make this code
> > easier to understand.
>
> Sure, no need to hurry, and after all, I'm OK with the current patch too.
>

OK, here is my attempt at making it a bit more readable:

- move all of the details on offsets, lengths and buffers into a 
single function instead of doing these operation from multiple places

- use a bottom up approach - try to avoid details in the high level functions, 
introduce them gradually as you go deeper in the function call stack

I've attached both the patch and a full excerpt - it might be easier to 
comment on it  this way.

I've minimally tested the patch, no obvious functional or performance problems 
were found.

Thanks,
tavi

--Boundary-00=_caBXI3tjCoHqavK
Content-Type: text/plain;
  charset="iso-8859-1";
  name="y"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="y"


static inline void __segment_seek(struct page **page, int *poff, int *plen,
				  int off)
{
	*poff += off;
	*page += *poff / PAGE_SIZE;
	*poff = *poff % PAGE_SIZE;
	*plen -= off;
}

static inline int __splice_segment(struct page *page, unsigned int poff,
				   unsigned int plen, unsigned int *off,
				   unsigned int *len, struct sk_buff *skb,
				   struct splice_pipe_desc *spd)
{
	/* skip this segment if already processed */
	if (*off >= plen) {
		*off -= plen;
		return 0;
	}

	/* ignore any bits we already processed */
	if (*off) {
		__segment_seek(&page, &poff, &plen, *off);
		*off = 0;
	}

	do {
		unsigned int flen = min(*len, plen);

		if (spd_fill_page(spd, page, flen, poff, skb))
			return 1;

		__segment_seek(&page, &poff, &plen, flen);
		*len -= flen;

	} while (*len && plen);

	return 0;
}

int __skb_splice_bits(struct sk_buff *skb, unsigned int *offset,
			     unsigned int *len,
			     struct splice_pipe_desc *spd)
{
	int seg;

	/*
	 * map the linear part
	 */
	if (__splice_segment(virt_to_page(skb->data),
			     (unsigned long) skb->data & (PAGE_SIZE - 1),
			     skb_headlen(skb),
			     offset, len, skb, spd))
		return 1;

	/*
	 * then map the fragments
	 */
	for (seg = 0; seg < skb_shinfo(skb)->nr_frags; seg++) {
		const skb_frag_t *f = &skb_shinfo(skb)->frags[seg];

		if (__splice_segment(f->page, f->page_offset, f->size,
				     offset, len, skb, spd))
			return 1;
	}

	/*
	 * now see if we have a frag_list to map
	 */
	if (skb_shinfo(skb)->frag_list) {
		struct sk_buff *list = skb_shinfo(skb)->frag_list;

		for (; list && *len; list = list->next)
			if (__skb_splice_bits(list, offset, len, spd))
				return 1;
	}

	return 0;
}

/*
 * Map data from the skb to a pipe. Should handle both the linear part,
 * the fragments, and the frag list.
 */
int skb_splice_bits(struct sk_buff *__skb, unsigned int offset,
		    struct pipe_inode_info *pipe, unsigned int tlen,
		    unsigned int flags)
{
	struct partial_page partial[PIPE_BUFFERS];
	struct page *pages[PIPE_BUFFERS];
	struct splice_pipe_desc spd = {
		.pages = pages,
		.partial = partial,
		.flags = flags,
		.ops = &sock_pipe_buf_ops,
		.spd_release = sock_spd_release,
	};
	struct sk_buff *skb;

	/*
	 * I'd love to avoid the clone here, but tcp_read_sock()
	 * ignores reference counts and unconditonally kills the sk_buff
	 * on return from the actor.
	 */
	skb = skb_clone(__skb, GFP_KERNEL);
	if (unlikely(!skb))
		return -ENOMEM;


	__skb_splice_bits(skb, &offset, &tlen, &spd);

	/*
	 * drop our reference to the clone, the pipe consumption will
	 * drop the rest.
	 */
	kfree_skb(skb);

	if (spd.nr_pages) {
		int ret;
		struct sock *sk = __skb->sk;

		/*
		 * Drop the socket lock, otherwise we have reverse
		 * locking dependencies between sk_lock and i_mutex
		 * here as compared to sendfile(). We enter here
		 * with the socket lock held, and splice_to_pipe() will
		 * grab the pipe inode lock. For sendfile() emulation,
		 * we call into ->sendpage() with the i_mutex lock held
		 * and networking will grab the socket lock.
		 */
		release_sock(sk);
		ret = splice_to_pipe(pipe, &spd);
		lock_sock(sk);
		return ret;
	}

	return 0;
}

--Boundary-00=_caBXI3tjCoHqavK
Content-Type: text/plain;
  charset="iso-8859-1";
  name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="x"

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 25fa74d..017daef 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1188,114 +1188,89 @@ static inline int spd_fill_page(struct splice_pipe_desc *spd, struct page *page,
 	return 0;
 }
 
-/*
- * Map linear and fragment data from the skb to spd. Returns number of
- * pages mapped.
- */
-static int __skb_splice_bits(struct sk_buff *skb, unsigned int *offset,
-			     unsigned int *total_len,
-			     struct splice_pipe_desc *spd)
+static inline void __segment_seek(struct page **page, int *poff, int *plen,
+				  int off)
 {
-	unsigned int nr_pages = spd->nr_pages;
-	unsigned int poff, plen, len, toff, tlen;
-	int headlen, seg;
+	*poff += off;
+	*page += *poff / PAGE_SIZE;
+	*poff = *poff % PAGE_SIZE;
+	*plen -= off;
+}
 
-	toff = *offset;
-	tlen = *total_len;
-	if (!tlen)
-		goto err;
+static inline int __splice_segment(struct page *page, unsigned int poff,
+				   unsigned int plen, unsigned int *off,
+				   unsigned int *len, struct sk_buff *skb,
+				   struct splice_pipe_desc *spd)
+{
+	/* skip this segment if already processed */
+	if (*off >= plen) {
+		*off -= plen;
+		return 0;
+	}
 
-	/*
-	 * if the offset is greater than the linear part, go directly to
-	 * the fragments.
-	 */
-	headlen = skb_headlen(skb);
-	if (toff >= headlen) {
-		toff -= headlen;
-		goto map_frag;
+	/* ignore any bits we already processed */
+	if (*off) {
+		__segment_seek(&page, &poff, &plen, *off);
+		*off = 0;
 	}
 
-	/*
-	 * first map the linear region into the pages/partial map, skipping
-	 * any potential initial offset.
-	 */
-	len = 0;
-	while (len < headlen) {
-		void *p = skb->data + len;
-
-		poff = (unsigned long) p & (PAGE_SIZE - 1);
-		plen = min_t(unsigned int, headlen - len, PAGE_SIZE - poff);
-		len += plen;
-
-		if (toff) {
-			if (plen <= toff) {
-				toff -= plen;
-				continue;
-			}
-			plen -= toff;
-			poff += toff;
-			toff = 0;
-		}
+	do {
+		unsigned int flen = min(*len, plen);
 
-		plen = min(plen, tlen);
-		if (!plen)
-			break;
+		if (spd_fill_page(spd, page, flen, poff, skb))
+			return 1;
 
-		/*
-		 * just jump directly to update and return, no point
-		 * in going over fragments when the output is full.
-		 */
-		if (spd_fill_page(spd, virt_to_page(p), plen, poff, skb))
-			goto done;
+		__segment_seek(&page, &poff, &plen, flen);
+		*len -= flen;
 
-		tlen -= plen;
-	}
+	} while (*len && plen);
+
+	return 0;
+}
+
+int __skb_splice_bits(struct sk_buff *skb, unsigned int *offset,
+			     unsigned int *len,
+			     struct splice_pipe_desc *spd)
+{
+	int seg;
+
+	/*
+	 * map the linear part
+	 */
+	if (__splice_segment(virt_to_page(skb->data),
+			     (unsigned long) skb->data & (PAGE_SIZE - 1),
+			     skb_headlen(skb),
+			     offset, len, skb, spd))
+		return 1;
 
 	/*
 	 * then map the fragments
 	 */
-map_frag:
 	for (seg = 0; seg < skb_shinfo(skb)->nr_frags; seg++) {
 		const skb_frag_t *f = &skb_shinfo(skb)->frags[seg];
 
-		plen = f->size;
-		poff = f->page_offset;
-
-		if (toff) {
-			if (plen <= toff) {
-				toff -= plen;
-				continue;
-			}
-			plen -= toff;
-			poff += toff;
-			toff = 0;
-		}
-
-		plen = min(plen, tlen);
-		if (!plen)
-			break;
+		if (__splice_segment(f->page, f->page_offset, f->size,
+				     offset, len, skb, spd))
+			return 1;
+	}
 
-		if (spd_fill_page(spd, f->page, plen, poff, skb))
-			break;
+	/*
+	 * now see if we have a frag_list to map
+	 */
+	if (skb_shinfo(skb)->frag_list) {
+		struct sk_buff *list = skb_shinfo(skb)->frag_list;
 
-		tlen -= plen;
+		for (; list && *len; list = list->next)
+			if (__skb_splice_bits(list, offset, len, spd))
+				return 1;
 	}
 
-done:
-	if (spd->nr_pages - nr_pages) {
-		*offset = 0;
-		*total_len = tlen;
-		return 0;
-	}
-err:
-	return 1;
+	return 0;
 }
 
 /*
  * Map data from the skb to a pipe. Should handle both the linear part,
- * the fragments, and the frag list. It does NOT handle frag lists within
- * the frag list, if such a thing exists. We'd probably need to recurse to
- * handle that cleanly.
+ * the fragments, and the frag list.
  */
 int skb_splice_bits(struct sk_buff *__skb, unsigned int offset,
 		    struct pipe_inode_info *pipe, unsigned int tlen,
@@ -1321,28 +1296,9 @@ int skb_splice_bits(struct sk_buff *__skb, unsigned int offset,
 	if (unlikely(!skb))
 		return -ENOMEM;
 
-	/*
-	 * __skb_splice_bits() only fails if the output has no room left,
-	 * so no point in going over the frag_list for the error case.
-	 */
-	if (__skb_splice_bits(skb, &offset, &tlen, &spd))
-		goto done;
-	else if (!tlen)
-		goto done;
-
-	/*
-	 * now see if we have a frag_list to map
-	 */
-	if (skb_shinfo(skb)->frag_list) {
-		struct sk_buff *list = skb_shinfo(skb)->frag_list;
 
-		for (; list && tlen; list = list->next) {
-			if (__skb_splice_bits(list, &offset, &tlen, &spd))
-				break;
-		}
-	}
+	__skb_splice_bits(skb, &offset, &tlen, &spd);
 
-done:
 	/*
 	 * drop our reference to the clone, the pipe consumption will
 	 * drop the rest.

--Boundary-00=_caBXI3tjCoHqavK--
