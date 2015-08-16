From: Achiad Shochat <achiad@mellanox.com>
Subject: [PATCH net-next 5/8] net/mlx5e: HW LRO changes/fixes
Date: Sun, 16 Aug 2015 16:04:49 +0300
Message-ID: <1439730292-29617-6-git-send-email-achiad@mellanox.com>
References: <1439730292-29617-1-git-send-email-achiad@mellanox.com>
Cc: netdev@vger.kernel.org, Achiad <achiad@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Tal Alon <talal@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:38406 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751500AbbHPNHF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Aug 2015 09:07:05 -0400
In-Reply-To: <1439730292-29617-1-git-send-email-achiad@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Change the maximum LRO session size from 16KB to 64KB
- Reduce the LRO session timeout from 512us to 32us in
  order to reduce the TCP latency of non-LRO'ed flows.
- Fix skb_shinfo(skb)->gso_size and set skb_shinfo(skb)->gso_type.
- Fix a bug accessing un-initialized mdev pointer.

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      | 2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 3 +--
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   | 4 +++-
 3 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index d32a005..298f0bf 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -50,7 +50,7 @@
 #define MLX5E_PARAMS_DEFAULT_LOG_RQ_SIZE                0xa
 #define MLX5E_PARAMS_MAXIMUM_LOG_RQ_SIZE                0xd
 
-#define MLX5E_PARAMS_DEFAULT_LRO_WQE_SZ                 (16 * 1024)
+#define MLX5E_PARAMS_DEFAULT_LRO_WQE_SZ                 (64 * 1024)
 #define MLX5E_PARAMS_DEFAULT_RX_CQ_MODERATION_USEC      0x10
 #define MLX5E_PARAMS_DEFAULT_RX_CQ_MODERATION_PKTS      0x20
 #define MLX5E_PARAMS_DEFAULT_TX_CQ_MODERATION_USEC      0x10
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 2b48ff0..f50a11977 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1300,7 +1300,7 @@ static void mlx5e_build_tir_ctx_lro(void *tirc, struct mlx5e_priv *priv)
 		  ROUGH_MAX_L2_L3_HDR_SZ) >> 8);
 	MLX5_SET(tirc, tirc, lro_timeout_period_usecs,
 		 MLX5_CAP_ETH(priv->mdev,
-			      lro_timer_supported_periods[3]));
+			      lro_timer_supported_periods[2]));
 }
 
 static int mlx5e_modify_tir_lro(struct mlx5e_priv *priv, int tt)
@@ -1940,7 +1940,6 @@ static void mlx5e_build_netdev_priv(struct mlx5_core_dev *mdev,
 	for (i = 0; i < MLX5E_INDIR_RQT_SIZE; i++)
 		priv->params.indirection_rqt[i] = i % num_channels;
 
-	priv->params.lro_en = false && !!MLX5_CAP_ETH(priv->mdev, lro_cap);
 	priv->params.lro_wqe_sz            =
 		MLX5E_PARAMS_DEFAULT_LRO_WQE_SZ;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 9a93741..9bb88f6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -111,10 +111,12 @@ static void mlx5e_lro_update_hdr(struct sk_buff *skb, struct mlx5_cqe64 *cqe)
 		tcp = (struct tcphdr *)(skb->data + ETH_HLEN +
 					sizeof(struct iphdr));
 		ipv6 = NULL;
+		skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
 	} else {
 		tcp = (struct tcphdr *)(skb->data + ETH_HLEN +
 					sizeof(struct ipv6hdr));
 		ipv4 = NULL;
+		skb_shinfo(skb)->gso_type = SKB_GSO_TCPV6;
 	}
 
 	if (get_cqe_lro_tcppsh(cqe))
@@ -162,7 +164,7 @@ static inline void mlx5e_build_rx_skb(struct mlx5_cqe64 *cqe,
 	lro_num_seg = be32_to_cpu(cqe->srqn) >> 24;
 	if (lro_num_seg > 1) {
 		mlx5e_lro_update_hdr(skb, cqe);
-		skb_shinfo(skb)->gso_size = MLX5E_PARAMS_DEFAULT_LRO_WQE_SZ;
+		skb_shinfo(skb)->gso_size = DIV_ROUND_UP(cqe_bcnt, lro_num_seg);
 		rq->stats.lro_packets++;
 		rq->stats.lro_bytes += cqe_bcnt;
 	}
-- 
1.8.3.1
