From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v3 05/12] net: flow_table: add validation functions
 for rules
Date: Tue, 20 Jan 2015 12:28:20 -0800
Message-ID: <20150120202819.1741.15301.stgit@nitbit.x32>
References: <20150120202404.1741.8658.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, davem@davemloft.net,
	gerlitz.or@gmail.com, andy@greyhouse.net, ast@plumgrid.com
To: tgraf@suug.ch, simon.horman@netronome.com, sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:35223 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752328AbbATU2j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 15:28:39 -0500
Received: by mail-ob0-f174.google.com with SMTP id wo20so26395815obc.5
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2015 12:28:38 -0800 (PST)
In-Reply-To: <20150120202404.1741.8658.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds common validation functions that is used before
adding rules to verify they match the table spec returned
from driver.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 net/core/flow_table.c |   75 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 75 insertions(+)

diff --git a/net/core/flow_table.c b/net/core/flow_table.c
index c1a9716..4b4da2e 100644
--- a/net/core/flow_table.c
+++ b/net/core/flow_table.c
@@ -1633,6 +1633,78 @@ static int net_flow_del_rule_cache(struct net_flow_tbl *table,
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
+	/* Only accept rules with matches AND actions it does not seem
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
@@ -1701,6 +1773,9 @@ static int net_flow_table_cmd_flows(struct sk_buff *recv_skb,
 
 		switch (cmd) {
 		case NFL_TABLE_CMD_SET_FLOWS:
+			err = net_flow_is_valid_rule(table, this);
+			if (err)
+				break;
 			err = dev->netdev_ops->ndo_flow_set_rule(dev, this);
 			if (!err)
 				net_flow_add_rule_cache(table, this);
