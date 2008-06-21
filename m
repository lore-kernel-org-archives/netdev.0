From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [PATH] tcp: fix for splice receive when used with software LRO
Date: Sat, 21 Jun 2008 13:19:42 +0300
Message-ID: <200806211319.42558.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_+WNXIQRBrj1NFSh"
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:4190 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755841AbYFUKV7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jun 2008 06:21:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_+WNXIQRBrj1NFSh
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


Hi David,

Please apply to net-2.6.

Thanks,
tavi

--Boundary-00=_+WNXIQRBrj1NFSh
Content-Type: text/plain;
  charset="us-ascii";
  name="z"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="z"

commit 41f5beb8a6e12e0c2588aee82ba68c46baf9d5f2
Author: Octavian Purdila <opurdila@ixiacom.com>
Date:   Sat Jun 21 03:17:10 2008 +0300

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
    Acked-by: Jarek Poplawski <jarkao2@gmail.com>

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 1e556d3..d912982 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1290,7 +1290,6 @@ static int __skb_splice_bits(struct sk_buff *skb, unsigned int *offset,
 			     unsigned int *total_len,
 			     struct splice_pipe_desc *spd)
 {
-	unsigned int nr_pages = spd->nr_pages;
 	unsigned int poff, plen, len, toff, tlen;
 	int headlen, seg;
 
@@ -1340,7 +1339,7 @@ static int __skb_splice_bits(struct sk_buff *skb, unsigned int *offset,
 		 * in going over fragments when the output is full.
 		 */
 		if (spd_fill_page(spd, virt_to_page(p), plen, poff, skb))
-			goto done;
+			goto err;
 
 		tlen -= plen;
 	}
@@ -1370,17 +1369,15 @@ map_frag:
 			break;
 
 		if (spd_fill_page(spd, f->page, plen, poff, skb))
-			break;
+			goto err;
 
 		tlen -= plen;
 	}
 
-done:
-	if (spd->nr_pages - nr_pages) {
-		*offset = 0;
-		*total_len = tlen;
-		return 0;
-	}
+	*offset = toff;
+	*total_len = tlen;
+
+	return 0;
 err:
 	return 1;
 }

--Boundary-00=_+WNXIQRBrj1NFSh--
