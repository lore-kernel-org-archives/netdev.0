From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [PATCH] Fix frag list handling in TCP splice receive
Date: Sat, 17 May 2008 16:36:07 +0300
Message-ID: <200805171636.07443.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:4457 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753251AbYEQNhH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 May 2008 09:37:07 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If an skb does not have fragments but its fragment list is not empty (can
happen, via LRO at least) and a previous tcp_read_sock has consumed
the linear part of the skb then __skb_splice_bits:

(a) incorrectly reports an error and

(b) forgets to update the offset to account for the linear part

Any of the two problems will cause the subsequent __skb_splice_bits call
(the one that handles the fragment list skbs) to either skip data, or, if the
unadjusted offset is greater then the size of the next skb, make
tcp_splice_read loop forever.

Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
---
 net/core/skbuff.c |   17 ++++++++++++-----
 1 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 2e4fcd9..0a9002b 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1198,12 +1198,14 @@ static int __skb_splice_bits(struct sk_buff *skb, unsigned int *offset,
 {
 	unsigned int nr_pages = spd->nr_pages;
 	unsigned int poff, plen, len, toff, tlen;
-	int headlen, seg;
+	int headlen, seg, error = 0;
 
 	toff = *offset;
 	tlen = *total_len;
-	if (!tlen)
+	if (!tlen) {
+		error = 1;
 		goto err;
+	}
 
 	/*
 	 * if the offset is greater than the linear part, go directly to
@@ -1245,7 +1247,8 @@ static int __skb_splice_bits(struct sk_buff *skb, unsigned int *offset,
 		 * just jump directly to update and return, no point
 		 * in going over fragments when the output is full.
 		 */
-		if (spd_fill_page(spd, virt_to_page(p), plen, poff, skb))
+		error = spd_fill_page(spd, virt_to_page(p), plen, poff, skb);
+		if (error)
 			goto done;
 
 		tlen -= plen;
@@ -1275,7 +1278,8 @@ map_frag:
 		if (!plen)
 			break;
 
-		if (spd_fill_page(spd, f->page, plen, poff, skb))
+		error = spd_fill_page(spd, f->page, plen, poff, skb);
+		if (error)
 			break;
 
 		tlen -= plen;
@@ -1288,7 +1292,10 @@ done:
 		return 0;
 	}
 err:
-	return 1;
+	/* update the offset to reflect the linear part skip, if any */
+	if (!error)
+		*offset = toff;
+	return error;
 }
 
 /*
-- 
1.5.4.3

