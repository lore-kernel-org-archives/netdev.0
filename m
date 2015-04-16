From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 10/16] netconsole: introduce netconsole_mutex
Date: Thu, 16 Apr 2015 19:03:47 -0400
Message-ID: <1429225433-11946-11-git-send-email-tj@kernel.org>
References: <1429225433-11946-1-git-send-email-tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Tejun Heo <tj@kernel.org>
To: akpm@linux-foundation.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f178.google.com ([209.85.216.178]:35851 "EHLO
	mail-qc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753865AbbDPXEf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 19:04:35 -0400
In-Reply-To: <1429225433-11946-1-git-send-email-tj@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

console_lock protects the target_list itself and setting and clearing
of its ->enabled flag; however, nothing protects the overall
enable/disable operations which we'll need to make netconsole
management more dynamic for the scheduled reliable transmission
support.  Also, an earlier patch introduced a small race window where
dynamic console disable may compete against asynchronous disable
kicked off from netdevice_notifier.

This patch adds netconsole_mutex which protects all target
create/destroy and enable/disable operations.  It also replaces
netconsole_target->mutex used by dynamic consoles.  The above
mentioned race is removed by this change.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: David Miller <davem@davemloft.net>
---
 drivers/net/netconsole.c | 48 ++++++++++++++++++++++++++++--------------------
 1 file changed, 28 insertions(+), 20 deletions(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index 57c02ab..f0ac9f6 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -75,10 +75,14 @@ __setup("netconsole=", option_setup);
 
 /*
  * Linked list of all configured targets.  The list and each target's
- * enable/disable state are protected by console_lock.
+ * enable/disable state are protected by both netconsole_mutex and
+ * console_lock.
  */
 static LIST_HEAD(target_list);
 
+/* protects target creation/destruction and enable/disable */
+static DEFINE_MUTEX(netconsole_mutex);
+
 /**
  * struct netconsole_target - Represents a configured netconsole target.
  * @list:	Links this target into the target_list.
@@ -106,7 +110,6 @@ struct netconsole_target {
 #endif
 	bool			enabled;
 	bool			disable_scheduled;
-	struct mutex		mutex;
 	struct netpoll		np;
 };
 
@@ -184,7 +187,6 @@ static struct netconsole_target *alloc_netconsole_target(void)
 	strlcpy(nt->np.dev_name, "eth0", IFNAMSIZ);
 	nt->np.local_port = 6665;
 	nt->np.remote_port = 6666;
-	mutex_init(&nt->mutex);
 	eth_broadcast_addr(nt->np.remote_mac);
 
 	return nt;
@@ -196,6 +198,8 @@ static struct netconsole_target *alloc_param_target(char *target_config)
 	int err = -ENOMEM;
 	struct netconsole_target *nt;
 
+	lockdep_assert_held(&netconsole_mutex);
+
 	nt = alloc_netconsole_target();
 	if (!nt)
 		goto fail;
@@ -573,10 +577,10 @@ static ssize_t netconsole_target_attr_store(struct config_item *item,
 	struct netconsole_target_attr *na =
 		container_of(attr, struct netconsole_target_attr, attr);
 
-	mutex_lock(&nt->mutex);
+	mutex_lock(&netconsole_mutex);
 	if (na->store)
 		ret = na->store(nt, buf, count);
-	mutex_unlock(&nt->mutex);
+	mutex_unlock(&netconsole_mutex);
 
 	return ret;
 }
@@ -610,9 +614,11 @@ static struct config_item *make_netconsole_target(struct config_group *group,
 	config_item_init_type_name(&nt->item, name, &netconsole_target_type);
 
 	/* Adding, but it is disabled */
+	mutex_lock(&netconsole_mutex);
 	console_lock();
 	list_add(&nt->list, &target_list);
 	console_unlock();
+	mutex_unlock(&netconsole_mutex);
 
 	return &nt->item;
 }
@@ -622,6 +628,7 @@ static void drop_netconsole_target(struct config_group *group,
 {
 	struct netconsole_target *nt = to_target(item);
 
+	mutex_lock(&netconsole_mutex);
 	console_lock();
 	list_del(&nt->list);
 	console_unlock();
@@ -634,6 +641,7 @@ static void drop_netconsole_target(struct config_group *group,
 		netpoll_cleanup(&nt->np);
 
 	config_item_put(&nt->item);
+	mutex_unlock(&netconsole_mutex);
 }
 
 static struct configfs_group_operations netconsole_subsys_group_ops = {
@@ -662,6 +670,7 @@ static void netconsole_deferred_disable_work_fn(struct work_struct *work)
 {
 	struct netconsole_target *nt, *to_disable;
 
+	mutex_lock(&netconsole_mutex);
 repeat:
 	to_disable = NULL;
 	console_lock();
@@ -685,6 +694,8 @@ repeat:
 		netconsole_target_put(to_disable);
 		goto repeat;
 	}
+
+	mutex_unlock(&netconsole_mutex);
 }
 
 static DECLARE_WORK(netconsole_deferred_disable_work,
@@ -791,6 +802,8 @@ static int __init init_netconsole(void)
 	char *target_config;
 	char *input = config;
 
+	mutex_lock(&netconsole_mutex);
+
 	if (strnlen(input, MAX_PARAM_LENGTH)) {
 		while ((target_config = strsep(&input, ";"))) {
 			nt = alloc_param_target(target_config);
@@ -818,24 +831,21 @@ static int __init init_netconsole(void)
 	register_console(&netconsole);
 	pr_info("network logging started\n");
 
+	mutex_unlock(&netconsole_mutex);
 	return err;
 
 undonotifier:
 	unregister_netdevice_notifier(&netconsole_netdev_notifier);
-	cancel_work_sync(&netconsole_deferred_disable_work);
 fail:
 	pr_err("cleaning up\n");
 
-	/*
-	 * Remove all targets and destroy them (only targets created
-	 * from the boot/module option exist here). Skipping the console
-	 * lock is safe here.
-	 */
+	/* targets are already inactive, skipping the console lock is safe */
 	list_for_each_entry_safe(nt, tmp, &target_list, list) {
 		list_del(&nt->list);
 		free_param_target(nt);
 	}
-
+	mutex_unlock(&netconsole_mutex);
+	cancel_work_sync(&netconsole_deferred_disable_work);
 	return err;
 }
 
@@ -843,22 +853,20 @@ static void __exit cleanup_netconsole(void)
 {
 	struct netconsole_target *nt, *tmp;
 
+	mutex_lock(&netconsole_mutex);
+
 	unregister_console(&netconsole);
 	dynamic_netconsole_exit();
 	unregister_netdevice_notifier(&netconsole_netdev_notifier);
-	cancel_work_sync(&netconsole_deferred_disable_work);
 
-	/*
-	 * Targets created via configfs pin references on our module
-	 * and would first be rmdir(2)'ed from userspace. We reach
-	 * here only when they are already destroyed, and only those
-	 * created from the boot/module option are left, so remove and
-	 * destroy them. Skipping the console lock is safe here.
-	 */
+	/* targets are already inactive, skipping the console lock is safe */
 	list_for_each_entry_safe(nt, tmp, &target_list, list) {
 		list_del(&nt->list);
 		free_param_target(nt);
 	}
+
+	mutex_unlock(&netconsole_mutex);
+	cancel_work_sync(&netconsole_deferred_disable_work);
 }
 
 /*
-- 
2.1.0
