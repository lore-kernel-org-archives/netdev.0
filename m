From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 18/19] team: allow to send multiple set events in one message
Date: Tue, 19 Jun 2012 17:54:20 +0200
Message-ID: <1340121261-2966-19-git-send-email-jpirko@redhat.com>
References: <1340121261-2966-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, jbrouer@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43071 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754787Ab2FSPyx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2012 11:54:53 -0400
In-Reply-To: <1340121261-2966-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When multiple sets are done, event message is generated for each. This
patch accumulates these messages into one.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/team/team.c |   33 +++++++++------------------------
 1 file changed, 9 insertions(+), 24 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index a7b391d..3a4a74b 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -320,8 +320,6 @@ static void __team_options_unregister(struct team *team,
 }
 
 static void __team_options_change_check(struct team *team);
-static void __team_option_inst_change(struct team *team,
-				      struct team_option_inst *opt_inst);
 
 int team_options_register(struct team *team,
 			  const struct team_option *option,
@@ -360,16 +358,9 @@ static int team_option_set(struct team *team,
 			   struct team_option_inst *opt_inst,
 			   struct team_gsetter_ctx *ctx)
 {
-	int err;
-
 	if (!opt_inst->option->setter)
 		return -EOPNOTSUPP;
-	err = opt_inst->option->setter(team, ctx);
-	if (err)
-		return err;
-
-	__team_option_inst_change(team, opt_inst);
-	return err;
+	return opt_inst->option->setter(team, ctx);
 }
 
 void team_option_inst_set_change(struct team_option_inst_info *opt_inst_info)
@@ -1750,12 +1741,16 @@ static int team_nl_cmd_options_get(struct sk_buff *skb, struct genl_info *info)
 	return err;
 }
 
+static int team_nl_send_event_options_get(struct team *team,
+					  struct list_head *sel_opt_inst_list);
+
 static int team_nl_cmd_options_set(struct sk_buff *skb, struct genl_info *info)
 {
 	struct team *team;
 	int err = 0;
 	int i;
 	struct nlattr *nl_option;
+	LIST_HEAD(opt_inst_list);
 
 	team = team_nl_team_get(info);
 	if (!team)
@@ -1867,6 +1862,8 @@ static int team_nl_cmd_options_set(struct sk_buff *skb, struct genl_info *info)
 			err = team_option_set(team, opt_inst, &ctx);
 			if (err)
 				goto team_put;
+			opt_inst->changed = true;
+			list_add(&opt_inst->tmp_list, &opt_inst_list);
 		}
 		if (!opt_found) {
 			err = -ENOENT;
@@ -1874,6 +1871,8 @@ static int team_nl_cmd_options_set(struct sk_buff *skb, struct genl_info *info)
 		}
 	}
 
+	err = team_nl_send_event_options_get(team, &opt_inst_list);
+
 team_put:
 	team_nl_team_put(team);
 
@@ -2074,20 +2073,6 @@ static void __team_options_change_check(struct team *team)
 			    err);
 }
 
-static void __team_option_inst_change(struct team *team,
-				      struct team_option_inst *sel_opt_inst)
-{
-	int err;
-	LIST_HEAD(sel_opt_inst_list);
-
-	sel_opt_inst->changed = true;
-	list_add(&sel_opt_inst->tmp_list, &sel_opt_inst_list);
-	err = team_nl_send_event_options_get(team, &sel_opt_inst_list);
-	if (err)
-		netdev_warn(team->dev, "Failed to send option change via netlink (err %d)\n",
-			    err);
-}
-
 /* rtnl lock is held */
 static void __team_port_change_check(struct team_port *port, bool linkup)
 {
-- 
1.7.10.2
