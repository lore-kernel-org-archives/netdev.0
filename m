From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Subject: [PATCH 7/8] net/emergency_skb: create a deep copy on clone
Date: Fri,  2 Jul 2010 21:20:20 +0200
Message-ID: <1278098421-21296-8-git-send-email-sebastian@breakpoint.cc>
References: <1278098421-21296-1-git-send-email-sebastian@breakpoint.cc>
Cc: tglx@linutronix.de,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:41209 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757547Ab0GBTUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jul 2010 15:20:35 -0400
In-Reply-To: <1278098421-21296-1-git-send-email-sebastian@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

skb_clone() creates a clone of the skb: a new head is allocated from the
slab cache and the reference counter for the data part is incremented.
For the skbs from the emergency pool, we don't really want to clone
them that way:
- talking to slab may lead to lock contention which in turn increases
  the latency.
- the original (with the data part) may return earlier to the pool than
  the clone. In that case we would "lose" the skb from the emergency
  pool.

Instead we do a copy of head and data into a skb from the emergency
pool.
This patch cuts pskb_copy() into a helper function which does
the bare work and the remaining pskb_copy() allocates a new skb and
calls it.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 net/core/skbuff.c |   80 +++++++++++++++++++++++++++++++++++++++--------------
 1 files changed, 59 insertions(+), 21 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index f02737d..9e094fc 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -613,6 +613,7 @@ struct sk_buff *skb_morph(struct sk_buff *dst, struct sk_buff *src)
 }
 EXPORT_SYMBOL_GPL(skb_morph);
 
+static int __pskb_copy(struct sk_buff *skb, struct sk_buff *n);
 /**
  *	skb_clone	-	duplicate an sk_buff
  *	@skb: buffer to clone
@@ -631,6 +632,20 @@ struct sk_buff *skb_clone(struct sk_buff *skb, gfp_t gfp_mask)
 {
 	struct sk_buff *n;
 
+	if (skb->emerg_dev) {
+		n = skb_dequeue(&skb->emerg_dev->rx_recycle);
+		if (!n)
+			goto norm_clone;
+		/* remove earlier reservers */
+		skb_reserve(n, - skb_headroom(n));
+		if (!__pskb_copy(skb, n)) {
+			n->emerg_dev = skb->emerg_dev;
+			dev_hold(skb->emerg_dev);
+			return n;
+		}
+		net_recycle_add(skb->emerg_dev, n);
+	}
+norm_clone:
 	n = skb + 1;
 	if (skb->fclone == SKB_FCLONE_ORIG &&
 	    n->fclone == SKB_FCLONE_UNAVAILABLE) {
@@ -720,31 +735,22 @@ struct sk_buff *skb_copy(const struct sk_buff *skb, gfp_t gfp_mask)
 EXPORT_SYMBOL(skb_copy);
 
 /**
- *	pskb_copy	-	create copy of an sk_buff with private head.
- *	@skb: buffer to copy
- *	@gfp_mask: allocation priority
+ *      __pskb_copy     -       create copy of an sk_buff with private head.
+ *      @skb: buffer to copy
+ *      @n: skb to copy it
  *
- *	Make a copy of both an &sk_buff and part of its data, located
- *	in header. Fragmented data remain shared. This is used when
- *	the caller wishes to modify only header of &sk_buff and needs
- *	private copy of the header to alter. Returns %NULL on failure
- *	or the pointer to the buffer on success.
- *	The returned buffer has a reference count of 1.
+ *      This functions behaves like pskb_copy() except that it takes
+ *      an allready allocated skb where it will copy head and data.
+ *      The returned buffer has a reference count of 1.
  */
-
-struct sk_buff *pskb_copy(struct sk_buff *skb, gfp_t gfp_mask)
+static int __pskb_copy(struct sk_buff *skb, struct sk_buff *n)
 {
-	/*
-	 *	Allocate the copy buffer
-	 */
-	struct sk_buff *n;
 #ifdef NET_SKBUFF_DATA_USES_OFFSET
-	n = alloc_skb(skb->end, gfp_mask);
+	if (skb->end > n->end)
 #else
-	n = alloc_skb(skb->end - skb->head, gfp_mask);
+	if ((skb->end - skb->head) > (n->end - n->head))
 #endif
-	if (!n)
-		goto out;
+		return -EMSGSIZE;
 
 	/* Set the data pointer */
 	skb_reserve(n, skb->data - skb->head);
@@ -773,8 +779,40 @@ struct sk_buff *pskb_copy(struct sk_buff *skb, gfp_t gfp_mask)
 	}
 
 	copy_skb_header(n, skb);
-out:
-	return n;
+	return 0;
+}
+
+/**
+ *	pskb_copy	-	create copy of an sk_buff with private head.
+ *	@skb: buffer to copy
+ *	@gfp_mask: allocation priority
+ *
+ *	Make a copy of both an &sk_buff and part of its data, located
+ *	in header. Fragmented data remain shared. This is used when
+ *	the caller wishes to modify only header of &sk_buff and needs
+ *	private copy of the header to alter. Returns %NULL on failure
+ *	or the pointer to the buffer on success.
+ *	The returned buffer has a reference count of 1.
+ */
+
+struct sk_buff *pskb_copy(struct sk_buff *skb, gfp_t gfp_mask)
+{
+	/*
+	 *	Allocate the copy buffer
+	 */
+	struct sk_buff *n;
+#ifdef NET_SKBUFF_DATA_USES_OFFSET
+	n = alloc_skb(skb->end, gfp_mask);
+#else
+	n = alloc_skb(skb->end - skb->head, gfp_mask);
+#endif
+	if (!n)
+		return NULL;
+	if (!__pskb_copy(skb, n))
+		return n;
+	kfree_skb(n);
+	return NULL;
+
 }
 EXPORT_SYMBOL(pskb_copy);
 
-- 
1.6.6.1

