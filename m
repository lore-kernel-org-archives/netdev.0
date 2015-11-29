From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V1 09/18] net/mlx5e: Write UC/MC list and promisc mode into vport context
Date: Sun, 29 Nov 2015 17:37:17 +0200
Message-ID: <1448811446-18598-10-git-send-email-ogerlitz@mellanox.com>
References: <1448811446-18598-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Don Dutile <ddutile@redhat.com>,
	Doug Ledford <dledford@redhat.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:35059 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751838AbbK2Piy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Nov 2015 10:38:54 -0500
In-Reply-To: <1448811446-18598-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>

Each Vport/vNIC must notify underlying e-Switch layer
for UC/MC list and promisc mode updates, in-order to update
l2 tables and SR-IOV FDB tables.

We do that at set_rx_mode ndo.

preperation for ethernet-SRIOV and l2 table management.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 .../ethernet/mellanox/mlx5/core/en_flow_table.c    | 87 ++++++++++++++++++++++
 1 file changed, 87 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c b/drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c
index 22d603f..fb02f6c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c
@@ -671,6 +671,91 @@ static void mlx5e_sync_netdev_addr(struct mlx5e_priv *priv)
 	netif_addr_unlock_bh(netdev);
 }
 
+static void mlx5e_fill_addr_array(struct mlx5e_priv *priv, int list_type,
+				  u8 addr_array[][ETH_ALEN], int size)
+{
+	bool is_uc = (list_type == MLX5_NVPRT_LIST_TYPE_UC);
+	struct net_device *ndev = priv->netdev;
+	struct mlx5e_eth_addr_hash_node *hn;
+	struct hlist_head *addr_list;
+	struct hlist_node *tmp;
+	int i = 0;
+	int hi;
+
+	addr_list = is_uc ? priv->eth_addr.netdev_uc : priv->eth_addr.netdev_mc;
+
+	if (is_uc) /* Make sure our own address is pushed first */
+		ether_addr_copy(addr_array[i++], ndev->dev_addr);
+	else if (priv->eth_addr.broadcast_enabled)
+		ether_addr_copy(addr_array[i++], ndev->broadcast);
+
+	mlx5e_for_each_hash_node(hn, tmp, addr_list, hi) {
+		if (ether_addr_equal(ndev->dev_addr, hn->ai.addr))
+			continue;
+		if (i >= size)
+			break;
+		ether_addr_copy(addr_array[i++], hn->ai.addr);
+	}
+}
+
+static void mlx5e_vport_context_update_addr_list(struct mlx5e_priv *priv,
+						 int list_type)
+{
+	bool is_uc = (list_type == MLX5_NVPRT_LIST_TYPE_UC);
+	struct mlx5e_eth_addr_hash_node *hn;
+	u8 (*addr_array)[ETH_ALEN] = NULL;
+	struct hlist_head *addr_list;
+	struct hlist_node *tmp;
+	int max_size;
+	int size;
+	int err;
+	int hi;
+
+	size = is_uc ? 0 : (priv->eth_addr.broadcast_enabled ? 1 : 0);
+	max_size = is_uc ?
+		1 << MLX5_CAP_GEN(priv->mdev, log_max_current_uc_list) :
+		1 << MLX5_CAP_GEN(priv->mdev, log_max_current_mc_list);
+
+	addr_list = is_uc ? priv->eth_addr.netdev_uc : priv->eth_addr.netdev_mc;
+	mlx5e_for_each_hash_node(hn, tmp, addr_list, hi)
+		size++;
+
+	if (size > max_size) {
+		netdev_warn(priv->netdev,
+			    "netdev %s list size (%d) > (%d) max vport list size, some addresses will be dropped\n",
+			    is_uc ? "UC" : "MC", size, max_size);
+		size = max_size;
+	}
+
+	if (size) {
+		addr_array = kcalloc(size, ETH_ALEN, GFP_KERNEL);
+		if (!addr_array) {
+			err = -ENOMEM;
+			goto out;
+		}
+		mlx5e_fill_addr_array(priv, list_type, addr_array, size);
+	}
+
+	err = mlx5_modify_nic_vport_mac_list(priv->mdev, list_type, addr_array, size);
+out:
+	if (err)
+		netdev_err(priv->netdev,
+			   "Failed to modify vport %s list err(%d)\n",
+			   is_uc ? "UC" : "MC", err);
+	kfree(addr_array);
+}
+
+static void mlx5e_vport_context_update(struct mlx5e_priv *priv)
+{
+	struct mlx5e_eth_addr_db *ea = &priv->eth_addr;
+
+	mlx5e_vport_context_update_addr_list(priv, MLX5_NVPRT_LIST_TYPE_UC);
+	mlx5e_vport_context_update_addr_list(priv, MLX5_NVPRT_LIST_TYPE_MC);
+	mlx5_modify_nic_vport_promisc(priv->mdev, 0,
+				      ea->allmulti_enabled,
+				      ea->promisc_enabled);
+}
+
 static void mlx5e_apply_netdev_addr(struct mlx5e_priv *priv)
 {
 	struct mlx5e_eth_addr_hash_node *hn;
@@ -748,6 +833,8 @@ void mlx5e_set_rx_mode_work(struct work_struct *work)
 	ea->promisc_enabled   = promisc_enabled;
 	ea->allmulti_enabled  = allmulti_enabled;
 	ea->broadcast_enabled = broadcast_enabled;
+
+	mlx5e_vport_context_update(priv);
 }
 
 void mlx5e_init_eth_addr(struct mlx5e_priv *priv)
-- 
2.3.7
