From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 02/18] net/mlx4_en: Change loopback only upon feature change
Date: Thu,  2 Apr 2015 16:31:07 +0300
Message-ID: <1427981483-19317-3-git-send-email-ogerlitz@mellanox.com>
References: <1427981483-19317-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Ido Shamay <idos@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:45667 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752057AbbDBNby (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Apr 2015 09:31:54 -0400
In-Reply-To: <1427981483-19317-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Shamay <idos@mellanox.com>

Currently any change of netdev features results in a call to
mlx4_en_update_loopback_state(). Those calls are unnecessary,
and should be called only upon loopback feature change.

Also moved some of the logic into mlx4_en_update_loopback_state().

Signed-off-by: Ido Shamay <idos@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_main.c   |    5 +++++
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   12 +++++-------
 2 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_main.c b/drivers/net/ethernet/mellanox/mlx4/en_main.c
index 58d5a07..913b716 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_main.c
@@ -103,6 +103,11 @@ void mlx4_en_update_loopback_state(struct net_device *dev,
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 
+	if (features & NETIF_F_LOOPBACK)
+		priv->ctrl_flags |= cpu_to_be32(MLX4_WQE_CTRL_FORCE_LOOPBACK);
+	else
+		priv->ctrl_flags &= cpu_to_be32(~MLX4_WQE_CTRL_FORCE_LOOPBACK);
+
 	priv->flags &= ~(MLX4_EN_FLAG_RX_FILTER_NEEDED|
 			MLX4_EN_FLAG_ENABLE_HW_LOOPBACK);
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 354e254..4ee564c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2210,13 +2210,11 @@ static int mlx4_en_set_features(struct net_device *netdev,
 		en_info(priv, "Turn %s TX vlan strip offload\n",
 			(features & NETIF_F_HW_VLAN_CTAG_TX) ? "ON" : "OFF");
 
-	if (features & NETIF_F_LOOPBACK)
-		priv->ctrl_flags |= cpu_to_be32(MLX4_WQE_CTRL_FORCE_LOOPBACK);
-	else
-		priv->ctrl_flags &=
-			cpu_to_be32(~MLX4_WQE_CTRL_FORCE_LOOPBACK);
-
-	mlx4_en_update_loopback_state(netdev, features);
+	if (DEV_FEATURE_CHANGED(netdev, features, NETIF_F_LOOPBACK)) {
+		en_info(priv, "Turn %s loopback\n",
+			(features & NETIF_F_LOOPBACK) ? "ON" : "OFF");
+		mlx4_en_update_loopback_state(netdev, features);
+	}
 
 	return 0;
 
-- 
1.7.1
