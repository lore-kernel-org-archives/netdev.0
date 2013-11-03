From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V1 4/9] net/mlx4_core: Resource tracker for reg/unreg vlans
Date: Sun,  3 Nov 2013 10:03:20 +0200
Message-ID: <1383465805-28640-5-git-send-email-ogerlitz@mellanox.com>
References: <1383465805-28640-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com, roland@kernel.org,
	jackm@dev.mellanox.co.il, Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:37911 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752701Ab3KCIDl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Nov 2013 03:03:41 -0500
In-Reply-To: <1383465805-28640-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

Add resource tracker support for reg/unreg vlans calls done by VFs.

Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |  127 +++++++++++++++++++-
 1 files changed, 121 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index 993a2ef..e18bfff 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -55,6 +55,14 @@ struct mac_res {
 	u8 port;
 };
 
+struct vlan_res {
+	struct list_head list;
+	u16 vlan;
+	int ref_count;
+	int vlan_index;
+	u8 port;
+};
+
 struct res_common {
 	struct list_head	list;
 	struct rb_node		node;
@@ -266,6 +274,7 @@ static const char *ResourceType(enum mlx4_resource rt)
 	case RES_MPT: return "RES_MPT";
 	case RES_MTT: return "RES_MTT";
 	case RES_MAC: return  "RES_MAC";
+	case RES_VLAN: return  "RES_VLAN";
 	case RES_EQ: return "RES_EQ";
 	case RES_COUNTER: return "RES_COUNTER";
 	case RES_FS_RULE: return "RES_FS_RULE";
@@ -274,6 +283,7 @@ static const char *ResourceType(enum mlx4_resource rt)
 	};
 }
 
+static void rem_slave_vlans(struct mlx4_dev *dev, int slave);
 int mlx4_init_resource_tracker(struct mlx4_dev *dev)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
@@ -309,11 +319,18 @@ void mlx4_free_resource_tracker(struct mlx4_dev *dev,
 	int i;
 
 	if (priv->mfunc.master.res_tracker.slave_list) {
-		if (type != RES_TR_FREE_STRUCTS_ONLY)
-			for (i = 0 ; i < dev->num_slaves; i++)
+		if (type != RES_TR_FREE_STRUCTS_ONLY) {
+			for (i = 0; i < dev->num_slaves; i++) {
 				if (type == RES_TR_FREE_ALL ||
 				    dev->caps.function != i)
 					mlx4_delete_all_resources_for_slave(dev, i);
+			}
+			/* free master's vlans */
+			i = dev->caps.function;
+			mutex_lock(&priv->mfunc.master.res_tracker.slave_list[i].mutex);
+			rem_slave_vlans(dev, i);
+			mutex_unlock(&priv->mfunc.master.res_tracker.slave_list[i].mutex);
+		}
 
 		if (type != RES_TR_FREE_SLAVES_ONLY) {
 			kfree(priv->mfunc.master.res_tracker.slave_list);
@@ -1469,12 +1486,96 @@ static int mac_alloc_res(struct mlx4_dev *dev, int slave, int op, int cmd,
 	return err;
 }
 
-static int vlan_alloc_res(struct mlx4_dev *dev, int slave, int op, int cmd,
-			 u64 in_param, u64 *out_param, int port)
+static int vlan_add_to_slave(struct mlx4_dev *dev, int slave, u16 vlan,
+			     int port, int vlan_index)
 {
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	struct mlx4_resource_tracker *tracker = &priv->mfunc.master.res_tracker;
+	struct list_head *vlan_list =
+		&tracker->slave_list[slave].res_list[RES_VLAN];
+	struct vlan_res *res, *tmp;
+
+	list_for_each_entry_safe(res, tmp, vlan_list, list) {
+		if (res->vlan == vlan && res->port == (u8) port) {
+			/* vlan found. update ref count */
+			++res->ref_count;
+			return 0;
+		}
+	}
+
+	res = kzalloc(sizeof(*res), GFP_KERNEL);
+	if (!res)
+		return -ENOMEM;
+	res->vlan = vlan;
+	res->port = (u8) port;
+	res->vlan_index = vlan_index;
+	res->ref_count = 1;
+	list_add_tail(&res->list,
+		      &tracker->slave_list[slave].res_list[RES_VLAN]);
 	return 0;
 }
 
+
+static void vlan_del_from_slave(struct mlx4_dev *dev, int slave, u16 vlan,
+				int port)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	struct mlx4_resource_tracker *tracker = &priv->mfunc.master.res_tracker;
+	struct list_head *vlan_list =
+		&tracker->slave_list[slave].res_list[RES_VLAN];
+	struct vlan_res *res, *tmp;
+
+	list_for_each_entry_safe(res, tmp, vlan_list, list) {
+		if (res->vlan == vlan && res->port == (u8) port) {
+			if (!--res->ref_count) {
+				list_del(&res->list);
+				kfree(res);
+			}
+			break;
+		}
+	}
+}
+
+static void rem_slave_vlans(struct mlx4_dev *dev, int slave)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	struct mlx4_resource_tracker *tracker = &priv->mfunc.master.res_tracker;
+	struct list_head *vlan_list =
+		&tracker->slave_list[slave].res_list[RES_VLAN];
+	struct vlan_res *res, *tmp;
+	int i;
+
+	list_for_each_entry_safe(res, tmp, vlan_list, list) {
+		list_del(&res->list);
+		/* dereference the vlan the num times the slave referenced it */
+		for (i = 0; i < res->ref_count; i++)
+			__mlx4_unregister_vlan(dev, res->port, res->vlan);
+		kfree(res);
+	}
+}
+
+static int vlan_alloc_res(struct mlx4_dev *dev, int slave, int op, int cmd,
+			  u64 in_param, u64 *out_param, int port)
+{
+	int err;
+	u16 vlan;
+	int vlan_index;
+
+	if (!port || op != RES_OP_RESERVE_AND_MAP)
+		return -EINVAL;
+
+	vlan = (u16) in_param;
+
+	err = __mlx4_register_vlan(dev, port, vlan, &vlan_index);
+	if (!err) {
+		set_param_l(out_param, (u32) vlan_index);
+		err = vlan_add_to_slave(dev, slave, vlan, port, vlan_index);
+		if (err)
+			__mlx4_unregister_vlan(dev, port, vlan);
+	}
+	return err;
+}
+
 static int counter_alloc_res(struct mlx4_dev *dev, int slave, int op, int cmd,
 			     u64 in_param, u64 *out_param)
 {
@@ -1755,7 +1856,21 @@ static int mac_free_res(struct mlx4_dev *dev, int slave, int op, int cmd,
 static int vlan_free_res(struct mlx4_dev *dev, int slave, int op, int cmd,
 			    u64 in_param, u64 *out_param, int port)
 {
-	return 0;
+	int err = 0;
+
+	switch (op) {
+	case RES_OP_RESERVE_AND_MAP:
+		if (!port)
+			return -EINVAL;
+		vlan_del_from_slave(dev, slave, in_param, port);
+		__mlx4_unregister_vlan(dev, port, in_param);
+		break;
+	default:
+		err = -EINVAL;
+		break;
+	}
+
+	return err;
 }
 
 static int counter_free_res(struct mlx4_dev *dev, int slave, int op, int cmd,
@@ -3968,7 +4083,7 @@ void mlx4_delete_all_resources_for_slave(struct mlx4_dev *dev, int slave)
 	struct mlx4_priv *priv = mlx4_priv(dev);
 
 	mutex_lock(&priv->mfunc.master.res_tracker.slave_list[slave].mutex);
-	/*VLAN*/
+	rem_slave_vlans(dev, slave);
 	rem_slave_macs(dev, slave);
 	rem_slave_fs_rule(dev, slave);
 	rem_slave_qps(dev, slave);
-- 
1.7.1
