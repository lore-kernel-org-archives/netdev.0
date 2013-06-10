From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/3] team: remove synchronize_rcu() called during queue override change
Date: Mon, 10 Jun 2013 17:42:23 +0200
Message-ID: <1370878945-9718-2-git-send-email-jiri@resnulli.us>
References: <1370878945-9718-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, fbl@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f41.google.com ([74.125.83.41]:62640 "EHLO
	mail-ee0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750976Ab3FJPmz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 11:42:55 -0400
Received: by mail-ee0-f41.google.com with SMTP id d17so1681356eek.14
        for <netdev@vger.kernel.org>; Mon, 10 Jun 2013 08:42:53 -0700 (PDT)
In-Reply-To: <1370878945-9718-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes synchronize_rcu() from function
__team_queue_override_port_del(). That can be done because it is ok to
do list_del_rcu() and list_add_tail_rcu() on the same list_head member
without calling synchronize_rcu() in between. A bit of refactoring
needed to be done because INIT_LIST_HEAD needed to be removed (to not
kill the forward pointer) as well.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/team/team.c | 63 ++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 47 insertions(+), 16 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 4ac10f2..f00446e 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -725,9 +725,9 @@ static bool team_queue_override_transmit(struct team *team, struct sk_buff *skb)
 static void __team_queue_override_port_del(struct team *team,
 					   struct team_port *port)
 {
+	if (!port->queue_id)
+		return;
 	list_del_rcu(&port->qom_list);
-	synchronize_rcu();
-	INIT_LIST_HEAD(&port->qom_list);
 }
 
 static bool team_queue_override_port_has_gt_prio_than(struct team_port *port,
@@ -749,9 +749,8 @@ static void __team_queue_override_port_add(struct team *team,
 	struct list_head *qom_list;
 	struct list_head *node;
 
-	if (!port->queue_id || !team_port_enabled(port))
+	if (!port->queue_id)
 		return;
-
 	qom_list = __team_get_qom_list(team, port->queue_id);
 	node = qom_list;
 	list_for_each_entry(cur, qom_list, qom_list) {
@@ -768,7 +767,7 @@ static void __team_queue_override_enabled_check(struct team *team)
 	bool enabled = false;
 
 	list_for_each_entry(port, &team->port_list, list) {
-		if (!list_empty(&port->qom_list)) {
+		if (port->queue_id) {
 			enabled = true;
 			break;
 		}
@@ -780,14 +779,44 @@ static void __team_queue_override_enabled_check(struct team *team)
 	team->queue_override_enabled = enabled;
 }
 
-static void team_queue_override_port_refresh(struct team *team,
-					     struct team_port *port)
+static void team_queue_override_port_prio_changed(struct team *team,
+						  struct team_port *port)
 {
+	if (!port->queue_id || team_port_enabled(port))
+		return;
 	__team_queue_override_port_del(team, port);
 	__team_queue_override_port_add(team, port);
 	__team_queue_override_enabled_check(team);
 }
 
+static void team_queue_override_port_change_queue_id(struct team *team,
+						     struct team_port *port,
+						     u16 new_queue_id)
+{
+	if (team_port_enabled(port)) {
+		__team_queue_override_port_del(team, port);
+		port->queue_id = new_queue_id;
+		__team_queue_override_port_add(team, port);
+		__team_queue_override_enabled_check(team);
+	} else {
+		port->queue_id = new_queue_id;
+	}
+}
+
+static void team_queue_override_port_add(struct team *team,
+					 struct team_port *port)
+{
+	__team_queue_override_port_add(team, port);
+	__team_queue_override_enabled_check(team);
+}
+
+static void team_queue_override_port_del(struct team *team,
+					 struct team_port *port)
+{
+	__team_queue_override_port_del(team, port);
+	__team_queue_override_enabled_check(team);
+}
+
 
 /****************
  * Port handling
@@ -819,7 +848,7 @@ static void team_port_enable(struct team *team,
 	hlist_add_head_rcu(&port->hlist,
 			   team_port_index_hash(team, port->index));
 	team_adjust_ops(team);
-	team_queue_override_port_refresh(team, port);
+	team_queue_override_port_add(team, port);
 	if (team->ops.port_enabled)
 		team->ops.port_enabled(team, port);
 }
@@ -848,7 +877,7 @@ static void team_port_disable(struct team *team,
 	hlist_del_rcu(&port->hlist);
 	__reconstruct_port_hlist(team, port->index);
 	port->index = -1;
-	team_queue_override_port_refresh(team, port);
+	team_queue_override_port_del(team, port);
 	__team_adjust_ops(team, team->en_port_count - 1);
 	/*
 	 * Wait until readers see adjusted ops. This ensures that
@@ -1259,9 +1288,12 @@ static int team_priority_option_set(struct team *team,
 				    struct team_gsetter_ctx *ctx)
 {
 	struct team_port *port = ctx->info->port;
+	s32 priority = ctx->data.s32_val;
 
-	port->priority = ctx->data.s32_val;
-	team_queue_override_port_refresh(team, port);
+	if (port->priority == priority)
+		return 0;
+	port->priority = priority;
+	team_queue_override_port_prio_changed(team, port);
 	return 0;
 }
 
@@ -1278,17 +1310,16 @@ static int team_queue_id_option_set(struct team *team,
 				    struct team_gsetter_ctx *ctx)
 {
 	struct team_port *port = ctx->info->port;
+	u16 new_queue_id = ctx->data.u32_val;
 
-	if (port->queue_id == ctx->data.u32_val)
+	if (port->queue_id == new_queue_id)
 		return 0;
-	if (ctx->data.u32_val >= team->dev->real_num_tx_queues)
+	if (new_queue_id >= team->dev->real_num_tx_queues)
 		return -EINVAL;
-	port->queue_id = ctx->data.u32_val;
-	team_queue_override_port_refresh(team, port);
+	team_queue_override_port_change_queue_id(team, port, new_queue_id);
 	return 0;
 }
 
-
 static const struct team_option team_options[] = {
 	{
 		.name = "mode",
-- 
1.8.1.4
