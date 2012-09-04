From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 2/2] openvswitch: Increase maximum number
	of datapath ports.
Date: Tue,  4 Sep 2012 12:14:09 -0700
Message-ID: <1346786049-3100-3-git-send-email-jesse@nicira.com>
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

Use hash table to store ports of datapath. Allow 64K ports per switch.

Signed-off-by: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/actions.c  |    2 +-
 net/openvswitch/datapath.c |  110 +++++++++++++++++++++++++++++++-------------
 net/openvswitch/datapath.h |   33 ++++++++++---
 net/openvswitch/flow.c     |   11 ++---
 net/openvswitch/flow.h     |    3 +-
 net/openvswitch/vport.c    |    1 +
 net/openvswitch/vport.h    |    4 +-
 7 files changed, 113 insertions(+), 51 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index f3f96ba..0da6877 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -266,7 +266,7 @@ static int do_output(struct datapath *dp, struct sk_buff *skb, int out_port)
 	if (unlikely(!skb))
 		return -ENOMEM;
 
-	vport = rcu_dereference(dp->ports[out_port]);
+	vport = ovs_vport_rcu(dp, out_port);
 	if (unlikely(!vport)) {
 		kfree_skb(skb);
 		return -ENODEV;
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index cad39fc..105a0b5 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -116,7 +116,7 @@ static struct datapath *get_dp(struct net *net, int dp_ifindex)
 /* Must be called with rcu_read_lock or RTNL lock. */
 const char *ovs_dp_name(const struct datapath *dp)
 {
-	struct vport *vport = rcu_dereference_rtnl(dp->ports[OVSP_LOCAL]);
+	struct vport *vport = ovs_vport_rtnl_rcu(dp, OVSP_LOCAL);
 	return vport->ops->get_name(vport);
 }
 
@@ -127,7 +127,7 @@ static int get_dpifindex(struct datapath *dp)
 
 	rcu_read_lock();
 
-	local = rcu_dereference(dp->ports[OVSP_LOCAL]);
+	local = ovs_vport_rcu(dp, OVSP_LOCAL);
 	if (local)
 		ifindex = local->ops->get_ifindex(local);
 	else
@@ -145,9 +145,30 @@ static void destroy_dp_rcu(struct rcu_head *rcu)
 	ovs_flow_tbl_destroy((__force struct flow_table *)dp->table);
 	free_percpu(dp->stats_percpu);
 	release_net(ovs_dp_get_net(dp));
+	kfree(dp->ports);
 	kfree(dp);
 }
 
+static struct hlist_head *vport_hash_bucket(const struct datapath *dp,
+					    u16 port_no)
+{
+	return &dp->ports[port_no & (DP_VPORT_HASH_BUCKETS - 1)];
+}
+
+struct vport *ovs_lookup_vport(const struct datapath *dp, u16 port_no)
+{
+	struct vport *vport;
+	struct hlist_node *n;
+	struct hlist_head *head;
+
+	head = vport_hash_bucket(dp, port_no);
+	hlist_for_each_entry_rcu(vport, n, head, dp_hash_node) {
+		if (vport->port_no == port_no)
+			return vport;
+	}
+	return NULL;
+}
+
 /* Called with RTNL lock and genl_lock. */
 static struct vport *new_vport(const struct vport_parms *parms)
 {
@@ -156,9 +177,9 @@ static struct vport *new_vport(const struct vport_parms *parms)
 	vport = ovs_vport_add(parms);
 	if (!IS_ERR(vport)) {
 		struct datapath *dp = parms->dp;
+		struct hlist_head *head = vport_hash_bucket(dp, vport->port_no);
 
-		rcu_assign_pointer(dp->ports[parms->port_no], vport);
-		list_add(&vport->node, &dp->port_list);
+		hlist_add_head_rcu(&vport->dp_hash_node, head);
 	}
 
 	return vport;
@@ -170,8 +191,7 @@ void ovs_dp_detach_port(struct vport *p)
 	ASSERT_RTNL();
 
 	/* First drop references to device. */
-	list_del(&p->node);
-	rcu_assign_pointer(p->dp->ports[p->port_no], NULL);
+	hlist_del_rcu(&p->dp_hash_node);
 
 	/* Then destroy it. */
 	ovs_vport_del(p);
@@ -1248,7 +1268,7 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 	struct datapath *dp;
 	struct vport *vport;
 	struct ovs_net *ovs_net;
-	int err;
+	int err, i;
 
 	err = -EINVAL;
 	if (!a[OVS_DP_ATTR_NAME] || !a[OVS_DP_ATTR_UPCALL_PID])
@@ -1261,7 +1281,6 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 	if (dp == NULL)
 		goto err_unlock_rtnl;
 
-	INIT_LIST_HEAD(&dp->port_list);
 	ovs_dp_set_net(dp, hold_net(sock_net(skb->sk)));
 
 	/* Allocate table. */
@@ -1276,6 +1295,16 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 		goto err_destroy_table;
 	}
 
+	dp->ports = kmalloc(DP_VPORT_HASH_BUCKETS * sizeof(struct hlist_head),
+			GFP_KERNEL);
+	if (!dp->ports) {
+		err = -ENOMEM;
+		goto err_destroy_percpu;
+	}
+
+	for (i = 0; i < DP_VPORT_HASH_BUCKETS; i++)
+		INIT_HLIST_HEAD(&dp->ports[i]);
+
 	/* Set up our datapath device. */
 	parms.name = nla_data(a[OVS_DP_ATTR_NAME]);
 	parms.type = OVS_VPORT_TYPE_INTERNAL;
@@ -1290,7 +1319,7 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 		if (err == -EBUSY)
 			err = -EEXIST;
 
-		goto err_destroy_percpu;
+		goto err_destroy_ports_array;
 	}
 
 	reply = ovs_dp_cmd_build_info(dp, info->snd_pid,
@@ -1309,7 +1338,9 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 	return 0;
 
 err_destroy_local_port:
-	ovs_dp_detach_port(rtnl_dereference(dp->ports[OVSP_LOCAL]));
+	ovs_dp_detach_port(ovs_vport_rtnl(dp, OVSP_LOCAL));
+err_destroy_ports_array:
+	kfree(dp->ports);
 err_destroy_percpu:
 	free_percpu(dp->stats_percpu);
 err_destroy_table:
@@ -1326,15 +1357,21 @@ err:
 /* Called with genl_mutex. */
 static void __dp_destroy(struct datapath *dp)
 {
-	struct vport *vport, *next_vport;
+	int i;
 
 	rtnl_lock();
-	list_for_each_entry_safe(vport, next_vport, &dp->port_list, node)
-		if (vport->port_no != OVSP_LOCAL)
-			ovs_dp_detach_port(vport);
+
+	for (i = 0; i < DP_VPORT_HASH_BUCKETS; i++) {
+		struct vport *vport;
+		struct hlist_node *node, *n;
+
+		hlist_for_each_entry_safe(vport, node, n, &dp->ports[i], dp_hash_node)
+			if (vport->port_no != OVSP_LOCAL)
+				ovs_dp_detach_port(vport);
+	}
 
 	list_del(&dp->list_node);
-	ovs_dp_detach_port(rtnl_dereference(dp->ports[OVSP_LOCAL]));
+	ovs_dp_detach_port(ovs_vport_rtnl(dp, OVSP_LOCAL));
 
 	/* rtnl_unlock() will wait until all the references to devices that
 	 * are pending unregistration have been dropped.  We do it here to
@@ -1566,7 +1603,7 @@ static struct vport *lookup_vport(struct net *net,
 		if (!dp)
 			return ERR_PTR(-ENODEV);
 
-		vport = rcu_dereference_rtnl(dp->ports[port_no]);
+		vport = ovs_vport_rtnl_rcu(dp, port_no);
 		if (!vport)
 			return ERR_PTR(-ENOENT);
 		return vport;
@@ -1603,7 +1640,7 @@ static int ovs_vport_cmd_new(struct sk_buff *skb, struct genl_info *info)
 		if (port_no >= DP_MAX_PORTS)
 			goto exit_unlock;
 
-		vport = rtnl_dereference(dp->ports[port_no]);
+		vport = ovs_vport_rtnl_rcu(dp, port_no);
 		err = -EBUSY;
 		if (vport)
 			goto exit_unlock;
@@ -1613,7 +1650,7 @@ static int ovs_vport_cmd_new(struct sk_buff *skb, struct genl_info *info)
 				err = -EFBIG;
 				goto exit_unlock;
 			}
-			vport = rtnl_dereference(dp->ports[port_no]);
+			vport = ovs_vport_rtnl(dp, port_no);
 			if (!vport)
 				break;
 		}
@@ -1755,32 +1792,39 @@ static int ovs_vport_cmd_dump(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	struct ovs_header *ovs_header = genlmsg_data(nlmsg_data(cb->nlh));
 	struct datapath *dp;
-	u32 port_no;
-	int retval;
+	int bucket = cb->args[0], skip = cb->args[1];
+	int i, j = 0;
 
 	dp = get_dp(sock_net(skb->sk), ovs_header->dp_ifindex);
 	if (!dp)
 		return -ENODEV;
 
 	rcu_read_lock();
-	for (port_no = cb->args[0]; port_no < DP_MAX_PORTS; port_no++) {
+	for (i = bucket; i < DP_VPORT_HASH_BUCKETS; i++) {
 		struct vport *vport;
-
-		vport = rcu_dereference(dp->ports[port_no]);
-		if (!vport)
-			continue;
-
-		if (ovs_vport_cmd_fill_info(vport, skb, NETLINK_CB(cb->skb).pid,
-					    cb->nlh->nlmsg_seq, NLM_F_MULTI,
-					    OVS_VPORT_CMD_NEW) < 0)
-			break;
+		struct hlist_node *n;
+
+		j = 0;
+		hlist_for_each_entry_rcu(vport, n, &dp->ports[i], dp_hash_node) {
+			if (j >= skip &&
+			    ovs_vport_cmd_fill_info(vport, skb,
+						    NETLINK_CB(cb->skb).pid,
+						    cb->nlh->nlmsg_seq,
+						    NLM_F_MULTI,
+						    OVS_VPORT_CMD_NEW) < 0)
+				goto out;
+
+			j++;
+		}
+		skip = 0;
 	}
+out:
 	rcu_read_unlock();
 
-	cb->args[0] = port_no;
-	retval = skb->len;
+	cb->args[0] = i;
+	cb->args[1] = j;
 
-	return retval;
+	return skb->len;
 }
 
 static struct genl_ops dp_vport_genl_ops[] = {
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index 771c11e..129ec54 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -29,7 +29,9 @@
 #include "flow.h"
 #include "vport.h"
 
-#define DP_MAX_PORTS 1024
+#define DP_MAX_PORTS           USHRT_MAX
+#define DP_VPORT_HASH_BUCKETS  1024
+
 #define SAMPLE_ACTION_DEPTH 3
 
 /**
@@ -57,10 +59,8 @@ struct dp_stats_percpu {
  * @list_node: Element in global 'dps' list.
  * @n_flows: Number of flows currently in flow table.
  * @table: Current flow table.  Protected by genl_lock and RCU.
- * @ports: Map from port number to &struct vport.  %OVSP_LOCAL port
- * always exists, other ports may be %NULL.  Protected by RTNL and RCU.
- * @port_list: List of all ports in @ports in arbitrary order.  RTNL required
- * to iterate or modify.
+ * @ports: Hash table for ports.  %OVSP_LOCAL port always exists.  Protected by
+ * RTNL and RCU.
  * @stats_percpu: Per-CPU datapath statistics.
  * @net: Reference to net namespace.
  *
@@ -75,8 +75,7 @@ struct datapath {
 	struct flow_table __rcu *table;
 
 	/* Switch ports. */
-	struct vport __rcu *ports[DP_MAX_PORTS];
-	struct list_head port_list;
+	struct hlist_head *ports;
 
 	/* Stats. */
 	struct dp_stats_percpu __percpu *stats_percpu;
@@ -87,6 +86,26 @@ struct datapath {
 #endif
 };
 
+struct vport *ovs_lookup_vport(const struct datapath *dp, u16 port_no);
+
+static inline struct vport *ovs_vport_rcu(const struct datapath *dp, int port_no)
+{
+	WARN_ON_ONCE(!rcu_read_lock_held());
+	return ovs_lookup_vport(dp, port_no);
+}
+
+static inline struct vport *ovs_vport_rtnl_rcu(const struct datapath *dp, int port_no)
+{
+	WARN_ON_ONCE(!rcu_read_lock_held() && !rtnl_is_locked());
+	return ovs_lookup_vport(dp, port_no);
+}
+
+static inline struct vport *ovs_vport_rtnl(const struct datapath *dp, int port_no)
+{
+	ASSERT_RTNL();
+	return ovs_lookup_vport(dp, port_no);
+}
+
 /**
  * struct ovs_skb_cb - OVS data in skb CB
  * @flow: The flow associated with this packet.  May be %NULL if no flow.
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index b7f38b1..f9f211d 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -203,10 +203,7 @@ struct sw_flow_actions *ovs_flow_actions_alloc(const struct nlattr *actions)
 	int actions_len = nla_len(actions);
 	struct sw_flow_actions *sfa;
 
-	/* At least DP_MAX_PORTS actions are required to be able to flood a
-	 * packet to every port.  Factor of 2 allows for setting VLAN tags,
-	 * etc. */
-	if (actions_len > 2 * DP_MAX_PORTS * nla_total_size(4))
+	if (actions_len > MAX_ACTIONS_BUFSIZE)
 		return ERR_PTR(-EINVAL);
 
 	sfa = kmalloc(sizeof(*sfa) + actions_len, GFP_KERNEL);
@@ -1000,7 +997,7 @@ int ovs_flow_from_nlattrs(struct sw_flow_key *swkey, int *key_lenp,
 		swkey->phy.in_port = in_port;
 		attrs &= ~(1 << OVS_KEY_ATTR_IN_PORT);
 	} else {
-		swkey->phy.in_port = USHRT_MAX;
+		swkey->phy.in_port = DP_MAX_PORTS;
 	}
 
 	/* Data attributes. */
@@ -1143,7 +1140,7 @@ int ovs_flow_metadata_from_nlattrs(u32 *priority, u16 *in_port,
 	const struct nlattr *nla;
 	int rem;
 
-	*in_port = USHRT_MAX;
+	*in_port = DP_MAX_PORTS;
 	*priority = 0;
 
 	nla_for_each_nested(nla, attr, rem) {
@@ -1180,7 +1177,7 @@ int ovs_flow_to_nlattrs(const struct sw_flow_key *swkey, struct sk_buff *skb)
 	    nla_put_u32(skb, OVS_KEY_ATTR_PRIORITY, swkey->phy.priority))
 		goto nla_put_failure;
 
-	if (swkey->phy.in_port != USHRT_MAX &&
+	if (swkey->phy.in_port != DP_MAX_PORTS &&
 	    nla_put_u32(skb, OVS_KEY_ATTR_IN_PORT, swkey->phy.in_port))
 		goto nla_put_failure;
 
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index 9b75617..d92e22a 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -43,7 +43,7 @@ struct sw_flow_actions {
 struct sw_flow_key {
 	struct {
 		u32	priority;	/* Packet QoS priority. */
-		u16	in_port;	/* Input switch port (or USHRT_MAX). */
+		u16	in_port;	/* Input switch port (or DP_MAX_PORTS). */
 	} phy;
 	struct {
 		u8     src[ETH_ALEN];	/* Ethernet source address. */
@@ -161,6 +161,7 @@ int ovs_flow_from_nlattrs(struct sw_flow_key *swkey, int *key_lenp,
 int ovs_flow_metadata_from_nlattrs(u32 *priority, u16 *in_port,
 			       const struct nlattr *);
 
+#define MAX_ACTIONS_BUFSIZE    (16 * 1024)
 #define TBL_MIN_BUCKETS		1024
 
 struct flow_table {
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 9873ace..1abd960 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -127,6 +127,7 @@ struct vport *ovs_vport_alloc(int priv_size, const struct vport_ops *ops,
 	vport->port_no = parms->port_no;
 	vport->upcall_pid = parms->upcall_pid;
 	vport->ops = ops;
+	INIT_HLIST_NODE(&vport->dp_hash_node);
 
 	vport->percpu_stats = alloc_percpu(struct vport_percpu_stats);
 	if (!vport->percpu_stats) {
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index 97cef08..c56e483 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -70,10 +70,10 @@ struct vport_err_stats {
  * @rcu: RCU callback head for deferred destruction.
  * @port_no: Index into @dp's @ports array.
  * @dp: Datapath to which this port belongs.
- * @node: Element in @dp's @port_list.
  * @upcall_pid: The Netlink port to use for packets received on this port that
  * miss the flow table.
  * @hash_node: Element in @dev_table hash table in vport.c.
+ * @dp_hash_node: Element in @datapath->ports hash table in datapath.c.
  * @ops: Class structure.
  * @percpu_stats: Points to per-CPU statistics used and maintained by vport
  * @stats_lock: Protects @err_stats;
@@ -83,10 +83,10 @@ struct vport {
 	struct rcu_head rcu;
 	u16 port_no;
 	struct datapath	*dp;
-	struct list_head node;
 	u32 upcall_pid;
 
 	struct hlist_node hash_node;
+	struct hlist_node dp_hash_node;
 	const struct vport_ops *ops;
 
 	struct vport_percpu_stats __percpu *percpu_stats;
-- 
1.7.9.5
