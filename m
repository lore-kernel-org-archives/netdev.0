From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: TCP connection hang problem with 2.6.16.16, e1000.
Date: Thu, 1 Jun 2006 12:56:33 +1000
Message-ID: <20060601025633.GA20137@gondor.apana.org.au>
References: <447DC830.4080201@candelatech.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="M9NhX3UHpAaciwkO"
Cc: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2568 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S965196AbWFAC4v
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 May 2006 22:56:51 -0400
To: "David S. Miller" <davem@davemloft.net>,
	Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <447DC830.4080201@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--M9NhX3UHpAaciwkO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, May 31, 2006 at 04:45:36PM +0000, Ben Greear wrote:
>
> May 31 08:07:00 xeon-dt kernel: irqbalance: page allocation failure. order:1, mode:0x20
> May 31 08:07:00 xeon-dt kernel:  [<78147393>] __alloc_pages+0x1d8/0x2b8
> May 31 08:07:00 xeon-dt kernel:  [<7815c525>] kmem_getpages+0x2f/0x8c
> May 31 08:07:00 xeon-dt kernel:  [<7815d297>] cache_grow+0xb1/0x14e
> May 31 08:07:00 xeon-dt kernel:  [<7815d48e>] cache_alloc_refill+0x15a/0x206
> May 31 08:07:00 xeon-dt kernel:  [<7815d7c5>] __kmalloc+0x68/0x80
> May 31 08:07:00 xeon-dt kernel:  [<782b3ba2>] __alloc_skb+0x4c/0xf6
> May 31 08:07:00 xeon-dt kernel:  [<782e63af>] tcp_collapse+0xe9/0x34e

We specifically calculate the packet size here to avoid a 2-page
allocation, yet we still do.  This is the bug.

[NET]: Fix SKB_MAX_ORDER calculation

The calculation in SKB_MAX_ORDER is incorrect in that it can cause
an overflow across a page boundary which is what it's meant to prevent.
In particular, the header length (X) should not be lumped together with
skb_shared_info.  The latter needs to be aligned properly while the header
has no choice but to sit in front of wherever the payload is.

Therefore the correct calculation is to take away the aligned size of
skb_shared_info, and then subtract the header length.  The resulting
quantity L satisfies the following inequality:

	SKB_DATA_ALIGN(L + X) + sizeof(struct skb_shared_info) <= PAGE_SIZE

This is the quantity used by alloc_skb to do the actual allocation.

While we're at it, there is no need to round up the header size in
sk_stream_alloc_pskb.  The only thing this achieves is to make the
data payload cache-aligned.  However, the data payload is just a
byte stream with no alignment requirements.  So we should take away
the rounding.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--M9NhX3UHpAaciwkO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="skb-max-order.patch"

index f8f2347..8761000 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -39,9 +39,8 @@ #define CHECKSUM_UNNECESSARY 2
 
 #define SKB_DATA_ALIGN(X)	(((X) + (SMP_CACHE_BYTES - 1)) & \
 				 ~(SMP_CACHE_BYTES - 1))
-#define SKB_MAX_ORDER(X, ORDER)	(((PAGE_SIZE << (ORDER)) - (X) - \
-				  sizeof(struct skb_shared_info)) & \
-				  ~(SMP_CACHE_BYTES - 1))
+#define SKB_MAX_ORDER(X, ORDER)	((PAGE_SIZE << (ORDER)) - (X) - \
+				 SKB_DATA_ALIGN(sizeof(struct skb_shared_info)))
 #define SKB_MAX_HEAD(X)		(SKB_MAX_ORDER((X), 0))
 #define SKB_MAX_ALLOC		(SKB_MAX_ORDER(0, 2))
 
index c9fad6f..9694fdf 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1162,7 +1162,7 @@ static inline struct sk_buff *sk_stream_
 	struct sk_buff *skb;
 	int hdr_len;
 
-	hdr_len = SKB_DATA_ALIGN(sk->sk_prot->max_header);
+	hdr_len = sk->sk_prot->max_header;
 	skb = alloc_skb_fclone(size + hdr_len, gfp);
 	if (skb) {
 		skb->truesize += mem;

--M9NhX3UHpAaciwkO--
