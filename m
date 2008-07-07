From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [PATCH v2] net: refactor tcp splice receive path to improve readability
Date: Mon, 7 Jul 2008 12:39:17 +0300
Message-ID: <200807071239.17431.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_FRecI4UrDaVyPB1"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:3801 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750929AbYGGJmx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 05:42:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_FRecI4UrDaVyPB1
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


On Sunday 06 July 2008, David Miller wrote:

> > Please consider applying this to net-next-2.6. I've minimally tested it
> > and no  performance or functional problems were found. It applies on
> > top of the previous fix I've sent ([PATH] tcp: fix for splice receive
> > when used with software LRO).
>
> It doesn't apply cleanly even though I've merged in net-2.6
> which includes your splice receive bug fix.
>
> Please respin this patch, thanks.

This one applies cleanly to head of net-next-2.6. 

Thanks,
tavi

--Boundary-00=_FRecI4UrDaVyPB1
Content-Type: text/plain;
  charset="us-ascii";
  name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="x"

commit 53930f7124fe57426c9ce838ec4f94496d76de92
Author: Octavian Purdila <opurdila@ixiacom.com>
Date:   Mon Jul 7 12:29:12 2008 +0300

    net: refactor tcp splice receive path to improve readability
    
    - move all of the details on offsets, lengths and buffers into a
    single function instead of doing these operation from multiple places
    
    - use a bottom up approach: try to avoid details in the high level
    functions, introduce them gradually as we go deeper in the function
    call stack
    
    With helpful feedback from Jarek Poplawski.
    
    Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
    Acked-by: Jarek Poplawski <jarkao2@gmail.com>

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 7c57156..a093610 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1280,114 +1280,83 @@ static inline int spd_fill_page(struct splice_pipe_desc *spd, struct page *page,
 	return 0;
 }
 
-/*
- * Map linear and fragment data from the skb to spd. Returns number of
- * pages mapped.
- */
-static int __skb_splice_bits(struct sk_buff *skb, unsigned int *offset,
-			     unsigned int *total_len,
-			     struct splice_pipe_desc *spd)
-{
-	unsigned int nr_pages = spd->nr_pages;
-	unsigned int poff, plen, len, toff, tlen;
-	int headlen, seg, error = 0;
-
-	toff = *offset;
-	tlen = *total_len;
-	if (!tlen) {
-		error = 1;
-		goto err;
+static inline void __segment_seek(struct page **page, unsigned int *poff,
+				  unsigned int *plen, unsigned int off)
+{
+	*poff += off;
+	*page += *poff / PAGE_SIZE;
+	*poff = *poff % PAGE_SIZE;
+	*plen -= off;
+}
+
+static inline int __splice_segment(struct page *page, unsigned int poff,
+				   unsigned int plen, unsigned int *off,
+				   unsigned int *len, struct sk_buff *skb,
+				   struct splice_pipe_desc *spd)
+{
+	if (!*len)
+		return 1;
+
+	/* skip this segment if already processed */
+	if (*off >= plen) {
+		*off -= plen;
+		return 0;
 	}
 
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
+		/* the linear region may spread across several pages  */
+		flen = min_t(unsigned int, flen, PAGE_SIZE - poff);
 
-		/*
-		 * just jump directly to update and return, no point
-		 * in going over fragments when the output is full.
-		 */
-		error = spd_fill_page(spd, virt_to_page(p), plen, poff, skb);
-		if (error)
-			goto done;
+		if (spd_fill_page(spd, page, flen, poff, skb))
+			return 1;
 
-		tlen -= plen;
-	}
+		__segment_seek(&page, &poff, &plen, flen);
+		*len -= flen;
+
+	} while (*len && plen);
+
+	return 0;
+}
+
+/*
+ * Map linear and fragment data from the skb to spd. It reports failure if the
+ * pipe is full or if we already spliced the requested length.
+ */
+int __skb_splice_bits(struct sk_buff *skb, unsigned int *offset,
+		      unsigned int *len,
+		      struct splice_pipe_desc *spd)
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
-
-		error = spd_fill_page(spd, f->page, plen, poff, skb);
-		if (error)
-			break;
-
-		tlen -= plen;
+		if (__splice_segment(f->page, f->page_offset, f->size,
+				     offset, len, skb, spd))
+			return 1;
 	}
 
-done:
-	if (spd->nr_pages - nr_pages) {
-		*offset = 0;
-		*total_len = tlen;
-		return 0;
-	}
-err:
-	/* update the offset to reflect the linear part skip, if any */
-	if (!error)
-		*offset = toff;
-	return error;
+	return 0;
 }
 
 /*

--Boundary-00=_FRecI4UrDaVyPB1--
