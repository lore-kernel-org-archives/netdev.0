From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 04/16] mlxsw: spectrum_switchdev: Save mids list per bridge device
Date: Wed, 20 Sep 2017 16:15:04 +0200
Message-ID: <20170920141516.1402-5-jiri@resnulli.us>
References: <20170920141516.1402-1-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33823 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751463AbdITOPW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 10:15:22 -0400
Received: by mail-wm0-f68.google.com with SMTP id i131so2586374wma.1
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 07:15:21 -0700 (PDT)
In-Reply-To: <20170920141516.1402-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Instead of saving all the mids in the same list, save them per vlan
device. This change allows a more efficient mid find.
Also, in the next patches, there will be added a lot of loops over all the
mids in bridge device for multicast disable, mrouter change and ndb flush.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 49 +++++++++++-----------
 1 file changed, 24 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index cb2275ed..2ba8a44 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -67,7 +67,6 @@ struct mlxsw_sp_bridge {
 	u32 ageing_time;
 	bool vlan_enabled_exists;
 	struct list_head bridges_list;
-	struct list_head mids_list;
 	DECLARE_BITMAP(mids_bitmap, MLXSW_SP_MID_MAX);
 	const struct mlxsw_sp_bridge_ops *bridge_8021q_ops;
 	const struct mlxsw_sp_bridge_ops *bridge_8021d_ops;
@@ -77,6 +76,7 @@ struct mlxsw_sp_bridge_device {
 	struct net_device *dev;
 	struct list_head list;
 	struct list_head ports_list;
+	struct list_head mids_list;
 	u8 vlan_enabled:1,
 	   multicast_enabled:1;
 	const struct mlxsw_sp_bridge_ops *ops;
@@ -161,6 +161,7 @@ mlxsw_sp_bridge_device_create(struct mlxsw_sp_bridge *bridge,
 	} else {
 		bridge_device->ops = bridge->bridge_8021d_ops;
 	}
+	INIT_LIST_HEAD(&bridge_device->mids_list);
 	list_add(&bridge_device->list, &bridge->bridges_list);
 
 	return bridge_device;
@@ -170,10 +171,17 @@ static void
 mlxsw_sp_bridge_device_destroy(struct mlxsw_sp_bridge *bridge,
 			       struct mlxsw_sp_bridge_device *bridge_device)
 {
+	struct mlxsw_sp_mid *mid, *tmp;
+
 	list_del(&bridge_device->list);
 	if (bridge_device->vlan_enabled)
 		bridge->vlan_enabled_exists = false;
 	WARN_ON(!list_empty(&bridge_device->ports_list));
+	list_for_each_entry_safe(mid, tmp, &bridge_device->mids_list, list) {
+		list_del(&mid->list);
+		clear_bit(mid->mid, bridge->mids_bitmap);
+		kfree(mid);
+	}
 	kfree(bridge_device);
 }
 
@@ -1221,22 +1229,25 @@ static int mlxsw_sp_port_smid_set(struct mlxsw_sp_port *mlxsw_sp_port, u16 mid,
 	return err;
 }
 
-static struct mlxsw_sp_mid *__mlxsw_sp_mc_get(struct mlxsw_sp *mlxsw_sp,
-					      const unsigned char *addr,
-					      u16 fid)
+static struct
+mlxsw_sp_mid *__mlxsw_sp_mc_get(struct mlxsw_sp_bridge_device *bridge_device,
+				const unsigned char *addr,
+				u16 fid)
 {
 	struct mlxsw_sp_mid *mid;
 
-	list_for_each_entry(mid, &mlxsw_sp->bridge->mids_list, list) {
+	list_for_each_entry(mid, &bridge_device->mids_list, list) {
 		if (ether_addr_equal(mid->addr, addr) && mid->fid == fid)
 			return mid;
 	}
 	return NULL;
 }
 
-static struct mlxsw_sp_mid *__mlxsw_sp_mc_alloc(struct mlxsw_sp *mlxsw_sp,
-						const unsigned char *addr,
-						u16 fid)
+static struct
+mlxsw_sp_mid *__mlxsw_sp_mc_alloc(struct mlxsw_sp *mlxsw_sp,
+				  struct mlxsw_sp_bridge_device *bridge_device,
+				  const unsigned char *addr,
+				  u16 fid)
 {
 	struct mlxsw_sp_mid *mid;
 	size_t alloc_size;
@@ -1263,7 +1274,7 @@ static struct mlxsw_sp_mid *__mlxsw_sp_mc_alloc(struct mlxsw_sp *mlxsw_sp,
 	ether_addr_copy(mid->addr, addr);
 	mid->fid = fid;
 	mid->mid = mid_idx;
-	list_add_tail(&mid->list, &mlxsw_sp->bridge->mids_list);
+	list_add_tail(&mid->list, &bridge_device->mids_list);
 
 	return mid;
 }
@@ -1316,9 +1327,10 @@ static int mlxsw_sp_port_mdb_add(struct mlxsw_sp_port *mlxsw_sp_port,
 
 	fid_index = mlxsw_sp_fid_index(mlxsw_sp_port_vlan->fid);
 
-	mid = __mlxsw_sp_mc_get(mlxsw_sp, mdb->addr, fid_index);
+	mid = __mlxsw_sp_mc_get(bridge_device, mdb->addr, fid_index);
 	if (!mid) {
-		mid = __mlxsw_sp_mc_alloc(mlxsw_sp, mdb->addr, fid_index);
+		mid = __mlxsw_sp_mc_alloc(mlxsw_sp, bridge_device, mdb->addr,
+					  fid_index);
 		if (!mid) {
 			netdev_err(dev, "Unable to allocate MC group\n");
 			return -ENOMEM;
@@ -1440,7 +1452,7 @@ static int mlxsw_sp_port_mdb_del(struct mlxsw_sp_port *mlxsw_sp_port,
 
 	fid_index = mlxsw_sp_fid_index(mlxsw_sp_port_vlan->fid);
 
-	mid = __mlxsw_sp_mc_get(mlxsw_sp, mdb->addr, fid_index);
+	mid = __mlxsw_sp_mc_get(bridge_device, mdb->addr, fid_index);
 	if (!mid) {
 		netdev_err(dev, "Unable to remove port from MC DB\n");
 		return -EINVAL;
@@ -1995,17 +2007,6 @@ static void mlxsw_sp_fdb_fini(struct mlxsw_sp *mlxsw_sp)
 
 }
 
-static void mlxsw_sp_mids_fini(struct mlxsw_sp *mlxsw_sp)
-{
-	struct mlxsw_sp_mid *mid, *tmp;
-
-	list_for_each_entry_safe(mid, tmp, &mlxsw_sp->bridge->mids_list, list) {
-		list_del(&mid->list);
-		clear_bit(mid->mid, mlxsw_sp->bridge->mids_bitmap);
-		kfree(mid);
-	}
-}
-
 int mlxsw_sp_switchdev_init(struct mlxsw_sp *mlxsw_sp)
 {
 	struct mlxsw_sp_bridge *bridge;
@@ -2017,7 +2018,6 @@ int mlxsw_sp_switchdev_init(struct mlxsw_sp *mlxsw_sp)
 	bridge->mlxsw_sp = mlxsw_sp;
 
 	INIT_LIST_HEAD(&mlxsw_sp->bridge->bridges_list);
-	INIT_LIST_HEAD(&mlxsw_sp->bridge->mids_list);
 
 	bridge->bridge_8021q_ops = &mlxsw_sp_bridge_8021q_ops;
 	bridge->bridge_8021d_ops = &mlxsw_sp_bridge_8021d_ops;
@@ -2028,7 +2028,6 @@ int mlxsw_sp_switchdev_init(struct mlxsw_sp *mlxsw_sp)
 void mlxsw_sp_switchdev_fini(struct mlxsw_sp *mlxsw_sp)
 {
 	mlxsw_sp_fdb_fini(mlxsw_sp);
-	mlxsw_sp_mids_fini(mlxsw_sp);
 	WARN_ON(!list_empty(&mlxsw_sp->bridge->bridges_list));
 	kfree(mlxsw_sp->bridge);
 }
-- 
2.9.5
