From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 4/4] team: add support for queue override by setting queue_id for port
Date: Fri, 27 Jul 2012 18:28:55 +0200
Message-ID: <1343406535-22388-5-git-send-email-jiri@resnulli.us>
References: <1343406535-22388-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:52938 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752507Ab2G0Q3J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2012 12:29:09 -0400
Received: by mail-we0-f174.google.com with SMTP id x8so2210290wey.19
        for <netdev@vger.kernel.org>; Fri, 27 Jul 2012 09:29:09 -0700 (PDT)
In-Reply-To: <1343406535-22388-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to what bonding has. This allows to set queue_id for port so
this port will be used when skb with matching skb->queue_mapping is
going to be transmitted.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/team/team.c |  163 ++++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/if_team.h |    4 ++
 2 files changed, 165 insertions(+), 2 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index a30b7c1..ba10c46 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -658,6 +658,122 @@ static rx_handler_result_t team_handle_frame(struct sk_buff **pskb)
 }
 
 
+/*************************************
+ * Multiqueue Tx port select override
+ *************************************/
+
+static int team_queue_override_init(struct team *team)
+{
+	struct list_head *listarr;
+	unsigned int queue_cnt = team->dev->num_tx_queues - 1;
+	unsigned int i;
+
+	if (!queue_cnt)
+		return 0;
+	listarr = kmalloc(sizeof(struct list_head) * queue_cnt, GFP_KERNEL);
+	if (!listarr)
+		return -ENOMEM;
+	team->qom_lists = listarr;
+	for (i = 0; i < queue_cnt; i++)
+		INIT_LIST_HEAD(listarr++);
+	return 0;
+}
+
+static void team_queue_override_fini(struct team *team)
+{
+	kfree(team->qom_lists);
+}
+
+static struct list_head *__team_get_qom_list(struct team *team, u16 queue_id)
+{
+	return &team->qom_lists[queue_id - 1];
+}
+
+/*
+ * note: already called with rcu_read_lock
+ */
+static bool team_queue_override_transmit(struct team *team, struct sk_buff *skb)
+{
+	struct list_head *qom_list;
+	struct team_port *port;
+
+	if (!team->queue_override_enabled || !skb->queue_mapping)
+		return false;
+	qom_list = __team_get_qom_list(team, skb->queue_mapping);
+	list_for_each_entry_rcu(port, qom_list, qom_list) {
+		if (!team_dev_queue_xmit(team, port, skb))
+			return true;
+	}
+	return false;
+}
+
+static void __team_queue_override_port_del(struct team *team,
+					   struct team_port *port)
+{
+	list_del_rcu(&port->qom_list);
+	synchronize_rcu();
+	INIT_LIST_HEAD(&port->qom_list);
+}
+
+static bool team_queue_override_port_has_gt_prio_than(struct team_port *port,
+						      struct team_port *cur)
+{
+	if (port->priority < cur->priority)
+		return true;
+	if (port->priority > cur->priority)
+		return false;
+	if (port->index < cur->index)
+		return true;
+	return false;
+}
+
+static void __team_queue_override_port_add(struct team *team,
+					   struct team_port *port)
+{
+	struct team_port *cur;
+	struct list_head *qom_list;
+	struct list_head *node;
+
+	if (!port->queue_id || !team_port_enabled(port))
+		return;
+
+	qom_list = __team_get_qom_list(team, port->queue_id);
+	node = qom_list;
+	list_for_each_entry(cur, qom_list, qom_list) {
+		if (team_queue_override_port_has_gt_prio_than(port, cur))
+			break;
+		node = &cur->qom_list;
+	}
+	list_add_tail_rcu(&port->qom_list, node);
+}
+
+static void __team_queue_override_enabled_check(struct team *team)
+{
+	struct team_port *port;
+	bool enabled = false;
+
+	list_for_each_entry(port, &team->port_list, list) {
+		if (!list_empty(&port->qom_list)) {
+			enabled = true;
+			break;
+		}
+	}
+	if (enabled == team->queue_override_enabled)
+		return;
+	netdev_dbg(team->dev, "%s queue override\n",
+		   enabled ? "Enabling" : "Disabling");
+	team->queue_override_enabled = enabled;
+}
+
+static void team_queue_override_port_refresh(struct team *team,
+					     struct team_port *port)
+{
+	__team_queue_override_port_del(team, port);
+	__team_queue_override_port_add(team, port);
+	__team_queue_override_enabled_check(team);
+}
+
+
 /****************
  * Port handling
  ****************/
@@ -688,6 +804,7 @@ static void team_port_enable(struct team *team,
 	hlist_add_head_rcu(&port->hlist,
 			   team_port_index_hash(team, port->index));
 	team_adjust_ops(team);
+	team_queue_override_port_refresh(team, port);
 	if (team->ops.port_enabled)
 		team->ops.port_enabled(team, port);
 }
@@ -716,6 +833,7 @@ static void team_port_disable(struct team *team,
 	hlist_del_rcu(&port->hlist);
 	__reconstruct_port_hlist(team, port->index);
 	port->index = -1;
+	team_queue_override_port_refresh(team, port);
 	__team_adjust_ops(team, team->en_port_count - 1);
 	/*
 	 * Wait until readers see adjusted ops. This ensures that
@@ -881,6 +999,7 @@ static int team_port_add(struct team *team, struct net_device *port_dev)
 
 	port->dev = port_dev;
 	port->team = team;
+	INIT_LIST_HEAD(&port->qom_list);
 
 	port->orig.mtu = port_dev->mtu;
 	err = dev_set_mtu(port_dev, dev->mtu);
@@ -1107,9 +1226,34 @@ static int team_priority_option_set(struct team *team,
 	struct team_port *port = ctx->info->port;
 
 	port->priority = ctx->data.s32_val;
+	team_queue_override_port_refresh(team, port);
 	return 0;
 }
 
+static int team_queue_id_option_get(struct team *team,
+				    struct team_gsetter_ctx *ctx)
+{
+	struct team_port *port = ctx->info->port;
+
+	ctx->data.u32_val = port->queue_id;
+	return 0;
+}
+
+static int team_queue_id_option_set(struct team *team,
+				    struct team_gsetter_ctx *ctx)
+{
+	struct team_port *port = ctx->info->port;
+
+	if (port->queue_id == ctx->data.u32_val)
+		return 0;
+	if (ctx->data.u32_val >= team->dev->real_num_tx_queues)
+		return -EINVAL;
+	port->queue_id = ctx->data.u32_val;
+	team_queue_override_port_refresh(team, port);
+	return 0;
+}
+
+
 static const struct team_option team_options[] = {
 	{
 		.name = "mode",
@@ -1145,6 +1289,13 @@ static const struct team_option team_options[] = {
 		.getter = team_priority_option_get,
 		.setter = team_priority_option_set,
 	},
+	{
+		.name = "queue_id",
+		.type = TEAM_OPTION_TYPE_U32,
+		.per_port = true,
+		.getter = team_queue_id_option_get,
+		.setter = team_queue_id_option_set,
+	},
 };
 
 static struct lock_class_key team_netdev_xmit_lock_key;
@@ -1180,6 +1331,9 @@ static int team_init(struct net_device *dev)
 	for (i = 0; i < TEAM_PORT_HASHENTRIES; i++)
 		INIT_HLIST_HEAD(&team->en_port_hlist[i]);
 	INIT_LIST_HEAD(&team->port_list);
+	err = team_queue_override_init(team);
+	if (err)
+		goto err_team_queue_override_init;
 
 	team_adjust_ops(team);
 
@@ -1195,6 +1349,8 @@ static int team_init(struct net_device *dev)
 	return 0;
 
 err_options_register:
+	team_queue_override_fini(team);
+err_team_queue_override_init:
 	free_percpu(team->pcpu_stats);
 
 	return err;
@@ -1212,6 +1368,7 @@ static void team_uninit(struct net_device *dev)
 
 	__team_change_mode(team, NULL); /* cleanup */
 	__team_options_unregister(team, team_options, ARRAY_SIZE(team_options));
+	team_queue_override_fini(team);
 	mutex_unlock(&team->lock);
 }
 
@@ -1241,10 +1398,12 @@ static int team_close(struct net_device *dev)
 static netdev_tx_t team_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct team *team = netdev_priv(dev);
-	bool tx_success = false;
+	bool tx_success;
 	unsigned int len = skb->len;
 
-	tx_success = team->ops.transmit(team, skb);
+	tx_success = team_queue_override_transmit(team, skb);
+	if (!tx_success)
+		tx_success = team->ops.transmit(team, skb);
 	if (tx_success) {
 		struct team_pcpu_stats *pcpu_stats;
 
diff --git a/include/linux/if_team.h b/include/linux/if_team.h
index 06495b3..33fcc20 100644
--- a/include/linux/if_team.h
+++ b/include/linux/if_team.h
@@ -68,6 +68,8 @@ struct team_port {
 #endif
 
 	s32 priority; /* lower number ~ higher priority */
+	u16 queue_id;
+	struct list_head qom_list; /* node in queue override mapping list */
 	long mode_priv[0];
 };
 
@@ -200,6 +202,8 @@ struct team {
 
 	const struct team_mode *mode;
 	struct team_mode_ops ops;
+	bool queue_override_enabled;
+	struct list_head *qom_lists; /* array of queue override mapping lists */
 	long mode_priv[TEAM_MODE_PRIV_LONGS];
 };
 
-- 
1.7.10.4
