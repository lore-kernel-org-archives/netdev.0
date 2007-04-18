From: Keiichi KII <k-keiichi@bx.jp.nec.com>
Subject: [RFC][PATCH -mm take4 3/6] add interface for netconsole using sysfs
Date: Wed, 18 Apr 2007 21:08:45 +0900
Message-ID: <46260A4D.1050005@bx.jp.nec.com>
References: <462605DC.2080804@bx.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: mpm@selenic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO202.gate.nec.co.jp ([202.32.8.206]:43290 "EHLO
	tyo202.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422940AbXDRMJA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2007 08:09:00 -0400
In-Reply-To: <462605DC.2080804@bx.jp.nec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Keiichi KII <k-keiichi@bx.jp.nec.com>

This patch contains the following changes.

create a sysfs entry for netconsole in /sys/class/misc.
This entry has elements related to netconsole as follows.
You can change configuration of netconsole(writable attributes such as IP
address, port number and so on) and check current configuration of netconsole.

-+- /sys/class/misc/
 |-+- netconsole/
   |-+- port1/
   | |--- id          [r--r--r--]  unique port id
   | |--- local_ip    [rw-r--r--]  source IP to use, writable
   | |--- local_mac   [r--r--r--]  source MAC address
   | |--- local_port  [rw-r--r--]  source port number for UDP packets, writable
   | |--- remote_ip   [rw-r--r--]  port number for logging agent, writable
   | |--- remote_mac  [rw-r--r--]  MAC address for logging agent, writable
   | ---- remote_port [rw-r--r--]  IP address for logging agent, writable
   |--- port2/
   |--- port3/
   ...

Signed-off-by: Keiichi KII <k-keiichi@bx.jp.nec.com>
Signed-off-by: Takayoshi Kochi <t-kochi@bq.jp.nec.com>
---
Index: mm/drivers/net/netconsole.c
===================================================================
--- mm.orig/drivers/net/netconsole.c
+++ mm/drivers/net/netconsole.c
@@ -45,6 +45,8 @@
 #include <linux/sysrq.h>
 #include <linux/smp.h>
 #include <linux/netpoll.h>
+#include <linux/miscdevice.h>
+#include <linux/inet.h>
 
 MODULE_AUTHOR("Maintainer: Matt Mackall <mpm@selenic.com>");
 MODULE_DESCRIPTION("Console driver for network interfaces");
@@ -67,6 +69,7 @@ static struct netpoll np = {
 #ifdef CONFIG_NETCONSOLE_DYNCON
 struct netconsole_target {
 	struct list_head list;
+	struct kobject obj;
 	int id;
 	struct netpoll np;
 };
@@ -77,6 +80,207 @@ static DEFINE_SPINLOCK(target_list_lock)
 static int add_target(char* target_config);
 static void remove_target(struct netconsole_target *nt);
 static void cleanup_netconsole(void);
+static int setup_target_sysfs(struct netconsole_target *nt);
+
+static int miscdev_configured;
+
+static ssize_t show_id(struct netconsole_target *nt, char *buf)
+{
+	return sprintf(buf, "%d\n", nt->id);
+}
+
+static ssize_t show_local_port(struct netconsole_target *nt, char *buf)
+{
+	return sprintf(buf, "%d\n", nt->np.local_port);
+}
+
+static ssize_t show_remote_port(struct netconsole_target *nt, char *buf)
+{
+	return sprintf(buf, "%d\n", nt->np.remote_port);
+}
+
+static ssize_t show_local_ip(struct netconsole_target *nt, char *buf)
+{
+	return sprintf(buf, "%d.%d.%d.%d\n", HIPQUAD(nt->np.local_ip));
+}
+
+static ssize_t show_remote_ip(struct netconsole_target *nt, char *buf)
+{
+	return sprintf(buf, "%d.%d.%d.%d\n", HIPQUAD(nt->np.remote_ip));
+}
+
+static ssize_t show_local_mac(struct netconsole_target *nt, char *buf)
+{
+	return sprintf(buf, "%02x:%02x:%02x:%02x:%02x:%02x\n",
+		       nt->np.local_mac[0], nt->np.local_mac[1],
+		       nt->np.local_mac[2], nt->np.local_mac[3],
+		       nt->np.local_mac[4], nt->np.local_mac[5]);
+}
+
+static ssize_t show_remote_mac(struct netconsole_target *nt, char *buf)
+{
+	return sprintf(buf, "%02x:%02x:%02x:%02x:%02x:%02x\n",
+		       nt->np.remote_mac[0], nt->np.remote_mac[1],
+		       nt->np.remote_mac[2], nt->np.remote_mac[3],
+		       nt->np.remote_mac[4], nt->np.remote_mac[5]);
+}
+
+static ssize_t store_local_port(struct netconsole_target *nt, const char *buf,
+				size_t count)
+{
+	spin_lock(&target_list_lock);
+	nt->np.local_port = simple_strtol(buf, NULL, 10);
+	spin_unlock(&target_list_lock);
+
+	return count;
+}
+
+static ssize_t store_remote_port(struct netconsole_target *nt, const char *buf,
+				size_t count)
+{
+	spin_lock(&target_list_lock);
+	nt->np.remote_port = simple_strtol(buf, NULL, 10);
+	spin_unlock(&target_list_lock);
+
+	return count;
+}
+
+static ssize_t store_local_ip(struct netconsole_target *nt, const char *buf,
+			      size_t count)
+{
+	spin_lock(&target_list_lock);
+	nt->np.local_ip = ntohl(in_aton(buf));
+	spin_unlock(&target_list_lock);
+
+	return count;
+}
+
+static ssize_t store_remote_ip(struct netconsole_target *nt, const char *buf,
+			       size_t count)
+{
+	spin_lock(&target_list_lock);
+	nt->np.remote_ip = ntohl(in_aton(buf));
+	spin_unlock(&target_list_lock);
+
+	return count;
+}
+
+static ssize_t store_remote_mac(struct netconsole_target *nt, const char *buf,
+			       size_t count)
+{
+	unsigned char input_mac[ETH_ALEN] =
+		{0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
+	const char *cur = buf;
+	int i = 0;
+
+	input_mac[i++] = simple_strtol(cur, NULL, 16);
+	while ((cur = strchr(cur, ':')) != NULL) {
+		cur++;
+		input_mac[i++] = simple_strtol(cur, NULL, 16);
+	}
+	if (i != ETH_ALEN)
+		return -EINVAL;
+	spin_lock(&target_list_lock);
+	memcpy(nt->np.remote_mac, input_mac, ETH_ALEN);
+	spin_unlock(&target_list_lock);
+
+	return count;
+}
+
+struct target_attr {
+	struct attribute attr;
+	ssize_t (*show)(struct netconsole_target*, char*);
+	ssize_t (*store)(struct netconsole_target*, const char*,
+			 size_t count);
+};
+
+#define NETCON_CLASS_ATTR(_name, _mode, _show, _store) \
+struct target_attr target_attr_##_name = \
+                           __ATTR(_name, _mode, _show, _store)
+
+static NETCON_CLASS_ATTR(id, S_IRUGO, show_id, NULL);
+static NETCON_CLASS_ATTR(local_port, S_IRUGO | S_IWUSR,
+			 show_local_port, store_local_port);
+static NETCON_CLASS_ATTR(remote_port, S_IRUGO | S_IWUSR,
+			 show_remote_port, store_remote_port);
+static NETCON_CLASS_ATTR(local_ip, S_IRUGO | S_IWUSR,
+			 show_local_ip, store_local_ip);
+static NETCON_CLASS_ATTR(remote_ip, S_IRUGO | S_IWUSR,
+			 show_remote_ip, store_remote_ip);
+static NETCON_CLASS_ATTR(local_mac, S_IRUGO, show_local_mac, NULL);
+static NETCON_CLASS_ATTR(remote_mac, S_IRUGO | S_IWUSR,
+			 show_remote_mac, store_remote_mac);
+
+static struct attribute *target_attrs[] = {
+	&target_attr_id.attr,
+	&target_attr_local_port.attr,
+	&target_attr_remote_port.attr,
+	&target_attr_local_ip.attr,
+	&target_attr_remote_ip.attr,
+	&target_attr_local_mac.attr,
+	&target_attr_remote_mac.attr,
+	NULL
+};
+
+static ssize_t show_target_attr(struct kobject *kobj,
+				    struct attribute *attr,
+				    char *buffer)
+{
+	struct target_attr *na =
+		container_of(attr, struct target_attr, attr);
+	struct netconsole_target * nt =
+		container_of(kobj, struct netconsole_target, obj);
+	if (na->show)
+		return na->show(nt, buffer);
+	else
+		return -EIO;
+}
+
+static ssize_t store_target_attr(struct kobject *kobj,
+				     struct attribute *attr,
+				     const char *buffer, size_t count)
+{
+	struct target_attr *na =
+		container_of(attr, struct target_attr, attr);
+	struct netconsole_target *nt =
+		container_of(kobj, struct netconsole_target, obj);
+	if (na->store)
+		return na->store(nt, buffer, count);
+	else
+		return -EIO;
+}
+
+static void release_target(struct kobject *kobj)
+{
+	struct netconsole_target *nt =
+		container_of(kobj, struct netconsole_target, obj);
+
+	remove_target(nt);
+}
+
+static struct sysfs_ops target_sysfs_ops = {
+	.show = show_target_attr,
+	.store = store_target_attr
+};
+
+static struct kobj_type target_ktype = {
+	.release = release_target,
+	.sysfs_ops = &target_sysfs_ops,
+	.default_attrs = target_attrs,
+};
+
+static struct miscdevice netconsole_miscdev = {
+	.minor = MISC_DYNAMIC_MINOR,
+	.name = "netconsole",
+};
+
+static int setup_target_sysfs(struct netconsole_target *nt)
+{
+	kobject_set_name(&nt->obj, "port%d", nt->id);
+	nt->obj.parent = &netconsole_miscdev.this_device->kobj;
+	nt->obj.ktype = &target_ktype;
+	return kobject_register(&nt->obj);
+}
 
 static int add_target(char* target_config)
 {
@@ -117,6 +321,7 @@ static int add_target(char* target_confi
 	list_add(&new_target->list, &target_list);
 	spin_unlock(&target_list_lock);
 
+	retval = setup_target_sysfs(new_target);
  out:
 	return retval;
 }
@@ -195,6 +400,15 @@ static int __init init_netconsole(void)
 #ifdef CONFIG_NETCONSOLE_DYNCON
 	char *p;
 
+	if (misc_register(&netconsole_miscdev)) {
+		printk(KERN_ERR
+		       "netconsole: failed to register misc device for "
+		       "name = %s, id = %d\n",
+		       netconsole_miscdev.name, netconsole_miscdev.minor);
+		return -EIO;
+	} else
+		miscdev_configured = 1;
+
 	register_console(&netconsole);
 	if(!strlen(config)) {
 		printk(KERN_ERR "netconsole: not configured\n");
@@ -227,8 +441,10 @@ static void cleanup_netconsole(void)
 
 	unregister_console(&netconsole);
 	list_for_each_entry_safe(nt, tmp, &target_list, list) {
-		remove_target(nt);
+		kobject_unregister(&nt->obj);
 	}
+	if (miscdev_configured)
+		misc_deregister(&netconsole_miscdev);
 #else
 	unregister_console(&netconsole);
 	netpoll_cleanup(&np);

-- 


