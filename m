From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [NET]: Get rid of alloc_skb code duplication
Date: Tue, 17 Apr 2007 21:57:46 +1000
Message-ID: <20070417115746.GA20287@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4564 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753873AbXDQL56 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2007 07:57:58 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave:

[NET]: Get rid of alloc_skb code duplication

The skb initialisation code is shared between alloc_skb and
alloc_skb_from_cache.  Now I don't know what actually uses
the latter so perhaps we could simply get rid of it.

However, if we're to keep it, then let's move the common code
out as they've started diverging.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index fae7f94..db4f526 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -128,6 +128,31 @@ EXPORT_SYMBOL(skb_truesize_bug);
  *
  */
 
+static void init_skb(struct sk_buff *skb, u8 *data, unsigned int size)
+{
+	struct skb_shared_info *shinfo;
+
+	/*
+	 * See comment in sk_buff definition, just before the 'tail' member
+	 */
+	memset(skb, 0, offsetof(struct sk_buff, tail));
+	skb->truesize = size + sizeof(struct sk_buff);
+	atomic_set(&skb->users, 1);
+	skb->head = data;
+	skb->data = data;
+	skb_reset_tail_pointer(skb);
+	skb->end = skb->tail + size;
+	/* make sure we initialize shinfo sequentially */
+	shinfo = skb_shinfo(skb);
+	atomic_set(&shinfo->dataref, 1);
+	shinfo->nr_frags  = 0;
+	shinfo->gso_size = 0;
+	shinfo->gso_segs = 0;
+	shinfo->gso_type = 0;
+	shinfo->ip6_frag_id = 0;
+	shinfo->frag_list = NULL;
+}
+
 /**
  *	__alloc_skb	-	allocate a network buffer
  *	@size: size to allocate
@@ -147,7 +172,6 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 			    int fclone, int node)
 {
 	struct kmem_cache *cache;
-	struct skb_shared_info *shinfo;
 	struct sk_buff *skb;
 	u8 *data;
 
@@ -164,25 +188,7 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 	if (!data)
 		goto nodata;
 
-	/*
-	 * See comment in sk_buff definition, just before the 'tail' member
-	 */
-	memset(skb, 0, offsetof(struct sk_buff, tail));
-	skb->truesize = size + sizeof(struct sk_buff);
-	atomic_set(&skb->users, 1);
-	skb->head = data;
-	skb->data = data;
-	skb_reset_tail_pointer(skb);
-	skb->end = skb->tail + size;
-	/* make sure we initialize shinfo sequentially */
-	shinfo = skb_shinfo(skb);
-	atomic_set(&shinfo->dataref, 1);
-	shinfo->nr_frags  = 0;
-	shinfo->gso_size = 0;
-	shinfo->gso_segs = 0;
-	shinfo->gso_type = 0;
-	shinfo->ip6_frag_id = 0;
-	shinfo->frag_list = NULL;
+	init_skb(skb, data, size);
 
 	if (fclone) {
 		struct sk_buff *child = skb + 1;
@@ -233,23 +239,8 @@ struct sk_buff *alloc_skb_from_cache(struct kmem_cache *cp,
 	data = kmem_cache_alloc(cp, gfp_mask);
 	if (!data)
 		goto nodata;
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
 
-	atomic_set(&(skb_shinfo(skb)->dataref), 1);
-	skb_shinfo(skb)->nr_frags  = 0;
-	skb_shinfo(skb)->gso_size = 0;
-	skb_shinfo(skb)->gso_segs = 0;
-	skb_shinfo(skb)->gso_type = 0;
-	skb_shinfo(skb)->frag_list = NULL;
+	init_skb(skb, data, size);
 out:
 	return skb;
 nodata:
