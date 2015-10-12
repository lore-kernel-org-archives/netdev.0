From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v4 1/7] switchdev: introduce switchdev workqueue
Date: Mon, 12 Oct 2015 19:54:21 +0200
Message-ID: <1444672467-20621-2-git-send-email-jiri@resnulli.us>
References: <1444672467-20621-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
	john.fastabend@gmail.com, David.Laight@ACULAB.COM,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:37005 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751539AbbJLRyb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 13:54:31 -0400
Received: by wijq8 with SMTP id q8so69159138wij.0
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 10:54:30 -0700 (PDT)
In-Reply-To: <1444672467-20621-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This is going to be used for deferred operations.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/switchdev.h   |  5 +++++
 net/switchdev/switchdev.c | 19 +++++++++++++++++++
 2 files changed, 24 insertions(+)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 1ce7083..d2879f2 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -205,6 +205,7 @@ int switchdev_port_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
 void switchdev_port_fwd_mark_set(struct net_device *dev,
 				 struct net_device *group_dev,
 				 bool joining);
+void switchdev_flush_deferred(void);
 
 #else
 
@@ -326,6 +327,10 @@ static inline void switchdev_port_fwd_mark_set(struct net_device *dev,
 {
 }
 
+static inline void switchdev_flush_deferred(void)
+{
+}
+
 #endif
 
 #endif /* _LINUX_SWITCHDEV_H_ */
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 7a9ab90..d119e9c 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -17,9 +17,12 @@
 #include <linux/netdevice.h>
 #include <linux/if_bridge.h>
 #include <linux/list.h>
+#include <linux/workqueue.h>
 #include <net/ip_fib.h>
 #include <net/switchdev.h>
 
+static struct workqueue_struct *switchdev_wq;
+
 /**
  *	switchdev_trans_item_enqueue - Enqueue data item to transaction queue
  *
@@ -1217,3 +1220,19 @@ void switchdev_port_fwd_mark_set(struct net_device *dev,
 	dev->offload_fwd_mark = mark;
 }
 EXPORT_SYMBOL_GPL(switchdev_port_fwd_mark_set);
+
+void switchdev_flush_deferred(void)
+{
+	flush_workqueue(switchdev_wq);
+}
+EXPORT_SYMBOL_GPL(switchdev_flush_deferred);
+
+static int __init switchdev_init(void)
+{
+	switchdev_wq = create_workqueue("switchdev");
+	if (!switchdev_wq)
+		return -ENOMEM;
+	return 0;
+}
+
+subsys_initcall(switchdev_init);
-- 
1.9.3
