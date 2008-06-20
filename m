From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [RESEND] [PATCH] tcp: fix for splice receive when used with software LRO
Date: Fri, 20 Jun 2008 13:09:35 +0300
Message-ID: <200806201309.35272.opurdila@ixiacom.com>
References: <485B4ADE.8070102@domat.com.pl> <20080620063706.GA4009@ff.dom.local>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_fH4WIaJS6xvkJ1N"
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:4806 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751674AbYFTKLJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2008 06:11:09 -0400
In-Reply-To: <20080620063706.GA4009@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_fH4WIaJS6xvkJ1N
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Friday 20 June 2008, Jarek Poplawski wrote:

> This patch looks fine to me, but I wonder if, btw., this place can't
> be optimized a bit, so why can't we simply:
>
> 	if (spd_fill_page(spd, f->page, plen, poff, skb))
> 		goto err;
>
> in both cases, since nothing more can't be filled after this?

Yes, you are right. Here is the patch with your suggestions in place, tested. 

BTW, I have another trivial fix and a RFC related to tcp splice read that I've 
sent a while ago. Should I resend them as well? 

Thanks,
tavi

--Boundary-00=_fH4WIaJS6xvkJ1N
Content-Type: text/plain;
  charset="iso-8859-1";
  name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="x"

commit b4671a70a6d70cdf11537a5231193271b06a3efa
Author: Octavian Purdila <opurdila@ixiacom.com>
Date:   Fri Jun 20 12:49:24 2008 +0300

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
index 25fa74d..4262006 100644
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
@@ -1245,8 +1247,9 @@ static int __skb_splice_bits(struct sk_buff *skb, unsigned int *offset,
 		 * just jump directly to update and return, no point
 		 * in going over fragments when the output is full.
 		 */
-		if (spd_fill_page(spd, virt_to_page(p), plen, poff, skb))
-			goto done;
+		error = spd_fill_page(spd, virt_to_page(p), plen, poff, skb);
+		if (error)
+			goto err;
 
 		tlen -= plen;
 	}
@@ -1275,8 +1278,9 @@ map_frag:
 		if (!plen)
 			break;
 
-		if (spd_fill_page(spd, f->page, plen, poff, skb))
-			break;
+		error = spd_fill_page(spd, f->page, plen, poff, skb);
+		if (error)
+			goto err;
 
 		tlen -= plen;
 	}
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

--Boundary-00=_fH4WIaJS6xvkJ1N--
