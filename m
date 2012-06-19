From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 06/19] team: introduce array options
Date: Tue, 19 Jun 2012 17:54:08 +0200
Message-ID: <1340121261-2966-7-git-send-email-jpirko@redhat.com>
References: <1340121261-2966-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, jbrouer@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1025 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754670Ab2FSPye (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2012 11:54:34 -0400
In-Reply-To: <1340121261-2966-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/team/team.c |   75 ++++++++++++++++++++++++++++++++---------------
 include/linux/if_team.h |    3 ++
 2 files changed, 55 insertions(+), 23 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index f50b8ca..32cb290 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -90,6 +90,7 @@ struct team_option_inst { /* One for each option instance */
 	struct list_head list;
 	struct team_option *option;
 	struct team_port *port; /* != NULL if per-port */
+	u32 array_index;
 	bool changed;
 	bool removed;
 };
@@ -106,22 +107,6 @@ static struct team_option *__team_find_option(struct team *team,
 	return NULL;
 }
 
-static int __team_option_inst_add(struct team *team, struct team_option *option,
-				  struct team_port *port)
-{
-	struct team_option_inst *opt_inst;
-
-	opt_inst = kmalloc(sizeof(*opt_inst), GFP_KERNEL);
-	if (!opt_inst)
-		return -ENOMEM;
-	opt_inst->option = option;
-	opt_inst->port = port;
-	opt_inst->changed = true;
-	opt_inst->removed = false;
-	list_add_tail(&opt_inst->list, &team->option_inst_list);
-	return 0;
-}
-
 static void __team_option_inst_del(struct team_option_inst *opt_inst)
 {
 	list_del(&opt_inst->list);
@@ -139,14 +124,42 @@ static void __team_option_inst_del_option(struct team *team,
 	}
 }
 
+static int __team_option_inst_add(struct team *team, struct team_option *option,
+				  struct team_port *port)
+{
+	struct team_option_inst *opt_inst;
+	unsigned int array_size;
+	unsigned int i;
+
+	array_size = option->array_size;
+	if (!array_size)
+		array_size = 1; /* No array but still need one instance */
+
+	for (i = 0; i < array_size; i++) {
+		opt_inst = kmalloc(sizeof(*opt_inst), GFP_KERNEL);
+		if (!opt_inst)
+			return -ENOMEM;
+		opt_inst->option = option;
+		opt_inst->port = port;
+		opt_inst->array_index = i;
+		opt_inst->changed = true;
+		opt_inst->removed = false;
+		list_add_tail(&opt_inst->list, &team->option_inst_list);
+	}
+	return 0;
+}
+
 static int __team_option_inst_add_option(struct team *team,
 					 struct team_option *option)
 {
 	struct team_port *port;
 	int err;
 
-	if (!option->per_port)
-		return __team_option_inst_add(team, option, 0);
+	if (!option->per_port) {
+		err = __team_option_inst_add(team, option, 0);
+		if (err)
+			goto inst_del_option;
+	}
 
 	list_for_each_entry(port, &team->port_list, list) {
 		err = __team_option_inst_add(team, option, port);
@@ -1567,6 +1580,11 @@ static int team_nl_fill_options_get(struct sk_buff *skb,
 				opt_inst->port->dev->ifindex))
 			goto nla_put_failure;
 		ctx.port = opt_inst->port;
+		if (opt_inst->option->array_size &&
+		    nla_put_u32(skb, TEAM_ATTR_OPTION_ARRAY_INDEX,
+				opt_inst->array_index))
+			goto nla_put_failure;
+		ctx.array_index = opt_inst->array_index;
 		switch (option->type) {
 		case TEAM_OPTION_TYPE_U32:
 			if (nla_put_u8(skb, TEAM_ATTR_OPTION_TYPE, NLA_U32))
@@ -1668,10 +1686,12 @@ static int team_nl_cmd_options_set(struct sk_buff *skb, struct genl_info *info)
 
 	nla_for_each_nested(nl_option, info->attrs[TEAM_ATTR_LIST_OPTION], i) {
 		struct nlattr *opt_attrs[TEAM_ATTR_OPTION_MAX + 1];
-		struct nlattr *attr_port_ifindex;
+		struct nlattr *attr;
 		struct nlattr *attr_data;
 		enum team_option_type opt_type;
 		int opt_port_ifindex = 0; /* != 0 for per-port options */
+		u32 opt_array_index = 0;
+		bool opt_is_array = false;
 		struct team_option_inst *opt_inst;
 		char *opt_name;
 		bool opt_found = false;
@@ -1713,9 +1733,15 @@ static int team_nl_cmd_options_set(struct sk_buff *skb, struct genl_info *info)
 		}
 
 		opt_name = nla_data(opt_attrs[TEAM_ATTR_OPTION_NAME]);
-		attr_port_ifindex = opt_attrs[TEAM_ATTR_OPTION_PORT_IFINDEX];
-		if (attr_port_ifindex)
-			opt_port_ifindex = nla_get_u32(attr_port_ifindex);
+		attr = opt_attrs[TEAM_ATTR_OPTION_PORT_IFINDEX];
+		if (attr)
+			opt_port_ifindex = nla_get_u32(attr);
+
+		attr = opt_attrs[TEAM_ATTR_OPTION_ARRAY_INDEX];
+		if (attr) {
+			opt_is_array = true;
+			opt_array_index = nla_get_u32(attr);
+		}
 
 		list_for_each_entry(opt_inst, &team->option_inst_list, list) {
 			struct team_option *option = opt_inst->option;
@@ -1726,10 +1752,13 @@ static int team_nl_cmd_options_set(struct sk_buff *skb, struct genl_info *info)
 				      opt_inst->port->dev->ifindex : 0;
 			if (option->type != opt_type ||
 			    strcmp(option->name, opt_name) ||
-			    tmp_ifindex != opt_port_ifindex)
+			    tmp_ifindex != opt_port_ifindex ||
+			    (option->array_size && !opt_is_array) ||
+			    opt_inst->array_index != opt_array_index)
 				continue;
 			opt_found = true;
 			ctx.port = opt_inst->port;
+			ctx.array_index = opt_inst->array_index;
 			switch (opt_type) {
 			case TEAM_OPTION_TYPE_U32:
 				ctx.data.u32_val = nla_get_u32(attr_data);
diff --git a/include/linux/if_team.h b/include/linux/if_team.h
index 54af95f..b1719e2 100644
--- a/include/linux/if_team.h
+++ b/include/linux/if_team.h
@@ -93,6 +93,7 @@ struct team_gsetter_ctx {
 		} bin_val;
 		bool bool_val;
 	} data;
+	u32 array_index;
 	struct team_port *port;
 };
 
@@ -100,6 +101,7 @@ struct team_option {
 	struct list_head list;
 	const char *name;
 	bool per_port;
+	unsigned int array_size; /* != 0 means the option is array */
 	enum team_option_type type;
 	int (*getter)(struct team *team, struct team_gsetter_ctx *ctx);
 	int (*setter)(struct team *team, struct team_gsetter_ctx *ctx);
@@ -242,6 +244,7 @@ enum {
 	TEAM_ATTR_OPTION_DATA,		/* dynamic */
 	TEAM_ATTR_OPTION_REMOVED,	/* flag */
 	TEAM_ATTR_OPTION_PORT_IFINDEX,	/* u32 */ /* for per-port options */
+	TEAM_ATTR_OPTION_ARRAY_INDEX,	/* u32 */ /* for array options */
 
 	__TEAM_ATTR_OPTION_MAX,
 	TEAM_ATTR_OPTION_MAX = __TEAM_ATTR_OPTION_MAX - 1,
-- 
1.7.10.2
