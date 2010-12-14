From: Mike Waychison <mikew@google.com>
Subject: [PATCH v3 05/22] netconsole: Wrap the list and locking in a structure
Date: Tue, 14 Dec 2010 13:29:21 -0800
Message-ID: <20101214212920.17022.44697.stgit@mike.mtv.corp.google.com>
References: <20101214212846.17022.64836.stgit@mike.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: adurbin@google.com, linux-kernel@vger.kernel.org,
	chavey@google.com, Greg KH <greg@kroah.com>,
	netdev@vger.kernel.org,
	=?utf-8?q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>,
	akpm@linux-foundation.org, linux-api@vger.kernel.org
To: simon.kagstrom@netinsight.net, davem@davemloft.net,
	nhorman@tuxdriver.com, Matt Mackall <mpm@selenic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101214212846.17022.64836.stgit@mike.mtv.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for moving all the netpoll target handling code out of
netconsole proper and into netpoll, wrap the list and lock in a new
structure, netpoll_targets.

Signed-off-by: Mike Waychison <mikew@google.com>
Acked-by: Matt Mackall <mpm@selenic.com>
---
 drivers/net/netconsole.c |   85 ++++++++++++++++++++++++----------------------
 1 files changed, 44 insertions(+), 41 deletions(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index 68700c1..3aa7151 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -65,11 +65,14 @@ static int __init option_setup(char *opt)
 __setup("netconsole=", option_setup);
 #endif	/* MODULE */
 
-/* Linked list of all configured targets */
-static LIST_HEAD(target_list);
-
-/* This needs to be a spinlock because write_msg() cannot sleep */
-static DEFINE_SPINLOCK(target_list_lock);
+struct netpoll_targets {
+	struct list_head list;
+	spinlock_t lock;
+};
+#define DEFINE_NETPOLL_TARGETS(x) struct netpoll_targets x = \
+	{ .list = LIST_HEAD_INIT(x.list), \
+	  .lock = __SPIN_LOCK_UNLOCKED(x.lock) }
+static DEFINE_NETPOLL_TARGETS(targets);
 
 #define NETPOLL_DISABLED	0
 #define NETPOLL_SETTINGUP	1
@@ -78,7 +81,7 @@ static DEFINE_SPINLOCK(target_list_lock);
 
 /**
  * struct netconsole_target - Represents a configured netconsole target.
- * @list:	Links this target into the target_list.
+ * @list:	Links this target into the netpoll_targets.list.
  * @item:	Links us into the configfs subsystem hierarchy.
  * @np_state:	Enabled / Disabled / SettingUp / Cleaning
  *		Visible from userspace (read-write) as "enabled".
@@ -175,10 +178,10 @@ static void deferred_netpoll_cleanup(struct work_struct *work)
 	nt = container_of(work, struct netconsole_target, cleanup_work);
 	netpoll_cleanup(&nt->np);
 
-	spin_lock_irqsave(&target_list_lock, flags);
+	spin_lock_irqsave(&targets.lock, flags);
 	BUG_ON(nt->np_state != NETPOLL_CLEANING);
 	nt->np_state = NETPOLL_DISABLED;
-	spin_unlock_irqrestore(&target_list_lock, flags);
+	spin_unlock_irqrestore(&targets.lock, flags);
 
 	netconsole_target_put(nt);
 }
@@ -365,7 +368,7 @@ static ssize_t store_enabled(struct netconsole_target *nt,
 		return enabled;
 
 	if (enabled) {	/* 1 */
-		spin_lock_irqsave(&target_list_lock, flags);
+		spin_lock_irqsave(&targets.lock, flags);
 		if (nt->np_state != NETPOLL_DISABLED)
 			goto busy;
 		else {
@@ -377,7 +380,7 @@ static ssize_t store_enabled(struct netconsole_target *nt,
 			 * because there is a reference implicitly held by the
 			 * caller of the store operation.
 			 */
-			spin_unlock_irqrestore(&target_list_lock, flags);
+			spin_unlock_irqrestore(&targets.lock, flags);
 		}
 
 		/*
@@ -387,34 +390,34 @@ static ssize_t store_enabled(struct netconsole_target *nt,
 		netpoll_print_options(&nt->np);
 
 		err = netpoll_setup(&nt->np);
-		spin_lock_irqsave(&target_list_lock, flags);
+		spin_lock_irqsave(&targets.lock, flags);
 		if (err)
 			nt->np_state = NETPOLL_DISABLED;
 		else
 			nt->np_state = NETPOLL_ENABLED;
-		spin_unlock_irqrestore(&target_list_lock, flags);
+		spin_unlock_irqrestore(&targets.lock, flags);
 		if (err)
 			return err;
 
 		printk(KERN_INFO "netconsole: network logging started\n");
 	} else {	/* 0 */
-		spin_lock_irqsave(&target_list_lock, flags);
+		spin_lock_irqsave(&targets.lock, flags);
 		if (nt->np_state == NETPOLL_ENABLED)
 			nt->np_state = NETPOLL_CLEANING;
 		else if (nt->np_state != NETPOLL_DISABLED)
 			goto busy;
-		spin_unlock_irqrestore(&target_list_lock, flags);
+		spin_unlock_irqrestore(&targets.lock, flags);
 
 		netpoll_cleanup(&nt->np);
 
-		spin_lock_irqsave(&target_list_lock, flags);
+		spin_lock_irqsave(&targets.lock, flags);
 		nt->np_state = NETPOLL_DISABLED;
-		spin_unlock_irqrestore(&target_list_lock, flags);
+		spin_unlock_irqrestore(&targets.lock, flags);
 	}
 
 	return strnlen(buf, count);
 busy:
-	spin_unlock_irqrestore(&target_list_lock, flags);
+	spin_unlock_irqrestore(&targets.lock, flags);
 	return -EBUSY;
 }
 
@@ -531,16 +534,16 @@ static ssize_t store_locked_##_name(struct netconsole_target *nt,	\
 {									\
 	unsigned long flags;						\
 	ssize_t ret;							\
-	spin_lock_irqsave(&target_list_lock, flags);			\
+	spin_lock_irqsave(&targets.lock, flags);			\
 	if (nt->np_state != NETPOLL_DISABLED) {				\
 		printk(KERN_ERR "netconsole: target (%s) is enabled, "	\
 				"disable to update parameters\n",	\
 				config_item_name(&nt->item));		\
-		spin_unlock_irqrestore(&target_list_lock, flags);	\
+		spin_unlock_irqrestore(&targets.lock, flags);		\
 		return -EBUSY;						\
 	}								\
 	ret = store_##_name(nt, buf, count);				\
-	spin_unlock_irqrestore(&target_list_lock, flags);		\
+	spin_unlock_irqrestore(&targets.lock, flags);			\
 	return ret;							\
 }
 
@@ -549,9 +552,9 @@ static ssize_t show_locked_##_name(struct netconsole_target *nt, char *buf) \
 {									\
 	unsigned long flags;						\
 	ssize_t ret;							\
-	spin_lock_irqsave(&target_list_lock, flags);			\
+	spin_lock_irqsave(&targets.lock, flags);			\
 	ret = show_##_name(nt, buf);					\
-	spin_unlock_irqrestore(&target_list_lock, flags);		\
+	spin_unlock_irqrestore(&targets.lock, flags);			\
 	return ret;							\
 }
 
@@ -668,9 +671,9 @@ static struct config_item *make_netconsole_target(struct config_group *group,
 	config_item_init_type_name(&nt->item, name, &netconsole_target_type);
 
 	/* Adding, but it is disabled */
-	spin_lock_irqsave(&target_list_lock, flags);
-	list_add(&nt->list, &target_list);
-	spin_unlock_irqrestore(&target_list_lock, flags);
+	spin_lock_irqsave(&targets.lock, flags);
+	list_add(&nt->list, &targets.list);
+	spin_unlock_irqrestore(&targets.lock, flags);
 
 	return &nt->item;
 }
@@ -681,9 +684,9 @@ static void drop_netconsole_target(struct config_group *group,
 	unsigned long flags;
 	struct netconsole_target *nt = to_target(item);
 
-	spin_lock_irqsave(&target_list_lock, flags);
+	spin_lock_irqsave(&targets.lock, flags);
 	list_del(&nt->list);
-	spin_unlock_irqrestore(&target_list_lock, flags);
+	spin_unlock_irqrestore(&targets.lock, flags);
 
 	/*
 	 * The target may have never been disabled, or was disabled due
@@ -698,7 +701,7 @@ static void drop_netconsole_target(struct config_group *group,
 	if (nt->np_state == NETPOLL_ENABLED || nt->np_state == NETPOLL_CLEANING)
 		netpoll_cleanup(&nt->np);
 
-	config_item_put(&nt->item);
+	netconsole_target_put(nt);
 }
 
 static struct configfs_group_operations netconsole_subsys_group_ops = {
@@ -725,7 +728,7 @@ static struct configfs_subsystem netconsole_subsys = {
 
 /*
  * Call netpoll_cleanup on this target asynchronously.
- * target_list_lock is required.
+ * targets.lock is required.
  */
 static void defer_netpoll_cleanup(struct netconsole_target *nt)
 {
@@ -749,8 +752,8 @@ static int netconsole_netdev_event(struct notifier_block *this,
 	      event == NETDEV_BONDING_DESLAVE))
 		goto done;
 
-	spin_lock_irqsave(&target_list_lock, flags);
-	list_for_each_entry(nt, &target_list, list) {
+	spin_lock_irqsave(&targets.lock, flags);
+	list_for_each_entry(nt, &targets.list, list) {
 		if (nt->np_state == NETPOLL_ENABLED && nt->np.dev == dev) {
 			switch (event) {
 			case NETDEV_CHANGENAME:
@@ -766,7 +769,7 @@ static int netconsole_netdev_event(struct notifier_block *this,
 			}
 		}
 	}
-	spin_unlock_irqrestore(&target_list_lock, flags);
+	spin_unlock_irqrestore(&targets.lock, flags);
 	if (event == NETDEV_UNREGISTER || event == NETDEV_BONDING_DESLAVE)
 		printk(KERN_INFO "netconsole: network logging stopped, "
 			"interface %s %s\n",  dev->name,
@@ -788,11 +791,11 @@ static void write_msg(struct console *con, const char *msg, unsigned int len)
 	const char *tmp;
 
 	/* Avoid taking lock and disabling interrupts unnecessarily */
-	if (list_empty(&target_list))
+	if (list_empty(&targets.list))
 		return;
 
-	spin_lock_irqsave(&target_list_lock, flags);
-	list_for_each_entry(nt, &target_list, list) {
+	spin_lock_irqsave(&targets.lock, flags);
+	list_for_each_entry(nt, &targets.list, list) {
 		if (nt->np_state == NETPOLL_ENABLED
 		    && netif_running(nt->np.dev)) {
 			/*
@@ -810,7 +813,7 @@ static void write_msg(struct console *con, const char *msg, unsigned int len)
 			}
 		}
 	}
-	spin_unlock_irqrestore(&target_list_lock, flags);
+	spin_unlock_irqrestore(&targets.lock, flags);
 }
 
 static struct console netconsole = {
@@ -837,9 +840,9 @@ static int __init init_netconsole(void)
 			/* Dump existing printks when we register */
 			netconsole.flags |= CON_PRINTBUFFER;
 
-			spin_lock_irqsave(&target_list_lock, flags);
-			list_add(&nt->list, &target_list);
-			spin_unlock_irqrestore(&target_list_lock, flags);
+			spin_lock_irqsave(&targets.lock, flags);
+			list_add(&nt->list, &targets.list);
+			spin_unlock_irqrestore(&targets.lock, flags);
 		}
 	}
 
@@ -867,7 +870,7 @@ fail:
 	 * from the boot/module option exist here). Skipping the list
 	 * lock is safe here, and netpoll_cleanup() will sleep.
 	 */
-	list_for_each_entry_safe(nt, tmp, &target_list, list) {
+	list_for_each_entry_safe(nt, tmp, &targets.list, list) {
 		list_del(&nt->list);
 		free_param_target(nt);
 	}
@@ -891,7 +894,7 @@ static void __exit cleanup_netconsole(void)
 	 * destroy them. Skipping the list lock is safe here, and
 	 * netpoll_cleanup() will sleep.
 	 */
-	list_for_each_entry_safe(nt, tmp, &target_list, list) {
+	list_for_each_entry_safe(nt, tmp, &targets.list, list) {
 		list_del(&nt->list);
 		free_param_target(nt);
 	}
