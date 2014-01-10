From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] bridge: move br_net_exit() to br.c
Date: Fri, 10 Jan 2014 13:58:47 -0800
Message-ID: <1389391127-3881-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:37156 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751986AbaAJV67 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 16:58:59 -0500
Received: by mail-pa0-f47.google.com with SMTP id kq14so5281117pab.34
        for <netdev@vger.kernel.org>; Fri, 10 Jan 2014 13:58:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

And it can become static.

Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

---
diff --git a/net/bridge/br.c b/net/bridge/br.c
index ba780cc..19311aa 100644
--- a/net/bridge/br.c
+++ b/net/bridge/br.c
@@ -22,14 +22,29 @@
 
 #include "br_private.h"
 
-static const struct stp_proto br_stp_proto = {
-	.rcv	= br_stp_rcv,
-};
+static void __net_exit br_net_exit(struct net *net)
+{
+	struct net_device *dev;
+	LIST_HEAD(list);
+
+	rtnl_lock();
+	for_each_netdev(net, dev)
+		if (dev->priv_flags & IFF_EBRIDGE)
+			br_dev_delete(dev, &list);
+
+	unregister_netdevice_many(&list);
+	rtnl_unlock();
+
+}
 
 static struct pernet_operations br_net_ops = {
 	.exit	= br_net_exit,
 };
 
+static const struct stp_proto br_stp_proto = {
+	.rcv	= br_stp_rcv,
+};
+
 static int __init br_init(void)
 {
 	int err;
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 1f6bd1e..cffe1d6 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -455,18 +455,3 @@ int br_del_if(struct net_bridge *br, struct net_device *dev)
 
 	return 0;
 }
-
-void __net_exit br_net_exit(struct net *net)
-{
-	struct net_device *dev;
-	LIST_HEAD(list);
-
-	rtnl_lock();
-	for_each_netdev(net, dev)
-		if (dev->priv_flags & IFF_EBRIDGE)
-			br_dev_delete(dev, &list);
-
-	unregister_netdevice_many(&list);
-	rtnl_unlock();
-
-}
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 3733f15..fcd1233 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -407,7 +407,6 @@ void br_flood_forward(struct net_bridge *br, struct sk_buff *skb,
 void br_port_carrier_check(struct net_bridge_port *p);
 int br_add_bridge(struct net *net, const char *name);
 int br_del_bridge(struct net *net, const char *name);
-void br_net_exit(struct net *net);
 int br_add_if(struct net_bridge *br, struct net_device *dev);
 int br_del_if(struct net_bridge *br, struct net_device *dev);
 int br_min_mtu(const struct net_bridge *br);
