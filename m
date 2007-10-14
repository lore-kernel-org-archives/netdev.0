From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 2/10] [SKBUFF]: Add skb_morph
Date: Sun, 14 Oct 2007 12:27:40 +0800
Message-ID: <E1Igv4m-00030E-00@gondolin.me.apana.org.au>
References: <20071014042604.GA11431@gondor.apana.org.au>
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1395 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751439AbXJNE1y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Oct 2007 00:27:54 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[SKBUFF]: Add skb_morph

This patch creates a new function skb_morph that's just like skb_clone
except that it lets user provide the spare skb that will be overwritten
by the one that's to be cloned.

This will be used by IP fragment reassembly so that we get back the same
skb that went in last (rather than the head skb that we get now which
requires us to carry around double pointers all over the place).

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/skbuff.h |    1 
 net/core/skbuff.c      |   83 +++++++++++++++++++++++++++++++------------------
 2 files changed, 54 insertions(+), 30 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index a656cec..be5bf0b 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -357,6 +357,7 @@ static inline struct sk_buff *alloc_skb_fclone(unsigned int size,
 }
 
 extern void	       kfree_skbmem(struct sk_buff *skb);
+extern struct sk_buff *skb_morph(struct sk_buff *dst, struct sk_buff *src);
 extern struct sk_buff *skb_clone(struct sk_buff *skb,
 				 gfp_t priority);
 extern struct sk_buff *skb_copy(const struct sk_buff *skb,
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 758bbef..c3aa68c 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -400,37 +400,8 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 	skb_copy_secmark(new, old);
 }
 
-/**
- *	skb_clone	-	duplicate an sk_buff
- *	@skb: buffer to clone
- *	@gfp_mask: allocation priority
- *
- *	Duplicate an &sk_buff. The new one is not owned by a socket. Both
- *	copies share the same packet data but not structure. The new
- *	buffer has a reference count of 1. If the allocation fails the
- *	function returns %NULL otherwise the new buffer is returned.
- *
- *	If this function is called from an interrupt gfp_mask() must be
- *	%GFP_ATOMIC.
- */
-
-struct sk_buff *skb_clone(struct sk_buff *skb, gfp_t gfp_mask)
+static struct sk_buff *__skb_clone(struct sk_buff *n, struct sk_buff *skb)
 {
-	struct sk_buff *n;
-
-	n = skb + 1;
-	if (skb->fclone == SKB_FCLONE_ORIG &&
-	    n->fclone == SKB_FCLONE_UNAVAILABLE) {
-		atomic_t *fclone_ref = (atomic_t *) (n + 1);
-		n->fclone = SKB_FCLONE_CLONE;
-		atomic_inc(fclone_ref);
-	} else {
-		n = kmem_cache_alloc(skbuff_head_cache, gfp_mask);
-		if (!n)
-			return NULL;
-		n->fclone = SKB_FCLONE_UNAVAILABLE;
-	}
-
 #define C(x) n->x = skb->x
 
 	n->next = n->prev = NULL;
@@ -462,6 +433,58 @@ struct sk_buff *skb_clone(struct sk_buff *skb, gfp_t gfp_mask)
 	skb->cloned = 1;
 
 	return n;
+#undef C
+}
+
+/**
+ *	skb_morph	-	morph one skb into another
+ *	@dst: the skb to receive the contents
+ *	@src: the skb to supply the contents
+ *
+ *	This is identical to skb_clone except that the target skb is
+ *	supplied by the user.
+ *
+ *	The target skb is returned upon exit.
+ */
+struct sk_buff *skb_morph(struct sk_buff *dst, struct sk_buff *src)
+{
+	skb_release_data(dst);
+	return __skb_clone(dst, src);
+}
+EXPORT_SYMBOL_GPL(skb_morph);
+
+/**
+ *	skb_clone	-	duplicate an sk_buff
+ *	@skb: buffer to clone
+ *	@gfp_mask: allocation priority
+ *
+ *	Duplicate an &sk_buff. The new one is not owned by a socket. Both
+ *	copies share the same packet data but not structure. The new
+ *	buffer has a reference count of 1. If the allocation fails the
+ *	function returns %NULL otherwise the new buffer is returned.
+ *
+ *	If this function is called from an interrupt gfp_mask() must be
+ *	%GFP_ATOMIC.
+ */
+
+struct sk_buff *skb_clone(struct sk_buff *skb, gfp_t gfp_mask)
+{
+	struct sk_buff *n;
+
+	n = skb + 1;
+	if (skb->fclone == SKB_FCLONE_ORIG &&
+	    n->fclone == SKB_FCLONE_UNAVAILABLE) {
+		atomic_t *fclone_ref = (atomic_t *) (n + 1);
+		n->fclone = SKB_FCLONE_CLONE;
+		atomic_inc(fclone_ref);
+	} else {
+		n = kmem_cache_alloc(skbuff_head_cache, gfp_mask);
+		if (!n)
+			return NULL;
+		n->fclone = SKB_FCLONE_UNAVAILABLE;
+	}
+
+	return __skb_clone(n, skb);
 }
 
 static void copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
