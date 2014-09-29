From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net-next] net: cleanup and document skb fclone layout
Date: Mon, 29 Sep 2014 13:29:15 -0700
Message-ID: <1412022555.30721.40.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1411860341.15768.55.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:53748 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753815AbaI2U3R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 16:29:17 -0400
Received: by mail-pd0-f176.google.com with SMTP id fp1so4872751pdb.7
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 13:29:16 -0700 (PDT)
In-Reply-To: <1411860341.15768.55.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Lets use a proper structure to clearly document and implement
skb fast clones.

Then, we might experiment more easily alternative layouts.

This patch adds a new skb_fclone_busy() helper, used by tcp and xfrm,
to stop leaking of implementation details.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
v2: rebased on latest net-next

 include/linux/skbuff.h |   25 +++++++++++++++++++++++
 net/core/skbuff.c      |   41 +++++++++++++++++++--------------------
 net/ipv4/tcp_output.c  |    5 ----
 net/xfrm/xfrm_policy.c |    4 ---
 4 files changed, 47 insertions(+), 28 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 262efdbc346b..d8f7d74d5a4d 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -781,6 +781,31 @@ struct sk_buff *alloc_skb_with_frags(unsigned long header_len,
 				     int *errcode,
 				     gfp_t gfp_mask);
 
+/* Layout of fast clones : [skb1][skb2][fclone_ref] */
+struct sk_buff_fclones {
+	struct sk_buff	skb1;
+
+	struct sk_buff	skb2;
+
+	atomic_t	fclone_ref;
+};
+
+/**
+ *	skb_fclone_busy - check if fclone is busy
+ *	@skb: buffer
+ *
+ * Returns true is skb is a fast clone, and its clone is not freed.
+ */
+static inline bool skb_fclone_busy(const struct sk_buff *skb)
+{
+	const struct sk_buff_fclones *fclones;
+
+	fclones = container_of(skb, struct sk_buff_fclones, skb1);
+
+	return skb->fclone == SKB_FCLONE_ORIG &&
+	       fclones->skb2.fclone == SKB_FCLONE_CLONE;
+}
+
 static inline struct sk_buff *alloc_skb_fclone(unsigned int size,
 					       gfp_t priority)
 {
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 4be570a4ab21..a8cebb40699c 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -257,15 +257,16 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 	kmemcheck_annotate_variable(shinfo->destructor_arg);
 
 	if (flags & SKB_ALLOC_FCLONE) {
-		struct sk_buff *child = skb + 1;
-		atomic_t *fclone_ref = (atomic_t *) (child + 1);
+		struct sk_buff_fclones *fclones;
 
-		kmemcheck_annotate_bitfield(child, flags1);
+		fclones = container_of(skb, struct sk_buff_fclones, skb1);
+
+		kmemcheck_annotate_bitfield(&fclones->skb2, flags1);
 		skb->fclone = SKB_FCLONE_ORIG;
-		atomic_set(fclone_ref, 1);
+		atomic_set(&fclones->fclone_ref, 1);
 
-		child->fclone = SKB_FCLONE_UNAVAILABLE;
-		child->pfmemalloc = pfmemalloc;
+		fclones->skb2.fclone = SKB_FCLONE_UNAVAILABLE;
+		fclones->skb2.pfmemalloc = pfmemalloc;
 	}
 out:
 	return skb;
@@ -524,8 +525,7 @@ static void skb_release_data(struct sk_buff *skb)
  */
 static void kfree_skbmem(struct sk_buff *skb)
 {
-	struct sk_buff *other;
-	atomic_t *fclone_ref;
+	struct sk_buff_fclones *fclones;
 
 	switch (skb->fclone) {
 	case SKB_FCLONE_UNAVAILABLE:
@@ -533,22 +533,21 @@ static void kfree_skbmem(struct sk_buff *skb)
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
@@ -859,17 +858,18 @@ EXPORT_SYMBOL_GPL(skb_copy_ubufs);
 
 struct sk_buff *skb_clone(struct sk_buff *skb, gfp_t gfp_mask)
 {
-	struct sk_buff *n;
+	struct sk_buff_fclones *fclones = container_of(skb,
+						       struct sk_buff_fclones,
+						       skb1);
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
@@ -3240,8 +3240,7 @@ void __init skb_init(void)
 					      SLAB_HWCACHE_ALIGN|SLAB_PANIC,
 					      NULL);
 	skbuff_fclone_cache = kmem_cache_create("skbuff_fclone_cache",
-						(2*sizeof(struct sk_buff)) +
-						sizeof(atomic_t),
+						sizeof(struct sk_buff_fclones),
 						0,
 						SLAB_HWCACHE_ALIGN|SLAB_PANIC,
 						NULL);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index ee567e9e98c3..8d4eac793700 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2110,10 +2110,7 @@ bool tcp_schedule_loss_probe(struct sock *sk)
 static bool skb_still_in_host_queue(const struct sock *sk,
 				    const struct sk_buff *skb)
 {
-	const struct sk_buff *fclone = skb + 1;
-
-	if (unlikely(skb->fclone == SKB_FCLONE_ORIG &&
-		     fclone->fclone == SKB_FCLONE_CLONE)) {
+	if (unlikely(skb_fclone_busy(skb))) {
 		NET_INC_STATS_BH(sock_net(sk),
 				 LINUX_MIB_TCPSPURIOUS_RTX_HOSTQUEUES);
 		return true;
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index f623dca6ce30..4c4e457e7888 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1961,10 +1961,8 @@ static int xdst_queue_output(struct sock *sk, struct sk_buff *skb)
 	struct xfrm_dst *xdst = (struct xfrm_dst *) dst;
 	struct xfrm_policy *pol = xdst->pols[0];
 	struct xfrm_policy_queue *pq = &pol->polq;
-	const struct sk_buff *fclone = skb + 1;
 
-	if (unlikely(skb->fclone == SKB_FCLONE_ORIG &&
-		     fclone->fclone == SKB_FCLONE_CLONE)) {
+	if (unlikely(skb_fclone_busy(skb))) {
 		kfree_skb(skb);
 		return 0;
 	}
