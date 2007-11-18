From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [TCP]: Fix TCP header misalignment
Date: Sun, 18 Nov 2007 20:15:30 +0800
Message-ID: <20071118121530.GA27963@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3639 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751376AbXKRMPd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Nov 2007 07:15:33 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave:

[TCP]: Fix TCP header misalignment

Indeed my previous change to alloc_pskb has made it possible
for the TCP header to be misaligned iff the MTU is not a multiple
of 4 (and less than a page).  So I suspect the optimised IPsec
MTU calculation is giving you just such an MTU :)

This patch fixes it by changing alloc_pskb to make sure that
the size is at least 32-bit aligned.  This does not cause the
problem fixed by the previous patch because max_header is always
32-bit aligned which means that in the SG/NOTSO case this will
be a no-op.

I thought about putting this in the callers but all the current
callers are from TCP.  If and when we get a non-TCP caller we
can always create a TCP wrapper for this function and move the
alignment over there.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/include/net/sock.h b/include/net/sock.h
index 567e468..6f67b91 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1236,6 +1236,9 @@ static inline struct sk_buff *sk_stream_alloc_pskb(struct sock *sk,
 {
 	struct sk_buff *skb;
 
+	/* The TCP header must be at least 32-bit aligned.  */
+	size = ALIGN(size, 4);
+
 	skb = alloc_skb_fclone(size + sk->sk_prot->max_header, gfp);
 	if (skb) {
 		skb->truesize += mem;
