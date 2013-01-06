From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: splice: avoid high order page splitting
Date: Sat, 05 Jan 2013 23:31:18 -0800
Message-ID: <1357457478.1678.5928.camel@edumazet-glaptop>
References: <20130105214958.GA19814@1wt.eu>
	 <1357427926.1678.4771.camel@edumazet-glaptop>
	 <20130105232913.GQ16031@1wt.eu>
	 <1357430523.1678.4901.camel@edumazet-glaptop>
	 <20130106005053.GS16031@1wt.eu>
	 <1357435276.1678.5067.camel@edumazet-glaptop>
	 <20130106013027.GV16031@1wt.eu>
	 <1357436430.1678.5111.camel@edumazet-glaptop>
	 <1357437086.1678.5135.camel@edumazet-glaptop>
	 <1357438591.1678.5205.camel@edumazet-glaptop>
	 <20130106025256.GY16031@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:49498 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780Ab3AFHbV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jan 2013 02:31:21 -0500
Received: by mail-pa0-f54.google.com with SMTP id bi5so10029278pad.13
        for <netdev@vger.kernel.org>; Sat, 05 Jan 2013 23:31:21 -0800 (PST)
In-Reply-To: <20130106025256.GY16031@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
 
splice() can handle pages of any order, but network code tries hard to
split them in PAGE_SIZE units. Not quite successfully anyway, as
__splice_segment() assumed poff < PAGE_SIZE. This is true for
the skb->data part, not necessarily for the fragments.

This patch removes this logic to give the pages as they are in the skb.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Willy Tarreau <w@1wt.eu>
---
 net/core/skbuff.c |   38 +++++++++-----------------------------
 1 file changed, 9 insertions(+), 29 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index bc96100..b03fc0c 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1707,20 +1707,6 @@ static bool spd_fill_page(struct splice_pipe_desc *spd,
 	return false;
 }
 
-static inline void __segment_seek(struct page **page, unsigned int *poff,
-				  unsigned int *plen, unsigned int off)
-{
-	unsigned long n;
-
-	*poff += off;
-	n = *poff / PAGE_SIZE;
-	if (n)
-		*page = nth_page(*page, n);
-
-	*poff = *poff % PAGE_SIZE;
-	*plen -= off;
-}
-
 static bool __splice_segment(struct page *page, unsigned int poff,
 			     unsigned int plen, unsigned int *off,
 			     unsigned int *len, struct sk_buff *skb,
@@ -1728,6 +1714,8 @@ static bool __splice_segment(struct page *page, unsigned int poff,
 			     struct sock *sk,
 			     struct pipe_inode_info *pipe)
 {
+	unsigned int flen;
+
 	if (!*len)
 		return true;
 
@@ -1738,24 +1726,16 @@ static bool __splice_segment(struct page *page, unsigned int poff,
 	}
 
 	/* ignore any bits we already processed */
-	if (*off) {
-		__segment_seek(&page, &poff, &plen, *off);
-		*off = 0;
-	}
-
-	do {
-		unsigned int flen = min(*len, plen);
+	poff += *off;
+	plen -= *off;
+	*off = 0;
 
-		/* the linear region may spread across several pages  */
-		flen = min_t(unsigned int, flen, PAGE_SIZE - poff);
+	flen = min(*len, plen);
 
-		if (spd_fill_page(spd, pipe, page, &flen, poff, skb, linear, sk))
-			return true;
-
-		__segment_seek(&page, &poff, &plen, flen);
-		*len -= flen;
+	if (spd_fill_page(spd, pipe, page, &flen, poff, skb, linear, sk))
+		return true;
 
-	} while (*len && plen);
+	*len -= flen;
 
 	return false;
 }
