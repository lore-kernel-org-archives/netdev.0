From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 02/11] net: add function to allocate skbuff head without data area
Date: Mon, 20 Aug 2012 08:18:43 +0200
Message-ID: <1345443532-3707-3-git-send-email-kaber@trash.net>
References: <1345443532-3707-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Florian.Westphal@Sophos.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1345443532-3707-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a function to allocate a skbuff head without any data. This will be
used by memory mapped netlink to attached data from the mmaped area to
the skb.

Additionally change skb_release_all() to check whether the skb has a
data area to allow the skb destructor to clear the data pointer in
case only a head has been allocated.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/skbuff.h |    6 ++++++
 net/core/skbuff.c      |   31 ++++++++++++++++++++++++++++++-
 2 files changed, 36 insertions(+), 1 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index b33a3a1..93fe80f 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -589,6 +589,12 @@ static inline struct sk_buff *alloc_skb_fclone(unsigned int size,
 	return __alloc_skb(size, priority, SKB_ALLOC_FCLONE, NUMA_NO_NODE);
 }
 
+extern struct sk_buff *__alloc_skb_head(gfp_t priority, int node);
+static inline struct sk_buff *alloc_skb_head(gfp_t priority)
+{
+	return __alloc_skb_head(priority, -1);
+}
+
 extern void skb_recycle(struct sk_buff *skb);
 extern bool skb_recycle_check(struct sk_buff *skb, int skb_size);
 
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index fe00d12..4046f6e 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -188,6 +188,34 @@ out:
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
@@ -581,7 +609,8 @@ static void skb_release_head_state(struct sk_buff *skb)
 static void skb_release_all(struct sk_buff *skb)
 {
 	skb_release_head_state(skb);
-	skb_release_data(skb);
+	if (likely(skb->data))
+		skb_release_data(skb);
 }
 
 /**
-- 
1.7.7.6

