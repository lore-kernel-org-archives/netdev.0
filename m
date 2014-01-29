From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH regression] dma-debug: fix overlap detection
Date: Tue, 28 Jan 2014 19:00:54 -0800
Message-ID: <20140129025817.10334.73833.stgit@viggo.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Sander Eikelenboom <linux@eikelenboom.it>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>
To: akpm@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 0abdd7a81b7e "dma-debug: introduce debug_dma_assert_idle()" was
reworked to expand the overlap counter to the full range expressable by
3 tag bits, but it has a thinko in treating the overlap counter as a
pure reference count for the entry.

Instead of deleting when the reference-count drops to zero, we need to
delete when the overlap-count drops below zero.  Also, when detecting
overflow we can just test the overlap-count > MAX rather than applying
special meaning to 0.

Cc: Francois Romieu <romieu@fr.zoreil.com>
Reported-by: Sander Eikelenboom <linux@eikelenboom.it>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---

Regression report available here:
http://marc.info/?l=linux-netdev&m=139073373932386&w=2

This patch, now tested on the original net_dma case, sees the expected
handful of reports before the eventual data corruption occurs.

 lib/dma-debug.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/lib/dma-debug.c b/lib/dma-debug.c
index c38083871f11..2defd1308b04 100644
--- a/lib/dma-debug.c
+++ b/lib/dma-debug.c
@@ -463,7 +463,7 @@ static int active_pfn_set_overlap(unsigned long pfn, int overlap)
 	int i;
 
 	if (overlap > ACTIVE_PFN_MAX_OVERLAP || overlap < 0)
-		return 0;
+		return overlap;
 
 	for (i = RADIX_TREE_MAX_TAGS - 1; i >= 0; i--)
 		if (overlap & 1 << i)
@@ -486,7 +486,7 @@ static void active_pfn_inc_overlap(unsigned long pfn)
 	 * debug_dma_assert_idle() as the pfn may be marked idle
 	 * prematurely.
 	 */
-	WARN_ONCE(overlap == 0,
+	WARN_ONCE(overlap > ACTIVE_PFN_MAX_OVERLAP,
 		  "DMA-API: exceeded %d overlapping mappings of pfn %lx\n",
 		  ACTIVE_PFN_MAX_OVERLAP, pfn);
 }
@@ -517,7 +517,11 @@ static void active_pfn_remove(struct dma_debug_entry *entry)
 	unsigned long flags;
 
 	spin_lock_irqsave(&radix_lock, flags);
-	if (active_pfn_dec_overlap(entry->pfn) == 0)
+	/* since we are counting overlaps the final put of the
+	 * entry->pfn will occur when the overlap count is 0.
+	 * active_pfn_dec_overlap() returns -1 in that case
+	 */
+	if (active_pfn_dec_overlap(entry->pfn) < 0)
 		radix_tree_delete(&dma_active_pfn, entry->pfn);
 	spin_unlock_irqrestore(&radix_lock, flags);
 }
