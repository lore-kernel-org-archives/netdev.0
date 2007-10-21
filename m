From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fw: [Bug 9189] New: Oops in kernel 2.6.21-rc4 through 2.6.23, page allocation failure
Date: Sun, 21 Oct 2007 12:56:01 +0800
Message-ID: <20071021045601.GA8427@gondor.apana.org.au>
References: <4718C651.5040804@psc.edu> <E1IiuGl-000482-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@linux-foundation.org, davem@davemloft.net,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org
To: John Heffner <jheffner@psc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4403 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750946AbXJUE5G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2007 00:57:06 -0400
Content-Disposition: inline
In-Reply-To: <E1IiuGl-000482-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 20, 2007 at 12:00:15AM +0800, Herbert Xu wrote:
> >> 
> >> Backtrace #1:
> >> page allocation failure. order:1, mode:0x20
> >>  [<c0131581>] __alloc_pages+0x2e1/0x300   
> >>  [<c0144bee>] cache_alloc_refill+0x29e/0x4b0
> >>  [<c0144e6e>] __kmalloc+0x6e/0x80
> >>  [<c0227103>] __alloc_skb+0x53/0x110
> >>  [<c024de5c>] tcp_collapse+0x1ac/0x370
> >>  [<c024e11d>] tcp_prune_queue+0xfd/0x2c0
> >>  [<c024eaad>] tcp_data_queue+0x7cd/0xbb0
> >>  [<c0225c2d>] skb_checksum+0x4d/0x2a0
> >>  [<c02504ee>] tcp_rcv_established+0x36e/0x6a0
> >>  [<c02561e4>] tcp_v4_do_rcv+0xb4/0x2a0
> >>  [<c0131379>] __alloc_pages+0xd9/0x300
> >>  [<c0258269>] tcp_v4_rcv+0x6a9/0x6c0
> >>  [<c023ddb1>] ip_local_deliver+0x91/0x110
> >>  [<c023e130>] ip_rcv+0x230/0x3c0
> >>  [<c0227103>] __alloc_skb+0x53/0x110
> >>  [<c022b742>] netif_receive_skb+0x152/0x1e0
> >>  [<c022ce6f>] process_backlog+0x6f/0xe0
> >>  [<c022cf3c>] net_rx_action+0x5c/0xf0
> >>  [<c0115af2>] __do_softirq+0x42/0x90
> >>  [<c0115b67>] do_softirq+0x27/0x30
> >>  [<c01044fd>] do_IRQ+0x3d/0x70
> >>  [<c0115818>] sys_gettimeofday+0x28/0x80
> >>  [<c0102967>] common_interrupt+0x23/0x28
> >>  =======================

I knew this looked familiar.  In fact I'd already sent a patch
to fix this back in June 2006 but it seems to have been lost.

Here it is again rediffed against today's kernel:

[NET]: Fix SKB_WITH_OVERHEAD calculation

The calculation in SKB_WITH_OVERHEAD is incorrect in that it can cause
an overflow across a page boundary which is what it's meant to prevent.
In particular, the header length (X) should not be lumped together with
skb_shared_info.  The latter needs to be aligned properly while the header
has no choice but to sit in front of wherever the payload is.

Therefore the correct calculation is to take away the aligned size of
skb_shared_info, and then subtract the header length.  The resulting
quantity L satisfies the following inequality:

	SKB_DATA_ALIGN(L + X) + sizeof(struct skb_shared_info) <= PAGE_SIZE

This is the quantity used by alloc_skb to do the actual allocation.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index f93f22b..369f60a 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -41,8 +41,7 @@
 #define SKB_DATA_ALIGN(X)	(((X) + (SMP_CACHE_BYTES - 1)) & \
 				 ~(SMP_CACHE_BYTES - 1))
 #define SKB_WITH_OVERHEAD(X)	\
-	(((X) - sizeof(struct skb_shared_info)) & \
-	 ~(SMP_CACHE_BYTES - 1))
+	((X) - SKB_DATA_ALIGN(sizeof(struct skb_shared_info)))
 #define SKB_MAX_ORDER(X, ORDER) \
 	SKB_WITH_OVERHEAD((PAGE_SIZE << (ORDER)) - (X))
 #define SKB_MAX_HEAD(X)		(SKB_MAX_ORDER((X), 0))
