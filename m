From: Keiichi KII <k-keiichi@bx.jp.nec.com>
Subject: [RFC][PATCH -mm take4 4/6] using symlink for the net_device
Date: Wed, 18 Apr 2007 21:11:14 +0900
Message-ID: <46260AE2.9080107@bx.jp.nec.com>
References: <462605DC.2080804@bx.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: mpm@selenic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO202.gate.nec.co.jp ([202.32.8.206]:44371 "EHLO
	tyo202.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422948AbXDRMLZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2007 08:11:25 -0400
In-Reply-To: <462605DC.2080804@bx.jp.nec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Keiichi KII <k-keiichi@bx.jp.nec.com>

We use symbolic link for net_device.
The link in sysfs represents the corresponding network etherdevice.

-+- /sys/class/misc/
 |-+- netconsole/
 |-+- port1/
 | |--- id             [r--r--r--]  id
 | |--- net:<net_dev>  [rw-r--r--]  net_dev: eth0,eth1,...
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
@@ -81,6 +81,9 @@ static int add_target(char* target_confi
 static void remove_target(struct netconsole_target *nt);
 static void cleanup_netconsole(void);
 static int setup_target_sysfs(struct netconsole_target *nt);
+static char *make_netdev_class_name(char *netdev_name);
+static int netconsole_event(struct notifier_block *this, unsigned long event,
+			    void *ptr);
 
 static int miscdev_configured;
 
@@ -274,12 +277,77 @@ static struct miscdevice netconsole_misc
 	.name = "netconsole",
 };
 
+static struct notifier_block netconsole_notifier = {
+	.notifier_call = netconsole_event,
+};
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
+	if (IS_ERR(name))
+		return PTR_ERR(name);
+	retval = sysfs_create_link(&nt->obj, &nt->np.dev->dev.kobj, name);
+	kfree(name);
+
+	return retval;
+}
+
+static char *make_netdev_class_name(char *netdev_name)
+{
+	int size;
+	char *name;
+	char *netdev_class_prefix = "net:";
+
+	size = strlen(netdev_class_prefix) + strlen(netdev_name) + 1;
+	name = kmalloc(size, GFP_KERNEL);
+	if (!name) {
+		printk(KERN_ERR "netconsole: kmalloc() failed!\n");
+		return ERR_PTR(-ENOMEM);
+	}
+	strcpy(name, netdev_class_prefix);
+	strcat(name, netdev_name);
+
+	return name;
+}
+
+static int netconsole_event(struct notifier_block *this, unsigned long event,
+			    void *ptr)
+{
+	int error = 0;
+	char *old_link_name = NULL, *new_link_name = NULL;
+	struct netconsole_target *nt;
+	struct net_device *dev = ptr;
+
+	if (event == NETDEV_CHANGENAME) {
+		spin_lock(&target_list_lock);
+		list_for_each_entry(nt, &target_list, list) {
+			if (nt->np.dev != dev)
+				continue;
+			new_link_name = make_netdev_class_name(dev->name);
+			old_link_name =
+				make_netdev_class_name(nt->np.dev_name);
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
+		spin_unlock(&target_list_lock);
+	}
+
+	return NOTIFY_DONE;
 }
 
 static int add_target(char* target_config)
@@ -409,6 +477,7 @@ static int __init init_netconsole(void)
 	} else
 		miscdev_configured = 1;
 
+	register_netdevice_notifier(&netconsole_notifier);
 	register_console(&netconsole);
 	if(!strlen(config)) {
 		printk(KERN_ERR "netconsole: not configured\n");
@@ -443,6 +512,7 @@ static void cleanup_netconsole(void)
 	list_for_each_entry_safe(nt, tmp, &target_list, list) {
 		kobject_unregister(&nt->obj);
 	}
+	unregister_netdevice_notifier(&netconsole_notifier);
 	if (miscdev_configured)
 		misc_deregister(&netconsole_miscdev);
 #else

-- 


