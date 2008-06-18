From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [RESEND] [PATCH] tcp: fix for splice receive when used with software LRO
Date: Wed, 18 Jun 2008 19:07:16 +0300
Message-ID: <200806181907.16584.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_0KTWIC5MzgFXvGy"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:3277 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750838AbYFRQIt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 12:08:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_0KTWIC5MzgFXvGy
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


This is a resend of "[PATCH] Fix frag list handling in TCP splice receive",  
modified to conform to the new commit header line rules.The commit message 
has also been edited, and hopefully it is more clear now.

It fixes an infinite loop problem, in tcp_read_splice, that I can easily 
reproduce on my setup with a simple splice test program on the receive side. 

AFAICS, this problem should affect all setups which use software LRO and TCP 
splice receive. Did anybody tried this combination?

Thanks,
tavi

--Boundary-00=_0KTWIC5MzgFXvGy
Content-Type: text/plain;
  name="[PATCH] tcp: fix for splice receive when used with software LRO"
Content-Transfer-Encoding: 7bit

commit 7c1ca9b811e2d38b8a6b5ea02b8211bf7df4e4ab
Author: Octavian Purdila <opurdila@ixiacom.com>
Date:   Wed Jun 18 18:24:06 2008 +0300

    tcp: fix for splice receive when used with software LRO
    
    If an skb has nr_frags set to zero but its frag_list is not empty (as
    it can happen if software LRO is enabled), and a previous
    tcp_read_sock has consumed the linear part of the skb, then
    __skb_splice_bits:
    
    (a) incorrectly reports an error and
    
    (b) forgets to update the offset to account for the linear part
    
    Any of the two problems will cause the subsequent __skb_splice_bits
    call (the one that handles the frag_list skbs) to either skip data,
    or, if the unadjusted offset is greater then the size of the next skb
    in the frag_list, make tcp_splice_read loop forever.
    
    Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 874790b..27cb0d3 100644
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
@@ -1278,7 +1281,8 @@ map_frag:
 		if (!plen)
 			break;
 
-		if (spd_fill_page(spd, f->page, plen, poff, skb))
+		error = spd_fill_page(spd, f->page, plen, poff, skb);
+		if (error)
 			break;
 
 		tlen -= plen;
@@ -1291,7 +1295,10 @@ done:
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

--Boundary-00=_0KTWIC5MzgFXvGy--
