From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH] netpoll: remove return value from netpoll_rx_disable()
Date: Tue, 28 May 2013 13:53:31 +0800
Message-ID: <51A4465B.4010901@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Eric Dumazet <edumazet@google.com>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:33767 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932109Ab3E1FyA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 01:54:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The netpoll_rx_disable() will always return 0, it is no use and looks wordy,
so remove the unnecessary code and get rid of it in _dev_open and _dev_close.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 include/linux/netpoll.h |  4 ++--
 net/core/dev.c          | 15 ++++-----------
 net/core/netpoll.c      |  3 +--
 3 files changed, 7 insertions(+), 15 deletions(-)

diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
index fa2cb76..f3c7c24 100644
--- a/include/linux/netpoll.h
+++ b/include/linux/netpoll.h
@@ -53,10 +53,10 @@ struct netpoll_info {
 };
 
 #ifdef CONFIG_NETPOLL
-extern int netpoll_rx_disable(struct net_device *dev);
+extern void netpoll_rx_disable(struct net_device *dev);
 extern void netpoll_rx_enable(struct net_device *dev);
 #else
-static inline int netpoll_rx_disable(struct net_device *dev) { return 0; }
+static inline void netpoll_rx_disable(struct net_device *dev) { return; }
 static inline void netpoll_rx_enable(struct net_device *dev) { return; }
 #endif
 
diff --git a/net/core/dev.c b/net/core/dev.c
index fc1e289..20300d4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1198,9 +1198,7 @@ static int __dev_open(struct net_device *dev)
 	 * If we don't do this there is a chance ndo_poll_controller
 	 * or ndo_poll may be running while we open the device
 	 */
-	ret = netpoll_rx_disable(dev);
-	if (ret)
-		return ret;
+	netpoll_rx_disable(dev);
 
 	ret = call_netdevice_notifiers(NETDEV_PRE_UP, dev);
 	ret = notifier_to_errno(ret);
@@ -1309,9 +1307,7 @@ static int __dev_close(struct net_device *dev)
 	LIST_HEAD(single);
 
 	/* Temporarily disable netpoll until the interface is down */
-	retval = netpoll_rx_disable(dev);
-	if (retval)
-		return retval;
+	netpoll_rx_disable(dev);
 
 	list_add(&dev->unreg_list, &single);
 	retval = __dev_close_many(&single);
@@ -1353,14 +1349,11 @@ static int dev_close_many(struct list_head *head)
  */
 int dev_close(struct net_device *dev)
 {
-	int ret = 0;
 	if (dev->flags & IFF_UP) {
 		LIST_HEAD(single);
 
 		/* Block netpoll rx while the interface is going down */
-		ret = netpoll_rx_disable(dev);
-		if (ret)
-			return ret;
+		netpoll_rx_disable(dev);
 
 		list_add(&dev->unreg_list, &single);
 		dev_close_many(&single);
@@ -1368,7 +1361,7 @@ int dev_close(struct net_device *dev)
 
 		netpoll_rx_enable(dev);
 	}
-	return ret;
+	return 0;
 }
 EXPORT_SYMBOL(dev_close);
 
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index cec074b..37deedd 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -247,7 +247,7 @@ static void netpoll_poll_dev(struct net_device *dev)
 	zap_completion_queue();
 }
 
-int netpoll_rx_disable(struct net_device *dev)
+void netpoll_rx_disable(struct net_device *dev)
 {
 	struct netpoll_info *ni;
 	int idx;
@@ -257,7 +257,6 @@ int netpoll_rx_disable(struct net_device *dev)
 	if (ni)
 		down(&ni->dev_lock);
 	srcu_read_unlock(&netpoll_srcu, idx);
-	return 0;
 }
 EXPORT_SYMBOL(netpoll_rx_disable);
 
-- 
1.8.0
