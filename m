From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 7/8] net/mlx4_core: Add XRC domains and counters to resource tracker
Date: Mon, 14 May 2012 23:04:12 +0300
Message-ID: <1337025853-26685-8-git-send-email-ogerlitz@mellanox.com>
References: <1337025853-26685-1-git-send-email-ogerlitz@mellanox.com>
Cc: roland@kernel.org, netdev@vger.kernel.org,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:38308 "HELO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757756Ab2ENUE0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2012 16:04:26 -0400
In-Reply-To: <1337025853-26685-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

Add missing resource tracking for XRC domains and complete the tracking for HCA 
network flow counters.

Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c          |   35 ++++-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |    4 +
 drivers/net/ethernet/mellanox/mlx4/pd.c            |   39 ++++-
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |  202 +++++++++++++++++++-
 4 files changed, 275 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 2e94f76..984ace4 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -1306,7 +1306,7 @@ static void mlx4_cleanup_counters_table(struct mlx4_dev *dev)
 	mlx4_bitmap_cleanup(&mlx4_priv(dev)->counters_bitmap);
 }
 
-int mlx4_counter_alloc(struct mlx4_dev *dev, u32 *idx)
+int __mlx4_counter_alloc(struct mlx4_dev *dev, u32 *idx)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
 
@@ -1319,13 +1319,44 @@ int mlx4_counter_alloc(struct mlx4_dev *dev, u32 *idx)
 
 	return 0;
 }
+
+int mlx4_counter_alloc(struct mlx4_dev *dev, u32 *idx)
+{
+	u64 out_param;
+	int err;
+
+	if (mlx4_is_mfunc(dev)) {
+		err = mlx4_cmd_imm(dev, 0, &out_param, RES_COUNTER,
+				   RES_OP_RESERVE, MLX4_CMD_ALLOC_RES,
+				   MLX4_CMD_TIME_CLASS_A, MLX4_CMD_WRAPPED);
+		if (!err)
+			*idx = get_param_l(&out_param);
+
+		return err;
+	}
+	return __mlx4_counter_alloc(dev, idx);
+}
 EXPORT_SYMBOL_GPL(mlx4_counter_alloc);
 
-void mlx4_counter_free(struct mlx4_dev *dev, u32 idx)
+void __mlx4_counter_free(struct mlx4_dev *dev, u32 idx)
 {
 	mlx4_bitmap_free(&mlx4_priv(dev)->counters_bitmap, idx);
 	return;
 }
+
+void mlx4_counter_free(struct mlx4_dev *dev, u32 idx)
+{
+	u64 in_param;
+
+	if (mlx4_is_mfunc(dev)) {
+		set_param_l(&in_param, idx);
+		mlx4_cmd(dev, in_param, RES_COUNTER, RES_OP_RESERVE,
+			 MLX4_CMD_FREE_RES, MLX4_CMD_TIME_CLASS_A,
+			 MLX4_CMD_WRAPPED);
+		return;
+	}
+	__mlx4_counter_free(dev, idx);
+}
 EXPORT_SYMBOL_GPL(mlx4_counter_free);
 
 static int mlx4_setup_hca(struct mlx4_dev *dev)
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index 8767fbf..86b6e5a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -876,6 +876,10 @@ void __mlx4_unregister_mac(struct mlx4_dev *dev, u8 port, u64 mac);
 int __mlx4_replace_mac(struct mlx4_dev *dev, u8 port, int qpn, u64 new_mac);
 int __mlx4_write_mtt(struct mlx4_dev *dev, struct mlx4_mtt *mtt,
 		     int start_index, int npages, u64 *page_list);
+int __mlx4_counter_alloc(struct mlx4_dev *dev, u32 *idx);
+void __mlx4_counter_free(struct mlx4_dev *dev, u32 idx);
+int __mlx4_xrcd_alloc(struct mlx4_dev *dev, u32 *xrcdn);
+void __mlx4_xrcd_free(struct mlx4_dev *dev, u32 xrcdn);
 
 void mlx4_start_catas_poll(struct mlx4_dev *dev);
 void mlx4_stop_catas_poll(struct mlx4_dev *dev);
diff --git a/drivers/net/ethernet/mellanox/mlx4/pd.c b/drivers/net/ethernet/mellanox/mlx4/pd.c
index db4746d..1ac8863 100644
--- a/drivers/net/ethernet/mellanox/mlx4/pd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/pd.c
@@ -63,7 +63,7 @@ void mlx4_pd_free(struct mlx4_dev *dev, u32 pdn)
 }
 EXPORT_SYMBOL_GPL(mlx4_pd_free);
 
-int mlx4_xrcd_alloc(struct mlx4_dev *dev, u32 *xrcdn)
+int __mlx4_xrcd_alloc(struct mlx4_dev *dev, u32 *xrcdn)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
 
@@ -73,12 +73,47 @@ int mlx4_xrcd_alloc(struct mlx4_dev *dev, u32 *xrcdn)
 
 	return 0;
 }
+
+int mlx4_xrcd_alloc(struct mlx4_dev *dev, u32 *xrcdn)
+{
+	u64 out_param;
+	int err;
+
+	if (mlx4_is_mfunc(dev)) {
+		err = mlx4_cmd_imm(dev, 0, &out_param,
+				   RES_XRCD, RES_OP_RESERVE,
+				   MLX4_CMD_ALLOC_RES,
+				   MLX4_CMD_TIME_CLASS_A, MLX4_CMD_WRAPPED);
+		if (err)
+			return err;
+
+		*xrcdn = get_param_l(&out_param);
+		return 0;
+	}
+	return __mlx4_xrcd_alloc(dev, xrcdn);
+}
 EXPORT_SYMBOL_GPL(mlx4_xrcd_alloc);
 
-void mlx4_xrcd_free(struct mlx4_dev *dev, u32 xrcdn)
+void __mlx4_xrcd_free(struct mlx4_dev *dev, u32 xrcdn)
 {
 	mlx4_bitmap_free(&mlx4_priv(dev)->xrcd_bitmap, xrcdn);
 }
+
+void mlx4_xrcd_free(struct mlx4_dev *dev, u32 xrcdn)
+{
+	u64 in_param;
+	int err;
+
+	if (mlx4_is_mfunc(dev)) {
+		set_param_l(&in_param, xrcdn);
+		err = mlx4_cmd(dev, in_param, RES_XRCD,
+			       RES_OP_RESERVE, MLX4_CMD_FREE_RES,
+			       MLX4_CMD_TIME_CLASS_A, MLX4_CMD_WRAPPED);
+		if (err)
+			mlx4_warn(dev, "Failed to release xrcdn %d\n", xrcdn);
+	} else
+		__mlx4_xrcd_free(dev, xrcdn);
+}
 EXPORT_SYMBOL_GPL(mlx4_xrcd_free);
 
 int mlx4_init_pd_table(struct mlx4_dev *dev)
diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index e17d759..626d1e3 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -179,6 +179,16 @@ struct res_counter {
 	int			port;
 };
 
+enum res_xrcdn_states {
+	RES_XRCD_BUSY = RES_ANY_BUSY,
+	RES_XRCD_ALLOCATED,
+};
+
+struct res_xrcdn {
+	struct res_common	com;
+	int			port;
+};
+
 /* For Debug uses */
 static const char *ResourceType(enum mlx4_resource rt)
 {
@@ -191,6 +201,7 @@ static const char *ResourceType(enum mlx4_resource rt)
 	case RES_MAC: return  "RES_MAC";
 	case RES_EQ: return "RES_EQ";
 	case RES_COUNTER: return "RES_COUNTER";
+	case RES_XRCD: return "RES_XRCD";
 	default: return "Unknown resource type !!!";
 	};
 }
@@ -448,6 +459,20 @@ static struct res_common *alloc_counter_tr(int id)
 	return &ret->com;
 }
 
+static struct res_common *alloc_xrcdn_tr(int id)
+{
+	struct res_xrcdn *ret;
+
+	ret = kzalloc(sizeof *ret, GFP_KERNEL);
+	if (!ret)
+		return NULL;
+
+	ret->com.res_id = id;
+	ret->com.state = RES_XRCD_ALLOCATED;
+
+	return &ret->com;
+}
+
 static struct res_common *alloc_tr(int id, enum mlx4_resource type, int slave,
 				   int extra)
 {
@@ -478,7 +503,9 @@ static struct res_common *alloc_tr(int id, enum mlx4_resource type, int slave,
 	case RES_COUNTER:
 		ret = alloc_counter_tr(id);
 		break;
-
+	case RES_XRCD:
+		ret = alloc_xrcdn_tr(id);
+		break;
 	default:
 		return NULL;
 	}
@@ -601,6 +628,16 @@ static int remove_counter_ok(struct res_counter *res)
 	return 0;
 }
 
+static int remove_xrcdn_ok(struct res_xrcdn *res)
+{
+	if (res->com.state == RES_XRCD_BUSY)
+		return -EBUSY;
+	else if (res->com.state != RES_XRCD_ALLOCATED)
+		return -EPERM;
+
+	return 0;
+}
+
 static int remove_cq_ok(struct res_cq *res)
 {
 	if (res->com.state == RES_CQ_BUSY)
@@ -640,6 +677,8 @@ static int remove_ok(struct res_common *res, enum mlx4_resource type, int extra)
 		return remove_eq_ok((struct res_eq *)res);
 	case RES_COUNTER:
 		return remove_counter_ok((struct res_counter *)res);
+	case RES_XRCD:
+		return remove_xrcdn_ok((struct res_xrcdn *)res);
 	default:
 		return -EINVAL;
 	}
@@ -1246,6 +1285,50 @@ static int vlan_alloc_res(struct mlx4_dev *dev, int slave, int op, int cmd,
 	return 0;
 }
 
+static int counter_alloc_res(struct mlx4_dev *dev, int slave, int op, int cmd,
+			     u64 in_param, u64 *out_param)
+{
+	u32 index;
+	int err;
+
+	if (op != RES_OP_RESERVE)
+		return -EINVAL;
+
+	err = __mlx4_counter_alloc(dev, &index);
+	if (err)
+		return err;
+
+	err = add_res_range(dev, slave, index, 1, RES_COUNTER, 0);
+	if (err)
+		__mlx4_counter_free(dev, index);
+	else
+		set_param_l(out_param, index);
+
+	return err;
+}
+
+static int xrcdn_alloc_res(struct mlx4_dev *dev, int slave, int op, int cmd,
+			   u64 in_param, u64 *out_param)
+{
+	u32 xrcdn;
+	int err;
+
+	if (op != RES_OP_RESERVE)
+		return -EINVAL;
+
+	err = __mlx4_xrcd_alloc(dev, &xrcdn);
+	if (err)
+		return err;
+
+	err = add_res_range(dev, slave, xrcdn, 1, RES_XRCD, 0);
+	if (err)
+		__mlx4_xrcd_free(dev, xrcdn);
+	else
+		set_param_l(out_param, xrcdn);
+
+	return err;
+}
+
 int mlx4_ALLOC_RES_wrapper(struct mlx4_dev *dev, int slave,
 			   struct mlx4_vhcr *vhcr,
 			   struct mlx4_cmd_mailbox *inbox,
@@ -1291,6 +1374,16 @@ int mlx4_ALLOC_RES_wrapper(struct mlx4_dev *dev, int slave,
 				    vhcr->in_param, &vhcr->out_param);
 		break;
 
+	case RES_COUNTER:
+		err = counter_alloc_res(dev, slave, vhcr->op_modifier, alop,
+					vhcr->in_param, &vhcr->out_param);
+		break;
+
+	case RES_XRCD:
+		err = xrcdn_alloc_res(dev, slave, vhcr->op_modifier, alop,
+				      vhcr->in_param, &vhcr->out_param);
+		break;
+
 	default:
 		err = -EINVAL;
 		break;
@@ -1473,6 +1566,44 @@ static int vlan_free_res(struct mlx4_dev *dev, int slave, int op, int cmd,
 	return 0;
 }
 
+static int counter_free_res(struct mlx4_dev *dev, int slave, int op, int cmd,
+			    u64 in_param, u64 *out_param)
+{
+	int index;
+	int err;
+
+	if (op != RES_OP_RESERVE)
+		return -EINVAL;
+
+	index = get_param_l(&in_param);
+	err = rem_res_range(dev, slave, index, 1, RES_COUNTER, 0);
+	if (err)
+		return err;
+
+	__mlx4_counter_free(dev, index);
+
+	return err;
+}
+
+static int xrcdn_free_res(struct mlx4_dev *dev, int slave, int op, int cmd,
+			  u64 in_param, u64 *out_param)
+{
+	int xrcdn;
+	int err;
+
+	if (op != RES_OP_RESERVE)
+		return -EINVAL;
+
+	xrcdn = get_param_l(&in_param);
+	err = rem_res_range(dev, slave, xrcdn, 1, RES_XRCD, 0);
+	if (err)
+		return err;
+
+	__mlx4_xrcd_free(dev, xrcdn);
+
+	return err;
+}
+
 int mlx4_FREE_RES_wrapper(struct mlx4_dev *dev, int slave,
 			  struct mlx4_vhcr *vhcr,
 			  struct mlx4_cmd_mailbox *inbox,
@@ -1518,6 +1649,15 @@ int mlx4_FREE_RES_wrapper(struct mlx4_dev *dev, int slave,
 				   vhcr->in_param, &vhcr->out_param);
 		break;
 
+	case RES_COUNTER:
+		err = counter_free_res(dev, slave, vhcr->op_modifier, alop,
+				       vhcr->in_param, &vhcr->out_param);
+		break;
+
+	case RES_XRCD:
+		err = xrcdn_free_res(dev, slave, vhcr->op_modifier, alop,
+				     vhcr->in_param, &vhcr->out_param);
+
 	default:
 		break;
 	}
@@ -3032,6 +3172,64 @@ static void rem_slave_eqs(struct mlx4_dev *dev, int slave)
 	spin_unlock_irq(mlx4_tlock(dev));
 }
 
+static void rem_slave_counters(struct mlx4_dev *dev, int slave)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	struct mlx4_resource_tracker *tracker = &priv->mfunc.master.res_tracker;
+	struct list_head *counter_list =
+		&tracker->slave_list[slave].res_list[RES_COUNTER];
+	struct res_counter *counter;
+	struct res_counter *tmp;
+	int err;
+	int index;
+
+	err = move_all_busy(dev, slave, RES_COUNTER);
+	if (err)
+		mlx4_warn(dev, "rem_slave_counters: Could not move all counters to "
+			  "busy for slave %d\n", slave);
+
+	spin_lock_irq(mlx4_tlock(dev));
+	list_for_each_entry_safe(counter, tmp, counter_list, com.list) {
+		if (counter->com.owner == slave) {
+			index = counter->com.res_id;
+			radix_tree_delete(&tracker->res_tree[RES_COUNTER], index);
+			list_del(&counter->com.list);
+			kfree(counter);
+			__mlx4_counter_free(dev, index);
+		}
+	}
+	spin_unlock_irq(mlx4_tlock(dev));
+}
+
+static void rem_slave_xrcdns(struct mlx4_dev *dev, int slave)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	struct mlx4_resource_tracker *tracker = &priv->mfunc.master.res_tracker;
+	struct list_head *xrcdn_list =
+		&tracker->slave_list[slave].res_list[RES_XRCD];
+	struct res_xrcdn *xrcd;
+	struct res_xrcdn *tmp;
+	int err;
+	int xrcdn;
+
+	err = move_all_busy(dev, slave, RES_XRCD);
+	if (err)
+		mlx4_warn(dev, "rem_slave_xrcdns: Could not move all xrcdns to "
+			  "busy for slave %d\n", slave);
+
+	spin_lock_irq(mlx4_tlock(dev));
+	list_for_each_entry_safe(xrcd, tmp, xrcdn_list, com.list) {
+		if (xrcd->com.owner == slave) {
+			xrcdn = xrcd->com.res_id;
+			radix_tree_delete(&tracker->res_tree[RES_XRCD], xrcdn);
+			list_del(&xrcd->com.list);
+			kfree(xrcd);
+			__mlx4_xrcd_free(dev, xrcdn);
+		}
+	}
+	spin_unlock_irq(mlx4_tlock(dev));
+}
+
 void mlx4_delete_all_resources_for_slave(struct mlx4_dev *dev, int slave)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
@@ -3045,5 +3243,7 @@ void mlx4_delete_all_resources_for_slave(struct mlx4_dev *dev, int slave)
 	rem_slave_mrs(dev, slave);
 	rem_slave_eqs(dev, slave);
 	rem_slave_mtts(dev, slave);
+	rem_slave_counters(dev, slave);
+	rem_slave_xrcdns(dev, slave);
 	mutex_unlock(&priv->mfunc.master.res_tracker.slave_list[slave].mutex);
 }
-- 
1.7.1
