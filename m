From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 07/12] net/mlx5e: Poll XDP TX CQ before RX CQ
Date: Sat, 25 Mar 2017 00:52:09 +0300
Message-ID: <20170324215214.25711-8-saeedm@mellanox.com>
References: <20170324215214.25711-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, kernel-team@fb.com,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:35766 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S966697AbdCXVwo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 17:52:44 -0400
In-Reply-To: <20170324215214.25711-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Handle XDP TX completions before handling RX packets, to make sure more
free space is available for XDP TX packets a moment before handling
RX packets.

Performance improvement:
System: Intel(R) Xeon(R) CPU E5-2620 v3 @ 2.40GHz

Test case              Before     Now      improvement
---------------------------------------------------------------
XDP Drop (1 core)      16.9Mpps  16.9Mpps    No change
XDP TX   (1 core)      12Mpps    13Mpps      8%

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Reviewed-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
index 9beeb4a1212f..c880022bb21a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
@@ -118,12 +118,12 @@ int mlx5e_napi_poll(struct napi_struct *napi, int budget)
 	for (i = 0; i < c->num_tc; i++)
 		busy |= mlx5e_poll_tx_cq(&c->sq[i].cq, budget);
 
-	work_done = mlx5e_poll_rx_cq(&c->rq.cq, budget);
-	busy |= work_done == budget;
-
 	if (c->xdp)
 		busy |= mlx5e_poll_xdpsq_cq(&c->rq.xdpsq.cq);
 
+	work_done = mlx5e_poll_rx_cq(&c->rq.cq, budget);
+	busy |= work_done == budget;
+
 	mlx5e_poll_ico_cq(&c->icosq.cq);
 
 	busy |= mlx5e_post_rx_wqes(&c->rq);
-- 
2.11.0
