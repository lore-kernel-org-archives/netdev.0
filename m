From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 07/10] net/mlx5e: Retrieve the switchdev id from the firmware only once
Date: Thu, 18 Aug 2016 21:09:08 +0300
Message-ID: <1471543751-24164-8-git-send-email-saeedm@mellanox.com>
References: <1471543751-24164-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:41782 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932393AbcHSBnO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 21:43:14 -0400
In-Reply-To: <1471543751-24164-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

Avoid firmware command execution each time the switchdev HW ID attr get
call is made. We do that by reading the ID (PF NIC MAC) only once at
load time and store it on the representor structure.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 5 +++++
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c  | 5 ++---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h | 1 +
 3 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 65258b2..03d944c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3387,6 +3387,7 @@ static void mlx5e_nic_enable(struct mlx5e_priv *priv)
 	queue_work(priv->wq, &priv->set_rx_mode_work);
 
 	if (MLX5_CAP_GEN(mdev, vport_group_manager)) {
+		mlx5_query_nic_vport_mac_address(mdev, 0, rep.hw_id);
 		rep.load = mlx5e_nic_rep_load;
 		rep.unload = mlx5e_nic_rep_unload;
 		rep.vport = 0;
@@ -3505,16 +3506,20 @@ static void mlx5e_register_vport_rep(struct mlx5_core_dev *mdev)
 	struct mlx5_eswitch *esw = mdev->priv.eswitch;
 	int total_vfs = MLX5_TOTAL_VPORTS(mdev);
 	int vport;
+	u8 mac[ETH_ALEN];
 
 	if (!MLX5_CAP_GEN(mdev, vport_group_manager))
 		return;
 
+	mlx5_query_nic_vport_mac_address(mdev, 0, mac);
+
 	for (vport = 1; vport < total_vfs; vport++) {
 		struct mlx5_eswitch_rep rep;
 
 		rep.load = mlx5e_vport_rep_load;
 		rep.unload = mlx5e_vport_rep_unload;
 		rep.vport = vport;
+		ether_addr_copy(rep.hw_id, mac);
 		mlx5_eswitch_register_vport_rep(esw, &rep);
 	}
 }
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
index 1c7d8b8..134de4a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -135,17 +135,16 @@ static const struct ethtool_ops mlx5e_rep_ethtool_ops = {
 int mlx5e_attr_get(struct net_device *dev, struct switchdev_attr *attr)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
+	struct mlx5_eswitch_rep *rep = priv->ppriv;
 	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
-	u8 mac[ETH_ALEN];
 
 	if (esw->mode == SRIOV_NONE)
 		return -EOPNOTSUPP;
 
 	switch (attr->id) {
 	case SWITCHDEV_ATTR_ID_PORT_PARENT_ID:
-		mlx5_query_nic_vport_mac_address(priv->mdev, 0, mac);
 		attr->u.ppid.id_len = ETH_ALEN;
-		memcpy(&attr->u.ppid.id, &mac, ETH_ALEN);
+		ether_addr_copy(attr->u.ppid.id, rep->hw_id);
 		break;
 	default:
 		return -EOPNOTSUPP;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
index c0b0560..a961409 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
@@ -174,6 +174,7 @@ struct mlx5_eswitch_rep {
 	void		      *priv_data;
 	struct list_head       vport_sqs_list;
 	bool		       valid;
+	u8		       hw_id[ETH_ALEN];
 };
 
 struct mlx5_esw_offload {
-- 
2.7.4
