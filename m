From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-next 01/11] openvswitch: Move flow table rehashing to flow install.
Date: Tue, 29 Oct 2013 17:22:14 -0700
Message-ID: <1383092544-50599-2-git-send-email-jesse@nicira.com>
References: <1383092544-50599-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Pravin B Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog137.obsmtp.com ([74.125.149.18]:37832 "HELO
	na3sys009aog137.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752527Ab3J3AWc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 20:22:32 -0400
Received: by mail-pd0-f182.google.com with SMTP id q10so169503pdj.27
        for <netdev@vger.kernel.org>; Tue, 29 Oct 2013 17:22:32 -0700 (PDT)
In-Reply-To: <1383092544-50599-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>

Rehashing in ovs-workqueue can cause ovs-mutex lock contentions
in case of heavy flow setups where both needs ovs-mutex.  So by
moving rehashing to flow-setup we can eliminate contention.
This also simplify ovs locking and reduces dependence on
workqueue.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
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
