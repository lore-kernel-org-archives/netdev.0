From: Eldad Zack <eldad@fogrefinery.com>
Subject: [PATCH 6/8] LLDP: Core routines
Date: Mon, 25 Jun 2012 20:28:18 +0200
Message-ID: <1340648900-6547-7-git-send-email-eldad@fogrefinery.com>
References: <1340648900-6547-1-git-send-email-eldad@fogrefinery.com>
Cc: Eldad Zack <eldad@fogrefinery.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f174.google.com ([209.85.160.174]:57839 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755842Ab2FYS27 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 14:28:59 -0400
Received: by mail-gh0-f174.google.com with SMTP id r11so3094761ghr.19
        for <netdev@vger.kernel.org>; Mon, 25 Jun 2012 11:28:59 -0700 (PDT)
In-Reply-To: <1340648900-6547-1-git-send-email-eldad@fogrefinery.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Core LLDP routines: handles modules registration,
  netdevice notifications and timers.

* Adds specific data pointer to netdevice.

Signed-off-by: Eldad Zack <eldad@fogrefinery.com>
---
 include/linux/netdevice.h |    4 +
 net/lldp/lldp_core.c      |  214 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 218 insertions(+)
 create mode 100644 net/lldp/lldp_core.c

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index d94cb14..813475a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -61,6 +61,7 @@ struct device;
 struct phy_device;
 /* 802.11 specific */
 struct wireless_dev;
+struct lldp_ptr;
 					/* source back-compat hooks */
 #define SET_ETHTOOL_OPS(netdev,ops) \
 	( (netdev)->ethtool_ops = (ops) )
@@ -1158,6 +1159,9 @@ struct net_device {
 	void			*ax25_ptr;	/* AX.25 specific data */
 	struct wireless_dev	*ieee80211_ptr;	/* IEEE 802.11 specific data,
 						   assign before registering */
+#if IS_ENABLED(CONFIG_LLDP)
+	struct lldp_dev __rcu	*lldp_ptr;	/* LLDP specific data */
+#endif
 
 /*
  * Cache lines mostly used on receive path (including eth_type_trans())
diff --git a/net/lldp/lldp_core.c b/net/lldp/lldp_core.c
new file mode 100644
index 0000000..3d4a1f1
--- /dev/null
+++ b/net/lldp/lldp_core.c
@@ -0,0 +1,214 @@
+/* LLDP		Link Layer Discovery Protocol impementation for Linux
+ *		IEEE Std 802.1ab
+ *
+ * Author:	Eldad Zack <eldad@fogrefinery.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#define pr_fmt(fmt) "LLDP " fmt
+
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/timer.h>
+#include <linux/if_ether.h>
+#include <linux/etherdevice.h>
+#include <linux/if_arp.h>
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+#include "lldp.h"
+
+int sysctl_lldp_operational_mode = LLDP_SYSCTL_OP_SUPPRESS;
+int sysctl_lldp_transmit_interval = LLDP_DEFAULT_MSG_TX_INTERVAL;
+int sysctl_lldp_hold_multiplier = LLDP_DEFAULT_MSG_TX_HOLD_MULT;
+
+bool is_valid_lldp_dev(struct net_device *dev)
+{
+	bool ret;
+
+	if (!is_valid_ether_addr(dev->dev_addr))
+		return false;
+
+	ret = (!(dev->flags & IFF_LOOPBACK) &&
+		(dev->type == ARPHRD_ETHER) &&
+		(dev->addr_len == ETH_ALEN));
+
+	return ret;
+}
+
+int init_lldp_dev_info(struct net_device *dev)
+{
+	struct lldp_dev *ldev;
+
+	if (dev == NULL)
+		return -EINVAL;
+
+	if (dev->lldp_ptr != NULL)
+		return 0;
+
+	ldev = kzalloc(sizeof(struct lldp_dev), GFP_ATOMIC);
+	if (ldev == NULL)
+		return -ENOMEM;
+
+	rcu_read_lock();
+	dev->lldp_ptr = ldev;
+	rcu_read_unlock();
+
+	return 0;
+}
+
+void lldp_timer_handler(unsigned long data)
+{
+	struct net_device *dev = (struct net_device *) data;
+	struct lldp_dev *ldev;
+	struct timer_list *tx_timer;
+
+	BUG_ON(dev == NULL);
+
+	rcu_read_lock();
+	if (dev->lldp_ptr == NULL) { /* device went down */
+		rcu_read_unlock();
+		return;
+	}
+
+	ldev = dev->lldp_ptr;
+	tx_timer = ldev->tx_timer;
+
+	if (sysctl_lldp_operational_mode & LLDP_SYSCTL_OP_TX)
+		lldp_send(dev);
+
+	mod_timer(tx_timer, jiffies +
+		msecs_to_jiffies(1000 * sysctl_lldp_transmit_interval));
+	rcu_read_unlock();
+}
+
+void lldp_add_dev(struct net_device *dev)
+{
+	int err;
+	struct lldp_dev *ldev;
+	struct timer_list *tx_timer;
+
+	err = init_lldp_dev_info(dev);
+	if (err < 0) {
+		pr_err("could not start on device %s (%d)\n", dev->name, err);
+		return;
+	}
+
+	rcu_read_lock();
+	ldev = dev->lldp_ptr;
+	rcu_read_unlock();
+
+	if (ldev->tx_timer != NULL)
+		return;
+
+	tx_timer = kzalloc(sizeof(struct timer_list), GFP_ATOMIC);
+	if (tx_timer == NULL) {
+		pr_err("no memory available (device %s)\n", dev->name);
+		return;
+	}
+
+	setup_timer(tx_timer, lldp_timer_handler, (unsigned long) dev);
+
+	rcu_read_lock();
+	ldev->tx_timer = tx_timer;
+	rcu_read_unlock();
+
+	/* Send the first frame without waiting. The timer handler
+	 * will schedule it.
+	 */
+	lldp_timer_handler((unsigned long) dev);
+
+	pr_info("started on device %s\n", dev->name);
+}
+
+static void lldp_del_dev(struct net_device *dev)
+{
+	struct lldp_dev *ldev;
+	struct timer_list *tx_timer;
+
+	if (dev == NULL)
+		return;
+
+	rcu_read_lock();
+	ldev = (struct lldp_dev *)dev->lldp_ptr;
+	if (ldev == NULL) {
+		rcu_read_unlock();
+		return;
+	}
+
+	tx_timer = ldev->tx_timer;
+	if (tx_timer != NULL) {
+		ldev->tx_timer = NULL;
+		del_timer(tx_timer);
+		kfree(tx_timer);
+	}
+
+	dev->lldp_ptr = NULL;
+	kfree(ldev);
+	rcu_read_unlock();
+
+	pr_info("stopped on device %s\n", dev->name);
+}
+
+static int lldp_notify(struct notifier_block *nb, unsigned long event,
+		void *data)
+{
+	struct net_device *dev = (struct net_device *) data;
+
+	if (dev == NULL)
+		return NOTIFY_DONE;
+
+	if (!is_valid_lldp_dev(dev))
+		return NOTIFY_DONE;
+
+	switch (event) {
+	case NETDEV_UP: /* NETDEV_CHANGE */
+	case NETDEV_CHANGE:
+		lldp_add_dev(dev);
+		break;
+	case NETDEV_GOING_DOWN:
+		/* Shutdown PDU, Clause 10.2.1.2 */
+		lldp_send_shutdown(dev);
+		break;
+	case NETDEV_UNREGISTER: /* NETDEV_DOWN */
+	case NETDEV_DOWN:
+		lldp_del_dev(dev);
+		break;
+	}
+
+	return NOTIFY_OK;
+};
+
+static struct notifier_block lldp_dev_notify = {
+	.notifier_call = lldp_notify,
+};
+
+static int __init lldp_init(void)
+{
+	pr_info("module initializing\n");
+
+	register_netdevice_notifier(&lldp_dev_notify);
+	lldp_register_sysctl();
+	return 0;
+}
+
+static void __exit lldp_fini(void)
+{
+	struct net_device *dev;
+
+	lldp_unregister_sysctl();
+	unregister_netdevice_notifier(&lldp_dev_notify);
+
+	for_each_netdev(&init_net, dev)
+		lldp_del_dev(dev);
+
+	pr_info("module stopped\n");
+}
+
+module_init(lldp_init);
+module_exit(lldp_fini);
+
+MODULE_LICENSE("GPL");
-- 
1.7.10
