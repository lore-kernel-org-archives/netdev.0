From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH net-next 1/3] xen-netback: page pool support
Date: Fri, 24 May 2013 11:32:31 +0100
Message-ID: <1369391553-16835-2-git-send-email-wei.liu2@citrix.com>
References: <1369391553-16835-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ian.campbell@citrix.com>, <konrad.wilk@oracle.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:46452 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760407Ab3EXKch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 May 2013 06:32:37 -0400
In-Reply-To: <1369391553-16835-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements a page pool for all vifs. It has two functionalities:
 a) to limit the amount of pages used by all vifs
 b) to track pages belong to vifs

Each vif gets page from the pool and puts page back to the pool when it
finishes with the page. The pool itself doesn't pre-allocate any page
so memory overhead is minimal.

This is ground work to move towards thread-per-vif (1:1) model netback.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/Makefile    |    2 +-
 drivers/net/xen-netback/common.h    |   12 +++
 drivers/net/xen-netback/netback.c   |  134 ++++++++-----------------
 drivers/net/xen-netback/page_pool.c |  186 +++++++++++++++++++++++++++++++++++
 drivers/net/xen-netback/page_pool.h |   60 +++++++++++
 5 files changed, 299 insertions(+), 95 deletions(-)
 create mode 100644 drivers/net/xen-netback/page_pool.c
 create mode 100644 drivers/net/xen-netback/page_pool.h

diff --git a/drivers/net/xen-netback/Makefile b/drivers/net/xen-netback/Makefile
index e346e81..dc4b8b1 100644
--- a/drivers/net/xen-netback/Makefile
+++ b/drivers/net/xen-netback/Makefile
@@ -1,3 +1,3 @@
 obj-$(CONFIG_XEN_NETDEV_BACKEND) := xen-netback.o
 
-xen-netback-y := netback.o xenbus.o interface.o
+xen-netback-y := netback.o xenbus.o interface.o page_pool.o
diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 8a4d77e..96f033d 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -47,6 +47,18 @@
 
 struct xen_netbk;
 
+typedef unsigned int pending_ring_idx_t;
+#define INVALID_PENDING_RING_IDX (~0U)
+
+struct pending_tx_info {
+	struct xen_netif_tx_request req; /* coalesced tx request */
+	struct xenvif *vif;
+	pending_ring_idx_t head; /* head != INVALID_PENDING_RING_IDX
+				  * if it is head of one or more tx
+				  * reqs
+				  */
+};
+
 struct xenvif {
 	/* Unique identifier for this interface. */
 	domid_t          domid;
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 82576ff..197f414 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -33,6 +33,7 @@
  */
 
 #include "common.h"
+#include "page_pool.h"
 
 #include <linux/kthread.h>
 #include <linux/if_vlan.h>
@@ -63,6 +64,15 @@ static unsigned int fatal_skb_slots = FATAL_SKB_SLOTS_DEFAULT;
 module_param(fatal_skb_slots, uint, 0444);
 
 /*
+ * We calculate page pool size with pool_entries_per_cpu.
+ * page_pool_size = pool_entries_per_cpu * nr_online_cpus
+ *
+ * These entries are shared among all cpus.
+ */
+static unsigned int pool_entries_per_cpu = PAGE_POOL_DEFAULT_ENTRIES_PER_CPU;
+module_param(pool_entries_per_cpu, uint, 0444);
+
+/*
  * To avoid confusion, we define XEN_NETBK_LEGACY_SLOTS_MAX indicating
  * the maximum slots a valid packet can use. Now this value is defined
  * to be XEN_NETIF_NR_SLOTS_MIN, which is supposed to be supported by
@@ -70,18 +80,6 @@ module_param(fatal_skb_slots, uint, 0444);
  */
 #define XEN_NETBK_LEGACY_SLOTS_MAX XEN_NETIF_NR_SLOTS_MIN
 
-typedef unsigned int pending_ring_idx_t;
-#define INVALID_PENDING_RING_IDX (~0U)
-
-struct pending_tx_info {
-	struct xen_netif_tx_request req; /* coalesced tx request */
-	struct xenvif *vif;
-	pending_ring_idx_t head; /* head != INVALID_PENDING_RING_IDX
-				  * if it is head of one or more tx
-				  * reqs
-				  */
-};
-
 struct netbk_rx_meta {
 	int id;
 	int size;
@@ -95,21 +93,6 @@ struct netbk_rx_meta {
 
 #define MAX_BUFFER_OFFSET PAGE_SIZE
 
-/* extra field used in struct page */
-union page_ext {
-	struct {
-#if BITS_PER_LONG < 64
-#define IDX_WIDTH   8
-#define GROUP_WIDTH (BITS_PER_LONG - IDX_WIDTH)
-		unsigned int group:GROUP_WIDTH;
-		unsigned int idx:IDX_WIDTH;
-#else
-		unsigned int group, idx;
-#endif
-	} e;
-	void *mapping;
-};
-
 struct xen_netbk {
 	wait_queue_head_t wq;
 	struct task_struct *task;
@@ -119,7 +102,7 @@ struct xen_netbk {
 
 	struct timer_list net_timer;
 
-	struct page *mmap_pages[MAX_PENDING_REQS];
+	int32_t mmap_pages[MAX_PENDING_REQS];
 
 	pending_ring_idx_t pending_prod;
 	pending_ring_idx_t pending_cons;
@@ -205,7 +188,7 @@ static struct xen_netif_rx_response *make_rx_response(struct xenvif *vif,
 static inline unsigned long idx_to_pfn(struct xen_netbk *netbk,
 				       u16 idx)
 {
-	return page_to_pfn(netbk->mmap_pages[idx]);
+	return page_to_pfn(to_page(netbk->mmap_pages[idx]));
 }
 
 static inline unsigned long idx_to_kaddr(struct xen_netbk *netbk,
@@ -214,45 +197,6 @@ static inline unsigned long idx_to_kaddr(struct xen_netbk *netbk,
 	return (unsigned long)pfn_to_kaddr(idx_to_pfn(netbk, idx));
 }
 
-/* extra field used in struct page */
-static inline void set_page_ext(struct page *pg, struct xen_netbk *netbk,
-				unsigned int idx)
-{
-	unsigned int group = netbk - xen_netbk;
-	union page_ext ext = { .e = { .group = group + 1, .idx = idx } };
-
-	BUILD_BUG_ON(sizeof(ext) > sizeof(ext.mapping));
-	pg->mapping = ext.mapping;
-}
-
-static int get_page_ext(struct page *pg,
-			unsigned int *pgroup, unsigned int *pidx)
-{
-	union page_ext ext = { .mapping = pg->mapping };
-	struct xen_netbk *netbk;
-	unsigned int group, idx;
-
-	group = ext.e.group - 1;
-
-	if (group < 0 || group >= xen_netbk_group_nr)
-		return 0;
-
-	netbk = &xen_netbk[group];
-
-	idx = ext.e.idx;
-
-	if ((idx < 0) || (idx >= MAX_PENDING_REQS))
-		return 0;
-
-	if (netbk->mmap_pages[idx] != pg)
-		return 0;
-
-	*pgroup = group;
-	*pidx = idx;
-
-	return 1;
-}
-
 /*
  * This is the amount of packet we copy rather than map, so that the
  * guest can't fiddle with the contents of the headers while we do
@@ -457,8 +401,8 @@ static void netbk_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
 	 * These variables are used iff get_page_ext returns true,
 	 * in which case they are guaranteed to be initialized.
 	 */
-	unsigned int uninitialized_var(group), uninitialized_var(idx);
-	int foreign = get_page_ext(page, &group, &idx);
+	int32_t uninitialized_var(idx);
+	int foreign = is_in_pool(page, &idx);
 	unsigned long bytes;
 
 	/* Data must not cross a page boundary. */
@@ -495,10 +439,10 @@ static void netbk_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
 		copy_gop = npo->copy + npo->copy_prod++;
 		copy_gop->flags = GNTCOPY_dest_gref;
 		if (foreign) {
-			struct xen_netbk *netbk = &xen_netbk[group];
+			struct xen_netbk *netbk = to_netbk(idx);
 			struct pending_tx_info *src_pend;
 
-			src_pend = &netbk->pending_tx_info[idx];
+			src_pend = &netbk->pending_tx_info[*to_pending_ring_idx(idx)];
 
 			copy_gop->source.domid = src_pend->vif->domid;
 			copy_gop->source.u.ref = src_pend->req.gref;
@@ -1042,11 +986,11 @@ static struct page *xen_netbk_alloc_page(struct xen_netbk *netbk,
 					 u16 pending_idx)
 {
 	struct page *page;
-	page = alloc_page(GFP_KERNEL|__GFP_COLD);
+	int32_t idx;
+	page = page_pool_get(netbk, &idx);
 	if (!page)
 		return NULL;
-	set_page_ext(page, netbk, pending_idx);
-	netbk->mmap_pages[pending_idx] = page;
+	netbk->mmap_pages[pending_idx] = idx;
 	return page;
 }
 
@@ -1083,8 +1027,9 @@ static struct gnttab_copy *xen_netbk_get_requests(struct xen_netbk *netbk,
 	     shinfo->nr_frags++) {
 		struct pending_tx_info *pending_tx_info =
 			netbk->pending_tx_info;
+		int32_t idx;
 
-		page = alloc_page(GFP_KERNEL|__GFP_COLD);
+		page = page_pool_get(netbk, &idx);
 		if (!page)
 			goto err;
 
@@ -1133,7 +1078,7 @@ static struct gnttab_copy *xen_netbk_get_requests(struct xen_netbk *netbk,
 				 * fields for head tx req will be set
 				 * to correct values after the loop.
 				 */
-				netbk->mmap_pages[pending_idx] = (void *)(~0UL);
+				netbk->mmap_pages[pending_idx] = PAGE_POOL_INVALID_IDX;
 				pending_tx_info[pending_idx].head =
 					INVALID_PENDING_RING_IDX;
 
@@ -1153,8 +1098,8 @@ static struct gnttab_copy *xen_netbk_get_requests(struct xen_netbk *netbk,
 		first->req.offset = 0;
 		first->req.size = dst_offset;
 		first->head = start_idx;
-		set_page_ext(page, netbk, head_idx);
-		netbk->mmap_pages[head_idx] = page;
+		netbk->mmap_pages[head_idx] = idx;
+		*to_pending_ring_idx(idx) = start_idx;
 		frag_set_pending_idx(&frags[shinfo->nr_frags], head_idx);
 	}
 
@@ -1263,7 +1208,7 @@ static void xen_netbk_fill_frags(struct xen_netbk *netbk, struct sk_buff *skb)
 		skb->truesize += txp->size;
 
 		/* Take an extra reference to offset xen_netbk_idx_release */
-		get_page(netbk->mmap_pages[pending_idx]);
+		get_page(to_page(netbk->mmap_pages[pending_idx]));
 		xen_netbk_idx_release(netbk, pending_idx, XEN_NETIF_RSP_OKAY);
 	}
 }
@@ -1707,11 +1652,7 @@ static void xen_netbk_idx_release(struct xen_netbk *netbk, u16 pending_idx,
 	pending_ring_idx_t head;
 	u16 peek; /* peek into next tx request */
 
-	BUG_ON(netbk->mmap_pages[pending_idx] == (void *)(~0UL));
-
-	/* Already complete? */
-	if (netbk->mmap_pages[pending_idx] == NULL)
-		return;
+	BUG_ON(netbk->mmap_pages[pending_idx] == PAGE_POOL_INVALID_IDX);
 
 	pending_tx_info = &netbk->pending_tx_info[pending_idx];
 
@@ -1744,9 +1685,8 @@ static void xen_netbk_idx_release(struct xen_netbk *netbk, u16 pending_idx,
 
 	} while (!pending_tx_is_head(netbk, peek));
 
-	netbk->mmap_pages[pending_idx]->mapping = 0;
-	put_page(netbk->mmap_pages[pending_idx]);
-	netbk->mmap_pages[pending_idx] = NULL;
+	page_pool_put(netbk->mmap_pages[pending_idx]);
+	netbk->mmap_pages[pending_idx] = PAGE_POOL_INVALID_IDX;
 }
 
 
@@ -1883,6 +1823,7 @@ static int __init netback_init(void)
 	int i;
 	int rc = 0;
 	int group;
+	unsigned int pool_size;
 
 	if (!xen_domain())
 		return -ENODEV;
@@ -1936,12 +1877,19 @@ static int __init netback_init(void)
 		wake_up_process(netbk->task);
 	}
 
-	rc = xenvif_xenbus_init();
+	pool_size = num_online_cpus() * pool_entries_per_cpu;
+	rc = page_pool_init(pool_size);
 	if (rc)
 		goto failed_init;
 
+	rc = xenvif_xenbus_init();
+	if (rc)
+		goto failed_init_destroy_pool;
+
 	return 0;
 
+failed_init_destroy_pool:
+	page_pool_destroy();
 failed_init:
 	while (--group >= 0) {
 		struct xen_netbk *netbk = &xen_netbk[group];
@@ -1957,7 +1905,7 @@ module_init(netback_init);
 
 static void __exit netback_fini(void)
 {
-	int i, j;
+	int i;
 
 	xenvif_xenbus_fini();
 
@@ -1965,13 +1913,11 @@ static void __exit netback_fini(void)
 		struct xen_netbk *netbk = &xen_netbk[i];
 		del_timer_sync(&netbk->net_timer);
 		kthread_stop(netbk->task);
-		for (j = 0; j < MAX_PENDING_REQS; j++) {
-			if (netbk->mmap_pages[i])
-				__free_page(netbk->mmap_pages[i]);
-		}
 	}
 
 	vfree(xen_netbk);
+
+	page_pool_destroy();
 }
 module_exit(netback_fini);
 
diff --git a/drivers/net/xen-netback/page_pool.c b/drivers/net/xen-netback/page_pool.c
new file mode 100644
index 0000000..ae1224b
--- /dev/null
+++ b/drivers/net/xen-netback/page_pool.c
@@ -0,0 +1,186 @@
+/*
+ * Global page pool for Xen netback.
+ *
+ * Wei Liu <wei.liu2@citrix.com>
+ * Copyright (c) Citrix Systems
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation; or, when distributed
+ * separately from the Linux kernel or incorporated into other
+ * software packages, subject to the following license:
+ *
+ * Permission is hereby granted, free of charge, to any person obtaining a copy
+ * of this source file (the "Software"), to deal in the Software without
+ * restriction, including without limitation the rights to use, copy, modify,
+ * merge, publish, distribute, sublicense, and/or sell copies of the Software,
+ * and to permit persons to whom the Software is furnished to do so, subject to
+ * the following conditions:
+ *
+ * The above copyright notice and this permission notice shall be included in
+ * all copies or substantial portions of the Software.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
+ * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
+ * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
+ * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
+ * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
+ * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
+ * IN THE SOFTWARE.
+ */
+
+#include "common.h"
+#include "page_pool.h"
+#include <asm/xen/page.h>
+
+static int32_t free_head;
+static int free_count;
+static unsigned int pool_size;
+static DEFINE_SPINLOCK(pool_lock);
+static struct page_pool_entry *pool;
+
+static int32_t get_free_entry(void)
+{
+	int32_t idx;
+
+	spin_lock(&pool_lock);
+
+	if (free_count == 0) {
+		spin_unlock(&pool_lock);
+		return -ENOSPC;
+	}
+
+	idx = free_head;
+	free_count--;
+	free_head = pool[idx].u.link;
+	pool[idx].u.link = PAGE_POOL_INVALID_IDX;
+
+	spin_unlock(&pool_lock);
+
+	return idx;
+}
+
+static void put_free_entry(int32_t idx)
+{
+	spin_lock(&pool_lock);
+
+	pool[idx].u.link = free_head;
+	free_head = idx;
+	free_count++;
+
+	spin_unlock(&pool_lock);
+}
+
+static inline void set_page_ext(struct page *page, int32_t idx)
+{
+	union page_ext ext = { .idx = idx };
+
+	BUILD_BUG_ON(sizeof(ext) > sizeof(ext.mapping));
+	page->mapping = ext.mapping;
+}
+
+static int get_page_ext(struct page *page, int32_t *pidx)
+{
+	union page_ext ext = { .mapping = page->mapping };
+	int32_t idx;
+
+	idx = ext.idx;
+
+	if ((idx < 0) || (idx >= pool_size))
+		return 0;
+
+	if (pool[idx].page != page)
+		return 0;
+
+	*pidx = idx;
+
+	return 1;
+}
+
+
+int is_in_pool(struct page *page, int32_t *pidx)
+{
+	return get_page_ext(page, pidx);
+}
+
+struct page *page_pool_get(struct xen_netbk *netbk, int32_t *pidx)
+{
+	int32_t idx;
+	struct page *page;
+
+	idx = get_free_entry();
+
+	if (idx < 0)
+		return NULL;
+
+	page = alloc_page(GFP_ATOMIC);
+
+	if (page == NULL) {
+		put_free_entry(idx);
+		return NULL;
+	}
+
+	set_page_ext(page, idx);
+	pool[idx].u.netbk = netbk;
+	pool[idx].page = page;
+
+	*pidx = idx;
+
+	return page;
+}
+
+void page_pool_put(int32_t idx)
+{
+	struct page *page = pool[idx].page;
+
+	pool[idx].page = NULL;
+	pool[idx].u.netbk = NULL;
+	page->mapping = NULL;
+	put_page(page);
+	put_free_entry(idx);
+}
+
+int page_pool_init(unsigned int size)
+{
+	int i;
+
+	pool = vzalloc(sizeof(struct page_pool_entry) * size);
+
+	if (!pool)
+		return -ENOMEM;
+
+	pool_size = size;
+	for (i = 0; i < pool_size - 1; i++)
+		pool[i].u.link = i + 1;
+	pool[pool_size - 1].u.link = PAGE_POOL_INVALID_IDX;
+	free_count = pool_size;
+	free_head = 0;
+
+	return 0;
+}
+
+void page_pool_destroy()
+{
+	int i;
+
+	for (i = 0; i < pool_size; i++)
+		if (pool[i].page)
+			put_page(pool[i].page);
+
+	vfree(pool);
+}
+
+struct page *to_page(int32_t idx)
+{
+	return pool[idx].page;
+}
+
+struct xen_netbk *to_netbk(int32_t idx)
+{
+	return pool[idx].u.netbk;
+}
+
+pending_ring_idx_t *to_pending_ring_idx(int32_t idx)
+{
+	return &pool[idx].pending_ring_idx;
+}
diff --git a/drivers/net/xen-netback/page_pool.h b/drivers/net/xen-netback/page_pool.h
new file mode 100644
index 0000000..b8c10f6
--- /dev/null
+++ b/drivers/net/xen-netback/page_pool.h
@@ -0,0 +1,60 @@
+/*
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation; or, when distributed
+ * separately from the Linux kernel or incorporated into other
+ * software packages, subject to the following license:
+ *
+ * Permission is hereby granted, free of charge, to any person obtaining a copy
+ * of this source file (the "Software"), to deal in the Software without
+ * restriction, including without limitation the rights to use, copy, modify,
+ * merge, publish, distribute, sublicense, and/or sell copies of the Software,
+ * and to permit persons to whom the Software is furnished to do so, subject to
+ * the following conditions:
+ *
+ * The above copyright notice and this permission notice shall be included in
+ * all copies or substantial portions of the Software.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
+ * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
+ * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
+ * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
+ * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
+ * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
+ * IN THE SOFTWARE.
+ */
+
+#ifndef __NETBK_PAGE_POOL_H__
+#define __NETBK_PAGE_POOL_H__
+
+#include "common.h"
+
+#define PAGE_POOL_DEFAULT_ENTRIES_PER_CPU 1024
+#define PAGE_POOL_INVALID_IDX   (-1)
+
+struct page_pool_entry {
+	struct page *page;
+	pending_ring_idx_t pending_ring_idx;
+	union {
+		struct xen_netbk *netbk;
+		int32_t link;
+	} u;
+};
+
+union page_ext {
+	int32_t idx;
+	void *mapping;
+};
+
+int page_pool_init(unsigned int size);
+void page_pool_destroy(void);
+
+struct page *page_pool_get(struct xen_netbk *netbk, int32_t *pidx);
+void page_pool_put(int32_t idx);
+int is_in_pool(struct page *page, int32_t *pidx);
+
+struct page *to_page(int32_t idx);
+struct xen_netbk *to_netbk(int32_t idx);
+pending_ring_idx_t *to_pending_ring_idx(int32_t idx);
+
+#endif /* __NETBK_PAGE_POOL_H__ */
-- 
1.7.10.4
