From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next v3 1/2] net: implement dma cache skb allocator
Date: Tue, 10 Mar 2015 23:13:03 +0530
Message-ID: <1426009384-11544-2-git-send-email-_govind@gmx.com>
References: <1426009384-11544-1-git-send-email-_govind@gmx.com>
Cc: ssujith@cisco.com, benve@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.19]:59295 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753306AbbCJRna (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Mar 2015 13:43:30 -0400
In-Reply-To: <1426009384-11544-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements dma cache skb allocator. This is based on
__alloc_page_frag & __page_frag_refill implementation in net/core/skbuff.c

In addition to frag allocation from order(3) page in __alloc_page_frag,
we also maintain dma address of the page. While allocating a frag for skb
we use va + offset for virtual address of the frag, and pa + offset for
dma address of the frag. This reduces the number of calls to dma_map() by 1/3
for 9000 bytes and by 1/20 for 1500 bytes.

__alloc_page_frag is limited to max buffer size of PAGE_SIZE, i.e 4096 in most
of the cases. So 9k buffer allocation goes through kmalloc which return
page of order 2, 16k. We waste 7k bytes for every 9k buffer.

we maintain dma_count variable which is incremented when we allocate a frag.
netdev_dma_frag_unmap() will decrement the dma_count and unmap it when there is
no user of that page.

This reduces the memory utilization for 9k mtu by 33%.

The user of dma cache allocator first calls netdev_dma_init() to initialize the
dma_head structure. User can allocate a dma frag by calling
netdev_dma_alloc_skb(), allocated skb is returned and dma_addr is stored in the
pointer *dma_addr passed to the function. Every call to this function should
have corresponding call to netdev_dma_frag_unmap() to unmap the page.

At last netdev_dma_destroy() is called to clean to dma_cache. Before calling
destroy(), user should have unmapped all the skb allocated.

All calls to these function should be mutually exclusive. It is the
responsibility of the caller to satisfy this condition. Since this will be
mostly used for rx buffer allocation, where unmap,allocation is serialized, we
can avoid using locks.

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 include/linux/skbuff.h |  22 ++++++
 net/core/skbuff.c      | 209 +++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 231 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index bba1330..ae2d024 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2153,6 +2153,28 @@ static inline struct sk_buff *dev_alloc_skb(unsigned int length)
 	return netdev_alloc_skb(NULL, length);
 }
 
+struct netdev_dma_node {
+	struct page_frag	frag;
+	unsigned int		pagecnt_bias;
+	int			dma_count;
+	void			*va;
+	dma_addr_t		dma_addr;
+};
+
+struct netdev_dma_head {
+	struct netdev_dma_node	*nc;
+	struct device		*dev;
+	gfp_t			gfp;
+};
+
+void netdev_dma_destroy(struct netdev_dma_head *nc_head);
+void netdev_dma_frag_unmap(struct netdev_dma_head *nc_head,
+			   struct netdev_dma_node *nc);
+void netdev_dma_init(struct netdev_dma_head *nc_head, struct device *dev,
+		     gfp_t gfp);
+struct sk_buff *netdev_dma_alloc_skb(struct netdev_dma_head *nc_head,
+				     struct netdev_dma_node **nc_node,
+				     dma_addr_t *dma_addr, size_t sz);
 
 static inline struct sk_buff *__netdev_alloc_skb_ip_align(struct net_device *dev,
 		unsigned int length, gfp_t gfp)
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 47c3241..ec3c46c 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -79,6 +79,7 @@
 
 struct kmem_cache *skbuff_head_cache __read_mostly;
 static struct kmem_cache *skbuff_fclone_cache __read_mostly;
+struct kmem_cache *netdev_dma_cache __read_mostly;
 
 /**
  *	skb_panic - private function for out-of-line support
@@ -361,6 +362,210 @@ static struct page *__page_frag_refill(struct netdev_alloc_cache *nc,
 	return page;
 }
 
+static void __dma_cache_refill(struct netdev_dma_head *nc_head, size_t sz)
+{
+	struct netdev_dma_node *nc;
+	gfp_t gfp_comp = nc_head->gfp | __GFP_COMP | __GFP_NOWARN |
+			 __GFP_NORETRY;
+	u8 order = NETDEV_FRAG_PAGE_MAX_ORDER;
+
+	nc = kmem_cache_alloc(netdev_dma_cache, GFP_ATOMIC);
+	nc_head->nc = nc;
+	if (unlikely(!nc))
+		return;
+
+	if (unlikely(sz > (PAGE_SIZE << NETDEV_FRAG_PAGE_MAX_ORDER)))
+		goto precise_order;
+
+	nc->frag.page = alloc_pages_node(NUMA_NO_NODE, gfp_comp, order);
+	if (unlikely(!nc->frag.page)) {
+precise_order:
+		order = get_order(sz);
+		nc->frag.page = alloc_pages_node(NUMA_NO_NODE, nc_head->gfp,
+						 order);
+		if (!nc->frag.page)
+			goto free_nc;
+	}
+
+	nc->frag.size = (PAGE_SIZE << order);
+	nc->dma_addr = dma_map_page(nc_head->dev, nc->frag.page, 0,
+				    nc->frag.size, DMA_FROM_DEVICE);
+	if (unlikely(dma_mapping_error(nc_head->dev, nc->dma_addr)))
+		goto free_page;
+	nc->va = page_address(nc->frag.page);
+	atomic_add(nc->frag.size - 1, &nc->frag.page->_count);
+	nc->pagecnt_bias = nc->frag.size;
+	nc->frag.offset = nc->frag.size;
+	nc->dma_count = 0;
+
+	return;
+
+free_page:
+	__free_pages(nc->frag.page, order);
+free_nc:
+	kmem_cache_free(netdev_dma_cache, nc);
+	nc_head->nc = NULL;
+}
+
+static struct netdev_dma_node *netdev_dma_alloc(struct netdev_dma_head *nc_head,
+						size_t sz)
+{
+	struct netdev_dma_node *nc = nc_head->nc;
+	int offset;
+
+	if (unlikely(!nc)) {
+refill:
+		__dma_cache_refill(nc_head, sz);
+		nc = nc_head->nc;
+		if (unlikely(!nc))
+			return NULL;
+	}
+
+	offset = nc->frag.offset - sz;
+	if (offset < 0) {
+		if (!atomic_sub_and_test(nc->pagecnt_bias,
+					 &nc->frag.page->_count)) {
+			/* the caller has processed all the frags belonging to
+			 * this page. Since page->_count is not 0 and
+			 * nc->dma_count is 0 these frags should be in stack.
+			 * We should unmap the page here.
+			 */
+			if (!nc->dma_count) {
+				dma_unmap_single(nc_head->dev, nc->dma_addr,
+						 nc->frag.size,
+						 DMA_FROM_DEVICE);
+				kmem_cache_free(netdev_dma_cache, nc);
+			} else {
+			/* frags from this page are used by the caller. Let the
+			 * caller unmap the page using netdev_dma_frag_unmap().
+			 */
+				nc->pagecnt_bias = 0;
+			}
+			goto refill;
+		}
+		WARN_ON(nc->dma_count);
+		atomic_set(&nc->frag.page->_count, nc->frag.size);
+		nc->pagecnt_bias = nc->frag.size;
+		offset = nc->frag.size - sz;
+	}
+	nc->pagecnt_bias--;
+	nc->dma_count++;
+	nc->frag.offset = offset;
+
+	return nc;
+}
+
+/* netdev_dma_alloc_skb - alloc skb with dma mapped data
+ * @nc_head:	initialized netdev_dma_head from which allocation should be
+ *		done.
+ * @nc_node:	Corresponding dma_node is stored in this. The caller needs to
+ *		save this and use it for netdev_dma_frag_unmap() to unmap
+ *		page frag later.
+ * @dma_addr:	dma address of the data is stored here.
+ * @sz:		size of data needed.
+ *
+ * Allocates skb from dma cached page. This function returns allocated skb_buff
+ * from the provided netdev_dma_head cache. It stores the dma address in
+ * dma_addr.
+ *
+ * All the calls to netdev_dma_alloc_skb(), netdev_dma_frag_unmap(),
+ * netdev_dma_init(), netdev_dma_destroy() should be mutually exclusive for a
+ * dma_head. It is the responsibility of the caller to satisfy this condition.
+ * Since this is mostly used for rx buffer allocation, where unmap,allocation
+ * is serialized we can avoid using locks.
+ */
+struct sk_buff *netdev_dma_alloc_skb(struct netdev_dma_head *nc_head,
+				     struct netdev_dma_node **nc_node,
+				     dma_addr_t *dma_addr, size_t sz)
+{
+	struct sk_buff *skb;
+	struct netdev_dma_node *nc;
+	void *va;
+
+	sz = sz + NET_IP_ALIGN + NET_SKB_PAD;
+	sz = SKB_DATA_ALIGN(sz) +
+	     SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
+	nc = netdev_dma_alloc(nc_head, sz);
+	if (unlikely(!nc))
+		return NULL;
+	va = nc->va + nc->frag.offset;
+	skb = build_skb(va, sz);
+	if (unlikely(!skb)) {
+		nc->pagecnt_bias++;
+		nc->frag.offset += sz;
+		nc->dma_count--;
+
+		return NULL;
+	}
+
+	skb_reserve(skb, NET_SKB_PAD + NET_IP_ALIGN);
+	*dma_addr = nc->dma_addr + nc->frag.offset + NET_SKB_PAD + NET_IP_ALIGN;
+	*nc_node = nc;
+
+	return skb;
+}
+EXPORT_SYMBOL_GPL(netdev_dma_alloc_skb);
+
+/* netdev_dma_init - initialize dma cache head
+ * @nc_head:	dma_head to be initialized
+ * @dev:	device for dma map
+ * @gfp:	gfp flagg for allocating page
+ *
+ * initializes dma_head with provided gfp flags and device
+ */
+void netdev_dma_init(struct netdev_dma_head *nc_head, struct device *dev,
+		     gfp_t gfp)
+{
+	nc_head->nc = NULL;
+	nc_head->dev = dev;
+	nc_head->gfp = gfp;
+}
+EXPORT_SYMBOL_GPL(netdev_dma_init);
+
+/* netdev_dma_frag_unmap - unmap page
+ * @nc_head:	dma_head of page frag allocator
+ * @nc:		dma_node to be unmapped
+ *
+ * unmaps requested page if there are no dma references to the page
+ */
+void netdev_dma_frag_unmap(struct netdev_dma_head *nc_head,
+			   struct netdev_dma_node *nc)
+{
+	/* If nc is not used by dma_head. We should be free to unmap the
+	 * page if there are no pending dma frags addr used by the caller.
+	 */
+	if (!--nc->dma_count && !nc->pagecnt_bias) {
+		dma_unmap_page(nc_head->dev, nc->dma_addr, nc->frag.size,
+			       DMA_FROM_DEVICE);
+		kmem_cache_free(netdev_dma_cache, nc);
+	}
+}
+EXPORT_SYMBOL_GPL(netdev_dma_frag_unmap);
+
+/* netdev_dma_destroy - destroy dma_head
+ * @nc_head:	dma_head to be destroyed
+ *
+ * unmap the current dma_page and free the page. Caller should have called
+ * netdev_dma_frag_unmap() for all the allocated frages before calling this
+ * function.
+ */
+void netdev_dma_destroy(struct netdev_dma_head *nc_head)
+{
+	struct netdev_dma_node *nc = nc_head->nc;
+
+	if (unlikely(!nc))
+		return;
+	if (WARN_ON(nc->dma_count))
+		return;
+	dma_unmap_page(nc_head->dev, nc->dma_addr, nc->frag.size,
+		       DMA_FROM_DEVICE);
+	atomic_sub(nc->pagecnt_bias - 1, &nc->frag.page->_count);
+	__free_pages(nc->frag.page, get_order(nc->frag.size));
+	kmem_cache_free(netdev_dma_cache, nc);
+	nc_head->nc = NULL;
+}
+EXPORT_SYMBOL_GPL(netdev_dma_destroy);
+
 static void *__alloc_page_frag(struct netdev_alloc_cache __percpu *cache,
 			       unsigned int fragsz, gfp_t gfp_mask)
 {
@@ -3324,6 +3529,10 @@ void __init skb_init(void)
 						0,
 						SLAB_HWCACHE_ALIGN|SLAB_PANIC,
 						NULL);
+	netdev_dma_cache = kmem_cache_create("netdev_dma_cache",
+					     sizeof(struct netdev_dma_node),
+					     0, SLAB_HWCACHE_ALIGN | SLAB_PANIC,
+					     NULL);
 }
 
 /**
-- 
2.3.2
