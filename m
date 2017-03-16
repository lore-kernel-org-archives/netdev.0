From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 05/17] net: convert sk_buff_fclones.fclone_ref from atomic_t to refcount_t
Date: Thu, 16 Mar 2017 17:28:55 +0200
Message-ID: <1489678147-21404-6-git-send-email-elena.reshetova@intel.com>
References: <1489678147-21404-1-git-send-email-elena.reshetova@intel.com>
Cc: bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net,
        stephen@networkplumber.org, peterz@infradead.org,
        keescook@chromium.org, Elena Reshetova <elena.reshetova@intel.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        David Windsor <dwindsor@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489678147-21404-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

refcount_t type and corresponding API should be
used instead of atomic_t when the variable is used as
a reference counter. This allows to avoid accidental
refcounter overflows that might lead to use-after-free
situations.

Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
Signed-off-by: David Windsor <dwindsor@gmail.com>
---
 include/linux/skbuff.h |  4 ++--
 net/core/skbuff.c      | 10 +++++-----
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 0bcaec4..63ce21f 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -945,7 +945,7 @@ struct sk_buff_fclones {
 
 	struct sk_buff	skb2;
 
-	atomic_t	fclone_ref;
+	refcount_t	fclone_ref;
 };
 
 /**
@@ -965,7 +965,7 @@ static inline bool skb_fclone_busy(const struct sock *sk,
 	fclones = container_of(skb, struct sk_buff_fclones, skb1);
 
 	return skb->fclone == SKB_FCLONE_ORIG &&
-	       atomic_read(&fclones->fclone_ref) > 1 &&
+	       refcount_read(&fclones->fclone_ref) > 1 &&
 	       fclones->skb2.sk == sk;
 }
 
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 94e961f..6911269 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -268,7 +268,7 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 
 		kmemcheck_annotate_bitfield(&fclones->skb2, flags1);
 		skb->fclone = SKB_FCLONE_ORIG;
-		atomic_set(&fclones->fclone_ref, 1);
+		refcount_set(&fclones->fclone_ref, 1);
 
 		fclones->skb2.fclone = SKB_FCLONE_CLONE;
 	}
@@ -629,7 +629,7 @@ static void kfree_skbmem(struct sk_buff *skb)
 		 * This test would have no chance to be true for the clone,
 		 * while here, branch prediction will be good.
 		 */
-		if (atomic_read(&fclones->fclone_ref) == 1)
+		if (refcount_read(&fclones->fclone_ref) == 1)
 			goto fastpath;
 		break;
 
@@ -637,7 +637,7 @@ static void kfree_skbmem(struct sk_buff *skb)
 		fclones = container_of(skb, struct sk_buff_fclones, skb2);
 		break;
 	}
-	if (!atomic_dec_and_test(&fclones->fclone_ref))
+	if (!refcount_dec_and_test(&fclones->fclone_ref))
 		return;
 fastpath:
 	kmem_cache_free(skbuff_fclone_cache, fclones);
@@ -1018,9 +1018,9 @@ struct sk_buff *skb_clone(struct sk_buff *skb, gfp_t gfp_mask)
 		return NULL;
 
 	if (skb->fclone == SKB_FCLONE_ORIG &&
-	    atomic_read(&fclones->fclone_ref) == 1) {
+	    refcount_read(&fclones->fclone_ref) == 1) {
 		n = &fclones->skb2;
-		atomic_set(&fclones->fclone_ref, 2);
+		refcount_set(&fclones->fclone_ref, 2);
 	} else {
 		if (skb_pfmemalloc(skb))
 			gfp_mask |= __GFP_MEMALLOC;
-- 
2.7.4
