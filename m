From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 03/30] mm: tag reseve pages
Date: Thu, 24 Jul 2008 16:00:45 +0200
Message-ID: <20080724141529.482207892@chello.nl>
References: <20080724140042.408642539@chello.nl>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fy
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:54691 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756410AbYGXOmk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 10:42:40 -0400
Content-Disposition: inline; filename=page_alloc-reserve.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tag pages allocated from the reserves with a non-zero page->reserve.
This allows us to distinguish and account reserve pages.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/mm_types.h |    1 +
 mm/page_alloc.c          |    4 +++-
 2 files changed, 4 insertions(+), 1 deletion(-)

Index: linux-2.6/include/linux/mm_types.h
===================================================================
--- linux-2.6.orig/include/linux/mm_types.h
+++ linux-2.6/include/linux/mm_types.h
@@ -70,6 +70,7 @@ struct page {
 	union {
 		pgoff_t index;		/* Our offset within mapping. */
 		void *freelist;		/* SLUB: freelist req. slab lock */
+		int reserve;		/* page_alloc: page is a reserve page */
 	};
 	struct list_head lru;		/* Pageout list, eg. active_list
 					 * protected by zone->lru_lock !
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c
+++ linux-2.6/mm/page_alloc.c
@@ -1433,8 +1433,10 @@ zonelist_scan:
 		}
 
 		page = buffered_rmqueue(preferred_zone, zone, order, gfp_mask);
-		if (page)
+		if (page) {
+			page->reserve = !!(alloc_flags & ALLOC_NO_WATERMARKS);
 			break;
+		}
 this_zone_full:
 		if (NUMA_BUILD)
 			zlc_mark_zone_full(zonelist, z);

-- 

