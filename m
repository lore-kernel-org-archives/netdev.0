From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 4/4] net: introduce dummy switch
Date: Wed, 19 Mar 2014 16:33:52 +0100
Message-ID: <1395243232-32630-5-git-send-email-jiri@resnulli.us>
References: <1395243232-32630-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f44.google.com ([74.125.83.44]:38695 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965493AbaCSPeG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 11:34:06 -0400
Received: by mail-ee0-f44.google.com with SMTP id e49so6762006eek.31
        for <netdev@vger.kernel.org>; Wed, 19 Mar 2014 08:34:05 -0700 (PDT)
In-Reply-To: <1395243232-32630-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dummy switch implementation using switchdev API

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/Kconfig       |   7 +++
 drivers/net/Makefile      |   1 +
 drivers/net/dummyswitch.c | 142 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 150 insertions(+)
 create mode 100644 drivers/net/dummyswitch.c

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 89402c3..a9629a7 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -71,6 +71,13 @@ config DUMMY
 	  To compile this driver as a module, choose M here: the module
 	  will be called dummy.
 
+config NET_DUMMY_SWITCH
+	tristate "Dummy switch net driver support"
+	depends on NET_SWITCHDEV
+	---help---
+	  To compile this driver as a module, choose M here: the module
+	  will be called dummyswitch.
+
 config EQUALIZER
 	tristate "EQL (serial line load balancing) support"
 	---help---
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 3fef8a8..d5d4ce6 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -7,6 +7,7 @@
 #
 obj-$(CONFIG_BONDING) += bonding/
 obj-$(CONFIG_DUMMY) += dummy.o
+obj-$(CONFIG_NET_DUMMY_SWITCH) += dummyswitch.o
 obj-$(CONFIG_EQUALIZER) += eql.o
 obj-$(CONFIG_IFB) += ifb.o
 obj-$(CONFIG_MACVLAN) += macvlan.o
diff --git a/drivers/net/dummyswitch.c b/drivers/net/dummyswitch.c
new file mode 100644
index 0000000..8c315cb6
--- /dev/null
+++ b/drivers/net/dummyswitch.c
@@ -0,0 +1,142 @@
+/*
+ * drivers/net/dummyswitch.c - Dummy switch device
+ * Copyright (c) 2014 Jiri Pirko <jiri@resnulli.us>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/moduleparam.h>
+#include <linux/switchdev.h>
+
+#include <net/rtnetlink.h>
+
+static int numswitches = 1;
+static int numports = 8;
+
+module_param(numswitches, int, 1);
+MODULE_PARM_DESC(numswitches, "Number of dummy switch pseudo devices");
+module_param(numports, int, 8);
+MODULE_PARM_DESC(numports, "Number of ports per dummy switch pseudo device");
+
+static const struct swdev_ops dummysw_swdev_ops = {
+	.kind = "dummyswitch",
+};
+
+static netdev_tx_t dummyswport_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	dev_kfree_skb(skb);
+	return NETDEV_TX_OK;
+}
+
+static const struct swportdev_ops dummysw_swportdev_ops = {
+	.kind = "dummyswitchport",
+	.skb_xmit = dummyswport_xmit,
+};
+
+static struct net_device **dummyswdevs;
+
+static void dummysw_exit_ports(struct net_device *dev)
+{
+	struct net_device *tmp;
+
+	for_each_netdev(dev_net(dev), tmp) {
+		if (netdev_master_upper_dev_get(tmp) == dev)
+			swportdev_destroy(tmp);
+	}
+}
+
+static int dummysw_init_ports(struct net_device *dev)
+{
+	struct net_device *tmp;
+	int err;
+	int i;
+
+	for (i = 0; i < numports; i++) {
+		tmp = swportdev_create(dev, &dummysw_swportdev_ops);
+		if (IS_ERR(tmp)) {
+			err = PTR_ERR(tmp);
+			goto exit_ports;
+		}
+	}
+	return 0;
+
+exit_ports:
+	dummysw_exit_ports(dev);
+	return err;
+}
+
+static void dummysw_exit_one(struct net_device **pdev)
+{
+	dummysw_exit_ports(*pdev);
+	swdev_destroy(*pdev);
+}
+
+static int dummysw_init_one(struct net_device **pdev)
+{
+	struct net_device *dev;
+	int err;
+
+	dev = swdev_create(&dummysw_swdev_ops);
+	if (IS_ERR(dev))
+		return PTR_ERR(dev);
+	err = dummysw_init_ports(dev);
+	if (err)
+		goto swdev_destroy;
+	*pdev = dev;
+	return 0;
+
+swdev_destroy:
+	swdev_destroy(dev);
+	return err;
+}
+
+static int __init dummysw_module_init(void)
+{
+	int err;
+	int i;
+
+	dummyswdevs = kmalloc(sizeof(struct net_device) * numswitches,
+			      GFP_KERNEL);
+	if (!dummyswdevs)
+		return -ENOMEM;
+
+	rtnl_lock();
+	for (i = 0; i < numswitches; i++) {
+		err = dummysw_init_one(&dummyswdevs[i]);
+		if (err)
+			goto rollback;
+	}
+	rtnl_unlock();
+	return 0;
+
+rollback:
+	for (i--; i >= 0; i--)
+		dummysw_exit_one(&dummyswdevs[i]);
+	rtnl_unlock();
+	kfree(dummyswdevs);
+	return err;
+}
+
+static void __exit dummysw_module_exit(void)
+{
+	int i;
+
+	rtnl_lock();
+	for (i = 0; i < numswitches; i++)
+		dummysw_exit_one(&dummyswdevs[i]);
+	rtnl_unlock();
+	kfree(dummyswdevs);
+}
+
+module_init(dummysw_module_init);
+module_exit(dummysw_module_exit);
+
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR("Jiri Pirko <jiri@resnulli.us>");
+MODULE_DESCRIPTION("Dummy switch device");
-- 
1.8.5.3
