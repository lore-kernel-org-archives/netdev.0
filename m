From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v7] net: ipv6: Make address flushing on ifdown optional
Date: Wed, 24 Feb 2016 09:25:37 -0800
Message-ID: <1456334737-16708-1-git-send-email-dsa@cumulusnetworks.com>
Cc: hideaki.yoshifuji@miraclelinux.com, hannes@stressinduktion.org,
	David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:32839 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758327AbcBXRZt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 12:25:49 -0500
Received: by mail-pf0-f180.google.com with SMTP id q63so16258224pfb.0
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2016 09:25:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, all ipv6 addresses are flushed when the interface is configured
down, including global, static addresses:

    $ ip -6 addr show dev eth1
    3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 state UP qlen 1000
        inet6 2100:1::2/120 scope global
           valid_lft forever preferred_lft forever
        inet6 fe80::e0:f9ff:fe79:34bd/64 scope link
           valid_lft forever preferred_lft forever
    $ ip link set dev eth1 down
    $ ip -6 addr show dev eth1
    << nothing; all addresses have been flushed>>

Add a new sysctl to make this behavior optional. The new setting defaults to
flush all addresses to maintain backwards compatibility. When the set global
addresses with no expire times are not flushed on an admin down. The sysctl
is per-interface or system-wide for all interfaces

    $ sysctl -w net.ipv6.conf.eth1.keep_addr_on_down=1
or
    $ sysctl -w net.ipv6.conf.all.keep_addr_on_down=1

Will keep addresses on eth1 on an admin down.

    $ ip -6 addr show dev eth1
    3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 state UP qlen 1000
        inet6 2100:1::2/120 scope global
           valid_lft forever preferred_lft forever
        inet6 fe80::e0:f9ff:fe79:34bd/64 scope link
           valid_lft forever preferred_lft forever
    $ ip link set dev eth1 down
    $ ip -6 addr show dev eth1
    3: eth1: <BROADCAST,MULTICAST> mtu 1500 state DOWN qlen 1000
        inet6 2100:1::2/120 scope global tentative
           valid_lft forever preferred_lft forever
        inet6 fe80::e0:f9ff:fe79:34bd/64 scope link tentative
           valid_lft forever preferred_lft forever

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
v7:
- converted sysctl to tri-state as requested
- removed user_managed boolean in favor of checking IFA_F_PERMANENT on address
- added comments about the keep_addr flag
- updated commit message

v6:
- rebase to 4.5.0-rc2
- flip logic from flush_addr to keep_addr with default 0. makes it easier
  to use the 'all' conf for interfaces.

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

 Documentation/networking/ip-sysctl.txt |   9 +++
 include/linux/ipv6.h                   |   1 +
 include/uapi/linux/ipv6.h              |   1 +
 net/ipv6/addrconf.c                    | 136 +++++++++++++++++++++++++++++----
 4 files changed, 132 insertions(+), 15 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 24ce97f42d35..d5df40c75aa4 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1563,6 +1563,15 @@ temp_prefered_lft - INTEGER
 	Preferred lifetime (in seconds) for temporary addresses.
 	Default: 86400 (1 day)
 
+keep_addr_on_down - INTEGER
+	Keep all IPv6 addresses on an interface down event. If set static
+	global addresses with no expiration time are not flushed.
+	  >0 : enabled
+	   0 : system default
+	  <0 : disabled
+
+	Default: 0 (addresses are removed)
+
 max_desync_factor - INTEGER
 	Maximum value for DESYNC_FACTOR, which is a random value
 	that ensures that clients don't synchronize with each
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 4b2267e1b7c3..7edc14fb66b6 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -62,6 +62,7 @@ struct ipv6_devconf {
 		struct in6_addr secret;
 	} stable_secret;
 	__s32		use_oif_addrs_only;
+	__s32		keep_addr_on_down;
 	void		*sysctl;
 };
 
diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
index ec117b65d5a5..395876060f50 100644
--- a/include/uapi/linux/ipv6.h
+++ b/include/uapi/linux/ipv6.h
@@ -176,6 +176,7 @@ enum {
 	DEVCONF_IGNORE_ROUTES_WITH_LINKDOWN,
 	DEVCONF_DROP_UNICAST_IN_L2_MULTICAST,
 	DEVCONF_DROP_UNSOLICITED_NA,
+	DEVCONF_KEEP_ADDR_ON_DOWN,
 	DEVCONF_MAX
 };
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 4751f8922362..a2d6f6c242af 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -216,6 +216,7 @@ static struct ipv6_devconf ipv6_devconf __read_mostly = {
 	},
 	.use_oif_addrs_only	= 0,
 	.ignore_routes_with_linkdown = 0,
+	.keep_addr_on_down	= 0,
 };
 
 static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
@@ -260,6 +261,7 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 	},
 	.use_oif_addrs_only	= 0,
 	.ignore_routes_with_linkdown = 0,
+	.keep_addr_on_down	= 0,
 };
 
 /* Check if a valid qdisc is available */
@@ -3168,6 +3170,55 @@ static void addrconf_gre_config(struct net_device *dev)
 }
 #endif
 
+static int fixup_permanent_addr(struct inet6_dev *idev,
+				struct inet6_ifaddr *ifp)
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
+static void addrconf_permanent_addr(struct net_device *dev)
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
+		if ((ifp->flags & IFA_F_PERMANENT) &&
+		    fixup_permanent_addr(idev, ifp) < 0) {
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
@@ -3253,6 +3304,9 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 			run_pending = 1;
 		}
 
+		/* restore routes for permanent addresses */
+		addrconf_permanent_addr(dev);
+
 		switch (dev->type) {
 #if IS_ENABLED(CONFIG_IPV6_SIT)
 		case ARPHRD_SIT:
@@ -3356,7 +3410,10 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 {
 	struct net *net = dev_net(dev);
 	struct inet6_dev *idev;
-	struct inet6_ifaddr *ifa;
+	struct inet6_ifaddr *ifa, *tmp;
+	struct list_head del_list;
+	int _keep_addr;
+	bool keep_addr;
 	int state, i;
 
 	ASSERT_RTNL();
@@ -3383,6 +3440,16 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 
 	}
 
+	/* aggregate the system setting and interface setting */
+	_keep_addr = net->ipv6.devconf_all->keep_addr_on_down;
+	if (!_keep_addr)
+		_keep_addr = idev->cnf.keep_addr_on_down;
+
+	/* combine the user config with event to determine if permanent
+	 * addresses are to be removed from address hash table
+	 */
+	keep_addr = !(how || _keep_addr <= 0);
+
 	/* Step 2: clear hash table */
 	for (i = 0; i < IN6_ADDR_HSIZE; i++) {
 		struct hlist_head *h = &inet6_addr_lst[i];
@@ -3391,9 +3458,15 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 restart:
 		hlist_for_each_entry_rcu(ifa, h, addr_lst) {
 			if (ifa->idev == idev) {
-				hlist_del_init_rcu(&ifa->addr_lst);
 				addrconf_del_dad_work(ifa);
-				goto restart;
+				/* combined flag + permanent flag decide if
+				 * address is retained on a down event
+				 */
+				if (!keep_addr ||
+				    !(ifa->flags & IFA_F_PERMANENT)) {
+					hlist_del_init_rcu(&ifa->addr_lst);
+					goto restart;
+				}
 			}
 		}
 		spin_unlock_bh(&addrconf_hash_lock);
@@ -3427,31 +3500,53 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 		write_lock_bh(&idev->lock);
 	}
 
-	while (!list_empty(&idev->addr_list)) {
-		ifa = list_first_entry(&idev->addr_list,
-				       struct inet6_ifaddr, if_list);
-		addrconf_del_dad_work(ifa);
+	/* re-combine the user config with event to determine if permanent
+	 * addresses are to be removed from the interface list
+	 */
+	keep_addr = (!how && _keep_addr > 0);
 
-		list_del(&ifa->if_list);
+	INIT_LIST_HEAD(&del_list);
+	list_for_each_entry_safe(ifa, tmp, &idev->addr_list, if_list) {
+		addrconf_del_dad_work(ifa);
 
 		write_unlock_bh(&idev->lock);
-
 		spin_lock_bh(&ifa->lock);
-		state = ifa->state;
-		ifa->state = INET6_IFADDR_STATE_DEAD;
+
+		if (keep_addr && (ifa->flags & IFA_F_PERMANENT)) {
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
 
+	/* now clean up addresses to be removed */
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
@@ -4716,6 +4811,7 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 	array[DEVCONF_USE_OIF_ADDRS_ONLY] = cnf->use_oif_addrs_only;
 	array[DEVCONF_DROP_UNICAST_IN_L2_MULTICAST] = cnf->drop_unicast_in_l2_multicast;
 	array[DEVCONF_DROP_UNSOLICITED_NA] = cnf->drop_unsolicited_na;
+	array[DEVCONF_KEEP_ADDR_ON_DOWN] = cnf->keep_addr_on_down;
 }
 
 static inline size_t inet6_ifla6_size(void)
@@ -5197,10 +5293,12 @@ static void __ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
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
@@ -5804,6 +5902,14 @@ static struct addrconf_sysctl_table
 			.proc_handler	= proc_dointvec,
 		},
 		{
+			.procname       = "keep_addr_on_down",
+			.data           = &ipv6_devconf.keep_addr_on_down,
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
2.1.4
