From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH 01/01] ipv6: RFC4214 Support (v2.1)
Date: Tue, 13 Nov 2007 14:03:28 -0500
Message-ID: <4739F500.2030404@hp.com>
References: <39C363776A4E8C4A94691D2BD9D1C9A1029EDC14@XCH-NW-7V2.nw.nos.boeing.com> <39C363776A4E8C4A94691D2BD9D1C9A1029EDC1F@XCH-NW-7V2.nw.nos.boeing.com> <39C363776A4E8C4A94691D2BD9D1C9A1029EDC22@XCH-NW-7V2.nw.nos.boeing.com> <39C363776A4E8C4A94691D2BD9D1C9A1029EDC24@XCH-NW-7V2.nw.nos.boeing.com> <4739C7EA.5070609@hp.com> <39C363776A4E8C4A94691D2BD9D1C9A1029EDC27@XCH-NW-7V2.nw.nos.boeing.com> <4739D7F7.90300@hp.com> <39C363776A4E8C4A94691D2BD9D1C9A1029EDC29@XCH-NW-7V2.nw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	=?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SBsoQg==?=
	 =?ISO-2022-JP?B?GyRCRiMxUUxAGyhC?= <yoshfuji@linux-ipv6.org>
To: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:41449 "EHLO palrel12.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763828AbXKMTDc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2007 14:03:32 -0500
In-Reply-To: <39C363776A4E8C4A94691D2BD9D1C9A1029EDC29@XCH-NW-7V2.nw.nos.boeing.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Fred

Looks much better...  a few more comments...

Templin, Fred L wrote:
> @@ -2531,6 +2552,18 @@ static void addrconf_rs_timer(unsigned l
>  		 *	Announcement received after solicitation
>  		 *	was sent
>  		 */
> +
> +		/* ISATAP (RFC4214) - schedule next RS/RA */
> +		if (ifp->idev->dev->priv_flags & IFF_ISATAP) {
> +			struct ip_tunnel *t  = netdev_priv(ifp->idev->dev);
> +			if (t->parms.i_key != INADDR_NONE) {
> +				spin_lock(&ifp->lock);
> +				ifp->probes = 0;
> +				ifp->idev->if_flags &= ~(IF_RS_SENT|IF_RA_RCVD);
> +				addrconf_mod_timer(ifp, AC_RS, t->parms.o_key*HZ);
> +				spin_unlock(&ifp->lock);
> +			}
> +		}
>  		goto out;
>  	}
>  
> @@ -2545,10 +2578,28 @@ static void addrconf_rs_timer(unsigned l
>  				   ifp->idev->cnf.rtr_solicit_interval);
>  		spin_unlock(&ifp->lock);
>  
> -		ipv6_addr_all_routers(&all_routers);
> +		/* ISATAP (RFC4214) - unicast RS */
> +		if (ifp->idev->dev->priv_flags & IFF_ISATAP) {
> +			struct ip_tunnel *t = netdev_priv(ifp->idev->dev);
> +
> +			if (t->parms.i_key == INADDR_NONE) goto out;
> +
> +			ipv6_addr_set(&all_routers, htonl(0xFE800000), 0, 0, 0);
> +			addrconf_ifid_isatap(all_routers.s6_addr + 8, t->parms.i_key);

You have this piece of code here and once more in addrconf_dad_completed().  Move to
its own static function.

> +		} else
> +			ipv6_addr_all_routers(&all_routers);
>  
>  		ndisc_send_rs(ifp->idev->dev, &ifp->addr, &all_routers);
>  	} else {
> +		/* ISATAP (RFC4214) - try again later */
> +		if (ifp->idev->dev->priv_flags & IFF_ISATAP) {
> +			struct ip_tunnel *t = netdev_priv(ifp->idev->dev);
> +			if (t->parms.i_key != INADDR_NONE) {
> +				ifp->probes = 0;
> +				ifp->idev->if_flags &= ~(IF_RS_SENT|IF_RA_RCVD);
> +				addrconf_mod_timer(ifp, AC_RS, t->parms.o_key*HZ);
> +			}
> +		}
>  		spin_unlock(&ifp->lock);

Hm..  Just noticed.  You do this code block under lock, but the block above it is
out of the lock.   Which way should it be?  Is there any way for it to be another
piece of common code.  It shows up 3 times in the same function.

>  		/*
>  		 * Note: we do not support deprecated "all on-link"
> @@ -2594,6 +2645,7 @@ static void addrconf_dad_start(struct in
>  	spin_lock_bh(&ifp->lock);
>  
>  	if (dev->flags&(IFF_NOARP|IFF_LOOPBACK) ||
> +	    dev->priv_flags&IFF_ISATAP ||
>  	    !(ifp->flags&IFA_F_TENTATIVE) ||
>  	    ifp->flags & IFA_F_NODAD) {
>  		ifp->flags &= ~(IFA_F_TENTATIVE|IFA_F_OPTIMISTIC);
> @@ -2690,7 +2742,16 @@ static void addrconf_dad_completed(struc
>  	    (ipv6_addr_type(&ifp->addr) & IPV6_ADDR_LINKLOCAL)) {
>  		struct in6_addr all_routers;
>  
> -		ipv6_addr_all_routers(&all_routers);
> +		/* ISATAP (RFC4214) - unicast RS */
> +		if (ifp->idev->dev->priv_flags & IFF_ISATAP) {
> +			struct ip_tunnel *t = netdev_priv(ifp->idev->dev);
> +
> +			if (t->parms.i_key == INADDR_NONE) return;
> +
> +			ipv6_addr_set(&all_routers, htonl(0xFE800000), 0, 0, 0);
> +			addrconf_ifid_isatap(all_routers.s6_addr + 8, t->parms.i_key);
> +		} else
> +			ipv6_addr_all_routers(&all_routers);
>  
>  		/*
>  		 *	If a host as already performed a random delay
> --- linux-2.6.24-rc2/net/ipv6/sit.c.orig	2007-11-08 12:03:41.000000000 -0800
> +++ linux-2.6.24-rc2/net/ipv6/sit.c	2007-11-13 09:34:31.000000000 -0800
> @@ -16,6 +16,7 @@
>   *	Changes:
>   * Roger Venning <r.venning@telstra.com>:	6to4 support
>   * Nate Thompson <nate@thebog.net>:		6to4 support
> + * Fred L. Templin <fltemplin@acm.org>:		isatap support
>   */
>  
>  #include <linux/module.h>
> @@ -182,6 +183,8 @@ static struct ip_tunnel * ipip6_tunnel_l
>  	dev->init = ipip6_tunnel_init;
>  	nt->parms = *parms;
>  
> +	if (parms->i_key) dev->priv_flags |= IFF_ISATAP;
> +

2 lines please.

>  	if (register_netdevice(dev) < 0) {
>  		free_netdev(dev);
>  		goto failed;
> @@ -364,6 +367,44 @@ static inline void ipip6_ecn_decapsulate
>  		IP6_ECN_set_ce(ipv6_hdr(skb));
>  }
>  
> +/* ISATAP (RFC4214) - check source address */
> +static inline int isatap_src_ok(struct sk_buff *skb, struct iphdr *iph, struct ip_tunnel *tunnel) {

Don't mark it 'inline' please.  It will usually automatically get inlined if it's called
only once.

Thanks
-vlad

> +	struct neighbour *neigh;
> +	struct dst_entry *dst;
> +	struct flowi fl;
> +	struct in6_addr *addr6;
> +	struct ipv6hdr *iph6;
> +	int ok = 0;
> +
> +	/* from ISATAP router */
> +	if ((iph->saddr == tunnel->parms.i_key) &&
> +	    (tunnel->parms.i_key != INADDR_NONE))
> +		return 1;
> +
> +	iph6 = ipv6_hdr(skb);
> +	addr6 = &iph6->saddr;
> +
> +	/* from legitimate previous hop */
> +	memset(&fl, 0, sizeof(fl));
> +	fl.proto = iph6->nexthdr;
> +	ipv6_addr_copy(&fl.fl6_dst, addr6);
> +	fl.oif = tunnel->dev->ifindex;
> +	security_skb_classify_flow(skb, &fl);
> +
> +	dst = ip6_route_output(NULL, &fl);
> +	if (!dst->error && (dst->dev == tunnel->dev) &&
> +	     ((neigh = dst->neighbour) != NULL)) {
> +
> +		addr6 = (struct in6_addr*)&neigh->primary_key;
> +
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
> @@ -382,6 +423,14 @@ static int ipip6_rcv(struct sk_buff *skb
>  		IPCB(skb)->flags = 0;
>  		skb->protocol = htons(ETH_P_IPV6);
>  		skb->pkt_type = PACKET_HOST;
> +
> +		if ((tunnel->dev->priv_flags & IFF_ISATAP) &&
> +		    !isatap_src_ok(skb, iph, tunnel)) {
> +			tunnel->stat.rx_errors++;
> +			read_unlock(&ipip6_lock);
> +			kfree_skb(skb);
> +			return 0;
> +		}
>  		tunnel->stat.rx_packets++;
>  		tunnel->stat.rx_bytes += skb->len;
>  		skb->dev = tunnel->dev;
> @@ -444,6 +493,29 @@ static int ipip6_tunnel_xmit(struct sk_b
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
>  
> @@ -651,6 +723,8 @@ ipip6_tunnel_ioctl (struct net_device *d
>  				ipip6_tunnel_unlink(t);
>  				t->parms.iph.saddr = p.iph.saddr;
>  				t->parms.iph.daddr = p.iph.daddr;
> +				t->parms.i_key = p.i_key;
> +				t->parms.o_key = p.o_key;
>  				memcpy(dev->dev_addr, &p.iph.saddr, 4);
>  				memcpy(dev->broadcast, &p.iph.daddr, 4);
>  				ipip6_tunnel_link(t);
> @@ -663,6 +737,8 @@ ipip6_tunnel_ioctl (struct net_device *d
>  			if (cmd == SIOCCHGTUNNEL) {
>  				t->parms.iph.ttl = p.iph.ttl;
>  				t->parms.iph.tos = p.iph.tos;
> +				t->parms.i_key = p.i_key;
> +				t->parms.o_key = p.o_key;
>  			}
>  			if (copy_to_user(ifr->ifr_ifru.ifru_data, &t->parms, sizeof(p)))
>  				err = -EFAULT;
> 

