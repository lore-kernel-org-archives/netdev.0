From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 07/17] mm: Ignore mempolicies when using ALLOC_NO_WATERMARK
Date: Thu, 10 May 2012 14:45:00 +0100
Message-ID: <1336657510-24378-8-git-send-email-mgorman@suse.de>
References: <1336657510-24378-1-git-send-email-mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>,
	Linux-Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Mike Christie <michaelc@cs.wisc.edu>,
	Eric B Munson <emunson@mgebm.net>,
	Mel Gorman <mgorman@suse.de>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:37226 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753414Ab2EJNpW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2012 09:45:22 -0400
In-Reply-To: <1336657510-24378-1-git-send-email-mgorman@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The reserve is proportionally distributed over all !highmem zones
in the system. So we need to allow an emergency allocation access to
all zones.  In order to do that we need to break out of any mempolicy
boundaries we might have.

In my opinion that does not break mempolicies as those are user
oriented and not system oriented. That is, system allocations are
not guaranteed to be within mempolicy boundaries. For instance IRQs
do not even have a mempolicy.

So breaking out of mempolicy boundaries for 'rare' emergency
allocations, which are always system allocations (as opposed to user)
is ok.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 363ca90..e225a7c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2293,6 +2293,13 @@ rebalance:
 
 	/* Allocate without watermarks if the context allows */
 	if (alloc_flags & ALLOC_NO_WATERMARKS) {
+		/*
+		 * Ignore mempolicies if ALLOC_NO_WATERMARKS on the grounds
+		 * the allocation is high priority and these type of
+		 * allocations are system rather than user orientated
+		 */
+		zonelist = node_zonelist(numa_node_id(), gfp_mask);
+
 		page = __alloc_pages_high_priority(gfp_mask, order,
 				zonelist, high_zoneidx, nodemask,
 				preferred_zone, migratetype);
-- 
1.7.9.2
