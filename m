From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next RFC v1 20/27] ipv6: move ipv6_get_ifaddr to vmlinux in case ipv6 is build as module
Date: Mon, 13 Mar 2017 00:01:44 +0100
Message-ID: <20170312230151.5185-21-hannes@stressinduktion.org>
References: <20170312230151.5185-1-hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:40330 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S935628AbdCLXCO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Mar 2017 19:02:14 -0400
Received: from compute7.internal (compute7.nyi.internal [10.202.2.47])
        by mailout.nyi.internal (Postfix) with ESMTP id A7638207B7
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:02:12 -0400 (EDT)
Received: from m.localhost.localhost (unknown [213.55.211.72])
        by mail.messagingengine.com (Postfix) with ESMTPA id E0C89240CF
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:02:11 -0400 (EDT)
In-Reply-To: <20170312230151.5185-1-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

inet6_hashtables is build into vmlinux in case ipv6 gets build as a
module. As the inet6_hashtables functions depend on ipv6_get_ifaddr
via ipv6_get_ifaddr_afnetns_rcu, we need to make the lookup function
always available.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/addrconf.h      |  6 ++++++
 net/ipv6/addrconf.c         | 35 +----------------------------------
 net/ipv6/inet6_hashtables.c | 39 +++++++++++++++++++++++++++++++++++++++
 3 files changed, 46 insertions(+), 34 deletions(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 644fa68bb4ddef..dcb17f88fd2875 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -78,6 +78,7 @@ bool ipv6_chk_custom_prefix(const struct in6_addr *addr,
 
 int ipv6_chk_prefix(const struct in6_addr *addr, struct net_device *dev);
 
+extern struct hlist_head inet6_addr_lst[IN6_ADDR_HSIZE];
 struct inet6_ifaddr *ipv6_get_ifaddr(struct net *net,
 				     const struct in6_addr *addr,
 				     struct net_device *dev, int strict);
@@ -416,6 +417,11 @@ static inline bool ipv6_addr_is_solict_mult(const struct in6_addr *addr)
 #endif
 }
 
+static inline u32 inet6_addr_hash(const struct in6_addr *addr)
+{
+	return hash_32(ipv6_addr_hash(addr), IN6_ADDR_HSIZE_SHIFT);
+}
+
 #ifdef CONFIG_PROC_FS
 int if6_proc_init(void);
 void if6_proc_exit(void);
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 2e546584695118..319f83a7d29dd5 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -160,7 +160,6 @@ static int ipv6_generate_stable_address(struct in6_addr *addr,
 /*
  *	Configured unicast address hash table
  */
-static struct hlist_head inet6_addr_lst[IN6_ADDR_HSIZE];
 static DEFINE_SPINLOCK(addrconf_hash_lock);
 
 static void addrconf_verify(void);
@@ -936,11 +935,6 @@ ipv6_link_dev_addr(struct inet6_dev *idev, struct inet6_ifaddr *ifp)
 	list_add_tail(&ifp->if_list, p);
 }
 
-static u32 inet6_addr_hash(const struct in6_addr *addr)
-{
-	return hash_32(ipv6_addr_hash(addr), IN6_ADDR_HSIZE_SHIFT);
-}
-
 /* On success it returns ifp with increased reference count */
 
 static struct inet6_ifaddr *
@@ -1888,30 +1882,6 @@ int ipv6_chk_prefix(const struct in6_addr *addr, struct net_device *dev)
 }
 EXPORT_SYMBOL(ipv6_chk_prefix);
 
-struct inet6_ifaddr *ipv6_get_ifaddr(struct net *net, const struct in6_addr *addr,
-				     struct net_device *dev, int strict)
-{
-	struct inet6_ifaddr *ifp, *result = NULL;
-	unsigned int hash = inet6_addr_hash(addr);
-
-	rcu_read_lock_bh();
-	hlist_for_each_entry_rcu_bh(ifp, &inet6_addr_lst[hash], addr_lst) {
-		if (!net_eq(dev_net(ifp->idev->dev), net))
-			continue;
-		if (ipv6_addr_equal(&ifp->addr, addr)) {
-			if (!dev || ifp->idev->dev == dev ||
-			    !(ifp->scope&(IFA_LINK|IFA_HOST) || strict)) {
-				result = ifp;
-				in6_ifa_hold(ifp);
-				break;
-			}
-		}
-	}
-	rcu_read_unlock_bh();
-
-	return result;
-}
-
 /* Gets referenced address, destroys ifaddr */
 
 static void addrconf_dad_stop(struct inet6_ifaddr *ifp, int dad_failed)
@@ -6518,7 +6488,7 @@ static struct rtnl_af_ops inet6_ops __read_mostly = {
 int __init addrconf_init(void)
 {
 	struct inet6_dev *idev;
-	int i, err;
+	int err;
 
 	err = ipv6_addr_label_init();
 	if (err < 0) {
@@ -6563,9 +6533,6 @@ int __init addrconf_init(void)
 		goto errlo;
 	}
 
-	for (i = 0; i < IN6_ADDR_HSIZE; i++)
-		INIT_HLIST_HEAD(&inet6_addr_lst[i]);
-
 	register_netdevice_notifier(&ipv6_dev_notf);
 
 	addrconf_verify();
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index d0900918a19e5e..8570e0e3016b65 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -25,6 +25,9 @@
 #include <net/ip.h>
 #include <net/sock_reuseport.h>
 
+struct hlist_head inet6_addr_lst[IN6_ADDR_HSIZE];
+EXPORT_SYMBOL(inet6_addr_lst);
+
 u32 inet6_ehashfn(const struct net *net,
 		  const struct in6_addr *laddr, const u16 lport,
 		  const struct in6_addr *faddr, const __be16 fport)
@@ -44,6 +47,32 @@ u32 inet6_ehashfn(const struct net *net,
 			       inet6_ehash_secret + net_hash_mix(net));
 }
 
+struct inet6_ifaddr *ipv6_get_ifaddr(struct net *net,
+				     const struct in6_addr *addr,
+				     struct net_device *dev, int strict)
+{
+	struct inet6_ifaddr *ifp, *result = NULL;
+	unsigned int hash = inet6_addr_hash(addr);
+
+	rcu_read_lock_bh();
+	hlist_for_each_entry_rcu_bh(ifp, &inet6_addr_lst[hash], addr_lst) {
+		if (!net_eq(dev_net(ifp->idev->dev), net))
+			continue;
+		if (ipv6_addr_equal(&ifp->addr, addr)) {
+			if (!dev || ifp->idev->dev == dev ||
+			    !(ifp->scope & (IFA_LINK | IFA_HOST) || strict)) {
+				result = ifp;
+				in6_ifa_hold(ifp);
+				break;
+			}
+		}
+	}
+	rcu_read_unlock_bh();
+
+	return result;
+}
+EXPORT_SYMBOL(ipv6_get_ifaddr);
+
 /*
  * Sockets in TCP_CLOSE state are _always_ taken out of the hash, so
  * we need not check it for TCP lookups anymore, thanks Alexey. -DaveM
@@ -275,3 +304,13 @@ int inet6_hash(struct sock *sk)
 	return err;
 }
 EXPORT_SYMBOL_GPL(inet6_hash);
+
+int __init inet6_hashtables_init(void)
+{
+	int i;
+
+	for (i = 0; i < IN6_ADDR_HSIZE; i++)
+		INIT_HLIST_HEAD(&inet6_addr_lst[i]);
+	return 0;
+}
+early_initcall(inet6_hashtables_init);
-- 
2.9.3
