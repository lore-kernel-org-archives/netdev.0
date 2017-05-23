From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 6/9] mlxsw: spectrum: Implement the ethtool flash_device callback
Date: Tue, 23 May 2017 08:52:58 +0200
Message-ID: <20170523065301.1091-7-jiri@resnulli.us>
References: <20170523065301.1091-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35738 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761693AbdEWGxO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 02:53:14 -0400
Received: by mail-wm0-f67.google.com with SMTP id g15so17508293wmc.2
        for <netdev@vger.kernel.org>; Mon, 22 May 2017 23:53:13 -0700 (PDT)
In-Reply-To: <20170523065301.1091-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

Add callback to the ethtool flash_device op. This callback uses the mlxfw
module to flash the new firmware file to the device.

As the firmware burn process takes about 20 seconds and ethtool takes the
rtnl lock during the flash_device callback, release the rtnl lock at the
beginning of the flash process and take it again before leaving the
callback. This way, the rtnl is not held during the process. To make sure
the device does not get deleted during the flash process, take a reference
to it before releasing the rtnl lock.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/Kconfig    |  1 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 41 ++++++++++++++++++++++++++
 2 files changed, 42 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/Kconfig b/drivers/net/ethernet/mellanox/mlxsw/Kconfig
index ef23eae..b9f80c2 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlxsw/Kconfig
@@ -75,6 +75,7 @@ config MLXSW_SPECTRUM
 	depends on MLXSW_CORE && MLXSW_PCI && NET_SWITCHDEV && VLAN_8021Q
 	depends on PSAMPLE || PSAMPLE=n
 	select PARMAN
+	select MLXFW
 	default m
 	---help---
 	  This driver supports Mellanox Technologies Spectrum Ethernet
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index b533a53..9e189fc 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -306,6 +306,21 @@ static const struct mlxfw_dev_ops mlxsw_sp_mlxfw_dev_ops = {
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
 int mlxsw_sp_flow_counter_get(struct mlxsw_sp *mlxsw_sp,
 			      unsigned int counter_index, u64 *packets,
 			      u64 *bytes)
@@ -2507,6 +2522,31 @@ mlxsw_sp_port_set_link_ksettings(struct net_device *dev,
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
@@ -2518,6 +2558,7 @@ static const struct ethtool_ops mlxsw_sp_port_ethtool_ops = {
 	.get_sset_count		= mlxsw_sp_port_get_sset_count,
 	.get_link_ksettings	= mlxsw_sp_port_get_link_ksettings,
 	.set_link_ksettings	= mlxsw_sp_port_set_link_ksettings,
+	.flash_device		= mlxsw_sp_flash_device,
 };
 
 static int
-- 
2.9.3
