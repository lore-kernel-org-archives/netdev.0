From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] ipv6: addrconf.h cleanups
Date: Tue, 21 Sep 2010 18:57:39 +0200
Message-ID: <1285088259.2617.717.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:35038 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755873Ab0IUQ5o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Sep 2010 12:57:44 -0400
Received: by fxm3 with SMTP id 3so1565792fxm.19
        for <netdev@vger.kernel.org>; Tue, 21 Sep 2010 09:57:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Use rcu_dereference_rtnl() in __in6_dev_get
- kerneldoc for __in6_dev_get() and in6_dev_get()
- Use inline functions instead of macros

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/addrconf.h |   63 ++++++++++++++++++++++++++-------------
 1 file changed, 43 insertions(+), 20 deletions(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 45375b4..39cf213 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -174,20 +174,32 @@ extern int ipv6_chk_acast_addr(struct net *net, struct net_device *dev,
 extern int register_inet6addr_notifier(struct notifier_block *nb);
 extern int unregister_inet6addr_notifier(struct notifier_block *nb);
 
-static inline struct inet6_dev *
-__in6_dev_get(struct net_device *dev)
+/**
+ * __in6_dev_get - get inet6_dev pointer from netdevice
+ * @dev: network device
+ *
+ * Caller must hold rcu_read_lock or RTNL, because this function
+ * does not take a reference on the inet6_dev.
+ */
+static inline struct inet6_dev *__in6_dev_get(const struct net_device *dev)
 {
-	return rcu_dereference_check(dev->ip6_ptr,
-				     rcu_read_lock_held() ||
-				     lockdep_rtnl_is_held());
+	return rcu_dereference_rtnl(dev->ip6_ptr);
 }
 
-static inline struct inet6_dev *
-in6_dev_get(struct net_device *dev)
+/**
+ * in6_dev_get - get inet6_dev pointer from netdevice
+ * @dev: network device
+ *
+ * This version can be used in any context, and takes a reference
+ * on the inet6_dev. Callers must use in6_dev_put() later to
+ * release this reference.
+ */
+static inline struct inet6_dev *in6_dev_get(const struct net_device *dev)
 {
-	struct inet6_dev *idev = NULL;
+	struct inet6_dev *idev;
+
 	rcu_read_lock();
-	idev = __in6_dev_get(dev);
+	idev = rcu_dereference(dev->ip6_ptr);
 	if (idev)
 		atomic_inc(&idev->refcnt);
 	rcu_read_unlock();
@@ -196,16 +208,21 @@ in6_dev_get(struct net_device *dev)
 
 extern void in6_dev_finish_destroy(struct inet6_dev *idev);
 
-static inline void
-in6_dev_put(struct inet6_dev *idev)
+static inline void in6_dev_put(struct inet6_dev *idev)
 {
 	if (atomic_dec_and_test(&idev->refcnt))
 		in6_dev_finish_destroy(idev);
 }
 
-#define __in6_dev_put(idev)  atomic_dec(&(idev)->refcnt)
-#define in6_dev_hold(idev)   atomic_inc(&(idev)->refcnt)
+static inline void __in6_dev_put(struct inet6_dev *idev)
+{
+	atomic_dec(&idev->refcnt);
+}
 
+static inline void in6_dev_hold(struct inet6_dev *idev)
+{
+	atomic_inc(&idev->refcnt);
+}
 
 extern void inet6_ifa_finish_destroy(struct inet6_ifaddr *ifp);
 
@@ -215,9 +232,15 @@ static inline void in6_ifa_put(struct inet6_ifaddr *ifp)
 		inet6_ifa_finish_destroy(ifp);
 }
 
-#define __in6_ifa_put(ifp)	atomic_dec(&(ifp)->refcnt)
-#define in6_ifa_hold(ifp)	atomic_inc(&(ifp)->refcnt)
+static inline void __in6_ifa_put(struct inet6_ifaddr *ifp)
+{
+	atomic_dec(&ifp->refcnt);
+}
 
+static inline void in6_ifa_hold(struct inet6_ifaddr *ifp)
+{
+	atomic_inc(&ifp->refcnt);
+}
 
 
 /*
@@ -240,23 +263,23 @@ static inline int ipv6_addr_is_multicast(const struct in6_addr *addr)
 
 static inline int ipv6_addr_is_ll_all_nodes(const struct in6_addr *addr)
 {
-	return (((addr->s6_addr32[0] ^ htonl(0xff020000)) |
+	return ((addr->s6_addr32[0] ^ htonl(0xff020000)) |
 		addr->s6_addr32[1] | addr->s6_addr32[2] |
-		(addr->s6_addr32[3] ^ htonl(0x00000001))) == 0);
+		(addr->s6_addr32[3] ^ htonl(0x00000001))) == 0;
 }
 
 static inline int ipv6_addr_is_ll_all_routers(const struct in6_addr *addr)
 {
-	return (((addr->s6_addr32[0] ^ htonl(0xff020000)) |
+	return ((addr->s6_addr32[0] ^ htonl(0xff020000)) |
 		addr->s6_addr32[1] | addr->s6_addr32[2] |
-		(addr->s6_addr32[3] ^ htonl(0x00000002))) == 0);
+		(addr->s6_addr32[3] ^ htonl(0x00000002))) == 0;
 }
 
 extern int __ipv6_isatap_ifid(u8 *eui, __be32 addr);
 
 static inline int ipv6_addr_is_isatap(const struct in6_addr *addr)
 {
-	return ((addr->s6_addr32[2] | htonl(0x02000000)) == htonl(0x02005EFE));
+	return (addr->s6_addr32[2] | htonl(0x02000000)) == htonl(0x02005EFE);
 }
 
 #ifdef CONFIG_PROC_FS


