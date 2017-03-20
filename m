From: Andy Zhou <azhou@ovn.org>
Subject: [net-next sample action optimization v4 1/4] openvswitch: Deferred fifo API change.
Date: Mon, 20 Mar 2017 16:32:27 -0700
Message-ID: <1490052750-60187-2-git-send-email-azhou@ovn.org>
References: <1490052750-60187-1-git-send-email-azhou@ovn.org>
Cc: joe@ovn.org, pshelar@ovn.org, Andy Zhou <azhou@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34403 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753258AbdCTXl2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 19:41:28 -0400
Received: by mail-pg0-f66.google.com with SMTP id b5so22437433pgg.1
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 16:40:18 -0700 (PDT)
In-Reply-To: <1490052750-60187-1-git-send-email-azhou@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

add_deferred_actions() API currently requires actions to be passed in
as a fully encoded netlink message. So far both 'sample' and 'recirc'
actions happens to carry actions as fully encoded netlink messages.
However, this requirement is more restrictive than necessary, future
patch will need to pass in action lists that are not fully encoded
by themselves.

Signed-off-by: Andy Zhou <azhou@ovn.org>
Acked-by: Joe Stringer <joe@ovn.org>
---
 net/openvswitch/actions.c | 18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index c82301c..75182e9 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -51,6 +51,7 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 struct deferred_action {
 	struct sk_buff *skb;
 	const struct nlattr *actions;
+	int actions_len;
 
 	/* Store pkt_key clone when creating deferred action. */
 	struct sw_flow_key pkt_key;
@@ -119,8 +120,9 @@ static struct deferred_action *action_fifo_put(struct action_fifo *fifo)
 
 /* Return true if fifo is not full */
 static struct deferred_action *add_deferred_actions(struct sk_buff *skb,
-						    const struct sw_flow_key *key,
-						    const struct nlattr *attr)
+				    const struct sw_flow_key *key,
+				    const struct nlattr *actions,
+				    const int actions_len)
 {
 	struct action_fifo *fifo;
 	struct deferred_action *da;
@@ -129,7 +131,8 @@ static struct deferred_action *add_deferred_actions(struct sk_buff *skb,
 	da = action_fifo_put(fifo);
 	if (da) {
 		da->skb = skb;
-		da->actions = attr;
+		da->actions = actions;
+		da->actions_len = actions_len;
 		da->pkt_key = *key;
 	}
 
@@ -966,7 +969,8 @@ static int sample(struct datapath *dp, struct sk_buff *skb,
 		/* Skip the sample action when out of memory. */
 		return 0;
 
-	if (!add_deferred_actions(skb, key, a)) {
+	if (!add_deferred_actions(skb, key, nla_data(acts_list),
+				  nla_len(acts_list))) {
 		if (net_ratelimit())
 			pr_warn("%s: deferred actions limit reached, dropping sample action\n",
 				ovs_dp_name(dp));
@@ -1123,7 +1127,7 @@ static int execute_recirc(struct datapath *dp, struct sk_buff *skb,
 		return 0;
 	}
 
-	da = add_deferred_actions(skb, key, NULL);
+	da = add_deferred_actions(skb, key, NULL, 0);
 	if (da) {
 		da->pkt_key.recirc_id = nla_get_u32(a);
 	} else {
@@ -1278,10 +1282,10 @@ static void process_deferred_actions(struct datapath *dp)
 		struct sk_buff *skb = da->skb;
 		struct sw_flow_key *key = &da->pkt_key;
 		const struct nlattr *actions = da->actions;
+		int actions_len = da->actions_len;
 
 		if (actions)
-			do_execute_actions(dp, skb, key, actions,
-					   nla_len(actions));
+			do_execute_actions(dp, skb, key, actions, actions_len);
 		else
 			ovs_dp_process_packet(skb, key);
 	} while (!action_fifo_is_empty(fifo));
-- 
1.8.3.1
