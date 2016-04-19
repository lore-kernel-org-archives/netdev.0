From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 9/9] net/mlx5e: Reset link modes upon setting speed to zero
Date: Tue, 19 Apr 2016 15:33:42 +0300
Message-ID: <1461069222-27076-10-git-send-email-saeedm@mellanox.com>
References: <1461069222-27076-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:48513 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753716AbcDSMfH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Apr 2016 08:35:07 -0400
In-Reply-To: <1461069222-27076-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Upon ethtool request to set speed to 0 we handle it as a special request
to reset link modes to Device's defaults.

Fixes: f62b8bb8f2d3 ("net/mlx5: Extend mlx5_core to support ConnectX-4
Ethernet functionality")
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |   18 +++++++++++-------
 1 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 3476ab8..206f7fc 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -640,17 +640,10 @@ static int mlx5e_set_settings(struct net_device *netdev,
 	struct mlx5e_priv *priv    = netdev_priv(netdev);
 	struct mlx5_core_dev *mdev = priv->mdev;
 	u32 link_modes;
-	u32 speed;
 	u32 eth_proto_cap, eth_proto_admin;
 	enum mlx5_port_status ps;
 	int err;
 
-	speed = ethtool_cmd_speed(cmd);
-
-	link_modes = cmd->autoneg == AUTONEG_ENABLE ?
-		mlx5e_ethtool2ptys_adver_link(cmd->advertising) :
-		mlx5e_ethtool2ptys_speed_link(speed);
-
 	err = mlx5_query_port_proto_cap(mdev, &eth_proto_cap, MLX5_PTYS_EN);
 	if (err) {
 		netdev_err(netdev, "%s: query port eth proto cap failed: %d\n",
@@ -658,6 +651,17 @@ static int mlx5e_set_settings(struct net_device *netdev,
 		goto out;
 	}
 
+	if (cmd->autoneg == AUTONEG_ENABLE) {
+		link_modes = mlx5e_ethtool2ptys_adver_link(cmd->advertising);
+	} else {
+		u32 speed = ethtool_cmd_speed(cmd);
+
+		if (speed)
+			link_modes = mlx5e_ethtool2ptys_speed_link(speed);
+		else /* speed 0 means reset link_modes to Device's default */
+			link_modes = eth_proto_cap;
+	}
+
 	link_modes = link_modes & eth_proto_cap;
 	if (!link_modes) {
 		netdev_err(netdev, "%s: Not supported link mode(s) requested",
-- 
1.7.1
