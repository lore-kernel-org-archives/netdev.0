From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] net: packet: option to only pass skb protocol
Date: Wed, 6 Jan 2010 21:24:16 +0200
Message-ID: <20100106192416.GA7586@redhat.com>
References: <4B43AEF6.6050701@nortel.com> <20100105.134218.258781374.davem@davemloft.net> <4B43B989.4010004@nortel.com> <20100105.155150.232916389.davem@davemloft.net> <20100106091257.GB599@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cfriesen@nortel.com, eric.dumazet@gmail.com, nhorman@tuxdriver.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756147Ab0AFT11@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100106091257.GB599@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 06, 2010 at 11:12:57AM +0200, Michael S. Tsirkin wrote:
> On Tue, Jan 05, 2010 at 03:51:50PM -0800, David Miller wrote:
> > From: "Chris Friesen" <cfriesen@nortel.com>
> > Date: Tue, 05 Jan 2010 16:13:29 -0600
> > 
> > > If SOCK_RAW packets are being sent, the protocol number is embedded in
> > > the packet data
> > 
> > Where exactly is that protocol value?  Not every link level protocol
> > is ethernet.
> > 
> > We support FDDI, HIPPI, wireless, VLAN, PPP, and a host of others.
> > 
> > So you can't know for sure unless you assume ethernet, which you
> > can't do.
> 
> You are right.  This is TX though so the socket is bound to a specific
> device, and devices know which link protocol they use.  So we could add a
> get_protocol operation to each device type, and call it if the protocol
> passed is ETH_P_ALL to get the real one.
> 
> Like this: except I only added this for ethernet, and I would have to
> add this for the rest of device types. But I would like to hear what
> others think about this before I do the rest of the work for the rest of
> device types.
> 
> Does the below look sane?

I mean, besides the missing semicolons etc :)
Also, maybe it's a good idea to add a socket option that would trigger
this behaviour, just to make sure existing behavior stays unchanged
even if it's broken?


> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index a3fccc8..99d7801 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -319,6 +319,7 @@ struct header_ops {
>  	void	(*cache_update)(struct hh_cache *hh,
>  				const struct net_device *dev,
>  				const unsigned char *haddr);
> +	__be16	(*get_protocol)(struct sk_buff *skb, struct net_device *dev)
>  };
>  
>  /* These flag bits are private to the generic network queueing
> diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
> index 205a1c1..3e7761d 100644
> --- a/net/ethernet/eth.c
> +++ b/net/ethernet/eth.c
> @@ -231,6 +231,17 @@ int eth_header_parse(const struct sk_buff *skb, unsigned char *haddr)
>  EXPORT_SYMBOL(eth_header_parse);
>  
>  /**
> + * eth_get_protocol - extract protocol value from packet
> + * @skb: packet to extract protocol from
> + * @dev: source device
> + */
> +__be16 eth_get_protocol(const struct sk_buff *skb, struct net_device *dev)
> +{
> +	const struct ethhdr *eth = eth_hdr(skb);
> +	return eth->h_proto
> +}
> +
> +/**
>   * eth_header_cache - fill cache entry from neighbour
>   * @neigh: source neighbour
>   * @hh: destination cache entry
> @@ -324,6 +335,7 @@ EXPORT_SYMBOL(eth_validate_addr);
>  const struct header_ops eth_header_ops ____cacheline_aligned = {
>  	.create		= eth_header,
>  	.parse		= eth_header_parse,
> +	.get_protocol   = eth_get_protocol,
>  	.rebuild	= eth_rebuild_header,
>  	.cache		= eth_header_cache,
>  	.cache_update	= eth_header_cache_update,
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index a81dae8..492e580 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -845,7 +845,6 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
>  
>  	ph.raw = frame;
>  
> -	skb->protocol = proto;
>  	skb->dev = dev;
>  	skb->priority = po->sk.sk_priority;
>  	skb->mark = po->sk.sk_mark;
> @@ -924,6 +923,14 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
>  		len = ((to_write > len_max) ? len_max : to_write);
>  	}
>  
> +	if (proto == htons(ETH_P_ALL) && dev->header_ops->get_protocol) {
> +		skb->protocol = dev->header_ops->get_protocol(dev, skb);
> +		if (unlikely(skb->protocol == htons(ETH_P_ALL)))
> +			return -EINVAL;
> +	} else {
> +		skb->protocol = proto;
> +	}
> +
>  	return tp_len;
>  }
>  
> @@ -1113,7 +1120,13 @@ static int packet_snd(struct socket *sock,
>  	if (err)
>  		goto out_free;
>  
> -	skb->protocol = proto;
> +	if (proto == htons(ETH_P_ALL) && dev->header_ops->get_protocol) {
> +		skb->protocol = dev->header_ops->get_protocol(dev, skb);
> +		if (unlikely(skb->protocol == htons(ETH_P_ALL)))
> +			return -EINVAL;
> +	} else {
> +		skb->protocol = proto;
> +	}
>  	skb->dev = dev;
>  	skb->priority = sk->sk_priority;
>  	skb->mark = sk->sk_mark;
> 
> -- 
> MST
