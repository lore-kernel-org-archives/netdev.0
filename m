From: Weiping Pan <panweiping3@gmail.com>
Subject: [PATCH net 2/2] net: make some functions return void
Date: Sun, 15 Jun 2014 18:05:10 +0800
Message-ID: <f5dd6bb35ca9e4d5a7e6069f7afa6ab3cfbd27af.1402826534.git.panweiping3@gmail.com>
References: <cover.1402826534.git.panweiping3@gmail.com>
Cc: davem@davemloft.net, edumazet@google.com,
	Weiping Pan <panweiping3@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:47102 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750995AbaFOKGD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jun 2014 06:06:03 -0400
Received: by mail-pb0-f47.google.com with SMTP id up15so494819pbc.34
        for <netdev@vger.kernel.org>; Sun, 15 Jun 2014 03:06:02 -0700 (PDT)
In-Reply-To: <cover.1402826534.git.panweiping3@gmail.com>
In-Reply-To: <cover.1402826534.git.panweiping3@gmail.com>
References: <cover.1402826534.git.panweiping3@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dev_close_many(), __dev_close_many() and __dev_close() do not need to return a
int, so make them return void, and modify __dev_change_flags() accordingly.

Signed-off-by: Weiping Pan <panweiping3@gmail.com>
---
 net/core/dev.c | 20 ++++++++------------
 1 file changed, 8 insertions(+), 12 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 002678f..9279d68 100644
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
 	if ((old_flags ^ flags) & IFF_UP) {	/* Bit is different  ? */
-		ret = ((old_flags & IFF_UP) ? __dev_close : __dev_open)(dev);
+		if (old_flags & IFF_UP)
+			__dev_close(dev);
+		else
+			ret = __dev_open(dev);
 	}
 
 	if ((flags ^ dev->gflags) & IFF_PROMISC) {
-- 
1.9.0
