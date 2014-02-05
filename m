From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net 2/5] openvswitch: Fix kernel panic on
	ovs_flow_free
Date: Tue,  4 Feb 2014 22:59:18 -0800
Message-ID: <1391583561-25399-3-git-send-email-jesse@nicira.com>
References: <1391583561-25399-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1391583561-25399-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Andy Zhou <azhou-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>

Both mega flow mask's reference counter and per flow table mask list
should only be accessed when holding ovs_mutex() lock. However
this is not true with ovs_flow_table_flush(). The patch fixes this bug.

Reported-by: Joe Stringer <joestringer-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Andy Zhou <azhou-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/datapath.c   |  9 +++--
 net/openvswitch/flow_table.c | 84 +++++++++++++++++++++-----------------------
 net/openvswitch/flow_table.h |  2 +-
 3 files changed, 47 insertions(+), 48 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index d1a73a6..e1b337e 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -55,6 +55,7 @@
 
 #include "datapath.h"
 #include "flow.h"
+#include "flow_table.h"
 #include "flow_netlink.h"
 #include "vport-internal_dev.h"
 #include "vport-netdev.h"
@@ -160,7 +161,6 @@ static void destroy_dp_rcu(struct rcu_head *rcu)
 {
 	struct datapath *dp = container_of(rcu, struct datapath, rcu);
 
-	ovs_flow_tbl_destroy(&dp->table);
 	free_percpu(dp->stats_percpu);
 	release_net(ovs_dp_get_net(dp));
 	kfree(dp->ports);
@@ -1287,7 +1287,7 @@ err_destroy_ports_array:
 err_destroy_percpu:
 	free_percpu(dp->stats_percpu);
 err_destroy_table:
-	ovs_flow_tbl_destroy(&dp->table);
+	ovs_flow_tbl_destroy(&dp->table, false);
 err_free_dp:
 	release_net(ovs_dp_get_net(dp));
 	kfree(dp);
@@ -1314,10 +1314,13 @@ static void __dp_destroy(struct datapath *dp)
 	list_del_rcu(&dp->list_node);
 
 	/* OVSP_LOCAL is datapath internal port. We need to make sure that
-	 * all port in datapath are destroyed first before freeing datapath.
+	 * all ports in datapath are destroyed first before freeing datapath.
 	 */
 	ovs_dp_detach_port(ovs_vport_ovsl(dp, OVSP_LOCAL));
 
+	/* RCU destroy the flow table */
+	ovs_flow_tbl_destroy(&dp->table, true);
+
 	call_rcu(&dp->rcu, destroy_dp_rcu);
 }
 
diff --git a/net/openvswitch/flow_table.c b/net/openvswitch/flow_table.c
index c58a0fe..bd14052 100644
--- a/net/openvswitch/flow_table.c
+++ b/net/openvswitch/flow_table.c
@@ -153,29 +153,27 @@ static void rcu_free_flow_callback(struct rcu_head *rcu)
 	flow_free(flow);
 }
 
-static void flow_mask_del_ref(struct sw_flow_mask *mask, bool deferred)
+void ovs_flow_free(struct sw_flow *flow, bool deferred)
 {
-	if (!mask)
+	if (!flow)
 		return;
 
-	BUG_ON(!mask->ref_count);
-	mask->ref_count--;
+	ASSERT_OVSL();
 
-	if (!mask->ref_count) {
-		list_del_rcu(&mask->list);
-		if (deferred)
-			kfree_rcu(mask, rcu);
-		else
-			kfree(mask);
-	}
-}
+	if (flow->mask) {
+		struct sw_flow_mask *mask = flow->mask;
 
-void ovs_flow_free(struct sw_flow *flow, bool deferred)
-{
-	if (!flow)
-		return;
+		BUG_ON(!mask->ref_count);
+		mask->ref_count--;
 
-	flow_mask_del_ref(flow->mask, deferred);
+		if (!mask->ref_count) {
+			list_del_rcu(&mask->list);
+			if (deferred)
+				kfree_rcu(mask, rcu);
+			else
+				kfree(mask);
+		}
+	}
 
 	if (deferred)
 		call_rcu(&flow->rcu, rcu_free_flow_callback);
@@ -188,26 +186,9 @@ static void free_buckets(struct flex_array *buckets)
 	flex_array_free(buckets);
 }
 
+
 static void __table_instance_destroy(struct table_instance *ti)
 {
-	int i;
-
-	if (ti->keep_flows)
-		goto skip_flows;
-
-	for (i = 0; i < ti->n_buckets; i++) {
-		struct sw_flow *flow;
-		struct hlist_head *head = flex_array_get(ti->buckets, i);
-		struct hlist_node *n;
-		int ver = ti->node_ver;
-
-		hlist_for_each_entry_safe(flow, n, head, hash_node[ver]) {
-			hlist_del(&flow->hash_node[ver]);
-			ovs_flow_free(flow, false);
-		}
-	}
-
-skip_flows:
 	free_buckets(ti->buckets);
 	kfree(ti);
 }
@@ -258,20 +239,38 @@ static void flow_tbl_destroy_rcu_cb(struct rcu_head *rcu)
 
 static void table_instance_destroy(struct table_instance *ti, bool deferred)
 {
+	int i;
+
 	if (!ti)
 		return;
 
+	if (ti->keep_flows)
+		goto skip_flows;
+
+	for (i = 0; i < ti->n_buckets; i++) {
+		struct sw_flow *flow;
+		struct hlist_head *head = flex_array_get(ti->buckets, i);
+		struct hlist_node *n;
+		int ver = ti->node_ver;
+
+		hlist_for_each_entry_safe(flow, n, head, hash_node[ver]) {
+			hlist_del_rcu(&flow->hash_node[ver]);
+			ovs_flow_free(flow, deferred);
+		}
+	}
+
+skip_flows:
 	if (deferred)
 		call_rcu(&ti->rcu, flow_tbl_destroy_rcu_cb);
 	else
 		__table_instance_destroy(ti);
 }
 
-void ovs_flow_tbl_destroy(struct flow_table *table)
+void ovs_flow_tbl_destroy(struct flow_table *table, bool deferred)
 {
 	struct table_instance *ti = ovsl_dereference(table->ti);
 
-	table_instance_destroy(ti, false);
+	table_instance_destroy(ti, deferred);
 }
 
 struct sw_flow *ovs_flow_tbl_dump_next(struct table_instance *ti,
@@ -504,16 +503,11 @@ static struct sw_flow_mask *mask_alloc(void)
 
 	mask = kmalloc(sizeof(*mask), GFP_KERNEL);
 	if (mask)
-		mask->ref_count = 0;
+		mask->ref_count = 1;
 
 	return mask;
 }
 
-static void mask_add_ref(struct sw_flow_mask *mask)
-{
-	mask->ref_count++;
-}
-
 static bool mask_equal(const struct sw_flow_mask *a,
 		       const struct sw_flow_mask *b)
 {
@@ -554,9 +548,11 @@ static int flow_mask_insert(struct flow_table *tbl, struct sw_flow *flow,
 		mask->key = new->key;
 		mask->range = new->range;
 		list_add_rcu(&mask->list, &tbl->mask_list);
+	} else {
+		BUG_ON(!mask->ref_count);
+		mask->ref_count++;
 	}
 
-	mask_add_ref(mask);
 	flow->mask = mask;
 	return 0;
 }
diff --git a/net/openvswitch/flow_table.h b/net/openvswitch/flow_table.h
index 1996e34..baaeb10 100644
--- a/net/openvswitch/flow_table.h
+++ b/net/openvswitch/flow_table.h
@@ -60,7 +60,7 @@ void ovs_flow_free(struct sw_flow *, bool deferred);
 
 int ovs_flow_tbl_init(struct flow_table *);
 int ovs_flow_tbl_count(struct flow_table *table);
-void ovs_flow_tbl_destroy(struct flow_table *table);
+void ovs_flow_tbl_destroy(struct flow_table *table, bool deferred);
 int ovs_flow_tbl_flush(struct flow_table *flow_table);
 
 int ovs_flow_tbl_insert(struct flow_table *table, struct sw_flow *flow,
-- 
1.8.3.2
