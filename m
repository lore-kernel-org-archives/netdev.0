From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 01/11] openvswitch: Move flow table
	rehashing to flow install.
Date: Sat,  2 Nov 2013 00:43:40 -0700
Message-ID: <1383378230-59624-2-git-send-email-jesse@nicira.com>
References: <1383378230-59624-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1383378230-59624-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
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

From: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>

Rehashing in ovs-workqueue can cause ovs-mutex lock contentions
in case of heavy flow setups where both needs ovs-mutex.  So by
moving rehashing to flow-setup we can eliminate contention.
This also simplify ovs locking and reduces dependence on
workqueue.

Signed-off-by: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/datapath.c | 50 ++++++++++------------------------------------
 net/openvswitch/datapath.h |  2 ++
 2 files changed, 13 insertions(+), 39 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 2aa13bd..2e1a9c2 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -60,8 +60,6 @@
 
 
 #define REHASH_FLOW_INTERVAL (10 * 60 * HZ)
-static void rehash_flow_table(struct work_struct *work);
-static DECLARE_DELAYED_WORK(rehash_flow_wq, rehash_flow_table);
 
 int ovs_net_id __read_mostly;
 
@@ -1289,22 +1287,25 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 	/* Check if this is a duplicate flow */
 	flow = ovs_flow_lookup(table, &key);
 	if (!flow) {
+		struct flow_table *new_table = NULL;
 		struct sw_flow_mask *mask_p;
+
 		/* Bail out if we're not allowed to create a new flow. */
 		error = -ENOENT;
 		if (info->genlhdr->cmd == OVS_FLOW_CMD_SET)
 			goto err_unlock_ovs;
 
 		/* Expand table, if necessary, to make room. */
-		if (ovs_flow_tbl_need_to_expand(table)) {
-			struct flow_table *new_table;
-
+		if (ovs_flow_tbl_need_to_expand(table))
 			new_table = ovs_flow_tbl_expand(table);
-			if (!IS_ERR(new_table)) {
-				rcu_assign_pointer(dp->table, new_table);
-				ovs_flow_tbl_destroy(table, true);
-				table = ovsl_dereference(dp->table);
-			}
+		else if (time_after(jiffies, dp->last_rehash + REHASH_FLOW_INTERVAL))
+			new_table = ovs_flow_tbl_rehash(table);
+
+		if (new_table && !IS_ERR(new_table)) {
+			rcu_assign_pointer(dp->table, new_table);
+			ovs_flow_tbl_destroy(table, true);
+			table = ovsl_dereference(dp->table);
+			dp->last_rehash = jiffies;
 		}
 
 		/* Allocate flow. */
@@ -2336,32 +2337,6 @@ error:
 	return err;
 }
 
-static void rehash_flow_table(struct work_struct *work)
-{
-	struct datapath *dp;
-	struct net *net;
-
-	ovs_lock();
-	rtnl_lock();
-	for_each_net(net) {
-		struct ovs_net *ovs_net = net_generic(net, ovs_net_id);
-
-		list_for_each_entry(dp, &ovs_net->dps, list_node) {
-			struct flow_table *old_table = ovsl_dereference(dp->table);
-			struct flow_table *new_table;
-
-			new_table = ovs_flow_tbl_rehash(old_table);
-			if (!IS_ERR(new_table)) {
-				rcu_assign_pointer(dp->table, new_table);
-				ovs_flow_tbl_destroy(old_table, true);
-			}
-		}
-	}
-	rtnl_unlock();
-	ovs_unlock();
-	schedule_delayed_work(&rehash_flow_wq, REHASH_FLOW_INTERVAL);
-}
-
 static int __net_init ovs_init_net(struct net *net)
 {
 	struct ovs_net *ovs_net = net_generic(net, ovs_net_id);
@@ -2419,8 +2394,6 @@ static int __init dp_init(void)
 	if (err < 0)
 		goto error_unreg_notifier;
 
-	schedule_delayed_work(&rehash_flow_wq, REHASH_FLOW_INTERVAL);
-
 	return 0;
 
 error_unreg_notifier:
@@ -2437,7 +2410,6 @@ error:
 
 static void dp_cleanup(void)
 {
-	cancel_delayed_work_sync(&rehash_flow_wq);
 	dp_unregister_genl(ARRAY_SIZE(dp_genl_families));
 	unregister_netdevice_notifier(&ovs_dp_device_notifier);
 	unregister_pernet_device(&ovs_net_ops);
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index 4d109c1..2c15541 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -62,6 +62,7 @@ struct dp_stats_percpu {
  * ovs_mutex and RCU.
  * @stats_percpu: Per-CPU datapath statistics.
  * @net: Reference to net namespace.
+ * @last_rehash: Timestamp of last rehash.
  *
  * Context: See the comment on locking at the top of datapath.c for additional
  * locking information.
@@ -83,6 +84,7 @@ struct datapath {
 	/* Network namespace ref. */
 	struct net *net;
 #endif
+	unsigned long last_rehash;
 };
 
 /**
-- 
1.8.3.2
