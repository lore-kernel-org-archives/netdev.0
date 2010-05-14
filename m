From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: [RFC] NF: IP tables idletimer target implementation
Date: Fri, 14 May 2010 15:50:58 +0300
Message-ID: <1273841458-10443-1-git-send-email-luciano.coelho@nokia.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Timo Teras <timo.teras@iki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:41003 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754307Ab0ENMvV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 08:51:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements an idletimer IP tables target that can be used to
identify when interfaces have been idle for a certain period of time.

It adds a file to the sysfs for each interface that is brought up.  The=
 file
contains the time remaining before the event is triggered.  This file c=
an
also be used to set the timer manually.

The default timeout should be set when the IP table rule is defined wit=
h the
--timeout parameter set.

This implementation was originally done by Timo Teras and a few other p=
eople
who have sent patches with updates and fixes.  It has lived for a while=
 in
the linux-omap tree, but has been removed when linux-omap was aligned w=
ith
upstream.  Now the patch has been forward-ported, which includes a few
changes related to net namespaces, x_tables etc.

While this is not the best approach for interface idle time monitoring,=
 it is
non-intrusive and fits well in the existing architecture without any ma=
jor
changes to the networking subsystem.

Cc: Timo Teras <timo.teras@iki.fi>
Signed-off-by: Luciano Coelho <luciano.coelho@nokia.com>
---
 include/linux/netfilter_ipv4/ipt_IDLETIMER.h |   22 ++
 net/ipv4/netfilter/Kconfig                   |   17 ++
 net/ipv4/netfilter/Makefile                  |    1 +
 net/ipv4/netfilter/ipt_IDLETIMER.c           |  320 ++++++++++++++++++=
++++++++
 4 files changed, 360 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/netfilter_ipv4/ipt_IDLETIMER.h
 create mode 100644 net/ipv4/netfilter/ipt_IDLETIMER.c

diff --git a/include/linux/netfilter_ipv4/ipt_IDLETIMER.h b/include/lin=
ux/netfilter_ipv4/ipt_IDLETIMER.h
new file mode 100644
index 0000000..89993e2
--- /dev/null
+++ b/include/linux/netfilter_ipv4/ipt_IDLETIMER.h
@@ -0,0 +1,22 @@
+/*
+ * linux/include/linux/netfilter_ipv4/ipt_IDLETIMER.h
+ *
+ * Header file for IP tables timer target module.
+ *
+ * Copyright (C) 2004 Nokia Corporation
+ * Written by Timo Ter=C3=A4s <ext-timo.teras@nokia.com>
+ *
+ * This program is free software; you can redistribute it and/or modif=
y
+ * it under the terms of the GNU General Public License as published b=
y
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef _IPT_TIMER_H
+#define _IPT_TIMER_H
+
+struct ipt_idletimer_info {
+	unsigned int timeout;
+};
+
+#endif
diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index 1833bdb..91fba9a 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -204,6 +204,23 @@ config IP_NF_TARGET_REDIRECT
=20
 	  To compile it as a module, choose M here.  If unsure, say N.
=20
+config IP_NF_TARGET_IDLETIMER
+	tristate  "IDLETIMER target support"
+	depends on IP_NF_IPTABLES
+	help
+	  This option adds a `IDLETIMER' target. Each matching packet resets
+	  the timer associated with input and/or output interfaces. Timer
+	  expiry causes kobject uevent. Idle timer can be read via sysfs.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
+config IP_NF_TARGET_IDLETIMER_DEBUG
+	bool "IDLETIMER target debugging"
+	help
+	  Say Y here if you want to get debugging information when using the
+	  IDLETIMER target.  If unsure, say N.
+
+
 config NF_NAT_SNMP_BASIC
 	tristate "Basic SNMP-ALG support"
 	depends on NF_NAT
diff --git a/net/ipv4/netfilter/Makefile b/net/ipv4/netfilter/Makefile
index 4811159..60bdaf1 100644
--- a/net/ipv4/netfilter/Makefile
+++ b/net/ipv4/netfilter/Makefile
@@ -60,6 +60,7 @@ obj-$(CONFIG_IP_NF_TARGET_MASQUERADE) +=3D ipt_MASQUE=
RADE.o
 obj-$(CONFIG_IP_NF_TARGET_NETMAP) +=3D ipt_NETMAP.o
 obj-$(CONFIG_IP_NF_TARGET_REDIRECT) +=3D ipt_REDIRECT.o
 obj-$(CONFIG_IP_NF_TARGET_REJECT) +=3D ipt_REJECT.o
+obj-$(CONFIG_IP_NF_TARGET_IDLETIMER) +=3D ipt_IDLETIMER.o
 obj-$(CONFIG_IP_NF_TARGET_ULOG) +=3D ipt_ULOG.o
=20
 # generic ARP tables
diff --git a/net/ipv4/netfilter/ipt_IDLETIMER.c b/net/ipv4/netfilter/ip=
t_IDLETIMER.c
new file mode 100644
index 0000000..2c5b465
--- /dev/null
+++ b/net/ipv4/netfilter/ipt_IDLETIMER.c
@@ -0,0 +1,320 @@
+/*
+ * linux/net/ipv4/netfilter/ipt_IDLETIMER.c
+ *
+ * Netfilter module to trigger a timer when packet matches.
+ * After timer expires a kevent will be sent.
+ *
+ * Copyright (C) 2004, 2010 Nokia Corporation
+ * Written by Timo Teras <ext-timo.teras@nokia.com>
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
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/timer.h>
+#include <linux/list.h>
+#include <linux/spinlock.h>
+#include <linux/notifier.h>
+#include <linux/netfilter.h>
+#include <linux/rtnetlink.h>
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter_ipv4/ipt_IDLETIMER.h>
+#include <linux/kobject.h>
+#include <linux/workqueue.h>
+
+#ifdef CONFIG_IP_NF_TARGET_IDLETIMER_DEBUG
+#define DEBUGP(format, args...) printk(KERN_DEBUG \
+				       "ipt_IDLETIMER:%s:" format "\n", \
+				       __func__ , ## args)
+#else
+#define DEBUGP(format, args...)
+#endif
+
+/*
+ * Internal timer management.
+ */
+static ssize_t utimer_attr_show(struct device *dev,
+				struct device_attribute *attr, char *buf);
+static ssize_t utimer_attr_store(struct device *dev,
+				 struct device_attribute *attr,
+				 const char *buf, size_t count);
+
+struct utimer_t {
+	char name[IFNAMSIZ];
+	struct list_head entry;
+	struct timer_list timer;
+	struct work_struct work;
+	struct net *net;
+};
+
+static LIST_HEAD(active_utimer_head);
+static DEFINE_SPINLOCK(list_lock);
+static DEVICE_ATTR(idletimer, 0644, utimer_attr_show, utimer_attr_stor=
e);
+
+static void utimer_delete(struct utimer_t *timer)
+{
+	DEBUGP("Deleting timer '%s'\n", timer->name);
+
+	list_del(&timer->entry);
+	del_timer_sync(&timer->timer);
+	put_net(timer->net);
+	kfree(timer);
+}
+
+static void utimer_work(struct work_struct *work)
+{
+	struct utimer_t *timer =3D container_of(work, struct utimer_t, work);
+	struct net_device *netdev =3D NULL;
+
+	netdev =3D dev_get_by_name(timer->net, timer->name);
+
+	if (netdev !=3D NULL) {
+		sysfs_notify(&netdev->dev.kobj, NULL,
+			     "idletimer");
+		dev_put(netdev);
+	}
+}
+
+static void utimer_expired(unsigned long data)
+{
+	struct utimer_t *timer =3D (struct utimer_t *) data;
+
+	DEBUGP("Timer '%s' expired\n", timer->name);
+
+	spin_lock_bh(&list_lock);
+	utimer_delete(timer);
+	spin_unlock_bh(&list_lock);
+
+	schedule_work(&timer->work);
+}
+
+static struct utimer_t *utimer_create(const char *name,
+				      struct net *net)
+{
+	struct utimer_t *timer;
+
+	timer =3D kmalloc(sizeof(struct utimer_t), GFP_ATOMIC);
+	if (timer =3D=3D NULL)
+		return NULL;
+
+	list_add(&timer->entry, &active_utimer_head);
+	strlcpy(timer->name, name, sizeof(timer->name));
+	timer->net =3D get_net(net);
+
+	init_timer(&timer->timer);
+	timer->timer.function =3D utimer_expired;
+	timer->timer.data =3D (unsigned long) timer;
+
+	INIT_WORK(&timer->work, utimer_work);
+
+	DEBUGP("Created timer '%s'\n", timer->name);
+
+	return timer;
+}
+
+static struct utimer_t *__utimer_find(const char *name, const struct n=
et *net)
+{
+	struct utimer_t *entry;
+
+	list_for_each_entry(entry, &active_utimer_head, entry) {
+		if (!strcmp(name, entry->name) && net =3D=3D entry->net)
+			return entry;
+	}
+
+	return NULL;
+}
+
+static void utimer_modify(const char *name,
+			  struct net *net,
+			  unsigned long expires)
+{
+	struct utimer_t *timer;
+
+	DEBUGP("Modifying timer '%s'\n", name);
+	spin_lock_bh(&list_lock);
+	timer =3D __utimer_find(name, net);
+	if (timer =3D=3D NULL)
+		timer =3D utimer_create(name, net);
+	mod_timer(&timer->timer, expires);
+	spin_unlock_bh(&list_lock);
+}
+
+static ssize_t utimer_attr_show(struct device *dev,
+				struct device_attribute *attr, char *buf)
+{
+	struct utimer_t *timer;
+	struct net_device *netdev =3D to_net_dev(dev);
+	unsigned long expires =3D 0;
+
+	spin_lock_bh(&list_lock);
+	timer =3D __utimer_find(netdev->name, dev_net(netdev));
+	if (timer)
+		expires =3D timer->timer.expires;
+	spin_unlock_bh(&list_lock);
+
+	if (expires)
+		return sprintf(buf, "%lu\n", (expires-jiffies) / HZ);
+
+	return sprintf(buf, "0\n");
+}
+
+static ssize_t utimer_attr_store(struct device *dev,
+				 struct device_attribute *attr,
+				 const char *buf, size_t count)
+{
+	int expires;
+	struct net_device *netdev =3D to_net_dev(dev);
+
+	if (sscanf(buf, "%d", &expires) =3D=3D 1) {
+		if (expires > 0)
+			utimer_modify(netdev->name,
+				      dev_net(netdev),
+				      jiffies+HZ*(unsigned long)expires);
+	}
+
+	return count;
+}
+
+static int utimer_notifier_call(struct notifier_block *this,
+				unsigned long event, void *ptr)
+{
+	struct net_device *netdev =3D ptr;
+	int ret;
+
+	switch (event) {
+	case NETDEV_UP:
+		DEBUGP("NETDEV_UP: %s\n", netdev->name);
+		ret =3D device_create_file(&netdev->dev,
+					 &dev_attr_idletimer);
+		WARN_ON(ret);
+
+		break;
+	case NETDEV_DOWN:
+		DEBUGP("NETDEV_DOWN: %s\n", netdev->name);
+		device_remove_file(&netdev->dev,
+				   &dev_attr_idletimer);
+		break;
+	}
+
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block utimer_notifier_block =3D {
+	.notifier_call	=3D utimer_notifier_call,
+};
+
+
+static int utimer_init(void)
+{
+	return register_netdevice_notifier(&utimer_notifier_block);
+}
+
+static void utimer_fini(void)
+{
+	struct utimer_t *entry, *next;
+	struct net_device *dev;
+	struct net *net;
+
+	list_for_each_entry_safe(entry, next, &active_utimer_head, entry)
+		utimer_delete(entry);
+
+	rtnl_lock();
+	unregister_netdevice_notifier(&utimer_notifier_block);
+	for_each_net(net) {
+		for_each_netdev(net, dev) {
+			utimer_notifier_call(&utimer_notifier_block,
+					     NETDEV_DOWN, dev);
+		}
+	}
+	rtnl_unlock();
+}
+
+/*
+ * The actual iptables plugin.
+ */
+static unsigned int ipt_idletimer_target(struct sk_buff *skb,
+					 const struct xt_action_param *par)
+{
+	const struct ipt_idletimer_info *target =3D par->targinfo;
+	unsigned long expires;
+
+	expires =3D jiffies + HZ*target->timeout;
+
+	if (par->in !=3D NULL)
+		utimer_modify(par->in->name,
+			      dev_net(par->in),
+			      expires);
+
+	if (par->out !=3D NULL)
+		utimer_modify(par->out->name,
+			      dev_net(par->out),
+			      expires);
+
+	return XT_CONTINUE;
+}
+
+static int ipt_idletimer_checkentry(const struct xt_tgchk_param *par)
+{
+	const struct ipt_idletimer_info *info =3D par->targinfo;
+
+	if (info->timeout =3D=3D 0) {
+		DEBUGP("timeout value is zero\n");
+		return false;
+	}
+
+	return true;
+}
+
+static struct xt_target ipt_idletimer =3D {
+	.name		=3D "IDLETIMER",
+	.family		=3D NFPROTO_IPV4,
+	.target		=3D ipt_idletimer_target,
+	.targetsize     =3D sizeof(struct ipt_idletimer_info),
+	.checkentry	=3D ipt_idletimer_checkentry,
+	.me		=3D THIS_MODULE,
+};
+
+static int __init init(void)
+{
+	int ret;
+
+	ret =3D utimer_init();
+	if (ret)
+		return ret;
+
+	ret =3D  xt_register_target(&ipt_idletimer);
+	if (ret < 0) {
+		utimer_fini();
+		return ret;
+	}
+
+	return 0;
+}
+
+static void __exit fini(void)
+{
+	xt_unregister_target(&ipt_idletimer);
+	utimer_fini();
+}
+
+module_init(init);
+module_exit(fini);
+
+MODULE_AUTHOR("Timo Teras <ext-timo.teras@nokia.com>");
+MODULE_DESCRIPTION("iptables idletimer target module");
+MODULE_LICENSE("GPL");
--=20
1.6.3.3

