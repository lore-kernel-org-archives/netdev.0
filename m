From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [NET]: Get rid of alloc_skb code duplication
Date: Wed, 18 Apr 2007 00:17:43 +1000
Message-ID: <20070417141743.GA21473@gondor.apana.org.au>
References: <20070417115746.GA20287@gondor.apana.org.au> <20070417130347.GA2632@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Keir Fraser <keir@xensource.com>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1513 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1030185AbXDQOSJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2007 10:18:09 -0400
Content-Disposition: inline
In-Reply-To: <20070417130347.GA2632@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 17, 2007 at 02:03:47PM +0100, Christoph Hellwig wrote:
>
> It was put in for Xen, but if you as the resident beat the crap out
> of Xen networking guru don't know about it we should probably just
> kill it.  Especially as we usually kill dead code pretty fast.

Heh, I wasn't touching Xen back then.

That's good news actually.  Xen has now killed their custom alloc_skb
so this is no longer needed.  Besides, even if they needed it they'll
have to patch it in anyway since you've already killed the ifdef that
lets them have a custom alloc_skb :)

[NET]: Get rid of alloc_skb_from_cache

Since this was added originally for Xen, and Xen has recently (~2.6.18)
stopped using this function, we can safely get rid of it.  Good timing
too since this function has started to bit rot.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 691ead8..a9b810d 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -342,9 +342,6 @@ static inline struct sk_buff *alloc_skb_fclone(unsigned int size,
 	return __alloc_skb(size, priority, 1, -1);
 }
 
-extern struct sk_buff *alloc_skb_from_cache(struct kmem_cache *cp,
-					    unsigned int size,
-					    gfp_t priority);
 extern void	       kfree_skbmem(struct sk_buff *skb);
 extern struct sk_buff *skb_clone(struct sk_buff *skb,
 				 gfp_t priority);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index fae7f94..2d8707e 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -202,63 +202,6 @@ nodata:
 }
 
 /**
- *	alloc_skb_from_cache	-	allocate a network buffer
- *	@cp: kmem_cache from which to allocate the data area
- *           (object size must be big enough for @size bytes + skb overheads)
- *	@size: size to allocate
- *	@gfp_mask: allocation mask
- *
- *	Allocate a new &sk_buff. The returned buffer has no headroom and
- *	tail room of size bytes. The object has a reference count of one.
- *	The return is the buffer. On a failure the return is %NULL.
- *
- *	Buffers may only be allocated from interrupts using a @gfp_mask of
- *	%GFP_ATOMIC.
- */
-struct sk_buff *alloc_skb_from_cache(struct kmem_cache *cp,
-				     unsigned int size,
-				     gfp_t gfp_mask)
-{
-	struct sk_buff *skb;
-	u8 *data;
-
-	/* Get the HEAD */
-	skb = kmem_cache_alloc(skbuff_head_cache,
-			       gfp_mask & ~__GFP_DMA);
-	if (!skb)
-		goto out;
-
-	/* Get the DATA. */
-	size = SKB_DATA_ALIGN(size);
-	data = kmem_cache_alloc(cp, gfp_mask);
-	if (!data)
-		goto nodata;
-	/*
-	 * See comment in sk_buff definition, just before the 'tail' member
-	 */
-	memset(skb, 0, offsetof(struct sk_buff, tail));
-	skb->truesize = size + sizeof(struct sk_buff);
-	atomic_set(&skb->users, 1);
-	skb->head = data;
-	skb->data = data;
-	skb_reset_tail_pointer(skb);
-	skb->end  = skb->tail + size;
-
-	atomic_set(&(skb_shinfo(skb)->dataref), 1);
-	skb_shinfo(skb)->nr_frags  = 0;
-	skb_shinfo(skb)->gso_size = 0;
-	skb_shinfo(skb)->gso_segs = 0;
-	skb_shinfo(skb)->gso_type = 0;
-	skb_shinfo(skb)->frag_list = NULL;
-out:
-	return skb;
-nodata:
-	kmem_cache_free(skbuff_head_cache, skb);
-	skb = NULL;
-	goto out;
-}
-
-/**
  *	__netdev_alloc_skb - allocate an skbuff for rx on a specific device
  *	@dev: network device to receive on
  *	@length: length to allocate
