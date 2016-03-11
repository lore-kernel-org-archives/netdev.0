From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 11/13] net/mlx5e: Prefetch next RX CQE
Date: Fri, 11 Mar 2016 15:39:52 +0200
Message-ID: <1457703594-9482-12-git-send-email-saeedm@mellanox.com>
References: <1457703594-9482-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:33285 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932186AbcCKNls (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Mar 2016 08:41:48 -0500
In-Reply-To: <1457703594-9482-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

Performance optimization that prefetches the next RX CQE while
handling the current one.

Performance tested on ConnectX4-Lx 50G.
* Netperf single TCP stream:
- bw raise of 3-10% for various representative messages sizes.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index aa7f90c..b53e9bd 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -664,15 +664,19 @@ mpwrq_cqe_out:
 int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget)
 {
 	struct mlx5e_rq *rq = container_of(cq, struct mlx5e_rq, cq);
+	struct mlx5_cqe64 *next_cqe = mlx5e_get_cqe(cq);
+	struct mlx5_cqe64 *cqe;
 	int work_done;
 
 	for (work_done = 0; work_done < budget; work_done++) {
-		struct mlx5_cqe64 *cqe = mlx5e_get_cqe(cq);
+		cqe = next_cqe;
 
 		if (!cqe)
 			break;
 
 		mlx5_cqwq_pop(&cq->wq);
+		next_cqe = mlx5e_get_cqe(cq);
+		prefetch(next_cqe);
 
 		rq->handle_rx_cqe(rq, cqe);
 	}
-- 
1.7.1
