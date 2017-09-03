From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 08/17] net/mlx5e: Refactor data-path lro header function
Date: Sun,  3 Sep 2017 07:21:08 +0300
Message-ID: <20170903042117.28923-9-saeedm@mellanox.com>
References: <20170903042117.28923-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, kernel-team@fb.com,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:60042 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751119AbdICEWM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 3 Sep 2017 00:22:12 -0400
In-Reply-To: <20170903042117.28923-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

Refactor function mlx5e_lro_update_hdr() to reduce number of
branches.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c | 45 +++++++++++--------------
 include/linux/mlx5/device.h                     |  2 +-
 2 files changed, 21 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index ab1213a3615e..9d9c13ae6b83 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -496,56 +496,51 @@ static void mlx5e_lro_update_hdr(struct sk_buff *skb, struct mlx5_cqe64 *cqe,
 				 u32 cqe_bcnt)
 {
 	struct ethhdr	*eth = (struct ethhdr *)(skb->data);
-	struct iphdr	*ipv4;
-	struct ipv6hdr	*ipv6;
 	struct tcphdr	*tcp;
 	int network_depth = 0;
 	__be16 proto;
 	u16 tot_len;
+	void *ip_p;
 
 	u8 l4_hdr_type = get_cqe_l4_hdr_type(cqe);
-	int tcp_ack = ((l4_hdr_type == CQE_L4_HDR_TYPE_TCP_ACK_NO_DATA) ||
-		       (l4_hdr_type == CQE_L4_HDR_TYPE_TCP_ACK_AND_DATA));
+	u8 tcp_ack = (l4_hdr_type == CQE_L4_HDR_TYPE_TCP_ACK_NO_DATA) ||
+		(l4_hdr_type == CQE_L4_HDR_TYPE_TCP_ACK_AND_DATA);
 
 	skb->mac_len = ETH_HLEN;
 	proto = __vlan_get_protocol(skb, eth->h_proto, &network_depth);
 
-	ipv4 = (struct iphdr *)(skb->data + network_depth);
-	ipv6 = (struct ipv6hdr *)(skb->data + network_depth);
 	tot_len = cqe_bcnt - network_depth;
+	ip_p = skb->data + network_depth;
 
 	if (proto == htons(ETH_P_IP)) {
-		tcp = (struct tcphdr *)(skb->data + network_depth +
-					sizeof(struct iphdr));
-		ipv6 = NULL;
-		skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
-	} else {
-		tcp = (struct tcphdr *)(skb->data + network_depth +
-					sizeof(struct ipv6hdr));
-		ipv4 = NULL;
-		skb_shinfo(skb)->gso_type = SKB_GSO_TCPV6;
-	}
-
-	if (get_cqe_lro_tcppsh(cqe))
-		tcp->psh                = 1;
+		struct iphdr *ipv4 = ip_p;
 
-	if (tcp_ack) {
-		tcp->ack                = 1;
-		tcp->ack_seq            = cqe->lro_ack_seq_num;
-		tcp->window             = cqe->lro_tcp_win;
-	}
+		tcp = ip_p + sizeof(struct iphdr);
+		skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
 
-	if (ipv4) {
 		ipv4->ttl               = cqe->lro_min_ttl;
 		ipv4->tot_len           = cpu_to_be16(tot_len);
 		ipv4->check             = 0;
 		ipv4->check             = ip_fast_csum((unsigned char *)ipv4,
 						       ipv4->ihl);
 	} else {
+		struct ipv6hdr *ipv6 = ip_p;
+
+		tcp = ip_p + sizeof(struct ipv6hdr);
+		skb_shinfo(skb)->gso_type = SKB_GSO_TCPV6;
+
 		ipv6->hop_limit         = cqe->lro_min_ttl;
 		ipv6->payload_len       = cpu_to_be16(tot_len -
 						      sizeof(struct ipv6hdr));
 	}
+
+	tcp->psh = get_cqe_lro_tcppsh(cqe);
+
+	if (tcp_ack) {
+		tcp->ack                = 1;
+		tcp->ack_seq            = cqe->lro_ack_seq_num;
+		tcp->window             = cqe->lro_tcp_win;
+	}
 }
 
 static inline void mlx5e_skb_set_hash(struct mlx5_cqe64 *cqe,
diff --git a/include/linux/mlx5/device.h b/include/linux/mlx5/device.h
index 3c7442b56460..7031d655ec32 100644
--- a/include/linux/mlx5/device.h
+++ b/include/linux/mlx5/device.h
@@ -709,7 +709,7 @@ static inline int mlx5_get_cqe_format(struct mlx5_cqe64 *cqe)
 	return (cqe->op_own >> 2) & 0x3;
 }
 
-static inline int get_cqe_lro_tcppsh(struct mlx5_cqe64 *cqe)
+static inline u8 get_cqe_lro_tcppsh(struct mlx5_cqe64 *cqe)
 {
 	return (cqe->lro_tcppsh_abort_dupack >> 6) & 1;
 }
-- 
2.13.0
