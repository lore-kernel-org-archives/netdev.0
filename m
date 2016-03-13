From: Varun Prakash <varun@chelsio.com>
Subject: [target-pending 11/12] cxgb4: add iSCSI DDP page pod manager
Date: Sun, 13 Mar 2016 19:49:33 +0530
Message-ID: <5adf989f0c2d810ea5f3fedab5db9c755c1b5f1d.1457877852.git.varun@chelsio.com>
References: <cover.1457877852.git.varun@chelsio.com>
Cc: target-devel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, swise@opengridcomputing.com,
	indranil@chelsio.com, kxie@chelsio.com, hariprasad@chelsio.com,
	varun@chelsio.com
To: nab@linux-iscsi.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:21924 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754081AbcCMOVG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2016 10:21:06 -0400
In-Reply-To: <cover.1457877852.git.varun@chelsio.com>
In-Reply-To: <cover.1457877852.git.varun@chelsio.com>
References: <cover.1457877852.git.varun@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

add files for common page pod manager,
both iSCSI initiator and target ULDs will
use common ppod manager for DDP.

Signed-off-by: Varun Prakash <varun@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ppm.c | 464 +++++++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ppm.h | 310 +++++++++++++++++
 2 files changed, 774 insertions(+)
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ppm.c
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ppm.h

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ppm.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ppm.c
new file mode 100644
index 0000000..d88a7a7
--- /dev/null
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ppm.c
@@ -0,0 +1,464 @@
+/*
+ * cxgb4_ppm.c: Chelsio common library for T4/T5 iSCSI PagePod Manager
+ *
+ * Copyright (c) 2016 Chelsio Communications, Inc. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * Written by: Karen Xie (kxie@chelsio.com)
+ */
+
+#include <linux/kernel.h>
+#include <linux/version.h>
+#include <linux/module.h>
+#include <linux/errno.h>
+#include <linux/types.h>
+#include <linux/debugfs.h>
+#include <linux/export.h>
+#include <linux/list.h>
+#include <linux/skbuff.h>
+#include <linux/pci.h>
+#include <linux/scatterlist.h>
+
+#include "cxgb4_ppm.h"
+
+/* Direct Data Placement -
+ * Directly place the iSCSI Data-In or Data-Out PDU's payload into
+ * pre-posted final destination host-memory buffers based on the
+ * Initiator Task Tag (ITT) in Data-In or Target Task Tag (TTT)
+ * in Data-Out PDUs. The host memory address is programmed into
+ * h/w in the format of pagepod entries. The location of the
+ * pagepod entry is encoded into ddp tag which is used as the base
+ * for ITT/TTT.
+ */
+
+/* Direct-Data Placement page size adjustment
+ */
+int cxgbi_ppm_find_page_index(struct cxgbi_ppm *ppm, unsigned long pgsz)
+{
+	struct cxgbi_tag_format *tformat = &ppm->tformat;
+	int i;
+
+	for (i = 0; i < DDP_PGIDX_MAX; i++) {
+		if (pgsz == 1UL << (DDP_PGSZ_BASE_SHIFT +
+					 tformat->pgsz_order[i])) {
+			pr_debug("%s: %s ppm, pgsz %lu -> idx %d.\n",
+				 __func__, ppm->ndev->name, pgsz, i);
+			return i;
+		}
+	}
+	pr_info("ippm: ddp page size %lu not supported.\n", pgsz);
+	return DDP_PGIDX_MAX;
+}
+
+/* DDP setup & teardown
+ */
+static int ppm_find_unused_entries(unsigned long *bmap,
+				   unsigned int max_ppods,
+				   unsigned int start,
+				   unsigned int nr,
+				   unsigned int align_mask)
+{
+	unsigned long i;
+
+	i = bitmap_find_next_zero_area(bmap, max_ppods, start, nr, align_mask);
+
+	if (unlikely(i >= max_ppods) && (start > nr))
+		i = bitmap_find_next_zero_area(bmap, max_ppods, 0, start - 1,
+					       align_mask);
+	if (unlikely(i >= max_ppods))
+		return -ENOSPC;
+
+	bitmap_set(bmap, i, nr);
+	return (int)i;
+}
+
+static void ppm_mark_entries(struct cxgbi_ppm *ppm, int i, int count,
+			     unsigned long caller_data)
+{
+	struct cxgbi_ppod_data *pdata = ppm->ppod_data + i;
+
+	pdata->caller_data = caller_data;
+	pdata->npods = count;
+
+	if (pdata->color == ((1 << PPOD_IDX_SHIFT) - 1))
+		pdata->color = 0;
+	else
+		pdata->color++;
+}
+
+static int ppm_get_cpu_entries(struct cxgbi_ppm *ppm, unsigned int count,
+			       unsigned long caller_data)
+{
+	struct cxgbi_ppm_pool *pool;
+	unsigned int cpu;
+	int i;
+
+	cpu = get_cpu();
+	pool = per_cpu_ptr(ppm->pool, cpu);
+	spin_lock_bh(&pool->lock);
+	put_cpu();
+
+	i = ppm_find_unused_entries(pool->bmap, ppm->pool_index_max,
+				    pool->next, count, 0);
+	if (i < 0) {
+		pool->next = 0;
+		spin_unlock_bh(&pool->lock);
+		return -ENOSPC;
+	}
+
+	pool->next = i + count;
+	if (pool->next >= ppm->pool_index_max)
+		pool->next = 0;
+
+	spin_unlock_bh(&pool->lock);
+
+	pr_debug("%s: cpu %u, idx %d + %d (%d), next %u.\n",
+		 __func__, cpu, i, count, i + cpu * ppm->pool_index_max,
+		pool->next);
+
+	i += cpu * ppm->pool_index_max;
+	ppm_mark_entries(ppm, i, count, caller_data);
+
+	return i;
+}
+
+static int ppm_get_entries(struct cxgbi_ppm *ppm, unsigned int count,
+			   unsigned long caller_data)
+{
+	int i;
+
+	spin_lock_bh(&ppm->map_lock);
+	i = ppm_find_unused_entries(ppm->ppod_bmap, ppm->bmap_index_max,
+				    ppm->next, count, 0);
+	if (i < 0) {
+		ppm->next = 0;
+		spin_unlock_bh(&ppm->map_lock);
+		pr_debug("ippm: NO suitable entries %u available.\n",
+			 count);
+		return -ENOSPC;
+	}
+
+	ppm->next = i + count;
+	if (ppm->next >= ppm->bmap_index_max)
+		ppm->next = 0;
+
+	spin_unlock_bh(&ppm->map_lock);
+
+	pr_debug("%s: idx %d + %d (%d), next %u, caller_data 0x%lx.\n",
+		 __func__, i, count, i + ppm->pool_rsvd, ppm->next,
+		 caller_data);
+
+	i += ppm->pool_rsvd;
+	ppm_mark_entries(ppm, i, count, caller_data);
+
+	return i;
+}
+
+static void ppm_unmark_entries(struct cxgbi_ppm *ppm, int i, int count)
+{
+	pr_debug("%s: idx %d + %d.\n", __func__, i, count);
+
+	if (i < ppm->pool_rsvd) {
+		unsigned int cpu;
+		struct cxgbi_ppm_pool *pool;
+
+		cpu = i / ppm->pool_index_max;
+		i %= ppm->pool_index_max;
+
+		pool = per_cpu_ptr(ppm->pool, cpu);
+		spin_lock_bh(&pool->lock);
+		bitmap_clear(pool->bmap, i, count);
+
+		if (i < pool->next)
+			pool->next = i;
+		spin_unlock_bh(&pool->lock);
+
+		pr_debug("%s: cpu %u, idx %d, next %u.\n",
+			 __func__, cpu, i, pool->next);
+	} else {
+		spin_lock_bh(&ppm->map_lock);
+
+		i -= ppm->pool_rsvd;
+		bitmap_clear(ppm->ppod_bmap, i, count);
+
+		if (i < ppm->next)
+			ppm->next = i;
+		spin_unlock_bh(&ppm->map_lock);
+
+		pr_debug("%s: idx %d, next %u.\n", __func__, i, ppm->next);
+	}
+}
+
+void cxgbi_ppm_ppod_release(struct cxgbi_ppm *ppm, u32 idx)
+{
+	struct cxgbi_ppod_data *pdata;
+
+	if (idx >= ppm->ppmax) {
+		pr_warn("ippm: idx too big %u > %u.\n", idx, ppm->ppmax);
+		return;
+	}
+
+	pdata = ppm->ppod_data + idx;
+	if (!pdata->npods) {
+		pr_warn("ippm: idx %u, npods 0.\n", idx);
+		return;
+	}
+
+	pr_debug("release idx %u, npods %u.\n", idx, pdata->npods);
+	ppm_unmark_entries(ppm, idx, pdata->npods);
+}
+EXPORT_SYMBOL(cxgbi_ppm_ppod_release);
+
+int cxgbi_ppm_ppods_reserve(struct cxgbi_ppm *ppm, unsigned short nr_pages,
+			    u32 per_tag_pg_idx, u32 *ppod_idx,
+			    u32 *ddp_tag, unsigned long caller_data)
+{
+	struct cxgbi_ppod_data *pdata;
+	unsigned int npods;
+	int idx = -1;
+	unsigned int hwidx;
+	u32 tag;
+
+	npods = (nr_pages + PPOD_PAGES_MAX - 1) >> PPOD_PAGES_SHIFT;
+	if (!npods) {
+		pr_warn("%s: pages %u -> npods %u, full.\n",
+			__func__, nr_pages, npods);
+		return -EINVAL;
+	}
+
+	/* grab from cpu pool first */
+	idx = ppm_get_cpu_entries(ppm, npods, caller_data);
+	/* try the general pool */
+	if (idx < 0)
+		idx = ppm_get_entries(ppm, npods, caller_data);
+	if (idx < 0) {
+		pr_debug("ippm: pages %u, nospc %u, nxt %u, 0x%lx.\n",
+			 nr_pages, npods, ppm->next, caller_data);
+		return idx;
+	}
+
+	pdata = ppm->ppod_data + idx;
+	hwidx = ppm->base_idx + idx;
+
+	tag = cxgbi_ppm_make_ddp_tag(hwidx, pdata->color);
+
+	if (per_tag_pg_idx)
+		tag |= (per_tag_pg_idx << 30) & 0xC0000000;
+
+	*ppod_idx = idx;
+	*ddp_tag = tag;
+
+	pr_debug("ippm: sg %u, tag 0x%x(%u,%u), data 0x%lx.\n",
+		 nr_pages, tag, idx, npods, caller_data);
+
+	return npods;
+}
+EXPORT_SYMBOL(cxgbi_ppm_ppods_reserve);
+
+void cxgbi_ppm_make_ppod_hdr(struct cxgbi_ppm *ppm, u32 tag,
+			     unsigned int tid, unsigned int offset,
+			     unsigned int length,
+			     struct cxgbi_pagepod_hdr *hdr)
+{
+	/* The ddp tag in pagepod should be with bit 31:30 set to 0.
+	 * The ddp Tag on the wire should be with non-zero 31:30 to the peer
+	 */
+	tag &= 0x3FFFFFFF;
+
+	hdr->vld_tid = htonl(PPOD_VALID_FLAG | PPOD_TID(tid));
+
+	hdr->rsvd = 0;
+	hdr->pgsz_tag_clr = htonl(tag & ppm->tformat.idx_clr_mask);
+	hdr->max_offset = htonl(length);
+	hdr->page_offset = htonl(offset);
+
+	pr_debug("ippm: tag 0x%x, tid 0x%x, xfer %u, off %u.\n",
+		 tag, tid, length, offset);
+}
+EXPORT_SYMBOL(cxgbi_ppm_make_ppod_hdr);
+
+static void ppm_free(struct cxgbi_ppm *ppm)
+{
+	vfree(ppm);
+}
+
+static void ppm_destroy(struct kref *kref)
+{
+	struct cxgbi_ppm *ppm = container_of(kref,
+					     struct cxgbi_ppm,
+					     refcnt);
+	pr_info("ippm: kref 0, destroy %s ppm 0x%p.\n",
+		ppm->ndev->name, ppm);
+
+	*ppm->ppm_pp = NULL;
+
+	free_percpu(ppm->pool);
+	ppm_free(ppm);
+}
+
+int cxgbi_ppm_release(struct cxgbi_ppm *ppm)
+{
+	if (ppm) {
+		int rv;
+
+		rv = kref_put(&ppm->refcnt, ppm_destroy);
+		return rv;
+	}
+	return 1;
+}
+
+static struct cxgbi_ppm_pool *ppm_alloc_cpu_pool(unsigned int *total,
+						 unsigned int *pcpu_ppmax)
+{
+	struct cxgbi_ppm_pool *pools;
+	unsigned int ppmax = (*total) / num_possible_cpus();
+	unsigned int max = (PCPU_MIN_UNIT_SIZE - sizeof(*pools)) << 3;
+	unsigned int bmap;
+	unsigned int alloc_sz;
+	unsigned int count = 0;
+	unsigned int cpu;
+
+	/* make sure per cpu pool fits into PCPU_MIN_UNIT_SIZE */
+	if (ppmax > max)
+		ppmax = max;
+
+	/* pool size must be multiple of unsigned long */
+	bmap = BITS_TO_LONGS(ppmax);
+	ppmax = (bmap * sizeof(unsigned long)) << 3;
+
+	alloc_sz = sizeof(*pools) + sizeof(unsigned long) * bmap;
+	pools = __alloc_percpu(alloc_sz, __alignof__(struct cxgbi_ppm_pool));
+
+	if (!pools)
+		return NULL;
+
+	for_each_possible_cpu(cpu) {
+		struct cxgbi_ppm_pool *ppool = per_cpu_ptr(pools, cpu);
+
+		memset(ppool, 0, alloc_sz);
+		spin_lock_init(&ppool->lock);
+		count += ppmax;
+	}
+
+	*total = count;
+	*pcpu_ppmax = ppmax;
+
+	return pools;
+}
+
+int cxgbi_ppm_init(void **ppm_pp, struct net_device *ndev,
+		   struct pci_dev *pdev, void *lldev,
+		   struct cxgbi_tag_format *tformat,
+		   unsigned int ppmax,
+		   unsigned int llimit,
+		   unsigned int start,
+		   unsigned int reserve_factor)
+{
+	struct cxgbi_ppm *ppm = (struct cxgbi_ppm *)(*ppm_pp);
+	struct cxgbi_ppm_pool *pool = NULL;
+	unsigned int ppmax_pool = 0;
+	unsigned int pool_index_max = 0;
+	unsigned int alloc_sz;
+	unsigned int ppod_bmap_size;
+
+	if (ppm) {
+		pr_info("ippm: %s, ppm 0x%p,0x%p already initialized, %u/%u.\n",
+			ndev->name, ppm_pp, ppm, ppm->ppmax, ppmax);
+		kref_get(&ppm->refcnt);
+		return 1;
+	}
+
+	if (reserve_factor) {
+		ppmax_pool = ppmax / reserve_factor;
+		pool = ppm_alloc_cpu_pool(&ppmax_pool, &pool_index_max);
+
+		pr_debug("%s: ppmax %u, cpu total %u, per cpu %u.\n",
+			 ndev->name, ppmax, ppmax_pool, pool_index_max);
+	}
+
+	ppod_bmap_size = BITS_TO_LONGS(ppmax - ppmax_pool);
+	alloc_sz = sizeof(struct cxgbi_ppm) +
+			ppmax * (sizeof(struct cxgbi_ppod_data)) +
+			ppod_bmap_size * sizeof(unsigned long);
+
+	ppm = vmalloc(alloc_sz);
+	if (!ppm)
+		goto release_ppm_pool;
+
+	memset(ppm, 0, alloc_sz);
+
+	ppm->ppod_bmap = (unsigned long *)(&ppm->ppod_data[ppmax]);
+
+	if ((ppod_bmap_size >> 3) > (ppmax - ppmax_pool)) {
+		unsigned int start = ppmax - ppmax_pool;
+		unsigned int end = ppod_bmap_size >> 3;
+
+		bitmap_set(ppm->ppod_bmap, ppmax, end - start);
+		pr_info("%s: %u - %u < %u * 8, mask extra bits %u, %u.\n",
+			__func__, ppmax, ppmax_pool, ppod_bmap_size, start,
+			end);
+	}
+
+	spin_lock_init(&ppm->map_lock);
+	kref_init(&ppm->refcnt);
+
+	memcpy(&ppm->tformat, tformat, sizeof(struct cxgbi_tag_format));
+
+	ppm->ppm_pp = ppm_pp;
+	ppm->ndev = ndev;
+	ppm->pdev = pdev;
+	ppm->lldev = lldev;
+	ppm->ppmax = ppmax;
+	ppm->next = 0;
+	ppm->llimit = llimit;
+	ppm->base_idx = start > llimit ?
+			(start - llimit + 1) >> PPOD_SIZE_SHIFT : 0;
+	ppm->bmap_index_max = ppmax - ppmax_pool;
+
+	ppm->pool = pool;
+	ppm->pool_rsvd = ppmax_pool;
+	ppm->pool_index_max = pool_index_max;
+
+	/* check one more time */
+	if (*ppm_pp) {
+		ppm_free(ppm);
+		ppm = (struct cxgbi_ppm *)(*ppm_pp);
+
+		pr_info("ippm: %s, ppm 0x%p,0x%p already initialized, %u/%u.\n",
+			ndev->name, ppm_pp, *ppm_pp, ppm->ppmax, ppmax);
+
+		kref_get(&ppm->refcnt);
+		return 1;
+	}
+	*ppm_pp = ppm;
+
+	ppm->tformat.pgsz_idx_dflt = cxgbi_ppm_find_page_index(ppm, PAGE_SIZE);
+
+	pr_info("ippm %s: ppm 0x%p, 0x%p, base %u/%u, pg %lu,%u, rsvd %u,%u.\n",
+		ndev->name, ppm_pp, ppm, ppm->base_idx, ppm->ppmax, PAGE_SIZE,
+		ppm->tformat.pgsz_idx_dflt, ppm->pool_rsvd,
+		ppm->pool_index_max);
+
+	return 0;
+
+release_ppm_pool:
+	free_percpu(pool);
+	return -ENOMEM;
+}
+EXPORT_SYMBOL(cxgbi_ppm_init);
+
+unsigned int cxgbi_tagmask_set(unsigned int ppmax)
+{
+	unsigned int bits = fls(ppmax);
+
+	if (bits > PPOD_IDX_MAX_SIZE)
+		bits = PPOD_IDX_MAX_SIZE;
+
+	pr_info("ippm: ppmax %u/0x%x -> bits %u, tagmask 0x%x.\n",
+		ppmax, ppmax, bits, 1 << (bits + PPOD_IDX_SHIFT));
+
+	return 1 << (bits + PPOD_IDX_SHIFT);
+}
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ppm.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ppm.h
new file mode 100644
index 0000000..d487326
--- /dev/null
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ppm.h
@@ -0,0 +1,310 @@
+/*
+ * cxgb4_ppm.h: Chelsio common library for T4/T5 iSCSI ddp operation
+ *
+ * Copyright (c) 2016 Chelsio Communications, Inc. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * Written by: Karen Xie (kxie@chelsio.com)
+ */
+
+#ifndef	__CXGB4PPM_H__
+#define	__CXGB4PPM_H__
+
+#include <linux/kernel.h>
+#include <linux/errno.h>
+#include <linux/types.h>
+#include <linux/debugfs.h>
+#include <linux/list.h>
+#include <linux/netdevice.h>
+#include <linux/scatterlist.h>
+#include <linux/skbuff.h>
+#include <linux/vmalloc.h>
+#include <linux/bitmap.h>
+
+struct cxgbi_pagepod_hdr {
+	u32 vld_tid;
+	u32 pgsz_tag_clr;
+	u32 max_offset;
+	u32 page_offset;
+	u64 rsvd;
+};
+
+#define PPOD_PAGES_MAX			4
+struct cxgbi_pagepod {
+	struct cxgbi_pagepod_hdr hdr;
+	u64 addr[PPOD_PAGES_MAX + 1];
+};
+
+/* ddp tag format
+ * for a 32-bit tag:
+ * bit #
+ * 31 .....   .....  0
+ *     X   Y...Y Z...Z, where
+ *     ^   ^^^^^ ^^^^
+ *     |   |      |____ when ddp bit = 0: color bits
+ *     |   |
+ *     |   |____ when ddp bit = 0: idx into the ddp memory region
+ *     |
+ *     |____ ddp bit: 0 - ddp tag, 1 - non-ddp tag
+ *
+ *  [page selector:2] [sw/free bits] [0] [idx] [color:6]
+ */
+
+#define DDP_PGIDX_MAX		4
+#define DDP_PGSZ_BASE_SHIFT	12	/* base page 4K */
+
+struct cxgbi_task_tag_info {
+	unsigned char flags;
+#define CXGBI_PPOD_INFO_FLAG_VALID	0x1
+#define CXGBI_PPOD_INFO_FLAG_MAPPED	0x2
+	unsigned char cid;
+	unsigned short pg_shift;
+	unsigned int npods;
+	unsigned int idx;
+	unsigned int tag;
+	struct cxgbi_pagepod_hdr hdr;
+	int nents;
+	int nr_pages;
+	struct scatterlist *sgl;
+};
+
+struct cxgbi_tag_format {
+	unsigned char pgsz_order[DDP_PGIDX_MAX];
+	unsigned char pgsz_idx_dflt;
+	unsigned char free_bits:4;
+	unsigned char color_bits:4;
+	unsigned char idx_bits;
+	unsigned char rsvd_bits;
+	unsigned int  no_ddp_mask;
+	unsigned int  idx_mask;
+	unsigned int  color_mask;
+	unsigned int  idx_clr_mask;
+	unsigned int  rsvd_mask;
+};
+
+struct cxgbi_ppod_data {
+	unsigned char pg_idx:2;
+	unsigned char color:6;
+	unsigned char chan_id;
+	unsigned short npods;
+	unsigned long caller_data;
+};
+
+/* per cpu ppm pool */
+struct cxgbi_ppm_pool {
+	unsigned int base;		/* base index */
+	unsigned int next;		/* next possible free index */
+	spinlock_t lock;		/* ppm pool lock */
+	unsigned long bmap[0];
+} ____cacheline_aligned_in_smp;
+
+struct cxgbi_ppm {
+	struct kref refcnt;
+	struct net_device *ndev;	/* net_device, 1st port */
+	struct pci_dev *pdev;
+	void *lldev;
+	void **ppm_pp;
+	struct cxgbi_tag_format tformat;
+	unsigned int ppmax;
+	unsigned int llimit;
+	unsigned int base_idx;
+
+	unsigned int pool_rsvd;
+	unsigned int pool_index_max;
+	struct cxgbi_ppm_pool __percpu *pool;
+	/* map lock */
+	spinlock_t map_lock;		/* ppm map lock */
+	unsigned int bmap_index_max;
+	unsigned int next;
+	unsigned long *ppod_bmap;
+	struct cxgbi_ppod_data ppod_data[0];
+};
+
+#define DDP_THRESHOLD		512
+
+#define PPOD_PAGES_SHIFT	2       /*  4 pages per pod */
+
+#define IPPOD_SIZE               sizeof(struct cxgbi_pagepod)  /*  64 */
+#define PPOD_SIZE_SHIFT         6
+
+/* page pods are allocated in groups of this size (must be power of 2) */
+#define PPOD_CLUSTER_SIZE	16U
+
+#define ULPMEM_DSGL_MAX_NPPODS	16	/*  1024/PPOD_SIZE */
+#define ULPMEM_IDATA_MAX_NPPODS	3	/* (PPOD_SIZE * 3 + ulptx hdr) < 256B */
+#define PCIE_MEMWIN_MAX_NPPODS	16	/*  1024/PPOD_SIZE */
+
+#define PPOD_COLOR_SHIFT	0
+#define PPOD_COLOR(x)		((x) << PPOD_COLOR_SHIFT)
+
+#define PPOD_IDX_SHIFT          6
+#define PPOD_IDX_MAX_SIZE       24
+
+#define PPOD_TID_SHIFT		0
+#define PPOD_TID(x)		((x) << PPOD_TID_SHIFT)
+
+#define PPOD_TAG_SHIFT		6
+#define PPOD_TAG(x)		((x) << PPOD_TAG_SHIFT)
+
+#define PPOD_VALID_SHIFT	24
+#define PPOD_VALID(x)		((x) << PPOD_VALID_SHIFT)
+#define PPOD_VALID_FLAG		PPOD_VALID(1U)
+
+#define PPOD_PI_EXTRACT_CTL_SHIFT	31
+#define PPOD_PI_EXTRACT_CTL(x)		((x) << PPOD_PI_EXTRACT_CTL_SHIFT)
+#define PPOD_PI_EXTRACT_CTL_FLAG	V_PPOD_PI_EXTRACT_CTL(1U)
+
+#define PPOD_PI_TYPE_SHIFT		29
+#define PPOD_PI_TYPE_MASK		0x3
+#define PPOD_PI_TYPE(x)			((x) << PPOD_PI_TYPE_SHIFT)
+
+#define PPOD_PI_CHECK_CTL_SHIFT		27
+#define PPOD_PI_CHECK_CTL_MASK		0x3
+#define PPOD_PI_CHECK_CTL(x)		((x) << PPOD_PI_CHECK_CTL_SHIFT)
+
+#define PPOD_PI_REPORT_CTL_SHIFT	25
+#define PPOD_PI_REPORT_CTL_MASK		0x3
+#define PPOD_PI_REPORT_CTL(x)		((x) << PPOD_PI_REPORT_CTL_SHIFT)
+
+static inline int cxgbi_ppm_is_ddp_tag(struct cxgbi_ppm *ppm, u32 tag)
+{
+	return !(tag & ppm->tformat.no_ddp_mask);
+}
+
+static inline int cxgbi_ppm_sw_tag_is_usable(struct cxgbi_ppm *ppm,
+					     u32 tag)
+{
+	/* the sw tag must be using <= 31 bits */
+	return !(tag & 0x80000000U);
+}
+
+static inline int cxgbi_ppm_make_non_ddp_tag(struct cxgbi_ppm *ppm,
+					     u32 sw_tag,
+					     u32 *final_tag)
+{
+	struct cxgbi_tag_format *tformat = &ppm->tformat;
+
+	if (!cxgbi_ppm_sw_tag_is_usable(ppm, sw_tag)) {
+		pr_info("sw_tag 0x%x NOT usable.\n", sw_tag);
+		return -EINVAL;
+	}
+
+	if (!sw_tag) {
+		*final_tag = tformat->no_ddp_mask;
+	} else {
+		unsigned int shift = tformat->idx_bits + tformat->color_bits;
+		u32 lower = sw_tag & tformat->idx_clr_mask;
+		u32 upper = (sw_tag >> shift) << (shift + 1);
+
+		*final_tag = upper | tformat->no_ddp_mask | lower;
+	}
+	return 0;
+}
+
+static inline u32 cxgbi_ppm_decode_non_ddp_tag(struct cxgbi_ppm *ppm,
+					       u32 tag)
+{
+	struct cxgbi_tag_format *tformat = &ppm->tformat;
+	unsigned int shift = tformat->idx_bits + tformat->color_bits;
+	u32 lower = tag & tformat->idx_clr_mask;
+	u32 upper = (tag >> tformat->rsvd_bits) << shift;
+
+	return upper | lower;
+}
+
+static inline u32 cxgbi_ppm_ddp_tag_get_idx(struct cxgbi_ppm *ppm,
+					    u32 ddp_tag)
+{
+	u32 hw_idx = (ddp_tag >> PPOD_IDX_SHIFT) &
+			ppm->tformat.idx_mask;
+
+	return hw_idx - ppm->base_idx;
+}
+
+static inline u32 cxgbi_ppm_make_ddp_tag(unsigned int hw_idx,
+					 unsigned char color)
+{
+	return (hw_idx << PPOD_IDX_SHIFT) | ((u32)color);
+}
+
+static inline unsigned long
+cxgbi_ppm_get_tag_caller_data(struct cxgbi_ppm *ppm,
+			      u32 ddp_tag)
+{
+	u32 idx = cxgbi_ppm_ddp_tag_get_idx(ppm, ddp_tag);
+
+	return ppm->ppod_data[idx].caller_data;
+}
+
+/* sw bits are the free bits */
+static inline int cxgbi_ppm_ddp_tag_update_sw_bits(struct cxgbi_ppm *ppm,
+						   u32 val, u32 orig_tag,
+						   u32 *final_tag)
+{
+	struct cxgbi_tag_format *tformat = &ppm->tformat;
+	u32 v = val >> tformat->free_bits;
+
+	if (v) {
+		pr_info("sw_bits 0x%x too large, avail bits %u.\n",
+			val, tformat->free_bits);
+		return -EINVAL;
+	}
+	if (!cxgbi_ppm_is_ddp_tag(ppm, orig_tag))
+		return -EINVAL;
+
+	*final_tag = (val << tformat->rsvd_bits) |
+		     (orig_tag & ppm->tformat.rsvd_mask);
+	return 0;
+}
+
+static inline void cxgbi_ppm_ppod_clear(struct cxgbi_pagepod *ppod)
+{
+	ppod->hdr.vld_tid = 0U;
+}
+
+static inline void cxgbi_tagmask_check(unsigned int tagmask,
+				       struct cxgbi_tag_format *tformat)
+{
+	unsigned int bits = fls(tagmask);
+
+	/* reserve top most 2 bits for page selector */
+	tformat->free_bits = 32 - 2 - bits;
+	tformat->rsvd_bits = bits;
+	tformat->color_bits = PPOD_IDX_SHIFT;
+	tformat->idx_bits = bits - 1 - PPOD_IDX_SHIFT;
+	tformat->no_ddp_mask = 1 << (bits - 1);
+	tformat->idx_mask = (1 << tformat->idx_bits) - 1;
+	tformat->color_mask = (1 << PPOD_IDX_SHIFT) - 1;
+	tformat->idx_clr_mask = (1 << (bits - 1)) - 1;
+	tformat->rsvd_mask = (1 << bits) - 1;
+
+	pr_info("ippm: tagmask 0x%x, rsvd %u=%u+%u+1, mask 0x%x,0x%x, "
+		"pg %u,%u,%u,%u.\n",
+		tagmask, tformat->rsvd_bits, tformat->idx_bits,
+		tformat->color_bits, tformat->no_ddp_mask, tformat->rsvd_mask,
+		tformat->pgsz_order[0], tformat->pgsz_order[1],
+		tformat->pgsz_order[2], tformat->pgsz_order[3]);
+}
+
+int cxgbi_ppm_find_page_index(struct cxgbi_ppm *ppm, unsigned long pgsz);
+void cxgbi_ppm_make_ppod_hdr(struct cxgbi_ppm *ppm, u32 tag,
+			     unsigned int tid, unsigned int offset,
+			     unsigned int length,
+			     struct cxgbi_pagepod_hdr *hdr);
+void cxgbi_ppm_ppod_release(struct cxgbi_ppm *, u32 idx);
+int cxgbi_ppm_ppods_reserve(struct cxgbi_ppm *, unsigned short nr_pages,
+			    u32 per_tag_pg_idx, u32 *ppod_idx, u32 *ddp_tag,
+			    unsigned long caller_data);
+int cxgbi_ppm_init(void **ppm_pp, struct net_device *, struct pci_dev *,
+		   void *lldev, struct cxgbi_tag_format *,
+		   unsigned int ppmax, unsigned int llimit,
+		   unsigned int start,
+		   unsigned int reserve_factor);
+int cxgbi_ppm_release(struct cxgbi_ppm *ppm);
+void cxgbi_tagmask_check(unsigned int tagmask, struct cxgbi_tag_format *);
+unsigned int cxgbi_tagmask_set(unsigned int ppmax);
+
+#endif	/*__CXGB4PPM_H__*/
-- 
2.0.2
