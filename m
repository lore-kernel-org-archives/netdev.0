From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 02/16] mlxsw: spectrum_switchdev: Add a ports bitmap to the mid db
Date: Wed, 20 Sep 2017 16:15:02 +0200
Message-ID: <20170920141516.1402-3-jiri@resnulli.us>
References: <20170920141516.1402-1-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:38290 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751612AbdITOPU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 10:15:20 -0400
Received: by mail-wm0-f68.google.com with SMTP id x17so2560219wmd.5
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 07:15:19 -0700 (PDT)
In-Reply-To: <20170920141516.1402-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Add a bitmap of ports to the mid struct to hold the ports that are
registered to this mid.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h       |  1 +
 .../net/ethernet/mellanox/mlxsw/spectrum_switchdev.c | 20 +++++++++++++++++---
 2 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 7180d8f..0424bee 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -95,6 +95,7 @@ struct mlxsw_sp_mid {
 	u16 fid;
 	u16 mid;
 	unsigned int ref_count;
+	unsigned long *ports_in_mid; /* bits array */
 };
 
 enum mlxsw_sp_span_type {
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 22f8d74..0fde16a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -1239,6 +1239,7 @@ static struct mlxsw_sp_mid *__mlxsw_sp_mc_alloc(struct mlxsw_sp *mlxsw_sp,
 						u16 fid)
 {
 	struct mlxsw_sp_mid *mid;
+	size_t alloc_size;
 	u16 mid_idx;
 
 	mid_idx = find_first_zero_bit(mlxsw_sp->bridge->mids_bitmap,
@@ -1250,6 +1251,14 @@ static struct mlxsw_sp_mid *__mlxsw_sp_mc_alloc(struct mlxsw_sp *mlxsw_sp,
 	if (!mid)
 		return NULL;
 
+	alloc_size = sizeof(unsigned long) *
+		     BITS_TO_LONGS(mlxsw_core_max_ports(mlxsw_sp->core));
+	mid->ports_in_mid = kzalloc(alloc_size, GFP_KERNEL);
+	if (!mid->ports_in_mid) {
+		kfree(mid);
+		return NULL;
+	}
+
 	set_bit(mid_idx, mlxsw_sp->bridge->mids_bitmap);
 	ether_addr_copy(mid->addr, addr);
 	mid->fid = fid;
@@ -1260,12 +1269,16 @@ static struct mlxsw_sp_mid *__mlxsw_sp_mc_alloc(struct mlxsw_sp *mlxsw_sp,
 	return mid;
 }
 
-static int __mlxsw_sp_mc_dec_ref(struct mlxsw_sp *mlxsw_sp,
+static int __mlxsw_sp_mc_dec_ref(struct mlxsw_sp_port *mlxsw_sp_port,
 				 struct mlxsw_sp_mid *mid)
 {
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+
+	clear_bit(mlxsw_sp_port->local_port, mid->ports_in_mid);
 	if (--mid->ref_count == 0) {
 		list_del(&mid->list);
 		clear_bit(mid->mid, mlxsw_sp->bridge->mids_bitmap);
+		kfree(mid->ports_in_mid);
 		kfree(mid);
 		return 1;
 	}
@@ -1311,6 +1324,7 @@ static int mlxsw_sp_port_mdb_add(struct mlxsw_sp_port *mlxsw_sp_port,
 		}
 	}
 	mid->ref_count++;
+	set_bit(mlxsw_sp_port->local_port, mid->ports_in_mid);
 
 	err = mlxsw_sp_port_smid_set(mlxsw_sp_port, mid->mid, true,
 				     mid->ref_count == 1);
@@ -1331,7 +1345,7 @@ static int mlxsw_sp_port_mdb_add(struct mlxsw_sp_port *mlxsw_sp_port,
 	return 0;
 
 err_out:
-	__mlxsw_sp_mc_dec_ref(mlxsw_sp, mid);
+	__mlxsw_sp_mc_dec_ref(mlxsw_sp_port, mid);
 	return err;
 }
 
@@ -1437,7 +1451,7 @@ static int mlxsw_sp_port_mdb_del(struct mlxsw_sp_port *mlxsw_sp_port,
 		netdev_err(dev, "Unable to remove port from SMID\n");
 
 	mid_idx = mid->mid;
-	if (__mlxsw_sp_mc_dec_ref(mlxsw_sp, mid)) {
+	if (__mlxsw_sp_mc_dec_ref(mlxsw_sp_port, mid)) {
 		err = mlxsw_sp_port_mdb_op(mlxsw_sp, mdb->addr, fid_index,
 					   mid_idx, false);
 		if (err)
-- 
2.9.5
