From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 12/12] IB/mlx5: Add flow steering support
Date: Tue,  5 Jan 2016 22:04:13 +0200
Message-ID: <1452024253-21193-13-git-send-email-saeedm@mellanox.com>
References: <1452024253-21193-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Doug Ledford <dledford@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>,
	Matan Barak <matanb@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Moni Shoua <monis@mellanox.com>, saeedm@dev.mellanox.co.il,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:41892 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754099AbcAEUFJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jan 2016 15:05:09 -0500
In-Reply-To: <1452024253-21193-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maor Gottlieb <maorg@mellanox.com>

Adding flow steering support by creating a flow-table per
priority (if rules exist in the priority).
mlx5_ib uses autogrouping and thus only creates the
required destinations.

Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Moni Shoua <monis@mellanox.com>
Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/infiniband/hw/mlx5/main.c    |  285 ++++++++++++++++++++++++++++++++++
 drivers/infiniband/hw/mlx5/mlx5_ib.h |   45 +++++-
 2 files changed, 329 insertions(+), 1 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index 6886d81..c1acd52 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -45,6 +45,7 @@
 #include <rdma/ib_umem.h>
 #include <linux/in.h>
 #include <linux/etherdevice.h>
+#include <linux/mlx5/fs.h>
 #include "user.h"
 #include "mlx5_ib.h"
 
@@ -1012,6 +1013,281 @@ static bool is_valid_attr(struct ib_flow_attr *flow_attr)
 	return !has_ipv4_spec || eth_type_ipv4;
 }
 
+static void put_flow_table(struct mlx5_ib_dev *dev,
+			   struct mlx5_ib_flow_prio *prio, bool ft_added)
+{
+	prio->refcount -= !!ft_added;
+	if (!prio->refcount) {
+		mlx5_destroy_flow_table(prio->flow_table);
+		prio->flow_table = NULL;
+	}
+}
+
+static int mlx5_ib_destroy_flow(struct ib_flow *flow_id)
+{
+	struct mlx5_ib_dev *dev = to_mdev(flow_id->qp->device);
+	struct mlx5_ib_flow_handler *handler = container_of(flow_id,
+							  struct mlx5_ib_flow_handler,
+							  ibflow);
+	struct mlx5_ib_flow_handler *iter, *tmp;
+
+	mutex_lock(&dev->flow_db.lock);
+
+	list_for_each_entry_safe(iter, tmp, &handler->list, list) {
+		mlx5_del_flow_rule(iter->rule);
+		list_del(&iter->list);
+		kfree(iter);
+	}
+
+	mlx5_del_flow_rule(handler->rule);
+	put_flow_table(dev, &dev->flow_db.prios[handler->prio], true);
+	mutex_unlock(&dev->flow_db.lock);
+
+	kfree(handler);
+
+	return 0;
+}
+
+#define MLX5_FS_MAX_TYPES	 10
+#define MLX5_FS_MAX_ENTRIES	 32000UL
+static struct mlx5_ib_flow_prio *get_flow_table(struct mlx5_ib_dev *dev,
+						struct ib_flow_attr *flow_attr)
+{
+	struct mlx5_flow_namespace *ns = NULL;
+	struct mlx5_ib_flow_prio *prio;
+	struct mlx5_flow_table *ft;
+	int num_entries;
+	int num_groups;
+	int priority;
+	int err = 0;
+
+	if (flow_attr->type == IB_FLOW_ATTR_NORMAL) {
+		if (flow_is_multicast_only(flow_attr))
+			priority = MLX5_IB_FLOW_MCAST_PRIO;
+		else
+			priority = flow_attr->priority;
+		ns = mlx5_get_flow_namespace(dev->mdev,
+					     MLX5_FLOW_NAMESPACE_BYPASS);
+		num_entries = MLX5_FS_MAX_ENTRIES;
+		num_groups = MLX5_FS_MAX_TYPES;
+		prio = &dev->flow_db.prios[priority];
+	} else if (flow_attr->type == IB_FLOW_ATTR_ALL_DEFAULT ||
+		   flow_attr->type == IB_FLOW_ATTR_MC_DEFAULT) {
+		ns = mlx5_get_flow_namespace(dev->mdev,
+					     MLX5_FLOW_NAMESPACE_LEFTOVERS);
+		build_leftovers_ft_param(&priority,
+					 &num_entries,
+					 &num_groups);
+		prio = &dev->flow_db.prios[MLX5_IB_FLOW_LEFTOVERS_PRIO];
+	}
+
+	if (!ns)
+		return ERR_PTR(-ENOTSUPP);
+
+	ft = prio->flow_table;
+	if (!ft) {
+		ft = mlx5_create_auto_grouped_flow_table(ns, priority,
+							 num_entries,
+							 num_groups);
+
+		if (!IS_ERR(ft)) {
+			prio->refcount = 0;
+			prio->flow_table = ft;
+		} else {
+			err = PTR_ERR(ft);
+		}
+	}
+
+	return err ? ERR_PTR(err) : prio;
+}
+
+static struct mlx5_ib_flow_handler *create_flow_rule(struct mlx5_ib_dev *dev,
+						     struct mlx5_ib_flow_prio *ft_prio,
+						     struct ib_flow_attr *flow_attr,
+						     struct mlx5_flow_destination *dst)
+{
+	struct mlx5_flow_table	*ft = ft_prio->flow_table;
+	struct mlx5_ib_flow_handler *handler;
+	void *ib_flow = flow_attr + 1;
+	u8 match_criteria_enable = 0;
+	unsigned int spec_index;
+	u32 *match_c;
+	u32 *match_v;
+	int err = 0;
+
+	if (!is_valid_attr(flow_attr))
+		return ERR_PTR(-EINVAL);
+
+	match_c = kzalloc(MLX5_ST_SZ_BYTES(fte_match_param), GFP_KERNEL);
+	match_v = kzalloc(MLX5_ST_SZ_BYTES(fte_match_param), GFP_KERNEL);
+	handler = kzalloc(sizeof(*handler), GFP_KERNEL);
+	if (!handler || !match_c || !match_v) {
+		err = -ENOMEM;
+		goto free;
+	}
+
+	INIT_LIST_HEAD(&handler->list);
+
+	for (spec_index = 0; spec_index < flow_attr->num_of_specs; spec_index++) {
+		err = parse_flow_attr(match_c, match_v, ib_flow);
+		if (err < 0)
+			goto free;
+
+		ib_flow += ((union ib_flow_spec *)ib_flow)->size;
+	}
+
+	/* Outer header support only */
+	match_criteria_enable = (!outer_header_zero(match_c)) << 0;
+	handler->rule = mlx5_add_flow_rule(ft, match_criteria_enable,
+					   match_c, match_v,
+					   MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
+					   MLX5_FS_DEFAULT_FLOW_TAG,
+					   dst);
+
+	if (IS_ERR(handler->rule)) {
+		err = PTR_ERR(handler->rule);
+		goto free;
+	}
+
+	handler->prio = ft_prio - dev->flow_db.prios;
+
+	ft_prio->flow_table = ft;
+free:
+	if (err)
+		kfree(handler);
+	kfree(match_c);
+	kfree(match_v);
+	return err ? ERR_PTR(err) : handler;
+}
+
+enum {
+	LEFTOVERS_MC,
+	LEFTOVERS_UC,
+};
+
+static struct mlx5_ib_flow_handler *create_leftovers_rule(struct mlx5_ib_dev *dev,
+							  struct mlx5_ib_flow_prio *ft_prio,
+							  struct ib_flow_attr *flow_attr,
+							  struct mlx5_flow_destination *dst)
+{
+	struct mlx5_ib_flow_handler *handler_ucast = NULL;
+	struct mlx5_ib_flow_handler *handler = NULL;
+
+	static struct {
+		struct ib_flow_attr	flow_attr;
+		struct ib_flow_spec_eth eth_flow;
+	} leftovers_specs[] = {
+		[LEFTOVERS_MC] = {
+			.flow_attr = {
+				.num_of_specs = 1,
+				.size = sizeof(leftovers_specs[0])
+			},
+			.eth_flow = {
+				.type = IB_FLOW_SPEC_ETH,
+				.size = sizeof(struct ib_flow_spec_eth),
+				.mask = {.dst_mac = {0x1} },
+				.val =  {.dst_mac = {0x1} }
+			}
+		},
+		[LEFTOVERS_UC] = {
+			.flow_attr = {
+				.num_of_specs = 1,
+				.size = sizeof(leftovers_specs[0])
+			},
+			.eth_flow = {
+				.type = IB_FLOW_SPEC_ETH,
+				.size = sizeof(struct ib_flow_spec_eth),
+				.mask = {.dst_mac = {0x1} },
+				.val = {.dst_mac = {} }
+			}
+		}
+	};
+
+	handler = create_flow_rule(dev, ft_prio,
+				   &leftovers_specs[LEFTOVERS_MC].flow_attr,
+				   dst);
+	if (!IS_ERR(handler) &&
+	    flow_attr->type == IB_FLOW_ATTR_ALL_DEFAULT) {
+		handler_ucast = create_flow_rule(dev, ft_prio,
+						 &leftovers_specs[LEFTOVERS_UC].flow_attr,
+						 dst);
+		if (IS_ERR(handler_ucast)) {
+			kfree(handler);
+			handler = handler_ucast;
+		} else {
+			list_add(&handler_ucast->list, &handler->list);
+		}
+	}
+
+	return handler;
+}
+
+static struct ib_flow *mlx5_ib_create_flow(struct ib_qp *qp,
+					   struct ib_flow_attr *flow_attr,
+					   int domain)
+{
+	struct mlx5_ib_dev *dev = to_mdev(qp->device);
+	struct mlx5_ib_flow_handler *handler = NULL;
+	struct mlx5_flow_destination *dst = NULL;
+	struct mlx5_ib_flow_prio *ft_prio;
+	int err;
+
+	if (flow_attr->priority > MLX5_IB_FLOW_LAST_PRIO)
+		return ERR_PTR(-ENOSPC);
+
+	if (domain != IB_FLOW_DOMAIN_USER ||
+	    flow_attr->port > MLX5_CAP_GEN(dev->mdev, num_ports) ||
+	    flow_attr->flags)
+		return ERR_PTR(-EINVAL);
+
+	dst = kzalloc(sizeof(*dst), GFP_KERNEL);
+	if (!dst)
+		return ERR_PTR(-ENOMEM);
+
+	mutex_lock(&dev->flow_db.lock);
+
+	ft_prio = get_flow_table(dev, flow_attr);
+	if (IS_ERR(ft_prio)) {
+		err = PTR_ERR(ft_prio);
+		goto unlock;
+	}
+
+	dst->type = MLX5_FLOW_DESTINATION_TYPE_TIR;
+	dst->tir_num = to_mqp(qp)->raw_packet_qp.rq.tirn;
+
+	if (flow_attr->type == IB_FLOW_ATTR_NORMAL) {
+		handler = create_flow_rule(dev, ft_prio, flow_attr,
+					   dst);
+	} else if (flow_attr->type == IB_FLOW_ATTR_ALL_DEFAULT ||
+		   flow_attr->type == IB_FLOW_ATTR_MC_DEFAULT) {
+		handler = create_leftovers_rule(dev, ft_prio, flow_attr,
+						dst);
+	} else {
+		err = -EINVAL;
+		goto destroy_ft;
+	}
+
+	if (IS_ERR(handler)) {
+		err = PTR_ERR(handler);
+		handler = NULL;
+		goto destroy_ft;
+	}
+
+	ft_prio->refcount++;
+	mutex_unlock(&dev->flow_db.lock);
+	kfree(dst);
+
+	return &handler->ibflow;
+
+destroy_ft:
+	put_flow_table(dev, ft_prio, false);
+unlock:
+	mutex_unlock(&dev->flow_db.lock);
+	kfree(dst);
+	kfree(handler);
+	return ERR_PTR(err);
+}
+
 static int mlx5_ib_mcg_attach(struct ib_qp *ibqp, union ib_gid *gid, u16 lid)
 {
 	struct mlx5_ib_dev *dev = to_mdev(ibqp->device);
@@ -1616,10 +1892,19 @@ static void *mlx5_ib_add(struct mlx5_core_dev *mdev)
 			(1ull << IB_USER_VERBS_CMD_CLOSE_XRCD);
 	}
 
+	if (mlx5_ib_port_link_layer(&dev->ib_dev) ==
+	    IB_LINK_LAYER_ETHERNET) {
+		dev->ib_dev.create_flow	= mlx5_ib_create_flow;
+		dev->ib_dev.destroy_flow = mlx5_ib_destroy_flow;
+		dev->ib_dev.uverbs_ex_cmd_mask |=
+			(1ull << IB_USER_VERBS_EX_CMD_CREATE_FLOW) |
+			(1ull << IB_USER_VERBS_EX_CMD_DESTROY_FLOW);
+	}
 	err = init_node_data(dev);
 	if (err)
 		goto err_dealloc;
 
+	mutex_init(&dev->flow_db.lock);
 	mutex_init(&dev->cap_mask_mutex);
 
 	err = create_dev_resources(&dev->devr);
diff --git a/drivers/infiniband/hw/mlx5/mlx5_ib.h b/drivers/infiniband/hw/mlx5/mlx5_ib.h
index 6333472..1474ccc 100644
--- a/drivers/infiniband/hw/mlx5/mlx5_ib.h
+++ b/drivers/infiniband/hw/mlx5/mlx5_ib.h
@@ -105,6 +105,36 @@ struct mlx5_ib_pd {
 	u32			pdn;
 };
 
+#define MLX5_IB_FLOW_MCAST_PRIO		(MLX5_BY_PASS_NUM_PRIOS - 1)
+#define MLX5_IB_FLOW_LAST_PRIO		(MLX5_IB_FLOW_MCAST_PRIO - 1)
+#if (MLX5_IB_FLOW_LAST_PRIO <= 0)
+#error "Invalid number of bypass priorities"
+#endif
+#define MLX5_IB_FLOW_LEFTOVERS_PRIO	(MLX5_IB_FLOW_MCAST_PRIO + 1)
+
+#define MLX5_IB_NUM_FLOW_FT		(MLX5_IB_FLOW_LEFTOVERS_PRIO + 1)
+struct mlx5_ib_flow_prio {
+	struct mlx5_flow_table		*flow_table;
+	unsigned int			refcount;
+};
+
+struct mlx5_ib_flow_handler {
+	struct list_head		list;
+	struct ib_flow			ibflow;
+	unsigned int			prio;
+	struct mlx5_flow_rule	*rule;
+};
+
+struct mlx5_ib_flow_db {
+	struct mlx5_ib_flow_prio	prios[MLX5_IB_NUM_FLOW_FT];
+	/* Protect flow steering bypass flow tables
+	 * when add/del flow rules.
+	 * only single add/removal of flow steering rule could be done
+	 * simultaneously.
+	 */
+	struct mutex			lock;
+};
+
 /* Use macros here so that don't have to duplicate
  * enum ib_send_flags and enum ib_qp_type for low-level driver
  */
@@ -171,9 +201,21 @@ struct mlx5_ib_pfault {
 	struct mlx5_pagefault	mpfault;
 };
 
+struct mlx5_ib_rq {
+	u32			tirn;
+};
+
+struct mlx5_ib_raw_packet_qp {
+	struct mlx5_ib_rq rq;
+};
+
 struct mlx5_ib_qp {
 	struct ib_qp		ibqp;
-	struct mlx5_core_qp	mqp;
+	union {
+		struct mlx5_core_qp		mqp;
+		struct mlx5_ib_raw_packet_qp	raw_packet_qp;
+	};
+
 	struct mlx5_buf		buf;
 
 	struct mlx5_db		db;
@@ -431,6 +473,7 @@ struct mlx5_ib_dev {
 	 */
 	struct srcu_struct      mr_srcu;
 #endif
+	struct mlx5_ib_flow_db	flow_db;
 };
 
 static inline struct mlx5_ib_cq *to_mibcq(struct mlx5_core_cq *mcq)
-- 
1.7.1
