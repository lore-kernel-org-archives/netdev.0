From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next] datapath: Rename last_action() as nla_is_last() and move to netlink.h
Date: Mon, 27 Oct 2014 16:12:16 +0900
Message-ID: <1414393936-14463-1-git-send-email-simon.horman@netronome.com>
Cc: dev@openvswitch.org, Simon Horman <simon.horman@netronome.com>,
	Thomas Graf <tgraf@suug.ch>, Andy Zhou <azhou@nicira.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:61526 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752120AbaJ0HMa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2014 03:12:30 -0400
Received: by mail-pa0-f46.google.com with SMTP id lf10so3249421pab.19
        for <netdev@vger.kernel.org>; Mon, 27 Oct 2014 00:12:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The original motivation for this change was to allow the helper to be used
in files other than actions.c as part of work on an odp select group
action.

It was as pointed out by Thomas Graf that this helper would be best off
living in netlink.h. Furthermore, I think that the generic nature of this
helper means it is best off in netlink.h regardless of if it is used more
than one .c file or not. Thus, I would like it considered independent of
the work on an odp select group action.

Cc: Thomas Graf <tgraf@suug.ch>
Cc: Pravin Shelar <pshelar@nicira.com>
Cc: Andy Zhou <azhou@nicira.com>
Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 include/net/netlink.h     | 10 ++++++++++
 net/openvswitch/actions.c | 11 +++--------
 2 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/include/net/netlink.h b/include/net/netlink.h
index 7b903e1..6415835 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -1185,4 +1185,14 @@ static inline int nla_validate_nested(const struct nlattr *start, int maxtype,
 #define nla_for_each_nested(pos, nla, rem) \
 	nla_for_each_attr(pos, nla_data(nla), nla_len(nla), rem)
 
+/**
+ * nla_is_last - Test if attribute is last in stream
+ * @nla: attribute to test
+ * @rem: bytes remaining in stream
+ */
+static inline bool nla_is_last(const struct nlattr *nla, int rem)
+{
+	return nla->nla_len == rem;
+}
+
 #endif
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 006886d..922c133 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -504,11 +504,6 @@ static int output_userspace(struct datapath *dp, struct sk_buff *skb,
 	return ovs_dp_upcall(dp, skb, &upcall);
 }
 
-static bool last_action(const struct nlattr *a, int rem)
-{
-	return a->nla_len == rem;
-}
-
 static int sample(struct datapath *dp, struct sk_buff *skb,
 		  struct sw_flow_key *key, const struct nlattr *attr)
 {
@@ -543,7 +538,7 @@ static int sample(struct datapath *dp, struct sk_buff *skb,
 	 * user space. This skb will be consumed by its caller.
 	 */
 	if (likely(nla_type(a) == OVS_ACTION_ATTR_USERSPACE &&
-		   last_action(a, rem)))
+		   nla_is_last(a, rem)))
 		return output_userspace(dp, skb, key, a);
 
 	skb = skb_clone(skb, GFP_ATOMIC);
@@ -633,7 +628,7 @@ static int execute_recirc(struct datapath *dp, struct sk_buff *skb,
 	if (err)
 		return err;
 
-	if (!last_action(a, rem)) {
+	if (!nla_is_last(a, rem)) {
 		/* Recirc action is the not the last action
 		 * of the action list, need to clone the skb.
 		 */
@@ -707,7 +702,7 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 
 		case OVS_ACTION_ATTR_RECIRC:
 			err = execute_recirc(dp, skb, key, a, rem);
-			if (last_action(a, rem)) {
+			if (nla_is_last(a, rem)) {
 				/* If this is the last action, the skb has
 				 * been consumed or freed.
 				 * Return immediately.
-- 
2.1.1
