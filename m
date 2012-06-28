From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [net-next PATCH 02/02] net/ipv4: VTI support new module for
 ip_vti.
Date: Thu, 28 Jun 2012 10:04:59 +0200
Message-ID: <20120628080459.GC1869@secunet.com>
References: <20120628010218.GA4056@debian-saurabh-64.vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Saurabh <saurabh.mohan@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53740 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752431Ab2F1IFK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jun 2012 04:05:10 -0400
Content-Disposition: inline
In-Reply-To: <20120628010218.GA4056@debian-saurabh-64.vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 27, 2012 at 06:02:18PM -0700, Saurabh wrote:
> 
> +config NET_IPVTI
> +	tristate "Virtual (secure) IP: tunneling"
> +	select INET_TUNNEL
> +	depends on INET_XFRM_MODE_TUNNEL
> +	---help---
> +	Tunneling means encapsulating data of one protocol type within
> +	another protocol and sending it over a channel that understands the
> +	Pencapsulating protocol. This particular tunneling driver implements
> +	encapsulation of IP within IP-ESP. This can be used with xfrm to give

This is not ESP specific anymore.

> +	the notion of a secure tunnel and then use routing protocol on top.
> +
> +	Saying Y to this option will produce one module ( = code which can
> +	be inserted in and removed from the running kernel whenever you
> +	want). Most people won't need this and can say N.
> +

Saying Y does not build a module, saying M builds a module. Also,
even if build as a module, you can't remove it whenever you want.
You can remove it as long as it is unused.

...

> +static netdev_tx_t vti_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct ip_tunnel *tunnel = netdev_priv(dev);
> +	struct pcpu_tstats *tstats;
> +	struct net_device_stats *stats = &tunnel->dev->stats;
> +	struct iphdr  *tiph = &tunnel->parms.iph;
> +	u8     tos = tunnel->parms.iph.tos;
> +	struct rtable *rt;		/* Route to the other host */
> +	struct net_device *tdev;	/* Device to other host */
> +	struct iphdr  *old_iph = ip_hdr(skb);
> +	__be32 dst = tiph->daddr;
> +	struct flowi4 fl4;
> +
> +	if (skb->protocol != htons(ETH_P_IP))
> +		goto tx_error;
> +
> +	if (tos&1)
> +		tos = old_iph->tos;
> +
> +	if (!dst) {
> +		/* NBMA tunnel */
> +		rt = skb_rtable(skb);
> +		if (rt == NULL) {
> +			stats->tx_fifo_errors++;
> +			goto tx_error;
> +		}
> +		dst = rt->rt_gateway;
> +		if (dst == 0)
> +			goto tx_error_icmp;
> +	}
> +
> +	memset(&fl4, 0, sizeof(fl4));
> +	flowi4_init_output(&fl4, tunnel->parms.link,
> +		htonl(tunnel->parms.i_key), RT_TOS(tos), RT_SCOPE_UNIVERSE,
> +		IPPROTO_IPIP, 0,
> +		dst, tiph->saddr, 0, 0);
> +	rt = ip_route_output_key(dev_net(dev), &fl4);
> +	if (IS_ERR(rt)) {
> +		dev->stats.tx_carrier_errors++;
> +		goto tx_error_icmp;
> +	}
> +#ifdef CONFIG_XFRM
> +		/* if there is no transform then this tunnel is not functional. */
> +		if (!rt->dst.xfrm) {

What if this is a transport mode xfrm?
You should ensure that this is really a tunnel mode xfrm.

> +			stats->tx_carrier_errors++;
> +			goto tx_error_icmp;
> +		}
> +#endif
