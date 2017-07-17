From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next] net: Revert "net: add function to allocate sk_buff head without data area"
Date: Mon, 17 Jul 2017 18:56:54 +0200
Message-ID: <20170717165654.20026-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:45906 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751301AbdGQQ4k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 12:56:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It was added for netlink mmap tx, there are no callers in the tree.
The commit also added a check for skb->head != NULL in kfree_skb path,
remove that too -- all skbs ought to have skb->head set.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/linux/skbuff.h |  6 ------
 net/core/skbuff.c      | 31 ++-----------------------------
 2 files changed, 2 insertions(+), 35 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index dbe29b6c9bd6..a749ba5c787f 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -945,12 +945,6 @@ static inline struct sk_buff *alloc_skb_fclone(unsigned int size,
 	return __alloc_skb(size, priority, SKB_ALLOC_FCLONE, NUMA_NO_NODE);
 }
 
-struct sk_buff *__alloc_skb_head(gfp_t priority, int node);
-static inline struct sk_buff *alloc_skb_head(gfp_t priority)
-{
-	return __alloc_skb_head(priority, -1);
-}
-
 struct sk_buff *skb_morph(struct sk_buff *dst, struct sk_buff *src);
 int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask);
 struct sk_buff *skb_clone(struct sk_buff *skb, gfp_t priority);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index b352c6bcfb31..6bc19c80c210 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -158,31 +158,6 @@ static void *__kmalloc_reserve(size_t size, gfp_t flags, int node,
  *
  */
 
-struct sk_buff *__alloc_skb_head(gfp_t gfp_mask, int node)
-{
-	struct sk_buff *skb;
-
-	/* Get the HEAD */
-	skb = kmem_cache_alloc_node(skbuff_head_cache,
-				    gfp_mask & ~__GFP_DMA, node);
-	if (!skb)
-		goto out;
-
-	/*
-	 * Only clear those fields we need to clear, not those that we will
-	 * actually initialise below. Hence, don't put any more fields after
-	 * the tail pointer in struct sk_buff!
-	 */
-	memset(skb, 0, offsetof(struct sk_buff, tail));
-	skb->head = NULL;
-	skb->truesize = sizeof(struct sk_buff);
-	refcount_set(&skb->users, 1);
-
-	skb->mac_header = (typeof(skb->mac_header))~0U;
-out:
-	return skb;
-}
-
 /**
  *	__alloc_skb	-	allocate a network buffer
  *	@size: size to allocate
@@ -663,8 +638,7 @@ void skb_release_head_state(struct sk_buff *skb)
 static void skb_release_all(struct sk_buff *skb)
 {
 	skb_release_head_state(skb);
-	if (likely(skb->head))
-		skb_release_data(skb);
+	skb_release_data(skb);
 }
 
 /**
@@ -762,8 +736,7 @@ void consume_stateless_skb(struct sk_buff *skb)
 		return;
 
 	trace_consume_skb(skb);
-	if (likely(skb->head))
-		skb_release_data(skb);
+	skb_release_data(skb);
 	kfree_skbmem(skb);
 }
 
-- 
2.13.0
