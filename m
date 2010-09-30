From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: PATCH net-next 1/2] ipv4: introduce __ip_dev_find()
Date: Thu, 30 Sep 2010 15:31:56 +0200
Message-ID: <1285853516.2615.515.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:55533 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755395Ab0I3NcE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Sep 2010 09:32:04 -0400
Received: by ewy23 with SMTP id 23so706321ewy.19
        for <netdev@vger.kernel.org>; Thu, 30 Sep 2010 06:32:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip_dev_find(net, addr) finds a device given an IPv4 source address and
takes a reference on it.

Introduce __ip_dev_find(), taking a third argument, to optionally take
the device reference. Callers not asking the reference to be taken
should be in an rcu_read_lock() protected section.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/inetdevice.h |    7 ++++++-
 net/ipv4/fib_frontend.c    |   32 +++++++++++++++++++-------------
 2 files changed, 25 insertions(+), 14 deletions(-)

diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index 1ec09bb..ccd5b07 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -159,7 +159,12 @@ struct in_ifaddr {
 extern int register_inetaddr_notifier(struct notifier_block *nb);
 extern int unregister_inetaddr_notifier(struct notifier_block *nb);
 
-extern struct net_device *ip_dev_find(struct net *net, __be32 addr);
+extern struct net_device *__ip_dev_find(struct net *net, __be32 addr, bool devref);
+static inline struct net_device *ip_dev_find(struct net *net, __be32 addr)
+{
+	return __ip_dev_find(net, addr, true);
+}
+
 extern int		inet_addr_onlink(struct in_device *in_dev, __be32 a, __be32 b);
 extern int		devinet_ioctl(struct net *net, unsigned int cmd, void __user *);
 extern void		devinet_init(void);
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 981f3c5..4a69a95 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -147,34 +147,40 @@ static void fib_flush(struct net *net)
 		rt_cache_flush(net, -1);
 }
 
-/*
- *	Find the first device with a given source address.
+/**
+ * __ip_dev_find - find the first device with a given source address.
+ * @net: the net namespace
+ * @addr: the source address
+ * @devref: if true, take a reference on the found device
+ *
+ * If a caller uses devref=false, it should be protected by RCU
  */
-
-struct net_device * ip_dev_find(struct net *net, __be32 addr)
+struct net_device *__ip_dev_find(struct net *net, __be32 addr, bool devref)
 {
-	struct flowi fl = { .nl_u = { .ip4_u = { .daddr = addr } },
-			    .flags = FLOWI_FLAG_MATCH_ANY_IIF };
-	struct fib_result res;
+	struct flowi fl = {
+		.nl_u = {
+			.ip4_u = {
+				.daddr = addr
+			}
+		},
+		.flags = FLOWI_FLAG_MATCH_ANY_IIF
+	};
+	struct fib_result res = { 0 };
 	struct net_device *dev = NULL;
 
-#ifdef CONFIG_IP_MULTIPLE_TABLES
-	res.r = NULL;
-#endif
-
 	if (fib_lookup(net, &fl, &res))
 		return NULL;
 	if (res.type != RTN_LOCAL)
 		goto out;
 	dev = FIB_RES_DEV(res);
 
-	if (dev)
+	if (dev && devref)
 		dev_hold(dev);
 out:
 	fib_res_put(&res);
 	return dev;
 }
-EXPORT_SYMBOL(ip_dev_find);
+EXPORT_SYMBOL(__ip_dev_find);
 
 /*
  * Find address type as if only "dev" was present in the system. If


