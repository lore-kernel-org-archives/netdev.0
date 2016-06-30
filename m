From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 10/13] net/mlx5e: Copy all L2 headers into inline segment
Date: Thu, 30 Jun 2016 17:34:47 +0300
Message-ID: <1467297290-11443-11-git-send-email-saeedm@mellanox.com>
References: <1467297290-11443-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Matthew Finlay <matt@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:37708 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752450AbcF3OhW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jun 2016 10:37:22 -0400
In-Reply-To: <1467297290-11443-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Finlay <matt@mellanox.com>

ConnectX4-Lx uses an inline wqe mode that currently defaults to
requiring the entire L2 header be included in the wqe.
This patch fixes mlx5e_get_inline_hdr_size() to account for
all L2 headers (VLAN, QinQ, etc) using skb_network_offset(skb).

Fixes: e586b3b0baee ("net/mlx5: Ethernet Datapath files")
Signed-off-by: Matthew Finlay <matt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index 65e3bce..42a5f06 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -123,7 +123,7 @@ static inline u16 mlx5e_get_inline_hdr_size(struct mlx5e_sq *sq,
 	 * headers and occur before the data gather.
 	 * Therefore these headers must be copied into the WQE
 	 */
-#define MLX5E_MIN_INLINE ETH_HLEN
+#define MLX5E_MIN_INLINE (ETH_HLEN + VLAN_HLEN)
 
 	if (bf) {
 		u16 ihs = skb_headlen(skb);
@@ -135,7 +135,7 @@ static inline u16 mlx5e_get_inline_hdr_size(struct mlx5e_sq *sq,
 			return skb_headlen(skb);
 	}
 
-	return MLX5E_MIN_INLINE;
+	return max(skb_network_offset(skb), MLX5E_MIN_INLINE);
 }
 
 static inline void mlx5e_tx_skb_pull_inline(unsigned char **skb_data,
-- 
2.8.0
