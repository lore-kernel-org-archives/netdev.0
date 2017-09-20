From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 03/16] mlxsw: spectrum_switchdev: Remove reference count from mid
Date: Wed, 20 Sep 2017 16:15:03 +0200
Message-ID: <20170920141516.1402-4-jiri@resnulli.us>
References: <20170920141516.1402-1-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33574 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751678AbdITOPV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 10:15:21 -0400
Received: by mail-wm0-f66.google.com with SMTP id m127so2592491wmm.0
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 07:15:20 -0700 (PDT)
In-Reply-To: <20170920141516.1402-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Since there is a bitmap for the ports registered to each mid, there is no
need for a ref count, since it will always be the number of set bits in
this bitmap. Any check of the ref count was replaced with checking if the
bitmap is empty.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h       |  1 -
 .../net/ethernet/mellanox/mlxsw/spectrum_switchdev.c | 20 ++++++++++----------
 2 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 0424bee..6fd0afe 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -94,7 +94,6 @@ struct mlxsw_sp_mid {
 	unsigned char addr[ETH_ALEN];
 	u16 fid;
 	u16 mid;
-	unsigned int ref_count;
 	unsigned long *ports_in_mid; /* bits array */
 };
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 0fde16a..cb2275ed 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -1263,19 +1263,19 @@ static struct mlxsw_sp_mid *__mlxsw_sp_mc_alloc(struct mlxsw_sp *mlxsw_sp,
 	ether_addr_copy(mid->addr, addr);
 	mid->fid = fid;
 	mid->mid = mid_idx;
-	mid->ref_count = 0;
 	list_add_tail(&mid->list, &mlxsw_sp->bridge->mids_list);
 
 	return mid;
 }
 
-static int __mlxsw_sp_mc_dec_ref(struct mlxsw_sp_port *mlxsw_sp_port,
-				 struct mlxsw_sp_mid *mid)
+static int mlxsw_sp_port_remove_from_mid(struct mlxsw_sp_port *mlxsw_sp_port,
+					 struct mlxsw_sp_mid *mid)
 {
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 
 	clear_bit(mlxsw_sp_port->local_port, mid->ports_in_mid);
-	if (--mid->ref_count == 0) {
+	if (bitmap_empty(mid->ports_in_mid,
+			 mlxsw_core_max_ports(mlxsw_sp->core))) {
 		list_del(&mid->list);
 		clear_bit(mid->mid, mlxsw_sp->bridge->mids_bitmap);
 		kfree(mid->ports_in_mid);
@@ -1296,6 +1296,7 @@ static int mlxsw_sp_port_mdb_add(struct mlxsw_sp_port *mlxsw_sp_port,
 	struct mlxsw_sp_bridge_device *bridge_device;
 	struct mlxsw_sp_bridge_port *bridge_port;
 	struct mlxsw_sp_mid *mid;
+	bool is_new_mid = false;
 	u16 fid_index;
 	int err = 0;
 
@@ -1322,18 +1323,17 @@ static int mlxsw_sp_port_mdb_add(struct mlxsw_sp_port *mlxsw_sp_port,
 			netdev_err(dev, "Unable to allocate MC group\n");
 			return -ENOMEM;
 		}
+		is_new_mid = true;
 	}
-	mid->ref_count++;
 	set_bit(mlxsw_sp_port->local_port, mid->ports_in_mid);
 
-	err = mlxsw_sp_port_smid_set(mlxsw_sp_port, mid->mid, true,
-				     mid->ref_count == 1);
+	err = mlxsw_sp_port_smid_set(mlxsw_sp_port, mid->mid, true, is_new_mid);
 	if (err) {
 		netdev_err(dev, "Unable to set SMID\n");
 		goto err_out;
 	}
 
-	if (mid->ref_count == 1) {
+	if (is_new_mid) {
 		err = mlxsw_sp_port_mdb_op(mlxsw_sp, mdb->addr, fid_index,
 					   mid->mid, true);
 		if (err) {
@@ -1345,7 +1345,7 @@ static int mlxsw_sp_port_mdb_add(struct mlxsw_sp_port *mlxsw_sp_port,
 	return 0;
 
 err_out:
-	__mlxsw_sp_mc_dec_ref(mlxsw_sp_port, mid);
+	mlxsw_sp_port_remove_from_mid(mlxsw_sp_port, mid);
 	return err;
 }
 
@@ -1451,7 +1451,7 @@ static int mlxsw_sp_port_mdb_del(struct mlxsw_sp_port *mlxsw_sp_port,
 		netdev_err(dev, "Unable to remove port from SMID\n");
 
 	mid_idx = mid->mid;
-	if (__mlxsw_sp_mc_dec_ref(mlxsw_sp_port, mid)) {
+	if (mlxsw_sp_port_remove_from_mid(mlxsw_sp_port, mid)) {
 		err = mlxsw_sp_port_mdb_op(mlxsw_sp, mdb->addr, fid_index,
 					   mid_idx, false);
 		if (err)
-- 
2.9.5
