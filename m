From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 1/3] net/mlx4: Fix endianness issue in qp context params
Date: Mon,  9 Oct 2017 16:59:48 +0300
Message-ID: <1507557590-17747-2-git-send-email-tariqt@mellanox.com>
References: <1507557590-17747-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:33670 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754161AbdJIOAE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 10:00:04 -0400
In-Reply-To: <1507557590-17747-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Should take care of the endianness before assigning to params2 field.

Fixes: 53f33ae295a5 ("net/mlx4_core: Port aggregation upper layer interface")
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_resources.c     | 2 +-
 drivers/net/ethernet/mellanox/mlx4/qp.c               | 2 +-
 drivers/net/ethernet/mellanox/mlx4/resource_tracker.c | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_resources.c b/drivers/net/ethernet/mellanox/mlx4/en_resources.c
index 5a47f9669621..6883ac75d37f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_resources.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_resources.c
@@ -53,7 +53,7 @@ void mlx4_en_fill_qp_context(struct mlx4_en_priv *priv, int size, int stride,
 	if (is_tx) {
 		context->sq_size_stride = ilog2(size) << 3 | (ilog2(stride) - 4);
 		if (mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_PORT_REMAP)
-			context->params2 |= MLX4_QP_BIT_FPP;
+			context->params2 |= cpu_to_be32(MLX4_QP_BIT_FPP);
 
 	} else {
 		context->sq_size_stride = ilog2(TXBB_SIZE) - 4;
diff --git a/drivers/net/ethernet/mellanox/mlx4/qp.c b/drivers/net/ethernet/mellanox/mlx4/qp.c
index 728a2fb1f5c0..203320923340 100644
--- a/drivers/net/ethernet/mellanox/mlx4/qp.c
+++ b/drivers/net/ethernet/mellanox/mlx4/qp.c
@@ -925,7 +925,7 @@ int mlx4_qp_to_ready(struct mlx4_dev *dev, struct mlx4_mtt *mtt,
 		context->flags &= cpu_to_be32(~(0xf << 28));
 		context->flags |= cpu_to_be32(states[i + 1] << 28);
 		if (states[i + 1] != MLX4_QP_STATE_RTR)
-			context->params2 &= ~MLX4_QP_BIT_FPP;
+			context->params2 &= ~cpu_to_be32(MLX4_QP_BIT_FPP);
 		err = mlx4_qp_modify(dev, mtt, states[i], states[i + 1],
 				     context, 0, 0, qp);
 		if (err) {
diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index fabb53379727..04304dd894c6 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -3185,7 +3185,7 @@ static int verify_qp_parameters(struct mlx4_dev *dev,
 	optpar	= be32_to_cpu(*(__be32 *) inbox->buf);
 
 	if (slave != mlx4_master_func_num(dev)) {
-		qp_ctx->params2 &= ~MLX4_QP_BIT_FPP;
+		qp_ctx->params2 &= ~cpu_to_be32(MLX4_QP_BIT_FPP);
 		/* setting QP rate-limit is disallowed for VFs */
 		if (qp_ctx->rate_limit_params)
 			return -EPERM;
-- 
1.8.3.1
