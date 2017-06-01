From: Yotam Gigi <yotamg@mellanox.com>
Subject: [PATCH net-next] mlxsw: spectrum: Implement the ethtool flash_device callback
Date: Thu,  1 Jun 2017 16:26:46 +0300
Message-ID: <20170601132646.51869-1-yotamg@mellanox.com>
Cc: Yotam Gigi <yotamg@mellanox.com>
To: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
        ogerlitz@mellanox.com, ilant@mellanox.com, jiri@mellanox.com,
        arkadis@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:35109 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751058AbdFANXf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 09:23:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add callback to the ethtool flash_device op. This callback uses the mlxfw
module to flash the new firmware file to the device.

As the firmware flash process takes about 20 seconds and ethtool takes the
rtnl lock during the flash_device callback, release the rtnl lock at the
beginning of the flash process and take it again before leaving the
callback. This way, the rtnl is not held during the process. To make sure
the device does not get deleted during the flash process, take a reference
to it before releasing the rtnl lock.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 51 +++++++++++++++++++++-----
 1 file changed, 42 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index e25c1fd..84b6f36 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -321,6 +321,21 @@ static const struct mlxfw_dev_ops mlxsw_sp_mlxfw_dev_ops = {
 	.fsm_release		= mlxsw_sp_fsm_release
 };
 
+static int mlxsw_sp_firmware_flash(struct mlxsw_sp *mlxsw_sp,
+				   const struct firmware *firmware)
+{
+	struct mlxsw_sp_mlxfw_dev mlxsw_sp_mlxfw_dev = {
+		.mlxfw_dev = {
+			.ops = &mlxsw_sp_mlxfw_dev_ops,
+			.psid = mlxsw_sp->bus_info->psid,
+			.psid_size = strlen(mlxsw_sp->bus_info->psid),
+		},
+		.mlxsw_sp = mlxsw_sp
+	};
+
+	return mlxfw_firmware_flash(&mlxsw_sp_mlxfw_dev.mlxfw_dev, firmware);
+}
+
 static bool mlxsw_sp_fw_rev_ge(const struct mlxsw_fw_rev *a,
 			       const struct mlxsw_fw_rev *b)
 {
@@ -334,14 +349,6 @@ static bool mlxsw_sp_fw_rev_ge(const struct mlxsw_fw_rev *a,
 static int mlxsw_sp_fw_rev_validate(struct mlxsw_sp *mlxsw_sp)
 {
 	const struct mlxsw_fw_rev *rev = &mlxsw_sp->bus_info->fw_rev;
-	struct mlxsw_sp_mlxfw_dev mlxsw_sp_mlxfw_dev = {
-		.mlxfw_dev = {
-			.ops = &mlxsw_sp_mlxfw_dev_ops,
-			.psid = mlxsw_sp->bus_info->psid,
-			.psid_size = strlen(mlxsw_sp->bus_info->psid),
-		},
-		.mlxsw_sp = mlxsw_sp
-	};
 	const struct firmware *firmware;
 	int err;
 
@@ -361,7 +368,7 @@ static int mlxsw_sp_fw_rev_validate(struct mlxsw_sp *mlxsw_sp)
 		return err;
 	}
 
-	err = mlxfw_firmware_flash(&mlxsw_sp_mlxfw_dev.mlxfw_dev, firmware);
+	err = mlxsw_sp_firmware_flash(mlxsw_sp, firmware);
 	release_firmware(firmware);
 	return err;
 }
@@ -2495,6 +2502,31 @@ mlxsw_sp_port_set_link_ksettings(struct net_device *dev,
 	return 0;
 }
 
+static int mlxsw_sp_flash_device(struct net_device *dev,
+				 struct ethtool_flash *flash)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	const struct firmware *firmware;
+	int err;
+
+	if (flash->region != ETHTOOL_FLASH_ALL_REGIONS)
+		return -EOPNOTSUPP;
+
+	dev_hold(dev);
+	rtnl_unlock();
+
+	err = request_firmware_direct(&firmware, flash->data, &dev->dev);
+	if (err)
+		goto out;
+	err = mlxsw_sp_firmware_flash(mlxsw_sp, firmware);
+	release_firmware(firmware);
+out:
+	rtnl_lock();
+	dev_put(dev);
+	return err;
+}
+
 static const struct ethtool_ops mlxsw_sp_port_ethtool_ops = {
 	.get_drvinfo		= mlxsw_sp_port_get_drvinfo,
 	.get_link		= ethtool_op_get_link,
@@ -2506,6 +2538,7 @@ static const struct ethtool_ops mlxsw_sp_port_ethtool_ops = {
 	.get_sset_count		= mlxsw_sp_port_get_sset_count,
 	.get_link_ksettings	= mlxsw_sp_port_get_link_ksettings,
 	.set_link_ksettings	= mlxsw_sp_port_set_link_ksettings,
+	.flash_device		= mlxsw_sp_flash_device,
 };
 
 static int
-- 
2.8.4
