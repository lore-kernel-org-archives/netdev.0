From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 01/12] net/mlx4_en: Reuse mapped memory in RX flow
Date: Sun,  8 Dec 2013 14:35:41 +0200
Message-ID: <1386506152-10298-2-git-send-email-amirv@mellanox.com>
References: <1386506152-10298-1-git-send-email-amirv@mellanox.com>
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	Eugenia Emantayev <eugenia@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:40351 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753503Ab3LHMgM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Dec 2013 07:36:12 -0500
In-Reply-To: <1386506152-10298-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

In receive flow use one fragment instead of multiple fragments.
Always allocate at least twice memory than needed for current MTU
and on each cycle use one hunk of the mapped memory.
Realloc and map new page only if this page was not freed.
This behavior allows to save unnecessary dma (un)mapping
operations that are very expensive when IOMMU is enabled.


Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |  12 +-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c     | 723 +++++++++----------------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |  56 +-
 3 files changed, 299 insertions(+), 492 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 709e5ec..9270006 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1490,7 +1490,11 @@ int mlx4_en_start_port(struct net_device *dev)
 
 	/* Calculate Rx buf size */
 	dev->mtu = min(dev->mtu, priv->max_mtu);
-	mlx4_en_calc_rx_buf(dev);
+	priv->rx_skb_size = dev->mtu + ETH_HLEN + VLAN_HLEN;
+	priv->rx_buf_size = roundup_pow_of_two(priv->rx_skb_size);
+	priv->rx_alloc_size = max_t(int, 2 * priv->rx_buf_size, PAGE_SIZE);
+	priv->rx_alloc_order = get_order(priv->rx_alloc_size);
+	priv->log_rx_info = ROUNDUP_LOG2(sizeof(struct mlx4_en_rx_buf));
 	en_dbg(DRV, priv, "Rx buf size:%d\n", priv->rx_skb_size);
 
 	/* Configure rx cq's and rings */
@@ -1923,7 +1927,7 @@ int mlx4_en_alloc_resources(struct mlx4_en_priv *priv)
 			goto err;
 
 		if (mlx4_en_create_rx_ring(priv, &priv->rx_ring[i],
-					   prof->rx_ring_size, priv->stride,
+					   prof->rx_ring_size,
 					   node))
 			goto err;
 	}
@@ -2316,7 +2320,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	memcpy(priv->prev_mac, dev->dev_addr, sizeof(priv->prev_mac));
 
 	priv->stride = roundup_pow_of_two(sizeof(struct mlx4_en_rx_desc) +
-					  DS_SIZE * MLX4_EN_MAX_RX_FRAGS);
+					  DS_SIZE);
 	err = mlx4_en_alloc_resources(priv);
 	if (err)
 		goto out;
@@ -2393,7 +2397,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	mlx4_en_update_loopback_state(priv->dev, priv->dev->features);
 
 	/* Configure port */
-	mlx4_en_calc_rx_buf(dev);
+	priv->rx_skb_size = dev->mtu + ETH_HLEN + VLAN_HLEN;
 	err = mlx4_SET_PORT_general(mdev->dev, priv->port,
 				    priv->rx_skb_size + ETH_FCS_LEN,
 				    prof->tx_pause, prof->tx_ppp,
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 07a1d0f..965c021 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -43,197 +43,72 @@
 
 #include "mlx4_en.h"
 
-static int mlx4_alloc_pages(struct mlx4_en_priv *priv,
-			    struct mlx4_en_rx_alloc *page_alloc,
-			    const struct mlx4_en_frag_info *frag_info,
-			    gfp_t _gfp)
+static int mlx4_en_alloc_frag(struct mlx4_en_priv *priv,
+			      struct mlx4_en_rx_ring *ring,
+			      struct mlx4_en_rx_desc *rx_desc,
+			      struct mlx4_en_rx_buf *rx_buf,
+			      enum mlx4_en_alloc_type type)
 {
-	int order;
+	struct device *dev = priv->ddev;
 	struct page *page;
-	dma_addr_t dma;
-
-	for (order = MLX4_EN_ALLOC_PREFER_ORDER; ;) {
-		gfp_t gfp = _gfp;
-
-		if (order)
-			gfp |= __GFP_COMP | __GFP_NOWARN;
-		page = alloc_pages(gfp, order);
-		if (likely(page))
-			break;
-		if (--order < 0 ||
-		    ((PAGE_SIZE << order) < frag_info->frag_size))
+	dma_addr_t dma = 0;
+	gfp_t gfp = GFP_ATOMIC | __GFP_COLD | __GFP_COMP | __GFP_NOWARN;
+
+	/* alloc new page */
+	page = alloc_pages_node(ring->numa_node, gfp, ring->rx_alloc_order);
+	if (unlikely(!page)) {
+		page = alloc_pages(gfp, ring->rx_alloc_order);
+		if (unlikely(!page))
 			return -ENOMEM;
 	}
-	dma = dma_map_page(priv->ddev, page, 0, PAGE_SIZE << order,
-			   PCI_DMA_FROMDEVICE);
-	if (dma_mapping_error(priv->ddev, dma)) {
-		put_page(page);
-		return -ENOMEM;
-	}
-	page_alloc->page_size = PAGE_SIZE << order;
-	page_alloc->page = page;
-	page_alloc->dma = dma;
-	page_alloc->page_offset = frag_info->frag_align;
-	/* Not doing get_page() for each frag is a big win
-	 * on asymetric workloads.
-	 */
-	atomic_set(&page->_count,
-		   page_alloc->page_size / frag_info->frag_stride);
-	return 0;
-}
 
-static int mlx4_en_alloc_frags(struct mlx4_en_priv *priv,
-			       struct mlx4_en_rx_desc *rx_desc,
-			       struct mlx4_en_rx_alloc *frags,
-			       struct mlx4_en_rx_alloc *ring_alloc,
-			       gfp_t gfp)
-{
-	struct mlx4_en_rx_alloc page_alloc[MLX4_EN_MAX_RX_FRAGS];
-	const struct mlx4_en_frag_info *frag_info;
-	struct page *page;
-	dma_addr_t dma;
-	int i;
-
-	for (i = 0; i < priv->num_frags; i++) {
-		frag_info = &priv->frag_info[i];
-		page_alloc[i] = ring_alloc[i];
-		page_alloc[i].page_offset += frag_info->frag_stride;
-
-		if (page_alloc[i].page_offset + frag_info->frag_stride <=
-		    ring_alloc[i].page_size)
-			continue;
-
-		if (mlx4_alloc_pages(priv, &page_alloc[i], frag_info, gfp))
-			goto out;
-	}
+	/* map new page */
+	dma = dma_map_page(dev, page, 0,
+			   ring->rx_alloc_size, DMA_FROM_DEVICE);
 
-	for (i = 0; i < priv->num_frags; i++) {
-		frags[i] = ring_alloc[i];
-		dma = ring_alloc[i].dma + ring_alloc[i].page_offset;
-		ring_alloc[i] = page_alloc[i];
-		rx_desc->data[i].addr = cpu_to_be64(dma);
-	}
-
-	return 0;
-
-out:
-	while (i--) {
-		frag_info = &priv->frag_info[i];
-		if (page_alloc[i].page != ring_alloc[i].page) {
-			dma_unmap_page(priv->ddev, page_alloc[i].dma,
-				page_alloc[i].page_size, PCI_DMA_FROMDEVICE);
-			page = page_alloc[i].page;
-			atomic_set(&page->_count, 1);
-			put_page(page);
-		}
+	/* free memory if mapping failed */
+	if (dma_mapping_error(dev, dma)) {
+		__free_pages(page, ring->rx_alloc_order);
+		return -ENOMEM;
 	}
-	return -ENOMEM;
-}
-
-static void mlx4_en_free_frag(struct mlx4_en_priv *priv,
-			      struct mlx4_en_rx_alloc *frags,
-			      int i)
-{
-	const struct mlx4_en_frag_info *frag_info = &priv->frag_info[i];
-	u32 next_frag_end = frags[i].page_offset + 2 * frag_info->frag_stride;
-
-
-	if (next_frag_end > frags[i].page_size)
-		dma_unmap_page(priv->ddev, frags[i].dma, frags[i].page_size,
-			       PCI_DMA_FROMDEVICE);
-
-	if (frags[i].page)
-		put_page(frags[i].page);
-}
-
-static int mlx4_en_init_allocator(struct mlx4_en_priv *priv,
-				  struct mlx4_en_rx_ring *ring)
-{
-	int i;
-	struct mlx4_en_rx_alloc *page_alloc;
-
-	for (i = 0; i < priv->num_frags; i++) {
-		const struct mlx4_en_frag_info *frag_info = &priv->frag_info[i];
 
-		if (mlx4_alloc_pages(priv, &ring->page_alloc[i],
-				     frag_info, GFP_KERNEL))
-			goto out;
-	}
+	/* allocation of replacement page was successfull,
+	 * therefore unmap the old one and set the new page
+	 * for HW use
+	 */
+	if (type == MLX4_EN_ALLOC_REPLACEMENT)
+		dma_unmap_page(dev, rx_buf->dma,
+			       ring->rx_alloc_size,
+			       DMA_FROM_DEVICE);
+
+	rx_buf->page = page;
+	rx_buf->dma = dma;
+	rx_buf->page_offset = 0;
+	rx_desc->data[0].addr = cpu_to_be64(dma);
 	return 0;
-
-out:
-	while (i--) {
-		struct page *page;
-
-		page_alloc = &ring->page_alloc[i];
-		dma_unmap_page(priv->ddev, page_alloc->dma,
-			       page_alloc->page_size, PCI_DMA_FROMDEVICE);
-		page = page_alloc->page;
-		atomic_set(&page->_count, 1);
-		put_page(page);
-		page_alloc->page = NULL;
-	}
-	return -ENOMEM;
-}
-
-static void mlx4_en_destroy_allocator(struct mlx4_en_priv *priv,
-				      struct mlx4_en_rx_ring *ring)
-{
-	struct mlx4_en_rx_alloc *page_alloc;
-	int i;
-
-	for (i = 0; i < priv->num_frags; i++) {
-		const struct mlx4_en_frag_info *frag_info = &priv->frag_info[i];
-
-		page_alloc = &ring->page_alloc[i];
-		en_dbg(DRV, priv, "Freeing allocator:%d count:%d\n",
-		       i, page_count(page_alloc->page));
-
-		dma_unmap_page(priv->ddev, page_alloc->dma,
-				page_alloc->page_size, PCI_DMA_FROMDEVICE);
-		while (page_alloc->page_offset + frag_info->frag_stride <
-		       page_alloc->page_size) {
-			put_page(page_alloc->page);
-			page_alloc->page_offset += frag_info->frag_stride;
-		}
-		page_alloc->page = NULL;
-	}
 }
 
 static void mlx4_en_init_rx_desc(struct mlx4_en_priv *priv,
-				 struct mlx4_en_rx_ring *ring, int index)
+				 struct mlx4_en_rx_ring *ring,
+				 int index)
 {
 	struct mlx4_en_rx_desc *rx_desc = ring->buf + ring->stride * index;
-	int possible_frags;
-	int i;
-
-	/* Set size and memtype fields */
-	for (i = 0; i < priv->num_frags; i++) {
-		rx_desc->data[i].byte_count =
-			cpu_to_be32(priv->frag_info[i].frag_size);
-		rx_desc->data[i].lkey = cpu_to_be32(priv->mdev->mr.key);
-	}
 
-	/* If the number of used fragments does not fill up the ring stride,
-	 * remaining (unused) fragments must be padded with null address/size
-	 * and a special memory key */
-	possible_frags = (ring->stride - sizeof(struct mlx4_en_rx_desc)) / DS_SIZE;
-	for (i = priv->num_frags; i < possible_frags; i++) {
-		rx_desc->data[i].byte_count = 0;
-		rx_desc->data[i].lkey = cpu_to_be32(MLX4_EN_MEMTYPE_PAD);
-		rx_desc->data[i].addr = 0;
-	}
+	rx_desc->data[0].byte_count =
+		cpu_to_be32(ring->rx_buf_size);
+	rx_desc->data[0].lkey = cpu_to_be32(priv->mdev->mr.key);
 }
 
 static int mlx4_en_prepare_rx_desc(struct mlx4_en_priv *priv,
-				   struct mlx4_en_rx_ring *ring, int index,
-				   gfp_t gfp)
+				   struct mlx4_en_rx_ring *ring,
+				   int index)
 {
-	struct mlx4_en_rx_desc *rx_desc = ring->buf + (index * ring->stride);
-	struct mlx4_en_rx_alloc *frags = ring->rx_info +
-					(index << priv->log_rx_info);
+	struct mlx4_en_rx_desc *rx_desc = ring->buf + ring->stride * index;
+	struct mlx4_en_rx_buf *rx_buf = &ring->rx_info[index];
+
+	return mlx4_en_alloc_frag(priv, ring, rx_desc, rx_buf,
+				  MLX4_EN_ALLOC_NEW);
 
-	return mlx4_en_alloc_frags(priv, rx_desc, frags, ring->page_alloc, gfp);
 }
 
 static inline void mlx4_en_update_rx_prod_db(struct mlx4_en_rx_ring *ring)
@@ -243,16 +118,17 @@ static inline void mlx4_en_update_rx_prod_db(struct mlx4_en_rx_ring *ring)
 
 static void mlx4_en_free_rx_desc(struct mlx4_en_priv *priv,
 				 struct mlx4_en_rx_ring *ring,
-				 int index)
+				 struct mlx4_en_rx_desc *rx_desc,
+				 struct mlx4_en_rx_buf *rx_buf)
 {
-	struct mlx4_en_rx_alloc *frags;
-	int nr;
-
-	frags = ring->rx_info + (index << priv->log_rx_info);
-	for (nr = 0; nr < priv->num_frags; nr++) {
-		en_dbg(DRV, priv, "Freeing fragment:%d\n", nr);
-		mlx4_en_free_frag(priv, frags, nr);
-	}
+	dma_unmap_page(priv->ddev, rx_buf->dma,
+		       ring->rx_alloc_size, DMA_FROM_DEVICE);
+	put_page(rx_buf->page);
+
+	rx_buf->dma = 0;
+	rx_buf->page = NULL;
+	rx_buf->page_offset = 0;
+	rx_desc->data[0].addr = 0;
 }
 
 static int mlx4_en_fill_rx_buffers(struct mlx4_en_priv *priv)
@@ -261,22 +137,21 @@ static int mlx4_en_fill_rx_buffers(struct mlx4_en_priv *priv)
 	int ring_ind;
 	int buf_ind;
 	int new_size;
+	struct mlx4_en_rx_desc *rx_desc;
+	struct mlx4_en_rx_buf *rx_buf;
 
 	for (buf_ind = 0; buf_ind < priv->prof->rx_ring_size; buf_ind++) {
 		for (ring_ind = 0; ring_ind < priv->rx_ring_num; ring_ind++) {
 			ring = priv->rx_ring[ring_ind];
 
 			if (mlx4_en_prepare_rx_desc(priv, ring,
-						    ring->actual_size,
-						    GFP_KERNEL)) {
+						    ring->actual_size)) {
 				if (ring->actual_size < MLX4_EN_MIN_RX_SIZE) {
-					en_err(priv, "Failed to allocate "
-						     "enough rx buffers\n");
+					en_err(priv, "Failed to allocate enough rx buffers\n");
 					return -ENOMEM;
 				} else {
 					new_size = rounddown_pow_of_two(ring->actual_size);
-					en_warn(priv, "Only %d buffers allocated "
-						      "reducing ring size to %d",
+					en_warn(priv, "Only %d buffers allocated reducing ring size to %d\n",
 						ring->actual_size, new_size);
 					goto reduce_rings;
 				}
@@ -293,10 +168,11 @@ reduce_rings:
 		while (ring->actual_size > new_size) {
 			ring->actual_size--;
 			ring->prod--;
-			mlx4_en_free_rx_desc(priv, ring, ring->actual_size);
+			rx_desc = ring->buf + ring->stride * ring->actual_size;
+			rx_buf = &ring->rx_info[ring->actual_size];
+			mlx4_en_free_rx_desc(priv, ring, rx_desc, rx_buf);
 		}
 	}
-
 	return 0;
 }
 
@@ -304,28 +180,34 @@ static void mlx4_en_free_rx_buf(struct mlx4_en_priv *priv,
 				struct mlx4_en_rx_ring *ring)
 {
 	int index;
+	struct mlx4_en_rx_desc *rx_desc;
+	struct mlx4_en_rx_buf *rx_buf;
 
 	en_dbg(DRV, priv, "Freeing Rx buf - cons:%d prod:%d\n",
 	       ring->cons, ring->prod);
 
 	/* Unmap and free Rx buffers */
 	BUG_ON((u32) (ring->prod - ring->cons) > ring->actual_size);
+
 	while (ring->cons != ring->prod) {
 		index = ring->cons & ring->size_mask;
+		rx_desc = ring->buf + ring->stride * index;
+		rx_buf = &ring->rx_info[index];
 		en_dbg(DRV, priv, "Processing descriptor:%d\n", index);
-		mlx4_en_free_rx_desc(priv, ring, index);
+		mlx4_en_free_rx_desc(priv, ring, rx_desc, rx_buf);
 		++ring->cons;
 	}
 }
 
 int mlx4_en_create_rx_ring(struct mlx4_en_priv *priv,
 			   struct mlx4_en_rx_ring **pring,
-			   u32 size, u16 stride, int node)
+			   u32 size, int node)
 {
 	struct mlx4_en_dev *mdev = priv->mdev;
 	struct mlx4_en_rx_ring *ring;
 	int err = -ENOMEM;
 	int tmp;
+	int this_cpu = numa_node_id();
 
 	ring = kzalloc_node(sizeof(*ring), GFP_KERNEL, node);
 	if (!ring) {
@@ -334,21 +216,22 @@ int mlx4_en_create_rx_ring(struct mlx4_en_priv *priv,
 			en_err(priv, "Failed to allocate RX ring structure\n");
 			return -ENOMEM;
 		}
-	}
+		ring->numa_node = this_cpu;
+	} else
+		ring->numa_node = node;
 
 	ring->prod = 0;
 	ring->cons = 0;
 	ring->size = size;
 	ring->size_mask = size - 1;
-	ring->stride = stride;
+	ring->stride = priv->stride;
 	ring->log_stride = ffs(ring->stride) - 1;
 	ring->buf_size = ring->size * ring->stride + TXBB_SIZE;
 
-	tmp = size * roundup_pow_of_two(MLX4_EN_MAX_RX_FRAGS *
-					sizeof(struct mlx4_en_rx_alloc));
-	ring->rx_info = vmalloc_node(tmp, node);
+	tmp = size * roundup_pow_of_two(sizeof(struct mlx4_en_rx_buf));
+	ring->rx_info = vzalloc_node(tmp, node);
 	if (!ring->rx_info) {
-		ring->rx_info = vmalloc(tmp);
+		ring->rx_info = vzalloc(tmp);
 		if (!ring->rx_info) {
 			err = -ENOMEM;
 			goto err_ring;
@@ -397,7 +280,7 @@ int mlx4_en_activate_rx_rings(struct mlx4_en_priv *priv)
 	int ring_ind;
 	int err;
 	int stride = roundup_pow_of_two(sizeof(struct mlx4_en_rx_desc) +
-					DS_SIZE * priv->num_frags);
+					DS_SIZE);
 
 	for (ring_ind = 0; ring_ind < priv->rx_ring_num; ring_ind++) {
 		ring = priv->rx_ring[ring_ind];
@@ -406,6 +289,9 @@ int mlx4_en_activate_rx_rings(struct mlx4_en_priv *priv)
 		ring->cons = 0;
 		ring->actual_size = 0;
 		ring->cqn = priv->rx_cq[ring_ind]->mcq.cqn;
+		ring->rx_alloc_order = priv->rx_alloc_order;
+		ring->rx_alloc_size = priv->rx_alloc_size;
+		ring->rx_buf_size = priv->rx_buf_size;
 
 		ring->stride = stride;
 		if (ring->stride <= TXBB_SIZE)
@@ -420,16 +306,6 @@ int mlx4_en_activate_rx_rings(struct mlx4_en_priv *priv)
 		/* Initialize all descriptors */
 		for (i = 0; i < ring->size; i++)
 			mlx4_en_init_rx_desc(priv, ring, i);
-
-		/* Initialize page allocators */
-		err = mlx4_en_init_allocator(priv, ring);
-		if (err) {
-			en_err(priv, "Failed initializing ring allocator\n");
-			if (ring->stride <= TXBB_SIZE)
-				ring->buf -= TXBB_SIZE;
-			ring_ind--;
-			goto err_allocator;
-		}
 	}
 	err = mlx4_en_fill_rx_buffers(priv);
 	if (err)
@@ -449,13 +325,14 @@ err_buffers:
 		mlx4_en_free_rx_buf(priv, priv->rx_ring[ring_ind]);
 
 	ring_ind = priv->rx_ring_num - 1;
-err_allocator:
+
 	while (ring_ind >= 0) {
-		if (priv->rx_ring[ring_ind]->stride <= TXBB_SIZE)
-			priv->rx_ring[ring_ind]->buf -= TXBB_SIZE;
-		mlx4_en_destroy_allocator(priv, priv->rx_ring[ring_ind]);
+		ring = priv->rx_ring[ring_ind];
+		if (ring->stride <= TXBB_SIZE)
+			ring->buf -= TXBB_SIZE;
 		ring_ind--;
 	}
+
 	return err;
 }
 
@@ -483,95 +360,125 @@ void mlx4_en_deactivate_rx_ring(struct mlx4_en_priv *priv,
 	mlx4_en_free_rx_buf(priv, ring);
 	if (ring->stride <= TXBB_SIZE)
 		ring->buf -= TXBB_SIZE;
-	mlx4_en_destroy_allocator(priv, ring);
 }
 
-
 static int mlx4_en_complete_rx_desc(struct mlx4_en_priv *priv,
-				    struct mlx4_en_rx_desc *rx_desc,
-				    struct mlx4_en_rx_alloc *frags,
-				    struct sk_buff *skb,
-				    int length)
+				     struct mlx4_en_rx_ring *ring,
+				     struct mlx4_en_rx_desc *rx_desc,
+				     struct mlx4_en_rx_buf *rx_buf,
+				     struct sk_buff *skb,
+				     int length)
 {
-	struct skb_frag_struct *skb_frags_rx = skb_shinfo(skb)->frags;
-	struct mlx4_en_frag_info *frag_info;
-	int nr;
-	dma_addr_t dma;
+	struct page *page = rx_buf->page;
+	struct skb_frag_struct *skb_frags_rx;
+	struct device *dev = priv->ddev;
+
+	if (skb) {
+		skb_frags_rx = skb_shinfo(skb)->frags;
+		__skb_frag_set_page(&skb_frags_rx[0], page);
+		skb_frag_size_set(&skb_frags_rx[0], length);
+		skb_frags_rx[0].page_offset = rx_buf->page_offset;
+	}
+
+	/* we are reusing so sync this buffer for CPU use */
+	dma_sync_single_range_for_cpu(dev,
+				      rx_buf->dma,
+				      rx_buf->page_offset,
+				      ring->rx_buf_size,
+				      DMA_FROM_DEVICE);
+	if (ring->rx_alloc_size == 2 * ring->rx_buf_size) {
+		/* if we are exclusive owner of the page we can reuse it,
+		 * otherwise alloc replacement page
+		 */
+		if (unlikely(page_count(page) != 1))
+			goto replace;
 
-	/* Collect used fragments while replacing them in the HW descriptors */
-	for (nr = 0; nr < priv->num_frags; nr++) {
-		frag_info = &priv->frag_info[nr];
-		if (length <= frag_info->frag_prefix_size)
-			break;
-		if (!frags[nr].page)
-			goto fail;
+			/* move page offset to next buffer */
+		rx_buf->page_offset ^= ring->rx_buf_size;
 
-		dma = be64_to_cpu(rx_desc->data[nr].addr);
-		dma_sync_single_for_cpu(priv->ddev, dma, frag_info->frag_size,
-					DMA_FROM_DEVICE);
+		/* increment ref count on page,
+		 * since we are only owner can
+		 * just set it to 2
+		 */
+		atomic_set(&page->_count, 2);
+	} else {
+		if (rx_buf->page_offset + ring->rx_buf_size >=
+		    ring->rx_alloc_size)
+			rx_buf->page_offset = 0;
+		else
+			rx_buf->page_offset += ring->rx_buf_size;
+
+		/* increment ref count on page */
+		get_page(page);
+	}
+
+	rx_desc->data[0].addr = cpu_to_be64(rx_buf->dma + rx_buf->page_offset);
+	/* sync the buffer for use by the device */
+	dma_sync_single_range_for_device(dev, rx_buf->dma,
+					 rx_buf->page_offset,
+					 ring->rx_buf_size,
+					 DMA_FROM_DEVICE);
+	return 0;
 
-		/* Save page reference in skb */
-		__skb_frag_set_page(&skb_frags_rx[nr], frags[nr].page);
-		skb_frag_size_set(&skb_frags_rx[nr], frag_info->frag_size);
-		skb_frags_rx[nr].page_offset = frags[nr].page_offset;
-		skb->truesize += frag_info->frag_stride;
-		frags[nr].page = NULL;
-	}
-	/* Adjust size of last fragment to match actual length */
-	if (nr > 0)
-		skb_frag_size_set(&skb_frags_rx[nr - 1],
-			length - priv->frag_info[nr - 1].frag_prefix_size);
-	return nr;
-
-fail:
-	while (nr > 0) {
-		nr--;
-		__skb_frag_unref(&skb_frags_rx[nr]);
+replace:
+	if (mlx4_en_alloc_frag(priv, ring, rx_desc, rx_buf,
+			       MLX4_EN_ALLOC_REPLACEMENT)) {
+		/* replacement allocation failed, drop and use same page */
+		dma_sync_single_range_for_device(dev, rx_buf->dma,
+						 rx_buf->page_offset,
+						 ring->rx_buf_size,
+						 DMA_FROM_DEVICE);
+		return -ENOMEM;
 	}
 	return 0;
 }
 
-
 static struct sk_buff *mlx4_en_rx_skb(struct mlx4_en_priv *priv,
+				      struct mlx4_en_rx_ring *ring,
 				      struct mlx4_en_rx_desc *rx_desc,
-				      struct mlx4_en_rx_alloc *frags,
+				      struct mlx4_en_rx_buf *rx_buf,
 				      unsigned int length)
 {
+	struct device *dev = priv->ddev;
 	struct sk_buff *skb;
 	void *va;
-	int used_frags;
 	dma_addr_t dma;
 
-	skb = netdev_alloc_skb(priv->dev, SMALL_PACKET_SIZE + NET_IP_ALIGN);
+	skb = netdev_alloc_skb_ip_align(priv->dev, SMALL_PACKET_SIZE);
 	if (!skb) {
 		en_dbg(RX_ERR, priv, "Failed allocating skb\n");
 		return NULL;
 	}
-	skb_reserve(skb, NET_IP_ALIGN);
-	skb->len = length;
+	prefetchw(skb->data);
 
+	skb->len = length;
 	/* Get pointer to first fragment so we could copy the headers into the
-	 * (linear part of the) skb */
-	va = page_address(frags[0].page) + frags[0].page_offset;
+	 * (linear part of the) skb
+	 */
+	va = page_address(rx_buf->page) + rx_buf->page_offset;
+	prefetch(va);
 
 	if (length <= SMALL_PACKET_SIZE) {
 		/* We are copying all relevant data to the skb - temporarily
-		 * sync buffers for the copy */
+		 * sync buffers for the copy
+		 */
 		dma = be64_to_cpu(rx_desc->data[0].addr);
-		dma_sync_single_for_cpu(priv->ddev, dma, length,
+		dma_sync_single_for_cpu(dev, dma, length,
 					DMA_FROM_DEVICE);
 		skb_copy_to_linear_data(skb, va, length);
+		dma_sync_single_for_device(dev, dma, length,
+					   DMA_FROM_DEVICE);
+		skb->truesize = length + sizeof(struct sk_buff);
 		skb->tail += length;
 	} else {
-		/* Move relevant fragments to skb */
-		used_frags = mlx4_en_complete_rx_desc(priv, rx_desc, frags,
-							skb, length);
-		if (unlikely(!used_frags)) {
+		if (mlx4_en_complete_rx_desc(priv, ring, rx_desc,
+					     rx_buf, skb, length)) {
 			kfree_skb(skb);
 			return NULL;
 		}
-		skb_shinfo(skb)->nr_frags = used_frags;
+		skb_shinfo(skb)->nr_frags = 1;
 
+		/* Move relevant fragments to skb */
 		/* Copy headers into the skb linear buffer */
 		memcpy(skb->data, va, HEADER_COPY_SIZE);
 		skb->tail += HEADER_COPY_SIZE;
@@ -582,7 +489,9 @@ static struct sk_buff *mlx4_en_rx_skb(struct mlx4_en_priv *priv,
 		/* Adjust size of first fragment */
 		skb_frag_size_sub(&skb_shinfo(skb)->frags[0], HEADER_COPY_SIZE);
 		skb->data_len = length - HEADER_COPY_SIZE;
+		skb->truesize += ring->rx_buf_size;
 	}
+
 	return skb;
 }
 
@@ -593,44 +502,56 @@ static void validate_loopback(struct mlx4_en_priv *priv, struct sk_buff *skb)
 
 	for (i = 0; i < MLX4_LOOPBACK_TEST_PAYLOAD; i++, offset++) {
 		if (*(skb->data + offset) != (unsigned char) (i & 0xff))
-			goto out_loopback;
+			return;
 	}
 	/* Loopback found */
 	priv->loopback_ok = 1;
-
-out_loopback:
-	dev_kfree_skb_any(skb);
 }
 
-static void mlx4_en_refill_rx_buffers(struct mlx4_en_priv *priv,
-				     struct mlx4_en_rx_ring *ring)
+static inline int invalid_cqe(struct mlx4_en_priv *priv,
+			      struct mlx4_cqe *cqe)
 {
-	int index = ring->prod & ring->size_mask;
-
-	while ((u32) (ring->prod - ring->cons) < ring->actual_size) {
-		if (mlx4_en_prepare_rx_desc(priv, ring, index, GFP_ATOMIC))
-			break;
-		ring->prod++;
-		index = ring->prod & ring->size_mask;
+	/* Drop packet on bad receive or bad checksum */
+	if (unlikely((cqe->owner_sr_opcode & MLX4_CQE_OPCODE_MASK) ==
+		     MLX4_CQE_OPCODE_ERROR)) {
+		en_err(priv, "CQE completed in error - vendor syndrom:%d syndrom:%d\n",
+		       ((struct mlx4_err_cqe *)cqe)->vendor_err_syndrome,
+		       ((struct mlx4_err_cqe *)cqe)->syndrome);
+		return 1;
+	}
+	if (unlikely(cqe->badfcs_enc & MLX4_CQE_BAD_FCS)) {
+		en_dbg(RX_ERR, priv, "Accepted frame with bad FCS\n");
+		return 1;
 	}
+
+	return 0;
 }
 
-int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int budget)
+int mlx4_en_process_rx_cq(struct net_device *dev,
+			  struct mlx4_en_cq *cq,
+			  int budget)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_en_dev *mdev = priv->mdev;
 	struct mlx4_cqe *cqe;
+	struct mlx4_cq *mcq = &cq->mcq;
 	struct mlx4_en_rx_ring *ring = priv->rx_ring[cq->ring];
-	struct mlx4_en_rx_alloc *frags;
 	struct mlx4_en_rx_desc *rx_desc;
+	struct mlx4_en_rx_buf *rx_buf;
+	struct net_device_stats *stats = &priv->stats;
 	struct sk_buff *skb;
 	int index;
-	int nr;
 	unsigned int length;
 	int polled = 0;
-	int ip_summed;
+	struct ethhdr *ethh;
+	dma_addr_t dma;
 	int factor = priv->cqe_factor;
+	u32 cons_index = mcq->cons_index;
+	u32 size_mask = ring->size_mask;
+	int size = cq->size;
+	struct mlx4_cqe *buf = cq->buf;
 	u64 timestamp;
+	int ip_summed;
 
 	if (!priv->port_up)
 		return 0;
@@ -638,70 +559,56 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 	/* We assume a 1:1 mapping between CQEs and Rx descriptors, so Rx
 	 * descriptor offset can be deduced from the CQE index instead of
 	 * reading 'cqe->index' */
-	index = cq->mcq.cons_index & ring->size_mask;
-	cqe = &cq->buf[(index << factor) + factor];
+	index = cons_index & size_mask;
+	cqe = &buf[(index << factor) + factor];
 
 	/* Process all completed CQEs */
 	while (XNOR(cqe->owner_sr_opcode & MLX4_CQE_OWNER_MASK,
-		    cq->mcq.cons_index & cq->size)) {
+		    cons_index & size)) {
 
-		frags = ring->rx_info + (index << priv->log_rx_info);
 		rx_desc = ring->buf + (index << ring->log_stride);
-
-		/*
-		 * make sure we read the CQE after we read the ownership bit
-		 */
+		rx_buf = &ring->rx_info[index];
+		/* make sure we read the CQE after we read the ownership bit */
 		rmb();
 
 		/* Drop packet on bad receive or bad checksum */
-		if (unlikely((cqe->owner_sr_opcode & MLX4_CQE_OPCODE_MASK) ==
-						MLX4_CQE_OPCODE_ERROR)) {
-			en_err(priv, "CQE completed in error - vendor "
-				  "syndrom:%d syndrom:%d\n",
-				  ((struct mlx4_err_cqe *) cqe)->vendor_err_syndrome,
-				  ((struct mlx4_err_cqe *) cqe)->syndrome);
-			goto next;
-		}
-		if (unlikely(cqe->badfcs_enc & MLX4_CQE_BAD_FCS)) {
-			en_dbg(RX_ERR, priv, "Accepted frame with bad FCS\n");
+		if (unlikely(invalid_cqe(priv, cqe)))
 			goto next;
-		}
+
+		/* Get pointer to first fragment since we haven't skb yet and
+		 * cast it to ethhdr struct
+		 */
+		dma = be64_to_cpu(rx_desc->data[0].addr);
+		dma_sync_single_for_cpu(priv->ddev, dma, sizeof(*ethh),
+					DMA_FROM_DEVICE);
+
+		ethh = (struct ethhdr *)(page_address(rx_buf->page) +
+					 rx_buf->page_offset);
 
 		/* Check if we need to drop the packet if SRIOV is not enabled
 		 * and not performing the selftest or flb disabled
 		 */
-		if (priv->flags & MLX4_EN_FLAG_RX_FILTER_NEEDED) {
-			struct ethhdr *ethh;
-			dma_addr_t dma;
-			/* Get pointer to first fragment since we haven't
-			 * skb yet and cast it to ethhdr struct
-			 */
-			dma = be64_to_cpu(rx_desc->data[0].addr);
-			dma_sync_single_for_cpu(priv->ddev, dma, sizeof(*ethh),
-						DMA_FROM_DEVICE);
-			ethh = (struct ethhdr *)(page_address(frags[0].page) +
-						 frags[0].page_offset);
-
-			if (is_multicast_ether_addr(ethh->h_dest)) {
-				struct mlx4_mac_entry *entry;
-				struct hlist_head *bucket;
-				unsigned int mac_hash;
-
-				/* Drop the packet, since HW loopback-ed it */
-				mac_hash = ethh->h_source[MLX4_EN_MAC_HASH_IDX];
-				bucket = &priv->mac_hash[mac_hash];
-				rcu_read_lock();
-				hlist_for_each_entry_rcu(entry, bucket, hlist) {
-					if (ether_addr_equal_64bits(entry->mac,
-								    ethh->h_source)) {
-						rcu_read_unlock();
-						goto next;
-					}
+		if (priv->flags & MLX4_EN_FLAG_RX_FILTER_NEEDED &&
+		    is_multicast_ether_addr(ethh->h_dest)) {
+			struct mlx4_mac_entry *entry;
+			struct hlist_head *bucket;
+			unsigned int mac_hash;
+
+			/* Drop the packet, since HW loopback-ed it */
+			mac_hash = ethh->h_source[MLX4_EN_MAC_HASH_IDX];
+			bucket = &priv->mac_hash[mac_hash];
+			rcu_read_lock();
+			hlist_for_each_entry_rcu(entry, bucket, hlist) {
+				if (ether_addr_equal_64bits(entry->mac,
+							    ethh->h_source)) {
+					rcu_read_unlock();
+					goto next;
 				}
-				rcu_read_unlock();
 			}
+			rcu_read_unlock();
 		}
-
+		/* avoid cache miss in tcp_gro_receive */
+		prefetch((char *)ethh + 64);
 		/*
 		 * Packet is OK - process it.
 		 */
@@ -710,77 +617,27 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 		ring->bytes += length;
 		ring->packets++;
 
-		if (likely(dev->features & NETIF_F_RXCSUM)) {
-			if ((cqe->status & cpu_to_be16(MLX4_CQE_STATUS_IPOK)) &&
-			    (cqe->checksum == cpu_to_be16(0xffff))) {
-				ring->csum_ok++;
-				/* This packet is eligible for GRO if it is:
-				 * - DIX Ethernet (type interpretation)
-				 * - TCP/IP (v4)
-				 * - without IP options
-				 * - not an IP fragment
-				 * - no LLS polling in progress
-				 */
-				if (!mlx4_en_cq_ll_polling(cq) &&
-				    (dev->features & NETIF_F_GRO)) {
-					struct sk_buff *gro_skb = napi_get_frags(&cq->napi);
-					if (!gro_skb)
-						goto next;
-
-					nr = mlx4_en_complete_rx_desc(priv,
-						rx_desc, frags, gro_skb,
-						length);
-					if (!nr)
-						goto next;
-
-					skb_shinfo(gro_skb)->nr_frags = nr;
-					gro_skb->len = length;
-					gro_skb->data_len = length;
-					gro_skb->ip_summed = CHECKSUM_UNNECESSARY;
-
-					if ((cqe->vlan_my_qpn &
-					    cpu_to_be32(MLX4_CQE_VLAN_PRESENT_MASK)) &&
-					    (dev->features & NETIF_F_HW_VLAN_CTAG_RX)) {
-						u16 vid = be16_to_cpu(cqe->sl_vid);
-
-						__vlan_hwaccel_put_tag(gro_skb, htons(ETH_P_8021Q), vid);
-					}
-
-					if (dev->features & NETIF_F_RXHASH)
-						gro_skb->rxhash = be32_to_cpu(cqe->immed_rss_invalid);
-
-					skb_record_rx_queue(gro_skb, cq->ring);
-
-					if (ring->hwtstamp_rx_filter == HWTSTAMP_FILTER_ALL) {
-						timestamp = mlx4_en_get_cqe_ts(cqe);
-						mlx4_en_fill_hwtstamps(mdev,
-								       skb_hwtstamps(gro_skb),
-								       timestamp);
-					}
-
-					napi_gro_frags(&cq->napi);
-					goto next;
-				}
-
-				/* GRO not possible, complete processing here */
-				ip_summed = CHECKSUM_UNNECESSARY;
-			} else {
-				ip_summed = CHECKSUM_NONE;
-				ring->csum_none++;
-			}
+		if (likely((dev->features & NETIF_F_RXCSUM) &&
+			   (cqe->status & cpu_to_be16(MLX4_CQE_STATUS_IPOK)) &&
+			   (cqe->checksum == cpu_to_be16(0xffff)))) {
+			ring->csum_ok++;
+			ip_summed = CHECKSUM_UNNECESSARY;
 		} else {
-			ip_summed = CHECKSUM_NONE;
 			ring->csum_none++;
+			ip_summed = CHECKSUM_NONE;
 		}
 
-		skb = mlx4_en_rx_skb(priv, rx_desc, frags, length);
+		/* any kind of traffic goes here */
+		skb = mlx4_en_rx_skb(priv, ring, rx_desc, rx_buf, length);
 		if (!skb) {
-			priv->stats.rx_dropped++;
+			stats->rx_dropped++;
 			goto next;
 		}
 
-                if (unlikely(priv->validate_loopback)) {
+		/* check for loopback */
+		if (unlikely(priv->validate_loopback)) {
 			validate_loopback(priv, skb);
+			kfree_skb(skb);
 			goto next;
 		}
 
@@ -791,12 +648,15 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 		if (dev->features & NETIF_F_RXHASH)
 			skb->rxhash = be32_to_cpu(cqe->immed_rss_invalid);
 
+		/* process VLAN traffic */
 		if ((be32_to_cpu(cqe->vlan_my_qpn) &
-		    MLX4_CQE_VLAN_PRESENT_MASK) &&
-		    (dev->features & NETIF_F_HW_VLAN_CTAG_RX))
-			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), be16_to_cpu(cqe->sl_vid));
+		     MLX4_CQE_VLAN_PRESENT_MASK) &&
+		    (dev->features & NETIF_F_HW_VLAN_CTAG_RX)) {
+			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q),
+					       be16_to_cpu(cqe->sl_vid));
 
-		if (ring->hwtstamp_rx_filter == HWTSTAMP_FILTER_ALL) {
+		/* process time stamps */
+		} else if (ring->hwtstamp_rx_filter == HWTSTAMP_FILTER_ALL) {
 			timestamp = mlx4_en_get_cqe_ts(cqe);
 			mlx4_en_fill_hwtstamps(mdev, skb_hwtstamps(skb),
 					       timestamp);
@@ -805,30 +665,32 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 		skb_mark_napi_id(skb, &cq->napi);
 
 		/* Push it up the stack */
-		netif_receive_skb(skb);
+		if (mlx4_en_cq_ll_polling(cq))
+			netif_receive_skb(skb);
+		else
+			napi_gro_receive(&cq->napi, skb);
 
 next:
-		for (nr = 0; nr < priv->num_frags; nr++)
-			mlx4_en_free_frag(priv, frags, nr);
-
-		++cq->mcq.cons_index;
-		index = (cq->mcq.cons_index) & ring->size_mask;
-		cqe = &cq->buf[(index << factor) + factor];
-		if (++polled == budget)
+		++cons_index;
+		index = cons_index & size_mask;
+		cqe = &buf[(index << factor) + factor];
+		if (++polled == budget) {
+			/* we are here because we reached the NAPI budget */
 			goto out;
+		}
 	}
 
 out:
 	AVG_PERF_COUNTER(priv->pstats.rx_coal_avg, polled);
-	mlx4_cq_set_ci(&cq->mcq);
+	mcq->cons_index = cons_index;
+	mlx4_cq_set_ci(mcq);
 	wmb(); /* ensure HW sees CQ consumer before we post new buffers */
-	ring->cons = cq->mcq.cons_index;
-	mlx4_en_refill_rx_buffers(priv, ring);
+	ring->cons = mcq->cons_index;
+	ring->prod += polled;
 	mlx4_en_update_rx_prod_db(ring);
 	return polled;
 }
 
-
 void mlx4_en_rx_irq(struct mlx4_cq *mcq)
 {
 	struct mlx4_en_cq *cq = container_of(mcq, struct mlx4_en_cq, mcq);
@@ -866,55 +728,6 @@ int mlx4_en_poll_rx_cq(struct napi_struct *napi, int budget)
 	return done;
 }
 
-static const int frag_sizes[] = {
-	FRAG_SZ0,
-	FRAG_SZ1,
-	FRAG_SZ2,
-	FRAG_SZ3
-};
-
-void mlx4_en_calc_rx_buf(struct net_device *dev)
-{
-	struct mlx4_en_priv *priv = netdev_priv(dev);
-	int eff_mtu = dev->mtu + ETH_HLEN + VLAN_HLEN + ETH_LLC_SNAP_SIZE;
-	int buf_size = 0;
-	int i = 0;
-
-	while (buf_size < eff_mtu) {
-		priv->frag_info[i].frag_size =
-			(eff_mtu > buf_size + frag_sizes[i]) ?
-				frag_sizes[i] : eff_mtu - buf_size;
-		priv->frag_info[i].frag_prefix_size = buf_size;
-		if (!i)	{
-			priv->frag_info[i].frag_align = NET_IP_ALIGN;
-			priv->frag_info[i].frag_stride =
-				ALIGN(frag_sizes[i] + NET_IP_ALIGN, SMP_CACHE_BYTES);
-		} else {
-			priv->frag_info[i].frag_align = 0;
-			priv->frag_info[i].frag_stride =
-				ALIGN(frag_sizes[i], SMP_CACHE_BYTES);
-		}
-		buf_size += priv->frag_info[i].frag_size;
-		i++;
-	}
-
-	priv->num_frags = i;
-	priv->rx_skb_size = eff_mtu;
-	priv->log_rx_info = ROUNDUP_LOG2(i * sizeof(struct mlx4_en_rx_alloc));
-
-	en_dbg(DRV, priv, "Rx buffer scatter-list (effective-mtu:%d "
-		  "num_frags:%d):\n", eff_mtu, priv->num_frags);
-	for (i = 0; i < priv->num_frags; i++) {
-		en_err(priv,
-		       "  frag:%d - size:%d prefix:%d align:%d stride:%d\n",
-		       i,
-		       priv->frag_info[i].frag_size,
-		       priv->frag_info[i].frag_prefix_size,
-		       priv->frag_info[i].frag_align,
-		       priv->frag_info[i].frag_stride);
-	}
-}
-
 /* RSS related functions */
 
 static int mlx4_en_config_rss_qp(struct mlx4_en_priv *priv, int qpn,
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index f3758de..fa33a83 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -94,27 +94,20 @@
 
 #define MLX4_EN_WATCHDOG_TIMEOUT	(15 * HZ)
 
-/* Use the maximum between 16384 and a single page */
-#define MLX4_EN_ALLOC_SIZE	PAGE_ALIGN(16384)
+#define MLX4_EN_ALLOC_SIZE     PAGE_ALIGN(PAGE_SIZE)
+#define MLX4_EN_ALLOC_ORDER    get_order(MLX4_EN_ALLOC_SIZE)
 
-#define MLX4_EN_ALLOC_PREFER_ORDER	PAGE_ALLOC_COSTLY_ORDER
-
-/* Receive fragment sizes; we use at most 3 fragments (for 9600 byte MTU
- * and 4K allocations) */
-enum {
-	FRAG_SZ0 = 1536 - NET_IP_ALIGN,
-	FRAG_SZ1 = 4096,
-	FRAG_SZ2 = 4096,
-	FRAG_SZ3 = MLX4_EN_ALLOC_SIZE
+enum mlx4_en_alloc_type {
+	MLX4_EN_ALLOC_NEW = 0,
+	MLX4_EN_ALLOC_REPLACEMENT = 1,
 };
-#define MLX4_EN_MAX_RX_FRAGS	4
 
 /* Maximum ring sizes */
 #define MLX4_EN_MAX_TX_SIZE	8192
 #define MLX4_EN_MAX_RX_SIZE	8192
 
-/* Minimum ring size for our page-allocation scheme to work */
-#define MLX4_EN_MIN_RX_SIZE	(MLX4_EN_ALLOC_SIZE / SMP_CACHE_BYTES)
+/* Minimum ring sizes */
+#define MLX4_EN_MIN_RX_SIZE	(4096 / TXBB_SIZE)
 #define MLX4_EN_MIN_TX_SIZE	(4096 / TXBB_SIZE)
 
 #define MLX4_EN_SMALL_PKT_SIZE		64
@@ -234,13 +227,6 @@ struct mlx4_en_tx_desc {
 #define MLX4_EN_CX3_LOW_ID	0x1000
 #define MLX4_EN_CX3_HIGH_ID	0x1005
 
-struct mlx4_en_rx_alloc {
-	struct page	*page;
-	dma_addr_t	dma;
-	u32		page_offset;
-	u32		page_size;
-};
-
 struct mlx4_en_tx_ring {
 	struct mlx4_hwq_resources wqres;
 	u32 size ; /* number of TXBBs */
@@ -275,9 +261,14 @@ struct mlx4_en_rx_desc {
 	struct mlx4_wqe_data_seg data[0];
 };
 
+struct mlx4_en_rx_buf {
+	dma_addr_t dma;
+	struct page *page;
+	unsigned int page_offset;
+};
+
 struct mlx4_en_rx_ring {
 	struct mlx4_hwq_resources wqres;
-	struct mlx4_en_rx_alloc page_alloc[MLX4_EN_MAX_RX_FRAGS];
 	u32 size ;	/* number of Rx descs*/
 	u32 actual_size;
 	u32 size_mask;
@@ -288,8 +279,12 @@ struct mlx4_en_rx_ring {
 	u32 cons;
 	u32 buf_size;
 	u8  fcs_del;
+	u16 rx_alloc_order;
+	u32 rx_alloc_size;
+	u32 rx_buf_size;
+	int qpn;
 	void *buf;
-	void *rx_info;
+	struct mlx4_en_rx_buf *rx_info;
 	unsigned long bytes;
 	unsigned long packets;
 #ifdef CONFIG_NET_RX_BUSY_POLL
@@ -300,6 +295,7 @@ struct mlx4_en_rx_ring {
 	unsigned long csum_ok;
 	unsigned long csum_none;
 	int hwtstamp_rx_filter;
+	int numa_node;
 };
 
 struct mlx4_en_cq {
@@ -436,13 +432,6 @@ struct mlx4_en_mc_list {
 	u64			reg_id;
 };
 
-struct mlx4_en_frag_info {
-	u16 frag_size;
-	u16 frag_prefix_size;
-	u16 frag_stride;
-	u16 frag_align;
-};
-
 #ifdef CONFIG_MLX4_EN_DCB
 /* Minimal TC BW - setting to 0 will block traffic */
 #define MLX4_EN_BW_MIN 1
@@ -526,8 +515,9 @@ struct mlx4_en_priv {
 	u32 tx_ring_num;
 	u32 rx_ring_num;
 	u32 rx_skb_size;
-	struct mlx4_en_frag_info frag_info[MLX4_EN_MAX_RX_FRAGS];
-	u16 num_frags;
+	u16 rx_alloc_order;
+	u32 rx_alloc_size;
+	u32 rx_buf_size;
 	u16 log_rx_info;
 
 	struct mlx4_en_tx_ring **tx_ring;
@@ -730,7 +720,7 @@ void mlx4_en_deactivate_tx_ring(struct mlx4_en_priv *priv,
 
 int mlx4_en_create_rx_ring(struct mlx4_en_priv *priv,
 			   struct mlx4_en_rx_ring **pring,
-			   u32 size, u16 stride, int node);
+			   u32 size, int node);
 void mlx4_en_destroy_rx_ring(struct mlx4_en_priv *priv,
 			     struct mlx4_en_rx_ring **pring,
 			     u32 size, u16 stride);
-- 
1.8.3.4
