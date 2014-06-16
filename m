From: Weiping Pan <panweiping3@gmail.com>
Subject: [PATCH net 2/2] net: make some functions return void
Date: Mon, 16 Jun 2014 21:57:23 +0800
Message-ID: <611ae0d4d819f57c4d0c67afa8ed58b16c7d102a.1402926490.git.panweiping3@gmail.com>
References: <cover.1402926490.git.panweiping3@gmail.com>
Cc: davem@davemloft.net, Weiping Pan <panweiping3@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:55304 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753625AbaFPN6X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2014 09:58:23 -0400
Received: by mail-pd0-f173.google.com with SMTP id r10so4431209pdi.18
        for <netdev@vger.kernel.org>; Mon, 16 Jun 2014 06:58:22 -0700 (PDT)
In-Reply-To: <cover.1402926490.git.panweiping3@gmail.com>
In-Reply-To: <cover.1402926490.git.panweiping3@gmail.com>
References: <cover.1402926490.git.panweiping3@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dev_close_many(), __dev_close_many() and __dev_close() do not need to return a
int, so make them return void, and modify __dev_change_flags() accordingly.

Signed-off-by: Weiping Pan <panweiping3@gmail.com>
---
 net/core/dev.c | 20 ++++++++------------
 1 file changed, 8 insertions(+), 12 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index a04b12f..44d4748 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1305,7 +1305,7 @@ int dev_open(struct net_device *dev)
 }
 EXPORT_SYMBOL(dev_open);
 
-static int __dev_close_many(struct list_head *head)
+static void __dev_close_many(struct list_head *head)
 {
 	struct net_device *dev;
 
@@ -1348,23 +1348,18 @@ static int __dev_close_many(struct list_head *head)
 		net_dmaengine_put();
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
 
-static int dev_close_many(struct list_head *head)
+static void dev_close_many(struct list_head *head)
 {
 	struct net_device *dev, *tmp;
 
@@ -1380,8 +1375,6 @@ static int dev_close_many(struct list_head *head)
 		call_netdevice_notifiers(NETDEV_DOWN, dev);
 		list_del_init(&dev->close_list);
 	}
-
-	return 0;
 }
 
 /**
@@ -5433,7 +5426,10 @@ int __dev_change_flags(struct net_device *dev, unsigned int flags)
 
 	ret = 0;
 	if ((old_flags ^ flags) & IFF_UP)
-		ret = ((old_flags & IFF_UP) ? __dev_close : __dev_open)(dev);
+		if (old_flags & IFF_UP)
+			__dev_close(dev);
+		else
+			ret = __dev_open(dev);
 
 	if ((flags ^ dev->gflags) & IFF_PROMISC) {
 		int inc = (flags & IFF_PROMISC) ? 1 : -1;
-- 
1.9.0
