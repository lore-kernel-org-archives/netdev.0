From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v9 4/5] openvswitch: Sample action without side effects
Date: Thu, 24 Jul 2014 14:39:59 -0700
Message-ID: <1406237999-1717-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Simon Horman <horms@verge.net.au>,
	Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog130.obsmtp.com ([74.125.149.143]:42976 "HELO
	na3sys009aog130.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S934718AbaGXVkJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2014 17:40:09 -0400
Received: by mail-pd0-f180.google.com with SMTP id y13so4376950pdi.25
        for <netdev@vger.kernel.org>; Thu, 24 Jul 2014 14:40:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>

The sample action is rather generic, allowing arbitrary actions to be
executed based on a probability. However its use, within the Open
vSwitch
code-base is limited: only a single user-space action is ever nested.

A consequence of the current implementation of sample actions is that
depending on weather the sample action executed (due to its probability)
any side-effects of nested actions may or may not be present before
executing subsequent actions.  This has the potential to complicate
verification of valid actions by the (kernel) datapath. And indeed
adding support for push and pop MPLS actions inside sample actions
is one case where such case.

In order to allow all supported actions to be continue to be nested
inside sample actions without the potential need for complex
verification code this patch changes the implementation of the sample
action in the kernel datapath so that sample actions are more like
a function call and any side effects of nested actions are not
present when executing subsequent actions.

With the above in mind the motivation for this change is twofold:

* To contain side-effects the sample action in the hope of making it
  easier to deal with in the future and;
* To avoid some rather complex verification code introduced in the MPLS
  datapath patch.

Signed-off-by: Simon Horman <horms@verge.net.au>
Signed-off-by: Jesse Gross <jesse@nicira.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/actions.c | 48 ++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 37 insertions(+), 11 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index e70d8b1..794a96f 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -38,7 +38,7 @@
 #include "vport.h"
 
 static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
-			const struct nlattr *attr, int len, bool keep_skb);
+			      const struct nlattr *attr, int len);
 
 static int make_writable(struct sk_buff *skb, int write_len)
 {
@@ -434,11 +434,17 @@ static int output_userspace(struct datapath *dp, struct sk_buff *skb,
 	return ovs_dp_upcall(dp, skb, &upcall);
 }
 
+static bool last_action(const struct nlattr *a, int rem)
+{
+	return a->nla_len == rem;
+}
+
 static int sample(struct datapath *dp, struct sk_buff *skb,
 		  const struct nlattr *attr)
 {
 	const struct nlattr *acts_list = NULL;
 	const struct nlattr *a;
+	struct sk_buff *sample_skb;
 	int rem;
 
 	for (a = nla_data(attr), rem = nla_len(attr); rem > 0;
@@ -455,8 +461,32 @@ static int sample(struct datapath *dp, struct sk_buff *skb,
 		}
 	}
 
-	return do_execute_actions(dp, skb, nla_data(acts_list),
-						 nla_len(acts_list), true);
+	rem = nla_len(acts_list);
+	a = nla_data(acts_list);
+
+	/* Actions list is either empty or only contains a single user-space
+	 * action, the latter being a special case as it is the only known
+	 * usage of the sample action.
+	 * In these special cases don't clone the skb as there are no
+	 * side-effects in the nested actions.
+	 * Otherwise, clone in case the nested actions have side effects.
+	 */
+	if (likely(rem == 0 || (nla_type(a) == OVS_ACTION_ATTR_USERSPACE &&
+				last_action(a, rem)))) {
+		sample_skb = skb;
+		skb_get(skb);
+	} else {
+		sample_skb = skb_clone(skb, GFP_ATOMIC);
+	}
+
+	/* Note that do_execute_actions() never consumes skb.
+	 * In the case where skb has been cloned above it is the clone that
+	 * is consumed.  Otherwise the skb_get(skb) call prevents
+	 * consumption by do_execute_actions(). Thus, it is safe to simply
+	 * return the error code and let the caller (also
+	 * do_execute_actions()) free skb on error.
+	 */
+	return do_execute_actions(dp, sample_skb, a, rem);
 }
 
 static int execute_set_action(struct sk_buff *skb,
@@ -507,7 +537,7 @@ static int execute_set_action(struct sk_buff *skb,
 
 /* Execute a list of actions against 'skb'. */
 static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
-			const struct nlattr *attr, int len, bool keep_skb)
+			      const struct nlattr *attr, int len)
 {
 	/* Every output action needs a separate clone of 'skb', but the common
 	 * case is just a single output action, so that doing a clone and
@@ -562,12 +592,9 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 		}
 	}
 
-	if (prev_port != -1) {
-		if (keep_skb)
-			skb = skb_clone(skb, GFP_ATOMIC);
-
+	if (prev_port != -1)
 		do_output(dp, skb, prev_port);
-	} else if (!keep_skb)
+	else
 		consume_skb(skb);
 
 	return 0;
@@ -579,6 +606,5 @@ int ovs_execute_actions(struct datapath *dp, struct sk_buff *skb)
 	struct sw_flow_actions *acts = rcu_dereference(OVS_CB(skb)->flow->sf_acts);
 
 	OVS_CB(skb)->tun_key = NULL;
-	return do_execute_actions(dp, skb, acts->actions,
-					 acts->actions_len, false);
+	return do_execute_actions(dp, skb, acts->actions, acts->actions_len);
 }
-- 
1.9.3
