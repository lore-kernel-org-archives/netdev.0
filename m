From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 3/9] net/mlx5e: Don't post fragmented MPWQE when RQ is disabled
Date: Mon, 29 Aug 2016 01:13:44 +0300
Message-ID: <1472422430-21583-4-git-send-email-saeedm@mellanox.com>
References: <1472422430-21583-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:53045 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1756153AbcH1WOe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 28 Aug 2016 18:14:34 -0400
In-Reply-To: <1472422430-21583-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ICO (Internal control operations) SQ (Send Queue) is closed/disabled
after RQ (Receive Queue).  After RQ is closed an ICO SQ completion
might post a fragmented MPWQE (Multi Packet Work Queue Element) into
that RQ.

As on regular RQ post, check if we are allowed to post to that
RQ (RQ is enabled). Cleanup in-progress UMR MPWQE on mlx5e_free_rx_descs
if needed.

Fixes: bc77b240b3c5 ('net/mlx5e: Add fragmented memory support for RX multi packet WQE')
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 4 ++++
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   | 6 ++++++
 2 files changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 2463eba..e259eaa 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -534,6 +534,10 @@ static void mlx5e_free_rx_descs(struct mlx5e_rq *rq)
 	__be16 wqe_ix_be;
 	u16 wqe_ix;
 
+	/* UMR WQE (if in progress) is always at wq->head */
+	if (test_bit(MLX5E_RQ_STATE_UMR_WQE_IN_PROGRESS, &rq->state))
+		mlx5e_free_rx_fragmented_mpwqe(rq, &rq->wqe_info[wq->head]);
+
 	while (!mlx5_wq_ll_is_empty(wq)) {
 		wqe_ix_be = *wq->tail_next;
 		wqe_ix    = be16_to_cpu(wqe_ix_be);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index fee1e47..b6f8ebb 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -506,6 +506,12 @@ void mlx5e_post_rx_fragmented_mpwqe(struct mlx5e_rq *rq)
 	struct mlx5e_rx_wqe *wqe = mlx5_wq_ll_get_wqe(wq, wq->head);
 
 	clear_bit(MLX5E_RQ_STATE_UMR_WQE_IN_PROGRESS, &rq->state);
+
+	if (unlikely(test_bit(MLX5E_RQ_STATE_FLUSH, &rq->state))) {
+		mlx5e_free_rx_fragmented_mpwqe(rq, &rq->wqe_info[wq->head]);
+		return;
+	}
+
 	mlx5_wq_ll_push(wq, be16_to_cpu(wqe->next.next_wqe_index));
 	rq->stats.mpwqe_frag++;
 
-- 
2.7.4
