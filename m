From: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Subject: RE: [PATCH 04/05] ipv6: RFC4214 Support
Date: Wed, 7 Nov 2007 08:16:45 -0800
Message-ID: <39C363776A4E8C4A94691D2BD9D1C9A1029EDBEC@XCH-NW-7V2.nw.nos.boeing.com>
References: <39C363776A4E8C4A94691D2BD9D1C9A1029EDBE5@XCH-NW-7V2.nw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from blv-smtpout-01.boeing.com ([130.76.32.69]:33185 "EHLO
	blv-smtpout-01.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753057AbXKGQQy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 11:16:54 -0500
Received: from stl-av-01.boeing.com (stl-av-01.boeing.com [192.76.190.6])
	by blv-smtpout-01.ns.cs.boeing.com (8.14.0/8.14.0/8.14.0/SMTPOUT) with ESMTP id lA7GGrAx028368
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 7 Nov 2007 08:16:53 -0800 (PST)
Received: from stl-av-01.boeing.com (localhost [127.0.0.1])
	by stl-av-01.boeing.com (8.14.0/8.14.0/DOWNSTREAM_RELAY) with ESMTP id lA7GGqfn011209
	for <netdev@vger.kernel.org>; Wed, 7 Nov 2007 10:16:52 -0600 (CST)
Received: from XCH-NWBH-11.nw.nos.boeing.com (xch-nwbh-11.nw.nos.boeing.com [130.247.55.84])
	by stl-av-01.boeing.com (8.14.0/8.14.0/UPSTREAM_RELAY) with ESMTP id lA7GGiXf010988
	for <netdev@vger.kernel.org>; Wed, 7 Nov 2007 10:16:49 -0600 (CST)
Content-class: urn:content-classes:message
In-Reply-To: <39C363776A4E8C4A94691D2BD9D1C9A1029EDBE5@XCH-NW-7V2.nw.nos.boeing.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> @@ -395,8 +451,6 @@ static int ipip6_rcv(struct sk_buff *skb
>  	}
>  
>  	icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PORT_UNREACH, 0);
> -	kfree_skb(skb);
> -	read_unlock(&ipip6_lock);
>  out:
>  	return 0;
>  }

Note that the above lines were incorrectly deleted.
This has been fixed and tested.

Fred
fred.l.templin@boeing.com

> -----Original Message-----
> From: Templin, Fred L 
> Sent: Tuesday, November 06, 2007 5:16 PM
> To: netdev@vger.kernel.org
> Subject: [PATCH 04/05] ipv6: RFC4214 Support
> 
> From: Fred L. Templin <fred.l.templin@boeing.com>
> 
> This is experimental support for the Intra-Site Automatic
> Tunnel Addressing Protocol (ISATAP) per RFC4214. It uses
> the SIT module, and is configured using the unmodified
> "ip" utility with device names beginning with: "isatap".
> 
> The following diffs are specific to the Linux 2.6.23
> kernel distribution.
> 
> Signed-off-by: Fred L. Templin <fred.l.templin@boeing.com>
> 
> ---
> 
> --- linux-2.6.23/net/ipv6/sit.c.orig	2007-10-09 13:31:38.000000000
> -0700
> +++ linux-2.6.23/net/ipv6/sit.c	2007-11-06 
> 15:32:27.000000000 -0800
> @@ -16,6 +16,7 @@
>   *	Changes:
>   * Roger Venning <r.venning@telstra.com>:	6to4 support
>   * Nate Thompson <nate@thebog.net>:		6to4 support
> + * Fred L. Templin <fltemplin@acm.org>:		isatap support
>   */
>  
>  #include <linux/module.h>
> @@ -154,6 +155,14 @@ static struct ip_tunnel * ipip6_tunnel_l
>  	struct net_device *dev;
>  	char name[IFNAMSIZ];
>  
> +#if defined(CONFIG_IPV6_ISATAP)
> +	/* ISATAP (RFC4214) - router address in daddr */
> +	if (!strncmp(parms->name, "isatap", 6)) {
> +		parms->i_key = parms->iph.daddr;
> +		parms->iph.daddr = remote = 0;
> +	}
> +#endif
> +
>  	for (tp = __ipip6_bucket(parms); (t = *tp) != NULL; tp =
> &t->next) {
>  		if (local == t->parms.iph.saddr && remote ==
> t->parms.iph.daddr)
>  			return t;
> @@ -182,6 +191,11 @@ static struct ip_tunnel * ipip6_tunnel_l
>  	dev->init = ipip6_tunnel_init;
>  	nt->parms = *parms;
>  
> +#if defined(CONFIG_IPV6_ISATAP)
> +	if (!strncmp(dev->name, "isatap", 6))
> +		dev->priv_flags |= IFF_ISATAP;
> +#endif
> +
>  	if (register_netdevice(dev) < 0) {
>  		free_netdev(dev);
>  		goto failed;
> @@ -382,6 +396,48 @@ static int ipip6_rcv(struct sk_buff *skb
>  		IPCB(skb)->flags = 0;
>  		skb->protocol = htons(ETH_P_IPV6);
>  		skb->pkt_type = PACKET_HOST;
> +#if defined(CONFIG_IPV6_ISATAP)
> +		/* ISATAP (RFC4214) - check source address */
> +		if (tunnel->dev->priv_flags & IFF_ISATAP) {
> +		    struct neighbour *neigh;
> +		    struct dst_entry *dst;
> +		    struct flowi fl;
> +		    struct in6_addr *addr6;
> +		    struct ipv6hdr *iph6;
> +
> +		    /* from ISATAP router */
> +		    if (iph->saddr == tunnel->parms.i_key) goto accept;
> +
> +		    iph6 = ipv6_hdr(skb);
> +		    addr6 = &iph6->saddr;
> +
> +		    /* from legitimate previous hop */
> +		    memset(&fl, 0, sizeof(fl));
> +		    fl.proto = iph6->nexthdr;
> +		    ipv6_addr_copy(&fl.fl6_dst, addr6);
> +		    fl.oif = tunnel->dev->ifindex;
> +		    security_skb_classify_flow(skb, &fl);
> +
> +		    if (!(dst = ip6_route_output(NULL, &fl)) ||
> +			 (dst->dev != tunnel->dev) ||
> +			 ((neigh = dst->neighbour) == NULL))
> +			goto drop;
> +
> +		    addr6 = (struct in6_addr*)&neigh->primary_key;
> +
> +		    if (!(ipv6_addr_is_isatap(addr6)) ||
> +			(addr6->s6_addr32[3] != iph->saddr)) {
> +drop:
> +			tunnel->stat.rx_errors++;
> +			dst_release(dst);
> +			kfree_skb(skb);
> +			read_unlock(&ipip6_lock);
> +			return 0;
> +		    }
> +		    dst_release(dst);
> +		}
> +accept:
> +#endif
>  		tunnel->stat.rx_packets++;
>  		tunnel->stat.rx_bytes += skb->len;
>  		skb->dev = tunnel->dev;
> @@ -395,8 +451,6 @@ static int ipip6_rcv(struct sk_buff *skb
>  	}
>  
>  	icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PORT_UNREACH, 0);
> -	kfree_skb(skb);
> -	read_unlock(&ipip6_lock);
>  out:
>  	return 0;
>  }
> @@ -444,6 +498,31 @@ static int ipip6_tunnel_xmit(struct sk_b
>  	if (skb->protocol != htons(ETH_P_IPV6))
>  		goto tx_error;
>  
> +#if defined(CONFIG_IPV6_ISATAP)
> +	/* ISATAP (RFC4214) - must come before 6to4 */
> +	if (dev->priv_flags & IFF_ISATAP) {
> +		struct neighbour *neigh = NULL;
> +
> +		if (skb->dst)
> +			neigh = skb->dst->neighbour;
> +
> +		if (neigh == NULL) {
> +			if (net_ratelimit())
> +		    		printk(KERN_DEBUG "sit: nexthop ==
> NULL\n");
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
> +#endif	/* CONFIG_IPV6_ISATAP */
> +
>  	if (!dst)
>  		dst = try_6to4(&iph6->daddr);
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
