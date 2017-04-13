From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next 14/16] net/mlx5e: IPoIB, RX handler
Date: Thu, 13 Apr 2017 06:37:04 +0300
Message-ID: <20170413033706.19016-15-saeedm@mellanox.com>
References: <20170413033706.19016-1-saeedm@mellanox.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        Vishwanathapura Niranjana <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170413033706.19016-1-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Implement IPoIB RX SKB handler.

Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Reviewed-by: Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c | 78 +++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/ipoib.c |  2 +
 drivers/net/ethernet/mellanox/mlx5/core/ipoib.h |  1 +
 3 files changed, 81 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 1a9532b31635..43308243f519 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -1031,3 +1031,81 @@ void mlx5e_free_xdpsq_descs(struct mlx5e_xdpsq *sq)
 		mlx5e_page_release(rq, di, false);
 	}
 }
+
+#ifdef CONFIG_MLX5_CORE_IPOIB
+
+#define MLX5_IB_GRH_DGID_OFFSET 24
+#define MLX5_IB_GRH_BYTES       40
+#define MLX5_IPOIB_ENCAP_LEN    4
+#define MLX5_GID_SIZE           16
+
+static inline void mlx5i_complete_rx_cqe(struct mlx5e_rq *rq,
+					 struct mlx5_cqe64 *cqe,
+					 u32 cqe_bcnt,
+					 struct sk_buff *skb)
+{
+	struct net_device *netdev = rq->netdev;
+	u8 *dgid;
+	u8 g;
+
+	g = (be32_to_cpu(cqe->flags_rqpn) >> 28) & 3;
+	dgid = skb->data + MLX5_IB_GRH_DGID_OFFSET;
+	if ((!g) || dgid[0] != 0xff)
+		skb->pkt_type = PACKET_HOST;
+	else if (memcmp(dgid, netdev->broadcast + 4, MLX5_GID_SIZE) == 0)
+		skb->pkt_type = PACKET_BROADCAST;
+	else
+		skb->pkt_type = PACKET_MULTICAST;
+
+	/* TODO: IB/ipoib: Allow mcast packets from other VFs
+	 * 68996a6e760e5c74654723eeb57bf65628ae87f4
+	 */
+
+	skb_pull(skb, MLX5_IB_GRH_BYTES);
+
+	skb->protocol = *((__be16 *)(skb->data));
+
+	skb->ip_summed = CHECKSUM_COMPLETE;
+	skb->csum = csum_unfold((__force __sum16)cqe->check_sum);
+
+	skb_record_rx_queue(skb, rq->ix);
+
+	if (likely(netdev->features & NETIF_F_RXHASH))
+		mlx5e_skb_set_hash(cqe, skb);
+
+	skb_reset_mac_header(skb);
+	skb_pull(skb, MLX5_IPOIB_ENCAP_LEN);
+
+	skb->dev = netdev;
+
+	rq->stats.csum_complete++;
+	rq->stats.packets++;
+	rq->stats.bytes += cqe_bcnt;
+}
+
+void mlx5i_handle_rx_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
+{
+	struct mlx5e_rx_wqe *wqe;
+	__be16 wqe_counter_be;
+	struct sk_buff *skb;
+	u16 wqe_counter;
+	u32 cqe_bcnt;
+
+	wqe_counter_be = cqe->wqe_counter;
+	wqe_counter    = be16_to_cpu(wqe_counter_be);
+	wqe            = mlx5_wq_ll_get_wqe(&rq->wq, wqe_counter);
+	cqe_bcnt       = be32_to_cpu(cqe->byte_cnt);
+
+	skb = skb_from_cqe(rq, cqe, wqe_counter, cqe_bcnt);
+	if (!skb)
+		goto wq_ll_pop;
+
+	mlx5i_complete_rx_cqe(rq, cqe, cqe_bcnt, skb);
+	napi_gro_receive(rq->cq.napi, skb);
+
+wq_ll_pop:
+	mlx5_wq_ll_pop(&rq->wq, wqe_counter_be,
+		       &wqe->next.next_wqe_index);
+}
+
+#endif /* CONFIG_MLX5_CORE_IPOIB */
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c b/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c
index c468aaedf0a6..001d2953cb6d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c
@@ -282,6 +282,8 @@ static const struct mlx5e_profile mlx5i_nic_profile = {
 	.disable	   = NULL, /* mlx5i_disable */
 	.update_stats	   = NULL, /* mlx5i_update_stats */
 	.max_nch	   = mlx5e_get_max_num_channels,
+	.rx_handlers.handle_rx_cqe       = mlx5i_handle_rx_cqe,
+	.rx_handlers.handle_rx_cqe_mpwqe = NULL, /* Not supported */
 	.max_tc		   = MLX5I_MAX_NUM_TC,
 };
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/ipoib.h b/drivers/net/ethernet/mellanox/mlx5/core/ipoib.h
index 89bca182464c..bae0a5cbc8ad 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/ipoib.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/ipoib.h
@@ -49,5 +49,6 @@ struct mlx5i_priv {
 
 netdev_tx_t mlx5i_sq_xmit(struct mlx5e_txqsq *sq, struct sk_buff *skb,
 			  struct mlx5_av *av, u32 dqpn, u32 dqkey);
+void mlx5i_handle_rx_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe);
 
 #endif /* __MLX5E_IPOB_H__ */
-- 
2.11.0

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
