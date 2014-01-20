From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [Xen-devel] [PATCH v3] xen/grant-table: Avoid m2p_override during	mapping
Date: Mon, 20 Jan 2014 16:22:47 -0500
Message-ID: <a6736948-c67e-4509-89a8-42ec9693830f@email.android.com>
References: <1390244288-3186-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8BIT
To: Zoltan Kiss <zoltan.kiss@citrix.com>, ian.campbell@citrix.com,
	wei.liu2@citrix.com, xen-devel@lists.xenproject.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jonathan.davies@citrix.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1390244288-3186-1-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Zoltan Kiss <zoltan.kiss@citrix.com> wrote:
>The grant mapping API does m2p_override unnecessarily: only gntdev
>needs it,
>for blkback and future netback patches it just cause a lock contention,
>as
>those pages never go to userspace. Therefore this series does the
>following:
>- the original functions were renamed to __gnttab_[un]map_refs, with a
>new
>  parameter m2p_override
>- based on m2p_override either they follow the original behaviour, or
>just set
>  the private flag and call set_phys_to_machine
>- gnttab_[un]map_refs are now a wrapper to call __gnttab_[un]map_refs
>with
>  m2p_override false
>- a new function gnttab_[un]map_refs_userspace provides the old
>behaviour

You don't say anything about the 'return ret' changed to 'return 0'.

Any particular reason for that?

Thanks
>
>v2:
>- move the storing of the old mfn in page->index to gnttab_map_refs
>- move the function header update to a separate patch
>
>v3:
>- a new approach to retain old behaviour where it needed
>- squash the patches into one
>
>Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
>Suggested-by: David Vrabel <david.vrabel@citrix.com>
>---
> drivers/block/xen-blkback/blkback.c |   15 +++----
> drivers/xen/gntdev.c                |   13 +++---
>drivers/xen/grant-table.c           |   81
>+++++++++++++++++++++++++++++------
> include/xen/grant_table.h           |    8 +++-
> 4 files changed, 87 insertions(+), 30 deletions(-)
>
>diff --git a/drivers/block/xen-blkback/blkback.c
>b/drivers/block/xen-blkback/blkback.c
>index 6620b73..875025f 100644
>--- a/drivers/block/xen-blkback/blkback.c
>+++ b/drivers/block/xen-blkback/blkback.c
>@@ -285,8 +285,7 @@ static void free_persistent_gnts(struct xen_blkif
>*blkif, struct rb_root *root,
> 
> 		if (++segs_to_unmap == BLKIF_MAX_SEGMENTS_PER_REQUEST ||
> 			!rb_next(&persistent_gnt->node)) {
>-			ret = gnttab_unmap_refs(unmap, NULL, pages,
>-				segs_to_unmap);
>+			ret = gnttab_unmap_refs(unmap, pages, segs_to_unmap);
> 			BUG_ON(ret);
> 			put_free_pages(blkif, pages, segs_to_unmap);
> 			segs_to_unmap = 0;
>@@ -321,8 +320,7 @@ static void unmap_purged_grants(struct work_struct
>*work)
> 		pages[segs_to_unmap] = persistent_gnt->page;
> 
> 		if (++segs_to_unmap == BLKIF_MAX_SEGMENTS_PER_REQUEST) {
>-			ret = gnttab_unmap_refs(unmap, NULL, pages,
>-				segs_to_unmap);
>+			ret = gnttab_unmap_refs(unmap, pages, segs_to_unmap);
> 			BUG_ON(ret);
> 			put_free_pages(blkif, pages, segs_to_unmap);
> 			segs_to_unmap = 0;
>@@ -330,7 +328,7 @@ static void unmap_purged_grants(struct work_struct
>*work)
> 		kfree(persistent_gnt);
> 	}
> 	if (segs_to_unmap > 0) {
>-		ret = gnttab_unmap_refs(unmap, NULL, pages, segs_to_unmap);
>+		ret = gnttab_unmap_refs(unmap, pages, segs_to_unmap);
> 		BUG_ON(ret);
> 		put_free_pages(blkif, pages, segs_to_unmap);
> 	}
>@@ -670,15 +668,14 @@ static void xen_blkbk_unmap(struct xen_blkif
>*blkif,
> 				    GNTMAP_host_map, pages[i]->handle);
> 		pages[i]->handle = BLKBACK_INVALID_HANDLE;
> 		if (++invcount == BLKIF_MAX_SEGMENTS_PER_REQUEST) {
>-			ret = gnttab_unmap_refs(unmap, NULL, unmap_pages,
>-			                        invcount);
>+			ret = gnttab_unmap_refs(unmap, unmap_pages, invcount);
> 			BUG_ON(ret);
> 			put_free_pages(blkif, unmap_pages, invcount);
> 			invcount = 0;
> 		}
> 	}
> 	if (invcount) {
>-		ret = gnttab_unmap_refs(unmap, NULL, unmap_pages, invcount);
>+		ret = gnttab_unmap_refs(unmap, unmap_pages, invcount);
> 		BUG_ON(ret);
> 		put_free_pages(blkif, unmap_pages, invcount);
> 	}
>@@ -740,7 +737,7 @@ again:
> 	}
> 
> 	if (segs_to_map) {
>-		ret = gnttab_map_refs(map, NULL, pages_to_gnt, segs_to_map);
>+		ret = gnttab_map_refs(map, pages_to_gnt, segs_to_map);
> 		BUG_ON(ret);
> 	}
> 
>diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
>index e41c79c..e652c0e 100644
>--- a/drivers/xen/gntdev.c
>+++ b/drivers/xen/gntdev.c
>@@ -284,8 +284,10 @@ static int map_grant_pages(struct grant_map *map)
> 	}
> 
> 	pr_debug("map %d+%d\n", map->index, map->count);
>-	err = gnttab_map_refs(map->map_ops, use_ptemod ? map->kmap_ops :
>NULL,
>-			map->pages, map->count);
>+	err = gnttab_map_refs_userspace(map->map_ops,
>+					use_ptemod ? map->kmap_ops : NULL,
>+					map->pages,
>+					map->count);
> 	if (err)
> 		return err;
> 
>@@ -315,9 +317,10 @@ static int __unmap_grant_pages(struct grant_map
>*map, int offset, int pages)
> 		}
> 	}
> 
>-	err = gnttab_unmap_refs(map->unmap_ops + offset,
>-			use_ptemod ? map->kmap_ops + offset : NULL, map->pages + offset,
>-			pages);
>+	err = gnttab_unmap_refs_userspace(map->unmap_ops + offset,
>+					  use_ptemod ? map->kmap_ops + offset : NULL,
>+					  map->pages + offset,
>+					  pages);
> 	if (err)
> 		return err;
> 
>diff --git a/drivers/xen/grant-table.c b/drivers/xen/grant-table.c
>index aa846a4..87ded60 100644
>--- a/drivers/xen/grant-table.c
>+++ b/drivers/xen/grant-table.c
>@@ -880,15 +880,17 @@ void gnttab_batch_copy(struct gnttab_copy *batch,
>unsigned count)
> }
> EXPORT_SYMBOL_GPL(gnttab_batch_copy);
> 
>-int gnttab_map_refs(struct gnttab_map_grant_ref *map_ops,
>+int __gnttab_map_refs(struct gnttab_map_grant_ref *map_ops,
> 		    struct gnttab_map_grant_ref *kmap_ops,
>-		    struct page **pages, unsigned int count)
>+		    struct page **pages, unsigned int count,
>+		    bool m2p_override)
> {
> 	int i, ret;
> 	bool lazy = false;
> 	pte_t *pte;
> 	unsigned long mfn;
> 
>+	BUG_ON(kmap_ops && !m2p_override);
>	ret = HYPERVISOR_grant_table_op(GNTTABOP_map_grant_ref, map_ops,
>count);
> 	if (ret)
> 		return ret;
>@@ -907,10 +909,12 @@ int gnttab_map_refs(struct gnttab_map_grant_ref
>*map_ops,
> 			set_phys_to_machine(map_ops[i].host_addr >> PAGE_SHIFT,
> 					map_ops[i].dev_bus_addr >> PAGE_SHIFT);
> 		}
>-		return ret;
>+		return 0;
> 	}
> 
>-	if (!in_interrupt() && paravirt_get_lazy_mode() ==
>PARAVIRT_LAZY_NONE) {
>+	if (m2p_override &&
>+	    !in_interrupt() &&
>+	    paravirt_get_lazy_mode() == PARAVIRT_LAZY_NONE) {
> 		arch_enter_lazy_mmu_mode();
> 		lazy = true;
> 	}
>@@ -927,8 +931,18 @@ int gnttab_map_refs(struct gnttab_map_grant_ref
>*map_ops,
> 		} else {
> 			mfn = PFN_DOWN(map_ops[i].dev_bus_addr);
> 		}
>-		ret = m2p_add_override(mfn, pages[i], kmap_ops ?
>-				       &kmap_ops[i] : NULL);
>+		if (m2p_override)
>+			ret = m2p_add_override(mfn, pages[i], kmap_ops ?
>+					       &kmap_ops[i] : NULL);
>+		else {
>+			unsigned long pfn = page_to_pfn(pages[i]);
>+			WARN_ON(PagePrivate(pages[i]));
>+			SetPagePrivate(pages[i]);
>+			set_page_private(pages[i], mfn);
>+			pages[i]->index = pfn_to_mfn(pfn);
>+			if (unlikely(!set_phys_to_machine(pfn, FOREIGN_FRAME(mfn))))
>+				return -ENOMEM;
>+		}
> 		if (ret)
> 			goto out;
> 	}
>@@ -937,17 +951,33 @@ int gnttab_map_refs(struct gnttab_map_grant_ref
>*map_ops,
> 	if (lazy)
> 		arch_leave_lazy_mmu_mode();
> 
>-	return ret;
>+	return 0;
>+}
>+
>+int gnttab_map_refs(struct gnttab_map_grant_ref *map_ops,
>+		    struct page **pages, unsigned int count)
>+{
>+	return __gnttab_map_refs(map_ops, NULL, pages, count, false);
> }
> EXPORT_SYMBOL_GPL(gnttab_map_refs);
> 
>-int gnttab_unmap_refs(struct gnttab_unmap_grant_ref *unmap_ops,
>+int gnttab_map_refs_userspace(struct gnttab_map_grant_ref *map_ops,
>+			      struct gnttab_map_grant_ref *kmap_ops,
>+			      struct page **pages, unsigned int count)
>+{
>+	return __gnttab_map_refs(map_ops, kmap_ops, pages, count, true);
>+}
>+EXPORT_SYMBOL_GPL(gnttab_map_refs_userspace);
>+
>+int __gnttab_unmap_refs(struct gnttab_unmap_grant_ref *unmap_ops,
> 		      struct gnttab_map_grant_ref *kmap_ops,
>-		      struct page **pages, unsigned int count)
>+		      struct page **pages, unsigned int count,
>+		      bool m2p_override)
> {
> 	int i, ret;
> 	bool lazy = false;
> 
>+	BUG_ON(kmap_ops && !m2p_override);
>	ret = HYPERVISOR_grant_table_op(GNTTABOP_unmap_grant_ref, unmap_ops,
>count);
> 	if (ret)
> 		return ret;
>@@ -958,17 +988,26 @@ int gnttab_unmap_refs(struct
>gnttab_unmap_grant_ref *unmap_ops,
> 			set_phys_to_machine(unmap_ops[i].host_addr >> PAGE_SHIFT,
> 					INVALID_P2M_ENTRY);
> 		}
>-		return ret;
>+		return 0;
> 	}
> 
>-	if (!in_interrupt() && paravirt_get_lazy_mode() ==
>PARAVIRT_LAZY_NONE) {
>+	if (m2p_override &&
>+	    !in_interrupt() &&
>+	    paravirt_get_lazy_mode() == PARAVIRT_LAZY_NONE) {
> 		arch_enter_lazy_mmu_mode();
> 		lazy = true;
> 	}
> 
> 	for (i = 0; i < count; i++) {
>-		ret = m2p_remove_override(pages[i], kmap_ops ?
>-				       &kmap_ops[i] : NULL);
>+		if (m2p_override)
>+			ret = m2p_remove_override(pages[i], kmap_ops ?
>+						  &kmap_ops[i] : NULL);
>+		else {
>+			unsigned long pfn = page_to_pfn(pages[i]);
>+			WARN_ON(!PagePrivate(pages[i]));
>+			ClearPagePrivate(pages[i]);
>+			set_phys_to_machine(pfn, pages[i]->index);
>+		}
> 		if (ret)
> 			goto out;
> 	}
>@@ -977,10 +1016,24 @@ int gnttab_unmap_refs(struct
>gnttab_unmap_grant_ref *unmap_ops,
> 	if (lazy)
> 		arch_leave_lazy_mmu_mode();
> 
>-	return ret;
>+	return 0;
>+}
>+
>+int gnttab_unmap_refs(struct gnttab_unmap_grant_ref *map_ops,
>+		    struct page **pages, unsigned int count)
>+{
>+	return __gnttab_unmap_refs(map_ops, NULL, pages, count, false);
> }
> EXPORT_SYMBOL_GPL(gnttab_unmap_refs);
> 
>+int gnttab_unmap_refs_userspace(struct gnttab_unmap_grant_ref
>*map_ops,
>+				struct gnttab_map_grant_ref *kmap_ops,
>+				struct page **pages, unsigned int count)
>+{
>+	return __gnttab_unmap_refs(map_ops, kmap_ops, pages, count, true);
>+}
>+EXPORT_SYMBOL_GPL(gnttab_unmap_refs_userspace);
>+
> static unsigned nr_status_frames(unsigned nr_grant_frames)
> {
> 	BUG_ON(grefs_per_grant_frame == 0);
>diff --git a/include/xen/grant_table.h b/include/xen/grant_table.h
>index 694dcaf..9a919b1 100644
>--- a/include/xen/grant_table.h
>+++ b/include/xen/grant_table.h
>@@ -184,11 +184,15 @@ unsigned int gnttab_max_grant_frames(void);
> #define gnttab_map_vaddr(map) ((void *)(map.host_virt_addr))
> 
> int gnttab_map_refs(struct gnttab_map_grant_ref *map_ops,
>-		    struct gnttab_map_grant_ref *kmap_ops,
> 		    struct page **pages, unsigned int count);
>+int gnttab_map_refs_userspace(struct gnttab_map_grant_ref *map_ops,
>+			      struct gnttab_map_grant_ref *kmap_ops,
>+			      struct page **pages, unsigned int count);
> int gnttab_unmap_refs(struct gnttab_unmap_grant_ref *unmap_ops,
>-		      struct gnttab_map_grant_ref *kunmap_ops,
> 		      struct page **pages, unsigned int count);
>+int gnttab_unmap_refs_userspace(struct gnttab_unmap_grant_ref
>*unmap_ops,
>+				struct gnttab_map_grant_ref *kunmap_ops,
>+				struct page **pages, unsigned int count);
> 
>/* Perform a batch of grant map/copy operations. Retry every batch slot
> * for which the hypervisor returns GNTST_eagain. This is typically due
>
>_______________________________________________
>Xen-devel mailing list
>Xen-devel@lists.xen.org
>http://lists.xen.org/xen-devel
