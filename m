From: sunil.kovvuri@gmail.com
Subject: [PATCH 9/9] net: thunderx: Optimize page recycling for XDP
Date: Tue,  2 May 2017 18:36:58 +0530
Message-ID: <1493730418-24606-10-git-send-email-sunil.kovvuri@gmail.com>
References: <1493730418-24606-1-git-send-email-sunil.kovvuri@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        Sunil Goutham <sgoutham@cavium.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1493730418-24606-1-git-send-email-sunil.kovvuri@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

Driver follows a method of taking one extra reference on the
page for recycling which is fine in usual packet path where
each 64KB page is segmented into multiple receive buffers.

But in XDP mode since there is just one receive buffer per
page taking extra page reference itself becomes big bottleneck
consuming ~50% of CPU cycles due to atomic operations.

This patch adds a internal ref count in pgcache for each
page and additional page references are taken in a batch
instead of just one at a time. Internal i.e 'pgcache->ref_count'
and page's i.e 'page->_refcount' counters are compared to check
page's recyclability.

Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c | 57 +++++++++++++++++++---
 drivers/net/ethernet/cavium/thunder/nicvf_queues.h |  1 +
 2 files changed, 51 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
index 43428ce..2b18176 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
@@ -82,6 +82,8 @@ static void nicvf_free_q_desc_mem(struct nicvf *nic, struct q_desc_mem *dmem)
 	dmem->base = NULL;
 }
 
+#define XDP_PAGE_REFCNT_REFILL 256
+
 /* Allocate a new page or recycle one if possible
  *
  * We cannot optimize dma mapping here, since
@@ -90,9 +92,10 @@ static void nicvf_free_q_desc_mem(struct nicvf *nic, struct q_desc_mem *dmem)
  *    and not idx into RBDR ring, so can't refer to saved info.
  * 3. There are multiple receive buffers per page
  */
-static struct pgcache *nicvf_alloc_page(struct nicvf *nic,
-					struct rbdr *rbdr, gfp_t gfp)
+static inline struct pgcache *nicvf_alloc_page(struct nicvf *nic,
+					       struct rbdr *rbdr, gfp_t gfp)
 {
+	int ref_count;
 	struct page *page = NULL;
 	struct pgcache *pgcache, *next;
 
@@ -100,8 +103,23 @@ static struct pgcache *nicvf_alloc_page(struct nicvf *nic,
 	pgcache = &rbdr->pgcache[rbdr->pgidx];
 	page = pgcache->page;
 	/* Check if page can be recycled */
-	if (page && (page_ref_count(page) != 1))
-		page = NULL;
+	if (page) {
+		ref_count = page_ref_count(page);
+		/* Check if this page has been used once i.e 'put_page'
+		 * called after packet transmission i.e internal ref_count
+		 * and page's ref_count are equal i.e page can be recycled.
+		 */
+		if (rbdr->is_xdp && (ref_count == pgcache->ref_count))
+			pgcache->ref_count--;
+		else
+			page = NULL;
+
+		/* In non-XDP mode, page's ref_count needs to be '1' for it
+		 * to be recycled.
+		 */
+		if (!rbdr->is_xdp && (ref_count != 1))
+			page = NULL;
+	}
 
 	if (!page) {
 		page = alloc_pages(gfp | __GFP_COMP | __GFP_NOWARN, 0);
@@ -120,11 +138,30 @@ static struct pgcache *nicvf_alloc_page(struct nicvf *nic,
 		/* Save the page in page cache */
 		pgcache->page = page;
 		pgcache->dma_addr = 0;
+		pgcache->ref_count = 0;
 		rbdr->pgalloc++;
 	}
 
-	/* Take extra page reference for recycling */
-	page_ref_add(page, 1);
+	/* Take additional page references for recycling */
+	if (rbdr->is_xdp) {
+		/* Since there is single RBDR (i.e single core doing
+		 * page recycling) per 8 Rx queues, in XDP mode adjusting
+		 * page references atomically is the biggest bottleneck, so
+		 * take bunch of references at a time.
+		 *
+		 * So here, below reference counts defer by '1'.
+		 */
+		if (!pgcache->ref_count) {
+			pgcache->ref_count = XDP_PAGE_REFCNT_REFILL;
+			page_ref_add(page, XDP_PAGE_REFCNT_REFILL);
+		}
+	} else {
+		/* In non-XDP case, single 64K page is divided across multiple
+		 * receive buffers, so cost of recycling is less anyway.
+		 * So we can do with just one extra reference.
+		 */
+		page_ref_add(page, 1);
+	}
 
 	rbdr->pgidx++;
 	rbdr->pgidx &= (rbdr->pgcnt - 1);
@@ -327,8 +364,14 @@ static void nicvf_free_rbdr(struct nicvf *nic, struct rbdr *rbdr)
 	head = 0;
 	while (head < rbdr->pgcnt) {
 		pgcache = &rbdr->pgcache[head];
-		if (pgcache->page && page_ref_count(pgcache->page) != 0)
+		if (pgcache->page && page_ref_count(pgcache->page) != 0) {
+			if (!rbdr->is_xdp) {
+				put_page(pgcache->page);
+				continue;
+			}
+			page_ref_sub(pgcache->page, pgcache->ref_count - 1);
 			put_page(pgcache->page);
+		}
 		head++;
 	}
 
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.h b/drivers/net/ethernet/cavium/thunder/nicvf_queues.h
index a07d5b4..5785852 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_queues.h
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.h
@@ -216,6 +216,7 @@ struct q_desc_mem {
 
 struct pgcache {
 	struct page	*page;
+	int		ref_count;
 	u64		dma_addr;
 };
 
-- 
2.7.4
