From: Aviad Yehezkel <aviadye@mellanox.com>
Subject: [RFC TLS Offload Support 07/15] mlx/mlx5_core: Allow sending multiple packets
Date: Tue, 28 Mar 2017 16:26:24 +0300
Message-ID: <1490707592-1430-8-git-send-email-aviadye@mellanox.com>
References: <1490707592-1430-1-git-send-email-aviadye@mellanox.com>
Cc: matanb@mellanox.com, liranl@mellanox.com, haggaie@mellanox.com,
        tom@herbertland.com, herbert@gondor.apana.org.au, nmav@gnults.org,
        fridolin.pokorny@gmail.com, ilant@mellanox.com,
        kliteyn@mellanox.com, linux-crypto@vger.kernel.org,
        saeedm@mellanox.com, aviadye@dev.mellanox.co.il
To: davem@davemloft.net, aviadye@mellanox.com, ilyal@mellanox.com,
        borisp@mellanox.com, davejwatson@fb.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:47706 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1755075AbdC1N16 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 09:27:58 -0400
In-Reply-To: <1490707592-1430-1-git-send-email-aviadye@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ilya Lesokhin <ilyal@mellanox.com>

Modify mlx5e_xmit to xmit multiple packet chained
using skb->next

Signed-off-by: Ilya Lesokhin <ilyal@mellanox.com>
Signed-off-by: Aviad Yehezkel <aviadye@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index e6ce509..f2d0cc0 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -35,7 +35,7 @@
 #include "en.h"
 
 #define MLX5E_SQ_NOPS_ROOM  MLX5_SEND_WQE_MAX_WQEBBS
-#define MLX5E_SQ_STOP_ROOM (MLX5_SEND_WQE_MAX_WQEBBS +\
+#define MLX5E_SQ_STOP_ROOM (2 * MLX5_SEND_WQE_MAX_WQEBBS +\
 			    MLX5E_SQ_NOPS_ROOM)
 
 void mlx5e_send_nop(struct mlx5e_sq *sq, bool notify_hw)
@@ -405,6 +405,8 @@ netdev_tx_t mlx5e_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct mlx5e_sq *sq = NULL;
 	struct mlx5_accel_ops *accel_ops;
 	struct mlx5_swp_info swp_info = {0};
+	struct sk_buff *next;
+	int rc;
 
 	rcu_read_lock();
 	accel_ops = mlx5_accel_get(priv->mdev);
@@ -417,7 +419,12 @@ netdev_tx_t mlx5e_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	sq = priv->txq_to_sq_map[skb_get_queue_mapping(skb)];
 
-	return mlx5e_sq_xmit(sq, skb, &swp_info);
+	do {
+		next = skb->next;
+		rc = mlx5e_sq_xmit(sq, skb, &swp_info);
+		skb = next;
+	} while (next);
+	return rc;
 }
 
 bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq, int napi_budget)
-- 
2.7.4
