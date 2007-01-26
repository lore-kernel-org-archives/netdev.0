From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] IPv6: Implement RFC 4429 Optimistic Duplicate Address Detection
Date: Fri, 26 Jan 2007 14:18:17 -0500
Message-ID: <20070126191817.GC15916@hmsreliant.homelinux.net>
References: <20070125133340.GA8891@hmsreliant.homelinux.net> <45B8E60B.7080809@hp.com> <20070125194500.GB8891@hmsreliant.homelinux.net> <20070126.091331.22638713.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: vladislav.yasevich@hp.com, sri@us.ibm.com, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	kaber@coreworks.de, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2542 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161210AbXAZT0B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jan 2007 14:26:01 -0500
Content-Disposition: inline
In-Reply-To: <20070126.091331.22638713.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 26, 2007 at 09:13:31AM +0900, YOSHIFUJI Hideaki / =E5=90=89=
=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> In article <20070125194500.GB8891@hmsreliant.homelinux.net> (at Thu, =
25 Jan 2007 14:45:00 -0500), Neil Horman <nhorman@tuxdriver.com> says:


New patch attached with most of your suggestions incorporated.  I've a =
few
comments mixed in for some of the suggestions that I think need further
discussion

> If optimistic_dad is disabled, flags should be IFA_F_TEMPORARY,
> not IFA_F_TEMPORARY|IFA_F_OPTIMISTIC.
>=20
> Another idea is to use IFA_F_OPTIMISTIC not
> IFA_F_OPTIMISTIC|IFA_F_TENTATIVE until the DAD has been finished.
>=20

I'm currently setting the OPTIMISTIC flag in every location that its po=
ssibly
needed, and then clearing it in addrconf_dad_start if that interface is=
 not
participating in optimistic dad.  I do this because the RFC in section =
3.1
indicates that manually configured addresses should not set the optimis=
tic flag.
If I removed the OPTIMISTIC flag from the locations it gets set in the =
patch and
then only set it for participating interfaces in addrconf_dad_start, I =
would
need to have some way to tell if the address in question was manually c=
onfigured
(to avoid setting it in that case).  At present I see no clear way to d=
o that,
but if you have a suggestion, I'll happily change this around.

<snip>
>=20
>                                     ((ifa_result->flags & (IFA_F_DEPR=
ECATED|IFA_F_OPTIMISTIC)) =3D=3D 0)
<snip>
> ditto.
>=20
Done

> > @@ -2123,7 +2133,8 @@ static void addrconf_add_linklocal(struct ine=
t6_dev *idev, struct in6_addr *addr
> >  {
> >  	struct inet6_ifaddr * ifp;
> > =20
> > -	ifp =3D ipv6_add_addr(idev, addr, 64, IFA_LINK, IFA_F_PERMANENT);
> > +	ifp =3D ipv6_add_addr(idev, addr, 64, IFA_LINK,=20
> > +		            IFA_F_PERMANENT|IFA_F_OPTIMISTIC);
> >  	if (!IS_ERR(ifp)) {
> >  		addrconf_dad_start(ifp, 0);
> >  		in6_ifa_put(ifp);
>=20
> Please do not always put IFA_F_OPTIMISTIC.
>=20
Again, same reasoning as above for why I set optimistic in this way.

> > =20
> > +	/*
> > +	 * Optimistic nodes need to joing the anycast address
> > +	 * right away
> > +	 */
> > +	if (ifp->flags & IFA_F_OPTIMISTIC)
> > +		addrconf_join_anycast(ifp);
> > +
> >  	if (ifp->prefix_len !=3D 128 && (ifp->flags&IFA_F_PERMANENT))
> >  		addrconf_prefix_route(&ifp->addr, ifp->prefix_len, dev, 0,
> >  					flags);
>=20
> Should we join anycast even if the node is a host (not a router)?!
>=20
I've moved this to the spot below where we check if we are forwarding, =
so the
new patch attached does not join anycast if we are a router.

> When you add a call to "addrconf_join_anycast()",=20
> you must consider when to leave this.
>=20
I think addrconf_dad_completed is appropriate for this.  New patch leav=
es
anycast group when we are no longer optimistic

>=20
> > @@ -2573,6 +2594,18 @@ static void addrconf_dad_start(struct inet6_=
ifaddr *ifp, u32 flags)
> >  		addrconf_dad_stop(ifp);
> >  		return;
> >  	}
> > +
> > +	/*
> > +	 * Forwarding devices (routers) should not use
> > +	 * optimistic addresses
> > +	 * Nor should interfaces that don't know the=20
> > +	 * Source address for their default gateway
> > +	 * RFC 4429 Sec 3.3
> > +	 */
> > +	if ((ipv6_devconf.forwarding) ||
> > +	   (ifp->rt =3D=3D NULL))
> > +		ifp->flags &=3D ~IFA_F_OPTIMISTIC;
> > +
> >  	addrconf_dad_kick(ifp);
> >  	spin_unlock_bh(&ifp->lock);
> >  out:
>=20
> Please test this condition when you are adding the
> address.
>=20
Are you sure?  There are several locations where we add an address that=
 we start
dad on.  Shall I test this in all of those places?  It would seem more
appropriate to do it in addrconf_dad_start, as I do.  Or am I missing s=
omething?


> BTW, you have not implemented the later condition,
> right?   Sefault gatewa is not tested.
>=20
I thought I was testing it.  I was under the impression from my reading=
 of the
code the ifp->rt held the rt6_info pointer for the default gateway, so =
if its
not set, we don't know the default gateway.  I may well be missing some=
thing
here though.  Please let me know.

> > index 6a9f616..fcd22e3 100644
> > --- a/net/ipv6/ndisc.c
> > +++ b/net/ipv6/ndisc.c
> > @@ -498,7 +498,21 @@ static void ndisc_send_na(struct net_device *d=
ev, struct neighbour *neigh,
> >          msg->icmph.icmp6_unused =3D 0;
> >          msg->icmph.icmp6_router    =3D router;
> >          msg->icmph.icmp6_solicited =3D solicited;
> > -        msg->icmph.icmp6_override  =3D override;
> > +	if (!ifp || !(ifp->flags & IFA_F_OPTIMISTIC))
> > +		msg->icmph.icmp6_override  =3D override;
> > +	else {
> > +		/*
> > +		 * We must clear the override flag on all
> > +		 * neighbor advertisements from source=20
> > +		 * addresses that are OPTIMISTIC - RFC 4429
> > +		 * section 2.2
> > +		 */
> > +		if (override)
> > +			printk(KERN_WARNING
> > +				"Disallowing override flag for OPTIMISTIC addr\n");
> > +		msg->icmph.icmp6_override =3D 0;
> > +	}
> > +
>=20
> Ifp is already put.  Please clear "override" in the code
> where we try getting temporary source address for NS.
>=20
Done.  I've moved the check to before the in6_ifa_put, and added a flag=
 to skip
adding the sllao option if we find we are optimistic.

> > @@ -622,9 +637,20 @@ void ndisc_send_rs(struct net_device *dev, str=
uct in6_addr *saddr,
> > +	/*
> > +	 * Check the source address.  If its OPTIMISTIC
> > +	 * and addr_len is non-zero (implying the sllao option)
> > +	 * then don't send the RS (RFC 4429, section 2.2)
> > +	 */
> > +	ifp =3D ipv6_get_ifaddr(saddr, dev, 1);
> > +
> > +	if ((!ifp) || ((ifp->flags & IFA_F_OPTIMISTIC) && dev->addr_len))
> > +		return;
> > +
> >  	ndisc_flow_init(&fl, NDISC_ROUTER_SOLICITATION, saddr, daddr,
> >  			dev->ifindex);
> > =20
>=20
> I disagree. Please send RS in other way.
> Choose another address, or send it without SLLAO.
>=20
Done



More thoughts/comments appreciated.

Thanks & Regards
Neil


Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 include/linux/if_addr.h |    1=20
 include/linux/ipv6.h    |    2 +
 include/linux/sysctl.h  |    1=20
 include/net/addrconf.h  |    4 +-
 net/ipv6/addrconf.c     |   78 +++++++++++++++++++++++++++++++++++++++=
---------
 net/ipv6/mcast.c        |    4 +-
 net/ipv6/ndisc.c        |   74 +++++++++++++++++++++++++++++++--------=
------
 7 files changed, 124 insertions(+), 40 deletions(-)



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
=20
@@ -205,6 +206,7 @@ enum {
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
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 2a7e461..fc29815 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -830,7 +830,8 @@ retry:
 	ift =3D !max_addresses ||
 	      ipv6_count_addresses(idev) < max_addresses ?=20
 		ipv6_add_addr(idev, &addr, tmp_plen,
-			      ipv6_addr_type(&addr)&IPV6_ADDR_SCOPE_MASK, IFA_F_TEMPORARY) =
: NULL;
+			      ipv6_addr_type(&addr)&IPV6_ADDR_SCOPE_MASK,=20
+			      IFA_F_TEMPORARY|IFA_F_OPTIMISTIC) : NULL;
 	if (!ift || IS_ERR(ift)) {
 		in6_ifa_put(ifp);
 		in6_dev_put(idev);
@@ -962,13 +963,14 @@ int ipv6_dev_get_saddr(struct net_device *daddr_d=
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
@@ -1027,15 +1029,17 @@ int ipv6_dev_get_saddr(struct net_device *daddr=
_dev,
 				}
 			}
=20
-			/* Rule 3: Avoid deprecated address */
+			/* Rule 3: Avoid deprecated and optimistic address */
 			if (hiscore.rule < 3) {
 				if (ipv6_saddr_preferred(hiscore.addr_type) ||
-				    !(ifa_result->flags & IFA_F_DEPRECATED))
+				   ((ifa_result->flags &
+				    (IFA_F_DEPRECATED|IFA_F_OPTIMISTIC) =3D=3D 0)))
 					hiscore.attrs |=3D IPV6_SADDR_SCORE_PREFERRED;
 				hiscore.rule++;
 			}
 			if (ipv6_saddr_preferred(score.addr_type) ||
-			    !(ifa->flags & IFA_F_DEPRECATED)) {
+			   ((ifa_result->flags &
+			    (IFA_F_DEPRECATED|IFA_F_OPTIMISTIC) =3D=3D 0))) {
 				score.attrs |=3D IPV6_SADDR_SCORE_PREFERRED;
 				if (!(hiscore.attrs & IPV6_SADDR_SCORE_PREFERRED)) {
 					score.rule =3D 3;
@@ -1174,7 +1178,8 @@ int ipv6_get_saddr(struct dst_entry *dst,
 }
=20
=20
-int ipv6_get_lladdr(struct net_device *dev, struct in6_addr *addr)
+int ipv6_get_lladdr(struct net_device *dev, struct in6_addr *addr,=20
+		    unsigned char banned_flags)
 {
 	struct inet6_dev *idev;
 	int err =3D -EADDRNOTAVAIL;
@@ -1185,7 +1190,7 @@ int ipv6_get_lladdr(struct net_device *dev, struc=
t in6_addr *addr)
=20
 		read_lock_bh(&idev->lock);
 		for (ifp=3Didev->addr_list; ifp; ifp=3Difp->if_next) {
-			if (ifp->scope =3D=3D IFA_LINK && !(ifp->flags&IFA_F_TENTATIVE)) {
+			if (ifp->scope =3D=3D IFA_LINK && !(ifp->flags & banned_flags)) {
 				ipv6_addr_copy(addr, &ifp->addr);
 				err =3D 0;
 				break;
@@ -1751,6 +1756,7 @@ ok:
=20
 			update_lft =3D create =3D 1;
 			ifp->cstamp =3D jiffies;
+			ifp->flags |=3D IFA_F_OPTIMISTIC;
 			addrconf_dad_start(ifp, RTF_ADDRCONF|RTF_PREFIX_RT);
 		}
=20
@@ -1945,7 +1951,11 @@ static int inet6_addr_add(int ifindex, struct in=
6_addr *pfx, int plen,
 		ifp->prefered_lft =3D prefered_lft;
 		ifp->tstamp =3D jiffies;
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
@@ -2123,7 +2133,8 @@ static void addrconf_add_linklocal(struct inet6_d=
ev *idev, struct in6_addr *addr
 {
 	struct inet6_ifaddr * ifp;
=20
-	ifp =3D ipv6_add_addr(idev, addr, 64, IFA_LINK, IFA_F_PERMANENT);
+	ifp =3D ipv6_add_addr(idev, addr, 64, IFA_LINK,=20
+		            IFA_F_PERMANENT|IFA_F_OPTIMISTIC);
 	if (!IS_ERR(ifp)) {
 		addrconf_dad_start(ifp, 0);
 		in6_ifa_put(ifp);
@@ -2190,7 +2201,7 @@ ipv6_inherit_linklocal(struct inet6_dev *idev, st=
ruct net_device *link_dev)
 {
 	struct in6_addr lladdr;
=20
-	if (!ipv6_get_lladdr(link_dev, &lladdr)) {
+	if (!ipv6_get_lladdr(link_dev, &lladdr, IFA_F_TENTATIVE)) {
 		addrconf_add_linklocal(idev, &lladdr);
 		return 0;
 	}
@@ -2527,7 +2538,11 @@ static void addrconf_dad_kick(struct inet6_ifadd=
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
@@ -2537,6 +2552,9 @@ static void addrconf_dad_start(struct inet6_ifadd=
r *ifp, u32 flags)
 	struct inet6_dev *idev =3D ifp->idev;
 	struct net_device *dev =3D idev->dev;
=20
+	if (!idev->cnf.optimistic_dad)
+		ifp->flags &=3D ~IFA_F_OPTIMISTIC;
+
 	addrconf_join_solict(dev, &ifp->addr);
=20
 	if (ifp->prefix_len !=3D 128 && (ifp->flags&IFA_F_PERMANENT))
@@ -2553,7 +2571,7 @@ static void addrconf_dad_start(struct inet6_ifadd=
r *ifp, u32 flags)
 	if (dev->flags&(IFF_NOARP|IFF_LOOPBACK) ||
 	    !(ifp->flags&IFA_F_TENTATIVE) ||
 	    ifp->flags & IFA_F_NODAD) {
-		ifp->flags &=3D ~IFA_F_TENTATIVE;
+		ifp->flags &=3D ~(IFA_F_TENTATIVE|IFA_F_OPTIMISTIC);
 		spin_unlock_bh(&ifp->lock);
 		read_unlock_bh(&idev->lock);
=20
@@ -2573,6 +2591,25 @@ static void addrconf_dad_start(struct inet6_ifad=
dr *ifp, u32 flags)
 		addrconf_dad_stop(ifp);
 		return;
 	}
+
+	/*
+	 * Forwarding devices (routers) should not use
+	 * optimistic addresses
+	 * Nor should interfaces that don't know the=20
+	 * Source address for their default gateway
+	 * RFC 4429 Sec 3.3
+	 */
+	if ((ipv6_devconf.forwarding) ||
+	   (ifp->rt =3D=3D NULL))
+		ifp->flags &=3D ~IFA_F_OPTIMISTIC;
+
+	/*
+	 * Optimistic nodes need to join the anycast address
+	 * right away
+	 */
+	if (ifp->flags & IFA_F_OPTIMISTIC)
+		addrconf_join_anycast(ifp);
+
 	addrconf_dad_kick(ifp);
 	spin_unlock_bh(&ifp->lock);
 out:
@@ -2597,7 +2634,7 @@ static void addrconf_dad_timer(unsigned long data=
)
 		 * DAD was successful
 		 */
=20
-		ifp->flags &=3D ~IFA_F_TENTATIVE;
+		ifp->flags &=3D ~(IFA_F_TENTATIVE|IFA_F_OPTIMISTIC);
 		spin_unlock_bh(&ifp->lock);
 		read_unlock_bh(&idev->lock);
=20
@@ -2627,6 +2664,9 @@ static void addrconf_dad_completed(struct inet6_i=
faddr *ifp)
 	 *	Configure the address for reception. Now it is valid.
 	 */
=20
+	if (ifp->flags & IFA_F_OPTIMISTIC)
+		addrconf_leave_anycast(ifp);
+
 	ipv6_ifa_notify(RTM_NEWADDR, ifp);
=20
 	/* If added prefix is link local and forwarding is off,
@@ -3398,6 +3438,7 @@ static void inline ipv6_store_devconf(struct ipv6=
_devconf *cnf,
 #endif
 #endif
 	array[DEVCONF_PROXY_NDP] =3D cnf->proxy_ndp;
+	array[DEVCONF_OPTIMISTIC_DAD] =3D cnf->optimistic_dad;
 }
=20
 static inline size_t inet6_if_nlmsg_size(void)
@@ -3918,6 +3959,15 @@ static struct addrconf_sysctl_table
 			.proc_handler	=3D	&proc_dointvec,
 		},
 		{
+			.ctl_name	=3D	NET_IPV6_OPTIMISTIC_DAD,
+			.procname       =3D       "optimistic_dad",
+			.data           =3D       &ipv6_devconf.optimistic_dad,
+			.maxlen         =3D       sizeof(int),
+			.mode           =3D       0644,
+			.proc_handler   =3D       &proc_dointvec,
+
+		},
+		{
 			.ctl_name	=3D	0,	/* sentinel */
 		}
 	},
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
index 6a9f616..6ed0357 100644
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
@@ -498,7 +500,8 @@ static void ndisc_send_na(struct net_device *dev, s=
truct neighbour *neigh,
         msg->icmph.icmp6_unused =3D 0;
         msg->icmph.icmp6_router    =3D router;
         msg->icmph.icmp6_solicited =3D solicited;
-        msg->icmph.icmp6_override  =3D override;
+	msg->icmph.icmp6_override  =3D override;
+
=20
         /* Set the target address. */
 	ipv6_addr_copy(&msg->target, solicited_addr);
@@ -542,7 +545,8 @@ void ndisc_send_ns(struct net_device *dev, struct n=
eighbour *neigh,
 	int send_llinfo;
=20
 	if (saddr =3D=3D NULL) {
-		if (ipv6_get_lladdr(dev, &addr_buf))
+		if (ipv6_get_lladdr(dev, &addr_buf,
+			            (IFA_F_TENTATIVE|IFA_F_OPTIMISTIC)))
 			return;
 		saddr =3D &addr_buf;
 	}
@@ -622,9 +626,21 @@ void ndisc_send_rs(struct net_device *dev, struct =
in6_addr *saddr,
         struct sk_buff *skb;
         struct icmp6hdr *hdr;
 	__u8 * opt;
+	struct inet6_ifaddr *ifp;
+	int include_sllao_option =3D 1;
         int len;
 	int err;
=20
+	/*
+	 * Check the source address.  If its OPTIMISTIC
+	 * and addr_len is non-zero (implying the sllao option)
+	 * then don't send the RS (RFC 4429, section 2.2)
+	 */
+	ifp =3D ipv6_get_ifaddr(saddr, dev, 1);
+
+	if ((!ifp) || ((ifp->flags & IFA_F_OPTIMISTIC) && dev->addr_len))
+		include_sllao_option=3D0;
+
 	ndisc_flow_init(&fl, NDISC_ROUTER_SOLICITATION, saddr, daddr,
 			dev->ifindex);
=20
@@ -664,7 +680,7 @@ void ndisc_send_rs(struct net_device *dev, struct i=
n6_addr *saddr,
=20
 	opt =3D (u8*) (hdr + 1);
=20
-	if (dev->addr_len)
+	if (dev->addr_len && include_sllao_option)
 		ndisc_fill_addr_option(opt, ND_OPT_SOURCE_LL_ADDR, dev->dev_addr,
 				       dev->addr_len, dev->type);
=20
@@ -746,6 +762,7 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 	int dad =3D ipv6_addr_any(saddr);
 	int inc;
 	int is_router;
+	int type;
=20
 	if (ipv6_addr_is_multicast(&msg->target)) {
 		ND_PRINTK2(KERN_WARNING=20
@@ -796,28 +813,39 @@ static void ndisc_recv_ns(struct sk_buff *skb)
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
@@ -1406,7 +1434,7 @@ void ndisc_send_redirect(struct sk_buff *skb, str=
uct neighbour *neigh,
=20
 	dev =3D skb->dev;
=20
-	if (ipv6_get_lladdr(dev, &saddr_buf)) {
+	if (ipv6_get_lladdr(dev, &saddr_buf, IFA_F_TENTATIVE)) {
 		ND_PRINTK2(KERN_WARNING
 			   "ICMPv6 Redirect: no link-local address on %s\n",
 			   dev->name);
