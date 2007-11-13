From: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Subject: RE: [PATCH 01/01] ipv6: RFC4214 Support (v2.0)
Date: Tue, 13 Nov 2007 08:32:25 -0800
Message-ID: <39C363776A4E8C4A94691D2BD9D1C9A1029EDC27@XCH-NW-7V2.nw.nos.boeing.com>
References: <39C363776A4E8C4A94691D2BD9D1C9A1029EDC14@XCH-NW-7V2.nw.nos.boeing.com> <39C363776A4E8C4A94691D2BD9D1C9A1029EDC1F@XCH-NW-7V2.nw.nos.boeing.com> <39C363776A4E8C4A94691D2BD9D1C9A1029EDC22@XCH-NW-7V2.nw.nos.boeing.com> <39C363776A4E8C4A94691D2BD9D1C9A1029EDC24@XCH-NW-7V2.nw.nos.boeing.com> <4739C7EA.5070609@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	=?iso-2022-jp?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>
To: "Vlad Yasevich" <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slb-smtpout-01.boeing.com ([130.76.64.48]:46942 "EHLO
	slb-smtpout-01.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756424AbXKMQcv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 11:32:51 -0500
Content-class: urn:content-classes:message
In-Reply-To: <4739C7EA.5070609@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

HI Vlad, 

> -----Original Message-----
> From: Vlad Yasevich [mailto:vladislav.yasevich@hp.com] 
> Sent: Tuesday, November 13, 2007 7:51 AM
> To: Templin, Fred L
> Cc: netdev@vger.kernel.org; YOSHIFUJI Hideaki / 吉藤英明
> Subject: Re: [PATCH 01/01] ipv6: RFC4214 Support (v2.0)
> 
> Hi Fred
> 
> Some comments.
> 
> Templin, Fred L wrote:
> > From: Fred L. Templin <fred.l.templin@boeing.com>
> > 
> > This patch includes support for the Intra-Site Automatic Tunnel
> > Addressing Protocol (ISATAP) per RFC4214. It uses the SIT
> > module, and is configured using extensions to the "iproute2"
> > utility.
> > 
> > The following diffs are specific to the Linux 2.6.24-rc2 kernel
> > distribution. This message includes the full and patchable 
> diff text;
> > please use this version to apply patches.
> > 
> > Signed-off-by: Fred L. Templin <fred.l.templin@boeing.com>
> > 
> > ---
> > 
> > --- linux-2.6.24-rc2/include/linux/if.h.orig	
> 2007-11-08 12:05:47.000000000 -0800
> > +++ linux-2.6.24-rc2/include/linux/if.h	2007-11-08 
> 08:26:44.000000000 -0800
> > @@ -61,6 +61,7 @@
> >  #define IFF_MASTER_ALB	0x10		/* bonding 
> master, balance-alb.	*/
> >  #define IFF_BONDING	0x20		/* bonding 
> master or slave	*/
> >  #define IFF_SLAVE_NEEDARP 0x40		/* need ARPs 
> for validation	*/
> > +#define IFF_ISATAP	0x80		/* ISATAP interface 
> (RFC4214)	*/
> >  
> >  #define IF_GET_IFACE	0x0001		/* for querying only */
> >  #define IF_GET_PROTO	0x0002
> > --- linux-2.6.24-rc2/include/linux/in.h.orig	
> 2007-11-09 08:00:32.000000000 -0800
> > +++ linux-2.6.24-rc2/include/linux/in.h	2007-11-12 
> 07:37:05.000000000 -0800
> > @@ -253,6 +253,14 @@ struct sockaddr_in {
> >  #define ZERONET(x)	(((x) & htonl(0xff000000)) == htonl(0x00000000))
> >  #define LOCAL_MCAST(x)	(((x) & htonl(0xFFFFFF00)) == 
> htonl(0xE0000000))
> >  
> > +/* Special-Use IPv4 Addresses (RFC3330) */
> > +#define PRIVATE_10(x)	(((x) & htonl(0xff000000)) == 
> htonl(0x0A000000))
> > +#define LINKLOCAL_169(x) (((x) & htonl(0xffff0000)) == 
> htonl(0xA9FE0000))
> > +#define PRIVATE_172(x)	(((x) & htonl(0xfff00000)) == 
> htonl(0xAC100000))
> > +#define TEST_192(x)	(((x) & htonl(0xffffff00)) == 
> htonl(0xC0000200))
> > +#define ANYCAST_6TO4(x)	(((x) & htonl(0xffffff00)) == 
> htonl(0xC0586300))
> > +#define PRIVATE_192(x)	(((x) & htonl(0xffff0000)) == 
> htonl(0xC0A80000))
> > +#define TEST_198(x)	(((x) & htonl(0xfffe0000)) == 
> htonl(0xC6120000))
> >  #endif
> >  
> >  #endif	/* _LINUX_IN_H */
> > --- linux-2.6.24-rc2/include/net/addrconf.h.orig	
> 2007-11-08 12:06:17.000000000 -0800
> > +++ linux-2.6.24-rc2/include/net/addrconf.h	2007-11-12 
> 14:29:51.000000000 -0800
> > @@ -241,6 +241,12 @@ static inline int ipv6_addr_is_ll_all_ro
> >  		addr->s6_addr32[3] == htonl(0x00000002));
> >  }
> >  
> > +/* only for IFF_ISATAP interfaces */
> > +static inline int ipv6_addr_is_isatap(const struct in6_addr *addr)
> > +{
> > +	return ((addr->s6_addr32[2] | htonl(0x02000000)) == 
> htonl(0x02005EFE));
> > +}
> > +
> >  #ifdef CONFIG_PROC_FS
> >  extern int if6_proc_init(void);
> >  extern void if6_proc_exit(void);
> > --- linux-2.6.24-rc2/net/ipv6/addrconf.c.orig	
> 2007-11-08 11:59:35.000000000 -0800
> > +++ linux-2.6.24-rc2/net/ipv6/addrconf.c	2007-11-12 
> 14:32:43.000000000 -0800
> > @@ -75,7 +75,7 @@
> >  #include <net/ip.h>
> >  #include <net/netlink.h>
> >  #include <net/pkt_sched.h>
> > -#include <linux/if_tunnel.h>
> > +#include <net/ipip.h>
> >  #include <linux/rtnetlink.h>
> >  
> >  #ifdef CONFIG_IPV6_PRIVACY
> > @@ -1424,6 +1424,20 @@ static int addrconf_ifid_infiniband(u8 *
> >  	return 0;
> >  }
> >  
> > +static int addrconf_ifid_isatap(u8 *eui, __be32 addr)
> > +{
> > +
> > +	eui[0] = 0x02; eui[1] = 0; eui[2] = 0x5E; eui[3] = 0xFE;
> > +	memcpy (eui+4, &addr, 4);
> > +
> > +	if (ZERONET(addr) || PRIVATE_10(addr) || LOOPBACK(addr) ||
> > +	    LINKLOCAL_169(addr) || PRIVATE_172(addr) || 
> TEST_192(addr) ||
> > +	    ANYCAST_6TO4(addr) || PRIVATE_192(addr) || TEST_198(addr) ||
> > +	    MULTICAST(addr) || BADCLASS(addr)) eui[0] &= ~0x02;
> 
> Please put the assignment on its own line.

OK.

> > +
> > +	return 0;
> > +}
> > +
> >  static int ipv6_generate_eui64(u8 *eui, struct net_device *dev)
> >  {
> >  	switch (dev->type) {
> > @@ -1435,6 +1449,9 @@ static int ipv6_generate_eui64(u8 *eui, 
> >  		return addrconf_ifid_arcnet(eui, dev);
> >  	case ARPHRD_INFINIBAND:
> >  		return addrconf_ifid_infiniband(eui, dev);
> > +	case ARPHRD_SIT:
> > +		if (dev->priv_flags & IFF_ISATAP)
> > +			return addrconf_ifid_isatap(eui, 
> *(__be32 *)dev->dev_addr);
> >  	}
> >  	return -1;
> >  }
> > @@ -1470,8 +1487,7 @@ regen:
> >  	 *
> >  	 *  - Reserved subnet anycast (RFC 2526)
> >  	 *	11111101 11....11 1xxxxxxx
> > -	 *  - ISATAP (draft-ietf-ngtrans-isatap-13.txt) 5.1
> > -	 *	00-00-5E-FE-xx-xx-xx-xx
> > +	 *  - ISATAP (RFC4214) 00-00-5E-FE-xx-xx-xx-xx
> >  	 *  - value 0
> >  	 *  - XXX: already assigned to an address on the device
> >  	 */
> > @@ -2201,6 +2217,29 @@ static void addrconf_sit_config(struct n
> >  		return;
> >  	}
> >  
> > +	/* ISATAP (RFC4214) - NBMA link */
> > +	if (dev->priv_flags & IFF_ISATAP) {
> > +		struct in6_addr addr;
> > +
> > +		addrconf_add_lroute(dev);
> > +
> > +		ipv6_addr_set(&addr,  htonl(0xFE800000), 0, 0, 0);
> > +
> > +		if (ipv6_generate_eui64(addr.s6_addr + 8, dev) == 0) {
> > +			struct inet6_ifaddr *ifp;
> > +
> > +			ifp = ipv6_add_addr(idev, &addr, 64,
> > +					IFA_LINK, IFA_F_PERMANENT);
> > +			if (!IS_ERR(ifp)) {
> > +				addrconf_prefix_route(&ifp->addr,
> > +					ifp->prefix_len, 
> idev->dev, 0, 0);
> > +				addrconf_dad_start(ifp, 0);
> > +				in6_ifa_put(ifp);
> > +			}
> > +	
> 
> If ipv6_generate_eui64() or ipv6_add_addr() fail, you will 
> still have a link-local
> prefix route on the device.
> 
> You might want to pull out the above code into a separate 
> function and do correct
> clean-ups on failures.

OK.

> > +		return;
> > +	}
> > +
> >  	sit_add_v4_addrs(idev);
> >  
> >  	if (dev->flags&IFF_POINTOPOINT) {
> > @@ -2531,6 +2570,18 @@ static void addrconf_rs_timer(unsigned l
> >  		 *	Announcement received after solicitation
> >  		 *	was sent
> >  		 */
> > +
> > +		/* ISATAP (RFC4214) - schedule next RS/RA */
> > +		if (ifp->idev->dev->priv_flags & IFF_ISATAP) {
> > +			struct ip_tunnel *t  = 
> netdev_priv(ifp->idev->dev);
> > +			if (t->parms.i_key != INADDR_NONE) {
> > +				spin_lock(&ifp->lock);
> > +				ifp->probes = 0;
> > +				ifp->idev->if_flags &= 
> ~(IF_RS_SENT|IF_RA_RCVD);
> > +				addrconf_mod_timer(ifp, AC_DAD, 
> t->parms.o_key*HZ);
> 
> You are using a DAD timer to schedule RS?

I am using the DAD timer to re-DAD the link local, which
in turn schedules RS.

> > +				spin_unlock(&ifp->lock);
> > +			}
> > +		}
> >  		goto out;
> >  	}
> >  
> > @@ -2545,10 +2596,28 @@ static void addrconf_rs_timer(unsigned l
> >  				   ifp->idev->cnf.rtr_solicit_interval);
> >  		spin_unlock(&ifp->lock);
> >  
> > -		ipv6_addr_all_routers(&all_routers);
> > +		/* ISATAP (RFC4214) - unicast RS */
> > +		if (ifp->idev->dev->priv_flags & IFF_ISATAP) {
> > +			struct ip_tunnel *t = 
> netdev_priv(ifp->idev->dev);
> > +
> > +			if (t->parms.i_key == INADDR_NONE) goto out;
> > +
> > +			ipv6_addr_set(&all_routers, 
> htonl(0xFE800000), 0, 0, 0);
> > +			
> addrconf_ifid_isatap(all_routers.s6_addr + 8, t->parms.i_key);
> > +		} else
> > +			ipv6_addr_all_routers(&all_routers);
> >  
> >  		ndisc_send_rs(ifp->idev->dev, &ifp->addr, &all_routers);
> >  	} else {
> > +		/* ISATAP (RFC4214) - try again later */
> > +		if (ifp->idev->dev->priv_flags & IFF_ISATAP) {
> > +			struct ip_tunnel *t = 
> netdev_priv(ifp->idev->dev);
> > +			if (t->parms.i_key != INADDR_NONE) {
> > +				ifp->probes = 0;
> > +				ifp->idev->if_flags &= 
> ~(IF_RS_SENT|IF_RA_RCVD);
> > +				addrconf_mod_timer(ifp, AC_DAD, 
> t->parms.o_key*HZ);
> 
> Again, using DAD timer?

Same as above.

> > +			}
> > +		}
> >  		spin_unlock(&ifp->lock);
> >  		/*
> >  		 * Note: we do not support deprecated "all on-link"
> > @@ -2594,6 +2663,7 @@ static void addrconf_dad_start(struct in
> >  	spin_lock_bh(&ifp->lock);
> >  
> >  	if (dev->flags&(IFF_NOARP|IFF_LOOPBACK) ||
> > +	    dev->priv_flags&IFF_ISATAP ||
> >  	    !(ifp->flags&IFA_F_TENTATIVE) ||
> >  	    ifp->flags & IFA_F_NODAD) {
> >  		ifp->flags &= ~(IFA_F_TENTATIVE|IFA_F_OPTIMISTIC);
> > @@ -2690,7 +2760,16 @@ static void addrconf_dad_completed(struc
> >  	    (ipv6_addr_type(&ifp->addr) & IPV6_ADDR_LINKLOCAL)) {
> >  		struct in6_addr all_routers;
> >  
> > -		ipv6_addr_all_routers(&all_routers);
> > +		/* ISATAP (RFC4214) - unicast RS */
> > +		if (ifp->idev->dev->priv_flags & IFF_ISATAP) {
> > +			struct ip_tunnel *t = 
> netdev_priv(ifp->idev->dev);
> > +
> > +			if (t->parms.i_key == INADDR_NONE) return;
> > +
> > +			ipv6_addr_set(&all_routers, 
> htonl(0xFE800000), 0, 0, 0);
> > +			
> addrconf_ifid_isatap(all_routers.s6_addr + 8, t->parms.i_key);
> > +		} else
> > +			ipv6_addr_all_routers(&all_routers);
> >  
> >  		/*
> >  		 *	If a host as already performed a random delay
> > --- linux-2.6.24-rc2/net/ipv6/sit.c.orig	2007-11-08 
> 12:03:41.000000000 -0800
> > +++ linux-2.6.24-rc2/net/ipv6/sit.c	2007-11-12 
> 14:30:52.000000000 -0800
> > @@ -16,6 +16,7 @@
> >   *	Changes:
> >   * Roger Venning <r.venning@telstra.com>:	6to4 support
> >   * Nate Thompson <nate@thebog.net>:		6to4 support
> > + * Fred L. Templin <fltemplin@acm.org>:		isatap support
> >   */
> >  
> >  #include <linux/module.h>
> > @@ -182,6 +183,8 @@ static struct ip_tunnel * ipip6_tunnel_l
> >  	dev->init = ipip6_tunnel_init;
> >  	nt->parms = *parms;
> >  
> > +	if (parms->i_key) dev->priv_flags |= IFF_ISATAP;
> > +
> >  	if (register_netdevice(dev) < 0) {
> >  		free_netdev(dev);
> >  		goto failed;
> > @@ -382,6 +385,47 @@ static int ipip6_rcv(struct sk_buff *skb
> >  		IPCB(skb)->flags = 0;
> >  		skb->protocol = htons(ETH_P_IPV6);
> >  		skb->pkt_type = PACKET_HOST;
> > +
> > +		/* ISATAP (RFC4214) - check source address */
> > +		if (tunnel->dev->priv_flags & IFF_ISATAP) {
> > +			struct neighbour *neigh;
> > +			struct dst_entry *dst;
> > +			struct flowi fl;
> > +			struct in6_addr *addr6;
> > +			struct ipv6hdr *iph6;
> > +
> > +			/* from ISATAP router */
> > +			if ((tunnel->parms.i_key != INADDR_NONE) &&
> > +			    (iph->saddr == 
> tunnel->parms.i_key)) goto accept;
> > +
> > +			iph6 = ipv6_hdr(skb);
> > +			addr6 = &iph6->saddr;
> > +
> > +			/* from legitimate previous hop */
> > +			memset(&fl, 0, sizeof(fl));
> > +			fl.proto = iph6->nexthdr;
> > +			ipv6_addr_copy(&fl.fl6_dst, addr6);
> > +			fl.oif = tunnel->dev->ifindex;
> > +			security_skb_classify_flow(skb, &fl);
> > +
> > +			if (!(dst = ip6_route_output(NULL, &fl)) ||
> > +			     (dst->dev != tunnel->dev) ||
> > +			     ((neigh = dst->neighbour) == 
> NULL)) goto drop;
> 
> You are catching the error conditions incorrectly.  
> ip6_route_output will return
> a pointer to dst whose error field will be set if the route 
> lookup failed.  You need
> to do something like:
> 			dst = ip6_route_output(NULL, &fl);
> 			if (dst->error || dst->dev != 
> tunnel->dev || ...)

OK.

> Also, please put the 'goto' on its own line.

OK.
 
> > +
> > +			addr6 = (struct in6_addr*)&neigh->primary_key;
> > +
> > +			if (!(ipv6_addr_is_isatap(addr6)) ||
> > +			     (addr6->s6_addr32[3] != iph->saddr)) {
> > +drop:
> > +				tunnel->stat.rx_errors++;
> > +				read_unlock(&ipip6_lock);
> > +				dst_release(dst);
> > +				kfree_skb(skb);
> > +				return 0;
> > +		    	}
> > +			dst_release(dst);
> > +		}
> > +accept:
> 
> You never use the 'drop' or 'accept' tags.  You can remove 
> them.

OK.

> Also, it appears
> that you are doing some validations on the tunnel.  Might 
> want to split that out into its
> own function and just call that.

OK.

Fred
fred.l.templin@boeing.com

> -vlad
> 
> >  		tunnel->stat.rx_packets++;
> >  		tunnel->stat.rx_bytes += skb->len;
> >  		skb->dev = tunnel->dev;
> > @@ -444,6 +488,29 @@ static int ipip6_tunnel_xmit(struct sk_b
> >  	if (skb->protocol != htons(ETH_P_IPV6))
> >  		goto tx_error;
> >  
> > +	/* ISATAP (RFC4214) - must come before 6to4 */
> > +	if (dev->priv_flags & IFF_ISATAP) {
> > +		struct neighbour *neigh = NULL;
> > +
> > +		if (skb->dst)
> > +			neigh = skb->dst->neighbour;
> > +
> > +		if (neigh == NULL) {
> > +			if (net_ratelimit())
> > +		    		printk(KERN_DEBUG "sit: nexthop 
> == NULL\n");
> > +			goto tx_error;
> > +	    	}
> > +
> > +		addr6 = (struct in6_addr*)&neigh->primary_key;
> > +		addr_type = ipv6_addr_type(addr6);
> > +
> > +		if ((addr_type & IPV6_ADDR_UNICAST) &&
> > +		     ipv6_addr_is_isatap(addr6))
> > +			dst = addr6->s6_addr32[3];
> > +		else
> > +			goto tx_error;
> > +	}
> > +
> >  	if (!dst)
> >  		dst = try_6to4(&iph6->daddr);
> >  
> > @@ -651,6 +718,8 @@ ipip6_tunnel_ioctl (struct net_device *d
> >  				ipip6_tunnel_unlink(t);
> >  				t->parms.iph.saddr = p.iph.saddr;
> >  				t->parms.iph.daddr = p.iph.daddr;
> > +				t->parms.i_key = p.i_key;
> > +				t->parms.o_key = p.o_key;
> >  				memcpy(dev->dev_addr, &p.iph.saddr, 4);
> >  				memcpy(dev->broadcast, &p.iph.daddr, 4);
> >  				ipip6_tunnel_link(t);
> > @@ -663,6 +732,8 @@ ipip6_tunnel_ioctl (struct net_device *d
> >  			if (cmd == SIOCCHGTUNNEL) {
> >  				t->parms.iph.ttl = p.iph.ttl;
> >  				t->parms.iph.tos = p.iph.tos;
> > +				t->parms.i_key = p.i_key;
> > +				t->parms.o_key = p.o_key;
> >  			}
> >  			if 
> (copy_to_user(ifr->ifr_ifru.ifru_data, &t->parms, sizeof(p)))
> >  				err = -EFAULT;
> > -
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> 
> 
