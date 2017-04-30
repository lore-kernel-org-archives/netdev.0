From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 12/15] net/mlx5e: Use prefetchw when a write is to follow
Date: Sun, 30 Apr 2017 16:20:13 +0300
Message-ID: <20170430132016.27012-13-saeedm@mellanox.com>
References: <20170430132016.27012-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen-Zion <hadarh@mellanox.com>,
        Ilya Lesokhin <ilyal@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>, kernel-team@fb.com,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:46834 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1756832AbdD3NUi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 09:20:38 -0400
In-Reply-To: <20170430132016.27012-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

"prefetchw()" prefetches the cacheline for write. Use it for
skb->data, as soon we'll be copying the packet header there.

Performance:
Single-stream packet-rate tested with pktgen.
Packets are dropped in tc level to zoom into driver data-path.
Larger gain is expected for smaller packets, as less time
is spent on handling SKB fragments, making the path shorter
and the improvement more significant.

---------------------------------------------
packet size | before    | after     | gain  |
64B         | 4,113,306 | 4,778,720 |  16%  |
1024B       | 3,633,819 | 3,950,593 | 8.7%  |

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Cc: kernel-team@fb.com
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index d717573b73da..7b1566f0ae58 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -906,7 +906,7 @@ void mlx5e_handle_rx_cqe_mpwrq(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
 		goto mpwrq_cqe_out;
 	}
 
-	prefetch(skb->data);
+	prefetchw(skb->data);
 	cqe_bcnt = mpwrq_get_cqe_byte_cnt(cqe);
 
 	mlx5e_mpwqe_fill_rx_skb(rq, cqe, wi, cqe_bcnt, skb);
-- 
2.11.0
