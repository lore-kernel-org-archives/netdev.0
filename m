From: Xander Huff <xander.huff@ni.com>
Subject: [PATCH 2/2] net: add device_poll functionality common to all net devices
Date: Mon, 26 Jan 2015 16:46:33 -0600
Message-ID: <1422312393-61485-2-git-send-email-xander.huff@ni.com>
References: <1422312393-61485-1-git-send-email-xander.huff@ni.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jaeden.amero@ni.com, ben.shelton@ni.com, brad.mouring@ni.com,
	rich.tollerton@ni.com
To: gregkh@suse.de, davem@davemloft.net, jeff.westfahl@ni.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1422312393-61485-1-git-send-email-xander.huff@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Westfahl <jeff.westfahl@ni.com>

The device_poll feature is generic to any device. Most net devices should
be able to use a set of common functionality to implement device_poll, such
as CAP_NET_ADMIN and rtnl_lock. Add this common functionality for all net
devices to use.

This is a standalone feature that should be submitted for review and
possible inclusion in mainline, or maybe in the RT patch.

Signed-off-by: Jeff Westfahl <jeff.westfahl@ni.com>
---
 include/linux/netdev_poll.h | 26 ++++++++++++++++++
 net/Kconfig                 |  3 +++
 net/core/Makefile           |  1 +
 net/core/dev_poll.c         | 64 +++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 94 insertions(+)
 create mode 100644 include/linux/netdev_poll.h
 create mode 100644 net/core/dev_poll.c

diff --git a/include/linux/netdev_poll.h b/include/linux/netdev_poll.h
new file mode 100644
index 0000000..3785454
--- /dev/null
+++ b/include/linux/netdev_poll.h
@@ -0,0 +1,26 @@
+/*
+ * Copyright (C) 2014 National Instruments Corp.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#ifndef _LINUX_NETDEV_POLL_H_
+#define _LINUX_NETDEV_POLL_H_
+
+#ifdef CONFIG_NETDEV_POLL
+
+#include <linux/device_poll.h>
+
+int netdev_poll_init(struct device_poll *device_poll);
+
+#endif
+
+#endif /* _LINUX_NETDEV_POLL_H_ */
diff --git a/net/Kconfig b/net/Kconfig
index a073148..6e6ec69 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -324,5 +324,8 @@ source "net/caif/Kconfig"
 source "net/ceph/Kconfig"
 source "net/nfc/Kconfig"
 
+config NETDEV_POLL
+	bool
+	select DEVICE_POLL
 
 endif   # if NET
diff --git a/net/core/Makefile b/net/core/Makefile
index 0d357b1..4255163 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -19,3 +19,4 @@ obj-$(CONFIG_FIB_RULES) += fib_rules.o
 obj-$(CONFIG_TRACEPOINTS) += net-traces.o
 obj-$(CONFIG_NET_DROP_MONITOR) += drop_monitor.o
 obj-$(CONFIG_NETWORK_PHY_TIMESTAMPING) += timestamping.o
+obj-$(CONFIG_NETDEV_POLL) += dev_poll.o
diff --git a/net/core/dev_poll.c b/net/core/dev_poll.c
new file mode 100644
index 0000000..1f2d455
--- /dev/null
+++ b/net/core/dev_poll.c
@@ -0,0 +1,64 @@
+/*
+ * Copyright (C) 2014 National Instruments Corp.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#include <linux/netdev_poll.h>
+#include <linux/netdevice.h>
+#include <linux/rtnetlink.h>
+
+/* netdev_poll internal functions */
+
+static int netdev_poll_reinit(struct device_poll *device_poll)
+{
+	int ret = 0;
+	struct net_device *netdev = to_net_dev(device_poll->device);
+
+	if (netif_running(netdev)) {
+		netdev->netdev_ops->ndo_stop(netdev);
+		ret = netdev->netdev_ops->ndo_open(netdev);
+	}
+
+	return ret;
+}
+
+static void netdev_poll_lock(struct device_poll *device_poll)
+{
+	rtnl_lock();
+}
+
+static void netdev_poll_unlock(struct device_poll *device_poll)
+{
+	rtnl_unlock();
+}
+
+/* netdev_poll external functions */
+
+int netdev_poll_init(struct device_poll *device_poll)
+{
+	if (!device_poll || !device_poll->device || !device_poll->ops)
+		return -EINVAL;
+
+	if (!device_poll->ops->reinit)
+		device_poll->ops->reinit = netdev_poll_reinit;
+	if (!device_poll->ops->lock)
+		device_poll->ops->lock = netdev_poll_lock;
+	if (!device_poll->ops->unlock)
+		device_poll->ops->unlock = netdev_poll_unlock;
+
+	/* Allow changes from any process with CAP_NET_ADMIN. */
+	device_poll->use_capability = 1;
+	device_poll->capability = CAP_NET_ADMIN;
+
+	return device_poll_init(device_poll);
+}
+EXPORT_SYMBOL(netdev_poll_init);
-- 
1.9.1
