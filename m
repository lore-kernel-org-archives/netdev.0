From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 09/15] net/mlx5e: Update neighbour 'used' state using HW flow rules counters
Date: Sun, 30 Apr 2017 16:20:10 +0300
Message-ID: <20170430132016.27012-10-saeedm@mellanox.com>
References: <20170430132016.27012-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen-Zion <hadarh@mellanox.com>,
        Ilya Lesokhin <ilyal@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:46744 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1756806AbdD3NU1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 09:20:27 -0400
In-Reply-To: <20170430132016.27012-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

When IP tunnel encapsulation rules are offloaded, the kernel can't see
the traffic of the offloaded flow. The neighbour for the IP tunnel
destination of the offloaded flow can mistakenly become STALE and
deleted by the kernel since its 'used' value wasn't changed.

To make sure that a neighbour which is used by the HW won't become
STALE, we proactively update the neighbour 'used' value every
DELAY_PROBE_TIME period, when packets were matched and counted by the HW
for one of the tunnel encap flows related to this neighbour.

The periodic task that updates the used neighbours is scheduled when a
tunnel encap rule is successfully offloaded into HW and keeps re-scheduling
itself as long as the representor's neighbours list isn't empty.

Add, remove, lookup and status change operations done over the
representor's neighbours list or the neighbour hash entry encaps list
are all serialized by RTNL lock.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c   | 52 +++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.h   | 11 ++++
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    | 58 ++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.h    |  3 ++
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h  |  5 ++
 .../net/ethernet/mellanox/mlx5/core/fs_counters.c  | 24 ++++++++-
 include/linux/mlx5/driver.h                        |  1 +
 7 files changed, 152 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
index 730de6b7e46e..af61b10b85bf 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -41,6 +41,7 @@
 #include "en.h"
 #include "en_rep.h"
 #include "en_tc.h"
+#include "fs_core.h"
 
 static const char mlx5e_rep_driver_name[] = "mlx5e_rep";
 
@@ -226,6 +227,51 @@ void mlx5e_remove_sqs_fwd_rules(struct mlx5e_priv *priv)
 	mlx5_eswitch_sqs2vport_stop(esw, rep);
 }
 
+static void mlx5e_rep_neigh_update_init_interval(struct mlx5e_rep_priv *rpriv)
+{
+#if IS_ENABLED(CONFIG_IPV6)
+	unsigned long ipv6_interval = NEIGH_VAR(&ipv6_stub->nd_tbl->parms,
+						DELAY_PROBE_TIME);
+#else
+	unsigned long ipv6_interval = ~0UL;
+#endif
+	unsigned long ipv4_interval = NEIGH_VAR(&arp_tbl.parms,
+						DELAY_PROBE_TIME);
+	struct net_device *netdev = rpriv->rep->netdev;
+	struct mlx5e_priv *priv = netdev_priv(netdev);
+
+	rpriv->neigh_update.min_interval = min_t(unsigned long, ipv6_interval, ipv4_interval);
+	mlx5_fc_update_sampling_interval(priv->mdev, rpriv->neigh_update.min_interval);
+}
+
+void mlx5e_rep_queue_neigh_stats_work(struct mlx5e_priv *priv)
+{
+	struct mlx5e_rep_priv *rpriv = priv->ppriv;
+	struct mlx5e_neigh_update_table *neigh_update = &rpriv->neigh_update;
+
+	mlx5_fc_queue_stats_work(priv->mdev,
+				 &neigh_update->neigh_stats_work,
+				 neigh_update->min_interval);
+}
+
+static void mlx5e_rep_neigh_stats_work(struct work_struct *work)
+{
+	struct mlx5e_rep_priv *rpriv = container_of(work, struct mlx5e_rep_priv,
+						    neigh_update.neigh_stats_work.work);
+	struct net_device *netdev = rpriv->rep->netdev;
+	struct mlx5e_priv *priv = netdev_priv(netdev);
+	struct mlx5e_neigh_hash_entry *nhe;
+
+	rtnl_lock();
+	if (!list_empty(&rpriv->neigh_update.neigh_list))
+		mlx5e_rep_queue_neigh_stats_work(priv);
+
+	list_for_each_entry(nhe, &rpriv->neigh_update.neigh_list, neigh_list)
+		mlx5e_tc_update_neigh_used_value(nhe);
+
+	rtnl_unlock();
+}
+
 static void mlx5e_rep_neigh_entry_hold(struct mlx5e_neigh_hash_entry *nhe)
 {
 	refcount_inc(&nhe->refcnt);
@@ -325,6 +371,7 @@ static int mlx5e_rep_netevent_event(struct notifier_block *nb,
 			return NOTIFY_DONE;
 
 		m_neigh.dev = n->dev;
+		m_neigh.family = n->ops->family;
 		memcpy(&m_neigh.dst_ip, n->primary_key, n->tbl->key_len);
 
 		/* We are in atomic context and can't take RTNL mutex, so use
@@ -378,6 +425,9 @@ static int mlx5e_rep_neigh_init(struct mlx5e_rep_priv *rpriv)
 
 	INIT_LIST_HEAD(&neigh_update->neigh_list);
 	spin_lock_init(&neigh_update->encap_lock);
+	INIT_DELAYED_WORK(&neigh_update->neigh_stats_work,
+			  mlx5e_rep_neigh_stats_work);
+	mlx5e_rep_neigh_update_init_interval(rpriv);
 
 	rpriv->neigh_update.netevent_nb.notifier_call = mlx5e_rep_netevent_event;
 	err = register_netevent_notifier(&rpriv->neigh_update.netevent_nb);
@@ -399,6 +449,8 @@ static void mlx5e_rep_neigh_cleanup(struct mlx5e_rep_priv *rpriv)
 
 	flush_workqueue(priv->wq); /* flush neigh update works */
 
+	cancel_delayed_work_sync(&rpriv->neigh_update.neigh_stats_work);
+
 	rhashtable_destroy(&neigh_update->neigh_ht);
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.h b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.h
index e4d0ea5246fd..a0a1a7a1d6c0 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.h
@@ -48,6 +48,8 @@ struct mlx5e_neigh_update_table {
 	/* protect lookup/remove operations */
 	spinlock_t              encap_lock;
 	struct notifier_block   netevent_nb;
+	struct delayed_work     neigh_stats_work;
+	unsigned long           min_interval; /* jiffies */
 };
 
 struct mlx5e_rep_priv {
@@ -61,6 +63,7 @@ struct mlx5e_neigh {
 		__be32	v4;
 		struct in6_addr v6;
 	} dst_ip;
+	int family;
 };
 
 struct mlx5e_neigh_hash_entry {
@@ -87,6 +90,12 @@ struct mlx5e_neigh_hash_entry {
 	 * it's used by the neigh notification call.
 	 */
 	refcount_t refcnt;
+
+	/* Save the last reported time offloaded trafic pass over one of the
+	 * neigh hash entry flows. Use it to periodically update the neigh
+	 * 'used' value and avoid neigh deleting by the kernel.
+	 */
+	unsigned long reported_lastuse;
 };
 
 enum {
@@ -131,4 +140,6 @@ int mlx5e_rep_encap_entry_attach(struct mlx5e_priv *priv,
 void mlx5e_rep_encap_entry_detach(struct mlx5e_priv *priv,
 				  struct mlx5e_encap_entry *e);
 
+void mlx5e_rep_queue_neigh_stats_work(struct mlx5e_priv *priv);
+
 #endif /* __MLX5E_REP_H__ */
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 624dbfe31a0e..11c27e4fadf6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -44,6 +44,7 @@
 #include <net/tc_act/tc_tunnel_key.h>
 #include <net/tc_act/tc_pedit.h>
 #include <net/vxlan.h>
+#include <net/arp.h>
 #include "en.h"
 #include "en_rep.h"
 #include "en_tc.h"
@@ -278,6 +279,7 @@ void mlx5e_tc_encap_flows_add(struct mlx5e_priv *priv,
 		return;
 	}
 	e->flags |= MLX5_ENCAP_ENTRY_VALID;
+	mlx5e_rep_queue_neigh_stats_work(priv);
 
 	list_for_each_entry(flow, &e->flows, encap) {
 		flow->esw_attr->encap_id = e->encap_id;
@@ -315,6 +317,58 @@ void mlx5e_tc_encap_flows_del(struct mlx5e_priv *priv,
 	}
 }
 
+void mlx5e_tc_update_neigh_used_value(struct mlx5e_neigh_hash_entry *nhe)
+{
+	struct mlx5e_neigh *m_neigh = &nhe->m_neigh;
+	u64 bytes, packets, lastuse = 0;
+	struct mlx5e_tc_flow *flow;
+	struct mlx5e_encap_entry *e;
+	struct mlx5_fc *counter;
+	struct neigh_table *tbl;
+	bool neigh_used = false;
+	struct neighbour *n;
+
+	if (m_neigh->family == AF_INET)
+		tbl = &arp_tbl;
+#if IS_ENABLED(CONFIG_IPV6)
+	else if (m_neigh->family == AF_INET6)
+		tbl = ipv6_stub->nd_tbl;
+#endif
+	else
+		return;
+
+	list_for_each_entry(e, &nhe->encap_list, encap_list) {
+		if (!(e->flags & MLX5_ENCAP_ENTRY_VALID))
+			continue;
+		list_for_each_entry(flow, &e->flows, encap) {
+			if (flow->flags & MLX5E_TC_FLOW_OFFLOADED) {
+				counter = mlx5_flow_rule_counter(flow->rule);
+				mlx5_fc_query_cached(counter, &bytes, &packets, &lastuse);
+				if (time_after((unsigned long)lastuse, nhe->reported_lastuse)) {
+					neigh_used = true;
+					break;
+				}
+			}
+		}
+	}
+
+	if (neigh_used) {
+		nhe->reported_lastuse = jiffies;
+
+		/* find the relevant neigh according to the cached device and
+		 * dst ip pair
+		 */
+		n = neigh_lookup(tbl, &m_neigh->dst_ip, m_neigh->dev);
+		if (!n) {
+			WARN(1, "The neighbour already freed\n");
+			return;
+		}
+
+		neigh_event_send(n, NULL);
+		neigh_release(n);
+	}
+}
+
 static void mlx5e_detach_encap(struct mlx5e_priv *priv,
 			       struct mlx5e_tc_flow *flow)
 {
@@ -1315,6 +1369,7 @@ static int mlx5e_create_encap_header_ipv4(struct mlx5e_priv *priv,
 	 * entry in the neigh hash table when a user deletes a rule
 	 */
 	e->m_neigh.dev = n->dev;
+	e->m_neigh.family = n->ops->family;
 	memcpy(&e->m_neigh.dst_ip, n->primary_key, n->tbl->key_len);
 	e->out_dev = out_dev;
 
@@ -1359,6 +1414,7 @@ static int mlx5e_create_encap_header_ipv4(struct mlx5e_priv *priv,
 		goto destroy_neigh_entry;
 
 	e->flags |= MLX5_ENCAP_ENTRY_VALID;
+	mlx5e_rep_queue_neigh_stats_work(netdev_priv(out_dev));
 	neigh_release(n);
 	return err;
 
@@ -1418,6 +1474,7 @@ static int mlx5e_create_encap_header_ipv6(struct mlx5e_priv *priv,
 	 * entry in the neigh hash table when a user deletes a rule
 	 */
 	e->m_neigh.dev = n->dev;
+	e->m_neigh.family = n->ops->family;
 	memcpy(&e->m_neigh.dst_ip, n->primary_key, n->tbl->key_len);
 	e->out_dev = out_dev;
 
@@ -1463,6 +1520,7 @@ static int mlx5e_create_encap_header_ipv6(struct mlx5e_priv *priv,
 		goto destroy_neigh_entry;
 
 	e->flags |= MLX5_ENCAP_ENTRY_VALID;
+	mlx5e_rep_queue_neigh_stats_work(netdev_priv(out_dev));
 	neigh_release(n);
 	return err;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.h b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.h
index 278c7a646a55..ecbe30d808ae 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.h
@@ -52,6 +52,9 @@ void mlx5e_tc_encap_flows_add(struct mlx5e_priv *priv,
 void mlx5e_tc_encap_flows_del(struct mlx5e_priv *priv,
 			      struct mlx5e_encap_entry *e);
 
+struct mlx5e_neigh_hash_entry;
+void mlx5e_tc_update_neigh_used_value(struct mlx5e_neigh_hash_entry *nhe);
+
 static inline int mlx5e_tc_num_filters(struct mlx5e_priv *priv)
 {
 	return atomic_read(&priv->fs.tc.ht.nelems);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
index 577d056bf3df..81eafc7b9dd9 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
@@ -199,6 +199,11 @@ struct mlx5_flow_root_namespace {
 
 int mlx5_init_fc_stats(struct mlx5_core_dev *dev);
 void mlx5_cleanup_fc_stats(struct mlx5_core_dev *dev);
+void mlx5_fc_queue_stats_work(struct mlx5_core_dev *dev,
+			      struct delayed_work *dwork,
+			      unsigned long delay);
+void mlx5_fc_update_sampling_interval(struct mlx5_core_dev *dev,
+				      unsigned long interval);
 
 int mlx5_init_fs(struct mlx5_core_dev *dev);
 void mlx5_cleanup_fs(struct mlx5_core_dev *dev);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_counters.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_counters.c
index 7431f633de31..6507d8acc54d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_counters.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_counters.c
@@ -165,7 +165,8 @@ static void mlx5_fc_stats_work(struct work_struct *work)
 	list_splice_tail_init(&fc_stats->addlist, &tmplist);
 
 	if (!list_empty(&tmplist) || !RB_EMPTY_ROOT(&fc_stats->counters))
-		queue_delayed_work(fc_stats->wq, &fc_stats->work, MLX5_FC_STATS_PERIOD);
+		queue_delayed_work(fc_stats->wq, &fc_stats->work,
+				   fc_stats->sampling_interval);
 
 	spin_unlock(&fc_stats->addlist_lock);
 
@@ -200,7 +201,7 @@ static void mlx5_fc_stats_work(struct work_struct *work)
 		node = mlx5_fc_stats_query(dev, counter, last->id);
 	}
 
-	fc_stats->next_query = now + MLX5_FC_STATS_PERIOD;
+	fc_stats->next_query = now + fc_stats->sampling_interval;
 }
 
 struct mlx5_fc *mlx5_fc_create(struct mlx5_core_dev *dev, bool aging)
@@ -265,6 +266,7 @@ int mlx5_init_fc_stats(struct mlx5_core_dev *dev)
 	if (!fc_stats->wq)
 		return -ENOMEM;
 
+	fc_stats->sampling_interval = MLX5_FC_STATS_PERIOD;
 	INIT_DELAYED_WORK(&fc_stats->work, mlx5_fc_stats_work);
 
 	return 0;
@@ -317,3 +319,21 @@ void mlx5_fc_query_cached(struct mlx5_fc *counter,
 	counter->lastbytes = c.bytes;
 	counter->lastpackets = c.packets;
 }
+
+void mlx5_fc_queue_stats_work(struct mlx5_core_dev *dev,
+			      struct delayed_work *dwork,
+			      unsigned long delay)
+{
+	struct mlx5_fc_stats *fc_stats = &dev->priv.fc_stats;
+
+	queue_delayed_work(fc_stats->wq, dwork, delay);
+}
+
+void mlx5_fc_update_sampling_interval(struct mlx5_core_dev *dev,
+				      unsigned long interval)
+{
+	struct mlx5_fc_stats *fc_stats = &dev->priv.fc_stats;
+
+	fc_stats->sampling_interval = min_t(unsigned long, interval,
+					    fc_stats->sampling_interval);
+}
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index f50864626230..3fece51dcf13 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -540,6 +540,7 @@ struct mlx5_fc_stats {
 	struct workqueue_struct *wq;
 	struct delayed_work work;
 	unsigned long next_query;
+	unsigned long sampling_interval; /* jiffies */
 };
 
 struct mlx5_eswitch;
-- 
2.11.0
