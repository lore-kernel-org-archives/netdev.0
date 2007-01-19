From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] IPv6: Implement RFC 4429 Optimistic Duplicate Address Detection
Date: Fri, 19 Jan 2007 16:23:14 -0500
Message-ID: <20070119212314.GA10748@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3171 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964932AbXASWAd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Jan 2007 17:00:33 -0500
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@coreworks.de
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patch to Implement IPv6 RFC 4429 (Optimistic Duplicate Address Detection).  In
short, this is a feature whereby a node with a Tentative address can begin to
make use of that address almost immediately after its configured.  To enable
this, extra rules need to be followed during the Duplicate address detection
phase of the addresses configuration, so that in the event of a collision,
neighboring nodes do not have thier neighbor caches affected adversely by the
optimistic node.  This patch implements those rules as outlined in the RFC.

I have a fairly limited testing environment here, but from the testing I've
done, this patch appears to conform to the rules as outlined in RFC 4429, causes
no adverse affects on normal IPv6 operation when in use, and doesn't seem to
break anything when disabled via the sysctl.

Comments and Reviews appreciated.

Thanks and Regards
Neil


Signed-Off-By: Neil Horman <nhorman@tuxdriver.com>


 include/linux/if_addr.h    |    1 
 include/linux/sysctl.h     |    1 
 include/net/addrconf.h     |    4 ++-
 include/net/ipv6.h         |    1 
 net/ipv6/addrconf.c        |   50 +++++++++++++++++++++++++++++++-------
 net/ipv6/mcast.c           |    4 +--
 net/ipv6/ndisc.c           |   59 ++++++++++++++++++++++++++++++++++++++-------
 net/ipv6/sysctl_net_ipv6.c |    8 ++++++
 8 files changed, 107 insertions(+), 21 deletions(-)


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
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 81480e6..62034c3 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -531,6 +531,7 @@ enum {
 	NET_IPV6_IP6FRAG_TIME=23,
 	NET_IPV6_IP6FRAG_SECRET_INTERVAL=24,
 	NET_IPV6_MLD_MAX_MSF=25,
+	NET_IPV6_OPT_DAD_ENABLE=26,
 };
 
 enum {
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
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 00328b7..dd16169 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -110,6 +110,7 @@ struct frag_hdr {
 /* sysctls */
 extern int sysctl_ipv6_bindv6only;
 extern int sysctl_mld_max_msf;
+extern int sysctl_optimistic_dad;
 
 /* MIBs */
 DECLARE_SNMP_STAT(struct ipstats_mib, ipv6_statistics);
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 2a7e461..f7afb2a 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -206,6 +206,8 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 	.proxy_ndp		= 0,
 };
 
+int sysctl_optimistic_dad = 1;
+
 /* IPv6 Wildcard Address and Loopback Address defined by RFC2553 */
 #if 0
 const struct in6_addr in6addr_any = IN6ADDR_ANY_INIT;
@@ -830,7 +832,8 @@ retry:
 	ift = !max_addresses ||
 	      ipv6_count_addresses(idev) < max_addresses ? 
 		ipv6_add_addr(idev, &addr, tmp_plen,
-			      ipv6_addr_type(&addr)&IPV6_ADDR_SCOPE_MASK, IFA_F_TEMPORARY) : NULL;
+			      ipv6_addr_type(&addr)&IPV6_ADDR_SCOPE_MASK, 
+				IFA_F_TEMPORARY|IFA_F_OPTIMISTIC) : NULL;
 	if (!ift || IS_ERR(ift)) {
 		in6_ifa_put(ifp);
 		in6_dev_put(idev);
@@ -1174,7 +1177,8 @@ int ipv6_get_saddr(struct dst_entry *dst,
 }
 
 
-int ipv6_get_lladdr(struct net_device *dev, struct in6_addr *addr)
+int ipv6_get_lladdr(struct net_device *dev, struct in6_addr *addr, 
+			unsigned char banned_flags)
 {
 	struct inet6_dev *idev;
 	int err = -EADDRNOTAVAIL;
@@ -1185,7 +1189,7 @@ int ipv6_get_lladdr(struct net_device *dev, struct in6_addr *addr)
 
 		read_lock_bh(&idev->lock);
 		for (ifp=idev->addr_list; ifp; ifp=ifp->if_next) {
-			if (ifp->scope == IFA_LINK && !(ifp->flags&IFA_F_TENTATIVE)) {
+			if (ifp->scope == IFA_LINK && !(ifp->flags&banned_flags)) {
 				ipv6_addr_copy(addr, &ifp->addr);
 				err = 0;
 				break;
@@ -1742,7 +1746,7 @@ ok:
 			if (!max_addresses ||
 			    ipv6_count_addresses(in6_dev) < max_addresses)
 				ifp = ipv6_add_addr(in6_dev, &addr, pinfo->prefix_len,
-						    addr_type&IPV6_ADDR_SCOPE_MASK, 0);
+						    addr_type&IPV6_ADDR_SCOPE_MASK,0);
 
 			if (!ifp || IS_ERR(ifp)) {
 				in6_dev_put(in6_dev);
@@ -1751,6 +1755,7 @@ ok:
 
 			update_lft = create = 1;
 			ifp->cstamp = jiffies;
+			ifp->flags |= IFA_F_OPTIMISTIC;
 			addrconf_dad_start(ifp, RTF_ADDRCONF|RTF_PREFIX_RT);
 		}
 
@@ -1945,7 +1950,11 @@ static int inet6_addr_add(int ifindex, struct in6_addr *pfx, int plen,
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
@@ -2123,7 +2132,8 @@ static void addrconf_add_linklocal(struct inet6_dev *idev, struct in6_addr *addr
 {
 	struct inet6_ifaddr * ifp;
 
-	ifp = ipv6_add_addr(idev, addr, 64, IFA_LINK, IFA_F_PERMANENT);
+	ifp = ipv6_add_addr(idev, addr, 64, IFA_LINK, 
+		IFA_F_PERMANENT|IFA_F_OPTIMISTIC);
 	if (!IS_ERR(ifp)) {
 		addrconf_dad_start(ifp, 0);
 		in6_ifa_put(ifp);
@@ -2190,7 +2200,7 @@ ipv6_inherit_linklocal(struct inet6_dev *idev, struct net_device *link_dev)
 {
 	struct in6_addr lladdr;
 
-	if (!ipv6_get_lladdr(link_dev, &lladdr)) {
+	if (!ipv6_get_lladdr(link_dev, &lladdr, IFA_F_TENTATIVE)) {
 		addrconf_add_linklocal(idev, &lladdr);
 		return 0;
 	}
@@ -2537,8 +2547,18 @@ static void addrconf_dad_start(struct inet6_ifaddr *ifp, u32 flags)
 	struct inet6_dev *idev = ifp->idev;
 	struct net_device *dev = idev->dev;
 
+	if (!sysctl_optimistic_dad)
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
@@ -2553,7 +2573,7 @@ static void addrconf_dad_start(struct inet6_ifaddr *ifp, u32 flags)
 	if (dev->flags&(IFF_NOARP|IFF_LOOPBACK) ||
 	    !(ifp->flags&IFA_F_TENTATIVE) ||
 	    ifp->flags & IFA_F_NODAD) {
-		ifp->flags &= ~IFA_F_TENTATIVE;
+		ifp->flags &= ~(IFA_F_TENTATIVE|IFA_F_OPTIMISTIC);
 		spin_unlock_bh(&ifp->lock);
 		read_unlock_bh(&idev->lock);
 
@@ -2573,6 +2593,18 @@ static void addrconf_dad_start(struct inet6_ifaddr *ifp, u32 flags)
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
@@ -2597,7 +2629,7 @@ static void addrconf_dad_timer(unsigned long data)
 		 * DAD was successful
 		 */
 
-		ifp->flags &= ~IFA_F_TENTATIVE;
+		ifp->flags &= ~(IFA_F_TENTATIVE|IFA_F_OPTIMISTIC);
 		spin_unlock_bh(&ifp->lock);
 		read_unlock_bh(&idev->lock);
 
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
index 6a9f616..a5bcba1 100644
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
+			(IFA_F_TENTATIVE|IFA_F_OPTIMISTIC)))
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
@@ -796,11 +823,13 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 	inc = ipv6_addr_is_multicast(daddr);
 
 	if ((ifp = ipv6_get_ifaddr(&msg->target, dev, 1)) != NULL) {
-		if (ifp->flags & IFA_F_TENTATIVE) {
+
+		if (ifp->flags & (IFA_F_TENTATIVE|IFA_F_OPTIMISTIC)) {
 			/* Address is tentative. If the source
-			   is unspecified address, it is someone
-			   does DAD, otherwise we ignore solicitations
-			   until DAD timer expires.
+			   is unspecified address, someone else
+			   is doing DAD, and if its not us, then
+			   we need to fail our own DAD
+			   RFC 4429 Sec 3.3
 			 */
 			if (!dad)
 				goto out;
@@ -816,8 +845,20 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 					goto out;
 				}
 			}
-			addrconf_dad_failure(ifp); 
-			return;
+
+			/* The one exception to the above rule about 
+			   optimistic addresses is that we need to always 
+			   respond to an NS from a unicast address if we are
+			   optimistic. RFC 4429 Sec 3.3.  If (unicast
+			   and optimistic) are false then we can just fail
+			   dad now.
+			*/
+			type = ipv6_addr_type(saddr);			
+			if (!((ifp->flags & IFA_F_OPTIMISTIC) && 
+			    (type & IPV6_ADDR_UNICAST))) {
+				addrconf_dad_failure(ifp); 
+				return;
+			}
 		}
 
 		idev = ifp->idev;
@@ -1406,7 +1447,7 @@ void ndisc_send_redirect(struct sk_buff *skb, struct neighbour *neigh,
 
 	dev = skb->dev;
 
-	if (ipv6_get_lladdr(dev, &saddr_buf)) {
+	if (ipv6_get_lladdr(dev, &saddr_buf, IFA_F_TENTATIVE)) {
 		ND_PRINTK2(KERN_WARNING
 			   "ICMPv6 Redirect: no link-local address on %s\n",
 			   dev->name);
diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index 7a4639d..3a8dee5 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -80,6 +80,14 @@ static ctl_table ipv6_table[] = {
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec
 	},
+	{
+		.ctl_name	= NET_IPV6_OPT_DAD_ENABLE,
+		.procname	= "ip6optimistic_dad_enable",
+		.data		= &sysctl_optimistic_dad,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec
+	},
 	{ .ctl_name = 0 }
 };
 
