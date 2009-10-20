From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: [PATCH RFC] net: add alloc_skb_mustcopy() to make clone copy
Date: Tue, 20 Oct 2009 15:19:18 +0900
Message-ID: <4ADD5666.9090409@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from claw.goop.org ([74.207.240.146]:54455 "EHLO claw.goop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750843AbZJTGTU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Oct 2009 02:19:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ RFC only ]

When doing network IO on behalf of guests, a Xen dom0 kernel gets granted
pages from guests.  These pages cannot be released normally, so we must
handle releasing them specially, which can do with a skb_destructor.

This is complicated by the fact that the lifetime of an skb's
frags can be extended via cloning.  To address this, this patch adds
alloc_skb_mustcopy() which allocates an skb with fclone==SKB_MUST_COPY.
If skb_clone() sees an skb with this set, it simply calls skb_copy
instead so that there are no aliases to the granted pages.

/* Signed-off-by: Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com> */

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index f2c69a2..830203f 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -228,6 +228,7 @@ enum {
 	SKB_FCLONE_UNAVAILABLE,
 	SKB_FCLONE_ORIG,
 	SKB_FCLONE_CLONE,
+	SKB_MUST_COPY,
 };
 
 enum {
@@ -449,13 +450,19 @@ extern struct sk_buff *__alloc_skb(unsigned int size,
 static inline struct sk_buff *alloc_skb(unsigned int size,
 					gfp_t priority)
 {
-	return __alloc_skb(size, priority, 0, -1);
+	return __alloc_skb(size, priority, SKB_FCLONE_UNAVAILABLE, -1);
 }
 
 static inline struct sk_buff *alloc_skb_fclone(unsigned int size,
 					       gfp_t priority)
 {
-	return __alloc_skb(size, priority, 1, -1);
+	return __alloc_skb(size, priority, SKB_FCLONE_ORIG, -1);
+}
+
+static inline struct sk_buff *alloc_skb_mustcopy(unsigned int size,
+					       gfp_t priority)
+{
+	return __alloc_skb(size, priority, SKB_MUST_COPY, -1);
 }
 
 extern int skb_recycle_check(struct sk_buff *skb, int skb_size);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 9e0597d..b130fab 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -177,7 +177,9 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 	struct sk_buff *skb;
 	u8 *data;
 
-	cache = fclone ? skbuff_fclone_cache : skbuff_head_cache;
+	cache = skbuff_head_cache;
+	if (fclone == SKB_FCLONE_ORIG)
+		cache = skbuff_fclone_cache;
 
 	/* Get the HEAD */
 	skb = kmem_cache_alloc_node(cache, gfp_mask & ~__GFP_DMA, node);
@@ -220,13 +222,13 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 	skb_frag_list_init(skb);
 	memset(&shinfo->hwtstamps, 0, sizeof(shinfo->hwtstamps));
 
-	if (fclone) {
+	skb->fclone = fclone;
+	if (fclone == SKB_FCLONE_ORIG) {
 		struct sk_buff *child = skb + 1;
 		atomic_t *fclone_ref = (atomic_t *) (child + 1);
 
 		kmemcheck_annotate_bitfield(child, flags1);
 		kmemcheck_annotate_bitfield(child, flags2);
-		skb->fclone = SKB_FCLONE_ORIG;
 		atomic_set(fclone_ref, 1);
 
 		child->fclone = SKB_FCLONE_UNAVAILABLE;
@@ -259,7 +261,8 @@ struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
 	int node = dev->dev.parent ? dev_to_node(dev->dev.parent) : -1;
 	struct sk_buff *skb;
 
-	skb = __alloc_skb(length + NET_SKB_PAD, gfp_mask, 0, node);
+	skb = __alloc_skb(length + NET_SKB_PAD, gfp_mask,
+			  SKB_FCLONE_UNAVAILABLE, node);
 	if (likely(skb)) {
 		skb_reserve(skb, NET_SKB_PAD);
 		skb->dev = dev;
@@ -364,6 +367,7 @@ static void kfree_skbmem(struct sk_buff *skb)
 
 	switch (skb->fclone) {
 	case SKB_FCLONE_UNAVAILABLE:
+	case SKB_MUST_COPY:
 		kmem_cache_free(skbuff_head_cache, skb);
 		break;
 
@@ -493,7 +497,9 @@ int skb_recycle_check(struct sk_buff *skb, int skb_size)
 {
 	struct skb_shared_info *shinfo;
 
-	if (skb_is_nonlinear(skb) || skb->fclone != SKB_FCLONE_UNAVAILABLE)
+	if (skb_is_nonlinear(skb) ||
+	    skb->fclone == SKB_FCLONE_ORIG ||
+	    skb->fclone == SKB_FCLONE_CLONE)
 		return 0;
 
 	skb_size = SKB_DATA_ALIGN(skb_size + NET_SKB_PAD);
@@ -640,6 +646,8 @@ struct sk_buff *skb_clone(struct sk_buff *skb, gfp_t gfp_mask)
 		atomic_t *fclone_ref = (atomic_t *) (n + 1);
 		n->fclone = SKB_FCLONE_CLONE;
 		atomic_inc(fclone_ref);
+	} else if (skb->fclone == SKB_MUST_COPY) {
+		return skb_copy(skb, gfp_mask);
 	} else {
 		n = kmem_cache_alloc(skbuff_head_cache, gfp_mask);
 		if (!n)


