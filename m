From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net v2] ipv6: fix rtnl lock assertion failure in ipv6_sock_ac_join()
Date: Tue,  2 Sep 2014 16:31:25 -0700
Message-ID: <1409700685-20076-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: tt.rantala@gmail.com, Cong Wang <xiyou.wangcong@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:47050 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755758AbaIBXbp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 19:31:45 -0400
Received: by mail-pd0-f175.google.com with SMTP id ft15so9651102pdb.6
        for <netdev@vger.kernel.org>; Tue, 02 Sep 2014 16:31:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tommi reported the following RTNL lock assertion failure:

[   77.297196] RTNL: assertion failed at net/ipv6/addrconf.c (1699)
[   77.298080] CPU: 0 PID: 4842 Comm: trinity-main Not tainted 3.17.0-rc2+ #30
[   77.299039] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   77.299789]  ffff88003d76a618 ffff880026133c50 ffffffff8238ba79
ffff880037c84520
[   77.300829]  ffff880026133c90 ffffffff820bd52b 0000000000000000
ffffffff82d86c40
[   77.301869]  0000000000000000 00000000f76fd1e1 ffff8800382d8000
ffff8800382d8220
[   77.302906] Call Trace:
[   77.303246]  [<ffffffff8238ba79>] dump_stack+0x4d/0x66
[   77.303928]  [<ffffffff820bd52b>] addrconf_join_solict+0x4b/0xb0
[   77.304731]  [<ffffffff820b031b>] ipv6_dev_ac_inc+0x2bb/0x330
[   77.305498]  [<ffffffff820b0060>] ? ac6_seq_start+0x260/0x260
[   77.306257]  [<ffffffff820b05fe>] ipv6_sock_ac_join+0x26e/0x360
[   77.307046]  [<ffffffff820b0429>] ? ipv6_sock_ac_join+0x99/0x360
[   77.307798]  [<ffffffff820cdd60>] do_ipv6_setsockopt.isra.5+0xa70/0xf20

This is due to we don't hold rtnl lock when calling addrconf_join_solict()
in ipv6_sock_ac_join(). So hold rtnl lock instead of RCU lock here,
after all it is not a hot path.

Although this warning was directly introduced by commit c15b1ccadb323ea
(ipv6: move DAD and addrconf_verify processing to workqueue), it doesn't
mean older kernels are fine since they may need rtnl lock as well,
but we don't take the risk since no one complains yet.

BTW, mcast _might_ have similar problem, but I don't want to touch it
as no one reports a bug so far.

Reported-by: Tommi Rantala <tt.rantala@gmail.com>
Tested-by: Sabrina Dubroca <sd@queasysnail.net>
Fixes: commit c15b1ccadb323ea ("ipv6: move DAD and addrconf_verify processing to workqueue")
Cc: David S. Miller <davem@davemloft.net>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/linux/netdevice.h |  4 ++--
 net/core/dev.c            | 13 +++++++------
 net/ipv6/anycast.c        | 24 ++++++++++++------------
 3 files changed, 21 insertions(+), 20 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 38377392..71838bb 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2074,8 +2074,8 @@ void __dev_remove_pack(struct packet_type *pt);
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
index ab9a165..343847a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -897,23 +897,24 @@ struct net_device *dev_getfirstbyhwtype(struct net *net, unsigned short type)
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
 	ret = NULL;
-	for_each_netdev_rcu(net, dev) {
+	for_each_netdev(net, dev) {
 		if (((dev->flags ^ if_flags) & mask) == 0) {
 			ret = dev;
 			break;
@@ -921,7 +922,7 @@ struct net_device *dev_get_by_flags_rcu(struct net *net, unsigned short if_flags
 	}
 	return ret;
 }
-EXPORT_SYMBOL(dev_get_by_flags_rcu);
+EXPORT_SYMBOL(__dev_get_by_flags);
 
 /**
  *	dev_valid_name - check if name is okay for network device
diff --git a/net/ipv6/anycast.c b/net/ipv6/anycast.c
index 2101832..a1eac55 100644
--- a/net/ipv6/anycast.c
+++ b/net/ipv6/anycast.c
@@ -77,7 +77,7 @@ int ipv6_sock_ac_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 	pac->acl_next = NULL;
 	pac->acl_addr = *addr;
 
-	rcu_read_lock();
+	rtnl_lock();
 	if (ifindex == 0) {
 		struct rt6_info *rt;
 
@@ -90,11 +90,11 @@ int ipv6_sock_ac_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
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
@@ -136,7 +136,7 @@ int ipv6_sock_ac_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 	}
 
 error:
-	rcu_read_unlock();
+	rtnl_unlock();
 	if (pac)
 		sock_kfree_s(sk, pac, sizeof(*pac));
 	return err;
@@ -171,11 +171,11 @@ int ipv6_sock_ac_drop(struct sock *sk, int ifindex, const struct in6_addr *addr)
 
 	spin_unlock_bh(&ipv6_sk_ac_lock);
 
-	rcu_read_lock();
-	dev = dev_get_by_index_rcu(net, pac->acl_ifindex);
+	rtnl_lock();
+	dev = __dev_get_by_index(net, pac->acl_ifindex);
 	if (dev)
 		ipv6_dev_ac_dec(dev, &pac->acl_addr);
-	rcu_read_unlock();
+	rtnl_unlock();
 
 	sock_kfree_s(sk, pac, sizeof(*pac));
 	return 0;
@@ -198,12 +198,12 @@ void ipv6_sock_ac_close(struct sock *sk)
 	spin_unlock_bh(&ipv6_sk_ac_lock);
 
 	prev_index = 0;
-	rcu_read_lock();
+	rtnl_lock();
 	while (pac) {
 		struct ipv6_ac_socklist *next = pac->acl_next;
 
 		if (pac->acl_ifindex != prev_index) {
-			dev = dev_get_by_index_rcu(net, pac->acl_ifindex);
+			dev = __dev_get_by_index(net, pac->acl_ifindex);
 			prev_index = pac->acl_ifindex;
 		}
 		if (dev)
@@ -211,7 +211,7 @@ void ipv6_sock_ac_close(struct sock *sk)
 		sock_kfree_s(sk, pac, sizeof(*pac));
 		pac = next;
 	}
-	rcu_read_unlock();
+	rtnl_unlock();
 }
 
 static void aca_put(struct ifacaddr6 *ac)
@@ -331,7 +331,7 @@ int __ipv6_dev_ac_dec(struct inet6_dev *idev, const struct in6_addr *addr)
 	return 0;
 }
 
-/* called with rcu_read_lock() */
+/* called with rtnl_lock() */
 static int ipv6_dev_ac_dec(struct net_device *dev, const struct in6_addr *addr)
 {
 	struct inet6_dev *idev = __in6_dev_get(dev);
-- 
1.8.3.1
