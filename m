From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC rocker-net-next 4/6] net: flow: free action args
Date: Mon,  5 Jan 2015 15:50:08 +0900
Message-ID: <1420440610-20621-5-git-send-email-simon.horman@netronome.com>
References: <1420440610-20621-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:54419 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753116AbbAEGun (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 01:50:43 -0500
Received: by mail-pd0-f173.google.com with SMTP id ft15so27579567pdb.32
        for <netdev@vger.kernel.org>; Sun, 04 Jan 2015 22:50:42 -0800 (PST)
In-Reply-To: <1420440610-20621-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Free the args of an action along with the action itself to avoid leaking
memory.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 net/core/flow_table.c | 16 ++++++++++++++--
 1 file changed, 14 insertions(+), 2 deletions(-)

diff --git a/net/core/flow_table.c b/net/core/flow_table.c
index c734a9d..1a32a72 100644
--- a/net/core/flow_table.c
+++ b/net/core/flow_table.c
@@ -1050,6 +1050,18 @@ static int net_flow_get_field(struct net_flow_field_ref *field,
 	return 0;
 }
 
+static void net_flow_free_actions(struct net_flow_action *actions)
+{
+	int i;
+
+	if (!actions)
+		return;
+
+	for (i = 0; actions[i].uid; i++)
+		kfree(actions[i].args);
+	kfree(actions);
+}
+
 static int net_flow_get_action(struct net_flow_action *a, struct nlattr *attr)
 {
 	struct nlattr *act[NET_FLOW_ACTION_ATTR_MAX+1];
@@ -1168,7 +1180,7 @@ static int net_flow_get_flow(struct net_flow_flow *flow, struct nlattr *attr)
 			err = net_flow_get_action(&flow->actions[count], attr2);
 			if (err) {
 				kfree(flow->matches);
-				kfree(flow->actions);
+				net_flow_free_actions(flow->actions);
 				return err;
 			}
 			count++;
@@ -1251,7 +1263,7 @@ static int net_flow_table_cmd_flows(struct sk_buff *recv_skb,
 
 		/* Cleanup flow */
 		kfree(this.matches);
-		kfree(this.actions);
+		net_flow_free_actions(this.actions);
 
 		if (err && err_handle == NET_FLOW_FLOWS_ERROR_ABORT)
 			goto out;
-- 
2.1.3
