From: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Subject: [PATCH net-next 3/3] net: make dev_close and related functions void
Date: Tue, 18 Jul 2017 15:59:27 -0700
Message-ID: <20170718225927.15944-4-sthemmin@microsoft.com>
References: <20170718225927.15944-1-sthemmin@microsoft.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Stephen Hemminger <sthemmin-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>
To: yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org, gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org,
        johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170718225927.15944-1-sthemmin-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

There is no useful return value from dev_close. All paths return 0.
Change dev_close and helper functions to void.

Signed-off-by: Stephen Hemminger <sthemmin-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>
---
 include/linux/netdevice.h |  4 ++--
 net/core/dev.c            | 26 +++++++++++---------------
 2 files changed, 13 insertions(+), 17 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c60351b84323..614642eb7eb7 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2432,8 +2432,8 @@ struct net_device *dev_get_by_name_rcu(struct net *net, const char *name);
 struct net_device *__dev_get_by_name(struct net *net, const char *name);
 int dev_alloc_name(struct net_device *dev, const char *name);
 int dev_open(struct net_device *dev);
-int dev_close(struct net_device *dev);
-int dev_close_many(struct list_head *head, bool unlink);
+void dev_close(struct net_device *dev);
+void dev_close_many(struct list_head *head, bool unlink);
 void dev_disable_lro(struct net_device *dev);
 int dev_loopback_xmit(struct net *net, struct sock *sk, struct sk_buff *newskb);
 int dev_queue_xmit(struct sk_buff *skb);
diff --git a/net/core/dev.c b/net/core/dev.c
index 467420eda02e..d1b9c9b6c970 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1413,7 +1413,7 @@ int dev_open(struct net_device *dev)
 }
 EXPORT_SYMBOL(dev_open);
 
-static int __dev_close_many(struct list_head *head)
+static void __dev_close_many(struct list_head *head)
 {
 	struct net_device *dev;
 
@@ -1455,23 +1455,18 @@ static int __dev_close_many(struct list_head *head)
 		dev->flags &= ~IFF_UP;
 		netpoll_poll_enable(dev);
 	}
-
-	return 0;
 }
 
-static int __dev_close(struct net_device *dev)
+static void __dev_close(struct net_device *dev)
 {
-	int retval;
 	LIST_HEAD(single);
 
 	list_add(&dev->close_list, &single);
-	retval = __dev_close_many(&single);
+	__dev_close_many(&single);
 	list_del(&single);
-
-	return retval;
 }
 
-int dev_close_many(struct list_head *head, bool unlink)
+void dev_close_many(struct list_head *head, bool unlink)
 {
 	struct net_device *dev, *tmp;
 
@@ -1488,8 +1483,6 @@ int dev_close_many(struct list_head *head, bool unlink)
 		if (unlink)
 			list_del_init(&dev->close_list);
 	}
-
-	return 0;
 }
 EXPORT_SYMBOL(dev_close_many);
 
@@ -1502,7 +1495,7 @@ EXPORT_SYMBOL(dev_close_many);
  *	is then deactivated and finally a %NETDEV_DOWN is sent to the notifier
  *	chain.
  */
-int dev_close(struct net_device *dev)
+void dev_close(struct net_device *dev)
 {
 	if (dev->flags & IFF_UP) {
 		LIST_HEAD(single);
@@ -1511,7 +1504,6 @@ int dev_close(struct net_device *dev)
 		dev_close_many(&single, true);
 		list_del(&single);
 	}
-	return 0;
 }
 EXPORT_SYMBOL(dev_close);
 
@@ -6725,8 +6717,12 @@ int __dev_change_flags(struct net_device *dev, unsigned int flags)
 	 */
 
 	ret = 0;
-	if ((old_flags ^ flags) & IFF_UP)
-		ret = ((old_flags & IFF_UP) ? __dev_close : __dev_open)(dev);
+	if ((old_flags ^ flags) & IFF_UP) {
+		if (old_flags & IFF_UP)
+			__dev_close(dev);
+		else
+			ret = __dev_open(dev);
+	}
 
 	if ((flags ^ dev->gflags) & IFF_PROMISC) {
 		int inc = (flags & IFF_PROMISC) ? 1 : -1;
-- 
2.11.0
