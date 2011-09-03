From: kaber@trash.net
Subject: [PATCH 02/11] net: add function to allocate skbuff head without data area
Date: Sat,  3 Sep 2011 19:26:02 +0200
Message-ID: <1315070771-18576-3-git-send-email-kaber@trash.net>
References: <1315070771-18576-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56146 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753199Ab1ICR0R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Sep 2011 13:26:17 -0400
In-Reply-To: <1315070771-18576-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Add a function to allocate a skbuff head without any data. This will be
used by memory mapped netlink to attach data from the mmaped area to the
skb.

Additionally change skb_release_all() to check whether the skb has a
data area to allow the skb destructor to clear the data pointer in
case only a head has been allocated.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/skbuff.h |    6 ++++++
 net/core/skbuff.c      |   31 ++++++++++++++++++++++++++++++-
 2 files changed, 36 insertions(+), 1 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 7b996ed..8cfc285 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -521,6 +521,12 @@ static inline struct sk_buff *alloc_skb_fclone(unsigned int size,
 	return __alloc_skb(size, priority, 1, NUMA_NO_NODE);
 }
 
+extern struct sk_buff *__alloc_skb_head(gfp_t priority, int node);
+static inline struct sk_buff *alloc_skb_head(gfp_t priority)
+{
+	return __alloc_skb_head(priority, -1);
+}
+
 extern bool skb_recycle_check(struct sk_buff *skb, int skb_size);
 
 extern struct sk_buff *skb_morph(struct sk_buff *dst, struct sk_buff *src);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 2beda82..d632de9 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -153,6 +153,34 @@ static void skb_under_panic(struct sk_buff *skb, int sz, void *here)
  *
  */
 
+struct sk_buff *__alloc_skb_head(gfp_t gfp_mask, int node)
+{
+	struct sk_buff *skb;
+
+	/* Get the HEAD */
+	skb = kmem_cache_alloc_node(skbuff_head_cache,
+				    gfp_mask & ~__GFP_DMA, node);
+	if (!skb)
+		goto out;
+	prefetchw(skb);
+
+	/*
+	 * Only clear those fields we need to clear, not those that we will
+	 * actually initialise below. Hence, don't put any more fields after
+	 * the tail pointer in struct sk_buff!
+	 */
+	memset(skb, 0, offsetof(struct sk_buff, tail));
+	skb->data = NULL;
+	skb->truesize = sizeof(struct sk_buff);
+	atomic_set(&skb->users, 1);
+
+#ifdef NET_SKBUFF_DATA_USES_OFFSET
+	skb->mac_header = ~0U;
+#endif
+out:
+	return skb;
+}
+
 /**
  *	__alloc_skb	-	allocate a network buffer
  *	@size: size to allocate
@@ -414,7 +442,8 @@ static void skb_release_head_state(struct sk_buff *skb)
 static void skb_release_all(struct sk_buff *skb)
 {
 	skb_release_head_state(skb);
-	skb_release_data(skb);
+	if (likely(skb->data))
+		skb_release_data(skb);
 }
 
 /**
-- 
1.7.4.4
