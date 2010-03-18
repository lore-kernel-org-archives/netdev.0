From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: dev_getfirstbyhwtype() optimization
Date: Thu, 18 Mar 2010 22:27:25 +0100
Message-ID: <1268947645.2894.166.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:42486 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751027Ab0CRV1a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Mar 2010 17:27:30 -0400
Received: by bwz25 with SMTP id 25so1175445bwz.28
        for <netdev@vger.kernel.org>; Thu, 18 Mar 2010 14:27:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use RCU to avoid RTNL use in dev_getfirstbyhwtype()

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/core/dev.c b/net/core/dev.c
index 17b1686..0f2e9fc 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -772,14 +772,17 @@ EXPORT_SYMBOL(__dev_getfirstbyhwtype);
 
 struct net_device *dev_getfirstbyhwtype(struct net *net, unsigned short type)
 {
-	struct net_device *dev;
+	struct net_device *dev, *ret = NULL;
 
-	rtnl_lock();
-	dev = __dev_getfirstbyhwtype(net, type);
-	if (dev)
-		dev_hold(dev);
-	rtnl_unlock();
-	return dev;
+	rcu_read_lock();
+	for_each_netdev_rcu(net, dev)
+		if (dev->type == type) {
+			dev_hold(dev);
+			ret = dev;
+			break;
+		}
+	rcu_read_unlock();
+	return ret;
 }
 EXPORT_SYMBOL(dev_getfirstbyhwtype);
 


