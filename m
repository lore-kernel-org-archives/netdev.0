From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH 1/2] net: Allow skb_recycle_check to be done in stages
Date: Thu, 13 Oct 2011 09:33:54 -0500
Message-ID: <1318516435-24314-1-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe004.messaging.microsoft.com ([213.199.154.207]:10278
	"EHLO AM1EHSOBE004.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750956Ab1JMOeD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 10:34:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb_recycle_check resets the skb if it's eligible for recycling.
However, there are times when a driver might want to optionally
manipulate the skb data with the skb before resetting the skb,
but after it has determined eligibility.  We do this by splitting the
eligibility check from the skb reset, creating two inline functions to
accomplish that task.

Signed-off-by: Andy Fleming <afleming@freescale.com>
---

I found this useful for a driver we're working on where the device can
do different things, depending on whether the skb is recycleable.

 include/linux/skbuff.h |   21 +++++++++++++++++++
 net/core/skbuff.c      |   51 ++++++++++++++++++++++++-----------------------
 2 files changed, 47 insertions(+), 25 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index ac6b05a..6b35ca1 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -525,6 +525,7 @@ static inline struct sk_buff *alloc_skb_fclone(unsigned int size,
 	return __alloc_skb(size, priority, 1, NUMA_NO_NODE);
 }
 
+extern void skb_recycle(struct sk_buff *skb);
 extern bool skb_recycle_check(struct sk_buff *skb, int skb_size);
 
 extern struct sk_buff *skb_morph(struct sk_buff *dst, struct sk_buff *src);
@@ -2459,5 +2460,25 @@ static inline void skb_checksum_none_assert(struct sk_buff *skb)
 
 bool skb_partial_csum_set(struct sk_buff *skb, u16 start, u16 off);
 
+static inline bool skb_is_recycleable(struct sk_buff *skb, int skb_size)
+{
+	if (irqs_disabled())
+		return false;
+
+	if (skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY)
+		return false;
+
+	if (skb_is_nonlinear(skb) || skb->fclone != SKB_FCLONE_UNAVAILABLE)
+		return false;
+
+	skb_size = SKB_DATA_ALIGN(skb_size + NET_SKB_PAD);
+	if (skb_end_pointer(skb) - skb->head < skb_size)
+		return false;
+
+	if (skb_shared(skb) || skb_cloned(skb))
+		return false;
+
+	return true;
+}
 #endif	/* __KERNEL__ */
 #endif	/* _LINUX_SKBUFF_H */
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 5b2c5f1..48bee84 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -475,6 +475,30 @@ void consume_skb(struct sk_buff *skb)
 EXPORT_SYMBOL(consume_skb);
 
 /**
+ * 	skb_recycle - clean up an skb for reuse
+ * 	@skb: buffer
+ *
+ * 	Recycles the skb to be reused as a receive buffer. This
+ * 	function does any necessary reference count dropping, and
+ * 	cleans up the skbuff as if it just came from __alloc_skb().
+ */
+void skb_recycle(struct sk_buff *skb)
+{
+	struct skb_shared_info *shinfo;
+
+	skb_release_head_state(skb);
+
+	shinfo = skb_shinfo(skb);
+	memset(shinfo, 0, offsetof(struct skb_shared_info, dataref));
+	atomic_set(&shinfo->dataref, 1);
+
+	memset(skb, 0, offsetof(struct sk_buff, tail));
+	skb->data = skb->head + NET_SKB_PAD;
+	skb_reset_tail_pointer(skb);
+}
+EXPORT_SYMBOL(skb_recycle);
+
+/**
  *	skb_recycle_check - check if skb can be reused for receive
  *	@skb: buffer
  *	@skb_size: minimum receive buffer size
@@ -488,33 +512,10 @@ EXPORT_SYMBOL(consume_skb);
  */
 bool skb_recycle_check(struct sk_buff *skb, int skb_size)
 {
-	struct skb_shared_info *shinfo;
-
-	if (irqs_disabled())
-		return false;
-
-	if (skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY)
-		return false;
-
-	if (skb_is_nonlinear(skb) || skb->fclone != SKB_FCLONE_UNAVAILABLE)
-		return false;
-
-	skb_size = SKB_DATA_ALIGN(skb_size + NET_SKB_PAD);
-	if (skb_end_pointer(skb) - skb->head < skb_size)
-		return false;
-
-	if (skb_shared(skb) || skb_cloned(skb))
+	if (!skb_is_recycleable(skb, skb_size))
 		return false;
 
-	skb_release_head_state(skb);
-
-	shinfo = skb_shinfo(skb);
-	memset(shinfo, 0, offsetof(struct skb_shared_info, dataref));
-	atomic_set(&shinfo->dataref, 1);
-
-	memset(skb, 0, offsetof(struct sk_buff, tail));
-	skb->data = skb->head + NET_SKB_PAD;
-	skb_reset_tail_pointer(skb);
+	skb_recycle(skb);
 
 	return true;
 }
-- 
1.7.3.4
