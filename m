From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next] ipv6: split duplicate address detection and router solicitation timer
Date: Sun, 23 Jun 2013 18:39:01 +0200
Message-ID: <20130623163901.GB13836@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: fleitner@redhat.com, yoshfuji@linux-ipv6.org, dlstevens@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:60986 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751478Ab3FWQjE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Jun 2013 12:39:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch splits the timers for duplicate address detection and router
solicitations apart. The router solicitations timer goes into inet6_dev
and the dad timer stays in inet6_ifaddr.

The reason behind this patch is to reduce the number of unneeded router
solicitations send out by the host if additional link-local addresses
are created. Currently we send out RS for every link-local address on
an interface.

If the RS timer fires we pick a source address with ipv6_get_lladdr. This
change could hurt people adding additional link-local addresses and
specifying these addresses in the radvd clients section because we
no longer guarantee that we use every ll address as source address in
router solicitations.

Cc: Flavio Leitner <fleitner@redhat.com>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: David Stevens <dlstevens@us.ibm.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/if_inet6.h |   8 ++-
 net/ipv6/addrconf.c    | 164 +++++++++++++++++++++++++++----------------------
 2 files changed, 97 insertions(+), 75 deletions(-)

diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index e07feb4..e4c5a2d 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -50,7 +50,7 @@ struct inet6_ifaddr {
 
 	int			state;
 
-	__u8			probes;
+	__u8			dad_probes;
 	__u8			flags;
 
 	__u16			scope;
@@ -58,7 +58,7 @@ struct inet6_ifaddr {
 	unsigned long		cstamp;	/* created timestamp */
 	unsigned long		tstamp; /* updated timestamp */
 
-	struct timer_list	timer;
+	struct timer_list	dad_timer;
 
 	struct inet6_dev	*idev;
 	struct rt6_info		*rt;
@@ -195,6 +195,10 @@ struct inet6_dev {
 	struct neigh_parms	*nd_parms;
 	struct ipv6_devconf	cnf;
 	struct ipv6_devstat	stats;
+
+	struct timer_list	rs_timer;
+	__u8			rs_probes;
+
 	unsigned long		tstamp; /* ipv6InterfaceTable update timestamp */
 	struct rcu_head		rcu;
 };
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 8044912..a3cf40b 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -253,37 +253,32 @@ static inline bool addrconf_qdisc_ok(const struct net_device *dev)
 	return !qdisc_tx_is_noop(dev);
 }
 
-static void addrconf_del_timer(struct inet6_ifaddr *ifp)
+static void addrconf_del_rs_timer(struct inet6_dev *idev)
 {
-	if (del_timer(&ifp->timer))
+	if (del_timer(&idev->rs_timer))
+		__in6_dev_put(idev);
+}
+
+static void addrconf_del_dad_timer(struct inet6_ifaddr *ifp)
+{
+	if (del_timer(&ifp->dad_timer))
 		__in6_ifa_put(ifp);
 }
 
-enum addrconf_timer_t {
-	AC_NONE,
-	AC_DAD,
-	AC_RS,
-};
+static void addrconf_mod_rs_timer(struct inet6_dev *idev,
+				  unsigned long when)
+{
+	if (!timer_pending(&idev->rs_timer))
+		in6_dev_hold(idev);
+	mod_timer(&idev->rs_timer, jiffies + when);
+}
 
-static void addrconf_mod_timer(struct inet6_ifaddr *ifp,
-			       enum addrconf_timer_t what,
-			       unsigned long when)
+static void addrconf_mod_dad_timer(struct inet6_ifaddr *ifp,
+				   unsigned long when)
 {
-	if (!del_timer(&ifp->timer))
+	if (!timer_pending(&ifp->dad_timer))
 		in6_ifa_hold(ifp);
-
-	switch (what) {
-	case AC_DAD:
-		ifp->timer.function = addrconf_dad_timer;
-		break;
-	case AC_RS:
-		ifp->timer.function = addrconf_rs_timer;
-		break;
-	default:
-		break;
-	}
-	ifp->timer.expires = jiffies + when;
-	add_timer(&ifp->timer);
+	mod_timer(&ifp->dad_timer, jiffies + when);
 }
 
 static int snmp6_alloc_dev(struct inet6_dev *idev)
@@ -326,6 +321,7 @@ void in6_dev_finish_destroy(struct inet6_dev *idev)
 
 	WARN_ON(!list_empty(&idev->addr_list));
 	WARN_ON(idev->mc_list != NULL);
+	WARN_ON(timer_pending(&idev->rs_timer));
 
 #ifdef NET_REFCNT_DEBUG
 	pr_debug("%s: %s\n", __func__, dev ? dev->name : "NIL");
@@ -357,7 +353,8 @@ static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
 	rwlock_init(&ndev->lock);
 	ndev->dev = dev;
 	INIT_LIST_HEAD(&ndev->addr_list);
-
+	setup_timer(&ndev->rs_timer, addrconf_rs_timer,
+		    (unsigned long)ndev);
 	memcpy(&ndev->cnf, dev_net(dev)->ipv6.devconf_dflt, sizeof(ndev->cnf));
 	ndev->cnf.mtu6 = dev->mtu;
 	ndev->cnf.sysctl = NULL;
@@ -776,7 +773,7 @@ void inet6_ifa_finish_destroy(struct inet6_ifaddr *ifp)
 
 	in6_dev_put(ifp->idev);
 
-	if (del_timer(&ifp->timer))
+	if (del_timer(&ifp->dad_timer))
 		pr_notice("Timer is still running, when freeing ifa=%p\n", ifp);
 
 	if (ifp->state != INET6_IFADDR_STATE_DEAD) {
@@ -869,9 +866,9 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr, int pfxlen,
 
 	spin_lock_init(&ifa->lock);
 	spin_lock_init(&ifa->state_lock);
-	init_timer(&ifa->timer);
+	setup_timer(&ifa->dad_timer, addrconf_dad_timer,
+		    (unsigned long)ifa);
 	INIT_HLIST_NODE(&ifa->addr_lst);
-	ifa->timer.data = (unsigned long) ifa;
 	ifa->scope = scope;
 	ifa->prefix_len = pfxlen;
 	ifa->flags = flags | IFA_F_TENTATIVE;
@@ -994,7 +991,7 @@ static void ipv6_del_addr(struct inet6_ifaddr *ifp)
 	}
 	write_unlock_bh(&idev->lock);
 
-	addrconf_del_timer(ifp);
+	addrconf_del_dad_timer(ifp);
 
 	ipv6_ifa_notify(RTM_DELADDR, ifp);
 
@@ -1447,6 +1444,23 @@ try_nextdev:
 }
 EXPORT_SYMBOL(ipv6_dev_get_saddr);
 
+static int __ipv6_get_lladdr(struct inet6_dev *idev, struct in6_addr *addr,
+			     unsigned char banned_flags)
+{
+	struct inet6_ifaddr *ifp;
+	int err = -EADDRNOTAVAIL;
+
+	list_for_each_entry(ifp, &idev->addr_list, if_list) {
+		if (ifp->scope == IFA_LINK &&
+		    !(ifp->flags & banned_flags)) {
+			*addr = ifp->addr;
+			err = 0;
+			break;
+		}
+	}
+	return err;
+}
+
 int ipv6_get_lladdr(struct net_device *dev, struct in6_addr *addr,
 		    unsigned char banned_flags)
 {
@@ -1456,17 +1470,8 @@ int ipv6_get_lladdr(struct net_device *dev, struct in6_addr *addr,
 	rcu_read_lock();
 	idev = __in6_dev_get(dev);
 	if (idev) {
-		struct inet6_ifaddr *ifp;
-
 		read_lock_bh(&idev->lock);
-		list_for_each_entry(ifp, &idev->addr_list, if_list) {
-			if (ifp->scope == IFA_LINK &&
-			    !(ifp->flags & banned_flags)) {
-				*addr = ifp->addr;
-				err = 0;
-				break;
-			}
-		}
+		err = __ipv6_get_lladdr(idev, addr, banned_flags);
 		read_unlock_bh(&idev->lock);
 	}
 	rcu_read_unlock();
@@ -1580,7 +1585,7 @@ static void addrconf_dad_stop(struct inet6_ifaddr *ifp, int dad_failed)
 {
 	if (ifp->flags&IFA_F_PERMANENT) {
 		spin_lock_bh(&ifp->lock);
-		addrconf_del_timer(ifp);
+		addrconf_del_dad_timer(ifp);
 		ifp->flags |= IFA_F_TENTATIVE;
 		if (dad_failed)
 			ifp->flags |= IFA_F_DADFAILED;
@@ -3038,7 +3043,7 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 		hlist_for_each_entry_rcu(ifa, h, addr_lst) {
 			if (ifa->idev == idev) {
 				hlist_del_init_rcu(&ifa->addr_lst);
-				addrconf_del_timer(ifa);
+				addrconf_del_dad_timer(ifa);
 				goto restart;
 			}
 		}
@@ -3047,6 +3052,8 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 
 	write_lock_bh(&idev->lock);
 
+	addrconf_del_rs_timer(idev);
+
 	/* Step 2: clear flags for stateless addrconf */
 	if (!how)
 		idev->if_flags &= ~(IF_RS_SENT|IF_RA_RCVD|IF_READY);
@@ -3076,7 +3083,7 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 	while (!list_empty(&idev->addr_list)) {
 		ifa = list_first_entry(&idev->addr_list,
 				       struct inet6_ifaddr, if_list);
-		addrconf_del_timer(ifa);
+		addrconf_del_dad_timer(ifa);
 
 		list_del(&ifa->if_list);
 
@@ -3118,10 +3125,10 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 
 static void addrconf_rs_timer(unsigned long data)
 {
-	struct inet6_ifaddr *ifp = (struct inet6_ifaddr *) data;
-	struct inet6_dev *idev = ifp->idev;
+	struct inet6_dev *idev = (struct inet6_dev *)data;
+	struct in6_addr lladdr;
 
-	read_lock(&idev->lock);
+	write_lock(&idev->lock);
 	if (idev->dead || !(idev->if_flags & IF_READY))
 		goto out;
 
@@ -3132,18 +3139,19 @@ static void addrconf_rs_timer(unsigned long data)
 	if (idev->if_flags & IF_RA_RCVD)
 		goto out;
 
-	spin_lock(&ifp->lock);
-	if (ifp->probes++ < idev->cnf.rtr_solicits) {
-		/* The wait after the last probe can be shorter */
-		addrconf_mod_timer(ifp, AC_RS,
-				   (ifp->probes == idev->cnf.rtr_solicits) ?
-				   idev->cnf.rtr_solicit_delay :
-				   idev->cnf.rtr_solicit_interval);
-		spin_unlock(&ifp->lock);
+	if (idev->rs_probes++ < idev->cnf.rtr_solicits) {
+		if (!__ipv6_get_lladdr(idev, &lladdr, IFA_F_TENTATIVE))
+			ndisc_send_rs(idev->dev, &lladdr,
+				      &in6addr_linklocal_allrouters);
+		else
+			goto out;
 
-		ndisc_send_rs(idev->dev, &ifp->addr, &in6addr_linklocal_allrouters);
+		/* The wait after the last probe can be shorter */
+		addrconf_mod_rs_timer(idev, (idev->rs_probes ==
+					     idev->cnf.rtr_solicits) ?
+				      idev->cnf.rtr_solicit_delay :
+				      idev->cnf.rtr_solicit_interval);
 	} else {
-		spin_unlock(&ifp->lock);
 		/*
 		 * Note: we do not support deprecated "all on-link"
 		 * assumption any longer.
@@ -3152,8 +3160,8 @@ static void addrconf_rs_timer(unsigned long data)
 	}
 
 out:
-	read_unlock(&idev->lock);
-	in6_ifa_put(ifp);
+	write_unlock(&idev->lock);
+	in6_dev_put(idev);
 }
 
 /*
@@ -3169,8 +3177,8 @@ static void addrconf_dad_kick(struct inet6_ifaddr *ifp)
 	else
 		rand_num = net_random() % (idev->cnf.rtr_solicit_delay ? : 1);
 
-	ifp->probes = idev->cnf.dad_transmits;
-	addrconf_mod_timer(ifp, AC_DAD, rand_num);
+	ifp->dad_probes = idev->cnf.dad_transmits;
+	addrconf_mod_dad_timer(ifp, rand_num);
 }
 
 static void addrconf_dad_start(struct inet6_ifaddr *ifp)
@@ -3231,40 +3239,40 @@ static void addrconf_dad_timer(unsigned long data)
 	struct inet6_dev *idev = ifp->idev;
 	struct in6_addr mcaddr;
 
-	if (!ifp->probes && addrconf_dad_end(ifp))
+	if (!ifp->dad_probes && addrconf_dad_end(ifp))
 		goto out;
 
-	read_lock(&idev->lock);
+	write_lock(&idev->lock);
 	if (idev->dead || !(idev->if_flags & IF_READY)) {
-		read_unlock(&idev->lock);
+		write_unlock(&idev->lock);
 		goto out;
 	}
 
 	spin_lock(&ifp->lock);
 	if (ifp->state == INET6_IFADDR_STATE_DEAD) {
 		spin_unlock(&ifp->lock);
-		read_unlock(&idev->lock);
+		write_unlock(&idev->lock);
 		goto out;
 	}
 
-	if (ifp->probes == 0) {
+	if (ifp->dad_probes == 0) {
 		/*
 		 * DAD was successful
 		 */
 
 		ifp->flags &= ~(IFA_F_TENTATIVE|IFA_F_OPTIMISTIC|IFA_F_DADFAILED);
 		spin_unlock(&ifp->lock);
-		read_unlock(&idev->lock);
+		write_unlock(&idev->lock);
 
 		addrconf_dad_completed(ifp);
 
 		goto out;
 	}
 
-	ifp->probes--;
-	addrconf_mod_timer(ifp, AC_DAD, ifp->idev->nd_parms->retrans_time);
+	ifp->dad_probes--;
+	addrconf_mod_dad_timer(ifp, ifp->idev->nd_parms->retrans_time);
 	spin_unlock(&ifp->lock);
-	read_unlock(&idev->lock);
+	write_unlock(&idev->lock);
 
 	/* send a neighbour solicitation for our addr */
 	addrconf_addr_solict_mult(&ifp->addr, &mcaddr);
@@ -3276,6 +3284,9 @@ out:
 static void addrconf_dad_completed(struct inet6_ifaddr *ifp)
 {
 	struct net_device *dev = ifp->idev->dev;
+	struct in6_addr lladdr;
+
+	addrconf_del_dad_timer(ifp);
 
 	/*
 	 *	Configure the address for reception. Now it is valid.
@@ -3296,13 +3307,20 @@ static void addrconf_dad_completed(struct inet6_ifaddr *ifp)
 		 *	[...] as part of DAD [...] there is no need
 		 *	to delay again before sending the first RS
 		 */
-		ndisc_send_rs(ifp->idev->dev, &ifp->addr, &in6addr_linklocal_allrouters);
+		if (!ipv6_get_lladdr(dev, &lladdr, IFA_F_TENTATIVE))
+			ndisc_send_rs(dev, &lladdr,
+				      &in6addr_linklocal_allrouters);
+		else
+			return;
 
-		spin_lock_bh(&ifp->lock);
-		ifp->probes = 1;
+		write_lock_bh(&ifp->idev->lock);
+		spin_lock(&ifp->lock);
+		ifp->idev->rs_probes = 1;
 		ifp->idev->if_flags |= IF_RS_SENT;
-		addrconf_mod_timer(ifp, AC_RS, ifp->idev->cnf.rtr_solicit_interval);
-		spin_unlock_bh(&ifp->lock);
+		addrconf_mod_rs_timer(ifp->idev,
+				      ifp->idev->cnf.rtr_solicit_interval);
+		spin_unlock(&ifp->lock);
+		write_unlock_bh(&ifp->idev->lock);
 	}
 }
 
-- 
1.8.1.4
