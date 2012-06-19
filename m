From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 01/19] team: make team_mode struct const
Date: Tue, 19 Jun 2012 17:54:03 +0200
Message-ID: <1340121261-2966-2-git-send-email-jpirko@redhat.com>
References: <1340121261-2966-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, jbrouer@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47400 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754448Ab2FSPy0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2012 11:54:26 -0400
In-Reply-To: <1340121261-2966-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/team/team.c                   |   55 ++++++++++++++++++++---------
 drivers/net/team/team_mode_activebackup.c |    2 +-
 drivers/net/team/team_mode_loadbalance.c  |    2 +-
 drivers/net/team/team_mode_roundrobin.c   |    2 +-
 include/linux/if_team.h                   |    5 ++-
 5 files changed, 43 insertions(+), 23 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index c61ae35..bdf87a9 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -371,13 +371,18 @@ static int team_option_set(struct team *team,
 static LIST_HEAD(mode_list);
 static DEFINE_SPINLOCK(mode_list_lock);
 
-static struct team_mode *__find_mode(const char *kind)
+struct team_mode_item {
+	struct list_head list;
+	const struct team_mode *mode;
+};
+
+static struct team_mode_item *__find_mode(const char *kind)
 {
-	struct team_mode *mode;
+	struct team_mode_item *mitem;
 
-	list_for_each_entry(mode, &mode_list, list) {
-		if (strcmp(mode->kind, kind) == 0)
-			return mode;
+	list_for_each_entry(mitem, &mode_list, list) {
+		if (strcmp(mitem->mode->kind, kind) == 0)
+			return mitem;
 	}
 	return NULL;
 }
@@ -392,49 +397,65 @@ static bool is_good_mode_name(const char *name)
 	return true;
 }
 
-int team_mode_register(struct team_mode *mode)
+int team_mode_register(const struct team_mode *mode)
 {
 	int err = 0;
+	struct team_mode_item *mitem;
 
 	if (!is_good_mode_name(mode->kind) ||
 	    mode->priv_size > TEAM_MODE_PRIV_SIZE)
 		return -EINVAL;
+
+	mitem = kmalloc(sizeof(*mitem), GFP_KERNEL);
+	if (!mitem)
+		return -ENOMEM;
+
 	spin_lock(&mode_list_lock);
 	if (__find_mode(mode->kind)) {
 		err = -EEXIST;
+		kfree(mitem);
 		goto unlock;
 	}
-	list_add_tail(&mode->list, &mode_list);
+	mitem->mode = mode;
+	list_add_tail(&mitem->list, &mode_list);
 unlock:
 	spin_unlock(&mode_list_lock);
 	return err;
 }
 EXPORT_SYMBOL(team_mode_register);
 
-int team_mode_unregister(struct team_mode *mode)
+void team_mode_unregister(const struct team_mode *mode)
 {
+	struct team_mode_item *mitem;
+
 	spin_lock(&mode_list_lock);
-	list_del_init(&mode->list);
+	mitem = __find_mode(mode->kind);
+	if (mitem) {
+		list_del_init(&mitem->list);
+		kfree(mitem);
+	}
 	spin_unlock(&mode_list_lock);
-	return 0;
 }
 EXPORT_SYMBOL(team_mode_unregister);
 
-static struct team_mode *team_mode_get(const char *kind)
+static const struct team_mode *team_mode_get(const char *kind)
 {
-	struct team_mode *mode;
+	struct team_mode_item *mitem;
+	const struct team_mode *mode = NULL;
 
 	spin_lock(&mode_list_lock);
-	mode = __find_mode(kind);
-	if (!mode) {
+	mitem = __find_mode(kind);
+	if (!mitem) {
 		spin_unlock(&mode_list_lock);
 		request_module("team-mode-%s", kind);
 		spin_lock(&mode_list_lock);
-		mode = __find_mode(kind);
+		mitem = __find_mode(kind);
 	}
-	if (mode)
+	if (mitem) {
+		mode = mitem->mode;
 		if (!try_module_get(mode->owner))
 			mode = NULL;
+	}
 
 	spin_unlock(&mode_list_lock);
 	return mode;
@@ -523,7 +544,7 @@ static int __team_change_mode(struct team *team,
 
 static int team_change_mode(struct team *team, const char *kind)
 {
-	struct team_mode *new_mode;
+	const struct team_mode *new_mode;
 	struct net_device *dev = team->dev;
 	int err;
 
diff --git a/drivers/net/team/team_mode_activebackup.c b/drivers/net/team/team_mode_activebackup.c
index fd6bd03..acd925f 100644
--- a/drivers/net/team/team_mode_activebackup.c
+++ b/drivers/net/team/team_mode_activebackup.c
@@ -108,7 +108,7 @@ static const struct team_mode_ops ab_mode_ops = {
 	.port_leave		= ab_port_leave,
 };
 
-static struct team_mode ab_mode = {
+static const struct team_mode ab_mode = {
 	.kind		= "activebackup",
 	.owner		= THIS_MODULE,
 	.priv_size	= sizeof(struct ab_priv),
diff --git a/drivers/net/team/team_mode_loadbalance.c b/drivers/net/team/team_mode_loadbalance.c
index 86e8183..6452428 100644
--- a/drivers/net/team/team_mode_loadbalance.c
+++ b/drivers/net/team/team_mode_loadbalance.c
@@ -148,7 +148,7 @@ static const struct team_mode_ops lb_mode_ops = {
 	.transmit		= lb_transmit,
 };
 
-static struct team_mode lb_mode = {
+static const struct team_mode lb_mode = {
 	.kind		= "loadbalance",
 	.owner		= THIS_MODULE,
 	.priv_size	= sizeof(struct lb_priv),
diff --git a/drivers/net/team/team_mode_roundrobin.c b/drivers/net/team/team_mode_roundrobin.c
index 6abfbdc..daafca2 100644
--- a/drivers/net/team/team_mode_roundrobin.c
+++ b/drivers/net/team/team_mode_roundrobin.c
@@ -81,7 +81,7 @@ static const struct team_mode_ops rr_mode_ops = {
 	.port_change_mac	= rr_port_change_mac,
 };
 
-static struct team_mode rr_mode = {
+static const struct team_mode rr_mode = {
 	.kind		= "roundrobin",
 	.owner		= THIS_MODULE,
 	.priv_size	= sizeof(struct rr_priv),
diff --git a/include/linux/if_team.h b/include/linux/if_team.h
index 8185f57..d45fcd5 100644
--- a/include/linux/if_team.h
+++ b/include/linux/if_team.h
@@ -105,7 +105,6 @@ struct team_option {
 };
 
 struct team_mode {
-	struct list_head list;
 	const char *kind;
 	struct module *owner;
 	size_t priv_size;
@@ -178,8 +177,8 @@ extern int team_options_register(struct team *team,
 extern void team_options_unregister(struct team *team,
 				    const struct team_option *option,
 				    size_t option_count);
-extern int team_mode_register(struct team_mode *mode);
-extern int team_mode_unregister(struct team_mode *mode);
+extern int team_mode_register(const struct team_mode *mode);
+extern void team_mode_unregister(const struct team_mode *mode);
 
 #endif /* __KERNEL__ */
 
-- 
1.7.10.2
