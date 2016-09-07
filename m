From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 1/5] net/mlx5e: Fix xmit_more counter race issue
Date: Wed,  7 Sep 2016 19:07:57 +0300
Message-ID: <1473264481-20392-2-git-send-email-saeedm@mellanox.com>
References: <1473264481-20392-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:58424 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752418AbcIGQIg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 12:08:36 -0400
In-Reply-To: <1473264481-20392-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

Update the xmit_more counter before notifying the HW,
to prevent a possible use-after-free of the skb.

Fixes: c8cf78fe100b ("net/mlx5e: Add ethtool counter for TX xmit_more")
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index 988eca9..eb0e725 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -356,6 +356,7 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 		sq->stats.stopped++;
 	}
 
+	sq->stats.xmit_more += skb->xmit_more;
 	if (!skb->xmit_more || netif_xmit_stopped(sq->txq)) {
 		int bf_sz = 0;
 
@@ -375,7 +376,6 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 
 	sq->stats.packets++;
 	sq->stats.bytes += num_bytes;
-	sq->stats.xmit_more += skb->xmit_more;
 	return NETDEV_TX_OK;
 
 dma_unmap_wqe_err:
-- 
2.7.4
