From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/3] team: add peer notification
Date: Fri, 19 Jul 2013 15:40:20 +0200
Message-ID: <1374241222-9683-2-git-send-email-jiri@resnulli.us>
References: <1374241222-9683-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, fubar@us.ibm.com, andy@greyhouse.net,
	kaber@trash.net, stephen@networkplumber.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, edumazet@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f48.google.com ([74.125.83.48]:44882 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760297Ab3GSNkb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 09:40:31 -0400
Received: by mail-ee0-f48.google.com with SMTP id b47so2348559eek.21
        for <netdev@vger.kernel.org>; Fri, 19 Jul 2013 06:40:29 -0700 (PDT)
In-Reply-To: <1374241222-9683-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When port is enabled or disabled, allow to notify peers by unsolicitated
NAs or gratuitous ARPs. Disabled by default.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/team/team.c | 87 +++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/if_team.h |  8 ++++-
 2 files changed, 94 insertions(+), 1 deletion(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index bff7e0b..9b185f7 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -622,6 +622,46 @@ static int team_change_mode(struct team *team, const char *kind)
 }
 
 
+/*********************
+ * Peers notification
+ *********************/
+
+static void team_notify_peers_work(struct work_struct *work)
+{
+	struct team *team;
+
+	team = container_of(work, struct team, notify_peers.dw.work);
+
+	if (!rtnl_trylock()) {
+		schedule_delayed_work(&team->notify_peers.dw, 0);
+		return;
+	}
+	call_netdevice_notifiers(NETDEV_NOTIFY_PEERS, team->dev);
+	rtnl_unlock();
+	if (!atomic_dec_and_test(&team->notify_peers.count_pending))
+		schedule_delayed_work(&team->notify_peers.dw,
+				      (team->notify_peers.interval * HZ) / 1000);
+}
+
+static void team_notify_peers(struct team *team)
+{
+	if (!team->notify_peers.count || !netif_running(team->dev))
+		return;
+	atomic_set(&team->notify_peers.count_pending, team->notify_peers.count);
+	schedule_delayed_work(&team->notify_peers.dw, 0);
+}
+
+static void team_notify_peers_init(struct team *team)
+{
+	INIT_DELAYED_WORK(&team->notify_peers.dw, team_notify_peers_work);
+}
+
+static void team_notify_peers_fini(struct team *team)
+{
+	cancel_delayed_work_sync(&team->notify_peers.dw);
+}
+
+
 /************************
  * Rx path frame handler
  ************************/
@@ -846,6 +886,7 @@ static void team_port_enable(struct team *team,
 	team_queue_override_port_add(team, port);
 	if (team->ops.port_enabled)
 		team->ops.port_enabled(team, port);
+	team_notify_peers(team);
 }
 
 static void __reconstruct_port_hlist(struct team *team, int rm_index)
@@ -875,6 +916,7 @@ static void team_port_disable(struct team *team,
 	team->en_port_count--;
 	team_queue_override_port_del(team, port);
 	team_adjust_ops(team);
+	team_notify_peers(team);
 }
 
 #define TEAM_VLAN_FEATURES (NETIF_F_ALL_CSUM | NETIF_F_SG | \
@@ -1205,6 +1247,34 @@ static int team_mode_option_set(struct team *team, struct team_gsetter_ctx *ctx)
 	return team_change_mode(team, ctx->data.str_val);
 }
 
+static int team_notify_peers_count_get(struct team *team,
+				       struct team_gsetter_ctx *ctx)
+{
+	ctx->data.u32_val = team->notify_peers.count;
+	return 0;
+}
+
+static int team_notify_peers_count_set(struct team *team,
+				       struct team_gsetter_ctx *ctx)
+{
+	team->notify_peers.count = ctx->data.u32_val;
+	return 0;
+}
+
+static int team_notify_peers_interval_get(struct team *team,
+					  struct team_gsetter_ctx *ctx)
+{
+	ctx->data.u32_val = team->notify_peers.interval;
+	return 0;
+}
+
+static int team_notify_peers_interval_set(struct team *team,
+					  struct team_gsetter_ctx *ctx)
+{
+	team->notify_peers.interval = ctx->data.u32_val;
+	return 0;
+}
+
 static int team_port_en_option_get(struct team *team,
 				   struct team_gsetter_ctx *ctx)
 {
@@ -1317,6 +1387,18 @@ static const struct team_option team_options[] = {
 		.setter = team_mode_option_set,
 	},
 	{
+		.name = "notify_peers_count",
+		.type = TEAM_OPTION_TYPE_U32,
+		.getter = team_notify_peers_count_get,
+		.setter = team_notify_peers_count_set,
+	},
+	{
+		.name = "notify_peers_interval",
+		.type = TEAM_OPTION_TYPE_U32,
+		.getter = team_notify_peers_interval_get,
+		.setter = team_notify_peers_interval_set,
+	},
+	{
 		.name = "enabled",
 		.type = TEAM_OPTION_TYPE_BOOL,
 		.per_port = true,
@@ -1396,6 +1478,9 @@ static int team_init(struct net_device *dev)
 
 	INIT_LIST_HEAD(&team->option_list);
 	INIT_LIST_HEAD(&team->option_inst_list);
+
+	team_notify_peers_init(team);
+
 	err = team_options_register(team, team_options, ARRAY_SIZE(team_options));
 	if (err)
 		goto err_options_register;
@@ -1406,6 +1491,7 @@ static int team_init(struct net_device *dev)
 	return 0;
 
 err_options_register:
+	team_notify_peers_fini(team);
 	team_queue_override_fini(team);
 err_team_queue_override_init:
 	free_percpu(team->pcpu_stats);
@@ -1425,6 +1511,7 @@ static void team_uninit(struct net_device *dev)
 
 	__team_change_mode(team, NULL); /* cleanup */
 	__team_options_unregister(team, team_options, ARRAY_SIZE(team_options));
+	team_notify_peers_fini(team);
 	team_queue_override_fini(team);
 	mutex_unlock(&team->lock);
 }
diff --git a/include/linux/if_team.h b/include/linux/if_team.h
index f6156f9..b0b8368 100644
--- a/include/linux/if_team.h
+++ b/include/linux/if_team.h
@@ -10,9 +10,9 @@
 #ifndef _LINUX_IF_TEAM_H_
 #define _LINUX_IF_TEAM_H_
 
-
 #include <linux/netpoll.h>
 #include <net/sch_generic.h>
+#include <linux/types.h>
 #include <uapi/linux/if_team.h>
 
 struct team_pcpu_stats {
@@ -194,6 +194,12 @@ struct team {
 	bool user_carrier_enabled;
 	bool queue_override_enabled;
 	struct list_head *qom_lists; /* array of queue override mapping lists */
+	struct {
+		unsigned int count;
+		unsigned int interval; /* in ms */
+		atomic_t count_pending;
+		struct delayed_work dw;
+	} notify_peers;
 	long mode_priv[TEAM_MODE_PRIV_LONGS];
 };
 
-- 
1.8.1.4
