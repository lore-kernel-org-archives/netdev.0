From: Wei Yongjun <weiyj.lk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] openvswitch: using kfree_rcu() to simplify the
	code
Date: Mon, 27 Aug 2012 12:20:45 +0800
Message-ID: <CAPgLHd_71Qh90j9FCkT2cQ35wNMkZeLDwHT2QLP55_3gfzfjTQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org
To: jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
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

From: Wei Yongjun <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>

The callback function of call_rcu() just calls a kfree(), so we
can use kfree_rcu() instead of call_rcu() + callback function.

spatch with a semantic match is used to found this problem.
(http://coccinelle.lip6.fr/)

Signed-off-by: Wei Yongjun <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>
---
 net/openvswitch/flow.c | 10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index b7f38b1..c7bf2f2 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -427,19 +427,11 @@ void ovs_flow_deferred_free(struct sw_flow *flow)
 	call_rcu(&flow->rcu, rcu_free_flow_callback);
 }
 
-/* RCU callback used by ovs_flow_deferred_free_acts. */
-static void rcu_free_acts_callback(struct rcu_head *rcu)
-{
-	struct sw_flow_actions *sf_acts = container_of(rcu,
-			struct sw_flow_actions, rcu);
-	kfree(sf_acts);
-}
-
 /* Schedules 'sf_acts' to be freed after the next RCU grace period.
  * The caller must hold rcu_read_lock for this to be sensible. */
 void ovs_flow_deferred_free_acts(struct sw_flow_actions *sf_acts)
 {
-	call_rcu(&sf_acts->rcu, rcu_free_acts_callback);
+	kfree_rcu(sf_acts, rcu);
 }
 
 static int parse_vlan(struct sk_buff *skb, struct sw_flow_key *key)
