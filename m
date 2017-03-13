From: Erez Shitrit <erezsh@mellanox.com>
Subject: [RFC v1 for accelerated IPoIB 24/25] net/mlx5e: Add support for build_rx_skb for packet from IB type
Date: Mon, 13 Mar 2017 20:31:35 +0200
Message-ID: <1489429896-10781-25-git-send-email-erezsh@mellanox.com>
References: <1489429896-10781-1-git-send-email-erezsh@mellanox.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        valex@mellanox.com, leonro@mellanox.com, saedm@mellanox.com,
        erezsh@dev.mellanox.co.il, Erez Shitrit <erezsh@mellanox.com>
To: dledford@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:49868 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753273AbdCMScL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 14:32:11 -0400
In-Reply-To: <1489429896-10781-1-git-send-email-erezsh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


New function that parse and build the skb for IPoIB traffic.

Signed-off-by: Erez Shitrit <erezsh@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |  8 ++++
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   | 49 +++++++++++++++++++++++
 2 files changed, 57 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 4dc8b21d011d..3b609bcc0914 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -499,6 +499,11 @@ inline void mlx5e_build_rx_skb(struct mlx5_cqe64 *cqe,
 			       struct mlx5e_rq *rq,
 			       struct sk_buff *skb);
 
+inline void mlx5i_build_rx_skb(struct mlx5_cqe64 *cqe,
+			       u32 cqe_bcnt,
+			       struct mlx5e_rq *rq,
+			       struct sk_buff *skb);
+
 static int mlx5e_create_rq(struct mlx5e_channel *c,
 			   struct mlx5e_rq_param *param,
 			   struct mlx5e_rq *rq)
@@ -584,6 +589,9 @@ static int mlx5e_create_rq(struct mlx5e_channel *c,
 		else
 			rq->handle_rx_cqe = mlx5e_handle_rx_cqe;
 
+		if (MLX5_CAP_GEN(mdev, port_type) != MLX5_CAP_PORT_TYPE_ETH)
+			rq->build_rx_skb = mlx5i_build_rx_skb;
+
 		rq->alloc_wqe = mlx5e_alloc_rx_wqe;
 		rq->dealloc_wqe = mlx5e_dealloc_rx_wqe;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 071a6ecce720..db3064c4b052 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -624,6 +624,55 @@ inline void mlx5e_build_rx_skb(struct mlx5_cqe64 *cqe,
 	mlx5e_handle_csum(netdev, cqe, rq, skb, !!lro_num_seg);
 }
 
+#define MLX5_IB_GRH_DGID_OFFSET 24
+#define MLX5_IB_GRH_BYTES       40
+#define MLX5_IPOIB_ENCAP_LEN    4
+#define MLX5_GID_SIZE           16
+
+inline void mlx5i_build_rx_skb(struct mlx5_cqe64 *cqe,
+			       u32 cqe_bcnt,
+			       struct mlx5e_rq *rq,
+			       struct sk_buff *skb)
+{
+	struct net_device *netdev = rq->netdev;
+	u8 *dgid;
+	u8 g;
+
+	skb_put(skb, cqe_bcnt);
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
+	mlx5e_handle_csum(netdev, cqe, rq, skb, rq->priv->params.lro_en);
+
+	skb_record_rx_queue(skb, rq->ix);
+
+	if (likely(netdev->features & NETIF_F_RXHASH))
+		mlx5e_skb_set_hash(cqe, skb);
+
+	skb_reset_mac_header(skb);
+	skb_pull(skb, MLX5_IPOIB_ENCAP_LEN);
+
+	++netdev->stats.rx_packets;
+	netdev->stats.rx_bytes += skb->len;
+
+	skb->dev = netdev;
+}
+
 static inline void mlx5e_complete_rx_cqe(struct mlx5e_rq *rq,
 					 struct mlx5_cqe64 *cqe,
 					 u32 cqe_bcnt,
-- 
1.8.3.1
