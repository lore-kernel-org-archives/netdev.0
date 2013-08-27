From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 01/11] openvswitch: Use RCU lock for flow
	dump operation.
Date: Tue, 27 Aug 2013 13:20:38 -0700
Message-ID: <1377634848-34327-2-git-send-email-jesse@nicira.com>
References: <1377634848-34327-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1377634848-34327-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
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

Flow dump operation is read-only operation.  There is no need to
take ovs-lock.  Following patch use rcu-lock for dumping flows.

Signed-off-by: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/datapath.c | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index f2ed760..e6fb866 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -1104,7 +1104,6 @@ static int ovs_flow_cmd_fill_info(struct sw_flow *flow, struct datapath *dp,
 				  u32 seq, u32 flags, u8 cmd)
 {
 	const int skb_orig_len = skb->len;
-	const struct sw_flow_actions *sf_acts;
 	struct nlattr *start;
 	struct ovs_flow_stats stats;
 	struct ovs_header *ovs_header;
@@ -1113,8 +1112,6 @@ static int ovs_flow_cmd_fill_info(struct sw_flow *flow, struct datapath *dp,
 	u8 tcp_flags;
 	int err;
 
-	sf_acts = ovsl_dereference(flow->sf_acts);
-
 	ovs_header = genlmsg_put(skb, portid, seq, &dp_flow_genl_family, flags, cmd);
 	if (!ovs_header)
 		return -EMSGSIZE;
@@ -1161,6 +1158,11 @@ static int ovs_flow_cmd_fill_info(struct sw_flow *flow, struct datapath *dp,
 	 */
 	start = nla_nest_start(skb, OVS_FLOW_ATTR_ACTIONS);
 	if (start) {
+		const struct sw_flow_actions *sf_acts;
+
+		sf_acts = rcu_dereference_check(flow->sf_acts,
+						lockdep_ovsl_is_held());
+
 		err = actions_to_attr(sf_acts->actions, sf_acts->actions_len, skb);
 		if (!err)
 			nla_nest_end(skb, start);
@@ -1440,15 +1442,14 @@ static int ovs_flow_cmd_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	struct datapath *dp;
 	struct flow_table *table;
 
-	ovs_lock();
+	rcu_read_lock();
 	dp = get_dp(sock_net(skb->sk), ovs_header->dp_ifindex);
 	if (!dp) {
-		ovs_unlock();
+		rcu_read_unlock();
 		return -ENODEV;
 	}
 
-	table = ovsl_dereference(dp->table);
-
+	table = rcu_dereference(dp->table);
 	for (;;) {
 		struct sw_flow *flow;
 		u32 bucket, obj;
@@ -1468,7 +1469,7 @@ static int ovs_flow_cmd_dump(struct sk_buff *skb, struct netlink_callback *cb)
 		cb->args[0] = bucket;
 		cb->args[1] = obj;
 	}
-	ovs_unlock();
+	rcu_read_unlock();
 	return skb->len;
 }
 
-- 
1.8.1.2
