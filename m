From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 08/16] netconsole: punt disabling to workqueue from netdevice_notifier
Date: Thu, 16 Apr 2015 19:03:45 -0400
Message-ID: <1429225433-11946-9-git-send-email-tj@kernel.org>
References: <1429225433-11946-1-git-send-email-tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Tejun Heo <tj@kernel.org>
To: akpm@linux-foundation.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f171.google.com ([209.85.220.171]:35132 "EHLO
	mail-qk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753805AbbDPXEb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 19:04:31 -0400
In-Reply-To: <1429225433-11946-1-git-send-email-tj@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The netdevice_notifier callback, netconsole_netdev_event(), needs to
perform netpoll_cleanup() for the affected targets; however, the
notifier is called with rtnl_lock held which the netpoll_cleanup()
path also grabs.  To avoid deadlock, the path uses __netpoll_cleanup()
instead and making the code path different from others.

The planned reliable netconsole support will add more logic to the
cleanup path making the slightly different paths painful.  Let's punt
netconsole_target disabling to workqueue so that it can later share
the same cleanup path.  This would also allow ditching
target_list_lock and depending on console_lock for synchronization.

Note that this introduces a narrow race window where the asynchronous
disabling may race against disabling from configfs ending up executing
netpoll_cleanup() more than once on the same instance.  The follow up
patches will fix it by introducing a mutex to protect overall enable /
disable operations; unfortunately, the locking update couldn't be
ordered before this change due to the locking order with rtnl_lock.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: David Miller <davem@davemloft.net>
---
 drivers/net/netconsole.c | 58 ++++++++++++++++++++++++++++++++++--------------
 1 file changed, 41 insertions(+), 17 deletions(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index 17692b8..d355776 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -105,6 +105,7 @@ struct netconsole_target {
 	struct config_item	item;
 #endif
 	bool			enabled;
+	bool			disable_scheduled;
 	struct mutex		mutex;
 	struct netpoll		np;
 };
@@ -660,6 +661,39 @@ static struct configfs_subsystem netconsole_subsys = {
 
 #endif	/* CONFIG_NETCONSOLE_DYNAMIC */
 
+static void netconsole_deferred_disable_work_fn(struct work_struct *work)
+{
+	struct netconsole_target *nt, *to_disable;
+	unsigned long flags;
+
+repeat:
+	to_disable = NULL;
+	spin_lock_irqsave(&target_list_lock, flags);
+	list_for_each_entry(nt, &target_list, list) {
+		if (!nt->disable_scheduled)
+			continue;
+		nt->disable_scheduled = false;
+
+		if (!nt->enabled)
+			continue;
+
+		netconsole_target_get(nt);
+		nt->enabled = false;
+		to_disable = nt;
+		break;
+	}
+	spin_unlock_irqrestore(&target_list_lock, flags);
+
+	if (to_disable) {
+		netpoll_cleanup(&to_disable->np);
+		netconsole_target_put(to_disable);
+		goto repeat;
+	}
+}
+
+static DECLARE_WORK(netconsole_deferred_disable_work,
+		    netconsole_deferred_disable_work_fn);
+
 /* Handle network interface device notifications */
 static int netconsole_netdev_event(struct notifier_block *this,
 				   unsigned long event, void *ptr)
@@ -674,9 +708,7 @@ static int netconsole_netdev_event(struct notifier_block *this,
 		goto done;
 
 	spin_lock_irqsave(&target_list_lock, flags);
-restart:
 	list_for_each_entry(nt, &target_list, list) {
-		netconsole_target_get(nt);
 		if (nt->np.dev == dev) {
 			switch (event) {
 			case NETDEV_CHANGENAME:
@@ -685,23 +717,14 @@ restart:
 			case NETDEV_RELEASE:
 			case NETDEV_JOIN:
 			case NETDEV_UNREGISTER:
-				/* rtnl_lock already held
-				 * we might sleep in __netpoll_cleanup()
-				 */
-				spin_unlock_irqrestore(&target_list_lock, flags);
-
-				__netpoll_cleanup(&nt->np);
-
-				spin_lock_irqsave(&target_list_lock, flags);
-				dev_put(nt->np.dev);
-				nt->np.dev = NULL;
-				nt->enabled = false;
+				/* rtnl_lock already held, punt to workqueue */
+				if (nt->enabled && !nt->disable_scheduled) {
+					nt->disable_scheduled = true;
+					schedule_work(&netconsole_deferred_disable_work);
+				}
 				stopped = true;
-				netconsole_target_put(nt);
-				goto restart;
 			}
 		}
-		netconsole_target_put(nt);
 	}
 	spin_unlock_irqrestore(&target_list_lock, flags);
 	if (stopped) {
@@ -810,7 +833,7 @@ static int __init init_netconsole(void)
 
 undonotifier:
 	unregister_netdevice_notifier(&netconsole_netdev_notifier);
-
+	cancel_work_sync(&netconsole_deferred_disable_work);
 fail:
 	pr_err("cleaning up\n");
 
@@ -834,6 +857,7 @@ static void __exit cleanup_netconsole(void)
 	unregister_console(&netconsole);
 	dynamic_netconsole_exit();
 	unregister_netdevice_notifier(&netconsole_netdev_notifier);
+	cancel_work_sync(&netconsole_deferred_disable_work);
 
 	/*
 	 * Targets created via configfs pin references on our module
-- 
2.1.0
