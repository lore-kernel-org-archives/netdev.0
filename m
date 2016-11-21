From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 3/7] net/mlx5e: Support VF vport link state control for SRIOV switchdev mode
Date: Mon, 21 Nov 2016 15:05:57 +0200
Message-ID: <1479733561-26601-4-git-send-email-saeedm@mellanox.com>
References: <1479733561-26601-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:46918 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932301AbcKUNHO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 08:07:14 -0500
In-Reply-To: <1479733561-26601-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Reflect the administative link changes done on the VF representor to the
VF e-switch vport. This means that doing ip link set down/up commands on
the VF rep will modify the e-switch vport state which in turn will make
proper VF drivers to set their carrier accordingly.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c | 33 ++++++++++++++++++++++--
 1 file changed, 31 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
index e0d1a56..5e33f6b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -236,6 +236,35 @@ void mlx5e_nic_rep_unload(struct mlx5_eswitch *esw,
 	mlx5e_tc_init(priv);
 }
 
+static int mlx5e_rep_open(struct net_device *dev)
+{
+	struct mlx5e_priv *priv = netdev_priv(dev);
+	struct mlx5_eswitch_rep *rep = priv->ppriv;
+	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
+	int err;
+
+	err = mlx5e_open(dev);
+	if (err)
+		return err;
+
+	err = mlx5_eswitch_set_vport_state(esw, rep->vport, MLX5_ESW_VPORT_ADMIN_STATE_UP);
+	if (!err)
+		netif_carrier_on(dev);
+
+	return 0;
+}
+
+static int mlx5e_rep_close(struct net_device *dev)
+{
+	struct mlx5e_priv *priv = netdev_priv(dev);
+	struct mlx5_eswitch_rep *rep = priv->ppriv;
+	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
+
+	(void)mlx5_eswitch_set_vport_state(esw, rep->vport, MLX5_ESW_VPORT_ADMIN_STATE_DOWN);
+
+	return mlx5e_close(dev);
+}
+
 static int mlx5e_rep_get_phys_port_name(struct net_device *dev,
 					char *buf, size_t len)
 {
@@ -349,8 +378,8 @@ static const struct switchdev_ops mlx5e_rep_switchdev_ops = {
 };
 
 static const struct net_device_ops mlx5e_netdev_ops_rep = {
-	.ndo_open                = mlx5e_open,
-	.ndo_stop                = mlx5e_close,
+	.ndo_open                = mlx5e_rep_open,
+	.ndo_stop                = mlx5e_rep_close,
 	.ndo_start_xmit          = mlx5e_xmit,
 	.ndo_get_phys_port_name  = mlx5e_rep_get_phys_port_name,
 	.ndo_setup_tc            = mlx5e_rep_ndo_setup_tc,
-- 
2.7.4
