From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 07/11] net/mlx4_en: Fix ethtool rules leftovers after module unloaded
Date: Wed, 30 Jan 2013 12:34:23 +0200
Message-ID: <1359542067-10760-8-git-send-email-amirv@mellanox.com>
References: <1359542067-10760-1-git-send-email-amirv@mellanox.com>
Cc: Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	Hadar Hen Zion <hadarh@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog108.obsmtp.com ([207.126.144.125]:46425 "HELO
	eu1sys200aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754352Ab3A3Ket (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 05:34:49 -0500
In-Reply-To: <1359542067-10760-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

As part of the driver unload flow, all steering rules must be deleted,
make sure to remove the rules that were set through ethtool.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |    3 +++
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  |   15 +++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |    3 +++
 3 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index 6f8044d..738e95d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -915,6 +915,7 @@ static int mlx4_en_flow_replace(struct net_device *dev,
 		loc_rule->id = 0;
 		memset(&loc_rule->flow_spec, 0,
 		       sizeof(struct ethtool_rx_flow_spec));
+		list_del(&loc_rule->list);
 	}
 	err = mlx4_flow_attach(priv->mdev->dev, &rule, &reg_id);
 	if (err) {
@@ -925,6 +926,7 @@ static int mlx4_en_flow_replace(struct net_device *dev,
 	loc_rule->id = reg_id;
 	memcpy(&loc_rule->flow_spec, &cmd->fs,
 	       sizeof(struct ethtool_rx_flow_spec));
+	list_add_tail(&loc_rule->list, &priv->ethtool_list);
 
 out_free_list:
 	list_for_each_entry_safe(spec, tmp_spec, &rule.list, list) {
@@ -958,6 +960,7 @@ static int mlx4_en_flow_detach(struct net_device *dev,
 	}
 	rule->id = 0;
 	memset(&rule->flow_spec, 0, sizeof(struct ethtool_rx_flow_spec));
+	list_del(&rule->list);
 out:
 	return err;
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 9c42812..333a7a0 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1039,6 +1039,9 @@ int mlx4_en_start_port(struct net_device *dev)
 
 	INIT_LIST_HEAD(&priv->mc_list);
 	INIT_LIST_HEAD(&priv->curr_list);
+	INIT_LIST_HEAD(&priv->ethtool_list);
+	memset(&priv->ethtool_rules[0], 0,
+	       sizeof(struct ethtool_flow_id) * MAX_NUM_OF_FS_RULES);
 
 	/* Calculate Rx buf size */
 	dev->mtu = min(dev->mtu, priv->max_mtu);
@@ -1202,6 +1205,7 @@ void mlx4_en_stop_port(struct net_device *dev)
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_en_dev *mdev = priv->mdev;
 	struct mlx4_en_mc_list *mclist, *tmp;
+	struct ethtool_flow_id *flow, *tmp_flow;
 	int i;
 	u8 mc_list[16] = {0};
 
@@ -1283,6 +1287,17 @@ void mlx4_en_stop_port(struct net_device *dev)
 	mlx4_put_eth_qp(mdev->dev, priv->port, priv->mac, priv->base_qpn);
 	mdev->mac_removed[priv->port] = 1;
 
+	/* Remove flow steering rules for the port*/
+	if (mdev->dev->caps.steering_mode ==
+	    MLX4_STEERING_MODE_DEVICE_MANAGED) {
+		ASSERT_RTNL();
+		list_for_each_entry_safe(flow, tmp_flow,
+					 &priv->ethtool_list, list) {
+			mlx4_flow_detach(mdev->dev, flow->id);
+			list_del(&flow->list);
+		}
+	}
+
 	/* Free RX Rings */
 	for (i = 0; i < priv->rx_ring_num; i++) {
 		mlx4_en_deactivate_rx_ring(priv, &priv->rx_ring[i]);
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 8d54412..4fb4a3e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -427,6 +427,7 @@ struct mlx4_en_frag_info {
 #endif
 
 struct ethtool_flow_id {
+	struct list_head list;
 	struct ethtool_rx_flow_spec flow_spec;
 	u64 id;
 };
@@ -441,6 +442,8 @@ struct mlx4_en_priv {
 	struct mlx4_en_port_state port_state;
 	spinlock_t stats_lock;
 	struct ethtool_flow_id ethtool_rules[MAX_NUM_OF_FS_RULES];
+	/* To allow rules removal while port is going down */
+	struct list_head ethtool_list;
 
 	unsigned long last_moder_packets[MAX_RX_RINGS];
 	unsigned long last_moder_tx_packets;
-- 
1.7.8.2
