From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Netpoll checksum issue
Date: Wed, 19 Apr 2006 10:31:53 -0700
Message-ID: <20060419103153.64ef0054@localhost.localdomain>
References: <6d6a94c50604190922m189b9d99gdd428a870e12c2c3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:3027 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750732AbWDSRb5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2006 13:31:57 -0400
To: Aubrey <aubreylee@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <6d6a94c50604190922m189b9d99gdd428a870e12c2c3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The changes to how hardware receive checksums are handled broke
the netpoll checksum code (for CHECKSUM_HW).  Since this is not at
all performance critical, try this patch. It changes to always to
normal software checksum.

--- linux-2.6.orig/net/core/netpoll.c	2006-03-22 09:30:56.000000000 -0800
+++ linux-2.6/net/core/netpoll.c	2006-04-19 10:30:13.000000000 -0700
@@ -102,20 +102,11 @@
 static int checksum_udp(struct sk_buff *skb, struct udphdr *uh,
 			     unsigned short ulen, u32 saddr, u32 daddr)
 {
-	unsigned int psum;
-
 	if (uh->check == 0 || skb->ip_summed == CHECKSUM_UNNECESSARY)
 		return 0;
 
-	psum = csum_tcpudp_nofold(saddr, daddr, ulen, IPPROTO_UDP, 0);
-
-	if (skb->ip_summed == CHECKSUM_HW &&
-	    !(u16)csum_fold(csum_add(psum, skb->csum)))
-		return 0;
-
-	skb->csum = psum;
-
-	return __skb_checksum_complete(skb);
+	skb->csum = csum_tcpudp_nofold(saddr, daddr, ulen, IPPROTO_UDP, 0);
+	return (u16) csum_fold(skb_checksum(skb, 0, skb->len, skb->csum));
 }
 
 /*
