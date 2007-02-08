From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] IPv6: Implement RFC 4429 Optimistic Duplicate Address Detection
Date: Thu, 8 Feb 2007 14:32:10 -0500
Message-ID: <20070208193210.GC27267@hmsreliant.homelinux.net>
References: <20070207205503.GB20804@hmsreliant.homelinux.net> <20070208.072620.63000777.yoshfuji@linux-ipv6.org> <20070208164151.GB27267@hmsreliant.homelinux.net> <20070209.021037.04063577.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: vladislav.yasevich@hp.com, sri@us.ibm.com, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	kaber@coreworks.de, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4585 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423262AbXBHTeF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Feb 2007 14:34:05 -0500
Content-Disposition: inline
In-Reply-To: <20070209.021037.04063577.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 09, 2007 at 02:10:37AM +0900, YOSHIFUJI Hideaki / =E5=90=89=
=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> In article <20070208164151.GB27267@hmsreliant.homelinux.net> (at Thu,=
 8 Feb 2007 11:41:52 -0500), Neil Horman <nhorman@tuxdriver.com> says:
>=20
><snip>=20
> These should be placed
>=20
> >  	}
>=20
> here. No?
>=20
Yes, you're right.  After re-reading the logic, its pretty evident that=
 you want
to do the optimistic dad checks regardless of weather the flows initial=
 source
address is the anycast address.

><snip>
>=20
> Still leaking ifp.  Something like this?
>=20
> int send_sllao =3D dev->addr_len;
>=20
> #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
> if (send_sllao) {
>   struct inet6_ifaddr *ifp =3D ipv6_get_ifaddr(saddr, dev, 1);
>   if (ifp) {
>      if (ifp->flags & IFA_F_OPTIMISTIC)
>        send_sllao =3D 0;
>      in6_ifa_put(ifp);
>   } else
>      send_sllao =3D 0;
> }
> #endif
>=20
Yeah, definately another leak.  You're fix looks good to me.

New patch attached with these fixes included


Thanks & Regards
Neil

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 include/linux/if_addr.h |    1=20
 include/linux/ipv6.h    |    4 ++
 include/linux/sysctl.h  |    1=20
 include/net/addrconf.h  |    4 +-
 net/ipv6/Kconfig        |   10 +++++
 net/ipv6/addrconf.c     |   90 +++++++++++++++++++++++++++++++++++++++=
+--------
 net/ipv6/ip6_output.c   |   35 ++++++++++++++++++
 net/ipv6/mcast.c        |    4 +-
 net/ipv6/ndisc.c        |   84 ++++++++++++++++++++++++++++++++-------=
-----
 9 files changed, 192 insertions(+), 41 deletions(-)




diff --git a/include/linux/if_addr.h b/include/linux/if_addr.h
index d557e4c..43f3bed 100644
--- a/include/linux/if_addr.h
+++ b/include/linux/if_addr.h
@@ -39,6 +39,7 @@ enum
 #define IFA_F_TEMPORARY		IFA_F_SECONDARY
=20
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
=20
@@ -205,6 +208,7 @@ enum {
 	DEVCONF_RTR_PROBE_INTERVAL,
 	DEVCONF_ACCEPT_RA_RT_INFO_MAX_PLEN,
 	DEVCONF_PROXY_NDP,
+	DEVCONF_OPTIMISTIC_DAD,
 	DEVCONF_MAX
 };
=20
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 81480e6..972a33a 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -570,6 +570,7 @@ enum {
 	NET_IPV6_RTR_PROBE_INTERVAL=3D21,
 	NET_IPV6_ACCEPT_RA_RT_INFO_MAX_PLEN=3D22,
 	NET_IPV6_PROXY_NDP=3D23,
+	NET_IPV6_OPTIMISTIC_DAD=3D24,
 	__NET_IPV6_MAX
 };
=20
diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 88df8fc..d248a19 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -73,7 +73,9 @@ extern int			ipv6_get_saddr(struct dst_entry *dst,
 extern int			ipv6_dev_get_saddr(struct net_device *dev,=20
 					       struct in6_addr *daddr,
 					       struct in6_addr *saddr);
-extern int			ipv6_get_lladdr(struct net_device *dev, struct in6_addr *=
);
+extern int			ipv6_get_lladdr(struct net_device *dev,=20
+						struct in6_addr *,
+						unsigned char banned_flags);
 extern int			ipv6_rcv_saddr_equal(const struct sock *sk,=20
 						      const struct sock *sk2);
 extern void			addrconf_join_solict(struct net_device *dev,
diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index deb4101..822d3eb 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -57,6 +57,16 @@ config IPV6_ROUTE_INFO
=20
 	  If unsure, say N.
=20
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
@@ -594,6 +594,16 @@ ipv6_add_addr(struct inet6_dev *idev, const struct=
 in6_addr *addr, int pfxlen,
=20
 	ifa->rt =3D rt;
=20
+	/*
+	 * part one of RFC 4429, section 3.3
+	 * We should not configure an address as=20
+	 * optimistic if we do not yet know the link
+	 * layer address of our nexhop router
+	 */
+
+	if (rt->rt6i_nexthop =3D=3D NULL)
+		ifa->flags &=3D ~IFA_F_OPTIMISTIC;
+
 	ifa->idev =3D idev;
 	in6_dev_hold(idev);
 	/* For caller */
@@ -770,6 +780,7 @@ static int ipv6_create_tempaddr(struct inet6_ifaddr=
 *ifp, struct inet6_ifaddr *i
 	int tmp_plen;
 	int ret =3D 0;
 	int max_addresses;
+	u32 addr_flags;
=20
 	write_lock(&idev->lock);
 	if (ift) {
@@ -827,10 +838,17 @@ retry:
 	spin_unlock_bh(&ifp->lock);
=20
 	write_unlock(&idev->lock);
+
+	addr_flags =3D IFA_F_TEMPORARY;
+	/* set in addrconf_prefix_rcv() */
+	if (ifp->flags & IFA_F_OPTIMISTIC)
+		addr_flags |=3D IFA_F_OPTIMISTIC;
+
 	ift =3D !max_addresses ||
 	      ipv6_count_addresses(idev) < max_addresses ?=20
 		ipv6_add_addr(idev, &addr, tmp_plen,
-			      ipv6_addr_type(&addr)&IPV6_ADDR_SCOPE_MASK, IFA_F_TEMPORARY) =
: NULL;
+			      ipv6_addr_type(&addr)&IPV6_ADDR_SCOPE_MASK,=20
+			      addr_flags) : NULL;
 	if (!ift || IS_ERR(ift)) {
 		in6_ifa_put(ifp);
 		in6_dev_put(idev);
@@ -962,13 +980,14 @@ int ipv6_dev_get_saddr(struct net_device *daddr_d=
ev,
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
 			if (unlikely(score.addr_type =3D=3D IPV6_ADDR_ANY ||
 				     score.addr_type & IPV6_ADDR_MULTICAST)) {
@@ -1027,15 +1046,17 @@ int ipv6_dev_get_saddr(struct net_device *daddr=
_dev,
 				}
 			}
=20
-			/* Rule 3: Avoid deprecated address */
+			/* Rule 3: Avoid deprecated and optimistic addresses */
 			if (hiscore.rule < 3) {
 				if (ipv6_saddr_preferred(hiscore.addr_type) ||
-				    !(ifa_result->flags & IFA_F_DEPRECATED))
+				   (((ifa_result->flags &
+				    (IFA_F_DEPRECATED|IFA_F_OPTIMISTIC)) =3D=3D 0)))
 					hiscore.attrs |=3D IPV6_SADDR_SCORE_PREFERRED;
 				hiscore.rule++;
 			}
 			if (ipv6_saddr_preferred(score.addr_type) ||
-			    !(ifa->flags & IFA_F_DEPRECATED)) {
+			   (((ifa_result->flags &
+			    (IFA_F_DEPRECATED|IFA_F_OPTIMISTIC)) =3D=3D 0))) {
 				score.attrs |=3D IPV6_SADDR_SCORE_PREFERRED;
 				if (!(hiscore.attrs & IPV6_SADDR_SCORE_PREFERRED)) {
 					score.rule =3D 3;
@@ -1174,7 +1195,8 @@ int ipv6_get_saddr(struct dst_entry *dst,
 }
=20
=20
-int ipv6_get_lladdr(struct net_device *dev, struct in6_addr *addr)
+int ipv6_get_lladdr(struct net_device *dev, struct in6_addr *addr,=20
+		    unsigned char banned_flags)
 {
 	struct inet6_dev *idev;
 	int err =3D -EADDRNOTAVAIL;
@@ -1185,7 +1207,7 @@ int ipv6_get_lladdr(struct net_device *dev, struc=
t in6_addr *addr)
=20
 		read_lock_bh(&idev->lock);
 		for (ifp=3Didev->addr_list; ifp; ifp=3Difp->if_next) {
-			if (ifp->scope =3D=3D IFA_LINK && !(ifp->flags&IFA_F_TENTATIVE)) {
+			if (ifp->scope =3D=3D IFA_LINK && !(ifp->flags & banned_flags)) {
 				ipv6_addr_copy(addr, &ifp->addr);
 				err =3D 0;
 				break;
@@ -1735,6 +1757,13 @@ ok:
=20
 		if (ifp =3D=3D NULL && valid_lft) {
 			int max_addresses =3D in6_dev->cnf.max_addresses;
+			u32 addr_flags =3D 0;
+
+#ifdef CONFIG_IPV6_OPTIMISTIC_DAD
+			if (in6_dev->cnf.optimistic_dad &&
+			    !ipv6_devconf.forwarding)
+				addr_flags =3D IFA_F_OPTIMISTIC;
+#endif
=20
 			/* Do not allow to create too much of autoconfigured
 			 * addresses; this would be too easy way to crash kernel.
@@ -1742,7 +1771,8 @@ ok:
 			if (!max_addresses ||
 			    ipv6_count_addresses(in6_dev) < max_addresses)
 				ifp =3D ipv6_add_addr(in6_dev, &addr, pinfo->prefix_len,
-						    addr_type&IPV6_ADDR_SCOPE_MASK, 0);
+						    addr_type&IPV6_ADDR_SCOPE_MASK,
+						    addr_flags);
=20
 			if (!ifp || IS_ERR(ifp)) {
 				in6_dev_put(in6_dev);
@@ -1945,7 +1975,11 @@ static int inet6_addr_add(int ifindex, struct in=
6_addr *pfx, int plen,
 		ifp->prefered_lft =3D prefered_lft;
 		ifp->tstamp =3D jiffies;
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
@@ -2122,8 +2156,16 @@ static void init_loopback(struct net_device *dev=
)
 static void addrconf_add_linklocal(struct inet6_dev *idev, struct in6_=
addr *addr)
 {
 	struct inet6_ifaddr * ifp;
+	u32 addr_flags =3D IFA_F_PERMANENT;
=20
-	ifp =3D ipv6_add_addr(idev, addr, 64, IFA_LINK, IFA_F_PERMANENT);
+#ifdef CONFIG_IPV6_OPTIMISTIC_DAD
+	if (idev->cnf.optimistic_dad &&
+	    !ipv6_devconf.forwarding)
+		addr_flags |=3D IFA_F_OPTIMISTIC;
+#endif
+
+
+	ifp =3D ipv6_add_addr(idev, addr, 64, IFA_LINK, addr_flags);
 	if (!IS_ERR(ifp)) {
 		addrconf_dad_start(ifp, 0);
 		in6_ifa_put(ifp);
@@ -2190,7 +2232,7 @@ ipv6_inherit_linklocal(struct inet6_dev *idev, st=
ruct net_device *link_dev)
 {
 	struct in6_addr lladdr;
=20
-	if (!ipv6_get_lladdr(link_dev, &lladdr)) {
+	if (!ipv6_get_lladdr(link_dev, &lladdr, IFA_F_TENTATIVE)) {
 		addrconf_add_linklocal(idev, &lladdr);
 		return 0;
 	}
@@ -2527,7 +2569,11 @@ static void addrconf_dad_kick(struct inet6_ifadd=
r *ifp)
 	unsigned long rand_num;
 	struct inet6_dev *idev =3D ifp->idev;
=20
-	rand_num =3D net_random() % (idev->cnf.rtr_solicit_delay ? : 1);
+	if (ifp->flags & IFA_F_OPTIMISTIC)
+		rand_num =3D 0;
+	else
+		rand_num =3D net_random() % (idev->cnf.rtr_solicit_delay ? : 1);
+
 	ifp->probes =3D idev->cnf.dad_transmits;
 	addrconf_mod_timer(ifp, AC_DAD, rand_num);
 }
@@ -2553,7 +2599,7 @@ static void addrconf_dad_start(struct inet6_ifadd=
r *ifp, u32 flags)
 	if (dev->flags&(IFF_NOARP|IFF_LOOPBACK) ||
 	    !(ifp->flags&IFA_F_TENTATIVE) ||
 	    ifp->flags & IFA_F_NODAD) {
-		ifp->flags &=3D ~IFA_F_TENTATIVE;
+		ifp->flags &=3D ~(IFA_F_TENTATIVE|IFA_F_OPTIMISTIC);
 		spin_unlock_bh(&ifp->lock);
 		read_unlock_bh(&idev->lock);
=20
@@ -2597,7 +2643,7 @@ static void addrconf_dad_timer(unsigned long data=
)
 		 * DAD was successful
 		 */
=20
-		ifp->flags &=3D ~IFA_F_TENTATIVE;
+		ifp->flags &=3D ~(IFA_F_TENTATIVE|IFA_F_OPTIMISTIC);
 		spin_unlock_bh(&ifp->lock);
 		read_unlock_bh(&idev->lock);
=20
@@ -3398,6 +3444,9 @@ static void inline ipv6_store_devconf(struct ipv6=
_devconf *cnf,
 #endif
 #endif
 	array[DEVCONF_PROXY_NDP] =3D cnf->proxy_ndp;
+#ifdef CONFIG_IPV6_OPTIMISTIC_DAD
+	array[DEVCONF_OPTIMISTIC_DAD] =3D cnf->optimistic_dad;
+#endif
 }
=20
 static inline size_t inet6_if_nlmsg_size(void)
@@ -3917,6 +3966,17 @@ static struct addrconf_sysctl_table
 			.mode		=3D	0644,
 			.proc_handler	=3D	&proc_dointvec,
 		},
+#ifdef CONFIG_IPV6_OPTIMISTIC_DAD
+		{
+			.ctl_name	=3D	NET_IPV6_OPTIMISTIC_DAD,
+			.procname       =3D       "optimistic_dad",
+			.data           =3D       &ipv6_devconf.optimistic_dad,
+			.maxlen         =3D       sizeof(int),
+			.mode           =3D       0644,
+			.proc_handler   =3D       &proc_dointvec,
+
+		},
+#endif
 		{
 			.ctl_name	=3D	0,	/* sentinel */
 		}
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 7b7bd44..df13fc8 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -861,6 +861,41 @@ static int ip6_dst_lookup_tail(struct sock *sk,
 			goto out_err_release;
 	}
=20
+#ifdef CONFIG_IPV6_OPTIMISTIC_DAD
+		/*
+		 * Here if the dst entry we've looked up=20
+		 * has a neighbour entry that is in the INCOMPLETE
+		 * state and the src address from the flow is=20
+		 * marked as OPTIMISTIC, we release the found=20
+		 * dst entry and replace it instead with the=20
+		 * dst entry of the nexthop router
+		 */
+		if (!((*dst)->neighbour->nud_state & NUD_VALID)) {
+			struct inet6_ifaddr *ifp;
+			struct flowi fl_gw;
+			int redirect;
+
+			ifp =3D ipv6_get_ifaddr(&fl->fl6_src, (*dst)->dev, 1);
+
+			redirect =3D (ifp && ifp->flags & IFA_F_OPTIMISTIC);
+			if (ifp)
+				in6_ifa_put(ifp);
+
+			if (redirect) {
+				/*
+				 * We need to get the dst entry for the=20
+				 * default router instead
+				 */
+				dst_release(*dst);
+				memcpy(&fl_gw, fl, sizeof(struct flowi));
+				memset(&fl_gw.fl6_dst, 0, sizeof(struct in6_addr));
+				*dst =3D ip6_route_output(sk, &fl_gw);
+				if ((err =3D (*dst)->error))
+					goto out_err_release;			=09
+			}
+		}
+#endif
+
 	return 0;
=20
 out_err_release:
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 882cde4..9c5273c 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1411,7 +1411,7 @@ static struct sk_buff *mld_newpack(struct net_dev=
ice *dev, int size)
=20
 	skb_reserve(skb, LL_RESERVED_SPACE(dev));
=20
-	if (ipv6_get_lladdr(dev, &addr_buf)) {
+	if (ipv6_get_lladdr(dev, &addr_buf, IFA_F_TENTATIVE)) {
 		/* <draft-ietf-magma-mld-source-05.txt>:
 		 * use unspecified address as the source address=20
 		 * when a valid link-local address is not available.
@@ -1789,7 +1789,7 @@ static void igmp6_send(struct in6_addr *addr, str=
uct net_device *dev, int type)
=20
 	skb_reserve(skb, LL_RESERVED_SPACE(dev));
=20
-	if (ipv6_get_lladdr(dev, &addr_buf)) {
+	if (ipv6_get_lladdr(dev, &addr_buf, IFA_F_TENTATIVE)) {
 		/* <draft-ietf-magma-mld-source-05.txt>:
 		 * use unspecified address as the source address=20
 		 * when a valid link-local address is not available.
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 39bb658..98913c4 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -447,6 +447,8 @@ static void ndisc_send_na(struct net_device *dev, s=
truct neighbour *neigh,
 	ifp =3D ipv6_get_ifaddr(solicited_addr, dev, 1);
  	if (ifp) {
 		src_addr =3D solicited_addr;
+		if (ifp->flags & IFA_F_OPTIMISTIC)
+			override =3D 0;
 		in6_ifa_put(ifp);
 	} else {
 		if (ipv6_dev_get_saddr(dev, daddr, &tmpaddr))
@@ -542,7 +544,8 @@ void ndisc_send_ns(struct net_device *dev, struct n=
eighbour *neigh,
 	int send_llinfo;
=20
 	if (saddr =3D=3D NULL) {
-		if (ipv6_get_lladdr(dev, &addr_buf))
+		if (ipv6_get_lladdr(dev, &addr_buf,=20
+				   (IFA_F_TENTATIVE|IFA_F_OPTIMISTIC)))
 			return;
 		saddr =3D &addr_buf;
 	}
@@ -622,9 +625,33 @@ void ndisc_send_rs(struct net_device *dev, struct =
in6_addr *saddr,
         struct sk_buff *skb;
         struct icmp6hdr *hdr;
 	__u8 * opt;
+	struct inet6_ifaddr *ifp;
+	int send_sllao =3D dev->addr_len;
         int len;
 	int err;
=20
+
+#ifdef CONFIG_IPV6_OPTIMISTIC_DAD
+	/*
+	 * According to section 2.2 of RFC 4429, we must not=20
+	 * send router solicitations with a sllao from=20
+	 * optimistic addresses, but we may send the solicitation
+	 * if we don't include the sllao.  So here we check
+	 * if our address is optimistic, and if so, we
+	 * supress the inclusion of the sllao.
+	 */=20
+	if (send_sllao) {
+		ifp =3D ipv6_get_ifaddr(saddr, dev, 1);
+		if (ifp) {
+			if (ifp->flags & IFA_F_OPTIMISTIC)  {
+				send_sllao=3D0;
+				in6_ifa_put(ifp);
+			}
+		} else {
+			send_sllao =3D 0;
+		}
+	}
+#endif
 	ndisc_flow_init(&fl, NDISC_ROUTER_SOLICITATION, saddr, daddr,
 			dev->ifindex);
=20
@@ -637,7 +664,7 @@ void ndisc_send_rs(struct net_device *dev, struct i=
n6_addr *saddr,
 		return;
=20
 	len =3D sizeof(struct icmp6hdr);
-	if (dev->addr_len)
+	if (send_sllao)
 		len +=3D ndisc_opt_addr_space(dev);
=20
         skb =3D sock_alloc_send_skb(sk,
@@ -664,7 +691,7 @@ void ndisc_send_rs(struct net_device *dev, struct i=
n6_addr *saddr,
=20
 	opt =3D (u8*) (hdr + 1);
=20
-	if (dev->addr_len)
+	if (send_sllao)
 		ndisc_fill_addr_option(opt, ND_OPT_SOURCE_LL_ADDR, dev->dev_addr,
 				       dev->addr_len, dev->type);
=20
@@ -796,28 +823,39 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 	inc =3D ipv6_addr_is_multicast(daddr);
=20
 	if ((ifp =3D ipv6_get_ifaddr(&msg->target, dev, 1)) !=3D NULL) {
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
+				if (dev->type =3D=3D ARPHRD_IEEE802_TR) {
+					unsigned char *sadr =3D skb->mac.raw;
+					if (((sadr[8] ^ dev->dev_addr[0]) & 0x7f) =3D=3D 0 &&
+					    sadr[9] =3D=3D dev->dev_addr[1] &&
+					    sadr[10] =3D=3D dev->dev_addr[2] &&
+					    sadr[11] =3D=3D dev->dev_addr[3] &&
+					    sadr[12] =3D=3D dev->dev_addr[4] &&
+					    sadr[13] =3D=3D dev->dev_addr[5]) {
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
-			if (dev->type =3D=3D ARPHRD_IEEE802_TR) {
-				unsigned char *sadr =3D skb->mac.raw;
-				if (((sadr[8] ^ dev->dev_addr[0]) & 0x7f) =3D=3D 0 &&
-				    sadr[9] =3D=3D dev->dev_addr[1] &&
-				    sadr[10] =3D=3D dev->dev_addr[2] &&
-				    sadr[11] =3D=3D dev->dev_addr[3] &&
-				    sadr[12] =3D=3D dev->dev_addr[4] &&
-				    sadr[13] =3D=3D dev->dev_addr[5]) {
-					/* looped-back to us */
+			} else {
+				/*
+				 * This is not a dad solicitation.
+				 * If we are an optimistic node,=20
+				 * we should respond. =20
+				 * Otherwise, we should ignore it.=20
+				 */
+				if (!(ifp->flags & IFA_F_OPTIMISTIC))
 					goto out;
-				}
 			}
-			addrconf_dad_failure(ifp);=20
-			return;
 		}
=20
 		idev =3D ifp->idev;
@@ -1406,7 +1444,7 @@ void ndisc_send_redirect(struct sk_buff *skb, str=
uct neighbour *neigh,
=20
 	dev =3D skb->dev;
=20
-	if (ipv6_get_lladdr(dev, &saddr_buf)) {
+	if (ipv6_get_lladdr(dev, &saddr_buf, IFA_F_TENTATIVE)) {
 		ND_PRINTK2(KERN_WARNING
 			   "ICMPv6 Redirect: no link-local address on %s\n",
 			   dev->name);
