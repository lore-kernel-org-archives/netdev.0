From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 08/16] mlxsw: spectrum_switchdev: Don't write mids to the HW when mc is disabled
Date: Wed, 20 Sep 2017 16:15:08 +0200
Message-ID: <20170920141516.1402-9-jiri@resnulli.us>
References: <20170920141516.1402-1-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35674 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751722AbdITOPZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 10:15:25 -0400
Received: by mail-wm0-f66.google.com with SMTP id e64so2588741wmi.2
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 07:15:25 -0700 (PDT)
In-Reply-To: <20170920141516.1402-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Don't write multicast related data to the HW when mc is disabled.
Also, don't allocate mid id to new mids (so the remove function could know
that they weren't wrote to the HW)

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c    | 21 +++++++++++++++++----
 1 file changed, 17 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 7f622de..cea257a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -1290,6 +1290,9 @@ mlxsw_sp_mc_write_mdb_entry(struct mlxsw_sp *mlxsw_sp,
 static int mlxsw_sp_mc_remove_mdb_entry(struct mlxsw_sp *mlxsw_sp,
 					struct mlxsw_sp_mid *mid)
 {
+	if (!mid->in_hw)
+		return 0;
+
 	clear_bit(mid->mid, mlxsw_sp->bridge->mids_bitmap);
 	mid->in_hw = false;
 	return mlxsw_sp_port_mdb_op(mlxsw_sp, mid->addr, mid->fid, mid->mid,
@@ -1319,11 +1322,15 @@ mlxsw_sp_mid *__mlxsw_sp_mc_alloc(struct mlxsw_sp *mlxsw_sp,
 	ether_addr_copy(mid->addr, addr);
 	mid->fid = fid;
 	mid->in_hw = false;
+
+	if (!bridge_device->multicast_enabled)
+		goto out;
+
 	if (!mlxsw_sp_mc_write_mdb_entry(mlxsw_sp, mid))
 		goto err_write_mdb_entry;
 
+out:
 	list_add_tail(&mid->list, &bridge_device->mids_list);
-
 	return mid;
 
 err_write_mdb_entry:
@@ -1391,6 +1398,9 @@ static int mlxsw_sp_port_mdb_add(struct mlxsw_sp_port *mlxsw_sp_port,
 	}
 	set_bit(mlxsw_sp_port->local_port, mid->ports_in_mid);
 
+	if (!bridge_device->multicast_enabled)
+		return 0;
+
 	err = mlxsw_sp_port_smid_set(mlxsw_sp_port, mid->mid, true);
 	if (err) {
 		netdev_err(dev, "Unable to set SMID\n");
@@ -1476,9 +1486,12 @@ __mlxsw_sp_port_mdb_del(struct mlxsw_sp_port *mlxsw_sp_port,
 	struct net_device *dev = mlxsw_sp_port->dev;
 	int err;
 
-	err = mlxsw_sp_port_smid_set(mlxsw_sp_port, mid->mid, false);
-	if (err)
-		netdev_err(dev, "Unable to remove port from SMID\n");
+	if (bridge_port->bridge_device->multicast_enabled) {
+		err = mlxsw_sp_port_smid_set(mlxsw_sp_port, mid->mid, false);
+
+		if (err)
+			netdev_err(dev, "Unable to remove port from SMID\n");
+	}
 
 	err = mlxsw_sp_port_remove_from_mid(mlxsw_sp_port, mid);
 	if (err)
-- 
2.9.5
