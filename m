From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv6: Revert optional address flusing on ifdown.
Date: Mon, 25 Apr 2016 15:47:16 -0400 (EDT)
Message-ID: <20160425.154716.125163450778550549.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32824 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964788AbcDYTrS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 15:47:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This reverts the following three commits:

70af921db6f8835f4b11c65731116560adb00c14
799977d9aafbf0ca0b9c39b04cbfb16db71302c9
f1705ec197e705b79ea40fe7a2cc5acfa1d3bfac

The feature was ill conceived, has terrible semantics, and has added
nothing but regressions to the already fragile ipv6 stack.

Fixes: f1705ec197e7 ("net: ipv6: Make address flushing on ifdown optional")
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 Documentation/networking/ip-sysctl.txt |   9 --
 include/linux/ipv6.h                   |   1 -
 include/uapi/linux/ipv6.h              |   1 -
 net/ipv6/addrconf.c                    | 162 +++------------------------------
 4 files changed, 12 insertions(+), 161 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index b183e2b..e0ac252 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1568,15 +1568,6 @@ temp_prefered_lft - INTEGER
 	Preferred lifetime (in seconds) for temporary addresses.
 	Default: 86400 (1 day)
 
-keep_addr_on_down - INTEGER
-	Keep all IPv6 addresses on an interface down event. If set static
-	global addresses with no expiration time are not flushed.
-	  >0 : enabled
-	   0 : system default
-	  <0 : disabled
-
-	Default: 0 (addresses are removed)
-
 max_desync_factor - INTEGER
 	Maximum value for DESYNC_FACTOR, which is a random value
 	that ensures that clients don't synchronize with each
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 7edc14f..4b2267e 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -62,7 +62,6 @@ struct ipv6_devconf {
 		struct in6_addr secret;
 	} stable_secret;
 	__s32		use_oif_addrs_only;
-	__s32		keep_addr_on_down;
 	void		*sysctl;
 };
 
diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
index 3958760..ec117b6 100644
--- a/include/uapi/linux/ipv6.h
+++ b/include/uapi/linux/ipv6.h
@@ -176,7 +176,6 @@ enum {
 	DEVCONF_IGNORE_ROUTES_WITH_LINKDOWN,
 	DEVCONF_DROP_UNICAST_IN_L2_MULTICAST,
 	DEVCONF_DROP_UNSOLICITED_NA,
-	DEVCONF_KEEP_ADDR_ON_DOWN,
 	DEVCONF_MAX
 };
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 23cec53..d77ba39 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -216,7 +216,6 @@ static struct ipv6_devconf ipv6_devconf __read_mostly = {
 	},
 	.use_oif_addrs_only	= 0,
 	.ignore_routes_with_linkdown = 0,
-	.keep_addr_on_down	= 0,
 };
 
 static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
@@ -261,7 +260,6 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 	},
 	.use_oif_addrs_only	= 0,
 	.ignore_routes_with_linkdown = 0,
-	.keep_addr_on_down	= 0,
 };
 
 /* Check if a valid qdisc is available */
@@ -3176,81 +3174,6 @@ static void addrconf_gre_config(struct net_device *dev)
 }
 #endif
 
-#if IS_ENABLED(CONFIG_NET_L3_MASTER_DEV)
-/* If the host route is cached on the addr struct make sure it is associated
- * with the proper table. e.g., enslavement can change and if so the cached
- * host route needs to move to the new table.
- */
-static void l3mdev_check_host_rt(struct inet6_dev *idev,
-				  struct inet6_ifaddr *ifp)
-{
-	if (ifp->rt) {
-		u32 tb_id = l3mdev_fib_table(idev->dev) ? : RT6_TABLE_LOCAL;
-
-		if (tb_id != ifp->rt->rt6i_table->tb6_id) {
-			ip6_del_rt(ifp->rt);
-			ifp->rt = NULL;
-		}
-	}
-}
-#else
-static void l3mdev_check_host_rt(struct inet6_dev *idev,
-				  struct inet6_ifaddr *ifp)
-{
-}
-#endif
-
-static int fixup_permanent_addr(struct inet6_dev *idev,
-				struct inet6_ifaddr *ifp)
-{
-	l3mdev_check_host_rt(idev, ifp);
-
-	if (!ifp->rt) {
-		struct rt6_info *rt;
-
-		rt = addrconf_dst_alloc(idev, &ifp->addr, false);
-		if (unlikely(IS_ERR(rt)))
-			return PTR_ERR(rt);
-
-		ifp->rt = rt;
-	}
-
-	if (!(ifp->flags & IFA_F_NOPREFIXROUTE)) {
-		addrconf_prefix_route(&ifp->addr, ifp->prefix_len,
-				      idev->dev, 0, 0);
-	}
-
-	addrconf_dad_start(ifp);
-
-	return 0;
-}
-
-static void addrconf_permanent_addr(struct net_device *dev)
-{
-	struct inet6_ifaddr *ifp, *tmp;
-	struct inet6_dev *idev;
-
-	idev = __in6_dev_get(dev);
-	if (!idev)
-		return;
-
-	write_lock_bh(&idev->lock);
-
-	list_for_each_entry_safe(ifp, tmp, &idev->addr_list, if_list) {
-		if ((ifp->flags & IFA_F_PERMANENT) &&
-		    fixup_permanent_addr(idev, ifp) < 0) {
-			write_unlock_bh(&idev->lock);
-			ipv6_del_addr(ifp);
-			write_lock_bh(&idev->lock);
-
-			net_info_ratelimited("%s: Failed to add prefix route for address %pI6c; dropping\n",
-					     idev->dev->name, &ifp->addr);
-		}
-	}
-
-	write_unlock_bh(&idev->lock);
-}
-
 static int addrconf_notify(struct notifier_block *this, unsigned long event,
 			   void *ptr)
 {
@@ -3337,9 +3260,6 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 			run_pending = 1;
 		}
 
-		/* restore routes for permanent addresses */
-		addrconf_permanent_addr(dev);
-
 		switch (dev->type) {
 #if IS_ENABLED(CONFIG_IPV6_SIT)
 		case ARPHRD_SIT:
@@ -3448,20 +3368,11 @@ static void addrconf_type_change(struct net_device *dev, unsigned long event)
 		ipv6_mc_unmap(idev);
 }
 
-static bool addr_is_local(const struct in6_addr *addr)
-{
-	return ipv6_addr_type(addr) &
-		(IPV6_ADDR_LINKLOCAL | IPV6_ADDR_LOOPBACK);
-}
-
 static int addrconf_ifdown(struct net_device *dev, int how)
 {
 	struct net *net = dev_net(dev);
 	struct inet6_dev *idev;
-	struct inet6_ifaddr *ifa, *tmp;
-	struct list_head del_list;
-	int _keep_addr;
-	bool keep_addr;
+	struct inet6_ifaddr *ifa;
 	int state, i;
 
 	ASSERT_RTNL();
@@ -3488,16 +3399,6 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 
 	}
 
-	/* aggregate the system setting and interface setting */
-	_keep_addr = net->ipv6.devconf_all->keep_addr_on_down;
-	if (!_keep_addr)
-		_keep_addr = idev->cnf.keep_addr_on_down;
-
-	/* combine the user config with event to determine if permanent
-	 * addresses are to be removed from address hash table
-	 */
-	keep_addr = !(how || _keep_addr <= 0);
-
 	/* Step 2: clear hash table */
 	for (i = 0; i < IN6_ADDR_HSIZE; i++) {
 		struct hlist_head *h = &inet6_addr_lst[i];
@@ -3506,16 +3407,9 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 restart:
 		hlist_for_each_entry_rcu(ifa, h, addr_lst) {
 			if (ifa->idev == idev) {
+				hlist_del_init_rcu(&ifa->addr_lst);
 				addrconf_del_dad_work(ifa);
-				/* combined flag + permanent flag decide if
-				 * address is retained on a down event
-				 */
-				if (!keep_addr ||
-				    !(ifa->flags & IFA_F_PERMANENT) ||
-				    addr_is_local(&ifa->addr)) {
-					hlist_del_init_rcu(&ifa->addr_lst);
-					goto restart;
-				}
+				goto restart;
 			}
 		}
 		spin_unlock_bh(&addrconf_hash_lock);
@@ -3549,54 +3443,31 @@ restart:
 		write_lock_bh(&idev->lock);
 	}
 
-	/* re-combine the user config with event to determine if permanent
-	 * addresses are to be removed from the interface list
-	 */
-	keep_addr = (!how && _keep_addr > 0);
-
-	INIT_LIST_HEAD(&del_list);
-	list_for_each_entry_safe(ifa, tmp, &idev->addr_list, if_list) {
+	while (!list_empty(&idev->addr_list)) {
+		ifa = list_first_entry(&idev->addr_list,
+				       struct inet6_ifaddr, if_list);
 		addrconf_del_dad_work(ifa);
 
-		write_unlock_bh(&idev->lock);
-		spin_lock_bh(&ifa->lock);
-
-		if (keep_addr && (ifa->flags & IFA_F_PERMANENT) &&
-		    !addr_is_local(&ifa->addr)) {
-			/* set state to skip the notifier below */
-			state = INET6_IFADDR_STATE_DEAD;
-			ifa->state = 0;
-			if (!(ifa->flags & IFA_F_NODAD))
-				ifa->flags |= IFA_F_TENTATIVE;
-		} else {
-			state = ifa->state;
-			ifa->state = INET6_IFADDR_STATE_DEAD;
+		list_del(&ifa->if_list);
 
-			list_del(&ifa->if_list);
-			list_add(&ifa->if_list, &del_list);
-		}
+		write_unlock_bh(&idev->lock);
 
+		spin_lock_bh(&ifa->lock);
+		state = ifa->state;
+		ifa->state = INET6_IFADDR_STATE_DEAD;
 		spin_unlock_bh(&ifa->lock);
 
 		if (state != INET6_IFADDR_STATE_DEAD) {
 			__ipv6_ifa_notify(RTM_DELADDR, ifa);
 			inet6addr_notifier_call_chain(NETDEV_DOWN, ifa);
 		}
+		in6_ifa_put(ifa);
 
 		write_lock_bh(&idev->lock);
 	}
 
 	write_unlock_bh(&idev->lock);
 
-	/* now clean up addresses to be removed */
-	while (!list_empty(&del_list)) {
-		ifa = list_first_entry(&del_list,
-				       struct inet6_ifaddr, if_list);
-		list_del(&ifa->if_list);
-
-		in6_ifa_put(ifa);
-	}
-
 	/* Step 5: Discard anycast and multicast list */
 	if (how) {
 		ipv6_ac_destroy_dev(idev);
@@ -4861,7 +4732,6 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 	array[DEVCONF_USE_OIF_ADDRS_ONLY] = cnf->use_oif_addrs_only;
 	array[DEVCONF_DROP_UNICAST_IN_L2_MULTICAST] = cnf->drop_unicast_in_l2_multicast;
 	array[DEVCONF_DROP_UNSOLICITED_NA] = cnf->drop_unsolicited_na;
-	array[DEVCONF_KEEP_ADDR_ON_DOWN] = cnf->keep_addr_on_down;
 }
 
 static inline size_t inet6_ifla6_size(void)
@@ -5950,14 +5820,6 @@ static struct addrconf_sysctl_table
 			.proc_handler	= proc_dointvec,
 		},
 		{
-			.procname       = "keep_addr_on_down",
-			.data           = &ipv6_devconf.keep_addr_on_down,
-			.maxlen         = sizeof(int),
-			.mode           = 0644,
-			.proc_handler   = proc_dointvec,
-
-		},
-		{
 			/* sentinel */
 		}
 	},
-- 
2.4.1
