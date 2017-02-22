From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 6/6] net/mlx5e: Fix wrong CQE decompression
Date: Wed, 22 Feb 2017 17:20:16 +0200
Message-ID: <20170222152016.31263-7-saeedm@mellanox.com>
References: <20170222152016.31263-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Tariq Toukan <tariqt@mellanox.com>,
        kernel-team@fb.com, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:57770 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S933019AbdBVPVr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 10:21:47 -0500
In-Reply-To: <20170222152016.31263-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

In cqe compression with striding RQ, the decompression of the CQE field
wqe_counter was done with a wrong wraparound value.
This caused handling cqes with a wrong pointer to wqe (rx descriptor)
and creating SKBs with wrong data, pointing to wrong (and already consumed)
strides/pages.

The meaning of the CQE field wqe_counter in striding RQ holds the
stride index instead of the WQE index. Hence, when decompressing
a CQE, wqe_counter should have wrapped-around the number of strides
in a single multi-packet WQE.

We dropped this wrap-around mask at all in CQE decompression of striding
RQ. It is not needed as in such cases the CQE compression session would
break because of different value of wqe_id field, starting a new
compression session.

Tested:
 ethtool -K ethxx lro off/on
 ethtool --set-priv-flags ethxx rx_cqe_compress on
 super_netperf 16 {ipv4,ipv6} -t TCP_STREAM -m 50 -D
 verified no csum errors and no page refcount issues.

Fixes: 7219ab34f184 ("net/mlx5e: CQE compression")
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Reported-by: Tom Herbert <tom@herbertland.com>
Cc: kernel-team@fb.com
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index d5ce20db3f0b..3d371688fbbb 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -94,19 +94,18 @@ static inline void mlx5e_cqes_update_owner(struct mlx5e_cq *cq, u32 cqcc, int n)
 static inline void mlx5e_decompress_cqe(struct mlx5e_rq *rq,
 					struct mlx5e_cq *cq, u32 cqcc)
 {
-	u16 wqe_cnt_step;
-
 	cq->title.byte_cnt     = cq->mini_arr[cq->mini_arr_idx].byte_cnt;
 	cq->title.check_sum    = cq->mini_arr[cq->mini_arr_idx].checksum;
 	cq->title.op_own      &= 0xf0;
 	cq->title.op_own      |= 0x01 & (cqcc >> cq->wq.log_sz);
 	cq->title.wqe_counter  = cpu_to_be16(cq->decmprs_wqe_counter);
 
-	wqe_cnt_step =
-		rq->wq_type == MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ ?
-		mpwrq_get_cqe_consumed_strides(&cq->title) : 1;
-	cq->decmprs_wqe_counter =
-		(cq->decmprs_wqe_counter + wqe_cnt_step) & rq->wq.sz_m1;
+	if (rq->wq_type == MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ)
+		cq->decmprs_wqe_counter +=
+			mpwrq_get_cqe_consumed_strides(&cq->title);
+	else
+		cq->decmprs_wqe_counter =
+			(cq->decmprs_wqe_counter + 1) & rq->wq.sz_m1;
 }
 
 static inline void mlx5e_decompress_cqe_no_hash(struct mlx5e_rq *rq,
-- 
2.11.0
