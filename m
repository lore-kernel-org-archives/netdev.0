From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 3/3] team: add support for sending multicast rejoins
Date: Sat, 20 Jul 2013 12:13:54 +0200
Message-ID: <1374315234-7096-4-git-send-email-jiri@resnulli.us>
References: <1374315234-7096-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, fubar@us.ibm.com, andy@greyhouse.net,
	kaber@trash.net, stephen@networkplumber.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, edumazet@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f178.google.com ([209.85.215.178]:45044 "EHLO
	mail-ea0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753549Ab3GTKOI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jul 2013 06:14:08 -0400
Received: by mail-ea0-f178.google.com with SMTP id l15so2797734eak.23
        for <netdev@vger.kernel.org>; Sat, 20 Jul 2013 03:14:06 -0700 (PDT)
In-Reply-To: <1374315234-7096-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to what is implemented in bonding. User is able to ask team
driver to send IGMP rejoins in case port is enabled or disabled. Using
previously introduced netdev notifier.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/team/team.c | 85 +++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/if_team.h |  6 ++++
 2 files changed, 91 insertions(+)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 2587dc8..75159e4 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -662,6 +662,46 @@ static void team_notify_peers_fini(struct team *team)
 }
 
 
+/*******************************
+ * Send multicast group rejoins
+ *******************************/
+
+static void team_mcast_rejoin_work(struct work_struct *work)
+{
+	struct team *team;
+
+	team = container_of(work, struct team, mcast_rejoin.dw.work);
+
+	if (!rtnl_trylock()) {
+		schedule_delayed_work(&team->mcast_rejoin.dw, 0);
+		return;
+	}
+	call_netdevice_notifiers(NETDEV_RESEND_IGMP, team->dev);
+	rtnl_unlock();
+	if (!atomic_dec_and_test(&team->mcast_rejoin.count_pending))
+		schedule_delayed_work(&team->mcast_rejoin.dw,
+				      msecs_to_jiffies(team->mcast_rejoin.interval));
+}
+
+static void team_mcast_rejoin(struct team *team)
+{
+	if (!team->mcast_rejoin.count || !netif_running(team->dev))
+		return;
+	atomic_set(&team->mcast_rejoin.count_pending, team->mcast_rejoin.count);
+	schedule_delayed_work(&team->mcast_rejoin.dw, 0);
+}
+
+static void team_mcast_rejoin_init(struct team *team)
+{
+	INIT_DELAYED_WORK(&team->mcast_rejoin.dw, team_mcast_rejoin_work);
+}
+
+static void team_mcast_rejoin_fini(struct team *team)
+{
+	cancel_delayed_work_sync(&team->mcast_rejoin.dw);
+}
+
+
 /************************
  * Rx path frame handler
  ************************/
@@ -887,6 +927,7 @@ static void team_port_enable(struct team *team,
 	if (team->ops.port_enabled)
 		team->ops.port_enabled(team, port);
 	team_notify_peers(team);
+	team_mcast_rejoin(team);
 }
 
 static void __reconstruct_port_hlist(struct team *team, int rm_index)
@@ -917,6 +958,7 @@ static void team_port_disable(struct team *team,
 	team_queue_override_port_del(team, port);
 	team_adjust_ops(team);
 	team_notify_peers(team);
+	team_mcast_rejoin(team);
 }
 
 #define TEAM_VLAN_FEATURES (NETIF_F_ALL_CSUM | NETIF_F_SG | \
@@ -1275,6 +1317,34 @@ static int team_notify_peers_interval_set(struct team *team,
 	return 0;
 }
 
+static int team_mcast_rejoin_count_get(struct team *team,
+				       struct team_gsetter_ctx *ctx)
+{
+	ctx->data.u32_val = team->mcast_rejoin.count;
+	return 0;
+}
+
+static int team_mcast_rejoin_count_set(struct team *team,
+				       struct team_gsetter_ctx *ctx)
+{
+	team->mcast_rejoin.count = ctx->data.u32_val;
+	return 0;
+}
+
+static int team_mcast_rejoin_interval_get(struct team *team,
+					  struct team_gsetter_ctx *ctx)
+{
+	ctx->data.u32_val = team->mcast_rejoin.interval;
+	return 0;
+}
+
+static int team_mcast_rejoin_interval_set(struct team *team,
+					  struct team_gsetter_ctx *ctx)
+{
+	team->mcast_rejoin.interval = ctx->data.u32_val;
+	return 0;
+}
+
 static int team_port_en_option_get(struct team *team,
 				   struct team_gsetter_ctx *ctx)
 {
@@ -1399,6 +1469,18 @@ static const struct team_option team_options[] = {
 		.setter = team_notify_peers_interval_set,
 	},
 	{
+		.name = "mcast_rejoin_count",
+		.type = TEAM_OPTION_TYPE_U32,
+		.getter = team_mcast_rejoin_count_get,
+		.setter = team_mcast_rejoin_count_set,
+	},
+	{
+		.name = "mcast_rejoin_interval",
+		.type = TEAM_OPTION_TYPE_U32,
+		.getter = team_mcast_rejoin_interval_get,
+		.setter = team_mcast_rejoin_interval_set,
+	},
+	{
 		.name = "enabled",
 		.type = TEAM_OPTION_TYPE_BOOL,
 		.per_port = true,
@@ -1480,6 +1562,7 @@ static int team_init(struct net_device *dev)
 	INIT_LIST_HEAD(&team->option_inst_list);
 
 	team_notify_peers_init(team);
+	team_mcast_rejoin_init(team);
 
 	err = team_options_register(team, team_options, ARRAY_SIZE(team_options));
 	if (err)
@@ -1491,6 +1574,7 @@ static int team_init(struct net_device *dev)
 	return 0;
 
 err_options_register:
+	team_mcast_rejoin_fini(team);
 	team_notify_peers_fini(team);
 	team_queue_override_fini(team);
 err_team_queue_override_init:
@@ -1511,6 +1595,7 @@ static void team_uninit(struct net_device *dev)
 
 	__team_change_mode(team, NULL); /* cleanup */
 	__team_options_unregister(team, team_options, ARRAY_SIZE(team_options));
+	team_mcast_rejoin_fini(team);
 	team_notify_peers_fini(team);
 	team_queue_override_fini(team);
 	mutex_unlock(&team->lock);
diff --git a/include/linux/if_team.h b/include/linux/if_team.h
index b0b8368..a899dc2 100644
--- a/include/linux/if_team.h
+++ b/include/linux/if_team.h
@@ -200,6 +200,12 @@ struct team {
 		atomic_t count_pending;
 		struct delayed_work dw;
 	} notify_peers;
+	struct {
+		unsigned int count;
+		unsigned int interval; /* in ms */
+		atomic_t count_pending;
+		struct delayed_work dw;
+	} mcast_rejoin;
 	long mode_priv[TEAM_MODE_PRIV_LONGS];
 };
 
-- 
1.8.1.4
