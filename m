From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next v2 1/8] ipv6: drop useless rcu_read_lock() in anycast
Date: Thu, 11 Sep 2014 15:35:09 -0700
Message-ID: <1410474916-21873-2-git-send-email-xiyou.wangcong@gmail.com>
References: <1410474916-21873-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:38602 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752241AbaIKWfj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2014 18:35:39 -0400
Received: by mail-pd0-f179.google.com with SMTP id g10so15322167pdj.38
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2014 15:35:39 -0700 (PDT)
In-Reply-To: <1410474916-21873-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These code is now protected by rtnl lock, rcu read lock
is useless now.

Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/linux/netdevice.h |  4 ++--
 net/core/dev.c            | 14 ++++++++------
 net/ipv6/anycast.c        | 18 ++++++------------
 3 files changed, 16 insertions(+), 20 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ba72f6b..17e640a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2083,8 +2083,8 @@ void __dev_remove_pack(struct packet_type *pt);
 void dev_add_offload(struct packet_offload *po);
 void dev_remove_offload(struct packet_offload *po);
 
-struct net_device *dev_get_by_flags_rcu(struct net *net, unsigned short flags,
-					unsigned short mask);
+struct net_device *__dev_get_by_flags(struct net *net, unsigned short flags,
+				      unsigned short mask);
 struct net_device *dev_get_by_name(struct net *net, const char *name);
 struct net_device *dev_get_by_name_rcu(struct net *net, const char *name);
 struct net_device *__dev_get_by_name(struct net *net, const char *name);
diff --git a/net/core/dev.c b/net/core/dev.c
index 3c6a967..2595f07 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -897,23 +897,25 @@ struct net_device *dev_getfirstbyhwtype(struct net *net, unsigned short type)
 EXPORT_SYMBOL(dev_getfirstbyhwtype);
 
 /**
- *	dev_get_by_flags_rcu - find any device with given flags
+ *	__dev_get_by_flags - find any device with given flags
  *	@net: the applicable net namespace
  *	@if_flags: IFF_* values
  *	@mask: bitmask of bits in if_flags to check
  *
  *	Search for any interface with the given flags. Returns NULL if a device
  *	is not found or a pointer to the device. Must be called inside
- *	rcu_read_lock(), and result refcount is unchanged.
+ *	rtnl_lock(), and result refcount is unchanged.
  */
 
-struct net_device *dev_get_by_flags_rcu(struct net *net, unsigned short if_flags,
-				    unsigned short mask)
+struct net_device *__dev_get_by_flags(struct net *net, unsigned short if_flags,
+				      unsigned short mask)
 {
 	struct net_device *dev, *ret;
 
+	ASSERT_RTNL();
+
 	ret = NULL;
-	for_each_netdev_rcu(net, dev) {
+	for_each_netdev(net, dev) {
 		if (((dev->flags ^ if_flags) & mask) == 0) {
 			ret = dev;
 			break;
@@ -921,7 +923,7 @@ struct net_device *dev_get_by_flags_rcu(struct net *net, unsigned short if_flags
 	}
 	return ret;
 }
-EXPORT_SYMBOL(dev_get_by_flags_rcu);
+EXPORT_SYMBOL(__dev_get_by_flags);
 
 /**
  *	dev_valid_name - check if name is okay for network device
diff --git a/net/ipv6/anycast.c b/net/ipv6/anycast.c
index ff2de7d..3b0429b 100644
--- a/net/ipv6/anycast.c
+++ b/net/ipv6/anycast.c
@@ -78,7 +78,6 @@ int ipv6_sock_ac_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 	pac->acl_addr = *addr;
 
 	rtnl_lock();
-	rcu_read_lock();
 	if (ifindex == 0) {
 		struct rt6_info *rt;
 
@@ -91,11 +90,11 @@ int ipv6_sock_ac_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 			goto error;
 		} else {
 			/* router, no matching interface: just pick one */
-			dev = dev_get_by_flags_rcu(net, IFF_UP,
-						   IFF_UP | IFF_LOOPBACK);
+			dev = __dev_get_by_flags(net, IFF_UP,
+						 IFF_UP | IFF_LOOPBACK);
 		}
 	} else
-		dev = dev_get_by_index_rcu(net, ifindex);
+		dev = __dev_get_by_index(net, ifindex);
 
 	if (dev == NULL) {
 		err = -ENODEV;
@@ -137,7 +136,6 @@ int ipv6_sock_ac_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 	}
 
 error:
-	rcu_read_unlock();
 	rtnl_unlock();
 	if (pac)
 		sock_kfree_s(sk, pac, sizeof(*pac));
@@ -174,11 +172,9 @@ int ipv6_sock_ac_drop(struct sock *sk, int ifindex, const struct in6_addr *addr)
 	spin_unlock_bh(&ipv6_sk_ac_lock);
 
 	rtnl_lock();
-	rcu_read_lock();
-	dev = dev_get_by_index_rcu(net, pac->acl_ifindex);
+	dev = __dev_get_by_index(net, pac->acl_ifindex);
 	if (dev)
 		ipv6_dev_ac_dec(dev, &pac->acl_addr);
-	rcu_read_unlock();
 	rtnl_unlock();
 
 	sock_kfree_s(sk, pac, sizeof(*pac));
@@ -203,12 +199,11 @@ void ipv6_sock_ac_close(struct sock *sk)
 
 	prev_index = 0;
 	rtnl_lock();
-	rcu_read_lock();
 	while (pac) {
 		struct ipv6_ac_socklist *next = pac->acl_next;
 
 		if (pac->acl_ifindex != prev_index) {
-			dev = dev_get_by_index_rcu(net, pac->acl_ifindex);
+			dev = __dev_get_by_index(net, pac->acl_ifindex);
 			prev_index = pac->acl_ifindex;
 		}
 		if (dev)
@@ -216,7 +211,6 @@ void ipv6_sock_ac_close(struct sock *sk)
 		sock_kfree_s(sk, pac, sizeof(*pac));
 		pac = next;
 	}
-	rcu_read_unlock();
 	rtnl_unlock();
 }
 
@@ -341,7 +335,7 @@ int __ipv6_dev_ac_dec(struct inet6_dev *idev, const struct in6_addr *addr)
 	return 0;
 }
 
-/* called with rcu_read_lock() */
+/* called with rtnl_lock() */
 static int ipv6_dev_ac_dec(struct net_device *dev, const struct in6_addr *addr)
 {
 	struct inet6_dev *idev = __in6_dev_get(dev);
-- 
1.8.3.1
