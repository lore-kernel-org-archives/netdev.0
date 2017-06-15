From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 3/6] net/mlx5e: Fix min inline value for VF rep SQs
Date: Thu, 15 Jun 2017 23:55:27 +0300
Message-ID: <20170615205530.26674-4-saeedm@mellanox.com>
References: <20170615205530.26674-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Chris Mi <chrism@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:52486 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751641AbdFOU4d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 16:56:33 -0400
In-Reply-To: <20170615205530.26674-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Mi <chrism@mellanox.com>

The offending commit only changed the code path for PF/VF, but it
didn't take care of VF representors. As a result, since
params->tx_min_inline_mode for VF representors is kzalloced to 0
(MLX5_INLINE_MODE_NONE), all VF reps SQs were set to that mode.

This actually works on CX5 by default but broke CX4. Fix that by
adding a call to query the min inline mode from the VF rep build up code.

Fixes: a6f402e49901 ("net/mlx5e: Tx, no inline copy on ConnectX-5")
Signed-off-by: Chris Mi <chrism@mellanox.com>
Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
index 79462c0368a0..46984a52a94b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -791,6 +791,8 @@ static void mlx5e_build_rep_params(struct mlx5_core_dev *mdev,
 	params->tx_max_inline         = mlx5e_get_max_inline_cap(mdev);
 	params->num_tc                = 1;
 	params->lro_wqe_sz            = MLX5E_PARAMS_DEFAULT_LRO_WQE_SZ;
+
+	mlx5_query_min_inline(mdev, &params->tx_min_inline_mode);
 }
 
 static void mlx5e_build_rep_netdev(struct net_device *netdev)
-- 
2.11.0
