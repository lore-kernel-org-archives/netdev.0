From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 07/17] openvswitch: Enable memory mapped
	Netlink i/o
Date: Mon,  6 Jan 2014 16:16:06 -0800
Message-ID: <1389053776-62865-8-git-send-email-jesse@nicira.com>
References: <1389053776-62865-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1389053776-62865-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
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

From: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>

Use memory mapped Netlink i/o for all unicast openvswitch
communication if a ring has been set up.

Benchmark
  * pktgen -> ovs internal port
  * 5M pkts, 5M flows
  * 4 threads, 8 cores

Before:
Result: OK: 67418743(c67108212+d310530) usec, 5000000 (9000byte,0frags)
  74163pps 5339Mb/sec (5339736000bps) errors: 0
	+   2.98%     ovs-vswitchd  [k] copy_user_generic_string
	+   2.49%     ovs-vswitchd  [k] memcpy
	+   1.84%       kpktgend_2  [k] memcpy
	+   1.81%       kpktgend_1  [k] memcpy
	+   1.81%       kpktgend_3  [k] memcpy
	+   1.78%       kpktgend_0  [k] memcpy

After:
Result: OK: 24229690(c24127165+d102524) usec, 5000000 (9000byte,0frags)
  206358pps 14857Mb/sec (14857776000bps) errors: 0
	+   2.80%     ovs-vswitchd  [k] memcpy
	+   1.31%       kpktgend_2  [k] memcpy
	+   1.23%       kpktgend_0  [k] memcpy
	+   1.09%       kpktgend_1  [k] memcpy
	+   1.04%       kpktgend_3  [k] memcpy
	+   0.96%     ovs-vswitchd  [k] copy_user_generic_string

Signed-off-by: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Reviewed-by: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/datapath.c | 56 ++++++++++++++++++++++++----------------------
 1 file changed, 29 insertions(+), 27 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 0727aaa..5da2534 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -402,6 +402,11 @@ static int queue_userspace_packet(struct net *net, int dp_ifindex,
 	struct sk_buff *nskb = NULL;
 	struct sk_buff *user_skb; /* to be queued to userspace */
 	struct nlattr *nla;
+	struct genl_info info = {
+		.dst_sk = net->genl_sock,
+		.snd_portid = upcall_info->portid,
+	};
+	size_t len;
 	int err;
 
 	if (vlan_tx_tag_present(skb)) {
@@ -422,7 +427,8 @@ static int queue_userspace_packet(struct net *net, int dp_ifindex,
 		goto out;
 	}
 
-	user_skb = genlmsg_new(upcall_msg_size(skb, upcall_info->userdata), GFP_ATOMIC);
+	len = upcall_msg_size(skb, upcall_info->userdata);
+	user_skb = genlmsg_new_unicast(len, &info, GFP_ATOMIC);
 	if (!user_skb) {
 		err = -ENOMEM;
 		goto out;
@@ -725,27 +731,30 @@ error:
 	return err;
 }
 
-static struct sk_buff *ovs_flow_cmd_alloc_info(struct sw_flow *flow)
+static struct sk_buff *ovs_flow_cmd_alloc_info(struct sw_flow *flow,
+					       struct genl_info *info)
 {
-	const struct sw_flow_actions *sf_acts;
+	size_t len;
 
-	sf_acts = ovsl_dereference(flow->sf_acts);
+	len = ovs_flow_cmd_msg_size(ovsl_dereference(flow->sf_acts));
 
-	return genlmsg_new(ovs_flow_cmd_msg_size(sf_acts), GFP_KERNEL);
+	return genlmsg_new_unicast(len, info, GFP_KERNEL);
 }
 
 static struct sk_buff *ovs_flow_cmd_build_info(struct sw_flow *flow,
 					       struct datapath *dp,
-					       u32 portid, u32 seq, u8 cmd)
+					       struct genl_info *info,
+					       u8 cmd)
 {
 	struct sk_buff *skb;
 	int retval;
 
-	skb = ovs_flow_cmd_alloc_info(flow);
+	skb = ovs_flow_cmd_alloc_info(flow, info);
 	if (!skb)
 		return ERR_PTR(-ENOMEM);
 
-	retval = ovs_flow_cmd_fill_info(flow, dp, skb, portid, seq, 0, cmd);
+	retval = ovs_flow_cmd_fill_info(flow, dp, skb, info->snd_portid,
+					info->snd_seq, 0, cmd);
 	BUG_ON(retval < 0);
 	return skb;
 }
@@ -826,8 +835,7 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 			goto err_flow_free;
 		}
 
-		reply = ovs_flow_cmd_build_info(flow, dp, info->snd_portid,
-						info->snd_seq, OVS_FLOW_CMD_NEW);
+		reply = ovs_flow_cmd_build_info(flow, dp, info, OVS_FLOW_CMD_NEW);
 	} else {
 		/* We found a matching flow. */
 		struct sw_flow_actions *old_acts;
@@ -855,8 +863,7 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 		rcu_assign_pointer(flow->sf_acts, acts);
 		ovs_nla_free_flow_actions(old_acts);
 
-		reply = ovs_flow_cmd_build_info(flow, dp, info->snd_portid,
-					       info->snd_seq, OVS_FLOW_CMD_NEW);
+		reply = ovs_flow_cmd_build_info(flow, dp, info, OVS_FLOW_CMD_NEW);
 
 		/* Clear stats. */
 		if (a[OVS_FLOW_ATTR_CLEAR]) {
@@ -918,8 +925,7 @@ static int ovs_flow_cmd_get(struct sk_buff *skb, struct genl_info *info)
 		goto unlock;
 	}
 
-	reply = ovs_flow_cmd_build_info(flow, dp, info->snd_portid,
-					info->snd_seq, OVS_FLOW_CMD_NEW);
+	reply = ovs_flow_cmd_build_info(flow, dp, info, OVS_FLOW_CMD_NEW);
 	if (IS_ERR(reply)) {
 		err = PTR_ERR(reply);
 		goto unlock;
@@ -966,7 +972,7 @@ static int ovs_flow_cmd_del(struct sk_buff *skb, struct genl_info *info)
 		goto unlock;
 	}
 
-	reply = ovs_flow_cmd_alloc_info(flow);
+	reply = ovs_flow_cmd_alloc_info(flow, info);
 	if (!reply) {
 		err = -ENOMEM;
 		goto unlock;
@@ -1118,17 +1124,17 @@ error:
 	return -EMSGSIZE;
 }
 
-static struct sk_buff *ovs_dp_cmd_build_info(struct datapath *dp, u32 portid,
-					     u32 seq, u8 cmd)
+static struct sk_buff *ovs_dp_cmd_build_info(struct datapath *dp,
+					     struct genl_info *info, u8 cmd)
 {
 	struct sk_buff *skb;
 	int retval;
 
-	skb = genlmsg_new(ovs_dp_cmd_msg_size(), GFP_KERNEL);
+	skb = genlmsg_new_unicast(ovs_dp_cmd_msg_size(), info, GFP_KERNEL);
 	if (!skb)
 		return ERR_PTR(-ENOMEM);
 
-	retval = ovs_dp_cmd_fill_info(dp, skb, portid, seq, 0, cmd);
+	retval = ovs_dp_cmd_fill_info(dp, skb, info->snd_portid, info->snd_seq, 0, cmd);
 	if (retval < 0) {
 		kfree_skb(skb);
 		return ERR_PTR(retval);
@@ -1223,8 +1229,7 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 		goto err_destroy_ports_array;
 	}
 
-	reply = ovs_dp_cmd_build_info(dp, info->snd_portid,
-				      info->snd_seq, OVS_DP_CMD_NEW);
+	reply = ovs_dp_cmd_build_info(dp, info, OVS_DP_CMD_NEW);
 	err = PTR_ERR(reply);
 	if (IS_ERR(reply))
 		goto err_destroy_local_port;
@@ -1290,8 +1295,7 @@ static int ovs_dp_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	if (IS_ERR(dp))
 		goto unlock;
 
-	reply = ovs_dp_cmd_build_info(dp, info->snd_portid,
-				      info->snd_seq, OVS_DP_CMD_DEL);
+	reply = ovs_dp_cmd_build_info(dp, info, OVS_DP_CMD_DEL);
 	err = PTR_ERR(reply);
 	if (IS_ERR(reply))
 		goto unlock;
@@ -1319,8 +1323,7 @@ static int ovs_dp_cmd_set(struct sk_buff *skb, struct genl_info *info)
 	if (IS_ERR(dp))
 		goto unlock;
 
-	reply = ovs_dp_cmd_build_info(dp, info->snd_portid,
-				      info->snd_seq, OVS_DP_CMD_NEW);
+	reply = ovs_dp_cmd_build_info(dp, info, OVS_DP_CMD_NEW);
 	if (IS_ERR(reply)) {
 		err = PTR_ERR(reply);
 		genl_set_err(&dp_datapath_genl_family, sock_net(skb->sk), 0,
@@ -1351,8 +1354,7 @@ static int ovs_dp_cmd_get(struct sk_buff *skb, struct genl_info *info)
 		goto unlock;
 	}
 
-	reply = ovs_dp_cmd_build_info(dp, info->snd_portid,
-				      info->snd_seq, OVS_DP_CMD_NEW);
+	reply = ovs_dp_cmd_build_info(dp, info, OVS_DP_CMD_NEW);
 	if (IS_ERR(reply)) {
 		err = PTR_ERR(reply);
 		goto unlock;
-- 
1.8.3.2
