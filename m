From: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 10/13] openvswitch: Minimize
	ovs_flow_cmd_del critical section.
Date: Tue, 20 May 2014 02:00:40 -0700
Message-ID: <1400576440-2464-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Jarno Rajahalme <jrajahalme-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>

ovs_flow_cmd_del() now allocates reply (if needed) after the flow has
already been removed from the flow table.  If the reply allocation
fails, a netlink error is signaled with netlink_set_err(), as is
already done in ovs_flow_cmd_new_or_set() in the similar situation.

Signed-off-by: Jarno Rajahalme <jrajahalme-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/datapath.c | 53 ++++++++++++++++++++++++----------------------
 1 file changed, 28 insertions(+), 25 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 949fc7f..f28beda 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -984,50 +984,53 @@ static int ovs_flow_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	struct sw_flow_match match;
 	int err;
 
+	if (likely(a[OVS_FLOW_ATTR_KEY])) {
+		ovs_match_init(&match, &key, NULL);
+		err = ovs_nla_get_match(&match, a[OVS_FLOW_ATTR_KEY], NULL);
+		if (unlikely(err))
+			return err;
+	}
+
 	ovs_lock();
 	dp = get_dp(sock_net(skb->sk), ovs_header->dp_ifindex);
-	if (!dp) {
+	if (unlikely(!dp)) {
 		err = -ENODEV;
 		goto unlock;
 	}
 
-	if (!a[OVS_FLOW_ATTR_KEY]) {
+	if (unlikely(!a[OVS_FLOW_ATTR_KEY])) {
 		err = ovs_flow_tbl_flush(&dp->table);
 		goto unlock;
 	}
 
-	ovs_match_init(&match, &key, NULL);
-	err = ovs_nla_get_match(&match, a[OVS_FLOW_ATTR_KEY], NULL);
-	if (err)
-		goto unlock;
-
 	flow = ovs_flow_tbl_lookup(&dp->table, &key);
-	if (!flow || !ovs_flow_cmp_unmasked_key(flow, &match)) {
+	if (unlikely(!flow || !ovs_flow_cmp_unmasked_key(flow, &match))) {
 		err = -ENOENT;
 		goto unlock;
 	}
 
-	reply = ovs_flow_cmd_alloc_info(ovsl_dereference(flow->sf_acts), info,
-					false);
-	if (IS_ERR(reply)) {
-		err = PTR_ERR(reply);
-		goto unlock;
-	}
-
 	ovs_flow_tbl_remove(&dp->table, flow);
+	ovs_unlock();
 
-	if (reply) {
-		err = ovs_flow_cmd_fill_info(flow, ovs_header->dp_ifindex,
-					     reply, info->snd_portid,
-					     info->snd_seq, 0,
-					     OVS_FLOW_CMD_DEL);
-		BUG_ON(err < 0);
+	reply = ovs_flow_cmd_alloc_info((const struct sw_flow_actions __force *) flow->sf_acts,
+					info, false);
+	if (likely(reply)) {
+		if (likely(!IS_ERR(reply))) {
+			rcu_read_lock();	/*To keep RCU checker happy. */
+			err = ovs_flow_cmd_fill_info(flow, ovs_header->dp_ifindex,
+						     reply, info->snd_portid,
+						     info->snd_seq, 0,
+						     OVS_FLOW_CMD_DEL);
+			rcu_read_unlock();
+			BUG_ON(err < 0);
+
+			ovs_notify(&dp_flow_genl_family, reply, info);
+		} else {
+			netlink_set_err(sock_net(skb->sk)->genl_sock, 0, 0, PTR_ERR(reply));
+		}
 	}
-	ovs_flow_free(flow, true);
-	ovs_unlock();
 
-	if (reply)
-		ovs_notify(&dp_flow_genl_family, reply, info);
+	ovs_flow_free(flow, true);
 	return 0;
 unlock:
 	ovs_unlock();
-- 
1.9.0
