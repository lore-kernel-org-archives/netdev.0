From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 07/10] net/mlx5e: IPoIB, Handle change_mtu
Date: Tue, 20 Jun 2017 17:13:11 +0300
Message-ID: <20170620141314.25620-8-saeedm@mellanox.com>
References: <20170620141314.25620-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Erez Shitrit <erezsh@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:42058 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751959AbdFTONd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 10:13:33 -0400
In-Reply-To: <20170620141314.25620-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erez Shitrit <erezsh@mellanox.com>

Add the ndo that supports change mtu for IPoIB.
The callback called from the ipoib ULP driver, that gives the ability to
change the SW and HW resources accordingly in the lower driver.

Signed-off-by: Erez Shitrit <erezsh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 .../net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c  | 31 ++++++++++++++++++++++
 1 file changed, 31 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c
index 9cf5f465caae..52a58af571a2 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c
@@ -42,12 +42,14 @@ static int mlx5i_open(struct net_device *netdev);
 static int mlx5i_close(struct net_device *netdev);
 static int  mlx5i_dev_init(struct net_device *dev);
 static void mlx5i_dev_cleanup(struct net_device *dev);
+static int mlx5i_change_mtu(struct net_device *netdev, int new_mtu);
 
 static const struct net_device_ops mlx5i_netdev_ops = {
 	.ndo_open                = mlx5i_open,
 	.ndo_stop                = mlx5i_close,
 	.ndo_init                = mlx5i_dev_init,
 	.ndo_uninit              = mlx5i_dev_cleanup,
+	.ndo_change_mtu          = mlx5i_change_mtu,
 };
 
 /* IPoIB mlx5 netdev profile */
@@ -312,6 +314,35 @@ static const struct mlx5e_profile mlx5i_nic_profile = {
 
 /* mlx5i netdev NDos */
 
+static int mlx5i_change_mtu(struct net_device *netdev, int new_mtu)
+{
+	struct mlx5e_priv *priv = mlx5i_epriv(netdev);
+	struct mlx5e_channels new_channels = {};
+	int curr_mtu;
+	int err = 0;
+
+	mutex_lock(&priv->state_lock);
+
+	curr_mtu    = netdev->mtu;
+	netdev->mtu = new_mtu;
+
+	if (!test_bit(MLX5E_STATE_OPENED, &priv->state))
+		goto out;
+
+	new_channels.params = priv->channels.params;
+	err = mlx5e_open_channels(priv, &new_channels);
+	if (err) {
+		netdev->mtu = curr_mtu;
+		goto out;
+	}
+
+	mlx5e_switch_priv_channels(priv, &new_channels, NULL);
+
+out:
+	mutex_unlock(&priv->state_lock);
+	return err;
+}
+
 static int mlx5i_dev_init(struct net_device *dev)
 {
 	struct mlx5e_priv    *priv   = mlx5i_epriv(dev);
-- 
2.11.0
