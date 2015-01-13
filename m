From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v2 05/12] net: flow_table: add validation functions
 for flows
Date: Tue, 13 Jan 2015 13:37:14 -0800
Message-ID: <20150113213713.13874.5838.stgit@nitbit.x32>
References: <20150113212941.13874.48692.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gerlitz.or@gmail.com, jhs@mojatatu.com,
	andy@greyhouse.net, davem@davemloft.net
To: tgraf@suug.ch, simon.horman@netronome.com, sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:50930 "EHLO
	mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751260AbbAMVhe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 16:37:34 -0500
Received: by mail-oi0-f53.google.com with SMTP id g201so4438038oib.12
        for <netdev@vger.kernel.org>; Tue, 13 Jan 2015 13:37:33 -0800 (PST)
In-Reply-To: <20150113212941.13874.48692.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds common validation functions that is used before
adding flows to verify they match the table spec returned
from driver.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 net/core/flow_table.c |   75 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 75 insertions(+)

diff --git a/net/core/flow_table.c b/net/core/flow_table.c
index baeae64..a938929 100644
--- a/net/core/flow_table.c
+++ b/net/core/flow_table.c
@@ -1627,6 +1627,78 @@ static int net_flow_del_rule_cache(struct net_flow_tbl *table,
 	return -EEXIST;
 }
 
+static int net_flow_is_valid_action_arg(struct net_flow_action *a, int id)
+{
+	struct net_flow_action_arg *args = a->args;
+	int i;
+
+	/* Actions may not have any arguments */
+	if (!a->args)
+		return 0;
+
+	for (i = 0; args[i].type != NFL_ACTION_ARG_TYPE_NULL; i++) {
+		if (a->args[i].type == NFL_ACTION_ARG_TYPE_NULL ||
+		    args[i].type != a->args[i].type)
+			return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int net_flow_is_valid_action(struct net_flow_action *a, int *actions)
+{
+	int i;
+
+	for (i = 0; actions[i]; i++) {
+		if (actions[i] == a->uid)
+			return net_flow_is_valid_action_arg(a, a->uid);
+	}
+	return -EINVAL;
+}
+
+static int net_flow_is_valid_match(struct net_flow_field_ref *f,
+				   struct net_flow_field_ref *fields)
+{
+	int i;
+
+	for (i = 0; fields[i].header; i++) {
+		if (f->header == fields[i].header &&
+		    f->field == fields[i].field)
+			return 0;
+	}
+
+	return -EINVAL;
+}
+
+static int net_flow_is_valid_rule(struct net_flow_tbl *table,
+				  struct net_flow_rule *flow)
+{
+	struct net_flow_field_ref *fields = table->matches;
+	int *actions = table->actions;
+	int i, err;
+
+	/* Only accept flows with matches AND actions it does not seem
+	 * correct to allow a match without actions or action chains
+	 * that will never be hit
+	 */
+	if (!flow->actions || !flow->matches)
+		return -EINVAL;
+
+	for (i = 0; flow->actions[i].uid; i++) {
+		err = net_flow_is_valid_action(&flow->actions[i], actions);
+		if (err)
+			return -EINVAL;
+	}
+
+	for (i = 0; flow->matches[i].header; i++) {
+		err = net_flow_is_valid_match(&flow->matches[i], fields);
+		if (err)
+			return -EINVAL;
+	}
+
+	return 0;
+}
+
 static int net_flow_table_cmd_flows(struct sk_buff *recv_skb,
 				    struct genl_info *info)
 {
@@ -1695,6 +1767,9 @@ static int net_flow_table_cmd_flows(struct sk_buff *recv_skb,
 
 		switch (cmd) {
 		case NFL_TABLE_CMD_SET_FLOWS:
+			err = net_flow_is_valid_rule(table, this);
+			if (err)
+				break;
 			err = dev->netdev_ops->ndo_flow_set_rule(dev, this);
 			if (!err)
 				net_flow_add_rule_cache(table, this);
