From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] IPv6: Implement RFC 4429 Optimistic Duplicate Address Detection
Date: Thu, 25 Jan 2007 14:45:00 -0500
Message-ID: <20070125194500.GB8891@hmsreliant.homelinux.net>
References: <20070119212314.GA10748@hmsreliant.homelinux.net> <20070120.080507.25118874.yoshfuji@linux-ipv6.org> <20070122181528.GD21059@hmsreliant.homelinux.net> <20070123.091820.104515696.yoshfuji@linux-ipv6.org> <20070123205118.GC582@hmsreliant.homelinux.net> <1169690087.23312.7.camel@w-sridhar2.beaverton.ibm.com> <20070125133340.GA8891@hmsreliant.homelinux.net> <45B8E60B.7080809@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	kaber@coreworks.de, netdev@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3630 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030537AbXAYUAn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jan 2007 15:00:43 -0500
Content-Disposition: inline
In-Reply-To: <45B8E60B.7080809@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 25, 2007 at 12:16:59PM -0500, Vlad Yasevich wrote:
<snip> 
> I tend to agree with Neil here.  Marking optimistic addresses as deprecated doesn't
> buy as much since the address can transition in and out of deprecated state regardless
> of DAD.
> 
> However, there is a problem with the current implementation in that OPTIMISTIC address
> will never be chosen as source because it's always TENTATIVE and OPTIMISTIC at the
> same time.  What needs to happen is for ipv6_dev_get_saddr() to not ignore OPTIMISTIC
> addresses and treat them same as DEPRECATED.
> 
> -vlad


Heres an updated patch.  Same as the previous patch but it adds three
modifications to ipv6_dev_get_saddr, which do the following:

a) Adds logic to not remove addresses that are both tentative and optimistic
from the set of considered addresses

b) Treats optimistic addresses and deptrecated address in the same fashion by
checking for both flags appropriately during source address selection.

Thoughts welcome.

Thanks & Regards
Neil

Signed-off-by: Neil Horman <nhorman@tuxdriver.com


 include/linux/if_addr.h |    1 
 include/linux/ipv6.h    |    2 +
 include/linux/sysctl.h  |    1 
 include/net/addrconf.h  |    4 +-
 net/ipv6/addrconf.c     |   69 ++++++++++++++++++++++++++++++++--------
 net/ipv6/mcast.c        |    4 +-
 net/ipv6/ndisc.c        |   82 +++++++++++++++++++++++++++++++++++-------------
 7 files changed, 125 insertions(+), 38 deletions(-)



diff --git a/include/linux/if_addr.h b/include/linux/if_addr.h
index d557e4c..43f3bed 100644
--- a/include/linux/if_addr.h
+++ b/include/linux/if_addr.h
@@ -39,6 +39,7 @@ enum
 #define IFA_F_TEMPORARY		IFA_F_SECONDARY
 
 #define	IFA_F_NODAD		0x02
+#define IFA_F_OPTIMISTIC	0x04
 #define	IFA_F_HOMEADDRESS	0x10
 #define IFA_F_DEPRECATED	0x20
 #define IFA_F_TENTATIVE		0x40
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index f824113..5d37abf 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -177,6 +177,7 @@ struct ipv6_devconf {
 #endif
 #endif
 	__s32		proxy_ndp;
+	__s32		optimistic_dad;
 	void		*sysctl;
 };
 
@@ -205,6 +206,7 @@ enum {
 	DEVCONF_RTR_PROBE_INTERVAL,
 	DEVCONF_ACCEPT_RA_RT_INFO_MAX_PLEN,
 	DEVCONF_PROXY_NDP,
+	DEVCONF_OPTIMISTIC_DAD,
 	DEVCONF_MAX
 };
 
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 81480e6..972a33a 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -570,6 +570,7 @@ enum {
 	NET_IPV6_RTR_PROBE_INTERVAL=21,
 	NET_IPV6_ACCEPT_RA_RT_INFO_MAX_PLEN=22,
 	NET_IPV6_PROXY_NDP=23,
+	NET_IPV6_OPTIMISTIC_DAD=24,
 	__NET_IPV6_MAX
 };
 
diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 88df8fc..d248a19 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -73,7 +73,9 @@ extern int			ipv6_get_saddr(struct dst_entry *dst,
 extern int			ipv6_dev_get_saddr(struct net_device *dev, 
 					       struct in6_addr *daddr,
 					       struct in6_addr *saddr);
-extern int			ipv6_get_lladdr(struct net_device *dev, struct in6_addr *);
+extern int			ipv6_get_lladdr(struct net_device *dev, 
+						struct in6_addr *,
+						unsigned char banned_flags);
 extern int			ipv6_rcv_saddr_equal(const struct sock *sk, 
 						      const struct sock *sk2);
 extern void			addrconf_join_solict(struct net_device *dev,
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 2a7e461..46f91ee 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -830,7 +830,8 @@ retry:
 	ift = !max_addresses ||
 	      ipv6_count_addresses(idev) < max_addresses ? 
 		ipv6_add_addr(idev, &addr, tmp_plen,
-			      ipv6_addr_type(&addr)&IPV6_ADDR_SCOPE_MASK, IFA_F_TEMPORARY) : NULL;
+			      ipv6_addr_type(&addr)&IPV6_ADDR_SCOPE_MASK, 
+			      IFA_F_TEMPORARY|IFA_F_OPTIMISTIC) : NULL;
 	if (!ift || IS_ERR(ift)) {
 		in6_ifa_put(ifp);
 		in6_dev_put(idev);
@@ -962,13 +963,14 @@ int ipv6_dev_get_saddr(struct net_device *daddr_dev,
 			 * - Tentative Address (RFC2462 section 5.4)
 			 *  - A tentative address is not considered
 			 *    "assigned to an interface" in the traditional
-			 *    sense.
+			 *    sense, unless it is also flagged as optimistic.
 			 * - Candidate Source Address (section 4)
 			 *  - In any case, anycast addresses, multicast
 			 *    addresses, and the unspecified address MUST
 			 *    NOT be included in a candidate set.
 			 */
-			if (ifa->flags & IFA_F_TENTATIVE)
+			if ((ifa->flags & IFA_F_TENTATIVE) &&
+			    (!(ifa->flags & IFA_F_OPTIMISTIC)))
 				continue;
 			if (unlikely(score.addr_type == IPV6_ADDR_ANY ||
 				     score.addr_type & IPV6_ADDR_MULTICAST)) {
@@ -1027,15 +1029,17 @@ int ipv6_dev_get_saddr(struct net_device *daddr_dev,
 				}
 			}
 
-			/* Rule 3: Avoid deprecated address */
+			/* Rule 3: Avoid deprecated and optimistic address */
 			if (hiscore.rule < 3) {
 				if (ipv6_saddr_preferred(hiscore.addr_type) ||
-				    !(ifa_result->flags & IFA_F_DEPRECATED))
+				    ((!(ifa_result->flags & IFA_F_DEPRECATED)) && 
+				    (!(ifa_result->flags & IFA_F_OPTIMISTIC))))
 					hiscore.attrs |= IPV6_SADDR_SCORE_PREFERRED;
 				hiscore.rule++;
 			}
 			if (ipv6_saddr_preferred(score.addr_type) ||
-			    !(ifa->flags & IFA_F_DEPRECATED)) {
+			    ((!(ifa->flags & IFA_F_DEPRECATED)) &&
+			    (!(ifa_result->flags & IFA_F_OPTIMISTIC)))) {
 				score.attrs |= IPV6_SADDR_SCORE_PREFERRED;
 				if (!(hiscore.attrs & IPV6_SADDR_SCORE_PREFERRED)) {
 					score.rule = 3;
@@ -1174,7 +1178,8 @@ int ipv6_get_saddr(struct dst_entry *dst,
 }
 
 
-int ipv6_get_lladdr(struct net_device *dev, struct in6_addr *addr)
+int ipv6_get_lladdr(struct net_device *dev, struct in6_addr *addr, 
+		    unsigned char banned_flags)
 {
 	struct inet6_dev *idev;
 	int err = -EADDRNOTAVAIL;
@@ -1185,7 +1190,7 @@ int ipv6_get_lladdr(struct net_device *dev, struct in6_addr *addr)
 
 		read_lock_bh(&idev->lock);
 		for (ifp=idev->addr_list; ifp; ifp=ifp->if_next) {
-			if (ifp->scope == IFA_LINK && !(ifp->flags&IFA_F_TENTATIVE)) {
+			if (ifp->scope == IFA_LINK && !(ifp->flags & banned_flags)) {
 				ipv6_addr_copy(addr, &ifp->addr);
 				err = 0;
 				break;
@@ -1751,6 +1756,7 @@ ok:
 
 			update_lft = create = 1;
 			ifp->cstamp = jiffies;
+			ifp->flags |= IFA_F_OPTIMISTIC;
 			addrconf_dad_start(ifp, RTF_ADDRCONF|RTF_PREFIX_RT);
 		}
 
@@ -1945,7 +1951,11 @@ static int inet6_addr_add(int ifindex, struct in6_addr *pfx, int plen,
 		ifp->prefered_lft = prefered_lft;
 		ifp->tstamp = jiffies;
 		spin_unlock_bh(&ifp->lock);
-
+		/*
+		 * Note that section 3.1 of RFC 4429 indicates
+		 * That the Optimistic flag should not be set for
+		 * manually configured addresses
+		 */
 		addrconf_dad_start(ifp, 0);
 		in6_ifa_put(ifp);
 		addrconf_verify(0);
@@ -2123,7 +2133,8 @@ static void addrconf_add_linklocal(struct inet6_dev *idev, struct in6_addr *addr
 {
 	struct inet6_ifaddr * ifp;
 
-	ifp = ipv6_add_addr(idev, addr, 64, IFA_LINK, IFA_F_PERMANENT);
+	ifp = ipv6_add_addr(idev, addr, 64, IFA_LINK, 
+		            IFA_F_PERMANENT|IFA_F_OPTIMISTIC);
 	if (!IS_ERR(ifp)) {
 		addrconf_dad_start(ifp, 0);
 		in6_ifa_put(ifp);
@@ -2190,7 +2201,7 @@ ipv6_inherit_linklocal(struct inet6_dev *idev, struct net_device *link_dev)
 {
 	struct in6_addr lladdr;
 
-	if (!ipv6_get_lladdr(link_dev, &lladdr)) {
+	if (!ipv6_get_lladdr(link_dev, &lladdr, IFA_F_TENTATIVE)) {
 		addrconf_add_linklocal(idev, &lladdr);
 		return 0;
 	}
@@ -2537,8 +2548,18 @@ static void addrconf_dad_start(struct inet6_ifaddr *ifp, u32 flags)
 	struct inet6_dev *idev = ifp->idev;
 	struct net_device *dev = idev->dev;
 
+	if (!idev->cnf.optimistic_dad)
+		ifp->flags &= ~IFA_F_OPTIMISTIC;
+
 	addrconf_join_solict(dev, &ifp->addr);
 
+	/*
+	 * Optimistic nodes need to joing the anycast address
+	 * right away
+	 */
+	if (ifp->flags & IFA_F_OPTIMISTIC)
+		addrconf_join_anycast(ifp);
+
 	if (ifp->prefix_len != 128 && (ifp->flags&IFA_F_PERMANENT))
 		addrconf_prefix_route(&ifp->addr, ifp->prefix_len, dev, 0,
 					flags);
@@ -2553,7 +2574,7 @@ static void addrconf_dad_start(struct inet6_ifaddr *ifp, u32 flags)
 	if (dev->flags&(IFF_NOARP|IFF_LOOPBACK) ||
 	    !(ifp->flags&IFA_F_TENTATIVE) ||
 	    ifp->flags & IFA_F_NODAD) {
-		ifp->flags &= ~IFA_F_TENTATIVE;
+		ifp->flags &= ~(IFA_F_TENTATIVE|IFA_F_OPTIMISTIC);
 		spin_unlock_bh(&ifp->lock);
 		read_unlock_bh(&idev->lock);
 
@@ -2573,6 +2594,18 @@ static void addrconf_dad_start(struct inet6_ifaddr *ifp, u32 flags)
 		addrconf_dad_stop(ifp);
 		return;
 	}
+
+	/*
+	 * Forwarding devices (routers) should not use
+	 * optimistic addresses
+	 * Nor should interfaces that don't know the 
+	 * Source address for their default gateway
+	 * RFC 4429 Sec 3.3
+	 */
+	if ((ipv6_devconf.forwarding) ||
+	   (ifp->rt == NULL))
+		ifp->flags &= ~IFA_F_OPTIMISTIC;
+
 	addrconf_dad_kick(ifp);
 	spin_unlock_bh(&ifp->lock);
 out:
@@ -2597,7 +2630,7 @@ static void addrconf_dad_timer(unsigned long data)
 		 * DAD was successful
 		 */
 
-		ifp->flags &= ~IFA_F_TENTATIVE;
+		ifp->flags &= ~(IFA_F_TENTATIVE|IFA_F_OPTIMISTIC);
 		spin_unlock_bh(&ifp->lock);
 		read_unlock_bh(&idev->lock);
 
@@ -3398,6 +3431,7 @@ static void inline ipv6_store_devconf(struct ipv6_devconf *cnf,
 #endif
 #endif
 	array[DEVCONF_PROXY_NDP] = cnf->proxy_ndp;
+	array[DEVCONF_OPTIMISTIC_DAD] = cnf->optimistic_dad;
 }
 
 static inline size_t inet6_if_nlmsg_size(void)
@@ -3918,6 +3952,15 @@ static struct addrconf_sysctl_table
 			.proc_handler	=	&proc_dointvec,
 		},
 		{
+			.ctl_name	=	NET_IPV6_OPTIMISTIC_DAD,
+			.procname       =       "optimistic_dad",
+			.data           =       &ipv6_devconf.optimistic_dad,
+			.maxlen         =       sizeof(int),
+			.mode           =       0644,
+			.proc_handler   =       &proc_dointvec,
+
+		},
+		{
 			.ctl_name	=	0,	/* sentinel */
 		}
 	},
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 882cde4..9c5273c 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1411,7 +1411,7 @@ static struct sk_buff *mld_newpack(struct net_device *dev, int size)
 
 	skb_reserve(skb, LL_RESERVED_SPACE(dev));
 
-	if (ipv6_get_lladdr(dev, &addr_buf)) {
+	if (ipv6_get_lladdr(dev, &addr_buf, IFA_F_TENTATIVE)) {
 		/* <draft-ietf-magma-mld-source-05.txt>:
 		 * use unspecified address as the source address 
 		 * when a valid link-local address is not available.
@@ -1789,7 +1789,7 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 
 	skb_reserve(skb, LL_RESERVED_SPACE(dev));
 
-	if (ipv6_get_lladdr(dev, &addr_buf)) {
+	if (ipv6_get_lladdr(dev, &addr_buf, IFA_F_TENTATIVE)) {
 		/* <draft-ietf-magma-mld-source-05.txt>:
 		 * use unspecified address as the source address 
 		 * when a valid link-local address is not available.
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 6a9f616..fcd22e3 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -498,7 +498,21 @@ static void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
         msg->icmph.icmp6_unused = 0;
         msg->icmph.icmp6_router    = router;
         msg->icmph.icmp6_solicited = solicited;
-        msg->icmph.icmp6_override  = override;
+	if (!ifp || !(ifp->flags & IFA_F_OPTIMISTIC))
+		msg->icmph.icmp6_override  = override;
+	else {
+		/*
+		 * We must clear the override flag on all
+		 * neighbor advertisements from source 
+		 * addresses that are OPTIMISTIC - RFC 4429
+		 * section 2.2
+		 */
+		if (override)
+			printk(KERN_WARNING
+				"Disallowing override flag for OPTIMISTIC addr\n");
+		msg->icmph.icmp6_override = 0;
+	}
+
 
         /* Set the target address. */
 	ipv6_addr_copy(&msg->target, solicited_addr);
@@ -542,7 +556,8 @@ void ndisc_send_ns(struct net_device *dev, struct neighbour *neigh,
 	int send_llinfo;
 
 	if (saddr == NULL) {
-		if (ipv6_get_lladdr(dev, &addr_buf))
+		if (ipv6_get_lladdr(dev, &addr_buf,
+			            (IFA_F_TENTATIVE|IFA_F_OPTIMISTIC)))
 			return;
 		saddr = &addr_buf;
 	}
@@ -622,9 +637,20 @@ void ndisc_send_rs(struct net_device *dev, struct in6_addr *saddr,
         struct sk_buff *skb;
         struct icmp6hdr *hdr;
 	__u8 * opt;
+	struct inet6_ifaddr *ifp;
         int len;
 	int err;
 
+	/*
+	 * Check the source address.  If its OPTIMISTIC
+	 * and addr_len is non-zero (implying the sllao option)
+	 * then don't send the RS (RFC 4429, section 2.2)
+	 */
+	ifp = ipv6_get_ifaddr(saddr, dev, 1);
+
+	if ((!ifp) || ((ifp->flags & IFA_F_OPTIMISTIC) && dev->addr_len))
+		return;
+
 	ndisc_flow_init(&fl, NDISC_ROUTER_SOLICITATION, saddr, daddr,
 			dev->ifindex);
 
@@ -746,6 +772,7 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 	int dad = ipv6_addr_any(saddr);
 	int inc;
 	int is_router;
+	int type;
 
 	if (ipv6_addr_is_multicast(&msg->target)) {
 		ND_PRINTK2(KERN_WARNING 
@@ -796,28 +823,39 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 	inc = ipv6_addr_is_multicast(daddr);
 
 	if ((ifp = ipv6_get_ifaddr(&msg->target, dev, 1)) != NULL) {
-		if (ifp->flags & IFA_F_TENTATIVE) {
-			/* Address is tentative. If the source
-			   is unspecified address, it is someone
-			   does DAD, otherwise we ignore solicitations
-			   until DAD timer expires.
-			 */
-			if (!dad)
+
+		if (ifp->flags & (IFA_F_TENTATIVE|IFA_F_OPTIMISTIC)) {
+			if (dad) {
+				if (dev->type == ARPHRD_IEEE802_TR) {
+					unsigned char *sadr = skb->mac.raw;
+					if (((sadr[8] ^ dev->dev_addr[0]) & 0x7f) == 0 &&
+					    sadr[9] == dev->dev_addr[1] &&
+					    sadr[10] == dev->dev_addr[2] &&
+					    sadr[11] == dev->dev_addr[3] &&
+					    sadr[12] == dev->dev_addr[4] &&
+					    sadr[13] == dev->dev_addr[5]) {
+						/* looped-back to us */
+						goto out;
+					}
+				}
+
+				/*
+				 * We are colliding with another node
+				 * who is doing DAD
+				 * so fail our DAD process
+				 */
+				addrconf_dad_failure(ifp);
 				goto out;
-			if (dev->type == ARPHRD_IEEE802_TR) {
-				unsigned char *sadr = skb->mac.raw;
-				if (((sadr[8] ^ dev->dev_addr[0]) & 0x7f) == 0 &&
-				    sadr[9] == dev->dev_addr[1] &&
-				    sadr[10] == dev->dev_addr[2] &&
-				    sadr[11] == dev->dev_addr[3] &&
-				    sadr[12] == dev->dev_addr[4] &&
-				    sadr[13] == dev->dev_addr[5]) {
-					/* looped-back to us */
+			} else {
+				/*
+				 * This is not a dad solicitation.
+				 * If we are an optimistic node, 
+				 * we should respond.  
+				 * Otherwise, we should ignore it. 
+				 */
+				if (!(ifp->flags & IFA_F_OPTIMISTIC))
 					goto out;
-				}
 			}
-			addrconf_dad_failure(ifp); 
-			return;
 		}
 
 		idev = ifp->idev;
@@ -1406,7 +1444,7 @@ void ndisc_send_redirect(struct sk_buff *skb, struct neighbour *neigh,
 
 	dev = skb->dev;
 
-	if (ipv6_get_lladdr(dev, &saddr_buf)) {
+	if (ipv6_get_lladdr(dev, &saddr_buf, IFA_F_TENTATIVE)) {
 		ND_PRINTK2(KERN_WARNING
 			   "ICMPv6 Redirect: no link-local address on %s\n",
 			   dev->name);
