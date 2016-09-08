From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 2/2] mlxsw: spectrum: Set port type before setting its address
Date: Thu,  8 Sep 2016 08:16:02 +0200
Message-ID: <1473315362-1984-3-git-send-email-jiri@resnulli.us>
References: <1473315362-1984-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35444 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752008AbcIHGQJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 02:16:09 -0400
Received: by mail-wm0-f66.google.com with SMTP id a6so6226994wmc.2
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2016 23:16:08 -0700 (PDT)
In-Reply-To: <1473315362-1984-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

During port init, we currently set the port's type to Ethernet after
setting its MAC address. However, the hardware documentation states this
should be the other way around.

Align the driver with the hardware documentation and set the port's MAC
address after setting its type.

Fixes: 56ade8fe3fe1 ("mlxsw: spectrum: Add initial support for Spectrum ASIC")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index e16b347..d48873b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2106,6 +2106,13 @@ static int mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 	dev->netdev_ops = &mlxsw_sp_port_netdev_ops;
 	dev->ethtool_ops = &mlxsw_sp_port_ethtool_ops;
 
+	err = mlxsw_sp_port_swid_set(mlxsw_sp_port, 0);
+	if (err) {
+		dev_err(mlxsw_sp->bus_info->dev, "Port %d: Failed to set SWID\n",
+			mlxsw_sp_port->local_port);
+		goto err_port_swid_set;
+	}
+
 	err = mlxsw_sp_port_dev_addr_init(mlxsw_sp_port);
 	if (err) {
 		dev_err(mlxsw_sp->bus_info->dev, "Port %d: Unable to init port mac address\n",
@@ -2131,13 +2138,6 @@ static int mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 		goto err_port_system_port_mapping_set;
 	}
 
-	err = mlxsw_sp_port_swid_set(mlxsw_sp_port, 0);
-	if (err) {
-		dev_err(mlxsw_sp->bus_info->dev, "Port %d: Failed to set SWID\n",
-			mlxsw_sp_port->local_port);
-		goto err_port_swid_set;
-	}
-
 	err = mlxsw_sp_port_speed_by_width_set(mlxsw_sp_port, width);
 	if (err) {
 		dev_err(mlxsw_sp->bus_info->dev, "Port %d: Failed to enable speeds\n",
@@ -2219,10 +2219,10 @@ err_port_buffers_init:
 err_port_admin_status_set:
 err_port_mtu_set:
 err_port_speed_by_width_set:
-	mlxsw_sp_port_swid_set(mlxsw_sp_port, MLXSW_PORT_SWID_DISABLED_PORT);
-err_port_swid_set:
 err_port_system_port_mapping_set:
 err_dev_addr_init:
+	mlxsw_sp_port_swid_set(mlxsw_sp_port, MLXSW_PORT_SWID_DISABLED_PORT);
+err_port_swid_set:
 	free_percpu(mlxsw_sp_port->pcpu_stats);
 err_alloc_stats:
 	kfree(mlxsw_sp_port->untagged_vlans);
-- 
2.5.5
