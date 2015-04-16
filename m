From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 11/16] netconsole: consolidate enable/disable and create/destroy paths
Date: Thu, 16 Apr 2015 19:03:48 -0400
Message-ID: <1429225433-11946-12-git-send-email-tj@kernel.org>
References: <1429225433-11946-1-git-send-email-tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Tejun Heo <tj@kernel.org>
To: akpm@linux-foundation.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f180.google.com ([209.85.220.180]:33107 "EHLO
	mail-qk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753887AbbDPXEh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 19:04:37 -0400
In-Reply-To: <1429225433-11946-1-git-send-email-tj@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netconsole management paths are scattered around in different places.
This patch reorganizes them so that

* All enable logic is in netconsole_enable() and disable in
  netconsole_disable().  Both should be called with netconsole_mutex
  held and netconsole_disable() may be invoked without intervening
  enable.

* alloc_param_target() now also handles linking the new target to
  target_list.  It's renamed to create_param_target() and now returns
  errno.

* store_enabled() now uses netconsole_enable/disable() instead of
  open-coding the logic.  This also fixes the missing synchronization
  against write path when manipulating ->enabled flag.

* drop_netconsole_target() and netconsole_deferred_disable_work_fn()
  updated to use netconsole_disable().

* init/cleanup_netconsole()'s destruction paths are consolidated into
  netconsole_destroy_all() which uses netconsole_disable().
  free_param_target() is no longer used and removed.

While the conversions aren't one-to-one equivalent, this patch
shouldn't cause any visible behavior differences and makes extension
of the enable/disable logic a lot easier.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: David Miller <davem@davemloft.net>
---
 drivers/net/netconsole.c | 147 +++++++++++++++++++++++++----------------------
 1 file changed, 79 insertions(+), 68 deletions(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index f0ac9f6..d72d902 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -83,6 +83,8 @@ static LIST_HEAD(target_list);
 /* protects target creation/destruction and enable/disable */
 static DEFINE_MUTEX(netconsole_mutex);
 
+static struct console netconsole;
+
 /**
  * struct netconsole_target - Represents a configured netconsole target.
  * @list:	Links this target into the target_list.
@@ -192,8 +194,43 @@ static struct netconsole_target *alloc_netconsole_target(void)
 	return nt;
 }
 
+static int netconsole_enable(struct netconsole_target *nt)
+{
+	int err;
+
+	lockdep_assert_held(&netconsole_mutex);
+	WARN_ON_ONCE(nt->enabled);
+
+	err = netpoll_setup(&nt->np);
+	if (err)
+		return err;
+
+	console_lock();
+	nt->enabled = true;
+	console_unlock();
+	return 0;
+}
+
+static void netconsole_disable(struct netconsole_target *nt)
+{
+	lockdep_assert_held(&netconsole_mutex);
+
+	/*
+	 * We need to disable the netconsole before cleaning it up
+	 * otherwise we might end up in write_msg() with !nt->np.dev &&
+	 * nt->enabled.
+	 */
+	if (nt->enabled) {
+		console_lock();
+		nt->enabled = false;
+		console_unlock();
+
+		netpoll_cleanup(&nt->np);
+	}
+}
+
 /* Allocate new target (from boot/module param) and setup netpoll for it */
-static struct netconsole_target *alloc_param_target(char *target_config)
+static int create_param_target(char *target_config)
 {
 	int err = -ENOMEM;
 	struct netconsole_target *nt;
@@ -209,24 +246,26 @@ static struct netconsole_target *alloc_param_target(char *target_config)
 	if (err)
 		goto fail;
 
-	err = netpoll_setup(&nt->np);
+	console_lock();
+	list_add(&nt->list, &target_list);
+	console_unlock();
+
+	err = netconsole_enable(nt);
 	if (err)
-		goto fail;
+		goto fail_del;
 
-	nt->enabled = true;
+	/* Dump existing printks when we register */
+	netconsole.flags |= CON_PRINTBUFFER;
 
-	return nt;
+	return 0;
 
+fail_del:
+	console_lock();
+	list_del(&nt->list);
+	console_unlock();
 fail:
 	kfree(nt);
-	return ERR_PTR(err);
-}
-
-/* Cleanup netpoll for given target (from boot/module param) and free it */
-static void free_param_target(struct netconsole_target *nt)
-{
-	netpoll_cleanup(&nt->np);
-	kfree(nt);
+	return err;
 }
 
 #ifdef	CONFIG_NETCONSOLE_DYNAMIC
@@ -350,24 +389,15 @@ static ssize_t store_enabled(struct netconsole_target *nt,
 		 */
 		netpoll_print_options(&nt->np);
 
-		err = netpoll_setup(&nt->np);
+		err = netconsole_enable(nt);
 		if (err)
 			return err;
 
 		pr_info("netconsole: network logging started\n");
 	} else {	/* false */
-		/* We need to disable the netconsole before cleaning it up
-		 * otherwise we might end up in write_msg() with
-		 * nt->np.dev == NULL and nt->enabled == true
-		 */
-		console_lock();
-		nt->enabled = false;
-		console_unlock();
-		netpoll_cleanup(&nt->np);
+		netconsole_disable(nt);
 	}
 
-	nt->enabled = enabled;
-
 	return strnlen(buf, count);
 }
 
@@ -633,13 +663,7 @@ static void drop_netconsole_target(struct config_group *group,
 	list_del(&nt->list);
 	console_unlock();
 
-	/*
-	 * The target may have never been enabled, or was manually disabled
-	 * before being removed so netpoll may have already been cleaned up.
-	 */
-	if (nt->enabled)
-		netpoll_cleanup(&nt->np);
-
+	netconsole_disable(nt);
 	config_item_put(&nt->item);
 	mutex_unlock(&netconsole_mutex);
 }
@@ -675,22 +699,16 @@ repeat:
 	to_disable = NULL;
 	console_lock();
 	list_for_each_entry(nt, &target_list, list) {
-		if (!nt->disable_scheduled)
-			continue;
-		nt->disable_scheduled = false;
-
-		if (!nt->enabled)
-			continue;
-
-		netconsole_target_get(nt);
-		nt->enabled = false;
-		to_disable = nt;
-		break;
+		if (nt->disable_scheduled) {
+			nt->disable_scheduled = false;
+			netconsole_target_get(nt);
+			to_disable = nt;
+		}
 	}
 	console_unlock();
 
 	if (to_disable) {
-		netpoll_cleanup(&to_disable->np);
+		netconsole_disable(to_disable);
 		netconsole_target_put(to_disable);
 		goto repeat;
 	}
@@ -795,10 +813,23 @@ static struct console netconsole = {
 	.write	= write_msg,
 };
 
+static void __init_or_module netconsole_destroy_all(void)
+{
+	struct netconsole_target *nt, *tmp;
+
+	lockdep_assert_held(&netconsole_mutex);
+
+	/* targets are already inactive, skipping the console lock is safe */
+	list_for_each_entry_safe(nt, tmp, &target_list, list) {
+		list_del(&nt->list);
+		netconsole_disable(nt);
+		kfree(nt);
+	}
+}
+
 static int __init init_netconsole(void)
 {
 	int err;
-	struct netconsole_target *nt, *tmp;
 	char *target_config;
 	char *input = config;
 
@@ -806,17 +837,9 @@ static int __init init_netconsole(void)
 
 	if (strnlen(input, MAX_PARAM_LENGTH)) {
 		while ((target_config = strsep(&input, ";"))) {
-			nt = alloc_param_target(target_config);
-			if (IS_ERR(nt)) {
-				err = PTR_ERR(nt);
+			err = create_param_target(target_config);
+			if (err)
 				goto fail;
-			}
-			/* Dump existing printks when we register */
-			netconsole.flags |= CON_PRINTBUFFER;
-
-			console_lock();
-			list_add(&nt->list, &target_list);
-			console_unlock();
 		}
 	}
 
@@ -838,12 +861,7 @@ undonotifier:
 	unregister_netdevice_notifier(&netconsole_netdev_notifier);
 fail:
 	pr_err("cleaning up\n");
-
-	/* targets are already inactive, skipping the console lock is safe */
-	list_for_each_entry_safe(nt, tmp, &target_list, list) {
-		list_del(&nt->list);
-		free_param_target(nt);
-	}
+	netconsole_destroy_all();
 	mutex_unlock(&netconsole_mutex);
 	cancel_work_sync(&netconsole_deferred_disable_work);
 	return err;
@@ -851,19 +869,12 @@ fail:
 
 static void __exit cleanup_netconsole(void)
 {
-	struct netconsole_target *nt, *tmp;
-
 	mutex_lock(&netconsole_mutex);
 
 	unregister_console(&netconsole);
 	dynamic_netconsole_exit();
 	unregister_netdevice_notifier(&netconsole_netdev_notifier);
-
-	/* targets are already inactive, skipping the console lock is safe */
-	list_for_each_entry_safe(nt, tmp, &target_list, list) {
-		list_del(&nt->list);
-		free_param_target(nt);
-	}
+	netconsole_destroy_all();
 
 	mutex_unlock(&netconsole_mutex);
 	cancel_work_sync(&netconsole_deferred_disable_work);
-- 
2.1.0
