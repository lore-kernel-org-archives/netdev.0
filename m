From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.24-rc2: Network commit causes SLUB performance regression with tbench
Date: Wed, 14 Nov 2007 19:48:44 +0800
Message-ID: <20071114114844.GA13927@gondor.apana.org.au>
References: <200711140514.28159.nickpiggin@yahoo.com.au> <20071113.223726.40898879.davem@davemloft.net> <200711140927.39796.nickpiggin@yahoo.com.au> <20071114.031022.183117678.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nickpiggin@yahoo.com.au, clameter@sgi.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1996 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754330AbXKNLtG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 06:49:06 -0500
Content-Disposition: inline
In-Reply-To: <20071114.031022.183117678.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 14, 2007 at 03:10:22AM -0800, David Miller wrote:
> 
> So the thing that's being effected here in TCP is
> net/ipv4/tcp.c:select_size(), specifically the else branch:

Thanks for the pointer.  Indeed there is a bug in that area.
I'm not sure whether it's causing the problem at hand but it's
certainly suboptimal.

[TCP]: Fix size calculation in sk_stream_alloc_pskb

We round up the header size in sk_stream_alloc_pskb so that
TSO packets get zero tail room.  Unfortunately this rounding
up is not coordinated with the select_size() function used by
TCP to calculate the second parameter of sk_stream_alloc_pskb.

As a result, we may allocate more than a page of data in the
non-TSO case when exactly one page is desired.

In fact, rounding up the head room is detrimental in the non-TSO
case because it makes memory that would otherwise be available to
the payload head room.  TSO doesn't need this either, all it wants
is the guarantee that there is no tail room.

So this patch fixes this by adjusting the skb_reserve call so that
exactly the requested amount (which all callers have calculated in
a precise way) is made available as tail room.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/include/net/sock.h b/include/net/sock.h
index 5504fb9..567e468 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1235,14 +1235,16 @@ static inline struct sk_buff *sk_stream_alloc_pskb(struct sock *sk,
 						   gfp_t gfp)
 {
 	struct sk_buff *skb;
-	int hdr_len;
 
-	hdr_len = SKB_DATA_ALIGN(sk->sk_prot->max_header);
-	skb = alloc_skb_fclone(size + hdr_len, gfp);
+	skb = alloc_skb_fclone(size + sk->sk_prot->max_header, gfp);
 	if (skb) {
 		skb->truesize += mem;
 		if (sk_stream_wmem_schedule(sk, skb->truesize)) {
-			skb_reserve(skb, hdr_len);
+			/*
+			 * Make sure that we have exactly size bytes
+			 * available to the caller, no more, no less.
+			 */
+			skb_reserve(skb, skb_tailroom(skb) - size);
 			return skb;
 		}
 		__kfree_skb(skb);
