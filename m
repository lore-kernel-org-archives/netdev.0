From: Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>
Subject: Re: [PATCH 11/31]: net: Implement simple sw TX hashing.
Date: Thu, 17 Jul 2008 17:59:33 +0200
Message-ID: <87vdz4sdqy.fsf@basil.nowhere.org>
References: <20080717.051635.124264554.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080717.051635.124264554.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> (David Miller's message of "Thu, 17 Jul 2008 05:16:35 -0700 (PDT)")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> writes:

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

Could you add a linuxmib counter for this default event? Just so that 
people can diagnose this more easily.

> +
> +	ports = (u32 *) (skb_network_header(skb) + (ihl * 4));
> +
> +	hash = 0;
> +	while (alen--)
> +		hash ^= *addr++;

Are you sure the hash behaves the same between big endian and little
endian? Perhaps it would be safer to always convert endian even if
that complicates the code a bit.

> +		hash ^= *ports;
> +		break;
> +
> +	default:
> +		break;

And also a linuxmib counter here.

> +	}
> +
> +	return hash % dev->real_num_tx_queues;

I haven't rechecked it in detail, but I suspect some more
folding of higher bits would be better again for endian safety.

-Andi

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
