From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 08/15] net/mlx5e: Add support to neighbour update flow
Date: Sun, 30 Apr 2017 16:20:09 +0300
Message-ID: <20170430132016.27012-9-saeedm@mellanox.com>
References: <20170430132016.27012-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen-Zion <hadarh@mellanox.com>,
        Ilya Lesokhin <ilyal@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:46766 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1756813AbdD3NU2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 09:20:28 -0400
In-Reply-To: <20170430132016.27012-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

In order to offload TC encap rules, the driver does a lookup for the IP
tunnel neighbour according to the output device and the destination IP
given by the user.

To keep tracking after the validity state of such neighbours, we keep
the neighbours information (pair of device pointer and destination IP)
in a hash table maintained at the relevant egress representor and
register to get NETEVENT_NEIGH_UPDATE events. When getting neighbour update
netevent, we search for a match among the cached neighbours entries used for
encapsulation.

In case the neighbour isn't valid, we can't offload the flow into the
HW. We cache the flow (requested matching and actions) in the driver and
offload the rule later, when the neighbour is resolved and becomes
valid.

When a flow is only cached in the driver and not offloaded into HW
yet, we use EAGAIN return value to mark it internally, the TC ndo still
returns success.

Listen to kernel neighbour update netevents to trace relevant neighbours
validity state:

1. If a neighbour becomes valid, offload the related rules to HW.

2. If the neighbour becomes invalid, remove the related rules from HW.

3. If the neighbour mac address was changed, update the encap header.
   Remove all the offloaded rules using the old encap header from the HW
   and insert new rules to HW with updated encap header.

Access to the neighbors hash table is protected by RTNL lock of its
caller or by the table's spinlock.

Details of the locking/synchronization among the different actions
applied on the neighbour table:

Add/remove operations - protected by RTNL lock of its caller (all TC
commands are protected by RTNL lock). Add and remove operations are
initiated only when the user inserts/removes a TC rule into/from the driver.

Lookup/remove operations - since the lookup operation is done from
netevent notifier block, RTNL lock can't be used (atomic context).
Use the table's spin lock to protect lookups from TC user removal operation.
bh is used since netevent can be called from a softirq context.

Lookup/add operations - The hash table access functions are taking
care of the protection between lookup and add operations.

When adding/removing encap headers and rules to/from the HW, RTNL lock
is used. It can happen when:

1. The user inserts/removes a TC rule into/from the driver (TC commands
are protected by RTNL lock of it's caller).

2. The driver gets neighbour notification event, which reports about
neighbour validity status change. Before adding/removing encap headers
and rules to/from the HW, RTNL lock is taken.

A neighbour hash table entry should be freed when its encap list is empty.
Since The neighbour update netevent notification schedules a neighbour
update work that uses the neighbour hash entry, it can't be freed
unconditionally when the encap list becomes empty during TC delete rule flow.
Use reference count to protect from freeing neighbour hash table entry
while it's still in use.

When the user asks to unregister a netdvice used by one of the neigbours,
neighbour removal notification is received. Then we take a reference on the
neighbour and don't free it until the relevant encap entries (and flows) are
marked as invalid (not offloaded) and removed from HW.
As long as the encap entry is still valid (checked under RTNL lock) we
can safely access the neighbour device saved on mlx5e_neigh struct.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c  | 230 +++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.h  |  38 +++-
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c   | 202 +++++++++++++++----
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.h   |   6 +
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h |   1 +
 5 files changed, 434 insertions(+), 43 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
index 52ea7f1c0973..730de6b7e46e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -34,6 +34,8 @@
 #include <linux/mlx5/fs.h>
 #include <net/switchdev.h>
 #include <net/pkt_cls.h>
+#include <net/netevent.h>
+#include <net/arp.h>
 
 #include "eswitch.h"
 #include "en.h"
@@ -224,6 +226,140 @@ void mlx5e_remove_sqs_fwd_rules(struct mlx5e_priv *priv)
 	mlx5_eswitch_sqs2vport_stop(esw, rep);
 }
 
+static void mlx5e_rep_neigh_entry_hold(struct mlx5e_neigh_hash_entry *nhe)
+{
+	refcount_inc(&nhe->refcnt);
+}
+
+static void mlx5e_rep_neigh_entry_release(struct mlx5e_neigh_hash_entry *nhe)
+{
+	if (refcount_dec_and_test(&nhe->refcnt))
+		kfree(nhe);
+}
+
+static void mlx5e_rep_update_flows(struct mlx5e_priv *priv,
+				   struct mlx5e_encap_entry *e,
+				   bool neigh_connected,
+				   unsigned char ha[ETH_ALEN])
+{
+	struct ethhdr *eth = (struct ethhdr *)e->encap_header;
+
+	ASSERT_RTNL();
+
+	if ((!neigh_connected && (e->flags & MLX5_ENCAP_ENTRY_VALID)) ||
+	    !ether_addr_equal(e->h_dest, ha))
+		mlx5e_tc_encap_flows_del(priv, e);
+
+	if (neigh_connected && !(e->flags & MLX5_ENCAP_ENTRY_VALID)) {
+		ether_addr_copy(e->h_dest, ha);
+		ether_addr_copy(eth->h_dest, ha);
+
+		mlx5e_tc_encap_flows_add(priv, e);
+	}
+}
+
+static void mlx5e_rep_neigh_update(struct work_struct *work)
+{
+	struct mlx5e_neigh_hash_entry *nhe =
+		container_of(work, struct mlx5e_neigh_hash_entry, neigh_update_work);
+	struct neighbour *n = nhe->n;
+	struct mlx5e_encap_entry *e;
+	unsigned char ha[ETH_ALEN];
+	struct mlx5e_priv *priv;
+	bool neigh_connected;
+	bool encap_connected;
+	u8 nud_state, dead;
+
+	rtnl_lock();
+
+	/* If these parameters are changed after we release the lock,
+	 * we'll receive another event letting us know about it.
+	 * We use this lock to avoid inconsistency between the neigh validity
+	 * and it's hw address.
+	 */
+	read_lock_bh(&n->lock);
+	memcpy(ha, n->ha, ETH_ALEN);
+	nud_state = n->nud_state;
+	dead = n->dead;
+	read_unlock_bh(&n->lock);
+
+	neigh_connected = (nud_state & NUD_VALID) && !dead;
+
+	list_for_each_entry(e, &nhe->encap_list, encap_list) {
+		encap_connected = !!(e->flags & MLX5_ENCAP_ENTRY_VALID);
+		priv = netdev_priv(e->out_dev);
+
+		if (encap_connected != neigh_connected ||
+		    !ether_addr_equal(e->h_dest, ha))
+			mlx5e_rep_update_flows(priv, e, neigh_connected, ha);
+	}
+	mlx5e_rep_neigh_entry_release(nhe);
+	rtnl_unlock();
+	neigh_release(n);
+}
+
+static struct mlx5e_neigh_hash_entry *
+mlx5e_rep_neigh_entry_lookup(struct mlx5e_priv *priv,
+			     struct mlx5e_neigh *m_neigh);
+
+static int mlx5e_rep_netevent_event(struct notifier_block *nb,
+				    unsigned long event, void *ptr)
+{
+	struct mlx5e_rep_priv *rpriv = container_of(nb, struct mlx5e_rep_priv,
+						    neigh_update.netevent_nb);
+	struct mlx5e_neigh_update_table *neigh_update = &rpriv->neigh_update;
+	struct net_device *netdev = rpriv->rep->netdev;
+	struct mlx5e_priv *priv = netdev_priv(netdev);
+	struct mlx5e_neigh_hash_entry *nhe = NULL;
+	struct mlx5e_neigh m_neigh = {};
+	struct neighbour *n;
+
+	switch (event) {
+	case NETEVENT_NEIGH_UPDATE:
+		n = ptr;
+#if IS_ENABLED(CONFIG_IPV6)
+		if (n->tbl != ipv6_stub->nd_tbl && n->tbl != &arp_tbl)
+#else
+		if (n->tbl != &arp_tbl)
+#endif
+			return NOTIFY_DONE;
+
+		m_neigh.dev = n->dev;
+		memcpy(&m_neigh.dst_ip, n->primary_key, n->tbl->key_len);
+
+		/* We are in atomic context and can't take RTNL mutex, so use
+		 * spin_lock_bh to lookup the neigh table. bh is used since
+		 * netevent can be called from a softirq context.
+		 */
+		spin_lock_bh(&neigh_update->encap_lock);
+		nhe = mlx5e_rep_neigh_entry_lookup(priv, &m_neigh);
+		if (!nhe) {
+			spin_unlock_bh(&neigh_update->encap_lock);
+			return NOTIFY_DONE;
+		}
+
+		/* This assignment is valid as long as the the neigh reference
+		 * is taken
+		 */
+		nhe->n = n;
+
+		/* Take a reference to ensure the neighbour and mlx5 encap
+		 * entry won't be destructed until we drop the reference in
+		 * delayed work.
+		 */
+		neigh_hold(n);
+		mlx5e_rep_neigh_entry_hold(nhe);
+
+		if (!queue_work(priv->wq, &nhe->neigh_update_work)) {
+			mlx5e_rep_neigh_entry_release(nhe);
+			neigh_release(n);
+		}
+		spin_unlock_bh(&neigh_update->encap_lock);
+		break;
+	}
+	return NOTIFY_DONE;
+}
+
 static const struct rhashtable_params mlx5e_neigh_ht_params = {
 	.head_offset = offsetof(struct mlx5e_neigh_hash_entry, rhash_node),
 	.key_offset = offsetof(struct mlx5e_neigh_hash_entry, m_neigh),
@@ -234,14 +370,34 @@ static const struct rhashtable_params mlx5e_neigh_ht_params = {
 static int mlx5e_rep_neigh_init(struct mlx5e_rep_priv *rpriv)
 {
 	struct mlx5e_neigh_update_table *neigh_update = &rpriv->neigh_update;
+	int err;
+
+	err = rhashtable_init(&neigh_update->neigh_ht, &mlx5e_neigh_ht_params);
+	if (err)
+		return err;
 
 	INIT_LIST_HEAD(&neigh_update->neigh_list);
-	return rhashtable_init(&neigh_update->neigh_ht, &mlx5e_neigh_ht_params);
+	spin_lock_init(&neigh_update->encap_lock);
+
+	rpriv->neigh_update.netevent_nb.notifier_call = mlx5e_rep_netevent_event;
+	err = register_netevent_notifier(&rpriv->neigh_update.netevent_nb);
+	if (err)
+		goto out_err;
+	return 0;
+
+out_err:
+	rhashtable_destroy(&neigh_update->neigh_ht);
+	return err;
 }
 
 static void mlx5e_rep_neigh_cleanup(struct mlx5e_rep_priv *rpriv)
 {
 	struct mlx5e_neigh_update_table *neigh_update = &rpriv->neigh_update;
+	struct mlx5e_priv *priv = netdev_priv(rpriv->rep->netdev);
+
+	unregister_netevent_notifier(&neigh_update->netevent_nb);
+
+	flush_workqueue(priv->wq); /* flush neigh update works */
 
 	rhashtable_destroy(&neigh_update->neigh_ht);
 }
@@ -268,13 +424,19 @@ static void mlx5e_rep_neigh_entry_remove(struct mlx5e_priv *priv,
 {
 	struct mlx5e_rep_priv *rpriv = priv->ppriv;
 
+	spin_lock_bh(&rpriv->neigh_update.encap_lock);
+
 	list_del(&nhe->neigh_list);
 
 	rhashtable_remove_fast(&rpriv->neigh_update.neigh_ht,
 			       &nhe->rhash_node,
 			       mlx5e_neigh_ht_params);
+	spin_unlock_bh(&rpriv->neigh_update.encap_lock);
 }
 
+/* This function must only be called under RTNL lock or under the
+ * representor's encap_lock in case RTNL mutex can't be held.
+ */
 static struct mlx5e_neigh_hash_entry *
 mlx5e_rep_neigh_entry_lookup(struct mlx5e_priv *priv,
 			     struct mlx5e_neigh *m_neigh)
@@ -286,6 +448,72 @@ mlx5e_rep_neigh_entry_lookup(struct mlx5e_priv *priv,
 				      mlx5e_neigh_ht_params);
 }
 
+static int mlx5e_rep_neigh_entry_create(struct mlx5e_priv *priv,
+					struct mlx5e_encap_entry *e,
+					struct mlx5e_neigh_hash_entry **nhe)
+{
+	int err;
+
+	*nhe = kzalloc(sizeof(**nhe), GFP_KERNEL);
+	if (!*nhe)
+		return -ENOMEM;
+
+	memcpy(&(*nhe)->m_neigh, &e->m_neigh, sizeof(e->m_neigh));
+	INIT_WORK(&(*nhe)->neigh_update_work, mlx5e_rep_neigh_update);
+	INIT_LIST_HEAD(&(*nhe)->encap_list);
+	refcount_set(&(*nhe)->refcnt, 1);
+
+	err = mlx5e_rep_neigh_entry_insert(priv, *nhe);
+	if (err)
+		goto out_free;
+	return 0;
+
+out_free:
+	kfree(*nhe);
+	return err;
+}
+
+static void mlx5e_rep_neigh_entry_destroy(struct mlx5e_priv *priv,
+					  struct mlx5e_neigh_hash_entry *nhe)
+{
+	/* The neigh hash entry must be removed from the hash table regardless
+	 * of the reference count value, so it won't be found by the next
+	 * neigh notification call. The neigh hash entry reference count is
+	 * incremented only during creation and neigh notification calls and
+	 * protects from freeing the nhe struct.
+	 */
+	mlx5e_rep_neigh_entry_remove(priv, nhe);
+	mlx5e_rep_neigh_entry_release(nhe);
+}
+
+int mlx5e_rep_encap_entry_attach(struct mlx5e_priv *priv,
+				 struct mlx5e_encap_entry *e)
+{
+	struct mlx5e_neigh_hash_entry *nhe;
+	int err;
+
+	nhe = mlx5e_rep_neigh_entry_lookup(priv, &e->m_neigh);
+	if (!nhe) {
+		err = mlx5e_rep_neigh_entry_create(priv, e, &nhe);
+		if (err)
+			return err;
+	}
+	list_add(&e->encap_list, &nhe->encap_list);
+	return 0;
+}
+
+void mlx5e_rep_encap_entry_detach(struct mlx5e_priv *priv,
+				  struct mlx5e_encap_entry *e)
+{
+	struct mlx5e_neigh_hash_entry *nhe;
+
+	list_del(&e->encap_list);
+	nhe = mlx5e_rep_neigh_entry_lookup(priv, &e->m_neigh);
+
+	if (list_empty(&nhe->encap_list))
+		mlx5e_rep_neigh_entry_destroy(priv, nhe);
+}
+
 static int mlx5e_rep_open(struct net_device *dev)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.h b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.h
index 99f6b5f41070..e4d0ea5246fd 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.h
@@ -45,6 +45,9 @@ struct mlx5e_neigh_update_table {
 	 * Used for stats query.
 	 */
 	struct list_head	neigh_list;
+	/* protect lookup/remove operations */
+	spinlock_t              encap_lock;
+	struct notifier_block   netevent_nb;
 };
 
 struct mlx5e_rep_priv {
@@ -69,18 +72,46 @@ struct mlx5e_neigh_hash_entry {
 	 * neighbour entries. Used for stats query.
 	 */
 	struct list_head neigh_list;
+
+	/* encap list sharing the same neigh */
+	struct list_head encap_list;
+
+	/* valid only when the neigh reference is taken during
+	 * neigh_update_work workqueue callback.
+	 */
+	struct neighbour *n;
+	struct work_struct neigh_update_work;
+
+	/* neigh hash entry can be deleted only when the refcount is zero.
+	 * refcount is needed to avoid neigh hash entry removal by TC, while
+	 * it's used by the neigh notification call.
+	 */
+	refcount_t refcnt;
+};
+
+enum {
+	/* set when the encap entry is successfully offloaded into HW */
+	MLX5_ENCAP_ENTRY_VALID     = BIT(0),
 };
 
 struct mlx5e_encap_entry {
+	/* neigh hash entry list of encaps sharing the same neigh */
+	struct list_head encap_list;
+	struct mlx5e_neigh m_neigh;
+	/* a node of the eswitch encap hash table which keeping all the encap
+	 * entries
+	 */
 	struct hlist_node encap_hlist;
 	struct list_head flows;
 	u32 encap_id;
-	struct neighbour *n;
 	struct ip_tunnel_info tun_info;
 	unsigned char h_dest[ETH_ALEN];	/* destination eth addr	*/
 
 	struct net_device *out_dev;
 	int tunnel_type;
+	u8 flags;
+	char *encap_header;
+	int encap_size;
 };
 
 void mlx5e_register_vport_reps(struct mlx5e_priv *priv);
@@ -95,4 +126,9 @@ bool mlx5e_has_offload_stats(const struct net_device *dev, int attr_id);
 int mlx5e_attr_get(struct net_device *dev, struct switchdev_attr *attr);
 void mlx5e_handle_rx_cqe_rep(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe);
 
+int mlx5e_rep_encap_entry_attach(struct mlx5e_priv *priv,
+				 struct mlx5e_encap_entry *e);
+void mlx5e_rep_encap_entry_detach(struct mlx5e_priv *priv,
+				  struct mlx5e_encap_entry *e);
+
 #endif /* __MLX5E_REP_H__ */
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index ae07fe6473bb..624dbfe31a0e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -45,8 +45,8 @@
 #include <net/tc_act/tc_pedit.h>
 #include <net/vxlan.h>
 #include "en.h"
-#include "en_tc.h"
 #include "en_rep.h"
+#include "en_tc.h"
 #include "eswitch.h"
 #include "vxlan.h"
 
@@ -246,19 +246,75 @@ static void mlx5e_tc_del_fdb_flow(struct mlx5e_priv *priv,
 	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
 	struct mlx5_esw_flow_attr *attr = flow->esw_attr;
 
-	if (flow->flags & MLX5E_TC_FLOW_OFFLOADED)
+	if (flow->flags & MLX5E_TC_FLOW_OFFLOADED) {
+		flow->flags &= ~MLX5E_TC_FLOW_OFFLOADED;
 		mlx5_eswitch_del_offloaded_rule(esw, flow->rule, flow->esw_attr);
+	}
 
 	mlx5_eswitch_del_vlan_action(esw, flow->esw_attr);
 
-	if (flow->esw_attr->action & MLX5_FLOW_CONTEXT_ACTION_ENCAP)
+	if (flow->esw_attr->action & MLX5_FLOW_CONTEXT_ACTION_ENCAP) {
 		mlx5e_detach_encap(priv, flow);
+		kvfree(flow->esw_attr->parse_attr);
+	}
 
 	if (flow->esw_attr->action & MLX5_FLOW_CONTEXT_ACTION_MOD_HDR)
 		mlx5_modify_header_dealloc(priv->mdev,
 					   attr->mod_hdr_id);
 }
 
+void mlx5e_tc_encap_flows_add(struct mlx5e_priv *priv,
+			      struct mlx5e_encap_entry *e)
+{
+	struct mlx5e_tc_flow *flow;
+	int err;
+
+	err = mlx5_encap_alloc(priv->mdev, e->tunnel_type,
+			       e->encap_size, e->encap_header,
+			       &e->encap_id);
+	if (err) {
+		mlx5_core_warn(priv->mdev, "Failed to offload cached encapsulation header, %d\n",
+			       err);
+		return;
+	}
+	e->flags |= MLX5_ENCAP_ENTRY_VALID;
+
+	list_for_each_entry(flow, &e->flows, encap) {
+		flow->esw_attr->encap_id = e->encap_id;
+		flow->rule = mlx5e_tc_add_fdb_flow(priv,
+						   flow->esw_attr->parse_attr,
+						   flow);
+		if (IS_ERR(flow->rule)) {
+			err = PTR_ERR(flow->rule);
+			mlx5_core_warn(priv->mdev, "Failed to update cached encapsulation flow, %d\n",
+				       err);
+			continue;
+		}
+		flow->flags |= MLX5E_TC_FLOW_OFFLOADED;
+	}
+}
+
+void mlx5e_tc_encap_flows_del(struct mlx5e_priv *priv,
+			      struct mlx5e_encap_entry *e)
+{
+	struct mlx5e_tc_flow *flow;
+	struct mlx5_fc *counter;
+
+	list_for_each_entry(flow, &e->flows, encap) {
+		if (flow->flags & MLX5E_TC_FLOW_OFFLOADED) {
+			flow->flags &= ~MLX5E_TC_FLOW_OFFLOADED;
+			counter = mlx5_flow_rule_counter(flow->rule);
+			mlx5_del_flow_rules(flow->rule);
+			mlx5_fc_destroy(priv->mdev, counter);
+		}
+	}
+
+	if (e->flags & MLX5_ENCAP_ENTRY_VALID) {
+		e->flags &= ~MLX5_ENCAP_ENTRY_VALID;
+		mlx5_encap_dealloc(priv->mdev, e->encap_id);
+	}
+}
+
 static void mlx5e_detach_encap(struct mlx5e_priv *priv,
 			       struct mlx5e_tc_flow *flow)
 {
@@ -269,11 +325,13 @@ static void mlx5e_detach_encap(struct mlx5e_priv *priv,
 		struct mlx5e_encap_entry *e;
 
 		e = list_entry(next, struct mlx5e_encap_entry, flows);
-		if (e->n) {
+		mlx5e_rep_encap_entry_detach(netdev_priv(e->out_dev), e);
+
+		if (e->flags & MLX5_ENCAP_ENTRY_VALID)
 			mlx5_encap_dealloc(priv->mdev, e->encap_id);
-			neigh_release(e->n);
-		}
+
 		hlist_del_rcu(&e->encap_hlist);
+		kfree(e->encap_header);
 		kfree(e);
 	}
 }
@@ -1253,20 +1311,27 @@ static int mlx5e_create_encap_header_ipv4(struct mlx5e_priv *priv,
 	if (err)
 		goto out;
 
+	/* used by mlx5e_detach_encap to lookup a neigh hash table
+	 * entry in the neigh hash table when a user deletes a rule
+	 */
+	e->m_neigh.dev = n->dev;
+	memcpy(&e->m_neigh.dst_ip, n->primary_key, n->tbl->key_len);
+	e->out_dev = out_dev;
+
+	/* It's importent to add the neigh to the hash table before checking
+	 * the neigh validity state. So if we'll get a notification, in case the
+	 * neigh changes it's validity state, we would find the relevant neigh
+	 * in the hash.
+	 */
+	err = mlx5e_rep_encap_entry_attach(netdev_priv(out_dev), e);
+	if (err)
+		goto out;
+
 	read_lock_bh(&n->lock);
 	nud_state = n->nud_state;
 	ether_addr_copy(e->h_dest, n->ha);
 	read_unlock_bh(&n->lock);
 
-	if (!(nud_state & NUD_VALID)) {
-		pr_warn("%s: can't offload, neighbour to %pI4 invalid\n", __func__, &fl4.daddr);
-		err = -EOPNOTSUPP;
-		goto out;
-	}
-
-	e->n = n;
-	e->out_dev = out_dev;
-
 	switch (e->tunnel_type) {
 	case MLX5_HEADER_TYPE_VXLAN:
 		gen_vxlan_header_ipv4(out_dev, encap_header,
@@ -1277,15 +1342,32 @@ static int mlx5e_create_encap_header_ipv4(struct mlx5e_priv *priv,
 		break;
 	default:
 		err = -EOPNOTSUPP;
-		goto out;
+		goto destroy_neigh_entry;
+	}
+	e->encap_size = ipv4_encap_size;
+	e->encap_header = encap_header;
+
+	if (!(nud_state & NUD_VALID)) {
+		neigh_event_send(n, NULL);
+		neigh_release(n);
+		return -EAGAIN;
 	}
 
 	err = mlx5_encap_alloc(priv->mdev, e->tunnel_type,
 			       ipv4_encap_size, encap_header, &e->encap_id);
+	if (err)
+		goto destroy_neigh_entry;
+
+	e->flags |= MLX5_ENCAP_ENTRY_VALID;
+	neigh_release(n);
+	return err;
+
+destroy_neigh_entry:
+	mlx5e_rep_encap_entry_detach(netdev_priv(e->out_dev), e);
 out:
-	if (err && n)
-		neigh_release(n);
 	kfree(encap_header);
+	if (n)
+		neigh_release(n);
 	return err;
 }
 
@@ -1332,20 +1414,27 @@ static int mlx5e_create_encap_header_ipv6(struct mlx5e_priv *priv,
 	if (err)
 		goto out;
 
+	/* used by mlx5e_detach_encap to lookup a neigh hash table
+	 * entry in the neigh hash table when a user deletes a rule
+	 */
+	e->m_neigh.dev = n->dev;
+	memcpy(&e->m_neigh.dst_ip, n->primary_key, n->tbl->key_len);
+	e->out_dev = out_dev;
+
+	/* It's importent to add the neigh to the hash table before checking
+	 * the neigh validity state. So if we'll get a notification, in case the
+	 * neigh changes it's validity state, we would find the relevant neigh
+	 * in the hash.
+	 */
+	err = mlx5e_rep_encap_entry_attach(netdev_priv(out_dev), e);
+	if (err)
+		goto out;
+
 	read_lock_bh(&n->lock);
 	nud_state = n->nud_state;
 	ether_addr_copy(e->h_dest, n->ha);
 	read_unlock_bh(&n->lock);
 
-	if (!(nud_state & NUD_VALID)) {
-		pr_warn("%s: can't offload, neighbour to %pI6 invalid\n", __func__, &fl6.daddr);
-		err = -EOPNOTSUPP;
-		goto out;
-	}
-
-	e->n = n;
-	e->out_dev = out_dev;
-
 	switch (e->tunnel_type) {
 	case MLX5_HEADER_TYPE_VXLAN:
 		gen_vxlan_header_ipv6(out_dev, encap_header,
@@ -1356,15 +1445,33 @@ static int mlx5e_create_encap_header_ipv6(struct mlx5e_priv *priv,
 		break;
 	default:
 		err = -EOPNOTSUPP;
-		goto out;
+		goto destroy_neigh_entry;
+	}
+
+	e->encap_size = ipv6_encap_size;
+	e->encap_header = encap_header;
+
+	if (!(nud_state & NUD_VALID)) {
+		neigh_event_send(n, NULL);
+		neigh_release(n);
+		return -EAGAIN;
 	}
 
 	err = mlx5_encap_alloc(priv->mdev, e->tunnel_type,
 			       ipv6_encap_size, encap_header, &e->encap_id);
+	if (err)
+		goto destroy_neigh_entry;
+
+	e->flags |= MLX5_ENCAP_ENTRY_VALID;
+	neigh_release(n);
+	return err;
+
+destroy_neigh_entry:
+	mlx5e_rep_encap_entry_detach(netdev_priv(e->out_dev), e);
 out:
-	if (err && n)
-		neigh_release(n);
 	kfree(encap_header);
+	if (n)
+		neigh_release(n);
 	return err;
 }
 
@@ -1432,7 +1539,7 @@ static int mlx5e_attach_encap(struct mlx5e_priv *priv,
 	else if (family == AF_INET6)
 		err = mlx5e_create_encap_header_ipv6(priv, mirred_dev, e);
 
-	if (err)
+	if (err && err != -EAGAIN)
 		goto out_err;
 
 	hash_add_rcu(esw->offloads.encap_tbl, &e->encap_hlist, hash_key);
@@ -1440,9 +1547,10 @@ static int mlx5e_attach_encap(struct mlx5e_priv *priv,
 attach_flow:
 	list_add(&flow->encap, &e->flows);
 	*encap_dev = e->out_dev;
-	attr->encap_id = e->encap_id;
+	if (e->flags & MLX5_ENCAP_ENTRY_VALID)
+		attr->encap_id = e->encap_id;
 
-	return 0;
+	return err;
 
 out_err:
 	kfree(e);
@@ -1459,7 +1567,7 @@ static int parse_tc_fdb_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
 	const struct tc_action *a;
 	LIST_HEAD(actions);
 	bool encap = false;
-	int err;
+	int err = 0;
 
 	if (tc_no_actions(exts))
 		return -EINVAL;
@@ -1502,7 +1610,7 @@ static int parse_tc_fdb_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
 			} else if (encap) {
 				err = mlx5e_attach_encap(priv, info,
 							 out_dev, &encap_dev, flow);
-				if (err)
+				if (err && err != -EAGAIN)
 					return err;
 				attr->action |= MLX5_FLOW_CONTEXT_ACTION_ENCAP |
 					MLX5_FLOW_CONTEXT_ACTION_FWD_DEST |
@@ -1510,6 +1618,7 @@ static int parse_tc_fdb_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
 				out_priv = netdev_priv(encap_dev);
 				rpriv = out_priv->ppriv;
 				attr->out_rep = rpriv->rep;
+				attr->parse_attr = parse_attr;
 			} else {
 				pr_err("devices %s %s not on same switch HW, can't offload forwarding\n",
 				       priv->netdev->name, out_dev->name);
@@ -1549,7 +1658,7 @@ static int parse_tc_fdb_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
 
 		return -EINVAL;
 	}
-	return 0;
+	return err;
 }
 
 int mlx5e_configure_flower(struct mlx5e_priv *priv, __be16 protocol,
@@ -1587,7 +1696,7 @@ int mlx5e_configure_flower(struct mlx5e_priv *priv, __be16 protocol,
 	if (flow->flags & MLX5E_TC_FLOW_ESWITCH) {
 		err = parse_tc_fdb_actions(priv, f->exts, parse_attr, flow);
 		if (err < 0)
-			goto err_free;
+			goto err_handle_encap_flow;
 		flow->rule = mlx5e_tc_add_fdb_flow(priv, parse_attr, flow);
 	} else {
 		err = parse_tc_nic_actions(priv, f->exts, parse_attr, flow);
@@ -1607,15 +1716,27 @@ int mlx5e_configure_flower(struct mlx5e_priv *priv, __be16 protocol,
 	if (err)
 		goto err_del_rule;
 
-	goto out;
+	if (flow->flags & MLX5E_TC_FLOW_ESWITCH &&
+	    !(flow->esw_attr->action & MLX5_FLOW_CONTEXT_ACTION_ENCAP))
+		kvfree(parse_attr);
+	return err;
 
 err_del_rule:
 	mlx5e_tc_del_flow(priv, flow);
 
+err_handle_encap_flow:
+	if (err == -EAGAIN) {
+		err = rhashtable_insert_fast(&tc->ht, &flow->node,
+					     tc->ht_params);
+		if (err)
+			mlx5e_tc_del_flow(priv, flow);
+		else
+			return 0;
+	}
+
 err_free:
-	kfree(flow);
-out:
 	kvfree(parse_attr);
+	kfree(flow);
 	return err;
 }
 
@@ -1634,7 +1755,6 @@ int mlx5e_delete_flower(struct mlx5e_priv *priv,
 
 	mlx5e_tc_del_flow(priv, flow);
 
-
 	kfree(flow);
 
 	return 0;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.h b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.h
index 34bf903fc886..278c7a646a55 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.h
@@ -46,6 +46,12 @@ int mlx5e_delete_flower(struct mlx5e_priv *priv,
 int mlx5e_stats_flower(struct mlx5e_priv *priv,
 		       struct tc_cls_flower_offload *f);
 
+struct mlx5e_encap_entry;
+void mlx5e_tc_encap_flows_add(struct mlx5e_priv *priv,
+			      struct mlx5e_encap_entry *e);
+void mlx5e_tc_encap_flows_del(struct mlx5e_priv *priv,
+			      struct mlx5e_encap_entry *e);
+
 static inline int mlx5e_tc_num_filters(struct mlx5e_priv *priv)
 {
 	return atomic_read(&priv->fs.tc.ht.nelems);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
index 751a673de97a..55beda6bf134 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
@@ -297,6 +297,7 @@ struct mlx5_esw_flow_attr {
 	bool	vlan_handled;
 	u32	encap_id;
 	u32	mod_hdr_id;
+	struct mlx5e_tc_flow_parse_attr *parse_attr;
 };
 
 int mlx5_eswitch_sqs2vport_start(struct mlx5_eswitch *esw,
-- 
2.11.0
