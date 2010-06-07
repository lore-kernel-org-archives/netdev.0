From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] anycast: Some RCU conversions
Date: Mon, 07 Jun 2010 23:42:13 +0200
Message-ID: <1275946933.2775.16.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:48719 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752279Ab0FGVmT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 17:42:19 -0400
Received: by wwb28 with SMTP id 28so43182wwb.19
        for <netdev@vger.kernel.org>; Mon, 07 Jun 2010 14:42:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- dev_get_by_flags() changed to dev_get_by_flags_rcu()

- ipv6_sock_ac_join() dont touch dev & idev refcounts
- ipv6_sock_ac_drop() dont touch dev & idev refcounts
- ipv6_sock_ac_close() dont touch dev & idev refcounts
- ipv6_dev_ac_dec() dount touch idev refcount
- ipv6_chk_acast_addr() dont touch idev refcount

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
---
 include/linux/netdevice.h |    4 -
 net/core/dev.c            |   14 ++---
 net/ipv6/anycast.c        |   90 ++++++++++++++++--------------------
 3 files changed, 49 insertions(+), 59 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 5156b80..c319f28 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1271,8 +1271,8 @@ extern void		dev_add_pack(struct packet_type *pt);
 extern void		dev_remove_pack(struct packet_type *pt);
 extern void		__dev_remove_pack(struct packet_type *pt);
 
-extern struct net_device	*dev_get_by_flags(struct net *net, unsigned short flags,
-						  unsigned short mask);
+extern struct net_device	*dev_get_by_flags_rcu(struct net *net, unsigned short flags,
+						      unsigned short mask);
 extern struct net_device	*dev_get_by_name(struct net *net, const char *name);
 extern struct net_device	*dev_get_by_name_rcu(struct net *net, const char *name);
 extern struct net_device	*__dev_get_by_name(struct net *net, const char *name);
diff --git a/net/core/dev.c b/net/core/dev.c
index b65347c..d41054d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -803,35 +803,31 @@ struct net_device *dev_getfirstbyhwtype(struct net *net, unsigned short type)
 EXPORT_SYMBOL(dev_getfirstbyhwtype);
 
 /**
- *	dev_get_by_flags - find any device with given flags
+ *	dev_get_by_flags_rcu - find any device with given flags
  *	@net: the applicable net namespace
  *	@if_flags: IFF_* values
  *	@mask: bitmask of bits in if_flags to check
  *
  *	Search for any interface with the given flags. Returns NULL if a device
- *	is not found or a pointer to the device. The device returned has
- *	had a reference added and the pointer is safe until the user calls
- *	dev_put to indicate they have finished with it.
+ *	is not found or a pointer to the device. Must be called inside
+ *	rcu_read_lock(), and result refcount is unchanged.
  */
 
-struct net_device *dev_get_by_flags(struct net *net, unsigned short if_flags,
+struct net_device *dev_get_by_flags_rcu(struct net *net, unsigned short if_flags,
 				    unsigned short mask)
 {
 	struct net_device *dev, *ret;
 
 	ret = NULL;
-	rcu_read_lock();
 	for_each_netdev_rcu(net, dev) {
 		if (((dev->flags ^ if_flags) & mask) == 0) {
-			dev_hold(dev);
 			ret = dev;
 			break;
 		}
 	}
-	rcu_read_unlock();
 	return ret;
 }
-EXPORT_SYMBOL(dev_get_by_flags);
+EXPORT_SYMBOL(dev_get_by_flags_rcu);
 
 /**
  *	dev_valid_name - check if name is okay for network device
diff --git a/net/ipv6/anycast.c b/net/ipv6/anycast.c
index b5b0705..f058fbd 100644
--- a/net/ipv6/anycast.c
+++ b/net/ipv6/anycast.c
@@ -77,41 +77,40 @@ int ipv6_sock_ac_join(struct sock *sk, int ifindex, struct in6_addr *addr)
 	pac->acl_next = NULL;
 	ipv6_addr_copy(&pac->acl_addr, addr);
 
+	rcu_read_lock();
 	if (ifindex == 0) {
 		struct rt6_info *rt;
 
 		rt = rt6_lookup(net, addr, NULL, 0, 0);
 		if (rt) {
 			dev = rt->rt6i_dev;
-			dev_hold(dev);
 			dst_release(&rt->u.dst);
 		} else if (ishost) {
 			err = -EADDRNOTAVAIL;
-			goto out_free_pac;
+			goto error;
 		} else {
 			/* router, no matching interface: just pick one */
-
-			dev = dev_get_by_flags(net, IFF_UP, IFF_UP|IFF_LOOPBACK);
+			dev = dev_get_by_flags_rcu(net, IFF_UP,
+						   IFF_UP | IFF_LOOPBACK);
 		}
 	} else
-		dev = dev_get_by_index(net, ifindex);
+		dev = dev_get_by_index_rcu(net, ifindex);
 
 	if (dev == NULL) {
 		err = -ENODEV;
-		goto out_free_pac;
+		goto error;
 	}
 
-	idev = in6_dev_get(dev);
+	idev = __in6_dev_get(dev);
 	if (!idev) {
 		if (ifindex)
 			err = -ENODEV;
 		else
 			err = -EADDRNOTAVAIL;
-		goto out_dev_put;
+		goto error;
 	}
 	/* reset ishost, now that we have a specific device */
 	ishost = !idev->cnf.forwarding;
-	in6_dev_put(idev);
 
 	pac->acl_ifindex = dev->ifindex;
 
@@ -124,26 +123,22 @@ int ipv6_sock_ac_join(struct sock *sk, int ifindex, struct in6_addr *addr)
 		if (ishost)
 			err = -EADDRNOTAVAIL;
 		if (err)
-			goto out_dev_put;
+			goto error;
 	}
 
 	err = ipv6_dev_ac_inc(dev, addr);
-	if (err)
-		goto out_dev_put;
-
-	write_lock_bh(&ipv6_sk_ac_lock);
-	pac->acl_next = np->ipv6_ac_list;
-	np->ipv6_ac_list = pac;
-	write_unlock_bh(&ipv6_sk_ac_lock);
-
-	dev_put(dev);
-
-	return 0;
+	if (!err) {
+		write_lock_bh(&ipv6_sk_ac_lock);
+		pac->acl_next = np->ipv6_ac_list;
+		np->ipv6_ac_list = pac;
+		write_unlock_bh(&ipv6_sk_ac_lock);
+		pac = NULL;
+	}
 
-out_dev_put:
-	dev_put(dev);
-out_free_pac:
-	sock_kfree_s(sk, pac, sizeof(*pac));
+error:
+	rcu_read_unlock();
+	if (pac)
+		sock_kfree_s(sk, pac, sizeof(*pac));
 	return err;
 }
 
@@ -176,11 +171,12 @@ int ipv6_sock_ac_drop(struct sock *sk, int ifindex, struct in6_addr *addr)
 
 	write_unlock_bh(&ipv6_sk_ac_lock);
 
-	dev = dev_get_by_index(net, pac->acl_ifindex);
-	if (dev) {
+	rcu_read_lock();
+	dev = dev_get_by_index_rcu(net, pac->acl_ifindex);
+	if (dev)
 		ipv6_dev_ac_dec(dev, &pac->acl_addr);
-		dev_put(dev);
-	}
+	rcu_read_unlock();
+
 	sock_kfree_s(sk, pac, sizeof(*pac));
 	return 0;
 }
@@ -199,13 +195,12 @@ void ipv6_sock_ac_close(struct sock *sk)
 	write_unlock_bh(&ipv6_sk_ac_lock);
 
 	prev_index = 0;
+	rcu_read_lock();
 	while (pac) {
 		struct ipv6_ac_socklist *next = pac->acl_next;
 
 		if (pac->acl_ifindex != prev_index) {
-			if (dev)
-				dev_put(dev);
-			dev = dev_get_by_index(net, pac->acl_ifindex);
+			dev = dev_get_by_index_rcu(net, pac->acl_ifindex);
 			prev_index = pac->acl_ifindex;
 		}
 		if (dev)
@@ -213,8 +208,7 @@ void ipv6_sock_ac_close(struct sock *sk)
 		sock_kfree_s(sk, pac, sizeof(*pac));
 		pac = next;
 	}
-	if (dev)
-		dev_put(dev);
+	rcu_read_unlock();
 }
 
 #if 0
@@ -363,33 +357,32 @@ int __ipv6_dev_ac_dec(struct inet6_dev *idev, struct in6_addr *addr)
 	return 0;
 }
 
+/* called with rcu_read_lock() */
 static int ipv6_dev_ac_dec(struct net_device *dev, struct in6_addr *addr)
 {
-	int ret;
-	struct inet6_dev *idev = in6_dev_get(dev);
+	struct inet6_dev *idev = __in6_dev_get(dev);
+
 	if (idev == NULL)
 		return -ENODEV;
-	ret = __ipv6_dev_ac_dec(idev, addr);
-	in6_dev_put(idev);
-	return ret;
+	return __ipv6_dev_ac_dec(idev, addr);
 }
 
 /*
  *	check if the interface has this anycast address
+ *	called with rcu_read_lock()
  */
 static int ipv6_chk_acast_dev(struct net_device *dev, struct in6_addr *addr)
 {
 	struct inet6_dev *idev;
 	struct ifacaddr6 *aca;
 
-	idev = in6_dev_get(dev);
+	idev = __in6_dev_get(dev);
 	if (idev) {
 		read_lock_bh(&idev->lock);
 		for (aca = idev->ac_list; aca; aca = aca->aca_next)
 			if (ipv6_addr_equal(&aca->aca_addr, addr))
 				break;
 		read_unlock_bh(&idev->lock);
-		in6_dev_put(idev);
 		return aca != NULL;
 	}
 	return 0;
@@ -403,14 +396,15 @@ int ipv6_chk_acast_addr(struct net *net, struct net_device *dev,
 {
 	int found = 0;
 
-	if (dev)
-		return ipv6_chk_acast_dev(dev, addr);
 	rcu_read_lock();
-	for_each_netdev_rcu(net, dev)
-		if (ipv6_chk_acast_dev(dev, addr)) {
-			found = 1;
-			break;
-		}
+	if (dev)
+		found = ipv6_chk_acast_dev(dev, addr);
+	else
+		for_each_netdev_rcu(net, dev)
+			if (ipv6_chk_acast_dev(dev, addr)) {
+				found = 1;
+				break;
+			}
 	rcu_read_unlock();
 	return found;
 }


