From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH  V3 11/11] IB/mlx5: Add flow steering support
Date: Mon, 11 Jan 2016 10:26:07 +0200
Message-ID: <1452500767-3628-12-git-send-email-ogerlitz@mellanox.com>
References: <1452500767-3628-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Doug Ledford <dledford@redhat.com>,
	Matan Barak <matanb@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Moni Shoua <monis@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:59727 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758754AbcAKI1L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jan 2016 03:27:11 -0500
In-Reply-To: <1452500767-3628-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maor Gottlieb <maorg@mellanox.com>

Adding flow steering support by creating a flow-table per
priority (if rules exist in the priority). mlx5_ib uses
autogrouping and thus only creates the required destinations.

Also includes adding of these flow steering utilities

1. Parsing verbs flow attributes hardware steering specs.

2. Check if flow is multicast - this is required in order to decide
to which flow table will we add the steering rule.

3. Set outer headers in flow match criteria to zeros.

Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Moni Shoua <monis@mellanox.com>
Signed-off-by: Matan Barak <matanb@mellanox.com>
---
 drivers/infiniband/hw/mlx5/main.c    | 463 +++++++++++++++++++++++++++++++++++
 drivers/infiniband/hw/mlx5/mlx5_ib.h |  45 +++-
 include/linux/mlx5/fs.h              |  10 +
 3 files changed, 517 insertions(+), 1 deletion(-)

diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index 7e97cb5..b0ec175 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -43,6 +43,9 @@
 #include <linux/mlx5/vport.h>
 #include <rdma/ib_smi.h>
 #include <rdma/ib_umem.h>
+#include <linux/in.h>
+#include <linux/etherdevice.h>
+#include <linux/mlx5/fs.h>
 #include "user.h"
 #include "mlx5_ib.h"
 
@@ -835,6 +838,457 @@ static int mlx5_ib_dealloc_pd(struct ib_pd *pd)
 	return 0;
 }
 
+static bool outer_header_zero(u32 *match_criteria)
+{
+	int size = MLX5_ST_SZ_BYTES(fte_match_param);
+	char *outer_headers_c = MLX5_ADDR_OF(fte_match_param, match_criteria,
+					     outer_headers);
+
+	return outer_headers_c[0] == 0 && !memcmp(outer_headers_c,
+						  outer_headers_c + 1,
+						  size - 1);
+}
+
+static int parse_flow_attr(u32 *match_c, u32 *match_v,
+			   union ib_flow_spec *ib_spec)
+{
+	void *outer_headers_c = MLX5_ADDR_OF(fte_match_param, match_c,
+					     outer_headers);
+	void *outer_headers_v = MLX5_ADDR_OF(fte_match_param, match_v,
+					     outer_headers);
+	switch (ib_spec->type) {
+	case IB_FLOW_SPEC_ETH:
+		if (ib_spec->size != sizeof(ib_spec->eth))
+			return -EINVAL;
+
+		ether_addr_copy(MLX5_ADDR_OF(fte_match_set_lyr_2_4, outer_headers_c,
+					     dmac_47_16),
+				ib_spec->eth.mask.dst_mac);
+		ether_addr_copy(MLX5_ADDR_OF(fte_match_set_lyr_2_4, outer_headers_v,
+					     dmac_47_16),
+				ib_spec->eth.val.dst_mac);
+
+		if (ib_spec->eth.mask.vlan_tag) {
+			MLX5_SET(fte_match_set_lyr_2_4, outer_headers_c,
+				 vlan_tag, 1);
+			MLX5_SET(fte_match_set_lyr_2_4, outer_headers_v,
+				 vlan_tag, 1);
+
+			MLX5_SET(fte_match_set_lyr_2_4, outer_headers_c,
+				 first_vid, ntohs(ib_spec->eth.mask.vlan_tag));
+			MLX5_SET(fte_match_set_lyr_2_4, outer_headers_v,
+				 first_vid, ntohs(ib_spec->eth.val.vlan_tag));
+
+			MLX5_SET(fte_match_set_lyr_2_4, outer_headers_c,
+				 first_cfi,
+				 ntohs(ib_spec->eth.mask.vlan_tag) >> 12);
+			MLX5_SET(fte_match_set_lyr_2_4, outer_headers_v,
+				 first_cfi,
+				 ntohs(ib_spec->eth.val.vlan_tag) >> 12);
+
+			MLX5_SET(fte_match_set_lyr_2_4, outer_headers_c,
+				 first_prio,
+				 ntohs(ib_spec->eth.mask.vlan_tag) >> 13);
+			MLX5_SET(fte_match_set_lyr_2_4, outer_headers_v,
+				 first_prio,
+				 ntohs(ib_spec->eth.val.vlan_tag) >> 13);
+		}
+		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_c,
+			 ethertype, ntohs(ib_spec->eth.mask.ether_type));
+		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_v,
+			 ethertype, ntohs(ib_spec->eth.val.ether_type));
+		break;
+	case IB_FLOW_SPEC_IPV4:
+		if (ib_spec->size != sizeof(ib_spec->ipv4))
+			return -EINVAL;
+
+		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_c,
+			 ethertype, 0xffff);
+		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_v,
+			 ethertype, ETH_P_IP);
+
+		memcpy(MLX5_ADDR_OF(fte_match_set_lyr_2_4, outer_headers_c,
+				    src_ipv4_src_ipv6.ipv4_layout.ipv4),
+		       &ib_spec->ipv4.mask.src_ip,
+		       sizeof(ib_spec->ipv4.mask.src_ip));
+		memcpy(MLX5_ADDR_OF(fte_match_set_lyr_2_4, outer_headers_v,
+				    src_ipv4_src_ipv6.ipv4_layout.ipv4),
+		       &ib_spec->ipv4.val.src_ip,
+		       sizeof(ib_spec->ipv4.val.src_ip));
+		memcpy(MLX5_ADDR_OF(fte_match_set_lyr_2_4, outer_headers_c,
+				    dst_ipv4_dst_ipv6.ipv4_layout.ipv4),
+		       &ib_spec->ipv4.mask.dst_ip,
+		       sizeof(ib_spec->ipv4.mask.dst_ip));
+		memcpy(MLX5_ADDR_OF(fte_match_set_lyr_2_4, outer_headers_v,
+				    dst_ipv4_dst_ipv6.ipv4_layout.ipv4),
+		       &ib_spec->ipv4.val.dst_ip,
+		       sizeof(ib_spec->ipv4.val.dst_ip));
+		break;
+	case IB_FLOW_SPEC_TCP:
+		if (ib_spec->size != sizeof(ib_spec->tcp_udp))
+			return -EINVAL;
+
+		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_c, ip_protocol,
+			 0xff);
+		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_v, ip_protocol,
+			 IPPROTO_TCP);
+
+		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_c, tcp_sport,
+			 ntohs(ib_spec->tcp_udp.mask.src_port));
+		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_v, tcp_sport,
+			 ntohs(ib_spec->tcp_udp.val.src_port));
+
+		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_c, tcp_dport,
+			 ntohs(ib_spec->tcp_udp.mask.dst_port));
+		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_v, tcp_dport,
+			 ntohs(ib_spec->tcp_udp.val.dst_port));
+		break;
+	case IB_FLOW_SPEC_UDP:
+		if (ib_spec->size != sizeof(ib_spec->tcp_udp))
+			return -EINVAL;
+
+		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_c, ip_protocol,
+			 0xff);
+		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_v, ip_protocol,
+			 IPPROTO_UDP);
+
+		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_c, udp_sport,
+			 ntohs(ib_spec->tcp_udp.mask.src_port));
+		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_v, udp_sport,
+			 ntohs(ib_spec->tcp_udp.val.src_port));
+
+		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_c, udp_dport,
+			 ntohs(ib_spec->tcp_udp.mask.dst_port));
+		MLX5_SET(fte_match_set_lyr_2_4, outer_headers_v, udp_dport,
+			 ntohs(ib_spec->tcp_udp.val.dst_port));
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+/* If a flow could catch both multicast and unicast packets,
+ * it won't fall into the multicast flow steering table and this rule
+ * could steal other multicast packets.
+ */
+static bool flow_is_multicast_only(struct ib_flow_attr *ib_attr)
+{
+	struct ib_flow_spec_eth *eth_spec;
+
+	if (ib_attr->type != IB_FLOW_ATTR_NORMAL ||
+	    ib_attr->size < sizeof(struct ib_flow_attr) +
+	    sizeof(struct ib_flow_spec_eth) ||
+	    ib_attr->num_of_specs < 1)
+		return false;
+
+	eth_spec = (struct ib_flow_spec_eth *)(ib_attr + 1);
+	if (eth_spec->type != IB_FLOW_SPEC_ETH ||
+	    eth_spec->size != sizeof(*eth_spec))
+		return false;
+
+	return is_multicast_ether_addr(eth_spec->mask.dst_mac) &&
+	       is_multicast_ether_addr(eth_spec->val.dst_mac);
+}
+
+static bool is_valid_attr(struct ib_flow_attr *flow_attr)
+{
+	union ib_flow_spec *ib_spec = (union ib_flow_spec *)(flow_attr + 1);
+	bool has_ipv4_spec = false;
+	bool eth_type_ipv4 = true;
+	unsigned int spec_index;
+
+	/* Validate that ethertype is correct */
+	for (spec_index = 0; spec_index < flow_attr->num_of_specs; spec_index++) {
+		if (ib_spec->type == IB_FLOW_SPEC_ETH &&
+		    ib_spec->eth.mask.ether_type) {
+			if (!((ib_spec->eth.mask.ether_type == htons(0xffff)) &&
+			      ib_spec->eth.val.ether_type == htons(ETH_P_IP)))
+				eth_type_ipv4 = false;
+		} else if (ib_spec->type == IB_FLOW_SPEC_IPV4) {
+			has_ipv4_spec = true;
+		}
+		ib_spec = (void *)ib_spec + ib_spec->size;
+	}
+	return !has_ipv4_spec || eth_type_ipv4;
+}
+
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
@@ -1439,10 +1893,19 @@ static void *mlx5_ib_add(struct mlx5_core_dev *mdev)
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
diff --git a/include/linux/mlx5/fs.h b/include/linux/mlx5/fs.h
index a943412..8230caa 100644
--- a/include/linux/mlx5/fs.h
+++ b/include/linux/mlx5/fs.h
@@ -38,6 +38,16 @@
 
 #define MLX5_FS_DEFAULT_FLOW_TAG 0x0
 
+#define LEFTOVERS_RULE_NUM	 2
+static inline void build_leftovers_ft_param(int *priority,
+					    int *n_ent,
+					    int *n_grp)
+{
+	*priority = 0; /* Priority of leftovers_prio-0 */
+	*n_ent = LEFTOVERS_RULE_NUM;
+	*n_grp = LEFTOVERS_RULE_NUM;
+}
+
 enum mlx5_flow_namespace_type {
 	MLX5_FLOW_NAMESPACE_BYPASS,
 	MLX5_FLOW_NAMESPACE_KERNEL,
-- 
2.3.7
