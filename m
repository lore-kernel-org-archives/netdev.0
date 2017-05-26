From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 04/18] mlxsw: spectrum: Introduce Port-VLAN structure
Date: Fri, 26 May 2017 08:37:26 +0200
Message-ID: <20170526063740.8909-5-jiri@resnulli.us>
References: <20170526063740.8909-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        stephen@networkplumber.org, nikolay@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35279 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S970580AbdEZGht (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 02:37:49 -0400
Received: by mail-wm0-f65.google.com with SMTP id g15so1683801wmc.2
        for <netdev@vger.kernel.org>; Thu, 25 May 2017 23:37:48 -0700 (PDT)
In-Reply-To: <20170526063740.8909-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

This is the first step in the transition from the vPort model to a
unified Port-VLAN structure. The new structure is defined and created /
destroyed upon invocation of the 8021q ndos, but it's not actually used
throughout the code.

Subsequent patches will initialize it correctly and also create /
destroy it upon switchdev's VLAN object.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 48 ++++++++++++++++++++++++--
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h | 23 ++++++++++++
 2 files changed, 68 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 5d67336..6f5f011 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1480,10 +1480,34 @@ static void mlxsw_sp_port_vport_destroy(struct mlxsw_sp_port *mlxsw_sp_vport)
 	kfree(mlxsw_sp_vport);
 }
 
+static struct mlxsw_sp_port_vlan *
+mlxsw_sp_port_vlan_create(struct mlxsw_sp_port *mlxsw_sp_port, u16 vid)
+{
+	struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan;
+
+	mlxsw_sp_port_vlan = kzalloc(sizeof(*mlxsw_sp_port_vlan), GFP_KERNEL);
+	if (!mlxsw_sp_port_vlan)
+		return ERR_PTR(-ENOMEM);
+
+	mlxsw_sp_port_vlan->mlxsw_sp_port = mlxsw_sp_port;
+	mlxsw_sp_port_vlan->vid = vid;
+	list_add(&mlxsw_sp_port_vlan->list, &mlxsw_sp_port->vlans_list);
+
+	return mlxsw_sp_port_vlan;
+}
+
+static void
+mlxsw_sp_port_vlan_destroy(struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan)
+{
+	list_del(&mlxsw_sp_port_vlan->list);
+	kfree(mlxsw_sp_port_vlan);
+}
+
 static int mlxsw_sp_port_add_vid(struct net_device *dev,
 				 __be16 __always_unused proto, u16 vid)
 {
 	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
+	struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan;
 	struct mlxsw_sp_port *mlxsw_sp_vport;
 	bool untagged = vid == 1;
 	int err;
@@ -1494,12 +1518,19 @@ static int mlxsw_sp_port_add_vid(struct net_device *dev,
 	if (!vid)
 		return 0;
 
-	if (mlxsw_sp_port_vport_find(mlxsw_sp_port, vid))
+	mlxsw_sp_port_vlan = mlxsw_sp_port_vlan_find_by_vid(mlxsw_sp_port, vid);
+	if (mlxsw_sp_port_vlan)
 		return 0;
 
+	mlxsw_sp_port_vlan = mlxsw_sp_port_vlan_create(mlxsw_sp_port, vid);
+	if (IS_ERR(mlxsw_sp_port_vlan))
+		return PTR_ERR(mlxsw_sp_port_vlan);
+
 	mlxsw_sp_vport = mlxsw_sp_port_vport_create(mlxsw_sp_port, vid);
-	if (!mlxsw_sp_vport)
-		return -ENOMEM;
+	if (!mlxsw_sp_vport) {
+		err = -ENOMEM;
+		goto err_port_vport_create;
+	}
 
 	err = mlxsw_sp_port_vlan_set(mlxsw_sp_vport, vid, vid, true, untagged);
 	if (err)
@@ -1509,6 +1540,8 @@ static int mlxsw_sp_port_add_vid(struct net_device *dev,
 
 err_port_add_vid:
 	mlxsw_sp_port_vport_destroy(mlxsw_sp_vport);
+err_port_vport_create:
+	mlxsw_sp_port_vlan_destroy(mlxsw_sp_port_vlan);
 	return err;
 }
 
@@ -1516,6 +1549,7 @@ static int mlxsw_sp_port_kill_vid(struct net_device *dev,
 				  __be16 __always_unused proto, u16 vid)
 {
 	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
+	struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan;
 	struct mlxsw_sp_port *mlxsw_sp_vport;
 	struct mlxsw_sp_fid *f;
 
@@ -1525,6 +1559,10 @@ static int mlxsw_sp_port_kill_vid(struct net_device *dev,
 	if (!vid)
 		return 0;
 
+	mlxsw_sp_port_vlan = mlxsw_sp_port_vlan_find_by_vid(mlxsw_sp_port, vid);
+	if (WARN_ON(!mlxsw_sp_port_vlan))
+		return 0;
+
 	mlxsw_sp_vport = mlxsw_sp_port_vport_find(mlxsw_sp_port, vid);
 	if (WARN_ON(!mlxsw_sp_vport))
 		return 0;
@@ -1540,6 +1578,8 @@ static int mlxsw_sp_port_kill_vid(struct net_device *dev,
 
 	mlxsw_sp_port_vport_destroy(mlxsw_sp_vport);
 
+	mlxsw_sp_port_vlan_destroy(mlxsw_sp_port_vlan);
+
 	return 0;
 }
 
@@ -2720,6 +2760,7 @@ static int __mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 		err = -ENOMEM;
 		goto err_port_untagged_vlans_alloc;
 	}
+	INIT_LIST_HEAD(&mlxsw_sp_port->vlans_list);
 	INIT_LIST_HEAD(&mlxsw_sp_port->vports_list);
 	INIT_LIST_HEAD(&mlxsw_sp_port->mall_tc_list);
 
@@ -2926,6 +2967,7 @@ static void __mlxsw_sp_port_remove(struct mlxsw_sp *mlxsw_sp, u8 local_port)
 	kfree(mlxsw_sp_port->untagged_vlans);
 	kfree(mlxsw_sp_port->active_vlans);
 	WARN_ON_ONCE(!list_empty(&mlxsw_sp_port->vports_list));
+	WARN_ON_ONCE(!list_empty(&mlxsw_sp_port->vlans_list));
 	free_netdev(mlxsw_sp_port->dev);
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 277a432..c4ac648 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -203,6 +203,13 @@ struct mlxsw_sp_port_sample {
 	bool truncate;
 };
 
+struct mlxsw_sp_port_vlan {
+	struct list_head list;
+	struct mlxsw_sp_port *mlxsw_sp_port;
+	struct mlxsw_sp_fid *fid;
+	u16 vid;
+};
+
 struct mlxsw_sp_port {
 	struct net_device *dev;
 	struct mlxsw_sp_port_pcpu_stats __percpu *pcpu_stats;
@@ -254,6 +261,7 @@ struct mlxsw_sp_port {
 	} hw_stats;
 	struct mlxsw_sp_port_sample *sample;
 	unsigned int nr_port_vid_map;  /* {Port, VID} => FID mappings */
+	struct list_head vlans_list;
 };
 
 bool mlxsw_sp_port_dev_check(const struct net_device *dev);
@@ -279,6 +287,21 @@ mlxsw_sp_port_lagged_get(struct mlxsw_sp *mlxsw_sp, u16 lag_id, u8 port_index)
 	return mlxsw_sp_port && mlxsw_sp_port->lagged ? mlxsw_sp_port : NULL;
 }
 
+static inline struct mlxsw_sp_port_vlan *
+mlxsw_sp_port_vlan_find_by_vid(const struct mlxsw_sp_port *mlxsw_sp_port,
+			       u16 vid)
+{
+	struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan;
+
+	list_for_each_entry(mlxsw_sp_port_vlan, &mlxsw_sp_port->vlans_list,
+			    list) {
+		if (mlxsw_sp_port_vlan->vid == vid)
+			return mlxsw_sp_port_vlan;
+	}
+
+	return NULL;
+}
+
 static inline u16
 mlxsw_sp_vport_vid_get(const struct mlxsw_sp_port *mlxsw_sp_vport)
 {
-- 
2.9.3
