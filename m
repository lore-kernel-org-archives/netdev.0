From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/2] ipv4: Implement __ip_dev_find using new interface
 address hash.
Date: Thu, 17 Feb 2011 20:46:40 -0800 (PST)
Message-ID: <20110217.204640.189718925.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59326
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753419Ab1BREqE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 23:46:04 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id E991124C087
	for <netdev@vger.kernel.org>; Thu, 17 Feb 2011 20:46:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Much quicker than going through the FIB tables.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/devinet.c      |   33 +++++++++++++++++++++++++++++++++
 net/ipv4/fib_frontend.c |   40 ----------------------------------------
 2 files changed, 33 insertions(+), 40 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index c1f2552..1550881 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -124,6 +124,39 @@ static void inet_hash_remove(struct in_ifaddr *ifa)
 	spin_unlock(&inet_addr_hash_lock);
 }
 
+/**
+ * __ip_dev_find - find the first device with a given source address.
+ * @net: the net namespace
+ * @addr: the source address
+ * @devref: if true, take a reference on the found device
+ *
+ * If a caller uses devref=false, it should be protected by RCU, or RTNL
+ */
+struct net_device *__ip_dev_find(struct net *net, __be32 addr, bool devref)
+{
+	unsigned int hash = inet_addr_hash(addr);
+	struct net_device *result = NULL;
+	struct in_ifaddr *ifa;
+	struct hlist_node *node;
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(ifa, node, &inet_addr_lst[hash], hash) {
+		struct net_device *dev = ifa->ifa_dev->dev;
+
+		if (!net_eq(dev_net(dev), net))
+			continue;
+		if (ifa->ifa_address == addr) {
+			result = dev;
+			break;
+		}
+	}
+	if (result && devref)
+		dev_hold(result);
+	rcu_read_unlock();
+	return result;
+}
+EXPORT_SYMBOL(__ip_dev_find);
+
 static void rtmsg_ifa(int event, struct in_ifaddr *, struct nlmsghdr *, u32);
 
 static BLOCKING_NOTIFIER_HEAD(inetaddr_chain);
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 2a49c06..ad0778a 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -132,46 +132,6 @@ static void fib_flush(struct net *net)
 		rt_cache_flush(net, -1);
 }
 
-/**
- * __ip_dev_find - find the first device with a given source address.
- * @net: the net namespace
- * @addr: the source address
- * @devref: if true, take a reference on the found device
- *
- * If a caller uses devref=false, it should be protected by RCU, or RTNL
- */
-struct net_device *__ip_dev_find(struct net *net, __be32 addr, bool devref)
-{
-	struct flowi fl = {
-		.fl4_dst = addr,
-	};
-	struct fib_result res = { 0 };
-	struct net_device *dev = NULL;
-	struct fib_table *local_table;
-
-#ifdef CONFIG_IP_MULTIPLE_TABLES
-	res.r = NULL;
-#endif
-
-	rcu_read_lock();
-	local_table = fib_get_table(net, RT_TABLE_LOCAL);
-	if (!local_table ||
-	    fib_table_lookup(local_table, &fl, &res, FIB_LOOKUP_NOREF)) {
-		rcu_read_unlock();
-		return NULL;
-	}
-	if (res.type != RTN_LOCAL)
-		goto out;
-	dev = FIB_RES_DEV(res);
-
-	if (dev && devref)
-		dev_hold(dev);
-out:
-	rcu_read_unlock();
-	return dev;
-}
-EXPORT_SYMBOL(__ip_dev_find);
-
 /*
  * Find address type as if only "dev" was present in the system. If
  * on_dev is NULL then all interfaces are taken into consideration.
-- 
1.7.4.1

