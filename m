From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 13/13] net/mlx5e: Add basic TC tunnel set action for SRIOV offloads
Date: Mon,  7 Nov 2016 15:14:48 +0200
Message-ID: <1478524488-1377-14-git-send-email-saeedm@mellanox.com>
References: <1478524488-1377-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen-Zion <hadarh@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:39596 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753421AbcKGNPH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 08:15:07 -0500
In-Reply-To: <1478524488-1377-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

In mlx5 HW, encapsulation is offloaded by the steering rule having
index into an encapsulation table containing the entire set of headers
to be added by the HW. The driver sets these headers in a buffer when we
are offloading the action.

The code maintains mlx5_encap_entry for each encap header it has
encountered when attempted to offload TC tunnel set action.

This entry maintains a linked list of all the flows sharing the same
encap header, when the last flow is removed from the list the encap
entry is removed.

The actual encap_header is allocated by the driver in the hardware only
if we have layer two neighbour info when the encap entry is created.
While the flow is in the driver, the driver holds a reference on the
neighbour.

When a new flow with encap action is inserted, the code first checks if
the required encap entry exists according to the tunnel set parameters.
If it does the encap is shared, otherwise a new mlx5_encap_entry is
created.

TC action parsing implementation in the driver assumes that tunnel set
action is provided in the same order set by the user, e.g before the
mirred_redirect action.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    | 295 ++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c  |   1 +
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h  |  20 ++
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c |   3 +
 4 files changed, 312 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 8946653..9d133fc 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -41,6 +41,7 @@
 #include <net/tc_act/tc_mirred.h>
 #include <net/tc_act/tc_vlan.h>
 #include <net/tc_act/tc_tunnel_key.h>
+#include <net/vxlan.h>
 #include "en.h"
 #include "en_tc.h"
 #include "eswitch.h"
@@ -50,9 +51,15 @@ struct mlx5e_tc_flow {
 	struct rhash_head	node;
 	u64			cookie;
 	struct mlx5_flow_handle *rule;
+	struct list_head	encap; /* flows sharing the same encap */
 	struct mlx5_esw_flow_attr *attr;
 };
 
+enum {
+	MLX5_HEADER_TYPE_VXLAN = 0x0,
+	MLX5_HEADER_TYPE_NVGRE = 0x1,
+};
+
 #define MLX5E_TC_TABLE_NUM_ENTRIES 1024
 #define MLX5E_TC_TABLE_NUM_GROUPS 4
 
@@ -538,11 +545,243 @@ static int parse_tc_nic_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
 	return 0;
 }
 
+static inline int cmp_encap_info(struct mlx5_encap_info *a,
+				 struct mlx5_encap_info *b)
+{
+	return memcmp(a, b, sizeof(*a));
+}
+
+static inline int hash_encap_info(struct mlx5_encap_info *info)
+{
+	return jhash(info, sizeof(*info), 0);
+}
+
+static int mlx5e_route_lookup_ipv4(struct mlx5e_priv *priv,
+				   struct net_device *mirred_dev,
+				   struct net_device **out_dev,
+				   struct flowi4 *fl4,
+				   struct neighbour **out_n,
+				   __be32 *saddr,
+				   int *out_ttl)
+{
+	struct rtable *rt;
+	struct neighbour *n = NULL;
+	int ttl;
+
+#if IS_ENABLED(CONFIG_INET)
+	rt = ip_route_output_key(dev_net(mirred_dev), fl4);
+	if (IS_ERR(rt)) {
+		pr_warn("%s: no route to %pI4\n", __func__, &fl4->daddr);
+		return -EOPNOTSUPP;
+	}
+#else
+	return -EOPNOTSUPP;
+#endif
+
+	if (!switchdev_port_same_parent_id(priv->netdev, rt->dst.dev)) {
+		pr_warn("%s: Can't offload the flow, netdevices aren't on the same HW e-switch\n",
+			__func__);
+		ip_rt_put(rt);
+		return -EOPNOTSUPP;
+	}
+
+	ttl = ip4_dst_hoplimit(&rt->dst);
+	n = dst_neigh_lookup(&rt->dst, &fl4->daddr);
+	ip_rt_put(rt);
+	if (!n)
+		return -ENOMEM;
+
+	*out_n = n;
+	*saddr = fl4->saddr;
+	*out_ttl = ttl;
+	*out_dev = rt->dst.dev;
+
+	return 0;
+}
+
+static int gen_vxlan_header_ipv4(struct net_device *out_dev,
+				 char buf[],
+				 unsigned char h_dest[ETH_ALEN],
+				 int ttl,
+				 __be32 daddr,
+				 __be32 saddr,
+				 __be16 udp_dst_port,
+				 __be32 vx_vni)
+{
+	int encap_size = VXLAN_HLEN + sizeof(struct iphdr) + ETH_HLEN;
+	struct ethhdr *eth = (struct ethhdr *)buf;
+	struct iphdr  *ip = (struct iphdr *)((char *)eth + sizeof(struct ethhdr));
+	struct udphdr *udp = (struct udphdr *)((char *)ip + sizeof(struct iphdr));
+	struct vxlanhdr *vxh = (struct vxlanhdr *)((char *)udp + sizeof(struct udphdr));
+
+	memset(buf, 0, encap_size);
+
+	ether_addr_copy(eth->h_dest, h_dest);
+	ether_addr_copy(eth->h_source, out_dev->dev_addr);
+	eth->h_proto = htons(ETH_P_IP);
+
+	ip->daddr = daddr;
+	ip->saddr = saddr;
+
+	ip->ttl = ttl;
+	ip->protocol = IPPROTO_UDP;
+	ip->version = 0x4;
+	ip->ihl = 0x5;
+
+	udp->dest = udp_dst_port;
+	vxh->vx_flags = VXLAN_HF_VNI;
+	vxh->vx_vni = vxlan_vni_field(vx_vni);
+
+	return encap_size;
+}
+
+static int mlx5e_create_encap_header_ipv4(struct mlx5e_priv *priv,
+					  struct net_device *mirred_dev,
+					  struct mlx5_encap_entry *e,
+					  struct net_device **out_dev)
+{
+	int max_encap_size = MLX5_CAP_ESW(priv->mdev, max_encap_header_size);
+	struct flowi4 fl4 = {};
+	struct neighbour *n;
+	char *encap_header;
+	int encap_size;
+	__be32 saddr;
+	int ttl;
+	int err;
+
+	encap_header = kzalloc(max_encap_size, GFP_KERNEL);
+	if (!encap_header)
+		return -ENOMEM;
+
+	switch (e->tunnel_type) {
+	case MLX5_HEADER_TYPE_VXLAN:
+		fl4.flowi4_proto = IPPROTO_UDP;
+		fl4.fl4_dport = e->tun_info.tp_dst;
+		break;
+	default:
+		err = -EOPNOTSUPP;
+		goto out;
+	}
+	fl4.daddr = e->tun_info.daddr;
+
+	err = mlx5e_route_lookup_ipv4(priv, mirred_dev, out_dev,
+				      &fl4, &n, &saddr, &ttl);
+	if (err)
+		goto out;
+
+	e->n = n;
+	e->out_dev = *out_dev;
+
+	if (!(n->nud_state & NUD_VALID)) {
+		err = -ENOTSUPP;
+		goto out;
+	}
+
+	neigh_ha_snapshot(e->h_dest, n, *out_dev);
+
+	switch (e->tunnel_type) {
+	case MLX5_HEADER_TYPE_VXLAN:
+		encap_size = gen_vxlan_header_ipv4(*out_dev, encap_header,
+						   e->h_dest, ttl,
+						   e->tun_info.daddr,
+						   saddr, e->tun_info.tp_dst,
+						   e->tun_info.tun_id);
+		break;
+	default:
+		err = -EOPNOTSUPP;
+		goto out;
+	}
+
+	err = mlx5_encap_alloc(priv->mdev, e->tunnel_type,
+			       encap_size, encap_header, &e->encap_id);
+out:
+	kfree(encap_header);
+	return err;
+}
+
+static int mlx5e_attach_encap(struct mlx5e_priv *priv,
+			      struct ip_tunnel_info *tun_info,
+			      struct net_device *mirred_dev,
+			      struct mlx5_esw_flow_attr *attr)
+{
+	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
+	unsigned short family = ip_tunnel_info_af(tun_info);
+	struct ip_tunnel_key *key = &tun_info->key;
+	struct mlx5_encap_info info;
+	struct mlx5_encap_entry *e;
+	struct net_device *out_dev;
+	uintptr_t hash_key;
+	bool found = false;
+	int tunnel_type;
+	int err;
+
+	/* udp dst port must be given */
+	if (!memchr_inv(&key->tp_dst, 0, sizeof(key->tp_dst)))
+		return -EOPNOTSUPP;
+
+	if (mlx5e_vxlan_lookup_port(priv, be16_to_cpu(key->tp_dst)) &&
+	    MLX5_CAP_ESW(priv->mdev, vxlan_encap_decap)) {
+		info.tp_dst = key->tp_dst;
+		info.tun_id = tunnel_id_to_key32(key->tun_id);
+		tunnel_type = MLX5_HEADER_TYPE_VXLAN;
+	} else {
+		return -EOPNOTSUPP;
+	}
+
+	switch (family) {
+	case AF_INET:
+		info.daddr = key->u.ipv4.dst;
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	hash_key = hash_encap_info(&info);
+
+	hash_for_each_possible_rcu(esw->offloads.encap_tbl, e,
+				   encap_hlist, hash_key) {
+		if (!cmp_encap_info(&e->tun_info, &info)) {
+			found = true;
+			break;
+		}
+	}
+
+	if (found) {
+		attr->encap = e;
+		return 0;
+	}
+
+	e = kzalloc(sizeof(*e), GFP_KERNEL);
+	if (!e)
+		return -ENOMEM;
+
+	e->tun_info = info;
+	e->tunnel_type = tunnel_type;
+	INIT_LIST_HEAD(&e->flows);
+
+	err = mlx5e_create_encap_header_ipv4(priv, mirred_dev, e, &out_dev);
+	if (err)
+		goto out_err;
+
+	attr->encap = e;
+	hash_add_rcu(esw->offloads.encap_tbl, &e->encap_hlist, hash_key);
+
+	return err;
+
+out_err:
+	kfree(e);
+	return err;
+}
+
 static int parse_tc_fdb_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
-				struct mlx5_esw_flow_attr *attr)
+				struct mlx5e_tc_flow *flow)
 {
+	struct mlx5_esw_flow_attr *attr = flow->attr;
+	struct ip_tunnel_info *info = NULL;
 	const struct tc_action *a;
 	LIST_HEAD(actions);
+	bool encap = false;
+	int err;
 
 	if (tc_no_actions(exts))
 		return -EINVAL;
@@ -565,16 +804,37 @@ static int parse_tc_fdb_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
 
 			out_dev = __dev_get_by_index(dev_net(priv->netdev), ifindex);
 
-			if (!switchdev_port_same_parent_id(priv->netdev, out_dev)) {
+			if (switchdev_port_same_parent_id(priv->netdev,
+							  out_dev)) {
+				attr->action |= MLX5_FLOW_CONTEXT_ACTION_FWD_DEST |
+					MLX5_FLOW_CONTEXT_ACTION_COUNT;
+				out_priv = netdev_priv(out_dev);
+				attr->out_rep = out_priv->ppriv;
+			} else if (encap) {
+				err = mlx5e_attach_encap(priv, info,
+							 out_dev, attr);
+				if (err)
+					return err;
+				list_add(&flow->encap, &attr->encap->flows);
+				attr->action |= MLX5_FLOW_CONTEXT_ACTION_ENCAP |
+					MLX5_FLOW_CONTEXT_ACTION_FWD_DEST |
+					MLX5_FLOW_CONTEXT_ACTION_COUNT;
+				out_priv = netdev_priv(attr->encap->out_dev);
+				attr->out_rep = out_priv->ppriv;
+			} else {
 				pr_err("devices %s %s not on same switch HW, can't offload forwarding\n",
 				       priv->netdev->name, out_dev->name);
 				return -EINVAL;
 			}
+			continue;
+		}
 
-			attr->action |= MLX5_FLOW_CONTEXT_ACTION_FWD_DEST |
-					MLX5_FLOW_CONTEXT_ACTION_COUNT;
-			out_priv = netdev_priv(out_dev);
-			attr->out_rep = out_priv->ppriv;
+		if (is_tcf_tunnel_set(a)) {
+			info = tcf_tunnel_info(a);
+			if (info)
+				encap = true;
+			else
+				return -EOPNOTSUPP;
 			continue;
 		}
 
@@ -644,7 +904,7 @@ int mlx5e_configure_flower(struct mlx5e_priv *priv, __be16 protocol,
 
 	if (fdb_flow) {
 		flow->attr  = (struct mlx5_esw_flow_attr *)(flow + 1);
-		err = parse_tc_fdb_actions(priv, f->exts, flow->attr);
+		err = parse_tc_fdb_actions(priv, f->exts, flow);
 		if (err < 0)
 			goto err_free;
 		flow->rule = mlx5e_tc_add_fdb_flow(priv, spec, flow->attr);
@@ -681,6 +941,24 @@ int mlx5e_configure_flower(struct mlx5e_priv *priv, __be16 protocol,
 	return err;
 }
 
+static void mlx5e_detach_encap(struct mlx5e_priv *priv,
+			       struct mlx5e_tc_flow *flow) {
+	struct list_head *next = flow->encap.next;
+
+	list_del(&flow->encap);
+	if (list_empty(next)) {
+		struct mlx5_encap_entry *e;
+
+		e = list_entry(next, struct mlx5_encap_entry, flows);
+		if (e->n) {
+			mlx5_encap_dealloc(priv->mdev, e->encap_id);
+			neigh_release(e->n);
+		}
+		hlist_del_rcu(&e->encap_hlist);
+		kfree(e);
+	}
+}
+
 int mlx5e_delete_flower(struct mlx5e_priv *priv,
 			struct tc_cls_flower_offload *f)
 {
@@ -696,6 +974,9 @@ int mlx5e_delete_flower(struct mlx5e_priv *priv,
 
 	mlx5e_tc_del_flow(priv, flow->rule, flow->attr);
 
+	if (flow->attr->action & MLX5_FLOW_CONTEXT_ACTION_ENCAP)
+		mlx5e_detach_encap(priv, flow);
+
 	kfree(flow);
 
 	return 0;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index ae05d27..9734ac8 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -1782,6 +1782,7 @@ int mlx5_eswitch_init(struct mlx5_core_dev *dev)
 		goto abort;
 	}
 
+	hash_init(esw->offloads.encap_tbl);
 	mutex_init(&esw->state_lock);
 
 	for (vport_num = 0; vport_num < total_vports; vport_num++) {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
index 6d414cb..40482e8 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
@@ -199,6 +199,7 @@ struct mlx5_esw_offload {
 	struct mlx5_flow_table *ft_offloads;
 	struct mlx5_flow_group *vport_rx_group;
 	struct mlx5_eswitch_rep *vport_reps;
+	DECLARE_HASHTABLE(encap_tbl, 8);
 };
 
 struct mlx5_eswitch {
@@ -272,6 +273,24 @@ enum {
 #define MLX5_FLOW_CONTEXT_ACTION_VLAN_POP  0x40
 #define MLX5_FLOW_CONTEXT_ACTION_VLAN_PUSH 0x80
 
+struct mlx5_encap_info {
+	__be32 daddr;
+	__be32 tun_id;
+	__be16 tp_dst;
+};
+
+struct mlx5_encap_entry {
+	struct hlist_node encap_hlist;
+	struct list_head flows;
+	u32 encap_id;
+	struct neighbour *n;
+	struct mlx5_encap_info tun_info;
+	unsigned char h_dest[ETH_ALEN];	/* destination eth addr	*/
+
+	struct net_device *out_dev;
+	int tunnel_type;
+};
+
 struct mlx5_esw_flow_attr {
 	struct mlx5_eswitch_rep *in_rep;
 	struct mlx5_eswitch_rep *out_rep;
@@ -279,6 +298,7 @@ struct mlx5_esw_flow_attr {
 	int	action;
 	u16	vlan;
 	bool	vlan_handled;
+	struct mlx5_encap_entry *encap;
 };
 
 int mlx5_eswitch_sqs2vport_start(struct mlx5_eswitch *esw,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index c2dc470..50fe8e8 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -85,6 +85,9 @@ mlx5_eswitch_add_offloaded_rule(struct mlx5_eswitch *esw,
 	if (flow_act.action & MLX5_FLOW_CONTEXT_ACTION_DECAP)
 		spec->match_criteria_enable |= MLX5_MATCH_INNER_HEADERS;
 
+	if (attr->encap)
+		flow_act.encap_id = attr->encap->encap_id;
+
 	rule = mlx5_add_flow_rules((struct mlx5_flow_table *)esw->fdb_table.fdb,
 				   spec, &flow_act, dest, i);
 	if (IS_ERR(rule))
-- 
2.7.4
