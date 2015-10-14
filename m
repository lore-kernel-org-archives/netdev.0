From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v5 1/8] switchdev: introduce switchdev deferred ops infrastructure
Date: Wed, 14 Oct 2015 19:40:48 +0200
Message-ID: <1444844455-12508-2-git-send-email-jiri@resnulli.us>
References: <1444844455-12508-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
	john.fastabend@gmail.com, David.Laight@ACULAB.COM,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:38896 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753784AbbJNRk7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 13:40:59 -0400
Received: by wieq12 with SMTP id q12so94318933wie.1
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2015 10:40:58 -0700 (PDT)
In-Reply-To: <1444844455-12508-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Introduce infrastructure which will be used internally to defer ops.
Note that the deferred ops are queued up and either are processed by
scheduled work or explicitly by user calling deferred_process function.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/switchdev.h   |  5 +++
 net/switchdev/switchdev.c | 80 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 85 insertions(+)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 1ce7083..31b9038 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -167,6 +167,7 @@ switchdev_notifier_info_to_dev(const struct switchdev_notifier_info *info)
 
 #ifdef CONFIG_NET_SWITCHDEV
 
+void switchdev_deferred_process(void);
 int switchdev_port_attr_get(struct net_device *dev,
 			    struct switchdev_attr *attr);
 int switchdev_port_attr_set(struct net_device *dev,
@@ -208,6 +209,10 @@ void switchdev_port_fwd_mark_set(struct net_device *dev,
 
 #else
 
+static inline void switchdev_deferred_process(void)
+{
+}
+
 static inline int switchdev_port_attr_get(struct net_device *dev,
 					  struct switchdev_attr *attr)
 {
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index b8aaf820..5e64b59 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -17,6 +17,7 @@
 #include <linux/netdevice.h>
 #include <linux/if_bridge.h>
 #include <linux/list.h>
+#include <linux/workqueue.h>
 #include <net/ip_fib.h>
 #include <net/switchdev.h>
 
@@ -92,6 +93,85 @@ static void switchdev_trans_items_warn_destroy(struct net_device *dev,
 	switchdev_trans_items_destroy(trans);
 }
 
+static LIST_HEAD(deferred);
+static DEFINE_SPINLOCK(deferred_lock);
+
+typedef void switchdev_deferred_func_t(struct net_device *dev,
+				       const void *data);
+
+struct switchdev_deferred_item {
+	struct list_head list;
+	struct net_device *dev;
+	switchdev_deferred_func_t *func;
+	unsigned long data[0];
+};
+
+static struct switchdev_deferred_item *switchdev_deferred_dequeue(void)
+{
+	struct switchdev_deferred_item *dfitem;
+
+	spin_lock_bh(&deferred_lock);
+	if (list_empty(&deferred)) {
+		dfitem = NULL;
+		goto unlock;
+	}
+	dfitem = list_first_entry(&deferred,
+				  struct switchdev_deferred_item, list);
+	list_del(&dfitem->list);
+unlock:
+	spin_unlock_bh(&deferred_lock);
+	return dfitem;
+}
+
+/**
+ *	switchdev_deferred_process - Process ops in deferred queue
+ *
+ *	Called to flush the ops currently queued in deferred ops queue.
+ *	rtnl_lock must be held.
+ */
+void switchdev_deferred_process(void)
+{
+	struct switchdev_deferred_item *dfitem;
+
+	ASSERT_RTNL();
+
+	while ((dfitem = switchdev_deferred_dequeue())) {
+		dfitem->func(dfitem->dev, dfitem->data);
+		dev_put(dfitem->dev);
+		kfree(dfitem);
+	}
+}
+EXPORT_SYMBOL_GPL(switchdev_deferred_process);
+
+static void switchdev_deferred_process_work(struct work_struct *work)
+{
+	rtnl_lock();
+	switchdev_deferred_process();
+	rtnl_unlock();
+}
+
+static DECLARE_WORK(deferred_process_work, switchdev_deferred_process_work);
+
+static int switchdev_deferred_enqueue(struct net_device *dev,
+				      const void *data, size_t data_len,
+				      switchdev_deferred_func_t *func)
+{
+	struct switchdev_deferred_item *dfitem;
+
+	dfitem = kmalloc(sizeof(*dfitem) + data_len, GFP_ATOMIC);
+	if (!dfitem)
+		return -ENOMEM;
+	dfitem->dev = dev;
+	dfitem->func = func;
+	memcpy(dfitem->data, data, data_len);
+	dev_hold(dev);
+	spin_lock_bh(&deferred_lock);
+	list_add_tail(&dfitem->list, &deferred);
+	spin_unlock_bh(&deferred_lock);
+	schedule_work(&deferred_process_work);
+	return 0;
+}
+
 /**
  *	switchdev_port_attr_get - Get port attribute
  *
-- 
1.9.3
