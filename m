From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/7] switchdev: introduce switchdev workqueue
Date: Sun, 11 Oct 2015 17:21:05 +0200
Message-ID: <1444576871-19138-2-git-send-email-jiri@resnulli.us>
References: <1444576871-19138-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
	john.fastabend@gmail.com, David.Laight@ACULAB.COM,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:35211 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751805AbbJKPVR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Oct 2015 11:21:17 -0400
Received: by wicge5 with SMTP id ge5so122656155wic.0
        for <netdev@vger.kernel.org>; Sun, 11 Oct 2015 08:21:15 -0700 (PDT)
In-Reply-To: <1444576871-19138-1-git-send-email-jiri@resnulli.us>
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
index 89266a3..cc7f772 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -202,6 +202,7 @@ int switchdev_port_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
 void switchdev_port_fwd_mark_set(struct net_device *dev,
 				 struct net_device *group_dev,
 				 bool joining);
+void switchdev_flush_deferred(void);
 
 #else
 
@@ -323,6 +324,10 @@ static inline void switchdev_port_fwd_mark_set(struct net_device *dev,
 {
 }
 
+static inline void switchdev_flush_deferred(void)
+{
+}
+
 #endif
 
 #endif /* _LINUX_SWITCHDEV_H_ */
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 6e4a4f9..10306b6 100644
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
@@ -1210,3 +1213,19 @@ void switchdev_port_fwd_mark_set(struct net_device *dev,
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
