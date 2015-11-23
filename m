From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 09/18] net/mlx5e: Write UC/MC list and promisc mode into vport context
Date: Mon, 23 Nov 2015 13:11:42 +0200
Message-ID: <1448277111-16474-10-git-send-email-ogerlitz@mellanox.com>
References: <1448277111-16474-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Don Dutile <ddutile@redhat.com>,
	Doug Ledford <dledford@redhat.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:37288 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752661AbbKWLNk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2015 06:13:40 -0500
In-Reply-To: <1448277111-16474-1-git-send-email-ogerlitz@mellanox.com>
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
 .../ethernet/mellanox/mlx5/core/en_flow_table.c    | 99 ++++++++++++++++++++++
 1 file changed, 99 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c b/drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c
index 22d603f..9a021be 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c
@@ -671,6 +671,103 @@ static void mlx5e_sync_netdev_addr(struct mlx5e_priv *priv)
 	netif_addr_unlock_bh(netdev);
 }
 
+/* Returns a pointer to an array of type u8[][ETH_ALEN] */
+static u8 (*mlx5e_build_addr_array(struct mlx5e_priv *priv, int list_type,
+				   int *size))[ETH_ALEN]
+{
+	bool is_uc = (list_type == MLX5_NVPRT_LIST_TYPE_UC);
+	struct net_device *ndev = priv->netdev;
+	struct mlx5e_eth_addr_hash_node *hn;
+	struct hlist_head *addr_list;
+	u8 (*addr_array)[ETH_ALEN];
+	struct hlist_node *tmp;
+	int max_list_size;
+	int list_size;
+	int hi;
+	int i;
+
+	list_size = is_uc ? 0 : (priv->eth_addr.broadcast_enabled ? 1 : 0);
+	max_list_size = is_uc ?
+		1 << MLX5_CAP_GEN(priv->mdev, log_max_current_uc_list) :
+		1 << MLX5_CAP_GEN(priv->mdev, log_max_current_mc_list);
+
+	addr_list = is_uc ? priv->eth_addr.netdev_uc : priv->eth_addr.netdev_mc;
+	mlx5e_for_each_hash_node(hn, tmp, addr_list, hi)
+		list_size++;
+
+	if (list_size > max_list_size) {
+		netdev_warn(ndev,
+			    "netdev %s list size (%d) > (%d) max vport list size, some addresses will be dropped\n",
+			    is_uc ? "UC" : "MC", list_size, max_list_size);
+		list_size = max_list_size;
+	}
+
+	addr_array = kcalloc(list_size, ETH_ALEN, GFP_KERNEL);
+	if (!addr_array)
+		return NULL;
+
+	i = 0;
+	if (is_uc) { /* Make sure our own address is pushed first */
+		mlx5e_for_each_hash_node(hn, tmp, addr_list, hi) {
+			if (ether_addr_equal(ndev->dev_addr, hn->ai.addr)) {
+				ether_addr_copy(addr_array[i++], ndev->dev_addr);
+				break;
+			}
+		}
+	}
+
+	if (!is_uc && priv->eth_addr.broadcast_enabled)
+		ether_addr_copy(addr_array[i++], ndev->broadcast);
+
+	mlx5e_for_each_hash_node(hn, tmp, addr_list, hi) {
+		if (ether_addr_equal(ndev->dev_addr, hn->ai.addr))
+			continue;
+		if (i >= list_size)
+			break;
+		ether_addr_copy(addr_array[i++], hn->ai.addr);
+	}
+
+	*size = list_size;
+	return addr_array;
+}
+
+static void mlx5e_vport_context_update_addr_list(struct mlx5e_priv *priv,
+						 int list_type)
+{
+	bool is_uc = (list_type == MLX5_NVPRT_LIST_TYPE_UC);
+	u8 (*mac_list)[ETH_ALEN];
+	int list_size;
+	int err;
+
+	mac_list = mlx5e_build_addr_array(priv, list_type, &list_size);
+	if (!mac_list) {
+		err = -ENOMEM;
+		goto out;
+	}
+
+	err = mlx5_modify_nic_vport_mac_list(priv->mdev,
+					     list_type,
+					     mac_list,
+					     list_size);
+out:
+	if (err)
+		netdev_err(priv->netdev,
+			   "Failed to modify vport %s list err(%d)\n",
+			   is_uc ? "UC" : "MC", err);
+	kfree(mac_list);
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
@@ -748,6 +845,8 @@ void mlx5e_set_rx_mode_work(struct work_struct *work)
 	ea->promisc_enabled   = promisc_enabled;
 	ea->allmulti_enabled  = allmulti_enabled;
 	ea->broadcast_enabled = broadcast_enabled;
+
+	mlx5e_vport_context_update(priv);
 }
 
 void mlx5e_init_eth_addr(struct mlx5e_priv *priv)
-- 
2.3.7
