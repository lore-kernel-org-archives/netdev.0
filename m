From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 7/9] mm: allow mempool to fall back to memalloc reserves
Date: Tue, 16 Jan 2007 10:46:04 +0100
Message-ID: <20070116101815.843531000@taijtu.programming.kicks-ass.net>
References: <20070116094557.494892000@taijtu.programming.kicks-ass.net>
Cc: David Miller <davem@davemloft.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:43220 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750855AbXAPK2X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jan 2007 05:28:23 -0500
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-mm@kvack.org
Content-Disposition: inline; filename=mempool_fixup.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow the mempool to use the memalloc reserves when all else fails and
the allocation context would otherwise allow it.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 mm/mempool.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

Index: linux-2.6-git/mm/mempool.c
===================================================================
--- linux-2.6-git.orig/mm/mempool.c	2007-01-12 08:03:44.000000000 +0100
+++ linux-2.6-git/mm/mempool.c	2007-01-12 10:38:57.000000000 +0100
@@ -14,6 +14,7 @@
 #include <linux/mempool.h>
 #include <linux/blkdev.h>
 #include <linux/writeback.h>
+#include "internal.h"
 
 static void add_element(mempool_t *pool, void *element)
 {
@@ -229,6 +230,15 @@ repeat_alloc:
 	}
 	spin_unlock_irqrestore(&pool->lock, flags);
 
+	/* if we really had right to the emergency reserves try those */
+	if (gfp_to_alloc_flags(gfp_mask) & ALLOC_NO_WATERMARKS) {
+		if (gfp_temp & __GFP_NOMEMALLOC) {
+			gfp_temp &= ~(__GFP_NOMEMALLOC|__GFP_NOWARN);
+			goto repeat_alloc;
+		} else
+			gfp_temp |= __GFP_NOMEMALLOC|__GFP_NOWARN;
+	}
+
 	/* We must not sleep in the GFP_ATOMIC case */
 	if (!(gfp_mask & __GFP_WAIT))
 		return NULL;

-- 

