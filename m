From: Mike Waychison <mikew-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v3 08/22] netconsole: Split out netpoll_targets init/exit
Date: Tue, 14 Dec 2010 13:29:37 -0800
Message-ID: <20101214212937.17022.22393.stgit@mike.mtv.corp.google.com>
References: <20101214212846.17022.64836.stgit@mike.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: adurbin-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	chavey-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	=?utf-8?q?Am=C3=A9rico?= Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: simon.kagstrom-vI6UBbBVNY+JA8cjQkG2/g@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, Matt Mackall <mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20101214212846.17022.64836.stgit-tzAwxxnF6Tt6FDdRrpk8kO4/NqBCd+6Q@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

As part of the factoring to move target handling out of netconsole,
abstract the construction and destruction of struct netpoll_targets
into their own functions.

Signed-off-by: Mike Waychison <mikew-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Acked-by: Matt Mackall <mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/netconsole.c |   69 ++++++++++++++++++++++++++++------------------
 1 files changed, 42 insertions(+), 27 deletions(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index fed427d..57451a7 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -663,13 +663,14 @@ static struct config_item_type netconsole_subsys_type = {
 	.ct_owner	= THIS_MODULE,
 };
 
-static int __init dynamic_netpoll_targets_init(struct netpoll_targets *nts)
+static int __init dynamic_netpoll_targets_init(const char *subsys_name,
+					       struct netpoll_targets *nts)
 {
 	struct configfs_subsystem *subsys = &nts->configfs_subsys;
 
 	config_group_init(&subsys->su_group);
 	mutex_init(&subsys->su_mutex);
-	strncpy((char *)&subsys->su_group.cg_item.ci_namebuf, "netconsole",
+	strncpy((char *)&subsys->su_group.cg_item.ci_namebuf, subsys_name,
 		CONFIGFS_ITEM_NAME_LEN);
 	subsys->su_group.cg_item.ci_type = &netconsole_subsys_type;
 	return configfs_register_subsystem(subsys);
@@ -817,13 +818,15 @@ static struct console netconsole = {
 	.write	= write_msg,
 };
 
-static int __init init_netconsole(void)
+static int __init register_netpoll_targets(const char *subsys_name,
+					   struct netpoll_targets *nts,
+					   char *static_targets)
 {
 	int err;
 	struct netconsole_target *nt, *tmp;
-	unsigned long flags;
 	char *target_config;
-	char *input = config;
+	char *input = static_targets;
+	unsigned long flags;
 
 	if (strnlen(input, MAX_PARAM_LENGTH)) {
 		while ((target_config = strsep(&input, ";"))) {
@@ -832,41 +835,33 @@ static int __init init_netconsole(void)
 				err = PTR_ERR(nt);
 				goto fail;
 			}
-			/* Dump existing printks when we register */
-			netconsole.flags |= CON_PRINTBUFFER;
 
-			spin_lock_irqsave(&targets.lock, flags);
-			list_add(&nt->list, &targets.list);
-			spin_unlock_irqrestore(&targets.lock, flags);
+			spin_lock_irqsave(&nts->lock, flags);
+			list_add(&nt->list, &nts->list);
+			spin_unlock_irqrestore(&nts->lock, flags);
 		}
 	}
 
-	targets.netdev_notifier.notifier_call = netconsole_netdev_event;
-	err = register_netdevice_notifier(&targets.netdev_notifier);
+	nts->netdev_notifier.notifier_call = netconsole_netdev_event;
+	err = register_netdevice_notifier(&nts->netdev_notifier);
 	if (err)
 		goto fail;
 
-	err = dynamic_netpoll_targets_init(&targets);
+	err = dynamic_netpoll_targets_init(subsys_name, nts);
 	if (err)
 		goto undonotifier;
 
-	register_console(&netconsole);
-	printk(KERN_INFO "netconsole: network logging started\n");
-
-	return err;
+	return 0;
 
 undonotifier:
-	unregister_netdevice_notifier(&targets.netdev_notifier);
-
+	unregister_netdevice_notifier(&nts->netdev_notifier);
 fail:
-	printk(KERN_ERR "netconsole: cleaning up\n");
-
 	/*
 	 * Remove all targets and destroy them (only targets created
 	 * from the boot/module option exist here). Skipping the list
 	 * lock is safe here, and netpoll_cleanup() will sleep.
 	 */
-	list_for_each_entry_safe(nt, tmp, &targets.list, list) {
+	list_for_each_entry_safe(nt, tmp, &nts->list, list) {
 		list_del(&nt->list);
 		free_param_target(nt);
 	}
@@ -874,13 +869,12 @@ fail:
 	return err;
 }
 
-static void __exit cleanup_netconsole(void)
+static void __exit unregister_netpoll_targets(struct netpoll_targets *nts)
 {
 	struct netconsole_target *nt, *tmp;
 
-	unregister_console(&netconsole);
-	dynamic_netpoll_targets_exit(&targets);
-	unregister_netdevice_notifier(&targets.netdev_notifier);
+	dynamic_netpoll_targets_exit(nts);
+	unregister_netdevice_notifier(&nts->netdev_notifier);
 
 	/*
 	 * Targets created via configfs pin references on our module
@@ -890,11 +884,32 @@ static void __exit cleanup_netconsole(void)
 	 * destroy them. Skipping the list lock is safe here, and
 	 * netpoll_cleanup() will sleep.
 	 */
-	list_for_each_entry_safe(nt, tmp, &targets.list, list) {
+	list_for_each_entry_safe(nt, tmp, &nts->list, list) {
 		list_del(&nt->list);
 		free_param_target(nt);
 	}
 }
 
+static int __init init_netconsole(void)
+{
+	int err;
+	err = register_netpoll_targets("netconsole", &targets, config);
+	if (err)
+		return err;
+	/* Dump existing printks if we registered any targets */
+	if (!list_empty(&targets.list))
+		netconsole.flags |= CON_PRINTBUFFER;
+	register_console(&netconsole);
+	printk(KERN_INFO "netconsole: network logging started\n");
+
+	return 0;
+}
+
+static void __exit cleanup_netconsole(void)
+{
+	unregister_console(&netconsole);
+	unregister_netpoll_targets(&targets);
+}
+
 module_init(init_netconsole);
 module_exit(cleanup_netconsole);
