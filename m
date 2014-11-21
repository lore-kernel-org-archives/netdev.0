From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net] net: Revert "net: avoid one atomic operation in
 skb_clone()"
Date: Fri, 21 Nov 2014 11:47:16 -0800
Message-ID: <1416599236.8629.124.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141121160937.GA32608@ret.masoncoding.com>
	 <1416587469.8629.106.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1416589451.8629.119.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141121180510.GA22112@kria>
	 <1416598161.8629.120.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Chris Mason <clm@fb.com>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:49577 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752441AbaKUTrT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 14:47:19 -0500
Received: by mail-ie0-f182.google.com with SMTP id x19so5636393ier.27
        for <netdev@vger.kernel.org>; Fri, 21 Nov 2014 11:47:18 -0800 (PST)
In-Reply-To: <1416598161.8629.120.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Not sure what I was thinking, but doing anything after
releasing a refcount is suicidal or/and embarrassing.

By the time we set skb->fclone to SKB_FCLONE_FREE, another cpu
could have released last reference and freed whole skb.

We potentially corrupt memory or trap if CONFIG_DEBUG_PAGEALLOC is set.

Reported-by: Chris Mason <clm@fb.com>
Fixes: ce1a4ea3f1258 ("net: avoid one atomic operation in skb_clone()")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Sabrina Dubroca <sd@queasysnail.net>
---
v2: the revert went wrong, as SKB_FCLONE_UNAVAILABLE
    was later replaced by SKB_FCLONE_FREE, spotted by Sabrina Dubroca

 net/core/skbuff.c |   23 ++++++-----------------
 1 file changed, 6 insertions(+), 17 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index c16615bfb61e..be4c7deed971 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -552,20 +552,13 @@ static void kfree_skbmem(struct sk_buff *skb)
 	case SKB_FCLONE_CLONE:
 		fclones = container_of(skb, struct sk_buff_fclones, skb2);
 
-		/* Warning : We must perform the atomic_dec_and_test() before
-		 * setting skb->fclone back to SKB_FCLONE_FREE, otherwise
-		 * skb_clone() could set clone_ref to 2 before our decrement.
-		 * Anyway, if we are going to free the structure, no need to
-		 * rewrite skb->fclone.
+		/* The clone portion is available for
+		 * fast-cloning again.
 		 */
-		if (atomic_dec_and_test(&fclones->fclone_ref)) {
+		skb->fclone = SKB_FCLONE_FREE;
+
+		if (atomic_dec_and_test(&fclones->fclone_ref))
 			kmem_cache_free(skbuff_fclone_cache, fclones);
-		} else {
-			/* The clone portion is available for
-			 * fast-cloning again.
-			 */
-			skb->fclone = SKB_FCLONE_FREE;
-		}
 		break;
 	}
 }
@@ -887,11 +880,7 @@ struct sk_buff *skb_clone(struct sk_buff *skb, gfp_t gfp_mask)
 	if (skb->fclone == SKB_FCLONE_ORIG &&
 	    n->fclone == SKB_FCLONE_FREE) {
 		n->fclone = SKB_FCLONE_CLONE;
-		/* As our fastclone was free, clone_ref must be 1 at this point.
-		 * We could use atomic_inc() here, but it is faster
-		 * to set the final value.
-		 */
-		atomic_set(&fclones->fclone_ref, 2);
+		atomic_inc(&fclones->fclone_ref);
 	} else {
 		if (skb_pfmemalloc(skb))
 			gfp_mask |= __GFP_MEMALLOC;
