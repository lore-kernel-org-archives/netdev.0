From: Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [RFC v1 for accelerated IPoIB 23/25] net/mlx5e: Change the function that checks the packet type
Date: Mon, 13 Mar 2017 20:31:34 +0200
Message-ID: <1489429896-10781-24-git-send-email-erezsh@mellanox.com>
References: <1489429896-10781-1-git-send-email-erezsh@mellanox.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        valex-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, saedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        erezsh-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org, Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1489429896-10781-1-git-send-email-erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Now we can use it for non-ethernet type packets (like IB).
After changing the order of the skb processing the function now can
check the skb->protocol field to check if it is ETH_P_IP/ETH_P_IPV6
packet.

Signed-off-by: Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 98546b3395df..071a6ecce720 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -549,9 +549,8 @@ static inline void mlx5e_skb_set_hash(struct mlx5_cqe64 *cqe,
 
 static inline bool is_first_ethertype_ip(struct sk_buff *skb)
 {
-	__be16 ethertype = ((struct ethhdr *)skb->data)->h_proto;
-
-	return (ethertype == htons(ETH_P_IP) || ethertype == htons(ETH_P_IPV6));
+	return (skb->protocol == htons(ETH_P_IP) ||
+		skb->protocol == htons(ETH_P_IPV6));
 }
 
 static inline void mlx5e_handle_csum(struct net_device *netdev,
@@ -621,8 +620,8 @@ inline void mlx5e_build_rx_skb(struct mlx5_cqe64 *cqe,
 
 	skb->mark = be32_to_cpu(cqe->sop_drop_qpn) & MLX5E_TC_FLOW_ID_MASK;
 
-	mlx5e_handle_csum(netdev, cqe, rq, skb, !!lro_num_seg);
 	skb->protocol = eth_type_trans(skb, netdev);
+	mlx5e_handle_csum(netdev, cqe, rq, skb, !!lro_num_seg);
 }
 
 static inline void mlx5e_complete_rx_cqe(struct mlx5e_rq *rq,
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
