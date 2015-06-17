From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 05/12] net/mlx5e: Poll rx cq before tx cq to improve round-trip latency
Date: Wed, 17 Jun 2015 18:26:22 +0300
Message-ID: <1434554789-13758-6-git-send-email-ogerlitz@mellanox.com>
References: <1434554789-13758-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:53997 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756858AbbFQP1O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2015 11:27:14 -0400
In-Reply-To: <1434554789-13758-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Achiad Shochat <achiad@mellanox.com>

For better round trip latency, handle rx completions before
tx completions.

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
index 088bc42..9f31572 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
@@ -60,13 +60,13 @@ int mlx5e_napi_poll(struct napi_struct *napi, int budget)
 
 	clear_bit(MLX5E_CHANNEL_NAPI_SCHED, &c->flags);
 
-	for (i = 0; i < c->num_tc; i++)
-		busy |= mlx5e_poll_tx_cq(&c->sq[i].cq);
-
 	busy |= mlx5e_poll_rx_cq(&c->rq.cq, budget);
 
 	busy |= mlx5e_post_rx_wqes(c->rq.cq.sqrq);
 
+	for (i = 0; i < c->num_tc; i++)
+		busy |= mlx5e_poll_tx_cq(&c->sq[i].cq);
+
 	if (busy)
 		return budget;
 
-- 
2.3.7
