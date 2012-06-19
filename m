From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 12/19] team: allow to specify one option instance to be send to userspace
Date: Tue, 19 Jun 2012 17:54:14 +0200
Message-ID: <1340121261-2966-13-git-send-email-jpirko@redhat.com>
References: <1340121261-2966-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, jbrouer@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64234 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753424Ab2FSPyo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2012 11:54:44 -0400
In-Reply-To: <1340121261-2966-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to walk through option instance list and look for ->changed ==
true when called knows exactly what one option instance changed.

Also use lists to pass option instances needed to be present in netlink
message.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/team/team.c |  210 ++++++++++++++++++++++++++++-------------------
 1 file changed, 124 insertions(+), 86 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index e977f44..da72f41 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -89,6 +89,7 @@ static void team_refresh_port_linkup(struct team_port *port)
 
 struct team_option_inst { /* One for each option instance */
 	struct list_head list;
+	struct list_head tmp_list;
 	struct team_option *option;
 	struct team_option_inst_info info;
 	bool changed;
@@ -319,6 +320,8 @@ static void __team_options_unregister(struct team *team,
 }
 
 static void __team_options_change_check(struct team *team);
+static void __team_option_inst_change(struct team *team,
+				      struct team_option_inst *opt_inst);
 
 int team_options_register(struct team *team,
 			  const struct team_option *option,
@@ -383,8 +386,7 @@ static int team_option_set(struct team *team,
 	if (err)
 		return err;
 
-	opt_inst->changed = true;
-	__team_options_change_check(team);
+	__team_option_inst_change(team, opt_inst);
 	return err;
 }
 
@@ -1565,9 +1567,95 @@ err_fill:
 	return err;
 }
 
+static int team_nl_fill_one_option_get(struct sk_buff *skb, struct team *team,
+				       struct team_option_inst *opt_inst)
+{
+	struct nlattr *option_item;
+	struct team_option *option = opt_inst->option;
+	struct team_option_inst_info *opt_inst_info;
+	struct team_gsetter_ctx ctx;
+	int err;
+
+	option_item = nla_nest_start(skb, TEAM_ATTR_ITEM_OPTION);
+	if (!option_item)
+		goto nla_put_failure;
+	if (nla_put_string(skb, TEAM_ATTR_OPTION_NAME, option->name))
+		goto nla_put_failure;
+	if (opt_inst->changed) {
+		if (nla_put_flag(skb, TEAM_ATTR_OPTION_CHANGED))
+			goto nla_put_failure;
+		opt_inst->changed = false;
+	}
+	if (opt_inst->removed && nla_put_flag(skb, TEAM_ATTR_OPTION_REMOVED))
+		goto nla_put_failure;
+
+	opt_inst_info = &opt_inst->info;
+	if (opt_inst_info->port &&
+	    nla_put_u32(skb, TEAM_ATTR_OPTION_PORT_IFINDEX,
+			opt_inst_info->port->dev->ifindex))
+		goto nla_put_failure;
+	if (opt_inst->option->array_size &&
+	    nla_put_u32(skb, TEAM_ATTR_OPTION_ARRAY_INDEX,
+			opt_inst_info->array_index))
+		goto nla_put_failure;
+	ctx.info = opt_inst_info;
+
+	switch (option->type) {
+	case TEAM_OPTION_TYPE_U32:
+		if (nla_put_u8(skb, TEAM_ATTR_OPTION_TYPE, NLA_U32))
+			goto nla_put_failure;
+		err = team_option_get(team, opt_inst, &ctx);
+		if (err)
+			goto errout;
+		if (nla_put_u32(skb, TEAM_ATTR_OPTION_DATA, ctx.data.u32_val))
+			goto nla_put_failure;
+		break;
+	case TEAM_OPTION_TYPE_STRING:
+		if (nla_put_u8(skb, TEAM_ATTR_OPTION_TYPE, NLA_STRING))
+			goto nla_put_failure;
+		err = team_option_get(team, opt_inst, &ctx);
+		if (err)
+			goto errout;
+		if (nla_put_string(skb, TEAM_ATTR_OPTION_DATA,
+				   ctx.data.str_val))
+			goto nla_put_failure;
+		break;
+	case TEAM_OPTION_TYPE_BINARY:
+		if (nla_put_u8(skb, TEAM_ATTR_OPTION_TYPE, NLA_BINARY))
+			goto nla_put_failure;
+		err = team_option_get(team, opt_inst, &ctx);
+		if (err)
+			goto errout;
+		if (nla_put(skb, TEAM_ATTR_OPTION_DATA, ctx.data.bin_val.len,
+			    ctx.data.bin_val.ptr))
+			goto nla_put_failure;
+		break;
+	case TEAM_OPTION_TYPE_BOOL:
+		if (nla_put_u8(skb, TEAM_ATTR_OPTION_TYPE, NLA_FLAG))
+			goto nla_put_failure;
+		err = team_option_get(team, opt_inst, &ctx);
+		if (err)
+			goto errout;
+		if (ctx.data.bool_val &&
+		    nla_put_flag(skb, TEAM_ATTR_OPTION_DATA))
+			goto nla_put_failure;
+		break;
+	default:
+		BUG();
+	}
+	nla_nest_end(skb, option_item);
+	return 0;
+
+nla_put_failure:
+	err = -EMSGSIZE;
+errout:
+	return err;
+}
+
 static int team_nl_fill_options_get(struct sk_buff *skb,
 				    u32 pid, u32 seq, int flags,
-				    struct team *team, bool fillall)
+				    struct team *team,
+				    struct list_head *sel_opt_inst_list)
 {
 	struct nlattr *option_list;
 	void *hdr;
@@ -1585,85 +1673,10 @@ static int team_nl_fill_options_get(struct sk_buff *skb,
 	if (!option_list)
 		goto nla_put_failure;
 
-	list_for_each_entry(opt_inst, &team->option_inst_list, list) {
-		struct nlattr *option_item;
-		struct team_option *option = opt_inst->option;
-		struct team_option_inst_info *opt_inst_info;
-		struct team_gsetter_ctx ctx;
-
-		/* Include only changed options if fill all mode is not on */
-		if (!fillall && !opt_inst->changed)
-			continue;
-		option_item = nla_nest_start(skb, TEAM_ATTR_ITEM_OPTION);
-		if (!option_item)
-			goto nla_put_failure;
-		if (nla_put_string(skb, TEAM_ATTR_OPTION_NAME, option->name))
-			goto nla_put_failure;
-		if (opt_inst->changed) {
-			if (nla_put_flag(skb, TEAM_ATTR_OPTION_CHANGED))
-				goto nla_put_failure;
-			opt_inst->changed = false;
-		}
-		if (opt_inst->removed &&
-		    nla_put_flag(skb, TEAM_ATTR_OPTION_REMOVED))
-			goto nla_put_failure;
-
-		opt_inst_info = &opt_inst->info;
-		if (opt_inst_info->port &&
-		    nla_put_u32(skb, TEAM_ATTR_OPTION_PORT_IFINDEX,
-				opt_inst_info->port->dev->ifindex))
-			goto nla_put_failure;
-		if (opt_inst->option->array_size &&
-		    nla_put_u32(skb, TEAM_ATTR_OPTION_ARRAY_INDEX,
-				opt_inst_info->array_index))
-			goto nla_put_failure;
-		ctx.info = opt_inst_info;
-
-		switch (option->type) {
-		case TEAM_OPTION_TYPE_U32:
-			if (nla_put_u8(skb, TEAM_ATTR_OPTION_TYPE, NLA_U32))
-				goto nla_put_failure;
-			err = team_option_get(team, opt_inst, &ctx);
-			if (err)
-				goto errout;
-			if (nla_put_u32(skb, TEAM_ATTR_OPTION_DATA,
-					ctx.data.u32_val))
-				goto nla_put_failure;
-			break;
-		case TEAM_OPTION_TYPE_STRING:
-			if (nla_put_u8(skb, TEAM_ATTR_OPTION_TYPE, NLA_STRING))
-				goto nla_put_failure;
-			err = team_option_get(team, opt_inst, &ctx);
-			if (err)
-				goto errout;
-			if (nla_put_string(skb, TEAM_ATTR_OPTION_DATA,
-					   ctx.data.str_val))
-				goto nla_put_failure;
-			break;
-		case TEAM_OPTION_TYPE_BINARY:
-			if (nla_put_u8(skb, TEAM_ATTR_OPTION_TYPE, NLA_BINARY))
-				goto nla_put_failure;
-			err = team_option_get(team, opt_inst, &ctx);
-			if (err)
-				goto errout;
-			if (nla_put(skb, TEAM_ATTR_OPTION_DATA,
-				    ctx.data.bin_val.len, ctx.data.bin_val.ptr))
-				goto nla_put_failure;
-			break;
-		case TEAM_OPTION_TYPE_BOOL:
-			if (nla_put_u8(skb, TEAM_ATTR_OPTION_TYPE, NLA_FLAG))
-				goto nla_put_failure;
-			err = team_option_get(team, opt_inst, &ctx);
-			if (err)
-				goto errout;
-			if (ctx.data.bool_val &&
-			    nla_put_flag(skb, TEAM_ATTR_OPTION_DATA))
-				goto nla_put_failure;
-			break;
-		default:
-			BUG();
-		}
-		nla_nest_end(skb, option_item);
+	list_for_each_entry(opt_inst, sel_opt_inst_list, tmp_list) {
+		err = team_nl_fill_one_option_get(skb, team, opt_inst);
+		if (err)
+			goto errout;
 	}
 
 	nla_nest_end(skb, option_list);
@@ -1680,9 +1693,14 @@ static int team_nl_fill_options_get_all(struct sk_buff *skb,
 					struct genl_info *info, int flags,
 					struct team *team)
 {
+	struct team_option_inst *opt_inst;
+	LIST_HEAD(sel_opt_inst_list);
+
+	list_for_each_entry(opt_inst, &team->option_inst_list, list)
+		list_add_tail(&opt_inst->tmp_list, &sel_opt_inst_list);
 	return team_nl_fill_options_get(skb, info->snd_pid,
 					info->snd_seq, NLM_F_ACK,
-					team, true);
+					team, &sel_opt_inst_list);
 }
 
 static int team_nl_cmd_options_get(struct sk_buff *skb, struct genl_info *info)
@@ -1941,7 +1959,8 @@ static struct genl_multicast_group team_change_event_mcgrp = {
 	.name = TEAM_GENL_CHANGE_EVENT_MC_GRP_NAME,
 };
 
-static int team_nl_send_event_options_get(struct team *team)
+static int team_nl_send_event_options_get(struct team *team,
+					  struct list_head *sel_opt_inst_list)
 {
 	struct sk_buff *skb;
 	int err;
@@ -1951,7 +1970,7 @@ static int team_nl_send_event_options_get(struct team *team)
 	if (!skb)
 		return -ENOMEM;
 
-	err = team_nl_fill_options_get(skb, 0, 0, 0, team, false);
+	err = team_nl_fill_options_get(skb, 0, 0, 0, team, sel_opt_inst_list);
 	if (err < 0)
 		goto err_fill;
 
@@ -2021,12 +2040,31 @@ static void team_nl_fini(void)
 static void __team_options_change_check(struct team *team)
 {
 	int err;
+	struct team_option_inst *opt_inst;
+	LIST_HEAD(sel_opt_inst_list);
 
-	err = team_nl_send_event_options_get(team);
+	list_for_each_entry(opt_inst, &team->option_inst_list, list) {
+		if (opt_inst->changed)
+			list_add_tail(&opt_inst->tmp_list, &sel_opt_inst_list);
+	}
+	err = team_nl_send_event_options_get(team, &sel_opt_inst_list);
 	if (err)
 		netdev_warn(team->dev, "Failed to send options change via netlink\n");
 }
 
+static void __team_option_inst_change(struct team *team,
+				      struct team_option_inst *sel_opt_inst)
+{
+	int err;
+	LIST_HEAD(sel_opt_inst_list);
+
+	sel_opt_inst->changed = true;
+	list_add(&sel_opt_inst->tmp_list, &sel_opt_inst_list);
+	err = team_nl_send_event_options_get(team, &sel_opt_inst_list);
+	if (err)
+		netdev_warn(team->dev, "Failed to send option change via netlink\n");
+}
+
 /* rtnl lock is held */
 static void __team_port_change_check(struct team_port *port, bool linkup)
 {
-- 
1.7.10.2
