From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next RFC v1 07/27] ipv4: introduce ifa_find_rcu
Date: Mon, 13 Mar 2017 00:01:31 +0100
Message-ID: <20170312230151.5185-8-hannes@stressinduktion.org>
References: <20170312230151.5185-1-hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:45285 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S935632AbdCLXCO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Mar 2017 19:02:14 -0400
Received: from compute7.internal (compute7.nyi.internal [10.202.2.47])
        by mailout.nyi.internal (Postfix) with ESMTP id AB33F20760
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:01:58 -0400 (EDT)
Received: from m.localhost.localhost (unknown [213.55.211.72])
        by mail.messagingengine.com (Postfix) with ESMTPA id 1769A240CF
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:01:57 -0400 (EDT)
In-Reply-To: <20170312230151.5185-1-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/linux/inetdevice.h |  1 +
 net/ipv4/devinet.c         | 29 +++++++++++++++++------------
 2 files changed, 18 insertions(+), 12 deletions(-)

diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index d5ac959e90baa1..eb1b662f62626f 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -159,6 +159,7 @@ int unregister_inetaddr_notifier(struct notifier_block *nb);
 void inet_netconf_notify_devconf(struct net *net, int type, int ifindex,
 				 struct ipv4_devconf *devconf);
 
+struct in_ifaddr *ifa_find_rcu(struct net *net, __be32 addr);
 struct net_device *__ip_dev_find(struct net *net, __be32 addr, bool devref);
 static inline struct net_device *ip_dev_find(struct net *net, __be32 addr)
 {
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index d4a38b6e9adb79..cc15afefa1df0a 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -128,6 +128,20 @@ static void inet_hash_remove(struct in_ifaddr *ifa)
 	hlist_del_init_rcu(&ifa->hash);
 }
 
+struct in_ifaddr *ifa_find_rcu(struct net *net, __be32 addr)
+{
+	u32 hash = inet_addr_hash(net, addr);
+	struct in_ifaddr *ifa;
+
+	hlist_for_each_entry_rcu(ifa, &inet_addr_lst[hash], hash) {
+		if (ifa->ifa_local == addr &&
+		    net_eq(dev_net(ifa->ifa_dev->dev), net))
+			return ifa;
+	}
+
+	return NULL;
+}
+
 /**
  * __ip_dev_find - find the first device with a given source address.
  * @net: the net namespace
@@ -138,21 +152,12 @@ static void inet_hash_remove(struct in_ifaddr *ifa)
  */
 struct net_device *__ip_dev_find(struct net *net, __be32 addr, bool devref)
 {
-	u32 hash = inet_addr_hash(net, addr);
-	struct net_device *result = NULL;
+	struct net_device *result;
 	struct in_ifaddr *ifa;
 
 	rcu_read_lock();
-	hlist_for_each_entry_rcu(ifa, &inet_addr_lst[hash], hash) {
-		if (ifa->ifa_local == addr) {
-			struct net_device *dev = ifa->ifa_dev->dev;
-
-			if (!net_eq(dev_net(dev), net))
-				continue;
-			result = dev;
-			break;
-		}
-	}
+	ifa = ifa_find_rcu(net, addr);
+	result = ifa ? ifa->ifa_dev->dev : NULL;
 	if (!result) {
 		struct flowi4 fl4 = { .daddr = addr };
 		struct fib_result res = { 0 };
-- 
2.9.3
