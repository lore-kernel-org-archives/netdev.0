From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 09/17] net: ovs: use kfree_rcu instead of
	rcu_free_{sw_flow_mask_cb, acts_callback}
Date: Mon,  6 Jan 2014 16:16:08 -0800
Message-ID: <1389053776-62865-10-git-send-email-jesse@nicira.com>
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

From: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

As we're only doing a kfree() anyway in the RCU callback, we can
simply use kfree_rcu, which does the same job, and remove the
function rcu_free_sw_flow_mask_cb() and rcu_free_acts_callback().

Signed-off-by: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/flow_netlink.c | 10 +---------
 net/openvswitch/flow_table.c   |  9 +--------
 2 files changed, 2 insertions(+), 17 deletions(-)

diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 3ccb92f..4d000ac 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -1176,19 +1176,11 @@ struct sw_flow_actions *ovs_nla_alloc_flow_actions(int size)
 	return sfa;
 }
 
-/* RCU callback used by ovs_nla_free_flow_actions. */
-static void rcu_free_acts_callback(struct rcu_head *rcu)
-{
-	struct sw_flow_actions *sf_acts = container_of(rcu,
-			struct sw_flow_actions, rcu);
-	kfree(sf_acts);
-}
-
 /* Schedules 'sf_acts' to be freed after the next RCU grace period.
  * The caller must hold rcu_read_lock for this to be sensible. */
 void ovs_nla_free_flow_actions(struct sw_flow_actions *sf_acts)
 {
-	call_rcu(&sf_acts->rcu, rcu_free_acts_callback);
+	kfree_rcu(sf_acts, rcu);
 }
 
 static struct nlattr *reserve_sfa_size(struct sw_flow_actions **sfa,
diff --git a/net/openvswitch/flow_table.c b/net/openvswitch/flow_table.c
index 299ea8b..099a1a9 100644
--- a/net/openvswitch/flow_table.c
+++ b/net/openvswitch/flow_table.c
@@ -155,13 +155,6 @@ static void rcu_free_flow_callback(struct rcu_head *rcu)
 	flow_free(flow);
 }
 
-static void rcu_free_sw_flow_mask_cb(struct rcu_head *rcu)
-{
-	struct sw_flow_mask *mask = container_of(rcu, struct sw_flow_mask, rcu);
-
-	kfree(mask);
-}
-
 static void flow_mask_del_ref(struct sw_flow_mask *mask, bool deferred)
 {
 	if (!mask)
@@ -173,7 +166,7 @@ static void flow_mask_del_ref(struct sw_flow_mask *mask, bool deferred)
 	if (!mask->ref_count) {
 		list_del_rcu(&mask->list);
 		if (deferred)
-			call_rcu(&mask->rcu, rcu_free_sw_flow_mask_cb);
+			kfree_rcu(mask, rcu);
 		else
 			kfree(mask);
 	}
-- 
1.8.3.2
