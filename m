From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH 7/7] slub: do prefetching in kmem_cache_alloc_bulk()
Date: Mon, 28 Sep 2015 14:26:39 +0200
Message-ID: <20150928122639.15409.21583.stgit@canyon>
References: <20150928122444.15409.10498.stgit@canyon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Christoph Lameter <cl@linux.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37653 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757134AbbI1M0l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Sep 2015 08:26:41 -0400
In-Reply-To: <20150928122444.15409.10498.stgit@canyon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For practical use-cases it is beneficial to prefetch the next freelist
object in bulk allocation loop.

Micro benchmarking show approx 1 cycle change:

bulk -  prev-patch     -  this patch
   1 -  49 cycles(tsc) - 49 cycles(tsc) - increase in cycles:0
   2 -  30 cycles(tsc) - 31 cycles(tsc) - increase in cycles:1
   3 -  23 cycles(tsc) - 25 cycles(tsc) - increase in cycles:2
   4 -  20 cycles(tsc) - 22 cycles(tsc) - increase in cycles:2
   8 -  18 cycles(tsc) - 19 cycles(tsc) - increase in cycles:1
  16 -  17 cycles(tsc) - 18 cycles(tsc) - increase in cycles:1
  30 -  18 cycles(tsc) - 17 cycles(tsc) - increase in cycles:-1
  32 -  18 cycles(tsc) - 19 cycles(tsc) - increase in cycles:1
  34 -  23 cycles(tsc) - 24 cycles(tsc) - increase in cycles:1
  48 -  21 cycles(tsc) - 22 cycles(tsc) - increase in cycles:1
  64 -  20 cycles(tsc) - 21 cycles(tsc) - increase in cycles:1
 128 -  27 cycles(tsc) - 27 cycles(tsc) - increase in cycles:0
 158 -  30 cycles(tsc) - 30 cycles(tsc) - increase in cycles:0
 250 -  37 cycles(tsc) - 37 cycles(tsc) - increase in cycles:0

Note, benchmark done with slab_nomerge to keep it stable enough
for accurate comparison.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 mm/slub.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/slub.c b/mm/slub.c
index c25717ab3b5a..5af75a618b91 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2951,6 +2951,7 @@ bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
 				goto error;
 
 			c = this_cpu_ptr(s->cpu_slab);
+			prefetch_freepointer(s, c->freelist);
 			continue; /* goto for-loop */
 		}
 
@@ -2960,6 +2961,7 @@ bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
 			goto error;
 
 		c->freelist = get_freepointer(s, object);
+		prefetch_freepointer(s, c->freelist);
 		p[i] = object;
 
 		/* kmem_cache debug support */
