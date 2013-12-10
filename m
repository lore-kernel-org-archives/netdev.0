From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] net: ovs: use kfree_rcu instead of rcu_free_{sw_flow_mask_cb,acts_callback}
Date: Tue, 10 Dec 2013 12:02:03 +0100
Message-ID: <1386673323-17101-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33105 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751698Ab3LJLCG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Dec 2013 06:02:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As we're only doing a kfree() anyway in the RCU callback, we can
simply use kfree_rcu, which does the same job, and remove the
function rcu_free_sw_flow_mask_cb() and rcu_free_acts_callback().

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/openvswitch/flow_netlink.c | 10 +---------
 net/openvswitch/flow_table.c   |  9 +--------
 2 files changed, 2 insertions(+), 17 deletions(-)

diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 2bc1bc1..0f37d87 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -1128,19 +1128,11 @@ struct sw_flow_actions *ovs_nla_alloc_flow_actions(int size)
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
index 262d7ca..edec2b0 100644
--- a/net/openvswitch/flow_table.c
+++ b/net/openvswitch/flow_table.c
@@ -131,13 +131,6 @@ static void rcu_free_flow_callback(struct rcu_head *rcu)
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
@@ -149,7 +142,7 @@ static void flow_mask_del_ref(struct sw_flow_mask *mask, bool deferred)
 	if (!mask->ref_count) {
 		list_del_rcu(&mask->list);
 		if (deferred)
-			call_rcu(&mask->rcu, rcu_free_sw_flow_mask_cb);
+			kfree_rcu(mask, rcu);
 		else
 			kfree(mask);
 	}
-- 
1.8.3.1
