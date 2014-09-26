From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] fclone layout suboptimal
Date: Fri, 26 Sep 2014 06:35:01 -0700
Message-ID: <1411738501.16953.122.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1411736859.16953.121.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:39326 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754210AbaIZNfC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 09:35:02 -0400
Received: by mail-pa0-f46.google.com with SMTP id kx10so13145854pab.5
        for <netdev@vger.kernel.org>; Fri, 26 Sep 2014 06:35:02 -0700 (PDT)
In-Reply-To: <1411736859.16953.121.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-09-26 at 06:07 -0700, Eric Dumazet wrote:

> [sk_buff skb1]
> [atomic_t fclone_ref]
> [sk_buff skb2]

Untested patch would be :

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index da1378a3e2c7..e39f03ea1822 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -178,6 +178,15 @@ out:
 	return skb;
 }
 
+/* Layout of fast clones : [skb1][fclone_ref][skb2] */
+struct sk_buff_fclones {
+	struct sk_buff	skb1;
+
+	atomic_t	fclone_ref;
+
+	struct sk_buff	skb2;
+};
+
 /**
  *	__alloc_skb	-	allocate a network buffer
  *	@size: size to allocate
@@ -257,16 +266,17 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 	kmemcheck_annotate_variable(shinfo->destructor_arg);
 
 	if (flags & SKB_ALLOC_FCLONE) {
-		struct sk_buff *child = skb + 1;
-		atomic_t *fclone_ref = (atomic_t *) (child + 1);
+		struct sk_buff_fclones *fclones;
+
+		fclones = (struct sk_buff_fclones *)skb;
 
-		kmemcheck_annotate_bitfield(child, flags1);
-		kmemcheck_annotate_bitfield(child, flags2);
-		skb->fclone = SKB_FCLONE_ORIG;
-		atomic_set(fclone_ref, 1);
+		kmemcheck_annotate_bitfield(&fclones->skb2, flags1);
+		kmemcheck_annotate_bitfield(&fclones->skb2, flags2);
+		fclones->skb1.fclone = SKB_FCLONE_ORIG;
+		atomic_set(&fclones->fclone_ref, 1);
 
-		child->fclone = SKB_FCLONE_UNAVAILABLE;
-		child->pfmemalloc = pfmemalloc;
+		fclones->skb2.fclone = SKB_FCLONE_UNAVAILABLE;
+		fclones->skb2.pfmemalloc = pfmemalloc;
 	}
 out:
 	return skb;
@@ -524,8 +534,7 @@ static void skb_release_data(struct sk_buff *skb)
  */
 static void kfree_skbmem(struct sk_buff *skb)
 {
-	struct sk_buff *other;
-	atomic_t *fclone_ref;
+	struct sk_buff_fclones *fclones;
 
 	switch (skb->fclone) {
 	case SKB_FCLONE_UNAVAILABLE:
@@ -533,22 +542,21 @@ static void kfree_skbmem(struct sk_buff *skb)
 		break;
 
 	case SKB_FCLONE_ORIG:
-		fclone_ref = (atomic_t *) (skb + 2);
-		if (atomic_dec_and_test(fclone_ref))
-			kmem_cache_free(skbuff_fclone_cache, skb);
+		fclones = container_of(skb, struct sk_buff_fclones, skb1);
+		if (atomic_dec_and_test(&fclones->fclone_ref))
+			kmem_cache_free(skbuff_fclone_cache, fclones);
 		break;
 
 	case SKB_FCLONE_CLONE:
-		fclone_ref = (atomic_t *) (skb + 1);
-		other = skb - 1;
+		fclones = container_of(skb, struct sk_buff_fclones, skb2);
 
 		/* The clone portion is available for
 		 * fast-cloning again.
 		 */
 		skb->fclone = SKB_FCLONE_UNAVAILABLE;
 
-		if (atomic_dec_and_test(fclone_ref))
-			kmem_cache_free(skbuff_fclone_cache, other);
+		if (atomic_dec_and_test(&fclones->fclone_ref))
+			kmem_cache_free(skbuff_fclone_cache, fclones);
 		break;
 	}
 }
@@ -855,17 +863,16 @@ EXPORT_SYMBOL_GPL(skb_copy_ubufs);
 
 struct sk_buff *skb_clone(struct sk_buff *skb, gfp_t gfp_mask)
 {
-	struct sk_buff *n;
+	struct sk_buff_fclones *fclones = (struct sk_buff_fclones *)skb;
+	struct sk_buff *n = &fclones->skb2;
 
 	if (skb_orphan_frags(skb, gfp_mask))
 		return NULL;
 
-	n = skb + 1;
 	if (skb->fclone == SKB_FCLONE_ORIG &&
 	    n->fclone == SKB_FCLONE_UNAVAILABLE) {
-		atomic_t *fclone_ref = (atomic_t *) (n + 1);
 		n->fclone = SKB_FCLONE_CLONE;
-		atomic_inc(fclone_ref);
+		atomic_inc(&fclones->fclone_ref);
 	} else {
 		if (skb_pfmemalloc(skb))
 			gfp_mask |= __GFP_MEMALLOC;
