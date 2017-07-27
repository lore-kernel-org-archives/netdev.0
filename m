From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net V2 01/14] net/mlx5: Clean SRIOV eswitch resources upon VF creation failure
Date: Thu, 27 Jul 2017 16:56:04 +0300
Message-ID: <20170727135617.18559-2-saeedm@mellanox.com>
References: <20170727135617.18559-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Noa Osherovich <noaos@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:40200 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751596AbdG0N5R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 09:57:17 -0400
In-Reply-To: <20170727135617.18559-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

Upon sriov enable, eswitch is always enabled.
Currently, if enable hca failed over all VFs, we would skip eswitch
disable as part of sriov disable, which will lead to resources leak.

Fix it by disabling eswitch if it was enabled (use indication from
eswitch mode).

Fixes: 6b6adee3dad2 ('net/mlx5: SRIOV core code refactoring')
Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Noa Osherovich <noaos@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c | 3 ++-
 drivers/net/ethernet/mellanox/mlx5/core/sriov.c   | 5 +++++
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index 89bfda419efe..8b18cc9ec026 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -1668,7 +1668,8 @@ void mlx5_eswitch_disable_sriov(struct mlx5_eswitch *esw)
 	int i;
 
 	if (!esw || !MLX5_CAP_GEN(esw->dev, vport_group_manager) ||
-	    MLX5_CAP_GEN(esw->dev, port_type) != MLX5_CAP_PORT_TYPE_ETH)
+	    MLX5_CAP_GEN(esw->dev, port_type) != MLX5_CAP_PORT_TYPE_ETH ||
+	    esw->mode == SRIOV_NONE)
 		return;
 
 	esw_info(esw->dev, "disable SRIOV: active vports(%d) mode(%d)\n",
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/sriov.c b/drivers/net/ethernet/mellanox/mlx5/core/sriov.c
index bcdf7779c48d..bf99d40e30b4 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/sriov.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/sriov.c
@@ -88,7 +88,11 @@ static void mlx5_device_disable_sriov(struct mlx5_core_dev *dev)
 	int vf;
 
 	if (!sriov->enabled_vfs)
+#ifdef CONFIG_MLX5_CORE_EN
+		goto disable_sriov_resources;
+#else
 		return;
+#endif
 
 	for (vf = 0; vf < sriov->num_vfs; vf++) {
 		if (!sriov->vfs_ctx[vf].enabled)
@@ -103,6 +107,7 @@ static void mlx5_device_disable_sriov(struct mlx5_core_dev *dev)
 	}
 
 #ifdef CONFIG_MLX5_CORE_EN
+disable_sriov_resources:
 	mlx5_eswitch_disable_sriov(dev->priv.eswitch);
 #endif
 
-- 
2.13.0
