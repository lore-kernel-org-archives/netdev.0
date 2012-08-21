From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: regression with poll(2)
Date: Tue, 21 Aug 2012 08:58:05 -0700
Message-ID: <20120821085805.41a102f1.akpm@linux-foundation.org>
References: <alpine.DEB.2.00.1208151226250.15721@cobra.newdream.net>
	<alpine.DEB.2.00.1208191051150.15570@cobra.newdream.net>
	<20120820090443.GA3275@suse.de>
	<CA+55aFw6S85jR+5zP9W6YykdsTMSVw9T5ibW93Gtx2rjw-b2EA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mel Gorman <mgorman@suse.de>, Sage Weil <sage@inktank.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ceph-devel@vger.kernel.org,
	Neil Brown <neilb@suse.de>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>, michaelc@cs.wisc.edu,
	emunson@mgebm.net, Eric Dumazet <eric.dumazet@gmail.com>,
	Christoph Lameter <cl@linux.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFw6S85jR+5zP9W6YykdsTMSVw9T5ibW93Gtx2rjw-b2EA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 20 Aug 2012 10:02:05 -0700 Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Mon, Aug 20, 2012 at 2:04 AM, Mel Gorman <mgorman@suse.de> wrote:
> >
> > Can the following patch be tested please? It is reported to fix an fio
> > regression that may be similar to what you are experiencing but has not
> > been picked up yet.
> 
> Andrew, is this in your queue, or should I take this directly, or
> what? It seems to fix the problem for Eric and Sage, at least.

Yes, I have a copy queued:


From: Alex Shi <alex.shi@intel.com>
Subject: mm: correct page->pfmemalloc to fix deactivate_slab regression

cfd19c5a9ec ("mm: only set page->pfmemalloc when ALLOC_NO_WATERMARKS was
used") tried to narrow down page->pfmemalloc setting, but it missed some
places the pfmemalloc should be set.

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

That causes our fio sync write performance to have a 40% regression.

Move the checking in get_page_from_freelist() which resolves this issue.

Signed-off-by: Alex Shi <alex.shi@intel.com>
Acked-by: Mel Gorman <mgorman@suse.de>
Cc: David Miller <davem@davemloft.net
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Tested-by: Eric Dumazet <eric.dumazet@gmail.com>
Tested-by: Sage Weil <sage@inktank.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/page_alloc.c |   21 +++++++++++----------
 1 file changed, 11 insertions(+), 10 deletions(-)

diff -puN mm/page_alloc.c~mm-correct-page-pfmemalloc-to-fix-deactivate_slab-regression mm/page_alloc.c
--- a/mm/page_alloc.c~mm-correct-page-pfmemalloc-to-fix-deactivate_slab-regression
+++ a/mm/page_alloc.c
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
 
_
