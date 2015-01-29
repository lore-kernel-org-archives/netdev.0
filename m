From: David Ahern <dsahern@gmail.com>
Subject: [PATCH] net: ipv6: Make address flushing on ifdown optional - v2
Date: Wed, 28 Jan 2015 21:01:05 -0700
Message-ID: <1422504065-17445-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>,
	Hannes Frederic Sowa <hannes@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:64198 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752544AbbA2ECS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2015 23:02:18 -0500
Received: by mail-ie0-f177.google.com with SMTP id vy18so28758755iec.8
        for <netdev@vger.kernel.org>; Wed, 28 Jan 2015 20:02:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, all ipv6 addresses are flushed when the interface is configured
down, even static address:

[root@f20 ~]# ip -6 addr add dev eth1 2000:11:1:1::1/64
[root@f20 ~]# ip addr show dev eth1
3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff
    inet6 2000:11:1:1::1/64 scope global tentative
       valid_lft forever preferred_lft forever
[root@f20 ~]# ip link set dev eth1 up
[root@f20 ~]# ip link set dev eth1 down
[root@f20 ~]# ip addr show dev eth1
3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN group default qlen 1000
    link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff

Add a new sysctl to make this behavior optional. The new setting defaults to
flush all addresses to maintain backwards compatibility. When the setting is
reset static addresses are not flushed:

[root@f20 ~]# echo 0 > /proc/sys/net/ipv6/conf/eth1/flush_addr_on_down
[root@f20 ~]# ip -6 addr add dev eth1 2000:11:1:1::1/64
[root@f20 ~]# ip addr show dev eth1
3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN group default qlen 1000
    link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff
    inet6 2000:11:1:1::1/64 scope global tentative
       valid_lft forever preferred_lft forever
[root@f20 ~]#  ip link set dev eth1 up
[root@f20 ~]#  ip link set dev eth1 down
[root@f20 ~]# ip addr show dev eth1
3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN group default qlen 1000
    link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff
    inet6 2000:11:1:1::1/64 scope global
       valid_lft forever preferred_lft forever
    inet6 fe80::4:11ff:fe22:3301/64 scope link
       valid_lft forever preferred_lft forever

v2:
- only keep static addresses as suggested by Hannes
- added new managed flag to track configured addresses
- on ifdown do not remove from configured address from inet6_addr_lst
- on ifdown reset the TENTATIVE flag and set state to DAD so that DAD is
  redone when link is brought up again

Suggested-by: Hannes Frederic Sowa <hannes@redhat.com>
Signed-off-by: David Ahern <dsahern@gmail.com>
Cc: Hannes Frederic Sowa <hannes@redhat.com>

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/linux/ipv6.h      |  1 +
 include/net/if_inet6.h    |  1 +
 include/uapi/linux/ipv6.h |  1 +
 net/ipv6/addrconf.c       | 55 ++++++++++++++++++++++++++++++++++++++---------
 4 files changed, 48 insertions(+), 10 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 2805062c013f..b91b7c8be023 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -53,6 +53,7 @@ struct ipv6_devconf {
 	__s32           ndisc_notify;
 	__s32		suppress_frag_ndisc;
 	__s32		accept_ra_mtu;
+	__s32		flush_addr_on_down;
 	void		*sysctl;
 };
 
diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index 98e5f9578f86..3b6323111f77 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -72,6 +72,7 @@ struct inet6_ifaddr {
 	int			regen_count;
 
 	bool			tokenized;
+	bool			managed;
 
 	struct rcu_head		rcu;
 	struct in6_addr		peer_addr;
diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
index 437a6a4b125a..ed10d4ba8340 100644
--- a/include/uapi/linux/ipv6.h
+++ b/include/uapi/linux/ipv6.h
@@ -170,6 +170,7 @@ enum {
 	DEVCONF_ACCEPT_RA_FROM_LOCAL,
 	DEVCONF_USE_OPTIMISTIC,
 	DEVCONF_ACCEPT_RA_MTU,
+	DEVCONF_FLUSH_ON_DOWN,
 	DEVCONF_MAX
 };
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 7dcc065e2160..e0e82aad2116 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -202,6 +202,7 @@ static struct ipv6_devconf ipv6_devconf __read_mostly = {
 	.accept_dad		= 1,
 	.suppress_frag_ndisc	= 1,
 	.accept_ra_mtu		= 1,
+	.flush_addr_on_down	= 1,
 };
 
 static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
@@ -240,6 +241,7 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 	.accept_dad		= 1,
 	.suppress_frag_ndisc	= 1,
 	.accept_ra_mtu		= 1,
+	.flush_addr_on_down	= 1,
 };
 
 /* Check if a valid qdisc is available */
@@ -870,6 +872,7 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
 	ifa->prefered_lft = prefered_lft;
 	ifa->cstamp = ifa->tstamp = jiffies;
 	ifa->tokenized = false;
+	ifa->managed = false;
 
 	ifa->rt = rt;
 
@@ -2510,6 +2513,8 @@ static int inet6_addr_add(struct net *net, int ifindex,
 			    valid_lft, prefered_lft);
 
 	if (!IS_ERR(ifp)) {
+		ifp->managed = true;
+
 		if (!(ifa_flags & IFA_F_NOPREFIXROUTE)) {
 			addrconf_prefix_route(&ifp->addr, ifp->prefix_len, dev,
 					      expires, flags);
@@ -3032,8 +3037,9 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 {
 	struct net *net = dev_net(dev);
 	struct inet6_dev *idev;
-	struct inet6_ifaddr *ifa;
+	struct inet6_ifaddr *ifa, *tmp;
 	int state, i;
+	struct list_head del_list;
 
 	ASSERT_RTNL();
 
@@ -3067,9 +3073,12 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 restart:
 		hlist_for_each_entry_rcu(ifa, h, addr_lst) {
 			if (ifa->idev == idev) {
-				hlist_del_init_rcu(&ifa->addr_lst);
 				addrconf_del_dad_work(ifa);
-				goto restart;
+				if (how || idev->cnf.flush_addr_on_down ||
+				    !ifa->managed) {
+					hlist_del_init_rcu(&ifa->addr_lst);
+					goto restart;
+				}
 			}
 		}
 		spin_unlock_bh(&addrconf_hash_lock);
@@ -3103,14 +3112,35 @@ restart:
 		write_lock_bh(&idev->lock);
 	}
 
-	while (!list_empty(&idev->addr_list)) {
-		ifa = list_first_entry(&idev->addr_list,
+	INIT_LIST_HEAD(&del_list);
+	list_for_each_entry_safe(ifa, tmp, &idev->addr_list, if_list) {
+		/* 
+		 * on NETDEV_DOWN events do not flush managed (user configured)
+		 * addresses unless configured to do so. If the address is not
+		 * deleted reset flags and state such that DAD is re-done on a
+ 		 * subsequent link up.
+ 		 */
+		if (!how && !idev->cnf.flush_addr_on_down && ifa->managed) {
+	    		if (!(ifa->flags & IFA_F_NODAD)) {
+				ifa->flags |= IFA_F_TENTATIVE;
+				ifa->state = INET6_IFADDR_STATE_DAD;
+			}
+		} else {
+			list_del(&ifa->if_list);
+			list_add(&ifa->if_list, &del_list);
+		}
+	}
+
+	write_unlock_bh(&idev->lock);
+
+	while (!list_empty(&del_list)) {
+		ifa = list_first_entry(&del_list,
 				       struct inet6_ifaddr, if_list);
+
 		addrconf_del_dad_work(ifa);
 
 		list_del(&ifa->if_list);
 
-		write_unlock_bh(&idev->lock);
 
 		spin_lock_bh(&ifa->state_lock);
 		state = ifa->state;
@@ -3122,12 +3152,8 @@ restart:
 			inet6addr_notifier_call_chain(NETDEV_DOWN, ifa);
 		}
 		in6_ifa_put(ifa);
-
-		write_lock_bh(&idev->lock);
 	}
 
-	write_unlock_bh(&idev->lock);
-
 	/* Step 5: Discard anycast and multicast list */
 	if (how) {
 		ipv6_ac_destroy_dev(idev);
@@ -4383,6 +4409,7 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 	array[DEVCONF_SUPPRESS_FRAG_NDISC] = cnf->suppress_frag_ndisc;
 	array[DEVCONF_ACCEPT_RA_FROM_LOCAL] = cnf->accept_ra_from_local;
 	array[DEVCONF_ACCEPT_RA_MTU] = cnf->accept_ra_mtu;
+	array[DEVCONF_FLUSH_ON_DOWN] = cnf->flush_addr_on_down;
 }
 
 static inline size_t inet6_ifla6_size(void)
@@ -5269,6 +5296,14 @@ static struct addrconf_sysctl_table
 			.proc_handler	= proc_dointvec,
 		},
 		{
+			.procname       = "flush_addr_on_down",
+			.data           = &ipv6_devconf.flush_addr_on_down,
+			.maxlen         = sizeof(int),
+			.mode           = 0644,
+			.proc_handler   = proc_dointvec,
+
+		},
+		{
 			/* sentinel */
 		}
 	},
-- 
1.9.3
