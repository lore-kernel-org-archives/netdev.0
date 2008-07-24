From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 10/30] mm: system wide ALLOC_NO_WATERMARK
Date: Thu, 24 Jul 2008 16:00:52 +0200
Message-ID: <20080724141529.992297913@chello.nl>
References: <20080724140042.408642539@chello.nl>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fy
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:54685 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751223AbYGXOmc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 10:42:32 -0400
Content-Disposition: inline; filename=global-ALLOC_NO_WATERMARKS.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The reserve is proportionally distributed over all (!highmem) zones in the
system. So we need to allow an emergency allocation access to all zones. In
order to do that we need to break out of any mempolicy boundaries we might
have.

In my opinion that does not break mempolicies as those are user oriented
and not system oriented. That is, system allocations are not guaranteed to be
within mempolicy boundaries. For instance IRQs don't even have a mempolicy.

So breaking out of mempolicy boundaries for 'rare' emergency allocations,
which are always system allocations (as opposed to user) is ok.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 mm/page_alloc.c |    5 +++++
 1 file changed, 5 insertions(+)

Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c
+++ linux-2.6/mm/page_alloc.c
@@ -1533,6 +1533,11 @@ restart:
 rebalance:
 	if (alloc_flags & ALLOC_NO_WATERMARKS) {
 nofail_alloc:
+		/*
+		 * break out of mempolicy boundaries
+		 */
+		zonelist = node_zonelist(numa_node_id(), gfp_mask);
+
 		/* go through the zonelist yet again, ignoring mins */
 		page = get_page_from_freelist(gfp_mask, nodemask, order,
 				zonelist, high_zoneidx, ALLOC_NO_WATERMARKS);

-- 

