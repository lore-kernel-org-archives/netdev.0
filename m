From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH] net: flow: Allow actions and matches to be NULL in net_flow_put_flow()
Date: Mon, 29 Dec 2014 11:20:02 +0900
Message-ID: <1419819602-23290-1-git-send-email-simon.horman@netronome.com>
Cc: Simon Horman <simon.horman@netronome.com>
To: John Fastabend <john.r.fastabend@intel.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:59912 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751534AbaL2CUO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Dec 2014 21:20:14 -0500
Received: by mail-pa0-f45.google.com with SMTP id lf10so16493453pab.4
        for <netdev@vger.kernel.org>; Sun, 28 Dec 2014 18:20:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This makes the handing of the absence of actions or matches
symmetric with net_flow_get_flow().

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 net/core/flow_table.c | 40 ++++++++++++++++++++++------------------
 1 file changed, 22 insertions(+), 18 deletions(-)

diff --git a/net/core/flow_table.c b/net/core/flow_table.c
index df2adf6..0992806 100644
--- a/net/core/flow_table.c
+++ b/net/core/flow_table.c
@@ -196,32 +196,36 @@ int net_flow_put_flow(struct sk_buff *skb, struct net_flow_flow *flow)
 	    nla_put_u32(skb, NET_FLOW_ATTR_PRIORITY, flow->priority))
 		goto flows_put_failure;
 
-	matches = nla_nest_start(skb, NET_FLOW_ATTR_MATCHES);
-	if (!matches)
-		goto flows_put_failure;
-	for (j = 0; flow->matches[j].header; j++) {
-		struct net_flow_field_ref *f = &flow->matches[j];
+	if (flow->matches) {
+		matches = nla_nest_start(skb, NET_FLOW_ATTR_MATCHES);
+		if (!matches)
+			goto flows_put_failure;
+		for (j = 0; flow->matches[j].header; j++) {
+			struct net_flow_field_ref *f = &flow->matches[j];
 
-		if (!f->header)
-			continue;
+			if (!f->header)
+				continue;
 
-		nla_put(skb, NET_FLOW_FIELD_REF, sizeof(*f), f);
+			nla_put(skb, NET_FLOW_FIELD_REF, sizeof(*f), f);
+		}
+		nla_nest_end(skb, matches);
 	}
-	nla_nest_end(skb, matches);
-
-	actions = nla_nest_start(skb, NET_FLOW_ATTR_ACTIONS);
-	if (!actions)
-		goto flows_put_failure;
 
-	for (i = 0; flow->actions[i].uid; i++) {
-		err = net_flow_put_flow_action(skb, &flow->actions[i]);
-		if (err) {
-			nla_nest_cancel(skb, actions);
+	if (flow->actions) {
+		actions = nla_nest_start(skb, NET_FLOW_ATTR_ACTIONS);
+		if (!actions)
 			goto flows_put_failure;
+
+		for (i = 0; flow->actions[i].uid; i++) {
+			err = net_flow_put_flow_action(skb, &flow->actions[i]);
+			if (err) {
+				nla_nest_cancel(skb, actions);
+				goto flows_put_failure;
+			}
 		}
+		nla_nest_end(skb, actions);
 	}
 
-	nla_nest_end(skb, actions);
 	nla_nest_end(skb, flows);
 	return 0;
 
-- 
2.1.3
