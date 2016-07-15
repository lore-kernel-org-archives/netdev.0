From: Brenden Blanco <bblanco@plumgrid.com>
Subject: [PATCH v9 06/11] net/mlx4_en: add page recycle to prepare rx ring for tx support
Date: Fri, 15 Jul 2016 16:28:53 -0700
Message-ID: <1468625338-32391-7-git-send-email-bblanco@plumgrid.com>
References: <1468625338-32391-1-git-send-email-bblanco@plumgrid.com>
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
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:36634 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751824AbcGOX3f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 19:29:35 -0400
Received: by mail-pa0-f45.google.com with SMTP id pp5so36505110pac.3
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 16:29:34 -0700 (PDT)
In-Reply-To: <1468625338-32391-1-git-send-email-bblanco@plumgrid.com>
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
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 35 +++++++++++--
 drivers/net/ethernet/mellanox/mlx4/en_rx.c     | 70 +++++++++++++++++++++++---
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   | 11 +++-
 3 files changed, 104 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index b7c1804..e54541e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2532,20 +2532,49 @@ static int mlx4_en_set_tx_maxrate(struct net_device *dev, int queue_index, u32 m
 static int mlx4_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
+	struct mlx4_en_dev *mdev = priv->mdev;
 	struct bpf_prog *old_prog;
+	int port_up = 0;
+	int err;
+
+	/* No need to reconfigure buffers when simply swapping the
+	 * program for a new one.
+	 */
+	if (READ_ONCE(priv->prog) && prog) {
+		/* This xchg is paired with READ_ONCE in the fast path, but is
+		 * also protected from itself via rtnl lock
+		 */
+		old_prog = xchg(&priv->prog, prog);
+		if (old_prog)
+			bpf_prog_put(old_prog);
+		return 0;
+	}
 
 	if (priv->num_frags > 1) {
 		en_err(priv, "Cannot set XDP if MTU requires multiple frags\n");
 		return -EOPNOTSUPP;
 	}
 
-	/* This xchg is paired with READ_ONCE in the fast path, but is
-	 * also protected from itself via rtnl lock
-	 */
+	mutex_lock(&mdev->state_lock);
+	if (priv->port_up) {
+		port_up = 1;
+		mlx4_en_stop_port(dev, 1);
+	}
+
 	old_prog = xchg(&priv->prog, prog);
 	if (old_prog)
 		bpf_prog_put(old_prog);
 
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
index adfa123..6020c37 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -57,7 +57,7 @@ static int mlx4_alloc_pages(struct mlx4_en_priv *priv,
 	struct page *page;
 	dma_addr_t dma;
 
-	for (order = MLX4_EN_ALLOC_PREFER_ORDER; ;) {
+	for (order = frag_info->order; ;) {
 		gfp_t gfp = _gfp;
 
 		if (order)
@@ -70,7 +70,7 @@ static int mlx4_alloc_pages(struct mlx4_en_priv *priv,
 			return -ENOMEM;
 	}
 	dma = dma_map_page(priv->ddev, page, 0, PAGE_SIZE << order,
-			   PCI_DMA_FROMDEVICE);
+			   frag_info->dma_dir);
 	if (dma_mapping_error(priv->ddev, dma)) {
 		put_page(page);
 		return -ENOMEM;
@@ -124,7 +124,8 @@ out:
 	while (i--) {
 		if (page_alloc[i].page != ring_alloc[i].page) {
 			dma_unmap_page(priv->ddev, page_alloc[i].dma,
-				page_alloc[i].page_size, PCI_DMA_FROMDEVICE);
+				page_alloc[i].page_size,
+				priv->frag_info[i].dma_dir);
 			page = page_alloc[i].page;
 			/* Revert changes done by mlx4_alloc_pages */
 			page_ref_sub(page, page_alloc[i].page_size /
@@ -145,7 +146,7 @@ static void mlx4_en_free_frag(struct mlx4_en_priv *priv,
 
 	if (next_frag_end > frags[i].page_size)
 		dma_unmap_page(priv->ddev, frags[i].dma, frags[i].page_size,
-			       PCI_DMA_FROMDEVICE);
+			       frag_info->dma_dir);
 
 	if (frags[i].page)
 		put_page(frags[i].page);
@@ -176,7 +177,8 @@ out:
 
 		page_alloc = &ring->page_alloc[i];
 		dma_unmap_page(priv->ddev, page_alloc->dma,
-			       page_alloc->page_size, PCI_DMA_FROMDEVICE);
+			       page_alloc->page_size,
+			       priv->frag_info[i].dma_dir);
 		page = page_alloc->page;
 		/* Revert changes done by mlx4_alloc_pages */
 		page_ref_sub(page, page_alloc->page_size /
@@ -201,7 +203,7 @@ static void mlx4_en_destroy_allocator(struct mlx4_en_priv *priv,
 		       i, page_count(page_alloc->page));
 
 		dma_unmap_page(priv->ddev, page_alloc->dma,
-				page_alloc->page_size, PCI_DMA_FROMDEVICE);
+				page_alloc->page_size, frag_info->dma_dir);
 		while (page_alloc->page_offset + frag_info->frag_stride <
 		       page_alloc->page_size) {
 			put_page(page_alloc->page);
@@ -244,6 +246,12 @@ static int mlx4_en_prepare_rx_desc(struct mlx4_en_priv *priv,
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
 
@@ -502,6 +510,24 @@ void mlx4_en_recover_from_oom(struct mlx4_en_priv *priv)
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
@@ -522,6 +548,16 @@ void mlx4_en_destroy_rx_ring(struct mlx4_en_priv *priv,
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
@@ -863,6 +899,8 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 				bpf_warn_invalid_xdp_action(act);
 			case XDP_ABORTED:
 			case XDP_DROP:
+				if (mlx4_en_rx_recycle(ring, frags))
+					goto consumed;
 				goto next;
 			}
 		}
@@ -1018,6 +1056,7 @@ next:
 		for (nr = 0; nr < priv->num_frags; nr++)
 			mlx4_en_free_frag(priv, frags, nr);
 
+consumed:
 		++cq->mcq.cons_index;
 		index = (cq->mcq.cons_index) & ring->size_mask;
 		cqe = mlx4_en_get_cqe(cq->buf, index, priv->cqe_size) + factor;
@@ -1093,19 +1132,34 @@ static const int frag_sizes[] = {
 
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
+	if (priv->prog) {
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
index 35ecfa2..948d7a1 100644
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
@@ -323,6 +329,7 @@ struct mlx4_en_rx_ring {
 	u8  fcs_del;
 	void *buf;
 	void *rx_info;
+	struct mlx4_en_page_cache page_cache;
 	unsigned long bytes;
 	unsigned long packets;
 	unsigned long csum_ok;
@@ -442,7 +449,9 @@ struct mlx4_en_mc_list {
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
