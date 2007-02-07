From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] IPv6: Implement RFC 4429 Optimistic Duplicate Address Detection
Date: Wed, 7 Feb 2007 15:55:03 -0500
Message-ID: <20070207205503.GB20804@hmsreliant.homelinux.net>
References: <45C3B22B.4020400@hp.com> <20070203150301.GA32659@hmsreliant.homelinux.net> <20070205205651.GB484@hmsreliant.homelinux.net> <20070206.102405.86919923.yoshfuji@linux-ipv6.org> <20070206125144.GB10707@hmsreliant.homelinux.net> <20070206200915.GC10707@hmsreliant.homelinux.net> <45C8EF75.6070506@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>, sri@us.ibm.com, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	kaber@coreworks.de, netdev@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4700 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161425AbXBGU5m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Feb 2007 15:57:42 -0500
Content-Disposition: inline
In-Reply-To: <45C8EF75.6070506@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 06, 2007 at 04:13:25PM -0500, Vlad Yasevich wrote:
> Hi Neil
> 
> a few comments.  sorry, just can't resist... :)
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Its really ok :).  Brian found some other minor typos as well.  I've attached
the latest patch which takes your comments, and Brians observations into
account.  The only change I left out was the space/tab conversion in
ndisc_send_ns, since it appeared to be more inline with the style in the rest of
the file.  Everything else is incorporated into this patch, however. Thanks for
all the keen eyes!

Thanks & Regards
Neil

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 include/linux/if_addr.h |    1 
 include/linux/ipv6.h    |    4 ++
 include/linux/sysctl.h  |    1 
 include/net/addrconf.h  |    4 +-
 net/ipv6/Kconfig        |   10 +++++
 net/ipv6/addrconf.c     |   90 ++++++++++++++++++++++++++++++++++++++++--------
 net/ipv6/ip6_output.c   |   28 ++++++++++++++
 net/ipv6/mcast.c        |    4 +-
 net/ipv6/ndisc.c        |   82 ++++++++++++++++++++++++++++++-------------
 9 files changed, 182 insertions(+), 42 deletions(-)



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
index f824113..bf93c1b 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -177,6 +177,9 @@ struct ipv6_devconf {
 #endif
 #endif
 	__s32		proxy_ndp;
+#ifdef CONFIG_IPV6_OPTIMISTIC_DAD
+	__s32		optimistic_dad;
+#endif
 	void		*sysctl;
 };
 
@@ -205,6 +208,7 @@ enum {
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
diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index deb4101..822d3eb 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -57,6 +57,16 @@ config IPV6_ROUTE_INFO
 
 	  If unsure, say N.
 
+config IPV6_OPTIMISTIC_DAD
+	bool "IPv6: Enable RFC 4429 Optimistic DAD (EXPERIMENTAL)"
+	depends on IPV6 && EXPERIMENTAL
+	---help---
+	  This is experimental support for optimistic Duplicate
+	  Address Detection.  It allows for autoconfigured addresses
+	  to be used more quickly.
+
+	  If unsure, say N.
+
 config INET6_AH
 	tristate "IPv6: AH transformation"
 	depends on IPV6
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index e385469..c884eeb 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -594,6 +594,16 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr, int pfxlen,
 
 	ifa->rt = rt;
 
+	/*
+	 * part one of RFC 4429, section 3.3
+	 * We should not configure an address as 
+	 * optimistic if we do not yet know the link
+	 * layer address of our nexhop router
+	 */
+
+	if (rt->rt6i_nexthop == NULL)
+		ifa->flags &= ~IFA_F_OPTIMISTIC;
+
 	ifa->idev = idev;
 	in6_dev_hold(idev);
 	/* For caller */
@@ -770,6 +780,7 @@ static int ipv6_create_tempaddr(struct inet6_ifaddr *ifp, struct inet6_ifaddr *i
 	int tmp_plen;
 	int ret = 0;
 	int max_addresses;
+	u32 addr_flags;
 
 	write_lock(&idev->lock);
 	if (ift) {
@@ -827,10 +838,17 @@ retry:
 	spin_unlock_bh(&ifp->lock);
 
 	write_unlock(&idev->lock);
+
+	addr_flags = IFA_F_TEMPORARY;
+	/* set in addrconf_prefix_rcv() */
+	if (ifp->flags & IFA_F_OPTIMISTIC)
+		addr_flags |= IFA_F_OPTIMISTIC;
+
 	ift = !max_addresses ||
 	      ipv6_count_addresses(idev) < max_addresses ? 
 		ipv6_add_addr(idev, &addr, tmp_plen,
-			      ipv6_addr_type(&addr)&IPV6_ADDR_SCOPE_MASK, IFA_F_TEMPORARY) : NULL;
+			      ipv6_addr_type(&addr)&IPV6_ADDR_SCOPE_MASK, 
+			      addr_flags) : NULL;
 	if (!ift || IS_ERR(ift)) {
 		in6_ifa_put(ifp);
 		in6_dev_put(idev);
@@ -962,13 +980,14 @@ int ipv6_dev_get_saddr(struct net_device *daddr_dev,
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
@@ -1027,15 +1046,17 @@ int ipv6_dev_get_saddr(struct net_device *daddr_dev,
 				}
 			}
 
-			/* Rule 3: Avoid deprecated address */
+			/* Rule 3: Avoid deprecated and optimistic addresses */
 			if (hiscore.rule < 3) {
 				if (ipv6_saddr_preferred(hiscore.addr_type) ||
-				    !(ifa_result->flags & IFA_F_DEPRECATED))
+				   (((ifa_result->flags &
+				    (IFA_F_DEPRECATED|IFA_F_OPTIMISTIC)) == 0)))
 					hiscore.attrs |= IPV6_SADDR_SCORE_PREFERRED;
 				hiscore.rule++;
 			}
 			if (ipv6_saddr_preferred(score.addr_type) ||
-			    !(ifa->flags & IFA_F_DEPRECATED)) {
+			   (((ifa_result->flags &
+			    (IFA_F_DEPRECATED|IFA_F_OPTIMISTIC)) == 0))) {
 				score.attrs |= IPV6_SADDR_SCORE_PREFERRED;
 				if (!(hiscore.attrs & IPV6_SADDR_SCORE_PREFERRED)) {
 					score.rule = 3;
@@ -1174,7 +1195,8 @@ int ipv6_get_saddr(struct dst_entry *dst,
 }
 
 
-int ipv6_get_lladdr(struct net_device *dev, struct in6_addr *addr)
+int ipv6_get_lladdr(struct net_device *dev, struct in6_addr *addr, 
+		    unsigned char banned_flags)
 {
 	struct inet6_dev *idev;
 	int err = -EADDRNOTAVAIL;
@@ -1185,7 +1207,7 @@ int ipv6_get_lladdr(struct net_device *dev, struct in6_addr *addr)
 
 		read_lock_bh(&idev->lock);
 		for (ifp=idev->addr_list; ifp; ifp=ifp->if_next) {
-			if (ifp->scope == IFA_LINK && !(ifp->flags&IFA_F_TENTATIVE)) {
+			if (ifp->scope == IFA_LINK && !(ifp->flags & banned_flags)) {
 				ipv6_addr_copy(addr, &ifp->addr);
 				err = 0;
 				break;
@@ -1735,6 +1757,13 @@ ok:
 
 		if (ifp == NULL && valid_lft) {
 			int max_addresses = in6_dev->cnf.max_addresses;
+			u32 addr_flags = 0;
+
+#ifdef CONFIG_IPV6_OPTIMISTIC_DAD
+			if (in6_dev->cnf.optimistic_dad &&
+			    !ipv6_devconf.forwarding)
+				addr_flags = IFA_F_OPTIMISTIC;
+#endif
 
 			/* Do not allow to create too much of autoconfigured
 			 * addresses; this would be too easy way to crash kernel.
@@ -1742,7 +1771,8 @@ ok:
 			if (!max_addresses ||
 			    ipv6_count_addresses(in6_dev) < max_addresses)
 				ifp = ipv6_add_addr(in6_dev, &addr, pinfo->prefix_len,
-						    addr_type&IPV6_ADDR_SCOPE_MASK, 0);
+						    addr_type&IPV6_ADDR_SCOPE_MASK,
+						    addr_flags);
 
 			if (!ifp || IS_ERR(ifp)) {
 				in6_dev_put(in6_dev);
@@ -1945,7 +1975,11 @@ static int inet6_addr_add(int ifindex, struct in6_addr *pfx, int plen,
 		ifp->prefered_lft = prefered_lft;
 		ifp->tstamp = jiffies;
 		spin_unlock_bh(&ifp->lock);
-
+		/*
+		 * Note that section 3.1 of RFC 4429 indicates
+		 * that the Optimistic flag should not be set for
+		 * manually configured addresses
+		 */
 		addrconf_dad_start(ifp, 0);
 		in6_ifa_put(ifp);
 		addrconf_verify(0);
@@ -2122,8 +2156,16 @@ static void init_loopback(struct net_device *dev)
 static void addrconf_add_linklocal(struct inet6_dev *idev, struct in6_addr *addr)
 {
 	struct inet6_ifaddr * ifp;
+	u32 addr_flags = IFA_F_PERMANENT;
 
-	ifp = ipv6_add_addr(idev, addr, 64, IFA_LINK, IFA_F_PERMANENT);
+#ifdef CONFIG_IPV6_OPTIMISTIC_DAD
+	if (idev->cnf.optimistic_dad &&
+	    !ipv6_devconf.forwarding)
+		addr_flags |= IFA_F_OPTIMISTIC;
+#endif
+
+
+	ifp = ipv6_add_addr(idev, addr, 64, IFA_LINK, addr_flags);
 	if (!IS_ERR(ifp)) {
 		addrconf_dad_start(ifp, 0);
 		in6_ifa_put(ifp);
@@ -2190,7 +2232,7 @@ ipv6_inherit_linklocal(struct inet6_dev *idev, struct net_device *link_dev)
 {
 	struct in6_addr lladdr;
 
-	if (!ipv6_get_lladdr(link_dev, &lladdr)) {
+	if (!ipv6_get_lladdr(link_dev, &lladdr, IFA_F_TENTATIVE)) {
 		addrconf_add_linklocal(idev, &lladdr);
 		return 0;
 	}
@@ -2527,7 +2569,11 @@ static void addrconf_dad_kick(struct inet6_ifaddr *ifp)
 	unsigned long rand_num;
 	struct inet6_dev *idev = ifp->idev;
 
-	rand_num = net_random() % (idev->cnf.rtr_solicit_delay ? : 1);
+	if (ifp->flags & IFA_F_OPTIMISTIC)
+		rand_num = 0;
+	else
+		rand_num = net_random() % (idev->cnf.rtr_solicit_delay ? : 1);
+
 	ifp->probes = idev->cnf.dad_transmits;
 	addrconf_mod_timer(ifp, AC_DAD, rand_num);
 }
@@ -2553,7 +2599,7 @@ static void addrconf_dad_start(struct inet6_ifaddr *ifp, u32 flags)
 	if (dev->flags&(IFF_NOARP|IFF_LOOPBACK) ||
 	    !(ifp->flags&IFA_F_TENTATIVE) ||
 	    ifp->flags & IFA_F_NODAD) {
-		ifp->flags &= ~IFA_F_TENTATIVE;
+		ifp->flags &= ~(IFA_F_TENTATIVE|IFA_F_OPTIMISTIC);
 		spin_unlock_bh(&ifp->lock);
 		read_unlock_bh(&idev->lock);
 
@@ -2597,7 +2643,7 @@ static void addrconf_dad_timer(unsigned long data)
 		 * DAD was successful
 		 */
 
-		ifp->flags &= ~IFA_F_TENTATIVE;
+		ifp->flags &= ~(IFA_F_TENTATIVE|IFA_F_OPTIMISTIC);
 		spin_unlock_bh(&ifp->lock);
 		read_unlock_bh(&idev->lock);
 
@@ -3398,6 +3444,9 @@ static void inline ipv6_store_devconf(struct ipv6_devconf *cnf,
 #endif
 #endif
 	array[DEVCONF_PROXY_NDP] = cnf->proxy_ndp;
+#ifdef CONFIG_IPV6_OPTIMISTIC_DAD
+	array[DEVCONF_OPTIMISTIC_DAD] = cnf->optimistic_dad;
+#endif
 }
 
 static inline size_t inet6_if_nlmsg_size(void)
@@ -3917,6 +3966,17 @@ static struct addrconf_sysctl_table
 			.mode		=	0644,
 			.proc_handler	=	&proc_dointvec,
 		},
+#ifdef CONFIG_IPV6_OPTIMISTIC_DAD
+		{
+			.ctl_name	=	NET_IPV6_OPTIMISTIC_DAD,
+			.procname       =       "optimistic_dad",
+			.data           =       &ipv6_devconf.optimistic_dad,
+			.maxlen         =       sizeof(int),
+			.mode           =       0644,
+			.proc_handler   =       &proc_dointvec,
+
+		},
+#endif
 		{
 			.ctl_name	=	0,	/* sentinel */
 		}
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 7b7bd44..8a1ea96 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -859,6 +859,34 @@ static int ip6_dst_lookup_tail(struct sock *sk,
 		err = ipv6_get_saddr(*dst, &fl->fl6_dst, &fl->fl6_src);
 		if (err)
 			goto out_err_release;
+#ifdef CONFIG_IPV6_OPTIMISTIC_DAD
+		/*
+		 * Here if the dst entry we've looked up 
+		 * has a neighbour entry that is in the INCOMPLETE
+		 * state and the src address from the flow is 
+		 * marked as OPTIMISTIC, we release the found 
+		 * dst entry and replace it instead with the 
+		 * dst entry of the nexthop router
+		 */
+		if (!((*dst)->neighbour->nud_state & NUD_VALID)) {
+			struct inet6_ifaddr *ifp;
+			struct flowi fl_gw;
+			ifp = ipv6_get_ifaddr(&fl->fl6_src, (*dst)->dev, 1);
+
+			if (ifp && ifp->flags & IFA_F_OPTIMISTIC) {
+				/*
+				 * We need to get the dst entry for the 
+				 * default router instead
+				 */
+				dst_release(*dst);
+				memcpy(&fl_gw, fl, sizeof(struct flowi));
+				memset(&fl_gw.fl6_dst, 0, sizeof(struct in6_addr));
+				*dst = ip6_route_output(sk, &fl_gw);
+				if ((err = (*dst)->error))
+					goto out_err_release;				
+			}
+		}
+#endif
 	}
 
 	return 0;
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
index 39bb658..919db04 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -447,6 +447,8 @@ static void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
 	ifp = ipv6_get_ifaddr(solicited_addr, dev, 1);
  	if (ifp) {
 		src_addr = solicited_addr;
+		if (ifp->flags & IFA_F_OPTIMISTIC)
+			override = 0;
 		in6_ifa_put(ifp);
 	} else {
 		if (ipv6_dev_get_saddr(dev, daddr, &tmpaddr))
@@ -542,7 +544,8 @@ void ndisc_send_ns(struct net_device *dev, struct neighbour *neigh,
 	int send_llinfo;
 
 	if (saddr == NULL) {
-		if (ipv6_get_lladdr(dev, &addr_buf))
+		if (ipv6_get_lladdr(dev, &addr_buf, 
+				   (IFA_F_TENTATIVE|IFA_F_OPTIMISTIC)))
 			return;
 		saddr = &addr_buf;
 	}
@@ -559,7 +562,7 @@ void ndisc_send_ns(struct net_device *dev, struct neighbour *neigh,
 		return;
 
 	len = sizeof(struct icmp6hdr) + sizeof(struct in6_addr);
-	send_llinfo = dev->addr_len && !ipv6_addr_any(saddr);
+	send_llinfo = dev->addr_len && !ipv6_addr_any(saddr); 
 	if (send_llinfo)
 		len += ndisc_opt_addr_space(dev);
 
@@ -622,9 +625,29 @@ void ndisc_send_rs(struct net_device *dev, struct in6_addr *saddr,
         struct sk_buff *skb;
         struct icmp6hdr *hdr;
 	__u8 * opt;
+	struct inet6_ifaddr *ifp;
+	int send_sllao = 1;
         int len;
 	int err;
 
+	/*
+	 * Check the source address.  If its OPTIMISTIC
+	 * and addr_len is non-zero (implying the sllao option)
+	 * then don't send the RS (RFC 4429, section 2.2)
+	 */
+	ifp = ipv6_get_ifaddr(saddr, dev, 1);
+
+	/*
+	 * According to section 2.2 of RFC 4429, we must not 
+	 * send router solicitations with a sllao from 
+	 * optimistic addresses, but we may send the solicitation
+	 * if we don't include the sllao.  So here we check
+	 * if our address is optimistic, and if so, we
+	 * supress the inclusion of the sllao.
+	 */ 
+	if (!dev->addr_len || !ifp || (ifp->flags & IFA_F_OPTIMISTIC))
+		send_sllao=0;
+
 	ndisc_flow_init(&fl, NDISC_ROUTER_SOLICITATION, saddr, daddr,
 			dev->ifindex);
 
@@ -637,7 +660,7 @@ void ndisc_send_rs(struct net_device *dev, struct in6_addr *saddr,
 		return;
 
 	len = sizeof(struct icmp6hdr);
-	if (dev->addr_len)
+	if (dev->addr_len && send_sllao)
 		len += ndisc_opt_addr_space(dev);
 
         skb = sock_alloc_send_skb(sk,
@@ -664,7 +687,7 @@ void ndisc_send_rs(struct net_device *dev, struct in6_addr *saddr,
 
 	opt = (u8*) (hdr + 1);
 
-	if (dev->addr_len)
+	if (dev->addr_len && send_sllao)
 		ndisc_fill_addr_option(opt, ND_OPT_SOURCE_LL_ADDR, dev->dev_addr,
 				       dev->addr_len, dev->type);
 
@@ -796,28 +819,39 @@ static void ndisc_recv_ns(struct sk_buff *skb)
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
@@ -1406,7 +1440,7 @@ void ndisc_send_redirect(struct sk_buff *skb, struct neighbour *neigh,
 
 	dev = skb->dev;
 
-	if (ipv6_get_lladdr(dev, &saddr_buf)) {
+	if (ipv6_get_lladdr(dev, &saddr_buf, IFA_F_TENTATIVE)) {
 		ND_PRINTK2(KERN_WARNING
 			   "ICMPv6 Redirect: no link-local address on %s\n",
 			   dev->name);
