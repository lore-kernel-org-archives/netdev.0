From: Timur Tabi <timur@freescale.com>
Subject: [PATCH v4] powerpc: change rheap functions to use ulongs instead of pointers
Date: Tue,  8 May 2007 14:46:36 -0500
Message-ID: <11786535963742-git-send-email-timur@freescale.com>
Cc: Timur Tabi <timur@freescale.com>
To: galak@kernel.crashing.org, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:46785 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031283AbXEHTrD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2007 15:47:03 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The rheap allocation functions return a pointer, but the actual value is based
on how the heap was initialized, and so it can be anything, e.g. an offset
into a buffer.  A ulong is a better representation of the value returned by
the allocation functions.

This patch changes all of the relevant rheap functions to use a unsigned long
integers instead of a pointer.  In case of an error, the value returned is
a negative error code that has been cast to an unsigned long.  The caller can
use the IS_ERR_VALUE() macro to check for this.

All code which calls the rheap functions is updated accordingly.  Macros
IS_MURAM_ERR() and IS_DPERR(), have been deleted in favor of IS_ERR_VALUE().

Also added error checking to rh_attach_region().

Signed-off-by: Timur Tabi <timur@freescale.com>
---

Updated for Paul's latest tree.  Even though this patch changes powerpc,
netdev, and serial drivers, it cannot be split up.  The powerpc side deletes
a function and changes prototypes of other functions, so if the netdev and
serial drivers are not updated at the same time, they won't compile.

 arch/powerpc/lib/rheap.c                |  117 ++++++++++++++++++-------------
 arch/powerpc/sysdev/commproc.c          |   20 +++---
 arch/powerpc/sysdev/cpm2_common.c       |   21 +++---
 arch/powerpc/sysdev/qe_lib/qe.c         |   29 ++++----
 arch/powerpc/sysdev/qe_lib/ucc_fast.c   |    5 +-
 arch/powerpc/sysdev/qe_lib/ucc_slow.c   |    7 +-
 arch/ppc/8xx_io/commproc.c              |   22 +++---
 arch/ppc/lib/rheap.c                    |   95 +++++++++++++------------
 arch/ppc/syslib/cpm2_common.c           |   23 +++---
 drivers/net/fs_enet/mac-scc.c           |    2 +-
 drivers/net/ucc_geth.c                  |   30 ++++----
 drivers/serial/cpm_uart/cpm_uart_cpm1.c |    4 +-
 drivers/serial/cpm_uart/cpm_uart_cpm2.c |    4 +-
 include/asm-powerpc/qe.h                |   13 +---
 include/asm-ppc/commproc.h              |   13 +---
 include/asm-ppc/cpm2.h                  |   13 +---
 include/asm-ppc/rheap.h                 |   20 +++---
 17 files changed, 221 insertions(+), 217 deletions(-)

diff --git a/arch/powerpc/lib/rheap.c b/arch/powerpc/lib/rheap.c
index 6c5c5dd..b2f6dcc 100644
--- a/arch/powerpc/lib/rheap.c
+++ b/arch/powerpc/lib/rheap.c
@@ -133,7 +133,7 @@ static rh_block_t *get_slot(rh_info_t * info)
 	info->empty_slots--;

 	/* Initialize */
-	blk->start = NULL;
+	blk->start = 0;
 	blk->size = 0;
 	blk->owner = NULL;

@@ -158,7 +158,7 @@ static void attach_free_block(rh_info_t * info, rh_block_t * blkn)

 	/* We assume that they are aligned properly */
 	size = blkn->size;
-	s = (unsigned long)blkn->start;
+	s = blkn->start;
 	e = s + size;

 	/* Find the blocks immediately before and after the given one
@@ -170,7 +170,7 @@ static void attach_free_block(rh_info_t * info, rh_block_t * blkn)
 	list_for_each(l, &info->free_list) {
 		blk = list_entry(l, rh_block_t, list);

-		bs = (unsigned long)blk->start;
+		bs = blk->start;
 		be = bs + blk->size;

 		if (next == NULL && s >= bs)
@@ -188,10 +188,10 @@ static void attach_free_block(rh_info_t * info, rh_block_t * blkn)
 	}

 	/* Now check if they are really adjacent */
-	if (before != NULL && s != (unsigned long)before->start + before->size)
+	if (before && s != (before->start + before->size))
 		before = NULL;

-	if (after != NULL && e != (unsigned long)after->start)
+	if (after && e != after->start)
 		after = NULL;

 	/* No coalescing; list insert and return */
@@ -216,7 +216,7 @@ static void attach_free_block(rh_info_t * info, rh_block_t * blkn)

 	/* Grow the after block backwards */
 	if (before == NULL && after != NULL) {
-		after->start = (int8_t *)after->start - size;
+		after->start -= size;
 		after->size += size;
 		return;
 	}
@@ -321,14 +321,14 @@ void rh_init(rh_info_t * info, unsigned int alignment, int max_blocks,
 }

 /* Attach a free memory region, coalesces regions if adjuscent */
-int rh_attach_region(rh_info_t * info, void *start, int size)
+int rh_attach_region(rh_info_t * info, unsigned long start, int size)
 {
 	rh_block_t *blk;
 	unsigned long s, e, m;
 	int r;

 	/* The region must be aligned */
-	s = (unsigned long)start;
+	s = start;
 	e = s + size;
 	m = info->alignment - 1;

@@ -338,9 +338,12 @@ int rh_attach_region(rh_info_t * info, void *start, int size)
 	/* Round end down */
 	e = e & ~m;

+	if (IS_ERR_VALUE(e) || (e < s))
+		return -ERANGE;
+
 	/* Take final values */
-	start = (void *)s;
-	size = (int)(e - s);
+	start = s;
+	size = e - s;

 	/* Grow the blocks, if needed */
 	r = assure_empty(info, 1);
@@ -358,7 +361,7 @@ int rh_attach_region(rh_info_t * info, void *start, int size)
 }

 /* Detatch given address range, splits free block if needed. */
-void *rh_detach_region(rh_info_t * info, void *start, int size)
+unsigned long rh_detach_region(rh_info_t * info, unsigned long start, int size)
 {
 	struct list_head *l;
 	rh_block_t *blk, *newblk;
@@ -366,10 +369,10 @@ void *rh_detach_region(rh_info_t * info, void *start, int size)

 	/* Validate size */
 	if (size <= 0)
-		return ERR_PTR(-EINVAL);
+		return (unsigned long) -EINVAL;

 	/* The region must be aligned */
-	s = (unsigned long)start;
+	s = start;
 	e = s + size;
 	m = info->alignment - 1;

@@ -380,34 +383,34 @@ void *rh_detach_region(rh_info_t * info, void *start, int size)
 	e = e & ~m;

 	if (assure_empty(info, 1) < 0)
-		return ERR_PTR(-ENOMEM);
+		return (unsigned long) -ENOMEM;

 	blk = NULL;
 	list_for_each(l, &info->free_list) {
 		blk = list_entry(l, rh_block_t, list);
 		/* The range must lie entirely inside one free block */
-		bs = (unsigned long)blk->start;
-		be = (unsigned long)blk->start + blk->size;
+		bs = blk->start;
+		be = blk->start + blk->size;
 		if (s >= bs && e <= be)
 			break;
 		blk = NULL;
 	}

 	if (blk == NULL)
-		return ERR_PTR(-ENOMEM);
+		return (unsigned long) -ENOMEM;

 	/* Perfect fit */
 	if (bs == s && be == e) {
 		/* Delete from free list, release slot */
 		list_del(&blk->list);
 		release_slot(info, blk);
-		return (void *)s;
+		return s;
 	}

 	/* blk still in free list, with updated start and/or size */
 	if (bs == s || be == e) {
 		if (bs == s)
-			blk->start = (int8_t *)blk->start + size;
+			blk->start += size;
 		blk->size -= size;

 	} else {
@@ -416,25 +419,29 @@ void *rh_detach_region(rh_info_t * info, void *start, int size)

 		/* the back free fragment */
 		newblk = get_slot(info);
-		newblk->start = (void *)e;
+		newblk->start = e;
 		newblk->size = be - e;

 		list_add(&newblk->list, &blk->list);
 	}

-	return (void *)s;
+	return s;
 }

-void *rh_alloc_align(rh_info_t * info, int size, int alignment, const char *owner)
+/* Allocate a block of memory at the specified alignment.  The value returned
+ * is an offset into the buffer initialized by rh_init(), or a negative number
+ * if there is an error.
+ */
+unsigned long rh_alloc_align(rh_info_t * info, int size, int alignment, const char *owner)
 {
 	struct list_head *l;
 	rh_block_t *blk;
 	rh_block_t *newblk;
-	void *start;
+	unsigned long start;

-	/* Validate size, (must be power of two) */
+	/* Validate size, and alignment must be power of two */
 	if (size <= 0 || (alignment & (alignment - 1)) != 0)
-		return ERR_PTR(-EINVAL);
+		return (unsigned long) -EINVAL;

 	/* given alignment larger that default rheap alignment */
 	if (alignment > info->alignment)
@@ -444,7 +451,7 @@ void *rh_alloc_align(rh_info_t * info, int size, int alignment, const char *owne
 	size = (size + (info->alignment - 1)) & ~(info->alignment - 1);

 	if (assure_empty(info, 1) < 0)
-		return ERR_PTR(-ENOMEM);
+		return (unsigned long) -ENOMEM;

 	blk = NULL;
 	list_for_each(l, &info->free_list) {
@@ -455,7 +462,7 @@ void *rh_alloc_align(rh_info_t * info, int size, int alignment, const char *owne
 	}

 	if (blk == NULL)
-		return ERR_PTR(-ENOMEM);
+		return (unsigned long) -ENOMEM;

 	/* Just fits */
 	if (blk->size == size) {
@@ -475,7 +482,7 @@ void *rh_alloc_align(rh_info_t * info, int size, int alignment, const char *owne
 	newblk->owner = owner;

 	/* blk still in free list, with updated start, size */
-	blk->start = (int8_t *)blk->start + size;
+	blk->start += size;
 	blk->size -= size;

 	start = newblk->start;
@@ -486,19 +493,25 @@ void *rh_alloc_align(rh_info_t * info, int size, int alignment, const char *owne
 	/* this is no problem with the deallocator since */
 	/* we scan for pointers that lie in the blocks   */
 	if (alignment > info->alignment)
-		start = (void *)(((unsigned long)start + alignment - 1) &
-				~(alignment - 1));
+		start = (start + alignment - 1) & ~(alignment - 1);

 	return start;
 }

-void *rh_alloc(rh_info_t * info, int size, const char *owner)
+/* Allocate a block of memory at the default alignment.  The value returned is
+ * an offset into the buffer initialized by rh_init(), or a negative number if
+ * there is an error.
+ */
+unsigned long rh_alloc(rh_info_t * info, int size, const char *owner)
 {
 	return rh_alloc_align(info, size, info->alignment, owner);
 }

-/* allocate at precisely the given address */
-void *rh_alloc_fixed(rh_info_t * info, void *start, int size, const char *owner)
+/* Allocate a block of memory at the given offset, rounded up to the default
+ * alignment.  The value returned is an offset into the buffer initialized by
+ * rh_init(), or a negative number if there is an error.
+ */
+unsigned long rh_alloc_fixed(rh_info_t * info, unsigned long start, int size, const char *owner)
 {
 	struct list_head *l;
 	rh_block_t *blk, *newblk1, *newblk2;
@@ -506,10 +519,10 @@ void *rh_alloc_fixed(rh_info_t * info, void *start, int size, const char *owner)

 	/* Validate size */
 	if (size <= 0)
-		return ERR_PTR(-EINVAL);
+		return (unsigned long) -EINVAL;

 	/* The region must be aligned */
-	s = (unsigned long)start;
+	s = start;
 	e = s + size;
 	m = info->alignment - 1;

@@ -520,20 +533,20 @@ void *rh_alloc_fixed(rh_info_t * info, void *start, int size, const char *owner)
 	e = e & ~m;

 	if (assure_empty(info, 2) < 0)
-		return ERR_PTR(-ENOMEM);
+		return (unsigned long) -ENOMEM;

 	blk = NULL;
 	list_for_each(l, &info->free_list) {
 		blk = list_entry(l, rh_block_t, list);
 		/* The range must lie entirely inside one free block */
-		bs = (unsigned long)blk->start;
-		be = (unsigned long)blk->start + blk->size;
+		bs = blk->start;
+		be = blk->start + blk->size;
 		if (s >= bs && e <= be)
 			break;
 	}

 	if (blk == NULL)
-		return ERR_PTR(-ENOMEM);
+		return (unsigned long) -ENOMEM;

 	/* Perfect fit */
 	if (bs == s && be == e) {
@@ -551,7 +564,7 @@ void *rh_alloc_fixed(rh_info_t * info, void *start, int size, const char *owner)
 	/* blk still in free list, with updated start and/or size */
 	if (bs == s || be == e) {
 		if (bs == s)
-			blk->start = (int8_t *)blk->start + size;
+			blk->start += size;
 		blk->size -= size;

 	} else {
@@ -560,14 +573,14 @@ void *rh_alloc_fixed(rh_info_t * info, void *start, int size, const char *owner)

 		/* The back free fragment */
 		newblk2 = get_slot(info);
-		newblk2->start = (void *)e;
+		newblk2->start = e;
 		newblk2->size = be - e;

 		list_add(&newblk2->list, &blk->list);
 	}

 	newblk1 = get_slot(info);
-	newblk1->start = (void *)s;
+	newblk1->start = s;
 	newblk1->size = e - s;
 	newblk1->owner = owner;

@@ -577,7 +590,11 @@ void *rh_alloc_fixed(rh_info_t * info, void *start, int size, const char *owner)
 	return start;
 }

-int rh_free(rh_info_t * info, void *start)
+/* Deallocate the memory previously allocated by one of the rh_alloc functions.
+ * The return value is the size of the deallocated block, or a negative number
+ * if there is an error.
+ */
+int rh_free(rh_info_t * info, unsigned long start)
 {
 	rh_block_t *blk, *blk2;
 	struct list_head *l;
@@ -642,7 +659,7 @@ int rh_get_stats(rh_info_t * info, int what, int max_stats, rh_stats_t * stats)
 	return nr;
 }

-int rh_set_owner(rh_info_t * info, void *start, const char *owner)
+int rh_set_owner(rh_info_t * info, unsigned long start, const char *owner)
 {
 	rh_block_t *blk, *blk2;
 	struct list_head *l;
@@ -684,8 +701,8 @@ void rh_dump(rh_info_t * info)
 		nr = maxnr;
 	for (i = 0; i < nr; i++)
 		printk(KERN_INFO
-		       "    0x%p-0x%p (%u)\n",
-		       st[i].start, (int8_t *) st[i].start + st[i].size,
+		       "    0x%lx-0x%lx (%u)\n",
+		       st[i].start, st[i].start + st[i].size,
 		       st[i].size);
 	printk(KERN_INFO "\n");

@@ -695,8 +712,8 @@ void rh_dump(rh_info_t * info)
 		nr = maxnr;
 	for (i = 0; i < nr; i++)
 		printk(KERN_INFO
-		       "    0x%p-0x%p (%u) %s\n",
-		       st[i].start, (int8_t *) st[i].start + st[i].size,
+		       "    0x%lx-0x%lx (%u) %s\n",
+		       st[i].start, st[i].start + st[i].size,
 		       st[i].size, st[i].owner != NULL ? st[i].owner : "");
 	printk(KERN_INFO "\n");
 }
@@ -704,6 +721,6 @@ void rh_dump(rh_info_t * info)
 void rh_dump_blk(rh_info_t * info, rh_block_t * blk)
 {
 	printk(KERN_INFO
-	       "blk @0x%p: 0x%p-0x%p (%u)\n",
-	       blk, blk->start, (int8_t *) blk->start + blk->size, blk->size);
+	       "blk @0x%p: 0x%lx-0x%lx (%u)\n",
+	       blk, blk->start, blk->start + blk->size, blk->size);
 }
diff --git a/arch/powerpc/sysdev/commproc.c b/arch/powerpc/sysdev/commproc.c
index 9b4fafd..4f67b89 100644
--- a/arch/powerpc/sysdev/commproc.c
+++ b/arch/powerpc/sysdev/commproc.c
@@ -330,7 +330,7 @@ void m8xx_cpm_dpinit(void)
 	 * with the processor and the microcode patches applied / activated.
 	 * But the following should be at least safe.
 	 */
-	rh_attach_region(&cpm_dpmem_info, (void *)CPM_DATAONLY_BASE, CPM_DATAONLY_SIZE);
+	rh_attach_region(&cpm_dpmem_info, CPM_DATAONLY_BASE, CPM_DATAONLY_SIZE);
 }

 /*
@@ -338,9 +338,9 @@ void m8xx_cpm_dpinit(void)
  * This function returns an offset into the DPRAM area.
  * Use cpm_dpram_addr() to get the virtual address of the area.
  */
-uint cpm_dpalloc(uint size, uint align)
+unsigned long cpm_dpalloc(uint size, uint align)
 {
-	void *start;
+	unsigned long start;
 	unsigned long flags;

 	spin_lock_irqsave(&cpm_dpmem_lock, flags);
@@ -352,30 +352,30 @@ uint cpm_dpalloc(uint size, uint align)
 }
 EXPORT_SYMBOL(cpm_dpalloc);

-int cpm_dpfree(uint offset)
+int cpm_dpfree(unsigned long offset)
 {
 	int ret;
 	unsigned long flags;

 	spin_lock_irqsave(&cpm_dpmem_lock, flags);
-	ret = rh_free(&cpm_dpmem_info, (void *)offset);
+	ret = rh_free(&cpm_dpmem_info, offset);
 	spin_unlock_irqrestore(&cpm_dpmem_lock, flags);

 	return ret;
 }
 EXPORT_SYMBOL(cpm_dpfree);

-uint cpm_dpalloc_fixed(uint offset, uint size, uint align)
+unsigned long cpm_dpalloc_fixed(unsigned long offset, uint size, uint align)
 {
-	void *start;
+	unsigned long start;
 	unsigned long flags;

 	spin_lock_irqsave(&cpm_dpmem_lock, flags);
 	cpm_dpmem_info.alignment = align;
-	start = rh_alloc_fixed(&cpm_dpmem_info, (void *)offset, size, "commproc");
+	start = rh_alloc_fixed(&cpm_dpmem_info, offset, size, "commproc");
 	spin_unlock_irqrestore(&cpm_dpmem_lock, flags);

-	return (uint)start;
+	return start;
 }
 EXPORT_SYMBOL(cpm_dpalloc_fixed);

@@ -385,7 +385,7 @@ void cpm_dpdump(void)
 }
 EXPORT_SYMBOL(cpm_dpdump);

-void *cpm_dpram_addr(uint offset)
+void *cpm_dpram_addr(unsigned long offset)
 {
 	return (void *)(dpram_vbase + offset);
 }
diff --git a/arch/powerpc/sysdev/cpm2_common.c b/arch/powerpc/sysdev/cpm2_common.c
index ec26599..9244129 100644
--- a/arch/powerpc/sysdev/cpm2_common.c
+++ b/arch/powerpc/sysdev/cpm2_common.c
@@ -248,15 +248,14 @@ static void cpm2_dpinit(void)
 	 * varies with the processor and the microcode patches activated.
 	 * But the following should be at least safe.
 	 */
-	rh_attach_region(&cpm_dpmem_info, (void *)CPM_DATAONLY_BASE,
-			CPM_DATAONLY_SIZE);
+	rh_attach_region(&cpm_dpmem_info, CPM_DATAONLY_BASE, CPM_DATAONLY_SIZE);
 }

 /* This function returns an index into the DPRAM area.
  */
-uint cpm_dpalloc(uint size, uint align)
+unsigned long cpm_dpalloc(uint size, uint align)
 {
-	void *start;
+	unsigned long start;
 	unsigned long flags;

 	spin_lock_irqsave(&cpm_dpmem_lock, flags);
@@ -268,13 +267,13 @@ uint cpm_dpalloc(uint size, uint align)
 }
 EXPORT_SYMBOL(cpm_dpalloc);

-int cpm_dpfree(uint offset)
+int cpm_dpfree(unsigned long offset)
 {
 	int ret;
 	unsigned long flags;

 	spin_lock_irqsave(&cpm_dpmem_lock, flags);
-	ret = rh_free(&cpm_dpmem_info, (void *)offset);
+	ret = rh_free(&cpm_dpmem_info, offset);
 	spin_unlock_irqrestore(&cpm_dpmem_lock, flags);

 	return ret;
@@ -282,17 +281,17 @@ int cpm_dpfree(uint offset)
 EXPORT_SYMBOL(cpm_dpfree);

 /* not sure if this is ever needed */
-uint cpm_dpalloc_fixed(uint offset, uint size, uint align)
+unsigned long cpm_dpalloc_fixed(unsigned long offset, uint size, uint align)
 {
-	void *start;
+	unsigned long start;
 	unsigned long flags;

 	spin_lock_irqsave(&cpm_dpmem_lock, flags);
 	cpm_dpmem_info.alignment = align;
-	start = rh_alloc_fixed(&cpm_dpmem_info, (void *)offset, size, "commproc");
+	start = rh_alloc_fixed(&cpm_dpmem_info, offset, size, "commproc");
 	spin_unlock_irqrestore(&cpm_dpmem_lock, flags);

-	return (uint)start;
+	return start;
 }
 EXPORT_SYMBOL(cpm_dpalloc_fixed);

@@ -302,7 +301,7 @@ void cpm_dpdump(void)
 }
 EXPORT_SYMBOL(cpm_dpdump);

-void *cpm_dpram_addr(uint offset)
+void *cpm_dpram_addr(unsigned long offset)
 {
 	return (void *)(im_dprambase + offset);
 }
diff --git a/arch/powerpc/sysdev/qe_lib/qe.c b/arch/powerpc/sysdev/qe_lib/qe.c
index 7f4c075..90f8740 100644
--- a/arch/powerpc/sysdev/qe_lib/qe.c
+++ b/arch/powerpc/sysdev/qe_lib/qe.c
@@ -244,7 +244,7 @@ EXPORT_SYMBOL(qe_put_snum);
 static int qe_sdma_init(void)
 {
 	struct sdma *sdma = &qe_immr->sdma;
-	u32 sdma_buf_offset;
+	unsigned long sdma_buf_offset;

 	if (!sdma)
 		return -ENODEV;
@@ -252,10 +252,10 @@ static int qe_sdma_init(void)
 	/* allocate 2 internal temporary buffers (512 bytes size each) for
 	 * the SDMA */
  	sdma_buf_offset = qe_muram_alloc(512 * 2, 4096);
-	if (IS_MURAM_ERR(sdma_buf_offset))
+	if (IS_ERR_VALUE(sdma_buf_offset))
 		return -ENOMEM;

-	out_be32(&sdma->sdebcr, sdma_buf_offset & QE_SDEBCR_BA_MASK);
+	out_be32(&sdma->sdebcr, (u32) sdma_buf_offset & QE_SDEBCR_BA_MASK);
  	out_be32(&sdma->sdmr, (QE_SDMR_GLB_1_MSK |
  					(0x1 << QE_SDMR_CEN_SHIFT)));

@@ -291,33 +291,32 @@ static void qe_muram_init(void)
 	if ((np = of_find_node_by_name(NULL, "data-only")) != NULL) {
 		address = *of_get_address(np, 0, &size, &flags);
 		of_node_put(np);
-		rh_attach_region(&qe_muram_info,
-			(void *)address, (int)size);
+		rh_attach_region(&qe_muram_info, address, (int) size);
 	}
 }

 /* This function returns an index into the MURAM area.
  */
-u32 qe_muram_alloc(u32 size, u32 align)
+unsigned long qe_muram_alloc(int size, int align)
 {
-	void *start;
+	unsigned long start;
 	unsigned long flags;

 	spin_lock_irqsave(&qe_muram_lock, flags);
 	start = rh_alloc_align(&qe_muram_info, size, align, "QE");
 	spin_unlock_irqrestore(&qe_muram_lock, flags);

-	return (u32) start;
+	return start;
 }
 EXPORT_SYMBOL(qe_muram_alloc);

-int qe_muram_free(u32 offset)
+int qe_muram_free(unsigned long offset)
 {
 	int ret;
 	unsigned long flags;

 	spin_lock_irqsave(&qe_muram_lock, flags);
-	ret = rh_free(&qe_muram_info, (void *)offset);
+	ret = rh_free(&qe_muram_info, offset);
 	spin_unlock_irqrestore(&qe_muram_lock, flags);

 	return ret;
@@ -325,16 +324,16 @@ int qe_muram_free(u32 offset)
 EXPORT_SYMBOL(qe_muram_free);

 /* not sure if this is ever needed */
-u32 qe_muram_alloc_fixed(u32 offset, u32 size)
+unsigned long qe_muram_alloc_fixed(unsigned long offset, int size)
 {
-	void *start;
+	unsigned long start;
 	unsigned long flags;

 	spin_lock_irqsave(&qe_muram_lock, flags);
-	start = rh_alloc_fixed(&qe_muram_info, (void *)offset, size, "commproc");
+	start = rh_alloc_fixed(&qe_muram_info, offset, size, "commproc");
 	spin_unlock_irqrestore(&qe_muram_lock, flags);

-	return (u32) start;
+	return start;
 }
 EXPORT_SYMBOL(qe_muram_alloc_fixed);

@@ -344,7 +343,7 @@ void qe_muram_dump(void)
 }
 EXPORT_SYMBOL(qe_muram_dump);

-void *qe_muram_addr(u32 offset)
+void *qe_muram_addr(unsigned long offset)
 {
 	return (void *)&qe_immr->muram[offset];
 }
diff --git a/arch/powerpc/sysdev/qe_lib/ucc_fast.c b/arch/powerpc/sysdev/qe_lib/ucc_fast.c
index 66137bf..9143236 100644
--- a/arch/powerpc/sysdev/qe_lib/ucc_fast.c
+++ b/arch/powerpc/sysdev/qe_lib/ucc_fast.c
@@ -18,6 +18,7 @@
 #include <linux/slab.h>
 #include <linux/stddef.h>
 #include <linux/interrupt.h>
+#include <linux/err.h>

 #include <asm/io.h>
 #include <asm/immap_qe.h>
@@ -268,7 +269,7 @@ int ucc_fast_init(struct ucc_fast_info * uf_info, struct ucc_fast_private ** ucc
 	/* Allocate memory for Tx Virtual Fifo */
 	uccf->ucc_fast_tx_virtual_fifo_base_offset =
 	    qe_muram_alloc(uf_info->utfs, UCC_FAST_VIRT_FIFO_REGS_ALIGNMENT);
-	if (IS_MURAM_ERR(uccf->ucc_fast_tx_virtual_fifo_base_offset)) {
+	if (IS_ERR_VALUE(uccf->ucc_fast_tx_virtual_fifo_base_offset)) {
 		printk(KERN_ERR "%s: cannot allocate MURAM for TX FIFO", __FUNCTION__);
 		uccf->ucc_fast_tx_virtual_fifo_base_offset = 0;
 		ucc_fast_free(uccf);
@@ -280,7 +281,7 @@ int ucc_fast_init(struct ucc_fast_info * uf_info, struct ucc_fast_private ** ucc
 		qe_muram_alloc(uf_info->urfs +
 			   UCC_FAST_RECEIVE_VIRTUAL_FIFO_SIZE_FUDGE_FACTOR,
 			   UCC_FAST_VIRT_FIFO_REGS_ALIGNMENT);
-	if (IS_MURAM_ERR(uccf->ucc_fast_rx_virtual_fifo_base_offset)) {
+	if (IS_ERR_VALUE(uccf->ucc_fast_rx_virtual_fifo_base_offset)) {
 		printk(KERN_ERR "%s: cannot allocate MURAM for RX FIFO", __FUNCTION__);
 		uccf->ucc_fast_rx_virtual_fifo_base_offset = 0;
 		ucc_fast_free(uccf);
diff --git a/arch/powerpc/sysdev/qe_lib/ucc_slow.c b/arch/powerpc/sysdev/qe_lib/ucc_slow.c
index b930d68..1f65c26 100644
--- a/arch/powerpc/sysdev/qe_lib/ucc_slow.c
+++ b/arch/powerpc/sysdev/qe_lib/ucc_slow.c
@@ -18,6 +18,7 @@
 #include <linux/slab.h>
 #include <linux/stddef.h>
 #include <linux/interrupt.h>
+#include <linux/err.h>

 #include <asm/io.h>
 #include <asm/immap_qe.h>
@@ -175,7 +176,7 @@ int ucc_slow_init(struct ucc_slow_info * us_info, struct ucc_slow_private ** ucc
 	/* Get PRAM base */
 	uccs->us_pram_offset =
 		qe_muram_alloc(UCC_SLOW_PRAM_SIZE, ALIGNMENT_OF_UCC_SLOW_PRAM);
-	if (IS_MURAM_ERR(uccs->us_pram_offset)) {
+	if (IS_ERR_VALUE(uccs->us_pram_offset)) {
 		printk(KERN_ERR "%s: cannot allocate MURAM for PRAM", __FUNCTION__);
 		ucc_slow_free(uccs);
 		return -ENOMEM;
@@ -210,7 +211,7 @@ int ucc_slow_init(struct ucc_slow_info * us_info, struct ucc_slow_private ** ucc
 	uccs->rx_base_offset =
 		qe_muram_alloc(us_info->rx_bd_ring_len * sizeof(struct qe_bd),
 				QE_ALIGNMENT_OF_BD);
-	if (IS_MURAM_ERR(uccs->rx_base_offset)) {
+	if (IS_ERR_VALUE(uccs->rx_base_offset)) {
 		printk(KERN_ERR "%s: cannot allocate RX BDs", __FUNCTION__);
 		uccs->rx_base_offset = 0;
 		ucc_slow_free(uccs);
@@ -220,7 +221,7 @@ int ucc_slow_init(struct ucc_slow_info * us_info, struct ucc_slow_private ** ucc
 	uccs->tx_base_offset =
 		qe_muram_alloc(us_info->tx_bd_ring_len * sizeof(struct qe_bd),
 			QE_ALIGNMENT_OF_BD);
-	if (IS_MURAM_ERR(uccs->tx_base_offset)) {
+	if (IS_ERR_VALUE(uccs->tx_base_offset)) {
 		printk(KERN_ERR "%s: cannot allocate TX BDs", __FUNCTION__);
 		uccs->tx_base_offset = 0;
 		ucc_slow_free(uccs);
diff --git a/arch/ppc/8xx_io/commproc.c b/arch/ppc/8xx_io/commproc.c
index 7a8722b..e2c6210 100644
--- a/arch/ppc/8xx_io/commproc.c
+++ b/arch/ppc/8xx_io/commproc.c
@@ -402,7 +402,7 @@ void m8xx_cpm_dpinit(void)
 	 * with the processor and the microcode patches applied / activated.
 	 * But the following should be at least safe.
 	 */
-	rh_attach_region(&cpm_dpmem_info, (void *)CPM_DATAONLY_BASE, CPM_DATAONLY_SIZE);
+	rh_attach_region(&cpm_dpmem_info, CPM_DATAONLY_BASE, CPM_DATAONLY_SIZE);
 }

 /*
@@ -410,9 +410,9 @@ void m8xx_cpm_dpinit(void)
  * This function returns an offset into the DPRAM area.
  * Use cpm_dpram_addr() to get the virtual address of the area.
  */
-uint cpm_dpalloc(uint size, uint align)
+unsigned long cpm_dpalloc(uint size, uint align)
 {
-	void *start;
+	unsigned long start;
 	unsigned long flags;

 	spin_lock_irqsave(&cpm_dpmem_lock, flags);
@@ -420,34 +420,34 @@ uint cpm_dpalloc(uint size, uint align)
 	start = rh_alloc(&cpm_dpmem_info, size, "commproc");
 	spin_unlock_irqrestore(&cpm_dpmem_lock, flags);

-	return (uint)start;
+	return start;
 }
 EXPORT_SYMBOL(cpm_dpalloc);

-int cpm_dpfree(uint offset)
+int cpm_dpfree(unsigned long offset)
 {
 	int ret;
 	unsigned long flags;

 	spin_lock_irqsave(&cpm_dpmem_lock, flags);
-	ret = rh_free(&cpm_dpmem_info, (void *)offset);
+	ret = rh_free(&cpm_dpmem_info, offset);
 	spin_unlock_irqrestore(&cpm_dpmem_lock, flags);

 	return ret;
 }
 EXPORT_SYMBOL(cpm_dpfree);

-uint cpm_dpalloc_fixed(uint offset, uint size, uint align)
+unsigned long cpm_dpalloc_fixed(unsigned long offset, uint size, uint align)
 {
-	void *start;
+	unsigned long start;
 	unsigned long flags;

 	spin_lock_irqsave(&cpm_dpmem_lock, flags);
 	cpm_dpmem_info.alignment = align;
-	start = rh_alloc_fixed(&cpm_dpmem_info, (void *)offset, size, "commproc");
+	start = rh_alloc_fixed(&cpm_dpmem_info, offset, size, "commproc");
 	spin_unlock_irqrestore(&cpm_dpmem_lock, flags);

-	return (uint)start;
+	return start;
 }
 EXPORT_SYMBOL(cpm_dpalloc_fixed);

@@ -457,7 +457,7 @@ void cpm_dpdump(void)
 }
 EXPORT_SYMBOL(cpm_dpdump);

-void *cpm_dpram_addr(uint offset)
+void *cpm_dpram_addr(unsigned long offset)
 {
 	return ((immap_t *)IMAP_ADDR)->im_cpm.cp_dpmem + offset;
 }
diff --git a/arch/ppc/lib/rheap.c b/arch/ppc/lib/rheap.c
index d407007..9dc2f34 100644
--- a/arch/ppc/lib/rheap.c
+++ b/arch/ppc/lib/rheap.c
@@ -132,7 +132,7 @@ static rh_block_t *get_slot(rh_info_t * info)
 	info->empty_slots--;

 	/* Initialize */
-	blk->start = NULL;
+	blk->start = 0;
 	blk->size = 0;
 	blk->owner = NULL;

@@ -157,7 +157,7 @@ static void attach_free_block(rh_info_t * info, rh_block_t * blkn)

 	/* We assume that they are aligned properly */
 	size = blkn->size;
-	s = (unsigned long)blkn->start;
+	s = blkn->start;
 	e = s + size;

 	/* Find the blocks immediately before and after the given one
@@ -169,7 +169,7 @@ static void attach_free_block(rh_info_t * info, rh_block_t * blkn)
 	list_for_each(l, &info->free_list) {
 		blk = list_entry(l, rh_block_t, list);

-		bs = (unsigned long)blk->start;
+		bs = blk->start;
 		be = bs + blk->size;

 		if (next == NULL && s >= bs)
@@ -187,10 +187,10 @@ static void attach_free_block(rh_info_t * info, rh_block_t * blkn)
 	}

 	/* Now check if they are really adjacent */
-	if (before != NULL && s != (unsigned long)before->start + before->size)
+	if (before && s != (before->start + before->size))
 		before = NULL;

-	if (after != NULL && e != (unsigned long)after->start)
+	if (after && e != after->start)
 		after = NULL;

 	/* No coalescing; list insert and return */
@@ -215,7 +215,7 @@ static void attach_free_block(rh_info_t * info, rh_block_t * blkn)

 	/* Grow the after block backwards */
 	if (before == NULL && after != NULL) {
-		after->start = (int8_t *)after->start - size;
+		after->start -= size;
 		after->size += size;
 		return;
 	}
@@ -320,14 +320,14 @@ void rh_init(rh_info_t * info, unsigned int alignment, int max_blocks,
 }

 /* Attach a free memory region, coalesces regions if adjuscent */
-int rh_attach_region(rh_info_t * info, void *start, int size)
+int rh_attach_region(rh_info_t * info, unsigned long start, int size)
 {
 	rh_block_t *blk;
 	unsigned long s, e, m;
 	int r;

 	/* The region must be aligned */
-	s = (unsigned long)start;
+	s = start;
 	e = s + size;
 	m = info->alignment - 1;

@@ -337,9 +337,12 @@ int rh_attach_region(rh_info_t * info, void *start, int size)
 	/* Round end down */
 	e = e & ~m;

+	if (IS_ERR_VALUE(e) || (e < s))
+		return -ERANGE;
+
 	/* Take final values */
-	start = (void *)s;
-	size = (int)(e - s);
+	start = s;
+	size = e - s;

 	/* Grow the blocks, if needed */
 	r = assure_empty(info, 1);
@@ -357,7 +360,7 @@ int rh_attach_region(rh_info_t * info, void *start, int size)
 }

 /* Detatch given address range, splits free block if needed. */
-void *rh_detach_region(rh_info_t * info, void *start, int size)
+unsigned long rh_detach_region(rh_info_t * info, unsigned long start, int size)
 {
 	struct list_head *l;
 	rh_block_t *blk, *newblk;
@@ -365,10 +368,10 @@ void *rh_detach_region(rh_info_t * info, void *start, int size)

 	/* Validate size */
 	if (size <= 0)
-		return ERR_PTR(-EINVAL);
+		return (unsigned long) -EINVAL;

 	/* The region must be aligned */
-	s = (unsigned long)start;
+	s = start;
 	e = s + size;
 	m = info->alignment - 1;

@@ -379,34 +382,34 @@ void *rh_detach_region(rh_info_t * info, void *start, int size)
 	e = e & ~m;

 	if (assure_empty(info, 1) < 0)
-		return ERR_PTR(-ENOMEM);
+		return (unsigned long) -ENOMEM;

 	blk = NULL;
 	list_for_each(l, &info->free_list) {
 		blk = list_entry(l, rh_block_t, list);
 		/* The range must lie entirely inside one free block */
-		bs = (unsigned long)blk->start;
-		be = (unsigned long)blk->start + blk->size;
+		bs = blk->start;
+		be = blk->start + blk->size;
 		if (s >= bs && e <= be)
 			break;
 		blk = NULL;
 	}

 	if (blk == NULL)
-		return ERR_PTR(-ENOMEM);
+		return (unsigned long) -ENOMEM;

 	/* Perfect fit */
 	if (bs == s && be == e) {
 		/* Delete from free list, release slot */
 		list_del(&blk->list);
 		release_slot(info, blk);
-		return (void *)s;
+		return s;
 	}

 	/* blk still in free list, with updated start and/or size */
 	if (bs == s || be == e) {
 		if (bs == s)
-			blk->start = (int8_t *)blk->start + size;
+			blk->start += size;
 		blk->size -= size;

 	} else {
@@ -415,31 +418,31 @@ void *rh_detach_region(rh_info_t * info, void *start, int size)

 		/* the back free fragment */
 		newblk = get_slot(info);
-		newblk->start = (void *)e;
+		newblk->start = e;
 		newblk->size = be - e;

 		list_add(&newblk->list, &blk->list);
 	}

-	return (void *)s;
+	return s;
 }

-void *rh_alloc(rh_info_t * info, int size, const char *owner)
+unsigned long rh_alloc(rh_info_t * info, int size, const char *owner)
 {
 	struct list_head *l;
 	rh_block_t *blk;
 	rh_block_t *newblk;
-	void *start;
+	unsigned long start;

 	/* Validate size */
 	if (size <= 0)
-		return ERR_PTR(-EINVAL);
+		return (unsigned long) -EINVAL;

 	/* Align to configured alignment */
 	size = (size + (info->alignment - 1)) & ~(info->alignment - 1);

 	if (assure_empty(info, 1) < 0)
-		return ERR_PTR(-ENOMEM);
+		return (unsigned long) -ENOMEM;

 	blk = NULL;
 	list_for_each(l, &info->free_list) {
@@ -450,7 +453,7 @@ void *rh_alloc(rh_info_t * info, int size, const char *owner)
 	}

 	if (blk == NULL)
-		return ERR_PTR(-ENOMEM);
+		return (unsigned long) -ENOMEM;

 	/* Just fits */
 	if (blk->size == size) {
@@ -470,7 +473,7 @@ void *rh_alloc(rh_info_t * info, int size, const char *owner)
 	newblk->owner = owner;

 	/* blk still in free list, with updated start, size */
-	blk->start = (int8_t *)blk->start + size;
+	blk->start += size;
 	blk->size -= size;

 	start = newblk->start;
@@ -481,18 +484,18 @@ void *rh_alloc(rh_info_t * info, int size, const char *owner)
 }

 /* allocate at precisely the given address */
-void *rh_alloc_fixed(rh_info_t * info, void *start, int size, const char *owner)
+unsigned long rh_alloc_fixed(rh_info_t * info, unsigned long start, int size, const char *owner)
 {
 	struct list_head *l;
 	rh_block_t *blk, *newblk1, *newblk2;
-	unsigned long s, e, m, bs, be;
+	unsigned long s, e, m, bs=0, be=0;

 	/* Validate size */
 	if (size <= 0)
-		return ERR_PTR(-EINVAL);
+		return (unsigned long) -EINVAL;

 	/* The region must be aligned */
-	s = (unsigned long)start;
+	s = start;
 	e = s + size;
 	m = info->alignment - 1;

@@ -503,20 +506,20 @@ void *rh_alloc_fixed(rh_info_t * info, void *start, int size, const char *owner)
 	e = e & ~m;

 	if (assure_empty(info, 2) < 0)
-		return ERR_PTR(-ENOMEM);
+		return (unsigned long) -ENOMEM;

 	blk = NULL;
 	list_for_each(l, &info->free_list) {
 		blk = list_entry(l, rh_block_t, list);
 		/* The range must lie entirely inside one free block */
-		bs = (unsigned long)blk->start;
-		be = (unsigned long)blk->start + blk->size;
+		bs = blk->start;
+		be = blk->start + blk->size;
 		if (s >= bs && e <= be)
 			break;
 	}

 	if (blk == NULL)
-		return ERR_PTR(-ENOMEM);
+		return (unsigned long) -ENOMEM;

 	/* Perfect fit */
 	if (bs == s && be == e) {
@@ -534,7 +537,7 @@ void *rh_alloc_fixed(rh_info_t * info, void *start, int size, const char *owner)
 	/* blk still in free list, with updated start and/or size */
 	if (bs == s || be == e) {
 		if (bs == s)
-			blk->start = (int8_t *)blk->start + size;
+			blk->start += size;
 		blk->size -= size;

 	} else {
@@ -543,14 +546,14 @@ void *rh_alloc_fixed(rh_info_t * info, void *start, int size, const char *owner)

 		/* The back free fragment */
 		newblk2 = get_slot(info);
-		newblk2->start = (void *)e;
+		newblk2->start = e;
 		newblk2->size = be - e;

 		list_add(&newblk2->list, &blk->list);
 	}

 	newblk1 = get_slot(info);
-	newblk1->start = (void *)s;
+	newblk1->start = s;
 	newblk1->size = e - s;
 	newblk1->owner = owner;

@@ -560,7 +563,7 @@ void *rh_alloc_fixed(rh_info_t * info, void *start, int size, const char *owner)
 	return start;
 }

-int rh_free(rh_info_t * info, void *start)
+int rh_free(rh_info_t * info, unsigned long start)
 {
 	rh_block_t *blk, *blk2;
 	struct list_head *l;
@@ -625,7 +628,7 @@ int rh_get_stats(rh_info_t * info, int what, int max_stats, rh_stats_t * stats)
 	return nr;
 }

-int rh_set_owner(rh_info_t * info, void *start, const char *owner)
+int rh_set_owner(rh_info_t * info, unsigned long start, const char *owner)
 {
 	rh_block_t *blk, *blk2;
 	struct list_head *l;
@@ -667,8 +670,8 @@ void rh_dump(rh_info_t * info)
 		nr = maxnr;
 	for (i = 0; i < nr; i++)
 		printk(KERN_INFO
-		       "    0x%p-0x%p (%u)\n",
-		       st[i].start, (int8_t *) st[i].start + st[i].size,
+		       "    0x%lx-0x%lx (%u)\n",
+		       st[i].start, st[i].start + st[i].size,
 		       st[i].size);
 	printk(KERN_INFO "\n");

@@ -678,8 +681,8 @@ void rh_dump(rh_info_t * info)
 		nr = maxnr;
 	for (i = 0; i < nr; i++)
 		printk(KERN_INFO
-		       "    0x%p-0x%p (%u) %s\n",
-		       st[i].start, (int8_t *) st[i].start + st[i].size,
+		       "    0x%lx-0x%lx (%u) %s\n",
+		       st[i].start, st[i].start + st[i].size,
 		       st[i].size, st[i].owner != NULL ? st[i].owner : "");
 	printk(KERN_INFO "\n");
 }
@@ -687,6 +690,6 @@ void rh_dump(rh_info_t * info)
 void rh_dump_blk(rh_info_t * info, rh_block_t * blk)
 {
 	printk(KERN_INFO
-	       "blk @0x%p: 0x%p-0x%p (%u)\n",
-	       blk, blk->start, (int8_t *) blk->start + blk->size, blk->size);
+	       "blk @0x%p: 0x%lx-0x%lx (%u)\n",
+	       blk, blk->start, blk->start + blk->size, blk->size);
 }
diff --git a/arch/ppc/syslib/cpm2_common.c b/arch/ppc/syslib/cpm2_common.c
index cbac44b..6cd859d 100644
--- a/arch/ppc/syslib/cpm2_common.c
+++ b/arch/ppc/syslib/cpm2_common.c
@@ -136,15 +136,14 @@ static void cpm2_dpinit(void)
 	 * varies with the processor and the microcode patches activated.
 	 * But the following should be at least safe.
 	 */
-	rh_attach_region(&cpm_dpmem_info, (void *)CPM_DATAONLY_BASE,
-			CPM_DATAONLY_SIZE);
+	rh_attach_region(&cpm_dpmem_info, CPM_DATAONLY_BASE, CPM_DATAONLY_SIZE);
 }

 /* This function returns an index into the DPRAM area.
  */
-uint cpm_dpalloc(uint size, uint align)
+unsigned long cpm_dpalloc(uint size, uint align)
 {
-	void *start;
+	unsigned long start;
 	unsigned long flags;

 	spin_lock_irqsave(&cpm_dpmem_lock, flags);
@@ -152,17 +151,17 @@ uint cpm_dpalloc(uint size, uint align)
 	start = rh_alloc(&cpm_dpmem_info, size, "commproc");
 	spin_unlock_irqrestore(&cpm_dpmem_lock, flags);

-	return (uint)start;
+	return start;
 }
 EXPORT_SYMBOL(cpm_dpalloc);

-int cpm_dpfree(uint offset)
+int cpm_dpfree(unsigned long offset)
 {
 	int ret;
 	unsigned long flags;

 	spin_lock_irqsave(&cpm_dpmem_lock, flags);
-	ret = rh_free(&cpm_dpmem_info, (void *)offset);
+	ret = rh_free(&cpm_dpmem_info, offset);
 	spin_unlock_irqrestore(&cpm_dpmem_lock, flags);

 	return ret;
@@ -170,17 +169,17 @@ int cpm_dpfree(uint offset)
 EXPORT_SYMBOL(cpm_dpfree);

 /* not sure if this is ever needed */
-uint cpm_dpalloc_fixed(uint offset, uint size, uint align)
+unsigned long cpm_dpalloc_fixed(unsigned long offset, uint size, uint align)
 {
-	void *start;
+	unsigned long start;
 	unsigned long flags;

 	spin_lock_irqsave(&cpm_dpmem_lock, flags);
 	cpm_dpmem_info.alignment = align;
-	start = rh_alloc_fixed(&cpm_dpmem_info, (void *)offset, size, "commproc");
+	start = rh_alloc_fixed(&cpm_dpmem_info, offset, size, "commproc");
 	spin_unlock_irqrestore(&cpm_dpmem_lock, flags);

-	return (uint)start;
+	return start;
 }
 EXPORT_SYMBOL(cpm_dpalloc_fixed);

@@ -190,7 +189,7 @@ void cpm_dpdump(void)
 }
 EXPORT_SYMBOL(cpm_dpdump);

-void *cpm_dpram_addr(uint offset)
+void *cpm_dpram_addr(unsigned long offset)
 {
 	return (void *)&cpm2_immr->im_dprambase[offset];
 }
diff --git a/drivers/net/fs_enet/mac-scc.c b/drivers/net/fs_enet/mac-scc.c
index d0f2898..7540966 100644
--- a/drivers/net/fs_enet/mac-scc.c
+++ b/drivers/net/fs_enet/mac-scc.c
@@ -167,7 +167,7 @@ static int allocate_bd(struct net_device *dev)

 	fep->ring_mem_addr = cpm_dpalloc((fpi->tx_ring + fpi->rx_ring) *
 					 sizeof(cbd_t), 8);
-	if (IS_DPERR(fep->ring_mem_addr))
+	if (IS_ERR_VALUE(fep->ring_mem_addr))
 		return -ENOMEM;

 	fep->ring_base = cpm_dpram_addr(fep->ring_mem_addr);
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index d7aff81..0f66765 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -293,7 +293,7 @@ static int fill_init_enet_entries(struct ucc_geth_private *ugeth,
 		else {
 			init_enet_offset =
 			    qe_muram_alloc(thread_size, thread_alignment);
-			if (IS_MURAM_ERR(init_enet_offset)) {
+			if (IS_ERR_VALUE(init_enet_offset)) {
 				ugeth_err
 		("fill_init_enet_entries: Can not allocate DPRAM memory.");
 				qe_put_snum((u8) snum);
@@ -2594,7 +2594,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			ugeth->tx_bd_ring_offset[j] =
 			    qe_muram_alloc(length,
 					   UCC_GETH_TX_BD_RING_ALIGNMENT);
-			if (!IS_MURAM_ERR(ugeth->tx_bd_ring_offset[j]))
+			if (!IS_ERR_VALUE(ugeth->tx_bd_ring_offset[j]))
 				ugeth->p_tx_bd_ring[j] =
 				    (u8 *) qe_muram_addr(ugeth->
 							 tx_bd_ring_offset[j]);
@@ -2629,7 +2629,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			ugeth->rx_bd_ring_offset[j] =
 			    qe_muram_alloc(length,
 					   UCC_GETH_RX_BD_RING_ALIGNMENT);
-			if (!IS_MURAM_ERR(ugeth->rx_bd_ring_offset[j]))
+			if (!IS_ERR_VALUE(ugeth->rx_bd_ring_offset[j]))
 				ugeth->p_rx_bd_ring[j] =
 				    (u8 *) qe_muram_addr(ugeth->
 							 rx_bd_ring_offset[j]);
@@ -2713,7 +2713,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	ugeth->tx_glbl_pram_offset =
 	    qe_muram_alloc(sizeof(struct ucc_geth_tx_global_pram),
 			   UCC_GETH_TX_GLOBAL_PRAM_ALIGNMENT);
-	if (IS_MURAM_ERR(ugeth->tx_glbl_pram_offset)) {
+	if (IS_ERR_VALUE(ugeth->tx_glbl_pram_offset)) {
 		ugeth_err
 		    ("%s: Can not allocate DPRAM memory for p_tx_glbl_pram.",
 		     __FUNCTION__);
@@ -2735,7 +2735,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			   sizeof(struct ucc_geth_thread_data_tx) +
 			   32 * (numThreadsTxNumerical == 1),
 			   UCC_GETH_THREAD_DATA_ALIGNMENT);
-	if (IS_MURAM_ERR(ugeth->thread_dat_tx_offset)) {
+	if (IS_ERR_VALUE(ugeth->thread_dat_tx_offset)) {
 		ugeth_err
 		    ("%s: Can not allocate DPRAM memory for p_thread_data_tx.",
 		     __FUNCTION__);
@@ -2763,7 +2763,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	    qe_muram_alloc(ug_info->numQueuesTx *
 			   sizeof(struct ucc_geth_send_queue_qd),
 			   UCC_GETH_SEND_QUEUE_QUEUE_DESCRIPTOR_ALIGNMENT);
-	if (IS_MURAM_ERR(ugeth->send_q_mem_reg_offset)) {
+	if (IS_ERR_VALUE(ugeth->send_q_mem_reg_offset)) {
 		ugeth_err
 		    ("%s: Can not allocate DPRAM memory for p_send_q_mem_reg.",
 		     __FUNCTION__);
@@ -2806,7 +2806,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		ugeth->scheduler_offset =
 		    qe_muram_alloc(sizeof(struct ucc_geth_scheduler),
 				   UCC_GETH_SCHEDULER_ALIGNMENT);
-		if (IS_MURAM_ERR(ugeth->scheduler_offset)) {
+		if (IS_ERR_VALUE(ugeth->scheduler_offset)) {
 			ugeth_err
 			 ("%s: Can not allocate DPRAM memory for p_scheduler.",
 			     __FUNCTION__);
@@ -2854,7 +2854,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		    qe_muram_alloc(sizeof
 				   (struct ucc_geth_tx_firmware_statistics_pram),
 				   UCC_GETH_TX_STATISTICS_ALIGNMENT);
-		if (IS_MURAM_ERR(ugeth->tx_fw_statistics_pram_offset)) {
+		if (IS_ERR_VALUE(ugeth->tx_fw_statistics_pram_offset)) {
 			ugeth_err
 			    ("%s: Can not allocate DPRAM memory for"
 				" p_tx_fw_statistics_pram.", __FUNCTION__);
@@ -2893,7 +2893,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	ugeth->rx_glbl_pram_offset =
 	    qe_muram_alloc(sizeof(struct ucc_geth_rx_global_pram),
 			   UCC_GETH_RX_GLOBAL_PRAM_ALIGNMENT);
-	if (IS_MURAM_ERR(ugeth->rx_glbl_pram_offset)) {
+	if (IS_ERR_VALUE(ugeth->rx_glbl_pram_offset)) {
 		ugeth_err
 		    ("%s: Can not allocate DPRAM memory for p_rx_glbl_pram.",
 		     __FUNCTION__);
@@ -2914,7 +2914,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	    qe_muram_alloc(numThreadsRxNumerical *
 			   sizeof(struct ucc_geth_thread_data_rx),
 			   UCC_GETH_THREAD_DATA_ALIGNMENT);
-	if (IS_MURAM_ERR(ugeth->thread_dat_rx_offset)) {
+	if (IS_ERR_VALUE(ugeth->thread_dat_rx_offset)) {
 		ugeth_err
 		    ("%s: Can not allocate DPRAM memory for p_thread_data_rx.",
 		     __FUNCTION__);
@@ -2937,7 +2937,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		    qe_muram_alloc(sizeof
 				   (struct ucc_geth_rx_firmware_statistics_pram),
 				   UCC_GETH_RX_STATISTICS_ALIGNMENT);
-		if (IS_MURAM_ERR(ugeth->rx_fw_statistics_pram_offset)) {
+		if (IS_ERR_VALUE(ugeth->rx_fw_statistics_pram_offset)) {
 			ugeth_err
 				("%s: Can not allocate DPRAM memory for"
 				" p_rx_fw_statistics_pram.", __FUNCTION__);
@@ -2959,7 +2959,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	    qe_muram_alloc(ug_info->numQueuesRx *
 			   sizeof(struct ucc_geth_rx_interrupt_coalescing_entry)
 			   + 4, UCC_GETH_RX_INTERRUPT_COALESCING_ALIGNMENT);
-	if (IS_MURAM_ERR(ugeth->rx_irq_coalescing_tbl_offset)) {
+	if (IS_ERR_VALUE(ugeth->rx_irq_coalescing_tbl_offset)) {
 		ugeth_err
 		    ("%s: Can not allocate DPRAM memory for"
 			" p_rx_irq_coalescing_tbl.", __FUNCTION__);
@@ -3027,7 +3027,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			   (sizeof(struct ucc_geth_rx_bd_queues_entry) +
 			    sizeof(struct ucc_geth_rx_prefetched_bds)),
 			   UCC_GETH_RX_BD_QUEUES_ALIGNMENT);
-	if (IS_MURAM_ERR(ugeth->rx_bd_qs_tbl_offset)) {
+	if (IS_ERR_VALUE(ugeth->rx_bd_qs_tbl_offset)) {
 		ugeth_err
 		    ("%s: Can not allocate DPRAM memory for p_rx_bd_qs_tbl.",
 		     __FUNCTION__);
@@ -3116,7 +3116,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		ugeth->exf_glbl_param_offset =
 		    qe_muram_alloc(sizeof(struct ucc_geth_exf_global_pram),
 		UCC_GETH_RX_EXTENDED_FILTERING_GLOBAL_PARAMETERS_ALIGNMENT);
-		if (IS_MURAM_ERR(ugeth->exf_glbl_param_offset)) {
+		if (IS_ERR_VALUE(ugeth->exf_glbl_param_offset)) {
 			ugeth_err
 				("%s: Can not allocate DPRAM memory for"
 				" p_exf_glbl_param.", __FUNCTION__);
@@ -3258,7 +3258,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)

 	/* Allocate InitEnet command parameter structure */
 	init_enet_pram_offset = qe_muram_alloc(sizeof(struct ucc_geth_init_pram), 4);
-	if (IS_MURAM_ERR(init_enet_pram_offset)) {
+	if (IS_ERR_VALUE(init_enet_pram_offset)) {
 		ugeth_err
 		    ("%s: Can not allocate DPRAM memory for p_init_enet_pram.",
 		     __FUNCTION__);
diff --git a/drivers/serial/cpm_uart/cpm_uart_cpm1.c b/drivers/serial/cpm_uart/cpm_uart_cpm1.c
index 925fb60..bb7afe9 100644
--- a/drivers/serial/cpm_uart/cpm_uart_cpm1.c
+++ b/drivers/serial/cpm_uart/cpm_uart_cpm1.c
@@ -125,7 +125,7 @@ int cpm_uart_allocbuf(struct uart_cpm_port *pinfo, unsigned int is_con)
 {
 	int dpmemsz, memsz;
 	u8 *dp_mem;
-	uint dp_offset;
+	unsigned long dp_offset;
 	u8 *mem_addr;
 	dma_addr_t dma_addr = 0;

@@ -133,7 +133,7 @@ int cpm_uart_allocbuf(struct uart_cpm_port *pinfo, unsigned int is_con)

 	dpmemsz = sizeof(cbd_t) * (pinfo->rx_nrfifos + pinfo->tx_nrfifos);
 	dp_offset = cpm_dpalloc(dpmemsz, 8);
-	if (IS_DPERR(dp_offset)) {
+	if (IS_ERR_VALUE(dp_offset)) {
 		printk(KERN_ERR
 		       "cpm_uart_cpm1.c: could not allocate buffer descriptors\n");
 		return -ENOMEM;
diff --git a/drivers/serial/cpm_uart/cpm_uart_cpm2.c b/drivers/serial/cpm_uart/cpm_uart_cpm2.c
index fa45599..1eeea36 100644
--- a/drivers/serial/cpm_uart/cpm_uart_cpm2.c
+++ b/drivers/serial/cpm_uart/cpm_uart_cpm2.c
@@ -222,7 +222,7 @@ int cpm_uart_allocbuf(struct uart_cpm_port *pinfo, unsigned int is_con)
 {
 	int dpmemsz, memsz;
 	u8 *dp_mem;
-	uint dp_offset;
+	unsigned long dp_offset;
 	u8 *mem_addr;
 	dma_addr_t dma_addr = 0;

@@ -230,7 +230,7 @@ int cpm_uart_allocbuf(struct uart_cpm_port *pinfo, unsigned int is_con)

 	dpmemsz = sizeof(cbd_t) * (pinfo->rx_nrfifos + pinfo->tx_nrfifos);
 	dp_offset = cpm_dpalloc(dpmemsz, 8);
-	if (IS_DPERR(dp_offset)) {
+	if (IS_ERR_VALUE(dp_offset)) {
 		printk(KERN_ERR
 		       "cpm_uart_cpm.c: could not allocate buffer descriptors\n");
 		return -ENOMEM;
diff --git a/include/asm-powerpc/qe.h b/include/asm-powerpc/qe.h
index a62168e..9d304b1 100644
--- a/include/asm-powerpc/qe.h
+++ b/include/asm-powerpc/qe.h
@@ -38,11 +38,11 @@ int qe_issue_cmd(u32 cmd, u32 device, u8 mcn_protocol, u32 cmd_input);
 void qe_setbrg(u32 brg, u32 rate);
 int qe_get_snum(void);
 void qe_put_snum(u8 snum);
-u32 qe_muram_alloc(u32 size, u32 align);
-int qe_muram_free(u32 offset);
-u32 qe_muram_alloc_fixed(u32 offset, u32 size);
+unsigned long qe_muram_alloc(int size, int align);
+int qe_muram_free(unsigned long offset);
+unsigned long qe_muram_alloc_fixed(unsigned long offset, int size);
 void qe_muram_dump(void);
-void *qe_muram_addr(u32 offset);
+void *qe_muram_addr(unsigned long offset);

 /* Buffer descriptors */
 struct qe_bd {
@@ -448,10 +448,5 @@ struct ucc_slow_pram {
 #define UCC_FAST_FUNCTION_CODE_DTB_LCL	0x02
 #define UCC_FAST_FUNCTION_CODE_BDB_LCL	0x01

-static inline long IS_MURAM_ERR(const u32 offset)
-{
-	return offset > (u32) - 1000L;
-}
-
 #endif /* __KERNEL__ */
 #endif /* _ASM_POWERPC_QE_H */
diff --git a/include/asm-ppc/commproc.h b/include/asm-ppc/commproc.h
index 4f99df1..3972487 100644
--- a/include/asm-ppc/commproc.h
+++ b/include/asm-ppc/commproc.h
@@ -63,20 +63,15 @@
 #define CPM_DATAONLY_SIZE	((uint)0x0700)
 #define CPM_DP_NOSPACE		((uint)0x7fffffff)

-static inline long IS_DPERR(const uint offset)
-{
-	return (uint)offset > (uint)-1000L;
-}
-
 /* Export the base address of the communication processor registers
  * and dual port ram.
  */
 extern	cpm8xx_t	*cpmp;		/* Pointer to comm processor */
-extern uint cpm_dpalloc(uint size, uint align);
-extern int cpm_dpfree(uint offset);
-extern uint cpm_dpalloc_fixed(uint offset, uint size, uint align);
+extern unsigned long cpm_dpalloc(uint size, uint align);
+extern int cpm_dpfree(unsigned long offset);
+extern unsigned long cpm_dpalloc_fixed(unsigned long offset, uint size, uint align);
 extern void cpm_dpdump(void);
-extern void *cpm_dpram_addr(uint offset);
+extern void *cpm_dpram_addr(unsigned long offset);
 extern uint cpm_dpram_phys(u8* addr);
 extern void cpm_setbrg(uint brg, uint rate);

diff --git a/include/asm-ppc/cpm2.h b/include/asm-ppc/cpm2.h
index 220cc2d..12a2860 100644
--- a/include/asm-ppc/cpm2.h
+++ b/include/asm-ppc/cpm2.h
@@ -104,21 +104,16 @@
  */
 #define NUM_CPM_HOST_PAGES	2

-static inline long IS_DPERR(const uint offset)
-{
-	return (uint)offset > (uint)-1000L;
-}
-
 /* Export the base address of the communication processor registers
  * and dual port ram.
  */
 extern		cpm_cpm2_t	*cpmp;	 /* Pointer to comm processor */

-extern uint cpm_dpalloc(uint size, uint align);
-extern int cpm_dpfree(uint offset);
-extern uint cpm_dpalloc_fixed(uint offset, uint size, uint align);
+extern unsigned long cpm_dpalloc(uint size, uint align);
+extern int cpm_dpfree(unsigned long offset);
+extern unsigned long cpm_dpalloc_fixed(unsigned long offset, uint size, uint align);
 extern void cpm_dpdump(void);
-extern void *cpm_dpram_addr(uint offset);
+extern void *cpm_dpram_addr(unsigned long offset);
 extern void cpm_setbrg(uint brg, uint rate);
 extern void cpm2_fastbrg(uint brg, uint rate, int div16);
 extern void cpm2_reset(void);
diff --git a/include/asm-ppc/rheap.h b/include/asm-ppc/rheap.h
index 39a10d8..1723817 100644
--- a/include/asm-ppc/rheap.h
+++ b/include/asm-ppc/rheap.h
@@ -18,7 +18,7 @@

 typedef struct _rh_block {
 	struct list_head list;
-	void *start;
+	unsigned long start;
 	int size;
 	const char *owner;
 } rh_block_t;
@@ -37,8 +37,8 @@ typedef struct _rh_info {
 #define RHIF_STATIC_INFO	0x1
 #define RHIF_STATIC_BLOCK	0x2

-typedef struct rh_stats_t {
-	void *start;
+typedef struct _rh_stats {
+	unsigned long start;
 	int size;
 	const char *owner;
 } rh_stats_t;
@@ -57,24 +57,24 @@ extern void rh_init(rh_info_t * info, unsigned int alignment, int max_blocks,
 		    rh_block_t * block);

 /* Attach a free region to manage */
-extern int rh_attach_region(rh_info_t * info, void *start, int size);
+extern int rh_attach_region(rh_info_t * info, unsigned long start, int size);

 /* Detach a free region */
-extern void *rh_detach_region(rh_info_t * info, void *start, int size);
+extern unsigned long rh_detach_region(rh_info_t * info, unsigned long start, int size);

 /* Allocate the given size from the remote heap (with alignment) */
-extern void *rh_alloc_align(rh_info_t * info, int size, int alignment,
+extern unsigned long rh_alloc_align(rh_info_t * info, int size, int alignment,
 		const char *owner);

 /* Allocate the given size from the remote heap */
-extern void *rh_alloc(rh_info_t * info, int size, const char *owner);
+extern unsigned long rh_alloc(rh_info_t * info, int size, const char *owner);

 /* Allocate the given size from the given address */
-extern void *rh_alloc_fixed(rh_info_t * info, void *start, int size,
+extern unsigned long rh_alloc_fixed(rh_info_t * info, unsigned long start, int size,
 			    const char *owner);

 /* Free the allocated area */
-extern int rh_free(rh_info_t * info, void *start);
+extern int rh_free(rh_info_t * info, unsigned long start);

 /* Get stats for debugging purposes */
 extern int rh_get_stats(rh_info_t * info, int what, int max_stats,
@@ -84,6 +84,6 @@ extern int rh_get_stats(rh_info_t * info, int what, int max_stats,
 extern void rh_dump(rh_info_t * info);

 /* Set owner of taken block */
-extern int rh_set_owner(rh_info_t * info, void *start, const char *owner);
+extern int rh_set_owner(rh_info_t * info, unsigned long start, const char *owner);

 #endif				/* __ASM_PPC_RHEAP_H__ */
--
1.5.0.2.260.g2eb065

