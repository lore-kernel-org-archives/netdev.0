From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-next 09/10] openvswitch: Simplify datapath locking.
Date: Tue, 16 Apr 2013 14:00:18 -0700
Message-ID: <1366146019-9015-10-git-send-email-jesse@nicira.com>
References: <1366146019-9015-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Pravin B Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog129.obsmtp.com ([74.125.149.142]:58587 "HELO
	na3sys009aog129.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S965290Ab3DPVAb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 17:00:31 -0400
Received: by mail-pb0-f69.google.com with SMTP id jt11so728964pbb.4
        for <netdev@vger.kernel.org>; Tue, 16 Apr 2013 14:00:25 -0700 (PDT)
In-Reply-To: <1366146019-9015-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>

Currently OVS uses combination of genl and rtnl lock to protect
datapath state.  This was done due to networking stack locking.
But this has complicated locking and there are few lock ordering
issues with new tunneling protocols.
Following patch simplifies locking by introducing new ovs mutex
and now this lock is used to protect entire ovs state.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 net/openvswitch/datapath.c           |  274 +++++++++++++++++++++-------------
 net/openvswitch/datapath.h           |   69 ++++++---
 net/openvswitch/dp_notify.c          |   82 ++++++----
 net/openvswitch/vport-internal_dev.c |    6 +
 net/openvswitch/vport-netdev.c       |    8 +-
 net/openvswitch/vport.c              |   22 ++-
 net/openvswitch/vport.h              |    4 +-
 7 files changed, 298 insertions(+), 167 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index d406503..b7d0b7c 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -44,6 +44,7 @@
 #include <linux/netfilter_ipv4.h>
 #include <linux/inetdevice.h>
 #include <linux/list.h>
+#include <linux/lockdep.h>
 #include <linux/openvswitch.h>
 #include <linux/rculist.h>
 #include <linux/dmi.h>
@@ -56,21 +57,13 @@
 #include "flow.h"
 #include "vport-internal_dev.h"
 
-/**
- * struct ovs_net - Per net-namespace data for ovs.
- * @dps: List of datapaths to enable dumping them all out.
- * Protected by genl_mutex.
- */
-struct ovs_net {
-	struct list_head dps;
-};
-
-static int ovs_net_id __read_mostly;
 
 #define REHASH_FLOW_INTERVAL (10 * 60 * HZ)
 static void rehash_flow_table(struct work_struct *work);
 static DECLARE_DELAYED_WORK(rehash_flow_wq, rehash_flow_table);
 
+int ovs_net_id __read_mostly;
+
 static void ovs_notify(struct sk_buff *skb, struct genl_info *info,
 		       struct genl_multicast_group *grp)
 {
@@ -81,20 +74,42 @@ static void ovs_notify(struct sk_buff *skb, struct genl_info *info,
 /**
  * DOC: Locking:
  *
- * Writes to device state (add/remove datapath, port, set operations on vports,
- * etc.) are protected by RTNL.
- *
- * Writes to other state (flow table modifications, set miscellaneous datapath
- * parameters, etc.) are protected by genl_mutex.  The RTNL lock nests inside
- * genl_mutex.
+ * All writes e.g. Writes to device state (add/remove datapath, port, set
+ * operations on vports, etc.), Writes to other state (flow table
+ * modifications, set miscellaneous datapath parameters, etc.) are protected
+ * by ovs_lock.
  *
  * Reads are protected by RCU.
  *
  * There are a few special cases (mostly stats) that have their own
  * synchronization but they nest under all of above and don't interact with
  * each other.
+ *
+ * The RTNL lock nests inside ovs_mutex.
  */
 
+static DEFINE_MUTEX(ovs_mutex);
+
+void ovs_lock(void)
+{
+	mutex_lock(&ovs_mutex);
+}
+
+void ovs_unlock(void)
+{
+	mutex_unlock(&ovs_mutex);
+}
+
+#ifdef CONFIG_LOCKDEP
+int lockdep_ovsl_is_held(void)
+{
+	if (debug_locks)
+		return lockdep_is_held(&ovs_mutex);
+	else
+		return 1;
+}
+#endif
+
 static struct vport *new_vport(const struct vport_parms *);
 static int queue_gso_packets(struct net *, int dp_ifindex, struct sk_buff *,
 			     const struct dp_upcall_info *);
@@ -102,7 +117,7 @@ static int queue_userspace_packet(struct net *, int dp_ifindex,
 				  struct sk_buff *,
 				  const struct dp_upcall_info *);
 
-/* Must be called with rcu_read_lock, genl_mutex, or RTNL lock. */
+/* Must be called with rcu_read_lock or ovs_mutex. */
 static struct datapath *get_dp(struct net *net, int dp_ifindex)
 {
 	struct datapath *dp = NULL;
@@ -120,10 +135,10 @@ static struct datapath *get_dp(struct net *net, int dp_ifindex)
 	return dp;
 }
 
-/* Must be called with rcu_read_lock or RTNL lock. */
+/* Must be called with rcu_read_lock or ovs_mutex. */
 const char *ovs_dp_name(const struct datapath *dp)
 {
-	struct vport *vport = ovs_vport_rtnl_rcu(dp, OVSP_LOCAL);
+	struct vport *vport = ovs_vport_ovsl_rcu(dp, OVSP_LOCAL);
 	return vport->ops->get_name(vport);
 }
 
@@ -175,7 +190,7 @@ struct vport *ovs_lookup_vport(const struct datapath *dp, u16 port_no)
 	return NULL;
 }
 
-/* Called with RTNL lock and genl_lock. */
+/* Called with ovs_mutex. */
 static struct vport *new_vport(const struct vport_parms *parms)
 {
 	struct vport *vport;
@@ -187,14 +202,12 @@ static struct vport *new_vport(const struct vport_parms *parms)
 
 		hlist_add_head_rcu(&vport->dp_hash_node, head);
 	}
-
 	return vport;
 }
 
-/* Called with RTNL lock. */
 void ovs_dp_detach_port(struct vport *p)
 {
-	ASSERT_RTNL();
+	ASSERT_OVSL();
 
 	/* First drop references to device. */
 	hlist_del_rcu(&p->dp_hash_node);
@@ -432,13 +445,13 @@ out:
 	return err;
 }
 
-/* Called with genl_mutex. */
+/* Called with ovs_mutex. */
 static int flush_flows(struct datapath *dp)
 {
 	struct flow_table *old_table;
 	struct flow_table *new_table;
 
-	old_table = genl_dereference(dp->table);
+	old_table = ovsl_dereference(dp->table);
 	new_table = ovs_flow_tbl_alloc(TBL_MIN_BUCKETS);
 	if (!new_table)
 		return -ENOMEM;
@@ -788,7 +801,7 @@ static struct genl_ops dp_packet_genl_ops[] = {
 static void get_dp_stats(struct datapath *dp, struct ovs_dp_stats *stats)
 {
 	int i;
-	struct flow_table *table = genl_dereference(dp->table);
+	struct flow_table *table = ovsl_dereference(dp->table);
 
 	stats->n_flows = ovs_flow_tbl_count(table);
 
@@ -840,7 +853,7 @@ static size_t ovs_flow_cmd_msg_size(const struct sw_flow_actions *acts)
 		+ nla_total_size(acts->actions_len); /* OVS_FLOW_ATTR_ACTIONS */
 }
 
-/* Called with genl_lock. */
+/* Called with ovs_mutex. */
 static int ovs_flow_cmd_fill_info(struct sw_flow *flow, struct datapath *dp,
 				  struct sk_buff *skb, u32 portid,
 				  u32 seq, u32 flags, u8 cmd)
@@ -854,8 +867,7 @@ static int ovs_flow_cmd_fill_info(struct sw_flow *flow, struct datapath *dp,
 	u8 tcp_flags;
 	int err;
 
-	sf_acts = rcu_dereference_protected(flow->sf_acts,
-					    lockdep_genl_is_held());
+	sf_acts = ovsl_dereference(flow->sf_acts);
 
 	ovs_header = genlmsg_put(skb, portid, seq, &dp_flow_genl_family, flags, cmd);
 	if (!ovs_header)
@@ -919,8 +931,7 @@ static struct sk_buff *ovs_flow_cmd_alloc_info(struct sw_flow *flow)
 {
 	const struct sw_flow_actions *sf_acts;
 
-	sf_acts = rcu_dereference_protected(flow->sf_acts,
-					    lockdep_genl_is_held());
+	sf_acts = ovsl_dereference(flow->sf_acts);
 
 	return genlmsg_new(ovs_flow_cmd_msg_size(sf_acts), GFP_KERNEL);
 }
@@ -971,12 +982,13 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 		goto error;
 	}
 
+	ovs_lock();
 	dp = get_dp(sock_net(skb->sk), ovs_header->dp_ifindex);
 	error = -ENODEV;
 	if (!dp)
-		goto error;
+		goto err_unlock_ovs;
 
-	table = genl_dereference(dp->table);
+	table = ovsl_dereference(dp->table);
 	flow = ovs_flow_tbl_lookup(table, &key, key_len);
 	if (!flow) {
 		struct sw_flow_actions *acts;
@@ -984,7 +996,7 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 		/* Bail out if we're not allowed to create a new flow. */
 		error = -ENOENT;
 		if (info->genlhdr->cmd == OVS_FLOW_CMD_SET)
-			goto error;
+			goto err_unlock_ovs;
 
 		/* Expand table, if necessary, to make room. */
 		if (ovs_flow_tbl_need_to_expand(table)) {
@@ -994,7 +1006,7 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 			if (!IS_ERR(new_table)) {
 				rcu_assign_pointer(dp->table, new_table);
 				ovs_flow_tbl_deferred_destroy(table);
-				table = genl_dereference(dp->table);
+				table = ovsl_dereference(dp->table);
 			}
 		}
 
@@ -1002,7 +1014,7 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 		flow = ovs_flow_alloc();
 		if (IS_ERR(flow)) {
 			error = PTR_ERR(flow);
-			goto error;
+			goto err_unlock_ovs;
 		}
 		flow->key = key;
 		clear_stats(flow);
@@ -1035,11 +1047,10 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 		error = -EEXIST;
 		if (info->genlhdr->cmd == OVS_FLOW_CMD_NEW &&
 		    info->nlhdr->nlmsg_flags & (NLM_F_CREATE | NLM_F_EXCL))
-			goto error;
+			goto err_unlock_ovs;
 
 		/* Update actions. */
-		old_acts = rcu_dereference_protected(flow->sf_acts,
-						     lockdep_genl_is_held());
+		old_acts = ovsl_dereference(flow->sf_acts);
 		acts_attrs = a[OVS_FLOW_ATTR_ACTIONS];
 		if (acts_attrs &&
 		   (old_acts->actions_len != nla_len(acts_attrs) ||
@@ -1050,7 +1061,7 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 			new_acts = ovs_flow_actions_alloc(acts_attrs);
 			error = PTR_ERR(new_acts);
 			if (IS_ERR(new_acts))
-				goto error;
+				goto err_unlock_ovs;
 
 			rcu_assign_pointer(flow->sf_acts, new_acts);
 			ovs_flow_deferred_free_acts(old_acts);
@@ -1066,6 +1077,7 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 			spin_unlock_bh(&flow->lock);
 		}
 	}
+	ovs_unlock();
 
 	if (!IS_ERR(reply))
 		ovs_notify(reply, info, &ovs_dp_flow_multicast_group);
@@ -1076,6 +1088,8 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 
 error_free_flow:
 	ovs_flow_free(flow);
+err_unlock_ovs:
+	ovs_unlock();
 error:
 	return error;
 }
@@ -1098,21 +1112,32 @@ static int ovs_flow_cmd_get(struct sk_buff *skb, struct genl_info *info)
 	if (err)
 		return err;
 
+	ovs_lock();
 	dp = get_dp(sock_net(skb->sk), ovs_header->dp_ifindex);
-	if (!dp)
-		return -ENODEV;
+	if (!dp) {
+		err = -ENODEV;
+		goto unlock;
+	}
 
-	table = genl_dereference(dp->table);
+	table = ovsl_dereference(dp->table);
 	flow = ovs_flow_tbl_lookup(table, &key, key_len);
-	if (!flow)
-		return -ENOENT;
+	if (!flow) {
+		err = -ENOENT;
+		goto unlock;
+	}
 
 	reply = ovs_flow_cmd_build_info(flow, dp, info->snd_portid,
 					info->snd_seq, OVS_FLOW_CMD_NEW);
-	if (IS_ERR(reply))
-		return PTR_ERR(reply);
+	if (IS_ERR(reply)) {
+		err = PTR_ERR(reply);
+		goto unlock;
+	}
 
+	ovs_unlock();
 	return genlmsg_reply(reply, info);
+unlock:
+	ovs_unlock();
+	return err;
 }
 
 static int ovs_flow_cmd_del(struct sk_buff *skb, struct genl_info *info)
@@ -1127,25 +1152,33 @@ static int ovs_flow_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	int err;
 	int key_len;
 
+	ovs_lock();
 	dp = get_dp(sock_net(skb->sk), ovs_header->dp_ifindex);
-	if (!dp)
-		return -ENODEV;
-
-	if (!a[OVS_FLOW_ATTR_KEY])
-		return flush_flows(dp);
+	if (!dp) {
+		err = -ENODEV;
+		goto unlock;
+	}
 
+	if (!a[OVS_FLOW_ATTR_KEY]) {
+		err = flush_flows(dp);
+		goto unlock;
+	}
 	err = ovs_flow_from_nlattrs(&key, &key_len, a[OVS_FLOW_ATTR_KEY]);
 	if (err)
-		return err;
+		goto unlock;
 
-	table = genl_dereference(dp->table);
+	table = ovsl_dereference(dp->table);
 	flow = ovs_flow_tbl_lookup(table, &key, key_len);
-	if (!flow)
-		return -ENOENT;
+	if (!flow) {
+		err = -ENOENT;
+		goto unlock;
+	}
 
 	reply = ovs_flow_cmd_alloc_info(flow);
-	if (!reply)
-		return -ENOMEM;
+	if (!reply) {
+		err = -ENOMEM;
+		goto unlock;
+	}
 
 	ovs_flow_tbl_remove(table, flow);
 
@@ -1154,9 +1187,13 @@ static int ovs_flow_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	BUG_ON(err < 0);
 
 	ovs_flow_deferred_free(flow);
+	ovs_unlock();
 
 	ovs_notify(reply, info, &ovs_dp_flow_multicast_group);
 	return 0;
+unlock:
+	ovs_unlock();
+	return err;
 }
 
 static int ovs_flow_cmd_dump(struct sk_buff *skb, struct netlink_callback *cb)
@@ -1165,11 +1202,14 @@ static int ovs_flow_cmd_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	struct datapath *dp;
 	struct flow_table *table;
 
+	ovs_lock();
 	dp = get_dp(sock_net(skb->sk), ovs_header->dp_ifindex);
-	if (!dp)
+	if (!dp) {
+		ovs_unlock();
 		return -ENODEV;
+	}
 
-	table = genl_dereference(dp->table);
+	table = ovsl_dereference(dp->table);
 
 	for (;;) {
 		struct sw_flow *flow;
@@ -1190,6 +1230,7 @@ static int ovs_flow_cmd_dump(struct sk_buff *skb, struct netlink_callback *cb)
 		cb->args[0] = bucket;
 		cb->args[1] = obj;
 	}
+	ovs_unlock();
 	return skb->len;
 }
 
@@ -1295,7 +1336,7 @@ static struct sk_buff *ovs_dp_cmd_build_info(struct datapath *dp, u32 portid,
 	return skb;
 }
 
-/* Called with genl_mutex and optionally with RTNL lock also. */
+/* Called with ovs_mutex. */
 static struct datapath *lookup_datapath(struct net *net,
 					struct ovs_header *ovs_header,
 					struct nlattr *a[OVS_DP_ATTR_MAX + 1])
@@ -1329,12 +1370,12 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 	if (!a[OVS_DP_ATTR_NAME] || !a[OVS_DP_ATTR_UPCALL_PID])
 		goto err;
 
-	rtnl_lock();
+	ovs_lock();
 
 	err = -ENOMEM;
 	dp = kzalloc(sizeof(*dp), GFP_KERNEL);
 	if (dp == NULL)
-		goto err_unlock_rtnl;
+		goto err_unlock_ovs;
 
 	ovs_dp_set_net(dp, hold_net(sock_net(skb->sk)));
 
@@ -1385,35 +1426,34 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 
 	ovs_net = net_generic(ovs_dp_get_net(dp), ovs_net_id);
 	list_add_tail(&dp->list_node, &ovs_net->dps);
-	rtnl_unlock();
+
+	ovs_unlock();
 
 	ovs_notify(reply, info, &ovs_dp_datapath_multicast_group);
 	return 0;
 
 err_destroy_local_port:
-	ovs_dp_detach_port(ovs_vport_rtnl(dp, OVSP_LOCAL));
+	ovs_dp_detach_port(ovs_vport_ovsl(dp, OVSP_LOCAL));
 err_destroy_ports_array:
 	kfree(dp->ports);
 err_destroy_percpu:
 	free_percpu(dp->stats_percpu);
 err_destroy_table:
-	ovs_flow_tbl_destroy(genl_dereference(dp->table));
+	ovs_flow_tbl_destroy(ovsl_dereference(dp->table));
 err_free_dp:
 	release_net(ovs_dp_get_net(dp));
 	kfree(dp);
-err_unlock_rtnl:
-	rtnl_unlock();
+err_unlock_ovs:
+	ovs_unlock();
 err:
 	return err;
 }
 
-/* Called with genl_mutex. */
+/* Called with ovs_mutex. */
 static void __dp_destroy(struct datapath *dp)
 {
 	int i;
 
-	rtnl_lock();
-
 	for (i = 0; i < DP_VPORT_HASH_BUCKETS; i++) {
 		struct vport *vport;
 		struct hlist_node *n;
@@ -1424,14 +1464,11 @@ static void __dp_destroy(struct datapath *dp)
 	}
 
 	list_del(&dp->list_node);
-	ovs_dp_detach_port(ovs_vport_rtnl(dp, OVSP_LOCAL));
 
-	/* rtnl_unlock() will wait until all the references to devices that
-	 * are pending unregistration have been dropped.  We do it here to
-	 * ensure that any internal devices (which contain DP pointers) are
-	 * fully destroyed before freeing the datapath.
+	/* OVSP_LOCAL is datapath internal port. We need to make sure that
+	 * all port in datapath are destroyed first before freeing datapath.
 	 */
-	rtnl_unlock();
+	ovs_dp_detach_port(ovs_vport_ovsl(dp, OVSP_LOCAL));
 
 	call_rcu(&dp->rcu, destroy_dp_rcu);
 }
@@ -1442,22 +1479,27 @@ static int ovs_dp_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	struct datapath *dp;
 	int err;
 
+	ovs_lock();
 	dp = lookup_datapath(sock_net(skb->sk), info->userhdr, info->attrs);
 	err = PTR_ERR(dp);
 	if (IS_ERR(dp))
-		return err;
+		goto unlock;
 
 	reply = ovs_dp_cmd_build_info(dp, info->snd_portid,
 				      info->snd_seq, OVS_DP_CMD_DEL);
 	err = PTR_ERR(reply);
 	if (IS_ERR(reply))
-		return err;
+		goto unlock;
 
 	__dp_destroy(dp);
+	ovs_unlock();
 
 	ovs_notify(reply, info, &ovs_dp_datapath_multicast_group);
 
 	return 0;
+unlock:
+	ovs_unlock();
+	return err;
 }
 
 static int ovs_dp_cmd_set(struct sk_buff *skb, struct genl_info *info)
@@ -1466,9 +1508,11 @@ static int ovs_dp_cmd_set(struct sk_buff *skb, struct genl_info *info)
 	struct datapath *dp;
 	int err;
 
+	ovs_lock();
 	dp = lookup_datapath(sock_net(skb->sk), info->userhdr, info->attrs);
+	err = PTR_ERR(dp);
 	if (IS_ERR(dp))
-		return PTR_ERR(dp);
+		goto unlock;
 
 	reply = ovs_dp_cmd_build_info(dp, info->snd_portid,
 				      info->snd_seq, OVS_DP_CMD_NEW);
@@ -1476,29 +1520,45 @@ static int ovs_dp_cmd_set(struct sk_buff *skb, struct genl_info *info)
 		err = PTR_ERR(reply);
 		netlink_set_err(sock_net(skb->sk)->genl_sock, 0,
 				ovs_dp_datapath_multicast_group.id, err);
-		return 0;
+		err = 0;
+		goto unlock;
 	}
 
+	ovs_unlock();
 	ovs_notify(reply, info, &ovs_dp_datapath_multicast_group);
 
 	return 0;
+unlock:
+	ovs_unlock();
+	return err;
 }
 
 static int ovs_dp_cmd_get(struct sk_buff *skb, struct genl_info *info)
 {
 	struct sk_buff *reply;
 	struct datapath *dp;
+	int err;
 
+	ovs_lock();
 	dp = lookup_datapath(sock_net(skb->sk), info->userhdr, info->attrs);
-	if (IS_ERR(dp))
-		return PTR_ERR(dp);
+	if (IS_ERR(dp)) {
+		err = PTR_ERR(dp);
+		goto unlock;
+	}
 
 	reply = ovs_dp_cmd_build_info(dp, info->snd_portid,
 				      info->snd_seq, OVS_DP_CMD_NEW);
-	if (IS_ERR(reply))
-		return PTR_ERR(reply);
+	if (IS_ERR(reply)) {
+		err = PTR_ERR(reply);
+		goto unlock;
+	}
 
+	ovs_unlock();
 	return genlmsg_reply(reply, info);
+
+unlock:
+	ovs_unlock();
+	return err;
 }
 
 static int ovs_dp_cmd_dump(struct sk_buff *skb, struct netlink_callback *cb)
@@ -1508,6 +1568,7 @@ static int ovs_dp_cmd_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	int skip = cb->args[0];
 	int i = 0;
 
+	ovs_lock();
 	list_for_each_entry(dp, &ovs_net->dps, list_node) {
 		if (i >= skip &&
 		    ovs_dp_cmd_fill_info(dp, skb, NETLINK_CB(cb->skb).portid,
@@ -1516,6 +1577,7 @@ static int ovs_dp_cmd_dump(struct sk_buff *skb, struct netlink_callback *cb)
 			break;
 		i++;
 	}
+	ovs_unlock();
 
 	cb->args[0] = i;
 
@@ -1568,7 +1630,7 @@ struct genl_multicast_group ovs_dp_vport_multicast_group = {
 	.name = OVS_VPORT_MCGROUP
 };
 
-/* Called with RTNL lock or RCU read lock. */
+/* Called with ovs_mutex or RCU read lock. */
 static int ovs_vport_cmd_fill_info(struct vport *vport, struct sk_buff *skb,
 				   u32 portid, u32 seq, u32 flags, u8 cmd)
 {
@@ -1607,7 +1669,7 @@ error:
 	return err;
 }
 
-/* Called with RTNL lock or RCU read lock. */
+/* Called with ovs_mutex or RCU read lock. */
 struct sk_buff *ovs_vport_cmd_build_info(struct vport *vport, u32 portid,
 					 u32 seq, u8 cmd)
 {
@@ -1626,7 +1688,7 @@ struct sk_buff *ovs_vport_cmd_build_info(struct vport *vport, u32 portid,
 	return skb;
 }
 
-/* Called with RTNL lock or RCU read lock. */
+/* Called with ovs_mutex or RCU read lock. */
 static struct vport *lookup_vport(struct net *net,
 				  struct ovs_header *ovs_header,
 				  struct nlattr *a[OVS_VPORT_ATTR_MAX + 1])
@@ -1652,7 +1714,7 @@ static struct vport *lookup_vport(struct net *net,
 		if (!dp)
 			return ERR_PTR(-ENODEV);
 
-		vport = ovs_vport_rtnl_rcu(dp, port_no);
+		vport = ovs_vport_ovsl_rcu(dp, port_no);
 		if (!vport)
 			return ERR_PTR(-ENODEV);
 		return vport;
@@ -1676,7 +1738,7 @@ static int ovs_vport_cmd_new(struct sk_buff *skb, struct genl_info *info)
 	    !a[OVS_VPORT_ATTR_UPCALL_PID])
 		goto exit;
 
-	rtnl_lock();
+	ovs_lock();
 	dp = get_dp(sock_net(skb->sk), ovs_header->dp_ifindex);
 	err = -ENODEV;
 	if (!dp)
@@ -1689,7 +1751,7 @@ static int ovs_vport_cmd_new(struct sk_buff *skb, struct genl_info *info)
 		if (port_no >= DP_MAX_PORTS)
 			goto exit_unlock;
 
-		vport = ovs_vport_rtnl_rcu(dp, port_no);
+		vport = ovs_vport_ovsl(dp, port_no);
 		err = -EBUSY;
 		if (vport)
 			goto exit_unlock;
@@ -1699,7 +1761,7 @@ static int ovs_vport_cmd_new(struct sk_buff *skb, struct genl_info *info)
 				err = -EFBIG;
 				goto exit_unlock;
 			}
-			vport = ovs_vport_rtnl(dp, port_no);
+			vport = ovs_vport_ovsl(dp, port_no);
 			if (!vport)
 				break;
 		}
@@ -1729,7 +1791,7 @@ static int ovs_vport_cmd_new(struct sk_buff *skb, struct genl_info *info)
 	ovs_notify(reply, info, &ovs_dp_vport_multicast_group);
 
 exit_unlock:
-	rtnl_unlock();
+	ovs_unlock();
 exit:
 	return err;
 }
@@ -1741,7 +1803,7 @@ static int ovs_vport_cmd_set(struct sk_buff *skb, struct genl_info *info)
 	struct vport *vport;
 	int err;
 
-	rtnl_lock();
+	ovs_lock();
 	vport = lookup_vport(sock_net(skb->sk), info->userhdr, a);
 	err = PTR_ERR(vport);
 	if (IS_ERR(vport))
@@ -1767,10 +1829,12 @@ static int ovs_vport_cmd_set(struct sk_buff *skb, struct genl_info *info)
 		goto exit_unlock;
 	}
 
+	ovs_unlock();
 	ovs_notify(reply, info, &ovs_dp_vport_multicast_group);
+	return 0;
 
 exit_unlock:
-	rtnl_unlock();
+	ovs_unlock();
 	return err;
 }
 
@@ -1781,7 +1845,7 @@ static int ovs_vport_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	struct vport *vport;
 	int err;
 
-	rtnl_lock();
+	ovs_lock();
 	vport = lookup_vport(sock_net(skb->sk), info->userhdr, a);
 	err = PTR_ERR(vport);
 	if (IS_ERR(vport))
@@ -1804,7 +1868,7 @@ static int ovs_vport_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	ovs_notify(reply, info, &ovs_dp_vport_multicast_group);
 
 exit_unlock:
-	rtnl_unlock();
+	ovs_unlock();
 	return err;
 }
 
@@ -1964,13 +2028,13 @@ static void rehash_flow_table(struct work_struct *work)
 	struct datapath *dp;
 	struct net *net;
 
-	genl_lock();
+	ovs_lock();
 	rtnl_lock();
 	for_each_net(net) {
 		struct ovs_net *ovs_net = net_generic(net, ovs_net_id);
 
 		list_for_each_entry(dp, &ovs_net->dps, list_node) {
-			struct flow_table *old_table = genl_dereference(dp->table);
+			struct flow_table *old_table = ovsl_dereference(dp->table);
 			struct flow_table *new_table;
 
 			new_table = ovs_flow_tbl_rehash(old_table);
@@ -1981,8 +2045,7 @@ static void rehash_flow_table(struct work_struct *work)
 		}
 	}
 	rtnl_unlock();
-	genl_unlock();
-
+	ovs_unlock();
 	schedule_delayed_work(&rehash_flow_wq, REHASH_FLOW_INTERVAL);
 }
 
@@ -1991,18 +2054,21 @@ static int __net_init ovs_init_net(struct net *net)
 	struct ovs_net *ovs_net = net_generic(net, ovs_net_id);
 
 	INIT_LIST_HEAD(&ovs_net->dps);
+	INIT_WORK(&ovs_net->dp_notify_work, ovs_dp_notify_wq);
 	return 0;
 }
 
 static void __net_exit ovs_exit_net(struct net *net)
 {
-	struct ovs_net *ovs_net = net_generic(net, ovs_net_id);
 	struct datapath *dp, *dp_next;
+	struct ovs_net *ovs_net = net_generic(net, ovs_net_id);
 
-	genl_lock();
+	ovs_lock();
 	list_for_each_entry_safe(dp, dp_next, &ovs_net->dps, list_node)
 		__dp_destroy(dp);
-	genl_unlock();
+	ovs_unlock();
+
+	cancel_work_sync(&ovs_net->dp_notify_work);
 }
 
 static struct pernet_operations ovs_net_ops = {
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index 655beb1..16b8406 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -57,9 +57,9 @@ struct dp_stats_percpu {
  * struct datapath - datapath for flow-based packet switching
  * @rcu: RCU callback head for deferred destruction.
  * @list_node: Element in global 'dps' list.
- * @table: Current flow table.  Protected by genl_lock and RCU.
+ * @table: Current flow table.  Protected by ovs_mutex and RCU.
  * @ports: Hash table for ports.  %OVSP_LOCAL port always exists.  Protected by
- * RTNL and RCU.
+ * ovs_mutex and RCU.
  * @stats_percpu: Per-CPU datapath statistics.
  * @net: Reference to net namespace.
  *
@@ -85,26 +85,6 @@ struct datapath {
 #endif
 };
 
-struct vport *ovs_lookup_vport(const struct datapath *dp, u16 port_no);
-
-static inline struct vport *ovs_vport_rcu(const struct datapath *dp, int port_no)
-{
-	WARN_ON_ONCE(!rcu_read_lock_held());
-	return ovs_lookup_vport(dp, port_no);
-}
-
-static inline struct vport *ovs_vport_rtnl_rcu(const struct datapath *dp, int port_no)
-{
-	WARN_ON_ONCE(!rcu_read_lock_held() && !rtnl_is_locked());
-	return ovs_lookup_vport(dp, port_no);
-}
-
-static inline struct vport *ovs_vport_rtnl(const struct datapath *dp, int port_no)
-{
-	ASSERT_RTNL();
-	return ovs_lookup_vport(dp, port_no);
-}
-
 /**
  * struct ovs_skb_cb - OVS data in skb CB
  * @flow: The flow associated with this packet.  May be %NULL if no flow.
@@ -131,6 +111,30 @@ struct dp_upcall_info {
 	u32 portid;
 };
 
+/**
+ * struct ovs_net - Per net-namespace data for ovs.
+ * @dps: List of datapaths to enable dumping them all out.
+ * Protected by genl_mutex.
+ */
+struct ovs_net {
+	struct list_head dps;
+	struct work_struct dp_notify_work;
+};
+
+extern int ovs_net_id;
+void ovs_lock(void);
+void ovs_unlock(void);
+
+#ifdef CONFIG_LOCKDEP
+int lockdep_ovsl_is_held(void);
+#else
+#define lockdep_ovsl_is_held()	1
+#endif
+
+#define ASSERT_OVSL()		WARN_ON(unlikely(!lockdep_ovsl_is_held()))
+#define ovsl_dereference(p)					\
+	rcu_dereference_protected(p, lockdep_ovsl_is_held())
+
 static inline struct net *ovs_dp_get_net(struct datapath *dp)
 {
 	return read_pnet(&dp->net);
@@ -141,6 +145,26 @@ static inline void ovs_dp_set_net(struct datapath *dp, struct net *net)
 	write_pnet(&dp->net, net);
 }
 
+struct vport *ovs_lookup_vport(const struct datapath *dp, u16 port_no);
+
+static inline struct vport *ovs_vport_rcu(const struct datapath *dp, int port_no)
+{
+	WARN_ON_ONCE(!rcu_read_lock_held());
+	return ovs_lookup_vport(dp, port_no);
+}
+
+static inline struct vport *ovs_vport_ovsl_rcu(const struct datapath *dp, int port_no)
+{
+	WARN_ON_ONCE(!rcu_read_lock_held() && !lockdep_ovsl_is_held());
+	return ovs_lookup_vport(dp, port_no);
+}
+
+static inline struct vport *ovs_vport_ovsl(const struct datapath *dp, int port_no)
+{
+	ASSERT_OVSL();
+	return ovs_lookup_vport(dp, port_no);
+}
+
 extern struct notifier_block ovs_dp_device_notifier;
 extern struct genl_multicast_group ovs_dp_vport_multicast_group;
 
@@ -154,4 +178,5 @@ struct sk_buff *ovs_vport_cmd_build_info(struct vport *, u32 pid, u32 seq,
 					 u8 cmd);
 
 int ovs_execute_actions(struct datapath *dp, struct sk_buff *skb);
+void ovs_dp_notify_wq(struct work_struct *work);
 #endif /* datapath.h */
diff --git a/net/openvswitch/dp_notify.c b/net/openvswitch/dp_notify.c
index 5558350..ef4feec 100644
--- a/net/openvswitch/dp_notify.c
+++ b/net/openvswitch/dp_notify.c
@@ -18,46 +18,78 @@
 
 #include <linux/netdevice.h>
 #include <net/genetlink.h>
+#include <net/netns/generic.h>
 
 #include "datapath.h"
 #include "vport-internal_dev.h"
 #include "vport-netdev.h"
 
+static void dp_detach_port_notify(struct vport *vport)
+{
+	struct sk_buff *notify;
+	struct datapath *dp;
+
+	dp = vport->dp;
+	notify = ovs_vport_cmd_build_info(vport, 0, 0,
+					  OVS_VPORT_CMD_DEL);
+	ovs_dp_detach_port(vport);
+	if (IS_ERR(notify)) {
+		netlink_set_err(ovs_dp_get_net(dp)->genl_sock, 0,
+				ovs_dp_vport_multicast_group.id,
+				PTR_ERR(notify));
+		return;
+	}
+
+	genlmsg_multicast_netns(ovs_dp_get_net(dp), notify, 0,
+				ovs_dp_vport_multicast_group.id,
+				GFP_KERNEL);
+}
+
+void ovs_dp_notify_wq(struct work_struct *work)
+{
+	struct ovs_net *ovs_net = container_of(work, struct ovs_net, dp_notify_work);
+	struct datapath *dp;
+
+	ovs_lock();
+	list_for_each_entry(dp, &ovs_net->dps, list_node) {
+		int i;
+
+		for (i = 0; i < DP_VPORT_HASH_BUCKETS; i++) {
+			struct vport *vport;
+			struct hlist_node *n;
+
+			hlist_for_each_entry_safe(vport, n, &dp->ports[i], dp_hash_node) {
+				struct netdev_vport *netdev_vport;
+
+				if (vport->ops->type != OVS_VPORT_TYPE_NETDEV)
+					continue;
+
+				netdev_vport = netdev_vport_priv(vport);
+				if (netdev_vport->dev->reg_state == NETREG_UNREGISTERED ||
+				    netdev_vport->dev->reg_state == NETREG_UNREGISTERING)
+					dp_detach_port_notify(vport);
+			}
+		}
+	}
+	ovs_unlock();
+}
+
 static int dp_device_event(struct notifier_block *unused, unsigned long event,
 			   void *ptr)
 {
+	struct ovs_net *ovs_net;
 	struct net_device *dev = ptr;
-	struct vport *vport;
+	struct vport *vport = NULL;
 
-	if (ovs_is_internal_dev(dev))
-		vport = ovs_internal_dev_get_vport(dev);
-	else
+	if (!ovs_is_internal_dev(dev))
 		vport = ovs_netdev_get_vport(dev);
 
 	if (!vport)
 		return NOTIFY_DONE;
 
-	switch (event) {
-	case NETDEV_UNREGISTER:
-		if (!ovs_is_internal_dev(dev)) {
-			struct sk_buff *notify;
-			struct datapath *dp = vport->dp;
-
-			notify = ovs_vport_cmd_build_info(vport, 0, 0,
-							  OVS_VPORT_CMD_DEL);
-			ovs_dp_detach_port(vport);
-			if (IS_ERR(notify)) {
-				netlink_set_err(ovs_dp_get_net(dp)->genl_sock, 0,
-						ovs_dp_vport_multicast_group.id,
-						PTR_ERR(notify));
-				break;
-			}
-
-			genlmsg_multicast_netns(ovs_dp_get_net(dp), notify, 0,
-						ovs_dp_vport_multicast_group.id,
-						GFP_KERNEL);
-		}
-		break;
+	if (event == NETDEV_UNREGISTER) {
+		ovs_net = net_generic(dev_net(dev), ovs_net_id);
+		queue_work(system_wq, &ovs_net->dp_notify_work);
 	}
 
 	return NOTIFY_DONE;
diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
index 40f8a24..9604760 100644
--- a/net/openvswitch/vport-internal_dev.c
+++ b/net/openvswitch/vport-internal_dev.c
@@ -173,16 +173,19 @@ static struct vport *internal_dev_create(const struct vport_parms *parms)
 	if (vport->port_no == OVSP_LOCAL)
 		netdev_vport->dev->features |= NETIF_F_NETNS_LOCAL;
 
+	rtnl_lock();
 	err = register_netdevice(netdev_vport->dev);
 	if (err)
 		goto error_free_netdev;
 
 	dev_set_promiscuity(netdev_vport->dev, 1);
+	rtnl_unlock();
 	netif_start_queue(netdev_vport->dev);
 
 	return vport;
 
 error_free_netdev:
+	rtnl_unlock();
 	free_netdev(netdev_vport->dev);
 error_free_vport:
 	ovs_vport_free(vport);
@@ -195,10 +198,13 @@ static void internal_dev_destroy(struct vport *vport)
 	struct netdev_vport *netdev_vport = netdev_vport_priv(vport);
 
 	netif_stop_queue(netdev_vport->dev);
+	rtnl_lock();
 	dev_set_promiscuity(netdev_vport->dev, -1);
 
 	/* unregister_netdevice() waits for an RCU grace period. */
 	unregister_netdevice(netdev_vport->dev);
+
+	rtnl_unlock();
 }
 
 static int internal_dev_recv(struct vport *vport, struct sk_buff *skb)
diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index 2130d61..40a89ae 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -100,16 +100,20 @@ static struct vport *netdev_create(const struct vport_parms *parms)
 		goto error_put;
 	}
 
+	rtnl_lock();
 	err = netdev_rx_handler_register(netdev_vport->dev, netdev_frame_hook,
 					 vport);
 	if (err)
-		goto error_put;
+		goto error_unlock;
 
 	dev_set_promiscuity(netdev_vport->dev, 1);
 	netdev_vport->dev->priv_flags |= IFF_OVS_DATAPATH;
+	rtnl_unlock();
 
 	return vport;
 
+error_unlock:
+	rtnl_unlock();
 error_put:
 	dev_put(netdev_vport->dev);
 error_free_vport:
@@ -131,9 +135,11 @@ static void netdev_destroy(struct vport *vport)
 {
 	struct netdev_vport *netdev_vport = netdev_vport_priv(vport);
 
+	rtnl_lock();
 	netdev_vport->dev->priv_flags &= ~IFF_OVS_DATAPATH;
 	netdev_rx_handler_unregister(netdev_vport->dev);
 	dev_set_promiscuity(netdev_vport->dev, -1);
+	rtnl_unlock();
 
 	call_rcu(&netdev_vport->rcu, free_port_rcu);
 }
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 71a2de8..c90d856 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -40,7 +40,7 @@ static const struct vport_ops *vport_ops_list[] = {
 	&ovs_internal_vport_ops,
 };
 
-/* Protected by RCU read lock for reading, RTNL lock for writing. */
+/* Protected by RCU read lock for reading, ovs_mutex for writing. */
 static struct hlist_head *dev_table;
 #define VPORT_HASH_BUCKETS 1024
 
@@ -80,7 +80,7 @@ static struct hlist_head *hash_bucket(struct net *net, const char *name)
  *
  * @name: name of port to find
  *
- * Must be called with RTNL or RCU read lock.
+ * Must be called with ovs or RCU read lock.
  */
 struct vport *ovs_vport_locate(struct net *net, const char *name)
 {
@@ -161,7 +161,7 @@ void ovs_vport_free(struct vport *vport)
  * @parms: Information about new vport.
  *
  * Creates a new vport with the specified configuration (which is dependent on
- * device type).  RTNL lock must be held.
+ * device type).  ovs_mutex must be held.
  */
 struct vport *ovs_vport_add(const struct vport_parms *parms)
 {
@@ -169,8 +169,6 @@ struct vport *ovs_vport_add(const struct vport_parms *parms)
 	int err = 0;
 	int i;
 
-	ASSERT_RTNL();
-
 	for (i = 0; i < ARRAY_SIZE(vport_ops_list); i++) {
 		if (vport_ops_list[i]->type == parms->type) {
 			struct hlist_head *bucket;
@@ -201,12 +199,10 @@ out:
  * @port: New configuration.
  *
  * Modifies an existing device with the specified configuration (which is
- * dependent on device type).  RTNL lock must be held.
+ * dependent on device type).  ovs_mutex must be held.
  */
 int ovs_vport_set_options(struct vport *vport, struct nlattr *options)
 {
-	ASSERT_RTNL();
-
 	if (!vport->ops->set_options)
 		return -EOPNOTSUPP;
 	return vport->ops->set_options(vport, options);
@@ -218,11 +214,11 @@ int ovs_vport_set_options(struct vport *vport, struct nlattr *options)
  * @vport: vport to delete.
  *
  * Detaches @vport from its datapath and destroys it.  It is possible to fail
- * for reasons such as lack of memory.  RTNL lock must be held.
+ * for reasons such as lack of memory.  ovs_mutex must be held.
  */
 void ovs_vport_del(struct vport *vport)
 {
-	ASSERT_RTNL();
+	ASSERT_OVSL();
 
 	hlist_del_rcu(&vport->hash_node);
 
@@ -237,7 +233,7 @@ void ovs_vport_del(struct vport *vport)
  *
  * Retrieves transmit, receive, and error stats for the given device.
  *
- * Must be called with RTNL lock or rcu_read_lock.
+ * Must be called with ovs_mutex or rcu_read_lock.
  */
 void ovs_vport_get_stats(struct vport *vport, struct ovs_vport_stats *stats)
 {
@@ -296,7 +292,7 @@ void ovs_vport_get_stats(struct vport *vport, struct ovs_vport_stats *stats)
  * negative error code if a real error occurred.  If an error occurs, @skb is
  * left unmodified.
  *
- * Must be called with RTNL lock or rcu_read_lock.
+ * Must be called with ovs_mutex or rcu_read_lock.
  */
 int ovs_vport_get_options(const struct vport *vport, struct sk_buff *skb)
 {
@@ -348,7 +344,7 @@ void ovs_vport_receive(struct vport *vport, struct sk_buff *skb)
  * @vport: vport on which to send the packet
  * @skb: skb to send
  *
- * Sends the given packet and returns the length of data sent.  Either RTNL
+ * Sends the given packet and returns the length of data sent.  Either ovs
  * lock or rcu_read_lock must be held.
  */
 int ovs_vport_send(struct vport *vport, struct sk_buff *skb)
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index aee7d43..7282b84 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -138,14 +138,14 @@ struct vport_parms {
 struct vport_ops {
 	enum ovs_vport_type type;
 
-	/* Called with RTNL lock. */
+	/* Called with ovs_mutex. */
 	struct vport *(*create)(const struct vport_parms *);
 	void (*destroy)(struct vport *);
 
 	int (*set_options)(struct vport *, struct nlattr *);
 	int (*get_options)(const struct vport *, struct sk_buff *);
 
-	/* Called with rcu_read_lock or RTNL lock. */
+	/* Called with rcu_read_lock or ovs_mutex. */
 	const char *(*get_name)(const struct vport *);
 	void (*get_config)(const struct vport *, void *);
 	int (*get_ifindex)(const struct vport *);
-- 
1.7.10.4
