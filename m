From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net v4] ovs: limit ovs recursions in ovs_execute_actions to not corrupt stack
Date: Fri, 15 Jan 2016 17:51:15 +0100
Message-ID: <1452876675-19834-1-git-send-email-hannes@stressinduktion.org>
Cc: Pravin Shelar <pshelar@ovn.org>,
	Simon Horman <simon.horman@netronome.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:46976 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753421AbcAOQvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2016 11:51:23 -0500
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id D143920426
	for <netdev@vger.kernel.org>; Fri, 15 Jan 2016 11:51:22 -0500 (EST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It was seen that defective configurations of openvswitch could overwrite
the STACK_END_MAGIC and cause a hard crash of the kernel because of too
many recursions within ovs.

This problem arises due to the high stack usage of openvswitch. The rest
of the kernel is fine with the current limit of 10 (RECURSION_LIMIT).

We use the already existing recursion counter in ovs_execute_actions to
implement an upper bound of 5 recursions.

Cc: Pravin Shelar <pshelar@ovn.org>
Cc: Simon Horman <simon.horman@netronome.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
v2) added preemption guards
v3) Pravin suggested to reuse the ovs_execute_actions counter which this
    patch does. Also only allow 5 recursions as suggested by Pravin.
v4) added unlikely as suggested by Eric

Thanks to all reviewers!

 net/openvswitch/actions.c | 21 ++++++++++++++++-----
 1 file changed, 16 insertions(+), 5 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index c88d0f2d3e019b..da66f9e1660dbb 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -1160,17 +1160,28 @@ int ovs_execute_actions(struct datapath *dp, struct sk_buff *skb,
 			const struct sw_flow_actions *acts,
 			struct sw_flow_key *key)
 {
-	int level = this_cpu_read(exec_actions_level);
-	int err;
+	static const int ovs_recursion_limit = 5;
+	int err, level;
+
+	preempt_disable();
+	level = __this_cpu_inc_return(exec_actions_level);
+	if (unlikely(level > ovs_recursion_limit)) {
+		net_crit_ratelimited("ovs: recursion limit reached on datapath %s, probable configuration error\n",
+				     ovs_dp_name(dp));
+		kfree_skb(skb);
+		err = -ENETDOWN;
+		goto out;
+	}
 
-	this_cpu_inc(exec_actions_level);
 	err = do_execute_actions(dp, skb, key,
 				 acts->actions, acts->actions_len);
 
-	if (!level)
+	if (level == 1)
 		process_deferred_actions(dp);
 
-	this_cpu_dec(exec_actions_level);
+out:
+	__this_cpu_dec(exec_actions_level);
+	preempt_enable();
 	return err;
 }
 
-- 
2.5.0
