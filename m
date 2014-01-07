From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 04/17] openvswitch: Silence RCU lockdep
	checks from flow lookup.
Date: Mon,  6 Jan 2014 16:16:03 -0800
Message-ID: <1389053776-62865-5-git-send-email-jesse@nicira.com>
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

Flow lookup can happen either in packet processing context or userspace
context but it was annotated as requiring RCU read lock to be held. This
also allows OVS mutex to be held without causing warnings.

Reported-by: Justin Pettit <jpettit-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Reviewed-by: Thomas Graf <tgraf-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/datapath.c   | 3 +--
 net/openvswitch/datapath.h   | 2 ++
 net/openvswitch/flow_table.c | 2 +-
 3 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index fcaed98..0727aaa 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -701,8 +701,7 @@ static int ovs_flow_cmd_fill_info(struct sw_flow *flow, struct datapath *dp,
 	if (start) {
 		const struct sw_flow_actions *sf_acts;
 
-		sf_acts = rcu_dereference_check(flow->sf_acts,
-						lockdep_ovsl_is_held());
+		sf_acts = rcu_dereference_ovsl(flow->sf_acts);
 
 		err = ovs_nla_put_actions(sf_acts->actions,
 					  sf_acts->actions_len, skb);
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index 4067ea4..ba13be4 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -145,6 +145,8 @@ int lockdep_ovsl_is_held(void);
 #define ASSERT_OVSL()		WARN_ON(unlikely(!lockdep_ovsl_is_held()))
 #define ovsl_dereference(p)					\
 	rcu_dereference_protected(p, lockdep_ovsl_is_held())
+#define rcu_dereference_ovsl(p)					\
+	rcu_dereference_check(p, lockdep_ovsl_is_held())
 
 static inline struct net *ovs_dp_get_net(struct datapath *dp)
 {
diff --git a/net/openvswitch/flow_table.c b/net/openvswitch/flow_table.c
index 261a54e..7b9cf2c 100644
--- a/net/openvswitch/flow_table.c
+++ b/net/openvswitch/flow_table.c
@@ -433,7 +433,7 @@ struct sw_flow *ovs_flow_tbl_lookup_stats(struct flow_table *tbl,
 				    const struct sw_flow_key *key,
 				    u32 *n_mask_hit)
 {
-	struct table_instance *ti = rcu_dereference(tbl->ti);
+	struct table_instance *ti = rcu_dereference_ovsl(tbl->ti);
 	struct sw_flow_mask *mask;
 	struct sw_flow *flow;
 
-- 
1.8.3.2
