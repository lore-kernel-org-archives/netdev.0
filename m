From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: [PATCH v2] netfilter: Xtables: idletimer target implementation
Date: Wed,  2 Jun 2010 16:41:02 +0300
Message-ID: <1275486062-23753-1-git-send-email-luciano.coelho@nokia.com>
Cc: netfilter-devel@vger.kernel.org, kaber@trash.net,
	jengelh@medozas.de, Timo Teras <timo.teras@iki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.105.134]:26957 "EHLO
	mgw-mx09.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755062Ab0FBNrh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 09:47:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements an idletimer Xtables target that can be used to
identify when interfaces have been idle for a certain period of time.

Timers are identified by labels and are created when a rule is set with a new
label.  The rules also take a timeout value (in seconds) as an option.  If
more than one rule uses the same timer label, the timer will be restarted
whenever any of the rules get a hit.

One entry for each timer is created in sysfs.  This attribute contains the
timer remaining for the timer to expire.  The attributes are located under
the module's object:

/sys/module/xt_IDLETIMER/idletimer/<label>

When the timer expires, the target module sends a sysfs notification to the
userspace, which can then decide what to do (eg. disconnect to save power).

Cc: Timo Teras <timo.teras@iki.fi>
Signed-off-by: Luciano Coelho <luciano.coelho@nokia.com>
---
v2: Fixed according to Jan's comments

 include/linux/netfilter/xt_IDLETIMER.h |   40 ++++
 net/netfilter/Kconfig                  |   12 +
 net/netfilter/Makefile                 |    1 +
 net/netfilter/xt_IDLETIMER.c           |  360 ++++++++++++++++++++++++++++++++
 4 files changed, 413 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/netfilter/xt_IDLETIMER.h
 create mode 100644 net/netfilter/xt_IDLETIMER.c

diff --git a/include/linux/netfilter/xt_IDLETIMER.h b/include/linux/netfilter/xt_IDLETIMER.h
new file mode 100644
index 0000000..6e62224
--- /dev/null
+++ b/include/linux/netfilter/xt_IDLETIMER.h
@@ -0,0 +1,40 @@
+/*
+ * linux/include/linux/netfilter/xt_IDLETIMER.h
+ *
+ * Header file for Xtables timer target module.
+ *
+ * Copyright (C) 2004, 2010 Nokia Corporation
+ * Written by Timo Teras <ext-timo.teras@nokia.com>
+ *
+ * Converted to x_tables and forward-ported to 2.6.34
+ * by Luciano Coelho <luciano.coelho@nokia.com>
+ *
+ * Contact: Luciano Coelho <luciano.coelho@nokia.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * version 2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
+ * 02110-1301 USA
+ */
+
+#ifndef _XT_IDLETIMER_H
+#define _XT_IDLETIMER_H
+
+#define MAX_LABEL_SIZE 32
+
+struct idletimer_tg_info {
+	__u32 timeout;
+
+	char label[MAX_LABEL_SIZE];
+};
+
+#endif
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 8593a77..413ed24 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -424,6 +424,18 @@ config NETFILTER_XT_TARGET_HL
 	since you can easily create immortal packets that loop
 	forever on the network.
 
+config NETFILTER_XT_TARGET_IDLETIMER
+	tristate  "IDLETIMER target support"
+	depends on NETFILTER_ADVANCED
+	help
+
+	  This option adds the `IDLETIMER' target.  Each matching packet
+	  resets the timer associated with label specified when the rule is
+	  added.  When the timer expires, it triggers a sysfs notification.
+	  The remaining time for expiration can be read via sysfs.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
 config NETFILTER_XT_TARGET_LED
 	tristate '"LED" target support'
 	depends on LEDS_CLASS && LEDS_TRIGGERS
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 14e3a8f..e28420a 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -61,6 +61,7 @@ obj-$(CONFIG_NETFILTER_XT_TARGET_TCPMSS) += xt_TCPMSS.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP) += xt_TCPOPTSTRIP.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_TEE) += xt_TEE.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_TRACE) += xt_TRACE.o
+obj-$(CONFIG_NETFILTER_XT_TARGET_IDLETIMER) += xt_IDLETIMER.o
 
 # matches
 obj-$(CONFIG_NETFILTER_XT_MATCH_CLUSTER) += xt_cluster.o
diff --git a/net/netfilter/xt_IDLETIMER.c b/net/netfilter/xt_IDLETIMER.c
new file mode 100644
index 0000000..33fe839
--- /dev/null
+++ b/net/netfilter/xt_IDLETIMER.c
@@ -0,0 +1,360 @@
+/*
+ * linux/net/netfilter/xt_IDLETIMER.c
+ *
+ * Netfilter module to trigger a timer when packet matches.
+ * After timer expires a kevent will be sent.
+ *
+ * Copyright (C) 2004, 2010 Nokia Corporation
+ * Written by Timo Teras <ext-timo.teras@nokia.com>
+ *
+ * Converted to x_tables and reworked for upstream inclusion
+ * by Luciano Coelho <luciano.coelho@nokia.com>
+ *
+ * Contact: Luciano Coelho <luciano.coelho@nokia.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * version 2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
+ * 02110-1301 USA
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/module.h>
+#include <linux/timer.h>
+#include <linux/list.h>
+#include <linux/spinlock.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter/xt_IDLETIMER.h>
+#include <linux/kobject.h>
+#include <linux/workqueue.h>
+#include <linux/sysfs.h>
+
+struct idletimer_tg {
+	struct list_head entry;
+	struct timer_list timer;
+	struct work_struct work;
+
+	struct kobject *kobj;
+	struct idletimer_tg_attr *attr;
+
+	unsigned int refcnt;
+};
+
+/* Start with an empty group, we'll add attributes dynamically */
+static struct attribute *idletimer_tg_group_attrs[] = {
+	NULL,
+};
+
+static struct attribute_group idletimer_tg_group = {
+	.attrs = idletimer_tg_group_attrs,
+};
+
+struct idletimer_tg_attr {
+	struct attribute attr;
+	ssize_t	(*show)(struct kobject *kobj,
+			struct attribute *attr, char *buf);
+};
+
+static LIST_HEAD(idletimer_tg_list);
+static DEFINE_SPINLOCK(list_lock);
+
+static struct kobject *idletimer_tg_kobj;
+
+static
+struct idletimer_tg *__idletimer_tg_find_by_label(const char *label)
+{
+	struct idletimer_tg *entry;
+
+	BUG_ON(!label);
+
+	list_for_each_entry(entry, &idletimer_tg_list, entry) {
+		if (!strcmp(label, entry->attr->attr.name))
+			return entry;
+	}
+
+	return NULL;
+}
+
+static ssize_t idletimer_tg_show(struct kobject *kobj, struct attribute *attr,
+				 char *buf)
+{
+	struct idletimer_tg *timer;
+	unsigned long expires = 0;
+
+	spin_lock_bh(&list_lock);
+	timer =	__idletimer_tg_find_by_label(attr->name);
+	if (timer)
+		expires = timer->timer.expires;
+	spin_unlock_bh(&list_lock);
+
+	if (expires > jiffies)
+		return sprintf(buf, "%u\n",
+			       jiffies_to_msecs(expires - jiffies) / 1000);
+
+	return sprintf(buf, "0\n");
+}
+
+static void idletimer_tg_delete(const struct idletimer_tg_info *info)
+{
+	struct idletimer_tg *timer;
+
+	spin_lock_bh(&list_lock);
+	timer = __idletimer_tg_find_by_label(info->label);
+	if (!timer) {
+		spin_unlock_bh(&list_lock);
+		return;
+	}
+
+	if (--timer->refcnt == 0) {
+		pr_debug("deleting timer %s\n", info->label);
+
+		list_del(&timer->entry);
+		del_timer_sync(&timer->timer);
+		spin_unlock_bh(&list_lock);
+
+		sysfs_remove_file_from_group(idletimer_tg_kobj,
+					     &timer->attr->attr, NULL);
+		kfree(timer->attr->attr.name);
+		kfree(timer->attr);
+		kfree(timer);
+	} else {
+		spin_unlock_bh(&list_lock);
+		pr_debug("decreased refcnt of timer %s to %u\n",
+			 info->label, timer->refcnt);
+	}
+}
+
+static void idletimer_tg_work(struct work_struct *work)
+{
+	struct idletimer_tg *timer = container_of(work, struct idletimer_tg,
+						  work);
+
+	sysfs_notify(idletimer_tg_kobj, NULL,
+		     timer->attr->attr.name);
+}
+
+static void idletimer_tg_expired(unsigned long data)
+{
+	struct idletimer_tg *timer = (struct idletimer_tg *) data;
+
+	pr_debug("timer %s expired\n",
+		 timer->attr->attr.name);
+
+	schedule_work(&timer->work);
+}
+
+static
+struct idletimer_tg *idletimer_tg_create(const struct idletimer_tg_info *info)
+{
+	struct idletimer_tg *timer;
+	struct idletimer_tg_attr *attr;
+
+	attr = kzalloc(sizeof(attr), GFP_KERNEL);
+	if (!attr) {
+		pr_debug("couldn't alloc attribute\n");
+		return NULL;
+	}
+
+	attr->attr.name = kstrdup(info->label, GFP_KERNEL);
+	if (!attr->attr.name) {
+		pr_debug("couldn't alloc attribute name\n");
+		goto out_free_attr;
+	}
+	attr->attr.mode = S_IRUGO;
+	attr->show = idletimer_tg_show;
+
+	if (sysfs_add_file_to_group(idletimer_tg_kobj, &attr->attr, NULL)) {
+		pr_debug("couldn't add attr to sysfs\n");
+		goto out_free_name;
+	}
+
+	timer = kmalloc(sizeof(struct idletimer_tg), GFP_KERNEL);
+	if (!timer) {
+		pr_debug("couldn't alloc timer\n");
+		goto out_free_file;
+	}
+
+	spin_lock_bh(&list_lock);
+	list_add(&timer->entry, &idletimer_tg_list);
+
+	init_timer(&timer->timer);
+	setup_timer(&timer->timer, idletimer_tg_expired, (unsigned long) timer);
+	mod_timer(&timer->timer,
+		  msecs_to_jiffies(info->timeout * 1000) + jiffies);
+
+	timer->attr = attr;
+	timer->refcnt = 0;
+
+	INIT_WORK(&timer->work, idletimer_tg_work);
+	spin_unlock_bh(&list_lock);
+
+	return timer;
+
+out_free_file:
+	sysfs_remove_file_from_group(idletimer_tg_kobj,
+				     &attr->attr, NULL);
+out_free_name:
+	kfree(attr->attr.name);
+out_free_attr:
+	kfree(attr);
+	return NULL;
+}
+
+static void idletimer_tg_cleanup(void)
+{
+	struct idletimer_tg *timer;
+
+	sysfs_remove_group(idletimer_tg_kobj,
+			   &idletimer_tg_group);
+
+	spin_lock(&list_lock);
+	list_for_each_entry(timer, &idletimer_tg_list, entry) {
+		pr_debug("deleting timer %s\n", timer->attr->attr.name);
+
+		list_del(&timer->entry);
+		del_timer_sync(&timer->timer);
+		kfree(timer->attr->attr.name);
+		kfree(timer->attr);
+		kfree(timer);
+	}
+	spin_unlock(&list_lock);
+}
+
+/*
+ * The actual xt_tables plugin.
+ */
+static unsigned int idletimer_tg_target(struct sk_buff *skb,
+					 const struct xt_action_param *par)
+{
+	const struct idletimer_tg_info *info = par->targinfo;
+	struct idletimer_tg *timer;
+
+	pr_debug("resetting timer %s, timeout period %u\n",
+		 info->label, info->timeout);
+
+	spin_lock(&list_lock);
+	timer = __idletimer_tg_find_by_label(info->label);
+
+	BUG_ON(!timer);
+
+	mod_timer(&timer->timer,
+		  msecs_to_jiffies(info->timeout * 1000) + jiffies);
+	spin_unlock(&list_lock);
+
+	return XT_CONTINUE;
+}
+
+static int idletimer_tg_checkentry(const struct xt_tgchk_param *par)
+{
+	const struct idletimer_tg_info *info = par->targinfo;
+	struct idletimer_tg *timer;
+
+	pr_debug("checkentry targinfo %s\n", info->label);
+
+	if (info->timeout == 0) {
+		pr_debug("timeout value is zero\n");
+		return -EINVAL;
+	}
+
+	if (!info->label || strlen(info->label) == 0) {
+		pr_debug("label is missing\n");
+		return -EINVAL;
+	}
+
+	spin_lock(&list_lock);
+	timer = __idletimer_tg_find_by_label(info->label);
+	if (!timer) {
+		spin_unlock(&list_lock);
+		timer = idletimer_tg_create(info);
+		if (!timer) {
+			pr_debug("failed to create timer\n");
+			return -ENOMEM;
+		}
+		spin_lock(&list_lock);
+	}
+
+	timer->refcnt++;
+	mod_timer(&timer->timer,
+		  msecs_to_jiffies(info->timeout * 1000) + jiffies);
+	spin_unlock(&list_lock);
+
+	return 0;
+}
+
+static void idletimer_tg_destroy(const struct xt_tgdtor_param *par)
+{
+	const struct idletimer_tg_info *info = par->targinfo;
+
+	pr_debug("destroy targinfo %s\n", info->label);
+
+	idletimer_tg_delete(info);
+}
+
+static struct xt_target idletimer_tg __read_mostly = {
+	.name		= "IDLETIMER",
+	.family		= NFPROTO_UNSPEC,
+	.target		= idletimer_tg_target,
+	.targetsize     = sizeof(struct idletimer_tg_info),
+	.checkentry	= idletimer_tg_checkentry,
+	.destroy        = idletimer_tg_destroy,
+	.me		= THIS_MODULE,
+};
+
+static int __init idletimer_tg_init(void)
+{
+	int ret;
+
+	idletimer_tg_kobj = kobject_create_and_add("idletimer",
+						   &THIS_MODULE->mkobj.kobj);
+	if (!idletimer_tg_kobj)
+		return -ENOMEM;
+
+	/*
+	 * Maybe adding the kobj under the net class would be cleaner, but at
+	 * the moment the net class only contains interfaces as children.  So
+	 * let's keep the idletimer class inside it's own module's object to
+	 * be safe, in case someone expects all objects under net to be
+	 * actual interfaces.
+	 */
+	ret = sysfs_create_group(idletimer_tg_kobj,
+				 &idletimer_tg_group);
+	if (ret < 0) {
+		pr_debug("failed to create sysfs group");
+		return ret;
+	}
+
+	ret =  xt_register_target(&idletimer_tg);
+	if (ret < 0) {
+		kobject_put(idletimer_tg_kobj);
+		idletimer_tg_cleanup();
+		return ret;
+	}
+
+	return 0;
+}
+
+static void __exit idletimer_tg_exit(void)
+{
+	xt_unregister_target(&idletimer_tg);
+	kobject_put(idletimer_tg_kobj);
+	idletimer_tg_cleanup();
+}
+
+module_init(idletimer_tg_init);
+module_exit(idletimer_tg_exit);
+
+MODULE_AUTHOR("Timo Teras <ext-timo.teras@nokia.com>");
+MODULE_AUTHOR("Luciano Coelho <luciano.coelho@nokia.com>");
+MODULE_DESCRIPTION("Xtables: idle time monitor");
+MODULE_LICENSE("GPL v2");
-- 
1.6.3.3

