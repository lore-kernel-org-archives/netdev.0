From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 16/16] mlxsw: spectrum_switchdev: Consider mrouter status for mdb changes
Date: Wed, 20 Sep 2017 16:15:16 +0200
Message-ID: <20170920141516.1402-17-jiri@resnulli.us>
References: <20170920141516.1402-1-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:37645 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751768AbdITOPd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 10:15:33 -0400
Received: by mail-wm0-f67.google.com with SMTP id f4so2564311wmh.4
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 07:15:32 -0700 (PDT)
In-Reply-To: <20170920141516.1402-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

When a mrouter is registered or leaves a mid, don't update the HW.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 459cedc..0f9eac5 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -1491,6 +1491,9 @@ static int mlxsw_sp_port_mdb_add(struct mlxsw_sp_port *mlxsw_sp_port,
 	if (!bridge_device->multicast_enabled)
 		return 0;
 
+	if (bridge_port->mrouter)
+		return 0;
+
 	err = mlxsw_sp_port_smid_set(mlxsw_sp_port, mid->mid, true);
 	if (err) {
 		netdev_err(dev, "Unable to set SMID\n");
@@ -1613,10 +1616,12 @@ __mlxsw_sp_port_mdb_del(struct mlxsw_sp_port *mlxsw_sp_port,
 	int err;
 
 	if (bridge_port->bridge_device->multicast_enabled) {
-		err = mlxsw_sp_port_smid_set(mlxsw_sp_port, mid->mid, false);
-
-		if (err)
-			netdev_err(dev, "Unable to remove port from SMID\n");
+		if (bridge_port->bridge_device->multicast_enabled) {
+			err = mlxsw_sp_port_smid_set(mlxsw_sp_port, mid->mid,
+						     false);
+			if (err)
+				netdev_err(dev, "Unable to remove port from SMID\n");
+		}
 	}
 
 	err = mlxsw_sp_port_remove_from_mid(mlxsw_sp_port, mid);
-- 
2.9.5
