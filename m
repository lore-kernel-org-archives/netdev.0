From: Tonghao Zhang <xiangxia.m.yue@gmail.com>
Subject: [PATCH v2] datapath: Avoid using stack larger than 1024.
Date: Tue, 27 Jun 2017 19:29:59 -0700
Message-ID: <1498616999-3035-1-git-send-email-xiangxia.m.yue@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: pshelar@ovn.org, gvrose8192@gmail.com,
        Tonghao Zhang <xiangxia.m.yue@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36815 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752010AbdF1CaO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 22:30:14 -0400
Received: by mail-pg0-f66.google.com with SMTP id u36so6368757pgn.3
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 19:30:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When compiling OvS-master on 4.4.0-81 kernel,
there is a warning:

    CC [M]  /root/ovs/datapath/linux/datapath.o
    /root/ovs/datapath/linux/datapath.c: In function
    ‘ovs_flow_cmd_set’:
    /root/ovs/datapath/linux/datapath.c:1221:1: warning:
    the frame size of 1040 bytes is larger than 1024 bytes
    [-Wframe-larger-than=]

This patch factors out match-init and action-copy to avoid
"Wframe-larger-than=1024" warning. Because mask is only
used to get actions, we new a function to save some
stack space.

Signed-off-by: Tonghao Zhang <xiangxia.m.yue@gmail.com>
---
 datapath/datapath.c | 73 ++++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 50 insertions(+), 23 deletions(-)

diff --git a/datapath/datapath.c b/datapath/datapath.c
index c85029c..fdbe314 100644
--- a/datapath/datapath.c
+++ b/datapath/datapath.c
@@ -1100,6 +1100,50 @@ static struct sw_flow_actions *get_flow_actions(struct net *net,
 	return acts;
 }
 
+/* Factor out match-init and action-copy to avoid
+ * "Wframe-larger-than=1024" warning. Because mask is only
+ * used to get actions, we new a function to save some
+ * stack space.
+ *
+ * If there are not key and action attrs, we return 0
+ * directly. In the case, the caller will also not use the
+ * match as before. If there is action attr, we try to get
+ * actions and save them to *acts.
+ * */
+static int ovs_nla_init_match_and_action(struct net *net,
+					 struct sw_flow_match *match,
+					 struct sw_flow_key *key,
+					 struct nlattr **a,
+					 struct sw_flow_actions **acts,
+					 bool log)
+{
+	struct sw_flow_mask mask;
+	int error = 0;
+
+	if (a[OVS_FLOW_ATTR_KEY]) {
+		ovs_match_init(match, key, true, &mask);
+		error = ovs_nla_get_match(net, match, a[OVS_FLOW_ATTR_KEY],
+					  a[OVS_FLOW_ATTR_MASK], log);
+		if (error)
+			return error;
+	}
+
+	if (a[OVS_FLOW_ATTR_ACTIONS]) {
+		if (!a[OVS_FLOW_ATTR_KEY]) {
+			OVS_NLERR(log,
+				  "Flow key attribute not present in set flow.");
+			return -EINVAL;
+		}
+
+		*acts = get_flow_actions(net, a[OVS_FLOW_ATTR_ACTIONS], key,
+					 &mask, log);
+		if (IS_ERR(*acts))
+			return PTR_ERR(*acts);
+	}
+
+	return 0;
+}
+
 static int ovs_flow_cmd_set(struct sk_buff *skb, struct genl_info *info)
 {
 	struct net *net = sock_net(skb->sk);
@@ -1107,7 +1151,6 @@ static int ovs_flow_cmd_set(struct sk_buff *skb, struct genl_info *info)
 	struct ovs_header *ovs_header = info->userhdr;
 	struct sw_flow_key key;
 	struct sw_flow *flow;
-	struct sw_flow_mask mask;
 	struct sk_buff *reply = NULL;
 	struct datapath *dp;
 	struct sw_flow_actions *old_acts = NULL, *acts = NULL;
@@ -1119,34 +1162,18 @@ static int ovs_flow_cmd_set(struct sk_buff *skb, struct genl_info *info)
 	bool ufid_present;
 
 	ufid_present = ovs_nla_get_ufid(&sfid, a[OVS_FLOW_ATTR_UFID], log);
-	if (a[OVS_FLOW_ATTR_KEY]) {
-		ovs_match_init(&match, &key, true, &mask);
-		error = ovs_nla_get_match(net, &match, a[OVS_FLOW_ATTR_KEY],
-					  a[OVS_FLOW_ATTR_MASK], log);
-	} else if (!ufid_present) {
+	if (!a[OVS_FLOW_ATTR_KEY] && !ufid_present) {
 		OVS_NLERR(log,
 			  "Flow set message rejected, Key attribute missing.");
-		error = -EINVAL;
+		return -EINVAL;
 	}
+
+	error = ovs_nla_init_match_and_action(net, &match, &key, a,
+					      &acts, log);
 	if (error)
 		goto error;
 
-	/* Validate actions. */
-	if (a[OVS_FLOW_ATTR_ACTIONS]) {
-		if (!a[OVS_FLOW_ATTR_KEY]) {
-			OVS_NLERR(log,
-				  "Flow key attribute not present in set flow.");
-			error = -EINVAL;
-			goto error;
-		}
-
-		acts = get_flow_actions(net, a[OVS_FLOW_ATTR_ACTIONS], &key,
-					&mask, log);
-		if (IS_ERR(acts)) {
-			error = PTR_ERR(acts);
-			goto error;
-		}
-
+	if (acts) {
 		/* Can allocate before locking if have acts. */
 		reply = ovs_flow_cmd_alloc_info(acts, &sfid, info, false,
 						ufid_flags);
-- 
1.8.3.1
