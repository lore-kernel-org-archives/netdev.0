From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC] network devices generating uevents?
Date: Fri, 21 Nov 2008 13:46:59 -0800
Message-ID: <20081121134659.5b305b5c@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36680 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752675AbYKUVrE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 16:47:04 -0500
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.vyatta.com (Postfix) with ESMTP id 3569E4F4228
	for <netdev@vger.kernel.org>; Fri, 21 Nov 2008 13:47:04 -0800 (PST)
Received: from mail.vyatta.com ([127.0.0.1])
	by localhost (mail.vyatta.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id oHNuWaLykKai for <netdev@vger.kernel.org>;
	Fri, 21 Nov 2008 13:47:02 -0800 (PST)
Received: from extreme (unknown [96.225.231.79])
	by mail.vyatta.com (Postfix) with ESMTP id 002744F4226
	for <netdev@vger.kernel.org>; Fri, 21 Nov 2008 13:47:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Perhaps the following would make it easier for applications to
track network device events without having to use netlink.
Compile tested only so far. The implementation is almost trivial...

--- a/net/core/Makefile	2008-11-21 12:25:31.000000000 -0800
+++ b/net/core/Makefile	2008-11-21 13:32:30.000000000 -0800
@@ -17,3 +17,4 @@ obj-$(CONFIG_NET_PKTGEN) += pktgen.o
 obj-$(CONFIG_NETPOLL) += netpoll.o
 obj-$(CONFIG_NET_DMA) += user_dma.o
 obj-$(CONFIG_FIB_RULES) += fib_rules.o
+obj-$(CONFIG_HOTPLUG) += uevent.o
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ b/net/core/uevent.c	2008-11-21 13:42:13.000000000 -0800
@@ -0,0 +1,45 @@
+/*
+ * Linux network device event notification
+ *
+ * Author:
+ *	Stephen Hemminger <shemminger@vyatta.com>
+ */
+
+#include <linux/kernel.h>
+#include <linux/netdevice.h>
+#include <linux/kobject.h>
+#include <linux/notifier.h>
+
+static int netdev_event(struct notifier_block *this, unsigned long event, void *ptr)
+{
+	struct net_device *netdev = ptr;
+
+	switch (event) {
+	case NETDEV_UNREGISTER:
+		kobject_uevent(&netdev->dev.kobj, KOBJ_REMOVE);
+		break;
+	case NETDEV_REGISTER:
+		kobject_uevent(&netdev->dev.kobj, KOBJ_ADD);
+		break;
+	case NETDEV_UP:
+		kobject_uevent(&netdev->dev.kobj, KOBJ_ONLINE);
+		break;
+	case NETDEV_DOWN:
+		kobject_uevent(&netdev->dev.kobj, KOBJ_OFFLINE);
+		break;
+	case NETDEV_CHANGE:
+		kobject_uevent(&netdev->dev.kobj, KOBJ_CHANGE);
+		break;
+	}
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block netdev_uevent_notifier = {
+	.notifier_call	= netdev_event,
+};
+
+static int __init netdev_uevent_init(void)
+{
+	return register_netdevice_notifier(&netdev_uevent_notifier);
+}
+device_initcall(netdev_uevent_init);
