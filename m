From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 1/2] openvswitch: Add support for network
	namespaces.
Date: Tue,  4 Sep 2012 12:14:08 -0700
Message-ID: <1346786049-3100-2-git-send-email-jesse@nicira.com>
References: <1346786049-3100-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1346786049-3100-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
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

Following patch adds support for network namespace to openvswitch.
Since it must release devices when namespaces are destroyed, a
side effect of this patch is that the module no longer keeps a
refcount but instead cleans up any state when it is unloaded.

Signed-off-by: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/datapath.c           |  269 ++++++++++++++++++++--------------
 net/openvswitch/datapath.h           |   19 ++-
 net/openvswitch/dp_notify.c          |    8 +-
 net/openvswitch/vport-internal_dev.c |    7 +-
 net/openvswitch/vport-netdev.c       |    2 +-
 net/openvswitch/vport.c              |   22 ++-
 net/openvswitch/vport.h              |    3 +-
 7 files changed, 207 insertions(+), 123 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index d8277d2..cad39fc 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -49,12 +49,29 @@
 #include <linux/dmi.h>
 #include <linux/workqueue.h>
 #include <net/genetlink.h>
+#include <net/net_namespace.h>
+#include <net/netns/generic.h>
 
 #include "datapath.h"
 #include "flow.h"
 #include "vport-internal_dev.h"
 
 /**
+ * struct ovs_net - Per net-namespace data for ovs.
+ * @dps: List of datapaths to enable dumping them all out.
+ * Protected by genl_mutex.
+ */
+struct ovs_net {
+	struct list_head dps;
+};
+
+static int ovs_net_id __read_mostly;
+
+#define REHASH_FLOW_INTERVAL (10 * 60 * HZ)
+static void rehash_flow_table(struct work_struct *work);
+static DECLARE_DELAYED_WORK(rehash_flow_wq, rehash_flow_table);
+
+/**
  * DOC: Locking:
  *
  * Writes to device state (add/remove datapath, port, set operations on vports,
@@ -71,29 +88,21 @@
  * each other.
  */
 
-/* Global list of datapaths to enable dumping them all out.
- * Protected by genl_mutex.
- */
-static LIST_HEAD(dps);
-
-#define REHASH_FLOW_INTERVAL (10 * 60 * HZ)
-static void rehash_flow_table(struct work_struct *work);
-static DECLARE_DELAYED_WORK(rehash_flow_wq, rehash_flow_table);
-
 static struct vport *new_vport(const struct vport_parms *);
-static int queue_gso_packets(int dp_ifindex, struct sk_buff *,
+static int queue_gso_packets(struct net *, int dp_ifindex, struct sk_buff *,
 			     const struct dp_upcall_info *);
-static int queue_userspace_packet(int dp_ifindex, struct sk_buff *,
+static int queue_userspace_packet(struct net *, int dp_ifindex,
+				  struct sk_buff *,
 				  const struct dp_upcall_info *);
 
 /* Must be called with rcu_read_lock, genl_mutex, or RTNL lock. */
-static struct datapath *get_dp(int dp_ifindex)
+static struct datapath *get_dp(struct net *net, int dp_ifindex)
 {
 	struct datapath *dp = NULL;
 	struct net_device *dev;
 
 	rcu_read_lock();
-	dev = dev_get_by_index_rcu(&init_net, dp_ifindex);
+	dev = dev_get_by_index_rcu(net, dp_ifindex);
 	if (dev) {
 		struct vport *vport = ovs_internal_dev_get_vport(dev);
 		if (vport)
@@ -135,6 +144,7 @@ static void destroy_dp_rcu(struct rcu_head *rcu)
 
 	ovs_flow_tbl_destroy((__force struct flow_table *)dp->table);
 	free_percpu(dp->stats_percpu);
+	release_net(ovs_dp_get_net(dp));
 	kfree(dp);
 }
 
@@ -220,11 +230,12 @@ static struct genl_family dp_packet_genl_family = {
 	.hdrsize = sizeof(struct ovs_header),
 	.name = OVS_PACKET_FAMILY,
 	.version = OVS_PACKET_VERSION,
-	.maxattr = OVS_PACKET_ATTR_MAX
+	.maxattr = OVS_PACKET_ATTR_MAX,
+	.netnsok = true
 };
 
 int ovs_dp_upcall(struct datapath *dp, struct sk_buff *skb,
-	      const struct dp_upcall_info *upcall_info)
+		  const struct dp_upcall_info *upcall_info)
 {
 	struct dp_stats_percpu *stats;
 	int dp_ifindex;
@@ -242,9 +253,9 @@ int ovs_dp_upcall(struct datapath *dp, struct sk_buff *skb,
 	}
 
 	if (!skb_is_gso(skb))
-		err = queue_userspace_packet(dp_ifindex, skb, upcall_info);
+		err = queue_userspace_packet(ovs_dp_get_net(dp), dp_ifindex, skb, upcall_info);
 	else
-		err = queue_gso_packets(dp_ifindex, skb, upcall_info);
+		err = queue_gso_packets(ovs_dp_get_net(dp), dp_ifindex, skb, upcall_info);
 	if (err)
 		goto err;
 
@@ -260,7 +271,8 @@ err:
 	return err;
 }
 
-static int queue_gso_packets(int dp_ifindex, struct sk_buff *skb,
+static int queue_gso_packets(struct net *net, int dp_ifindex,
+			     struct sk_buff *skb,
 			     const struct dp_upcall_info *upcall_info)
 {
 	unsigned short gso_type = skb_shinfo(skb)->gso_type;
@@ -276,7 +288,7 @@ static int queue_gso_packets(int dp_ifindex, struct sk_buff *skb,
 	/* Queue all of the segments. */
 	skb = segs;
 	do {
-		err = queue_userspace_packet(dp_ifindex, skb, upcall_info);
+		err = queue_userspace_packet(net, dp_ifindex, skb, upcall_info);
 		if (err)
 			break;
 
@@ -306,7 +318,8 @@ static int queue_gso_packets(int dp_ifindex, struct sk_buff *skb,
 	return err;
 }
 
-static int queue_userspace_packet(int dp_ifindex, struct sk_buff *skb,
+static int queue_userspace_packet(struct net *net, int dp_ifindex,
+				  struct sk_buff *skb,
 				  const struct dp_upcall_info *upcall_info)
 {
 	struct ovs_header *upcall;
@@ -362,7 +375,7 @@ static int queue_userspace_packet(int dp_ifindex, struct sk_buff *skb,
 
 	skb_copy_and_csum_dev(skb, nla_data(nla));
 
-	err = genlmsg_unicast(&init_net, user_skb, upcall_info->pid);
+	err = genlmsg_unicast(net, user_skb, upcall_info->pid);
 
 out:
 	kfree_skb(nskb);
@@ -370,15 +383,10 @@ out:
 }
 
 /* Called with genl_mutex. */
-static int flush_flows(int dp_ifindex)
+static int flush_flows(struct datapath *dp)
 {
 	struct flow_table *old_table;
 	struct flow_table *new_table;
-	struct datapath *dp;
-
-	dp = get_dp(dp_ifindex);
-	if (!dp)
-		return -ENODEV;
 
 	old_table = genl_dereference(dp->table);
 	new_table = ovs_flow_tbl_alloc(TBL_MIN_BUCKETS);
@@ -668,7 +676,7 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 	packet->priority = flow->key.phy.priority;
 
 	rcu_read_lock();
-	dp = get_dp(ovs_header->dp_ifindex);
+	dp = get_dp(sock_net(skb->sk), ovs_header->dp_ifindex);
 	err = -ENODEV;
 	if (!dp)
 		goto err_unlock;
@@ -742,7 +750,8 @@ static struct genl_family dp_flow_genl_family = {
 	.hdrsize = sizeof(struct ovs_header),
 	.name = OVS_FLOW_FAMILY,
 	.version = OVS_FLOW_VERSION,
-	.maxattr = OVS_FLOW_ATTR_MAX
+	.maxattr = OVS_FLOW_ATTR_MAX,
+	.netnsok = true
 };
 
 static struct genl_multicast_group ovs_dp_flow_multicast_group = {
@@ -894,7 +903,7 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 		goto error;
 	}
 
-	dp = get_dp(ovs_header->dp_ifindex);
+	dp = get_dp(sock_net(skb->sk), ovs_header->dp_ifindex);
 	error = -ENODEV;
 	if (!dp)
 		goto error;
@@ -995,7 +1004,7 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 			   ovs_dp_flow_multicast_group.id, info->nlhdr,
 			   GFP_KERNEL);
 	else
-		netlink_set_err(init_net.genl_sock, 0,
+		netlink_set_err(sock_net(skb->sk)->genl_sock, 0,
 				ovs_dp_flow_multicast_group.id, PTR_ERR(reply));
 	return 0;
 
@@ -1023,7 +1032,7 @@ static int ovs_flow_cmd_get(struct sk_buff *skb, struct genl_info *info)
 	if (err)
 		return err;
 
-	dp = get_dp(ovs_header->dp_ifindex);
+	dp = get_dp(sock_net(skb->sk), ovs_header->dp_ifindex);
 	if (!dp)
 		return -ENODEV;
 
@@ -1052,16 +1061,17 @@ static int ovs_flow_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	int err;
 	int key_len;
 
+	dp = get_dp(sock_net(skb->sk), ovs_header->dp_ifindex);
+	if (!dp)
+		return -ENODEV;
+
 	if (!a[OVS_FLOW_ATTR_KEY])
-		return flush_flows(ovs_header->dp_ifindex);
+		return flush_flows(dp);
+
 	err = ovs_flow_from_nlattrs(&key, &key_len, a[OVS_FLOW_ATTR_KEY]);
 	if (err)
 		return err;
 
-	dp = get_dp(ovs_header->dp_ifindex);
-	if (!dp)
-		return -ENODEV;
-
 	table = genl_dereference(dp->table);
 	flow = ovs_flow_tbl_lookup(table, &key, key_len);
 	if (!flow)
@@ -1090,7 +1100,7 @@ static int ovs_flow_cmd_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	struct datapath *dp;
 	struct flow_table *table;
 
-	dp = get_dp(ovs_header->dp_ifindex);
+	dp = get_dp(sock_net(skb->sk), ovs_header->dp_ifindex);
 	if (!dp)
 		return -ENODEV;
 
@@ -1152,7 +1162,8 @@ static struct genl_family dp_datapath_genl_family = {
 	.hdrsize = sizeof(struct ovs_header),
 	.name = OVS_DATAPATH_FAMILY,
 	.version = OVS_DATAPATH_VERSION,
-	.maxattr = OVS_DP_ATTR_MAX
+	.maxattr = OVS_DP_ATTR_MAX,
+	.netnsok = true
 };
 
 static struct genl_multicast_group ovs_dp_datapath_multicast_group = {
@@ -1210,18 +1221,19 @@ static struct sk_buff *ovs_dp_cmd_build_info(struct datapath *dp, u32 pid,
 }
 
 /* Called with genl_mutex and optionally with RTNL lock also. */
-static struct datapath *lookup_datapath(struct ovs_header *ovs_header,
+static struct datapath *lookup_datapath(struct net *net,
+					struct ovs_header *ovs_header,
 					struct nlattr *a[OVS_DP_ATTR_MAX + 1])
 {
 	struct datapath *dp;
 
 	if (!a[OVS_DP_ATTR_NAME])
-		dp = get_dp(ovs_header->dp_ifindex);
+		dp = get_dp(net, ovs_header->dp_ifindex);
 	else {
 		struct vport *vport;
 
 		rcu_read_lock();
-		vport = ovs_vport_locate(nla_data(a[OVS_DP_ATTR_NAME]));
+		vport = ovs_vport_locate(net, nla_data(a[OVS_DP_ATTR_NAME]));
 		dp = vport && vport->port_no == OVSP_LOCAL ? vport->dp : NULL;
 		rcu_read_unlock();
 	}
@@ -1235,6 +1247,7 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 	struct sk_buff *reply;
 	struct datapath *dp;
 	struct vport *vport;
+	struct ovs_net *ovs_net;
 	int err;
 
 	err = -EINVAL;
@@ -1242,15 +1255,14 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 		goto err;
 
 	rtnl_lock();
-	err = -ENODEV;
-	if (!try_module_get(THIS_MODULE))
-		goto err_unlock_rtnl;
 
 	err = -ENOMEM;
 	dp = kzalloc(sizeof(*dp), GFP_KERNEL);
 	if (dp == NULL)
-		goto err_put_module;
+		goto err_unlock_rtnl;
+
 	INIT_LIST_HEAD(&dp->port_list);
+	ovs_dp_set_net(dp, hold_net(sock_net(skb->sk)));
 
 	/* Allocate table. */
 	err = -ENOMEM;
@@ -1287,7 +1299,8 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 	if (IS_ERR(reply))
 		goto err_destroy_local_port;
 
-	list_add_tail(&dp->list_node, &dps);
+	ovs_net = net_generic(ovs_dp_get_net(dp), ovs_net_id);
+	list_add_tail(&dp->list_node, &ovs_net->dps);
 	rtnl_unlock();
 
 	genl_notify(reply, genl_info_net(info), info->snd_pid,
@@ -1302,34 +1315,20 @@ err_destroy_percpu:
 err_destroy_table:
 	ovs_flow_tbl_destroy(genl_dereference(dp->table));
 err_free_dp:
+	release_net(ovs_dp_get_net(dp));
 	kfree(dp);
-err_put_module:
-	module_put(THIS_MODULE);
 err_unlock_rtnl:
 	rtnl_unlock();
 err:
 	return err;
 }
 
-static int ovs_dp_cmd_del(struct sk_buff *skb, struct genl_info *info)
+/* Called with genl_mutex. */
+static void __dp_destroy(struct datapath *dp)
 {
 	struct vport *vport, *next_vport;
-	struct sk_buff *reply;
-	struct datapath *dp;
-	int err;
 
 	rtnl_lock();
-	dp = lookup_datapath(info->userhdr, info->attrs);
-	err = PTR_ERR(dp);
-	if (IS_ERR(dp))
-		goto exit_unlock;
-
-	reply = ovs_dp_cmd_build_info(dp, info->snd_pid,
-				      info->snd_seq, OVS_DP_CMD_DEL);
-	err = PTR_ERR(reply);
-	if (IS_ERR(reply))
-		goto exit_unlock;
-
 	list_for_each_entry_safe(vport, next_vport, &dp->port_list, node)
 		if (vport->port_no != OVSP_LOCAL)
 			ovs_dp_detach_port(vport);
@@ -1345,17 +1344,32 @@ static int ovs_dp_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	rtnl_unlock();
 
 	call_rcu(&dp->rcu, destroy_dp_rcu);
-	module_put(THIS_MODULE);
+}
+
+static int ovs_dp_cmd_del(struct sk_buff *skb, struct genl_info *info)
+{
+	struct sk_buff *reply;
+	struct datapath *dp;
+	int err;
+
+	dp = lookup_datapath(sock_net(skb->sk), info->userhdr, info->attrs);
+	err = PTR_ERR(dp);
+	if (IS_ERR(dp))
+		return err;
+
+	reply = ovs_dp_cmd_build_info(dp, info->snd_pid,
+				      info->snd_seq, OVS_DP_CMD_DEL);
+	err = PTR_ERR(reply);
+	if (IS_ERR(reply))
+		return err;
+
+	__dp_destroy(dp);
 
 	genl_notify(reply, genl_info_net(info), info->snd_pid,
 		    ovs_dp_datapath_multicast_group.id, info->nlhdr,
 		    GFP_KERNEL);
 
 	return 0;
-
-exit_unlock:
-	rtnl_unlock();
-	return err;
 }
 
 static int ovs_dp_cmd_set(struct sk_buff *skb, struct genl_info *info)
@@ -1364,7 +1378,7 @@ static int ovs_dp_cmd_set(struct sk_buff *skb, struct genl_info *info)
 	struct datapath *dp;
 	int err;
 
-	dp = lookup_datapath(info->userhdr, info->attrs);
+	dp = lookup_datapath(sock_net(skb->sk), info->userhdr, info->attrs);
 	if (IS_ERR(dp))
 		return PTR_ERR(dp);
 
@@ -1372,7 +1386,7 @@ static int ovs_dp_cmd_set(struct sk_buff *skb, struct genl_info *info)
 				      info->snd_seq, OVS_DP_CMD_NEW);
 	if (IS_ERR(reply)) {
 		err = PTR_ERR(reply);
-		netlink_set_err(init_net.genl_sock, 0,
+		netlink_set_err(sock_net(skb->sk)->genl_sock, 0,
 				ovs_dp_datapath_multicast_group.id, err);
 		return 0;
 	}
@@ -1389,7 +1403,7 @@ static int ovs_dp_cmd_get(struct sk_buff *skb, struct genl_info *info)
 	struct sk_buff *reply;
 	struct datapath *dp;
 
-	dp = lookup_datapath(info->userhdr, info->attrs);
+	dp = lookup_datapath(sock_net(skb->sk), info->userhdr, info->attrs);
 	if (IS_ERR(dp))
 		return PTR_ERR(dp);
 
@@ -1403,11 +1417,12 @@ static int ovs_dp_cmd_get(struct sk_buff *skb, struct genl_info *info)
 
 static int ovs_dp_cmd_dump(struct sk_buff *skb, struct netlink_callback *cb)
 {
+	struct ovs_net *ovs_net = net_generic(sock_net(skb->sk), ovs_net_id);
 	struct datapath *dp;
 	int skip = cb->args[0];
 	int i = 0;
 
-	list_for_each_entry(dp, &dps, list_node) {
+	list_for_each_entry(dp, &ovs_net->dps, list_node) {
 		if (i >= skip &&
 		    ovs_dp_cmd_fill_info(dp, skb, NETLINK_CB(cb->skb).pid,
 					 cb->nlh->nlmsg_seq, NLM_F_MULTI,
@@ -1459,7 +1474,8 @@ static struct genl_family dp_vport_genl_family = {
 	.hdrsize = sizeof(struct ovs_header),
 	.name = OVS_VPORT_FAMILY,
 	.version = OVS_VPORT_VERSION,
-	.maxattr = OVS_VPORT_ATTR_MAX
+	.maxattr = OVS_VPORT_ATTR_MAX,
+	.netnsok = true
 };
 
 struct genl_multicast_group ovs_dp_vport_multicast_group = {
@@ -1525,14 +1541,15 @@ struct sk_buff *ovs_vport_cmd_build_info(struct vport *vport, u32 pid,
 }
 
 /* Called with RTNL lock or RCU read lock. */
-static struct vport *lookup_vport(struct ovs_header *ovs_header,
+static struct vport *lookup_vport(struct net *net,
+				  struct ovs_header *ovs_header,
 				  struct nlattr *a[OVS_VPORT_ATTR_MAX + 1])
 {
 	struct datapath *dp;
 	struct vport *vport;
 
 	if (a[OVS_VPORT_ATTR_NAME]) {
-		vport = ovs_vport_locate(nla_data(a[OVS_VPORT_ATTR_NAME]));
+		vport = ovs_vport_locate(net, nla_data(a[OVS_VPORT_ATTR_NAME]));
 		if (!vport)
 			return ERR_PTR(-ENODEV);
 		if (ovs_header->dp_ifindex &&
@@ -1545,7 +1562,7 @@ static struct vport *lookup_vport(struct ovs_header *ovs_header,
 		if (port_no >= DP_MAX_PORTS)
 			return ERR_PTR(-EFBIG);
 
-		dp = get_dp(ovs_header->dp_ifindex);
+		dp = get_dp(net, ovs_header->dp_ifindex);
 		if (!dp)
 			return ERR_PTR(-ENODEV);
 
@@ -1574,7 +1591,7 @@ static int ovs_vport_cmd_new(struct sk_buff *skb, struct genl_info *info)
 		goto exit;
 
 	rtnl_lock();
-	dp = get_dp(ovs_header->dp_ifindex);
+	dp = get_dp(sock_net(skb->sk), ovs_header->dp_ifindex);
 	err = -ENODEV;
 	if (!dp)
 		goto exit_unlock;
@@ -1638,7 +1655,7 @@ static int ovs_vport_cmd_set(struct sk_buff *skb, struct genl_info *info)
 	int err;
 
 	rtnl_lock();
-	vport = lookup_vport(info->userhdr, a);
+	vport = lookup_vport(sock_net(skb->sk), info->userhdr, a);
 	err = PTR_ERR(vport);
 	if (IS_ERR(vport))
 		goto exit_unlock;
@@ -1658,7 +1675,7 @@ static int ovs_vport_cmd_set(struct sk_buff *skb, struct genl_info *info)
 	reply = ovs_vport_cmd_build_info(vport, info->snd_pid, info->snd_seq,
 					 OVS_VPORT_CMD_NEW);
 	if (IS_ERR(reply)) {
-		netlink_set_err(init_net.genl_sock, 0,
+		netlink_set_err(sock_net(skb->sk)->genl_sock, 0,
 				ovs_dp_vport_multicast_group.id, PTR_ERR(reply));
 		goto exit_unlock;
 	}
@@ -1679,7 +1696,7 @@ static int ovs_vport_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	int err;
 
 	rtnl_lock();
-	vport = lookup_vport(info->userhdr, a);
+	vport = lookup_vport(sock_net(skb->sk), info->userhdr, a);
 	err = PTR_ERR(vport);
 	if (IS_ERR(vport))
 		goto exit_unlock;
@@ -1714,7 +1731,7 @@ static int ovs_vport_cmd_get(struct sk_buff *skb, struct genl_info *info)
 	int err;
 
 	rcu_read_lock();
-	vport = lookup_vport(ovs_header, a);
+	vport = lookup_vport(sock_net(skb->sk), ovs_header, a);
 	err = PTR_ERR(vport);
 	if (IS_ERR(vport))
 		goto exit_unlock;
@@ -1741,7 +1758,7 @@ static int ovs_vport_cmd_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	u32 port_no;
 	int retval;
 
-	dp = get_dp(ovs_header->dp_ifindex);
+	dp = get_dp(sock_net(skb->sk), ovs_header->dp_ifindex);
 	if (!dp)
 		return -ENODEV;
 
@@ -1766,28 +1783,6 @@ static int ovs_vport_cmd_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	return retval;
 }
 
-static void rehash_flow_table(struct work_struct *work)
-{
-	struct datapath *dp;
-
-	genl_lock();
-
-	list_for_each_entry(dp, &dps, list_node) {
-		struct flow_table *old_table = genl_dereference(dp->table);
-		struct flow_table *new_table;
-
-		new_table = ovs_flow_tbl_rehash(old_table);
-		if (!IS_ERR(new_table)) {
-			rcu_assign_pointer(dp->table, new_table);
-			ovs_flow_tbl_deferred_destroy(old_table);
-		}
-	}
-
-	genl_unlock();
-
-	schedule_delayed_work(&rehash_flow_wq, REHASH_FLOW_INTERVAL);
-}
-
 static struct genl_ops dp_vport_genl_ops[] = {
 	{ .cmd = OVS_VPORT_CMD_NEW,
 	  .flags = GENL_ADMIN_PERM, /* Requires CAP_NET_ADMIN privilege. */
@@ -1872,6 +1867,59 @@ error:
 	return err;
 }
 
+static void rehash_flow_table(struct work_struct *work)
+{
+	struct datapath *dp;
+	struct net *net;
+
+	genl_lock();
+	rtnl_lock();
+	for_each_net(net) {
+		struct ovs_net *ovs_net = net_generic(net, ovs_net_id);
+
+		list_for_each_entry(dp, &ovs_net->dps, list_node) {
+			struct flow_table *old_table = genl_dereference(dp->table);
+			struct flow_table *new_table;
+
+			new_table = ovs_flow_tbl_rehash(old_table);
+			if (!IS_ERR(new_table)) {
+				rcu_assign_pointer(dp->table, new_table);
+				ovs_flow_tbl_deferred_destroy(old_table);
+			}
+		}
+	}
+	rtnl_unlock();
+	genl_unlock();
+
+	schedule_delayed_work(&rehash_flow_wq, REHASH_FLOW_INTERVAL);
+}
+
+static int __net_init ovs_init_net(struct net *net)
+{
+	struct ovs_net *ovs_net = net_generic(net, ovs_net_id);
+
+	INIT_LIST_HEAD(&ovs_net->dps);
+	return 0;
+}
+
+static void __net_exit ovs_exit_net(struct net *net)
+{
+	struct ovs_net *ovs_net = net_generic(net, ovs_net_id);
+	struct datapath *dp, *dp_next;
+
+	genl_lock();
+	list_for_each_entry_safe(dp, dp_next, &ovs_net->dps, list_node)
+		__dp_destroy(dp);
+	genl_unlock();
+}
+
+static struct pernet_operations ovs_net_ops = {
+	.init = ovs_init_net,
+	.exit = ovs_exit_net,
+	.id   = &ovs_net_id,
+	.size = sizeof(struct ovs_net),
+};
+
 static int __init dp_init(void)
 {
 	struct sk_buff *dummy_skb;
@@ -1889,10 +1937,14 @@ static int __init dp_init(void)
 	if (err)
 		goto error_flow_exit;
 
-	err = register_netdevice_notifier(&ovs_dp_device_notifier);
+	err = register_pernet_device(&ovs_net_ops);
 	if (err)
 		goto error_vport_exit;
 
+	err = register_netdevice_notifier(&ovs_dp_device_notifier);
+	if (err)
+		goto error_netns_exit;
+
 	err = dp_register_genl();
 	if (err < 0)
 		goto error_unreg_notifier;
@@ -1903,6 +1955,8 @@ static int __init dp_init(void)
 
 error_unreg_notifier:
 	unregister_netdevice_notifier(&ovs_dp_device_notifier);
+error_netns_exit:
+	unregister_pernet_device(&ovs_net_ops);
 error_vport_exit:
 	ovs_vport_exit();
 error_flow_exit:
@@ -1914,9 +1968,10 @@ error:
 static void dp_cleanup(void)
 {
 	cancel_delayed_work_sync(&rehash_flow_wq);
-	rcu_barrier();
 	dp_unregister_genl(ARRAY_SIZE(dp_genl_families));
 	unregister_netdevice_notifier(&ovs_dp_device_notifier);
+	unregister_pernet_device(&ovs_net_ops);
+	rcu_barrier();
 	ovs_vport_exit();
 	ovs_flow_exit();
 }
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index c1105c1..771c11e 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -27,8 +27,7 @@
 #include <linux/u64_stats_sync.h>
 
 #include "flow.h"
-
-struct vport;
+#include "vport.h"
 
 #define DP_MAX_PORTS 1024
 #define SAMPLE_ACTION_DEPTH 3
@@ -63,6 +62,7 @@ struct dp_stats_percpu {
  * @port_list: List of all ports in @ports in arbitrary order.  RTNL required
  * to iterate or modify.
  * @stats_percpu: Per-CPU datapath statistics.
+ * @net: Reference to net namespace.
  *
  * Context: See the comment on locking at the top of datapath.c for additional
  * locking information.
@@ -80,6 +80,11 @@ struct datapath {
 
 	/* Stats. */
 	struct dp_stats_percpu __percpu *stats_percpu;
+
+#ifdef CONFIG_NET_NS
+	/* Network namespace ref. */
+	struct net *net;
+#endif
 };
 
 /**
@@ -108,6 +113,16 @@ struct dp_upcall_info {
 	u32 pid;
 };
 
+static inline struct net *ovs_dp_get_net(struct datapath *dp)
+{
+	return read_pnet(&dp->net);
+}
+
+static inline void ovs_dp_set_net(struct datapath *dp, struct net *net)
+{
+	write_pnet(&dp->net, net);
+}
+
 extern struct notifier_block ovs_dp_device_notifier;
 extern struct genl_multicast_group ovs_dp_vport_multicast_group;
 
diff --git a/net/openvswitch/dp_notify.c b/net/openvswitch/dp_notify.c
index 36dcee8..5558350 100644
--- a/net/openvswitch/dp_notify.c
+++ b/net/openvswitch/dp_notify.c
@@ -41,19 +41,21 @@ static int dp_device_event(struct notifier_block *unused, unsigned long event,
 	case NETDEV_UNREGISTER:
 		if (!ovs_is_internal_dev(dev)) {
 			struct sk_buff *notify;
+			struct datapath *dp = vport->dp;
 
 			notify = ovs_vport_cmd_build_info(vport, 0, 0,
 							  OVS_VPORT_CMD_DEL);
 			ovs_dp_detach_port(vport);
 			if (IS_ERR(notify)) {
-				netlink_set_err(init_net.genl_sock, 0,
+				netlink_set_err(ovs_dp_get_net(dp)->genl_sock, 0,
 						ovs_dp_vport_multicast_group.id,
 						PTR_ERR(notify));
 				break;
 			}
 
-			genlmsg_multicast(notify, 0, ovs_dp_vport_multicast_group.id,
-					  GFP_KERNEL);
+			genlmsg_multicast_netns(ovs_dp_get_net(dp), notify, 0,
+						ovs_dp_vport_multicast_group.id,
+						GFP_KERNEL);
 		}
 		break;
 	}
diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
index 4061b9e..5d460c3 100644
--- a/net/openvswitch/vport-internal_dev.c
+++ b/net/openvswitch/vport-internal_dev.c
@@ -144,7 +144,7 @@ static void do_setup(struct net_device *netdev)
 	netdev->tx_queue_len = 0;
 
 	netdev->features = NETIF_F_LLTX | NETIF_F_SG | NETIF_F_FRAGLIST |
-				NETIF_F_HIGHDMA | NETIF_F_HW_CSUM | NETIF_F_TSO;
+			   NETIF_F_HIGHDMA | NETIF_F_HW_CSUM | NETIF_F_TSO;
 
 	netdev->vlan_features = netdev->features;
 	netdev->features |= NETIF_F_HW_VLAN_TX;
@@ -175,9 +175,14 @@ static struct vport *internal_dev_create(const struct vport_parms *parms)
 		goto error_free_vport;
 	}
 
+	dev_net_set(netdev_vport->dev, ovs_dp_get_net(vport->dp));
 	internal_dev = internal_dev_priv(netdev_vport->dev);
 	internal_dev->vport = vport;
 
+	/* Restrict bridge port to current netns. */
+	if (vport->port_no == OVSP_LOCAL)
+		netdev_vport->dev->features |= NETIF_F_NETNS_LOCAL;
+
 	err = register_netdevice(netdev_vport->dev);
 	if (err)
 		goto error_free_netdev;
diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index 6ea3551..3c1e58b 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -83,7 +83,7 @@ static struct vport *netdev_create(const struct vport_parms *parms)
 
 	netdev_vport = netdev_vport_priv(vport);
 
-	netdev_vport->dev = dev_get_by_name(&init_net, parms->name);
+	netdev_vport->dev = dev_get_by_name(ovs_dp_get_net(vport->dp), parms->name);
 	if (!netdev_vport->dev) {
 		err = -ENODEV;
 		goto error_free_vport;
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 6140336..9873ace 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -16,10 +16,10 @@
  * 02110-1301, USA
  */
 
-#include <linux/dcache.h>
 #include <linux/etherdevice.h>
 #include <linux/if.h>
 #include <linux/if_vlan.h>
+#include <linux/jhash.h>
 #include <linux/kernel.h>
 #include <linux/list.h>
 #include <linux/mutex.h>
@@ -27,7 +27,9 @@
 #include <linux/rcupdate.h>
 #include <linux/rtnetlink.h>
 #include <linux/compat.h>
+#include <net/net_namespace.h>
 
+#include "datapath.h"
 #include "vport.h"
 #include "vport-internal_dev.h"
 
@@ -67,9 +69,9 @@ void ovs_vport_exit(void)
 	kfree(dev_table);
 }
 
-static struct hlist_head *hash_bucket(const char *name)
+static struct hlist_head *hash_bucket(struct net *net, const char *name)
 {
-	unsigned int hash = full_name_hash(name, strlen(name));
+	unsigned int hash = jhash(name, strlen(name), (unsigned long) net);
 	return &dev_table[hash & (VPORT_HASH_BUCKETS - 1)];
 }
 
@@ -80,14 +82,15 @@ static struct hlist_head *hash_bucket(const char *name)
  *
  * Must be called with RTNL or RCU read lock.
  */
-struct vport *ovs_vport_locate(const char *name)
+struct vport *ovs_vport_locate(struct net *net, const char *name)
 {
-	struct hlist_head *bucket = hash_bucket(name);
+	struct hlist_head *bucket = hash_bucket(net, name);
 	struct vport *vport;
 	struct hlist_node *node;
 
 	hlist_for_each_entry_rcu(vport, node, bucket, hash_node)
-		if (!strcmp(name, vport->ops->get_name(vport)))
+		if (!strcmp(name, vport->ops->get_name(vport)) &&
+		    net_eq(ovs_dp_get_net(vport->dp), net))
 			return vport;
 
 	return NULL;
@@ -170,14 +173,17 @@ struct vport *ovs_vport_add(const struct vport_parms *parms)
 
 	for (i = 0; i < ARRAY_SIZE(vport_ops_list); i++) {
 		if (vport_ops_list[i]->type == parms->type) {
+			struct hlist_head *bucket;
+
 			vport = vport_ops_list[i]->create(parms);
 			if (IS_ERR(vport)) {
 				err = PTR_ERR(vport);
 				goto out;
 			}
 
-			hlist_add_head_rcu(&vport->hash_node,
-					   hash_bucket(vport->ops->get_name(vport)));
+			bucket = hash_bucket(ovs_dp_get_net(vport->dp),
+					     vport->ops->get_name(vport));
+			hlist_add_head_rcu(&vport->hash_node, bucket);
 			return vport;
 		}
 	}
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index aac680c..97cef08 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -20,6 +20,7 @@
 #define VPORT_H 1
 
 #include <linux/list.h>
+#include <linux/netlink.h>
 #include <linux/openvswitch.h>
 #include <linux/skbuff.h>
 #include <linux/spinlock.h>
@@ -38,7 +39,7 @@ void ovs_vport_exit(void);
 struct vport *ovs_vport_add(const struct vport_parms *);
 void ovs_vport_del(struct vport *);
 
-struct vport *ovs_vport_locate(const char *name);
+struct vport *ovs_vport_locate(struct net *net, const char *name);
 
 void ovs_vport_get_stats(struct vport *, struct ovs_vport_stats *);
 
-- 
1.7.9.5
