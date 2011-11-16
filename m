From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 3/3] team: replicate options on register
Date: Wed, 16 Nov 2011 22:09:09 +0100
Message-ID: <1321477749-1877-4-git-send-email-jpirko@redhat.com>
References: <1321477749-1877-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	andy@greyhouse.net, fbl@redhat.com, jzupka@redhat.com,
	ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8513 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753713Ab1KPVJV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Nov 2011 16:09:21 -0500
In-Reply-To: <1321477749-1877-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since multiple team instances are putting defined options into their
option list, during register each option must be cloned before added
into list. This resolves uncool memory corruptions when using multiple
teams.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/team/team.c                   |   76 +++++++++++++++++++++++++----
 drivers/net/team/team_mode_activebackup.c |    5 +-
 include/linux/if_team.h                   |    8 ++--
 3 files changed, 72 insertions(+), 17 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 04f9302..b47f43e 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -80,30 +80,78 @@ EXPORT_SYMBOL(team_port_set_team_mac);
  * Options handling
  *******************/
 
-void team_options_register(struct team *team, struct team_option *option,
-			   size_t option_count)
+struct team_option *__team_find_option(struct team *team, const char *opt_name)
+{
+	struct team_option *option;
+
+	list_for_each_entry(option, &team->option_list, list) {
+		if (strcmp(option->name, opt_name) == 0)
+			return option;
+	}
+	return NULL;
+}
+
+int team_options_register(struct team *team,
+			  const struct team_option *option,
+			  size_t option_count)
 {
 	int i;
+	struct team_option *dst_opts[option_count];
+	int err;
+
+	memset(dst_opts, 0, sizeof(dst_opts));
+	for (i = 0; i < option_count; i++, option++) {
+		struct team_option *dst_opt;
+
+		if (__team_find_option(team, option->name)) {
+			err = -EEXIST;
+			goto rollback;
+		}
+		dst_opt = kmalloc(sizeof(*option), GFP_KERNEL);
+		if (!dst_opt) {
+			err = -ENOMEM;
+			goto rollback;
+		}
+		memcpy(dst_opt, option, sizeof(*option));
+		dst_opts[i] = dst_opt;
+	}
+
+	for (i = 0; i < option_count; i++)
+		list_add_tail(&dst_opts[i]->list, &team->option_list);
 
-	for (i = 0; i < option_count; i++, option++)
-		list_add_tail(&option->list, &team->option_list);
+	return 0;
+
+rollback:
+	for (i = 0; i < option_count; i++)
+		kfree(dst_opts[i]);
+
+	return err;
 }
+
 EXPORT_SYMBOL(team_options_register);
 
 static void __team_options_change_check(struct team *team,
 					struct team_option *changed_option);
 
 static void __team_options_unregister(struct team *team,
-				      struct team_option *option,
+				      const struct team_option *option,
 				      size_t option_count)
 {
 	int i;
 
-	for (i = 0; i < option_count; i++, option++)
-		list_del(&option->list);
+	for (i = 0; i < option_count; i++, option++) {
+		struct team_option *del_opt;
+
+		del_opt = __team_find_option(team, option->name);
+		if (del_opt) {
+			list_del(&del_opt->list);
+			kfree(del_opt);
+		}
+	}
 }
 
-void team_options_unregister(struct team *team, struct team_option *option,
+void team_options_unregister(struct team *team,
+			     const struct team_option *option,
 			     size_t option_count)
 {
 	__team_options_unregister(team, option, option_count);
@@ -632,7 +680,7 @@ static int team_mode_option_set(struct team *team, void *arg)
 	return team_change_mode(team, *str);
 }
 
-static struct team_option team_options[] = {
+static const struct team_option team_options[] = {
 	{
 		.name = "mode",
 		.type = TEAM_OPTION_TYPE_STRING,
@@ -645,6 +693,7 @@ static int team_init(struct net_device *dev)
 {
 	struct team *team = netdev_priv(dev);
 	int i;
+	int err;
 
 	team->dev = dev;
 	mutex_init(&team->lock);
@@ -660,10 +709,17 @@ static int team_init(struct net_device *dev)
 	team_adjust_ops(team);
 
 	INIT_LIST_HEAD(&team->option_list);
-	team_options_register(team, team_options, ARRAY_SIZE(team_options));
+	err = team_options_register(team, team_options, ARRAY_SIZE(team_options));
+	if (err)
+		goto err_options_register;
 	netif_carrier_off(dev);
 
 	return 0;
+
+err_options_register:
+	free_percpu(team->pcpu_stats);
+
+	return err;
 }
 
 static void team_uninit(struct net_device *dev)
diff --git a/drivers/net/team/team_mode_activebackup.c b/drivers/net/team/team_mode_activebackup.c
index 6fe920c..b344275 100644
--- a/drivers/net/team/team_mode_activebackup.c
+++ b/drivers/net/team/team_mode_activebackup.c
@@ -83,7 +83,7 @@ static int ab_active_port_set(struct team *team, void *arg)
 	return -ENOENT;
 }
 
-static struct team_option ab_options[] = {
+static const struct team_option ab_options[] = {
 	{
 		.name = "activeport",
 		.type = TEAM_OPTION_TYPE_U32,
@@ -94,8 +94,7 @@ static struct team_option ab_options[] = {
 
 int ab_init(struct team *team)
 {
-	team_options_register(team, ab_options, ARRAY_SIZE(ab_options));
-	return 0;
+	return team_options_register(team, ab_options, ARRAY_SIZE(ab_options));
 }
 
 void ab_exit(struct team *team)
diff --git a/include/linux/if_team.h b/include/linux/if_team.h
index a6eac12..828181f 100644
--- a/include/linux/if_team.h
+++ b/include/linux/if_team.h
@@ -140,11 +140,11 @@ static inline struct team_port *team_get_port_by_index_rcu(struct team *team,
 }
 
 extern int team_port_set_team_mac(struct team_port *port);
-extern void team_options_register(struct team *team,
-				  struct team_option *option,
-				  size_t option_count);
+extern int team_options_register(struct team *team,
+				 const struct team_option *option,
+				 size_t option_count);
 extern void team_options_unregister(struct team *team,
-				    struct team_option *option,
+				    const struct team_option *option,
 				    size_t option_count);
 extern int team_mode_register(struct team_mode *mode);
 extern int team_mode_unregister(struct team_mode *mode);
-- 
1.7.6
