From: Mel Gorman <mgorman@suse.de>
Subject: Re: regression with poll(2)
Date: Mon, 20 Aug 2012 10:04:44 +0100
Message-ID: <20120820090443.GA3275@suse.de>
References: <alpine.DEB.2.00.1208151226250.15721@cobra.newdream.net>
 <alpine.DEB.2.00.1208191051150.15570@cobra.newdream.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ceph-devel@vger.kernel.org,
	neilb@suse.de, a.p.zijlstra@chello.nl, michaelc@cs.wisc.edu,
	emunson@mgebm.net, eric.dumazet@gmail.com, sebastian@breakpoint.cc,
	cl@linux.com, akpm@linux-foundation.org,
	torvalds@linux-foundation.org
To: Sage Weil <sage@inktank.com>
Return-path: <ceph-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1208191051150.15570@cobra.newdream.net>
Sender: ceph-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 19, 2012 at 11:49:31AM -0700, Sage Weil wrote:
> I've bisected and identified this commit:
> 
>     netvm: propagate page->pfmemalloc to skb
>     
>     The skb->pfmemalloc flag gets set to true iff during the slab allocation
>     of data in __alloc_skb that the the PFMEMALLOC reserves were used.  If the
>     packet is fragmented, it is possible that pages will be allocated from the
>     PFMEMALLOC reserve without propagating this information to the skb.  This
>     patch propagates page->pfmemalloc from pages allocated for fragments to
>     the skb.
>     
>     Signed-off-by: Mel Gorman <mgorman@suse.de>
>     Acked-by: David S. Miller <davem@davemloft.net>
>     Cc: Neil Brown <neilb@suse.de>
>     Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
>     Cc: Mike Christie <michaelc@cs.wisc.edu>
>     Cc: Eric B Munson <emunson@mgebm.net>
>     Cc: Eric Dumazet <eric.dumazet@gmail.com>
>     Cc: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
>     Cc: Mel Gorman <mgorman@suse.de>
>     Cc: Christoph Lameter <cl@linux.com>
>     Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>     Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> 

Ok, thanks.

> I've retested several times and confirmed that this change leads to the 
> breakage, and also confirmed that reverting it on top of -rc1 also fixes 
> the problem.
> 
> I've also added some additional instrumentation to my code and confirmed 
> that the process is blocking on poll(2) while netstat is reporting 
> data available on the socket.
> 
> What can I do to help track this down?
> 

Can the following patch be tested please? It is reported to fix an fio
regression that may be similar to what you are experiencing but has not
been picked up yet.

---8<---
From: Alex Shi <alex.shi@intel.com>
Subject: [PATCH] mm: correct page->pfmemalloc to fix deactivate_slab regression

commit cfd19c5a9ec (mm: only set page->pfmemalloc when
ALLOC_NO_WATERMARKS was used) try to narrow down page->pfmemalloc
setting, but it missed some places the pfmemalloc should be set.

So, in __slab_alloc, the unalignment pfmemalloc and ALLOC_NO_WATERMARKS
cause incorrect deactivate_slab() on our core2 server:

    64.73%           fio  [kernel.kallsyms]     [k] _raw_spin_lock
                     |
                     --- _raw_spin_lock
                        |
                        |---0.34%-- deactivate_slab
                        |          __slab_alloc
                        |          kmem_cache_alloc
                        |          |

That causes our fio sync write performance has 40% regression.

This patch move the checking in get_page_from_freelist, that resolved
this issue.

Signed-off-by: Alex Shi <alex.shi@intel.com>
---
 mm/page_alloc.c |   21 +++++++++++----------
 1 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 009ac28..07f1924 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1928,6 +1928,17 @@ this_zone_full:
 		zlc_active = 0;
 		goto zonelist_scan;
 	}
+
+	if (page)
+		/*
+		 * page->pfmemalloc is set when ALLOC_NO_WATERMARKS was
+		 * necessary to allocate the page. The expectation is
+		 * that the caller is taking steps that will free more
+		 * memory. The caller should avoid the page being used
+		 * for !PFMEMALLOC purposes.
+		 */
+		page->pfmemalloc = !!(alloc_flags & ALLOC_NO_WATERMARKS);
+
 	return page;
 }
 
@@ -2389,14 +2400,6 @@ rebalance:
 				zonelist, high_zoneidx, nodemask,
 				preferred_zone, migratetype);
 		if (page) {
-			/*
-			 * page->pfmemalloc is set when ALLOC_NO_WATERMARKS was
-			 * necessary to allocate the page. The expectation is
-			 * that the caller is taking steps that will free more
-			 * memory. The caller should avoid the page being used
-			 * for !PFMEMALLOC purposes.
-			 */
-			page->pfmemalloc = true;
 			goto got_pg;
 		}
 	}
@@ -2569,8 +2572,6 @@ retry_cpuset:
 		page = __alloc_pages_slowpath(gfp_mask, order,
 				zonelist, high_zoneidx, nodemask,
 				preferred_zone, migratetype);
-	else
-		page->pfmemalloc = false;
 
 	trace_mm_page_alloc(page, order, gfp_mask, migratetype);
 
-- 
1.7.5.4

