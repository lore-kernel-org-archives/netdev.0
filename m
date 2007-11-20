From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 01/01] ipv6: RFC4214 Support (v2.4)
Date: Wed, 21 Nov 2007 02:43:46 +0900 (JST)
Message-ID: <20071121.024346.46225680.yoshfuji@linux-ipv6.org>
References: <39C363776A4E8C4A94691D2BD9D1C9A1029EDC29@XCH-NW-7V2.nw.nos.boeing.com>
	<39C363776A4E8C4A94691D2BD9D1C9A1029EDC2B@XCH-NW-7V2.nw.nos.boeing.com>
	<39C363776A4E8C4A94691D2BD9D1C9A1029EDC3F@XCH-NW-7V2.nw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vladislav.yasevich@hp.com,
	yoshfuji@linux-ipv6.org
To: Fred.L.Templin@boeing.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:35823 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754559AbXKTRnn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 12:43:43 -0500
In-Reply-To: <39C363776A4E8C4A94691D2BD9D1C9A1029EDC3F@XCH-NW-7V2.nw.nos.boeing.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

I'll take care of this.

Regards,

--yoshfuji

In article <39C363776A4E8C4A94691D2BD9D1C9A1029EDC3F@XCH-NW-7V2.nw.nos.boeing.com> (at Tue, 20 Nov 2007 09:36:26 -0800), "Templin, Fred L" <Fred.L.Templin@boeing.com> says:

> From: Fred L. Templin <fred.l.templin@boeing.com>
> 
> This patch includes support for the Intra-Site Automatic Tunnel
> Addressing Protocol (ISATAP) per RFC4214. It uses the SIT
> module, and is configured using extensions to the "iproute2"
> utility. The diffs are specific to the Linux 2.6.24-rc2 kernel
> distribution.
> 
> This version reflects changes based on netdev list discussions
> on 11/14/07 thru 11/15/07. It does away with in-the-kernel RS/RA
> pinging and now asks that the task be performed by an application.
> The application will essentially entail a port of the FreeBSD 'rtsold'
> daemon, and will use the standard socket API.
> 
> Signed-off-by: Fred L. Templin <fred.l.templin@boeing.com>
> 
> ---
> 
> --- linux-2.6.24-rc2/include/linux/if_tunnel.h.orig	2007-11-19 03:54:12.000000000 -0800
> +++ linux-2.6.24-rc2/include/linux/if_tunnel.h	2007-11-19 03:55:58.000000000 -0800
> @@ -17,6 +17,9 @@
>  #define GRE_FLAGS	__constant_htons(0x00F8)
>  #define GRE_VERSION	__constant_htons(0x0007)
>  
> +/* i_flags values for SIT mode */
> +#define	SIT_ISATAP	0x0001
> +
>  struct ip_tunnel_parm
>  {
>  	char			name[IFNAMSIZ];
> --- linux-2.6.24-rc2/include/linux/in.h.orig	2007-11-09 08:00:32.000000000 -0800
> +++ linux-2.6.24-rc2/include/linux/in.h	2007-11-12 07:37:05.000000000 -0800
> @@ -253,6 +253,14 @@ struct sockaddr_in {
>  #define ZERONET(x)	(((x) & htonl(0xff000000)) == htonl(0x00000000))
>  #define LOCAL_MCAST(x)	(((x) & htonl(0xFFFFFF00)) == htonl(0xE0000000))
>  
> +/* Special-Use IPv4 Addresses (RFC3330) */
> +#define PRIVATE_10(x)	(((x) & htonl(0xff000000)) == htonl(0x0A000000))
> +#define LINKLOCAL_169(x) (((x) & htonl(0xffff0000)) == htonl(0xA9FE0000))
> +#define PRIVATE_172(x)	(((x) & htonl(0xfff00000)) == htonl(0xAC100000))
> +#define TEST_192(x)	(((x) & htonl(0xffffff00)) == htonl(0xC0000200))
> +#define ANYCAST_6TO4(x)	(((x) & htonl(0xffffff00)) == htonl(0xC0586300))
> +#define PRIVATE_192(x)	(((x) & htonl(0xffff0000)) == htonl(0xC0A80000))
> +#define TEST_198(x)	(((x) & htonl(0xfffe0000)) == htonl(0xC6120000))
>  #endif
>  
>  #endif	/* _LINUX_IN_H */
> --- linux-2.6.24-rc2/include/net/addrconf.h.orig	2007-11-08 12:06:17.000000000 -0800
> +++ linux-2.6.24-rc2/include/net/addrconf.h	2007-11-19 05:47:48.000000000 -0800
> @@ -17,6 +17,7 @@
>  
>  #define IPV6_MAX_ADDRESSES		16
>  
> +#include <linux/in.h>
>  #include <linux/in6.h>
>  
>  struct prefix_info {
> @@ -241,6 +242,24 @@ static inline int ipv6_addr_is_ll_all_ro
>  		addr->s6_addr32[3] == htonl(0x00000002));
>  }
>  
> +static inline int ipv6_isatap_eui64(u8 *eui, __be32 addr)
> +{
> +	eui[0] = (ZERONET(addr) || PRIVATE_10(addr) || LOOPBACK(addr) ||
> +		  LINKLOCAL_169(addr) || PRIVATE_172(addr) || TEST_192(addr) ||
> +		  ANYCAST_6TO4(addr) || PRIVATE_192(addr) || TEST_198(addr) ||
> +		  MULTICAST(addr) || BADCLASS(addr)) ? 0x00 : 0x02;
> +	eui[1] = 0;
> +	eui[2] = 0x5E;
> +	eui[3] = 0xFE;
> +	memcpy (eui+4, &addr, 4);
> +	return 0;
> +}
> +
> +static inline int ipv6_addr_is_isatap(const struct in6_addr *addr)
> +{
> +	return ((addr->s6_addr32[2] | htonl(0x02000000)) == htonl(0x02005EFE));
> +}
> +
>  #ifdef CONFIG_PROC_FS
>  extern int if6_proc_init(void);
>  extern void if6_proc_exit(void);
> --- linux-2.6.24-rc2/net/ipv6/addrconf.c.orig	2007-11-19 03:43:06.000000000 -0800
> +++ linux-2.6.24-rc2/net/ipv6/addrconf.c	2007-11-19 13:29:36.000000000 -0800
> @@ -379,6 +379,13 @@ static struct inet6_dev * ipv6_add_dev(s
>  		       "%s: Disabled Privacy Extensions\n",
>  		       dev->name);
>  		ndev->cnf.use_tempaddr = -1;
> +
> +		if (dev->type == ARPHRD_SIT && (dev->priv_flags & IFF_ISATAP)) {
> +			printk(KERN_INFO
> +		      	       "%s: Disabled Multicast RS\n",
> +			       dev->name);
> +			ndev->cnf.rtr_solicits = 0;
> +		}
>  	} else {
>  		in6_dev_hold(ndev);
>  		ipv6_regen_rndid((unsigned long) ndev);
> @@ -1435,6 +1442,9 @@ static int ipv6_generate_eui64(u8 *eui, 
>  		return addrconf_ifid_arcnet(eui, dev);
>  	case ARPHRD_INFINIBAND:
>  		return addrconf_ifid_infiniband(eui, dev);
> +	case ARPHRD_SIT:
> +		if (dev->priv_flags & IFF_ISATAP)
> +			return ipv6_isatap_eui64(eui, *(__be32 *)dev->dev_addr);
>  	}
>  	return -1;
>  }
> @@ -1470,7 +1480,7 @@ regen:
>  	 *
>  	 *  - Reserved subnet anycast (RFC 2526)
>  	 *	11111101 11....11 1xxxxxxx
> -	 *  - ISATAP (draft-ietf-ngtrans-isatap-13.txt) 5.1
> +	 *  - ISATAP (RFC4214) 6.1
>  	 *	00-00-5E-FE-xx-xx-xx-xx
>  	 *  - value 0
>  	 *  - XXX: already assigned to an address on the device
> @@ -2201,6 +2211,16 @@ static void addrconf_sit_config(struct n
>  		return;
>  	}
>  
> +	if (dev->priv_flags & IFF_ISATAP) {
> +		struct in6_addr addr;
> +
> +		ipv6_addr_set(&addr,  htonl(0xFE800000), 0, 0, 0);
> +		addrconf_prefix_route(&addr, 64, dev, 0, 0);
> +		if (!ipv6_generate_eui64(addr.s6_addr + 8, dev))
> +			addrconf_add_linklocal(idev, &addr);
> +		return;
> +	}
> +
>  	sit_add_v4_addrs(idev);
>  
>  	if (dev->flags&IFF_POINTOPOINT) {
> --- linux-2.6.24-rc2/net/ipv6/route.c.orig	2007-11-19 15:26:30.000000000 -0800
> +++ linux-2.6.24-rc2/net/ipv6/route.c	2007-11-19 16:06:00.000000000 -0800
> @@ -1668,6 +1668,8 @@ struct rt6_info *rt6_get_dflt_router(str
>  	return rt;
>  }
>  
> +EXPORT_SYMBOL(rt6_get_dflt_router);
> +
>  struct rt6_info *rt6_add_dflt_router(struct in6_addr *gwaddr,
>  				     struct net_device *dev,
>  				     unsigned int pref)
> --- linux-2.6.24-rc2/net/ipv6/sit.c.orig	2007-11-08 12:03:41.000000000 -0800
> +++ linux-2.6.24-rc2/net/ipv6/sit.c	2007-11-19 16:15:01.000000000 -0800
> @@ -16,6 +16,7 @@
>   *	Changes:
>   * Roger Venning <r.venning@telstra.com>:	6to4 support
>   * Nate Thompson <nate@thebog.net>:		6to4 support
> + * Fred L. Templin <fltemplin@acm.org>:		isatap support
>   */
>  
>  #include <linux/module.h>
> @@ -182,6 +183,9 @@ static struct ip_tunnel * ipip6_tunnel_l
>  	dev->init = ipip6_tunnel_init;
>  	nt->parms = *parms;
>  
> +	if (parms->i_flags & SIT_ISATAP)
> +		dev->priv_flags |= IFF_ISATAP;
> +
>  	if (register_netdevice(dev) < 0) {
>  		free_netdev(dev);
>  		goto failed;
> @@ -364,6 +368,48 @@ static inline void ipip6_ecn_decapsulate
>  		IP6_ECN_set_ce(ipv6_hdr(skb));
>  }
>  
> +/* ISATAP (RFC4214) - check source address */
> +static int
> +isatap_srcok(struct sk_buff *skb, struct iphdr *iph, struct net_device *dev)
> +{
> +	struct neighbour *neigh;
> +	struct dst_entry *dst;
> +	struct rt6_info *rt;
> +	struct flowi fl;
> +	struct in6_addr *addr6;
> +	struct in6_addr rtr;
> +	struct ipv6hdr *iph6;
> +	int ok = 0;
> +
> +	/* from onlink default router */
> +	ipv6_addr_set(&rtr,  htonl(0xFE800000), 0, 0, 0);
> +	ipv6_isatap_eui64(rtr.s6_addr + 8, iph->saddr);
> +	if ((rt = rt6_get_dflt_router(&rtr, dev))) {
> +		dst_release(&rt->u.dst);
> +		return 1;
> +	}
> +
> +	iph6 = ipv6_hdr(skb);
> +	memset(&fl, 0, sizeof(fl));
> +	fl.proto = iph6->nexthdr;
> +	ipv6_addr_copy(&fl.fl6_dst, &iph6->saddr);
> +	fl.oif = dev->ifindex;
> +	security_skb_classify_flow(skb, &fl);
> +
> +	dst = ip6_route_output(NULL, &fl);
> +	if (!dst->error && (dst->dev == dev) && (neigh = dst->neighbour)) {
> +
> +		addr6 = (struct in6_addr*)&neigh->primary_key;
> +
> +		/* from correct previous hop */
> +		if (ipv6_addr_is_isatap(addr6) &&
> +		    (addr6->s6_addr32[3] == iph->saddr))
> +			ok = 1;
> +    	}
> +	dst_release(dst);
> +	return ok;
> +}
> +
>  static int ipip6_rcv(struct sk_buff *skb)
>  {
>  	struct iphdr *iph;
> @@ -382,6 +428,14 @@ static int ipip6_rcv(struct sk_buff *skb
>  		IPCB(skb)->flags = 0;
>  		skb->protocol = htons(ETH_P_IPV6);
>  		skb->pkt_type = PACKET_HOST;
> +
> +		if ((tunnel->dev->priv_flags & IFF_ISATAP) &&
> +		    !isatap_srcok(skb, iph, tunnel->dev)) {
> +			tunnel->stat.rx_errors++;
> +			read_unlock(&ipip6_lock);
> +			kfree_skb(skb);
> +			return 0;
> +		}
>  		tunnel->stat.rx_packets++;
>  		tunnel->stat.rx_bytes += skb->len;
>  		skb->dev = tunnel->dev;
> @@ -444,6 +498,29 @@ static int ipip6_tunnel_xmit(struct sk_b
>  	if (skb->protocol != htons(ETH_P_IPV6))
>  		goto tx_error;
>  
> +	/* ISATAP (RFC4214) - must come before 6to4 */
> +	if (dev->priv_flags & IFF_ISATAP) {
> +		struct neighbour *neigh = NULL;
> +
> +		if (skb->dst)
> +			neigh = skb->dst->neighbour;
> +
> +		if (neigh == NULL) {
> +			if (net_ratelimit())
> +		    		printk(KERN_DEBUG "sit: nexthop == NULL\n");
> +			goto tx_error;
> +	    	}
> +
> +		addr6 = (struct in6_addr*)&neigh->primary_key;
> +		addr_type = ipv6_addr_type(addr6);
> +
> +		if ((addr_type & IPV6_ADDR_UNICAST) &&
> +		     ipv6_addr_is_isatap(addr6))
> +			dst = addr6->s6_addr32[3];
> +		else
> +			goto tx_error;
> +	}
> +
>  	if (!dst)
>  		dst = try_6to4(&iph6->daddr);
