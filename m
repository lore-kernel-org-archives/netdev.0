From: Keiichi KII <k-keiichi@bx.jp.nec.com>
Subject: [RFC][PATCH -mm take5 4/7] using symlink for the net_device
Date: Wed, 13 Jun 2007 19:29:01 +0900
Message-ID: <466FC6ED.9060208@bx.jp.nec.com>
References: <466FC455.5060001@bx.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Matt Mackall <mpm@selenic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO202.gate.nec.co.jp ([202.32.8.206]:54366 "EHLO
	tyo202.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756898AbXFMK3V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 06:29:21 -0400
In-Reply-To: <466FC455.5060001@bx.jp.nec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Keiichi KII <k-keiichi@bx.jp.nec.com>

We use symbolic link for net_device.
The link in sysfs represents the corresponding network etherdevice.

-+- /sys/class/misc/
 |-+- netconsole/
 |-+- port1/
 | |--- id             [r--r--r--]  id
 | |--- net:<net_dev>  [r--r--r--]  net_dev: eth0,eth1,...
 | ...
 |--- port2/
 ...

Signed-off-by: Keiichi KII <k-keiichi@bx.jp.nec.com>
Signed-off-by: Takayoshi Kochi <t-kochi@bq.jp.nec.com>
---
Index: mm/drivers/net/netconsole.c
===================================================================
--- mm.orig/drivers/net/netconsole.c
+++ mm/drivers/net/netconsole.c
@@ -76,6 +76,7 @@ struct netconsole_target {
 
 static LIST_HEAD(target_list);
 static DEFINE_SPINLOCK(target_list_lock);
+static DECLARE_MUTEX(netdev_change_sem);
 
 static int miscdev_configured;
 
@@ -239,12 +240,14 @@ static void remove_target(struct netcons
 {
 	unsigned long flags;
 
+	down(&netdev_change_sem);
 	spin_lock_irqsave(&target_list_lock, flags);
 	list_del(&nt->list);
 	if (list_empty(&target_list))
 		netpoll_cleanup(&nt->np);
 	spin_unlock_irqrestore(&target_list_lock, flags);
 	kfree(nt);
+	up(&netdev_change_sem);
 }
 
 static void release_target(struct kobject *kobj)
@@ -271,12 +274,35 @@ static struct kobj_type target_ktype = {
 	.default_attrs = target_attrs,
 };
 
+static char *make_netdev_class_name(char *netdev_name)
+{
+	char *name;
+
+	name = kasprintf(GFP_KERNEL, "net:%s", netdev_name);
+	if (!name) {
+		printk(KERN_ERR "netconsole: kmalloc() failed!\n");
+		return NULL;
+	}
+
+	return name;
+}
+
 static int setup_target_sysfs(struct netconsole_target *nt)
 {
+	int retval = 0;
+	char *name;
+
 	kobject_set_name(&nt->obj, "port%d", nt->id);
 	nt->obj.parent = &netconsole_miscdev.this_device->kobj;
 	nt->obj.ktype = &target_ktype;
-	return kobject_register(&nt->obj);
+	retval = kobject_register(&nt->obj);
+	name = make_netdev_class_name(nt->np.dev_name);
+	if (!name)
+		return -ENOMEM;
+	retval = sysfs_create_link(&nt->obj, &nt->np.dev->dev.kobj, name);
+	kfree(name);
+
+	return retval;
 }
 
 static int add_target(char* target_config)
@@ -323,6 +349,60 @@ static int add_target(char* target_confi
  out:
 	return retval;
 }
+
+static int netconsole_event(struct notifier_block *this, unsigned long event,
+			    void *ptr)
+{
+	int error = 0;
+	unsigned long flags;
+	char *old_link_name = NULL, *new_link_name = NULL;
+	struct netconsole_target *nt, *tmp;
+	struct net_device *dev = ptr;
+	LIST_HEAD(modify_target_list);
+
+	if (event == NETDEV_CHANGENAME) {
+		spin_lock_irqsave(&target_list_lock, flags);
+		list_for_each_entry_safe(nt, tmp, &target_list, list)
+			if (nt->np.dev == dev)
+				list_move(&nt->list, &modify_target_list);
+		spin_unlock_irqrestore(&target_list_lock, flags);
+
+		down(&netdev_change_sem);
+		list_for_each_entry(nt, &modify_target_list, list) {
+			new_link_name = make_netdev_class_name(dev->name);
+			old_link_name = make_netdev_class_name(nt->np.dev_name);
+			if (!new_link_name || !old_link_name) {
+				printk(KERN_ERR "netconsole: "
+				       "make_netdev_class_name() failed!\n");
+				kfree(new_link_name);
+				kfree(old_link_name);
+				continue;
+			}
+			sysfs_remove_link(&nt->obj, old_link_name);
+			error = sysfs_create_link(&nt->obj,
+						  &nt->np.dev->dev.kobj,
+						  new_link_name);
+			if (error)
+				printk(KERN_ERR "can't create link: %s\n",
+				       new_link_name);
+			strcpy(nt->np.dev_name, dev->name);
+			kfree(new_link_name);
+			kfree(old_link_name);
+		}
+		up(&netdev_change_sem);
+
+		spin_lock_irqsave(&target_list_lock, flags);
+		list_for_each_entry_safe(nt, tmp, &modify_target_list, list)
+			list_move(&nt->list, &target_list);
+		spin_unlock_irqrestore(&target_list_lock, flags);
+	}
+
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block netconsole_notifier = {
+	.notifier_call = netconsole_event,
+};
 #endif /* CONFIG_NETCONSOLE_DYNCON */
 
 static void write_msg(struct console *con, const char *msg, unsigned int len)
@@ -387,6 +467,7 @@ static void cleanup_netconsole(void)
 	unregister_console(&netconsole);
 	list_for_each_entry_safe(nt, tmp, &target_list, list)
 		kobject_unregister(&nt->obj);
+	unregister_netdevice_notifier(&netconsole_notifier);
 	if (miscdev_configured)
 		misc_deregister(&netconsole_miscdev);
 #else
@@ -410,6 +491,7 @@ static int __init init_netconsole(void)
 	} else
 		miscdev_configured = 1;
 
+	register_netdevice_notifier(&netconsole_notifier);
 	register_console(&netconsole);
 	if (!strlen(config)) {
 		printk(KERN_ERR "netconsole: not configured\n");

-- 


