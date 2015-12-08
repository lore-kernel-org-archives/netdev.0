From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 2/2] net/mlx5e: Assign random MAC address if needed
Date: Tue,  8 Dec 2015 23:56:51 +0200
Message-ID: <1449611811-30573-3-git-send-email-saeedm@mellanox.com>
References: <1449611811-30573-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	saeedm@dev.mellanox.co.il, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:40437 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750879AbbLHV5Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2015 16:57:16 -0500
In-Reply-To: <1449611811-30573-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Under SRIOV there might be a case where VFs are loaded
without pre-assigned MAC address. In this case, the VF
will randomize its own MAC.  This will address the case
of administrator not assigning MAC to the VF through
the PF OS APIs and keep udev happy.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |    5 +++++
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |    3 +++
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index d67058a..a20be56 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2103,6 +2103,11 @@ static void mlx5e_set_netdev_dev_addr(struct net_device *netdev)
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 
 	mlx5_query_nic_vport_mac_address(priv->mdev, 0, netdev->dev_addr);
+	if (is_zero_ether_addr(netdev->dev_addr) &&
+	    !MLX5_CAP_GEN(priv->mdev, vport_group_manager)) {
+		eth_hw_addr_random(netdev);
+		mlx5_core_info(priv->mdev, "Assigned random MAC address %pM\n", netdev->dev_addr);
+	}
 }
 
 static void mlx5e_build_netdev(struct net_device *netdev)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
index bee7da8..ea6a137 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
@@ -65,6 +65,9 @@ do {									\
 		(__dev)->priv.name, __func__, __LINE__, current->pid,	\
 		##__VA_ARGS__)
 
+#define mlx5_core_info(__dev, format, ...)				\
+	dev_info(&(__dev)->pdev->dev, format, ##__VA_ARGS__)
+
 enum {
 	MLX5_CMD_DATA, /* print command payload only */
 	MLX5_CMD_TIME, /* print command execution time */
-- 
1.7.1
