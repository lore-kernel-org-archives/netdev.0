From: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 02/13] openvswitch: Avoid assigning a
	NULL pointer to flow actions.
Date: Tue, 20 May 2014 01:59:53 -0700
Message-ID: <1400576393-2229-1-git-send-email-pshelar@nicira.com>
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

Flow SET can accept an empty set of actions, with the intended
semantics of leaving existing actions unmodified.  This seems to have
been brokin after OVS 1.7, as we have assigned the flow's actions
pointer to NULL in this case, but we never check for the NULL pointer
later on.  This patch restores the intended behavior and documents it
in the include/linux/openvswitch.h.

Signed-off-by: Jarno Rajahalme <jrajahalme-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 include/uapi/linux/openvswitch.h |  4 +++-
 net/openvswitch/datapath.c       | 14 ++++++++------
 2 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 970553c..0b979ee 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -395,7 +395,9 @@ struct ovs_key_nd {
  * @OVS_FLOW_ATTR_ACTIONS: Nested %OVS_ACTION_ATTR_* attributes specifying
  * the actions to take for packets that match the key.  Always present in
  * notifications.  Required for %OVS_FLOW_CMD_NEW requests, optional for
- * %OVS_FLOW_CMD_SET requests.
+ * %OVS_FLOW_CMD_SET requests.  An %OVS_FLOW_CMD_SET without
+ * %OVS_FLOW_ATTR_ACTIONS will not modify the actions.  To clear the actions,
+ * an %OVS_FLOW_ATTR_ACTIONS without any nested attributes must be given.
  * @OVS_FLOW_ATTR_STATS: &struct ovs_flow_stats giving statistics for this
  * flow.  Present in notifications if the stats would be nonzero.  Ignored in
  * requests.
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 8867d7e..90a1e5e 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -810,6 +810,7 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 			goto err_kfree;
 		}
 	} else if (info->genlhdr->cmd == OVS_FLOW_CMD_NEW) {
+		/* OVS_FLOW_CMD_NEW must have actions. */
 		error = -EINVAL;
 		goto error;
 	}
@@ -849,8 +850,6 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 		reply = ovs_flow_cmd_build_info(flow, dp, info, OVS_FLOW_CMD_NEW);
 	} else {
 		/* We found a matching flow. */
-		struct sw_flow_actions *old_acts;
-
 		/* Bail out if we're not allowed to modify an existing flow.
 		 * We accept NLM_F_CREATE in place of the intended NLM_F_EXCL
 		 * because Generic Netlink treats the latter as a dump
@@ -866,11 +865,14 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 		if (!ovs_flow_cmp_unmasked_key(flow, &match))
 			goto err_unlock_ovs;
 
-		/* Update actions. */
-		old_acts = ovsl_dereference(flow->sf_acts);
-		rcu_assign_pointer(flow->sf_acts, acts);
-		ovs_nla_free_flow_actions(old_acts);
+		/* Update actions, if present. */
+		if (acts) {
+			struct sw_flow_actions *old_acts;
 
+			old_acts = ovsl_dereference(flow->sf_acts);
+			rcu_assign_pointer(flow->sf_acts, acts);
+			ovs_nla_free_flow_actions(old_acts);
+		}
 		reply = ovs_flow_cmd_build_info(flow, dp, info, OVS_FLOW_CMD_NEW);
 
 		/* Clear stats. */
-- 
1.9.0
