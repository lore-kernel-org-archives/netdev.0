From: Calvin Owens <calvinowens@fb.com>
Subject: [PATCH v2 net-next] mlx5: Add ndo_poll_controller() implementation
Date: Wed, 28 Sep 2016 21:46:39 -0700
Message-ID: <f7bb6739eabb508d5393a26a542797563d386b17.1475123641.git.calvinowens@fb.com>
References: <20160928.045409.1002159444377863778.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <kernel-team@fb.com>, <davem@davemloft.net>,
        Calvin Owens <calvinowens@fb.com>
To: Saeed Mahameed <saeedm@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160928.045409.1002159444377863778.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This implements ndo_poll_controller in net_device_ops callbacks for mlx5,
which is necessary to use netconsole with this driver.

Acked-By: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Calvin Owens <calvinowens@fb.com>
---
Changes in v2:
	* Only iterate channels to avoid redundant napi_schedule() calls

drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index b58cfe3..7eaf380 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3188,6 +3188,20 @@ static int mlx5e_xdp(struct net_device *dev, struct netdev_xdp *xdp)
 	}
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
@@ -3208,6 +3222,9 @@ static const struct net_device_ops mlx5e_netdev_ops_basic = {
 #endif
 	.ndo_tx_timeout          = mlx5e_tx_timeout,
 	.ndo_xdp		 = mlx5e_xdp,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller     = mlx5e_netpoll,
+#endif
 };
 
 static const struct net_device_ops mlx5e_netdev_ops_sriov = {
@@ -3240,6 +3257,9 @@ static const struct net_device_ops mlx5e_netdev_ops_sriov = {
 	.ndo_get_vf_stats        = mlx5e_get_vf_stats,
 	.ndo_tx_timeout          = mlx5e_tx_timeout,
 	.ndo_xdp		 = mlx5e_xdp,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller     = mlx5e_netpoll,
+#endif
 };
 
 static int mlx5e_check_required_hca_cap(struct mlx5_core_dev *mdev)
-- 
2.9.3
