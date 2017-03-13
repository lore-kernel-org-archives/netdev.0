From: Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [RFC v1 for accelerated IPoIB 22/25] net/mlx5e: New function pointer for build_rx_skb is
Date: Mon, 13 Mar 2017 20:31:33 +0200
Message-ID: <1489429896-10781-23-git-send-email-erezsh@mellanox.com>
References: <1489429896-10781-1-git-send-email-erezsh@mellanox.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        valex-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, saedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        erezsh-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org, Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1489429896-10781-1-git-send-email-erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


In order to have the ability to support IB link with the same base code.

Signed-off-by: Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |  6 ++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |  7 +++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   | 10 +++++-----
 3 files changed, 18 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index b6758d0b93a5..84de1ca11524 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -298,6 +298,11 @@ typedef int (*mlx5e_fp_alloc_wqe)(struct mlx5e_rq *rq, struct mlx5e_rx_wqe *wqe,
 
 typedef void (*mlx5e_fp_dealloc_wqe)(struct mlx5e_rq *rq, u16 ix);
 
+typedef void (*mlx5e_fp_build_rx_skb)(struct mlx5_cqe64 *cqe,
+				      u32 cqe_bcnt,
+				      struct mlx5e_rq *rq,
+				      struct sk_buff *skb);
+
 struct mlx5e_dma_info {
 	struct page	*page;
 	dma_addr_t	addr;
@@ -367,6 +372,7 @@ struct mlx5e_rq {
 	mlx5e_fp_handle_rx_cqe handle_rx_cqe;
 	mlx5e_fp_alloc_wqe     alloc_wqe;
 	mlx5e_fp_dealloc_wqe   dealloc_wqe;
+	mlx5e_fp_build_rx_skb  build_rx_skb;
 
 	unsigned long          state;
 	int                    ix;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 24efc8ccc075..4dc8b21d011d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -493,6 +493,12 @@ static int mlx5e_create_rq_umr_mkey(struct mlx5e_rq *rq)
 	return mlx5e_create_umr_mkey(priv, num_mtts, PAGE_SHIFT, &rq->umr_mkey);
 }
 
+/* forward declaration */
+inline void mlx5e_build_rx_skb(struct mlx5_cqe64 *cqe,
+			       u32 cqe_bcnt,
+			       struct mlx5e_rq *rq,
+			       struct sk_buff *skb);
+
 static int mlx5e_create_rq(struct mlx5e_channel *c,
 			   struct mlx5e_rq_param *param,
 			   struct mlx5e_rq *rq)
@@ -538,6 +544,7 @@ static int mlx5e_create_rq(struct mlx5e_channel *c,
 	if (rq->xdp_prog)
 		rq->buff.map_dir = DMA_BIDIRECTIONAL;
 
+	rq->build_rx_skb = mlx5e_build_rx_skb;
 	switch (priv->params.rq_wq_type) {
 	case MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ:
 		if (mlx5e_is_vf_vport_rep(priv)) {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index ad08e64fee1a..98546b3395df 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -590,10 +590,10 @@ static inline void mlx5e_handle_csum(struct net_device *netdev,
 	rq->stats.csum_none++;
 }
 
-static inline void mlx5e_build_rx_skb(struct mlx5_cqe64 *cqe,
-				      u32 cqe_bcnt,
-				      struct mlx5e_rq *rq,
-				      struct sk_buff *skb)
+inline void mlx5e_build_rx_skb(struct mlx5_cqe64 *cqe,
+			       u32 cqe_bcnt,
+			       struct mlx5e_rq *rq,
+			       struct sk_buff *skb)
 {
 	struct net_device *netdev = rq->netdev;
 	struct mlx5e_tstamp *tstamp = rq->tstamp;
@@ -632,7 +632,7 @@ static inline void mlx5e_complete_rx_cqe(struct mlx5e_rq *rq,
 {
 	rq->stats.packets++;
 	rq->stats.bytes += cqe_bcnt;
-	mlx5e_build_rx_skb(cqe, cqe_bcnt, rq, skb);
+	rq->build_rx_skb(cqe, cqe_bcnt, rq, skb);
 }
 
 static inline void mlx5e_xmit_xdp_doorbell(struct mlx5e_sq *sq)
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
