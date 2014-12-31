From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v1 03/11] net: flow_table: add apply action
 argument to tables
Date: Wed, 31 Dec 2014 11:46:44 -0800
Message-ID: <20141231194642.31070.14445.stgit@nitbit.x32>
References: <20141231194057.31070.5244.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, andy@greyhouse.net
To: tgraf@suug.ch, sfeldma@gmail.com, jiri@resnulli.us,
	jhs@mojatatu.com, simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f171.google.com ([209.85.214.171]:56784 "EHLO
	mail-ob0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751554AbaLaTrE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2014 14:47:04 -0500
Received: by mail-ob0-f171.google.com with SMTP id uz6so49270993obc.2
        for <netdev@vger.kernel.org>; Wed, 31 Dec 2014 11:47:03 -0800 (PST)
In-Reply-To: <20141231194057.31070.5244.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Actions may not always be applied after exiting a table. For example
some pipelines may accumulate actions and then apply them at the end
of a pipeline.

To model this we use a table type called APPLY. Tables who share an
apply identifier have their actions applied in one step.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/linux/if_flow.h      |    1 +
 include/uapi/linux/if_flow.h |    1 +
 net/core/flow_table.c        |    1 +
 3 files changed, 3 insertions(+)

diff --git a/include/linux/if_flow.h b/include/linux/if_flow.h
index 20fa752..a042a3d 100644
--- a/include/linux/if_flow.h
+++ b/include/linux/if_flow.h
@@ -67,6 +67,7 @@ struct net_flow_table {
 	char name[NET_FLOW_NAMSIZ];
 	int uid;
 	int source;
+	int apply_action;
 	int size;
 	struct net_flow_field_ref *matches;
 	int *actions;
diff --git a/include/uapi/linux/if_flow.h b/include/uapi/linux/if_flow.h
index 125cdc6..3c1a860 100644
--- a/include/uapi/linux/if_flow.h
+++ b/include/uapi/linux/if_flow.h
@@ -265,6 +265,7 @@ enum {
 	NET_FLOW_TABLE_ATTR_NAME,
 	NET_FLOW_TABLE_ATTR_UID,
 	NET_FLOW_TABLE_ATTR_SOURCE,
+	NET_FLOW_TABLE_ATTR_APPLY,
 	NET_FLOW_TABLE_ATTR_SIZE,
 	NET_FLOW_TABLE_ATTR_MATCHES,
 	NET_FLOW_TABLE_ATTR_ACTIONS,
diff --git a/net/core/flow_table.c b/net/core/flow_table.c
index f4cf293..97cdf92 100644
--- a/net/core/flow_table.c
+++ b/net/core/flow_table.c
@@ -223,6 +223,7 @@ static int net_flow_put_table(struct net_device *dev,
 	if (nla_put_string(skb, NET_FLOW_TABLE_ATTR_NAME, t->name) ||
 	    nla_put_u32(skb, NET_FLOW_TABLE_ATTR_UID, t->uid) ||
 	    nla_put_u32(skb, NET_FLOW_TABLE_ATTR_SOURCE, t->source) ||
+	    nla_put_u32(skb, NET_FLOW_TABLE_ATTR_APPLY, t->apply_action) ||
 	    nla_put_u32(skb, NET_FLOW_TABLE_ATTR_SIZE, t->size))
 		return -EMSGSIZE;
 
