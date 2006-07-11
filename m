From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPCOMP]: Fix truesize after decompression
Date: Tue, 11 Jul 2006 21:45:44 +1000
Message-ID: <20060711114544.GA11396@gondor.apana.org.au>
References: <BB1F4EFD574E9F409035BDA71C9612500242B8@exchange.i-bn>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:22034 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751219AbWGKLqH
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jul 2006 07:46:07 -0400
To: "David S. Miller" <davem@davemloft.net>,
	Beschorner Daniel <Daniel.Beschorner@facton.com>
Content-Disposition: inline
In-Reply-To: <BB1F4EFD574E9F409035BDA71C9612500242B8@exchange.i-bn>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 06, 2006 at 12:53:45PM +0000, Beschorner Daniel wrote:
> Does it harm?
> 
> SKB BUG: Invalid truesize (380) len=1383, sizeof(sk_buff)=156
> SKB BUG: Invalid truesize (316) len=1383, sizeof(sk_buff)=156
> SKB BUG: Invalid truesize (348) len=1383, sizeof(sk_buff)=156
> SKB BUG: Invalid truesize (316) len=1383, sizeof(sk_buff)=156
> SKB BUG: Invalid truesize (380) len=1383, sizeof(sk_buff)=156
> 
> I found it in the log of a 2.6.17 box using IPSEC tunnels.

It's not fatal, but it does stuff up socket accounting.  Unfortunately
getting totally accurate truesizes is not easy due to the large numbers
of pskb_expand_head calls scattered around the stack.

[IPCOMP]: Fix truesize after decompression

The truesize check has uncovered the fact that we forgot to update truesize
after pskb_expand_head.  Unfortunately pskb_expand_head can't update it for
us because it's used in all sorts of different contexts, some of which would
not allow truesize to be updated by itself.

So the solution for now is to simply update it in IPComp.

This patch also changes skb_put to __skb_put since we've just expanded
tailroom by exactly that amount so we know it's there (but gcc does not).

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/ipv4/ipcomp.c b/net/ipv4/ipcomp.c
index 8e03748..8a8b5cf 100644
--- a/net/ipv4/ipcomp.c
+++ b/net/ipv4/ipcomp.c
@@ -70,7 +70,8 @@ static int ipcomp_decompress(struct xfrm
 	if (err)
 		goto out;
 		
-	skb_put(skb, dlen - plen);
+	skb->truesize += dlen - plen;
+	__skb_put(skb, dlen - plen);
 	memcpy(skb->data, scratch, dlen);
 out:	
 	put_cpu();
diff --git a/net/ipv6/ipcomp6.c b/net/ipv6/ipcomp6.c
index b285b03..7e4d1c1 100644
--- a/net/ipv6/ipcomp6.c
+++ b/net/ipv6/ipcomp6.c
@@ -109,7 +109,8 @@ static int ipcomp6_input(struct xfrm_sta
 		goto out_put_cpu;
 	}
 
-	skb_put(skb, dlen - plen);
+	skb->truesize += dlen - plen;
+	__skb_put(skb, dlen - plen);
 	memcpy(skb->data, scratch, dlen);
 	err = ipch->nexthdr;
 
