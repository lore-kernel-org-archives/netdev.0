From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 5/6] netpoll: Rename netpoll_rx_enable/disable to netpoll_poll_disable/enable
Date: Mon, 17 Mar 2014 23:27:19 -0700
Message-ID: <87lhw8f2d4.fsf_-_@xmission.com>
References: <20140314.225923.61318448733570839.davem@davemloft.net>
	<87k3bwqgf7.fsf@xmission.com> <877g7wqg8e.fsf_-_@xmission.com>
	<20140317.154916.2276987764507311378.davem@davemloft.net>
	<87iorcgh5d.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: stephen@networkplumber.org, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:48240 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751787AbaCRG1Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 02:27:25 -0400
In-Reply-To: <87iorcgh5d.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Mon, 17 Mar 2014 23:22:38 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The netpoll_rx_enable and netpoll_rx_disable functions have always
controlled polling the network drivers transmit and receive queues.

Rename them to netpoll_poll_enable and netpoll_poll_disable to make
their functionality clear.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/linux/netpoll.h |    8 ++++----
 net/core/dev.c          |    8 ++++----
 net/core/netpoll.c      |    8 ++++----
 3 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
index 893b9e66060e..b25ee9ffdbe6 100644
--- a/include/linux/netpoll.h
+++ b/include/linux/netpoll.h
@@ -47,11 +47,11 @@ struct netpoll_info {
 };
 
 #ifdef CONFIG_NETPOLL
-extern void netpoll_rx_disable(struct net_device *dev);
-extern void netpoll_rx_enable(struct net_device *dev);
+extern void netpoll_poll_disable(struct net_device *dev);
+extern void netpoll_poll_enable(struct net_device *dev);
 #else
-static inline void netpoll_rx_disable(struct net_device *dev) { return; }
-static inline void netpoll_rx_enable(struct net_device *dev) { return; }
+static inline void netpoll_poll_disable(struct net_device *dev) { return; }
+static inline void netpoll_poll_enable(struct net_device *dev) { return; }
 #endif
 
 void netpoll_send_udp(struct netpoll *np, const char *msg, int len);
diff --git a/net/core/dev.c b/net/core/dev.c
index f660448d992d..8b3ea4058a5e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1245,7 +1245,7 @@ static int __dev_open(struct net_device *dev)
 	 * If we don't do this there is a chance ndo_poll_controller
 	 * or ndo_poll may be running while we open the device
 	 */
-	netpoll_rx_disable(dev);
+	netpoll_poll_disable(dev);
 
 	ret = call_netdevice_notifiers(NETDEV_PRE_UP, dev);
 	ret = notifier_to_errno(ret);
@@ -1260,7 +1260,7 @@ static int __dev_open(struct net_device *dev)
 	if (!ret && ops->ndo_open)
 		ret = ops->ndo_open(dev);
 
-	netpoll_rx_enable(dev);
+	netpoll_poll_enable(dev);
 
 	if (ret)
 		clear_bit(__LINK_STATE_START, &dev->state);
@@ -1314,7 +1314,7 @@ static int __dev_close_many(struct list_head *head)
 
 	list_for_each_entry(dev, head, close_list) {
 		/* Temporarily disable netpoll until the interface is down */
-		netpoll_rx_disable(dev);
+		netpoll_poll_disable(dev);
 
 		call_netdevice_notifiers(NETDEV_GOING_DOWN, dev);
 
@@ -1346,7 +1346,7 @@ static int __dev_close_many(struct list_head *head)
 
 		dev->flags &= ~IFF_UP;
 		net_dmaengine_put();
-		netpoll_rx_enable(dev);
+		netpoll_poll_enable(dev);
 	}
 
 	return 0;
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index a9abb195a2c3..dec929b71348 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -214,7 +214,7 @@ static void netpoll_poll_dev(struct net_device *dev)
 	zap_completion_queue();
 }
 
-void netpoll_rx_disable(struct net_device *dev)
+void netpoll_poll_disable(struct net_device *dev)
 {
 	struct netpoll_info *ni;
 	int idx;
@@ -225,9 +225,9 @@ void netpoll_rx_disable(struct net_device *dev)
 		down(&ni->dev_lock);
 	srcu_read_unlock(&netpoll_srcu, idx);
 }
-EXPORT_SYMBOL(netpoll_rx_disable);
+EXPORT_SYMBOL(netpoll_poll_disable);
 
-void netpoll_rx_enable(struct net_device *dev)
+void netpoll_poll_enable(struct net_device *dev)
 {
 	struct netpoll_info *ni;
 	rcu_read_lock();
@@ -236,7 +236,7 @@ void netpoll_rx_enable(struct net_device *dev)
 		up(&ni->dev_lock);
 	rcu_read_unlock();
 }
-EXPORT_SYMBOL(netpoll_rx_enable);
+EXPORT_SYMBOL(netpoll_poll_enable);
 
 static void refill_skbs(void)
 {
-- 
1.7.5.4
