From: Brenden Blanco <bblanco@plumgrid.com>
Subject: [PATCH v10 07/12] net/mlx4_en: add page recycle to prepare rx ring for tx support
Date: Tue, 19 Jul 2016 12:16:52 -0700
Message-ID: <1468955817-10604-8-git-send-email-bblanco@plumgrid.com>
References: <1468955817-10604-1-git-send-email-bblanco@plumgrid.com>
Cc: Brenden Blanco <bblanco@plumgrid.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Martin KaFai Lau <kafai@fb.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Ari Saha <as754m@att.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>, john.fastabend@gmail.com,
	hannes@stressinduktion.org, Thomas Graf <tgraf@suug.ch>,
	Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Tariq Toukan <ttoukan.linux@gmail.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:34532 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751507AbcGSTRc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 15:17:32 -0400
Received: by mail-pf0-f175.google.com with SMTP id p64so10203172pfb.1
        for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 12:17:31 -0700 (PDT)
In-Reply-To: <1468955817-10604-1-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mlx4 driver by default allocates order-3 pages for the ring to
consume in multiple fragments. When the device has an xdp program, this
behavior will prevent tx actions since the page must be re-mapped in
TODEVICE mode, which cannot be done if the page is still shared.

Start by making the allocator configurable based on whether xdp is
running, such that order-0 pages are always used and never shared.

Since this will stress the page allocator, add a simple page cache to
each rx ring. Pages in the cache are left dma-mapped, and in drop-only
stress tests the page allocator is eliminated from the perf report.

Note that setting an xdp program will now require the rings to be
reconfigured.

Before:
 26.91%  ksoftirqd/0  [mlx4_en]         [k] mlx4_en_process_rx_cq
 17.88%  ksoftirqd/0  [mlx4_en]         [k] mlx4_en_alloc_frags
  6.00%  ksoftirqd/0  [mlx4_en]         [k] mlx4_en_free_frag
  4.49%  ksoftirqd/0  [kernel.vmlinux]  [k] get_page_from_freelist
  3.21%  swapper      [kernel.vmlinux]  [k] intel_idle
  2.73%  ksoftirqd/0  [kernel.vmlinux]  [k] bpf_map_lookup_elem
  2.57%  swapper      [mlx4_en]         [k] mlx4_en_process_rx_cq

After:
 31.72%  swapper      [kernel.vmlinux]       [k] intel_idle
  8.79%  swapper      [mlx4_en]              [k] mlx4_en_process_rx_cq
  7.54%  swapper      [kernel.vmlinux]       [k] poll_idle
  6.36%  swapper      [mlx4_core]            [k] mlx4_eq_int
  4.21%  swapper      [kernel.vmlinux]       [k] tasklet_action
  4.03%  swapper      [kernel.vmlinux]       [k] cpuidle_enter_state
  3.43%  swapper      [mlx4_en]              [k] mlx4_en_prepare_rx_desc
  2.18%  swapper      [kernel.vmlinux]       [k] native_irq_return_iret
  1.37%  swapper      [kernel.vmlinux]       [k] menu_select
  1.09%  swapper      [kernel.vmlinux]       [k] bpf_map_lookup_elem

Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 38 +++++++++++++-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c     | 70 +++++++++++++++++++++++---
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   | 11 +++-
 3 files changed, 109 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index c34a33d..47ae2a2 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2529,12 +2529,33 @@ static int mlx4_en_set_tx_maxrate(struct net_device *dev, int queue_index, u32 m
 static int mlx4_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
+	struct mlx4_en_dev *mdev = priv->mdev;
 	struct bpf_prog *old_prog;
 	int xdp_ring_num;
+	int port_up = 0;
+	int err;
 	int i;
 
 	xdp_ring_num = prog ? ALIGN(priv->rx_ring_num, MLX4_EN_NUM_UP) : 0;
 
+	/* No need to reconfigure buffers when simply swapping the
+	 * program for a new one.
+	 */
+	if (priv->xdp_ring_num == xdp_ring_num) {
+		if (prog) {
+			prog = bpf_prog_add(prog, priv->rx_ring_num - 1);
+			if (IS_ERR(prog))
+				return PTR_ERR(prog);
+		}
+		for (i = 0; i < priv->rx_ring_num; i++) {
+			/* This xchg is paired with READ_ONCE in the fastpath */
+			old_prog = xchg(&priv->rx_ring[i]->xdp_prog, prog);
+			if (old_prog)
+				bpf_prog_put(old_prog);
+		}
+		return 0;
+	}
+
 	if (priv->num_frags > 1) {
 		en_err(priv, "Cannot set XDP if MTU requires multiple frags\n");
 		return -EOPNOTSUPP;
@@ -2546,15 +2567,30 @@ static int mlx4_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 			return PTR_ERR(prog);
 	}
 
+	mutex_lock(&mdev->state_lock);
+	if (priv->port_up) {
+		port_up = 1;
+		mlx4_en_stop_port(dev, 1);
+	}
+
 	priv->xdp_ring_num = xdp_ring_num;
 
-	/* This xchg is paired with READ_ONCE in the fast path */
 	for (i = 0; i < priv->rx_ring_num; i++) {
 		old_prog = xchg(&priv->rx_ring[i]->xdp_prog, prog);
 		if (old_prog)
 			bpf_prog_put(old_prog);
 	}
 
+	if (port_up) {
+		err = mlx4_en_start_port(dev);
+		if (err) {
+			en_err(priv, "Failed starting port %d for XDP change\n",
+			       priv->port);
+			queue_work(mdev->workqueue, &priv->watchdog_task);
+		}
+	}
+
+	mutex_unlock(&mdev->state_lock);
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 6729545..9dd5dc1 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -58,7 +58,7 @@ static int mlx4_alloc_pages(struct mlx4_en_priv *priv,
 	struct page *page;
 	dma_addr_t dma;
 
-	for (order = MLX4_EN_ALLOC_PREFER_ORDER; ;) {
+	for (order = frag_info->order; ;) {
 		gfp_t gfp = _gfp;
 
 		if (order)
@@ -71,7 +71,7 @@ static int mlx4_alloc_pages(struct mlx4_en_priv *priv,
 			return -ENOMEM;
 	}
 	dma = dma_map_page(priv->ddev, page, 0, PAGE_SIZE << order,
-			   PCI_DMA_FROMDEVICE);
+			   frag_info->dma_dir);
 	if (dma_mapping_error(priv->ddev, dma)) {
 		put_page(page);
 		return -ENOMEM;
@@ -125,7 +125,8 @@ out:
 	while (i--) {
 		if (page_alloc[i].page != ring_alloc[i].page) {
 			dma_unmap_page(priv->ddev, page_alloc[i].dma,
-				page_alloc[i].page_size, PCI_DMA_FROMDEVICE);
+				page_alloc[i].page_size,
+				priv->frag_info[i].dma_dir);
 			page = page_alloc[i].page;
 			/* Revert changes done by mlx4_alloc_pages */
 			page_ref_sub(page, page_alloc[i].page_size /
@@ -146,7 +147,7 @@ static void mlx4_en_free_frag(struct mlx4_en_priv *priv,
 
 	if (next_frag_end > frags[i].page_size)
 		dma_unmap_page(priv->ddev, frags[i].dma, frags[i].page_size,
-			       PCI_DMA_FROMDEVICE);
+			       frag_info->dma_dir);
 
 	if (frags[i].page)
 		put_page(frags[i].page);
@@ -177,7 +178,8 @@ out:
 
 		page_alloc = &ring->page_alloc[i];
 		dma_unmap_page(priv->ddev, page_alloc->dma,
-			       page_alloc->page_size, PCI_DMA_FROMDEVICE);
+			       page_alloc->page_size,
+			       priv->frag_info[i].dma_dir);
 		page = page_alloc->page;
 		/* Revert changes done by mlx4_alloc_pages */
 		page_ref_sub(page, page_alloc->page_size /
@@ -202,7 +204,7 @@ static void mlx4_en_destroy_allocator(struct mlx4_en_priv *priv,
 		       i, page_count(page_alloc->page));
 
 		dma_unmap_page(priv->ddev, page_alloc->dma,
-				page_alloc->page_size, PCI_DMA_FROMDEVICE);
+				page_alloc->page_size, frag_info->dma_dir);
 		while (page_alloc->page_offset + frag_info->frag_stride <
 		       page_alloc->page_size) {
 			put_page(page_alloc->page);
@@ -245,6 +247,12 @@ static int mlx4_en_prepare_rx_desc(struct mlx4_en_priv *priv,
 	struct mlx4_en_rx_alloc *frags = ring->rx_info +
 					(index << priv->log_rx_info);
 
+	if (ring->page_cache.index > 0) {
+		frags[0] = ring->page_cache.buf[--ring->page_cache.index];
+		rx_desc->data[0].addr = cpu_to_be64(frags[0].dma);
+		return 0;
+	}
+
 	return mlx4_en_alloc_frags(priv, rx_desc, frags, ring->page_alloc, gfp);
 }
 
@@ -503,6 +511,24 @@ void mlx4_en_recover_from_oom(struct mlx4_en_priv *priv)
 	}
 }
 
+/* When the rx ring is running in page-per-packet mode, a released frame can go
+ * directly into a small cache, to avoid unmapping or touching the page
+ * allocator. In bpf prog performance scenarios, buffers are either forwarded
+ * or dropped, never converted to skbs, so every page can come directly from
+ * this cache when it is sized to be a multiple of the napi budget.
+ */
+bool mlx4_en_rx_recycle(struct mlx4_en_rx_ring *ring,
+			struct mlx4_en_rx_alloc *frame)
+{
+	struct mlx4_en_page_cache *cache = &ring->page_cache;
+
+	if (cache->index >= MLX4_EN_CACHE_SIZE)
+		return false;
+
+	cache->buf[cache->index++] = *frame;
+	return true;
+}
+
 void mlx4_en_destroy_rx_ring(struct mlx4_en_priv *priv,
 			     struct mlx4_en_rx_ring **pring,
 			     u32 size, u16 stride)
@@ -525,6 +551,16 @@ void mlx4_en_destroy_rx_ring(struct mlx4_en_priv *priv,
 void mlx4_en_deactivate_rx_ring(struct mlx4_en_priv *priv,
 				struct mlx4_en_rx_ring *ring)
 {
+	int i;
+
+	for (i = 0; i < ring->page_cache.index; i++) {
+		struct mlx4_en_rx_alloc *frame = &ring->page_cache.buf[i];
+
+		dma_unmap_page(priv->ddev, frame->dma, frame->page_size,
+			       priv->frag_info[0].dma_dir);
+		put_page(frame->page);
+	}
+	ring->page_cache.index = 0;
 	mlx4_en_free_rx_buf(priv, ring);
 	if (ring->stride <= TXBB_SIZE)
 		ring->buf -= TXBB_SIZE;
@@ -866,6 +902,8 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 				bpf_warn_invalid_xdp_action(act);
 			case XDP_ABORTED:
 			case XDP_DROP:
+				if (mlx4_en_rx_recycle(ring, frags))
+					goto consumed;
 				goto next;
 			}
 		}
@@ -1021,6 +1059,7 @@ next:
 		for (nr = 0; nr < priv->num_frags; nr++)
 			mlx4_en_free_frag(priv, frags, nr);
 
+consumed:
 		++cq->mcq.cons_index;
 		index = (cq->mcq.cons_index) & ring->size_mask;
 		cqe = mlx4_en_get_cqe(cq->buf, index, priv->cqe_size) + factor;
@@ -1096,19 +1135,34 @@ static const int frag_sizes[] = {
 
 void mlx4_en_calc_rx_buf(struct net_device *dev)
 {
+	enum dma_data_direction dma_dir = PCI_DMA_FROMDEVICE;
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	int eff_mtu = MLX4_EN_EFF_MTU(dev->mtu);
+	int order = MLX4_EN_ALLOC_PREFER_ORDER;
+	u32 align = SMP_CACHE_BYTES;
 	int buf_size = 0;
 	int i = 0;
 
+	/* bpf requires buffers to be set up as 1 packet per page.
+	 * This only works when num_frags == 1.
+	 */
+	if (priv->xdp_ring_num) {
+		/* This will gain efficient xdp frame recycling at the expense
+		 * of more costly truesize accounting
+		 */
+		align = PAGE_SIZE;
+		order = 0;
+	}
+
 	while (buf_size < eff_mtu) {
+		priv->frag_info[i].order = order;
 		priv->frag_info[i].frag_size =
 			(eff_mtu > buf_size + frag_sizes[i]) ?
 				frag_sizes[i] : eff_mtu - buf_size;
 		priv->frag_info[i].frag_prefix_size = buf_size;
 		priv->frag_info[i].frag_stride =
-				ALIGN(priv->frag_info[i].frag_size,
-				      SMP_CACHE_BYTES);
+				ALIGN(priv->frag_info[i].frag_size, align);
+		priv->frag_info[i].dma_dir = dma_dir;
 		buf_size += priv->frag_info[i].frag_size;
 		i++;
 	}
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index eb1238d..eff4be0 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -259,6 +259,12 @@ struct mlx4_en_rx_alloc {
 	u32		page_size;
 };
 
+#define MLX4_EN_CACHE_SIZE (2 * NAPI_POLL_WEIGHT)
+struct mlx4_en_page_cache {
+	u32 index;
+	struct mlx4_en_rx_alloc buf[MLX4_EN_CACHE_SIZE];
+};
+
 struct mlx4_en_tx_ring {
 	/* cache line used and dirtied in tx completion
 	 * (mlx4_en_free_tx_buf())
@@ -324,6 +330,7 @@ struct mlx4_en_rx_ring {
 	void *buf;
 	void *rx_info;
 	struct bpf_prog *xdp_prog;
+	struct mlx4_en_page_cache page_cache;
 	unsigned long bytes;
 	unsigned long packets;
 	unsigned long csum_ok;
@@ -443,7 +450,9 @@ struct mlx4_en_mc_list {
 struct mlx4_en_frag_info {
 	u16 frag_size;
 	u16 frag_prefix_size;
-	u16 frag_stride;
+	u32 frag_stride;
+	enum dma_data_direction dma_dir;
+	int order;
 };
 
 #ifdef CONFIG_MLX4_EN_DCB
-- 
2.8.2
