From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH for-next 08/15] net/mlx5e: Avoid port remapping of mlx5e netdev TISes
Date: Wed, 24 Aug 2016 13:39:07 +0300
Message-ID: <1472035154-14517-9-git-send-email-saeedm@mellanox.com>
References: <1472035154-14517-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Leon Romanovsky <leonro@mellanox.com>,
        Tal Alon <talal@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Majd Dibbiny <majd@mellanox.com>,
        Aviv Heller <avivh@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Leon Romanovsky <leon@kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:59858 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754056AbcHXKl0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 06:41:26 -0400
In-Reply-To: <1472035154-14517-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aviv Heller <avivh@mellanox.com>

TISes belonging to the mlx5e NIC should not be
subject to port remap.

Signed-off-by: Aviv Heller <avivh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Leon Romanovsky <leon@kernel.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c   |  4 ++++
 drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h | 12 ++++++++++++
 2 files changed, 16 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 219804f..fa40414 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2025,6 +2025,10 @@ static int mlx5e_create_tis(struct mlx5e_priv *priv, int tc)
 
 	MLX5_SET(tisc, tisc, prio, tc << 1);
 	MLX5_SET(tisc, tisc, transport_domain, mdev->mlx5e_res.td.tdn);
+
+	if (mlx5_lag_is_lacp_owner(mdev))
+		MLX5_SET(tisc, tisc, strict_lag_tx_port_affinity, 1);
+
 	return mlx5_core_create_tis(mdev, in, sizeof(in), &priv->tisn[tc]);
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
index 173a6b2..e716996 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
@@ -107,4 +107,16 @@ void mlx5_remove_dev_by_protocol(struct mlx5_core_dev *dev, int protocol);
 void mlx5e_init(void);
 void mlx5e_cleanup(void);
 
+static inline int mlx5_lag_is_lacp_owner(struct mlx5_core_dev *dev)
+{
+	/* LACP owner conditions:
+	 * 1) Function is physical.
+	 * 2) LAG is supported by FW.
+	 * 3) LAG is managed by driver (currently the only option).
+	 */
+	return  MLX5_CAP_GEN(dev, vport_group_manager) &&
+		   (MLX5_CAP_GEN(dev, num_lag_ports) > 1) &&
+		    MLX5_CAP_GEN(dev, lag_master);
+}
+
 #endif /* __MLX5_CORE_H__ */
-- 
2.7.4
