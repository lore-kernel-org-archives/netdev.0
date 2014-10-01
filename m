From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: avoid one atomic operation in skb_clone()
Date: Wed, 01 Oct 2014 15:27:15 -0700
Message-ID: <1412202435.16704.68.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:44499 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751914AbaJAW1C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 18:27:02 -0400
Received: by mail-pa0-f46.google.com with SMTP id fa1so1036245pad.5
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2014 15:27:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Fast clone cloning can actually avoid an atomic_inc(), if we
guarantee prior clone_ref value is 1.

This requires a change kfree_skbmem(), to perform the 
atomic_dec_and_test() on clone_ref before setting fclone to
SKB_FCLONE_UNAVAILABLE.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/skbuff.c |   23 +++++++++++++++++------
 1 file changed, 17 insertions(+), 6 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index a8cebb40699c..f77e64873caf 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -541,13 +541,20 @@ static void kfree_skbmem(struct sk_buff *skb)
 	case SKB_FCLONE_CLONE:
 		fclones = container_of(skb, struct sk_buff_fclones, skb2);
 
-		/* The clone portion is available for
-		 * fast-cloning again.
+		/* Warning : We must perform the atomic_dec_and_test() before
+		 * setting skb->fclone back to SKB_FCLONE_UNAVAILABLE, otherwise
+		 * skb_clone() could set clone_ref to 2 before our decrement.
+		 * Anyway, if we are going to free the structure, no need to
+		 * rewrite skb->fclone.
 		 */
-		skb->fclone = SKB_FCLONE_UNAVAILABLE;
-
-		if (atomic_dec_and_test(&fclones->fclone_ref))
+		if (atomic_dec_and_test(&fclones->fclone_ref)) {
 			kmem_cache_free(skbuff_fclone_cache, fclones);
+		} else {
+			/* The clone portion is available for
+			 * fast-cloning again.
+			 */
+			skb->fclone = SKB_FCLONE_UNAVAILABLE;
+		}
 		break;
 	}
 }
@@ -869,7 +876,11 @@ struct sk_buff *skb_clone(struct sk_buff *skb, gfp_t gfp_mask)
 	if (skb->fclone == SKB_FCLONE_ORIG &&
 	    n->fclone == SKB_FCLONE_UNAVAILABLE) {
 		n->fclone = SKB_FCLONE_CLONE;
-		atomic_inc(&fclones->fclone_ref);
+		/* As our fastclone was free, clone_ref must be 1 at this point.
+		 * We could use atomic_inc() here, but it is faster
+		 * to set the final value.
+		 */
+		atomic_set(&fclones->fclone_ref, 2);
 	} else {
 		if (skb_pfmemalloc(skb))
 			gfp_mask |= __GFP_MEMALLOC;
