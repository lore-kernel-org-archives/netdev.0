From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH v2 4/4] dma debug: introduce debug_dma_assert_idle()
Date: Thu, 09 Jan 2014 12:17:26 -0800
Message-ID: <20140109201657.28381.9305.stgit@viggo.jf.intel.com>
References: <20140109201157.28381.94057.stgit@viggo.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Vinod Koul <vinod.koul@intel.com>, netdev@vger.kernel.org,
	Joerg Roedel <joro@8bytes.org>, linux-kernel@vger.kernel.org,
	James Bottomley <JBottomley@Parallels.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>
To: dmaengine@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140109201157.28381.94057.stgit@viggo.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Record actively mapped pages and provide an api for asserting a given
page is dma inactive before execution proceeds.  Placing
debug_dma_assert_idle() in cow_user_page() flagged the violation of the
dma-api in the NET_DMA implementation (see commit 77873803363c "net_dma:
mark broken").

Cc: Joerg Roedel <joro@8bytes.org>
Cc: Vinod Koul <vinod.koul@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Russell King <rmk+kernel@arm.linux.org.uk>
Cc: James Bottomley <JBottomley@Parallels.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
Added CONFIG_DMA_VS_CPU_DEBUG

 include/linux/dma-debug.h |    6 ++
 lib/Kconfig.debug         |   13 ++++-
 lib/dma-debug.c           |  130 +++++++++++++++++++++++++++++++++++++++++----
 mm/memory.c               |    3 +
 4 files changed, 138 insertions(+), 14 deletions(-)

diff --git a/include/linux/dma-debug.h b/include/linux/dma-debug.h
index fc0e34ce038f..27a029fb2ead 100644
--- a/include/linux/dma-debug.h
+++ b/include/linux/dma-debug.h
@@ -185,4 +185,10 @@ static inline void debug_dma_dump_mappings(struct device *dev)
 
 #endif /* CONFIG_DMA_API_DEBUG */
 
+#ifdef CONFIG_DMA_VS_CPU_DEBUG
+extern void debug_dma_assert_idle(struct page *page);
+#else
+static inline void debug_dma_assert_idle(struct page *page) { }
+#endif /* CONFIG_DMA_VS_CPU_DEBUG  */
+
 #endif /* __DMA_DEBUG_H */
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index db25707aa41b..99751c47fa87 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1575,9 +1575,20 @@ config DMA_API_DEBUG
 	  With this option you will be able to detect common bugs in device
 	  drivers like double-freeing of DMA mappings or freeing mappings that
 	  were never allocated.
-	  This option causes a performance degredation.  Use only if you want
+	  This option causes a performance degradation.  Use only if you want
 	  to debug device drivers. If unsure, say N.
 
+config DMA_VS_CPU_DEBUG
+	bool "Enable debugging CPU vs DMA ownership of pages"
+	depends on DMA_API_DEBUG
+	help
+	  Enable this option to attempt to catch cases where a page owned by
+	  DMA is being touched by the cpu in a way that could cause data
+	  corruption.  For example, this enables cow_user_page() to check
+	  that the source page is not undergoing DMA.  This option
+	  further increases the overhead of DMA_API_DEBUG.  Use only if
+	  debugging device drivers.  If unsure, say N.
+
 source "samples/Kconfig"
 
 source "lib/Kconfig.kgdb"
diff --git a/lib/dma-debug.c b/lib/dma-debug.c
index d87a17a819d0..f67ae111cd2f 100644
--- a/lib/dma-debug.c
+++ b/lib/dma-debug.c
@@ -57,7 +57,8 @@ struct dma_debug_entry {
 	struct list_head list;
 	struct device    *dev;
 	int              type;
-	phys_addr_t      paddr;
+	unsigned long	 pfn;
+	size_t		 offset;
 	u64              dev_addr;
 	u64              size;
 	int              direction;
@@ -372,6 +373,11 @@ static void hash_bucket_del(struct dma_debug_entry *entry)
 	list_del(&entry->list);
 }
 
+static unsigned long long phys_addr(struct dma_debug_entry *entry)
+{
+	return page_to_phys(pfn_to_page(entry->pfn)) + entry->offset;
+}
+
 /*
  * Dump mapping entries for debugging purposes
  */
@@ -389,9 +395,9 @@ void debug_dma_dump_mappings(struct device *dev)
 		list_for_each_entry(entry, &bucket->list, list) {
 			if (!dev || dev == entry->dev) {
 				dev_info(entry->dev,
-					 "%s idx %d P=%Lx D=%Lx L=%Lx %s %s\n",
+					 "%s idx %d P=%Lx N=%lx D=%Lx L=%Lx %s %s\n",
 					 type2name[entry->type], idx,
-					 (unsigned long long)entry->paddr,
+					 phys_addr(entry), entry->pfn,
 					 entry->dev_addr, entry->size,
 					 dir2name[entry->direction],
 					 maperr2str[entry->map_err_type]);
@@ -403,6 +409,83 @@ void debug_dma_dump_mappings(struct device *dev)
 }
 EXPORT_SYMBOL(debug_dma_dump_mappings);
 
+/* memory usage is constrained by the maximum number of available
+ * dma-debug entries
+ */
+static RADIX_TREE(dma_active_pfn, GFP_NOWAIT);
+static DEFINE_SPINLOCK(radix_lock);
+
+static void __active_pfn_inc_overlap(struct dma_debug_entry *entry)
+{
+	unsigned long pfn = entry->pfn;
+	int i;
+
+	for (i = 0; i < RADIX_TREE_MAX_TAGS; i++)
+		if (radix_tree_tag_get(&dma_active_pfn, pfn, i) == 0) {
+			radix_tree_tag_set(&dma_active_pfn, pfn, i);
+			return;
+		}
+	pr_debug("DMA-API: max overlap count (%d) reached for pfn 0x%lx\n",
+		 RADIX_TREE_MAX_TAGS, pfn);
+}
+
+static void __active_pfn_dec_overlap(struct dma_debug_entry *entry)
+{
+	unsigned long pfn = entry->pfn;
+	int i;
+
+	for (i = RADIX_TREE_MAX_TAGS - 1; i >= 0; i--)
+		if (radix_tree_tag_get(&dma_active_pfn, pfn, i)) {
+			radix_tree_tag_clear(&dma_active_pfn, pfn, i);
+			return;
+		}
+	radix_tree_delete(&dma_active_pfn, pfn);
+}
+
+static int active_pfn_insert(struct dma_debug_entry *entry)
+{
+	unsigned long flags;
+	int rc;
+
+	spin_lock_irqsave(&radix_lock, flags);
+	rc = radix_tree_insert(&dma_active_pfn, entry->pfn, entry);
+	if (rc == -EEXIST)
+		__active_pfn_inc_overlap(entry);
+	spin_unlock_irqrestore(&radix_lock, flags);
+
+	return rc;
+}
+
+static void active_pfn_remove(struct dma_debug_entry *entry)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&radix_lock, flags);
+	__active_pfn_dec_overlap(entry);
+	spin_unlock_irqrestore(&radix_lock, flags);
+}
+
+void debug_dma_assert_idle(struct page *page)
+{
+	unsigned long flags;
+	struct dma_debug_entry *entry;
+
+	if (!page)
+		return;
+
+	spin_lock_irqsave(&radix_lock, flags);
+	entry = radix_tree_lookup(&dma_active_pfn, page_to_pfn(page));
+	spin_unlock_irqrestore(&radix_lock, flags);
+
+	if (!entry)
+		return;
+
+	err_printk(entry->dev, entry,
+		   "DMA-API: cpu touching an active dma mapped page "
+		   "[pfn=0x%lx]\n", entry->pfn);
+}
+EXPORT_SYMBOL_GPL(debug_dma_assert_idle);
+
 /*
  * Wrapper function for adding an entry to the hash.
  * This function takes care of locking itself.
@@ -411,10 +494,22 @@ static void add_dma_entry(struct dma_debug_entry *entry)
 {
 	struct hash_bucket *bucket;
 	unsigned long flags;
+	int rc;
 
 	bucket = get_hash_bucket(entry, &flags);
 	hash_bucket_add(bucket, entry);
 	put_hash_bucket(bucket, &flags);
+
+	rc = active_pfn_insert(entry);
+	if (rc == -ENOMEM) {
+		pr_err("DMA-API: pfn tracking out of memory - "
+		       "disabling dma-debug\n");
+		global_disable = true;
+	}
+
+	/* TODO: report -EEXIST errors as overlapping mappings are not
+	 * supported by the DMA API
+	 */
 }
 
 static struct dma_debug_entry *__dma_entry_alloc(void)
@@ -469,6 +564,8 @@ static void dma_entry_free(struct dma_debug_entry *entry)
 {
 	unsigned long flags;
 
+	active_pfn_remove(entry);
+
 	/*
 	 * add to beginning of the list - this way the entries are
 	 * more likely cache hot when they are reallocated.
@@ -895,15 +992,15 @@ static void check_unmap(struct dma_debug_entry *ref)
 			   ref->dev_addr, ref->size,
 			   type2name[entry->type], type2name[ref->type]);
 	} else if ((entry->type == dma_debug_coherent) &&
-		   (ref->paddr != entry->paddr)) {
+		   (phys_addr(ref) != phys_addr(entry))) {
 		err_printk(ref->dev, entry, "DMA-API: device driver frees "
 			   "DMA memory with different CPU address "
 			   "[device address=0x%016llx] [size=%llu bytes] "
 			   "[cpu alloc address=0x%016llx] "
 			   "[cpu free address=0x%016llx]",
 			   ref->dev_addr, ref->size,
-			   (unsigned long long)entry->paddr,
-			   (unsigned long long)ref->paddr);
+			   phys_addr(entry),
+			   phys_addr(ref));
 	}
 
 	if (ref->sg_call_ents && ref->type == dma_debug_sg &&
@@ -1052,7 +1149,8 @@ void debug_dma_map_page(struct device *dev, struct page *page, size_t offset,
 
 	entry->dev       = dev;
 	entry->type      = dma_debug_page;
-	entry->paddr     = page_to_phys(page) + offset;
+	entry->pfn	 = page_to_pfn(page);
+	entry->offset	 = offset,
 	entry->dev_addr  = dma_addr;
 	entry->size      = size;
 	entry->direction = direction;
@@ -1148,7 +1246,8 @@ void debug_dma_map_sg(struct device *dev, struct scatterlist *sg,
 
 		entry->type           = dma_debug_sg;
 		entry->dev            = dev;
-		entry->paddr          = sg_phys(s);
+		entry->pfn	      = page_to_pfn(sg_page(s));
+		entry->offset	      = s->offset,
 		entry->size           = sg_dma_len(s);
 		entry->dev_addr       = sg_dma_address(s);
 		entry->direction      = direction;
@@ -1198,7 +1297,8 @@ void debug_dma_unmap_sg(struct device *dev, struct scatterlist *sglist,
 		struct dma_debug_entry ref = {
 			.type           = dma_debug_sg,
 			.dev            = dev,
-			.paddr          = sg_phys(s),
+			.pfn		= page_to_pfn(sg_page(s)),
+			.offset		= s->offset,
 			.dev_addr       = sg_dma_address(s),
 			.size           = sg_dma_len(s),
 			.direction      = dir,
@@ -1233,7 +1333,8 @@ void debug_dma_alloc_coherent(struct device *dev, size_t size,
 
 	entry->type      = dma_debug_coherent;
 	entry->dev       = dev;
-	entry->paddr     = virt_to_phys(virt);
+	entry->pfn	 = page_to_pfn(virt_to_page(virt));
+	entry->offset	 = (size_t) virt & PAGE_MASK;
 	entry->size      = size;
 	entry->dev_addr  = dma_addr;
 	entry->direction = DMA_BIDIRECTIONAL;
@@ -1248,7 +1349,8 @@ void debug_dma_free_coherent(struct device *dev, size_t size,
 	struct dma_debug_entry ref = {
 		.type           = dma_debug_coherent,
 		.dev            = dev,
-		.paddr          = virt_to_phys(virt),
+		.pfn		= page_to_pfn(virt_to_page(virt)),
+		.offset		= (size_t) virt & PAGE_MASK,
 		.dev_addr       = addr,
 		.size           = size,
 		.direction      = DMA_BIDIRECTIONAL,
@@ -1356,7 +1458,8 @@ void debug_dma_sync_sg_for_cpu(struct device *dev, struct scatterlist *sg,
 		struct dma_debug_entry ref = {
 			.type           = dma_debug_sg,
 			.dev            = dev,
-			.paddr          = sg_phys(s),
+			.pfn		= page_to_pfn(sg_page(s)),
+			.offset		= s->offset,
 			.dev_addr       = sg_dma_address(s),
 			.size           = sg_dma_len(s),
 			.direction      = direction,
@@ -1388,7 +1491,8 @@ void debug_dma_sync_sg_for_device(struct device *dev, struct scatterlist *sg,
 		struct dma_debug_entry ref = {
 			.type           = dma_debug_sg,
 			.dev            = dev,
-			.paddr          = sg_phys(s),
+			.pfn		= page_to_pfn(sg_page(s)),
+			.offset		= s->offset,
 			.dev_addr       = sg_dma_address(s),
 			.size           = sg_dma_len(s),
 			.direction      = direction,
diff --git a/mm/memory.c b/mm/memory.c
index 5d9025f3b3e1..c89788436f81 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -59,6 +59,7 @@
 #include <linux/gfp.h>
 #include <linux/migrate.h>
 #include <linux/string.h>
+#include <linux/dma-debug.h>
 
 #include <asm/io.h>
 #include <asm/pgalloc.h>
@@ -2559,6 +2560,8 @@ static inline int pte_unmap_same(struct mm_struct *mm, pmd_t *pmd,
 
 static inline void cow_user_page(struct page *dst, struct page *src, unsigned long va, struct vm_area_struct *vma)
 {
+	debug_dma_assert_idle(src);
+
 	/*
 	 * If the source page was a PFN mapping, we don't have
 	 * a "struct page" for it. We do a best-effort copy by
