From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 09/16] netconsole: replace target_list_lock with console_lock
Date: Thu, 16 Apr 2015 19:03:46 -0400
Message-ID: <1429225433-11946-10-git-send-email-tj@kernel.org>
References: <1429225433-11946-1-git-send-email-tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Tejun Heo <tj@kernel.org>
To: akpm@linux-foundation.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429225433-11946-1-git-send-email-tj@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

netconsole has been using a spinlock - target_list_lock - to protect
the list of configured netconsole targets and their enable/disable
states.  With the disabling from netdevice_notifier moved off to a
workqueue by the previous patch and thus outside of rtnl_lock,
target_list_lock can be replaced with console_lock, which allows us to
avoid grabbing an extra lock in the log write path and can simplify
locking when involving other subsystems as console_lock is only
trylocked from printk path.

This patch replaces target_list_lock with console_lock.  The
conversion is one-to-one except for write_msg().  The function is
called with console_lock() already held so no further locking is
necessary; however, as netpoll_send_udp() expects irq to be disabled,
explicit irq save/restore pair is added around it.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: David Miller <davem@davemloft.net>
---
 drivers/net/netconsole.c | 50 ++++++++++++++++++------------------------------
 1 file changed, 19 insertions(+), 31 deletions(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index d355776..57c02ab 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -73,12 +73,12 @@ static int __init option_setup(char *opt)
 __setup("netconsole=", option_setup);
 #endif	/* MODULE */
 
-/* Linked list of all configured targets */
+/*
+ * Linked list of all configured targets.  The list and each target's
+ * enable/disable state are protected by console_lock.
+ */
 static LIST_HEAD(target_list);
 
-/* This needs to be a spinlock because write_msg() cannot sleep */
-static DEFINE_SPINLOCK(target_list_lock);
-
 /**
  * struct netconsole_target - Represents a configured netconsole target.
  * @list:	Links this target into the target_list.
@@ -325,7 +325,6 @@ static ssize_t store_enabled(struct netconsole_target *nt,
 			     const char *buf,
 			     size_t count)
 {
-	unsigned long flags;
 	int enabled;
 	int err;
 
@@ -357,9 +356,9 @@ static ssize_t store_enabled(struct netconsole_target *nt,
 		 * otherwise we might end up in write_msg() with
 		 * nt->np.dev == NULL and nt->enabled == true
 		 */
-		spin_lock_irqsave(&target_list_lock, flags);
+		console_lock();
 		nt->enabled = false;
-		spin_unlock_irqrestore(&target_list_lock, flags);
+		console_unlock();
 		netpoll_cleanup(&nt->np);
 	}
 
@@ -601,7 +600,6 @@ static struct config_item_type netconsole_target_type = {
 static struct config_item *make_netconsole_target(struct config_group *group,
 						  const char *name)
 {
-	unsigned long flags;
 	struct netconsole_target *nt;
 
 	nt = alloc_netconsole_target();
@@ -612,9 +610,9 @@ static struct config_item *make_netconsole_target(struct config_group *group,
 	config_item_init_type_name(&nt->item, name, &netconsole_target_type);
 
 	/* Adding, but it is disabled */
-	spin_lock_irqsave(&target_list_lock, flags);
+	console_lock();
 	list_add(&nt->list, &target_list);
-	spin_unlock_irqrestore(&target_list_lock, flags);
+	console_unlock();
 
 	return &nt->item;
 }
@@ -622,12 +620,11 @@ static struct config_item *make_netconsole_target(struct config_group *group,
 static void drop_netconsole_target(struct config_group *group,
 				   struct config_item *item)
 {
-	unsigned long flags;
 	struct netconsole_target *nt = to_target(item);
 
-	spin_lock_irqsave(&target_list_lock, flags);
+	console_lock();
 	list_del(&nt->list);
-	spin_unlock_irqrestore(&target_list_lock, flags);
+	console_unlock();
 
 	/*
 	 * The target may have never been enabled, or was manually disabled
@@ -664,11 +661,10 @@ static struct configfs_subsystem netconsole_subsys = {
 static void netconsole_deferred_disable_work_fn(struct work_struct *work)
 {
 	struct netconsole_target *nt, *to_disable;
-	unsigned long flags;
 
 repeat:
 	to_disable = NULL;
-	spin_lock_irqsave(&target_list_lock, flags);
+	console_lock();
 	list_for_each_entry(nt, &target_list, list) {
 		if (!nt->disable_scheduled)
 			continue;
@@ -682,7 +678,7 @@ repeat:
 		to_disable = nt;
 		break;
 	}
-	spin_unlock_irqrestore(&target_list_lock, flags);
+	console_unlock();
 
 	if (to_disable) {
 		netpoll_cleanup(&to_disable->np);
@@ -698,7 +694,6 @@ static DECLARE_WORK(netconsole_deferred_disable_work,
 static int netconsole_netdev_event(struct notifier_block *this,
 				   unsigned long event, void *ptr)
 {
-	unsigned long flags;
 	struct netconsole_target *nt;
 	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
 	bool stopped = false;
@@ -707,7 +702,7 @@ static int netconsole_netdev_event(struct notifier_block *this,
 	      event == NETDEV_RELEASE || event == NETDEV_JOIN))
 		goto done;
 
-	spin_lock_irqsave(&target_list_lock, flags);
+	console_lock();
 	list_for_each_entry(nt, &target_list, list) {
 		if (nt->np.dev == dev) {
 			switch (event) {
@@ -726,7 +721,7 @@ static int netconsole_netdev_event(struct notifier_block *this,
 			}
 		}
 	}
-	spin_unlock_irqrestore(&target_list_lock, flags);
+	console_unlock();
 	if (stopped) {
 		const char *msg = "had an event";
 		switch (event) {
@@ -755,7 +750,6 @@ static struct notifier_block netconsole_netdev_notifier = {
 static void write_msg(struct console *con, const char *msg, unsigned int len)
 {
 	int frag, left;
-	unsigned long flags;
 	struct netconsole_target *nt;
 	const char *tmp;
 
@@ -765,9 +759,7 @@ static void write_msg(struct console *con, const char *msg, unsigned int len)
 	if (list_empty(&target_list))
 		return;
 
-	spin_lock_irqsave(&target_list_lock, flags);
 	list_for_each_entry(nt, &target_list, list) {
-		netconsole_target_get(nt);
 		if (nt->enabled && netif_running(nt->np.dev)) {
 			/*
 			 * We nest this inside the for-each-target loop above
@@ -783,9 +775,7 @@ static void write_msg(struct console *con, const char *msg, unsigned int len)
 				left -= frag;
 			}
 		}
-		netconsole_target_put(nt);
 	}
-	spin_unlock_irqrestore(&target_list_lock, flags);
 }
 
 static struct console netconsole = {
@@ -798,7 +788,6 @@ static int __init init_netconsole(void)
 {
 	int err;
 	struct netconsole_target *nt, *tmp;
-	unsigned long flags;
 	char *target_config;
 	char *input = config;
 
@@ -812,9 +801,9 @@ static int __init init_netconsole(void)
 			/* Dump existing printks when we register */
 			netconsole.flags |= CON_PRINTBUFFER;
 
-			spin_lock_irqsave(&target_list_lock, flags);
+			console_lock();
 			list_add(&nt->list, &target_list);
-			spin_unlock_irqrestore(&target_list_lock, flags);
+			console_unlock();
 		}
 	}
 
@@ -839,8 +828,8 @@ fail:
 
 	/*
 	 * Remove all targets and destroy them (only targets created
-	 * from the boot/module option exist here). Skipping the list
-	 * lock is safe here, and netpoll_cleanup() will sleep.
+	 * from the boot/module option exist here). Skipping the console
+	 * lock is safe here.
 	 */
 	list_for_each_entry_safe(nt, tmp, &target_list, list) {
 		list_del(&nt->list);
@@ -864,8 +853,7 @@ static void __exit cleanup_netconsole(void)
 	 * and would first be rmdir(2)'ed from userspace. We reach
 	 * here only when they are already destroyed, and only those
 	 * created from the boot/module option are left, so remove and
-	 * destroy them. Skipping the list lock is safe here, and
-	 * netpoll_cleanup() will sleep.
+	 * destroy them. Skipping the console lock is safe here.
 	 */
 	list_for_each_entry_safe(nt, tmp, &target_list, list) {
 		list_del(&nt->list);
-- 
2.1.0
