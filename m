From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 16/19] team: implement multipart netlink messages for options transfers
Date: Tue, 19 Jun 2012 17:54:18 +0200
Message-ID: <1340121261-2966-17-git-send-email-jpirko@redhat.com>
References: <1340121261-2966-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, jbrouer@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36006 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754657Ab2FSPyu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2012 11:54:50 -0400
In-Reply-To: <1340121261-2966-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/team/team.c |  198 +++++++++++++++++++++++++++--------------------
 1 file changed, 116 insertions(+), 82 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index bc76f94..9e9d3e5 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1571,102 +1571,128 @@ err_fill:
 	return err;
 }
 
+typedef int team_nl_send_func_t(struct sk_buff *skb,
+				struct team *team, u32 pid);
+
+static int team_nl_send_unicast(struct sk_buff *skb, struct team *team, u32 pid)
+{
+	return genlmsg_unicast(dev_net(team->dev), skb, pid);
+}
+
 static int team_nl_fill_one_option_get(struct sk_buff *skb, struct team *team,
 				       struct team_option_inst *opt_inst)
 {
 	struct nlattr *option_item;
 	struct team_option *option = opt_inst->option;
-	struct team_option_inst_info *opt_inst_info;
+	struct team_option_inst_info *opt_inst_info = &opt_inst->info;
 	struct team_gsetter_ctx ctx;
 	int err;
 
+	ctx.info = opt_inst_info;
+	err = team_option_get(team, opt_inst, &ctx);
+	if (err)
+		return err;
+
 	option_item = nla_nest_start(skb, TEAM_ATTR_ITEM_OPTION);
 	if (!option_item)
-		goto nla_put_failure;
-	if (nla_put_string(skb, TEAM_ATTR_OPTION_NAME, option->name))
-		goto nla_put_failure;
-	if (opt_inst->changed) {
-		if (nla_put_flag(skb, TEAM_ATTR_OPTION_CHANGED))
-			goto nla_put_failure;
-		opt_inst->changed = false;
-	}
-	if (opt_inst->removed && nla_put_flag(skb, TEAM_ATTR_OPTION_REMOVED))
-		goto nla_put_failure;
+		return -EMSGSIZE;
 
-	opt_inst_info = &opt_inst->info;
+	if (nla_put_string(skb, TEAM_ATTR_OPTION_NAME, option->name))
+		goto nest_cancel;
 	if (opt_inst_info->port &&
 	    nla_put_u32(skb, TEAM_ATTR_OPTION_PORT_IFINDEX,
 			opt_inst_info->port->dev->ifindex))
-		goto nla_put_failure;
+		goto nest_cancel;
 	if (opt_inst->option->array_size &&
 	    nla_put_u32(skb, TEAM_ATTR_OPTION_ARRAY_INDEX,
 			opt_inst_info->array_index))
-		goto nla_put_failure;
-	ctx.info = opt_inst_info;
+		goto nest_cancel;
 
 	switch (option->type) {
 	case TEAM_OPTION_TYPE_U32:
 		if (nla_put_u8(skb, TEAM_ATTR_OPTION_TYPE, NLA_U32))
-			goto nla_put_failure;
-		err = team_option_get(team, opt_inst, &ctx);
-		if (err)
-			goto errout;
+			goto nest_cancel;
 		if (nla_put_u32(skb, TEAM_ATTR_OPTION_DATA, ctx.data.u32_val))
-			goto nla_put_failure;
+			goto nest_cancel;
 		break;
 	case TEAM_OPTION_TYPE_STRING:
 		if (nla_put_u8(skb, TEAM_ATTR_OPTION_TYPE, NLA_STRING))
-			goto nla_put_failure;
-		err = team_option_get(team, opt_inst, &ctx);
-		if (err)
-			goto errout;
+			goto nest_cancel;
 		if (nla_put_string(skb, TEAM_ATTR_OPTION_DATA,
 				   ctx.data.str_val))
-			goto nla_put_failure;
+			goto nest_cancel;
 		break;
 	case TEAM_OPTION_TYPE_BINARY:
 		if (nla_put_u8(skb, TEAM_ATTR_OPTION_TYPE, NLA_BINARY))
-			goto nla_put_failure;
-		err = team_option_get(team, opt_inst, &ctx);
-		if (err)
-			goto errout;
+			goto nest_cancel;
 		if (nla_put(skb, TEAM_ATTR_OPTION_DATA, ctx.data.bin_val.len,
 			    ctx.data.bin_val.ptr))
-			goto nla_put_failure;
+			goto nest_cancel;
 		break;
 	case TEAM_OPTION_TYPE_BOOL:
 		if (nla_put_u8(skb, TEAM_ATTR_OPTION_TYPE, NLA_FLAG))
-			goto nla_put_failure;
-		err = team_option_get(team, opt_inst, &ctx);
-		if (err)
-			goto errout;
+			goto nest_cancel;
 		if (ctx.data.bool_val &&
 		    nla_put_flag(skb, TEAM_ATTR_OPTION_DATA))
-			goto nla_put_failure;
+			goto nest_cancel;
 		break;
 	default:
 		BUG();
 	}
+	if (opt_inst->removed && nla_put_flag(skb, TEAM_ATTR_OPTION_REMOVED))
+		goto nest_cancel;
+	if (opt_inst->changed) {
+		if (nla_put_flag(skb, TEAM_ATTR_OPTION_CHANGED))
+			goto nest_cancel;
+		opt_inst->changed = false;
+	}
 	nla_nest_end(skb, option_item);
 	return 0;
 
-nla_put_failure:
-	err = -EMSGSIZE;
-errout:
-	return err;
+nest_cancel:
+	nla_nest_cancel(skb, option_item);
+	return -EMSGSIZE;
+}
+
+static int __send_and_alloc_skb(struct sk_buff **pskb,
+				struct team *team, u32 pid,
+				team_nl_send_func_t *send_func)
+{
+	int err;
+
+	if (*pskb) {
+		err = send_func(*pskb, team, pid);
+		if (err)
+			return err;
+	}
+	*pskb = genlmsg_new(NLMSG_DEFAULT_SIZE - GENL_HDRLEN, GFP_KERNEL);
+	if (!*pskb)
+		return -ENOMEM;
+	return 0;
 }
 
-static int team_nl_fill_options_get(struct sk_buff *skb,
-				    u32 pid, u32 seq, int flags,
-				    struct team *team,
+static int team_nl_send_options_get(struct team *team, u32 pid, u32 seq,
+				    int flags, team_nl_send_func_t *send_func,
 				    struct list_head *sel_opt_inst_list)
 {
 	struct nlattr *option_list;
+	struct nlmsghdr *nlh;
 	void *hdr;
 	struct team_option_inst *opt_inst;
 	int err;
+	struct sk_buff *skb = NULL;
+	bool incomplete;
+	int i;
 
-	hdr = genlmsg_put(skb, pid, seq, &team_nl_family, flags,
+	opt_inst = list_first_entry(sel_opt_inst_list,
+				    struct team_option_inst, tmp_list);
+
+start_again:
+	err = __send_and_alloc_skb(&skb, team, pid, send_func);
+	if (err)
+		return err;
+
+	hdr = genlmsg_put(skb, pid, seq, &team_nl_family, flags | NLM_F_MULTI,
 			  TEAM_CMD_OPTIONS_GET);
 	if (IS_ERR(hdr))
 		return PTR_ERR(hdr);
@@ -1677,46 +1703,62 @@ static int team_nl_fill_options_get(struct sk_buff *skb,
 	if (!option_list)
 		goto nla_put_failure;
 
-	list_for_each_entry(opt_inst, sel_opt_inst_list, tmp_list) {
+	i = 0;
+	incomplete = false;
+	list_for_each_entry_from(opt_inst, sel_opt_inst_list, tmp_list) {
 		err = team_nl_fill_one_option_get(skb, team, opt_inst);
-		if (err)
+		if (err) {
+			if (err == -EMSGSIZE) {
+				if (!i)
+					goto errout;
+				incomplete = true;
+				break;
+			}
 			goto errout;
+		}
+		i++;
 	}
 
 	nla_nest_end(skb, option_list);
-	return genlmsg_end(skb, hdr);
+	genlmsg_end(skb, hdr);
+	if (incomplete)
+		goto start_again;
+
+send_done:
+	nlh = nlmsg_put(skb, pid, seq, NLMSG_DONE, 0, flags | NLM_F_MULTI);
+	if (!nlh) {
+		err = __send_and_alloc_skb(&skb, team, pid, send_func);
+		if (err)
+			goto errout;
+		goto send_done;
+	}
+
+	return send_func(skb, team, pid);
 
 nla_put_failure:
 	err = -EMSGSIZE;
 errout:
 	genlmsg_cancel(skb, hdr);
+	nlmsg_free(skb);
 	return err;
 }
 
-static int team_nl_fill_options_get_all(struct sk_buff *skb,
-					struct genl_info *info, int flags,
-					struct team *team)
-{
-	struct team_option_inst *opt_inst;
-	LIST_HEAD(sel_opt_inst_list);
-
-	list_for_each_entry(opt_inst, &team->option_inst_list, list)
-		list_add_tail(&opt_inst->tmp_list, &sel_opt_inst_list);
-	return team_nl_fill_options_get(skb, info->snd_pid,
-					info->snd_seq, NLM_F_ACK,
-					team, &sel_opt_inst_list);
-}
-
 static int team_nl_cmd_options_get(struct sk_buff *skb, struct genl_info *info)
 {
 	struct team *team;
+	struct team_option_inst *opt_inst;
 	int err;
+	LIST_HEAD(sel_opt_inst_list);
 
 	team = team_nl_team_get(info);
 	if (!team)
 		return -EINVAL;
 
-	err = team_nl_send_generic(info, team, team_nl_fill_options_get_all);
+	list_for_each_entry(opt_inst, &team->option_inst_list, list)
+		list_add_tail(&opt_inst->tmp_list, &sel_opt_inst_list);
+	err = team_nl_send_options_get(team, info->snd_pid, info->snd_seq,
+				       NLM_F_ACK, team_nl_send_unicast,
+				       &sel_opt_inst_list);
 
 	team_nl_team_put(team);
 
@@ -1963,28 +2005,18 @@ static struct genl_multicast_group team_change_event_mcgrp = {
 	.name = TEAM_GENL_CHANGE_EVENT_MC_GRP_NAME,
 };
 
+static int team_nl_send_multicast(struct sk_buff *skb,
+				  struct team *team, u32 pid)
+{
+	return genlmsg_multicast_netns(dev_net(team->dev), skb, 0,
+				       team_change_event_mcgrp.id, GFP_KERNEL);
+}
+
 static int team_nl_send_event_options_get(struct team *team,
 					  struct list_head *sel_opt_inst_list)
 {
-	struct sk_buff *skb;
-	int err;
-	struct net *net = dev_net(team->dev);
-
-	skb = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
-	if (!skb)
-		return -ENOMEM;
-
-	err = team_nl_fill_options_get(skb, 0, 0, 0, team, sel_opt_inst_list);
-	if (err < 0)
-		goto err_fill;
-
-	err = genlmsg_multicast_netns(net, skb, 0, team_change_event_mcgrp.id,
-				      GFP_KERNEL);
-	return err;
-
-err_fill:
-	nlmsg_free(skb);
-	return err;
+	return team_nl_send_options_get(team, 0, 0, 0, team_nl_send_multicast,
+					sel_opt_inst_list);
 }
 
 static int team_nl_send_event_port_list_get(struct team *team)
@@ -2053,7 +2085,8 @@ static void __team_options_change_check(struct team *team)
 	}
 	err = team_nl_send_event_options_get(team, &sel_opt_inst_list);
 	if (err)
-		netdev_warn(team->dev, "Failed to send options change via netlink\n");
+		netdev_warn(team->dev, "Failed to send options change via netlink (err %d)\n",
+			    err);
 }
 
 static void __team_option_inst_change(struct team *team,
@@ -2066,7 +2099,8 @@ static void __team_option_inst_change(struct team *team,
 	list_add(&sel_opt_inst->tmp_list, &sel_opt_inst_list);
 	err = team_nl_send_event_options_get(team, &sel_opt_inst_list);
 	if (err)
-		netdev_warn(team->dev, "Failed to send option change via netlink\n");
+		netdev_warn(team->dev, "Failed to send option change via netlink (err %d)\n",
+			    err);
 }
 
 /* rtnl lock is held */
-- 
1.7.10.2
