From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: [PATCH V2 net-next] net: Cleanup skb cloning  by adding SKB_FCLONE_FREE
Date: Thu,  2 Oct 2014 10:00:43 -0700
Message-ID: <1412269243-5583-1-git-send-email-subramanian.vijay@gmail.com>
Cc: davem@davemloft.net, edumazet@google.com,
	Vijay Subramanian <subramanian.vijay@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:54364 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751834AbaJBRA5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 13:00:57 -0400
Received: by mail-pa0-f53.google.com with SMTP id kq14so2895223pab.40
        for <netdev@vger.kernel.org>; Thu, 02 Oct 2014 10:00:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SKB_FCLONE_UNAVAILABLE has overloaded meaning depending on type of skb.
1: If skb is allocated from head_cache, it indicates fclone is not available.
2: If skb is a companion fclone skb (allocated from fclone_cache), it indicates
it is available to be used.

To avoid confusion for case 2 above, this patch  replaces
SKB_FCLONE_UNAVAILABLE with SKB_FCLONE_FREE where appropriate. For fclone
companion skbs, this indicates it is free for use.

SKB_FCLONE_UNAVAILABLE will now simply indicate skb is from head_cache and
cannot / will not have a companion fclone.

Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
---
V1-->V2: Comment all states

 include/linux/skbuff.h | 7 ++++---
 net/core/skbuff.c      | 8 ++++----
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 7c5036d..3a5ec76 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -339,9 +339,10 @@ struct skb_shared_info {
 
 
 enum {
-	SKB_FCLONE_UNAVAILABLE,
-	SKB_FCLONE_ORIG,
-	SKB_FCLONE_CLONE,
+	SKB_FCLONE_UNAVAILABLE,	/* skb has no fclone (from head_cache) */
+	SKB_FCLONE_ORIG,	/* orig skb (from fclone_cache) */
+	SKB_FCLONE_CLONE,	/* companion fclone skb (from fclone_cache) */
+	SKB_FCLONE_FREE,	/* this companion fclone skb is available */
 };
 
 enum {
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index f77e648..6f4e359 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -265,7 +265,7 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 		skb->fclone = SKB_FCLONE_ORIG;
 		atomic_set(&fclones->fclone_ref, 1);
 
-		fclones->skb2.fclone = SKB_FCLONE_UNAVAILABLE;
+		fclones->skb2.fclone = SKB_FCLONE_FREE;
 		fclones->skb2.pfmemalloc = pfmemalloc;
 	}
 out:
@@ -542,7 +542,7 @@ static void kfree_skbmem(struct sk_buff *skb)
 		fclones = container_of(skb, struct sk_buff_fclones, skb2);
 
 		/* Warning : We must perform the atomic_dec_and_test() before
-		 * setting skb->fclone back to SKB_FCLONE_UNAVAILABLE, otherwise
+		 * setting skb->fclone back to SKB_FCLONE_FREE, otherwise
 		 * skb_clone() could set clone_ref to 2 before our decrement.
 		 * Anyway, if we are going to free the structure, no need to
 		 * rewrite skb->fclone.
@@ -553,7 +553,7 @@ static void kfree_skbmem(struct sk_buff *skb)
 			/* The clone portion is available for
 			 * fast-cloning again.
 			 */
-			skb->fclone = SKB_FCLONE_UNAVAILABLE;
+			skb->fclone = SKB_FCLONE_FREE;
 		}
 		break;
 	}
@@ -874,7 +874,7 @@ struct sk_buff *skb_clone(struct sk_buff *skb, gfp_t gfp_mask)
 		return NULL;
 
 	if (skb->fclone == SKB_FCLONE_ORIG &&
-	    n->fclone == SKB_FCLONE_UNAVAILABLE) {
+	    n->fclone == SKB_FCLONE_FREE) {
 		n->fclone = SKB_FCLONE_CLONE;
 		/* As our fastclone was free, clone_ref must be 1 at this point.
 		 * We could use atomic_inc() here, but it is faster
-- 
1.9.1
