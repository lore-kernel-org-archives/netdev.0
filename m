From: Dan Williams <dan.j.williams@intel.com>
Subject: Re: 3.14-mw regression: rtl8169 WARNING: DMA-API: exceeded 7
 overlapping mappings of pfn 55ebe
Date: Thu, 13 Feb 2014 12:14:47 -0800
Message-ID: <1392322487.11022.4.camel@dwillia2-mobl2.amr.corp.intel.com>
References: <1859471893.20140126115521@eikelenboom.it>
	 <20140127000305.GA14236@electric-eye.fr.zoreil.com>
	 <CAA9_cme2hgJ=jCDkPh5n5RP8fiJE-dVwbFr-apKv1=mNGPHYZg@mail.gmail.com>
	 <84816226.20140206123631@eikelenboom.it>
	 <942972114.20140206140909@eikelenboom.it>
	 <CAPcyv4g2EnCLFWfLfSDnjtwrid2tCq2k6wh-8sPYY06eJpM83A@mail.gmail.com>
	 <1434499348.20140211205617@eikelenboom.it>
	 <CAPcyv4juAS0ODRPKE-_wXYu5bixLnvsgs3jgo4vzWcatfnyVsw@mail.gmail.com>
	 <1392178661.1752.1.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-Ysqi0BnoY9UwbjxLNshF"
Cc: Sander Eikelenboom <linux@eikelenboom.it>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1392178661.1752.1.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-Ysqi0BnoY9UwbjxLNshF
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

On Tue, 2014-02-11 at 20:17 -0800, Eric Dumazet wrote:
> On Tue, 2014-02-11 at 18:07 -0800, Dan Williams wrote:
> 
> > The overlap granularity is too large.  Multiple dma_map_single
> > mappings are allowed to a given page as long as they don't collide on
> > the same cache line.
> > 
> 
> I am not sure why you try number of mappings of a page.
> 
> Try launching 100 concurrent netperf -t TCP_SENFILE
> 
> Same page might be mapped more than 100 times, more than 10000 times in
> some cases.

Thanks for that test case.

I updated the fix patch with the following.

diff --git a/lib/dma-debug.c b/lib/dma-debug.c
index 42b12740940b..611010df1e9c 100644
--- a/lib/dma-debug.c
+++ b/lib/dma-debug.c
@@ -513,6 +513,13 @@ static int active_cln_insert(struct dma_debug_entry *entry)
        unsigned long flags;
        int rc;
 
+       /* If the device is not writing memory then we don't have any
+        * concerns about the cpu consuming stale data.  This mitigates
+        * legitimate usages of overlapping mappings.
+        */
+       if (entry->direction == DMA_TO_DEVICE)
+               return 0;
+
        spin_lock_irqsave(&radix_lock, flags);
        rc = radix_tree_insert(&dma_active_cacheline, to_cln(entry), entry);
        if (rc == -EEXIST)
@@ -526,6 +533,10 @@ static void active_cln_remove(struct dma_debug_entry *entry)
 {
        unsigned long flags;
 
+       /* ...mirror the insert case */
+       if (entry->direction == DMA_TO_DEVICE)
+               return;
+
        spin_lock_irqsave(&radix_lock, flags);
        /* since we are counting overlaps the final put of the
         * cacheline will occur when the overlap count is 0.


Sander, barring a negative test result from you I'll send the attached
patch to Andrew.

--
Dan


--=-Ysqi0BnoY9UwbjxLNshF
Content-Disposition: attachment; filename="fix-dma-debug-overlap-v2.patch"
Content-Type: text/x-patch; name="fix-dma-debug-overlap-v2.patch"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

dma debug: account for cachelines and read-only mappings in overlap tracking

From: Dan Williams <dan.j.williams@intel.com>

While debug_dma_assert_idle() checks if a given *page* is actively
undergoing dma the valid granularity of a dma mapping is a *cacheline*.
Sander's testing shows that the warning message "DMA-API: exceeded 7
overlapping mappings of pfn..." is falsely triggering.  The test is
simply mapping multiple cachelines in a given page.

Ultimately we want overlap tracking to be valid as it is a real api
violation, to that end we need to track active mappings by cachelines.
To this end, update the active dma tracking to use the
page-frame-relative cacheline of the mapping as the key, and update
debug_dma_assert_idle() to check for all possible mapped cachelines for
a given page.  However, this is only a problem when the dma-mapping is
writable by the device.  In fact it is fairly standard for read-only
mappings to have hundreds or thousands of mappings at once.  Limiting
the overlap tracking to writable (!DMA_TO_DEVICE) mappings mitigates
false-positive reports of overlap violations.

Note, the radix gang lookup is sub-optimal.  It would be best if it
stopped fetching entries once the search passed a page boundary.
Nevertheless, this implementation does not perturb the original net_dma
failing case.  That is to say the extra overhead does not show up in
terms of making the failing case pass due to a timing change.

Reported-by: Sander Eikelenboom <linux@eikelenboom.it>
Reported-by: Dave Jones <davej@redhat.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Francois Romieu <romieu@fr.zoreil.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Wei Liu <wei.liu2@citrix.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 lib/dma-debug.c |  123 +++++++++++++++++++++++++++++++++++--------------------
 1 files changed, 78 insertions(+), 45 deletions(-)

diff --git a/lib/dma-debug.c b/lib/dma-debug.c
index 2defd1308b04..611010df1e9c 100644
--- a/lib/dma-debug.c
+++ b/lib/dma-debug.c
@@ -424,111 +424,132 @@ void debug_dma_dump_mappings(struct device *dev)
 EXPORT_SYMBOL(debug_dma_dump_mappings);
 
 /*
- * For each page mapped (initial page in the case of
- * dma_alloc_coherent/dma_map_{single|page}, or each page in a
- * scatterlist) insert into this tree using the pfn as the key. At
+ * For each mapping (initial cacheline in the case of
+ * dma_alloc_coherent/dma_map_page, initial cacheline in each page of a
+ * scatterlist, or the cacheline specified in dma_map_single) insert
+ * into this tree using the cacheline as the key. At
  * dma_unmap_{single|sg|page} or dma_free_coherent delete the entry.  If
- * the pfn already exists at insertion time add a tag as a reference
+ * the entry already exists at insertion time add a tag as a reference
  * count for the overlapping mappings.  For now, the overlap tracking
- * just ensures that 'unmaps' balance 'maps' before marking the pfn
- * idle, but we should also be flagging overlaps as an API violation.
+ * just ensures that 'unmaps' balance 'maps' before marking the
+ * cacheline idle, but we should also be flagging overlaps as an API
+ * violation.
  *
  * Memory usage is mostly constrained by the maximum number of available
  * dma-debug entries in that we need a free dma_debug_entry before
- * inserting into the tree.  In the case of dma_map_{single|page} and
- * dma_alloc_coherent there is only one dma_debug_entry and one pfn to
- * track per event.  dma_map_sg(), on the other hand,
- * consumes a single dma_debug_entry, but inserts 'nents' entries into
- * the tree.
+ * inserting into the tree.  In the case of dma_map_page and
+ * dma_alloc_coherent there is only one dma_debug_entry and one
+ * dma_active_cacheline entry to track per event.  dma_map_sg(), on the
+ * other hand, consumes a single dma_debug_entry, but inserts 'nents'
+ * entries into the tree.
  *
  * At any time debug_dma_assert_idle() can be called to trigger a
- * warning if the given page is in the active set.
+ * warning if any cachelines in the given page are in the active set.
  */
-static RADIX_TREE(dma_active_pfn, GFP_NOWAIT);
+static RADIX_TREE(dma_active_cacheline, GFP_NOWAIT);
 static DEFINE_SPINLOCK(radix_lock);
-#define ACTIVE_PFN_MAX_OVERLAP ((1 << RADIX_TREE_MAX_TAGS) - 1)
+#define ACTIVE_CLN_MAX_OVERLAP ((1 << RADIX_TREE_MAX_TAGS) - 1)
+#define CACHELINE_PER_PAGE_SHIFT (PAGE_SHIFT - L1_CACHE_SHIFT)
+#define CACHELINES_PER_PAGE (1 << CACHELINE_PER_PAGE_SHIFT)
 
-static int active_pfn_read_overlap(unsigned long pfn)
+unsigned long to_cln(struct dma_debug_entry *entry)
+{
+	return (entry->pfn << CACHELINE_PER_PAGE_SHIFT) +
+		(entry->offset >> L1_CACHE_SHIFT);
+}
+
+static int active_cln_read_overlap(unsigned long cln)
 {
 	int overlap = 0, i;
 
 	for (i = RADIX_TREE_MAX_TAGS - 1; i >= 0; i--)
-		if (radix_tree_tag_get(&dma_active_pfn, pfn, i))
+		if (radix_tree_tag_get(&dma_active_cacheline, cln, i))
 			overlap |= 1 << i;
 	return overlap;
 }
 
-static int active_pfn_set_overlap(unsigned long pfn, int overlap)
+static int active_cln_set_overlap(unsigned long cln, int overlap)
 {
 	int i;
 
-	if (overlap > ACTIVE_PFN_MAX_OVERLAP || overlap < 0)
+	if (overlap > ACTIVE_CLN_MAX_OVERLAP || overlap < 0)
 		return overlap;
 
 	for (i = RADIX_TREE_MAX_TAGS - 1; i >= 0; i--)
 		if (overlap & 1 << i)
-			radix_tree_tag_set(&dma_active_pfn, pfn, i);
+			radix_tree_tag_set(&dma_active_cacheline, cln, i);
 		else
-			radix_tree_tag_clear(&dma_active_pfn, pfn, i);
+			radix_tree_tag_clear(&dma_active_cacheline, cln, i);
 
 	return overlap;
 }
 
-static void active_pfn_inc_overlap(unsigned long pfn)
+static void active_cln_inc_overlap(unsigned long cln)
 {
-	int overlap = active_pfn_read_overlap(pfn);
+	int overlap = active_cln_read_overlap(cln);
 
-	overlap = active_pfn_set_overlap(pfn, ++overlap);
+	overlap = active_cln_set_overlap(cln, ++overlap);
 
 	/* If we overflowed the overlap counter then we're potentially
 	 * leaking dma-mappings.  Otherwise, if maps and unmaps are
 	 * balanced then this overflow may cause false negatives in
-	 * debug_dma_assert_idle() as the pfn may be marked idle
+	 * debug_dma_assert_idle() as the cln may be marked idle
 	 * prematurely.
 	 */
-	WARN_ONCE(overlap > ACTIVE_PFN_MAX_OVERLAP,
-		  "DMA-API: exceeded %d overlapping mappings of pfn %lx\n",
-		  ACTIVE_PFN_MAX_OVERLAP, pfn);
+	WARN_ONCE(overlap > ACTIVE_CLN_MAX_OVERLAP,
+		  "DMA-API: exceeded %d overlapping mappings of cln %lx\n",
+		  ACTIVE_CLN_MAX_OVERLAP, cln);
 }
 
-static int active_pfn_dec_overlap(unsigned long pfn)
+static int active_cln_dec_overlap(unsigned long cln)
 {
-	int overlap = active_pfn_read_overlap(pfn);
+	int overlap = active_cln_read_overlap(cln);
 
-	return active_pfn_set_overlap(pfn, --overlap);
+	return active_cln_set_overlap(cln, --overlap);
 }
 
-static int active_pfn_insert(struct dma_debug_entry *entry)
+static int active_cln_insert(struct dma_debug_entry *entry)
 {
 	unsigned long flags;
 	int rc;
 
+	/* If the device is not writing memory then we don't have any
+	 * concerns about the cpu consuming stale data.  This mitigates
+	 * legitimate usages of overlapping mappings.
+	 */
+	if (entry->direction == DMA_TO_DEVICE)
+		return 0;
+
 	spin_lock_irqsave(&radix_lock, flags);
-	rc = radix_tree_insert(&dma_active_pfn, entry->pfn, entry);
+	rc = radix_tree_insert(&dma_active_cacheline, to_cln(entry), entry);
 	if (rc == -EEXIST)
-		active_pfn_inc_overlap(entry->pfn);
+		active_cln_inc_overlap(to_cln(entry));
 	spin_unlock_irqrestore(&radix_lock, flags);
 
 	return rc;
 }
 
-static void active_pfn_remove(struct dma_debug_entry *entry)
+static void active_cln_remove(struct dma_debug_entry *entry)
 {
 	unsigned long flags;
 
+	/* ...mirror the insert case */
+	if (entry->direction == DMA_TO_DEVICE)
+		return;
+
 	spin_lock_irqsave(&radix_lock, flags);
 	/* since we are counting overlaps the final put of the
-	 * entry->pfn will occur when the overlap count is 0.
-	 * active_pfn_dec_overlap() returns -1 in that case
+	 * cacheline will occur when the overlap count is 0.
+	 * active_cln_dec_overlap() returns -1 in that case
 	 */
-	if (active_pfn_dec_overlap(entry->pfn) < 0)
-		radix_tree_delete(&dma_active_pfn, entry->pfn);
+	if (active_cln_dec_overlap(to_cln(entry)) < 0)
+		radix_tree_delete(&dma_active_cacheline, to_cln(entry));
 	spin_unlock_irqrestore(&radix_lock, flags);
 }
 
 /**
  * debug_dma_assert_idle() - assert that a page is not undergoing dma
- * @page: page to lookup in the dma_active_pfn tree
+ * @page: page to lookup in the dma_active_cacheline tree
  *
  * Place a call to this routine in cases where the cpu touching the page
  * before the dma completes (page is dma_unmapped) will lead to data
@@ -536,14 +557,26 @@ static void active_pfn_remove(struct dma_debug_entry *entry)
  */
 void debug_dma_assert_idle(struct page *page)
 {
+	unsigned long cln = page_to_pfn(page) << CACHELINE_PER_PAGE_SHIFT;
+	static struct dma_debug_entry *ents[CACHELINES_PER_PAGE];
+	struct dma_debug_entry *entry = NULL;
+	void **results = (void **) &ents;
+	unsigned int nents, i;
 	unsigned long flags;
-	struct dma_debug_entry *entry;
 
 	if (!page)
 		return;
 
 	spin_lock_irqsave(&radix_lock, flags);
-	entry = radix_tree_lookup(&dma_active_pfn, page_to_pfn(page));
+	nents = radix_tree_gang_lookup(&dma_active_cacheline, results, cln,
+				       CACHELINES_PER_PAGE);
+	for (i = 0; i < nents; i++) {
+		if (to_cln(ents[i]) == cln) {
+			entry = ents[i];
+			break;
+		} else if (to_cln(ents[i]) >= cln + CACHELINES_PER_PAGE)
+			break;
+	}
 	spin_unlock_irqrestore(&radix_lock, flags);
 
 	if (!entry)
@@ -551,7 +584,7 @@ void debug_dma_assert_idle(struct page *page)
 
 	err_printk(entry->dev, entry,
 		   "DMA-API: cpu touching an active dma mapped page "
-		   "[pfn=0x%lx]\n", entry->pfn);
+		   "[cln=0x%lx]\n", to_cln(entry));
 }
 
 /*
@@ -568,9 +601,9 @@ static void add_dma_entry(struct dma_debug_entry *entry)
 	hash_bucket_add(bucket, entry);
 	put_hash_bucket(bucket, &flags);
 
-	rc = active_pfn_insert(entry);
+	rc = active_cln_insert(entry);
 	if (rc == -ENOMEM) {
-		pr_err("DMA-API: pfn tracking ENOMEM, dma-debug disabled\n");
+		pr_err("DMA-API: cacheline tracking ENOMEM, dma-debug disabled\n");
 		global_disable = true;
 	}
 
@@ -631,7 +664,7 @@ static void dma_entry_free(struct dma_debug_entry *entry)
 {
 	unsigned long flags;
 
-	active_pfn_remove(entry);
+	active_cln_remove(entry);
 
 	/*
 	 * add to beginning of the list - this way the entries are

--=-Ysqi0BnoY9UwbjxLNshF--
