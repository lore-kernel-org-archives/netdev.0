From: Andy Zhou <azhou@ovn.org>
Subject: [net-next v2] openvswitch: Simplify do_execute_actions().
Date: Fri, 27 Jan 2017 13:45:28 -0800
Message-ID: <1485553528-16248-1-git-send-email-azhou@ovn.org>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@ovn.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36607 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751430AbdA0Vpq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 16:45:46 -0500
Received: by mail-pf0-f195.google.com with SMTP id 19so19246782pfo.3
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 13:45:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

do_execute_actions() implements a worthwhile optimization: in case
an output action is the last action in an action list, skb_clone()
can be avoided by outputing the current skb. However, the
implementation is more complicated than necessary.  This patch
simplify this logic.

Signed-off-by: Andy Zhou <azhou@ovn.org>
---
v1->v2:  drop skb NULL check in do_output()


---
 net/openvswitch/actions.c | 42 ++++++++++++++++++++----------------------
 1 file changed, 20 insertions(+), 22 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 514f7bc..efa9a88 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -1141,12 +1141,6 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 			      struct sw_flow_key *key,
 			      const struct nlattr *attr, int len)
 {
-	/* Every output action needs a separate clone of 'skb', but the common
-	 * case is just a single output action, so that doing a clone and
-	 * then freeing the original skbuff is wasteful.  So the following code
-	 * is slightly obscure just to avoid that.
-	 */
-	int prev_port = -1;
 	const struct nlattr *a;
 	int rem;
 
@@ -1154,20 +1148,28 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 	     a = nla_next(a, &rem)) {
 		int err = 0;
 
-		if (unlikely(prev_port != -1)) {
-			struct sk_buff *out_skb = skb_clone(skb, GFP_ATOMIC);
-
-			if (out_skb)
-				do_output(dp, out_skb, prev_port, key);
+		switch (nla_type(a)) {
+		case OVS_ACTION_ATTR_OUTPUT: {
+			int port = nla_get_u32(a);
+			struct sk_buff *clone;
+
+			/* Every output action needs a separate clone
+			 * of 'skb', In case the output action is the
+			 * last action, cloning can be avoided.
+			 */
+			if (nla_is_last(a, rem)) {
+				do_output(dp, skb, port, key);
+				/* 'skb' has been used for output.
+				 */
+				return 0;
+			}
 
+			clone = skb_clone(skb, GFP_ATOMIC);
+			if (clone)
+				do_output(dp, clone, port, key);
 			OVS_CB(skb)->cutlen = 0;
-			prev_port = -1;
-		}
-
-		switch (nla_type(a)) {
-		case OVS_ACTION_ATTR_OUTPUT:
-			prev_port = nla_get_u32(a);
 			break;
+		}
 
 		case OVS_ACTION_ATTR_TRUNC: {
 			struct ovs_action_trunc *trunc = nla_data(a);
@@ -1257,11 +1259,7 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 		}
 	}
 
-	if (prev_port != -1)
-		do_output(dp, skb, prev_port, key);
-	else
-		consume_skb(skb);
-
+	consume_skb(skb);
 	return 0;
 }
 
-- 
1.8.3.1
