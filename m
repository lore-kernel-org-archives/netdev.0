From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 13/15] net/mlx5e: Support the flash device ethtool callback
Date: Fri, 23 Jun 2017 17:26:20 +0300
Message-ID: <20170623142622.16565-14-saeedm@mellanox.com>
References: <20170623142622.16565-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Yotam Gigi <yotamg@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54101 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754233AbdFWO14 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 10:27:56 -0400
In-Reply-To: <20170623142622.16565-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

This callback further invokes the mlxfw module to flash the new
firmware file to the device.

As the firmware flash process takes about 20 seconds and ethtool
takes the rtnl lock during the flash_device callback, we release
the rtnl lock at the beginning of the flash process and take it
again before leaving the callback.

This way, rtnl is not held during the process. To make sure the
device does not get deleted while being flashed, we take a
reference to it before releasing rtnl lock.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  2 ++
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   | 35 ++++++++++++++++++++++
 2 files changed, 37 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 709f500ef16f..eef0a50e2388 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -1060,6 +1060,8 @@ int mlx5e_ethtool_set_coalesce(struct mlx5e_priv *priv,
 			       struct ethtool_coalesce *coal);
 int mlx5e_ethtool_get_ts_info(struct mlx5e_priv *priv,
 			      struct ethtool_ts_info *info);
+int mlx5e_ethtool_flash_device(struct mlx5e_priv *priv,
+			       struct ethtool_flash *flash);
 
 /* mlx5e generic netdev management API */
 struct net_device*
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 169435d8aa1e..16b1e96a7050 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -1795,6 +1795,40 @@ static int mlx5e_set_rxnfc(struct net_device *dev, struct ethtool_rxnfc *cmd)
 	return err;
 }
 
+int mlx5e_ethtool_flash_device(struct mlx5e_priv *priv,
+			       struct ethtool_flash *flash)
+{
+	struct mlx5_core_dev *mdev = priv->mdev;
+	struct net_device *dev = priv->netdev;
+	const struct firmware *fw;
+	int err;
+
+	if (flash->region != ETHTOOL_FLASH_ALL_REGIONS)
+		return -EOPNOTSUPP;
+
+	err = request_firmware_direct(&fw, flash->data, &dev->dev);
+	if (err)
+		return err;
+
+	dev_hold(dev);
+	rtnl_unlock();
+
+	err = mlx5_firmware_flash(mdev, fw);
+	release_firmware(fw);
+
+	rtnl_lock();
+	dev_put(dev);
+	return err;
+}
+
+static int mlx5e_flash_device(struct net_device *dev,
+			      struct ethtool_flash *flash)
+{
+	struct mlx5e_priv *priv = netdev_priv(dev);
+
+	return mlx5e_ethtool_flash_device(priv, flash);
+}
+
 const struct ethtool_ops mlx5e_ethtool_ops = {
 	.get_drvinfo       = mlx5e_get_drvinfo,
 	.get_link          = ethtool_op_get_link,
@@ -1815,6 +1849,7 @@ const struct ethtool_ops mlx5e_ethtool_ops = {
 	.set_rxfh          = mlx5e_set_rxfh,
 	.get_rxnfc         = mlx5e_get_rxnfc,
 	.set_rxnfc         = mlx5e_set_rxnfc,
+	.flash_device      = mlx5e_flash_device,
 	.get_tunable       = mlx5e_get_tunable,
 	.set_tunable       = mlx5e_set_tunable,
 	.get_pauseparam    = mlx5e_get_pauseparam,
-- 
2.11.0
