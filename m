From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [GIT PULL net-next-2.6] IPv6 Updates
Date: Wed, 02 Jul 2008 12:39:57 +0900 (JST)
Message-ID: <20080702.123957.75682669.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:35989 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752887AbYGBDi4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2008 23:38:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

Please consider pulling following changes on top of commit
28f49d8fec19833672a6a813bfde0068fee50bc9
    Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/git/linville/wireless-next-2.6
available at
    git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-next.git net-next-2.6-v6ready-20080702

Regards,

--yoshfuji

HEADLINES
---------

    ipv6: Do not assign non-valid address on interface.
    ipv6: Do not forward packets with the unspecified source address.
    ipv6: Assume the loopback address in link-local scope.
    ipv6: Add disable_ipv6 sysctl to disable IPv6 operaion on specific interface.
    ipv6 addrconf: add accept_dad sysctl to control DAD operation.
    ipv6 route: Prefer outgoing interface with source address assigned.

DIFFSTAT
--------

 Documentation/networking/ip-sysctl.txt |   11 +++++++
 include/linux/ipv6.h                   |    4 ++
 net/ipv6/addrconf.c                    |   53 ++++++++++++++++++++++++++++++++
 net/ipv6/ip6_input.c                   |    3 +-
 net/ipv6/ip6_output.c                  |   10 +++++-
 net/ipv6/route.c                       |   32 +++++++++++++------
 6 files changed, 101 insertions(+), 12 deletions(-)

CHANGESETS
----------

commit 008f0e9d62b07f9e805ac5c04b70017ca400ab93
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Jun 25 16:26:47 2008 +0900

    ipv6: Do not assign non-valid address on interface.
    
    Check the type of the address when adding a new one on interface.
    - the unspecified address (::) is always disallowed (RFC4291 2.5.2)
    - the loopback address is disallowed unless the interface is (one of)
      loopback (RFC4291 2.5.3).
    - multicast addresses are disallowed.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 84127d8..8b6875f 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -578,6 +578,13 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr, int pfxlen,
 	struct rt6_info *rt;
 	int hash;
 	int err = 0;
+	int addr_type = ipv6_addr_type(addr);
+
+	if (addr_type == IPV6_ADDR_ANY ||
+	    addr_type & IPV6_ADDR_MULTICAST ||
+	    (!(idev->dev->flags & IFF_LOOPBACK) &&
+	     addr_type & IPV6_ADDR_LOOPBACK))
+		return ERR_PTR(-EADDRNOTAVAIL);
 
 	rcu_read_lock_bh();
 	if (idev->dead) {

---
commit 0f58910c07daed6004f0c1470e57e26ef124a24e
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Jun 25 16:55:26 2008 +0900

    ipv6: Do not forward packets with the unspecified source address.
    
    RFC4291 2.5.2.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index fd7cd1b..871bdec 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -498,7 +498,8 @@ int ip6_forward(struct sk_buff *skb)
 		int addrtype = ipv6_addr_type(&hdr->saddr);
 
 		/* This check is security critical. */
-		if (addrtype & (IPV6_ADDR_MULTICAST|IPV6_ADDR_LOOPBACK))
+		if (addrtype == IPV6_ADDR_ANY ||
+		    addrtype & (IPV6_ADDR_MULTICAST | IPV6_ADDR_LOOPBACK))
 			goto error;
 		if (addrtype & IPV6_ADDR_LINKLOCAL) {
 			icmpv6_send(skb, ICMPV6_DEST_UNREACH,

---
commit a1b2782aef0f82c1ee141a668b3668ef46582303
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Jun 25 16:58:17 2008 +0900

    ipv6: Assume the loopback address in link-local scope.
    
    Handle interface property strictly when looking up a route
    for the loopback address (RFC4291 2.5.3).
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 751e98f..dbad96c 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -228,7 +228,7 @@ static __inline__ int rt6_check_expired(const struct rt6_info *rt)
 static inline int rt6_need_strict(struct in6_addr *daddr)
 {
 	return (ipv6_addr_type(daddr) &
-		(IPV6_ADDR_MULTICAST | IPV6_ADDR_LINKLOCAL));
+		(IPV6_ADDR_MULTICAST | IPV6_ADDR_LINKLOCAL | IPV6_ADDR_LOOPBACK));
 }
 
 /*

---
commit 5350c087ed30ef916937e8fe764ba1256ccd4ef8
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Sat Jun 28 14:17:11 2008 +0900

    ipv6: Add disable_ipv6 sysctl to disable IPv6 operaion on specific interface.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 17a6e46..120f6a8 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1024,6 +1024,10 @@ max_addresses - INTEGER
 	autoconfigured addresses.
 	Default: 16
 
+disable_ipv6 - BOOLEAN
+	Disable IPv6 operation.
+	Default: FALSE (enable IPv6 operation)
+
 icmp/*:
 ratelimit - INTEGER
 	Limit the maximal rates for sending ICMPv6 packets.
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index cde056e..d9d7f9b 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -163,6 +163,7 @@ struct ipv6_devconf {
 #ifdef CONFIG_IPV6_MROUTE
 	__s32		mc_forwarding;
 #endif
+	__s32		disable_ipv6;
 	void		*sysctl;
 };
 
@@ -194,6 +195,7 @@ enum {
 	DEVCONF_OPTIMISTIC_DAD,
 	DEVCONF_ACCEPT_SOURCE_ROUTE,
 	DEVCONF_MC_FORWARDING,
+	DEVCONF_DISABLE_IPV6,
 	DEVCONF_MAX
 };
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 8b6875f..8c5cff5 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -183,6 +183,7 @@ struct ipv6_devconf ipv6_devconf __read_mostly = {
 #endif
 	.proxy_ndp		= 0,
 	.accept_source_route	= 0,	/* we do not accept RH0 by default. */
+	.disable_ipv6		= 0,
 };
 
 static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
@@ -215,6 +216,7 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 #endif
 	.proxy_ndp		= 0,
 	.accept_source_route	= 0,	/* we do not accept RH0 by default. */
+	.disable_ipv6		= 0,
 };
 
 /* IPv6 Wildcard Address and Loopback Address defined by RFC2553 */
@@ -3657,6 +3659,7 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 #ifdef CONFIG_IPV6_MROUTE
 	array[DEVCONF_MC_FORWARDING] = cnf->mc_forwarding;
 #endif
+	array[DEVCONF_DISABLE_IPV6] = cnf->disable_ipv6;
 }
 
 static inline size_t inet6_if_nlmsg_size(void)
@@ -4216,6 +4219,14 @@ static struct addrconf_sysctl_table
 		},
 #endif
 		{
+			.ctl_name	=	CTL_UNNUMBERED,
+			.procname	=	"disable_ipv6",
+			.data		=	&ipv6_devconf.disable_ipv6,
+			.maxlen		=	sizeof(int),
+			.mode		=	0644,
+			.proc_handler	=	&proc_dointvec,
+		},
+		{
 			.ctl_name	=	0,	/* sentinel */
 		}
 	},
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index 34e5a96..ea81c61 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -71,7 +71,8 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
 
 	IP6_INC_STATS_BH(idev, IPSTATS_MIB_INRECEIVES);
 
-	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL) {
+	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL ||
+	    !idev || unlikely(idev->cnf.disable_ipv6)) {
 		IP6_INC_STATS_BH(idev, IPSTATS_MIB_INDISCARDS);
 		rcu_read_unlock();
 		goto out;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 871bdec..0981c1e 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -173,6 +173,13 @@ static inline int ip6_skb_dst_mtu(struct sk_buff *skb)
 
 int ip6_output(struct sk_buff *skb)
 {
+	struct inet6_dev *idev = ip6_dst_idev(skb->dst);
+	if (unlikely(idev->cnf.disable_ipv6)) {
+		IP6_INC_STATS(idev, IPSTATS_MIB_OUTDISCARDS);
+		kfree_skb(skb);
+		return 0;
+	}
+
 	if ((skb->len > ip6_skb_dst_mtu(skb) && !skb_is_gso(skb)) ||
 				dst_allfrag(skb->dst))
 		return ip6_fragment(skb, ip6_output2);

---
commit e6a359e650a738f4e2387ca5570c546e03b7e29d
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Sat Jun 28 14:18:38 2008 +0900

    ipv6 addrconf: add accept_dad sysctl to control DAD operation.
    
    - If 0, disable DAD.
    - If 1, perform DAD (default).
    - If >1, perform DAD and disable IPv6 operation if DAD for MAC-based
      link-local address has been failed (RFC4862 5.4.5).
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 120f6a8..2e5111f 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1028,6 +1028,13 @@ disable_ipv6 - BOOLEAN
 	Disable IPv6 operation.
 	Default: FALSE (enable IPv6 operation)
 
+accept_dad - INTEGER
+	Whether to accept DAD (Duplicate Address Detection).
+	0: Disable DAD
+	1: Enable DAD (default)
+	2: Enable DAD, and disable IPv6 operation if MAC-based duplicate
+	   link-local address has been found.
+
 icmp/*:
 ratelimit - INTEGER
 	Limit the maximal rates for sending ICMPv6 packets.
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index d9d7f9b..391ad08 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -164,6 +164,7 @@ struct ipv6_devconf {
 	__s32		mc_forwarding;
 #endif
 	__s32		disable_ipv6;
+	__s32		accept_dad;
 	void		*sysctl;
 };
 
@@ -196,6 +197,7 @@ enum {
 	DEVCONF_ACCEPT_SOURCE_ROUTE,
 	DEVCONF_MC_FORWARDING,
 	DEVCONF_DISABLE_IPV6,
+	DEVCONF_ACCEPT_DAD,
 	DEVCONF_MAX
 };
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 8c5cff5..2ec73e6 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -119,6 +119,7 @@ static void ipv6_regen_rndid(unsigned long data);
 static int desync_factor = MAX_DESYNC_FACTOR * HZ;
 #endif
 
+static int ipv6_generate_eui64(u8 *eui, struct net_device *dev);
 static int ipv6_count_addresses(struct inet6_dev *idev);
 
 /*
@@ -184,6 +185,7 @@ struct ipv6_devconf ipv6_devconf __read_mostly = {
 	.proxy_ndp		= 0,
 	.accept_source_route	= 0,	/* we do not accept RH0 by default. */
 	.disable_ipv6		= 0,
+	.accept_dad		= 1,
 };
 
 static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
@@ -217,6 +219,7 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 	.proxy_ndp		= 0,
 	.accept_source_route	= 0,	/* we do not accept RH0 by default. */
 	.disable_ipv6		= 0,
+	.accept_dad		= 1,
 };
 
 /* IPv6 Wildcard Address and Loopback Address defined by RFC2553 */
@@ -380,6 +383,9 @@ static struct inet6_dev * ipv6_add_dev(struct net_device *dev)
 	 */
 	in6_dev_hold(ndev);
 
+	if (dev->flags & (IFF_NOARP | IFF_LOOPBACK))
+		ndev->cnf.accept_dad = -1;
+
 #if defined(CONFIG_IPV6_SIT) || defined(CONFIG_IPV6_SIT_MODULE)
 	if (dev->type == ARPHRD_SIT && (dev->priv_flags & IFF_ISATAP)) {
 		printk(KERN_INFO
@@ -1421,6 +1427,20 @@ static void addrconf_dad_stop(struct inet6_ifaddr *ifp)
 
 void addrconf_dad_failure(struct inet6_ifaddr *ifp)
 {
+	struct inet6_dev *idev = ifp->idev;
+	if (idev->cnf.accept_dad > 1 && !idev->cnf.disable_ipv6) {
+		struct in6_addr addr;
+
+		addr.s6_addr32[0] = htonl(0xfe800000);
+		addr.s6_addr32[1] = 0;
+
+		if (!ipv6_generate_eui64(addr.s6_addr + 8, idev->dev) &&
+		    ipv6_addr_equal(&ifp->addr, &addr)) {
+			/* DAD failed for link-local based on MAC address */
+			idev->cnf.disable_ipv6 = 1;
+		}
+	}
+
 	if (net_ratelimit())
 		printk(KERN_INFO "%s: duplicate address detected!\n", ifp->idev->dev->name);
 	addrconf_dad_stop(ifp);
@@ -2753,6 +2773,7 @@ static void addrconf_dad_start(struct inet6_ifaddr *ifp, u32 flags)
 	spin_lock_bh(&ifp->lock);
 
 	if (dev->flags&(IFF_NOARP|IFF_LOOPBACK) ||
+	    idev->cnf.accept_dad < 1 ||
 	    !(ifp->flags&IFA_F_TENTATIVE) ||
 	    ifp->flags & IFA_F_NODAD) {
 		ifp->flags &= ~(IFA_F_TENTATIVE|IFA_F_OPTIMISTIC);
@@ -2800,6 +2821,11 @@ static void addrconf_dad_timer(unsigned long data)
 		read_unlock_bh(&idev->lock);
 		goto out;
 	}
+	if (idev->cnf.accept_dad > 1 && idev->cnf.disable_ipv6) {
+		read_unlock_bh(&idev->lock);
+		addrconf_dad_failure(ifp);
+		return;
+	}
 	spin_lock_bh(&ifp->lock);
 	if (ifp->probes == 0) {
 		/*
@@ -3660,6 +3686,7 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 	array[DEVCONF_MC_FORWARDING] = cnf->mc_forwarding;
 #endif
 	array[DEVCONF_DISABLE_IPV6] = cnf->disable_ipv6;
+	array[DEVCONF_ACCEPT_DAD] = cnf->accept_dad;
 }
 
 static inline size_t inet6_if_nlmsg_size(void)
@@ -4227,6 +4254,14 @@ static struct addrconf_sysctl_table
 			.proc_handler	=	&proc_dointvec,
 		},
 		{
+			.ctl_name	=	CTL_UNNUMBERED,
+			.procname	=	"accept_dad",
+			.data		=	&ipv6_devconf.accept_dad,
+			.maxlen		=	sizeof(int),
+			.mode		=	0644,
+			.proc_handler	=	&proc_dointvec,
+		},
+		{
 			.ctl_name	=	0,	/* sentinel */
 		}
 	},

---
commit 4194d1bf543d99630b4ac444c6392df515e20e10
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Sat Jun 28 14:23:32 2008 +0900

    ipv6 route: Prefer outgoing interface with source address assigned.
    
    Outgoing interface is selected by the route decision if unspecified.
    Let's prefer routes via interface(s) with the address assigned if we
    have multiple routes with same cost.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index dbad96c..b02dd28 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -237,17 +237,29 @@ static inline int rt6_need_strict(struct in6_addr *daddr)
 
 static inline struct rt6_info *rt6_device_match(struct net *net,
 						    struct rt6_info *rt,
+						    struct in6_addr *saddr,
 						    int oif,
 						    int flags)
 {
 	struct rt6_info *local = NULL;
 	struct rt6_info *sprt;
 
-	if (oif) {
-		for (sprt = rt; sprt; sprt = sprt->u.dst.rt6_next) {
-			struct net_device *dev = sprt->rt6i_dev;
+	if (!oif && ipv6_addr_any(saddr))
+		saddr = NULL;
+
+	for (sprt = rt; sprt; sprt = sprt->u.dst.rt6_next) {
+		struct net_device *dev = sprt->rt6i_dev;
+
+		if (oif) {
 			if (dev->ifindex == oif)
 				return sprt;
+		} else {
+			if (saddr && ipv6_chk_addr(net, saddr, dev,
+						   flags & RT6_LOOKUP_F_IFACE))
+				return sprt;
+		}
+
+		if (oif) {
 			if (dev->flags & IFF_LOOPBACK) {
 				if (sprt->rt6i_idev == NULL ||
 				    sprt->rt6i_idev->dev->ifindex != oif) {
@@ -259,13 +271,13 @@ static inline struct rt6_info *rt6_device_match(struct net *net,
 				}
 				local = sprt;
 			}
-		}
 
-		if (local)
-			return local;
+			if (local)
+				return local;
 
-		if (flags & RT6_LOOKUP_F_IFACE)
-			return net->ipv6.ip6_null_entry;
+			if (flags & RT6_LOOKUP_F_IFACE)
+				return net->ipv6.ip6_null_entry;
+		}
 	}
 	return rt;
 }
@@ -539,7 +551,7 @@ static struct rt6_info *ip6_pol_route_lookup(struct net *net,
 	fn = fib6_lookup(&table->tb6_root, &fl->fl6_dst, &fl->fl6_src);
 restart:
 	rt = fn->leaf;
-	rt = rt6_device_match(net, rt, fl->oif, flags);
+	rt = rt6_device_match(net, rt, &fl->fl6_src, fl->oif, flags);
 	BACKTRACK(net, &fl->fl6_src);
 out:
 	dst_use(&rt->u.dst, jiffies);

---
commit 008f0e9d62b07f9e805ac5c04b70017ca400ab93
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Jun 25 16:26:47 2008 +0900

    ipv6: Do not assign non-valid address on interface.
    
    Check the type of the address when adding a new one on interface.
    - the unspecified address (::) is always disallowed (RFC4291 2.5.2)
    - the loopback address is disallowed unless the interface is (one of)
      loopback (RFC4291 2.5.3).
    - multicast addresses are disallowed.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 84127d8..8b6875f 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -578,6 +578,13 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr, int pfxlen,
 	struct rt6_info *rt;
 	int hash;
 	int err = 0;
+	int addr_type = ipv6_addr_type(addr);
+
+	if (addr_type == IPV6_ADDR_ANY ||
+	    addr_type & IPV6_ADDR_MULTICAST ||
+	    (!(idev->dev->flags & IFF_LOOPBACK) &&
+	     addr_type & IPV6_ADDR_LOOPBACK))
+		return ERR_PTR(-EADDRNOTAVAIL);
 
 	rcu_read_lock_bh();
 	if (idev->dead) {

---
commit 0f58910c07daed6004f0c1470e57e26ef124a24e
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Jun 25 16:55:26 2008 +0900

    ipv6: Do not forward packets with the unspecified source address.
    
    RFC4291 2.5.2.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index fd7cd1b..871bdec 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -498,7 +498,8 @@ int ip6_forward(struct sk_buff *skb)
 		int addrtype = ipv6_addr_type(&hdr->saddr);
 
 		/* This check is security critical. */
-		if (addrtype & (IPV6_ADDR_MULTICAST|IPV6_ADDR_LOOPBACK))
+		if (addrtype == IPV6_ADDR_ANY ||
+		    addrtype & (IPV6_ADDR_MULTICAST | IPV6_ADDR_LOOPBACK))
 			goto error;
 		if (addrtype & IPV6_ADDR_LINKLOCAL) {
 			icmpv6_send(skb, ICMPV6_DEST_UNREACH,

---
commit a1b2782aef0f82c1ee141a668b3668ef46582303
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Jun 25 16:58:17 2008 +0900

    ipv6: Assume the loopback address in link-local scope.
    
    Handle interface property strictly when looking up a route
    for the loopback address (RFC4291 2.5.3).
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 751e98f..dbad96c 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -228,7 +228,7 @@ static __inline__ int rt6_check_expired(const struct rt6_info *rt)
 static inline int rt6_need_strict(struct in6_addr *daddr)
 {
 	return (ipv6_addr_type(daddr) &
-		(IPV6_ADDR_MULTICAST | IPV6_ADDR_LINKLOCAL));
+		(IPV6_ADDR_MULTICAST | IPV6_ADDR_LINKLOCAL | IPV6_ADDR_LOOPBACK));
 }
 
 /*

---
commit 5350c087ed30ef916937e8fe764ba1256ccd4ef8
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Sat Jun 28 14:17:11 2008 +0900

    ipv6: Add disable_ipv6 sysctl to disable IPv6 operaion on specific interface.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 17a6e46..120f6a8 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1024,6 +1024,10 @@ max_addresses - INTEGER
 	autoconfigured addresses.
 	Default: 16
 
+disable_ipv6 - BOOLEAN
+	Disable IPv6 operation.
+	Default: FALSE (enable IPv6 operation)
+
 icmp/*:
 ratelimit - INTEGER
 	Limit the maximal rates for sending ICMPv6 packets.
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index cde056e..d9d7f9b 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -163,6 +163,7 @@ struct ipv6_devconf {
 #ifdef CONFIG_IPV6_MROUTE
 	__s32		mc_forwarding;
 #endif
+	__s32		disable_ipv6;
 	void		*sysctl;
 };
 
@@ -194,6 +195,7 @@ enum {
 	DEVCONF_OPTIMISTIC_DAD,
 	DEVCONF_ACCEPT_SOURCE_ROUTE,
 	DEVCONF_MC_FORWARDING,
+	DEVCONF_DISABLE_IPV6,
 	DEVCONF_MAX
 };
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 8b6875f..8c5cff5 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -183,6 +183,7 @@ struct ipv6_devconf ipv6_devconf __read_mostly = {
 #endif
 	.proxy_ndp		= 0,
 	.accept_source_route	= 0,	/* we do not accept RH0 by default. */
+	.disable_ipv6		= 0,
 };
 
 static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
@@ -215,6 +216,7 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 #endif
 	.proxy_ndp		= 0,
 	.accept_source_route	= 0,	/* we do not accept RH0 by default. */
+	.disable_ipv6		= 0,
 };
 
 /* IPv6 Wildcard Address and Loopback Address defined by RFC2553 */
@@ -3657,6 +3659,7 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 #ifdef CONFIG_IPV6_MROUTE
 	array[DEVCONF_MC_FORWARDING] = cnf->mc_forwarding;
 #endif
+	array[DEVCONF_DISABLE_IPV6] = cnf->disable_ipv6;
 }
 
 static inline size_t inet6_if_nlmsg_size(void)
@@ -4216,6 +4219,14 @@ static struct addrconf_sysctl_table
 		},
 #endif
 		{
+			.ctl_name	=	CTL_UNNUMBERED,
+			.procname	=	"disable_ipv6",
+			.data		=	&ipv6_devconf.disable_ipv6,
+			.maxlen		=	sizeof(int),
+			.mode		=	0644,
+			.proc_handler	=	&proc_dointvec,
+		},
+		{
 			.ctl_name	=	0,	/* sentinel */
 		}
 	},
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index 34e5a96..ea81c61 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -71,7 +71,8 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
 
 	IP6_INC_STATS_BH(idev, IPSTATS_MIB_INRECEIVES);
 
-	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL) {
+	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL ||
+	    !idev || unlikely(idev->cnf.disable_ipv6)) {
 		IP6_INC_STATS_BH(idev, IPSTATS_MIB_INDISCARDS);
 		rcu_read_unlock();
 		goto out;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 871bdec..0981c1e 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -173,6 +173,13 @@ static inline int ip6_skb_dst_mtu(struct sk_buff *skb)
 
 int ip6_output(struct sk_buff *skb)
 {
+	struct inet6_dev *idev = ip6_dst_idev(skb->dst);
+	if (unlikely(idev->cnf.disable_ipv6)) {
+		IP6_INC_STATS(idev, IPSTATS_MIB_OUTDISCARDS);
+		kfree_skb(skb);
+		return 0;
+	}
+
 	if ((skb->len > ip6_skb_dst_mtu(skb) && !skb_is_gso(skb)) ||
 				dst_allfrag(skb->dst))
 		return ip6_fragment(skb, ip6_output2);

---
commit e6a359e650a738f4e2387ca5570c546e03b7e29d
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Sat Jun 28 14:18:38 2008 +0900

    ipv6 addrconf: add accept_dad sysctl to control DAD operation.
    
    - If 0, disable DAD.
    - If 1, perform DAD (default).
    - If >1, perform DAD and disable IPv6 operation if DAD for MAC-based
      link-local address has been failed (RFC4862 5.4.5).
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 120f6a8..2e5111f 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1028,6 +1028,13 @@ disable_ipv6 - BOOLEAN
 	Disable IPv6 operation.
 	Default: FALSE (enable IPv6 operation)
 
+accept_dad - INTEGER
+	Whether to accept DAD (Duplicate Address Detection).
+	0: Disable DAD
+	1: Enable DAD (default)
+	2: Enable DAD, and disable IPv6 operation if MAC-based duplicate
+	   link-local address has been found.
+
 icmp/*:
 ratelimit - INTEGER
 	Limit the maximal rates for sending ICMPv6 packets.
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index d9d7f9b..391ad08 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -164,6 +164,7 @@ struct ipv6_devconf {
 	__s32		mc_forwarding;
 #endif
 	__s32		disable_ipv6;
+	__s32		accept_dad;
 	void		*sysctl;
 };
 
@@ -196,6 +197,7 @@ enum {
 	DEVCONF_ACCEPT_SOURCE_ROUTE,
 	DEVCONF_MC_FORWARDING,
 	DEVCONF_DISABLE_IPV6,
+	DEVCONF_ACCEPT_DAD,
 	DEVCONF_MAX
 };
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 8c5cff5..2ec73e6 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -119,6 +119,7 @@ static void ipv6_regen_rndid(unsigned long data);
 static int desync_factor = MAX_DESYNC_FACTOR * HZ;
 #endif
 
+static int ipv6_generate_eui64(u8 *eui, struct net_device *dev);
 static int ipv6_count_addresses(struct inet6_dev *idev);
 
 /*
@@ -184,6 +185,7 @@ struct ipv6_devconf ipv6_devconf __read_mostly = {
 	.proxy_ndp		= 0,
 	.accept_source_route	= 0,	/* we do not accept RH0 by default. */
 	.disable_ipv6		= 0,
+	.accept_dad		= 1,
 };
 
 static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
@@ -217,6 +219,7 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 	.proxy_ndp		= 0,
 	.accept_source_route	= 0,	/* we do not accept RH0 by default. */
 	.disable_ipv6		= 0,
+	.accept_dad		= 1,
 };
 
 /* IPv6 Wildcard Address and Loopback Address defined by RFC2553 */
@@ -380,6 +383,9 @@ static struct inet6_dev * ipv6_add_dev(struct net_device *dev)
 	 */
 	in6_dev_hold(ndev);
 
+	if (dev->flags & (IFF_NOARP | IFF_LOOPBACK))
+		ndev->cnf.accept_dad = -1;
+
 #if defined(CONFIG_IPV6_SIT) || defined(CONFIG_IPV6_SIT_MODULE)
 	if (dev->type == ARPHRD_SIT && (dev->priv_flags & IFF_ISATAP)) {
 		printk(KERN_INFO
@@ -1421,6 +1427,20 @@ static void addrconf_dad_stop(struct inet6_ifaddr *ifp)
 
 void addrconf_dad_failure(struct inet6_ifaddr *ifp)
 {
+	struct inet6_dev *idev = ifp->idev;
+	if (idev->cnf.accept_dad > 1 && !idev->cnf.disable_ipv6) {
+		struct in6_addr addr;
+
+		addr.s6_addr32[0] = htonl(0xfe800000);
+		addr.s6_addr32[1] = 0;
+
+		if (!ipv6_generate_eui64(addr.s6_addr + 8, idev->dev) &&
+		    ipv6_addr_equal(&ifp->addr, &addr)) {
+			/* DAD failed for link-local based on MAC address */
+			idev->cnf.disable_ipv6 = 1;
+		}
+	}
+
 	if (net_ratelimit())
 		printk(KERN_INFO "%s: duplicate address detected!\n", ifp->idev->dev->name);
 	addrconf_dad_stop(ifp);
@@ -2753,6 +2773,7 @@ static void addrconf_dad_start(struct inet6_ifaddr *ifp, u32 flags)
 	spin_lock_bh(&ifp->lock);
 
 	if (dev->flags&(IFF_NOARP|IFF_LOOPBACK) ||
+	    idev->cnf.accept_dad < 1 ||
 	    !(ifp->flags&IFA_F_TENTATIVE) ||
 	    ifp->flags & IFA_F_NODAD) {
 		ifp->flags &= ~(IFA_F_TENTATIVE|IFA_F_OPTIMISTIC);
@@ -2800,6 +2821,11 @@ static void addrconf_dad_timer(unsigned long data)
 		read_unlock_bh(&idev->lock);
 		goto out;
 	}
+	if (idev->cnf.accept_dad > 1 && idev->cnf.disable_ipv6) {
+		read_unlock_bh(&idev->lock);
+		addrconf_dad_failure(ifp);
+		return;
+	}
 	spin_lock_bh(&ifp->lock);
 	if (ifp->probes == 0) {
 		/*
@@ -3660,6 +3686,7 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 	array[DEVCONF_MC_FORWARDING] = cnf->mc_forwarding;
 #endif
 	array[DEVCONF_DISABLE_IPV6] = cnf->disable_ipv6;
+	array[DEVCONF_ACCEPT_DAD] = cnf->accept_dad;
 }
 
 static inline size_t inet6_if_nlmsg_size(void)
@@ -4227,6 +4254,14 @@ static struct addrconf_sysctl_table
 			.proc_handler	=	&proc_dointvec,
 		},
 		{
+			.ctl_name	=	CTL_UNNUMBERED,
+			.procname	=	"accept_dad",
+			.data		=	&ipv6_devconf.accept_dad,
+			.maxlen		=	sizeof(int),
+			.mode		=	0644,
+			.proc_handler	=	&proc_dointvec,
+		},
+		{
 			.ctl_name	=	0,	/* sentinel */
 		}
 	},

---
commit 4194d1bf543d99630b4ac444c6392df515e20e10
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Sat Jun 28 14:23:32 2008 +0900

    ipv6 route: Prefer outgoing interface with source address assigned.
    
    Outgoing interface is selected by the route decision if unspecified.
    Let's prefer routes via interface(s) with the address assigned if we
    have multiple routes with same cost.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index dbad96c..b02dd28 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -237,17 +237,29 @@ static inline int rt6_need_strict(struct in6_addr *daddr)
 
 static inline struct rt6_info *rt6_device_match(struct net *net,
 						    struct rt6_info *rt,
+						    struct in6_addr *saddr,
 						    int oif,
 						    int flags)
 {
 	struct rt6_info *local = NULL;
 	struct rt6_info *sprt;
 
-	if (oif) {
-		for (sprt = rt; sprt; sprt = sprt->u.dst.rt6_next) {
-			struct net_device *dev = sprt->rt6i_dev;
+	if (!oif && ipv6_addr_any(saddr))
+		saddr = NULL;
+
+	for (sprt = rt; sprt; sprt = sprt->u.dst.rt6_next) {
+		struct net_device *dev = sprt->rt6i_dev;
+
+		if (oif) {
 			if (dev->ifindex == oif)
 				return sprt;
+		} else {
+			if (saddr && ipv6_chk_addr(net, saddr, dev,
+						   flags & RT6_LOOKUP_F_IFACE))
+				return sprt;
+		}
+
+		if (oif) {
 			if (dev->flags & IFF_LOOPBACK) {
 				if (sprt->rt6i_idev == NULL ||
 				    sprt->rt6i_idev->dev->ifindex != oif) {
@@ -259,13 +271,13 @@ static inline struct rt6_info *rt6_device_match(struct net *net,
 				}
 				local = sprt;
 			}
-		}
 
-		if (local)
-			return local;
+			if (local)
+				return local;
 
-		if (flags & RT6_LOOKUP_F_IFACE)
-			return net->ipv6.ip6_null_entry;
+			if (flags & RT6_LOOKUP_F_IFACE)
+				return net->ipv6.ip6_null_entry;
+		}
 	}
 	return rt;
 }
@@ -539,7 +551,7 @@ static struct rt6_info *ip6_pol_route_lookup(struct net *net,
 	fn = fib6_lookup(&table->tb6_root, &fl->fl6_dst, &fl->fl6_src);
 restart:
 	rt = fn->leaf;
-	rt = rt6_device_match(net, rt, fl->oif, flags);
+	rt = rt6_device_match(net, rt, &fl->fl6_src, fl->oif, flags);
 	BACKTRACK(net, &fl->fl6_src);
 out:
 	dst_use(&rt->u.dst, jiffies);

---

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
