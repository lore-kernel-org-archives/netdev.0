From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 08/19] team: push array_index and port into separate structure
Date: Tue, 19 Jun 2012 17:54:10 +0200
Message-ID: <1340121261-2966-9-git-send-email-jpirko@redhat.com>
References: <1340121261-2966-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, jbrouer@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37146 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754637Ab2FSPyi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2012 11:54:38 -0400
In-Reply-To: <1340121261-2966-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce struct team_option_inst_info and push option instance info
there. It can be then easily passed to gsetter context and used for
feature async option changes.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/team/team.c |   68 ++++++++++++++++++++++++++++++-----------------
 include/linux/if_team.h |    9 +++++--
 2 files changed, 50 insertions(+), 27 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 7ec53f8..cff8e25 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -89,8 +89,7 @@ static void team_refresh_port_linkup(struct team_port *port)
 struct team_option_inst { /* One for each option instance */
 	struct list_head list;
 	struct team_option *option;
-	struct team_port *port; /* != NULL if per-port */
-	u32 array_index;
+	struct team_option_inst_info info;
 	bool changed;
 	bool removed;
 };
@@ -130,6 +129,7 @@ static int __team_option_inst_add(struct team *team, struct team_option *option,
 	struct team_option_inst *opt_inst;
 	unsigned int array_size;
 	unsigned int i;
+	int err;
 
 	array_size = option->array_size;
 	if (!array_size)
@@ -140,11 +140,17 @@ static int __team_option_inst_add(struct team *team, struct team_option *option,
 		if (!opt_inst)
 			return -ENOMEM;
 		opt_inst->option = option;
-		opt_inst->port = port;
-		opt_inst->array_index = i;
+		opt_inst->info.port = port;
+		opt_inst->info.array_index = i;
 		opt_inst->changed = true;
 		opt_inst->removed = false;
 		list_add_tail(&opt_inst->list, &team->option_inst_list);
+		if (option->init) {
+			err = option->init(team, &opt_inst->info);
+			if (err)
+				return err;
+		}
+
 	}
 	return 0;
 }
@@ -193,7 +199,7 @@ static void __team_option_inst_del_port(struct team *team,
 
 	list_for_each_entry_safe(opt_inst, tmp, &team->option_inst_list, list) {
 		if (opt_inst->option->per_port &&
-		    opt_inst->port == port)
+		    opt_inst->info.port == port)
 			__team_option_inst_del(opt_inst);
 	}
 }
@@ -224,7 +230,7 @@ static void __team_option_inst_mark_removed_port(struct team *team,
 	struct team_option_inst *opt_inst;
 
 	list_for_each_entry(opt_inst, &team->option_inst_list, list) {
-		if (opt_inst->port == port) {
+		if (opt_inst->info.port == port) {
 			opt_inst->changed = true;
 			opt_inst->removed = true;
 		}
@@ -958,39 +964,47 @@ static int team_mode_option_set(struct team *team, struct team_gsetter_ctx *ctx)
 static int team_port_en_option_get(struct team *team,
 				   struct team_gsetter_ctx *ctx)
 {
-	ctx->data.bool_val = team_port_enabled(ctx->port);
+	struct team_port *port = ctx->info->port;
+
+	ctx->data.bool_val = team_port_enabled(port);
 	return 0;
 }
 
 static int team_port_en_option_set(struct team *team,
 				   struct team_gsetter_ctx *ctx)
 {
+	struct team_port *port = ctx->info->port;
+
 	if (ctx->data.bool_val)
-		team_port_enable(team, ctx->port);
+		team_port_enable(team, port);
 	else
-		team_port_disable(team, ctx->port);
+		team_port_disable(team, port);
 	return 0;
 }
 
 static int team_user_linkup_option_get(struct team *team,
 				       struct team_gsetter_ctx *ctx)
 {
-	ctx->data.bool_val = ctx->port->user.linkup;
+	struct team_port *port = ctx->info->port;
+
+	ctx->data.bool_val = port->user.linkup;
 	return 0;
 }
 
 static int team_user_linkup_option_set(struct team *team,
 				       struct team_gsetter_ctx *ctx)
 {
-	ctx->port->user.linkup = ctx->data.bool_val;
-	team_refresh_port_linkup(ctx->port);
+	struct team_port *port = ctx->info->port;
+
+	port->user.linkup = ctx->data.bool_val;
+	team_refresh_port_linkup(port);
 	return 0;
 }
 
 static int team_user_linkup_en_option_get(struct team *team,
 					  struct team_gsetter_ctx *ctx)
 {
-	struct team_port *port = ctx->port;
+	struct team_port *port = ctx->info->port;
 
 	ctx->data.bool_val = port->user.linkup_enabled;
 	return 0;
@@ -999,10 +1013,10 @@ static int team_user_linkup_en_option_get(struct team *team,
 static int team_user_linkup_en_option_set(struct team *team,
 					  struct team_gsetter_ctx *ctx)
 {
-	struct team_port *port = ctx->port;
+	struct team_port *port = ctx->info->port;
 
 	port->user.linkup_enabled = ctx->data.bool_val;
-	team_refresh_port_linkup(ctx->port);
+	team_refresh_port_linkup(port);
 	return 0;
 }
 
@@ -1557,6 +1571,7 @@ static int team_nl_fill_options_get(struct sk_buff *skb,
 	list_for_each_entry(opt_inst, &team->option_inst_list, list) {
 		struct nlattr *option_item;
 		struct team_option *option = opt_inst->option;
+		struct team_option_inst_info *opt_inst_info;
 		struct team_gsetter_ctx ctx;
 
 		/* Include only changed options if fill all mode is not on */
@@ -1575,16 +1590,18 @@ static int team_nl_fill_options_get(struct sk_buff *skb,
 		if (opt_inst->removed &&
 		    nla_put_flag(skb, TEAM_ATTR_OPTION_REMOVED))
 			goto nla_put_failure;
-		if (opt_inst->port &&
+
+		opt_inst_info = &opt_inst->info;
+		if (opt_inst_info->port &&
 		    nla_put_u32(skb, TEAM_ATTR_OPTION_PORT_IFINDEX,
-				opt_inst->port->dev->ifindex))
+				opt_inst_info->port->dev->ifindex))
 			goto nla_put_failure;
-		ctx.port = opt_inst->port;
 		if (opt_inst->option->array_size &&
 		    nla_put_u32(skb, TEAM_ATTR_OPTION_ARRAY_INDEX,
-				opt_inst->array_index))
+				opt_inst_info->array_index))
 			goto nla_put_failure;
-		ctx.array_index = opt_inst->array_index;
+		ctx.info = opt_inst_info;
+
 		switch (option->type) {
 		case TEAM_OPTION_TYPE_U32:
 			if (nla_put_u8(skb, TEAM_ATTR_OPTION_TYPE, NLA_U32))
@@ -1746,19 +1763,20 @@ static int team_nl_cmd_options_set(struct sk_buff *skb, struct genl_info *info)
 		list_for_each_entry(opt_inst, &team->option_inst_list, list) {
 			struct team_option *option = opt_inst->option;
 			struct team_gsetter_ctx ctx;
+			struct team_option_inst_info *opt_inst_info;
 			int tmp_ifindex;
 
-			tmp_ifindex = opt_inst->port ?
-				      opt_inst->port->dev->ifindex : 0;
+			opt_inst_info = &opt_inst->info;
+			tmp_ifindex = opt_inst_info->port ?
+				      opt_inst_info->port->dev->ifindex : 0;
 			if (option->type != opt_type ||
 			    strcmp(option->name, opt_name) ||
 			    tmp_ifindex != opt_port_ifindex ||
 			    (option->array_size && !opt_is_array) ||
-			    opt_inst->array_index != opt_array_index)
+			    opt_inst_info->array_index != opt_array_index)
 				continue;
 			opt_found = true;
-			ctx.port = opt_inst->port;
-			ctx.array_index = opt_inst->array_index;
+			ctx.info = opt_inst_info;
 			switch (opt_type) {
 			case TEAM_OPTION_TYPE_U32:
 				ctx.data.u32_val = nla_get_u32(attr_data);
diff --git a/include/linux/if_team.h b/include/linux/if_team.h
index b1719e2..30854cb 100644
--- a/include/linux/if_team.h
+++ b/include/linux/if_team.h
@@ -83,6 +83,11 @@ enum team_option_type {
 	TEAM_OPTION_TYPE_BOOL,
 };
 
+struct team_option_inst_info {
+	u32 array_index;
+	struct team_port *port; /* != NULL if per-port */
+};
+
 struct team_gsetter_ctx {
 	union {
 		u32 u32_val;
@@ -93,8 +98,7 @@ struct team_gsetter_ctx {
 		} bin_val;
 		bool bool_val;
 	} data;
-	u32 array_index;
-	struct team_port *port;
+	struct team_option_inst_info *info;
 };
 
 struct team_option {
@@ -103,6 +107,7 @@ struct team_option {
 	bool per_port;
 	unsigned int array_size; /* != 0 means the option is array */
 	enum team_option_type type;
+	int (*init)(struct team *team, struct team_option_inst_info *info);
 	int (*getter)(struct team *team, struct team_gsetter_ctx *ctx);
 	int (*setter)(struct team *team, struct team_gsetter_ctx *ctx);
 };
-- 
1.7.10.2
