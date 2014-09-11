From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v2 3/4] openvswitch: simplify sample action implementation
Date: Thu, 11 Sep 2014 16:28:13 -0700
Message-ID: <1410478093-1494-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog118.obsmtp.com ([74.125.149.244]:48954 "HELO
	na3sys009aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752709AbaIKX1r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2014 19:27:47 -0400
Received: by mail-pa0-f47.google.com with SMTP id ey11so12551593pad.34
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2014 16:27:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Zhou <azhou@nicira.com>

The current sample() function implementation is more complicated
than necessary in handling single user space action optimization
and skb reference counting. There is no functional changes.

Signed-off-by: Andy Zhou <azhou@nicira.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/actions.c | 43 ++++++++++++++++++-------------------------
 1 file changed, 18 insertions(+), 25 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 39c722f..fda7ef3 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -449,7 +449,6 @@ static int sample(struct datapath *dp, struct sk_buff *skb,
 {
 	const struct nlattr *acts_list = NULL;
 	const struct nlattr *a;
-	struct sk_buff *sample_skb;
 	int rem;
 
 	for (a = nla_data(attr), rem = nla_len(attr); rem > 0;
@@ -467,33 +466,27 @@ static int sample(struct datapath *dp, struct sk_buff *skb,
 	}
 
 	rem = nla_len(acts_list);
-	a = nla_data(acts_list);
+	/* Actions list is empty, do nothing */
+	if (unlikely(!rem))
+		return 0;
 
-	/* Actions list is either empty or only contains a single user-space
-	 * action, the latter being a special case as it is the only known
-	 * usage of the sample action.
-	 * In these special cases don't clone the skb as there are no
-	 * side-effects in the nested actions.
-	 * Otherwise, clone in case the nested actions have side effects.
+	a = nla_data(acts_list);
+	/* The only known usage of sample action is having a single user-space
+	 * action. Treat this usage as a special case.
+	 * The output_userspace() should clone the skb to be sent to the
+	 * user space. This skb will be consumed by its caller.
 	 */
-	if (likely(rem == 0 || (nla_type(a) == OVS_ACTION_ATTR_USERSPACE &&
-				last_action(a, rem)))) {
-		sample_skb = skb;
-		skb_get(skb);
-	} else {
-		sample_skb = skb_clone(skb, GFP_ATOMIC);
-		if (!sample_skb) /* Skip sample action when out of memory. */
-			return 0;
-	}
+	if (likely(nla_type(a) == OVS_ACTION_ATTR_USERSPACE &&
+		   last_action(a, rem)))
+		return output_userspace(dp, skb, a);
 
-	/* Note that do_execute_actions() never consumes skb.
-	 * In the case where skb has been cloned above it is the clone that
-	 * is consumed.  Otherwise the skb_get(skb) call prevents
-	 * consumption by do_execute_actions(). Thus, it is safe to simply
-	 * return the error code and let the caller (also
-	 * do_execute_actions()) free skb on error.
-	 */
-	return do_execute_actions(dp, sample_skb, a, rem);
+	skb = skb_clone(skb, GFP_ATOMIC);
+	if (!skb)
+		/* Skip the sample action when out of memory. */
+		return 0;
+
+	/* do_execute_actions() will consume the cloned skb. */
+	return do_execute_actions(dp, skb, a, rem);
 }
 
 static int execute_set_action(struct sk_buff *skb,
-- 
1.9.3
