From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [GIT PULL] IPv6 Updates (take 2)
Date: Thu, 03 Jul 2008 18:07:55 +0900 (JST)
Message-ID: <20080703.180755.18521463.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:36077 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757468AbYGCM3S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 08:29:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Please consider pulling following (most IPv6) changes since commit
b4653e99450693b75a3c6c8ff4f070164f12815e
    niu: Add support for rx flow hash configuration.
available at:
    git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-next.git net-next-2.6-v6ready-20080703

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
    ipv6: Do cleanup for ip6_mr_init.
    ipv4: Do cleanup for ip_mr_init
    ipv4,ipv6 mroute: Add some helper inline functions to remove ugly ifdefs.

DIFFSTAT
--------

 Documentation/networking/ip-sysctl.txt |   11 +++++++
 include/linux/igmp.h                   |    1 -
 include/linux/ipv6.h                   |    4 ++
 include/linux/mroute.h                 |   28 ++++++++++++++++-
 include/linux/mroute6.h                |   35 +++++++++++++++++++++
 net/ipv4/af_inet.c                     |    5 ++-
 net/ipv4/ipmr.c                        |   28 ++++++++++++++---
 net/ipv6/addrconf.c                    |   53 ++++++++++++++++++++++++++++++++
 net/ipv6/af_inet6.c                    |   11 ++++---
 net/ipv6/ip6_input.c                   |    3 +-
 net/ipv6/ip6_output.c                  |   10 +++++-
 net/ipv6/ip6mr.c                       |   38 ++++++++++++++++++++---
 net/ipv6/route.c                       |   22 ++++++++++---
 13 files changed, 223 insertions(+), 26 deletions(-)

CHANGESETS
----------

commit d68b82705a4a754e5773f412c6b8f1e65259bc8b
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
commit f81b2e7d8cf8c6a52b7a5224c3b89cee5aeb6811
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
commit 5ce83afaac956238c3c25f60a899c511e9d8cbf4
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
commit 778d80be52699596bf70e0eb0761cf5e1e46088d
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Sat Jun 28 14:17:11 2008 +0900

    ipv6: Add disable_ipv6 sysctl to disable IPv6 operaion on specific interface.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 71c7bea..dae980e 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1025,6 +1025,10 @@ max_addresses - INTEGER
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
commit 1b34be74cbf18f5d58cc85c7c4afcd9f7d74accd
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Sat Jun 28 14:18:38 2008 +0900

    ipv6 addrconf: add accept_dad sysctl to control DAD operation.
    
    - If 0, disable DAD.
    - If 1, perform DAD (default).
    - If >1, perform DAD and disable IPv6 operation if DAD for MAC-based
      link-local address has been failed (RFC4862 5.4.5).
    
    We do not follow RFC4862 by default.  Refer to the netdev thread entitled
    "Linux IPv6 DAD not full conform to RFC 4862 ?"
    	http://www.spinics.net/lists/netdev/msg52027.html
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index dae980e..72f6d52 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1029,6 +1029,13 @@ disable_ipv6 - BOOLEAN
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
commit dd3abc4ef52597ec8268274222574b2700ba3ded
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Jul 2 18:30:18 2008 +0900

    ipv6 route: Prefer outgoing interface with source address assigned.
    
    Outgoing interface is selected by the route decision if unspecified.
    Let's prefer routes via interface(s) with the address assigned if we
    have multiple routes with same cost.
    With help from Naohiro Ooiwa <nooiwa@miraclelinux.com>.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index dbad96c..5d6c166 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -237,15 +237,20 @@ static inline int rt6_need_strict(struct in6_addr *daddr)
 
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
+		goto out;
+
+	for (sprt = rt; sprt; sprt = sprt->u.dst.rt6_next) {
+		struct net_device *dev = sprt->rt6i_dev;
+
+		if (oif) {
 			if (dev->ifindex == oif)
 				return sprt;
 			if (dev->flags & IFF_LOOPBACK) {
@@ -259,14 +264,21 @@ static inline struct rt6_info *rt6_device_match(struct net *net,
 				}
 				local = sprt;
 			}
+		} else {
+			if (ipv6_chk_addr(net, saddr, dev,
+					  flags & RT6_LOOKUP_F_IFACE))
+				return sprt;
 		}
+	}
 
+	if (oif) {
 		if (local)
 			return local;
 
 		if (flags & RT6_LOOKUP_F_IFACE)
 			return net->ipv6.ip6_null_entry;
 	}
+out:
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
commit 623d1a1af77bd52a389c6eda5920e28eb2ee468b
Author: Wang Chen <wangchen@cn.fujitsu.com>
Date:   Thu Jul 3 12:13:30 2008 +0800

    ipv6: Do cleanup for ip6_mr_init.
    
    If do not do it, we will get following issues:
    1. Leaving junks after inet6_init failing halfway.
    2. Leaving proc and notifier junks after ipv6 modules unloading.
    
    Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/linux/mroute6.h b/include/linux/mroute6.h
index e798959..4c4d6f5 100644
--- a/include/linux/mroute6.h
+++ b/include/linux/mroute6.h
@@ -135,7 +135,8 @@ extern int ip6_mroute_setsockopt(struct sock *, int, char __user *, int);
 extern int ip6_mroute_getsockopt(struct sock *, int, char __user *, int __user *);
 extern int ip6_mr_input(struct sk_buff *skb);
 extern int ip6mr_ioctl(struct sock *sk, int cmd, void __user *arg);
-extern void ip6_mr_init(void);
+extern int ip6_mr_init(void);
+extern void ip6_mr_cleanup(void);
 
 struct mif_device
 {
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 3ce8d2f..6b39af1 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -953,7 +953,9 @@ static int __init inet6_init(void)
 	if (err)
 		goto icmp_fail;
 #ifdef CONFIG_IPV6_MROUTE
-	ip6_mr_init();
+	err = ip6_mr_init();
+	if (err)
+		goto ipmr_fail;
 #endif
 	err = ndisc_init();
 	if (err)
@@ -1057,6 +1059,10 @@ netfilter_fail:
 igmp_fail:
 	ndisc_cleanup();
 ndisc_fail:
+#ifdef CONFIG_IPV6_MROUTE
+	ip6_mr_cleanup();
+ipmr_fail:
+#endif
 	icmpv6_cleanup();
 icmp_fail:
 	unregister_pernet_subsys(&inet6_net_ops);
@@ -1111,6 +1117,9 @@ static void __exit inet6_exit(void)
 	ipv6_netfilter_fini();
 	igmp6_cleanup();
 	ndisc_cleanup();
+#ifdef CONFIG_IPV6_MROUTE
+	ip6_mr_cleanup();
+#endif
 	icmpv6_cleanup();
 	rawv6_exit();
 
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 90e7630..cfac26d 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -948,23 +948,51 @@ static struct notifier_block ip6_mr_notifier = {
  *	Setup for IP multicast routing
  */
 
-void __init ip6_mr_init(void)
+int __init ip6_mr_init(void)
 {
+	int err;
+
 	mrt_cachep = kmem_cache_create("ip6_mrt_cache",
 				       sizeof(struct mfc6_cache),
 				       0, SLAB_HWCACHE_ALIGN,
 				       NULL);
 	if (!mrt_cachep)
-		panic("cannot allocate ip6_mrt_cache");
+		return -ENOMEM;
 
 	setup_timer(&ipmr_expire_timer, ipmr_expire_process, 0);
-	register_netdevice_notifier(&ip6_mr_notifier);
+	err = register_netdevice_notifier(&ip6_mr_notifier);
+	if (err)
+		goto reg_notif_fail;
+#ifdef CONFIG_PROC_FS
+	err = -ENOMEM;
+	if (!proc_net_fops_create(&init_net, "ip6_mr_vif", 0, &ip6mr_vif_fops))
+		goto proc_vif_fail;
+	if (!proc_net_fops_create(&init_net, "ip6_mr_cache",
+				     0, &ip6mr_mfc_fops))
+		goto proc_cache_fail;
+#endif
+	return 0;
+reg_notif_fail:
+	kmem_cache_destroy(mrt_cachep);
 #ifdef CONFIG_PROC_FS
-	proc_net_fops_create(&init_net, "ip6_mr_vif", 0, &ip6mr_vif_fops);
-	proc_net_fops_create(&init_net, "ip6_mr_cache", 0, &ip6mr_mfc_fops);
+proc_vif_fail:
+	unregister_netdevice_notifier(&ip6_mr_notifier);
+proc_cache_fail:
+	proc_net_remove(&init_net, "ip6_mr_vif");
 #endif
+	return err;
 }
 
+void ip6_mr_cleanup(void)
+{
+#ifdef CONFIG_PROC_FS
+	proc_net_remove(&init_net, "ip6_mr_cache");
+	proc_net_remove(&init_net, "ip6_mr_vif");
+#endif
+	unregister_netdevice_notifier(&ip6_mr_notifier);
+	del_timer(&ipmr_expire_timer);
+	kmem_cache_destroy(mrt_cachep);
+}
 
 static int ip6mr_mfc_add(struct mf6cctl *mfc, int mrtsock)
 {

---
commit 03d2f897e9fb3218989baa2139a951ce7f5414bf
Author: Wang Chen <wangchen@cn.fujitsu.com>
Date:   Thu Jul 3 12:13:36 2008 +0800

    ipv4: Do cleanup for ip_mr_init
    
    Same as ip6_mr_init(), make ip_mr_init() return errno if fails.
    But do not do error handling in inet_init(), just print a msg.
    
    Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/linux/igmp.h b/include/linux/igmp.h
index f5a1a0d..7bb3c09 100644
--- a/include/linux/igmp.h
+++ b/include/linux/igmp.h
@@ -228,7 +228,6 @@ extern int ip_mc_msfget(struct sock *sk, struct ip_msfilter *msf,
 extern int ip_mc_gsfget(struct sock *sk, struct group_filter *gsf,
 		struct group_filter __user *optval, int __user *optlen);
 extern int ip_mc_sf_allow(struct sock *sk, __be32 local, __be32 rmt, int dif);
-extern void ip_mr_init(void);
 extern void ip_mc_init_dev(struct in_device *);
 extern void ip_mc_destroy_dev(struct in_device *);
 extern void ip_mc_up(struct in_device *);
diff --git a/include/linux/mroute.h b/include/linux/mroute.h
index de4decf..df8efd4 100644
--- a/include/linux/mroute.h
+++ b/include/linux/mroute.h
@@ -147,8 +147,7 @@ static inline int ip_mroute_opt(int opt)
 extern int ip_mroute_setsockopt(struct sock *, int, char __user *, int);
 extern int ip_mroute_getsockopt(struct sock *, int, char __user *, int __user *);
 extern int ipmr_ioctl(struct sock *sk, int cmd, void __user *arg);
-extern void ip_mr_init(void);
-
+extern int ip_mr_init(void);
 
 struct vif_device
 {
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 42bd24b..dc41133 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1479,14 +1479,15 @@ static int __init inet_init(void)
 	 *	Initialise the multicast router
 	 */
 #if defined(CONFIG_IP_MROUTE)
-	ip_mr_init();
+	if (ip_mr_init())
+		printk(KERN_CRIT "inet_init: Cannot init ipv4 mroute\n");
 #endif
 	/*
 	 *	Initialise per-cpu ipv4 mibs
 	 */
 
 	if (init_ipv4_mibs())
-		printk(KERN_CRIT "inet_init: Cannot init ipv4 mibs\n"); ;
+		printk(KERN_CRIT "inet_init: Cannot init ipv4 mibs\n");
 
 	ipv4_proc_init();
 
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 300ab0c..438fab9 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1878,16 +1878,36 @@ static struct net_protocol pim_protocol = {
  *	Setup for IP multicast routing
  */
 
-void __init ip_mr_init(void)
+int __init ip_mr_init(void)
 {
+	int err;
+
 	mrt_cachep = kmem_cache_create("ip_mrt_cache",
 				       sizeof(struct mfc_cache),
 				       0, SLAB_HWCACHE_ALIGN|SLAB_PANIC,
 				       NULL);
+	if (!mrt_cachep)
+		return -ENOMEM;
+
 	setup_timer(&ipmr_expire_timer, ipmr_expire_process, 0);
-	register_netdevice_notifier(&ip_mr_notifier);
+	err = register_netdevice_notifier(&ip_mr_notifier);
+	if (err)
+		goto reg_notif_fail;
 #ifdef CONFIG_PROC_FS
-	proc_net_fops_create(&init_net, "ip_mr_vif", 0, &ipmr_vif_fops);
-	proc_net_fops_create(&init_net, "ip_mr_cache", 0, &ipmr_mfc_fops);
+	err = -ENOMEM;
+	if (!proc_net_fops_create(&init_net, "ip_mr_vif", 0, &ipmr_vif_fops))
+		goto proc_vif_fail;
+	if (!proc_net_fops_create(&init_net, "ip_mr_cache", 0, &ipmr_mfc_fops))
+		goto proc_cache_fail;
 #endif
+	return 0;
+reg_notif_fail:
+	kmem_cache_destroy(mrt_cachep);
+#ifdef CONFIG_PROC_FS
+proc_vif_fail:
+	unregister_netdevice_notifier(&ip_mr_notifier);
+proc_cache_fail:
+	proc_net_remove(&init_net, "ip_mr_vif");
+#endif
+	return err;
 }

---
commit e0835f8fa56d2d308486f8a34cf1c4480cd27f4e
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Jul 3 16:51:22 2008 +0900

    ipv4,ipv6 mroute: Add some helper inline functions to remove ugly ifdefs.
    
    ip{,v6}_mroute_{set,get}sockopt() should not matter by optimization but
    it would be better not to depend on optimization semantically.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/linux/mroute.h b/include/linux/mroute.h
index df8efd4..07112ee 100644
--- a/include/linux/mroute.h
+++ b/include/linux/mroute.h
@@ -144,10 +144,37 @@ static inline int ip_mroute_opt(int opt)
 }
 #endif
 
+#ifdef CONFIG_IP_MROUTE
 extern int ip_mroute_setsockopt(struct sock *, int, char __user *, int);
 extern int ip_mroute_getsockopt(struct sock *, int, char __user *, int __user *);
 extern int ipmr_ioctl(struct sock *sk, int cmd, void __user *arg);
 extern int ip_mr_init(void);
+#else
+static inline
+int ip_mroute_setsockopt(struct sock *sock,
+			 int optname, char __user *optval, int optlen)
+{
+	return -ENOPROTOOPT;
+}
+
+static inline
+int ip_mroute_getsockopt(struct sock *sock,
+			 int optname, char __user *optval, int __user *optlen)
+{
+	return -ENOPROTOOPT;
+}
+
+static inline
+int ipmr_ioctl(struct sock *sk, int cmd, void __user *arg)
+{
+	return -ENOIOCTLCMD;
+}
+
+static inline int ip_mr_init(void)
+{
+	return 0;
+}
+#endif
 
 struct vif_device
 {
diff --git a/include/linux/mroute6.h b/include/linux/mroute6.h
index 4c4d6f5..5cf5047 100644
--- a/include/linux/mroute6.h
+++ b/include/linux/mroute6.h
@@ -131,12 +131,44 @@ static inline int ip6_mroute_opt(int opt)
 
 struct sock;
 
+#ifdef CONFIG_IPV6_MROUTE
 extern int ip6_mroute_setsockopt(struct sock *, int, char __user *, int);
 extern int ip6_mroute_getsockopt(struct sock *, int, char __user *, int __user *);
 extern int ip6_mr_input(struct sk_buff *skb);
 extern int ip6mr_ioctl(struct sock *sk, int cmd, void __user *arg);
 extern int ip6_mr_init(void);
 extern void ip6_mr_cleanup(void);
+#else
+static inline
+int ip6_mroute_setsockopt(struct sock *sock,
+			  int optname, char __user *optval, int optlen)
+{
+	return -ENOPROTOOPT;
+}
+
+static inline
+int ip6_mroute_getsockopt(struct sock *sock,
+			  int optname, char __user *optval, int __user *optlen)
+{
+	return -ENOPROTOOPT;
+}
+
+static inline
+int ip6mr_ioctl(struct sock *sk, int cmd, void __user *arg)
+{
+	return -ENOIOCTLCMD;
+}
+
+static inline int ip6_mr_init(void)
+{
+	return 0;
+}
+
+static inline void ip6_mr_cleanup(void)
+{
+	return;
+}
+#endif
 
 struct mif_device
 {
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 6b39af1..3d828bc 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -59,9 +59,7 @@
 
 #include <asm/uaccess.h>
 #include <asm/system.h>
-#ifdef CONFIG_IPV6_MROUTE
 #include <linux/mroute6.h>
-#endif
 
 MODULE_AUTHOR("Cast of dozens");
 MODULE_DESCRIPTION("IPv6 protocol stack for Linux");
@@ -952,11 +950,9 @@ static int __init inet6_init(void)
 	err = icmpv6_init();
 	if (err)
 		goto icmp_fail;
-#ifdef CONFIG_IPV6_MROUTE
 	err = ip6_mr_init();
 	if (err)
 		goto ipmr_fail;
-#endif
 	err = ndisc_init();
 	if (err)
 		goto ndisc_fail;
@@ -1059,10 +1055,8 @@ netfilter_fail:
 igmp_fail:
 	ndisc_cleanup();
 ndisc_fail:
-#ifdef CONFIG_IPV6_MROUTE
 	ip6_mr_cleanup();
 ipmr_fail:
-#endif
 	icmpv6_cleanup();
 icmp_fail:
 	unregister_pernet_subsys(&inet6_net_ops);
@@ -1117,9 +1111,7 @@ static void __exit inet6_exit(void)
 	ipv6_netfilter_fini();
 	igmp6_cleanup();
 	ndisc_cleanup();
-#ifdef CONFIG_IPV6_MROUTE
 	ip6_mr_cleanup();
-#endif
 	icmpv6_cleanup();
 	rawv6_exit();
 

---
commit d68b82705a4a754e5773f412c6b8f1e65259bc8b
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
commit f81b2e7d8cf8c6a52b7a5224c3b89cee5aeb6811
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
commit 5ce83afaac956238c3c25f60a899c511e9d8cbf4
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
commit 778d80be52699596bf70e0eb0761cf5e1e46088d
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Sat Jun 28 14:17:11 2008 +0900

    ipv6: Add disable_ipv6 sysctl to disable IPv6 operaion on specific interface.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 71c7bea..dae980e 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1025,6 +1025,10 @@ max_addresses - INTEGER
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
commit 1b34be74cbf18f5d58cc85c7c4afcd9f7d74accd
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Sat Jun 28 14:18:38 2008 +0900

    ipv6 addrconf: add accept_dad sysctl to control DAD operation.
    
    - If 0, disable DAD.
    - If 1, perform DAD (default).
    - If >1, perform DAD and disable IPv6 operation if DAD for MAC-based
      link-local address has been failed (RFC4862 5.4.5).
    
    We do not follow RFC4862 by default.  Refer to the netdev thread entitled
    "Linux IPv6 DAD not full conform to RFC 4862 ?"
    	http://www.spinics.net/lists/netdev/msg52027.html
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index dae980e..72f6d52 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1029,6 +1029,13 @@ disable_ipv6 - BOOLEAN
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
commit dd3abc4ef52597ec8268274222574b2700ba3ded
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Jul 2 18:30:18 2008 +0900

    ipv6 route: Prefer outgoing interface with source address assigned.
    
    Outgoing interface is selected by the route decision if unspecified.
    Let's prefer routes via interface(s) with the address assigned if we
    have multiple routes with same cost.
    With help from Naohiro Ooiwa <nooiwa@miraclelinux.com>.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index dbad96c..5d6c166 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -237,15 +237,20 @@ static inline int rt6_need_strict(struct in6_addr *daddr)
 
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
+		goto out;
+
+	for (sprt = rt; sprt; sprt = sprt->u.dst.rt6_next) {
+		struct net_device *dev = sprt->rt6i_dev;
+
+		if (oif) {
 			if (dev->ifindex == oif)
 				return sprt;
 			if (dev->flags & IFF_LOOPBACK) {
@@ -259,14 +264,21 @@ static inline struct rt6_info *rt6_device_match(struct net *net,
 				}
 				local = sprt;
 			}
+		} else {
+			if (ipv6_chk_addr(net, saddr, dev,
+					  flags & RT6_LOOKUP_F_IFACE))
+				return sprt;
 		}
+	}
 
+	if (oif) {
 		if (local)
 			return local;
 
 		if (flags & RT6_LOOKUP_F_IFACE)
 			return net->ipv6.ip6_null_entry;
 	}
+out:
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
commit 623d1a1af77bd52a389c6eda5920e28eb2ee468b
Author: Wang Chen <wangchen@cn.fujitsu.com>
Date:   Thu Jul 3 12:13:30 2008 +0800

    ipv6: Do cleanup for ip6_mr_init.
    
    If do not do it, we will get following issues:
    1. Leaving junks after inet6_init failing halfway.
    2. Leaving proc and notifier junks after ipv6 modules unloading.
    
    Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/linux/mroute6.h b/include/linux/mroute6.h
index e798959..4c4d6f5 100644
--- a/include/linux/mroute6.h
+++ b/include/linux/mroute6.h
@@ -135,7 +135,8 @@ extern int ip6_mroute_setsockopt(struct sock *, int, char __user *, int);
 extern int ip6_mroute_getsockopt(struct sock *, int, char __user *, int __user *);
 extern int ip6_mr_input(struct sk_buff *skb);
 extern int ip6mr_ioctl(struct sock *sk, int cmd, void __user *arg);
-extern void ip6_mr_init(void);
+extern int ip6_mr_init(void);
+extern void ip6_mr_cleanup(void);
 
 struct mif_device
 {
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 3ce8d2f..6b39af1 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -953,7 +953,9 @@ static int __init inet6_init(void)
 	if (err)
 		goto icmp_fail;
 #ifdef CONFIG_IPV6_MROUTE
-	ip6_mr_init();
+	err = ip6_mr_init();
+	if (err)
+		goto ipmr_fail;
 #endif
 	err = ndisc_init();
 	if (err)
@@ -1057,6 +1059,10 @@ netfilter_fail:
 igmp_fail:
 	ndisc_cleanup();
 ndisc_fail:
+#ifdef CONFIG_IPV6_MROUTE
+	ip6_mr_cleanup();
+ipmr_fail:
+#endif
 	icmpv6_cleanup();
 icmp_fail:
 	unregister_pernet_subsys(&inet6_net_ops);
@@ -1111,6 +1117,9 @@ static void __exit inet6_exit(void)
 	ipv6_netfilter_fini();
 	igmp6_cleanup();
 	ndisc_cleanup();
+#ifdef CONFIG_IPV6_MROUTE
+	ip6_mr_cleanup();
+#endif
 	icmpv6_cleanup();
 	rawv6_exit();
 
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 90e7630..cfac26d 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -948,23 +948,51 @@ static struct notifier_block ip6_mr_notifier = {
  *	Setup for IP multicast routing
  */
 
-void __init ip6_mr_init(void)
+int __init ip6_mr_init(void)
 {
+	int err;
+
 	mrt_cachep = kmem_cache_create("ip6_mrt_cache",
 				       sizeof(struct mfc6_cache),
 				       0, SLAB_HWCACHE_ALIGN,
 				       NULL);
 	if (!mrt_cachep)
-		panic("cannot allocate ip6_mrt_cache");
+		return -ENOMEM;
 
 	setup_timer(&ipmr_expire_timer, ipmr_expire_process, 0);
-	register_netdevice_notifier(&ip6_mr_notifier);
+	err = register_netdevice_notifier(&ip6_mr_notifier);
+	if (err)
+		goto reg_notif_fail;
+#ifdef CONFIG_PROC_FS
+	err = -ENOMEM;
+	if (!proc_net_fops_create(&init_net, "ip6_mr_vif", 0, &ip6mr_vif_fops))
+		goto proc_vif_fail;
+	if (!proc_net_fops_create(&init_net, "ip6_mr_cache",
+				     0, &ip6mr_mfc_fops))
+		goto proc_cache_fail;
+#endif
+	return 0;
+reg_notif_fail:
+	kmem_cache_destroy(mrt_cachep);
 #ifdef CONFIG_PROC_FS
-	proc_net_fops_create(&init_net, "ip6_mr_vif", 0, &ip6mr_vif_fops);
-	proc_net_fops_create(&init_net, "ip6_mr_cache", 0, &ip6mr_mfc_fops);
+proc_vif_fail:
+	unregister_netdevice_notifier(&ip6_mr_notifier);
+proc_cache_fail:
+	proc_net_remove(&init_net, "ip6_mr_vif");
 #endif
+	return err;
 }
 
+void ip6_mr_cleanup(void)
+{
+#ifdef CONFIG_PROC_FS
+	proc_net_remove(&init_net, "ip6_mr_cache");
+	proc_net_remove(&init_net, "ip6_mr_vif");
+#endif
+	unregister_netdevice_notifier(&ip6_mr_notifier);
+	del_timer(&ipmr_expire_timer);
+	kmem_cache_destroy(mrt_cachep);
+}
 
 static int ip6mr_mfc_add(struct mf6cctl *mfc, int mrtsock)
 {

---
commit 03d2f897e9fb3218989baa2139a951ce7f5414bf
Author: Wang Chen <wangchen@cn.fujitsu.com>
Date:   Thu Jul 3 12:13:36 2008 +0800

    ipv4: Do cleanup for ip_mr_init
    
    Same as ip6_mr_init(), make ip_mr_init() return errno if fails.
    But do not do error handling in inet_init(), just print a msg.
    
    Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/linux/igmp.h b/include/linux/igmp.h
index f5a1a0d..7bb3c09 100644
--- a/include/linux/igmp.h
+++ b/include/linux/igmp.h
@@ -228,7 +228,6 @@ extern int ip_mc_msfget(struct sock *sk, struct ip_msfilter *msf,
 extern int ip_mc_gsfget(struct sock *sk, struct group_filter *gsf,
 		struct group_filter __user *optval, int __user *optlen);
 extern int ip_mc_sf_allow(struct sock *sk, __be32 local, __be32 rmt, int dif);
-extern void ip_mr_init(void);
 extern void ip_mc_init_dev(struct in_device *);
 extern void ip_mc_destroy_dev(struct in_device *);
 extern void ip_mc_up(struct in_device *);
diff --git a/include/linux/mroute.h b/include/linux/mroute.h
index de4decf..df8efd4 100644
--- a/include/linux/mroute.h
+++ b/include/linux/mroute.h
@@ -147,8 +147,7 @@ static inline int ip_mroute_opt(int opt)
 extern int ip_mroute_setsockopt(struct sock *, int, char __user *, int);
 extern int ip_mroute_getsockopt(struct sock *, int, char __user *, int __user *);
 extern int ipmr_ioctl(struct sock *sk, int cmd, void __user *arg);
-extern void ip_mr_init(void);
-
+extern int ip_mr_init(void);
 
 struct vif_device
 {
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 42bd24b..dc41133 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1479,14 +1479,15 @@ static int __init inet_init(void)
 	 *	Initialise the multicast router
 	 */
 #if defined(CONFIG_IP_MROUTE)
-	ip_mr_init();
+	if (ip_mr_init())
+		printk(KERN_CRIT "inet_init: Cannot init ipv4 mroute\n");
 #endif
 	/*
 	 *	Initialise per-cpu ipv4 mibs
 	 */
 
 	if (init_ipv4_mibs())
-		printk(KERN_CRIT "inet_init: Cannot init ipv4 mibs\n"); ;
+		printk(KERN_CRIT "inet_init: Cannot init ipv4 mibs\n");
 
 	ipv4_proc_init();
 
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 300ab0c..438fab9 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1878,16 +1878,36 @@ static struct net_protocol pim_protocol = {
  *	Setup for IP multicast routing
  */
 
-void __init ip_mr_init(void)
+int __init ip_mr_init(void)
 {
+	int err;
+
 	mrt_cachep = kmem_cache_create("ip_mrt_cache",
 				       sizeof(struct mfc_cache),
 				       0, SLAB_HWCACHE_ALIGN|SLAB_PANIC,
 				       NULL);
+	if (!mrt_cachep)
+		return -ENOMEM;
+
 	setup_timer(&ipmr_expire_timer, ipmr_expire_process, 0);
-	register_netdevice_notifier(&ip_mr_notifier);
+	err = register_netdevice_notifier(&ip_mr_notifier);
+	if (err)
+		goto reg_notif_fail;
 #ifdef CONFIG_PROC_FS
-	proc_net_fops_create(&init_net, "ip_mr_vif", 0, &ipmr_vif_fops);
-	proc_net_fops_create(&init_net, "ip_mr_cache", 0, &ipmr_mfc_fops);
+	err = -ENOMEM;
+	if (!proc_net_fops_create(&init_net, "ip_mr_vif", 0, &ipmr_vif_fops))
+		goto proc_vif_fail;
+	if (!proc_net_fops_create(&init_net, "ip_mr_cache", 0, &ipmr_mfc_fops))
+		goto proc_cache_fail;
 #endif
+	return 0;
+reg_notif_fail:
+	kmem_cache_destroy(mrt_cachep);
+#ifdef CONFIG_PROC_FS
+proc_vif_fail:
+	unregister_netdevice_notifier(&ip_mr_notifier);
+proc_cache_fail:
+	proc_net_remove(&init_net, "ip_mr_vif");
+#endif
+	return err;
 }

---
commit e0835f8fa56d2d308486f8a34cf1c4480cd27f4e
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Jul 3 16:51:22 2008 +0900

    ipv4,ipv6 mroute: Add some helper inline functions to remove ugly ifdefs.
    
    ip{,v6}_mroute_{set,get}sockopt() should not matter by optimization but
    it would be better not to depend on optimization semantically.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/linux/mroute.h b/include/linux/mroute.h
index df8efd4..07112ee 100644
--- a/include/linux/mroute.h
+++ b/include/linux/mroute.h
@@ -144,10 +144,37 @@ static inline int ip_mroute_opt(int opt)
 }
 #endif
 
+#ifdef CONFIG_IP_MROUTE
 extern int ip_mroute_setsockopt(struct sock *, int, char __user *, int);
 extern int ip_mroute_getsockopt(struct sock *, int, char __user *, int __user *);
 extern int ipmr_ioctl(struct sock *sk, int cmd, void __user *arg);
 extern int ip_mr_init(void);
+#else
+static inline
+int ip_mroute_setsockopt(struct sock *sock,
+			 int optname, char __user *optval, int optlen)
+{
+	return -ENOPROTOOPT;
+}
+
+static inline
+int ip_mroute_getsockopt(struct sock *sock,
+			 int optname, char __user *optval, int __user *optlen)
+{
+	return -ENOPROTOOPT;
+}
+
+static inline
+int ipmr_ioctl(struct sock *sk, int cmd, void __user *arg)
+{
+	return -ENOIOCTLCMD;
+}
+
+static inline int ip_mr_init(void)
+{
+	return 0;
+}
+#endif
 
 struct vif_device
 {
diff --git a/include/linux/mroute6.h b/include/linux/mroute6.h
index 4c4d6f5..5cf5047 100644
--- a/include/linux/mroute6.h
+++ b/include/linux/mroute6.h
@@ -131,12 +131,44 @@ static inline int ip6_mroute_opt(int opt)
 
 struct sock;
 
+#ifdef CONFIG_IPV6_MROUTE
 extern int ip6_mroute_setsockopt(struct sock *, int, char __user *, int);
 extern int ip6_mroute_getsockopt(struct sock *, int, char __user *, int __user *);
 extern int ip6_mr_input(struct sk_buff *skb);
 extern int ip6mr_ioctl(struct sock *sk, int cmd, void __user *arg);
 extern int ip6_mr_init(void);
 extern void ip6_mr_cleanup(void);
+#else
+static inline
+int ip6_mroute_setsockopt(struct sock *sock,
+			  int optname, char __user *optval, int optlen)
+{
+	return -ENOPROTOOPT;
+}
+
+static inline
+int ip6_mroute_getsockopt(struct sock *sock,
+			  int optname, char __user *optval, int __user *optlen)
+{
+	return -ENOPROTOOPT;
+}
+
+static inline
+int ip6mr_ioctl(struct sock *sk, int cmd, void __user *arg)
+{
+	return -ENOIOCTLCMD;
+}
+
+static inline int ip6_mr_init(void)
+{
+	return 0;
+}
+
+static inline void ip6_mr_cleanup(void)
+{
+	return;
+}
+#endif
 
 struct mif_device
 {
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 6b39af1..3d828bc 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -59,9 +59,7 @@
 
 #include <asm/uaccess.h>
 #include <asm/system.h>
-#ifdef CONFIG_IPV6_MROUTE
 #include <linux/mroute6.h>
-#endif
 
 MODULE_AUTHOR("Cast of dozens");
 MODULE_DESCRIPTION("IPv6 protocol stack for Linux");
@@ -952,11 +950,9 @@ static int __init inet6_init(void)
 	err = icmpv6_init();
 	if (err)
 		goto icmp_fail;
-#ifdef CONFIG_IPV6_MROUTE
 	err = ip6_mr_init();
 	if (err)
 		goto ipmr_fail;
-#endif
 	err = ndisc_init();
 	if (err)
 		goto ndisc_fail;
@@ -1059,10 +1055,8 @@ netfilter_fail:
 igmp_fail:
 	ndisc_cleanup();
 ndisc_fail:
-#ifdef CONFIG_IPV6_MROUTE
 	ip6_mr_cleanup();
 ipmr_fail:
-#endif
 	icmpv6_cleanup();
 icmp_fail:
 	unregister_pernet_subsys(&inet6_net_ops);
@@ -1117,9 +1111,7 @@ static void __exit inet6_exit(void)
 	ipv6_netfilter_fini();
 	igmp6_cleanup();
 	ndisc_cleanup();
-#ifdef CONFIG_IPV6_MROUTE
 	ip6_mr_cleanup();
-#endif
 	icmpv6_cleanup();
 	rawv6_exit();
 

---

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
