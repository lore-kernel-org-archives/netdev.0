From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V1 net-next 5/8] net/mlx4: Add set VF mac address support
Date: Thu, 25 Apr 2013 18:22:27 +0300
Message-ID: <1366903350-9096-6-git-send-email-ogerlitz@mellanox.com>
References: <1366903350-9096-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	Rony Efraim <ronye@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:36180 "EHLO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758493Ab3DYPWk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 11:22:40 -0400
In-Reply-To: <1366903350-9096-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rony Efraim <ronye@mellanox.com>

Add ndo_set_vf_mac support which allows to set the MAC address
for mlx4 VF Ethernet NICs from the host.

Signed-off-by: Rony Efraim <ronye@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c       |   31 +++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   42 +++++++++++++++++++++++-
 include/linux/mlx4/cmd.h                       |    1 +
 3 files changed, 73 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 0a301e1..a029124 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -2016,3 +2016,34 @@ u32 mlx4_comm_get_version(void)
 {
 	 return ((u32) CMD_CHAN_IF_REV << 8) | (u32) CMD_CHAN_VER;
 }
+
+static int mlx4_get_slave_indx(struct mlx4_dev *dev, int vf)
+{
+	if ((vf < 0) || (vf >= dev->num_vfs)) {
+		mlx4_err(dev, "Bad vf number:%d (number of activated vf: %d)\n", vf, dev->num_vfs);
+		return -EINVAL;
+	}
+
+	return vf+1;
+}
+
+int mlx4_set_vf_mac(struct mlx4_dev *dev, int port, int vf, u64 mac)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	struct mlx4_vport_state *s_info;
+	int slave;
+
+	if (!mlx4_is_master(dev))
+		return -EPROTONOSUPPORT;
+
+	slave = mlx4_get_slave_indx(dev, vf);
+	if (slave < 0)
+		return -EINVAL;
+
+	s_info = &priv->mfunc.master.vf_admin[slave].vport[port];
+	s_info->mac = mac;
+	mlx4_info(dev, "default mac on vf %d port %d to %llX will take afect only after vf restart\n",
+		  vf, port, s_info->mac);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(mlx4_set_vf_mac);
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 05c7c13..8293a92 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2024,6 +2024,19 @@ static int mlx4_en_set_features(struct net_device *netdev,
 
 }
 
+static int mlx4_en_set_vf_mac(struct net_device *dev, int queue, u8 *mac)
+{
+	struct mlx4_en_priv *en_priv = netdev_priv(dev);
+	struct mlx4_en_dev *mdev = en_priv->mdev;
+	u64 mac_u64 = mlx4_en_mac_to_u64(mac);
+
+	if (!is_valid_ether_addr(mac))
+		return -EINVAL;
+
+	return mlx4_set_vf_mac(mdev->dev, en_priv->port, queue, mac_u64);
+}
+
+
 static const struct net_device_ops mlx4_netdev_ops = {
 	.ndo_open		= mlx4_en_open,
 	.ndo_stop		= mlx4_en_close,
@@ -2048,6 +2061,30 @@ static const struct net_device_ops mlx4_netdev_ops = {
 #endif
 };
 
+static const struct net_device_ops mlx4_netdev_ops_master = {
+	.ndo_open		= mlx4_en_open,
+	.ndo_stop		= mlx4_en_close,
+	.ndo_start_xmit		= mlx4_en_xmit,
+	.ndo_select_queue	= mlx4_en_select_queue,
+	.ndo_get_stats		= mlx4_en_get_stats,
+	.ndo_set_rx_mode	= mlx4_en_set_rx_mode,
+	.ndo_set_mac_address	= mlx4_en_set_mac,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_change_mtu		= mlx4_en_change_mtu,
+	.ndo_tx_timeout		= mlx4_en_tx_timeout,
+	.ndo_vlan_rx_add_vid	= mlx4_en_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid	= mlx4_en_vlan_rx_kill_vid,
+	.ndo_set_vf_mac		= mlx4_en_set_vf_mac,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= mlx4_en_netpoll,
+#endif
+	.ndo_set_features	= mlx4_en_set_features,
+	.ndo_setup_tc		= mlx4_en_setup_tc,
+#ifdef CONFIG_RFS_ACCEL
+	.ndo_rx_flow_steer	= mlx4_en_filter_rfs,
+#endif
+};
+
 int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 			struct mlx4_en_port_profile *prof)
 {
@@ -2164,7 +2201,10 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	/*
 	 * Initialize netdev entry points
 	 */
-	dev->netdev_ops = &mlx4_netdev_ops;
+	if (mlx4_is_master(priv->mdev->dev))
+		dev->netdev_ops = &mlx4_netdev_ops_master;
+	else
+		dev->netdev_ops = &mlx4_netdev_ops;
 	dev->watchdog_timeo = MLX4_EN_WATCHDOG_TIMEOUT;
 	netif_set_real_num_tx_queues(dev, priv->tx_ring_num);
 	netif_set_real_num_rx_queues(dev, priv->rx_ring_num);
diff --git a/include/linux/mlx4/cmd.h b/include/linux/mlx4/cmd.h
index 2606951..f21ddc6 100644
--- a/include/linux/mlx4/cmd.h
+++ b/include/linux/mlx4/cmd.h
@@ -232,6 +232,7 @@ struct mlx4_cmd_mailbox *mlx4_alloc_cmd_mailbox(struct mlx4_dev *dev);
 void mlx4_free_cmd_mailbox(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbox);
 
 u32 mlx4_comm_get_version(void);
+int mlx4_set_vf_mac(struct mlx4_dev *dev, int port, int vf, u64 mac);
 
 #define MLX4_COMM_GET_IF_REV(cmd_chan_ver) (u8)((cmd_chan_ver) >> 8)
 
-- 
1.7.1
