From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next] ipv6: statically link register_inet6addr_notifier()
Date: Sun, 14 Apr 2013 23:18:43 +0800
Message-ID: <1365952723-23295-1-git-send-email-amwang@redhat.com>
Cc: Tomas Melin <tomas.melin@iki.fi>,
	"David S. Miller" <davem@davemloft.net>,
	YOSHIFUJI Hidaki <yoshfuji@linux-ipv6.org>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30335 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751880Ab3DNPTG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Apr 2013 11:19:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

Tomas reported the following build error:

net/built-in.o: In function `ieee80211_unregister_hw':
(.text+0x10f0e1): undefined reference to `unregister_inet6addr_notifier'
net/built-in.o: In function `ieee80211_register_hw':
(.text+0x10f610): undefined reference to `register_inet6addr_notifier'
make: *** [vmlinux] Error 1

when built IPv6 as a module.

So we have to statically link these symbols.

Reported-by: Tomas Melin <tomas.melin@iki.fi>
Cc: Tomas Melin <tomas.melin@iki.fi>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: YOSHIFUJI Hidaki <yoshfuji@linux-ipv6.org>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 40be2a0..84a6440 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -199,6 +199,7 @@ extern bool ipv6_chk_acast_addr(struct net *net, struct net_device *dev,
 /* Device notifier */
 extern int register_inet6addr_notifier(struct notifier_block *nb);
 extern int unregister_inet6addr_notifier(struct notifier_block *nb);
+extern int inet6addr_notifier_call_chain(unsigned long val, void *v);
 
 extern void inet6_netconf_notify_devconf(struct net *net, int type, int ifindex,
 					 struct ipv6_devconf *devconf);
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 28b61e8..d1ab6ab 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -169,8 +169,6 @@ static void inet6_prefix_notify(int event, struct inet6_dev *idev,
 static bool ipv6_chk_same_addr(struct net *net, const struct in6_addr *addr,
 			       struct net_device *dev);
 
-static ATOMIC_NOTIFIER_HEAD(inet6addr_chain);
-
 static struct ipv6_devconf ipv6_devconf __read_mostly = {
 	.forwarding		= 0,
 	.hop_limit		= IPV6_DEFAULT_HOPLIMIT,
@@ -910,7 +908,7 @@ out2:
 	rcu_read_unlock_bh();
 
 	if (likely(err == 0))
-		atomic_notifier_call_chain(&inet6addr_chain, NETDEV_UP, ifa);
+		inet6addr_notifier_call_chain(NETDEV_UP, ifa);
 	else {
 		kfree(ifa);
 		ifa = ERR_PTR(err);
@@ -1000,7 +998,7 @@ static void ipv6_del_addr(struct inet6_ifaddr *ifp)
 
 	ipv6_ifa_notify(RTM_DELADDR, ifp);
 
-	atomic_notifier_call_chain(&inet6addr_chain, NETDEV_DOWN, ifp);
+	inet6addr_notifier_call_chain(NETDEV_DOWN, ifp);
 
 	/*
 	 * Purge or update corresponding prefix
@@ -3087,7 +3085,7 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 
 		if (state != INET6_IFADDR_STATE_DEAD) {
 			__ipv6_ifa_notify(RTM_DELADDR, ifa);
-			atomic_notifier_call_chain(&inet6addr_chain, NETDEV_DOWN, ifa);
+			inet6addr_notifier_call_chain(NETDEV_DOWN, ifa);
 		}
 		in6_ifa_put(ifa);
 
@@ -5054,22 +5052,6 @@ static struct pernet_operations addrconf_ops = {
 	.exit = addrconf_exit_net,
 };
 
-/*
- *      Device notifier
- */
-
-int register_inet6addr_notifier(struct notifier_block *nb)
-{
-	return atomic_notifier_chain_register(&inet6addr_chain, nb);
-}
-EXPORT_SYMBOL(register_inet6addr_notifier);
-
-int unregister_inet6addr_notifier(struct notifier_block *nb)
-{
-	return atomic_notifier_chain_unregister(&inet6addr_chain, nb);
-}
-EXPORT_SYMBOL(unregister_inet6addr_notifier);
-
 static struct rtnl_af_ops inet6_ops = {
 	.family		  = AF_INET6,
 	.fill_link_af	  = inet6_fill_link_af,
diff --git a/net/ipv6/addrconf_core.c b/net/ipv6/addrconf_core.c
index d051e5f..7210456 100644
--- a/net/ipv6/addrconf_core.c
+++ b/net/ipv6/addrconf_core.c
@@ -78,3 +78,22 @@ int __ipv6_addr_type(const struct in6_addr *addr)
 }
 EXPORT_SYMBOL(__ipv6_addr_type);
 
+static ATOMIC_NOTIFIER_HEAD(inet6addr_chain);
+
+int register_inet6addr_notifier(struct notifier_block *nb)
+{
+	return atomic_notifier_chain_register(&inet6addr_chain, nb);
+}
+EXPORT_SYMBOL(register_inet6addr_notifier);
+
+int unregister_inet6addr_notifier(struct notifier_block *nb)
+{
+	return atomic_notifier_chain_unregister(&inet6addr_chain, nb);
+}
+EXPORT_SYMBOL(unregister_inet6addr_notifier);
+
+int inet6addr_notifier_call_chain(unsigned long val, void *v)
+{
+	return atomic_notifier_call_chain(&inet6addr_chain, val, v);
+}
+EXPORT_SYMBOL(inet6addr_notifier_call_chain);
