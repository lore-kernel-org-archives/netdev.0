From: Brice Goglin <Brice.Goglin@inria.fr>
Subject: Re: [PATCH 11/31]: net: Implement simple sw TX hashing.
Date: Sun, 03 Aug 2008 14:16:27 +0200
Message-ID: <4895A19B.5090307@inria.fr>
References: <20080717.051635.124264554.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, johannes@sipsolutions.net,
	linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g19.free.fr ([212.27.42.35]:55889 "EHLO smtp5-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753531AbYHCMQc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Aug 2008 08:16:32 -0400
In-Reply-To: <20080717.051635.124264554.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> It just xor hashes over IPv4/IPv6 addresses and ports of transport.
>
> The only assumption it makes is that skb_network_header() is set
> correctly.
>   

Hey David,

Sorry for the late reply, I didn't have time to look at multiqueue tx
details before. I have some curiosity-questions about your hashing.

> +static u16 simple_tx_hash(struct net_device *dev, struct sk_buff *skb)
> +{
> +	u32 *addr, *ports, hash, ihl;
> +	u8 ip_proto;
> +	int alen;
> +
> +	switch (skb->protocol) {
> +	case __constant_htons(ETH_P_IP):
> +		ip_proto = ip_hdr(skb)->protocol;
> +		addr = &ip_hdr(skb)->saddr;
> +		ihl = ip_hdr(skb)->ihl;
> +		alen = 2;
> +		break;
> +	case __constant_htons(ETH_P_IPV6):
> +		ip_proto = ipv6_hdr(skb)->nexthdr;
> +		addr = &ipv6_hdr(skb)->saddr.s6_addr32[0];
> +		ihl = (40 >> 2);
> +		alen = 8;
> +		break;
> +	default:
> +		return 0;
> +	}
>   

What's your plan for other protocols here? Should we add an optional
tx_hash() method in struct packet_type?

> @@ -1672,6 +1722,8 @@ static struct netdev_queue *dev_pick_tx(struct net_device *dev,
>  
>  	if (dev->select_queue)
>  		queue_index = dev->select_queue(dev, skb);
> +	else if (dev->real_num_tx_queues > 1)
> +		queue_index = simple_tx_hash(dev, skb);
>   

Some devices might will add some protocol specific hashing (IP and IPv6)
that could look like what simple_tx_hash() does above, right? But if we
add some new protocols in sample_tx_hash(), it will be ignored by these
devices, and we might have to update the hashing in all select_queue()
methods as well.

So I wonder if we shouldn't change all this into:
1) simple_tx_hash(skb) returns a big protocol-independent integer (like
a concatenation or basic xor of IP proto/addr/...). It basically just
converts the skb header in something flat and proto-independent.
2.a) if the device provides select_queue(), we pass this integer to it.
select_queue() either uses the skb headers if it really wants to hash IP
or IPv6 precisely, or uses our protocol-independent integer and just
hash it in a dumb way without caring about the protocol hidden behind it.
2.b) if there's no select_queue(), we hash the big integer depending on
the number of tx queues

This way, we can easily add some protocol specific hashing to all
drivers without having to modify select_queue() everywhere. Of course,
if we don't care about hashing anything but IP/IPv6, it doesn't matter :)

Brice

