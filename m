From: Neil Horman <nhorman@tuxdriver.com>
Subject: [RFC PATCH 1/5] net: add SKB_FCLONE_SCRATCH API
Date: Thu, 27 Oct 2011 15:53:37 -0400
Message-ID: <1319745221-30880-2-git-send-email-nhorman@tuxdriver.com>
References: <1319745221-30880-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@updev.think-freely.org>,
	Neil Horman <nhorman@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38385 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752520Ab1J0TyP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2011 15:54:15 -0400
In-Reply-To: <1319745221-30880-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@updev.think-freely.org>

The FCLONE api for skb allocation is nice in that it allows for the
pre-allocation of skbs when you know you will need additional clones.  A nice
addition to this api would be the ability to quickly allocate extra skbs when
needed without having to call into the slab allocator.  This API provides that
ability.  By using the internally fragmented space between the tail and end
pointer, and after the skb_shinfo space, we can opportunistically format this
space for use as extra sk_buff structures.  This allows for both fast
allocations in cases where skbs need to be cloned quickly (like in a multiple
multicast listener workload), and it does so without needing to allocate further
memory from the system, reducing overall memory demand.

There are rules when using this api however:

1) skbs that have their data reserved via this api become fixed, i.e. they can
no longer call skb_pull, or pskb_expand_tail

2) only a single skb can reserve the space.  The api assumes that the skb that
reserves the space is the owner, and only that skbs owning context will allocate
out of the shared area

Tested successfully by myself
Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
---
 include/linux/skbuff.h |   51 +++++++++++++++++++++++++++++-
 net/core/skbuff.c      |   82 ++++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 129 insertions(+), 4 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 6a6b352..e04fa48 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -258,7 +258,7 @@ struct skb_shared_info {
 	skb_frag_t	frags[MAX_SKB_FRAGS];
 };
 
-/* We divide dataref into two halves.  The higher 16 bits hold references
+/* We divide dataref two halves.  The higher 15 bits hold references
  * to the payload part of skb->data.  The lower 16 bits hold references to
  * the entire skb->data.  A clone of a headerless skb holds the length of
  * the header in skb->hdr_len.
@@ -277,6 +277,7 @@ enum {
 	SKB_FCLONE_UNAVAILABLE,
 	SKB_FCLONE_ORIG,
 	SKB_FCLONE_CLONE,
+	SKB_FCLONE_SCRATCH,
 };
 
 enum {
@@ -2512,5 +2513,53 @@ static inline bool skb_is_recycleable(const struct sk_buff *skb, int skb_size)
 
 	return true;
 }
+
+struct skb_scr_control {
+	struct sk_buff_head scr_skbs;
+	struct sk_buff *owner;
+};
+
+/*
+ * gets our control data for the scratch area
+ */
+static inline struct skb_scr_control*
+	skb_get_scratch_control(struct sk_buff *skb)
+{
+	struct skb_scr_control *sctl;
+	sctl = (struct skb_scr_control *)((void *)skb_shinfo(skb) +
+					  sizeof(struct skb_shared_info));
+	return sctl;
+}
+
+/*
+ * Converts the scratch space of an skbs data area to a list of
+ * skbuffs.  Returns the number of additional skbs allocated
+ */
+extern unsigned int skb_make_fclone_scratch(struct sk_buff *skb);
+
+/*
+ * Allocates an skb out of our scratch space
+ */
+static inline struct sk_buff *alloc_fscratch_skb(struct sk_buff *skb)
+{
+	struct skb_scr_control *sctl = skb_get_scratch_control(skb);
+	struct sk_buff *sskb;
+
+	BUG_ON(skb->fclone != SKB_FCLONE_SCRATCH);
+	BUG_ON(!sctl);
+	BUG_ON(sctl->owner != skb);
+	if (skb_queue_empty(&sctl->scr_skbs))
+		return NULL;
+
+	sskb = __skb_dequeue(&sctl->scr_skbs);
+
+	/*
+	 * Mark us as a scratch skb, so we get properly kfree-ed
+	 */
+	sskb->fclone = SKB_FCLONE_SCRATCH;
+
+	return sskb;
+}
+
 #endif	/* __KERNEL__ */
 #endif	/* _LINUX_SKBUFF_H */
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index ca4db40..6fdf1a7 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -367,6 +367,7 @@ static void kfree_skbmem(struct sk_buff *skb)
 	atomic_t *fclone_ref;
 
 	switch (skb->fclone) {
+	case SKB_FCLONE_SCRATCH:
 	case SKB_FCLONE_UNAVAILABLE:
 		kmem_cache_free(skbuff_head_cache, skb);
 		break;
@@ -438,8 +439,16 @@ static void skb_release_all(struct sk_buff *skb)
 
 void __kfree_skb(struct sk_buff *skb)
 {
+	struct skb_scr_control *sctl;
+	bool need_free = (skb->fclone == SKB_FCLONE_SCRATCH);
+	if (need_free) {
+		sctl = skb_get_scratch_control(skb);
+		need_free = (sctl->owner == skb);
+	}
+
 	skb_release_all(skb);
-	kfree_skbmem(skb);
+	if (need_free)
+		kfree_skbmem(skb);
 }
 EXPORT_SYMBOL(__kfree_skb);
 
@@ -701,6 +710,7 @@ int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
 struct sk_buff *skb_clone(struct sk_buff *skb, gfp_t gfp_mask)
 {
 	struct sk_buff *n;
+	atomic_t *fclone_ref;
 
 	if (skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY) {
 		if (skb_copy_ubufs(skb, gfp_mask))
@@ -710,10 +720,15 @@ struct sk_buff *skb_clone(struct sk_buff *skb, gfp_t gfp_mask)
 	n = skb + 1;
 	if (skb->fclone == SKB_FCLONE_ORIG &&
 	    n->fclone == SKB_FCLONE_UNAVAILABLE) {
-		atomic_t *fclone_ref = (atomic_t *) (n + 1);
+		fclone_ref = (atomic_t *) (n + 1);
 		n->fclone = SKB_FCLONE_CLONE;
 		atomic_inc(fclone_ref);
-	} else {
+	} else if (skb->fclone == SKB_FCLONE_SCRATCH)
+		n = alloc_fscratch_skb(skb);
+	else
+		n = NULL;
+
+	if (!n) {
 		n = kmem_cache_alloc(skbuff_head_cache, gfp_mask);
 		if (!n)
 			return NULL;
@@ -3205,3 +3220,64 @@ void __skb_warn_lro_forwarding(const struct sk_buff *skb)
 			   " while LRO is enabled\n", skb->dev->name);
 }
 EXPORT_SYMBOL(__skb_warn_lro_forwarding);
+
+unsigned int skb_make_fclone_scratch(struct sk_buff *skb)
+{
+	size_t bufsz, totsz, scrsz, tmpsz;
+	struct skb_scr_control *sctl;
+	struct sk_buff *scr_skb;
+	struct skb_shared_info *old_info;
+	bool format_tail = false;
+
+	if (skb_shared(skb))
+		return 0;
+
+	/*
+	 * Cant do scratch space on fcloned skbs
+	 */
+	if (skb->fclone)
+		return 0;
+
+	if ((skb->end - skb->tail) > sizeof(struct skb_shared_info)) {
+		old_info = skb_shinfo(skb);
+		skb->end = skb->tail;
+		memcpy(skb_shinfo(skb), old_info,
+		       sizeof(struct skb_shared_info));
+	}
+
+	/*
+	 * skb is ours, lets see how big the data area is
+	 */
+	totsz = ksize(skb->head);
+
+	/*
+	 * This is the used size of our data buffer
+	 */
+	bufsz = (skb_end_pointer(skb) - skb->head) +
+		 sizeof(struct skb_shared_info);
+
+	if ((bufsz + sizeof(struct skb_scr_control)) >= totsz)
+		return 0;
+
+	/*
+	 * And this is the leftover area, minus sizeof(int) to store the number
+	 * of scratch skbs we have
+	 */
+	scrsz = totsz - (bufsz + sizeof(struct skb_scr_control));
+
+	sctl = skb_get_scratch_control(skb);
+
+	sctl->owner = skb;
+	scr_skb = (struct sk_buff *)(sctl + 1);
+	__skb_queue_head_init(&sctl->scr_skbs);
+	for (tmpsz = sizeof(struct sk_buff); tmpsz < scrsz;
+	    tmpsz += sizeof(struct sk_buff)) {
+		__skb_queue_tail(&sctl->scr_skbs, scr_skb);
+		scr_skb++;
+	}
+
+	skb->fclone = SKB_FCLONE_SCRATCH;
+
+	return skb_queue_len(&sctl->scr_skbs);
+
+}
-- 
1.7.6.4
