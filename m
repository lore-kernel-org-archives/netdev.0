From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 6/8] net/mlx5e: IPoIB, handle RX packet correctly
Date: Tue, 23 May 2017 17:16:08 +0300
Message-ID: <20170523141610.27833-7-saeedm@mellanox.com>
References: <20170523141610.27833-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Erez Shitrit <erezsh@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44705 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S965519AbdEWOQk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 10:16:40 -0400
In-Reply-To: <20170523141610.27833-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erez Shitrit <erezsh@mellanox.com>

IPoIB packet contains the pseudo header area, we need to pull it prior
to reset_mac_header in order to let the GRO work well.

In more details:
GRO checks the mac address of the new coming packet, it does that by
comparing the hard_header_len size of the current packet to the previous
one in that session, the comparison is over hard_header_len size.
Now, the driver prepares that area in the skb by allocating area from the
reserved part and resetting the correct mac header to it.

Fixes: 9d6bd752c63c ("net/mlx5e: IPoIB, RX handler")
Signed-off-by: Erez Shitrit <erezsh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 7b1566f0ae58..66b5fec15313 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -1041,6 +1041,8 @@ void mlx5e_free_xdpsq_descs(struct mlx5e_xdpsq *sq)
 #define MLX5_IB_GRH_BYTES       40
 #define MLX5_IPOIB_ENCAP_LEN    4
 #define MLX5_GID_SIZE           16
+#define MLX5_IPOIB_PSEUDO_LEN   20
+#define MLX5_IPOIB_HARD_LEN     (MLX5_IPOIB_PSEUDO_LEN + MLX5_IPOIB_ENCAP_LEN)
 
 static inline void mlx5i_complete_rx_cqe(struct mlx5e_rq *rq,
 					 struct mlx5_cqe64 *cqe,
@@ -1048,6 +1050,7 @@ static inline void mlx5i_complete_rx_cqe(struct mlx5e_rq *rq,
 					 struct sk_buff *skb)
 {
 	struct net_device *netdev = rq->netdev;
+	char *pseudo_header;
 	u8 *dgid;
 	u8 g;
 
@@ -1076,8 +1079,11 @@ static inline void mlx5i_complete_rx_cqe(struct mlx5e_rq *rq,
 	if (likely(netdev->features & NETIF_F_RXHASH))
 		mlx5e_skb_set_hash(cqe, skb);
 
+	/* 20 bytes of ipoib header and 4 for encap existing */
+	pseudo_header = skb_push(skb, MLX5_IPOIB_PSEUDO_LEN);
+	memset(pseudo_header, 0, MLX5_IPOIB_PSEUDO_LEN);
 	skb_reset_mac_header(skb);
-	skb_pull(skb, MLX5_IPOIB_ENCAP_LEN);
+	skb_pull(skb, MLX5_IPOIB_HARD_LEN);
 
 	skb->dev = netdev;
 
-- 
2.11.0
