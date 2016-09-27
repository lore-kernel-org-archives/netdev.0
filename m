From: Calvin Owens <calvinowens@fb.com>
Subject: [PATCH v2] mlx5: Add ndo_poll_controller() implementation
Date: Tue, 27 Sep 2016 15:23:27 -0700
Message-ID: <df7c9e07a041523e13be905d00e74007ecb88c6b.1475014333.git.calvinowens@fb.com>
References: <CALzJLG8o3dfPJR-2iaWb-s7r65r51HhgTs5Srf92-Tx0sZCSHw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <kernel-team@fb.com>, Saeed Mahameed <saeedm@dev.mellanox.co.il>,
        Calvin Owens <calvinowens@fb.com>
To: Saeed Mahameed <saeedm@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALzJLG8o3dfPJR-2iaWb-s7r65r51HhgTs5Srf92-Tx0sZCSHw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This implements ndo_poll_controller in net_device_ops callback for mlx5,
which is necessary to use netconsole with this driver.

Cc: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Signed-off-by: Calvin Owens <calvinowens@fb.com>
---
Changes in v2:
	* Only iterate channels to avoid redundant napi_schedule() calls

drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 2459c7f..830b8d0 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2786,6 +2786,20 @@ static void mlx5e_tx_timeout(struct net_device *dev)
 		schedule_work(&priv->tx_timeout_work);
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+/* Fake "interrupt" called by netpoll (eg netconsole) to send skbs without
+ * reenabling interrupts.
+ */
+static void mlx5e_netpoll(struct net_device *dev)
+{
+	struct mlx5e_priv *priv = netdev_priv(dev);
+	int i;
+
+	for (i = 0; i < priv->params.num_channels; i++)
+		napi_schedule(&priv->channel[i]->napi);
+}
+#endif
+
 static const struct net_device_ops mlx5e_netdev_ops_basic = {
 	.ndo_open                = mlx5e_open,
 	.ndo_stop                = mlx5e_close,
@@ -2805,6 +2819,9 @@ static const struct net_device_ops mlx5e_netdev_ops_basic = {
 	.ndo_rx_flow_steer	 = mlx5e_rx_flow_steer,
 #endif
 	.ndo_tx_timeout          = mlx5e_tx_timeout,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller     = mlx5e_netpoll,
+#endif
 };
 
 static const struct net_device_ops mlx5e_netdev_ops_sriov = {
@@ -2836,6 +2853,9 @@ static const struct net_device_ops mlx5e_netdev_ops_sriov = {
 	.ndo_set_vf_link_state   = mlx5e_set_vf_link_state,
 	.ndo_get_vf_stats        = mlx5e_get_vf_stats,
 	.ndo_tx_timeout          = mlx5e_tx_timeout,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller     = mlx5e_netpoll,
+#endif
 };
 
 static int mlx5e_check_required_hca_cap(struct mlx5_core_dev *mdev)
-- 
2.9.3
