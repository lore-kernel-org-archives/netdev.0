From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 08/12] ipv6: convert idev_list to list macros
Date: Tue, 02 Mar 2010 15:32:51 -0800
Message-ID: <20100302234003.407374090@vyatta.com>
References: <20100302233243.259794027@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58955 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758000Ab0CBXr0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Mar 2010 18:47:26 -0500
Content-Disposition: inline; filename=ipv6-idev-list.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert to list macro's for the list of addresses per interface
in IPv6. 

This also solves a potential race problem during the cleanup process.
The issue is that addrconf_ifdown() needs to traverse address list,
but then drop lock to call the notifier. The version in -next
could get confused if add/delete happened during this window.
Original code (2.6.32 and earlier) was okay because all addresses
were always deleted.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 drivers/net/bonding/bond_ipv6.c |    9 ++--
 include/net/if_inet6.h          |    6 +--
 net/ipv6/addrconf.c             |   74 ++++++++++++++++++++++------------------
 net/sctp/ipv6.c                 |    2 -
 4 files changed, 50 insertions(+), 41 deletions(-)

--- a/drivers/net/bonding/bond_ipv6.c	2010-03-02 14:29:25.436951570 -0800
+++ b/drivers/net/bonding/bond_ipv6.c	2010-03-02 14:46:33.864952850 -0800
@@ -37,7 +37,6 @@
 static void bond_glean_dev_ipv6(struct net_device *dev, struct in6_addr *addr)
 {
 	struct inet6_dev *idev;
-	struct inet6_ifaddr *ifa;
 
 	if (!dev)
 		return;
@@ -47,10 +46,12 @@ static void bond_glean_dev_ipv6(struct n
 		return;
 
 	read_lock_bh(&idev->lock);
-	ifa = idev->addr_list;
-	if (ifa)
+	if (!list_empty(&idev->addr_list)) {
+		struct inet6_ifaddr *ifa
+			= list_first_entry(&idev->addr_list,
+					   struct inet6_ifaddr, if_list);
 		ipv6_addr_copy(addr, &ifa->addr);
-	else
+	} else
 		ipv6_addr_set(addr, 0, 0, 0, 0);
 
 	read_unlock_bh(&idev->lock);
--- a/include/net/if_inet6.h	2010-03-02 14:38:15.169701060 -0800
+++ b/include/net/if_inet6.h	2010-03-02 14:46:33.864952850 -0800
@@ -55,7 +55,7 @@ struct inet6_ifaddr {
 	struct rt6_info		*rt;
 
 	struct hlist_node	addr_lst;
-	struct inet6_ifaddr	*if_next;       /* next addr in inet6_dev */
+	struct list_head	if_list;
 
 #ifdef CONFIG_IPV6_PRIVACY
 	struct list_head	tmp_list;
@@ -152,9 +152,9 @@ struct ipv6_devstat {
 };
 
 struct inet6_dev {
-	struct net_device		*dev;
+	struct net_device	*dev;
 
-	struct inet6_ifaddr	*addr_list;
+	struct list_head	addr_list;
 
 	struct ifmcaddr6	*mc_list;
 	struct ifmcaddr6	*mc_tomb;
--- a/net/ipv6/addrconf.c	2010-03-02 14:34:41.516826671 -0800
+++ b/net/ipv6/addrconf.c	2010-03-02 14:46:33.868952041 -0800
@@ -317,7 +317,7 @@ void in6_dev_finish_destroy(struct inet6
 {
 	struct net_device *dev = idev->dev;
 
-	WARN_ON(idev->addr_list != NULL);
+	WARN_ON(!list_empty(&idev->addr_list));
 	WARN_ON(idev->mc_list != NULL);
 
 #ifdef NET_REFCNT_DEBUG
@@ -350,6 +350,8 @@ static struct inet6_dev * ipv6_add_dev(s
 
 	rwlock_init(&ndev->lock);
 	ndev->dev = dev;
+	INIT_LIST_HEAD(&ndev->addr_list);
+
 	memcpy(&ndev->cnf, dev_net(dev)->ipv6.devconf_dflt, sizeof(ndev->cnf));
 	ndev->cnf.mtu6 = dev->mtu;
 	ndev->cnf.sysctl = NULL;
@@ -466,7 +468,8 @@ static void dev_forward_change(struct in
 		else
 			ipv6_dev_mc_dec(dev, &in6addr_linklocal_allrouters);
 	}
-	for (ifa=idev->addr_list; ifa; ifa=ifa->if_next) {
+
+	list_for_each_entry(ifa, &idev->addr_list, if_list) {
 		if (ifa->flags&IFA_F_TENTATIVE)
 			continue;
 		if (idev->cnf.forwarding)
@@ -532,7 +535,6 @@ static void inet6_ifa_finish_destroy_rcu
 /* Nobody refers to this ifaddr, destroy it */
 void inet6_ifa_finish_destroy(struct inet6_ifaddr *ifp)
 {
-	WARN_ON(ifp->if_next != NULL);
 	WARN_ON(!hlist_unhashed(&ifp->addr_lst));
 
 #ifdef NET_REFCNT_DEBUG
@@ -556,21 +558,21 @@ void inet6_ifa_finish_destroy(struct ine
 static void
 ipv6_link_dev_addr(struct inet6_dev *idev, struct inet6_ifaddr *ifp)
 {
-	struct inet6_ifaddr *ifa, **ifap;
+	struct list_head *p;
 	int ifp_scope = ipv6_addr_src_scope(&ifp->addr);
 
 	/*
 	 * Each device address list is sorted in order of scope -
 	 * global before linklocal.
 	 */
-	for (ifap = &idev->addr_list; (ifa = *ifap) != NULL;
-	     ifap = &ifa->if_next) {
+	list_for_each(p, &idev->addr_list) {
+		struct inet6_ifaddr *ifa
+			= list_entry(p, struct inet6_ifaddr, if_list);
 		if (ifp_scope >= ipv6_addr_src_scope(&ifa->addr))
 			break;
 	}
 
-	ifp->if_next = *ifap;
-	*ifap = ifp;
+	list_add(&ifp->if_list, p);
 }
 
 static u32 ipv6_addr_hash(const struct in6_addr *addr)
@@ -703,7 +705,7 @@ out:
 
 static void ipv6_del_addr(struct inet6_ifaddr *ifp)
 {
-	struct inet6_ifaddr *ifa, **ifap;
+	struct inet6_ifaddr *ifa, *ifn;
 	struct inet6_dev *idev = ifp->idev;
 	int hash;
 	int deleted = 0, onlink = 0;
@@ -730,11 +732,11 @@ static void ipv6_del_addr(struct inet6_i
 	}
 #endif
 
-	for (ifap = &idev->addr_list; (ifa=*ifap) != NULL;) {
+	list_for_each_entry_safe(ifa, ifn, &idev->addr_list, if_list) {
 		if (ifa == ifp) {
-			*ifap = ifa->if_next;
+			list_del_init(&ifp->if_list);
 			__in6_ifa_put(ifp);
-			ifa->if_next = NULL;
+
 			if (!(ifp->flags & IFA_F_PERMANENT) || onlink > 0)
 				break;
 			deleted = 1;
@@ -767,7 +769,6 @@ static void ipv6_del_addr(struct inet6_i
 				}
 			}
 		}
-		ifap = &ifa->if_next;
 	}
 	write_unlock_bh(&idev->lock);
 
@@ -1146,7 +1147,7 @@ int ipv6_dev_get_saddr(struct net *net, 
 			continue;
 
 		read_lock_bh(&idev->lock);
-		for (score->ifa = idev->addr_list; score->ifa; score->ifa = score->ifa->if_next) {
+		list_for_each_entry(score->ifa, &idev->addr_list, if_list) {
 			int i;
 
 			/*
@@ -1238,8 +1239,9 @@ int ipv6_get_lladdr(struct net_device *d
 		struct inet6_ifaddr *ifp;
 
 		read_lock_bh(&idev->lock);
-		for (ifp=idev->addr_list; ifp; ifp=ifp->if_next) {
-			if (ifp->scope == IFA_LINK && !(ifp->flags & banned_flags)) {
+		list_for_each_entry(ifp, &idev->addr_list, if_list) {
+			if (ifp->scope == IFA_LINK &&
+			    !(ifp->flags & banned_flags)) {
 				ipv6_addr_copy(addr, &ifp->addr);
 				err = 0;
 				break;
@@ -1257,7 +1259,7 @@ static int ipv6_count_addresses(struct i
 	struct inet6_ifaddr *ifp;
 
 	read_lock_bh(&idev->lock);
-	for (ifp=idev->addr_list; ifp; ifp=ifp->if_next)
+	list_for_each_entry(ifp, &idev->addr_list, if_list)
 		cnt++;
 	read_unlock_bh(&idev->lock);
 	return cnt;
@@ -1317,7 +1319,7 @@ int ipv6_chk_prefix(struct in6_addr *add
 	idev = __in6_dev_get(dev);
 	if (idev) {
 		read_lock_bh(&idev->lock);
-		for (ifa = idev->addr_list; ifa; ifa = ifa->if_next) {
+		list_for_each_entry(ifa, &idev->addr_list, if_list) {
 			onlink = ipv6_prefix_equal(addr, &ifa->addr,
 						   ifa->prefix_len);
 			if (onlink)
@@ -1553,7 +1555,7 @@ static int ipv6_inherit_eui64(u8 *eui, s
 	struct inet6_ifaddr *ifp;
 
 	read_lock_bh(&idev->lock);
-	for (ifp=idev->addr_list; ifp; ifp=ifp->if_next) {
+	list_for_each_entry(ifp, &idev->addr_list, if_list) {
 		if (ifp->scope == IFA_LINK && !(ifp->flags&IFA_F_TENTATIVE)) {
 			memcpy(eui, ifp->addr.s6_addr+8, 8);
 			err = 0;
@@ -2157,7 +2159,7 @@ static int inet6_addr_del(struct net *ne
 		return -ENXIO;
 
 	read_lock_bh(&idev->lock);
-	for (ifp = idev->addr_list; ifp; ifp=ifp->if_next) {
+	list_for_each_entry(ifp, &idev->addr_list, if_list) {
 		if (ifp->prefix_len == plen &&
 		    ipv6_addr_equal(pfx, &ifp->addr)) {
 			in6_ifa_hold(ifp);
@@ -2168,7 +2170,7 @@ static int inet6_addr_del(struct net *ne
 			/* If the last address is deleted administratively,
 			   disable IPv6 on this interface.
 			 */
-			if (idev->addr_list == NULL)
+			if (list_empty(&idev->addr_list))
 				addrconf_ifdown(idev->dev, 1);
 			return 0;
 		}
@@ -2601,8 +2603,9 @@ static void addrconf_bonding_change(stru
 static int addrconf_ifdown(struct net_device *dev, int how)
 {
 	struct inet6_dev *idev;
-	struct inet6_ifaddr *ifa, **bifa;
+	struct inet6_ifaddr *ifa;
 	struct net *net = dev_net(dev);
+	LIST_HEAD(keep_list);
 
 	ASSERT_RTNL();
 
@@ -2656,8 +2659,10 @@ static int addrconf_ifdown(struct net_de
 		write_lock_bh(&idev->lock);
 	}
 #endif
-	bifa = &idev->addr_list;
-	while ((ifa = *bifa) != NULL) {
+	while (!list_empty(&idev->addr_list)) {
+		ifa = list_first_entry(&idev->addr_list,
+				       struct inet6_ifaddr, if_list);
+
 		addrconf_del_timer(ifa);
 
 		/* If just doing link down, and address is permanent
@@ -2665,7 +2670,7 @@ static int addrconf_ifdown(struct net_de
 		if (how == 0 &&
 		    (ifa->flags&IFA_F_PERMANENT) &&
 		    !(ipv6_addr_type(&ifa->addr) & IPV6_ADDR_LINKLOCAL)) {
-			bifa = &ifa->if_next;
+			list_move_tail(&ifa->if_list, &keep_list);
 
 			/* If not doing DAD on this address, just keep it. */
 			if ((dev->flags&(IFF_NOARP|IFF_LOOPBACK)) ||
@@ -2681,8 +2686,7 @@ static int addrconf_ifdown(struct net_de
 			ifa->flags |= IFA_F_TENTATIVE;
 			in6_ifa_hold(ifa);
 		} else {
-			*bifa = ifa->if_next;
-			ifa->if_next = NULL;
+			list_del(&ifa->if_list);
 			ifa->dead = 1;
 		}
 		write_unlock_bh(&idev->lock);
@@ -2699,6 +2703,9 @@ static int addrconf_ifdown(struct net_de
 
 		write_lock_bh(&idev->lock);
 	}
+
+	list_splice(&keep_list, &idev->addr_list);
+
 	write_unlock_bh(&idev->lock);
 
 	/* Step 5: Discard multicast list */
@@ -2907,7 +2914,7 @@ static void addrconf_dad_run(struct inet
 	struct inet6_ifaddr *ifp;
 
 	read_lock_bh(&idev->lock);
-	for (ifp = idev->addr_list; ifp; ifp = ifp->if_next) {
+	list_for_each_entry(ifp, &idev->addr_list, if_list) {
 		spin_lock(&ifp->lock);
 		if (!(ifp->flags & IFA_F_TENTATIVE)) {
 			spin_unlock(&ifp->lock);
@@ -3490,7 +3497,6 @@ static int in6_dump_addrs(struct inet6_d
 			  struct netlink_callback *cb, enum addr_type_t type,
 			  int s_ip_idx, int *p_ip_idx)
 {
-	struct inet6_ifaddr *ifa;
 	struct ifmcaddr6 *ifmca;
 	struct ifacaddr6 *ifaca;
 	int err = 1;
@@ -3498,11 +3504,12 @@ static int in6_dump_addrs(struct inet6_d
 
 	read_lock_bh(&idev->lock);
 	switch (type) {
-	case UNICAST_ADDR:
+	case UNICAST_ADDR: {
+		struct inet6_ifaddr *ifa;
+
 		/* unicast address incl. temp addr */
-		for (ifa = idev->addr_list; ifa;
-		     ifa = ifa->if_next, ip_idx++) {
-			if (ip_idx < s_ip_idx)
+		list_for_each_entry(ifa, &idev->addr_list, if_list) {
+			if (++ip_idx < s_ip_idx)
 				continue;
 			err = inet6_fill_ifaddr(skb, ifa,
 						NETLINK_CB(cb->skb).pid,
@@ -3513,6 +3520,7 @@ static int in6_dump_addrs(struct inet6_d
 				break;
 		}
 		break;
+	}
 	case MULTICAST_ADDR:
 		/* multicast address */
 		for (ifmca = idev->mc_list; ifmca;
--- a/net/sctp/ipv6.c	2010-03-02 14:29:25.452951406 -0800
+++ b/net/sctp/ipv6.c	2010-03-02 14:46:33.868952041 -0800
@@ -371,7 +371,7 @@ static void sctp_v6_copy_addrlist(struct
 	}
 
 	read_lock_bh(&in6_dev->lock);
-	for (ifp = in6_dev->addr_list; ifp; ifp = ifp->if_next) {
+	list_for_each_entry(ifp, &in6_dev->addr_list, if_list) {
 		/* Add the address to the local list.  */
 		addr = t_new(struct sctp_sockaddr_entry, GFP_ATOMIC);
 		if (addr) {

-- 

