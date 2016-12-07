From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH v4 net-next 3/4] mlx4: xdp: Reserve headroom for receiving packet when XDP prog is active
Date: Wed, 7 Dec 2016 15:53:13 -0800
Message-ID: <1481154794-2311034-4-git-send-email-kafai@fb.com>
References: <1481154794-2311034-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>,
        Jakub Kicinski <kubakici@wp.pl>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Kernel Team <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 00082601.pphosted.com ([67.231.145.42]:52080 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753180AbcLGXxQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 18:53:16 -0500
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uB7NoDLq027043
        for <netdev@vger.kernel.org>; Wed, 7 Dec 2016 15:53:16 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 276qfgb6f8-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 07 Dec 2016 15:53:16 -0800
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)     by
 mx-out.facebook.com (10.103.99.97) with ESMTP  id
 51705d40bcd811e69efb0002c9931860-edffca50 for <netdev@vger.kernel.org>;        Wed,
 07 Dec 2016 15:53:14 -0800
In-Reply-To: <1481154794-2311034-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reserve XDP_PACKET_HEADROOM for packet and enable bpf_xdp_adjust_head()
support.  This patch only affects the code path when XDP is active.

After testing, the tx_dropped counter is incremented if the xdp_prog sends
more than wire MTU.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |  8 ++------
 drivers/net/ethernet/mellanox/mlx4/en_rx.c     | 24 ++++++++++++++++++------
 drivers/net/ethernet/mellanox/mlx4/en_tx.c     |  9 +++++----
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |  3 ++-
 4 files changed, 27 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index c97d25b06444..bcd955339058 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -51,7 +51,8 @@
 #include "mlx4_en.h"
 #include "en_port.h"
 
-#define MLX4_EN_MAX_XDP_MTU ((int)(PAGE_SIZE - ETH_HLEN - (2 * VLAN_HLEN)))
+#define MLX4_EN_MAX_XDP_MTU ((int)(PAGE_SIZE - ETH_HLEN - (2 * VLAN_HLEN) - \
+				   XDP_PACKET_HEADROOM))
 
 int mlx4_en_setup_tc(struct net_device *dev, u8 up)
 {
@@ -2700,11 +2701,6 @@ static int mlx4_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 	int err;
 	int i;
 
-	if (prog && prog->xdp_adjust_head) {
-		en_err(priv, "Does not support bpf_xdp_adjust_head()\n");
-		return -EOPNOTSUPP;
-	}
-
 	xdp_ring_num = prog ? priv->rx_ring_num : 0;
 
 	/* No need to reconfigure buffers when simply swapping the
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 23e9d04d1ef4..3c37e216bbf3 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -96,7 +96,6 @@ static int mlx4_en_alloc_frags(struct mlx4_en_priv *priv,
 	struct mlx4_en_rx_alloc page_alloc[MLX4_EN_MAX_RX_FRAGS];
 	const struct mlx4_en_frag_info *frag_info;
 	struct page *page;
-	dma_addr_t dma;
 	int i;
 
 	for (i = 0; i < priv->num_frags; i++) {
@@ -115,9 +114,10 @@ static int mlx4_en_alloc_frags(struct mlx4_en_priv *priv,
 
 	for (i = 0; i < priv->num_frags; i++) {
 		frags[i] = ring_alloc[i];
-		dma = ring_alloc[i].dma + ring_alloc[i].page_offset;
+		frags[i].page_offset += priv->frag_info[i].rx_headroom;
+		rx_desc->data[i].addr = cpu_to_be64(frags[i].dma +
+						    frags[i].page_offset);
 		ring_alloc[i] = page_alloc[i];
-		rx_desc->data[i].addr = cpu_to_be64(dma);
 	}
 
 	return 0;
@@ -250,7 +250,8 @@ static int mlx4_en_prepare_rx_desc(struct mlx4_en_priv *priv,
 
 	if (ring->page_cache.index > 0) {
 		frags[0] = ring->page_cache.buf[--ring->page_cache.index];
-		rx_desc->data[0].addr = cpu_to_be64(frags[0].dma);
+		rx_desc->data[0].addr = cpu_to_be64(frags[0].dma +
+						    frags[0].page_offset);
 		return 0;
 	}
 
@@ -889,6 +890,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 		if (xdp_prog) {
 			struct xdp_buff xdp;
 			dma_addr_t dma;
+			void *orig_data;
 			u32 act;
 
 			dma = be64_to_cpu(rx_desc->data[0].addr);
@@ -896,11 +898,19 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 						priv->frag_info[0].frag_size,
 						DMA_FROM_DEVICE);
 
-			xdp.data = page_address(frags[0].page) +
-							frags[0].page_offset;
+			xdp.data_hard_start = page_address(frags[0].page);
+			xdp.data = xdp.data_hard_start + frags[0].page_offset;
 			xdp.data_end = xdp.data + length;
+			orig_data = xdp.data;
 
 			act = bpf_prog_run_xdp(xdp_prog, &xdp);
+
+			if (xdp.data != orig_data) {
+				length = xdp.data_end - xdp.data;
+				frags[0].page_offset = xdp.data -
+					xdp.data_hard_start;
+			}
+
 			switch (act) {
 			case XDP_PASS:
 				break;
@@ -1180,6 +1190,7 @@ void mlx4_en_calc_rx_buf(struct net_device *dev)
 		 */
 		priv->frag_info[0].frag_stride = PAGE_SIZE;
 		priv->frag_info[0].dma_dir = PCI_DMA_BIDIRECTIONAL;
+		priv->frag_info[0].rx_headroom = XDP_PACKET_HEADROOM;
 		i = 1;
 	} else {
 		int buf_size = 0;
@@ -1194,6 +1205,7 @@ void mlx4_en_calc_rx_buf(struct net_device *dev)
 				ALIGN(priv->frag_info[i].frag_size,
 				      SMP_CACHE_BYTES);
 			priv->frag_info[i].dma_dir = PCI_DMA_FROMDEVICE;
+			priv->frag_info[i].rx_headroom = 0;
 			buf_size += priv->frag_info[i].frag_size;
 			i++;
 		}
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 4b597dca5c52..5886ad78058f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -354,7 +354,7 @@ u32 mlx4_en_recycle_tx_desc(struct mlx4_en_priv *priv,
 	struct mlx4_en_rx_alloc frame = {
 		.page = tx_info->page,
 		.dma = tx_info->map0_dma,
-		.page_offset = 0,
+		.page_offset = XDP_PACKET_HEADROOM,
 		.page_size = PAGE_SIZE,
 	};
 
@@ -1132,7 +1132,7 @@ netdev_tx_t mlx4_en_xmit_frame(struct mlx4_en_rx_ring *rx_ring,
 	tx_info->page = frame->page;
 	frame->page = NULL;
 	tx_info->map0_dma = dma;
-	tx_info->map0_byte_count = length;
+	tx_info->map0_byte_count = PAGE_SIZE;
 	tx_info->nr_txbb = nr_txbb;
 	tx_info->nr_bytes = max_t(unsigned int, length, ETH_ZLEN);
 	tx_info->data_offset = (void *)data - (void *)tx_desc;
@@ -1141,9 +1141,10 @@ netdev_tx_t mlx4_en_xmit_frame(struct mlx4_en_rx_ring *rx_ring,
 	tx_info->linear = 1;
 	tx_info->inl = 0;
 
-	dma_sync_single_for_device(priv->ddev, dma, length, PCI_DMA_TODEVICE);
+	dma_sync_single_range_for_device(priv->ddev, dma, frame->page_offset,
+					 length, PCI_DMA_TODEVICE);
 
-	data->addr = cpu_to_be64(dma);
+	data->addr = cpu_to_be64(dma + frame->page_offset);
 	data->lkey = ring->mr_key;
 	dma_wmb();
 	data->byte_count = cpu_to_be32(length);
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 20a936428f4a..ba1c6cd0cc79 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -475,7 +475,8 @@ struct mlx4_en_frag_info {
 	u16 frag_prefix_size;
 	u32 frag_stride;
 	enum dma_data_direction dma_dir;
-	int order;
+	u16 order;
+	u16 rx_headroom;
 };
 
 #ifdef CONFIG_MLX4_EN_DCB
-- 
2.5.1
