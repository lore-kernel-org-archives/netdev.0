From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] IPv6: Implement RFC 4429 Optimistic Duplicate Address Detection
Date: Thu, 25 Jan 2007 08:33:40 -0500
Message-ID: <20070125133340.GA8891@hmsreliant.homelinux.net>
References: <20070119212314.GA10748@hmsreliant.homelinux.net> <20070120.080507.25118874.yoshfuji@linux-ipv6.org> <20070122181528.GD21059@hmsreliant.homelinux.net> <20070123.091820.104515696.yoshfuji@linux-ipv6.org> <20070123205118.GC582@hmsreliant.homelinux.net> <1169690087.23312.7.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	kaber@coreworks.de, netdev@vger.kernel.org
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3270 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965354AbXAYNqA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jan 2007 08:46:00 -0500
Content-Disposition: inline
In-Reply-To: <1169690087.23312.7.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 24, 2007 at 05:54:47PM -0800, Sridhar Samudrala wrote:
> Sec 2.1 of RFC 4429 says
>=20
>    Unless noted otherwise, components of the IPv6 protocol stack shou=
ld
>    treat addresses in the Optimistic state equivalently to those in t=
he
>    Deprecated state, indicating that the address is available for use
>    but should not be used if another suitable address is available.  =
=46or
>    example, Default Address Selection [RFC3484] uses the address stat=
e
>    to decide which source address to use for an outgoing packet.
>    Implementations should treat an address in state Optimistic as if =
it
>    were in state Deprecated.  If address states are recorded as
>    individual flags, this can easily be achieved by also setting
>    'Deprecated' when 'Optimistic' is set.
>=20
> So i think DEPRECATED flag also should be set when we mark an address
> as OPTIMISTIC so that we don't use it as source address for new=20
> connections if another address is available until DAD is completed.
>=20
> Thanks
> Sridhar
>=20

Oh, good catch.  Thank you Sri.  However, I'm worried about the next pa=
ragraph:

It is important to note that the address lifetime rules of [RFC2462]
   still apply, and so an address may be Deprecated as well as
   Optimistic.  When DAD completes without incident, the address become=
s
   either a Preferred or a Deprecated address, as per RFC 2462

Given that, it seems to me that addresses which are flagged as Deprecat=
ed may
enter and exit that state independently of the DAD process, which I thi=
nk gives
rise to the possibility of a race.  I.e. if an address becomes deprecat=
ed right
before DAD completes, and then addrconf_dad_complete clears the IFA_F_D=
EPRECATED
flag, that seems wrong.  Instead I think it would be better if we teste=
d for the
OPTIMISTIC flag in ipv6_dev_get_saddr in parallel with the DEPRECATED f=
lag.  I
may be wrong about this, but I'm going to err on the side of safety.  I=
f you can
ensure that this race is not possible.  Please let me know, and I'll ha=
ppily
just set the flag.  I'll repost a new patch soon.

Thanks & Regards
Neil

>=20
> On Tue, 2007-01-23 at 15:51 -0500, Neil Horman wrote:
> > On Tue, Jan 23, 2007 at 09:18:20AM +0900, YOSHIFUJI Hideaki / =E5=90=
=89=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> > > Hello.
> > <snip>
> >=20
> > New patch attached, incorporating Yoshijui and Vlads latest comment=
s.  I didn't
> > follow guidance on the ndisc_recv_ns comment, Yoshifuji, since Vlad=
 had already
> > suggested an alternate solution in a previous post, but from lookin=
g at them
> > both, they should be equivalent.
> >=20
> > Thanks & Regards
> > Neil
> >=20
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> >=20
> >=20
> >  include/linux/if_addr.h |    1
> >  include/linux/ipv6.h    |    2 +
> >  include/linux/sysctl.h  |    1
> >  include/net/addrconf.h  |    4 +-
> >  net/ipv6/addrconf.c     |   56 ++++++++++++++++++++++++++++----
> >  net/ipv6/mcast.c        |    4 +-
> >  net/ipv6/ndisc.c        |   82 +++++++++++++++++++++++++++++++++++=
-------------
> >  7 files changed, 117 insertions(+), 33 deletions(-)
> >=20
> >=20
> > diff --git a/include/linux/if_addr.h b/include/linux/if_addr.h
> > index d557e4c..43f3bed 100644
> > --- a/include/linux/if_addr.h
> > +++ b/include/linux/if_addr.h
> > @@ -39,6 +39,7 @@ enum
> >  #define IFA_F_TEMPORARY		IFA_F_SECONDARY
> >=20
> >  #define	IFA_F_NODAD		0x02
> > +#define IFA_F_OPTIMISTIC	0x04
> >  #define	IFA_F_HOMEADDRESS	0x10
> >  #define IFA_F_DEPRECATED	0x20
> >  #define IFA_F_TENTATIVE		0x40
> > diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
> > index f824113..5d37abf 100644
> > --- a/include/linux/ipv6.h
> > +++ b/include/linux/ipv6.h
> > @@ -177,6 +177,7 @@ struct ipv6_devconf {
> >  #endif
> >  #endif
> >  	__s32		proxy_ndp;
> > +	__s32		optimistic_dad;
> >  	void		*sysctl;
> >  };
> >=20
> > @@ -205,6 +206,7 @@ enum {
> >  	DEVCONF_RTR_PROBE_INTERVAL,
> >  	DEVCONF_ACCEPT_RA_RT_INFO_MAX_PLEN,
> >  	DEVCONF_PROXY_NDP,
> > +	DEVCONF_OPTIMISTIC_DAD,
> >  	DEVCONF_MAX
> >  };
> >=20
> > diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
> > index 81480e6..972a33a 100644
> > --- a/include/linux/sysctl.h
> > +++ b/include/linux/sysctl.h
> > @@ -570,6 +570,7 @@ enum {
> >  	NET_IPV6_RTR_PROBE_INTERVAL=3D21,
> >  	NET_IPV6_ACCEPT_RA_RT_INFO_MAX_PLEN=3D22,
> >  	NET_IPV6_PROXY_NDP=3D23,
> > +	NET_IPV6_OPTIMISTIC_DAD=3D24,
> >  	__NET_IPV6_MAX
> >  };
> >=20
> > diff --git a/include/net/addrconf.h b/include/net/addrconf.h
> > index 88df8fc..d248a19 100644
> > --- a/include/net/addrconf.h
> > +++ b/include/net/addrconf.h
> > @@ -73,7 +73,9 @@ extern int			ipv6_get_saddr(struct dst_entry *dst=
,
> >  extern int			ipv6_dev_get_saddr(struct net_device *dev,
> >  					       struct in6_addr *daddr,
> >  					       struct in6_addr *saddr);
> > -extern int			ipv6_get_lladdr(struct net_device *dev, struct in6_ad=
dr *);
> > +extern int			ipv6_get_lladdr(struct net_device *dev,
> > +						struct in6_addr *,
> > +						unsigned char banned_flags);
> >  extern int			ipv6_rcv_saddr_equal(const struct sock *sk,
> >  						      const struct sock *sk2);
> >  extern void			addrconf_join_solict(struct net_device *dev,
> > diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> > index 2a7e461..d2b01ec 100644
> > --- a/net/ipv6/addrconf.c
> > +++ b/net/ipv6/addrconf.c
> > @@ -830,7 +830,8 @@ retry:
> >  	ift =3D !max_addresses ||
> >  	      ipv6_count_addresses(idev) < max_addresses ?
> >  		ipv6_add_addr(idev, &addr, tmp_plen,
> > -			      ipv6_addr_type(&addr)&IPV6_ADDR_SCOPE_MASK, IFA_F_TEMPORA=
RY) : NULL;
> > +			      ipv6_addr_type(&addr)&IPV6_ADDR_SCOPE_MASK,
> > +			      IFA_F_TEMPORARY|IFA_F_OPTIMISTIC) : NULL;
> >  	if (!ift || IS_ERR(ift)) {
> >  		in6_ifa_put(ifp);
> >  		in6_dev_put(idev);
> > @@ -1174,7 +1175,8 @@ int ipv6_get_saddr(struct dst_entry *dst,
> >  }
> >=20
> >=20
> > -int ipv6_get_lladdr(struct net_device *dev, struct in6_addr *addr)
> > +int ipv6_get_lladdr(struct net_device *dev, struct in6_addr *addr,
> > +		    unsigned char banned_flags)
> >  {
> >  	struct inet6_dev *idev;
> >  	int err =3D -EADDRNOTAVAIL;
> > @@ -1185,7 +1187,7 @@ int ipv6_get_lladdr(struct net_device *dev, s=
truct in6_addr *addr)
> >=20
> >  		read_lock_bh(&idev->lock);
> >  		for (ifp=3Didev->addr_list; ifp; ifp=3Difp->if_next) {
> > -			if (ifp->scope =3D=3D IFA_LINK && !(ifp->flags&IFA_F_TENTATIVE)=
) {
> > +			if (ifp->scope =3D=3D IFA_LINK && !(ifp->flags & banned_flags))=
 {
> >  				ipv6_addr_copy(addr, &ifp->addr);
> >  				err =3D 0;
> >  				break;
> > @@ -1751,6 +1753,7 @@ ok:
> >=20
> >  			update_lft =3D create =3D 1;
> >  			ifp->cstamp =3D jiffies;
> > +			ifp->flags |=3D IFA_F_OPTIMISTIC;
> >  			addrconf_dad_start(ifp, RTF_ADDRCONF|RTF_PREFIX_RT);
> >  		}
> >=20
> > @@ -1945,7 +1948,11 @@ static int inet6_addr_add(int ifindex, struc=
t in6_addr *pfx, int plen,
> >  		ifp->prefered_lft =3D prefered_lft;
> >  		ifp->tstamp =3D jiffies;
> >  		spin_unlock_bh(&ifp->lock);
> > -
> > +		/*
> > +		 * Note that section 3.1 of RFC 4429 indicates
> > +		 * That the Optimistic flag should not be set for
> > +		 * manually configured addresses
> > +		 */
> >  		addrconf_dad_start(ifp, 0);
> >  		in6_ifa_put(ifp);
> >  		addrconf_verify(0);
> > @@ -2123,7 +2130,8 @@ static void addrconf_add_linklocal(struct ine=
t6_dev *idev, struct in6_addr *addr
> >  {
> >  	struct inet6_ifaddr * ifp;
> >=20
> > -	ifp =3D ipv6_add_addr(idev, addr, 64, IFA_LINK, IFA_F_PERMANENT);
> > +	ifp =3D ipv6_add_addr(idev, addr, 64, IFA_LINK,
> > +		            IFA_F_PERMANENT|IFA_F_OPTIMISTIC);
> >  	if (!IS_ERR(ifp)) {
> >  		addrconf_dad_start(ifp, 0);
> >  		in6_ifa_put(ifp);
> > @@ -2190,7 +2198,7 @@ ipv6_inherit_linklocal(struct inet6_dev *idev=
, struct net_device *link_dev)
> >  {
> >  	struct in6_addr lladdr;
> >=20
> > -	if (!ipv6_get_lladdr(link_dev, &lladdr)) {
> > +	if (!ipv6_get_lladdr(link_dev, &lladdr, IFA_F_TENTATIVE)) {
> >  		addrconf_add_linklocal(idev, &lladdr);
> >  		return 0;
> >  	}
> > @@ -2537,8 +2545,18 @@ static void addrconf_dad_start(struct inet6_=
ifaddr *ifp, u32 flags)
> >  	struct inet6_dev *idev =3D ifp->idev;
> >  	struct net_device *dev =3D idev->dev;
> >=20
> > +	if (!idev->cnf.optimistic_dad)
> > +		ifp->flags &=3D ~IFA_F_OPTIMISTIC;
> > +
> >  	addrconf_join_solict(dev, &ifp->addr);
> >=20
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
> > @@ -2553,7 +2571,7 @@ static void addrconf_dad_start(struct inet6_i=
faddr *ifp, u32 flags)
> >  	if (dev->flags&(IFF_NOARP|IFF_LOOPBACK) ||
> >  	    !(ifp->flags&IFA_F_TENTATIVE) ||
> >  	    ifp->flags & IFA_F_NODAD) {
> > -		ifp->flags &=3D ~IFA_F_TENTATIVE;
> > +		ifp->flags &=3D ~(IFA_F_TENTATIVE|IFA_F_OPTIMISTIC);
> >  		spin_unlock_bh(&ifp->lock);
> >  		read_unlock_bh(&idev->lock);
> >=20
> > @@ -2573,6 +2591,18 @@ static void addrconf_dad_start(struct inet6_=
ifaddr *ifp, u32 flags)
> >  		addrconf_dad_stop(ifp);
> >  		return;
> >  	}
> > +
> > +	/*
> > +	 * Forwarding devices (routers) should not use
> > +	 * optimistic addresses
> > +	 * Nor should interfaces that don't know the
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
> > @@ -2597,7 +2627,7 @@ static void addrconf_dad_timer(unsigned long =
data)
> >  		 * DAD was successful
> >  		 */
> >=20
> > -		ifp->flags &=3D ~IFA_F_TENTATIVE;
> > +		ifp->flags &=3D ~(IFA_F_TENTATIVE|IFA_F_OPTIMISTIC);
> >  		spin_unlock_bh(&ifp->lock);
> >  		read_unlock_bh(&idev->lock);
> >=20
> > @@ -3398,6 +3428,7 @@ static void inline ipv6_store_devconf(struct =
ipv6_devconf *cnf,
> >  #endif
> >  #endif
> >  	array[DEVCONF_PROXY_NDP] =3D cnf->proxy_ndp;
> > +	array[DEVCONF_OPTIMISTIC_DAD] =3D cnf->optimistic_dad;
> >  }
> >=20
> >  static inline size_t inet6_if_nlmsg_size(void)
> > @@ -3918,6 +3949,15 @@ static struct addrconf_sysctl_table
> >  			.proc_handler	=3D	&proc_dointvec,
> >  		},
> >  		{
> > +			.ctl_name	=3D	NET_IPV6_OPTIMISTIC_DAD,
> > +			.procname       =3D       "optimistic_dad",
> > +			.data           =3D       &ipv6_devconf.optimistic_dad,
> > +			.maxlen         =3D       sizeof(int),
> > +			.mode           =3D       0644,
> > +			.proc_handler   =3D       &proc_dointvec,
> > +
> > +		},
> > +		{
> >  			.ctl_name	=3D	0,	/* sentinel */
> >  		}
> >  	},
> > diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
> > index 882cde4..9c5273c 100644
> > --- a/net/ipv6/mcast.c
> > +++ b/net/ipv6/mcast.c
> > @@ -1411,7 +1411,7 @@ static struct sk_buff *mld_newpack(struct net=
_device *dev, int size)
> >=20
> >  	skb_reserve(skb, LL_RESERVED_SPACE(dev));
> >=20
> > -	if (ipv6_get_lladdr(dev, &addr_buf)) {
> > +	if (ipv6_get_lladdr(dev, &addr_buf, IFA_F_TENTATIVE)) {
> >  		/* <draft-ietf-magma-mld-source-05.txt>:
> >  		 * use unspecified address as the source address
> >  		 * when a valid link-local address is not available.
> > @@ -1789,7 +1789,7 @@ static void igmp6_send(struct in6_addr *addr,=
 struct net_device *dev, int type)
> >=20
> >  	skb_reserve(skb, LL_RESERVED_SPACE(dev));
> >=20
> > -	if (ipv6_get_lladdr(dev, &addr_buf)) {
> > +	if (ipv6_get_lladdr(dev, &addr_buf, IFA_F_TENTATIVE)) {
> >  		/* <draft-ietf-magma-mld-source-05.txt>:
> >  		 * use unspecified address as the source address
> >  		 * when a valid link-local address is not available.
> > diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
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
> > +		 * neighbor advertisements from source
> > +		 * addresses that are OPTIMISTIC - RFC 4429
> > +		 * section 2.2
> > +		 */
> > +		if (override)
> > +			printk(KERN_WARNING
> > +				"Disallowing override flag for OPTIMISTIC addr\n");
> > +		msg->icmph.icmp6_override =3D 0;
> > +	}
> > +
> >=20
> >          /* Set the target address. */
> >  	ipv6_addr_copy(&msg->target, solicited_addr);
> > @@ -542,7 +556,8 @@ void ndisc_send_ns(struct net_device *dev, stru=
ct neighbour *neigh,
> >  	int send_llinfo;
> >=20
> >  	if (saddr =3D=3D NULL) {
> > -		if (ipv6_get_lladdr(dev, &addr_buf))
> > +		if (ipv6_get_lladdr(dev, &addr_buf,
> > +			            (IFA_F_TENTATIVE|IFA_F_OPTIMISTIC)))
> >  			return;
> >  		saddr =3D &addr_buf;
> >  	}
> > @@ -622,9 +637,20 @@ void ndisc_send_rs(struct net_device *dev, str=
uct in6_addr *saddr,
> >          struct sk_buff *skb;
> >          struct icmp6hdr *hdr;
> >  	__u8 * opt;
> > +	struct inet6_ifaddr *ifp;
> >          int len;
> >  	int err;
> >=20
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
> >=20
> > @@ -746,6 +772,7 @@ static void ndisc_recv_ns(struct sk_buff *skb)
> >  	int dad =3D ipv6_addr_any(saddr);
> >  	int inc;
> >  	int is_router;
> > +	int type;
> >=20
> >  	if (ipv6_addr_is_multicast(&msg->target)) {
> >  		ND_PRINTK2(KERN_WARNING
> > @@ -796,28 +823,39 @@ static void ndisc_recv_ns(struct sk_buff *skb=
)
> >  	inc =3D ipv6_addr_is_multicast(daddr);
> >=20
> >  	if ((ifp =3D ipv6_get_ifaddr(&msg->target, dev, 1)) !=3D NULL) {
> > -		if (ifp->flags & IFA_F_TENTATIVE) {
> > -			/* Address is tentative. If the source
> > -			   is unspecified address, it is someone
> > -			   does DAD, otherwise we ignore solicitations
> > -			   until DAD timer expires.
> > -			 */
> > -			if (!dad)
> > +
> > +		if (ifp->flags & (IFA_F_TENTATIVE|IFA_F_OPTIMISTIC)) {
> > +			if (dad) {
> > +				if (dev->type =3D=3D ARPHRD_IEEE802_TR) {
> > +					unsigned char *sadr =3D skb->mac.raw;
> > +					if (((sadr[8] ^ dev->dev_addr[0]) & 0x7f) =3D=3D 0 &&
> > +					    sadr[9] =3D=3D dev->dev_addr[1] &&
> > +					    sadr[10] =3D=3D dev->dev_addr[2] &&
> > +					    sadr[11] =3D=3D dev->dev_addr[3] &&
> > +					    sadr[12] =3D=3D dev->dev_addr[4] &&
> > +					    sadr[13] =3D=3D dev->dev_addr[5]) {
> > +						/* looped-back to us */
> > +						goto out;
> > +					}
> > +				}
> > +
> > +				/*
> > +				 * We are colliding with another node
> > +				 * who is doing DAD
> > +				 * so fail our DAD process
> > +				 */
> > +				addrconf_dad_failure(ifp);
> >  				goto out;
> > -			if (dev->type =3D=3D ARPHRD_IEEE802_TR) {
> > -				unsigned char *sadr =3D skb->mac.raw;
> > -				if (((sadr[8] ^ dev->dev_addr[0]) & 0x7f) =3D=3D 0 &&
> > -				    sadr[9] =3D=3D dev->dev_addr[1] &&
> > -				    sadr[10] =3D=3D dev->dev_addr[2] &&
> > -				    sadr[11] =3D=3D dev->dev_addr[3] &&
> > -				    sadr[12] =3D=3D dev->dev_addr[4] &&
> > -				    sadr[13] =3D=3D dev->dev_addr[5]) {
> > -					/* looped-back to us */
> > +			} else {
> > +				/*
> > +				 * This is not a dad solicitation.
> > +				 * If we are an optimistic node,
> > +				 * we should respond.
> > +				 * Otherwise, we should ignore it.
> > +				 */
> > +				if (!(ifp->flags & IFA_F_OPTIMISTIC))
> >  					goto out;
> > -				}
> >  			}
> > -			addrconf_dad_failure(ifp);
> > -			return;
> >  		}
> >=20
> >  		idev =3D ifp->idev;
> > @@ -1406,7 +1444,7 @@ void ndisc_send_redirect(struct sk_buff *skb,=
 struct neighbour *neigh,
> >=20
> >  	dev =3D skb->dev;
> >=20
> > -	if (ipv6_get_lladdr(dev, &saddr_buf)) {
> > +	if (ipv6_get_lladdr(dev, &saddr_buf, IFA_F_TENTATIVE)) {
> >  		ND_PRINTK2(KERN_WARNING
> >  			   "ICMPv6 Redirect: no link-local address on %s\n",
> >  			   dev->name);
> > -
> > To unsubscribe from this list: send the line "unsubscribe netdev" i=
n
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
