From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH V2 6/7] net/mlx4_en: adding loopback support
Date: Sun, 27 Nov 2011 07:55:19 +0200
Message-ID: <4ED1D0C7.2040906@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<ogerlitz@mellanox.com>, <oren@mellanox.co.il>,
	<amirv@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog116.obsmtp.com ([207.126.144.141]:57180 "HELO
	eu1sys200aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754396Ab1K0ITx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2011 03:19:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.co.il>

Device must be in promiscuous mode or DMAC must be same as the host MAC, or
else packet will be dropped by the HW rx filtering.

Signed-off-by: Amir Vadai <amirv@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   19 +++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/en_tx.c     |    3 +--
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |    1 +
 include/linux/mlx4/qp.h                        |    1 +
 4 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 78d776b..4c5bbb3 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -974,6 +974,21 @@ static int mlx4_en_change_mtu(struct net_device *dev, int new_mtu)
 	return 0;
 }
 
+static int mlx4_en_set_features(struct net_device *netdev,
+		netdev_features_t features)
+{
+	struct mlx4_en_priv *priv = netdev_priv(netdev);
+
+	if (features & NETIF_F_LOOPBACK)
+		priv->ctrl_flags |= cpu_to_be32(MLX4_WQE_CTRL_FORCE_LOOPBACK);
+	else
+		priv->ctrl_flags &=
+			cpu_to_be32(~MLX4_WQE_CTRL_FORCE_LOOPBACK);
+
+	return 0;
+
+}
+
 static const struct net_device_ops mlx4_netdev_ops = {
 	.ndo_open		= mlx4_en_open,
 	.ndo_stop		= mlx4_en_close,
@@ -990,6 +1005,7 @@ static const struct net_device_ops mlx4_netdev_ops = {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= mlx4_en_netpoll,
 #endif
+	.ndo_set_features	= mlx4_en_set_features,
 };
 
 int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
@@ -1022,6 +1038,8 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	priv->port = port;
 	priv->port_up = false;
 	priv->flags = prof->flags;
+	priv->ctrl_flags = cpu_to_be32(MLX4_WQE_CTRL_CQ_UPDATE |
+			MLX4_WQE_CTRL_SOLICITED);
 	priv->tx_ring_num = prof->tx_ring_num;
 	priv->rx_ring_num = prof->rx_ring_num;
 	priv->mac_index = -1;
@@ -1088,6 +1106,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	dev->features = dev->hw_features | NETIF_F_HIGHDMA |
 			NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX |
 			NETIF_F_HW_VLAN_FILTER;
+	dev->hw_features |= NETIF_F_LOOPBACK;
 
 	mdev->pndev[port] = dev;
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 3094f94..807c218 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -679,8 +679,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	tx_desc->ctrl.vlan_tag = cpu_to_be16(vlan_tag);
 	tx_desc->ctrl.ins_vlan = MLX4_WQE_CTRL_INS_VLAN * !!vlan_tag;
 	tx_desc->ctrl.fence_size = (real_size / 16) & 0x3f;
-	tx_desc->ctrl.srcrb_flags = cpu_to_be32(MLX4_WQE_CTRL_CQ_UPDATE |
-						MLX4_WQE_CTRL_SOLICITED);
+	tx_desc->ctrl.srcrb_flags = priv->ctrl_flags;
 	if (likely(skb->ip_summed == CHECKSUM_PARTIAL)) {
 		tx_desc->ctrl.srcrb_flags |= cpu_to_be32(MLX4_WQE_CTRL_IP_CSUM |
 							 MLX4_WQE_CTRL_TCP_UDP_CSUM);
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index c367832..7d26b7a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -452,6 +452,7 @@ struct mlx4_en_priv {
 	int base_qpn;
 
 	struct mlx4_en_rss_map rss_map;
+	u32 ctrl_flags;
 	u32 flags;
 #define MLX4_EN_FLAG_PROMISC	0x1
 #define MLX4_EN_FLAG_MC_PROMISC	0x2
diff --git a/include/linux/mlx4/qp.h b/include/linux/mlx4/qp.h
index 6562ff6..bee8fa2 100644
--- a/include/linux/mlx4/qp.h
+++ b/include/linux/mlx4/qp.h
@@ -210,6 +210,7 @@ struct mlx4_wqe_ctrl_seg {
 	 * [4]   IP checksum
 	 * [3:2] C (generate completion queue entry)
 	 * [1]   SE (solicited event)
+	 * [0]   FL (force loopback)
 	 */
 	__be32			srcrb_flags;
 	/*
-- 
1.7.7
