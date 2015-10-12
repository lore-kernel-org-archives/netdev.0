From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v5] net: ipv6: Make address flushing on ifdown optional
Date: Mon, 12 Oct 2015 09:33:07 -0700
Message-ID: <1444667587-13863-1-git-send-email-dsa@cumulusnetworks.com>
Cc: hannes@redhat.com, nicolas.dichtel@6wind.com,
	David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34812 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752659AbbJLQdR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 12:33:17 -0400
Received: by padhy16 with SMTP id hy16so158008033pad.1
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 09:33:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, all ipv6 addresses are flushed when the interface is configured
down, including global, static addresses:

    $ ip -6 addr add dev eth1 2000:11:1:1::1/64
    $ ip addr show dev eth1
    3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
        link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff
        inet6 2000:11:1:1::1/64 scope global tentative
           valid_lft forever preferred_lft forever
    $ ip link set dev eth1 up
    $ ip link set dev eth1 down
    $ ip addr show dev eth1
    3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN group default qlen 1000
        link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff

Add a new sysctl to make this behavior optional. The new setting defaults to
flush all addresses to maintain backwards compatibility. When the setting is
reset global addresses with no expire times are not flushed:

    $ echo 0 > /proc/sys/net/ipv6/conf/eth1/flush_addr_on_down
    $ ip -6 addr add dev eth1 2000:11:1:1::1/64
    $ ip addr show dev eth1
    3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN group default qlen 1000
        link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff
        inet6 2000:11:1:1::1/64 scope global tentative
           valid_lft forever preferred_lft forever
    $ ip link set dev eth1 up
    $ ip link set dev eth1 down
    $ ip addr show dev eth1
    3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN group default qlen 1000
        link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff
        inet6 2000:11:1:1::1/64 scope global
           valid_lft forever preferred_lft forever
        inet6 fe80::4:11ff:fe22:3301/64 scope link
           valid_lft forever preferred_lft forever

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
v5:
- renamed managed to user_managed as requested by Hannes
- handle addrconf_dst_alloc failure and cleanup ifp as noted by Dave
  -- tested by faking allocation failure
- minor ordering changes in addrconf_ifdown() to handle changes under lock

v4:
- rebased to top of tree
- updated to clear all routes on admin down and re-added on admin up
- verified the route tables (main and local) on a link down have *no*
  remnants of the configured, global address. On a link up all routes
  are restored -- multicast, linklocal, local routes and connected.

v3:
- fix local variable ordering and comment style per Dave's comment
- consistency in DEVCONF naming per Brian Haley's comment
- added entry to Documentation/networking/ip-sysctl.txt

v2:
- only keep static addresses as suggested by Hannes
- added new managed flag to track configured addresses
- on ifdown do not remove from configured address from inet6_addr_lst
- on ifdown reset the TENTATIVE flag and set state to DAD so that DAD is
  redone when link is brought up again

 Documentation/networking/ip-sysctl.txt |   6 ++
 include/linux/ipv6.h                   |   1 +
 include/net/if_inet6.h                 |   1 +
 include/uapi/linux/ipv6.h              |   1 +
 net/ipv6/addrconf.c                    | 124 +++++++++++++++++++++++++++++----
 5 files changed, 118 insertions(+), 15 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index ebe94f2cab98..51c60f58f7ec 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1432,6 +1432,12 @@ dad_transmits - INTEGER
 	The amount of Duplicate Address Detection probes to send.
 	Default: 1
 
+flush_addr_on_down - BOOLEAN
+	Flush all IPv6 addresses on an interface down event. If disabled
+	static global addresses with no expiration time are not flushed.
+
+	Default: enabled
+
 forwarding - INTEGER
 	Configure interface-specific Host/Router behaviour.
 
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 0ef2a97ccdb5..112a18940ab2 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -60,6 +60,7 @@ struct ipv6_devconf {
 		struct in6_addr secret;
 	} stable_secret;
 	__s32		use_oif_addrs_only;
+	__s32		flush_addr_on_down;
 	void		*sysctl;
 };
 
diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index 1c8b6820b694..01ba6a286a4b 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -72,6 +72,7 @@ struct inet6_ifaddr {
 	int			regen_count;
 
 	bool			tokenized;
+	bool			user_managed;
 
 	struct rcu_head		rcu;
 	struct in6_addr		peer_addr;
diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
index 38b4fef20219..7c514f7cd209 100644
--- a/include/uapi/linux/ipv6.h
+++ b/include/uapi/linux/ipv6.h
@@ -174,6 +174,7 @@ enum {
 	DEVCONF_USE_OIF_ADDRS_ONLY,
 	DEVCONF_ACCEPT_RA_MIN_HOP_LIMIT,
 	DEVCONF_IGNORE_ROUTES_WITH_LINKDOWN,
+	DEVCONF_FLUSH_ADDR_ON_DOWN,
 	DEVCONF_MAX
 };
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index c8380f1876f1..fae99057d94a 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -215,6 +215,7 @@ static struct ipv6_devconf ipv6_devconf __read_mostly = {
 	},
 	.use_oif_addrs_only	= 0,
 	.ignore_routes_with_linkdown = 0,
+	.flush_addr_on_down	= 1,
 };
 
 static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
@@ -259,6 +260,7 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 	},
 	.use_oif_addrs_only	= 0,
 	.ignore_routes_with_linkdown = 0,
+	.flush_addr_on_down	= 1,
 };
 
 /* Check if a valid qdisc is available */
@@ -954,6 +956,7 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
 	ifa->prefered_lft = prefered_lft;
 	ifa->cstamp = ifa->tstamp = jiffies;
 	ifa->tokenized = false;
+	ifa->user_managed = false;
 
 	ifa->rt = rt;
 
@@ -2687,6 +2690,9 @@ static int inet6_addr_add(struct net *net, int ifindex,
 			    valid_lft, prefered_lft);
 
 	if (!IS_ERR(ifp)) {
+		if (!expires)
+			ifp->user_managed = true;
+
 		if (!(ifa_flags & IFA_F_NOPREFIXROUTE)) {
 			addrconf_prefix_route(&ifp->addr, ifp->prefix_len, dev,
 					      expires, flags);
@@ -3122,6 +3128,55 @@ static void addrconf_gre_config(struct net_device *dev)
 }
 #endif
 
+static int fixup_user_managed_addr(struct inet6_dev *idev,
+				   struct inet6_ifaddr *ifp)
+{
+	if (!ifp->rt) {
+		struct rt6_info *rt;
+
+		rt = addrconf_dst_alloc(idev, &ifp->addr, false);
+		if (unlikely(IS_ERR(rt)))
+			return PTR_ERR(rt);
+
+		ifp->rt = rt;
+	}
+
+	if (!(ifp->flags & IFA_F_NOPREFIXROUTE)) {
+		addrconf_prefix_route(&ifp->addr, ifp->prefix_len,
+				      idev->dev, 0, 0);
+	}
+
+	addrconf_dad_start(ifp);
+
+	return 0;
+}
+
+static void addrconf_user_managed_addr(struct net_device *dev)
+{
+	struct inet6_ifaddr *ifp, *tmp;
+	struct inet6_dev *idev;
+
+	idev = __in6_dev_get(dev);
+	if (!idev)
+		return;
+
+	write_lock_bh(&idev->lock);
+
+	list_for_each_entry_safe(ifp, tmp, &idev->addr_list, if_list) {
+		if (ifp->user_managed &&
+		    fixup_user_managed_addr(idev, ifp) < 0) {
+			write_unlock_bh(&idev->lock);
+			ipv6_del_addr(ifp);
+			write_lock_bh(&idev->lock);
+
+			net_info_ratelimited("%s: Failed to add prefix route for address %pI6c; dropping\n",
+					     idev->dev->name, &ifp->addr);
+		}
+	}
+
+	write_unlock_bh(&idev->lock);
+}
+
 static int addrconf_notify(struct notifier_block *this, unsigned long event,
 			   void *ptr)
 {
@@ -3181,6 +3236,8 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 			run_pending = 1;
 		}
 
+		addrconf_user_managed_addr(dev);
+
 		switch (dev->type) {
 #if IS_ENABLED(CONFIG_IPV6_SIT)
 		case ARPHRD_SIT:
@@ -3301,7 +3358,8 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 {
 	struct net *net = dev_net(dev);
 	struct inet6_dev *idev;
-	struct inet6_ifaddr *ifa;
+	struct inet6_ifaddr *ifa, *tmp;
+	struct list_head del_list;
 	int state, i;
 
 	ASSERT_RTNL();
@@ -3336,9 +3394,13 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 restart:
 		hlist_for_each_entry_rcu(ifa, h, addr_lst) {
 			if (ifa->idev == idev) {
-				hlist_del_init_rcu(&ifa->addr_lst);
 				addrconf_del_dad_work(ifa);
-				goto restart;
+				if (how || idev->cnf.flush_addr_on_down ||
+				    !ifa->user_managed) {
+					hlist_del_init_rcu(&ifa->addr_lst);
+					goto restart;
+				}
+
 			}
 		}
 		spin_unlock_bh(&addrconf_hash_lock);
@@ -3372,31 +3434,52 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 		write_lock_bh(&idev->lock);
 	}
 
-	while (!list_empty(&idev->addr_list)) {
-		ifa = list_first_entry(&idev->addr_list,
-				       struct inet6_ifaddr, if_list);
-		addrconf_del_dad_work(ifa);
+	INIT_LIST_HEAD(&del_list);
+	list_for_each_entry_safe(ifa, tmp, &idev->addr_list, if_list) {
+		bool keep_ifa = false;
 
-		list_del(&ifa->if_list);
+		if (!how && !idev->cnf.flush_addr_on_down && ifa->user_managed)
+			keep_ifa = true;
 
-		write_unlock_bh(&idev->lock);
+		addrconf_del_dad_work(ifa);
 
+		write_unlock_bh(&idev->lock);
 		spin_lock_bh(&ifa->lock);
-		state = ifa->state;
-		ifa->state = INET6_IFADDR_STATE_DEAD;
+
+		if (unlikely(keep_ifa)) {
+			/* set state to skip the notifier below */
+			state = INET6_IFADDR_STATE_DEAD;
+			ifa->state = 0;
+			if (!(ifa->flags & IFA_F_NODAD))
+				ifa->flags |= IFA_F_TENTATIVE;
+		} else {
+			state = ifa->state;
+			ifa->state = INET6_IFADDR_STATE_DEAD;
+
+			list_del(&ifa->if_list);
+			list_add(&ifa->if_list, &del_list);
+		}
+
 		spin_unlock_bh(&ifa->lock);
 
 		if (state != INET6_IFADDR_STATE_DEAD) {
 			__ipv6_ifa_notify(RTM_DELADDR, ifa);
 			inet6addr_notifier_call_chain(NETDEV_DOWN, ifa);
 		}
-		in6_ifa_put(ifa);
 
 		write_lock_bh(&idev->lock);
 	}
 
 	write_unlock_bh(&idev->lock);
 
+	while (!list_empty(&del_list)) {
+		ifa = list_first_entry(&del_list,
+				       struct inet6_ifaddr, if_list);
+		list_del(&ifa->if_list);
+
+		in6_ifa_put(ifa);
+	}
+
 	/* Step 5: Discard anycast and multicast list */
 	if (how) {
 		ipv6_ac_destroy_dev(idev);
@@ -4656,6 +4739,7 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 	array[DEVCONF_IGNORE_ROUTES_WITH_LINKDOWN] = cnf->ignore_routes_with_linkdown;
 	/* we omit DEVCONF_STABLE_SECRET for now */
 	array[DEVCONF_USE_OIF_ADDRS_ONLY] = cnf->use_oif_addrs_only;
+	array[DEVCONF_FLUSH_ADDR_ON_DOWN] = cnf->flush_addr_on_down;
 }
 
 static inline size_t inet6_ifla6_size(void)
@@ -5135,10 +5219,12 @@ static void __ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
 			if (rt)
 				ip6_del_rt(rt);
 		}
-		dst_hold(&ifp->rt->dst);
-
-		ip6_del_rt(ifp->rt);
+		if (ifp->rt) {
+			dst_hold(&ifp->rt->dst);
 
+			ip6_del_rt(ifp->rt);
+			ifp->rt = NULL;
+		}
 		rt_genid_bump_ipv6(net);
 		break;
 	}
@@ -5717,6 +5803,14 @@ static struct addrconf_sysctl_table
 			.proc_handler	= addrconf_sysctl_ignore_routes_with_linkdown,
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
1.9.1
